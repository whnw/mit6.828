
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 17 02 00 00       	call   800248 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 f7 0c 00 00       	call   800d4d <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 a0 26 80 	movl   $0x8026a0,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 b3 26 80 00 	movl   $0x8026b3,(%esp)
  800075:	e8 3e 02 00 00       	call   8002b8 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 03 0d 00 00       	call   800da1 <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 c3 26 80 	movl   $0x8026c3,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 b3 26 80 00 	movl   $0x8026b3,(%esp)
  8000bd:	e8 f6 01 00 00       	call   8002b8 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 fa 09 00 00       	call   800ad4 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 06 0d 00 00       	call   800df4 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 d4 26 80 	movl   $0x8026d4,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 b3 26 80 00 	movl   $0x8026b3,(%esp)
  80010d:	e8 a6 01 00 00       	call   8002b8 <_panic>
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800121:	be 07 00 00 00       	mov    $0x7,%esi
  800126:	89 f0                	mov    %esi,%eax
  800128:	cd 30                	int    $0x30
  80012a:	89 c6                	mov    %eax,%esi
  80012c:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80012e:	85 c0                	test   %eax,%eax
  800130:	79 20                	jns    800152 <dumbfork+0x39>
		panic("sys_exofork: %e", envid);
  800132:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800136:	c7 44 24 08 e7 26 80 	movl   $0x8026e7,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 b3 26 80 00 	movl   $0x8026b3,(%esp)
  80014d:	e8 66 01 00 00       	call   8002b8 <_panic>
	if (envid == 0) {
  800152:	85 c0                	test   %eax,%eax
  800154:	75 22                	jne    800178 <dumbfork+0x5f>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800156:	e8 b4 0b 00 00       	call   800d0f <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800167:	c1 e0 07             	shl    $0x7,%eax
  80016a:	29 d0                	sub    %edx,%eax
  80016c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800171:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  800176:	eb 6e                	jmp    8001e6 <dumbfork+0xcd>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800178:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  80017f:	eb 13                	jmp    800194 <dumbfork+0x7b>
		duppage(envid, addr);
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	89 1c 24             	mov    %ebx,(%esp)
  800188:	e8 a7 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80018d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800194:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800197:	3d 00 70 80 00       	cmp    $0x807000,%eax
  80019c:	72 e3                	jb     800181 <dumbfork+0x68>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  80019e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001aa:	89 34 24             	mov    %esi,(%esp)
  8001ad:	e8 82 fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001b2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001b9:	00 
  8001ba:	89 34 24             	mov    %esi,(%esp)
  8001bd:	e8 85 0c 00 00       	call   800e47 <sys_env_set_status>
  8001c2:	85 c0                	test   %eax,%eax
  8001c4:	79 20                	jns    8001e6 <dumbfork+0xcd>
		panic("sys_env_set_status: %e", r);
  8001c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ca:	c7 44 24 08 f7 26 80 	movl   $0x8026f7,0x8(%esp)
  8001d1:	00 
  8001d2:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001d9:	00 
  8001da:	c7 04 24 b3 26 80 00 	movl   $0x8026b3,(%esp)
  8001e1:	e8 d2 00 00 00       	call   8002b8 <_panic>

	return envid;
}
  8001e6:	89 f0                	mov    %esi,%eax
  8001e8:	83 c4 20             	add    $0x20,%esp
  8001eb:	5b                   	pop    %ebx
  8001ec:	5e                   	pop    %esi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	56                   	push   %esi
  8001f3:	53                   	push   %ebx
  8001f4:	83 ec 10             	sub    $0x10,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001f7:	e8 1d ff ff ff       	call   800119 <dumbfork>
  8001fc:	89 c3                	mov    %eax,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001fe:	be 00 00 00 00       	mov    $0x0,%esi
  800203:	eb 2a                	jmp    80022f <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800205:	85 db                	test   %ebx,%ebx
  800207:	74 07                	je     800210 <umain+0x21>
  800209:	b8 0e 27 80 00       	mov    $0x80270e,%eax
  80020e:	eb 05                	jmp    800215 <umain+0x26>
  800210:	b8 15 27 80 00       	mov    $0x802715,%eax
  800215:	89 44 24 08          	mov    %eax,0x8(%esp)
  800219:	89 74 24 04          	mov    %esi,0x4(%esp)
  80021d:	c7 04 24 1b 27 80 00 	movl   $0x80271b,(%esp)
  800224:	e8 87 01 00 00       	call   8003b0 <cprintf>
		sys_yield();
  800229:	e8 00 0b 00 00       	call   800d2e <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  80022e:	46                   	inc    %esi
  80022f:	83 fb 01             	cmp    $0x1,%ebx
  800232:	19 c0                	sbb    %eax,%eax
  800234:	83 e0 0a             	and    $0xa,%eax
  800237:	83 c0 0a             	add    $0xa,%eax
  80023a:	39 c6                	cmp    %eax,%esi
  80023c:	7c c7                	jl     800205 <umain+0x16>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  80023e:	83 c4 10             	add    $0x10,%esp
  800241:	5b                   	pop    %ebx
  800242:	5e                   	pop    %esi
  800243:	5d                   	pop    %ebp
  800244:	c3                   	ret    
  800245:	00 00                	add    %al,(%eax)
	...

00800248 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	56                   	push   %esi
  80024c:	53                   	push   %ebx
  80024d:	83 ec 10             	sub    $0x10,%esp
  800250:	8b 75 08             	mov    0x8(%ebp),%esi
  800253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800256:	e8 b4 0a 00 00       	call   800d0f <sys_getenvid>
  80025b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800260:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800267:	c1 e0 07             	shl    $0x7,%eax
  80026a:	29 d0                	sub    %edx,%eax
  80026c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800271:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800276:	85 f6                	test   %esi,%esi
  800278:	7e 07                	jle    800281 <libmain+0x39>
		binaryname = argv[0];
  80027a:	8b 03                	mov    (%ebx),%eax
  80027c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800281:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800285:	89 34 24             	mov    %esi,(%esp)
  800288:	e8 62 ff ff ff       	call   8001ef <umain>

	// exit gracefully
	exit();
  80028d:	e8 0a 00 00 00       	call   80029c <exit>
}
  800292:	83 c4 10             	add    $0x10,%esp
  800295:	5b                   	pop    %ebx
  800296:	5e                   	pop    %esi
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    
  800299:	00 00                	add    %al,(%eax)
	...

0080029c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8002a2:	e8 58 0f 00 00       	call   8011ff <close_all>
	sys_env_destroy(0);
  8002a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002ae:	e8 0a 0a 00 00       	call   800cbd <sys_env_destroy>
}
  8002b3:	c9                   	leave  
  8002b4:	c3                   	ret    
  8002b5:	00 00                	add    %al,(%eax)
	...

008002b8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	56                   	push   %esi
  8002bc:	53                   	push   %ebx
  8002bd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002c3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002c9:	e8 41 0a 00 00       	call   800d0f <sys_getenvid>
  8002ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002dc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e4:	c7 04 24 38 27 80 00 	movl   $0x802738,(%esp)
  8002eb:	e8 c0 00 00 00       	call   8003b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f7:	89 04 24             	mov    %eax,(%esp)
  8002fa:	e8 50 00 00 00       	call   80034f <vcprintf>
	cprintf("\n");
  8002ff:	c7 04 24 2b 27 80 00 	movl   $0x80272b,(%esp)
  800306:	e8 a5 00 00 00       	call   8003b0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80030b:	cc                   	int3   
  80030c:	eb fd                	jmp    80030b <_panic+0x53>
	...

00800310 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	53                   	push   %ebx
  800314:	83 ec 14             	sub    $0x14,%esp
  800317:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031a:	8b 03                	mov    (%ebx),%eax
  80031c:	8b 55 08             	mov    0x8(%ebp),%edx
  80031f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800323:	40                   	inc    %eax
  800324:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800326:	3d ff 00 00 00       	cmp    $0xff,%eax
  80032b:	75 19                	jne    800346 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80032d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800334:	00 
  800335:	8d 43 08             	lea    0x8(%ebx),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	e8 40 09 00 00       	call   800c80 <sys_cputs>
		b->idx = 0;
  800340:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800346:	ff 43 04             	incl   0x4(%ebx)
}
  800349:	83 c4 14             	add    $0x14,%esp
  80034c:	5b                   	pop    %ebx
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800358:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80035f:	00 00 00 
	b.cnt = 0;
  800362:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800369:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80036c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80036f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800373:	8b 45 08             	mov    0x8(%ebp),%eax
  800376:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800380:	89 44 24 04          	mov    %eax,0x4(%esp)
  800384:	c7 04 24 10 03 80 00 	movl   $0x800310,(%esp)
  80038b:	e8 82 01 00 00       	call   800512 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800390:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800396:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003a0:	89 04 24             	mov    %eax,(%esp)
  8003a3:	e8 d8 08 00 00       	call   800c80 <sys_cputs>

	return b.cnt;
}
  8003a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ae:	c9                   	leave  
  8003af:	c3                   	ret    

008003b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	e8 87 ff ff ff       	call   80034f <vcprintf>
	va_end(ap);

	return cnt;
}
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    
	...

008003cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	57                   	push   %edi
  8003d0:	56                   	push   %esi
  8003d1:	53                   	push   %ebx
  8003d2:	83 ec 3c             	sub    $0x3c,%esp
  8003d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d8:	89 d7                	mov    %edx,%edi
  8003da:	8b 45 08             	mov    0x8(%ebp),%eax
  8003dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003e9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003ec:	85 c0                	test   %eax,%eax
  8003ee:	75 08                	jne    8003f8 <printnum+0x2c>
  8003f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003f6:	77 57                	ja     80044f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003f8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003fc:	4b                   	dec    %ebx
  8003fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800401:	8b 45 10             	mov    0x10(%ebp),%eax
  800404:	89 44 24 08          	mov    %eax,0x8(%esp)
  800408:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80040c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800410:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800417:	00 
  800418:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80041b:	89 04 24             	mov    %eax,(%esp)
  80041e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800421:	89 44 24 04          	mov    %eax,0x4(%esp)
  800425:	e8 0e 20 00 00       	call   802438 <__udivdi3>
  80042a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80042e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800432:	89 04 24             	mov    %eax,(%esp)
  800435:	89 54 24 04          	mov    %edx,0x4(%esp)
  800439:	89 fa                	mov    %edi,%edx
  80043b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80043e:	e8 89 ff ff ff       	call   8003cc <printnum>
  800443:	eb 0f                	jmp    800454 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800445:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800449:	89 34 24             	mov    %esi,(%esp)
  80044c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80044f:	4b                   	dec    %ebx
  800450:	85 db                	test   %ebx,%ebx
  800452:	7f f1                	jg     800445 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800454:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800458:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80045c:	8b 45 10             	mov    0x10(%ebp),%eax
  80045f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800463:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80046a:	00 
  80046b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80046e:	89 04 24             	mov    %eax,(%esp)
  800471:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800474:	89 44 24 04          	mov    %eax,0x4(%esp)
  800478:	e8 db 20 00 00       	call   802558 <__umoddi3>
  80047d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800481:	0f be 80 5b 27 80 00 	movsbl 0x80275b(%eax),%eax
  800488:	89 04 24             	mov    %eax,(%esp)
  80048b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80048e:	83 c4 3c             	add    $0x3c,%esp
  800491:	5b                   	pop    %ebx
  800492:	5e                   	pop    %esi
  800493:	5f                   	pop    %edi
  800494:	5d                   	pop    %ebp
  800495:	c3                   	ret    

00800496 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800496:	55                   	push   %ebp
  800497:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800499:	83 fa 01             	cmp    $0x1,%edx
  80049c:	7e 0e                	jle    8004ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80049e:	8b 10                	mov    (%eax),%edx
  8004a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a3:	89 08                	mov    %ecx,(%eax)
  8004a5:	8b 02                	mov    (%edx),%eax
  8004a7:	8b 52 04             	mov    0x4(%edx),%edx
  8004aa:	eb 22                	jmp    8004ce <getuint+0x38>
	else if (lflag)
  8004ac:	85 d2                	test   %edx,%edx
  8004ae:	74 10                	je     8004c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004b0:	8b 10                	mov    (%eax),%edx
  8004b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b5:	89 08                	mov    %ecx,(%eax)
  8004b7:	8b 02                	mov    (%edx),%eax
  8004b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004be:	eb 0e                	jmp    8004ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004c0:	8b 10                	mov    (%eax),%edx
  8004c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c5:	89 08                	mov    %ecx,(%eax)
  8004c7:	8b 02                	mov    (%edx),%eax
  8004c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004ce:	5d                   	pop    %ebp
  8004cf:	c3                   	ret    

008004d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004d9:	8b 10                	mov    (%eax),%edx
  8004db:	3b 50 04             	cmp    0x4(%eax),%edx
  8004de:	73 08                	jae    8004e8 <sprintputch+0x18>
		*b->buf++ = ch;
  8004e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004e3:	88 0a                	mov    %cl,(%edx)
  8004e5:	42                   	inc    %edx
  8004e6:	89 10                	mov    %edx,(%eax)
}
  8004e8:	5d                   	pop    %ebp
  8004e9:	c3                   	ret    

008004ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8004fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800501:	89 44 24 04          	mov    %eax,0x4(%esp)
  800505:	8b 45 08             	mov    0x8(%ebp),%eax
  800508:	89 04 24             	mov    %eax,(%esp)
  80050b:	e8 02 00 00 00       	call   800512 <vprintfmt>
	va_end(ap);
}
  800510:	c9                   	leave  
  800511:	c3                   	ret    

