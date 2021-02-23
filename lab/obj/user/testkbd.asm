
obj/user/testkbd.debug:     file format elf32-i386


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
  80002c:	e8 8b 02 00 00       	call   8002bc <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  800040:	e8 3d 0e 00 00       	call   800e82 <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800045:	4b                   	dec    %ebx
  800046:	75 f8                	jne    800040 <umain+0xc>
		sys_yield();

	close(0);
  800048:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80004f:	e8 ce 12 00 00       	call   801322 <close>
	if ((r = opencons()) < 0)
  800054:	e8 0f 02 00 00       	call   800268 <opencons>
  800059:	85 c0                	test   %eax,%eax
  80005b:	79 20                	jns    80007d <umain+0x49>
		panic("opencons: %e", r);
  80005d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800061:	c7 44 24 08 80 27 80 	movl   $0x802780,0x8(%esp)
  800068:	00 
  800069:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800070:	00 
  800071:	c7 04 24 8d 27 80 00 	movl   $0x80278d,(%esp)
  800078:	e8 af 02 00 00       	call   80032c <_panic>
	if (r != 0)
  80007d:	85 c0                	test   %eax,%eax
  80007f:	74 20                	je     8000a1 <umain+0x6d>
		panic("first opencons used fd %d", r);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 9c 27 80 	movl   $0x80279c,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 8d 27 80 00 	movl   $0x80278d,(%esp)
  80009c:	e8 8b 02 00 00       	call   80032c <_panic>
	if ((r = dup(0, 1)) < 0)
  8000a1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8000a8:	00 
  8000a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b0:	e8 be 12 00 00       	call   801373 <dup>
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	79 20                	jns    8000d9 <umain+0xa5>
		panic("dup: %e", r);
  8000b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bd:	c7 44 24 08 b6 27 80 	movl   $0x8027b6,0x8(%esp)
  8000c4:	00 
  8000c5:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8000cc:	00 
  8000cd:	c7 04 24 8d 27 80 00 	movl   $0x80278d,(%esp)
  8000d4:	e8 53 02 00 00       	call   80032c <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000d9:	c7 04 24 be 27 80 00 	movl   $0x8027be,(%esp)
  8000e0:	e8 b7 08 00 00       	call   80099c <readline>
		if (buf != NULL)
  8000e5:	85 c0                	test   %eax,%eax
  8000e7:	74 1a                	je     800103 <umain+0xcf>
			fprintf(1, "%s\n", buf);
  8000e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ed:	c7 44 24 04 cc 27 80 	movl   $0x8027cc,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000fc:	e8 ef 19 00 00       	call   801af0 <fprintf>
  800101:	eb d6                	jmp    8000d9 <umain+0xa5>
		else
			fprintf(1, "(end of file received)\n");
  800103:	c7 44 24 04 d0 27 80 	movl   $0x8027d0,0x4(%esp)
  80010a:	00 
  80010b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800112:	e8 d9 19 00 00       	call   801af0 <fprintf>
  800117:	eb c0                	jmp    8000d9 <umain+0xa5>
  800119:	00 00                	add    %al,(%eax)
	...

0080011c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80011f:	b8 00 00 00 00       	mov    $0x0,%eax
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    

00800126 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800126:	55                   	push   %ebp
  800127:	89 e5                	mov    %esp,%ebp
  800129:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80012c:	c7 44 24 04 e8 27 80 	movl   $0x8027e8,0x4(%esp)
  800133:	00 
  800134:	8b 45 0c             	mov    0xc(%ebp),%eax
  800137:	89 04 24             	mov    %eax,(%esp)
  80013a:	e8 70 09 00 00       	call   800aaf <strcpy>
	return 0;
}
  80013f:	b8 00 00 00 00       	mov    $0x0,%eax
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
  80014c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800152:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800157:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80015d:	eb 30                	jmp    80018f <devcons_write+0x49>
		m = n - tot;
  80015f:	8b 75 10             	mov    0x10(%ebp),%esi
  800162:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  800164:	83 fe 7f             	cmp    $0x7f,%esi
  800167:	76 05                	jbe    80016e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  800169:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80016e:	89 74 24 08          	mov    %esi,0x8(%esp)
  800172:	03 45 0c             	add    0xc(%ebp),%eax
  800175:	89 44 24 04          	mov    %eax,0x4(%esp)
  800179:	89 3c 24             	mov    %edi,(%esp)
  80017c:	e8 a7 0a 00 00       	call   800c28 <memmove>
		sys_cputs(buf, m);
  800181:	89 74 24 04          	mov    %esi,0x4(%esp)
  800185:	89 3c 24             	mov    %edi,(%esp)
  800188:	e8 47 0c 00 00       	call   800dd4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80018d:	01 f3                	add    %esi,%ebx
  80018f:	89 d8                	mov    %ebx,%eax
  800191:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800194:	72 c9                	jb     80015f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800196:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8001a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8001ab:	75 07                	jne    8001b4 <devcons_read+0x13>
  8001ad:	eb 25                	jmp    8001d4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8001af:	e8 ce 0c 00 00       	call   800e82 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8001b4:	e8 39 0c 00 00       	call   800df2 <sys_cgetc>
  8001b9:	85 c0                	test   %eax,%eax
  8001bb:	74 f2                	je     8001af <devcons_read+0xe>
  8001bd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8001bf:	85 c0                	test   %eax,%eax
  8001c1:	78 1d                	js     8001e0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8001c3:	83 f8 04             	cmp    $0x4,%eax
  8001c6:	74 13                	je     8001db <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8001c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001cb:	88 10                	mov    %dl,(%eax)
	return 1;
  8001cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8001d2:	eb 0c                	jmp    8001e0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8001d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001d9:	eb 05                	jmp    8001e0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8001db:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    

008001e2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8001e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001eb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001f5:	00 
  8001f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001f9:	89 04 24             	mov    %eax,(%esp)
  8001fc:	e8 d3 0b 00 00       	call   800dd4 <sys_cputs>
}
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <getchar>:

int
getchar(void)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800209:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800210:	00 
  800211:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800214:	89 44 24 04          	mov    %eax,0x4(%esp)
  800218:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80021f:	e8 64 12 00 00       	call   801488 <read>
	if (r < 0)
  800224:	85 c0                	test   %eax,%eax
  800226:	78 0f                	js     800237 <getchar+0x34>
		return r;
	if (r < 1)
  800228:	85 c0                	test   %eax,%eax
  80022a:	7e 06                	jle    800232 <getchar+0x2f>
		return -E_EOF;
	return c;
  80022c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800230:	eb 05                	jmp    800237 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800232:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80023f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800242:	89 44 24 04          	mov    %eax,0x4(%esp)
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	89 04 24             	mov    %eax,(%esp)
  80024c:	e8 99 0f 00 00       	call   8011ea <fd_lookup>
  800251:	85 c0                	test   %eax,%eax
  800253:	78 11                	js     800266 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800255:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800258:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80025e:	39 10                	cmp    %edx,(%eax)
  800260:	0f 94 c0             	sete   %al
  800263:	0f b6 c0             	movzbl %al,%eax
}
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <opencons>:

int
opencons(void)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80026e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800271:	89 04 24             	mov    %eax,(%esp)
  800274:	e8 1e 0f 00 00       	call   801197 <fd_alloc>
  800279:	85 c0                	test   %eax,%eax
  80027b:	78 3c                	js     8002b9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80027d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800284:	00 
  800285:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800293:	e8 09 0c 00 00       	call   800ea1 <sys_page_alloc>
  800298:	85 c0                	test   %eax,%eax
  80029a:	78 1d                	js     8002b9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80029c:	8b 15 00 30 80 00    	mov    0x803000,%edx
  8002a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8002a5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8002a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8002aa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8002b1:	89 04 24             	mov    %eax,(%esp)
  8002b4:	e8 b3 0e 00 00       	call   80116c <fd2num>
}
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    
	...

008002bc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 10             	sub    $0x10,%esp
  8002c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002ca:	e8 94 0b 00 00       	call   800e63 <sys_getenvid>
  8002cf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8002db:	c1 e0 07             	shl    $0x7,%eax
  8002de:	29 d0                	sub    %edx,%eax
  8002e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e5:	a3 08 44 80 00       	mov    %eax,0x804408


	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002ea:	85 f6                	test   %esi,%esi
  8002ec:	7e 07                	jle    8002f5 <libmain+0x39>
		binaryname = argv[0];
  8002ee:	8b 03                	mov    (%ebx),%eax
  8002f0:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  8002f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002f9:	89 34 24             	mov    %esi,(%esp)
  8002fc:	e8 33 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800301:	e8 0a 00 00 00       	call   800310 <exit>
}
  800306:	83 c4 10             	add    $0x10,%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    
  80030d:	00 00                	add    %al,(%eax)
	...

00800310 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800316:	e8 38 10 00 00       	call   801353 <close_all>
	sys_env_destroy(0);
  80031b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800322:	e8 ea 0a 00 00       	call   800e11 <sys_env_destroy>
}
  800327:	c9                   	leave  
  800328:	c3                   	ret    
  800329:	00 00                	add    %al,(%eax)
	...

0080032c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80032c:	55                   	push   %ebp
  80032d:	89 e5                	mov    %esp,%ebp
  80032f:	56                   	push   %esi
  800330:	53                   	push   %ebx
  800331:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800334:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800337:	8b 1d 1c 30 80 00    	mov    0x80301c,%ebx
  80033d:	e8 21 0b 00 00       	call   800e63 <sys_getenvid>
  800342:	8b 55 0c             	mov    0xc(%ebp),%edx
  800345:	89 54 24 10          	mov    %edx,0x10(%esp)
  800349:	8b 55 08             	mov    0x8(%ebp),%edx
  80034c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800350:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800354:	89 44 24 04          	mov    %eax,0x4(%esp)
  800358:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  80035f:	e8 c0 00 00 00       	call   800424 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800364:	89 74 24 04          	mov    %esi,0x4(%esp)
  800368:	8b 45 10             	mov    0x10(%ebp),%eax
  80036b:	89 04 24             	mov    %eax,(%esp)
  80036e:	e8 50 00 00 00       	call   8003c3 <vcprintf>
	cprintf("\n");
  800373:	c7 04 24 e6 27 80 00 	movl   $0x8027e6,(%esp)
  80037a:	e8 a5 00 00 00       	call   800424 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80037f:	cc                   	int3   
  800380:	eb fd                	jmp    80037f <_panic+0x53>
	...

00800384 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	53                   	push   %ebx
  800388:	83 ec 14             	sub    $0x14,%esp
  80038b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038e:	8b 03                	mov    (%ebx),%eax
  800390:	8b 55 08             	mov    0x8(%ebp),%edx
  800393:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800397:	40                   	inc    %eax
  800398:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80039a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80039f:	75 19                	jne    8003ba <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8003a1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003a8:	00 
  8003a9:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ac:	89 04 24             	mov    %eax,(%esp)
  8003af:	e8 20 0a 00 00       	call   800dd4 <sys_cputs>
		b->idx = 0;
  8003b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003ba:	ff 43 04             	incl   0x4(%ebx)
}
  8003bd:	83 c4 14             	add    $0x14,%esp
  8003c0:	5b                   	pop    %ebx
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    

008003c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8003cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d3:	00 00 00 
	b.cnt = 0;
  8003d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ee:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f8:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  8003ff:	e8 82 01 00 00       	call   800586 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800404:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80040a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80040e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800414:	89 04 24             	mov    %eax,(%esp)
  800417:	e8 b8 09 00 00       	call   800dd4 <sys_cputs>

	return b.cnt;
}
  80041c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800422:	c9                   	leave  
  800423:	c3                   	ret    

00800424 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80042a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80042d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800431:	8b 45 08             	mov    0x8(%ebp),%eax
  800434:	89 04 24             	mov    %eax,(%esp)
  800437:	e8 87 ff ff ff       	call   8003c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80043c:	c9                   	leave  
  80043d:	c3                   	ret    
	...

00800440 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
  800443:	57                   	push   %edi
  800444:	56                   	push   %esi
  800445:	53                   	push   %ebx
  800446:	83 ec 3c             	sub    $0x3c,%esp
  800449:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044c:	89 d7                	mov    %edx,%edi
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800454:	8b 45 0c             	mov    0xc(%ebp),%eax
  800457:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80045a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80045d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800460:	85 c0                	test   %eax,%eax
  800462:	75 08                	jne    80046c <printnum+0x2c>
  800464:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800467:	39 45 10             	cmp    %eax,0x10(%ebp)
  80046a:	77 57                	ja     8004c3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80046c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800470:	4b                   	dec    %ebx
  800471:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800475:	8b 45 10             	mov    0x10(%ebp),%eax
  800478:	89 44 24 08          	mov    %eax,0x8(%esp)
  80047c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800480:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800484:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80048b:	00 
  80048c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80048f:	89 04 24             	mov    %eax,(%esp)
  800492:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800495:	89 44 24 04          	mov    %eax,0x4(%esp)
  800499:	e8 86 20 00 00       	call   802524 <__udivdi3>
  80049e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004a2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004a6:	89 04 24             	mov    %eax,(%esp)
  8004a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004ad:	89 fa                	mov    %edi,%edx
  8004af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004b2:	e8 89 ff ff ff       	call   800440 <printnum>
  8004b7:	eb 0f                	jmp    8004c8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004b9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004bd:	89 34 24             	mov    %esi,(%esp)
  8004c0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004c3:	4b                   	dec    %ebx
  8004c4:	85 db                	test   %ebx,%ebx
  8004c6:	7f f1                	jg     8004b9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004cc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8004d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004de:	00 
  8004df:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004e2:	89 04 24             	mov    %eax,(%esp)
  8004e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ec:	e8 53 21 00 00       	call   802644 <__umoddi3>
  8004f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8004f5:	0f be 80 23 28 80 00 	movsbl 0x802823(%eax),%eax
  8004fc:	89 04 24             	mov    %eax,(%esp)
  8004ff:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800502:	83 c4 3c             	add    $0x3c,%esp
  800505:	5b                   	pop    %ebx
  800506:	5e                   	pop    %esi
  800507:	5f                   	pop    %edi
  800508:	5d                   	pop    %ebp
  800509:	c3                   	ret    

0080050a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80050d:	83 fa 01             	cmp    $0x1,%edx
  800510:	7e 0e                	jle    800520 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800512:	8b 10                	mov    (%eax),%edx
  800514:	8d 4a 08             	lea    0x8(%edx),%ecx
  800517:	89 08                	mov    %ecx,(%eax)
  800519:	8b 02                	mov    (%edx),%eax
  80051b:	8b 52 04             	mov    0x4(%edx),%edx
  80051e:	eb 22                	jmp    800542 <getuint+0x38>
	else if (lflag)
  800520:	85 d2                	test   %edx,%edx
  800522:	74 10                	je     800534 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800524:	8b 10                	mov    (%eax),%edx
  800526:	8d 4a 04             	lea    0x4(%edx),%ecx
  800529:	89 08                	mov    %ecx,(%eax)
  80052b:	8b 02                	mov    (%edx),%eax
  80052d:	ba 00 00 00 00       	mov    $0x0,%edx
  800532:	eb 0e                	jmp    800542 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800534:	8b 10                	mov    (%eax),%edx
  800536:	8d 4a 04             	lea    0x4(%edx),%ecx
  800539:	89 08                	mov    %ecx,(%eax)
  80053b:	8b 02                	mov    (%edx),%eax
  80053d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800542:	5d                   	pop    %ebp
  800543:	c3                   	ret    

00800544 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80054a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80054d:	8b 10                	mov    (%eax),%edx
  80054f:	3b 50 04             	cmp    0x4(%eax),%edx
  800552:	73 08                	jae    80055c <sprintputch+0x18>
		*b->buf++ = ch;
  800554:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800557:	88 0a                	mov    %cl,(%edx)
  800559:	42                   	inc    %edx
  80055a:	89 10                	mov    %edx,(%eax)
}
  80055c:	5d                   	pop    %ebp
  80055d:	c3                   	ret    

0080055e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80055e:	55                   	push   %ebp
  80055f:	89 e5                	mov    %esp,%ebp
  800561:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800564:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800567:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80056b:	8b 45 10             	mov    0x10(%ebp),%eax
  80056e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800572:	8b 45 0c             	mov    0xc(%ebp),%eax
  800575:	89 44 24 04          	mov    %eax,0x4(%esp)
  800579:	8b 45 08             	mov    0x8(%ebp),%eax
  80057c:	89 04 24             	mov    %eax,(%esp)
  80057f:	e8 02 00 00 00       	call   800586 <vprintfmt>
	va_end(ap);
}
  800584:	c9                   	leave  
  800585:	c3                   	ret    