00800512 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	57                   	push   %edi
  800516:	56                   	push   %esi
  800517:	53                   	push   %ebx
  800518:	83 ec 4c             	sub    $0x4c,%esp
  80051b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051e:	8b 75 10             	mov    0x10(%ebp),%esi
  800521:	eb 12                	jmp    800535 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800523:	85 c0                	test   %eax,%eax
  800525:	0f 84 6b 03 00 00    	je     800896 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80052b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800535:	0f b6 06             	movzbl (%esi),%eax
  800538:	46                   	inc    %esi
  800539:	83 f8 25             	cmp    $0x25,%eax
  80053c:	75 e5                	jne    800523 <vprintfmt+0x11>
  80053e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800542:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800549:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80054e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800555:	b9 00 00 00 00       	mov    $0x0,%ecx
  80055a:	eb 26                	jmp    800582 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80055f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800563:	eb 1d                	jmp    800582 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800568:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80056c:	eb 14                	jmp    800582 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800571:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800578:	eb 08                	jmp    800582 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80057a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80057d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	0f b6 06             	movzbl (%esi),%eax
  800585:	8d 56 01             	lea    0x1(%esi),%edx
  800588:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80058b:	8a 16                	mov    (%esi),%dl
  80058d:	83 ea 23             	sub    $0x23,%edx
  800590:	80 fa 55             	cmp    $0x55,%dl
  800593:	0f 87 e1 02 00 00    	ja     80087a <vprintfmt+0x368>
  800599:	0f b6 d2             	movzbl %dl,%edx
  80059c:	ff 24 95 a0 28 80 00 	jmp    *0x8028a0(,%edx,4)
  8005a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005a6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ab:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8005ae:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8005b2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005b5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005b8:	83 fa 09             	cmp    $0x9,%edx
  8005bb:	77 2a                	ja     8005e7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005bd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005be:	eb eb                	jmp    8005ab <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 04             	lea    0x4(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ce:	eb 17                	jmp    8005e7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d4:	78 98                	js     80056e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005d9:	eb a7                	jmp    800582 <vprintfmt+0x70>
  8005db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005de:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005e5:	eb 9b                	jmp    800582 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005eb:	79 95                	jns    800582 <vprintfmt+0x70>
  8005ed:	eb 8b                	jmp    80057a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ef:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005f3:	eb 8d                	jmp    800582 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 04             	lea    0x4(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800602:	8b 00                	mov    (%eax),%eax
  800604:	89 04 24             	mov    %eax,(%esp)
  800607:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80060d:	e9 23 ff ff ff       	jmp    800535 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	8b 00                	mov    (%eax),%eax
  80061d:	85 c0                	test   %eax,%eax
  80061f:	79 02                	jns    800623 <vprintfmt+0x111>
  800621:	f7 d8                	neg    %eax
  800623:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800625:	83 f8 10             	cmp    $0x10,%eax
  800628:	7f 0b                	jg     800635 <vprintfmt+0x123>
  80062a:	8b 04 85 00 2a 80 00 	mov    0x802a00(,%eax,4),%eax
  800631:	85 c0                	test   %eax,%eax
  800633:	75 23                	jne    800658 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800635:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800639:	c7 44 24 08 73 27 80 	movl   $0x802773,0x8(%esp)
  800640:	00 
  800641:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800645:	8b 45 08             	mov    0x8(%ebp),%eax
  800648:	89 04 24             	mov    %eax,(%esp)
  80064b:	e8 9a fe ff ff       	call   8004ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800650:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800653:	e9 dd fe ff ff       	jmp    800535 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800658:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80065c:	c7 44 24 08 3d 2b 80 	movl   $0x802b3d,0x8(%esp)
  800663:	00 
  800664:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800668:	8b 55 08             	mov    0x8(%ebp),%edx
  80066b:	89 14 24             	mov    %edx,(%esp)
  80066e:	e8 77 fe ff ff       	call   8004ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800676:	e9 ba fe ff ff       	jmp    800535 <vprintfmt+0x23>
  80067b:	89 f9                	mov    %edi,%ecx
  80067d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800680:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 50 04             	lea    0x4(%eax),%edx
  800689:	89 55 14             	mov    %edx,0x14(%ebp)
  80068c:	8b 30                	mov    (%eax),%esi
  80068e:	85 f6                	test   %esi,%esi
  800690:	75 05                	jne    800697 <vprintfmt+0x185>
				p = "(null)";
  800692:	be 6c 27 80 00       	mov    $0x80276c,%esi
			if (width > 0 && padc != '-')
  800697:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80069b:	0f 8e 84 00 00 00    	jle    800725 <vprintfmt+0x213>
  8006a1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8006a5:	74 7e                	je     800725 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006ab:	89 34 24             	mov    %esi,(%esp)
  8006ae:	e8 8b 02 00 00       	call   80093e <strnlen>
  8006b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006b6:	29 c2                	sub    %eax,%edx
  8006b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8006bb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006bf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006c2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006c5:	89 de                	mov    %ebx,%esi
  8006c7:	89 d3                	mov    %edx,%ebx
  8006c9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cb:	eb 0b                	jmp    8006d8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d1:	89 3c 24             	mov    %edi,(%esp)
  8006d4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d7:	4b                   	dec    %ebx
  8006d8:	85 db                	test   %ebx,%ebx
  8006da:	7f f1                	jg     8006cd <vprintfmt+0x1bb>
  8006dc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006df:	89 f3                	mov    %esi,%ebx
  8006e1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	79 05                	jns    8006f0 <vprintfmt+0x1de>
  8006eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f3:	29 c2                	sub    %eax,%edx
  8006f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006f8:	eb 2b                	jmp    800725 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006fa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006fe:	74 18                	je     800718 <vprintfmt+0x206>
  800700:	8d 50 e0             	lea    -0x20(%eax),%edx
  800703:	83 fa 5e             	cmp    $0x5e,%edx
  800706:	76 10                	jbe    800718 <vprintfmt+0x206>
					putch('?', putdat);
  800708:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800713:	ff 55 08             	call   *0x8(%ebp)
  800716:	eb 0a                	jmp    800722 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800718:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071c:	89 04 24             	mov    %eax,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800722:	ff 4d e4             	decl   -0x1c(%ebp)
  800725:	0f be 06             	movsbl (%esi),%eax
  800728:	46                   	inc    %esi
  800729:	85 c0                	test   %eax,%eax
  80072b:	74 21                	je     80074e <vprintfmt+0x23c>
  80072d:	85 ff                	test   %edi,%edi
  80072f:	78 c9                	js     8006fa <vprintfmt+0x1e8>
  800731:	4f                   	dec    %edi
  800732:	79 c6                	jns    8006fa <vprintfmt+0x1e8>
  800734:	8b 7d 08             	mov    0x8(%ebp),%edi
  800737:	89 de                	mov    %ebx,%esi
  800739:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80073c:	eb 18                	jmp    800756 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800742:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800749:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80074b:	4b                   	dec    %ebx
  80074c:	eb 08                	jmp    800756 <vprintfmt+0x244>
  80074e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800751:	89 de                	mov    %ebx,%esi
  800753:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800756:	85 db                	test   %ebx,%ebx
  800758:	7f e4                	jg     80073e <vprintfmt+0x22c>
  80075a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80075d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800762:	e9 ce fd ff ff       	jmp    800535 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800767:	83 f9 01             	cmp    $0x1,%ecx
  80076a:	7e 10                	jle    80077c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8d 50 08             	lea    0x8(%eax),%edx
  800772:	89 55 14             	mov    %edx,0x14(%ebp)
  800775:	8b 30                	mov    (%eax),%esi
  800777:	8b 78 04             	mov    0x4(%eax),%edi
  80077a:	eb 26                	jmp    8007a2 <vprintfmt+0x290>
	else if (lflag)
  80077c:	85 c9                	test   %ecx,%ecx
  80077e:	74 12                	je     800792 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800780:	8b 45 14             	mov    0x14(%ebp),%eax
  800783:	8d 50 04             	lea    0x4(%eax),%edx
  800786:	89 55 14             	mov    %edx,0x14(%ebp)
  800789:	8b 30                	mov    (%eax),%esi
  80078b:	89 f7                	mov    %esi,%edi
  80078d:	c1 ff 1f             	sar    $0x1f,%edi
  800790:	eb 10                	jmp    8007a2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8d 50 04             	lea    0x4(%eax),%edx
  800798:	89 55 14             	mov    %edx,0x14(%ebp)
  80079b:	8b 30                	mov    (%eax),%esi
  80079d:	89 f7                	mov    %esi,%edi
  80079f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007a2:	85 ff                	test   %edi,%edi
  8007a4:	78 0a                	js     8007b0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ab:	e9 8c 00 00 00       	jmp    80083c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007bb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007be:	f7 de                	neg    %esi
  8007c0:	83 d7 00             	adc    $0x0,%edi
  8007c3:	f7 df                	neg    %edi
			}
			base = 10;
  8007c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ca:	eb 70                	jmp    80083c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007cc:	89 ca                	mov    %ecx,%edx
  8007ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d1:	e8 c0 fc ff ff       	call   800496 <getuint>
  8007d6:	89 c6                	mov    %eax,%esi
  8007d8:	89 d7                	mov    %edx,%edi
			base = 10;
  8007da:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007df:	eb 5b                	jmp    80083c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  8007e1:	89 ca                	mov    %ecx,%edx
  8007e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e6:	e8 ab fc ff ff       	call   800496 <getuint>
  8007eb:	89 c6                	mov    %eax,%esi
  8007ed:	89 d7                	mov    %edx,%edi
			base = 8;
  8007ef:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007f4:	eb 46                	jmp    80083c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8007f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007fa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800801:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800804:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800808:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80080f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800812:	8b 45 14             	mov    0x14(%ebp),%eax
  800815:	8d 50 04             	lea    0x4(%eax),%edx
  800818:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80081b:	8b 30                	mov    (%eax),%esi
  80081d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800822:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800827:	eb 13                	jmp    80083c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800829:	89 ca                	mov    %ecx,%edx
  80082b:	8d 45 14             	lea    0x14(%ebp),%eax
  80082e:	e8 63 fc ff ff       	call   800496 <getuint>
  800833:	89 c6                	mov    %eax,%esi
  800835:	89 d7                	mov    %edx,%edi
			base = 16;
  800837:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80083c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800840:	89 54 24 10          	mov    %edx,0x10(%esp)
  800844:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800847:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80084b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084f:	89 34 24             	mov    %esi,(%esp)
  800852:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800856:	89 da                	mov    %ebx,%edx
  800858:	8b 45 08             	mov    0x8(%ebp),%eax
  80085b:	e8 6c fb ff ff       	call   8003cc <printnum>
			break;
  800860:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800863:	e9 cd fc ff ff       	jmp    800535 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800868:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80086c:	89 04 24             	mov    %eax,(%esp)
  80086f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800872:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800875:	e9 bb fc ff ff       	jmp    800535 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80087a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800885:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800888:	eb 01                	jmp    80088b <vprintfmt+0x379>
  80088a:	4e                   	dec    %esi
  80088b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80088f:	75 f9                	jne    80088a <vprintfmt+0x378>
  800891:	e9 9f fc ff ff       	jmp    800535 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800896:	83 c4 4c             	add    $0x4c,%esp
  800899:	5b                   	pop    %ebx
  80089a:	5e                   	pop    %esi
  80089b:	5f                   	pop    %edi
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	83 ec 28             	sub    $0x28,%esp
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008bb:	85 c0                	test   %eax,%eax
  8008bd:	74 30                	je     8008ef <vsnprintf+0x51>
  8008bf:	85 d2                	test   %edx,%edx
  8008c1:	7e 33                	jle    8008f6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8008cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d8:	c7 04 24 d0 04 80 00 	movl   $0x8004d0,(%esp)
  8008df:	e8 2e fc ff ff       	call   800512 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ed:	eb 0c                	jmp    8008fb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f4:	eb 05                	jmp    8008fb <vsnprintf+0x5d>
  8008f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008fb:	c9                   	leave  
  8008fc:	c3                   	ret    

008008fd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800903:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800906:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80090a:	8b 45 10             	mov    0x10(%ebp),%eax
  80090d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800911:	8b 45 0c             	mov    0xc(%ebp),%eax
  800914:	89 44 24 04          	mov    %eax,0x4(%esp)
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	89 04 24             	mov    %eax,(%esp)
  80091e:	e8 7b ff ff ff       	call   80089e <vsnprintf>
	va_end(ap);

	return rc;
}
  800923:	c9                   	leave  
  800924:	c3                   	ret    
  800925:	00 00                	add    %al,(%eax)
	...

00800928 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
  800933:	eb 01                	jmp    800936 <strlen+0xe>
		n++;
  800935:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800936:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80093a:	75 f9                	jne    800935 <strlen+0xd>
		n++;
	return n;
}
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800947:	b8 00 00 00 00       	mov    $0x0,%eax
  80094c:	eb 01                	jmp    80094f <strnlen+0x11>
		n++;
  80094e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80094f:	39 d0                	cmp    %edx,%eax
  800951:	74 06                	je     800959 <strnlen+0x1b>
  800953:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800957:	75 f5                	jne    80094e <strnlen+0x10>
		n++;
	return n;
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	53                   	push   %ebx
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800965:	ba 00 00 00 00       	mov    $0x0,%edx
  80096a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80096d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800970:	42                   	inc    %edx
  800971:	84 c9                	test   %cl,%cl
  800973:	75 f5                	jne    80096a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800975:	5b                   	pop    %ebx
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	53                   	push   %ebx
  80097c:	83 ec 08             	sub    $0x8,%esp
  80097f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800982:	89 1c 24             	mov    %ebx,(%esp)
  800985:	e8 9e ff ff ff       	call   800928 <strlen>
	strcpy(dst + len, src);
  80098a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800991:	01 d8                	add    %ebx,%eax
  800993:	89 04 24             	mov    %eax,(%esp)
  800996:	e8 c0 ff ff ff       	call   80095b <strcpy>
	return dst;
}
  80099b:	89 d8                	mov    %ebx,%eax
  80099d:	83 c4 08             	add    $0x8,%esp
  8009a0:	5b                   	pop    %ebx
  8009a1:	5d                   	pop    %ebp
  8009a2:	c3                   	ret    

008009a3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a3:	55                   	push   %ebp
  8009a4:	89 e5                	mov    %esp,%ebp
  8009a6:	56                   	push   %esi
  8009a7:	53                   	push   %ebx
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ae:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009b6:	eb 0c                	jmp    8009c4 <strncpy+0x21>
		*dst++ = *src;
  8009b8:	8a 1a                	mov    (%edx),%bl
  8009ba:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009bd:	80 3a 01             	cmpb   $0x1,(%edx)
  8009c0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c3:	41                   	inc    %ecx
  8009c4:	39 f1                	cmp    %esi,%ecx
  8009c6:	75 f0                	jne    8009b8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009c8:	5b                   	pop    %ebx
  8009c9:	5e                   	pop    %esi
  8009ca:	5d                   	pop    %ebp
  8009cb:	c3                   	ret    

008009cc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	56                   	push   %esi
  8009d0:	53                   	push   %ebx
  8009d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009d7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009da:	85 d2                	test   %edx,%edx
  8009dc:	75 0a                	jne    8009e8 <strlcpy+0x1c>
  8009de:	89 f0                	mov    %esi,%eax
  8009e0:	eb 1a                	jmp    8009fc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009e2:	88 18                	mov    %bl,(%eax)
  8009e4:	40                   	inc    %eax
  8009e5:	41                   	inc    %ecx
  8009e6:	eb 02                	jmp    8009ea <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8009ea:	4a                   	dec    %edx
  8009eb:	74 0a                	je     8009f7 <strlcpy+0x2b>
  8009ed:	8a 19                	mov    (%ecx),%bl
  8009ef:	84 db                	test   %bl,%bl
  8009f1:	75 ef                	jne    8009e2 <strlcpy+0x16>
  8009f3:	89 c2                	mov    %eax,%edx
  8009f5:	eb 02                	jmp    8009f9 <strlcpy+0x2d>
  8009f7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8009f9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8009fc:	29 f0                	sub    %esi,%eax
}
  8009fe:	5b                   	pop    %ebx
  8009ff:	5e                   	pop    %esi
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a08:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a0b:	eb 02                	jmp    800a0f <strcmp+0xd>
		p++, q++;
  800a0d:	41                   	inc    %ecx
  800a0e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a0f:	8a 01                	mov    (%ecx),%al
  800a11:	84 c0                	test   %al,%al
  800a13:	74 04                	je     800a19 <strcmp+0x17>
  800a15:	3a 02                	cmp    (%edx),%al
  800a17:	74 f4                	je     800a0d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a19:	0f b6 c0             	movzbl %al,%eax
  800a1c:	0f b6 12             	movzbl (%edx),%edx
  800a1f:	29 d0                	sub    %edx,%eax
}
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	53                   	push   %ebx
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a30:	eb 03                	jmp    800a35 <strncmp+0x12>
		n--, p++, q++;
  800a32:	4a                   	dec    %edx
  800a33:	40                   	inc    %eax
  800a34:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a35:	85 d2                	test   %edx,%edx
  800a37:	74 14                	je     800a4d <strncmp+0x2a>
  800a39:	8a 18                	mov    (%eax),%bl
  800a3b:	84 db                	test   %bl,%bl
  800a3d:	74 04                	je     800a43 <strncmp+0x20>
  800a3f:	3a 19                	cmp    (%ecx),%bl
  800a41:	74 ef                	je     800a32 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a43:	0f b6 00             	movzbl (%eax),%eax
  800a46:	0f b6 11             	movzbl (%ecx),%edx
  800a49:	29 d0                	sub    %edx,%eax
  800a4b:	eb 05                	jmp    800a52 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a4d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a52:	5b                   	pop    %ebx
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a5e:	eb 05                	jmp    800a65 <strchr+0x10>
		if (*s == c)
  800a60:	38 ca                	cmp    %cl,%dl
  800a62:	74 0c                	je     800a70 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a64:	40                   	inc    %eax
  800a65:	8a 10                	mov    (%eax),%dl
  800a67:	84 d2                	test   %dl,%dl
  800a69:	75 f5                	jne    800a60 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a6b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a70:	5d                   	pop    %ebp
  800a71:	c3                   	ret    

00800a72 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a72:	55                   	push   %ebp
  800a73:	89 e5                	mov    %esp,%ebp
  800a75:	8b 45 08             	mov    0x8(%ebp),%eax
  800a78:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a7b:	eb 05                	jmp    800a82 <strfind+0x10>
		if (*s == c)
  800a7d:	38 ca                	cmp    %cl,%dl
  800a7f:	74 07                	je     800a88 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a81:	40                   	inc    %eax
  800a82:	8a 10                	mov    (%eax),%dl
  800a84:	84 d2                	test   %dl,%dl
  800a86:	75 f5                	jne    800a7d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	57                   	push   %edi
  800a8e:	56                   	push   %esi
  800a8f:	53                   	push   %ebx
  800a90:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a96:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a99:	85 c9                	test   %ecx,%ecx
  800a9b:	74 30                	je     800acd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a9d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa3:	75 25                	jne    800aca <memset+0x40>
  800aa5:	f6 c1 03             	test   $0x3,%cl
  800aa8:	75 20                	jne    800aca <memset+0x40>
		c &= 0xFF;
  800aaa:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aad:	89 d3                	mov    %edx,%ebx
  800aaf:	c1 e3 08             	shl    $0x8,%ebx
  800ab2:	89 d6                	mov    %edx,%esi
  800ab4:	c1 e6 18             	shl    $0x18,%esi
  800ab7:	89 d0                	mov    %edx,%eax
  800ab9:	c1 e0 10             	shl    $0x10,%eax
  800abc:	09 f0                	or     %esi,%eax
  800abe:	09 d0                	or     %edx,%eax
  800ac0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ac2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac5:	fc                   	cld    
  800ac6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac8:	eb 03                	jmp    800acd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aca:	fc                   	cld    
  800acb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800acd:	89 f8                	mov    %edi,%eax
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5f                   	pop    %edi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae2:	39 c6                	cmp    %eax,%esi
  800ae4:	73 34                	jae    800b1a <memmove+0x46>
  800ae6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae9:	39 d0                	cmp    %edx,%eax
  800aeb:	73 2d                	jae    800b1a <memmove+0x46>
		s += n;
		d += n;
  800aed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af0:	f6 c2 03             	test   $0x3,%dl
  800af3:	75 1b                	jne    800b10 <memmove+0x3c>
  800af5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800afb:	75 13                	jne    800b10 <memmove+0x3c>
  800afd:	f6 c1 03             	test   $0x3,%cl
  800b00:	75 0e                	jne    800b10 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b02:	83 ef 04             	sub    $0x4,%edi
  800b05:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b08:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b0b:	fd                   	std    
  800b0c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0e:	eb 07                	jmp    800b17 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b10:	4f                   	dec    %edi
  800b11:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b14:	fd                   	std    
  800b15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b17:	fc                   	cld    
  800b18:	eb 20                	jmp    800b3a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b20:	75 13                	jne    800b35 <memmove+0x61>
  800b22:	a8 03                	test   $0x3,%al
  800b24:	75 0f                	jne    800b35 <memmove+0x61>
  800b26:	f6 c1 03             	test   $0x3,%cl
  800b29:	75 0a                	jne    800b35 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b2b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b2e:	89 c7                	mov    %eax,%edi
  800b30:	fc                   	cld    
  800b31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b33:	eb 05                	jmp    800b3a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b35:	89 c7                	mov    %eax,%edi
  800b37:	fc                   	cld    
  800b38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b44:	8b 45 10             	mov    0x10(%ebp),%eax
  800b47:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	89 04 24             	mov    %eax,(%esp)
  800b58:	e8 77 ff ff ff       	call   800ad4 <memmove>
}
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	57                   	push   %edi
  800b63:	56                   	push   %esi
  800b64:	53                   	push   %ebx
  800b65:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b68:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b73:	eb 16                	jmp    800b8b <memcmp+0x2c>
		if (*s1 != *s2)
  800b75:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b78:	42                   	inc    %edx
  800b79:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b7d:	38 c8                	cmp    %cl,%al
  800b7f:	74 0a                	je     800b8b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800b81:	0f b6 c0             	movzbl %al,%eax
  800b84:	0f b6 c9             	movzbl %cl,%ecx
  800b87:	29 c8                	sub    %ecx,%eax
  800b89:	eb 09                	jmp    800b94 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8b:	39 da                	cmp    %ebx,%edx
  800b8d:	75 e6                	jne    800b75 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ba2:	89 c2                	mov    %eax,%edx
  800ba4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ba7:	eb 05                	jmp    800bae <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba9:	38 08                	cmp    %cl,(%eax)
  800bab:	74 05                	je     800bb2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bad:	40                   	inc    %eax
  800bae:	39 d0                	cmp    %edx,%eax
  800bb0:	72 f7                	jb     800ba9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc0:	eb 01                	jmp    800bc3 <strtol+0xf>
		s++;
  800bc2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc3:	8a 02                	mov    (%edx),%al
  800bc5:	3c 20                	cmp    $0x20,%al
  800bc7:	74 f9                	je     800bc2 <strtol+0xe>
  800bc9:	3c 09                	cmp    $0x9,%al
  800bcb:	74 f5                	je     800bc2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bcd:	3c 2b                	cmp    $0x2b,%al
  800bcf:	75 08                	jne    800bd9 <strtol+0x25>
		s++;
  800bd1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bd2:	bf 00 00 00 00       	mov    $0x0,%edi
  800bd7:	eb 13                	jmp    800bec <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bd9:	3c 2d                	cmp    $0x2d,%al
  800bdb:	75 0a                	jne    800be7 <strtol+0x33>
		s++, neg = 1;
  800bdd:	8d 52 01             	lea    0x1(%edx),%edx
  800be0:	bf 01 00 00 00       	mov    $0x1,%edi
  800be5:	eb 05                	jmp    800bec <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800be7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bec:	85 db                	test   %ebx,%ebx
  800bee:	74 05                	je     800bf5 <strtol+0x41>
  800bf0:	83 fb 10             	cmp    $0x10,%ebx
  800bf3:	75 28                	jne    800c1d <strtol+0x69>
  800bf5:	8a 02                	mov    (%edx),%al
  800bf7:	3c 30                	cmp    $0x30,%al
  800bf9:	75 10                	jne    800c0b <strtol+0x57>
  800bfb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bff:	75 0a                	jne    800c0b <strtol+0x57>
		s += 2, base = 16;
  800c01:	83 c2 02             	add    $0x2,%edx
  800c04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c09:	eb 12                	jmp    800c1d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c0b:	85 db                	test   %ebx,%ebx
  800c0d:	75 0e                	jne    800c1d <strtol+0x69>
  800c0f:	3c 30                	cmp    $0x30,%al
  800c11:	75 05                	jne    800c18 <strtol+0x64>
		s++, base = 8;
  800c13:	42                   	inc    %edx
  800c14:	b3 08                	mov    $0x8,%bl
  800c16:	eb 05                	jmp    800c1d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c18:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c22:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c24:	8a 0a                	mov    (%edx),%cl
  800c26:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c29:	80 fb 09             	cmp    $0x9,%bl
  800c2c:	77 08                	ja     800c36 <strtol+0x82>
			dig = *s - '0';
  800c2e:	0f be c9             	movsbl %cl,%ecx
  800c31:	83 e9 30             	sub    $0x30,%ecx
  800c34:	eb 1e                	jmp    800c54 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c36:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c39:	80 fb 19             	cmp    $0x19,%bl
  800c3c:	77 08                	ja     800c46 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c3e:	0f be c9             	movsbl %cl,%ecx
  800c41:	83 e9 57             	sub    $0x57,%ecx
  800c44:	eb 0e                	jmp    800c54 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c46:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c49:	80 fb 19             	cmp    $0x19,%bl
  800c4c:	77 12                	ja     800c60 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c4e:	0f be c9             	movsbl %cl,%ecx
  800c51:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c54:	39 f1                	cmp    %esi,%ecx
  800c56:	7d 0c                	jge    800c64 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c58:	42                   	inc    %edx
  800c59:	0f af c6             	imul   %esi,%eax
  800c5c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c5e:	eb c4                	jmp    800c24 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c60:	89 c1                	mov    %eax,%ecx
  800c62:	eb 02                	jmp    800c66 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c64:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c66:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c6a:	74 05                	je     800c71 <strtol+0xbd>
		*endptr = (char *) s;
  800c6c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c6f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c71:	85 ff                	test   %edi,%edi
  800c73:	74 04                	je     800c79 <strtol+0xc5>
  800c75:	89 c8                	mov    %ecx,%eax
  800c77:	f7 d8                	neg    %eax
}
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    
	...

00800c80 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c80:	55                   	push   %ebp
  800c81:	89 e5                	mov    %esp,%ebp
  800c83:	57                   	push   %edi
  800c84:	56                   	push   %esi
  800c85:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c86:	b8 00 00 00 00       	mov    $0x0,%eax
  800c8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c91:	89 c3                	mov    %eax,%ebx
  800c93:	89 c7                	mov    %eax,%edi
  800c95:	89 c6                	mov    %eax,%esi
  800c97:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <sys_cgetc>:

int
sys_cgetc(void)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cae:	89 d1                	mov    %edx,%ecx
  800cb0:	89 d3                	mov    %edx,%ebx
  800cb2:	89 d7                	mov    %edx,%edi
  800cb4:	89 d6                	mov    %edx,%esi
  800cb6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ccb:	b8 03 00 00 00       	mov    $0x3,%eax
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	89 cb                	mov    %ecx,%ebx
  800cd5:	89 cf                	mov    %ecx,%edi
  800cd7:	89 ce                	mov    %ecx,%esi
  800cd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 28                	jle    800d07 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800cea:	00 
  800ceb:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  800cf2:	00 
  800cf3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cfa:	00 
  800cfb:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800d02:	e8 b1 f5 ff ff       	call   8002b8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d07:	83 c4 2c             	add    $0x2c,%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	ba 00 00 00 00       	mov    $0x0,%edx
  800d1a:	b8 02 00 00 00       	mov    $0x2,%eax
  800d1f:	89 d1                	mov    %edx,%ecx
  800d21:	89 d3                	mov    %edx,%ebx
  800d23:	89 d7                	mov    %edx,%edi
  800d25:	89 d6                	mov    %edx,%esi
  800d27:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <sys_yield>:

void
sys_yield(void)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d34:	ba 00 00 00 00       	mov    $0x0,%edx
  800d39:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d3e:	89 d1                	mov    %edx,%ecx
  800d40:	89 d3                	mov    %edx,%ebx
  800d42:	89 d7                	mov    %edx,%edi
  800d44:	89 d6                	mov    %edx,%esi
  800d46:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d48:	5b                   	pop    %ebx
  800d49:	5e                   	pop    %esi
  800d4a:	5f                   	pop    %edi
  800d4b:	5d                   	pop    %ebp
  800d4c:	c3                   	ret    

00800d4d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
  800d53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d56:	be 00 00 00 00       	mov    $0x0,%esi
  800d5b:	b8 04 00 00 00       	mov    $0x4,%eax
  800d60:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	89 f7                	mov    %esi,%edi
  800d6b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	7e 28                	jle    800d99 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d71:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d75:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d7c:	00 
  800d7d:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  800d84:	00 
  800d85:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8c:	00 
  800d8d:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800d94:	e8 1f f5 ff ff       	call   8002b8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d99:	83 c4 2c             	add    $0x2c,%esp
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daa:	b8 05 00 00 00       	mov    $0x5,%eax
  800daf:	8b 75 18             	mov    0x18(%ebp),%esi
  800db2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	7e 28                	jle    800dec <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800dcf:	00 
  800dd0:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ddf:	00 
  800de0:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800de7:	e8 cc f4 ff ff       	call   8002b8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dec:	83 c4 2c             	add    $0x2c,%esp
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	57                   	push   %edi
  800df8:	56                   	push   %esi
  800df9:	53                   	push   %ebx
  800dfa:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e02:	b8 06 00 00 00       	mov    $0x6,%eax
  800e07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0d:	89 df                	mov    %ebx,%edi
  800e0f:	89 de                	mov    %ebx,%esi
  800e11:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e13:	85 c0                	test   %eax,%eax
  800e15:	7e 28                	jle    800e3f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e17:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e22:	00 
  800e23:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  800e2a:	00 
  800e2b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e32:	00 
  800e33:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800e3a:	e8 79 f4 ff ff       	call   8002b8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e3f:	83 c4 2c             	add    $0x2c,%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e55:	b8 08 00 00 00       	mov    $0x8,%eax
  800e5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	89 df                	mov    %ebx,%edi
  800e62:	89 de                	mov    %ebx,%esi
  800e64:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e66:	85 c0                	test   %eax,%eax
  800e68:	7e 28                	jle    800e92 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e6e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e75:	00 
  800e76:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  800e7d:	00 
  800e7e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e85:	00 
  800e86:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800e8d:	e8 26 f4 ff ff       	call   8002b8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e92:	83 c4 2c             	add    $0x2c,%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	57                   	push   %edi
  800e9e:	56                   	push   %esi
  800e9f:	53                   	push   %ebx
  800ea0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea8:	b8 09 00 00 00       	mov    $0x9,%eax
  800ead:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb3:	89 df                	mov    %ebx,%edi
  800eb5:	89 de                	mov    %ebx,%esi
  800eb7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	7e 28                	jle    800ee5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ec1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ec8:	00 
  800ec9:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  800ed0:	00 
  800ed1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed8:	00 
  800ed9:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800ee0:	e8 d3 f3 ff ff       	call   8002b8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ee5:	83 c4 2c             	add    $0x2c,%esp
  800ee8:	5b                   	pop    %ebx
  800ee9:	5e                   	pop    %esi
  800eea:	5f                   	pop    %edi
  800eeb:	5d                   	pop    %ebp
  800eec:	c3                   	ret    

00800eed <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	57                   	push   %edi
  800ef1:	56                   	push   %esi
  800ef2:	53                   	push   %ebx
  800ef3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	89 df                	mov    %ebx,%edi
  800f08:	89 de                	mov    %ebx,%esi
  800f0a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f0c:	85 c0                	test   %eax,%eax
  800f0e:	7e 28                	jle    800f38 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f10:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f14:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  800f23:	00 
  800f24:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f2b:	00 
  800f2c:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800f33:	e8 80 f3 ff ff       	call   8002b8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f38:	83 c4 2c             	add    $0x2c,%esp
  800f3b:	5b                   	pop    %ebx
  800f3c:	5e                   	pop    %esi
  800f3d:	5f                   	pop    %edi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f46:	be 00 00 00 00       	mov    $0x0,%esi
  800f4b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f50:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f53:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f59:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f5e:	5b                   	pop    %ebx
  800f5f:	5e                   	pop    %esi
  800f60:	5f                   	pop    %edi
  800f61:	5d                   	pop    %ebp
  800f62:	c3                   	ret    

00800f63 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f63:	55                   	push   %ebp
  800f64:	89 e5                	mov    %esp,%ebp
  800f66:	57                   	push   %edi
  800f67:	56                   	push   %esi
  800f68:	53                   	push   %ebx
  800f69:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f71:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f76:	8b 55 08             	mov    0x8(%ebp),%edx
  800f79:	89 cb                	mov    %ecx,%ebx
  800f7b:	89 cf                	mov    %ecx,%edi
  800f7d:	89 ce                	mov    %ecx,%esi
  800f7f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f81:	85 c0                	test   %eax,%eax
  800f83:	7e 28                	jle    800fad <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f85:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f89:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800f90:	00 
  800f91:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
  800f98:	00 
  800f99:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa0:	00 
  800fa1:	c7 04 24 80 2a 80 00 	movl   $0x802a80,(%esp)
  800fa8:	e8 0b f3 ff ff       	call   8002b8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fad:	83 c4 2c             	add    $0x2c,%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    