00800586 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800586:	55                   	push   %ebp
  800587:	89 e5                	mov    %esp,%ebp
  800589:	57                   	push   %edi
  80058a:	56                   	push   %esi
  80058b:	53                   	push   %ebx
  80058c:	83 ec 4c             	sub    $0x4c,%esp
  80058f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800592:	8b 75 10             	mov    0x10(%ebp),%esi
  800595:	eb 12                	jmp    8005a9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800597:	85 c0                	test   %eax,%eax
  800599:	0f 84 6b 03 00 00    	je     80090a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80059f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a3:	89 04 24             	mov    %eax,(%esp)
  8005a6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005a9:	0f b6 06             	movzbl (%esi),%eax
  8005ac:	46                   	inc    %esi
  8005ad:	83 f8 25             	cmp    $0x25,%eax
  8005b0:	75 e5                	jne    800597 <vprintfmt+0x11>
  8005b2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8005b6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8005bd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8005c2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8005c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ce:	eb 26                	jmp    8005f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8005d3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8005d7:	eb 1d                	jmp    8005f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005dc:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8005e0:	eb 14                	jmp    8005f6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8005e5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005ec:	eb 08                	jmp    8005f6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8005ee:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005f1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	0f b6 06             	movzbl (%esi),%eax
  8005f9:	8d 56 01             	lea    0x1(%esi),%edx
  8005fc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005ff:	8a 16                	mov    (%esi),%dl
  800601:	83 ea 23             	sub    $0x23,%edx
  800604:	80 fa 55             	cmp    $0x55,%dl
  800607:	0f 87 e1 02 00 00    	ja     8008ee <vprintfmt+0x368>
  80060d:	0f b6 d2             	movzbl %dl,%edx
  800610:	ff 24 95 60 29 80 00 	jmp    *0x802960(,%edx,4)
  800617:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80061a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80061f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800622:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800626:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800629:	8d 50 d0             	lea    -0x30(%eax),%edx
  80062c:	83 fa 09             	cmp    $0x9,%edx
  80062f:	77 2a                	ja     80065b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800631:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800632:	eb eb                	jmp    80061f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)
  80063d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800642:	eb 17                	jmp    80065b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800644:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800648:	78 98                	js     8005e2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80064d:	eb a7                	jmp    8005f6 <vprintfmt+0x70>
  80064f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800652:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800659:	eb 9b                	jmp    8005f6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80065b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80065f:	79 95                	jns    8005f6 <vprintfmt+0x70>
  800661:	eb 8b                	jmp    8005ee <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800663:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800667:	eb 8d                	jmp    8005f6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 50 04             	lea    0x4(%eax),%edx
  80066f:	89 55 14             	mov    %edx,0x14(%ebp)
  800672:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800676:	8b 00                	mov    (%eax),%eax
  800678:	89 04 24             	mov    %eax,(%esp)
  80067b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800681:	e9 23 ff ff ff       	jmp    8005a9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 50 04             	lea    0x4(%eax),%edx
  80068c:	89 55 14             	mov    %edx,0x14(%ebp)
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	85 c0                	test   %eax,%eax
  800693:	79 02                	jns    800697 <vprintfmt+0x111>
  800695:	f7 d8                	neg    %eax
  800697:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800699:	83 f8 10             	cmp    $0x10,%eax
  80069c:	7f 0b                	jg     8006a9 <vprintfmt+0x123>
  80069e:	8b 04 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%eax
  8006a5:	85 c0                	test   %eax,%eax
  8006a7:	75 23                	jne    8006cc <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8006a9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006ad:	c7 44 24 08 3b 28 80 	movl   $0x80283b,0x8(%esp)
  8006b4:	00 
  8006b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bc:	89 04 24             	mov    %eax,(%esp)
  8006bf:	e8 9a fe ff ff       	call   80055e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8006c7:	e9 dd fe ff ff       	jmp    8005a9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8006cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d0:	c7 44 24 08 0d 2c 80 	movl   $0x802c0d,0x8(%esp)
  8006d7:	00 
  8006d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8006df:	89 14 24             	mov    %edx,(%esp)
  8006e2:	e8 77 fe ff ff       	call   80055e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ea:	e9 ba fe ff ff       	jmp    8005a9 <vprintfmt+0x23>
  8006ef:	89 f9                	mov    %edi,%ecx
  8006f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 30                	mov    (%eax),%esi
  800702:	85 f6                	test   %esi,%esi
  800704:	75 05                	jne    80070b <vprintfmt+0x185>
				p = "(null)";
  800706:	be 34 28 80 00       	mov    $0x802834,%esi
			if (width > 0 && padc != '-')
  80070b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80070f:	0f 8e 84 00 00 00    	jle    800799 <vprintfmt+0x213>
  800715:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800719:	74 7e                	je     800799 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80071b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80071f:	89 34 24             	mov    %esi,(%esp)
  800722:	e8 6b 03 00 00       	call   800a92 <strnlen>
  800727:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80072a:	29 c2                	sub    %eax,%edx
  80072c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80072f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800733:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800736:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800739:	89 de                	mov    %ebx,%esi
  80073b:	89 d3                	mov    %edx,%ebx
  80073d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80073f:	eb 0b                	jmp    80074c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800741:	89 74 24 04          	mov    %esi,0x4(%esp)
  800745:	89 3c 24             	mov    %edi,(%esp)
  800748:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80074b:	4b                   	dec    %ebx
  80074c:	85 db                	test   %ebx,%ebx
  80074e:	7f f1                	jg     800741 <vprintfmt+0x1bb>
  800750:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800753:	89 f3                	mov    %esi,%ebx
  800755:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800758:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80075b:	85 c0                	test   %eax,%eax
  80075d:	79 05                	jns    800764 <vprintfmt+0x1de>
  80075f:	b8 00 00 00 00       	mov    $0x0,%eax
  800764:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800767:	29 c2                	sub    %eax,%edx
  800769:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80076c:	eb 2b                	jmp    800799 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80076e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800772:	74 18                	je     80078c <vprintfmt+0x206>
  800774:	8d 50 e0             	lea    -0x20(%eax),%edx
  800777:	83 fa 5e             	cmp    $0x5e,%edx
  80077a:	76 10                	jbe    80078c <vprintfmt+0x206>
					putch('?', putdat);
  80077c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800780:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800787:	ff 55 08             	call   *0x8(%ebp)
  80078a:	eb 0a                	jmp    800796 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80078c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800790:	89 04 24             	mov    %eax,(%esp)
  800793:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800796:	ff 4d e4             	decl   -0x1c(%ebp)
  800799:	0f be 06             	movsbl (%esi),%eax
  80079c:	46                   	inc    %esi
  80079d:	85 c0                	test   %eax,%eax
  80079f:	74 21                	je     8007c2 <vprintfmt+0x23c>
  8007a1:	85 ff                	test   %edi,%edi
  8007a3:	78 c9                	js     80076e <vprintfmt+0x1e8>
  8007a5:	4f                   	dec    %edi
  8007a6:	79 c6                	jns    80076e <vprintfmt+0x1e8>
  8007a8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ab:	89 de                	mov    %ebx,%esi
  8007ad:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007b0:	eb 18                	jmp    8007ca <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007bd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007bf:	4b                   	dec    %ebx
  8007c0:	eb 08                	jmp    8007ca <vprintfmt+0x244>
  8007c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007c5:	89 de                	mov    %ebx,%esi
  8007c7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8007ca:	85 db                	test   %ebx,%ebx
  8007cc:	7f e4                	jg     8007b2 <vprintfmt+0x22c>
  8007ce:	89 7d 08             	mov    %edi,0x8(%ebp)
  8007d1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007d6:	e9 ce fd ff ff       	jmp    8005a9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007db:	83 f9 01             	cmp    $0x1,%ecx
  8007de:	7e 10                	jle    8007f0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8d 50 08             	lea    0x8(%eax),%edx
  8007e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e9:	8b 30                	mov    (%eax),%esi
  8007eb:	8b 78 04             	mov    0x4(%eax),%edi
  8007ee:	eb 26                	jmp    800816 <vprintfmt+0x290>
	else if (lflag)
  8007f0:	85 c9                	test   %ecx,%ecx
  8007f2:	74 12                	je     800806 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8007f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f7:	8d 50 04             	lea    0x4(%eax),%edx
  8007fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fd:	8b 30                	mov    (%eax),%esi
  8007ff:	89 f7                	mov    %esi,%edi
  800801:	c1 ff 1f             	sar    $0x1f,%edi
  800804:	eb 10                	jmp    800816 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8d 50 04             	lea    0x4(%eax),%edx
  80080c:	89 55 14             	mov    %edx,0x14(%ebp)
  80080f:	8b 30                	mov    (%eax),%esi
  800811:	89 f7                	mov    %esi,%edi
  800813:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800816:	85 ff                	test   %edi,%edi
  800818:	78 0a                	js     800824 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80081a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081f:	e9 8c 00 00 00       	jmp    8008b0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800824:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800828:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80082f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800832:	f7 de                	neg    %esi
  800834:	83 d7 00             	adc    $0x0,%edi
  800837:	f7 df                	neg    %edi
			}
			base = 10;
  800839:	b8 0a 00 00 00       	mov    $0xa,%eax
  80083e:	eb 70                	jmp    8008b0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800840:	89 ca                	mov    %ecx,%edx
  800842:	8d 45 14             	lea    0x14(%ebp),%eax
  800845:	e8 c0 fc ff ff       	call   80050a <getuint>
  80084a:	89 c6                	mov    %eax,%esi
  80084c:	89 d7                	mov    %edx,%edi
			base = 10;
  80084e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800853:	eb 5b                	jmp    8008b0 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800855:	89 ca                	mov    %ecx,%edx
  800857:	8d 45 14             	lea    0x14(%ebp),%eax
  80085a:	e8 ab fc ff ff       	call   80050a <getuint>
  80085f:	89 c6                	mov    %eax,%esi
  800861:	89 d7                	mov    %edx,%edi
			base = 8;
  800863:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800868:	eb 46                	jmp    8008b0 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80086a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800875:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800878:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800883:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800886:	8b 45 14             	mov    0x14(%ebp),%eax
  800889:	8d 50 04             	lea    0x4(%eax),%edx
  80088c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80088f:	8b 30                	mov    (%eax),%esi
  800891:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800896:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80089b:	eb 13                	jmp    8008b0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80089d:	89 ca                	mov    %ecx,%edx
  80089f:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a2:	e8 63 fc ff ff       	call   80050a <getuint>
  8008a7:	89 c6                	mov    %eax,%esi
  8008a9:	89 d7                	mov    %edx,%edi
			base = 16;
  8008ab:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008b0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8008b4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8008b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c3:	89 34 24             	mov    %esi,(%esp)
  8008c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008ca:	89 da                	mov    %ebx,%edx
  8008cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cf:	e8 6c fb ff ff       	call   800440 <printnum>
			break;
  8008d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008d7:	e9 cd fc ff ff       	jmp    8005a9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e0:	89 04 24             	mov    %eax,(%esp)
  8008e3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008e9:	e9 bb fc ff ff       	jmp    8005a9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008f2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008f9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008fc:	eb 01                	jmp    8008ff <vprintfmt+0x379>
  8008fe:	4e                   	dec    %esi
  8008ff:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800903:	75 f9                	jne    8008fe <vprintfmt+0x378>
  800905:	e9 9f fc ff ff       	jmp    8005a9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80090a:	83 c4 4c             	add    $0x4c,%esp
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	83 ec 28             	sub    $0x28,%esp
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80091e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800921:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800925:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800928:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80092f:	85 c0                	test   %eax,%eax
  800931:	74 30                	je     800963 <vsnprintf+0x51>
  800933:	85 d2                	test   %edx,%edx
  800935:	7e 33                	jle    80096a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800937:	8b 45 14             	mov    0x14(%ebp),%eax
  80093a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80093e:	8b 45 10             	mov    0x10(%ebp),%eax
  800941:	89 44 24 08          	mov    %eax,0x8(%esp)
  800945:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800948:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094c:	c7 04 24 44 05 80 00 	movl   $0x800544,(%esp)
  800953:	e8 2e fc ff ff       	call   800586 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800958:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80095b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80095e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800961:	eb 0c                	jmp    80096f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800963:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800968:	eb 05                	jmp    80096f <vsnprintf+0x5d>
  80096a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80096f:	c9                   	leave  
  800970:	c3                   	ret    

00800971 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800977:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80097a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80097e:	8b 45 10             	mov    0x10(%ebp),%eax
  800981:	89 44 24 08          	mov    %eax,0x8(%esp)
  800985:	8b 45 0c             	mov    0xc(%ebp),%eax
  800988:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	89 04 24             	mov    %eax,(%esp)
  800992:	e8 7b ff ff ff       	call   800912 <vsnprintf>
	va_end(ap);

	return rc;
}
  800997:	c9                   	leave  
  800998:	c3                   	ret    
  800999:	00 00                	add    %al,(%eax)
	...

0080099c <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	57                   	push   %edi
  8009a0:	56                   	push   %esi
  8009a1:	53                   	push   %ebx
  8009a2:	83 ec 1c             	sub    $0x1c,%esp
  8009a5:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8009a8:	85 c0                	test   %eax,%eax
  8009aa:	74 18                	je     8009c4 <readline+0x28>
		fprintf(1, "%s", prompt);
  8009ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b0:	c7 44 24 04 0d 2c 80 	movl   $0x802c0d,0x4(%esp)
  8009b7:	00 
  8009b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8009bf:	e8 2c 11 00 00       	call   801af0 <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  8009c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009cb:	e8 69 f8 ff ff       	call   800239 <iscons>
  8009d0:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8009d2:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8009d7:	e8 27 f8 ff ff       	call   800203 <getchar>
  8009dc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8009de:	85 c0                	test   %eax,%eax
  8009e0:	79 20                	jns    800a02 <readline+0x66>
			if (c != -E_EOF)
  8009e2:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8009e5:	0f 84 82 00 00 00    	je     800a6d <readline+0xd1>
				cprintf("read error: %e\n", c);
  8009eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ef:	c7 04 24 23 2b 80 00 	movl   $0x802b23,(%esp)
  8009f6:	e8 29 fa ff ff       	call   800424 <cprintf>
			return NULL;
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800a00:	eb 70                	jmp    800a72 <readline+0xd6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800a02:	83 f8 08             	cmp    $0x8,%eax
  800a05:	74 05                	je     800a0c <readline+0x70>
  800a07:	83 f8 7f             	cmp    $0x7f,%eax
  800a0a:	75 17                	jne    800a23 <readline+0x87>
  800a0c:	85 f6                	test   %esi,%esi
  800a0e:	7e 13                	jle    800a23 <readline+0x87>
			if (echoing)
  800a10:	85 ff                	test   %edi,%edi
  800a12:	74 0c                	je     800a20 <readline+0x84>
				cputchar('\b');
  800a14:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800a1b:	e8 c2 f7 ff ff       	call   8001e2 <cputchar>
			i--;
  800a20:	4e                   	dec    %esi
  800a21:	eb b4                	jmp    8009d7 <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800a23:	83 fb 1f             	cmp    $0x1f,%ebx
  800a26:	7e 1d                	jle    800a45 <readline+0xa9>
  800a28:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800a2e:	7f 15                	jg     800a45 <readline+0xa9>
			if (echoing)
  800a30:	85 ff                	test   %edi,%edi
  800a32:	74 08                	je     800a3c <readline+0xa0>
				cputchar(c);
  800a34:	89 1c 24             	mov    %ebx,(%esp)
  800a37:	e8 a6 f7 ff ff       	call   8001e2 <cputchar>
			buf[i++] = c;
  800a3c:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  800a42:	46                   	inc    %esi
  800a43:	eb 92                	jmp    8009d7 <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  800a45:	83 fb 0a             	cmp    $0xa,%ebx
  800a48:	74 05                	je     800a4f <readline+0xb3>
  800a4a:	83 fb 0d             	cmp    $0xd,%ebx
  800a4d:	75 88                	jne    8009d7 <readline+0x3b>
			if (echoing)
  800a4f:	85 ff                	test   %edi,%edi
  800a51:	74 0c                	je     800a5f <readline+0xc3>
				cputchar('\n');
  800a53:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800a5a:	e8 83 f7 ff ff       	call   8001e2 <cputchar>
			buf[i] = 0;
  800a5f:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800a66:	b8 00 40 80 00       	mov    $0x804000,%eax
  800a6b:	eb 05                	jmp    800a72 <readline+0xd6>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  800a72:	83 c4 1c             	add    $0x1c,%esp
  800a75:	5b                   	pop    %ebx
  800a76:	5e                   	pop    %esi
  800a77:	5f                   	pop    %edi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    
	...