00800fb5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	57                   	push   %edi
  800fb9:	56                   	push   %esi
  800fba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc0:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fc5:	89 d1                	mov    %edx,%ecx
  800fc7:	89 d3                	mov    %edx,%ebx
  800fc9:	89 d7                	mov    %edx,%edi
  800fcb:	89 d6                	mov    %edx,%esi
  800fcd:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fcf:	5b                   	pop    %ebx
  800fd0:	5e                   	pop    %esi
  800fd1:	5f                   	pop    %edi
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    

00800fd4 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	57                   	push   %edi
  800fd8:	56                   	push   %esi
  800fd9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdf:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fe4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fea:	89 df                	mov    %ebx,%edi
  800fec:	89 de                	mov    %ebx,%esi
  800fee:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800ff0:	5b                   	pop    %ebx
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	57                   	push   %edi
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801000:	b8 10 00 00 00       	mov    $0x10,%eax
  801005:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801008:	8b 55 08             	mov    0x8(%ebp),%edx
  80100b:	89 df                	mov    %ebx,%edi
  80100d:	89 de                	mov    %ebx,%esi
  80100f:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    
	...

00801018 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80101b:	8b 45 08             	mov    0x8(%ebp),%eax
  80101e:	05 00 00 00 30       	add    $0x30000000,%eax
  801023:	c1 e8 0c             	shr    $0xc,%eax
}
  801026:	5d                   	pop    %ebp
  801027:	c3                   	ret    

00801028 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80102e:	8b 45 08             	mov    0x8(%ebp),%eax
  801031:	89 04 24             	mov    %eax,(%esp)
  801034:	e8 df ff ff ff       	call   801018 <fd2num>
  801039:	c1 e0 0c             	shl    $0xc,%eax
  80103c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801041:	c9                   	leave  
  801042:	c3                   	ret    

00801043 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	53                   	push   %ebx
  801047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80104a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80104f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801051:	89 c2                	mov    %eax,%edx
  801053:	c1 ea 16             	shr    $0x16,%edx
  801056:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80105d:	f6 c2 01             	test   $0x1,%dl
  801060:	74 11                	je     801073 <fd_alloc+0x30>
  801062:	89 c2                	mov    %eax,%edx
  801064:	c1 ea 0c             	shr    $0xc,%edx
  801067:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80106e:	f6 c2 01             	test   $0x1,%dl
  801071:	75 09                	jne    80107c <fd_alloc+0x39>
			*fd_store = fd;
  801073:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801075:	b8 00 00 00 00       	mov    $0x0,%eax
  80107a:	eb 17                	jmp    801093 <fd_alloc+0x50>
  80107c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801081:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801086:	75 c7                	jne    80104f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801088:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80108e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801093:	5b                   	pop    %ebx
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80109c:	83 f8 1f             	cmp    $0x1f,%eax
  80109f:	77 36                	ja     8010d7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010a1:	c1 e0 0c             	shl    $0xc,%eax
  8010a4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010a9:	89 c2                	mov    %eax,%edx
  8010ab:	c1 ea 16             	shr    $0x16,%edx
  8010ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b5:	f6 c2 01             	test   $0x1,%dl
  8010b8:	74 24                	je     8010de <fd_lookup+0x48>
  8010ba:	89 c2                	mov    %eax,%edx
  8010bc:	c1 ea 0c             	shr    $0xc,%edx
  8010bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c6:	f6 c2 01             	test   $0x1,%dl
  8010c9:	74 1a                	je     8010e5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ce:	89 02                	mov    %eax,(%edx)
	return 0;
  8010d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d5:	eb 13                	jmp    8010ea <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010dc:	eb 0c                	jmp    8010ea <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e3:	eb 05                	jmp    8010ea <fd_lookup+0x54>
  8010e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	53                   	push   %ebx
  8010f0:	83 ec 14             	sub    $0x14,%esp
  8010f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8010f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8010fe:	eb 0e                	jmp    80110e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801100:	39 08                	cmp    %ecx,(%eax)
  801102:	75 09                	jne    80110d <dev_lookup+0x21>
			*dev = devtab[i];
  801104:	89 03                	mov    %eax,(%ebx)
			return 0;
  801106:	b8 00 00 00 00       	mov    $0x0,%eax
  80110b:	eb 33                	jmp    801140 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80110d:	42                   	inc    %edx
  80110e:	8b 04 95 10 2b 80 00 	mov    0x802b10(,%edx,4),%eax
  801115:	85 c0                	test   %eax,%eax
  801117:	75 e7                	jne    801100 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801119:	a1 08 40 80 00       	mov    0x804008,%eax
  80111e:	8b 40 48             	mov    0x48(%eax),%eax
  801121:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801125:	89 44 24 04          	mov    %eax,0x4(%esp)
  801129:	c7 04 24 90 2a 80 00 	movl   $0x802a90,(%esp)
  801130:	e8 7b f2 ff ff       	call   8003b0 <cprintf>
	*dev = 0;
  801135:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80113b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801140:	83 c4 14             	add    $0x14,%esp
  801143:	5b                   	pop    %ebx
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    

00801146 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	56                   	push   %esi
  80114a:	53                   	push   %ebx
  80114b:	83 ec 30             	sub    $0x30,%esp
  80114e:	8b 75 08             	mov    0x8(%ebp),%esi
  801151:	8a 45 0c             	mov    0xc(%ebp),%al
  801154:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801157:	89 34 24             	mov    %esi,(%esp)
  80115a:	e8 b9 fe ff ff       	call   801018 <fd2num>
  80115f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801162:	89 54 24 04          	mov    %edx,0x4(%esp)
  801166:	89 04 24             	mov    %eax,(%esp)
  801169:	e8 28 ff ff ff       	call   801096 <fd_lookup>
  80116e:	89 c3                	mov    %eax,%ebx
  801170:	85 c0                	test   %eax,%eax
  801172:	78 05                	js     801179 <fd_close+0x33>
	    || fd != fd2)
  801174:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801177:	74 0d                	je     801186 <fd_close+0x40>
		return (must_exist ? r : 0);
  801179:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80117d:	75 46                	jne    8011c5 <fd_close+0x7f>
  80117f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801184:	eb 3f                	jmp    8011c5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801186:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801189:	89 44 24 04          	mov    %eax,0x4(%esp)
  80118d:	8b 06                	mov    (%esi),%eax
  80118f:	89 04 24             	mov    %eax,(%esp)
  801192:	e8 55 ff ff ff       	call   8010ec <dev_lookup>
  801197:	89 c3                	mov    %eax,%ebx
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 18                	js     8011b5 <fd_close+0x6f>
		if (dev->dev_close)
  80119d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a0:	8b 40 10             	mov    0x10(%eax),%eax
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	74 09                	je     8011b0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011a7:	89 34 24             	mov    %esi,(%esp)
  8011aa:	ff d0                	call   *%eax
  8011ac:	89 c3                	mov    %eax,%ebx
  8011ae:	eb 05                	jmp    8011b5 <fd_close+0x6f>
		else
			r = 0;
  8011b0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011c0:	e8 2f fc ff ff       	call   800df4 <sys_page_unmap>
	return r;
}
  8011c5:	89 d8                	mov    %ebx,%eax
  8011c7:	83 c4 30             	add    $0x30,%esp
  8011ca:	5b                   	pop    %ebx
  8011cb:	5e                   	pop    %esi
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011db:	8b 45 08             	mov    0x8(%ebp),%eax
  8011de:	89 04 24             	mov    %eax,(%esp)
  8011e1:	e8 b0 fe ff ff       	call   801096 <fd_lookup>
  8011e6:	85 c0                	test   %eax,%eax
  8011e8:	78 13                	js     8011fd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8011ea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011f1:	00 
  8011f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f5:	89 04 24             	mov    %eax,(%esp)
  8011f8:	e8 49 ff ff ff       	call   801146 <fd_close>
}
  8011fd:	c9                   	leave  
  8011fe:	c3                   	ret    

008011ff <close_all>:

void
close_all(void)
{
  8011ff:	55                   	push   %ebp
  801200:	89 e5                	mov    %esp,%ebp
  801202:	53                   	push   %ebx
  801203:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801206:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80120b:	89 1c 24             	mov    %ebx,(%esp)
  80120e:	e8 bb ff ff ff       	call   8011ce <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801213:	43                   	inc    %ebx
  801214:	83 fb 20             	cmp    $0x20,%ebx
  801217:	75 f2                	jne    80120b <close_all+0xc>
		close(i);
}
  801219:	83 c4 14             	add    $0x14,%esp
  80121c:	5b                   	pop    %ebx
  80121d:	5d                   	pop    %ebp
  80121e:	c3                   	ret    

0080121f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80121f:	55                   	push   %ebp
  801220:	89 e5                	mov    %esp,%ebp
  801222:	57                   	push   %edi
  801223:	56                   	push   %esi
  801224:	53                   	push   %ebx
  801225:	83 ec 4c             	sub    $0x4c,%esp
  801228:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80122b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80122e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801232:	8b 45 08             	mov    0x8(%ebp),%eax
  801235:	89 04 24             	mov    %eax,(%esp)
  801238:	e8 59 fe ff ff       	call   801096 <fd_lookup>
  80123d:	89 c3                	mov    %eax,%ebx
  80123f:	85 c0                	test   %eax,%eax
  801241:	0f 88 e3 00 00 00    	js     80132a <dup+0x10b>
		return r;
	close(newfdnum);
  801247:	89 3c 24             	mov    %edi,(%esp)
  80124a:	e8 7f ff ff ff       	call   8011ce <close>

	newfd = INDEX2FD(newfdnum);
  80124f:	89 fe                	mov    %edi,%esi
  801251:	c1 e6 0c             	shl    $0xc,%esi
  801254:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80125a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80125d:	89 04 24             	mov    %eax,(%esp)
  801260:	e8 c3 fd ff ff       	call   801028 <fd2data>
  801265:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801267:	89 34 24             	mov    %esi,(%esp)
  80126a:	e8 b9 fd ff ff       	call   801028 <fd2data>
  80126f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801272:	89 d8                	mov    %ebx,%eax
  801274:	c1 e8 16             	shr    $0x16,%eax
  801277:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80127e:	a8 01                	test   $0x1,%al
  801280:	74 46                	je     8012c8 <dup+0xa9>
  801282:	89 d8                	mov    %ebx,%eax
  801284:	c1 e8 0c             	shr    $0xc,%eax
  801287:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80128e:	f6 c2 01             	test   $0x1,%dl
  801291:	74 35                	je     8012c8 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801293:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80129a:	25 07 0e 00 00       	and    $0xe07,%eax
  80129f:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012b1:	00 
  8012b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012bd:	e8 df fa ff ff       	call   800da1 <sys_page_map>
  8012c2:	89 c3                	mov    %eax,%ebx
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	78 3b                	js     801303 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012cb:	89 c2                	mov    %eax,%edx
  8012cd:	c1 ea 0c             	shr    $0xc,%edx
  8012d0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d7:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8012dd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012e1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012ec:	00 
  8012ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012f8:	e8 a4 fa ff ff       	call   800da1 <sys_page_map>
  8012fd:	89 c3                	mov    %eax,%ebx
  8012ff:	85 c0                	test   %eax,%eax
  801301:	79 25                	jns    801328 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801303:	89 74 24 04          	mov    %esi,0x4(%esp)
  801307:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80130e:	e8 e1 fa ff ff       	call   800df4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801313:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801316:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801321:	e8 ce fa ff ff       	call   800df4 <sys_page_unmap>
	return r;
  801326:	eb 02                	jmp    80132a <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801328:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80132a:	89 d8                	mov    %ebx,%eax
  80132c:	83 c4 4c             	add    $0x4c,%esp
  80132f:	5b                   	pop    %ebx
  801330:	5e                   	pop    %esi
  801331:	5f                   	pop    %edi
  801332:	5d                   	pop    %ebp
  801333:	c3                   	ret    

00801334 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801334:	55                   	push   %ebp
  801335:	89 e5                	mov    %esp,%ebp
  801337:	53                   	push   %ebx
  801338:	83 ec 24             	sub    $0x24,%esp
  80133b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801341:	89 44 24 04          	mov    %eax,0x4(%esp)
  801345:	89 1c 24             	mov    %ebx,(%esp)
  801348:	e8 49 fd ff ff       	call   801096 <fd_lookup>
  80134d:	85 c0                	test   %eax,%eax
  80134f:	78 6d                	js     8013be <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801351:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801354:	89 44 24 04          	mov    %eax,0x4(%esp)
  801358:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135b:	8b 00                	mov    (%eax),%eax
  80135d:	89 04 24             	mov    %eax,(%esp)
  801360:	e8 87 fd ff ff       	call   8010ec <dev_lookup>
  801365:	85 c0                	test   %eax,%eax
  801367:	78 55                	js     8013be <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801369:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136c:	8b 50 08             	mov    0x8(%eax),%edx
  80136f:	83 e2 03             	and    $0x3,%edx
  801372:	83 fa 01             	cmp    $0x1,%edx
  801375:	75 23                	jne    80139a <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801377:	a1 08 40 80 00       	mov    0x804008,%eax
  80137c:	8b 40 48             	mov    0x48(%eax),%eax
  80137f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801383:	89 44 24 04          	mov    %eax,0x4(%esp)
  801387:	c7 04 24 d4 2a 80 00 	movl   $0x802ad4,(%esp)
  80138e:	e8 1d f0 ff ff       	call   8003b0 <cprintf>
		return -E_INVAL;
  801393:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801398:	eb 24                	jmp    8013be <read+0x8a>
	}
	if (!dev->dev_read)
  80139a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80139d:	8b 52 08             	mov    0x8(%edx),%edx
  8013a0:	85 d2                	test   %edx,%edx
  8013a2:	74 15                	je     8013b9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8013a7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ae:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8013b2:	89 04 24             	mov    %eax,(%esp)
  8013b5:	ff d2                	call   *%edx
  8013b7:	eb 05                	jmp    8013be <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013b9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8013be:	83 c4 24             	add    $0x24,%esp
  8013c1:	5b                   	pop    %ebx
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    

008013c4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	57                   	push   %edi
  8013c8:	56                   	push   %esi
  8013c9:	53                   	push   %ebx
  8013ca:	83 ec 1c             	sub    $0x1c,%esp
  8013cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d8:	eb 23                	jmp    8013fd <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013da:	89 f0                	mov    %esi,%eax
  8013dc:	29 d8                	sub    %ebx,%eax
  8013de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e5:	01 d8                	add    %ebx,%eax
  8013e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013eb:	89 3c 24             	mov    %edi,(%esp)
  8013ee:	e8 41 ff ff ff       	call   801334 <read>
		if (m < 0)
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	78 10                	js     801407 <readn+0x43>
			return m;
		if (m == 0)
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	74 0a                	je     801405 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013fb:	01 c3                	add    %eax,%ebx
  8013fd:	39 f3                	cmp    %esi,%ebx
  8013ff:	72 d9                	jb     8013da <readn+0x16>
  801401:	89 d8                	mov    %ebx,%eax
  801403:	eb 02                	jmp    801407 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801405:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801407:	83 c4 1c             	add    $0x1c,%esp
  80140a:	5b                   	pop    %ebx
  80140b:	5e                   	pop    %esi
  80140c:	5f                   	pop    %edi
  80140d:	5d                   	pop    %ebp
  80140e:	c3                   	ret    