00800a7c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
  800a87:	eb 01                	jmp    800a8a <strlen+0xe>
		n++;
  800a89:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a8a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a8e:	75 f9                	jne    800a89 <strlen+0xd>
		n++;
	return n;
}
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a98:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa0:	eb 01                	jmp    800aa3 <strnlen+0x11>
		n++;
  800aa2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800aa3:	39 d0                	cmp    %edx,%eax
  800aa5:	74 06                	je     800aad <strnlen+0x1b>
  800aa7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800aab:	75 f5                	jne    800aa2 <strnlen+0x10>
		n++;
	return n;
}
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	53                   	push   %ebx
  800ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ab9:	ba 00 00 00 00       	mov    $0x0,%edx
  800abe:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800ac1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ac4:	42                   	inc    %edx
  800ac5:	84 c9                	test   %cl,%cl
  800ac7:	75 f5                	jne    800abe <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strcat>:

char *
strcat(char *dst, const char *src)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	53                   	push   %ebx
  800ad0:	83 ec 08             	sub    $0x8,%esp
  800ad3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ad6:	89 1c 24             	mov    %ebx,(%esp)
  800ad9:	e8 9e ff ff ff       	call   800a7c <strlen>
	strcpy(dst + len, src);
  800ade:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ae5:	01 d8                	add    %ebx,%eax
  800ae7:	89 04 24             	mov    %eax,(%esp)
  800aea:	e8 c0 ff ff ff       	call   800aaf <strcpy>
	return dst;
}
  800aef:	89 d8                	mov    %ebx,%eax
  800af1:	83 c4 08             	add    $0x8,%esp
  800af4:	5b                   	pop    %ebx
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b02:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b0a:	eb 0c                	jmp    800b18 <strncpy+0x21>
		*dst++ = *src;
  800b0c:	8a 1a                	mov    (%edx),%bl
  800b0e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b11:	80 3a 01             	cmpb   $0x1,(%edx)
  800b14:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b17:	41                   	inc    %ecx
  800b18:	39 f1                	cmp    %esi,%ecx
  800b1a:	75 f0                	jne    800b0c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	8b 75 08             	mov    0x8(%ebp),%esi
  800b28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b2e:	85 d2                	test   %edx,%edx
  800b30:	75 0a                	jne    800b3c <strlcpy+0x1c>
  800b32:	89 f0                	mov    %esi,%eax
  800b34:	eb 1a                	jmp    800b50 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800b36:	88 18                	mov    %bl,(%eax)
  800b38:	40                   	inc    %eax
  800b39:	41                   	inc    %ecx
  800b3a:	eb 02                	jmp    800b3e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b3c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800b3e:	4a                   	dec    %edx
  800b3f:	74 0a                	je     800b4b <strlcpy+0x2b>
  800b41:	8a 19                	mov    (%ecx),%bl
  800b43:	84 db                	test   %bl,%bl
  800b45:	75 ef                	jne    800b36 <strlcpy+0x16>
  800b47:	89 c2                	mov    %eax,%edx
  800b49:	eb 02                	jmp    800b4d <strlcpy+0x2d>
  800b4b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b4d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b50:	29 f0                	sub    %esi,%eax
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5d                   	pop    %ebp
  800b55:	c3                   	ret    

00800b56 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b5f:	eb 02                	jmp    800b63 <strcmp+0xd>
		p++, q++;
  800b61:	41                   	inc    %ecx
  800b62:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b63:	8a 01                	mov    (%ecx),%al
  800b65:	84 c0                	test   %al,%al
  800b67:	74 04                	je     800b6d <strcmp+0x17>
  800b69:	3a 02                	cmp    (%edx),%al
  800b6b:	74 f4                	je     800b61 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b6d:	0f b6 c0             	movzbl %al,%eax
  800b70:	0f b6 12             	movzbl (%edx),%edx
  800b73:	29 d0                	sub    %edx,%eax
}
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	53                   	push   %ebx
  800b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b81:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b84:	eb 03                	jmp    800b89 <strncmp+0x12>
		n--, p++, q++;
  800b86:	4a                   	dec    %edx
  800b87:	40                   	inc    %eax
  800b88:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b89:	85 d2                	test   %edx,%edx
  800b8b:	74 14                	je     800ba1 <strncmp+0x2a>
  800b8d:	8a 18                	mov    (%eax),%bl
  800b8f:	84 db                	test   %bl,%bl
  800b91:	74 04                	je     800b97 <strncmp+0x20>
  800b93:	3a 19                	cmp    (%ecx),%bl
  800b95:	74 ef                	je     800b86 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b97:	0f b6 00             	movzbl (%eax),%eax
  800b9a:	0f b6 11             	movzbl (%ecx),%edx
  800b9d:	29 d0                	sub    %edx,%eax
  800b9f:	eb 05                	jmp    800ba6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ba1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ba6:	5b                   	pop    %ebx
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    

00800ba9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ba9:	55                   	push   %ebp
  800baa:	89 e5                	mov    %esp,%ebp
  800bac:	8b 45 08             	mov    0x8(%ebp),%eax
  800baf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bb2:	eb 05                	jmp    800bb9 <strchr+0x10>
		if (*s == c)
  800bb4:	38 ca                	cmp    %cl,%dl
  800bb6:	74 0c                	je     800bc4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bb8:	40                   	inc    %eax
  800bb9:	8a 10                	mov    (%eax),%dl
  800bbb:	84 d2                	test   %dl,%dl
  800bbd:	75 f5                	jne    800bb4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800bcf:	eb 05                	jmp    800bd6 <strfind+0x10>
		if (*s == c)
  800bd1:	38 ca                	cmp    %cl,%dl
  800bd3:	74 07                	je     800bdc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bd5:	40                   	inc    %eax
  800bd6:	8a 10                	mov    (%eax),%dl
  800bd8:	84 d2                	test   %dl,%dl
  800bda:	75 f5                	jne    800bd1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800be7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bed:	85 c9                	test   %ecx,%ecx
  800bef:	74 30                	je     800c21 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bf1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bf7:	75 25                	jne    800c1e <memset+0x40>
  800bf9:	f6 c1 03             	test   $0x3,%cl
  800bfc:	75 20                	jne    800c1e <memset+0x40>
		c &= 0xFF;
  800bfe:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c01:	89 d3                	mov    %edx,%ebx
  800c03:	c1 e3 08             	shl    $0x8,%ebx
  800c06:	89 d6                	mov    %edx,%esi
  800c08:	c1 e6 18             	shl    $0x18,%esi
  800c0b:	89 d0                	mov    %edx,%eax
  800c0d:	c1 e0 10             	shl    $0x10,%eax
  800c10:	09 f0                	or     %esi,%eax
  800c12:	09 d0                	or     %edx,%eax
  800c14:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800c16:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800c19:	fc                   	cld    
  800c1a:	f3 ab                	rep stos %eax,%es:(%edi)
  800c1c:	eb 03                	jmp    800c21 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c1e:	fc                   	cld    
  800c1f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c21:	89 f8                	mov    %edi,%eax
  800c23:	5b                   	pop    %ebx
  800c24:	5e                   	pop    %esi
  800c25:	5f                   	pop    %edi
  800c26:	5d                   	pop    %ebp
  800c27:	c3                   	ret    

00800c28 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	57                   	push   %edi
  800c2c:	56                   	push   %esi
  800c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c30:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c33:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c36:	39 c6                	cmp    %eax,%esi
  800c38:	73 34                	jae    800c6e <memmove+0x46>
  800c3a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c3d:	39 d0                	cmp    %edx,%eax
  800c3f:	73 2d                	jae    800c6e <memmove+0x46>
		s += n;
		d += n;
  800c41:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c44:	f6 c2 03             	test   $0x3,%dl
  800c47:	75 1b                	jne    800c64 <memmove+0x3c>
  800c49:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c4f:	75 13                	jne    800c64 <memmove+0x3c>
  800c51:	f6 c1 03             	test   $0x3,%cl
  800c54:	75 0e                	jne    800c64 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c56:	83 ef 04             	sub    $0x4,%edi
  800c59:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c5c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c5f:	fd                   	std    
  800c60:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c62:	eb 07                	jmp    800c6b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c64:	4f                   	dec    %edi
  800c65:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c68:	fd                   	std    
  800c69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c6b:	fc                   	cld    
  800c6c:	eb 20                	jmp    800c8e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c74:	75 13                	jne    800c89 <memmove+0x61>
  800c76:	a8 03                	test   $0x3,%al
  800c78:	75 0f                	jne    800c89 <memmove+0x61>
  800c7a:	f6 c1 03             	test   $0x3,%cl
  800c7d:	75 0a                	jne    800c89 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c7f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c82:	89 c7                	mov    %eax,%edi
  800c84:	fc                   	cld    
  800c85:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c87:	eb 05                	jmp    800c8e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c89:	89 c7                	mov    %eax,%edi
  800c8b:	fc                   	cld    
  800c8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c98:	8b 45 10             	mov    0x10(%ebp),%eax
  800c9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca9:	89 04 24             	mov    %eax,(%esp)
  800cac:	e8 77 ff ff ff       	call   800c28 <memmove>
}
  800cb1:	c9                   	leave  
  800cb2:	c3                   	ret    

00800cb3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	8b 7d 08             	mov    0x8(%ebp),%edi
  800cbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc7:	eb 16                	jmp    800cdf <memcmp+0x2c>
		if (*s1 != *s2)
  800cc9:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ccc:	42                   	inc    %edx
  800ccd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800cd1:	38 c8                	cmp    %cl,%al
  800cd3:	74 0a                	je     800cdf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800cd5:	0f b6 c0             	movzbl %al,%eax
  800cd8:	0f b6 c9             	movzbl %cl,%ecx
  800cdb:	29 c8                	sub    %ecx,%eax
  800cdd:	eb 09                	jmp    800ce8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cdf:	39 da                	cmp    %ebx,%edx
  800ce1:	75 e6                	jne    800cc9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ce3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    

00800ced <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cf6:	89 c2                	mov    %eax,%edx
  800cf8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cfb:	eb 05                	jmp    800d02 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cfd:	38 08                	cmp    %cl,(%eax)
  800cff:	74 05                	je     800d06 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d01:	40                   	inc    %eax
  800d02:	39 d0                	cmp    %edx,%eax
  800d04:	72 f7                	jb     800cfd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d14:	eb 01                	jmp    800d17 <strtol+0xf>
		s++;
  800d16:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d17:	8a 02                	mov    (%edx),%al
  800d19:	3c 20                	cmp    $0x20,%al
  800d1b:	74 f9                	je     800d16 <strtol+0xe>
  800d1d:	3c 09                	cmp    $0x9,%al
  800d1f:	74 f5                	je     800d16 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d21:	3c 2b                	cmp    $0x2b,%al
  800d23:	75 08                	jne    800d2d <strtol+0x25>
		s++;
  800d25:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d26:	bf 00 00 00 00       	mov    $0x0,%edi
  800d2b:	eb 13                	jmp    800d40 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800d2d:	3c 2d                	cmp    $0x2d,%al
  800d2f:	75 0a                	jne    800d3b <strtol+0x33>
		s++, neg = 1;
  800d31:	8d 52 01             	lea    0x1(%edx),%edx
  800d34:	bf 01 00 00 00       	mov    $0x1,%edi
  800d39:	eb 05                	jmp    800d40 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800d3b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d40:	85 db                	test   %ebx,%ebx
  800d42:	74 05                	je     800d49 <strtol+0x41>
  800d44:	83 fb 10             	cmp    $0x10,%ebx
  800d47:	75 28                	jne    800d71 <strtol+0x69>
  800d49:	8a 02                	mov    (%edx),%al
  800d4b:	3c 30                	cmp    $0x30,%al
  800d4d:	75 10                	jne    800d5f <strtol+0x57>
  800d4f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d53:	75 0a                	jne    800d5f <strtol+0x57>
		s += 2, base = 16;
  800d55:	83 c2 02             	add    $0x2,%edx
  800d58:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d5d:	eb 12                	jmp    800d71 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d5f:	85 db                	test   %ebx,%ebx
  800d61:	75 0e                	jne    800d71 <strtol+0x69>
  800d63:	3c 30                	cmp    $0x30,%al
  800d65:	75 05                	jne    800d6c <strtol+0x64>
		s++, base = 8;
  800d67:	42                   	inc    %edx
  800d68:	b3 08                	mov    $0x8,%bl
  800d6a:	eb 05                	jmp    800d71 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d6c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d71:	b8 00 00 00 00       	mov    $0x0,%eax
  800d76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d78:	8a 0a                	mov    (%edx),%cl
  800d7a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d7d:	80 fb 09             	cmp    $0x9,%bl
  800d80:	77 08                	ja     800d8a <strtol+0x82>
			dig = *s - '0';
  800d82:	0f be c9             	movsbl %cl,%ecx
  800d85:	83 e9 30             	sub    $0x30,%ecx
  800d88:	eb 1e                	jmp    800da8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d8a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d8d:	80 fb 19             	cmp    $0x19,%bl
  800d90:	77 08                	ja     800d9a <strtol+0x92>
			dig = *s - 'a' + 10;
  800d92:	0f be c9             	movsbl %cl,%ecx
  800d95:	83 e9 57             	sub    $0x57,%ecx
  800d98:	eb 0e                	jmp    800da8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d9a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d9d:	80 fb 19             	cmp    $0x19,%bl
  800da0:	77 12                	ja     800db4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800da2:	0f be c9             	movsbl %cl,%ecx
  800da5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800da8:	39 f1                	cmp    %esi,%ecx
  800daa:	7d 0c                	jge    800db8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800dac:	42                   	inc    %edx
  800dad:	0f af c6             	imul   %esi,%eax
  800db0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800db2:	eb c4                	jmp    800d78 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800db4:	89 c1                	mov    %eax,%ecx
  800db6:	eb 02                	jmp    800dba <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800db8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800dba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dbe:	74 05                	je     800dc5 <strtol+0xbd>
		*endptr = (char *) s;
  800dc0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dc3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dc5:	85 ff                	test   %edi,%edi
  800dc7:	74 04                	je     800dcd <strtol+0xc5>
  800dc9:	89 c8                	mov    %ecx,%eax
  800dcb:	f7 d8                	neg    %eax
}
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    
	...

00800dd4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800dda:	b8 00 00 00 00       	mov    $0x0,%eax
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	89 c7                	mov    %eax,%edi
  800de9:	89 c6                	mov    %eax,%esi
  800deb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <sys_cgetc>:

int
sys_cgetc(void)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfd:	b8 01 00 00 00       	mov    $0x1,%eax
  800e02:	89 d1                	mov    %edx,%ecx
  800e04:	89 d3                	mov    %edx,%ebx
  800e06:	89 d7                	mov    %edx,%edi
  800e08:	89 d6                	mov    %edx,%esi
  800e0a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e0c:	5b                   	pop    %ebx
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	57                   	push   %edi
  800e15:	56                   	push   %esi
  800e16:	53                   	push   %ebx
  800e17:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e1f:	b8 03 00 00 00       	mov    $0x3,%eax
  800e24:	8b 55 08             	mov    0x8(%ebp),%edx
  800e27:	89 cb                	mov    %ecx,%ebx
  800e29:	89 cf                	mov    %ecx,%edi
  800e2b:	89 ce                	mov    %ecx,%esi
  800e2d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e2f:	85 c0                	test   %eax,%eax
  800e31:	7e 28                	jle    800e5b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e33:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e37:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 08 33 2b 80 	movl   $0x802b33,0x8(%esp)
  800e46:	00 
  800e47:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e4e:	00 
  800e4f:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  800e56:	e8 d1 f4 ff ff       	call   80032c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e5b:	83 c4 2c             	add    $0x2c,%esp
  800e5e:	5b                   	pop    %ebx
  800e5f:	5e                   	pop    %esi
  800e60:	5f                   	pop    %edi
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	57                   	push   %edi
  800e67:	56                   	push   %esi
  800e68:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e69:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6e:	b8 02 00 00 00       	mov    $0x2,%eax
  800e73:	89 d1                	mov    %edx,%ecx
  800e75:	89 d3                	mov    %edx,%ebx
  800e77:	89 d7                	mov    %edx,%edi
  800e79:	89 d6                	mov    %edx,%esi
  800e7b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5f                   	pop    %edi
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <sys_yield>:

void
sys_yield(void)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e88:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e92:	89 d1                	mov    %edx,%ecx
  800e94:	89 d3                	mov    %edx,%ebx
  800e96:	89 d7                	mov    %edx,%edi
  800e98:	89 d6                	mov    %edx,%esi
  800e9a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e9c:	5b                   	pop    %ebx
  800e9d:	5e                   	pop    %esi
  800e9e:	5f                   	pop    %edi
  800e9f:	5d                   	pop    %ebp
  800ea0:	c3                   	ret    

00800ea1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	57                   	push   %edi
  800ea5:	56                   	push   %esi
  800ea6:	53                   	push   %ebx
  800ea7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaa:	be 00 00 00 00       	mov    $0x0,%esi
  800eaf:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eba:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebd:	89 f7                	mov    %esi,%edi
  800ebf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec1:	85 c0                	test   %eax,%eax
  800ec3:	7e 28                	jle    800eed <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ec5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 08 33 2b 80 	movl   $0x802b33,0x8(%esp)
  800ed8:	00 
  800ed9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee0:	00 
  800ee1:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  800ee8:	e8 3f f4 ff ff       	call   80032c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800eed:	83 c4 2c             	add    $0x2c,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	57                   	push   %edi
  800ef9:	56                   	push   %esi
  800efa:	53                   	push   %ebx
  800efb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efe:	b8 05 00 00 00       	mov    $0x5,%eax
  800f03:	8b 75 18             	mov    0x18(%ebp),%esi
  800f06:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f09:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f12:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f14:	85 c0                	test   %eax,%eax
  800f16:	7e 28                	jle    800f40 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f18:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f23:	00 
  800f24:	c7 44 24 08 33 2b 80 	movl   $0x802b33,0x8(%esp)
  800f2b:	00 
  800f2c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f33:	00 
  800f34:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  800f3b:	e8 ec f3 ff ff       	call   80032c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f40:	83 c4 2c             	add    $0x2c,%esp
  800f43:	5b                   	pop    %ebx
  800f44:	5e                   	pop    %esi
  800f45:	5f                   	pop    %edi
  800f46:	5d                   	pop    %ebp
  800f47:	c3                   	ret    

00800f48 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	57                   	push   %edi
  800f4c:	56                   	push   %esi
  800f4d:	53                   	push   %ebx
  800f4e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f51:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f56:	b8 06 00 00 00       	mov    $0x6,%eax
  800f5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f61:	89 df                	mov    %ebx,%edi
  800f63:	89 de                	mov    %ebx,%esi
  800f65:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f67:	85 c0                	test   %eax,%eax
  800f69:	7e 28                	jle    800f93 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f6f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f76:	00 
  800f77:	c7 44 24 08 33 2b 80 	movl   $0x802b33,0x8(%esp)
  800f7e:	00 
  800f7f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f86:	00 
  800f87:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  800f8e:	e8 99 f3 ff ff       	call   80032c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f93:	83 c4 2c             	add    $0x2c,%esp
  800f96:	5b                   	pop    %ebx
  800f97:	5e                   	pop    %esi
  800f98:	5f                   	pop    %edi
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    

00800f9b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	57                   	push   %edi
  800f9f:	56                   	push   %esi
  800fa0:	53                   	push   %ebx
  800fa1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fa9:	b8 08 00 00 00       	mov    $0x8,%eax
  800fae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb4:	89 df                	mov    %ebx,%edi
  800fb6:	89 de                	mov    %ebx,%esi
  800fb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	7e 28                	jle    800fe6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fbe:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fc9:	00 
  800fca:	c7 44 24 08 33 2b 80 	movl   $0x802b33,0x8(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd9:	00 
  800fda:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  800fe1:	e8 46 f3 ff ff       	call   80032c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800fe6:	83 c4 2c             	add    $0x2c,%esp
  800fe9:	5b                   	pop    %ebx
  800fea:	5e                   	pop    %esi
  800feb:	5f                   	pop    %edi
  800fec:	5d                   	pop    %ebp
  800fed:	c3                   	ret    

00800fee <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	57                   	push   %edi
  800ff2:	56                   	push   %esi
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ffc:	b8 09 00 00 00       	mov    $0x9,%eax
  801001:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801004:	8b 55 08             	mov    0x8(%ebp),%edx
  801007:	89 df                	mov    %ebx,%edi
  801009:	89 de                	mov    %ebx,%esi
  80100b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80100d:	85 c0                	test   %eax,%eax
  80100f:	7e 28                	jle    801039 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801011:	89 44 24 10          	mov    %eax,0x10(%esp)
  801015:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80101c:	00 
  80101d:	c7 44 24 08 33 2b 80 	movl   $0x802b33,0x8(%esp)
  801024:	00 
  801025:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80102c:	00 
  80102d:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  801034:	e8 f3 f2 ff ff       	call   80032c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801039:	83 c4 2c             	add    $0x2c,%esp
  80103c:	5b                   	pop    %ebx
  80103d:	5e                   	pop    %esi
  80103e:	5f                   	pop    %edi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    

00801041 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	57                   	push   %edi
  801045:	56                   	push   %esi
  801046:	53                   	push   %ebx
  801047:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80104f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801054:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801057:	8b 55 08             	mov    0x8(%ebp),%edx
  80105a:	89 df                	mov    %ebx,%edi
  80105c:	89 de                	mov    %ebx,%esi
  80105e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801060:	85 c0                	test   %eax,%eax
  801062:	7e 28                	jle    80108c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801064:	89 44 24 10          	mov    %eax,0x10(%esp)
  801068:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80106f:	00 
  801070:	c7 44 24 08 33 2b 80 	movl   $0x802b33,0x8(%esp)
  801077:	00 
  801078:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80107f:	00 
  801080:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  801087:	e8 a0 f2 ff ff       	call   80032c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80108c:	83 c4 2c             	add    $0x2c,%esp
  80108f:	5b                   	pop    %ebx
  801090:	5e                   	pop    %esi
  801091:	5f                   	pop    %edi
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	57                   	push   %edi
  801098:	56                   	push   %esi
  801099:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109a:	be 00 00 00 00       	mov    $0x0,%esi
  80109f:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010a4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8010b0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8010b2:	5b                   	pop    %ebx
  8010b3:	5e                   	pop    %esi
  8010b4:	5f                   	pop    %edi
  8010b5:	5d                   	pop    %ebp
  8010b6:	c3                   	ret    

008010b7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8010b7:	55                   	push   %ebp
  8010b8:	89 e5                	mov    %esp,%ebp
  8010ba:	57                   	push   %edi
  8010bb:	56                   	push   %esi
  8010bc:	53                   	push   %ebx
  8010bd:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8010cd:	89 cb                	mov    %ecx,%ebx
  8010cf:	89 cf                	mov    %ecx,%edi
  8010d1:	89 ce                	mov    %ecx,%esi
  8010d3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	7e 28                	jle    801101 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010dd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8010e4:	00 
  8010e5:	c7 44 24 08 33 2b 80 	movl   $0x802b33,0x8(%esp)
  8010ec:	00 
  8010ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010f4:	00 
  8010f5:	c7 04 24 50 2b 80 00 	movl   $0x802b50,(%esp)
  8010fc:	e8 2b f2 ff ff       	call   80032c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801101:	83 c4 2c             	add    $0x2c,%esp
  801104:	5b                   	pop    %ebx
  801105:	5e                   	pop    %esi
  801106:	5f                   	pop    %edi
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    

00801109 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	57                   	push   %edi
  80110d:	56                   	push   %esi
  80110e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80110f:	ba 00 00 00 00       	mov    $0x0,%edx
  801114:	b8 0e 00 00 00       	mov    $0xe,%eax
  801119:	89 d1                	mov    %edx,%ecx
  80111b:	89 d3                	mov    %edx,%ebx
  80111d:	89 d7                	mov    %edx,%edi
  80111f:	89 d6                	mov    %edx,%esi
  801121:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801123:	5b                   	pop    %ebx
  801124:	5e                   	pop    %esi
  801125:	5f                   	pop    %edi
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	57                   	push   %edi
  80112c:	56                   	push   %esi
  80112d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80112e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801133:	b8 0f 00 00 00       	mov    $0xf,%eax
  801138:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113b:	8b 55 08             	mov    0x8(%ebp),%edx
  80113e:	89 df                	mov    %ebx,%edi
  801140:	89 de                	mov    %ebx,%esi
  801142:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  801144:	5b                   	pop    %ebx
  801145:	5e                   	pop    %esi
  801146:	5f                   	pop    %edi
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    

00801149 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	57                   	push   %edi
  80114d:	56                   	push   %esi
  80114e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801154:	b8 10 00 00 00       	mov    $0x10,%eax
  801159:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115c:	8b 55 08             	mov    0x8(%ebp),%edx
  80115f:	89 df                	mov    %ebx,%edi
  801161:	89 de                	mov    %ebx,%esi
  801163:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  801165:	5b                   	pop    %ebx
  801166:	5e                   	pop    %esi
  801167:	5f                   	pop    %edi
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    
	...

0080116c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80116f:	8b 45 08             	mov    0x8(%ebp),%eax
  801172:	05 00 00 00 30       	add    $0x30000000,%eax
  801177:	c1 e8 0c             	shr    $0xc,%eax
}
  80117a:	5d                   	pop    %ebp
  80117b:	c3                   	ret    

0080117c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801182:	8b 45 08             	mov    0x8(%ebp),%eax
  801185:	89 04 24             	mov    %eax,(%esp)
  801188:	e8 df ff ff ff       	call   80116c <fd2num>
  80118d:	c1 e0 0c             	shl    $0xc,%eax
  801190:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801195:	c9                   	leave  
  801196:	c3                   	ret    

00801197 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	53                   	push   %ebx
  80119b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80119e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8011a3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a5:	89 c2                	mov    %eax,%edx
  8011a7:	c1 ea 16             	shr    $0x16,%edx
  8011aa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011b1:	f6 c2 01             	test   $0x1,%dl
  8011b4:	74 11                	je     8011c7 <fd_alloc+0x30>
  8011b6:	89 c2                	mov    %eax,%edx
  8011b8:	c1 ea 0c             	shr    $0xc,%edx
  8011bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c2:	f6 c2 01             	test   $0x1,%dl
  8011c5:	75 09                	jne    8011d0 <fd_alloc+0x39>
			*fd_store = fd;
  8011c7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8011c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ce:	eb 17                	jmp    8011e7 <fd_alloc+0x50>
  8011d0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011d5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011da:	75 c7                	jne    8011a3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8011e2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011e7:	5b                   	pop    %ebx
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f0:	83 f8 1f             	cmp    $0x1f,%eax
  8011f3:	77 36                	ja     80122b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011f5:	c1 e0 0c             	shl    $0xc,%eax
  8011f8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011fd:	89 c2                	mov    %eax,%edx
  8011ff:	c1 ea 16             	shr    $0x16,%edx
  801202:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801209:	f6 c2 01             	test   $0x1,%dl
  80120c:	74 24                	je     801232 <fd_lookup+0x48>
  80120e:	89 c2                	mov    %eax,%edx
  801210:	c1 ea 0c             	shr    $0xc,%edx
  801213:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80121a:	f6 c2 01             	test   $0x1,%dl
  80121d:	74 1a                	je     801239 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80121f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801222:	89 02                	mov    %eax,(%edx)
	return 0;
  801224:	b8 00 00 00 00       	mov    $0x0,%eax
  801229:	eb 13                	jmp    80123e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80122b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801230:	eb 0c                	jmp    80123e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801232:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801237:	eb 05                	jmp    80123e <fd_lookup+0x54>
  801239:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	53                   	push   %ebx
  801244:	83 ec 14             	sub    $0x14,%esp
  801247:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80124d:	ba 00 00 00 00       	mov    $0x0,%edx
  801252:	eb 0e                	jmp    801262 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801254:	39 08                	cmp    %ecx,(%eax)
  801256:	75 09                	jne    801261 <dev_lookup+0x21>
			*dev = devtab[i];
  801258:	89 03                	mov    %eax,(%ebx)
			return 0;
  80125a:	b8 00 00 00 00       	mov    $0x0,%eax
  80125f:	eb 33                	jmp    801294 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801261:	42                   	inc    %edx
  801262:	8b 04 95 e0 2b 80 00 	mov    0x802be0(,%edx,4),%eax
  801269:	85 c0                	test   %eax,%eax
  80126b:	75 e7                	jne    801254 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80126d:	a1 08 44 80 00       	mov    0x804408,%eax
  801272:	8b 40 48             	mov    0x48(%eax),%eax
  801275:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127d:	c7 04 24 60 2b 80 00 	movl   $0x802b60,(%esp)
  801284:	e8 9b f1 ff ff       	call   800424 <cprintf>
	*dev = 0;
  801289:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80128f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801294:	83 c4 14             	add    $0x14,%esp
  801297:	5b                   	pop    %ebx
  801298:	5d                   	pop    %ebp
  801299:	c3                   	ret    

0080129a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	56                   	push   %esi
  80129e:	53                   	push   %ebx
  80129f:	83 ec 30             	sub    $0x30,%esp
  8012a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a5:	8a 45 0c             	mov    0xc(%ebp),%al
  8012a8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ab:	89 34 24             	mov    %esi,(%esp)
  8012ae:	e8 b9 fe ff ff       	call   80116c <fd2num>
  8012b3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8012b6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012ba:	89 04 24             	mov    %eax,(%esp)
  8012bd:	e8 28 ff ff ff       	call   8011ea <fd_lookup>
  8012c2:	89 c3                	mov    %eax,%ebx
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	78 05                	js     8012cd <fd_close+0x33>
	    || fd != fd2)
  8012c8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012cb:	74 0d                	je     8012da <fd_close+0x40>
		return (must_exist ? r : 0);
  8012cd:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8012d1:	75 46                	jne    801319 <fd_close+0x7f>
  8012d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d8:	eb 3f                	jmp    801319 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e1:	8b 06                	mov    (%esi),%eax
  8012e3:	89 04 24             	mov    %eax,(%esp)
  8012e6:	e8 55 ff ff ff       	call   801240 <dev_lookup>
  8012eb:	89 c3                	mov    %eax,%ebx
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 18                	js     801309 <fd_close+0x6f>
		if (dev->dev_close)
  8012f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f4:	8b 40 10             	mov    0x10(%eax),%eax
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	74 09                	je     801304 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012fb:	89 34 24             	mov    %esi,(%esp)
  8012fe:	ff d0                	call   *%eax
  801300:	89 c3                	mov    %eax,%ebx
  801302:	eb 05                	jmp    801309 <fd_close+0x6f>
		else
			r = 0;
  801304:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801309:	89 74 24 04          	mov    %esi,0x4(%esp)
  80130d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801314:	e8 2f fc ff ff       	call   800f48 <sys_page_unmap>
	return r;
}
  801319:	89 d8                	mov    %ebx,%eax
  80131b:	83 c4 30             	add    $0x30,%esp
  80131e:	5b                   	pop    %ebx
  80131f:	5e                   	pop    %esi
  801320:	5d                   	pop    %ebp
  801321:	c3                   	ret    

00801322 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801328:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132f:	8b 45 08             	mov    0x8(%ebp),%eax
  801332:	89 04 24             	mov    %eax,(%esp)
  801335:	e8 b0 fe ff ff       	call   8011ea <fd_lookup>
  80133a:	85 c0                	test   %eax,%eax
  80133c:	78 13                	js     801351 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80133e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801345:	00 
  801346:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801349:	89 04 24             	mov    %eax,(%esp)
  80134c:	e8 49 ff ff ff       	call   80129a <fd_close>
}
  801351:	c9                   	leave  
  801352:	c3                   	ret    

00801353 <close_all>:

void
close_all(void)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	53                   	push   %ebx
  801357:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80135a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80135f:	89 1c 24             	mov    %ebx,(%esp)
  801362:	e8 bb ff ff ff       	call   801322 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801367:	43                   	inc    %ebx
  801368:	83 fb 20             	cmp    $0x20,%ebx
  80136b:	75 f2                	jne    80135f <close_all+0xc>
		close(i);
}
  80136d:	83 c4 14             	add    $0x14,%esp
  801370:	5b                   	pop    %ebx
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	57                   	push   %edi
  801377:	56                   	push   %esi
  801378:	53                   	push   %ebx
  801379:	83 ec 4c             	sub    $0x4c,%esp
  80137c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80137f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801382:	89 44 24 04          	mov    %eax,0x4(%esp)
  801386:	8b 45 08             	mov    0x8(%ebp),%eax
  801389:	89 04 24             	mov    %eax,(%esp)
  80138c:	e8 59 fe ff ff       	call   8011ea <fd_lookup>
  801391:	89 c3                	mov    %eax,%ebx
  801393:	85 c0                	test   %eax,%eax
  801395:	0f 88 e3 00 00 00    	js     80147e <dup+0x10b>
		return r;
	close(newfdnum);
  80139b:	89 3c 24             	mov    %edi,(%esp)
  80139e:	e8 7f ff ff ff       	call   801322 <close>

	newfd = INDEX2FD(newfdnum);
  8013a3:	89 fe                	mov    %edi,%esi
  8013a5:	c1 e6 0c             	shl    $0xc,%esi
  8013a8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013b1:	89 04 24             	mov    %eax,(%esp)
  8013b4:	e8 c3 fd ff ff       	call   80117c <fd2data>
  8013b9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013bb:	89 34 24             	mov    %esi,(%esp)
  8013be:	e8 b9 fd ff ff       	call   80117c <fd2data>
  8013c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013c6:	89 d8                	mov    %ebx,%eax
  8013c8:	c1 e8 16             	shr    $0x16,%eax
  8013cb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013d2:	a8 01                	test   $0x1,%al
  8013d4:	74 46                	je     80141c <dup+0xa9>
  8013d6:	89 d8                	mov    %ebx,%eax
  8013d8:	c1 e8 0c             	shr    $0xc,%eax
  8013db:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013e2:	f6 c2 01             	test   $0x1,%dl
  8013e5:	74 35                	je     80141c <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013e7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ee:	25 07 0e 00 00       	and    $0xe07,%eax
  8013f3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013f7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8013fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013fe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801405:	00 
  801406:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80140a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801411:	e8 df fa ff ff       	call   800ef5 <sys_page_map>
  801416:	89 c3                	mov    %eax,%ebx
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 3b                	js     801457 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80141c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80141f:	89 c2                	mov    %eax,%edx
  801421:	c1 ea 0c             	shr    $0xc,%edx
  801424:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80142b:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801431:	89 54 24 10          	mov    %edx,0x10(%esp)
  801435:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801439:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801440:	00 
  801441:	89 44 24 04          	mov    %eax,0x4(%esp)
  801445:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80144c:	e8 a4 fa ff ff       	call   800ef5 <sys_page_map>
  801451:	89 c3                	mov    %eax,%ebx
  801453:	85 c0                	test   %eax,%eax
  801455:	79 25                	jns    80147c <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801457:	89 74 24 04          	mov    %esi,0x4(%esp)
  80145b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801462:	e8 e1 fa ff ff       	call   800f48 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801467:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80146a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801475:	e8 ce fa ff ff       	call   800f48 <sys_page_unmap>
	return r;
  80147a:	eb 02                	jmp    80147e <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80147c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80147e:	89 d8                	mov    %ebx,%eax
  801480:	83 c4 4c             	add    $0x4c,%esp
  801483:	5b                   	pop    %ebx
  801484:	5e                   	pop    %esi
  801485:	5f                   	pop    %edi
  801486:	5d                   	pop    %ebp
  801487:	c3                   	ret    

00801488 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	53                   	push   %ebx
  80148c:	83 ec 24             	sub    $0x24,%esp
  80148f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801492:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801495:	89 44 24 04          	mov    %eax,0x4(%esp)
  801499:	89 1c 24             	mov    %ebx,(%esp)
  80149c:	e8 49 fd ff ff       	call   8011ea <fd_lookup>
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	78 6d                	js     801512 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014af:	8b 00                	mov    (%eax),%eax
  8014b1:	89 04 24             	mov    %eax,(%esp)
  8014b4:	e8 87 fd ff ff       	call   801240 <dev_lookup>
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 55                	js     801512 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c0:	8b 50 08             	mov    0x8(%eax),%edx
  8014c3:	83 e2 03             	and    $0x3,%edx
  8014c6:	83 fa 01             	cmp    $0x1,%edx
  8014c9:	75 23                	jne    8014ee <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014cb:	a1 08 44 80 00       	mov    0x804408,%eax
  8014d0:	8b 40 48             	mov    0x48(%eax),%eax
  8014d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014db:	c7 04 24 a4 2b 80 00 	movl   $0x802ba4,(%esp)
  8014e2:	e8 3d ef ff ff       	call   800424 <cprintf>
		return -E_INVAL;
  8014e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ec:	eb 24                	jmp    801512 <read+0x8a>
	}
	if (!dev->dev_read)
  8014ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f1:	8b 52 08             	mov    0x8(%edx),%edx
  8014f4:	85 d2                	test   %edx,%edx
  8014f6:	74 15                	je     80150d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8014fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801502:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801506:	89 04 24             	mov    %eax,(%esp)
  801509:	ff d2                	call   *%edx
  80150b:	eb 05                	jmp    801512 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80150d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801512:	83 c4 24             	add    $0x24,%esp
  801515:	5b                   	pop    %ebx
  801516:	5d                   	pop    %ebp
  801517:	c3                   	ret    

00801518 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	57                   	push   %edi
  80151c:	56                   	push   %esi
  80151d:	53                   	push   %ebx
  80151e:	83 ec 1c             	sub    $0x1c,%esp
  801521:	8b 7d 08             	mov    0x8(%ebp),%edi
  801524:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801527:	bb 00 00 00 00       	mov    $0x0,%ebx
  80152c:	eb 23                	jmp    801551 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80152e:	89 f0                	mov    %esi,%eax
  801530:	29 d8                	sub    %ebx,%eax
  801532:	89 44 24 08          	mov    %eax,0x8(%esp)
  801536:	8b 45 0c             	mov    0xc(%ebp),%eax
  801539:	01 d8                	add    %ebx,%eax
  80153b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153f:	89 3c 24             	mov    %edi,(%esp)
  801542:	e8 41 ff ff ff       	call   801488 <read>
		if (m < 0)
  801547:	85 c0                	test   %eax,%eax
  801549:	78 10                	js     80155b <readn+0x43>
			return m;
		if (m == 0)
  80154b:	85 c0                	test   %eax,%eax
  80154d:	74 0a                	je     801559 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80154f:	01 c3                	add    %eax,%ebx
  801551:	39 f3                	cmp    %esi,%ebx
  801553:	72 d9                	jb     80152e <readn+0x16>
  801555:	89 d8                	mov    %ebx,%eax
  801557:	eb 02                	jmp    80155b <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801559:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80155b:	83 c4 1c             	add    $0x1c,%esp
  80155e:	5b                   	pop    %ebx
  80155f:	5e                   	pop    %esi
  801560:	5f                   	pop    %edi
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    

00801563 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	53                   	push   %ebx
  801567:	83 ec 24             	sub    $0x24,%esp
  80156a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801570:	89 44 24 04          	mov    %eax,0x4(%esp)
  801574:	89 1c 24             	mov    %ebx,(%esp)
  801577:	e8 6e fc ff ff       	call   8011ea <fd_lookup>
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 68                	js     8015e8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801580:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801583:	89 44 24 04          	mov    %eax,0x4(%esp)
  801587:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158a:	8b 00                	mov    (%eax),%eax
  80158c:	89 04 24             	mov    %eax,(%esp)
  80158f:	e8 ac fc ff ff       	call   801240 <dev_lookup>
  801594:	85 c0                	test   %eax,%eax
  801596:	78 50                	js     8015e8 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801598:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80159f:	75 23                	jne    8015c4 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a1:	a1 08 44 80 00       	mov    0x804408,%eax
  8015a6:	8b 40 48             	mov    0x48(%eax),%eax
  8015a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b1:	c7 04 24 c0 2b 80 00 	movl   $0x802bc0,(%esp)
  8015b8:	e8 67 ee ff ff       	call   800424 <cprintf>
		return -E_INVAL;
  8015bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015c2:	eb 24                	jmp    8015e8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c7:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ca:	85 d2                	test   %edx,%edx
  8015cc:	74 15                	je     8015e3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015d1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015d8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015dc:	89 04 24             	mov    %eax,(%esp)
  8015df:	ff d2                	call   *%edx
  8015e1:	eb 05                	jmp    8015e8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015e3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8015e8:	83 c4 24             	add    $0x24,%esp
  8015eb:	5b                   	pop    %ebx
  8015ec:	5d                   	pop    %ebp
  8015ed:	c3                   	ret    

008015ee <seek>:

int
seek(int fdnum, off_t offset)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fe:	89 04 24             	mov    %eax,(%esp)
  801601:	e8 e4 fb ff ff       	call   8011ea <fd_lookup>
  801606:	85 c0                	test   %eax,%eax
  801608:	78 0e                	js     801618 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80160a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80160d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801610:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801613:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801618:	c9                   	leave  
  801619:	c3                   	ret    

0080161a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	53                   	push   %ebx
  80161e:	83 ec 24             	sub    $0x24,%esp
  801621:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801624:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801627:	89 44 24 04          	mov    %eax,0x4(%esp)
  80162b:	89 1c 24             	mov    %ebx,(%esp)
  80162e:	e8 b7 fb ff ff       	call   8011ea <fd_lookup>
  801633:	85 c0                	test   %eax,%eax
  801635:	78 61                	js     801698 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801637:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801641:	8b 00                	mov    (%eax),%eax
  801643:	89 04 24             	mov    %eax,(%esp)
  801646:	e8 f5 fb ff ff       	call   801240 <dev_lookup>
  80164b:	85 c0                	test   %eax,%eax
  80164d:	78 49                	js     801698 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80164f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801652:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801656:	75 23                	jne    80167b <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801658:	a1 08 44 80 00       	mov    0x804408,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80165d:	8b 40 48             	mov    0x48(%eax),%eax
  801660:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801664:	89 44 24 04          	mov    %eax,0x4(%esp)
  801668:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  80166f:	e8 b0 ed ff ff       	call   800424 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801674:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801679:	eb 1d                	jmp    801698 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80167b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80167e:	8b 52 18             	mov    0x18(%edx),%edx
  801681:	85 d2                	test   %edx,%edx
  801683:	74 0e                	je     801693 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801685:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801688:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80168c:	89 04 24             	mov    %eax,(%esp)
  80168f:	ff d2                	call   *%edx
  801691:	eb 05                	jmp    801698 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801693:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801698:	83 c4 24             	add    $0x24,%esp
  80169b:	5b                   	pop    %ebx
  80169c:	5d                   	pop    %ebp
  80169d:	c3                   	ret    

0080169e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	53                   	push   %ebx
  8016a2:	83 ec 24             	sub    $0x24,%esp
  8016a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016af:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b2:	89 04 24             	mov    %eax,(%esp)
  8016b5:	e8 30 fb ff ff       	call   8011ea <fd_lookup>
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 52                	js     801710 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c8:	8b 00                	mov    (%eax),%eax
  8016ca:	89 04 24             	mov    %eax,(%esp)
  8016cd:	e8 6e fb ff ff       	call   801240 <dev_lookup>
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 3a                	js     801710 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8016d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016dd:	74 2c                	je     80170b <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016df:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016e2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016e9:	00 00 00 
	stat->st_isdir = 0;
  8016ec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f3:	00 00 00 
	stat->st_dev = dev;
  8016f6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801700:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801703:	89 14 24             	mov    %edx,(%esp)
  801706:	ff 50 14             	call   *0x14(%eax)
  801709:	eb 05                	jmp    801710 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80170b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801710:	83 c4 24             	add    $0x24,%esp
  801713:	5b                   	pop    %ebx
  801714:	5d                   	pop    %ebp
  801715:	c3                   	ret    

00801716 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	56                   	push   %esi
  80171a:	53                   	push   %ebx
  80171b:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80171e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801725:	00 
  801726:	8b 45 08             	mov    0x8(%ebp),%eax
  801729:	89 04 24             	mov    %eax,(%esp)
  80172c:	e8 2a 02 00 00       	call   80195b <open>
  801731:	89 c3                	mov    %eax,%ebx
  801733:	85 c0                	test   %eax,%eax
  801735:	78 1b                	js     801752 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801737:	8b 45 0c             	mov    0xc(%ebp),%eax
  80173a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173e:	89 1c 24             	mov    %ebx,(%esp)
  801741:	e8 58 ff ff ff       	call   80169e <fstat>
  801746:	89 c6                	mov    %eax,%esi
	close(fd);
  801748:	89 1c 24             	mov    %ebx,(%esp)
  80174b:	e8 d2 fb ff ff       	call   801322 <close>
	return r;
  801750:	89 f3                	mov    %esi,%ebx
}
  801752:	89 d8                	mov    %ebx,%eax
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	5b                   	pop    %ebx
  801758:	5e                   	pop    %esi
  801759:	5d                   	pop    %ebp
  80175a:	c3                   	ret    
	...

0080175c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	56                   	push   %esi
  801760:	53                   	push   %ebx
  801761:	83 ec 10             	sub    $0x10,%esp
  801764:	89 c3                	mov    %eax,%ebx
  801766:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801768:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  80176f:	75 11                	jne    801782 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801771:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801778:	e8 1e 0d 00 00       	call   80249b <ipc_find_env>
  80177d:	a3 00 44 80 00       	mov    %eax,0x804400
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801782:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801789:	00 
  80178a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801791:	00 
  801792:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801796:	a1 00 44 80 00       	mov    0x804400,%eax
  80179b:	89 04 24             	mov    %eax,(%esp)
  80179e:	e8 75 0c 00 00       	call   802418 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017aa:	00 
  8017ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b6:	e8 ed 0b 00 00       	call   8023a8 <ipc_recv>
}
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	5b                   	pop    %ebx
  8017bf:	5e                   	pop    %esi
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    

008017c2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ce:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017db:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e0:	b8 02 00 00 00       	mov    $0x2,%eax
  8017e5:	e8 72 ff ff ff       	call   80175c <fsipc>
}
  8017ea:	c9                   	leave  
  8017eb:	c3                   	ret    

008017ec <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801802:	b8 06 00 00 00       	mov    $0x6,%eax
  801807:	e8 50 ff ff ff       	call   80175c <fsipc>
}
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    

0080180e <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	53                   	push   %ebx
  801812:	83 ec 14             	sub    $0x14,%esp
  801815:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
  80181b:	8b 40 0c             	mov    0xc(%eax),%eax
  80181e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801823:	ba 00 00 00 00       	mov    $0x0,%edx
  801828:	b8 05 00 00 00       	mov    $0x5,%eax
  80182d:	e8 2a ff ff ff       	call   80175c <fsipc>
  801832:	85 c0                	test   %eax,%eax
  801834:	78 2b                	js     801861 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801836:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80183d:	00 
  80183e:	89 1c 24             	mov    %ebx,(%esp)
  801841:	e8 69 f2 ff ff       	call   800aaf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801846:	a1 80 50 80 00       	mov    0x805080,%eax
  80184b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801851:	a1 84 50 80 00       	mov    0x805084,%eax
  801856:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80185c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801861:	83 c4 14             	add    $0x14,%esp
  801864:	5b                   	pop    %ebx
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	83 ec 18             	sub    $0x18,%esp
  80186d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801870:	8b 55 08             	mov    0x8(%ebp),%edx
  801873:	8b 52 0c             	mov    0xc(%edx),%edx
  801876:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80187c:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801881:	89 c2                	mov    %eax,%edx
  801883:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801888:	76 05                	jbe    80188f <devfile_write+0x28>
  80188a:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  80188f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801893:	8b 45 0c             	mov    0xc(%ebp),%eax
  801896:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189a:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8018a1:	e8 ec f3 ff ff       	call   800c92 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ab:	b8 04 00 00 00       	mov    $0x4,%eax
  8018b0:	e8 a7 fe ff ff       	call   80175c <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  8018b5:	c9                   	leave  
  8018b6:	c3                   	ret    

008018b7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	56                   	push   %esi
  8018bb:	53                   	push   %ebx
  8018bc:	83 ec 10             	sub    $0x10,%esp
  8018bf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018cd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d8:	b8 03 00 00 00       	mov    $0x3,%eax
  8018dd:	e8 7a fe ff ff       	call   80175c <fsipc>
  8018e2:	89 c3                	mov    %eax,%ebx
  8018e4:	85 c0                	test   %eax,%eax
  8018e6:	78 6a                	js     801952 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8018e8:	39 c6                	cmp    %eax,%esi
  8018ea:	73 24                	jae    801910 <devfile_read+0x59>
  8018ec:	c7 44 24 0c f4 2b 80 	movl   $0x802bf4,0xc(%esp)
  8018f3:	00 
  8018f4:	c7 44 24 08 fb 2b 80 	movl   $0x802bfb,0x8(%esp)
  8018fb:	00 
  8018fc:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801903:	00 
  801904:	c7 04 24 10 2c 80 00 	movl   $0x802c10,(%esp)
  80190b:	e8 1c ea ff ff       	call   80032c <_panic>
	assert(r <= PGSIZE);
  801910:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801915:	7e 24                	jle    80193b <devfile_read+0x84>
  801917:	c7 44 24 0c 1b 2c 80 	movl   $0x802c1b,0xc(%esp)
  80191e:	00 
  80191f:	c7 44 24 08 fb 2b 80 	movl   $0x802bfb,0x8(%esp)
  801926:	00 
  801927:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80192e:	00 
  80192f:	c7 04 24 10 2c 80 00 	movl   $0x802c10,(%esp)
  801936:	e8 f1 e9 ff ff       	call   80032c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80193b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80193f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801946:	00 
  801947:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194a:	89 04 24             	mov    %eax,(%esp)
  80194d:	e8 d6 f2 ff ff       	call   800c28 <memmove>
	return r;
}
  801952:	89 d8                	mov    %ebx,%eax
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	5b                   	pop    %ebx
  801958:	5e                   	pop    %esi
  801959:	5d                   	pop    %ebp
  80195a:	c3                   	ret    