0080140f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	53                   	push   %ebx
  801413:	83 ec 24             	sub    $0x24,%esp
  801416:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801419:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801420:	89 1c 24             	mov    %ebx,(%esp)
  801423:	e8 6e fc ff ff       	call   801096 <fd_lookup>
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 68                	js     801494 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801433:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801436:	8b 00                	mov    (%eax),%eax
  801438:	89 04 24             	mov    %eax,(%esp)
  80143b:	e8 ac fc ff ff       	call   8010ec <dev_lookup>
  801440:	85 c0                	test   %eax,%eax
  801442:	78 50                	js     801494 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801444:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801447:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80144b:	75 23                	jne    801470 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80144d:	a1 08 40 80 00       	mov    0x804008,%eax
  801452:	8b 40 48             	mov    0x48(%eax),%eax
  801455:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801459:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145d:	c7 04 24 f0 2a 80 00 	movl   $0x802af0,(%esp)
  801464:	e8 47 ef ff ff       	call   8003b0 <cprintf>
		return -E_INVAL;
  801469:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146e:	eb 24                	jmp    801494 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801470:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801473:	8b 52 0c             	mov    0xc(%edx),%edx
  801476:	85 d2                	test   %edx,%edx
  801478:	74 15                	je     80148f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80147a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80147d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801481:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801484:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801488:	89 04 24             	mov    %eax,(%esp)
  80148b:	ff d2                	call   *%edx
  80148d:	eb 05                	jmp    801494 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80148f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801494:	83 c4 24             	add    $0x24,%esp
  801497:	5b                   	pop    %ebx
  801498:	5d                   	pop    %ebp
  801499:	c3                   	ret    

0080149a <seek>:

int
seek(int fdnum, off_t offset)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014aa:	89 04 24             	mov    %eax,(%esp)
  8014ad:	e8 e4 fb ff ff       	call   801096 <fd_lookup>
  8014b2:	85 c0                	test   %eax,%eax
  8014b4:	78 0e                	js     8014c4 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8014b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c4:	c9                   	leave  
  8014c5:	c3                   	ret    

008014c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	53                   	push   %ebx
  8014ca:	83 ec 24             	sub    $0x24,%esp
  8014cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d7:	89 1c 24             	mov    %ebx,(%esp)
  8014da:	e8 b7 fb ff ff       	call   801096 <fd_lookup>
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	78 61                	js     801544 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ed:	8b 00                	mov    (%eax),%eax
  8014ef:	89 04 24             	mov    %eax,(%esp)
  8014f2:	e8 f5 fb ff ff       	call   8010ec <dev_lookup>
  8014f7:	85 c0                	test   %eax,%eax
  8014f9:	78 49                	js     801544 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801502:	75 23                	jne    801527 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801504:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801509:	8b 40 48             	mov    0x48(%eax),%eax
  80150c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801510:	89 44 24 04          	mov    %eax,0x4(%esp)
  801514:	c7 04 24 b0 2a 80 00 	movl   $0x802ab0,(%esp)
  80151b:	e8 90 ee ff ff       	call   8003b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801520:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801525:	eb 1d                	jmp    801544 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801527:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80152a:	8b 52 18             	mov    0x18(%edx),%edx
  80152d:	85 d2                	test   %edx,%edx
  80152f:	74 0e                	je     80153f <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801531:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801534:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801538:	89 04 24             	mov    %eax,(%esp)
  80153b:	ff d2                	call   *%edx
  80153d:	eb 05                	jmp    801544 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80153f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801544:	83 c4 24             	add    $0x24,%esp
  801547:	5b                   	pop    %ebx
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    

0080154a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	53                   	push   %ebx
  80154e:	83 ec 24             	sub    $0x24,%esp
  801551:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801554:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801557:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155b:	8b 45 08             	mov    0x8(%ebp),%eax
  80155e:	89 04 24             	mov    %eax,(%esp)
  801561:	e8 30 fb ff ff       	call   801096 <fd_lookup>
  801566:	85 c0                	test   %eax,%eax
  801568:	78 52                	js     8015bc <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801571:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801574:	8b 00                	mov    (%eax),%eax
  801576:	89 04 24             	mov    %eax,(%esp)
  801579:	e8 6e fb ff ff       	call   8010ec <dev_lookup>
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 3a                	js     8015bc <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801582:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801585:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801589:	74 2c                	je     8015b7 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80158b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80158e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801595:	00 00 00 
	stat->st_isdir = 0;
  801598:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80159f:	00 00 00 
	stat->st_dev = dev;
  8015a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015af:	89 14 24             	mov    %edx,(%esp)
  8015b2:	ff 50 14             	call   *0x14(%eax)
  8015b5:	eb 05                	jmp    8015bc <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015bc:	83 c4 24             	add    $0x24,%esp
  8015bf:	5b                   	pop    %ebx
  8015c0:	5d                   	pop    %ebp
  8015c1:	c3                   	ret    

008015c2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	56                   	push   %esi
  8015c6:	53                   	push   %ebx
  8015c7:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015d1:	00 
  8015d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d5:	89 04 24             	mov    %eax,(%esp)
  8015d8:	e8 2a 02 00 00       	call   801807 <open>
  8015dd:	89 c3                	mov    %eax,%ebx
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	78 1b                	js     8015fe <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8015e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ea:	89 1c 24             	mov    %ebx,(%esp)
  8015ed:	e8 58 ff ff ff       	call   80154a <fstat>
  8015f2:	89 c6                	mov    %eax,%esi
	close(fd);
  8015f4:	89 1c 24             	mov    %ebx,(%esp)
  8015f7:	e8 d2 fb ff ff       	call   8011ce <close>
	return r;
  8015fc:	89 f3                	mov    %esi,%ebx
}
  8015fe:	89 d8                	mov    %ebx,%eax
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	5b                   	pop    %ebx
  801604:	5e                   	pop    %esi
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    
	...

00801608 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	56                   	push   %esi
  80160c:	53                   	push   %ebx
  80160d:	83 ec 10             	sub    $0x10,%esp
  801610:	89 c3                	mov    %eax,%ebx
  801612:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801614:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80161b:	75 11                	jne    80162e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80161d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801624:	e8 86 0d 00 00       	call   8023af <ipc_find_env>
  801629:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80162e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801635:	00 
  801636:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80163d:	00 
  80163e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801642:	a1 00 40 80 00       	mov    0x804000,%eax
  801647:	89 04 24             	mov    %eax,(%esp)
  80164a:	e8 dd 0c 00 00       	call   80232c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80164f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801656:	00 
  801657:	89 74 24 04          	mov    %esi,0x4(%esp)
  80165b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801662:	e8 55 0c 00 00       	call   8022bc <ipc_recv>
}
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	5b                   	pop    %ebx
  80166b:	5e                   	pop    %esi
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    

0080166e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801674:	8b 45 08             	mov    0x8(%ebp),%eax
  801677:	8b 40 0c             	mov    0xc(%eax),%eax
  80167a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80167f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801682:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801687:	ba 00 00 00 00       	mov    $0x0,%edx
  80168c:	b8 02 00 00 00       	mov    $0x2,%eax
  801691:	e8 72 ff ff ff       	call   801608 <fsipc>
}
  801696:	c9                   	leave  
  801697:	c3                   	ret    

00801698 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80169e:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ae:	b8 06 00 00 00       	mov    $0x6,%eax
  8016b3:	e8 50 ff ff ff       	call   801608 <fsipc>
}
  8016b8:	c9                   	leave  
  8016b9:	c3                   	ret    

008016ba <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 14             	sub    $0x14,%esp
  8016c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ca:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d4:	b8 05 00 00 00       	mov    $0x5,%eax
  8016d9:	e8 2a ff ff ff       	call   801608 <fsipc>
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 2b                	js     80170d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016e2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016e9:	00 
  8016ea:	89 1c 24             	mov    %ebx,(%esp)
  8016ed:	e8 69 f2 ff ff       	call   80095b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016f2:	a1 80 50 80 00       	mov    0x805080,%eax
  8016f7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016fd:	a1 84 50 80 00       	mov    0x805084,%eax
  801702:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801708:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80170d:	83 c4 14             	add    $0x14,%esp
  801710:	5b                   	pop    %ebx
  801711:	5d                   	pop    %ebp
  801712:	c3                   	ret    

00801713 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	83 ec 18             	sub    $0x18,%esp
  801719:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80171c:	8b 55 08             	mov    0x8(%ebp),%edx
  80171f:	8b 52 0c             	mov    0xc(%edx),%edx
  801722:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801728:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  80172d:	89 c2                	mov    %eax,%edx
  80172f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801734:	76 05                	jbe    80173b <devfile_write+0x28>
  801736:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  80173b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80173f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801742:	89 44 24 04          	mov    %eax,0x4(%esp)
  801746:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80174d:	e8 ec f3 ff ff       	call   800b3e <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801752:	ba 00 00 00 00       	mov    $0x0,%edx
  801757:	b8 04 00 00 00       	mov    $0x4,%eax
  80175c:	e8 a7 fe ff ff       	call   801608 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801761:	c9                   	leave  
  801762:	c3                   	ret    

00801763 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	56                   	push   %esi
  801767:	53                   	push   %ebx
  801768:	83 ec 10             	sub    $0x10,%esp
  80176b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80176e:	8b 45 08             	mov    0x8(%ebp),%eax
  801771:	8b 40 0c             	mov    0xc(%eax),%eax
  801774:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801779:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80177f:	ba 00 00 00 00       	mov    $0x0,%edx
  801784:	b8 03 00 00 00       	mov    $0x3,%eax
  801789:	e8 7a fe ff ff       	call   801608 <fsipc>
  80178e:	89 c3                	mov    %eax,%ebx
  801790:	85 c0                	test   %eax,%eax
  801792:	78 6a                	js     8017fe <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801794:	39 c6                	cmp    %eax,%esi
  801796:	73 24                	jae    8017bc <devfile_read+0x59>
  801798:	c7 44 24 0c 24 2b 80 	movl   $0x802b24,0xc(%esp)
  80179f:	00 
  8017a0:	c7 44 24 08 2b 2b 80 	movl   $0x802b2b,0x8(%esp)
  8017a7:	00 
  8017a8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8017af:	00 
  8017b0:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  8017b7:	e8 fc ea ff ff       	call   8002b8 <_panic>
	assert(r <= PGSIZE);
  8017bc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017c1:	7e 24                	jle    8017e7 <devfile_read+0x84>
  8017c3:	c7 44 24 0c 4b 2b 80 	movl   $0x802b4b,0xc(%esp)
  8017ca:	00 
  8017cb:	c7 44 24 08 2b 2b 80 	movl   $0x802b2b,0x8(%esp)
  8017d2:	00 
  8017d3:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8017da:	00 
  8017db:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  8017e2:	e8 d1 ea ff ff       	call   8002b8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017eb:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017f2:	00 
  8017f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f6:	89 04 24             	mov    %eax,(%esp)
  8017f9:	e8 d6 f2 ff ff       	call   800ad4 <memmove>
	return r;
}
  8017fe:	89 d8                	mov    %ebx,%eax
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	5b                   	pop    %ebx
  801804:	5e                   	pop    %esi
  801805:	5d                   	pop    %ebp
  801806:	c3                   	ret    

00801807 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	56                   	push   %esi
  80180b:	53                   	push   %ebx
  80180c:	83 ec 20             	sub    $0x20,%esp
  80180f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801812:	89 34 24             	mov    %esi,(%esp)
  801815:	e8 0e f1 ff ff       	call   800928 <strlen>
  80181a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80181f:	7f 60                	jg     801881 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801821:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801824:	89 04 24             	mov    %eax,(%esp)
  801827:	e8 17 f8 ff ff       	call   801043 <fd_alloc>
  80182c:	89 c3                	mov    %eax,%ebx
  80182e:	85 c0                	test   %eax,%eax
  801830:	78 54                	js     801886 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801832:	89 74 24 04          	mov    %esi,0x4(%esp)
  801836:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80183d:	e8 19 f1 ff ff       	call   80095b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801842:	8b 45 0c             	mov    0xc(%ebp),%eax
  801845:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80184a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80184d:	b8 01 00 00 00       	mov    $0x1,%eax
  801852:	e8 b1 fd ff ff       	call   801608 <fsipc>
  801857:	89 c3                	mov    %eax,%ebx
  801859:	85 c0                	test   %eax,%eax
  80185b:	79 15                	jns    801872 <open+0x6b>
		fd_close(fd, 0);
  80185d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801864:	00 
  801865:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801868:	89 04 24             	mov    %eax,(%esp)
  80186b:	e8 d6 f8 ff ff       	call   801146 <fd_close>
		return r;
  801870:	eb 14                	jmp    801886 <open+0x7f>
	}

	return fd2num(fd);
  801872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801875:	89 04 24             	mov    %eax,(%esp)
  801878:	e8 9b f7 ff ff       	call   801018 <fd2num>
  80187d:	89 c3                	mov    %eax,%ebx
  80187f:	eb 05                	jmp    801886 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801881:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801886:	89 d8                	mov    %ebx,%eax
  801888:	83 c4 20             	add    $0x20,%esp
  80188b:	5b                   	pop    %ebx
  80188c:	5e                   	pop    %esi
  80188d:	5d                   	pop    %ebp
  80188e:	c3                   	ret    

0080188f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801895:	ba 00 00 00 00       	mov    $0x0,%edx
  80189a:	b8 08 00 00 00       	mov    $0x8,%eax
  80189f:	e8 64 fd ff ff       	call   801608 <fsipc>
}
  8018a4:	c9                   	leave  
  8018a5:	c3                   	ret    
	...

008018a8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8018ae:	c7 44 24 04 57 2b 80 	movl   $0x802b57,0x4(%esp)
  8018b5:	00 
  8018b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b9:	89 04 24             	mov    %eax,(%esp)
  8018bc:	e8 9a f0 ff ff       	call   80095b <strcpy>
	return 0;
}
  8018c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c6:	c9                   	leave  
  8018c7:	c3                   	ret    

008018c8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	53                   	push   %ebx
  8018cc:	83 ec 14             	sub    $0x14,%esp
  8018cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018d2:	89 1c 24             	mov    %ebx,(%esp)
  8018d5:	e8 1a 0b 00 00       	call   8023f4 <pageref>
  8018da:	83 f8 01             	cmp    $0x1,%eax
  8018dd:	75 0d                	jne    8018ec <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  8018df:	8b 43 0c             	mov    0xc(%ebx),%eax
  8018e2:	89 04 24             	mov    %eax,(%esp)
  8018e5:	e8 1f 03 00 00       	call   801c09 <nsipc_close>
  8018ea:	eb 05                	jmp    8018f1 <devsock_close+0x29>
	else
		return 0;
  8018ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f1:	83 c4 14             	add    $0x14,%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018fd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801904:	00 
  801905:	8b 45 10             	mov    0x10(%ebp),%eax
  801908:	89 44 24 08          	mov    %eax,0x8(%esp)
  80190c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801913:	8b 45 08             	mov    0x8(%ebp),%eax
  801916:	8b 40 0c             	mov    0xc(%eax),%eax
  801919:	89 04 24             	mov    %eax,(%esp)
  80191c:	e8 e3 03 00 00       	call   801d04 <nsipc_send>
}
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801929:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801930:	00 
  801931:	8b 45 10             	mov    0x10(%ebp),%eax
  801934:	89 44 24 08          	mov    %eax,0x8(%esp)
  801938:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193f:	8b 45 08             	mov    0x8(%ebp),%eax
  801942:	8b 40 0c             	mov    0xc(%eax),%eax
  801945:	89 04 24             	mov    %eax,(%esp)
  801948:	e8 37 03 00 00       	call   801c84 <nsipc_recv>
}
  80194d:	c9                   	leave  
  80194e:	c3                   	ret    