0080195b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	56                   	push   %esi
  80195f:	53                   	push   %ebx
  801960:	83 ec 20             	sub    $0x20,%esp
  801963:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801966:	89 34 24             	mov    %esi,(%esp)
  801969:	e8 0e f1 ff ff       	call   800a7c <strlen>
  80196e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801973:	7f 60                	jg     8019d5 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801975:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801978:	89 04 24             	mov    %eax,(%esp)
  80197b:	e8 17 f8 ff ff       	call   801197 <fd_alloc>
  801980:	89 c3                	mov    %eax,%ebx
  801982:	85 c0                	test   %eax,%eax
  801984:	78 54                	js     8019da <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801986:	89 74 24 04          	mov    %esi,0x4(%esp)
  80198a:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801991:	e8 19 f1 ff ff       	call   800aaf <strcpy>
	fsipcbuf.open.req_omode = mode;
  801996:	8b 45 0c             	mov    0xc(%ebp),%eax
  801999:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80199e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8019a6:	e8 b1 fd ff ff       	call   80175c <fsipc>
  8019ab:	89 c3                	mov    %eax,%ebx
  8019ad:	85 c0                	test   %eax,%eax
  8019af:	79 15                	jns    8019c6 <open+0x6b>
		fd_close(fd, 0);
  8019b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019b8:	00 
  8019b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bc:	89 04 24             	mov    %eax,(%esp)
  8019bf:	e8 d6 f8 ff ff       	call   80129a <fd_close>
		return r;
  8019c4:	eb 14                	jmp    8019da <open+0x7f>
	}

	return fd2num(fd);
  8019c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c9:	89 04 24             	mov    %eax,(%esp)
  8019cc:	e8 9b f7 ff ff       	call   80116c <fd2num>
  8019d1:	89 c3                	mov    %eax,%ebx
  8019d3:	eb 05                	jmp    8019da <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019d5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019da:	89 d8                	mov    %ebx,%eax
  8019dc:	83 c4 20             	add    $0x20,%esp
  8019df:	5b                   	pop    %ebx
  8019e0:	5e                   	pop    %esi
  8019e1:	5d                   	pop    %ebp
  8019e2:	c3                   	ret    

008019e3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ee:	b8 08 00 00 00       	mov    $0x8,%eax
  8019f3:	e8 64 fd ff ff       	call   80175c <fsipc>
}
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    
	...

008019fc <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	53                   	push   %ebx
  801a00:	83 ec 14             	sub    $0x14,%esp
  801a03:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801a05:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801a09:	7e 32                	jle    801a3d <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801a0b:	8b 40 04             	mov    0x4(%eax),%eax
  801a0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a12:	8d 43 10             	lea    0x10(%ebx),%eax
  801a15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a19:	8b 03                	mov    (%ebx),%eax
  801a1b:	89 04 24             	mov    %eax,(%esp)
  801a1e:	e8 40 fb ff ff       	call   801563 <write>
		if (result > 0)
  801a23:	85 c0                	test   %eax,%eax
  801a25:	7e 03                	jle    801a2a <writebuf+0x2e>
			b->result += result;
  801a27:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801a2a:	39 43 04             	cmp    %eax,0x4(%ebx)
  801a2d:	74 0e                	je     801a3d <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  801a2f:	89 c2                	mov    %eax,%edx
  801a31:	85 c0                	test   %eax,%eax
  801a33:	7e 05                	jle    801a3a <writebuf+0x3e>
  801a35:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3a:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801a3d:	83 c4 14             	add    $0x14,%esp
  801a40:	5b                   	pop    %ebx
  801a41:	5d                   	pop    %ebp
  801a42:	c3                   	ret    

00801a43 <putch>:

static void
putch(int ch, void *thunk)
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	53                   	push   %ebx
  801a47:	83 ec 04             	sub    $0x4,%esp
  801a4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801a4d:	8b 43 04             	mov    0x4(%ebx),%eax
  801a50:	8b 55 08             	mov    0x8(%ebp),%edx
  801a53:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801a57:	40                   	inc    %eax
  801a58:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801a5b:	3d 00 01 00 00       	cmp    $0x100,%eax
  801a60:	75 0e                	jne    801a70 <putch+0x2d>
		writebuf(b);
  801a62:	89 d8                	mov    %ebx,%eax
  801a64:	e8 93 ff ff ff       	call   8019fc <writebuf>
		b->idx = 0;
  801a69:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801a70:	83 c4 04             	add    $0x4,%esp
  801a73:	5b                   	pop    %ebx
  801a74:	5d                   	pop    %ebp
  801a75:	c3                   	ret    

00801a76 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a82:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801a88:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801a8f:	00 00 00 
	b.result = 0;
  801a92:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a99:	00 00 00 
	b.error = 1;
  801a9c:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801aa3:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801aa6:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801aad:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ab4:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801aba:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abe:	c7 04 24 43 1a 80 00 	movl   $0x801a43,(%esp)
  801ac5:	e8 bc ea ff ff       	call   800586 <vprintfmt>
	if (b.idx > 0)
  801aca:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801ad1:	7e 0b                	jle    801ade <vfprintf+0x68>
		writebuf(&b);
  801ad3:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801ad9:	e8 1e ff ff ff       	call   8019fc <writebuf>

	return (b.result ? b.result : b.error);
  801ade:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	75 06                	jne    801aee <vfprintf+0x78>
  801ae8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    

00801af0 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801af6:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801af9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b04:	8b 45 08             	mov    0x8(%ebp),%eax
  801b07:	89 04 24             	mov    %eax,(%esp)
  801b0a:	e8 67 ff ff ff       	call   801a76 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b0f:	c9                   	leave  
  801b10:	c3                   	ret    

00801b11 <printf>:

int
printf(const char *fmt, ...)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801b17:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801b1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b21:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b25:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801b2c:	e8 45 ff ff ff       	call   801a76 <vfprintf>
	va_end(ap);

	return cnt;
}
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    
	...

00801b34 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801b3a:	c7 44 24 04 27 2c 80 	movl   $0x802c27,0x4(%esp)
  801b41:	00 
  801b42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b45:	89 04 24             	mov    %eax,(%esp)
  801b48:	e8 62 ef ff ff       	call   800aaf <strcpy>
	return 0;
}
  801b4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b52:	c9                   	leave  
  801b53:	c3                   	ret    

00801b54 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	53                   	push   %ebx
  801b58:	83 ec 14             	sub    $0x14,%esp
  801b5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b5e:	89 1c 24             	mov    %ebx,(%esp)
  801b61:	e8 7a 09 00 00       	call   8024e0 <pageref>
  801b66:	83 f8 01             	cmp    $0x1,%eax
  801b69:	75 0d                	jne    801b78 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801b6b:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b6e:	89 04 24             	mov    %eax,(%esp)
  801b71:	e8 1f 03 00 00       	call   801e95 <nsipc_close>
  801b76:	eb 05                	jmp    801b7d <devsock_close+0x29>
	else
		return 0;
  801b78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b7d:	83 c4 14             	add    $0x14,%esp
  801b80:	5b                   	pop    %ebx
  801b81:	5d                   	pop    %ebp
  801b82:	c3                   	ret    

00801b83 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b89:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b90:	00 
  801b91:	8b 45 10             	mov    0x10(%ebp),%eax
  801b94:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba2:	8b 40 0c             	mov    0xc(%eax),%eax
  801ba5:	89 04 24             	mov    %eax,(%esp)
  801ba8:	e8 e3 03 00 00       	call   801f90 <nsipc_send>
}
  801bad:	c9                   	leave  
  801bae:	c3                   	ret    

00801baf <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801bb5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801bbc:	00 
  801bbd:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bce:	8b 40 0c             	mov    0xc(%eax),%eax
  801bd1:	89 04 24             	mov    %eax,(%esp)
  801bd4:	e8 37 03 00 00       	call   801f10 <nsipc_recv>
}
  801bd9:	c9                   	leave  
  801bda:	c3                   	ret    

00801bdb <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	56                   	push   %esi
  801bdf:	53                   	push   %ebx
  801be0:	83 ec 20             	sub    $0x20,%esp
  801be3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801be5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be8:	89 04 24             	mov    %eax,(%esp)
  801beb:	e8 a7 f5 ff ff       	call   801197 <fd_alloc>
  801bf0:	89 c3                	mov    %eax,%ebx
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	78 21                	js     801c17 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bf6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bfd:	00 
  801bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c01:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c0c:	e8 90 f2 ff ff       	call   800ea1 <sys_page_alloc>
  801c11:	89 c3                	mov    %eax,%ebx
  801c13:	85 c0                	test   %eax,%eax
  801c15:	79 0a                	jns    801c21 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801c17:	89 34 24             	mov    %esi,(%esp)
  801c1a:	e8 76 02 00 00       	call   801e95 <nsipc_close>
		return r;
  801c1f:	eb 22                	jmp    801c43 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c21:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c36:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c39:	89 04 24             	mov    %eax,(%esp)
  801c3c:	e8 2b f5 ff ff       	call   80116c <fd2num>
  801c41:	89 c3                	mov    %eax,%ebx
}
  801c43:	89 d8                	mov    %ebx,%eax
  801c45:	83 c4 20             	add    $0x20,%esp
  801c48:	5b                   	pop    %ebx
  801c49:	5e                   	pop    %esi
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    

00801c4c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c52:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c55:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c59:	89 04 24             	mov    %eax,(%esp)
  801c5c:	e8 89 f5 ff ff       	call   8011ea <fd_lookup>
  801c61:	85 c0                	test   %eax,%eax
  801c63:	78 17                	js     801c7c <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c68:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c6e:	39 10                	cmp    %edx,(%eax)
  801c70:	75 05                	jne    801c77 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c72:	8b 40 0c             	mov    0xc(%eax),%eax
  801c75:	eb 05                	jmp    801c7c <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c77:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    

00801c7e <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c84:	8b 45 08             	mov    0x8(%ebp),%eax
  801c87:	e8 c0 ff ff ff       	call   801c4c <fd2sockid>
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	78 1f                	js     801caf <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c90:	8b 55 10             	mov    0x10(%ebp),%edx
  801c93:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c97:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c9a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c9e:	89 04 24             	mov    %eax,(%esp)
  801ca1:	e8 38 01 00 00       	call   801dde <nsipc_accept>
  801ca6:	85 c0                	test   %eax,%eax
  801ca8:	78 05                	js     801caf <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801caa:	e8 2c ff ff ff       	call   801bdb <alloc_sockfd>
}
  801caf:	c9                   	leave  
  801cb0:	c3                   	ret    

00801cb1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cba:	e8 8d ff ff ff       	call   801c4c <fd2sockid>
  801cbf:	85 c0                	test   %eax,%eax
  801cc1:	78 16                	js     801cd9 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801cc3:	8b 55 10             	mov    0x10(%ebp),%edx
  801cc6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cca:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ccd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cd1:	89 04 24             	mov    %eax,(%esp)
  801cd4:	e8 5b 01 00 00       	call   801e34 <nsipc_bind>
}
  801cd9:	c9                   	leave  
  801cda:	c3                   	ret    

00801cdb <shutdown>:

int
shutdown(int s, int how)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce4:	e8 63 ff ff ff       	call   801c4c <fd2sockid>
  801ce9:	85 c0                	test   %eax,%eax
  801ceb:	78 0f                	js     801cfc <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ced:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cf0:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cf4:	89 04 24             	mov    %eax,(%esp)
  801cf7:	e8 77 01 00 00       	call   801e73 <nsipc_shutdown>
}
  801cfc:	c9                   	leave  
  801cfd:	c3                   	ret    

00801cfe <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d04:	8b 45 08             	mov    0x8(%ebp),%eax
  801d07:	e8 40 ff ff ff       	call   801c4c <fd2sockid>
  801d0c:	85 c0                	test   %eax,%eax
  801d0e:	78 16                	js     801d26 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801d10:	8b 55 10             	mov    0x10(%ebp),%edx
  801d13:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d1a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d1e:	89 04 24             	mov    %eax,(%esp)
  801d21:	e8 89 01 00 00       	call   801eaf <nsipc_connect>
}
  801d26:	c9                   	leave  
  801d27:	c3                   	ret    

00801d28 <listen>:

int
listen(int s, int backlog)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d31:	e8 16 ff ff ff       	call   801c4c <fd2sockid>
  801d36:	85 c0                	test   %eax,%eax
  801d38:	78 0f                	js     801d49 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d3d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d41:	89 04 24             	mov    %eax,(%esp)
  801d44:	e8 a5 01 00 00       	call   801eee <nsipc_listen>
}
  801d49:	c9                   	leave  
  801d4a:	c3                   	ret    

00801d4b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d51:	8b 45 10             	mov    0x10(%ebp),%eax
  801d54:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d62:	89 04 24             	mov    %eax,(%esp)
  801d65:	e8 99 02 00 00       	call   802003 <nsipc_socket>
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	78 05                	js     801d73 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801d6e:	e8 68 fe ff ff       	call   801bdb <alloc_sockfd>
}
  801d73:	c9                   	leave  
  801d74:	c3                   	ret    
  801d75:	00 00                	add    %al,(%eax)
	...

00801d78 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
  801d7b:	53                   	push   %ebx
  801d7c:	83 ec 14             	sub    $0x14,%esp
  801d7f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d81:	83 3d 04 44 80 00 00 	cmpl   $0x0,0x804404
  801d88:	75 11                	jne    801d9b <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d8a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801d91:	e8 05 07 00 00       	call   80249b <ipc_find_env>
  801d96:	a3 04 44 80 00       	mov    %eax,0x804404
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d9b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801da2:	00 
  801da3:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801daa:	00 
  801dab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801daf:	a1 04 44 80 00       	mov    0x804404,%eax
  801db4:	89 04 24             	mov    %eax,(%esp)
  801db7:	e8 5c 06 00 00       	call   802418 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801dbc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dc3:	00 
  801dc4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801dcb:	00 
  801dcc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd3:	e8 d0 05 00 00       	call   8023a8 <ipc_recv>
}
  801dd8:	83 c4 14             	add    $0x14,%esp
  801ddb:	5b                   	pop    %ebx
  801ddc:	5d                   	pop    %ebp
  801ddd:	c3                   	ret    

00801dde <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dde:	55                   	push   %ebp
  801ddf:	89 e5                	mov    %esp,%ebp
  801de1:	56                   	push   %esi
  801de2:	53                   	push   %ebx
  801de3:	83 ec 10             	sub    $0x10,%esp
  801de6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801de9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dec:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801df1:	8b 06                	mov    (%esi),%eax
  801df3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801df8:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfd:	e8 76 ff ff ff       	call   801d78 <nsipc>
  801e02:	89 c3                	mov    %eax,%ebx
  801e04:	85 c0                	test   %eax,%eax
  801e06:	78 23                	js     801e2b <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e08:	a1 10 60 80 00       	mov    0x806010,%eax
  801e0d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e11:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e18:	00 
  801e19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1c:	89 04 24             	mov    %eax,(%esp)
  801e1f:	e8 04 ee ff ff       	call   800c28 <memmove>
		*addrlen = ret->ret_addrlen;
  801e24:	a1 10 60 80 00       	mov    0x806010,%eax
  801e29:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801e2b:	89 d8                	mov    %ebx,%eax
  801e2d:	83 c4 10             	add    $0x10,%esp
  801e30:	5b                   	pop    %ebx
  801e31:	5e                   	pop    %esi
  801e32:	5d                   	pop    %ebp
  801e33:	c3                   	ret    

00801e34 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e34:	55                   	push   %ebp
  801e35:	89 e5                	mov    %esp,%ebp
  801e37:	53                   	push   %ebx
  801e38:	83 ec 14             	sub    $0x14,%esp
  801e3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e41:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e46:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e51:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801e58:	e8 cb ed ff ff       	call   800c28 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e5d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e63:	b8 02 00 00 00       	mov    $0x2,%eax
  801e68:	e8 0b ff ff ff       	call   801d78 <nsipc>
}
  801e6d:	83 c4 14             	add    $0x14,%esp
  801e70:	5b                   	pop    %ebx
  801e71:	5d                   	pop    %ebp
  801e72:	c3                   	ret    

00801e73 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e79:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e81:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e84:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e89:	b8 03 00 00 00       	mov    $0x3,%eax
  801e8e:	e8 e5 fe ff ff       	call   801d78 <nsipc>
}
  801e93:	c9                   	leave  
  801e94:	c3                   	ret    

00801e95 <nsipc_close>:

int
nsipc_close(int s)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ea3:	b8 04 00 00 00       	mov    $0x4,%eax
  801ea8:	e8 cb fe ff ff       	call   801d78 <nsipc>
}
  801ead:	c9                   	leave  
  801eae:	c3                   	ret    

00801eaf <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	53                   	push   %ebx
  801eb3:	83 ec 14             	sub    $0x14,%esp
  801eb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ec1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ec5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecc:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801ed3:	e8 50 ed ff ff       	call   800c28 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ed8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801ede:	b8 05 00 00 00       	mov    $0x5,%eax
  801ee3:	e8 90 fe ff ff       	call   801d78 <nsipc>
}
  801ee8:	83 c4 14             	add    $0x14,%esp
  801eeb:	5b                   	pop    %ebx
  801eec:	5d                   	pop    %ebp
  801eed:	c3                   	ret    

00801eee <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ef4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801efc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eff:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f04:	b8 06 00 00 00       	mov    $0x6,%eax
  801f09:	e8 6a fe ff ff       	call   801d78 <nsipc>
}
  801f0e:	c9                   	leave  
  801f0f:	c3                   	ret    

00801f10 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	56                   	push   %esi
  801f14:	53                   	push   %ebx
  801f15:	83 ec 10             	sub    $0x10,%esp
  801f18:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f23:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f29:	8b 45 14             	mov    0x14(%ebp),%eax
  801f2c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f31:	b8 07 00 00 00       	mov    $0x7,%eax
  801f36:	e8 3d fe ff ff       	call   801d78 <nsipc>
  801f3b:	89 c3                	mov    %eax,%ebx
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	78 46                	js     801f87 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801f41:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f46:	7f 04                	jg     801f4c <nsipc_recv+0x3c>
  801f48:	39 c6                	cmp    %eax,%esi
  801f4a:	7d 24                	jge    801f70 <nsipc_recv+0x60>
  801f4c:	c7 44 24 0c 33 2c 80 	movl   $0x802c33,0xc(%esp)
  801f53:	00 
  801f54:	c7 44 24 08 fb 2b 80 	movl   $0x802bfb,0x8(%esp)
  801f5b:	00 
  801f5c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801f63:	00 
  801f64:	c7 04 24 48 2c 80 00 	movl   $0x802c48,(%esp)
  801f6b:	e8 bc e3 ff ff       	call   80032c <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f70:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f74:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f7b:	00 
  801f7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f7f:	89 04 24             	mov    %eax,(%esp)
  801f82:	e8 a1 ec ff ff       	call   800c28 <memmove>
	}

	return r;
}
  801f87:	89 d8                	mov    %ebx,%eax
  801f89:	83 c4 10             	add    $0x10,%esp
  801f8c:	5b                   	pop    %ebx
  801f8d:	5e                   	pop    %esi
  801f8e:	5d                   	pop    %ebp
  801f8f:	c3                   	ret    

00801f90 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	53                   	push   %ebx
  801f94:	83 ec 14             	sub    $0x14,%esp
  801f97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9d:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801fa2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801fa8:	7e 24                	jle    801fce <nsipc_send+0x3e>
  801faa:	c7 44 24 0c 54 2c 80 	movl   $0x802c54,0xc(%esp)
  801fb1:	00 
  801fb2:	c7 44 24 08 fb 2b 80 	movl   $0x802bfb,0x8(%esp)
  801fb9:	00 
  801fba:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801fc1:	00 
  801fc2:	c7 04 24 48 2c 80 00 	movl   $0x802c48,(%esp)
  801fc9:	e8 5e e3 ff ff       	call   80032c <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd9:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801fe0:	e8 43 ec ff ff       	call   800c28 <memmove>
	nsipcbuf.send.req_size = size;
  801fe5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801feb:	8b 45 14             	mov    0x14(%ebp),%eax
  801fee:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ff3:	b8 08 00 00 00       	mov    $0x8,%eax
  801ff8:	e8 7b fd ff ff       	call   801d78 <nsipc>
}
  801ffd:	83 c4 14             	add    $0x14,%esp
  802000:	5b                   	pop    %ebx
  802001:	5d                   	pop    %ebp
  802002:	c3                   	ret    

00802003 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802003:	55                   	push   %ebp
  802004:	89 e5                	mov    %esp,%ebp
  802006:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802009:	8b 45 08             	mov    0x8(%ebp),%eax
  80200c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802011:	8b 45 0c             	mov    0xc(%ebp),%eax
  802014:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802019:	8b 45 10             	mov    0x10(%ebp),%eax
  80201c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802021:	b8 09 00 00 00       	mov    $0x9,%eax
  802026:	e8 4d fd ff ff       	call   801d78 <nsipc>
}
  80202b:	c9                   	leave  
  80202c:	c3                   	ret    
  80202d:	00 00                	add    %al,(%eax)
	...

00802030 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	56                   	push   %esi
  802034:	53                   	push   %ebx
  802035:	83 ec 10             	sub    $0x10,%esp
  802038:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80203b:	8b 45 08             	mov    0x8(%ebp),%eax
  80203e:	89 04 24             	mov    %eax,(%esp)
  802041:	e8 36 f1 ff ff       	call   80117c <fd2data>
  802046:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802048:	c7 44 24 04 60 2c 80 	movl   $0x802c60,0x4(%esp)
  80204f:	00 
  802050:	89 34 24             	mov    %esi,(%esp)
  802053:	e8 57 ea ff ff       	call   800aaf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802058:	8b 43 04             	mov    0x4(%ebx),%eax
  80205b:	2b 03                	sub    (%ebx),%eax
  80205d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802063:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80206a:	00 00 00 
	stat->st_dev = &devpipe;
  80206d:	c7 86 88 00 00 00 58 	movl   $0x803058,0x88(%esi)
  802074:	30 80 00 
	return 0;
}
  802077:	b8 00 00 00 00       	mov    $0x0,%eax
  80207c:	83 c4 10             	add    $0x10,%esp
  80207f:	5b                   	pop    %ebx
  802080:	5e                   	pop    %esi
  802081:	5d                   	pop    %ebp
  802082:	c3                   	ret    

00802083 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802083:	55                   	push   %ebp
  802084:	89 e5                	mov    %esp,%ebp
  802086:	53                   	push   %ebx
  802087:	83 ec 14             	sub    $0x14,%esp
  80208a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80208d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802091:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802098:	e8 ab ee ff ff       	call   800f48 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80209d:	89 1c 24             	mov    %ebx,(%esp)
  8020a0:	e8 d7 f0 ff ff       	call   80117c <fd2data>
  8020a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020b0:	e8 93 ee ff ff       	call   800f48 <sys_page_unmap>
}
  8020b5:	83 c4 14             	add    $0x14,%esp
  8020b8:	5b                   	pop    %ebx
  8020b9:	5d                   	pop    %ebp
  8020ba:	c3                   	ret    

008020bb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020bb:	55                   	push   %ebp
  8020bc:	89 e5                	mov    %esp,%ebp
  8020be:	57                   	push   %edi
  8020bf:	56                   	push   %esi
  8020c0:	53                   	push   %ebx
  8020c1:	83 ec 2c             	sub    $0x2c,%esp
  8020c4:	89 c7                	mov    %eax,%edi
  8020c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020c9:	a1 08 44 80 00       	mov    0x804408,%eax
  8020ce:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020d1:	89 3c 24             	mov    %edi,(%esp)
  8020d4:	e8 07 04 00 00       	call   8024e0 <pageref>
  8020d9:	89 c6                	mov    %eax,%esi
  8020db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020de:	89 04 24             	mov    %eax,(%esp)
  8020e1:	e8 fa 03 00 00       	call   8024e0 <pageref>
  8020e6:	39 c6                	cmp    %eax,%esi
  8020e8:	0f 94 c0             	sete   %al
  8020eb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8020ee:	8b 15 08 44 80 00    	mov    0x804408,%edx
  8020f4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8020f7:	39 cb                	cmp    %ecx,%ebx
  8020f9:	75 08                	jne    802103 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8020fb:	83 c4 2c             	add    $0x2c,%esp
  8020fe:	5b                   	pop    %ebx
  8020ff:	5e                   	pop    %esi
  802100:	5f                   	pop    %edi
  802101:	5d                   	pop    %ebp
  802102:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802103:	83 f8 01             	cmp    $0x1,%eax
  802106:	75 c1                	jne    8020c9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802108:	8b 42 58             	mov    0x58(%edx),%eax
  80210b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802112:	00 
  802113:	89 44 24 08          	mov    %eax,0x8(%esp)
  802117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80211b:	c7 04 24 67 2c 80 00 	movl   $0x802c67,(%esp)
  802122:	e8 fd e2 ff ff       	call   800424 <cprintf>
  802127:	eb a0                	jmp    8020c9 <_pipeisclosed+0xe>

00802129 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
  80212c:	57                   	push   %edi
  80212d:	56                   	push   %esi
  80212e:	53                   	push   %ebx
  80212f:	83 ec 1c             	sub    $0x1c,%esp
  802132:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802135:	89 34 24             	mov    %esi,(%esp)
  802138:	e8 3f f0 ff ff       	call   80117c <fd2data>
  80213d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80213f:	bf 00 00 00 00       	mov    $0x0,%edi
  802144:	eb 3c                	jmp    802182 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802146:	89 da                	mov    %ebx,%edx
  802148:	89 f0                	mov    %esi,%eax
  80214a:	e8 6c ff ff ff       	call   8020bb <_pipeisclosed>
  80214f:	85 c0                	test   %eax,%eax
  802151:	75 38                	jne    80218b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802153:	e8 2a ed ff ff       	call   800e82 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802158:	8b 43 04             	mov    0x4(%ebx),%eax
  80215b:	8b 13                	mov    (%ebx),%edx
  80215d:	83 c2 20             	add    $0x20,%edx
  802160:	39 d0                	cmp    %edx,%eax
  802162:	73 e2                	jae    802146 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802164:	8b 55 0c             	mov    0xc(%ebp),%edx
  802167:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80216a:	89 c2                	mov    %eax,%edx
  80216c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802172:	79 05                	jns    802179 <devpipe_write+0x50>
  802174:	4a                   	dec    %edx
  802175:	83 ca e0             	or     $0xffffffe0,%edx
  802178:	42                   	inc    %edx
  802179:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80217d:	40                   	inc    %eax
  80217e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802181:	47                   	inc    %edi
  802182:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802185:	75 d1                	jne    802158 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802187:	89 f8                	mov    %edi,%eax
  802189:	eb 05                	jmp    802190 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80218b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802190:	83 c4 1c             	add    $0x1c,%esp
  802193:	5b                   	pop    %ebx
  802194:	5e                   	pop    %esi
  802195:	5f                   	pop    %edi
  802196:	5d                   	pop    %ebp
  802197:	c3                   	ret    

00802198 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802198:	55                   	push   %ebp
  802199:	89 e5                	mov    %esp,%ebp
  80219b:	57                   	push   %edi
  80219c:	56                   	push   %esi
  80219d:	53                   	push   %ebx
  80219e:	83 ec 1c             	sub    $0x1c,%esp
  8021a1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021a4:	89 3c 24             	mov    %edi,(%esp)
  8021a7:	e8 d0 ef ff ff       	call   80117c <fd2data>
  8021ac:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021ae:	be 00 00 00 00       	mov    $0x0,%esi
  8021b3:	eb 3a                	jmp    8021ef <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021b5:	85 f6                	test   %esi,%esi
  8021b7:	74 04                	je     8021bd <devpipe_read+0x25>
				return i;
  8021b9:	89 f0                	mov    %esi,%eax
  8021bb:	eb 40                	jmp    8021fd <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021bd:	89 da                	mov    %ebx,%edx
  8021bf:	89 f8                	mov    %edi,%eax
  8021c1:	e8 f5 fe ff ff       	call   8020bb <_pipeisclosed>
  8021c6:	85 c0                	test   %eax,%eax
  8021c8:	75 2e                	jne    8021f8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021ca:	e8 b3 ec ff ff       	call   800e82 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021cf:	8b 03                	mov    (%ebx),%eax
  8021d1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8021d4:	74 df                	je     8021b5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021d6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8021db:	79 05                	jns    8021e2 <devpipe_read+0x4a>
  8021dd:	48                   	dec    %eax
  8021de:	83 c8 e0             	or     $0xffffffe0,%eax
  8021e1:	40                   	inc    %eax
  8021e2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8021e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021e9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8021ec:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021ee:	46                   	inc    %esi
  8021ef:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021f2:	75 db                	jne    8021cf <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8021f4:	89 f0                	mov    %esi,%eax
  8021f6:	eb 05                	jmp    8021fd <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021f8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8021fd:	83 c4 1c             	add    $0x1c,%esp
  802200:	5b                   	pop    %ebx
  802201:	5e                   	pop    %esi
  802202:	5f                   	pop    %edi
  802203:	5d                   	pop    %ebp
  802204:	c3                   	ret    

00802205 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802205:	55                   	push   %ebp
  802206:	89 e5                	mov    %esp,%ebp
  802208:	57                   	push   %edi
  802209:	56                   	push   %esi
  80220a:	53                   	push   %ebx
  80220b:	83 ec 3c             	sub    $0x3c,%esp
  80220e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802211:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802214:	89 04 24             	mov    %eax,(%esp)
  802217:	e8 7b ef ff ff       	call   801197 <fd_alloc>
  80221c:	89 c3                	mov    %eax,%ebx
  80221e:	85 c0                	test   %eax,%eax
  802220:	0f 88 45 01 00 00    	js     80236b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802226:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80222d:	00 
  80222e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802231:	89 44 24 04          	mov    %eax,0x4(%esp)
  802235:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80223c:	e8 60 ec ff ff       	call   800ea1 <sys_page_alloc>
  802241:	89 c3                	mov    %eax,%ebx
  802243:	85 c0                	test   %eax,%eax
  802245:	0f 88 20 01 00 00    	js     80236b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80224b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80224e:	89 04 24             	mov    %eax,(%esp)
  802251:	e8 41 ef ff ff       	call   801197 <fd_alloc>
  802256:	89 c3                	mov    %eax,%ebx
  802258:	85 c0                	test   %eax,%eax
  80225a:	0f 88 f8 00 00 00    	js     802358 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802260:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802267:	00 
  802268:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80226b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80226f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802276:	e8 26 ec ff ff       	call   800ea1 <sys_page_alloc>
  80227b:	89 c3                	mov    %eax,%ebx
  80227d:	85 c0                	test   %eax,%eax
  80227f:	0f 88 d3 00 00 00    	js     802358 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802285:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802288:	89 04 24             	mov    %eax,(%esp)
  80228b:	e8 ec ee ff ff       	call   80117c <fd2data>
  802290:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802292:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802299:	00 
  80229a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80229e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022a5:	e8 f7 eb ff ff       	call   800ea1 <sys_page_alloc>
  8022aa:	89 c3                	mov    %eax,%ebx
  8022ac:	85 c0                	test   %eax,%eax
  8022ae:	0f 88 91 00 00 00    	js     802345 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022b7:	89 04 24             	mov    %eax,(%esp)
  8022ba:	e8 bd ee ff ff       	call   80117c <fd2data>
  8022bf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8022c6:	00 
  8022c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022d2:	00 
  8022d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022de:	e8 12 ec ff ff       	call   800ef5 <sys_page_map>
  8022e3:	89 c3                	mov    %eax,%ebx
  8022e5:	85 c0                	test   %eax,%eax
  8022e7:	78 4c                	js     802335 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8022e9:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022f2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022f7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8022fe:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802304:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802307:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802309:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80230c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802313:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802316:	89 04 24             	mov    %eax,(%esp)
  802319:	e8 4e ee ff ff       	call   80116c <fd2num>
  80231e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802320:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802323:	89 04 24             	mov    %eax,(%esp)
  802326:	e8 41 ee ff ff       	call   80116c <fd2num>
  80232b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80232e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802333:	eb 36                	jmp    80236b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802335:	89 74 24 04          	mov    %esi,0x4(%esp)
  802339:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802340:	e8 03 ec ff ff       	call   800f48 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802345:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802348:	89 44 24 04          	mov    %eax,0x4(%esp)
  80234c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802353:	e8 f0 eb ff ff       	call   800f48 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802358:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80235b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80235f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802366:	e8 dd eb ff ff       	call   800f48 <sys_page_unmap>
    err:
	return r;
}
  80236b:	89 d8                	mov    %ebx,%eax
  80236d:	83 c4 3c             	add    $0x3c,%esp
  802370:	5b                   	pop    %ebx
  802371:	5e                   	pop    %esi
  802372:	5f                   	pop    %edi
  802373:	5d                   	pop    %ebp
  802374:	c3                   	ret    

00802375 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802375:	55                   	push   %ebp
  802376:	89 e5                	mov    %esp,%ebp
  802378:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80237b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80237e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802382:	8b 45 08             	mov    0x8(%ebp),%eax
  802385:	89 04 24             	mov    %eax,(%esp)
  802388:	e8 5d ee ff ff       	call   8011ea <fd_lookup>
  80238d:	85 c0                	test   %eax,%eax
  80238f:	78 15                	js     8023a6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802391:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802394:	89 04 24             	mov    %eax,(%esp)
  802397:	e8 e0 ed ff ff       	call   80117c <fd2data>
	return _pipeisclosed(fd, p);
  80239c:	89 c2                	mov    %eax,%edx
  80239e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023a1:	e8 15 fd ff ff       	call   8020bb <_pipeisclosed>
}
  8023a6:	c9                   	leave  
  8023a7:	c3                   	ret    