0080194f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	56                   	push   %esi
  801953:	53                   	push   %ebx
  801954:	83 ec 20             	sub    $0x20,%esp
  801957:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801959:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195c:	89 04 24             	mov    %eax,(%esp)
  80195f:	e8 df f6 ff ff       	call   801043 <fd_alloc>
  801964:	89 c3                	mov    %eax,%ebx
  801966:	85 c0                	test   %eax,%eax
  801968:	78 21                	js     80198b <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80196a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801971:	00 
  801972:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801975:	89 44 24 04          	mov    %eax,0x4(%esp)
  801979:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801980:	e8 c8 f3 ff ff       	call   800d4d <sys_page_alloc>
  801985:	89 c3                	mov    %eax,%ebx
  801987:	85 c0                	test   %eax,%eax
  801989:	79 0a                	jns    801995 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  80198b:	89 34 24             	mov    %esi,(%esp)
  80198e:	e8 76 02 00 00       	call   801c09 <nsipc_close>
		return r;
  801993:	eb 22                	jmp    8019b7 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801995:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80199b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8019aa:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8019ad:	89 04 24             	mov    %eax,(%esp)
  8019b0:	e8 63 f6 ff ff       	call   801018 <fd2num>
  8019b5:	89 c3                	mov    %eax,%ebx
}
  8019b7:	89 d8                	mov    %ebx,%eax
  8019b9:	83 c4 20             	add    $0x20,%esp
  8019bc:	5b                   	pop    %ebx
  8019bd:	5e                   	pop    %esi
  8019be:	5d                   	pop    %ebp
  8019bf:	c3                   	ret    

008019c0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8019c6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019cd:	89 04 24             	mov    %eax,(%esp)
  8019d0:	e8 c1 f6 ff ff       	call   801096 <fd_lookup>
  8019d5:	85 c0                	test   %eax,%eax
  8019d7:	78 17                	js     8019f0 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8019d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019dc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019e2:	39 10                	cmp    %edx,(%eax)
  8019e4:	75 05                	jne    8019eb <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8019e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e9:	eb 05                	jmp    8019f0 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8019eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fb:	e8 c0 ff ff ff       	call   8019c0 <fd2sockid>
  801a00:	85 c0                	test   %eax,%eax
  801a02:	78 1f                	js     801a23 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a04:	8b 55 10             	mov    0x10(%ebp),%edx
  801a07:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a0e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a12:	89 04 24             	mov    %eax,(%esp)
  801a15:	e8 38 01 00 00       	call   801b52 <nsipc_accept>
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 05                	js     801a23 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801a1e:	e8 2c ff ff ff       	call   80194f <alloc_sockfd>
}
  801a23:	c9                   	leave  
  801a24:	c3                   	ret    

00801a25 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2e:	e8 8d ff ff ff       	call   8019c0 <fd2sockid>
  801a33:	85 c0                	test   %eax,%eax
  801a35:	78 16                	js     801a4d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801a37:	8b 55 10             	mov    0x10(%ebp),%edx
  801a3a:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a41:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a45:	89 04 24             	mov    %eax,(%esp)
  801a48:	e8 5b 01 00 00       	call   801ba8 <nsipc_bind>
}
  801a4d:	c9                   	leave  
  801a4e:	c3                   	ret    

00801a4f <shutdown>:

int
shutdown(int s, int how)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a55:	8b 45 08             	mov    0x8(%ebp),%eax
  801a58:	e8 63 ff ff ff       	call   8019c0 <fd2sockid>
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	78 0f                	js     801a70 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801a61:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a64:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a68:	89 04 24             	mov    %eax,(%esp)
  801a6b:	e8 77 01 00 00       	call   801be7 <nsipc_shutdown>
}
  801a70:	c9                   	leave  
  801a71:	c3                   	ret    

00801a72 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a78:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7b:	e8 40 ff ff ff       	call   8019c0 <fd2sockid>
  801a80:	85 c0                	test   %eax,%eax
  801a82:	78 16                	js     801a9a <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801a84:	8b 55 10             	mov    0x10(%ebp),%edx
  801a87:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a8e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a92:	89 04 24             	mov    %eax,(%esp)
  801a95:	e8 89 01 00 00       	call   801c23 <nsipc_connect>
}
  801a9a:	c9                   	leave  
  801a9b:	c3                   	ret    

00801a9c <listen>:

int
listen(int s, int backlog)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa5:	e8 16 ff ff ff       	call   8019c0 <fd2sockid>
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	78 0f                	js     801abd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801aae:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ab1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ab5:	89 04 24             	mov    %eax,(%esp)
  801ab8:	e8 a5 01 00 00       	call   801c62 <nsipc_listen>
}
  801abd:	c9                   	leave  
  801abe:	c3                   	ret    

00801abf <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ac5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801acf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad6:	89 04 24             	mov    %eax,(%esp)
  801ad9:	e8 99 02 00 00       	call   801d77 <nsipc_socket>
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	78 05                	js     801ae7 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801ae2:	e8 68 fe ff ff       	call   80194f <alloc_sockfd>
}
  801ae7:	c9                   	leave  
  801ae8:	c3                   	ret    
  801ae9:	00 00                	add    %al,(%eax)
	...

00801aec <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801aec:	55                   	push   %ebp
  801aed:	89 e5                	mov    %esp,%ebp
  801aef:	53                   	push   %ebx
  801af0:	83 ec 14             	sub    $0x14,%esp
  801af3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801af5:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801afc:	75 11                	jne    801b0f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801afe:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801b05:	e8 a5 08 00 00       	call   8023af <ipc_find_env>
  801b0a:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b0f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b16:	00 
  801b17:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801b1e:	00 
  801b1f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b23:	a1 04 40 80 00       	mov    0x804004,%eax
  801b28:	89 04 24             	mov    %eax,(%esp)
  801b2b:	e8 fc 07 00 00       	call   80232c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b30:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b37:	00 
  801b38:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b3f:	00 
  801b40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b47:	e8 70 07 00 00       	call   8022bc <ipc_recv>
}
  801b4c:	83 c4 14             	add    $0x14,%esp
  801b4f:	5b                   	pop    %ebx
  801b50:	5d                   	pop    %ebp
  801b51:	c3                   	ret    

00801b52 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	56                   	push   %esi
  801b56:	53                   	push   %ebx
  801b57:	83 ec 10             	sub    $0x10,%esp
  801b5a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b60:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b65:	8b 06                	mov    (%esi),%eax
  801b67:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b6c:	b8 01 00 00 00       	mov    $0x1,%eax
  801b71:	e8 76 ff ff ff       	call   801aec <nsipc>
  801b76:	89 c3                	mov    %eax,%ebx
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	78 23                	js     801b9f <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b7c:	a1 10 60 80 00       	mov    0x806010,%eax
  801b81:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b85:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b8c:	00 
  801b8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b90:	89 04 24             	mov    %eax,(%esp)
  801b93:	e8 3c ef ff ff       	call   800ad4 <memmove>
		*addrlen = ret->ret_addrlen;
  801b98:	a1 10 60 80 00       	mov    0x806010,%eax
  801b9d:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801b9f:	89 d8                	mov    %ebx,%eax
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	5b                   	pop    %ebx
  801ba5:	5e                   	pop    %esi
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    

00801ba8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	53                   	push   %ebx
  801bac:	83 ec 14             	sub    $0x14,%esp
  801baf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801bba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc5:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801bcc:	e8 03 ef ff ff       	call   800ad4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801bd1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801bd7:	b8 02 00 00 00       	mov    $0x2,%eax
  801bdc:	e8 0b ff ff ff       	call   801aec <nsipc>
}
  801be1:	83 c4 14             	add    $0x14,%esp
  801be4:	5b                   	pop    %ebx
  801be5:	5d                   	pop    %ebp
  801be6:	c3                   	ret    

00801be7 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801bed:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf8:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801bfd:	b8 03 00 00 00       	mov    $0x3,%eax
  801c02:	e8 e5 fe ff ff       	call   801aec <nsipc>
}
  801c07:	c9                   	leave  
  801c08:	c3                   	ret    

00801c09 <nsipc_close>:

int
nsipc_close(int s)
{
  801c09:	55                   	push   %ebp
  801c0a:	89 e5                	mov    %esp,%ebp
  801c0c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c12:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c17:	b8 04 00 00 00       	mov    $0x4,%eax
  801c1c:	e8 cb fe ff ff       	call   801aec <nsipc>
}
  801c21:	c9                   	leave  
  801c22:	c3                   	ret    

00801c23 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	53                   	push   %ebx
  801c27:	83 ec 14             	sub    $0x14,%esp
  801c2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c30:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c35:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c40:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801c47:	e8 88 ee ff ff       	call   800ad4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c4c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801c52:	b8 05 00 00 00       	mov    $0x5,%eax
  801c57:	e8 90 fe ff ff       	call   801aec <nsipc>
}
  801c5c:	83 c4 14             	add    $0x14,%esp
  801c5f:	5b                   	pop    %ebx
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c68:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c73:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c78:	b8 06 00 00 00       	mov    $0x6,%eax
  801c7d:	e8 6a fe ff ff       	call   801aec <nsipc>
}
  801c82:	c9                   	leave  
  801c83:	c3                   	ret    

00801c84 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	56                   	push   %esi
  801c88:	53                   	push   %ebx
  801c89:	83 ec 10             	sub    $0x10,%esp
  801c8c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c92:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c97:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c9d:	8b 45 14             	mov    0x14(%ebp),%eax
  801ca0:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ca5:	b8 07 00 00 00       	mov    $0x7,%eax
  801caa:	e8 3d fe ff ff       	call   801aec <nsipc>
  801caf:	89 c3                	mov    %eax,%ebx
  801cb1:	85 c0                	test   %eax,%eax
  801cb3:	78 46                	js     801cfb <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801cb5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801cba:	7f 04                	jg     801cc0 <nsipc_recv+0x3c>
  801cbc:	39 c6                	cmp    %eax,%esi
  801cbe:	7d 24                	jge    801ce4 <nsipc_recv+0x60>
  801cc0:	c7 44 24 0c 63 2b 80 	movl   $0x802b63,0xc(%esp)
  801cc7:	00 
  801cc8:	c7 44 24 08 2b 2b 80 	movl   $0x802b2b,0x8(%esp)
  801ccf:	00 
  801cd0:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801cd7:	00 
  801cd8:	c7 04 24 78 2b 80 00 	movl   $0x802b78,(%esp)
  801cdf:	e8 d4 e5 ff ff       	call   8002b8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ce4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ce8:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801cef:	00 
  801cf0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf3:	89 04 24             	mov    %eax,(%esp)
  801cf6:	e8 d9 ed ff ff       	call   800ad4 <memmove>
	}

	return r;
}
  801cfb:	89 d8                	mov    %ebx,%eax
  801cfd:	83 c4 10             	add    $0x10,%esp
  801d00:	5b                   	pop    %ebx
  801d01:	5e                   	pop    %esi
  801d02:	5d                   	pop    %ebp
  801d03:	c3                   	ret    

00801d04 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	53                   	push   %ebx
  801d08:	83 ec 14             	sub    $0x14,%esp
  801d0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d11:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d16:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d1c:	7e 24                	jle    801d42 <nsipc_send+0x3e>
  801d1e:	c7 44 24 0c 84 2b 80 	movl   $0x802b84,0xc(%esp)
  801d25:	00 
  801d26:	c7 44 24 08 2b 2b 80 	movl   $0x802b2b,0x8(%esp)
  801d2d:	00 
  801d2e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801d35:	00 
  801d36:	c7 04 24 78 2b 80 00 	movl   $0x802b78,(%esp)
  801d3d:	e8 76 e5 ff ff       	call   8002b8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d42:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4d:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801d54:	e8 7b ed ff ff       	call   800ad4 <memmove>
	nsipcbuf.send.req_size = size;
  801d59:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801d5f:	8b 45 14             	mov    0x14(%ebp),%eax
  801d62:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d67:	b8 08 00 00 00       	mov    $0x8,%eax
  801d6c:	e8 7b fd ff ff       	call   801aec <nsipc>
}
  801d71:	83 c4 14             	add    $0x14,%esp
  801d74:	5b                   	pop    %ebx
  801d75:	5d                   	pop    %ebp
  801d76:	c3                   	ret    

00801d77 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d80:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d85:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d88:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d8d:	8b 45 10             	mov    0x10(%ebp),%eax
  801d90:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801d95:	b8 09 00 00 00       	mov    $0x9,%eax
  801d9a:	e8 4d fd ff ff       	call   801aec <nsipc>
}
  801d9f:	c9                   	leave  
  801da0:	c3                   	ret    
  801da1:	00 00                	add    %al,(%eax)
	...

00801da4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	56                   	push   %esi
  801da8:	53                   	push   %ebx
  801da9:	83 ec 10             	sub    $0x10,%esp
  801dac:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801daf:	8b 45 08             	mov    0x8(%ebp),%eax
  801db2:	89 04 24             	mov    %eax,(%esp)
  801db5:	e8 6e f2 ff ff       	call   801028 <fd2data>
  801dba:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801dbc:	c7 44 24 04 90 2b 80 	movl   $0x802b90,0x4(%esp)
  801dc3:	00 
  801dc4:	89 34 24             	mov    %esi,(%esp)
  801dc7:	e8 8f eb ff ff       	call   80095b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801dcc:	8b 43 04             	mov    0x4(%ebx),%eax
  801dcf:	2b 03                	sub    (%ebx),%eax
  801dd1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801dd7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801dde:	00 00 00 
	stat->st_dev = &devpipe;
  801de1:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801de8:	30 80 00 
	return 0;
}
  801deb:	b8 00 00 00 00       	mov    $0x0,%eax
  801df0:	83 c4 10             	add    $0x10,%esp
  801df3:	5b                   	pop    %ebx
  801df4:	5e                   	pop    %esi
  801df5:	5d                   	pop    %ebp
  801df6:	c3                   	ret    

00801df7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	53                   	push   %ebx
  801dfb:	83 ec 14             	sub    $0x14,%esp
  801dfe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e01:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e05:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e0c:	e8 e3 ef ff ff       	call   800df4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e11:	89 1c 24             	mov    %ebx,(%esp)
  801e14:	e8 0f f2 ff ff       	call   801028 <fd2data>
  801e19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e24:	e8 cb ef ff ff       	call   800df4 <sys_page_unmap>
}
  801e29:	83 c4 14             	add    $0x14,%esp
  801e2c:	5b                   	pop    %ebx
  801e2d:	5d                   	pop    %ebp
  801e2e:	c3                   	ret    

00801e2f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	57                   	push   %edi
  801e33:	56                   	push   %esi
  801e34:	53                   	push   %ebx
  801e35:	83 ec 2c             	sub    $0x2c,%esp
  801e38:	89 c7                	mov    %eax,%edi
  801e3a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e3d:	a1 08 40 80 00       	mov    0x804008,%eax
  801e42:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e45:	89 3c 24             	mov    %edi,(%esp)
  801e48:	e8 a7 05 00 00       	call   8023f4 <pageref>
  801e4d:	89 c6                	mov    %eax,%esi
  801e4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e52:	89 04 24             	mov    %eax,(%esp)
  801e55:	e8 9a 05 00 00       	call   8023f4 <pageref>
  801e5a:	39 c6                	cmp    %eax,%esi
  801e5c:	0f 94 c0             	sete   %al
  801e5f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801e62:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801e68:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e6b:	39 cb                	cmp    %ecx,%ebx
  801e6d:	75 08                	jne    801e77 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801e6f:	83 c4 2c             	add    $0x2c,%esp
  801e72:	5b                   	pop    %ebx
  801e73:	5e                   	pop    %esi
  801e74:	5f                   	pop    %edi
  801e75:	5d                   	pop    %ebp
  801e76:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801e77:	83 f8 01             	cmp    $0x1,%eax
  801e7a:	75 c1                	jne    801e3d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e7c:	8b 42 58             	mov    0x58(%edx),%eax
  801e7f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801e86:	00 
  801e87:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e8b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e8f:	c7 04 24 97 2b 80 00 	movl   $0x802b97,(%esp)
  801e96:	e8 15 e5 ff ff       	call   8003b0 <cprintf>
  801e9b:	eb a0                	jmp    801e3d <_pipeisclosed+0xe>