008023a8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023a8:	55                   	push   %ebp
  8023a9:	89 e5                	mov    %esp,%ebp
  8023ab:	56                   	push   %esi
  8023ac:	53                   	push   %ebx
  8023ad:	83 ec 10             	sub    $0x10,%esp
  8023b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8023b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023b6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8023b9:	85 c0                	test   %eax,%eax
  8023bb:	74 0a                	je     8023c7 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8023bd:	89 04 24             	mov    %eax,(%esp)
  8023c0:	e8 f2 ec ff ff       	call   8010b7 <sys_ipc_recv>
  8023c5:	eb 0c                	jmp    8023d3 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8023c7:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8023ce:	e8 e4 ec ff ff       	call   8010b7 <sys_ipc_recv>
	}
	if (r < 0)
  8023d3:	85 c0                	test   %eax,%eax
  8023d5:	79 16                	jns    8023ed <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8023d7:	85 db                	test   %ebx,%ebx
  8023d9:	74 06                	je     8023e1 <ipc_recv+0x39>
  8023db:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8023e1:	85 f6                	test   %esi,%esi
  8023e3:	74 2c                	je     802411 <ipc_recv+0x69>
  8023e5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8023eb:	eb 24                	jmp    802411 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8023ed:	85 db                	test   %ebx,%ebx
  8023ef:	74 0a                	je     8023fb <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  8023f1:	a1 08 44 80 00       	mov    0x804408,%eax
  8023f6:	8b 40 74             	mov    0x74(%eax),%eax
  8023f9:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  8023fb:	85 f6                	test   %esi,%esi
  8023fd:	74 0a                	je     802409 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  8023ff:	a1 08 44 80 00       	mov    0x804408,%eax
  802404:	8b 40 78             	mov    0x78(%eax),%eax
  802407:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802409:	a1 08 44 80 00       	mov    0x804408,%eax
  80240e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802411:	83 c4 10             	add    $0x10,%esp
  802414:	5b                   	pop    %ebx
  802415:	5e                   	pop    %esi
  802416:	5d                   	pop    %ebp
  802417:	c3                   	ret    

00802418 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802418:	55                   	push   %ebp
  802419:	89 e5                	mov    %esp,%ebp
  80241b:	57                   	push   %edi
  80241c:	56                   	push   %esi
  80241d:	53                   	push   %ebx
  80241e:	83 ec 1c             	sub    $0x1c,%esp
  802421:	8b 75 08             	mov    0x8(%ebp),%esi
  802424:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802427:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  80242a:	85 db                	test   %ebx,%ebx
  80242c:	74 19                	je     802447 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  80242e:	8b 45 14             	mov    0x14(%ebp),%eax
  802431:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802435:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802439:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80243d:	89 34 24             	mov    %esi,(%esp)
  802440:	e8 4f ec ff ff       	call   801094 <sys_ipc_try_send>
  802445:	eb 1c                	jmp    802463 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  802447:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80244e:	00 
  80244f:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802456:	ee 
  802457:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80245b:	89 34 24             	mov    %esi,(%esp)
  80245e:	e8 31 ec ff ff       	call   801094 <sys_ipc_try_send>
		}
		if (r == 0)
  802463:	85 c0                	test   %eax,%eax
  802465:	74 2c                	je     802493 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802467:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80246a:	74 20                	je     80248c <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  80246c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802470:	c7 44 24 08 7f 2c 80 	movl   $0x802c7f,0x8(%esp)
  802477:	00 
  802478:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80247f:	00 
  802480:	c7 04 24 92 2c 80 00 	movl   $0x802c92,(%esp)
  802487:	e8 a0 de ff ff       	call   80032c <_panic>
		}
		sys_yield();
  80248c:	e8 f1 e9 ff ff       	call   800e82 <sys_yield>
	}
  802491:	eb 97                	jmp    80242a <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802493:	83 c4 1c             	add    $0x1c,%esp
  802496:	5b                   	pop    %ebx
  802497:	5e                   	pop    %esi
  802498:	5f                   	pop    %edi
  802499:	5d                   	pop    %ebp
  80249a:	c3                   	ret    

0080249b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80249b:	55                   	push   %ebp
  80249c:	89 e5                	mov    %esp,%ebp
  80249e:	53                   	push   %ebx
  80249f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8024a2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8024a7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8024ae:	89 c2                	mov    %eax,%edx
  8024b0:	c1 e2 07             	shl    $0x7,%edx
  8024b3:	29 ca                	sub    %ecx,%edx
  8024b5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024bb:	8b 52 50             	mov    0x50(%edx),%edx
  8024be:	39 da                	cmp    %ebx,%edx
  8024c0:	75 0f                	jne    8024d1 <ipc_find_env+0x36>
			return envs[i].env_id;
  8024c2:	c1 e0 07             	shl    $0x7,%eax
  8024c5:	29 c8                	sub    %ecx,%eax
  8024c7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8024cc:	8b 40 40             	mov    0x40(%eax),%eax
  8024cf:	eb 0c                	jmp    8024dd <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024d1:	40                   	inc    %eax
  8024d2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024d7:	75 ce                	jne    8024a7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8024d9:	66 b8 00 00          	mov    $0x0,%ax
}
  8024dd:	5b                   	pop    %ebx
  8024de:	5d                   	pop    %ebp
  8024df:	c3                   	ret    

008024e0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024e0:	55                   	push   %ebp
  8024e1:	89 e5                	mov    %esp,%ebp
  8024e3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024e6:	89 c2                	mov    %eax,%edx
  8024e8:	c1 ea 16             	shr    $0x16,%edx
  8024eb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8024f2:	f6 c2 01             	test   $0x1,%dl
  8024f5:	74 1e                	je     802515 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8024f7:	c1 e8 0c             	shr    $0xc,%eax
  8024fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802501:	a8 01                	test   $0x1,%al
  802503:	74 17                	je     80251c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802505:	c1 e8 0c             	shr    $0xc,%eax
  802508:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80250f:	ef 
  802510:	0f b7 c0             	movzwl %ax,%eax
  802513:	eb 0c                	jmp    802521 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802515:	b8 00 00 00 00       	mov    $0x0,%eax
  80251a:	eb 05                	jmp    802521 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80251c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802521:	5d                   	pop    %ebp
  802522:	c3                   	ret    
	...

00802524 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802524:	55                   	push   %ebp
  802525:	57                   	push   %edi
  802526:	56                   	push   %esi
  802527:	83 ec 10             	sub    $0x10,%esp
  80252a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80252e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802532:	89 74 24 04          	mov    %esi,0x4(%esp)
  802536:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80253a:	89 cd                	mov    %ecx,%ebp
  80253c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802540:	85 c0                	test   %eax,%eax
  802542:	75 2c                	jne    802570 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802544:	39 f9                	cmp    %edi,%ecx
  802546:	77 68                	ja     8025b0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802548:	85 c9                	test   %ecx,%ecx
  80254a:	75 0b                	jne    802557 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80254c:	b8 01 00 00 00       	mov    $0x1,%eax
  802551:	31 d2                	xor    %edx,%edx
  802553:	f7 f1                	div    %ecx
  802555:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802557:	31 d2                	xor    %edx,%edx
  802559:	89 f8                	mov    %edi,%eax
  80255b:	f7 f1                	div    %ecx
  80255d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80255f:	89 f0                	mov    %esi,%eax
  802561:	f7 f1                	div    %ecx
  802563:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802565:	89 f0                	mov    %esi,%eax
  802567:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802569:	83 c4 10             	add    $0x10,%esp
  80256c:	5e                   	pop    %esi
  80256d:	5f                   	pop    %edi
  80256e:	5d                   	pop    %ebp
  80256f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802570:	39 f8                	cmp    %edi,%eax
  802572:	77 2c                	ja     8025a0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802574:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802577:	83 f6 1f             	xor    $0x1f,%esi
  80257a:	75 4c                	jne    8025c8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80257c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80257e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802583:	72 0a                	jb     80258f <__udivdi3+0x6b>
  802585:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802589:	0f 87 ad 00 00 00    	ja     80263c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80258f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802594:	89 f0                	mov    %esi,%eax
  802596:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802598:	83 c4 10             	add    $0x10,%esp
  80259b:	5e                   	pop    %esi
  80259c:	5f                   	pop    %edi
  80259d:	5d                   	pop    %ebp
  80259e:	c3                   	ret    
  80259f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8025a0:	31 ff                	xor    %edi,%edi
  8025a2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8025a4:	89 f0                	mov    %esi,%eax
  8025a6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8025a8:	83 c4 10             	add    $0x10,%esp
  8025ab:	5e                   	pop    %esi
  8025ac:	5f                   	pop    %edi
  8025ad:	5d                   	pop    %ebp
  8025ae:	c3                   	ret    
  8025af:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8025b0:	89 fa                	mov    %edi,%edx
  8025b2:	89 f0                	mov    %esi,%eax
  8025b4:	f7 f1                	div    %ecx
  8025b6:	89 c6                	mov    %eax,%esi
  8025b8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8025ba:	89 f0                	mov    %esi,%eax
  8025bc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8025be:	83 c4 10             	add    $0x10,%esp
  8025c1:	5e                   	pop    %esi
  8025c2:	5f                   	pop    %edi
  8025c3:	5d                   	pop    %ebp
  8025c4:	c3                   	ret    
  8025c5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8025c8:	89 f1                	mov    %esi,%ecx
  8025ca:	d3 e0                	shl    %cl,%eax
  8025cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8025d0:	b8 20 00 00 00       	mov    $0x20,%eax
  8025d5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8025d7:	89 ea                	mov    %ebp,%edx
  8025d9:	88 c1                	mov    %al,%cl
  8025db:	d3 ea                	shr    %cl,%edx
  8025dd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8025e1:	09 ca                	or     %ecx,%edx
  8025e3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8025e7:	89 f1                	mov    %esi,%ecx
  8025e9:	d3 e5                	shl    %cl,%ebp
  8025eb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8025ef:	89 fd                	mov    %edi,%ebp
  8025f1:	88 c1                	mov    %al,%cl
  8025f3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8025f5:	89 fa                	mov    %edi,%edx
  8025f7:	89 f1                	mov    %esi,%ecx
  8025f9:	d3 e2                	shl    %cl,%edx
  8025fb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8025ff:	88 c1                	mov    %al,%cl
  802601:	d3 ef                	shr    %cl,%edi
  802603:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802605:	89 f8                	mov    %edi,%eax
  802607:	89 ea                	mov    %ebp,%edx
  802609:	f7 74 24 08          	divl   0x8(%esp)
  80260d:	89 d1                	mov    %edx,%ecx
  80260f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802611:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802615:	39 d1                	cmp    %edx,%ecx
  802617:	72 17                	jb     802630 <__udivdi3+0x10c>
  802619:	74 09                	je     802624 <__udivdi3+0x100>
  80261b:	89 fe                	mov    %edi,%esi
  80261d:	31 ff                	xor    %edi,%edi
  80261f:	e9 41 ff ff ff       	jmp    802565 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802624:	8b 54 24 04          	mov    0x4(%esp),%edx
  802628:	89 f1                	mov    %esi,%ecx
  80262a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80262c:	39 c2                	cmp    %eax,%edx
  80262e:	73 eb                	jae    80261b <__udivdi3+0xf7>
		{
		  q0--;
  802630:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802633:	31 ff                	xor    %edi,%edi
  802635:	e9 2b ff ff ff       	jmp    802565 <__udivdi3+0x41>
  80263a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80263c:	31 f6                	xor    %esi,%esi
  80263e:	e9 22 ff ff ff       	jmp    802565 <__udivdi3+0x41>
	...

00802644 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802644:	55                   	push   %ebp
  802645:	57                   	push   %edi
  802646:	56                   	push   %esi
  802647:	83 ec 20             	sub    $0x20,%esp
  80264a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80264e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802652:	89 44 24 14          	mov    %eax,0x14(%esp)
  802656:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80265a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80265e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802662:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802664:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802666:	85 ed                	test   %ebp,%ebp
  802668:	75 16                	jne    802680 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80266a:	39 f1                	cmp    %esi,%ecx
  80266c:	0f 86 a6 00 00 00    	jbe    802718 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802672:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802674:	89 d0                	mov    %edx,%eax
  802676:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802678:	83 c4 20             	add    $0x20,%esp
  80267b:	5e                   	pop    %esi
  80267c:	5f                   	pop    %edi
  80267d:	5d                   	pop    %ebp
  80267e:	c3                   	ret    
  80267f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802680:	39 f5                	cmp    %esi,%ebp
  802682:	0f 87 ac 00 00 00    	ja     802734 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802688:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80268b:	83 f0 1f             	xor    $0x1f,%eax
  80268e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802692:	0f 84 a8 00 00 00    	je     802740 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802698:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80269c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80269e:	bf 20 00 00 00       	mov    $0x20,%edi
  8026a3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8026a7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8026ab:	89 f9                	mov    %edi,%ecx
  8026ad:	d3 e8                	shr    %cl,%eax
  8026af:	09 e8                	or     %ebp,%eax
  8026b1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8026b5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8026b9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026bd:	d3 e0                	shl    %cl,%eax
  8026bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8026c3:	89 f2                	mov    %esi,%edx
  8026c5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8026c7:	8b 44 24 14          	mov    0x14(%esp),%eax
  8026cb:	d3 e0                	shl    %cl,%eax
  8026cd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8026d1:	8b 44 24 14          	mov    0x14(%esp),%eax
  8026d5:	89 f9                	mov    %edi,%ecx
  8026d7:	d3 e8                	shr    %cl,%eax
  8026d9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8026db:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8026dd:	89 f2                	mov    %esi,%edx
  8026df:	f7 74 24 18          	divl   0x18(%esp)
  8026e3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8026e5:	f7 64 24 0c          	mull   0xc(%esp)
  8026e9:	89 c5                	mov    %eax,%ebp
  8026eb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8026ed:	39 d6                	cmp    %edx,%esi
  8026ef:	72 67                	jb     802758 <__umoddi3+0x114>
  8026f1:	74 75                	je     802768 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8026f3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8026f7:	29 e8                	sub    %ebp,%eax
  8026f9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8026fb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8026ff:	d3 e8                	shr    %cl,%eax
  802701:	89 f2                	mov    %esi,%edx
  802703:	89 f9                	mov    %edi,%ecx
  802705:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802707:	09 d0                	or     %edx,%eax
  802709:	89 f2                	mov    %esi,%edx
  80270b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80270f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802711:	83 c4 20             	add    $0x20,%esp
  802714:	5e                   	pop    %esi
  802715:	5f                   	pop    %edi
  802716:	5d                   	pop    %ebp
  802717:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802718:	85 c9                	test   %ecx,%ecx
  80271a:	75 0b                	jne    802727 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80271c:	b8 01 00 00 00       	mov    $0x1,%eax
  802721:	31 d2                	xor    %edx,%edx
  802723:	f7 f1                	div    %ecx
  802725:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802727:	89 f0                	mov    %esi,%eax
  802729:	31 d2                	xor    %edx,%edx
  80272b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80272d:	89 f8                	mov    %edi,%eax
  80272f:	e9 3e ff ff ff       	jmp    802672 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802734:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802736:	83 c4 20             	add    $0x20,%esp
  802739:	5e                   	pop    %esi
  80273a:	5f                   	pop    %edi
  80273b:	5d                   	pop    %ebp
  80273c:	c3                   	ret    
  80273d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802740:	39 f5                	cmp    %esi,%ebp
  802742:	72 04                	jb     802748 <__umoddi3+0x104>
  802744:	39 f9                	cmp    %edi,%ecx
  802746:	77 06                	ja     80274e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802748:	89 f2                	mov    %esi,%edx
  80274a:	29 cf                	sub    %ecx,%edi
  80274c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80274e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802750:	83 c4 20             	add    $0x20,%esp
  802753:	5e                   	pop    %esi
  802754:	5f                   	pop    %edi
  802755:	5d                   	pop    %ebp
  802756:	c3                   	ret    
  802757:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802758:	89 d1                	mov    %edx,%ecx
  80275a:	89 c5                	mov    %eax,%ebp
  80275c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802760:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802764:	eb 8d                	jmp    8026f3 <__umoddi3+0xaf>
  802766:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802768:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80276c:	72 ea                	jb     802758 <__umoddi3+0x114>
  80276e:	89 f1                	mov    %esi,%ecx
  802770:	eb 81                	jmp    8026f3 <__umoddi3+0xaf>