00801e9d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	57                   	push   %edi
  801ea1:	56                   	push   %esi
  801ea2:	53                   	push   %ebx
  801ea3:	83 ec 1c             	sub    $0x1c,%esp
  801ea6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ea9:	89 34 24             	mov    %esi,(%esp)
  801eac:	e8 77 f1 ff ff       	call   801028 <fd2data>
  801eb1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eb3:	bf 00 00 00 00       	mov    $0x0,%edi
  801eb8:	eb 3c                	jmp    801ef6 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801eba:	89 da                	mov    %ebx,%edx
  801ebc:	89 f0                	mov    %esi,%eax
  801ebe:	e8 6c ff ff ff       	call   801e2f <_pipeisclosed>
  801ec3:	85 c0                	test   %eax,%eax
  801ec5:	75 38                	jne    801eff <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ec7:	e8 62 ee ff ff       	call   800d2e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ecc:	8b 43 04             	mov    0x4(%ebx),%eax
  801ecf:	8b 13                	mov    (%ebx),%edx
  801ed1:	83 c2 20             	add    $0x20,%edx
  801ed4:	39 d0                	cmp    %edx,%eax
  801ed6:	73 e2                	jae    801eba <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ed8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801edb:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801ede:	89 c2                	mov    %eax,%edx
  801ee0:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801ee6:	79 05                	jns    801eed <devpipe_write+0x50>
  801ee8:	4a                   	dec    %edx
  801ee9:	83 ca e0             	or     $0xffffffe0,%edx
  801eec:	42                   	inc    %edx
  801eed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ef1:	40                   	inc    %eax
  801ef2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ef5:	47                   	inc    %edi
  801ef6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ef9:	75 d1                	jne    801ecc <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801efb:	89 f8                	mov    %edi,%eax
  801efd:	eb 05                	jmp    801f04 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801eff:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f04:	83 c4 1c             	add    $0x1c,%esp
  801f07:	5b                   	pop    %ebx
  801f08:	5e                   	pop    %esi
  801f09:	5f                   	pop    %edi
  801f0a:	5d                   	pop    %ebp
  801f0b:	c3                   	ret    

00801f0c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	57                   	push   %edi
  801f10:	56                   	push   %esi
  801f11:	53                   	push   %ebx
  801f12:	83 ec 1c             	sub    $0x1c,%esp
  801f15:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f18:	89 3c 24             	mov    %edi,(%esp)
  801f1b:	e8 08 f1 ff ff       	call   801028 <fd2data>
  801f20:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f22:	be 00 00 00 00       	mov    $0x0,%esi
  801f27:	eb 3a                	jmp    801f63 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f29:	85 f6                	test   %esi,%esi
  801f2b:	74 04                	je     801f31 <devpipe_read+0x25>
				return i;
  801f2d:	89 f0                	mov    %esi,%eax
  801f2f:	eb 40                	jmp    801f71 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f31:	89 da                	mov    %ebx,%edx
  801f33:	89 f8                	mov    %edi,%eax
  801f35:	e8 f5 fe ff ff       	call   801e2f <_pipeisclosed>
  801f3a:	85 c0                	test   %eax,%eax
  801f3c:	75 2e                	jne    801f6c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f3e:	e8 eb ed ff ff       	call   800d2e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f43:	8b 03                	mov    (%ebx),%eax
  801f45:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f48:	74 df                	je     801f29 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f4a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801f4f:	79 05                	jns    801f56 <devpipe_read+0x4a>
  801f51:	48                   	dec    %eax
  801f52:	83 c8 e0             	or     $0xffffffe0,%eax
  801f55:	40                   	inc    %eax
  801f56:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801f5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f5d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801f60:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f62:	46                   	inc    %esi
  801f63:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f66:	75 db                	jne    801f43 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801f68:	89 f0                	mov    %esi,%eax
  801f6a:	eb 05                	jmp    801f71 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f6c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801f71:	83 c4 1c             	add    $0x1c,%esp
  801f74:	5b                   	pop    %ebx
  801f75:	5e                   	pop    %esi
  801f76:	5f                   	pop    %edi
  801f77:	5d                   	pop    %ebp
  801f78:	c3                   	ret    

00801f79 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	57                   	push   %edi
  801f7d:	56                   	push   %esi
  801f7e:	53                   	push   %ebx
  801f7f:	83 ec 3c             	sub    $0x3c,%esp
  801f82:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801f85:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801f88:	89 04 24             	mov    %eax,(%esp)
  801f8b:	e8 b3 f0 ff ff       	call   801043 <fd_alloc>
  801f90:	89 c3                	mov    %eax,%ebx
  801f92:	85 c0                	test   %eax,%eax
  801f94:	0f 88 45 01 00 00    	js     8020df <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f9a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fa1:	00 
  801fa2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb0:	e8 98 ed ff ff       	call   800d4d <sys_page_alloc>
  801fb5:	89 c3                	mov    %eax,%ebx
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	0f 88 20 01 00 00    	js     8020df <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801fbf:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801fc2:	89 04 24             	mov    %eax,(%esp)
  801fc5:	e8 79 f0 ff ff       	call   801043 <fd_alloc>
  801fca:	89 c3                	mov    %eax,%ebx
  801fcc:	85 c0                	test   %eax,%eax
  801fce:	0f 88 f8 00 00 00    	js     8020cc <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fd4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fdb:	00 
  801fdc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fea:	e8 5e ed ff ff       	call   800d4d <sys_page_alloc>
  801fef:	89 c3                	mov    %eax,%ebx
  801ff1:	85 c0                	test   %eax,%eax
  801ff3:	0f 88 d3 00 00 00    	js     8020cc <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ff9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ffc:	89 04 24             	mov    %eax,(%esp)
  801fff:	e8 24 f0 ff ff       	call   801028 <fd2data>
  802004:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802006:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80200d:	00 
  80200e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802012:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802019:	e8 2f ed ff ff       	call   800d4d <sys_page_alloc>
  80201e:	89 c3                	mov    %eax,%ebx
  802020:	85 c0                	test   %eax,%eax
  802022:	0f 88 91 00 00 00    	js     8020b9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802028:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80202b:	89 04 24             	mov    %eax,(%esp)
  80202e:	e8 f5 ef ff ff       	call   801028 <fd2data>
  802033:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80203a:	00 
  80203b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80203f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802046:	00 
  802047:	89 74 24 04          	mov    %esi,0x4(%esp)
  80204b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802052:	e8 4a ed ff ff       	call   800da1 <sys_page_map>
  802057:	89 c3                	mov    %eax,%ebx
  802059:	85 c0                	test   %eax,%eax
  80205b:	78 4c                	js     8020a9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80205d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802063:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802066:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802068:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80206b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802072:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802078:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80207b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80207d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802080:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802087:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80208a:	89 04 24             	mov    %eax,(%esp)
  80208d:	e8 86 ef ff ff       	call   801018 <fd2num>
  802092:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802094:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802097:	89 04 24             	mov    %eax,(%esp)
  80209a:	e8 79 ef ff ff       	call   801018 <fd2num>
  80209f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8020a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020a7:	eb 36                	jmp    8020df <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8020a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020b4:	e8 3b ed ff ff       	call   800df4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8020b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8020bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c7:	e8 28 ed ff ff       	call   800df4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8020cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020da:	e8 15 ed ff ff       	call   800df4 <sys_page_unmap>
    err:
	return r;
}
  8020df:	89 d8                	mov    %ebx,%eax
  8020e1:	83 c4 3c             	add    $0x3c,%esp
  8020e4:	5b                   	pop    %ebx
  8020e5:	5e                   	pop    %esi
  8020e6:	5f                   	pop    %edi
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    

008020e9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8020e9:	55                   	push   %ebp
  8020ea:	89 e5                	mov    %esp,%ebp
  8020ec:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f9:	89 04 24             	mov    %eax,(%esp)
  8020fc:	e8 95 ef ff ff       	call   801096 <fd_lookup>
  802101:	85 c0                	test   %eax,%eax
  802103:	78 15                	js     80211a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802105:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802108:	89 04 24             	mov    %eax,(%esp)
  80210b:	e8 18 ef ff ff       	call   801028 <fd2data>
	return _pipeisclosed(fd, p);
  802110:	89 c2                	mov    %eax,%edx
  802112:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802115:	e8 15 fd ff ff       	call   801e2f <_pipeisclosed>
}
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    

0080211c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80211f:	b8 00 00 00 00       	mov    $0x0,%eax
  802124:	5d                   	pop    %ebp
  802125:	c3                   	ret    

00802126 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802126:	55                   	push   %ebp
  802127:	89 e5                	mov    %esp,%ebp
  802129:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80212c:	c7 44 24 04 af 2b 80 	movl   $0x802baf,0x4(%esp)
  802133:	00 
  802134:	8b 45 0c             	mov    0xc(%ebp),%eax
  802137:	89 04 24             	mov    %eax,(%esp)
  80213a:	e8 1c e8 ff ff       	call   80095b <strcpy>
	return 0;
}
  80213f:	b8 00 00 00 00       	mov    $0x0,%eax
  802144:	c9                   	leave  
  802145:	c3                   	ret    

00802146 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802146:	55                   	push   %ebp
  802147:	89 e5                	mov    %esp,%ebp
  802149:	57                   	push   %edi
  80214a:	56                   	push   %esi
  80214b:	53                   	push   %ebx
  80214c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802152:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802157:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80215d:	eb 30                	jmp    80218f <devcons_write+0x49>
		m = n - tot;
  80215f:	8b 75 10             	mov    0x10(%ebp),%esi
  802162:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802164:	83 fe 7f             	cmp    $0x7f,%esi
  802167:	76 05                	jbe    80216e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802169:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80216e:	89 74 24 08          	mov    %esi,0x8(%esp)
  802172:	03 45 0c             	add    0xc(%ebp),%eax
  802175:	89 44 24 04          	mov    %eax,0x4(%esp)
  802179:	89 3c 24             	mov    %edi,(%esp)
  80217c:	e8 53 e9 ff ff       	call   800ad4 <memmove>
		sys_cputs(buf, m);
  802181:	89 74 24 04          	mov    %esi,0x4(%esp)
  802185:	89 3c 24             	mov    %edi,(%esp)
  802188:	e8 f3 ea ff ff       	call   800c80 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80218d:	01 f3                	add    %esi,%ebx
  80218f:	89 d8                	mov    %ebx,%eax
  802191:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802194:	72 c9                	jb     80215f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802196:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80219c:	5b                   	pop    %ebx
  80219d:	5e                   	pop    %esi
  80219e:	5f                   	pop    %edi
  80219f:	5d                   	pop    %ebp
  8021a0:	c3                   	ret    

008021a1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021a1:	55                   	push   %ebp
  8021a2:	89 e5                	mov    %esp,%ebp
  8021a4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8021a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021ab:	75 07                	jne    8021b4 <devcons_read+0x13>
  8021ad:	eb 25                	jmp    8021d4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021af:	e8 7a eb ff ff       	call   800d2e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021b4:	e8 e5 ea ff ff       	call   800c9e <sys_cgetc>
  8021b9:	85 c0                	test   %eax,%eax
  8021bb:	74 f2                	je     8021af <devcons_read+0xe>
  8021bd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8021bf:	85 c0                	test   %eax,%eax
  8021c1:	78 1d                	js     8021e0 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021c3:	83 f8 04             	cmp    $0x4,%eax
  8021c6:	74 13                	je     8021db <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8021c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021cb:	88 10                	mov    %dl,(%eax)
	return 1;
  8021cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d2:	eb 0c                	jmp    8021e0 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8021d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d9:	eb 05                	jmp    8021e0 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021db:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021e0:	c9                   	leave  
  8021e1:	c3                   	ret    

008021e2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8021e2:	55                   	push   %ebp
  8021e3:	89 e5                	mov    %esp,%ebp
  8021e5:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8021e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021eb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8021ee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8021f5:	00 
  8021f6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021f9:	89 04 24             	mov    %eax,(%esp)
  8021fc:	e8 7f ea ff ff       	call   800c80 <sys_cputs>
}
  802201:	c9                   	leave  
  802202:	c3                   	ret    

00802203 <getchar>:

int
getchar(void)
{
  802203:	55                   	push   %ebp
  802204:	89 e5                	mov    %esp,%ebp
  802206:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802209:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802210:	00 
  802211:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802214:	89 44 24 04          	mov    %eax,0x4(%esp)
  802218:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80221f:	e8 10 f1 ff ff       	call   801334 <read>
	if (r < 0)
  802224:	85 c0                	test   %eax,%eax
  802226:	78 0f                	js     802237 <getchar+0x34>
		return r;
	if (r < 1)
  802228:	85 c0                	test   %eax,%eax
  80222a:	7e 06                	jle    802232 <getchar+0x2f>
		return -E_EOF;
	return c;
  80222c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802230:	eb 05                	jmp    802237 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802232:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802237:	c9                   	leave  
  802238:	c3                   	ret    

00802239 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802239:	55                   	push   %ebp
  80223a:	89 e5                	mov    %esp,%ebp
  80223c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80223f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802242:	89 44 24 04          	mov    %eax,0x4(%esp)
  802246:	8b 45 08             	mov    0x8(%ebp),%eax
  802249:	89 04 24             	mov    %eax,(%esp)
  80224c:	e8 45 ee ff ff       	call   801096 <fd_lookup>
  802251:	85 c0                	test   %eax,%eax
  802253:	78 11                	js     802266 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802255:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802258:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80225e:	39 10                	cmp    %edx,(%eax)
  802260:	0f 94 c0             	sete   %al
  802263:	0f b6 c0             	movzbl %al,%eax
}
  802266:	c9                   	leave  
  802267:	c3                   	ret    

00802268 <opencons>:

int
opencons(void)
{
  802268:	55                   	push   %ebp
  802269:	89 e5                	mov    %esp,%ebp
  80226b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80226e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802271:	89 04 24             	mov    %eax,(%esp)
  802274:	e8 ca ed ff ff       	call   801043 <fd_alloc>
  802279:	85 c0                	test   %eax,%eax
  80227b:	78 3c                	js     8022b9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80227d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802284:	00 
  802285:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802293:	e8 b5 ea ff ff       	call   800d4d <sys_page_alloc>
  802298:	85 c0                	test   %eax,%eax
  80229a:	78 1d                	js     8022b9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80229c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022aa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022b1:	89 04 24             	mov    %eax,(%esp)
  8022b4:	e8 5f ed ff ff       	call   801018 <fd2num>
}
  8022b9:	c9                   	leave  
  8022ba:	c3                   	ret    
	...

008022bc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022bc:	55                   	push   %ebp
  8022bd:	89 e5                	mov    %esp,%ebp
  8022bf:	56                   	push   %esi
  8022c0:	53                   	push   %ebx
  8022c1:	83 ec 10             	sub    $0x10,%esp
  8022c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8022c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ca:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8022cd:	85 c0                	test   %eax,%eax
  8022cf:	74 0a                	je     8022db <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8022d1:	89 04 24             	mov    %eax,(%esp)
  8022d4:	e8 8a ec ff ff       	call   800f63 <sys_ipc_recv>
  8022d9:	eb 0c                	jmp    8022e7 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8022db:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8022e2:	e8 7c ec ff ff       	call   800f63 <sys_ipc_recv>
	}
	if (r < 0)
  8022e7:	85 c0                	test   %eax,%eax
  8022e9:	79 16                	jns    802301 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8022eb:	85 db                	test   %ebx,%ebx
  8022ed:	74 06                	je     8022f5 <ipc_recv+0x39>
  8022ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8022f5:	85 f6                	test   %esi,%esi
  8022f7:	74 2c                	je     802325 <ipc_recv+0x69>
  8022f9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8022ff:	eb 24                	jmp    802325 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802301:	85 db                	test   %ebx,%ebx
  802303:	74 0a                	je     80230f <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802305:	a1 08 40 80 00       	mov    0x804008,%eax
  80230a:	8b 40 74             	mov    0x74(%eax),%eax
  80230d:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  80230f:	85 f6                	test   %esi,%esi
  802311:	74 0a                	je     80231d <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  802313:	a1 08 40 80 00       	mov    0x804008,%eax
  802318:	8b 40 78             	mov    0x78(%eax),%eax
  80231b:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  80231d:	a1 08 40 80 00       	mov    0x804008,%eax
  802322:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802325:	83 c4 10             	add    $0x10,%esp
  802328:	5b                   	pop    %ebx
  802329:	5e                   	pop    %esi
  80232a:	5d                   	pop    %ebp
  80232b:	c3                   	ret    

0080232c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80232c:	55                   	push   %ebp
  80232d:	89 e5                	mov    %esp,%ebp
  80232f:	57                   	push   %edi
  802330:	56                   	push   %esi
  802331:	53                   	push   %ebx
  802332:	83 ec 1c             	sub    $0x1c,%esp
  802335:	8b 75 08             	mov    0x8(%ebp),%esi
  802338:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80233b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  80233e:	85 db                	test   %ebx,%ebx
  802340:	74 19                	je     80235b <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802342:	8b 45 14             	mov    0x14(%ebp),%eax
  802345:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802349:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80234d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802351:	89 34 24             	mov    %esi,(%esp)
  802354:	e8 e7 eb ff ff       	call   800f40 <sys_ipc_try_send>
  802359:	eb 1c                	jmp    802377 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80235b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802362:	00 
  802363:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80236a:	ee 
  80236b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80236f:	89 34 24             	mov    %esi,(%esp)
  802372:	e8 c9 eb ff ff       	call   800f40 <sys_ipc_try_send>
		}
		if (r == 0)
  802377:	85 c0                	test   %eax,%eax
  802379:	74 2c                	je     8023a7 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80237b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80237e:	74 20                	je     8023a0 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802380:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802384:	c7 44 24 08 bb 2b 80 	movl   $0x802bbb,0x8(%esp)
  80238b:	00 
  80238c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802393:	00 
  802394:	c7 04 24 ce 2b 80 00 	movl   $0x802bce,(%esp)
  80239b:	e8 18 df ff ff       	call   8002b8 <_panic>
		}
		sys_yield();
  8023a0:	e8 89 e9 ff ff       	call   800d2e <sys_yield>
	}
  8023a5:	eb 97                	jmp    80233e <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8023a7:	83 c4 1c             	add    $0x1c,%esp
  8023aa:	5b                   	pop    %ebx
  8023ab:	5e                   	pop    %esi
  8023ac:	5f                   	pop    %edi
  8023ad:	5d                   	pop    %ebp
  8023ae:	c3                   	ret    

008023af <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8023af:	55                   	push   %ebp
  8023b0:	89 e5                	mov    %esp,%ebp
  8023b2:	53                   	push   %ebx
  8023b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8023b6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8023bb:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8023c2:	89 c2                	mov    %eax,%edx
  8023c4:	c1 e2 07             	shl    $0x7,%edx
  8023c7:	29 ca                	sub    %ecx,%edx
  8023c9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023cf:	8b 52 50             	mov    0x50(%edx),%edx
  8023d2:	39 da                	cmp    %ebx,%edx
  8023d4:	75 0f                	jne    8023e5 <ipc_find_env+0x36>
			return envs[i].env_id;
  8023d6:	c1 e0 07             	shl    $0x7,%eax
  8023d9:	29 c8                	sub    %ecx,%eax
  8023db:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8023e0:	8b 40 40             	mov    0x40(%eax),%eax
  8023e3:	eb 0c                	jmp    8023f1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8023e5:	40                   	inc    %eax
  8023e6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023eb:	75 ce                	jne    8023bb <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8023ed:	66 b8 00 00          	mov    $0x0,%ax
}
  8023f1:	5b                   	pop    %ebx
  8023f2:	5d                   	pop    %ebp
  8023f3:	c3                   	ret    

008023f4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023f4:	55                   	push   %ebp
  8023f5:	89 e5                	mov    %esp,%ebp
  8023f7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023fa:	89 c2                	mov    %eax,%edx
  8023fc:	c1 ea 16             	shr    $0x16,%edx
  8023ff:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802406:	f6 c2 01             	test   $0x1,%dl
  802409:	74 1e                	je     802429 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80240b:	c1 e8 0c             	shr    $0xc,%eax
  80240e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802415:	a8 01                	test   $0x1,%al
  802417:	74 17                	je     802430 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802419:	c1 e8 0c             	shr    $0xc,%eax
  80241c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802423:	ef 
  802424:	0f b7 c0             	movzwl %ax,%eax
  802427:	eb 0c                	jmp    802435 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802429:	b8 00 00 00 00       	mov    $0x0,%eax
  80242e:	eb 05                	jmp    802435 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802430:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802435:	5d                   	pop    %ebp
  802436:	c3                   	ret    
	...

00802438 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802438:	55                   	push   %ebp
  802439:	57                   	push   %edi
  80243a:	56                   	push   %esi
  80243b:	83 ec 10             	sub    $0x10,%esp
  80243e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802442:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802446:	89 74 24 04          	mov    %esi,0x4(%esp)
  80244a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80244e:	89 cd                	mov    %ecx,%ebp
  802450:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802454:	85 c0                	test   %eax,%eax
  802456:	75 2c                	jne    802484 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802458:	39 f9                	cmp    %edi,%ecx
  80245a:	77 68                	ja     8024c4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80245c:	85 c9                	test   %ecx,%ecx
  80245e:	75 0b                	jne    80246b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802460:	b8 01 00 00 00       	mov    $0x1,%eax
  802465:	31 d2                	xor    %edx,%edx
  802467:	f7 f1                	div    %ecx
  802469:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80246b:	31 d2                	xor    %edx,%edx
  80246d:	89 f8                	mov    %edi,%eax
  80246f:	f7 f1                	div    %ecx
  802471:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802473:	89 f0                	mov    %esi,%eax
  802475:	f7 f1                	div    %ecx
  802477:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802479:	89 f0                	mov    %esi,%eax
  80247b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80247d:	83 c4 10             	add    $0x10,%esp
  802480:	5e                   	pop    %esi
  802481:	5f                   	pop    %edi
  802482:	5d                   	pop    %ebp
  802483:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802484:	39 f8                	cmp    %edi,%eax
  802486:	77 2c                	ja     8024b4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802488:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80248b:	83 f6 1f             	xor    $0x1f,%esi
  80248e:	75 4c                	jne    8024dc <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802490:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802492:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802497:	72 0a                	jb     8024a3 <__udivdi3+0x6b>
  802499:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80249d:	0f 87 ad 00 00 00    	ja     802550 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024a3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024a8:	89 f0                	mov    %esi,%eax
  8024aa:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024ac:	83 c4 10             	add    $0x10,%esp
  8024af:	5e                   	pop    %esi
  8024b0:	5f                   	pop    %edi
  8024b1:	5d                   	pop    %ebp
  8024b2:	c3                   	ret    
  8024b3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8024b4:	31 ff                	xor    %edi,%edi
  8024b6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024b8:	89 f0                	mov    %esi,%eax
  8024ba:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024bc:	83 c4 10             	add    $0x10,%esp
  8024bf:	5e                   	pop    %esi
  8024c0:	5f                   	pop    %edi
  8024c1:	5d                   	pop    %ebp
  8024c2:	c3                   	ret    
  8024c3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024c4:	89 fa                	mov    %edi,%edx
  8024c6:	89 f0                	mov    %esi,%eax
  8024c8:	f7 f1                	div    %ecx
  8024ca:	89 c6                	mov    %eax,%esi
  8024cc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8024ce:	89 f0                	mov    %esi,%eax
  8024d0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8024d2:	83 c4 10             	add    $0x10,%esp
  8024d5:	5e                   	pop    %esi
  8024d6:	5f                   	pop    %edi
  8024d7:	5d                   	pop    %ebp
  8024d8:	c3                   	ret    
  8024d9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8024dc:	89 f1                	mov    %esi,%ecx
  8024de:	d3 e0                	shl    %cl,%eax
  8024e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8024e4:	b8 20 00 00 00       	mov    $0x20,%eax
  8024e9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8024eb:	89 ea                	mov    %ebp,%edx
  8024ed:	88 c1                	mov    %al,%cl
  8024ef:	d3 ea                	shr    %cl,%edx
  8024f1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8024f5:	09 ca                	or     %ecx,%edx
  8024f7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8024fb:	89 f1                	mov    %esi,%ecx
  8024fd:	d3 e5                	shl    %cl,%ebp
  8024ff:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802503:	89 fd                	mov    %edi,%ebp
  802505:	88 c1                	mov    %al,%cl
  802507:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802509:	89 fa                	mov    %edi,%edx
  80250b:	89 f1                	mov    %esi,%ecx
  80250d:	d3 e2                	shl    %cl,%edx
  80250f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802513:	88 c1                	mov    %al,%cl
  802515:	d3 ef                	shr    %cl,%edi
  802517:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802519:	89 f8                	mov    %edi,%eax
  80251b:	89 ea                	mov    %ebp,%edx
  80251d:	f7 74 24 08          	divl   0x8(%esp)
  802521:	89 d1                	mov    %edx,%ecx
  802523:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802525:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802529:	39 d1                	cmp    %edx,%ecx
  80252b:	72 17                	jb     802544 <__udivdi3+0x10c>
  80252d:	74 09                	je     802538 <__udivdi3+0x100>
  80252f:	89 fe                	mov    %edi,%esi
  802531:	31 ff                	xor    %edi,%edi
  802533:	e9 41 ff ff ff       	jmp    802479 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802538:	8b 54 24 04          	mov    0x4(%esp),%edx
  80253c:	89 f1                	mov    %esi,%ecx
  80253e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802540:	39 c2                	cmp    %eax,%edx
  802542:	73 eb                	jae    80252f <__udivdi3+0xf7>
		{
		  q0--;
  802544:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802547:	31 ff                	xor    %edi,%edi
  802549:	e9 2b ff ff ff       	jmp    802479 <__udivdi3+0x41>
  80254e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802550:	31 f6                	xor    %esi,%esi
  802552:	e9 22 ff ff ff       	jmp    802479 <__udivdi3+0x41>
	...

00802558 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802558:	55                   	push   %ebp
  802559:	57                   	push   %edi
  80255a:	56                   	push   %esi
  80255b:	83 ec 20             	sub    $0x20,%esp
  80255e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802562:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802566:	89 44 24 14          	mov    %eax,0x14(%esp)
  80256a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80256e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802572:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802576:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802578:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80257a:	85 ed                	test   %ebp,%ebp
  80257c:	75 16                	jne    802594 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80257e:	39 f1                	cmp    %esi,%ecx
  802580:	0f 86 a6 00 00 00    	jbe    80262c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802586:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802588:	89 d0                	mov    %edx,%eax
  80258a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80258c:	83 c4 20             	add    $0x20,%esp
  80258f:	5e                   	pop    %esi
  802590:	5f                   	pop    %edi
  802591:	5d                   	pop    %ebp
  802592:	c3                   	ret    
  802593:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802594:	39 f5                	cmp    %esi,%ebp
  802596:	0f 87 ac 00 00 00    	ja     802648 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80259c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80259f:	83 f0 1f             	xor    $0x1f,%eax
  8025a2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8025a6:	0f 84 a8 00 00 00    	je     802654 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8025ac:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025b0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8025b2:	bf 20 00 00 00       	mov    $0x20,%edi
  8025b7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8025bb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025bf:	89 f9                	mov    %edi,%ecx
  8025c1:	d3 e8                	shr    %cl,%eax
  8025c3:	09 e8                	or     %ebp,%eax
  8025c5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8025c9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8025cd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8025d1:	d3 e0                	shl    %cl,%eax
  8025d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8025d7:	89 f2                	mov    %esi,%edx
  8025d9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8025db:	8b 44 24 14          	mov    0x14(%esp),%eax
  8025df:	d3 e0                	shl    %cl,%eax
  8025e1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8025e5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8025e9:	89 f9                	mov    %edi,%ecx
  8025eb:	d3 e8                	shr    %cl,%eax
  8025ed:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8025ef:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8025f1:	89 f2                	mov    %esi,%edx
  8025f3:	f7 74 24 18          	divl   0x18(%esp)
  8025f7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8025f9:	f7 64 24 0c          	mull   0xc(%esp)
  8025fd:	89 c5                	mov    %eax,%ebp
  8025ff:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802601:	39 d6                	cmp    %edx,%esi
  802603:	72 67                	jb     80266c <__umoddi3+0x114>
  802605:	74 75                	je     80267c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802607:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80260b:	29 e8                	sub    %ebp,%eax
  80260d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80260f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802613:	d3 e8                	shr    %cl,%eax
  802615:	89 f2                	mov    %esi,%edx
  802617:	89 f9                	mov    %edi,%ecx
  802619:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80261b:	09 d0                	or     %edx,%eax
  80261d:	89 f2                	mov    %esi,%edx
  80261f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802623:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802625:	83 c4 20             	add    $0x20,%esp
  802628:	5e                   	pop    %esi
  802629:	5f                   	pop    %edi
  80262a:	5d                   	pop    %ebp
  80262b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80262c:	85 c9                	test   %ecx,%ecx
  80262e:	75 0b                	jne    80263b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802630:	b8 01 00 00 00       	mov    $0x1,%eax
  802635:	31 d2                	xor    %edx,%edx
  802637:	f7 f1                	div    %ecx
  802639:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80263b:	89 f0                	mov    %esi,%eax
  80263d:	31 d2                	xor    %edx,%edx
  80263f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802641:	89 f8                	mov    %edi,%eax
  802643:	e9 3e ff ff ff       	jmp    802586 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802648:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80264a:	83 c4 20             	add    $0x20,%esp
  80264d:	5e                   	pop    %esi
  80264e:	5f                   	pop    %edi
  80264f:	5d                   	pop    %ebp
  802650:	c3                   	ret    
  802651:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802654:	39 f5                	cmp    %esi,%ebp
  802656:	72 04                	jb     80265c <__umoddi3+0x104>
  802658:	39 f9                	cmp    %edi,%ecx
  80265a:	77 06                	ja     802662 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80265c:	89 f2                	mov    %esi,%edx
  80265e:	29 cf                	sub    %ecx,%edi
  802660:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802662:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802664:	83 c4 20             	add    $0x20,%esp
  802667:	5e                   	pop    %esi
  802668:	5f                   	pop    %edi
  802669:	5d                   	pop    %ebp
  80266a:	c3                   	ret    
  80266b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80266c:	89 d1                	mov    %edx,%ecx
  80266e:	89 c5                	mov    %eax,%ebp
  802670:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802674:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802678:	eb 8d                	jmp    802607 <__umoddi3+0xaf>
  80267a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80267c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802680:	72 ea                	jb     80266c <__umoddi3+0x114>
  802682:	89 f1                	mov    %esi,%ecx
  802684:	eb 81                	jmp    802607 <__umoddi3+0xaf>
