
obj/user/ls.debug:     file format elf32-i386


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
  80002c:	e8 f7 02 00 00       	call   800328 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <ls1>:
		panic("error reading directory %s: %e", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 24             	sub    $0x24,%esp
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003e:	8a 45 0c             	mov    0xc(%ebp),%al
  800041:	88 45 f7             	mov    %al,-0x9(%ebp)
	const char *sep;

	if(flag['l'])
  800044:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  80004b:	74 21                	je     80006e <ls1+0x3a>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  80004d:	3c 01                	cmp    $0x1,%al
  80004f:	19 c0                	sbb    %eax,%eax
  800051:	83 e0 c9             	and    $0xffffffc9,%eax
  800054:	83 c0 64             	add    $0x64,%eax
  800057:	89 44 24 08          	mov    %eax,0x8(%esp)
  80005b:	8b 45 10             	mov    0x10(%ebp),%eax
  80005e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800062:	c7 04 24 02 2a 80 00 	movl   $0x802a02,(%esp)
  800069:	e8 87 1b 00 00       	call   801bf5 <printf>
	if(prefix) {
  80006e:	85 db                	test   %ebx,%ebx
  800070:	74 3b                	je     8000ad <ls1+0x79>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800072:	80 3b 00             	cmpb   $0x0,(%ebx)
  800075:	74 16                	je     80008d <ls1+0x59>
  800077:	89 1c 24             	mov    %ebx,(%esp)
  80007a:	e8 89 09 00 00       	call   800a08 <strlen>
  80007f:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  800084:	74 0e                	je     800094 <ls1+0x60>
			sep = "/";
  800086:	b8 00 2a 80 00       	mov    $0x802a00,%eax
  80008b:	eb 0c                	jmp    800099 <ls1+0x65>
		else
			sep = "";
  80008d:	b8 68 2a 80 00       	mov    $0x802a68,%eax
  800092:	eb 05                	jmp    800099 <ls1+0x65>
  800094:	b8 68 2a 80 00       	mov    $0x802a68,%eax
		printf("%s%s", prefix, sep);
  800099:	89 44 24 08          	mov    %eax,0x8(%esp)
  80009d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a1:	c7 04 24 0b 2a 80 00 	movl   $0x802a0b,(%esp)
  8000a8:	e8 48 1b 00 00       	call   801bf5 <printf>
	}
	printf("%s", name);
  8000ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8000b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b4:	c7 04 24 9d 2e 80 00 	movl   $0x802e9d,(%esp)
  8000bb:	e8 35 1b 00 00       	call   801bf5 <printf>
	if(flag['F'] && isdir)
  8000c0:	83 3d 38 41 80 00 00 	cmpl   $0x0,0x804138
  8000c7:	74 12                	je     8000db <ls1+0xa7>
  8000c9:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  8000cd:	74 0c                	je     8000db <ls1+0xa7>
		printf("/");
  8000cf:	c7 04 24 00 2a 80 00 	movl   $0x802a00,(%esp)
  8000d6:	e8 1a 1b 00 00       	call   801bf5 <printf>
	printf("\n");
  8000db:	c7 04 24 67 2a 80 00 	movl   $0x802a67,(%esp)
  8000e2:	e8 0e 1b 00 00       	call   801bf5 <printf>
}
  8000e7:	83 c4 24             	add    $0x24,%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
  8000f9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800103:	00 
  800104:	8b 45 08             	mov    0x8(%ebp),%eax
  800107:	89 04 24             	mov    %eax,(%esp)
  80010a:	e8 30 19 00 00       	call   801a3f <open>
  80010f:	89 c6                	mov    %eax,%esi
  800111:	85 c0                	test   %eax,%eax
  800113:	79 59                	jns    80016e <lsdir+0x81>
		panic("open %s: %e", path, fd);
  800115:	89 44 24 10          	mov    %eax,0x10(%esp)
  800119:	8b 45 08             	mov    0x8(%ebp),%eax
  80011c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800120:	c7 44 24 08 10 2a 80 	movl   $0x802a10,0x8(%esp)
  800127:	00 
  800128:	c7 44 24 04 1d 00 00 	movl   $0x1d,0x4(%esp)
  80012f:	00 
  800130:	c7 04 24 1c 2a 80 00 	movl   $0x802a1c,(%esp)
  800137:	e8 5c 02 00 00       	call   800398 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  80013c:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  800143:	74 2f                	je     800174 <lsdir+0x87>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  800145:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800149:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
  80014f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800153:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80015a:	0f 94 c0             	sete   %al
  80015d:	0f b6 c0             	movzbl %al,%eax
  800160:	89 44 24 04          	mov    %eax,0x4(%esp)
  800164:	89 3c 24             	mov    %edi,(%esp)
  800167:	e8 c8 fe ff ff       	call   800034 <ls1>
  80016c:	eb 06                	jmp    800174 <lsdir+0x87>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %e", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80016e:	8d 9d e8 fe ff ff    	lea    -0x118(%ebp),%ebx
  800174:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  80017b:	00 
  80017c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800180:	89 34 24             	mov    %esi,(%esp)
  800183:	e8 74 14 00 00       	call   8015fc <readn>
  800188:	3d 00 01 00 00       	cmp    $0x100,%eax
  80018d:	74 ad                	je     80013c <lsdir+0x4f>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80018f:	85 c0                	test   %eax,%eax
  800191:	7e 23                	jle    8001b6 <lsdir+0xc9>
		panic("short read in directory %s", path);
  800193:	8b 45 08             	mov    0x8(%ebp),%eax
  800196:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80019a:	c7 44 24 08 26 2a 80 	movl   $0x802a26,0x8(%esp)
  8001a1:	00 
  8001a2:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8001a9:	00 
  8001aa:	c7 04 24 1c 2a 80 00 	movl   $0x802a1c,(%esp)
  8001b1:	e8 e2 01 00 00       	call   800398 <_panic>
	if (n < 0)
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	79 27                	jns    8001e1 <lsdir+0xf4>
		panic("error reading directory %s: %e", path, n);
  8001ba:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001be:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c5:	c7 44 24 08 6c 2a 80 	movl   $0x802a6c,0x8(%esp)
  8001cc:	00 
  8001cd:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8001d4:	00 
  8001d5:	c7 04 24 1c 2a 80 00 	movl   $0x802a1c,(%esp)
  8001dc:	e8 b7 01 00 00       	call   800398 <_panic>
}
  8001e1:	81 c4 2c 01 00 00    	add    $0x12c,%esp
  8001e7:	5b                   	pop    %ebx
  8001e8:	5e                   	pop    %esi
  8001e9:	5f                   	pop    %edi
  8001ea:	5d                   	pop    %ebp
  8001eb:	c3                   	ret    

008001ec <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	53                   	push   %ebx
  8001f0:	81 ec b4 00 00 00    	sub    $0xb4,%esp
  8001f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001f9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800203:	89 1c 24             	mov    %ebx,(%esp)
  800206:	e8 ef 15 00 00       	call   8017fa <stat>
  80020b:	85 c0                	test   %eax,%eax
  80020d:	79 24                	jns    800233 <ls+0x47>
		panic("stat %s: %e", path, r);
  80020f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800213:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800217:	c7 44 24 08 41 2a 80 	movl   $0x802a41,0x8(%esp)
  80021e:	00 
  80021f:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800226:	00 
  800227:	c7 04 24 1c 2a 80 00 	movl   $0x802a1c,(%esp)
  80022e:	e8 65 01 00 00       	call   800398 <_panic>
	if (st.st_isdir && !flag['d'])
  800233:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800236:	85 c0                	test   %eax,%eax
  800238:	74 1a                	je     800254 <ls+0x68>
  80023a:	83 3d b0 41 80 00 00 	cmpl   $0x0,0x8041b0
  800241:	75 11                	jne    800254 <ls+0x68>
		lsdir(path, prefix);
  800243:	8b 45 0c             	mov    0xc(%ebp),%eax
  800246:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024a:	89 1c 24             	mov    %ebx,(%esp)
  80024d:	e8 9b fe ff ff       	call   8000ed <lsdir>
  800252:	eb 23                	jmp    800277 <ls+0x8b>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  800254:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800258:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80025b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80025f:	85 c0                	test   %eax,%eax
  800261:	0f 95 c0             	setne  %al
  800264:	0f b6 c0             	movzbl %al,%eax
  800267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800272:	e8 bd fd ff ff       	call   800034 <ls1>
}
  800277:	81 c4 b4 00 00 00    	add    $0xb4,%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    

00800280 <usage>:
	printf("\n");
}

void
usage(void)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 18             	sub    $0x18,%esp
	printf("usage: ls [-dFl] [file...]\n");
  800286:	c7 04 24 4d 2a 80 00 	movl   $0x802a4d,(%esp)
  80028d:	e8 63 19 00 00       	call   801bf5 <printf>
	exit();
  800292:	e8 e5 00 00 00       	call   80037c <exit>
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <umain>:

void
umain(int argc, char **argv)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
  80029e:	83 ec 20             	sub    $0x20,%esp
  8002a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  8002a4:	8d 45 e8             	lea    -0x18(%ebp),%eax
  8002a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002af:	8d 45 08             	lea    0x8(%ebp),%eax
  8002b2:	89 04 24             	mov    %eax,(%esp)
  8002b5:	e8 3e 0e 00 00       	call   8010f8 <argstart>
	while ((i = argnext(&args)) >= 0)
  8002ba:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  8002bd:	eb 1d                	jmp    8002dc <umain+0x43>
		switch (i) {
  8002bf:	83 f8 64             	cmp    $0x64,%eax
  8002c2:	74 0a                	je     8002ce <umain+0x35>
  8002c4:	83 f8 6c             	cmp    $0x6c,%eax
  8002c7:	74 05                	je     8002ce <umain+0x35>
  8002c9:	83 f8 46             	cmp    $0x46,%eax
  8002cc:	75 09                	jne    8002d7 <umain+0x3e>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  8002ce:	ff 04 85 20 40 80 00 	incl   0x804020(,%eax,4)
			break;
  8002d5:	eb 05                	jmp    8002dc <umain+0x43>
		default:
			usage();
  8002d7:	e8 a4 ff ff ff       	call   800280 <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  8002dc:	89 1c 24             	mov    %ebx,(%esp)
  8002df:	e8 4d 0e 00 00       	call   801131 <argnext>
  8002e4:	85 c0                	test   %eax,%eax
  8002e6:	79 d7                	jns    8002bf <umain+0x26>
			break;
		default:
			usage();
		}

	if (argc == 1)
  8002e8:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8002ec:	75 28                	jne    800316 <umain+0x7d>
		ls("/", "");
  8002ee:	c7 44 24 04 68 2a 80 	movl   $0x802a68,0x4(%esp)
  8002f5:	00 
  8002f6:	c7 04 24 00 2a 80 00 	movl   $0x802a00,(%esp)
  8002fd:	e8 ea fe ff ff       	call   8001ec <ls>
  800302:	eb 1c                	jmp    800320 <umain+0x87>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  800304:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  800307:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030b:	89 04 24             	mov    %eax,(%esp)
  80030e:	e8 d9 fe ff ff       	call   8001ec <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  800313:	43                   	inc    %ebx
  800314:	eb 05                	jmp    80031b <umain+0x82>
			break;
		default:
			usage();
		}

	if (argc == 1)
  800316:	bb 01 00 00 00       	mov    $0x1,%ebx
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  80031b:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80031e:	7c e4                	jl     800304 <umain+0x6b>
			ls(argv[i], argv[i]);
	}
}
  800320:	83 c4 20             	add    $0x20,%esp
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    
	...

00800328 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
  80032d:	83 ec 10             	sub    $0x10,%esp
  800330:	8b 75 08             	mov    0x8(%ebp),%esi
  800333:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800336:	e8 b4 0a 00 00       	call   800def <sys_getenvid>
  80033b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800340:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800347:	c1 e0 07             	shl    $0x7,%eax
  80034a:	29 d0                	sub    %edx,%eax
  80034c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800351:	a3 20 44 80 00       	mov    %eax,0x804420


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800356:	85 f6                	test   %esi,%esi
  800358:	7e 07                	jle    800361 <libmain+0x39>
		binaryname = argv[0];
  80035a:	8b 03                	mov    (%ebx),%eax
  80035c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800361:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800365:	89 34 24             	mov    %esi,(%esp)
  800368:	e8 2c ff ff ff       	call   800299 <umain>

	// exit gracefully
	exit();
  80036d:	e8 0a 00 00 00       	call   80037c <exit>
}
  800372:	83 c4 10             	add    $0x10,%esp
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5d                   	pop    %ebp
  800378:	c3                   	ret    
  800379:	00 00                	add    %al,(%eax)
	...

0080037c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800382:	e8 b0 10 00 00       	call   801437 <close_all>
	sys_env_destroy(0);
  800387:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80038e:	e8 0a 0a 00 00       	call   800d9d <sys_env_destroy>
}
  800393:	c9                   	leave  
  800394:	c3                   	ret    
  800395:	00 00                	add    %al,(%eax)
	...

00800398 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800398:	55                   	push   %ebp
  800399:	89 e5                	mov    %esp,%ebp
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003a0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003a3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8003a9:	e8 41 0a 00 00       	call   800def <sys_getenvid>
  8003ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003c4:	c7 04 24 98 2a 80 00 	movl   $0x802a98,(%esp)
  8003cb:	e8 c0 00 00 00       	call   800490 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d7:	89 04 24             	mov    %eax,(%esp)
  8003da:	e8 50 00 00 00       	call   80042f <vcprintf>
	cprintf("\n");
  8003df:	c7 04 24 67 2a 80 00 	movl   $0x802a67,(%esp)
  8003e6:	e8 a5 00 00 00       	call   800490 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003eb:	cc                   	int3   
  8003ec:	eb fd                	jmp    8003eb <_panic+0x53>
	...

008003f0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 14             	sub    $0x14,%esp
  8003f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003fa:	8b 03                	mov    (%ebx),%eax
  8003fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ff:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800403:	40                   	inc    %eax
  800404:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800406:	3d ff 00 00 00       	cmp    $0xff,%eax
  80040b:	75 19                	jne    800426 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80040d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800414:	00 
  800415:	8d 43 08             	lea    0x8(%ebx),%eax
  800418:	89 04 24             	mov    %eax,(%esp)
  80041b:	e8 40 09 00 00       	call   800d60 <sys_cputs>
		b->idx = 0;
  800420:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800426:	ff 43 04             	incl   0x4(%ebx)
}
  800429:	83 c4 14             	add    $0x14,%esp
  80042c:	5b                   	pop    %ebx
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800438:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80043f:	00 00 00 
	b.cnt = 0;
  800442:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800449:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80044c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80044f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800453:	8b 45 08             	mov    0x8(%ebp),%eax
  800456:	89 44 24 08          	mov    %eax,0x8(%esp)
  80045a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800460:	89 44 24 04          	mov    %eax,0x4(%esp)
  800464:	c7 04 24 f0 03 80 00 	movl   $0x8003f0,(%esp)
  80046b:	e8 82 01 00 00       	call   8005f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800470:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800476:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800480:	89 04 24             	mov    %eax,(%esp)
  800483:	e8 d8 08 00 00       	call   800d60 <sys_cputs>

	return b.cnt;
}
  800488:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80048e:	c9                   	leave  
  80048f:	c3                   	ret    

00800490 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800496:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800499:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049d:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 87 ff ff ff       	call   80042f <vcprintf>
	va_end(ap);

	return cnt;
}
  8004a8:	c9                   	leave  
  8004a9:	c3                   	ret    
	...

008004ac <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ac:	55                   	push   %ebp
  8004ad:	89 e5                	mov    %esp,%ebp
  8004af:	57                   	push   %edi
  8004b0:	56                   	push   %esi
  8004b1:	53                   	push   %ebx
  8004b2:	83 ec 3c             	sub    $0x3c,%esp
  8004b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b8:	89 d7                	mov    %edx,%edi
  8004ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004c9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004cc:	85 c0                	test   %eax,%eax
  8004ce:	75 08                	jne    8004d8 <printnum+0x2c>
  8004d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004d6:	77 57                	ja     80052f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004d8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8004dc:	4b                   	dec    %ebx
  8004dd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8004e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8004ec:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8004f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004f7:	00 
  8004f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800501:	89 44 24 04          	mov    %eax,0x4(%esp)
  800505:	e8 9e 22 00 00       	call   8027a8 <__udivdi3>
  80050a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80050e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800512:	89 04 24             	mov    %eax,(%esp)
  800515:	89 54 24 04          	mov    %edx,0x4(%esp)
  800519:	89 fa                	mov    %edi,%edx
  80051b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051e:	e8 89 ff ff ff       	call   8004ac <printnum>
  800523:	eb 0f                	jmp    800534 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800525:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800529:	89 34 24             	mov    %esi,(%esp)
  80052c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80052f:	4b                   	dec    %ebx
  800530:	85 db                	test   %ebx,%ebx
  800532:	7f f1                	jg     800525 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800534:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800538:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80053c:	8b 45 10             	mov    0x10(%ebp),%eax
  80053f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800543:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80054a:	00 
  80054b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800554:	89 44 24 04          	mov    %eax,0x4(%esp)
  800558:	e8 6b 23 00 00       	call   8028c8 <__umoddi3>
  80055d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800561:	0f be 80 bb 2a 80 00 	movsbl 0x802abb(%eax),%eax
  800568:	89 04 24             	mov    %eax,(%esp)
  80056b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80056e:	83 c4 3c             	add    $0x3c,%esp
  800571:	5b                   	pop    %ebx
  800572:	5e                   	pop    %esi
  800573:	5f                   	pop    %edi
  800574:	5d                   	pop    %ebp
  800575:	c3                   	ret    

00800576 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800576:	55                   	push   %ebp
  800577:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800579:	83 fa 01             	cmp    $0x1,%edx
  80057c:	7e 0e                	jle    80058c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80057e:	8b 10                	mov    (%eax),%edx
  800580:	8d 4a 08             	lea    0x8(%edx),%ecx
  800583:	89 08                	mov    %ecx,(%eax)
  800585:	8b 02                	mov    (%edx),%eax
  800587:	8b 52 04             	mov    0x4(%edx),%edx
  80058a:	eb 22                	jmp    8005ae <getuint+0x38>
	else if (lflag)
  80058c:	85 d2                	test   %edx,%edx
  80058e:	74 10                	je     8005a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800590:	8b 10                	mov    (%eax),%edx
  800592:	8d 4a 04             	lea    0x4(%edx),%ecx
  800595:	89 08                	mov    %ecx,(%eax)
  800597:	8b 02                	mov    (%edx),%eax
  800599:	ba 00 00 00 00       	mov    $0x0,%edx
  80059e:	eb 0e                	jmp    8005ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005a0:	8b 10                	mov    (%eax),%edx
  8005a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005a5:	89 08                	mov    %ecx,(%eax)
  8005a7:	8b 02                	mov    (%edx),%eax
  8005a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005ae:	5d                   	pop    %ebp
  8005af:	c3                   	ret    

008005b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005b0:	55                   	push   %ebp
  8005b1:	89 e5                	mov    %esp,%ebp
  8005b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005b6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005b9:	8b 10                	mov    (%eax),%edx
  8005bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8005be:	73 08                	jae    8005c8 <sprintputch+0x18>
		*b->buf++ = ch;
  8005c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005c3:	88 0a                	mov    %cl,(%edx)
  8005c5:	42                   	inc    %edx
  8005c6:	89 10                	mov    %edx,(%eax)
}
  8005c8:	5d                   	pop    %ebp
  8005c9:	c3                   	ret    

008005ca <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ca:	55                   	push   %ebp
  8005cb:	89 e5                	mov    %esp,%ebp
  8005cd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005d0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8005da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e8:	89 04 24             	mov    %eax,(%esp)
  8005eb:	e8 02 00 00 00       	call   8005f2 <vprintfmt>
	va_end(ap);
}
  8005f0:	c9                   	leave  
  8005f1:	c3                   	ret    

008005f2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	57                   	push   %edi
  8005f6:	56                   	push   %esi
  8005f7:	53                   	push   %ebx
  8005f8:	83 ec 4c             	sub    $0x4c,%esp
  8005fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005fe:	8b 75 10             	mov    0x10(%ebp),%esi
  800601:	eb 12                	jmp    800615 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800603:	85 c0                	test   %eax,%eax
  800605:	0f 84 6b 03 00 00    	je     800976 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80060b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80060f:	89 04 24             	mov    %eax,(%esp)
  800612:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800615:	0f b6 06             	movzbl (%esi),%eax
  800618:	46                   	inc    %esi
  800619:	83 f8 25             	cmp    $0x25,%eax
  80061c:	75 e5                	jne    800603 <vprintfmt+0x11>
  80061e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800622:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800629:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80062e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800635:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063a:	eb 26                	jmp    800662 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80063f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800643:	eb 1d                	jmp    800662 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800645:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800648:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80064c:	eb 14                	jmp    800662 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80064e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800651:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800658:	eb 08                	jmp    800662 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80065a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80065d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800662:	0f b6 06             	movzbl (%esi),%eax
  800665:	8d 56 01             	lea    0x1(%esi),%edx
  800668:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80066b:	8a 16                	mov    (%esi),%dl
  80066d:	83 ea 23             	sub    $0x23,%edx
  800670:	80 fa 55             	cmp    $0x55,%dl
  800673:	0f 87 e1 02 00 00    	ja     80095a <vprintfmt+0x368>
  800679:	0f b6 d2             	movzbl %dl,%edx
  80067c:	ff 24 95 00 2c 80 00 	jmp    *0x802c00(,%edx,4)
  800683:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800686:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80068b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80068e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800692:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800695:	8d 50 d0             	lea    -0x30(%eax),%edx
  800698:	83 fa 09             	cmp    $0x9,%edx
  80069b:	77 2a                	ja     8006c7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80069d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80069e:	eb eb                	jmp    80068b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a3:	8d 50 04             	lea    0x4(%eax),%edx
  8006a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006ae:	eb 17                	jmp    8006c7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006b0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006b4:	78 98                	js     80064e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b9:	eb a7                	jmp    800662 <vprintfmt+0x70>
  8006bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006be:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006c5:	eb 9b                	jmp    800662 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006cb:	79 95                	jns    800662 <vprintfmt+0x70>
  8006cd:	eb 8b                	jmp    80065a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006cf:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006d3:	eb 8d                	jmp    800662 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8d 50 04             	lea    0x4(%eax),%edx
  8006db:	89 55 14             	mov    %edx,0x14(%ebp)
  8006de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e2:	8b 00                	mov    (%eax),%eax
  8006e4:	89 04 24             	mov    %eax,(%esp)
  8006e7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006ed:	e9 23 ff ff ff       	jmp    800615 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8d 50 04             	lea    0x4(%eax),%edx
  8006f8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fb:	8b 00                	mov    (%eax),%eax
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	79 02                	jns    800703 <vprintfmt+0x111>
  800701:	f7 d8                	neg    %eax
  800703:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800705:	83 f8 10             	cmp    $0x10,%eax
  800708:	7f 0b                	jg     800715 <vprintfmt+0x123>
  80070a:	8b 04 85 60 2d 80 00 	mov    0x802d60(,%eax,4),%eax
  800711:	85 c0                	test   %eax,%eax
  800713:	75 23                	jne    800738 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800715:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800719:	c7 44 24 08 d3 2a 80 	movl   $0x802ad3,0x8(%esp)
  800720:	00 
  800721:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800725:	8b 45 08             	mov    0x8(%ebp),%eax
  800728:	89 04 24             	mov    %eax,(%esp)
  80072b:	e8 9a fe ff ff       	call   8005ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800730:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800733:	e9 dd fe ff ff       	jmp    800615 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800738:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80073c:	c7 44 24 08 9d 2e 80 	movl   $0x802e9d,0x8(%esp)
  800743:	00 
  800744:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800748:	8b 55 08             	mov    0x8(%ebp),%edx
  80074b:	89 14 24             	mov    %edx,(%esp)
  80074e:	e8 77 fe ff ff       	call   8005ca <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800753:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800756:	e9 ba fe ff ff       	jmp    800615 <vprintfmt+0x23>
  80075b:	89 f9                	mov    %edi,%ecx
  80075d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800760:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 50 04             	lea    0x4(%eax),%edx
  800769:	89 55 14             	mov    %edx,0x14(%ebp)
  80076c:	8b 30                	mov    (%eax),%esi
  80076e:	85 f6                	test   %esi,%esi
  800770:	75 05                	jne    800777 <vprintfmt+0x185>
				p = "(null)";
  800772:	be cc 2a 80 00       	mov    $0x802acc,%esi
			if (width > 0 && padc != '-')
  800777:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80077b:	0f 8e 84 00 00 00    	jle    800805 <vprintfmt+0x213>
  800781:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800785:	74 7e                	je     800805 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800787:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80078b:	89 34 24             	mov    %esi,(%esp)
  80078e:	e8 8b 02 00 00       	call   800a1e <strnlen>
  800793:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800796:	29 c2                	sub    %eax,%edx
  800798:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80079b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80079f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007a2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007a5:	89 de                	mov    %ebx,%esi
  8007a7:	89 d3                	mov    %edx,%ebx
  8007a9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ab:	eb 0b                	jmp    8007b8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b1:	89 3c 24             	mov    %edi,(%esp)
  8007b4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007b7:	4b                   	dec    %ebx
  8007b8:	85 db                	test   %ebx,%ebx
  8007ba:	7f f1                	jg     8007ad <vprintfmt+0x1bb>
  8007bc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007bf:	89 f3                	mov    %esi,%ebx
  8007c1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007c7:	85 c0                	test   %eax,%eax
  8007c9:	79 05                	jns    8007d0 <vprintfmt+0x1de>
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d3:	29 c2                	sub    %eax,%edx
  8007d5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007d8:	eb 2b                	jmp    800805 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007da:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007de:	74 18                	je     8007f8 <vprintfmt+0x206>
  8007e0:	8d 50 e0             	lea    -0x20(%eax),%edx
  8007e3:	83 fa 5e             	cmp    $0x5e,%edx
  8007e6:	76 10                	jbe    8007f8 <vprintfmt+0x206>
					putch('?', putdat);
  8007e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ec:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007f3:	ff 55 08             	call   *0x8(%ebp)
  8007f6:	eb 0a                	jmp    800802 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8007f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007fc:	89 04 24             	mov    %eax,(%esp)
  8007ff:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800802:	ff 4d e4             	decl   -0x1c(%ebp)
  800805:	0f be 06             	movsbl (%esi),%eax
  800808:	46                   	inc    %esi
  800809:	85 c0                	test   %eax,%eax
  80080b:	74 21                	je     80082e <vprintfmt+0x23c>
  80080d:	85 ff                	test   %edi,%edi
  80080f:	78 c9                	js     8007da <vprintfmt+0x1e8>
  800811:	4f                   	dec    %edi
  800812:	79 c6                	jns    8007da <vprintfmt+0x1e8>
  800814:	8b 7d 08             	mov    0x8(%ebp),%edi
  800817:	89 de                	mov    %ebx,%esi
  800819:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80081c:	eb 18                	jmp    800836 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80081e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800822:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800829:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80082b:	4b                   	dec    %ebx
  80082c:	eb 08                	jmp    800836 <vprintfmt+0x244>
  80082e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800831:	89 de                	mov    %ebx,%esi
  800833:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800836:	85 db                	test   %ebx,%ebx
  800838:	7f e4                	jg     80081e <vprintfmt+0x22c>
  80083a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80083d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80083f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800842:	e9 ce fd ff ff       	jmp    800615 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800847:	83 f9 01             	cmp    $0x1,%ecx
  80084a:	7e 10                	jle    80085c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8d 50 08             	lea    0x8(%eax),%edx
  800852:	89 55 14             	mov    %edx,0x14(%ebp)
  800855:	8b 30                	mov    (%eax),%esi
  800857:	8b 78 04             	mov    0x4(%eax),%edi
  80085a:	eb 26                	jmp    800882 <vprintfmt+0x290>
	else if (lflag)
  80085c:	85 c9                	test   %ecx,%ecx
  80085e:	74 12                	je     800872 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800860:	8b 45 14             	mov    0x14(%ebp),%eax
  800863:	8d 50 04             	lea    0x4(%eax),%edx
  800866:	89 55 14             	mov    %edx,0x14(%ebp)
  800869:	8b 30                	mov    (%eax),%esi
  80086b:	89 f7                	mov    %esi,%edi
  80086d:	c1 ff 1f             	sar    $0x1f,%edi
  800870:	eb 10                	jmp    800882 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	8d 50 04             	lea    0x4(%eax),%edx
  800878:	89 55 14             	mov    %edx,0x14(%ebp)
  80087b:	8b 30                	mov    (%eax),%esi
  80087d:	89 f7                	mov    %esi,%edi
  80087f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800882:	85 ff                	test   %edi,%edi
  800884:	78 0a                	js     800890 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800886:	b8 0a 00 00 00       	mov    $0xa,%eax
  80088b:	e9 8c 00 00 00       	jmp    80091c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800890:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800894:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80089b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80089e:	f7 de                	neg    %esi
  8008a0:	83 d7 00             	adc    $0x0,%edi
  8008a3:	f7 df                	neg    %edi
			}
			base = 10;
  8008a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008aa:	eb 70                	jmp    80091c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008ac:	89 ca                	mov    %ecx,%edx
  8008ae:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b1:	e8 c0 fc ff ff       	call   800576 <getuint>
  8008b6:	89 c6                	mov    %eax,%esi
  8008b8:	89 d7                	mov    %edx,%edi
			base = 10;
  8008ba:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008bf:	eb 5b                	jmp    80091c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  8008c1:	89 ca                	mov    %ecx,%edx
  8008c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c6:	e8 ab fc ff ff       	call   800576 <getuint>
  8008cb:	89 c6                	mov    %eax,%esi
  8008cd:	89 d7                	mov    %edx,%edi
			base = 8;
  8008cf:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8008d4:	eb 46                	jmp    80091c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8008d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008da:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008e1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8008e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008ef:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f5:	8d 50 04             	lea    0x4(%eax),%edx
  8008f8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008fb:	8b 30                	mov    (%eax),%esi
  8008fd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800902:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800907:	eb 13                	jmp    80091c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800909:	89 ca                	mov    %ecx,%edx
  80090b:	8d 45 14             	lea    0x14(%ebp),%eax
  80090e:	e8 63 fc ff ff       	call   800576 <getuint>
  800913:	89 c6                	mov    %eax,%esi
  800915:	89 d7                	mov    %edx,%edi
			base = 16;
  800917:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80091c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800920:	89 54 24 10          	mov    %edx,0x10(%esp)
  800924:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800927:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80092b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80092f:	89 34 24             	mov    %esi,(%esp)
  800932:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800936:	89 da                	mov    %ebx,%edx
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	e8 6c fb ff ff       	call   8004ac <printnum>
			break;
  800940:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800943:	e9 cd fc ff ff       	jmp    800615 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800948:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80094c:	89 04 24             	mov    %eax,(%esp)
  80094f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800952:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800955:	e9 bb fc ff ff       	jmp    800615 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80095a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800965:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800968:	eb 01                	jmp    80096b <vprintfmt+0x379>
  80096a:	4e                   	dec    %esi
  80096b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80096f:	75 f9                	jne    80096a <vprintfmt+0x378>
  800971:	e9 9f fc ff ff       	jmp    800615 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800976:	83 c4 4c             	add    $0x4c,%esp
  800979:	5b                   	pop    %ebx
  80097a:	5e                   	pop    %esi
  80097b:	5f                   	pop    %edi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	83 ec 28             	sub    $0x28,%esp
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80098a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80098d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800991:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800994:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80099b:	85 c0                	test   %eax,%eax
  80099d:	74 30                	je     8009cf <vsnprintf+0x51>
  80099f:	85 d2                	test   %edx,%edx
  8009a1:	7e 33                	jle    8009d6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b8:	c7 04 24 b0 05 80 00 	movl   $0x8005b0,(%esp)
  8009bf:	e8 2e fc ff ff       	call   8005f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009c7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009cd:	eb 0c                	jmp    8009db <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009d4:	eb 05                	jmp    8009db <vsnprintf+0x5d>
  8009d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fb:	89 04 24             	mov    %eax,(%esp)
  8009fe:	e8 7b ff ff ff       	call   80097e <vsnprintf>
	va_end(ap);

	return rc;
}
  800a03:	c9                   	leave  
  800a04:	c3                   	ret    
  800a05:	00 00                	add    %al,(%eax)
	...

00800a08 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a13:	eb 01                	jmp    800a16 <strlen+0xe>
		n++;
  800a15:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a16:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a1a:	75 f9                	jne    800a15 <strlen+0xd>
		n++;
	return n;
}
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a24:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2c:	eb 01                	jmp    800a2f <strnlen+0x11>
		n++;
  800a2e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a2f:	39 d0                	cmp    %edx,%eax
  800a31:	74 06                	je     800a39 <strnlen+0x1b>
  800a33:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a37:	75 f5                	jne    800a2e <strnlen+0x10>
		n++;
	return n;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a4d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a50:	42                   	inc    %edx
  800a51:	84 c9                	test   %cl,%cl
  800a53:	75 f5                	jne    800a4a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a55:	5b                   	pop    %ebx
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	53                   	push   %ebx
  800a5c:	83 ec 08             	sub    $0x8,%esp
  800a5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a62:	89 1c 24             	mov    %ebx,(%esp)
  800a65:	e8 9e ff ff ff       	call   800a08 <strlen>
	strcpy(dst + len, src);
  800a6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a71:	01 d8                	add    %ebx,%eax
  800a73:	89 04 24             	mov    %eax,(%esp)
  800a76:	e8 c0 ff ff ff       	call   800a3b <strcpy>
	return dst;
}
  800a7b:	89 d8                	mov    %ebx,%eax
  800a7d:	83 c4 08             	add    $0x8,%esp
  800a80:	5b                   	pop    %ebx
  800a81:	5d                   	pop    %ebp
  800a82:	c3                   	ret    

00800a83 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a83:	55                   	push   %ebp
  800a84:	89 e5                	mov    %esp,%ebp
  800a86:	56                   	push   %esi
  800a87:	53                   	push   %ebx
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a91:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a96:	eb 0c                	jmp    800aa4 <strncpy+0x21>
		*dst++ = *src;
  800a98:	8a 1a                	mov    (%edx),%bl
  800a9a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a9d:	80 3a 01             	cmpb   $0x1,(%edx)
  800aa0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aa3:	41                   	inc    %ecx
  800aa4:	39 f1                	cmp    %esi,%ecx
  800aa6:	75 f0                	jne    800a98 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800aa8:	5b                   	pop    %ebx
  800aa9:	5e                   	pop    %esi
  800aaa:	5d                   	pop    %ebp
  800aab:	c3                   	ret    

00800aac <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aba:	85 d2                	test   %edx,%edx
  800abc:	75 0a                	jne    800ac8 <strlcpy+0x1c>
  800abe:	89 f0                	mov    %esi,%eax
  800ac0:	eb 1a                	jmp    800adc <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ac2:	88 18                	mov    %bl,(%eax)
  800ac4:	40                   	inc    %eax
  800ac5:	41                   	inc    %ecx
  800ac6:	eb 02                	jmp    800aca <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac8:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800aca:	4a                   	dec    %edx
  800acb:	74 0a                	je     800ad7 <strlcpy+0x2b>
  800acd:	8a 19                	mov    (%ecx),%bl
  800acf:	84 db                	test   %bl,%bl
  800ad1:	75 ef                	jne    800ac2 <strlcpy+0x16>
  800ad3:	89 c2                	mov    %eax,%edx
  800ad5:	eb 02                	jmp    800ad9 <strlcpy+0x2d>
  800ad7:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800ad9:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800adc:	29 f0                	sub    %esi,%eax
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aeb:	eb 02                	jmp    800aef <strcmp+0xd>
		p++, q++;
  800aed:	41                   	inc    %ecx
  800aee:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aef:	8a 01                	mov    (%ecx),%al
  800af1:	84 c0                	test   %al,%al
  800af3:	74 04                	je     800af9 <strcmp+0x17>
  800af5:	3a 02                	cmp    (%edx),%al
  800af7:	74 f4                	je     800aed <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af9:	0f b6 c0             	movzbl %al,%eax
  800afc:	0f b6 12             	movzbl (%edx),%edx
  800aff:	29 d0                	sub    %edx,%eax
}
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	53                   	push   %ebx
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b10:	eb 03                	jmp    800b15 <strncmp+0x12>
		n--, p++, q++;
  800b12:	4a                   	dec    %edx
  800b13:	40                   	inc    %eax
  800b14:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b15:	85 d2                	test   %edx,%edx
  800b17:	74 14                	je     800b2d <strncmp+0x2a>
  800b19:	8a 18                	mov    (%eax),%bl
  800b1b:	84 db                	test   %bl,%bl
  800b1d:	74 04                	je     800b23 <strncmp+0x20>
  800b1f:	3a 19                	cmp    (%ecx),%bl
  800b21:	74 ef                	je     800b12 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b23:	0f b6 00             	movzbl (%eax),%eax
  800b26:	0f b6 11             	movzbl (%ecx),%edx
  800b29:	29 d0                	sub    %edx,%eax
  800b2b:	eb 05                	jmp    800b32 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b2d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b32:	5b                   	pop    %ebx
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b3e:	eb 05                	jmp    800b45 <strchr+0x10>
		if (*s == c)
  800b40:	38 ca                	cmp    %cl,%dl
  800b42:	74 0c                	je     800b50 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b44:	40                   	inc    %eax
  800b45:	8a 10                	mov    (%eax),%dl
  800b47:	84 d2                	test   %dl,%dl
  800b49:	75 f5                	jne    800b40 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b5b:	eb 05                	jmp    800b62 <strfind+0x10>
		if (*s == c)
  800b5d:	38 ca                	cmp    %cl,%dl
  800b5f:	74 07                	je     800b68 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b61:	40                   	inc    %eax
  800b62:	8a 10                	mov    (%eax),%dl
  800b64:	84 d2                	test   %dl,%dl
  800b66:	75 f5                	jne    800b5d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
  800b70:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b76:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b79:	85 c9                	test   %ecx,%ecx
  800b7b:	74 30                	je     800bad <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b7d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b83:	75 25                	jne    800baa <memset+0x40>
  800b85:	f6 c1 03             	test   $0x3,%cl
  800b88:	75 20                	jne    800baa <memset+0x40>
		c &= 0xFF;
  800b8a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b8d:	89 d3                	mov    %edx,%ebx
  800b8f:	c1 e3 08             	shl    $0x8,%ebx
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	c1 e6 18             	shl    $0x18,%esi
  800b97:	89 d0                	mov    %edx,%eax
  800b99:	c1 e0 10             	shl    $0x10,%eax
  800b9c:	09 f0                	or     %esi,%eax
  800b9e:	09 d0                	or     %edx,%eax
  800ba0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ba2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ba5:	fc                   	cld    
  800ba6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ba8:	eb 03                	jmp    800bad <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800baa:	fc                   	cld    
  800bab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bad:	89 f8                	mov    %edi,%eax
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bc2:	39 c6                	cmp    %eax,%esi
  800bc4:	73 34                	jae    800bfa <memmove+0x46>
  800bc6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc9:	39 d0                	cmp    %edx,%eax
  800bcb:	73 2d                	jae    800bfa <memmove+0x46>
		s += n;
		d += n;
  800bcd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd0:	f6 c2 03             	test   $0x3,%dl
  800bd3:	75 1b                	jne    800bf0 <memmove+0x3c>
  800bd5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bdb:	75 13                	jne    800bf0 <memmove+0x3c>
  800bdd:	f6 c1 03             	test   $0x3,%cl
  800be0:	75 0e                	jne    800bf0 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800be2:	83 ef 04             	sub    $0x4,%edi
  800be5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be8:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800beb:	fd                   	std    
  800bec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bee:	eb 07                	jmp    800bf7 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bf0:	4f                   	dec    %edi
  800bf1:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bf4:	fd                   	std    
  800bf5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf7:	fc                   	cld    
  800bf8:	eb 20                	jmp    800c1a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bfa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c00:	75 13                	jne    800c15 <memmove+0x61>
  800c02:	a8 03                	test   $0x3,%al
  800c04:	75 0f                	jne    800c15 <memmove+0x61>
  800c06:	f6 c1 03             	test   $0x3,%cl
  800c09:	75 0a                	jne    800c15 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c0b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c0e:	89 c7                	mov    %eax,%edi
  800c10:	fc                   	cld    
  800c11:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c13:	eb 05                	jmp    800c1a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c15:	89 c7                	mov    %eax,%edi
  800c17:	fc                   	cld    
  800c18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c24:	8b 45 10             	mov    0x10(%ebp),%eax
  800c27:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c32:	8b 45 08             	mov    0x8(%ebp),%eax
  800c35:	89 04 24             	mov    %eax,(%esp)
  800c38:	e8 77 ff ff ff       	call   800bb4 <memmove>
}
  800c3d:	c9                   	leave  
  800c3e:	c3                   	ret    

00800c3f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c48:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c53:	eb 16                	jmp    800c6b <memcmp+0x2c>
		if (*s1 != *s2)
  800c55:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c58:	42                   	inc    %edx
  800c59:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c5d:	38 c8                	cmp    %cl,%al
  800c5f:	74 0a                	je     800c6b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c61:	0f b6 c0             	movzbl %al,%eax
  800c64:	0f b6 c9             	movzbl %cl,%ecx
  800c67:	29 c8                	sub    %ecx,%eax
  800c69:	eb 09                	jmp    800c74 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c6b:	39 da                	cmp    %ebx,%edx
  800c6d:	75 e6                	jne    800c55 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c82:	89 c2                	mov    %eax,%edx
  800c84:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c87:	eb 05                	jmp    800c8e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c89:	38 08                	cmp    %cl,(%eax)
  800c8b:	74 05                	je     800c92 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c8d:	40                   	inc    %eax
  800c8e:	39 d0                	cmp    %edx,%eax
  800c90:	72 f7                	jb     800c89 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	57                   	push   %edi
  800c98:	56                   	push   %esi
  800c99:	53                   	push   %ebx
  800c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca0:	eb 01                	jmp    800ca3 <strtol+0xf>
		s++;
  800ca2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca3:	8a 02                	mov    (%edx),%al
  800ca5:	3c 20                	cmp    $0x20,%al
  800ca7:	74 f9                	je     800ca2 <strtol+0xe>
  800ca9:	3c 09                	cmp    $0x9,%al
  800cab:	74 f5                	je     800ca2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cad:	3c 2b                	cmp    $0x2b,%al
  800caf:	75 08                	jne    800cb9 <strtol+0x25>
		s++;
  800cb1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cb2:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb7:	eb 13                	jmp    800ccc <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cb9:	3c 2d                	cmp    $0x2d,%al
  800cbb:	75 0a                	jne    800cc7 <strtol+0x33>
		s++, neg = 1;
  800cbd:	8d 52 01             	lea    0x1(%edx),%edx
  800cc0:	bf 01 00 00 00       	mov    $0x1,%edi
  800cc5:	eb 05                	jmp    800ccc <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cc7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ccc:	85 db                	test   %ebx,%ebx
  800cce:	74 05                	je     800cd5 <strtol+0x41>
  800cd0:	83 fb 10             	cmp    $0x10,%ebx
  800cd3:	75 28                	jne    800cfd <strtol+0x69>
  800cd5:	8a 02                	mov    (%edx),%al
  800cd7:	3c 30                	cmp    $0x30,%al
  800cd9:	75 10                	jne    800ceb <strtol+0x57>
  800cdb:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cdf:	75 0a                	jne    800ceb <strtol+0x57>
		s += 2, base = 16;
  800ce1:	83 c2 02             	add    $0x2,%edx
  800ce4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce9:	eb 12                	jmp    800cfd <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ceb:	85 db                	test   %ebx,%ebx
  800ced:	75 0e                	jne    800cfd <strtol+0x69>
  800cef:	3c 30                	cmp    $0x30,%al
  800cf1:	75 05                	jne    800cf8 <strtol+0x64>
		s++, base = 8;
  800cf3:	42                   	inc    %edx
  800cf4:	b3 08                	mov    $0x8,%bl
  800cf6:	eb 05                	jmp    800cfd <strtol+0x69>
	else if (base == 0)
		base = 10;
  800cf8:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cfd:	b8 00 00 00 00       	mov    $0x0,%eax
  800d02:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d04:	8a 0a                	mov    (%edx),%cl
  800d06:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d09:	80 fb 09             	cmp    $0x9,%bl
  800d0c:	77 08                	ja     800d16 <strtol+0x82>
			dig = *s - '0';
  800d0e:	0f be c9             	movsbl %cl,%ecx
  800d11:	83 e9 30             	sub    $0x30,%ecx
  800d14:	eb 1e                	jmp    800d34 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d16:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d19:	80 fb 19             	cmp    $0x19,%bl
  800d1c:	77 08                	ja     800d26 <strtol+0x92>
			dig = *s - 'a' + 10;
  800d1e:	0f be c9             	movsbl %cl,%ecx
  800d21:	83 e9 57             	sub    $0x57,%ecx
  800d24:	eb 0e                	jmp    800d34 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d26:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d29:	80 fb 19             	cmp    $0x19,%bl
  800d2c:	77 12                	ja     800d40 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d2e:	0f be c9             	movsbl %cl,%ecx
  800d31:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d34:	39 f1                	cmp    %esi,%ecx
  800d36:	7d 0c                	jge    800d44 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d38:	42                   	inc    %edx
  800d39:	0f af c6             	imul   %esi,%eax
  800d3c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d3e:	eb c4                	jmp    800d04 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d40:	89 c1                	mov    %eax,%ecx
  800d42:	eb 02                	jmp    800d46 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d44:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d46:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d4a:	74 05                	je     800d51 <strtol+0xbd>
		*endptr = (char *) s;
  800d4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d4f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d51:	85 ff                	test   %edi,%edi
  800d53:	74 04                	je     800d59 <strtol+0xc5>
  800d55:	89 c8                	mov    %ecx,%eax
  800d57:	f7 d8                	neg    %eax
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    
	...

00800d60 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d66:	b8 00 00 00 00       	mov    $0x0,%eax
  800d6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d71:	89 c3                	mov    %eax,%ebx
  800d73:	89 c7                	mov    %eax,%edi
  800d75:	89 c6                	mov    %eax,%esi
  800d77:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <sys_cgetc>:

int
sys_cgetc(void)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d84:	ba 00 00 00 00       	mov    $0x0,%edx
  800d89:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8e:	89 d1                	mov    %edx,%ecx
  800d90:	89 d3                	mov    %edx,%ebx
  800d92:	89 d7                	mov    %edx,%edi
  800d94:	89 d6                	mov    %edx,%esi
  800d96:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d98:	5b                   	pop    %ebx
  800d99:	5e                   	pop    %esi
  800d9a:	5f                   	pop    %edi
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    

00800d9d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d9d:	55                   	push   %ebp
  800d9e:	89 e5                	mov    %esp,%ebp
  800da0:	57                   	push   %edi
  800da1:	56                   	push   %esi
  800da2:	53                   	push   %ebx
  800da3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dab:	b8 03 00 00 00       	mov    $0x3,%eax
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	89 cb                	mov    %ecx,%ebx
  800db5:	89 cf                	mov    %ecx,%edi
  800db7:	89 ce                	mov    %ecx,%esi
  800db9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	7e 28                	jle    800de7 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800dca:	00 
  800dcb:	c7 44 24 08 c3 2d 80 	movl   $0x802dc3,0x8(%esp)
  800dd2:	00 
  800dd3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dda:	00 
  800ddb:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  800de2:	e8 b1 f5 ff ff       	call   800398 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800de7:	83 c4 2c             	add    $0x2c,%esp
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	57                   	push   %edi
  800df3:	56                   	push   %esi
  800df4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfa:	b8 02 00 00 00       	mov    $0x2,%eax
  800dff:	89 d1                	mov    %edx,%ecx
  800e01:	89 d3                	mov    %edx,%ebx
  800e03:	89 d7                	mov    %edx,%edi
  800e05:	89 d6                	mov    %edx,%esi
  800e07:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e09:	5b                   	pop    %ebx
  800e0a:	5e                   	pop    %esi
  800e0b:	5f                   	pop    %edi
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_yield>:

void
sys_yield(void)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e14:	ba 00 00 00 00       	mov    $0x0,%edx
  800e19:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e1e:	89 d1                	mov    %edx,%ecx
  800e20:	89 d3                	mov    %edx,%ebx
  800e22:	89 d7                	mov    %edx,%edi
  800e24:	89 d6                	mov    %edx,%esi
  800e26:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e28:	5b                   	pop    %ebx
  800e29:	5e                   	pop    %esi
  800e2a:	5f                   	pop    %edi
  800e2b:	5d                   	pop    %ebp
  800e2c:	c3                   	ret    

00800e2d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
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
  800e36:	be 00 00 00 00       	mov    $0x0,%esi
  800e3b:	b8 04 00 00 00       	mov    $0x4,%eax
  800e40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	89 f7                	mov    %esi,%edi
  800e4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	7e 28                	jle    800e79 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e51:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e55:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 08 c3 2d 80 	movl   $0x802dc3,0x8(%esp)
  800e64:	00 
  800e65:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6c:	00 
  800e6d:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  800e74:	e8 1f f5 ff ff       	call   800398 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e79:	83 c4 2c             	add    $0x2c,%esp
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	57                   	push   %edi
  800e85:	56                   	push   %esi
  800e86:	53                   	push   %ebx
  800e87:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8a:	b8 05 00 00 00       	mov    $0x5,%eax
  800e8f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	7e 28                	jle    800ecc <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800eaf:	00 
  800eb0:	c7 44 24 08 c3 2d 80 	movl   $0x802dc3,0x8(%esp)
  800eb7:	00 
  800eb8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ebf:	00 
  800ec0:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  800ec7:	e8 cc f4 ff ff       	call   800398 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ecc:	83 c4 2c             	add    $0x2c,%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5f                   	pop    %edi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
  800eda:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800edd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ee7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eea:	8b 55 08             	mov    0x8(%ebp),%edx
  800eed:	89 df                	mov    %ebx,%edi
  800eef:	89 de                	mov    %ebx,%esi
  800ef1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	7e 28                	jle    800f1f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800efb:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f02:	00 
  800f03:	c7 44 24 08 c3 2d 80 	movl   $0x802dc3,0x8(%esp)
  800f0a:	00 
  800f0b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f12:	00 
  800f13:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  800f1a:	e8 79 f4 ff ff       	call   800398 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f1f:	83 c4 2c             	add    $0x2c,%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	57                   	push   %edi
  800f2b:	56                   	push   %esi
  800f2c:	53                   	push   %ebx
  800f2d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f35:	b8 08 00 00 00       	mov    $0x8,%eax
  800f3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f40:	89 df                	mov    %ebx,%edi
  800f42:	89 de                	mov    %ebx,%esi
  800f44:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f46:	85 c0                	test   %eax,%eax
  800f48:	7e 28                	jle    800f72 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f55:	00 
  800f56:	c7 44 24 08 c3 2d 80 	movl   $0x802dc3,0x8(%esp)
  800f5d:	00 
  800f5e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f65:	00 
  800f66:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  800f6d:	e8 26 f4 ff ff       	call   800398 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f72:	83 c4 2c             	add    $0x2c,%esp
  800f75:	5b                   	pop    %ebx
  800f76:	5e                   	pop    %esi
  800f77:	5f                   	pop    %edi
  800f78:	5d                   	pop    %ebp
  800f79:	c3                   	ret    

00800f7a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	57                   	push   %edi
  800f7e:	56                   	push   %esi
  800f7f:	53                   	push   %ebx
  800f80:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f88:	b8 09 00 00 00       	mov    $0x9,%eax
  800f8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f90:	8b 55 08             	mov    0x8(%ebp),%edx
  800f93:	89 df                	mov    %ebx,%edi
  800f95:	89 de                	mov    %ebx,%esi
  800f97:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	7e 28                	jle    800fc5 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fa8:	00 
  800fa9:	c7 44 24 08 c3 2d 80 	movl   $0x802dc3,0x8(%esp)
  800fb0:	00 
  800fb1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb8:	00 
  800fb9:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  800fc0:	e8 d3 f3 ff ff       	call   800398 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fc5:	83 c4 2c             	add    $0x2c,%esp
  800fc8:	5b                   	pop    %ebx
  800fc9:	5e                   	pop    %esi
  800fca:	5f                   	pop    %edi
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    

00800fcd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	57                   	push   %edi
  800fd1:	56                   	push   %esi
  800fd2:	53                   	push   %ebx
  800fd3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fdb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fe0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fe3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe6:	89 df                	mov    %ebx,%edi
  800fe8:	89 de                	mov    %ebx,%esi
  800fea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fec:	85 c0                	test   %eax,%eax
  800fee:	7e 28                	jle    801018 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff0:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff4:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800ffb:	00 
  800ffc:	c7 44 24 08 c3 2d 80 	movl   $0x802dc3,0x8(%esp)
  801003:	00 
  801004:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80100b:	00 
  80100c:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  801013:	e8 80 f3 ff ff       	call   800398 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801018:	83 c4 2c             	add    $0x2c,%esp
  80101b:	5b                   	pop    %ebx
  80101c:	5e                   	pop    %esi
  80101d:	5f                   	pop    %edi
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    

00801020 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	57                   	push   %edi
  801024:	56                   	push   %esi
  801025:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801026:	be 00 00 00 00       	mov    $0x0,%esi
  80102b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801030:	8b 7d 14             	mov    0x14(%ebp),%edi
  801033:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801036:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801039:	8b 55 08             	mov    0x8(%ebp),%edx
  80103c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80103e:	5b                   	pop    %ebx
  80103f:	5e                   	pop    %esi
  801040:	5f                   	pop    %edi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    

00801043 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801043:	55                   	push   %ebp
  801044:	89 e5                	mov    %esp,%ebp
  801046:	57                   	push   %edi
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
  801049:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801051:	b8 0d 00 00 00       	mov    $0xd,%eax
  801056:	8b 55 08             	mov    0x8(%ebp),%edx
  801059:	89 cb                	mov    %ecx,%ebx
  80105b:	89 cf                	mov    %ecx,%edi
  80105d:	89 ce                	mov    %ecx,%esi
  80105f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801061:	85 c0                	test   %eax,%eax
  801063:	7e 28                	jle    80108d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801065:	89 44 24 10          	mov    %eax,0x10(%esp)
  801069:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801070:	00 
  801071:	c7 44 24 08 c3 2d 80 	movl   $0x802dc3,0x8(%esp)
  801078:	00 
  801079:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801080:	00 
  801081:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  801088:	e8 0b f3 ff ff       	call   800398 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80108d:	83 c4 2c             	add    $0x2c,%esp
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109b:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010a5:	89 d1                	mov    %edx,%ecx
  8010a7:	89 d3                	mov    %edx,%ebx
  8010a9:	89 d7                	mov    %edx,%edi
  8010ab:	89 d6                	mov    %edx,%esi
  8010ad:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8010af:	5b                   	pop    %ebx
  8010b0:	5e                   	pop    %esi
  8010b1:	5f                   	pop    %edi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010bf:	b8 0f 00 00 00       	mov    $0xf,%eax
  8010c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ca:	89 df                	mov    %ebx,%edi
  8010cc:	89 de                	mov    %ebx,%esi
  8010ce:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  8010d0:	5b                   	pop    %ebx
  8010d1:	5e                   	pop    %esi
  8010d2:	5f                   	pop    %edi
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	57                   	push   %edi
  8010d9:	56                   	push   %esi
  8010da:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e0:	b8 10 00 00 00       	mov    $0x10,%eax
  8010e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010eb:	89 df                	mov    %ebx,%edi
  8010ed:	89 de                	mov    %ebx,%esi
  8010ef:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  8010f1:	5b                   	pop    %ebx
  8010f2:	5e                   	pop    %esi
  8010f3:	5f                   	pop    %edi
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    
	...

008010f8 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801101:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801104:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801106:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801109:	83 3a 01             	cmpl   $0x1,(%edx)
  80110c:	7e 0b                	jle    801119 <argstart+0x21>
  80110e:	85 c9                	test   %ecx,%ecx
  801110:	75 0e                	jne    801120 <argstart+0x28>
  801112:	ba 00 00 00 00       	mov    $0x0,%edx
  801117:	eb 0c                	jmp    801125 <argstart+0x2d>
  801119:	ba 00 00 00 00       	mov    $0x0,%edx
  80111e:	eb 05                	jmp    801125 <argstart+0x2d>
  801120:	ba 68 2a 80 00       	mov    $0x802a68,%edx
  801125:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801128:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <argnext>:

int
argnext(struct Argstate *args)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	53                   	push   %ebx
  801135:	83 ec 14             	sub    $0x14,%esp
  801138:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  80113b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801142:	8b 43 08             	mov    0x8(%ebx),%eax
  801145:	85 c0                	test   %eax,%eax
  801147:	74 6c                	je     8011b5 <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  801149:	80 38 00             	cmpb   $0x0,(%eax)
  80114c:	75 4d                	jne    80119b <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  80114e:	8b 0b                	mov    (%ebx),%ecx
  801150:	83 39 01             	cmpl   $0x1,(%ecx)
  801153:	74 52                	je     8011a7 <argnext+0x76>
		    || args->argv[1][0] != '-'
  801155:	8b 53 04             	mov    0x4(%ebx),%edx
  801158:	8b 42 04             	mov    0x4(%edx),%eax
  80115b:	80 38 2d             	cmpb   $0x2d,(%eax)
  80115e:	75 47                	jne    8011a7 <argnext+0x76>
		    || args->argv[1][1] == '\0')
  801160:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801164:	74 41                	je     8011a7 <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801166:	40                   	inc    %eax
  801167:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80116a:	8b 01                	mov    (%ecx),%eax
  80116c:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801173:	89 44 24 08          	mov    %eax,0x8(%esp)
  801177:	8d 42 08             	lea    0x8(%edx),%eax
  80117a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117e:	83 c2 04             	add    $0x4,%edx
  801181:	89 14 24             	mov    %edx,(%esp)
  801184:	e8 2b fa ff ff       	call   800bb4 <memmove>
		(*args->argc)--;
  801189:	8b 03                	mov    (%ebx),%eax
  80118b:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  80118d:	8b 43 08             	mov    0x8(%ebx),%eax
  801190:	80 38 2d             	cmpb   $0x2d,(%eax)
  801193:	75 06                	jne    80119b <argnext+0x6a>
  801195:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801199:	74 0c                	je     8011a7 <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  80119b:	8b 53 08             	mov    0x8(%ebx),%edx
  80119e:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  8011a1:	42                   	inc    %edx
  8011a2:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  8011a5:	eb 13                	jmp    8011ba <argnext+0x89>

    endofargs:
	args->curarg = 0;
  8011a7:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  8011ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011b3:	eb 05                	jmp    8011ba <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  8011b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  8011ba:	83 c4 14             	add    $0x14,%esp
  8011bd:	5b                   	pop    %ebx
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 14             	sub    $0x14,%esp
  8011c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  8011ca:	8b 43 08             	mov    0x8(%ebx),%eax
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	74 59                	je     80122a <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  8011d1:	80 38 00             	cmpb   $0x0,(%eax)
  8011d4:	74 0c                	je     8011e2 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  8011d6:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  8011d9:	c7 43 08 68 2a 80 00 	movl   $0x802a68,0x8(%ebx)
  8011e0:	eb 43                	jmp    801225 <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  8011e2:	8b 03                	mov    (%ebx),%eax
  8011e4:	83 38 01             	cmpl   $0x1,(%eax)
  8011e7:	7e 2e                	jle    801217 <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  8011e9:	8b 53 04             	mov    0x4(%ebx),%edx
  8011ec:	8b 4a 04             	mov    0x4(%edx),%ecx
  8011ef:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  8011f2:	8b 00                	mov    (%eax),%eax
  8011f4:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  8011fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011ff:	8d 42 08             	lea    0x8(%edx),%eax
  801202:	89 44 24 04          	mov    %eax,0x4(%esp)
  801206:	83 c2 04             	add    $0x4,%edx
  801209:	89 14 24             	mov    %edx,(%esp)
  80120c:	e8 a3 f9 ff ff       	call   800bb4 <memmove>
		(*args->argc)--;
  801211:	8b 03                	mov    (%ebx),%eax
  801213:	ff 08                	decl   (%eax)
  801215:	eb 0e                	jmp    801225 <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  801217:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  80121e:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801225:	8b 43 0c             	mov    0xc(%ebx),%eax
  801228:	eb 05                	jmp    80122f <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  80122a:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  80122f:	83 c4 14             	add    $0x14,%esp
  801232:	5b                   	pop    %ebx
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    

00801235 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801235:	55                   	push   %ebp
  801236:	89 e5                	mov    %esp,%ebp
  801238:	83 ec 18             	sub    $0x18,%esp
  80123b:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  80123e:	8b 42 0c             	mov    0xc(%edx),%eax
  801241:	85 c0                	test   %eax,%eax
  801243:	75 08                	jne    80124d <argvalue+0x18>
  801245:	89 14 24             	mov    %edx,(%esp)
  801248:	e8 73 ff ff ff       	call   8011c0 <argnextvalue>
}
  80124d:	c9                   	leave  
  80124e:	c3                   	ret    
	...

00801250 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801253:	8b 45 08             	mov    0x8(%ebp),%eax
  801256:	05 00 00 00 30       	add    $0x30000000,%eax
  80125b:	c1 e8 0c             	shr    $0xc,%eax
}
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    

00801260 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801266:	8b 45 08             	mov    0x8(%ebp),%eax
  801269:	89 04 24             	mov    %eax,(%esp)
  80126c:	e8 df ff ff ff       	call   801250 <fd2num>
  801271:	c1 e0 0c             	shl    $0xc,%eax
  801274:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801279:	c9                   	leave  
  80127a:	c3                   	ret    

0080127b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	53                   	push   %ebx
  80127f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801282:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801287:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801289:	89 c2                	mov    %eax,%edx
  80128b:	c1 ea 16             	shr    $0x16,%edx
  80128e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801295:	f6 c2 01             	test   $0x1,%dl
  801298:	74 11                	je     8012ab <fd_alloc+0x30>
  80129a:	89 c2                	mov    %eax,%edx
  80129c:	c1 ea 0c             	shr    $0xc,%edx
  80129f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a6:	f6 c2 01             	test   $0x1,%dl
  8012a9:	75 09                	jne    8012b4 <fd_alloc+0x39>
			*fd_store = fd;
  8012ab:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8012ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b2:	eb 17                	jmp    8012cb <fd_alloc+0x50>
  8012b4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012be:	75 c7                	jne    801287 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8012c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012cb:	5b                   	pop    %ebx
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012d4:	83 f8 1f             	cmp    $0x1f,%eax
  8012d7:	77 36                	ja     80130f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012d9:	c1 e0 0c             	shl    $0xc,%eax
  8012dc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012e1:	89 c2                	mov    %eax,%edx
  8012e3:	c1 ea 16             	shr    $0x16,%edx
  8012e6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ed:	f6 c2 01             	test   $0x1,%dl
  8012f0:	74 24                	je     801316 <fd_lookup+0x48>
  8012f2:	89 c2                	mov    %eax,%edx
  8012f4:	c1 ea 0c             	shr    $0xc,%edx
  8012f7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012fe:	f6 c2 01             	test   $0x1,%dl
  801301:	74 1a                	je     80131d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801303:	8b 55 0c             	mov    0xc(%ebp),%edx
  801306:	89 02                	mov    %eax,(%edx)
	return 0;
  801308:	b8 00 00 00 00       	mov    $0x0,%eax
  80130d:	eb 13                	jmp    801322 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80130f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801314:	eb 0c                	jmp    801322 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801316:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80131b:	eb 05                	jmp    801322 <fd_lookup+0x54>
  80131d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801322:	5d                   	pop    %ebp
  801323:	c3                   	ret    

00801324 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801324:	55                   	push   %ebp
  801325:	89 e5                	mov    %esp,%ebp
  801327:	53                   	push   %ebx
  801328:	83 ec 14             	sub    $0x14,%esp
  80132b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801331:	ba 00 00 00 00       	mov    $0x0,%edx
  801336:	eb 0e                	jmp    801346 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801338:	39 08                	cmp    %ecx,(%eax)
  80133a:	75 09                	jne    801345 <dev_lookup+0x21>
			*dev = devtab[i];
  80133c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80133e:	b8 00 00 00 00       	mov    $0x0,%eax
  801343:	eb 33                	jmp    801378 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801345:	42                   	inc    %edx
  801346:	8b 04 95 70 2e 80 00 	mov    0x802e70(,%edx,4),%eax
  80134d:	85 c0                	test   %eax,%eax
  80134f:	75 e7                	jne    801338 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801351:	a1 20 44 80 00       	mov    0x804420,%eax
  801356:	8b 40 48             	mov    0x48(%eax),%eax
  801359:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80135d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801361:	c7 04 24 f0 2d 80 00 	movl   $0x802df0,(%esp)
  801368:	e8 23 f1 ff ff       	call   800490 <cprintf>
	*dev = 0;
  80136d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801373:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801378:	83 c4 14             	add    $0x14,%esp
  80137b:	5b                   	pop    %ebx
  80137c:	5d                   	pop    %ebp
  80137d:	c3                   	ret    

0080137e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80137e:	55                   	push   %ebp
  80137f:	89 e5                	mov    %esp,%ebp
  801381:	56                   	push   %esi
  801382:	53                   	push   %ebx
  801383:	83 ec 30             	sub    $0x30,%esp
  801386:	8b 75 08             	mov    0x8(%ebp),%esi
  801389:	8a 45 0c             	mov    0xc(%ebp),%al
  80138c:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80138f:	89 34 24             	mov    %esi,(%esp)
  801392:	e8 b9 fe ff ff       	call   801250 <fd2num>
  801397:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80139a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80139e:	89 04 24             	mov    %eax,(%esp)
  8013a1:	e8 28 ff ff ff       	call   8012ce <fd_lookup>
  8013a6:	89 c3                	mov    %eax,%ebx
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	78 05                	js     8013b1 <fd_close+0x33>
	    || fd != fd2)
  8013ac:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013af:	74 0d                	je     8013be <fd_close+0x40>
		return (must_exist ? r : 0);
  8013b1:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8013b5:	75 46                	jne    8013fd <fd_close+0x7f>
  8013b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013bc:	eb 3f                	jmp    8013fd <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c5:	8b 06                	mov    (%esi),%eax
  8013c7:	89 04 24             	mov    %eax,(%esp)
  8013ca:	e8 55 ff ff ff       	call   801324 <dev_lookup>
  8013cf:	89 c3                	mov    %eax,%ebx
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	78 18                	js     8013ed <fd_close+0x6f>
		if (dev->dev_close)
  8013d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d8:	8b 40 10             	mov    0x10(%eax),%eax
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	74 09                	je     8013e8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013df:	89 34 24             	mov    %esi,(%esp)
  8013e2:	ff d0                	call   *%eax
  8013e4:	89 c3                	mov    %eax,%ebx
  8013e6:	eb 05                	jmp    8013ed <fd_close+0x6f>
		else
			r = 0;
  8013e8:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013f8:	e8 d7 fa ff ff       	call   800ed4 <sys_page_unmap>
	return r;
}
  8013fd:	89 d8                	mov    %ebx,%eax
  8013ff:	83 c4 30             	add    $0x30,%esp
  801402:	5b                   	pop    %ebx
  801403:	5e                   	pop    %esi
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    

00801406 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80140c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801413:	8b 45 08             	mov    0x8(%ebp),%eax
  801416:	89 04 24             	mov    %eax,(%esp)
  801419:	e8 b0 fe ff ff       	call   8012ce <fd_lookup>
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 13                	js     801435 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801422:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801429:	00 
  80142a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142d:	89 04 24             	mov    %eax,(%esp)
  801430:	e8 49 ff ff ff       	call   80137e <fd_close>
}
  801435:	c9                   	leave  
  801436:	c3                   	ret    

00801437 <close_all>:

void
close_all(void)
{
  801437:	55                   	push   %ebp
  801438:	89 e5                	mov    %esp,%ebp
  80143a:	53                   	push   %ebx
  80143b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80143e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801443:	89 1c 24             	mov    %ebx,(%esp)
  801446:	e8 bb ff ff ff       	call   801406 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80144b:	43                   	inc    %ebx
  80144c:	83 fb 20             	cmp    $0x20,%ebx
  80144f:	75 f2                	jne    801443 <close_all+0xc>
		close(i);
}
  801451:	83 c4 14             	add    $0x14,%esp
  801454:	5b                   	pop    %ebx
  801455:	5d                   	pop    %ebp
  801456:	c3                   	ret    

00801457 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	57                   	push   %edi
  80145b:	56                   	push   %esi
  80145c:	53                   	push   %ebx
  80145d:	83 ec 4c             	sub    $0x4c,%esp
  801460:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801463:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801466:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146a:	8b 45 08             	mov    0x8(%ebp),%eax
  80146d:	89 04 24             	mov    %eax,(%esp)
  801470:	e8 59 fe ff ff       	call   8012ce <fd_lookup>
  801475:	89 c3                	mov    %eax,%ebx
  801477:	85 c0                	test   %eax,%eax
  801479:	0f 88 e3 00 00 00    	js     801562 <dup+0x10b>
		return r;
	close(newfdnum);
  80147f:	89 3c 24             	mov    %edi,(%esp)
  801482:	e8 7f ff ff ff       	call   801406 <close>

	newfd = INDEX2FD(newfdnum);
  801487:	89 fe                	mov    %edi,%esi
  801489:	c1 e6 0c             	shl    $0xc,%esi
  80148c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801492:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801495:	89 04 24             	mov    %eax,(%esp)
  801498:	e8 c3 fd ff ff       	call   801260 <fd2data>
  80149d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80149f:	89 34 24             	mov    %esi,(%esp)
  8014a2:	e8 b9 fd ff ff       	call   801260 <fd2data>
  8014a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014aa:	89 d8                	mov    %ebx,%eax
  8014ac:	c1 e8 16             	shr    $0x16,%eax
  8014af:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014b6:	a8 01                	test   $0x1,%al
  8014b8:	74 46                	je     801500 <dup+0xa9>
  8014ba:	89 d8                	mov    %ebx,%eax
  8014bc:	c1 e8 0c             	shr    $0xc,%eax
  8014bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014c6:	f6 c2 01             	test   $0x1,%dl
  8014c9:	74 35                	je     801500 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d2:	25 07 0e 00 00       	and    $0xe07,%eax
  8014d7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8014de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014e2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014e9:	00 
  8014ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014ee:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f5:	e8 87 f9 ff ff       	call   800e81 <sys_page_map>
  8014fa:	89 c3                	mov    %eax,%ebx
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	78 3b                	js     80153b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801500:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801503:	89 c2                	mov    %eax,%edx
  801505:	c1 ea 0c             	shr    $0xc,%edx
  801508:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80150f:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801515:	89 54 24 10          	mov    %edx,0x10(%esp)
  801519:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80151d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801524:	00 
  801525:	89 44 24 04          	mov    %eax,0x4(%esp)
  801529:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801530:	e8 4c f9 ff ff       	call   800e81 <sys_page_map>
  801535:	89 c3                	mov    %eax,%ebx
  801537:	85 c0                	test   %eax,%eax
  801539:	79 25                	jns    801560 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80153b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80153f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801546:	e8 89 f9 ff ff       	call   800ed4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80154b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80154e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801552:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801559:	e8 76 f9 ff ff       	call   800ed4 <sys_page_unmap>
	return r;
  80155e:	eb 02                	jmp    801562 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801560:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801562:	89 d8                	mov    %ebx,%eax
  801564:	83 c4 4c             	add    $0x4c,%esp
  801567:	5b                   	pop    %ebx
  801568:	5e                   	pop    %esi
  801569:	5f                   	pop    %edi
  80156a:	5d                   	pop    %ebp
  80156b:	c3                   	ret    

0080156c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	53                   	push   %ebx
  801570:	83 ec 24             	sub    $0x24,%esp
  801573:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801576:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801579:	89 44 24 04          	mov    %eax,0x4(%esp)
  80157d:	89 1c 24             	mov    %ebx,(%esp)
  801580:	e8 49 fd ff ff       	call   8012ce <fd_lookup>
  801585:	85 c0                	test   %eax,%eax
  801587:	78 6d                	js     8015f6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801589:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801590:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801593:	8b 00                	mov    (%eax),%eax
  801595:	89 04 24             	mov    %eax,(%esp)
  801598:	e8 87 fd ff ff       	call   801324 <dev_lookup>
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 55                	js     8015f6 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a4:	8b 50 08             	mov    0x8(%eax),%edx
  8015a7:	83 e2 03             	and    $0x3,%edx
  8015aa:	83 fa 01             	cmp    $0x1,%edx
  8015ad:	75 23                	jne    8015d2 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015af:	a1 20 44 80 00       	mov    0x804420,%eax
  8015b4:	8b 40 48             	mov    0x48(%eax),%eax
  8015b7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bf:	c7 04 24 34 2e 80 00 	movl   $0x802e34,(%esp)
  8015c6:	e8 c5 ee ff ff       	call   800490 <cprintf>
		return -E_INVAL;
  8015cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d0:	eb 24                	jmp    8015f6 <read+0x8a>
	}
	if (!dev->dev_read)
  8015d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d5:	8b 52 08             	mov    0x8(%edx),%edx
  8015d8:	85 d2                	test   %edx,%edx
  8015da:	74 15                	je     8015f1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015df:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8015e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015e6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8015ea:	89 04 24             	mov    %eax,(%esp)
  8015ed:	ff d2                	call   *%edx
  8015ef:	eb 05                	jmp    8015f6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8015f6:	83 c4 24             	add    $0x24,%esp
  8015f9:	5b                   	pop    %ebx
  8015fa:	5d                   	pop    %ebp
  8015fb:	c3                   	ret    

008015fc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	57                   	push   %edi
  801600:	56                   	push   %esi
  801601:	53                   	push   %ebx
  801602:	83 ec 1c             	sub    $0x1c,%esp
  801605:	8b 7d 08             	mov    0x8(%ebp),%edi
  801608:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80160b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801610:	eb 23                	jmp    801635 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801612:	89 f0                	mov    %esi,%eax
  801614:	29 d8                	sub    %ebx,%eax
  801616:	89 44 24 08          	mov    %eax,0x8(%esp)
  80161a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161d:	01 d8                	add    %ebx,%eax
  80161f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801623:	89 3c 24             	mov    %edi,(%esp)
  801626:	e8 41 ff ff ff       	call   80156c <read>
		if (m < 0)
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 10                	js     80163f <readn+0x43>
			return m;
		if (m == 0)
  80162f:	85 c0                	test   %eax,%eax
  801631:	74 0a                	je     80163d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801633:	01 c3                	add    %eax,%ebx
  801635:	39 f3                	cmp    %esi,%ebx
  801637:	72 d9                	jb     801612 <readn+0x16>
  801639:	89 d8                	mov    %ebx,%eax
  80163b:	eb 02                	jmp    80163f <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80163d:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80163f:	83 c4 1c             	add    $0x1c,%esp
  801642:	5b                   	pop    %ebx
  801643:	5e                   	pop    %esi
  801644:	5f                   	pop    %edi
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    

00801647 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	53                   	push   %ebx
  80164b:	83 ec 24             	sub    $0x24,%esp
  80164e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801651:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801654:	89 44 24 04          	mov    %eax,0x4(%esp)
  801658:	89 1c 24             	mov    %ebx,(%esp)
  80165b:	e8 6e fc ff ff       	call   8012ce <fd_lookup>
  801660:	85 c0                	test   %eax,%eax
  801662:	78 68                	js     8016cc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801664:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801667:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166e:	8b 00                	mov    (%eax),%eax
  801670:	89 04 24             	mov    %eax,(%esp)
  801673:	e8 ac fc ff ff       	call   801324 <dev_lookup>
  801678:	85 c0                	test   %eax,%eax
  80167a:	78 50                	js     8016cc <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801683:	75 23                	jne    8016a8 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801685:	a1 20 44 80 00       	mov    0x804420,%eax
  80168a:	8b 40 48             	mov    0x48(%eax),%eax
  80168d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801691:	89 44 24 04          	mov    %eax,0x4(%esp)
  801695:	c7 04 24 50 2e 80 00 	movl   $0x802e50,(%esp)
  80169c:	e8 ef ed ff ff       	call   800490 <cprintf>
		return -E_INVAL;
  8016a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016a6:	eb 24                	jmp    8016cc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ab:	8b 52 0c             	mov    0xc(%edx),%edx
  8016ae:	85 d2                	test   %edx,%edx
  8016b0:	74 15                	je     8016c7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016b5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016c0:	89 04 24             	mov    %eax,(%esp)
  8016c3:	ff d2                	call   *%edx
  8016c5:	eb 05                	jmp    8016cc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016c7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8016cc:	83 c4 24             	add    $0x24,%esp
  8016cf:	5b                   	pop    %ebx
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    

008016d2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016d8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016df:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e2:	89 04 24             	mov    %eax,(%esp)
  8016e5:	e8 e4 fb ff ff       	call   8012ce <fd_lookup>
  8016ea:	85 c0                	test   %eax,%eax
  8016ec:	78 0e                	js     8016fc <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	53                   	push   %ebx
  801702:	83 ec 24             	sub    $0x24,%esp
  801705:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801708:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80170b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170f:	89 1c 24             	mov    %ebx,(%esp)
  801712:	e8 b7 fb ff ff       	call   8012ce <fd_lookup>
  801717:	85 c0                	test   %eax,%eax
  801719:	78 61                	js     80177c <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801722:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801725:	8b 00                	mov    (%eax),%eax
  801727:	89 04 24             	mov    %eax,(%esp)
  80172a:	e8 f5 fb ff ff       	call   801324 <dev_lookup>
  80172f:	85 c0                	test   %eax,%eax
  801731:	78 49                	js     80177c <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801733:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801736:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80173a:	75 23                	jne    80175f <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80173c:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801741:	8b 40 48             	mov    0x48(%eax),%eax
  801744:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801748:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174c:	c7 04 24 10 2e 80 00 	movl   $0x802e10,(%esp)
  801753:	e8 38 ed ff ff       	call   800490 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801758:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80175d:	eb 1d                	jmp    80177c <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80175f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801762:	8b 52 18             	mov    0x18(%edx),%edx
  801765:	85 d2                	test   %edx,%edx
  801767:	74 0e                	je     801777 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801769:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80176c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801770:	89 04 24             	mov    %eax,(%esp)
  801773:	ff d2                	call   *%edx
  801775:	eb 05                	jmp    80177c <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801777:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80177c:	83 c4 24             	add    $0x24,%esp
  80177f:	5b                   	pop    %ebx
  801780:	5d                   	pop    %ebp
  801781:	c3                   	ret    

00801782 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	53                   	push   %ebx
  801786:	83 ec 24             	sub    $0x24,%esp
  801789:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80178c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80178f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801793:	8b 45 08             	mov    0x8(%ebp),%eax
  801796:	89 04 24             	mov    %eax,(%esp)
  801799:	e8 30 fb ff ff       	call   8012ce <fd_lookup>
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	78 52                	js     8017f4 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ac:	8b 00                	mov    (%eax),%eax
  8017ae:	89 04 24             	mov    %eax,(%esp)
  8017b1:	e8 6e fb ff ff       	call   801324 <dev_lookup>
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	78 3a                	js     8017f4 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8017ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017bd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017c1:	74 2c                	je     8017ef <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017c3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017c6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017cd:	00 00 00 
	stat->st_isdir = 0;
  8017d0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017d7:	00 00 00 
	stat->st_dev = dev;
  8017da:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017e7:	89 14 24             	mov    %edx,(%esp)
  8017ea:	ff 50 14             	call   *0x14(%eax)
  8017ed:	eb 05                	jmp    8017f4 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017ef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017f4:	83 c4 24             	add    $0x24,%esp
  8017f7:	5b                   	pop    %ebx
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    

008017fa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	56                   	push   %esi
  8017fe:	53                   	push   %ebx
  8017ff:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801802:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801809:	00 
  80180a:	8b 45 08             	mov    0x8(%ebp),%eax
  80180d:	89 04 24             	mov    %eax,(%esp)
  801810:	e8 2a 02 00 00       	call   801a3f <open>
  801815:	89 c3                	mov    %eax,%ebx
  801817:	85 c0                	test   %eax,%eax
  801819:	78 1b                	js     801836 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80181b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801822:	89 1c 24             	mov    %ebx,(%esp)
  801825:	e8 58 ff ff ff       	call   801782 <fstat>
  80182a:	89 c6                	mov    %eax,%esi
	close(fd);
  80182c:	89 1c 24             	mov    %ebx,(%esp)
  80182f:	e8 d2 fb ff ff       	call   801406 <close>
	return r;
  801834:	89 f3                	mov    %esi,%ebx
}
  801836:	89 d8                	mov    %ebx,%eax
  801838:	83 c4 10             	add    $0x10,%esp
  80183b:	5b                   	pop    %ebx
  80183c:	5e                   	pop    %esi
  80183d:	5d                   	pop    %ebp
  80183e:	c3                   	ret    
	...

00801840 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	56                   	push   %esi
  801844:	53                   	push   %ebx
  801845:	83 ec 10             	sub    $0x10,%esp
  801848:	89 c3                	mov    %eax,%ebx
  80184a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80184c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801853:	75 11                	jne    801866 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801855:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80185c:	e8 be 0e 00 00       	call   80271f <ipc_find_env>
  801861:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801866:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80186d:	00 
  80186e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801875:	00 
  801876:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80187a:	a1 00 40 80 00       	mov    0x804000,%eax
  80187f:	89 04 24             	mov    %eax,(%esp)
  801882:	e8 15 0e 00 00       	call   80269c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801887:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80188e:	00 
  80188f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801893:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80189a:	e8 8d 0d 00 00       	call   80262c <ipc_recv>
}
  80189f:	83 c4 10             	add    $0x10,%esp
  8018a2:	5b                   	pop    %ebx
  8018a3:	5e                   	pop    %esi
  8018a4:	5d                   	pop    %ebp
  8018a5:	c3                   	ret    

008018a6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8018af:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ba:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8018c9:	e8 72 ff ff ff       	call   801840 <fsipc>
}
  8018ce:	c9                   	leave  
  8018cf:	c3                   	ret    

008018d0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018dc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8018eb:	e8 50 ff ff ff       	call   801840 <fsipc>
}
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    

008018f2 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	53                   	push   %ebx
  8018f6:	83 ec 14             	sub    $0x14,%esp
  8018f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801902:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801907:	ba 00 00 00 00       	mov    $0x0,%edx
  80190c:	b8 05 00 00 00       	mov    $0x5,%eax
  801911:	e8 2a ff ff ff       	call   801840 <fsipc>
  801916:	85 c0                	test   %eax,%eax
  801918:	78 2b                	js     801945 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80191a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801921:	00 
  801922:	89 1c 24             	mov    %ebx,(%esp)
  801925:	e8 11 f1 ff ff       	call   800a3b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80192a:	a1 80 50 80 00       	mov    0x805080,%eax
  80192f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801935:	a1 84 50 80 00       	mov    0x805084,%eax
  80193a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801940:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801945:	83 c4 14             	add    $0x14,%esp
  801948:	5b                   	pop    %ebx
  801949:	5d                   	pop    %ebp
  80194a:	c3                   	ret    

0080194b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	83 ec 18             	sub    $0x18,%esp
  801951:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801954:	8b 55 08             	mov    0x8(%ebp),%edx
  801957:	8b 52 0c             	mov    0xc(%edx),%edx
  80195a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801960:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801965:	89 c2                	mov    %eax,%edx
  801967:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80196c:	76 05                	jbe    801973 <devfile_write+0x28>
  80196e:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801973:	89 54 24 08          	mov    %edx,0x8(%esp)
  801977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197e:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801985:	e8 94 f2 ff ff       	call   800c1e <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80198a:	ba 00 00 00 00       	mov    $0x0,%edx
  80198f:	b8 04 00 00 00       	mov    $0x4,%eax
  801994:	e8 a7 fe ff ff       	call   801840 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801999:	c9                   	leave  
  80199a:	c3                   	ret    

0080199b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	56                   	push   %esi
  80199f:	53                   	push   %ebx
  8019a0:	83 ec 10             	sub    $0x10,%esp
  8019a3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ac:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019b1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bc:	b8 03 00 00 00       	mov    $0x3,%eax
  8019c1:	e8 7a fe ff ff       	call   801840 <fsipc>
  8019c6:	89 c3                	mov    %eax,%ebx
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	78 6a                	js     801a36 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8019cc:	39 c6                	cmp    %eax,%esi
  8019ce:	73 24                	jae    8019f4 <devfile_read+0x59>
  8019d0:	c7 44 24 0c 84 2e 80 	movl   $0x802e84,0xc(%esp)
  8019d7:	00 
  8019d8:	c7 44 24 08 8b 2e 80 	movl   $0x802e8b,0x8(%esp)
  8019df:	00 
  8019e0:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8019e7:	00 
  8019e8:	c7 04 24 a0 2e 80 00 	movl   $0x802ea0,(%esp)
  8019ef:	e8 a4 e9 ff ff       	call   800398 <_panic>
	assert(r <= PGSIZE);
  8019f4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019f9:	7e 24                	jle    801a1f <devfile_read+0x84>
  8019fb:	c7 44 24 0c ab 2e 80 	movl   $0x802eab,0xc(%esp)
  801a02:	00 
  801a03:	c7 44 24 08 8b 2e 80 	movl   $0x802e8b,0x8(%esp)
  801a0a:	00 
  801a0b:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801a12:	00 
  801a13:	c7 04 24 a0 2e 80 00 	movl   $0x802ea0,(%esp)
  801a1a:	e8 79 e9 ff ff       	call   800398 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a23:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a2a:	00 
  801a2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2e:	89 04 24             	mov    %eax,(%esp)
  801a31:	e8 7e f1 ff ff       	call   800bb4 <memmove>
	return r;
}
  801a36:	89 d8                	mov    %ebx,%eax
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	5b                   	pop    %ebx
  801a3c:	5e                   	pop    %esi
  801a3d:	5d                   	pop    %ebp
  801a3e:	c3                   	ret    

00801a3f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	56                   	push   %esi
  801a43:	53                   	push   %ebx
  801a44:	83 ec 20             	sub    $0x20,%esp
  801a47:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a4a:	89 34 24             	mov    %esi,(%esp)
  801a4d:	e8 b6 ef ff ff       	call   800a08 <strlen>
  801a52:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a57:	7f 60                	jg     801ab9 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5c:	89 04 24             	mov    %eax,(%esp)
  801a5f:	e8 17 f8 ff ff       	call   80127b <fd_alloc>
  801a64:	89 c3                	mov    %eax,%ebx
  801a66:	85 c0                	test   %eax,%eax
  801a68:	78 54                	js     801abe <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a6e:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a75:	e8 c1 ef ff ff       	call   800a3b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a82:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a85:	b8 01 00 00 00       	mov    $0x1,%eax
  801a8a:	e8 b1 fd ff ff       	call   801840 <fsipc>
  801a8f:	89 c3                	mov    %eax,%ebx
  801a91:	85 c0                	test   %eax,%eax
  801a93:	79 15                	jns    801aaa <open+0x6b>
		fd_close(fd, 0);
  801a95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a9c:	00 
  801a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa0:	89 04 24             	mov    %eax,(%esp)
  801aa3:	e8 d6 f8 ff ff       	call   80137e <fd_close>
		return r;
  801aa8:	eb 14                	jmp    801abe <open+0x7f>
	}

	return fd2num(fd);
  801aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aad:	89 04 24             	mov    %eax,(%esp)
  801ab0:	e8 9b f7 ff ff       	call   801250 <fd2num>
  801ab5:	89 c3                	mov    %eax,%ebx
  801ab7:	eb 05                	jmp    801abe <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ab9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801abe:	89 d8                	mov    %ebx,%eax
  801ac0:	83 c4 20             	add    $0x20,%esp
  801ac3:	5b                   	pop    %ebx
  801ac4:	5e                   	pop    %esi
  801ac5:	5d                   	pop    %ebp
  801ac6:	c3                   	ret    

00801ac7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801acd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad2:	b8 08 00 00 00       	mov    $0x8,%eax
  801ad7:	e8 64 fd ff ff       	call   801840 <fsipc>
}
  801adc:	c9                   	leave  
  801add:	c3                   	ret    
	...

00801ae0 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 14             	sub    $0x14,%esp
  801ae7:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  801ae9:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801aed:	7e 32                	jle    801b21 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  801aef:	8b 40 04             	mov    0x4(%eax),%eax
  801af2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af6:	8d 43 10             	lea    0x10(%ebx),%eax
  801af9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afd:	8b 03                	mov    (%ebx),%eax
  801aff:	89 04 24             	mov    %eax,(%esp)
  801b02:	e8 40 fb ff ff       	call   801647 <write>
		if (result > 0)
  801b07:	85 c0                	test   %eax,%eax
  801b09:	7e 03                	jle    801b0e <writebuf+0x2e>
			b->result += result;
  801b0b:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801b0e:	39 43 04             	cmp    %eax,0x4(%ebx)
  801b11:	74 0e                	je     801b21 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  801b13:	89 c2                	mov    %eax,%edx
  801b15:	85 c0                	test   %eax,%eax
  801b17:	7e 05                	jle    801b1e <writebuf+0x3e>
  801b19:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1e:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  801b21:	83 c4 14             	add    $0x14,%esp
  801b24:	5b                   	pop    %ebx
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <putch>:

static void
putch(int ch, void *thunk)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	53                   	push   %ebx
  801b2b:	83 ec 04             	sub    $0x4,%esp
  801b2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801b31:	8b 43 04             	mov    0x4(%ebx),%eax
  801b34:	8b 55 08             	mov    0x8(%ebp),%edx
  801b37:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  801b3b:	40                   	inc    %eax
  801b3c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  801b3f:	3d 00 01 00 00       	cmp    $0x100,%eax
  801b44:	75 0e                	jne    801b54 <putch+0x2d>
		writebuf(b);
  801b46:	89 d8                	mov    %ebx,%eax
  801b48:	e8 93 ff ff ff       	call   801ae0 <writebuf>
		b->idx = 0;
  801b4d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  801b54:	83 c4 04             	add    $0x4,%esp
  801b57:	5b                   	pop    %ebx
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    

00801b5a <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  801b63:	8b 45 08             	mov    0x8(%ebp),%eax
  801b66:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801b6c:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  801b73:	00 00 00 
	b.result = 0;
  801b76:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801b7d:	00 00 00 
	b.error = 1;
  801b80:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801b87:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  801b8a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b91:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b94:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b98:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba2:	c7 04 24 27 1b 80 00 	movl   $0x801b27,(%esp)
  801ba9:	e8 44 ea ff ff       	call   8005f2 <vprintfmt>
	if (b.idx > 0)
  801bae:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801bb5:	7e 0b                	jle    801bc2 <vfprintf+0x68>
		writebuf(&b);
  801bb7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801bbd:	e8 1e ff ff ff       	call   801ae0 <writebuf>

	return (b.result ? b.result : b.error);
  801bc2:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801bc8:	85 c0                	test   %eax,%eax
  801bca:	75 06                	jne    801bd2 <vfprintf+0x78>
  801bcc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  801bd2:	c9                   	leave  
  801bd3:	c3                   	ret    

00801bd4 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801bda:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801bdd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801be1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be8:	8b 45 08             	mov    0x8(%ebp),%eax
  801beb:	89 04 24             	mov    %eax,(%esp)
  801bee:	e8 67 ff ff ff       	call   801b5a <vfprintf>
	va_end(ap);

	return cnt;
}
  801bf3:	c9                   	leave  
  801bf4:	c3                   	ret    

00801bf5 <printf>:

int
printf(const char *fmt, ...)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801bfb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801bfe:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c02:	8b 45 08             	mov    0x8(%ebp),%eax
  801c05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c09:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c10:	e8 45 ff ff ff       	call   801b5a <vfprintf>
	va_end(ap);

	return cnt;
}
  801c15:	c9                   	leave  
  801c16:	c3                   	ret    
	...

00801c18 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801c1e:	c7 44 24 04 b7 2e 80 	movl   $0x802eb7,0x4(%esp)
  801c25:	00 
  801c26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c29:	89 04 24             	mov    %eax,(%esp)
  801c2c:	e8 0a ee ff ff       	call   800a3b <strcpy>
	return 0;
}
  801c31:	b8 00 00 00 00       	mov    $0x0,%eax
  801c36:	c9                   	leave  
  801c37:	c3                   	ret    

00801c38 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	53                   	push   %ebx
  801c3c:	83 ec 14             	sub    $0x14,%esp
  801c3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c42:	89 1c 24             	mov    %ebx,(%esp)
  801c45:	e8 1a 0b 00 00       	call   802764 <pageref>
  801c4a:	83 f8 01             	cmp    $0x1,%eax
  801c4d:	75 0d                	jne    801c5c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801c4f:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c52:	89 04 24             	mov    %eax,(%esp)
  801c55:	e8 1f 03 00 00       	call   801f79 <nsipc_close>
  801c5a:	eb 05                	jmp    801c61 <devsock_close+0x29>
	else
		return 0;
  801c5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c61:	83 c4 14             	add    $0x14,%esp
  801c64:	5b                   	pop    %ebx
  801c65:	5d                   	pop    %ebp
  801c66:	c3                   	ret    

00801c67 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c6d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c74:	00 
  801c75:	8b 45 10             	mov    0x10(%ebp),%eax
  801c78:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c83:	8b 45 08             	mov    0x8(%ebp),%eax
  801c86:	8b 40 0c             	mov    0xc(%eax),%eax
  801c89:	89 04 24             	mov    %eax,(%esp)
  801c8c:	e8 e3 03 00 00       	call   802074 <nsipc_send>
}
  801c91:	c9                   	leave  
  801c92:	c3                   	ret    

00801c93 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c93:	55                   	push   %ebp
  801c94:	89 e5                	mov    %esp,%ebp
  801c96:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c99:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ca0:	00 
  801ca1:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ca8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cab:	89 44 24 04          	mov    %eax,0x4(%esp)
  801caf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb2:	8b 40 0c             	mov    0xc(%eax),%eax
  801cb5:	89 04 24             	mov    %eax,(%esp)
  801cb8:	e8 37 03 00 00       	call   801ff4 <nsipc_recv>
}
  801cbd:	c9                   	leave  
  801cbe:	c3                   	ret    

00801cbf <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 20             	sub    $0x20,%esp
  801cc7:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801cc9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ccc:	89 04 24             	mov    %eax,(%esp)
  801ccf:	e8 a7 f5 ff ff       	call   80127b <fd_alloc>
  801cd4:	89 c3                	mov    %eax,%ebx
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	78 21                	js     801cfb <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801cda:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ce1:	00 
  801ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf0:	e8 38 f1 ff ff       	call   800e2d <sys_page_alloc>
  801cf5:	89 c3                	mov    %eax,%ebx
  801cf7:	85 c0                	test   %eax,%eax
  801cf9:	79 0a                	jns    801d05 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801cfb:	89 34 24             	mov    %esi,(%esp)
  801cfe:	e8 76 02 00 00       	call   801f79 <nsipc_close>
		return r;
  801d03:	eb 22                	jmp    801d27 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d05:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d13:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d1a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d1d:	89 04 24             	mov    %eax,(%esp)
  801d20:	e8 2b f5 ff ff       	call   801250 <fd2num>
  801d25:	89 c3                	mov    %eax,%ebx
}
  801d27:	89 d8                	mov    %ebx,%eax
  801d29:	83 c4 20             	add    $0x20,%esp
  801d2c:	5b                   	pop    %ebx
  801d2d:	5e                   	pop    %esi
  801d2e:	5d                   	pop    %ebp
  801d2f:	c3                   	ret    

00801d30 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d36:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d39:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d3d:	89 04 24             	mov    %eax,(%esp)
  801d40:	e8 89 f5 ff ff       	call   8012ce <fd_lookup>
  801d45:	85 c0                	test   %eax,%eax
  801d47:	78 17                	js     801d60 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d52:	39 10                	cmp    %edx,(%eax)
  801d54:	75 05                	jne    801d5b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d56:	8b 40 0c             	mov    0xc(%eax),%eax
  801d59:	eb 05                	jmp    801d60 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d5b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d60:	c9                   	leave  
  801d61:	c3                   	ret    

00801d62 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d68:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6b:	e8 c0 ff ff ff       	call   801d30 <fd2sockid>
  801d70:	85 c0                	test   %eax,%eax
  801d72:	78 1f                	js     801d93 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d74:	8b 55 10             	mov    0x10(%ebp),%edx
  801d77:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d7e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d82:	89 04 24             	mov    %eax,(%esp)
  801d85:	e8 38 01 00 00       	call   801ec2 <nsipc_accept>
  801d8a:	85 c0                	test   %eax,%eax
  801d8c:	78 05                	js     801d93 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801d8e:	e8 2c ff ff ff       	call   801cbf <alloc_sockfd>
}
  801d93:	c9                   	leave  
  801d94:	c3                   	ret    

00801d95 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9e:	e8 8d ff ff ff       	call   801d30 <fd2sockid>
  801da3:	85 c0                	test   %eax,%eax
  801da5:	78 16                	js     801dbd <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801da7:	8b 55 10             	mov    0x10(%ebp),%edx
  801daa:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dae:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801db5:	89 04 24             	mov    %eax,(%esp)
  801db8:	e8 5b 01 00 00       	call   801f18 <nsipc_bind>
}
  801dbd:	c9                   	leave  
  801dbe:	c3                   	ret    

00801dbf <shutdown>:

int
shutdown(int s, int how)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc8:	e8 63 ff ff ff       	call   801d30 <fd2sockid>
  801dcd:	85 c0                	test   %eax,%eax
  801dcf:	78 0f                	js     801de0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801dd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd4:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dd8:	89 04 24             	mov    %eax,(%esp)
  801ddb:	e8 77 01 00 00       	call   801f57 <nsipc_shutdown>
}
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801de8:	8b 45 08             	mov    0x8(%ebp),%eax
  801deb:	e8 40 ff ff ff       	call   801d30 <fd2sockid>
  801df0:	85 c0                	test   %eax,%eax
  801df2:	78 16                	js     801e0a <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801df4:	8b 55 10             	mov    0x10(%ebp),%edx
  801df7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dfe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e02:	89 04 24             	mov    %eax,(%esp)
  801e05:	e8 89 01 00 00       	call   801f93 <nsipc_connect>
}
  801e0a:	c9                   	leave  
  801e0b:	c3                   	ret    

00801e0c <listen>:

int
listen(int s, int backlog)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e12:	8b 45 08             	mov    0x8(%ebp),%eax
  801e15:	e8 16 ff ff ff       	call   801d30 <fd2sockid>
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	78 0f                	js     801e2d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e1e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e21:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e25:	89 04 24             	mov    %eax,(%esp)
  801e28:	e8 a5 01 00 00       	call   801fd2 <nsipc_listen>
}
  801e2d:	c9                   	leave  
  801e2e:	c3                   	ret    

00801e2f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e35:	8b 45 10             	mov    0x10(%ebp),%eax
  801e38:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e43:	8b 45 08             	mov    0x8(%ebp),%eax
  801e46:	89 04 24             	mov    %eax,(%esp)
  801e49:	e8 99 02 00 00       	call   8020e7 <nsipc_socket>
  801e4e:	85 c0                	test   %eax,%eax
  801e50:	78 05                	js     801e57 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801e52:	e8 68 fe ff ff       	call   801cbf <alloc_sockfd>
}
  801e57:	c9                   	leave  
  801e58:	c3                   	ret    
  801e59:	00 00                	add    %al,(%eax)
	...

00801e5c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	53                   	push   %ebx
  801e60:	83 ec 14             	sub    $0x14,%esp
  801e63:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e65:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801e6c:	75 11                	jne    801e7f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e6e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801e75:	e8 a5 08 00 00       	call   80271f <ipc_find_env>
  801e7a:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e7f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801e86:	00 
  801e87:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801e8e:	00 
  801e8f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e93:	a1 04 40 80 00       	mov    0x804004,%eax
  801e98:	89 04 24             	mov    %eax,(%esp)
  801e9b:	e8 fc 07 00 00       	call   80269c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ea0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ea7:	00 
  801ea8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801eaf:	00 
  801eb0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801eb7:	e8 70 07 00 00       	call   80262c <ipc_recv>
}
  801ebc:	83 c4 14             	add    $0x14,%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5d                   	pop    %ebp
  801ec1:	c3                   	ret    

00801ec2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	56                   	push   %esi
  801ec6:	53                   	push   %ebx
  801ec7:	83 ec 10             	sub    $0x10,%esp
  801eca:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ecd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ed5:	8b 06                	mov    (%esi),%eax
  801ed7:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801edc:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee1:	e8 76 ff ff ff       	call   801e5c <nsipc>
  801ee6:	89 c3                	mov    %eax,%ebx
  801ee8:	85 c0                	test   %eax,%eax
  801eea:	78 23                	js     801f0f <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801eec:	a1 10 60 80 00       	mov    0x806010,%eax
  801ef1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ef5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801efc:	00 
  801efd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f00:	89 04 24             	mov    %eax,(%esp)
  801f03:	e8 ac ec ff ff       	call   800bb4 <memmove>
		*addrlen = ret->ret_addrlen;
  801f08:	a1 10 60 80 00       	mov    0x806010,%eax
  801f0d:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801f0f:	89 d8                	mov    %ebx,%eax
  801f11:	83 c4 10             	add    $0x10,%esp
  801f14:	5b                   	pop    %ebx
  801f15:	5e                   	pop    %esi
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    

00801f18 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	53                   	push   %ebx
  801f1c:	83 ec 14             	sub    $0x14,%esp
  801f1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f22:	8b 45 08             	mov    0x8(%ebp),%eax
  801f25:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f2a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f35:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f3c:	e8 73 ec ff ff       	call   800bb4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f41:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f47:	b8 02 00 00 00       	mov    $0x2,%eax
  801f4c:	e8 0b ff ff ff       	call   801e5c <nsipc>
}
  801f51:	83 c4 14             	add    $0x14,%esp
  801f54:	5b                   	pop    %ebx
  801f55:	5d                   	pop    %ebp
  801f56:	c3                   	ret    

00801f57 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f5d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f60:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f68:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f6d:	b8 03 00 00 00       	mov    $0x3,%eax
  801f72:	e8 e5 fe ff ff       	call   801e5c <nsipc>
}
  801f77:	c9                   	leave  
  801f78:	c3                   	ret    

00801f79 <nsipc_close>:

int
nsipc_close(int s)
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f82:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801f87:	b8 04 00 00 00       	mov    $0x4,%eax
  801f8c:	e8 cb fe ff ff       	call   801e5c <nsipc>
}
  801f91:	c9                   	leave  
  801f92:	c3                   	ret    

00801f93 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f93:	55                   	push   %ebp
  801f94:	89 e5                	mov    %esp,%ebp
  801f96:	53                   	push   %ebx
  801f97:	83 ec 14             	sub    $0x14,%esp
  801f9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa0:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fa5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb0:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801fb7:	e8 f8 eb ff ff       	call   800bb4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fbc:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801fc2:	b8 05 00 00 00       	mov    $0x5,%eax
  801fc7:	e8 90 fe ff ff       	call   801e5c <nsipc>
}
  801fcc:	83 c4 14             	add    $0x14,%esp
  801fcf:	5b                   	pop    %ebx
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    

00801fd2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fdb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe3:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801fe8:	b8 06 00 00 00       	mov    $0x6,%eax
  801fed:	e8 6a fe ff ff       	call   801e5c <nsipc>
}
  801ff2:	c9                   	leave  
  801ff3:	c3                   	ret    

00801ff4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ff4:	55                   	push   %ebp
  801ff5:	89 e5                	mov    %esp,%ebp
  801ff7:	56                   	push   %esi
  801ff8:	53                   	push   %ebx
  801ff9:	83 ec 10             	sub    $0x10,%esp
  801ffc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801fff:	8b 45 08             	mov    0x8(%ebp),%eax
  802002:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802007:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80200d:	8b 45 14             	mov    0x14(%ebp),%eax
  802010:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802015:	b8 07 00 00 00       	mov    $0x7,%eax
  80201a:	e8 3d fe ff ff       	call   801e5c <nsipc>
  80201f:	89 c3                	mov    %eax,%ebx
  802021:	85 c0                	test   %eax,%eax
  802023:	78 46                	js     80206b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802025:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80202a:	7f 04                	jg     802030 <nsipc_recv+0x3c>
  80202c:	39 c6                	cmp    %eax,%esi
  80202e:	7d 24                	jge    802054 <nsipc_recv+0x60>
  802030:	c7 44 24 0c c3 2e 80 	movl   $0x802ec3,0xc(%esp)
  802037:	00 
  802038:	c7 44 24 08 8b 2e 80 	movl   $0x802e8b,0x8(%esp)
  80203f:	00 
  802040:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802047:	00 
  802048:	c7 04 24 d8 2e 80 00 	movl   $0x802ed8,(%esp)
  80204f:	e8 44 e3 ff ff       	call   800398 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802054:	89 44 24 08          	mov    %eax,0x8(%esp)
  802058:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80205f:	00 
  802060:	8b 45 0c             	mov    0xc(%ebp),%eax
  802063:	89 04 24             	mov    %eax,(%esp)
  802066:	e8 49 eb ff ff       	call   800bb4 <memmove>
	}

	return r;
}
  80206b:	89 d8                	mov    %ebx,%eax
  80206d:	83 c4 10             	add    $0x10,%esp
  802070:	5b                   	pop    %ebx
  802071:	5e                   	pop    %esi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    

00802074 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	53                   	push   %ebx
  802078:	83 ec 14             	sub    $0x14,%esp
  80207b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80207e:	8b 45 08             	mov    0x8(%ebp),%eax
  802081:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  802086:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80208c:	7e 24                	jle    8020b2 <nsipc_send+0x3e>
  80208e:	c7 44 24 0c e4 2e 80 	movl   $0x802ee4,0xc(%esp)
  802095:	00 
  802096:	c7 44 24 08 8b 2e 80 	movl   $0x802e8b,0x8(%esp)
  80209d:	00 
  80209e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8020a5:	00 
  8020a6:	c7 04 24 d8 2e 80 00 	movl   $0x802ed8,(%esp)
  8020ad:	e8 e6 e2 ff ff       	call   800398 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020bd:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8020c4:	e8 eb ea ff ff       	call   800bb4 <memmove>
	nsipcbuf.send.req_size = size;
  8020c9:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8020cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8020d2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8020d7:	b8 08 00 00 00       	mov    $0x8,%eax
  8020dc:	e8 7b fd ff ff       	call   801e5c <nsipc>
}
  8020e1:	83 c4 14             	add    $0x14,%esp
  8020e4:	5b                   	pop    %ebx
  8020e5:	5d                   	pop    %ebp
  8020e6:	c3                   	ret    

008020e7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020e7:	55                   	push   %ebp
  8020e8:	89 e5                	mov    %esp,%ebp
  8020ea:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8020f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f8:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8020fd:	8b 45 10             	mov    0x10(%ebp),%eax
  802100:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802105:	b8 09 00 00 00       	mov    $0x9,%eax
  80210a:	e8 4d fd ff ff       	call   801e5c <nsipc>
}
  80210f:	c9                   	leave  
  802110:	c3                   	ret    
  802111:	00 00                	add    %al,(%eax)
	...

00802114 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802114:	55                   	push   %ebp
  802115:	89 e5                	mov    %esp,%ebp
  802117:	56                   	push   %esi
  802118:	53                   	push   %ebx
  802119:	83 ec 10             	sub    $0x10,%esp
  80211c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80211f:	8b 45 08             	mov    0x8(%ebp),%eax
  802122:	89 04 24             	mov    %eax,(%esp)
  802125:	e8 36 f1 ff ff       	call   801260 <fd2data>
  80212a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80212c:	c7 44 24 04 f0 2e 80 	movl   $0x802ef0,0x4(%esp)
  802133:	00 
  802134:	89 34 24             	mov    %esi,(%esp)
  802137:	e8 ff e8 ff ff       	call   800a3b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80213c:	8b 43 04             	mov    0x4(%ebx),%eax
  80213f:	2b 03                	sub    (%ebx),%eax
  802141:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802147:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80214e:	00 00 00 
	stat->st_dev = &devpipe;
  802151:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  802158:	30 80 00 
	return 0;
}
  80215b:	b8 00 00 00 00       	mov    $0x0,%eax
  802160:	83 c4 10             	add    $0x10,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5d                   	pop    %ebp
  802166:	c3                   	ret    

00802167 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802167:	55                   	push   %ebp
  802168:	89 e5                	mov    %esp,%ebp
  80216a:	53                   	push   %ebx
  80216b:	83 ec 14             	sub    $0x14,%esp
  80216e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802171:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802175:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80217c:	e8 53 ed ff ff       	call   800ed4 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802181:	89 1c 24             	mov    %ebx,(%esp)
  802184:	e8 d7 f0 ff ff       	call   801260 <fd2data>
  802189:	89 44 24 04          	mov    %eax,0x4(%esp)
  80218d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802194:	e8 3b ed ff ff       	call   800ed4 <sys_page_unmap>
}
  802199:	83 c4 14             	add    $0x14,%esp
  80219c:	5b                   	pop    %ebx
  80219d:	5d                   	pop    %ebp
  80219e:	c3                   	ret    

0080219f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80219f:	55                   	push   %ebp
  8021a0:	89 e5                	mov    %esp,%ebp
  8021a2:	57                   	push   %edi
  8021a3:	56                   	push   %esi
  8021a4:	53                   	push   %ebx
  8021a5:	83 ec 2c             	sub    $0x2c,%esp
  8021a8:	89 c7                	mov    %eax,%edi
  8021aa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8021ad:	a1 20 44 80 00       	mov    0x804420,%eax
  8021b2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021b5:	89 3c 24             	mov    %edi,(%esp)
  8021b8:	e8 a7 05 00 00       	call   802764 <pageref>
  8021bd:	89 c6                	mov    %eax,%esi
  8021bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021c2:	89 04 24             	mov    %eax,(%esp)
  8021c5:	e8 9a 05 00 00       	call   802764 <pageref>
  8021ca:	39 c6                	cmp    %eax,%esi
  8021cc:	0f 94 c0             	sete   %al
  8021cf:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8021d2:	8b 15 20 44 80 00    	mov    0x804420,%edx
  8021d8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8021db:	39 cb                	cmp    %ecx,%ebx
  8021dd:	75 08                	jne    8021e7 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8021df:	83 c4 2c             	add    $0x2c,%esp
  8021e2:	5b                   	pop    %ebx
  8021e3:	5e                   	pop    %esi
  8021e4:	5f                   	pop    %edi
  8021e5:	5d                   	pop    %ebp
  8021e6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8021e7:	83 f8 01             	cmp    $0x1,%eax
  8021ea:	75 c1                	jne    8021ad <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021ec:	8b 42 58             	mov    0x58(%edx),%eax
  8021ef:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8021f6:	00 
  8021f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021ff:	c7 04 24 f7 2e 80 00 	movl   $0x802ef7,(%esp)
  802206:	e8 85 e2 ff ff       	call   800490 <cprintf>
  80220b:	eb a0                	jmp    8021ad <_pipeisclosed+0xe>

0080220d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80220d:	55                   	push   %ebp
  80220e:	89 e5                	mov    %esp,%ebp
  802210:	57                   	push   %edi
  802211:	56                   	push   %esi
  802212:	53                   	push   %ebx
  802213:	83 ec 1c             	sub    $0x1c,%esp
  802216:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802219:	89 34 24             	mov    %esi,(%esp)
  80221c:	e8 3f f0 ff ff       	call   801260 <fd2data>
  802221:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802223:	bf 00 00 00 00       	mov    $0x0,%edi
  802228:	eb 3c                	jmp    802266 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80222a:	89 da                	mov    %ebx,%edx
  80222c:	89 f0                	mov    %esi,%eax
  80222e:	e8 6c ff ff ff       	call   80219f <_pipeisclosed>
  802233:	85 c0                	test   %eax,%eax
  802235:	75 38                	jne    80226f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802237:	e8 d2 eb ff ff       	call   800e0e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80223c:	8b 43 04             	mov    0x4(%ebx),%eax
  80223f:	8b 13                	mov    (%ebx),%edx
  802241:	83 c2 20             	add    $0x20,%edx
  802244:	39 d0                	cmp    %edx,%eax
  802246:	73 e2                	jae    80222a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802248:	8b 55 0c             	mov    0xc(%ebp),%edx
  80224b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80224e:	89 c2                	mov    %eax,%edx
  802250:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802256:	79 05                	jns    80225d <devpipe_write+0x50>
  802258:	4a                   	dec    %edx
  802259:	83 ca e0             	or     $0xffffffe0,%edx
  80225c:	42                   	inc    %edx
  80225d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802261:	40                   	inc    %eax
  802262:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802265:	47                   	inc    %edi
  802266:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802269:	75 d1                	jne    80223c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80226b:	89 f8                	mov    %edi,%eax
  80226d:	eb 05                	jmp    802274 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80226f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802274:	83 c4 1c             	add    $0x1c,%esp
  802277:	5b                   	pop    %ebx
  802278:	5e                   	pop    %esi
  802279:	5f                   	pop    %edi
  80227a:	5d                   	pop    %ebp
  80227b:	c3                   	ret    

0080227c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80227c:	55                   	push   %ebp
  80227d:	89 e5                	mov    %esp,%ebp
  80227f:	57                   	push   %edi
  802280:	56                   	push   %esi
  802281:	53                   	push   %ebx
  802282:	83 ec 1c             	sub    $0x1c,%esp
  802285:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802288:	89 3c 24             	mov    %edi,(%esp)
  80228b:	e8 d0 ef ff ff       	call   801260 <fd2data>
  802290:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802292:	be 00 00 00 00       	mov    $0x0,%esi
  802297:	eb 3a                	jmp    8022d3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802299:	85 f6                	test   %esi,%esi
  80229b:	74 04                	je     8022a1 <devpipe_read+0x25>
				return i;
  80229d:	89 f0                	mov    %esi,%eax
  80229f:	eb 40                	jmp    8022e1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8022a1:	89 da                	mov    %ebx,%edx
  8022a3:	89 f8                	mov    %edi,%eax
  8022a5:	e8 f5 fe ff ff       	call   80219f <_pipeisclosed>
  8022aa:	85 c0                	test   %eax,%eax
  8022ac:	75 2e                	jne    8022dc <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8022ae:	e8 5b eb ff ff       	call   800e0e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8022b3:	8b 03                	mov    (%ebx),%eax
  8022b5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022b8:	74 df                	je     802299 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022ba:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8022bf:	79 05                	jns    8022c6 <devpipe_read+0x4a>
  8022c1:	48                   	dec    %eax
  8022c2:	83 c8 e0             	or     $0xffffffe0,%eax
  8022c5:	40                   	inc    %eax
  8022c6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8022ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022cd:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8022d0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022d2:	46                   	inc    %esi
  8022d3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022d6:	75 db                	jne    8022b3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022d8:	89 f0                	mov    %esi,%eax
  8022da:	eb 05                	jmp    8022e1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022dc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022e1:	83 c4 1c             	add    $0x1c,%esp
  8022e4:	5b                   	pop    %ebx
  8022e5:	5e                   	pop    %esi
  8022e6:	5f                   	pop    %edi
  8022e7:	5d                   	pop    %ebp
  8022e8:	c3                   	ret    

008022e9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8022e9:	55                   	push   %ebp
  8022ea:	89 e5                	mov    %esp,%ebp
  8022ec:	57                   	push   %edi
  8022ed:	56                   	push   %esi
  8022ee:	53                   	push   %ebx
  8022ef:	83 ec 3c             	sub    $0x3c,%esp
  8022f2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8022f5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8022f8:	89 04 24             	mov    %eax,(%esp)
  8022fb:	e8 7b ef ff ff       	call   80127b <fd_alloc>
  802300:	89 c3                	mov    %eax,%ebx
  802302:	85 c0                	test   %eax,%eax
  802304:	0f 88 45 01 00 00    	js     80244f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80230a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802311:	00 
  802312:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802315:	89 44 24 04          	mov    %eax,0x4(%esp)
  802319:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802320:	e8 08 eb ff ff       	call   800e2d <sys_page_alloc>
  802325:	89 c3                	mov    %eax,%ebx
  802327:	85 c0                	test   %eax,%eax
  802329:	0f 88 20 01 00 00    	js     80244f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80232f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802332:	89 04 24             	mov    %eax,(%esp)
  802335:	e8 41 ef ff ff       	call   80127b <fd_alloc>
  80233a:	89 c3                	mov    %eax,%ebx
  80233c:	85 c0                	test   %eax,%eax
  80233e:	0f 88 f8 00 00 00    	js     80243c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802344:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80234b:	00 
  80234c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80234f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802353:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80235a:	e8 ce ea ff ff       	call   800e2d <sys_page_alloc>
  80235f:	89 c3                	mov    %eax,%ebx
  802361:	85 c0                	test   %eax,%eax
  802363:	0f 88 d3 00 00 00    	js     80243c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802369:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80236c:	89 04 24             	mov    %eax,(%esp)
  80236f:	e8 ec ee ff ff       	call   801260 <fd2data>
  802374:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802376:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80237d:	00 
  80237e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802382:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802389:	e8 9f ea ff ff       	call   800e2d <sys_page_alloc>
  80238e:	89 c3                	mov    %eax,%ebx
  802390:	85 c0                	test   %eax,%eax
  802392:	0f 88 91 00 00 00    	js     802429 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802398:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80239b:	89 04 24             	mov    %eax,(%esp)
  80239e:	e8 bd ee ff ff       	call   801260 <fd2data>
  8023a3:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8023aa:	00 
  8023ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8023b6:	00 
  8023b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023c2:	e8 ba ea ff ff       	call   800e81 <sys_page_map>
  8023c7:	89 c3                	mov    %eax,%ebx
  8023c9:	85 c0                	test   %eax,%eax
  8023cb:	78 4c                	js     802419 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8023cd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023d6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8023d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023db:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8023e2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023eb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8023ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023f0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8023f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023fa:	89 04 24             	mov    %eax,(%esp)
  8023fd:	e8 4e ee ff ff       	call   801250 <fd2num>
  802402:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802404:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802407:	89 04 24             	mov    %eax,(%esp)
  80240a:	e8 41 ee ff ff       	call   801250 <fd2num>
  80240f:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802412:	bb 00 00 00 00       	mov    $0x0,%ebx
  802417:	eb 36                	jmp    80244f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802419:	89 74 24 04          	mov    %esi,0x4(%esp)
  80241d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802424:	e8 ab ea ff ff       	call   800ed4 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802429:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80242c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802430:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802437:	e8 98 ea ff ff       	call   800ed4 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80243c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80243f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802443:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80244a:	e8 85 ea ff ff       	call   800ed4 <sys_page_unmap>
    err:
	return r;
}
  80244f:	89 d8                	mov    %ebx,%eax
  802451:	83 c4 3c             	add    $0x3c,%esp
  802454:	5b                   	pop    %ebx
  802455:	5e                   	pop    %esi
  802456:	5f                   	pop    %edi
  802457:	5d                   	pop    %ebp
  802458:	c3                   	ret    

00802459 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802459:	55                   	push   %ebp
  80245a:	89 e5                	mov    %esp,%ebp
  80245c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80245f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802462:	89 44 24 04          	mov    %eax,0x4(%esp)
  802466:	8b 45 08             	mov    0x8(%ebp),%eax
  802469:	89 04 24             	mov    %eax,(%esp)
  80246c:	e8 5d ee ff ff       	call   8012ce <fd_lookup>
  802471:	85 c0                	test   %eax,%eax
  802473:	78 15                	js     80248a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802475:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802478:	89 04 24             	mov    %eax,(%esp)
  80247b:	e8 e0 ed ff ff       	call   801260 <fd2data>
	return _pipeisclosed(fd, p);
  802480:	89 c2                	mov    %eax,%edx
  802482:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802485:	e8 15 fd ff ff       	call   80219f <_pipeisclosed>
}
  80248a:	c9                   	leave  
  80248b:	c3                   	ret    

0080248c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80248c:	55                   	push   %ebp
  80248d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80248f:	b8 00 00 00 00       	mov    $0x0,%eax
  802494:	5d                   	pop    %ebp
  802495:	c3                   	ret    

00802496 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802496:	55                   	push   %ebp
  802497:	89 e5                	mov    %esp,%ebp
  802499:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80249c:	c7 44 24 04 0f 2f 80 	movl   $0x802f0f,0x4(%esp)
  8024a3:	00 
  8024a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024a7:	89 04 24             	mov    %eax,(%esp)
  8024aa:	e8 8c e5 ff ff       	call   800a3b <strcpy>
	return 0;
}
  8024af:	b8 00 00 00 00       	mov    $0x0,%eax
  8024b4:	c9                   	leave  
  8024b5:	c3                   	ret    

008024b6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024b6:	55                   	push   %ebp
  8024b7:	89 e5                	mov    %esp,%ebp
  8024b9:	57                   	push   %edi
  8024ba:	56                   	push   %esi
  8024bb:	53                   	push   %ebx
  8024bc:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024c2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024c7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024cd:	eb 30                	jmp    8024ff <devcons_write+0x49>
		m = n - tot;
  8024cf:	8b 75 10             	mov    0x10(%ebp),%esi
  8024d2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8024d4:	83 fe 7f             	cmp    $0x7f,%esi
  8024d7:	76 05                	jbe    8024de <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8024d9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8024de:	89 74 24 08          	mov    %esi,0x8(%esp)
  8024e2:	03 45 0c             	add    0xc(%ebp),%eax
  8024e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024e9:	89 3c 24             	mov    %edi,(%esp)
  8024ec:	e8 c3 e6 ff ff       	call   800bb4 <memmove>
		sys_cputs(buf, m);
  8024f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024f5:	89 3c 24             	mov    %edi,(%esp)
  8024f8:	e8 63 e8 ff ff       	call   800d60 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024fd:	01 f3                	add    %esi,%ebx
  8024ff:	89 d8                	mov    %ebx,%eax
  802501:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802504:	72 c9                	jb     8024cf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802506:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  80250c:	5b                   	pop    %ebx
  80250d:	5e                   	pop    %esi
  80250e:	5f                   	pop    %edi
  80250f:	5d                   	pop    %ebp
  802510:	c3                   	ret    

00802511 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802511:	55                   	push   %ebp
  802512:	89 e5                	mov    %esp,%ebp
  802514:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802517:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80251b:	75 07                	jne    802524 <devcons_read+0x13>
  80251d:	eb 25                	jmp    802544 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80251f:	e8 ea e8 ff ff       	call   800e0e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802524:	e8 55 e8 ff ff       	call   800d7e <sys_cgetc>
  802529:	85 c0                	test   %eax,%eax
  80252b:	74 f2                	je     80251f <devcons_read+0xe>
  80252d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80252f:	85 c0                	test   %eax,%eax
  802531:	78 1d                	js     802550 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802533:	83 f8 04             	cmp    $0x4,%eax
  802536:	74 13                	je     80254b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802538:	8b 45 0c             	mov    0xc(%ebp),%eax
  80253b:	88 10                	mov    %dl,(%eax)
	return 1;
  80253d:	b8 01 00 00 00       	mov    $0x1,%eax
  802542:	eb 0c                	jmp    802550 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802544:	b8 00 00 00 00       	mov    $0x0,%eax
  802549:	eb 05                	jmp    802550 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80254b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802550:	c9                   	leave  
  802551:	c3                   	ret    

00802552 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802552:	55                   	push   %ebp
  802553:	89 e5                	mov    %esp,%ebp
  802555:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802558:	8b 45 08             	mov    0x8(%ebp),%eax
  80255b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80255e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802565:	00 
  802566:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802569:	89 04 24             	mov    %eax,(%esp)
  80256c:	e8 ef e7 ff ff       	call   800d60 <sys_cputs>
}
  802571:	c9                   	leave  
  802572:	c3                   	ret    

00802573 <getchar>:

int
getchar(void)
{
  802573:	55                   	push   %ebp
  802574:	89 e5                	mov    %esp,%ebp
  802576:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802579:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802580:	00 
  802581:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802584:	89 44 24 04          	mov    %eax,0x4(%esp)
  802588:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80258f:	e8 d8 ef ff ff       	call   80156c <read>
	if (r < 0)
  802594:	85 c0                	test   %eax,%eax
  802596:	78 0f                	js     8025a7 <getchar+0x34>
		return r;
	if (r < 1)
  802598:	85 c0                	test   %eax,%eax
  80259a:	7e 06                	jle    8025a2 <getchar+0x2f>
		return -E_EOF;
	return c;
  80259c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8025a0:	eb 05                	jmp    8025a7 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8025a2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8025a7:	c9                   	leave  
  8025a8:	c3                   	ret    

008025a9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8025a9:	55                   	push   %ebp
  8025aa:	89 e5                	mov    %esp,%ebp
  8025ac:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8025b9:	89 04 24             	mov    %eax,(%esp)
  8025bc:	e8 0d ed ff ff       	call   8012ce <fd_lookup>
  8025c1:	85 c0                	test   %eax,%eax
  8025c3:	78 11                	js     8025d6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025c8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8025ce:	39 10                	cmp    %edx,(%eax)
  8025d0:	0f 94 c0             	sete   %al
  8025d3:	0f b6 c0             	movzbl %al,%eax
}
  8025d6:	c9                   	leave  
  8025d7:	c3                   	ret    

008025d8 <opencons>:

int
opencons(void)
{
  8025d8:	55                   	push   %ebp
  8025d9:	89 e5                	mov    %esp,%ebp
  8025db:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8025de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025e1:	89 04 24             	mov    %eax,(%esp)
  8025e4:	e8 92 ec ff ff       	call   80127b <fd_alloc>
  8025e9:	85 c0                	test   %eax,%eax
  8025eb:	78 3c                	js     802629 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025ed:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8025f4:	00 
  8025f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802603:	e8 25 e8 ff ff       	call   800e2d <sys_page_alloc>
  802608:	85 c0                	test   %eax,%eax
  80260a:	78 1d                	js     802629 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80260c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802612:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802615:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802617:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80261a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802621:	89 04 24             	mov    %eax,(%esp)
  802624:	e8 27 ec ff ff       	call   801250 <fd2num>
}
  802629:	c9                   	leave  
  80262a:	c3                   	ret    
	...

0080262c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80262c:	55                   	push   %ebp
  80262d:	89 e5                	mov    %esp,%ebp
  80262f:	56                   	push   %esi
  802630:	53                   	push   %ebx
  802631:	83 ec 10             	sub    $0x10,%esp
  802634:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802637:	8b 45 0c             	mov    0xc(%ebp),%eax
  80263a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  80263d:	85 c0                	test   %eax,%eax
  80263f:	74 0a                	je     80264b <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802641:	89 04 24             	mov    %eax,(%esp)
  802644:	e8 fa e9 ff ff       	call   801043 <sys_ipc_recv>
  802649:	eb 0c                	jmp    802657 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80264b:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802652:	e8 ec e9 ff ff       	call   801043 <sys_ipc_recv>
	}
	if (r < 0)
  802657:	85 c0                	test   %eax,%eax
  802659:	79 16                	jns    802671 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  80265b:	85 db                	test   %ebx,%ebx
  80265d:	74 06                	je     802665 <ipc_recv+0x39>
  80265f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802665:	85 f6                	test   %esi,%esi
  802667:	74 2c                	je     802695 <ipc_recv+0x69>
  802669:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80266f:	eb 24                	jmp    802695 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802671:	85 db                	test   %ebx,%ebx
  802673:	74 0a                	je     80267f <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802675:	a1 20 44 80 00       	mov    0x804420,%eax
  80267a:	8b 40 74             	mov    0x74(%eax),%eax
  80267d:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  80267f:	85 f6                	test   %esi,%esi
  802681:	74 0a                	je     80268d <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  802683:	a1 20 44 80 00       	mov    0x804420,%eax
  802688:	8b 40 78             	mov    0x78(%eax),%eax
  80268b:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  80268d:	a1 20 44 80 00       	mov    0x804420,%eax
  802692:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802695:	83 c4 10             	add    $0x10,%esp
  802698:	5b                   	pop    %ebx
  802699:	5e                   	pop    %esi
  80269a:	5d                   	pop    %ebp
  80269b:	c3                   	ret    

0080269c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80269c:	55                   	push   %ebp
  80269d:	89 e5                	mov    %esp,%ebp
  80269f:	57                   	push   %edi
  8026a0:	56                   	push   %esi
  8026a1:	53                   	push   %ebx
  8026a2:	83 ec 1c             	sub    $0x1c,%esp
  8026a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8026a8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8026ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8026ae:	85 db                	test   %ebx,%ebx
  8026b0:	74 19                	je     8026cb <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8026b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8026b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8026c1:	89 34 24             	mov    %esi,(%esp)
  8026c4:	e8 57 e9 ff ff       	call   801020 <sys_ipc_try_send>
  8026c9:	eb 1c                	jmp    8026e7 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  8026cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8026d2:	00 
  8026d3:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8026da:	ee 
  8026db:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8026df:	89 34 24             	mov    %esi,(%esp)
  8026e2:	e8 39 e9 ff ff       	call   801020 <sys_ipc_try_send>
		}
		if (r == 0)
  8026e7:	85 c0                	test   %eax,%eax
  8026e9:	74 2c                	je     802717 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  8026eb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8026ee:	74 20                	je     802710 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  8026f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026f4:	c7 44 24 08 1b 2f 80 	movl   $0x802f1b,0x8(%esp)
  8026fb:	00 
  8026fc:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802703:	00 
  802704:	c7 04 24 2e 2f 80 00 	movl   $0x802f2e,(%esp)
  80270b:	e8 88 dc ff ff       	call   800398 <_panic>
		}
		sys_yield();
  802710:	e8 f9 e6 ff ff       	call   800e0e <sys_yield>
	}
  802715:	eb 97                	jmp    8026ae <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802717:	83 c4 1c             	add    $0x1c,%esp
  80271a:	5b                   	pop    %ebx
  80271b:	5e                   	pop    %esi
  80271c:	5f                   	pop    %edi
  80271d:	5d                   	pop    %ebp
  80271e:	c3                   	ret    

0080271f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80271f:	55                   	push   %ebp
  802720:	89 e5                	mov    %esp,%ebp
  802722:	53                   	push   %ebx
  802723:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802726:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80272b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802732:	89 c2                	mov    %eax,%edx
  802734:	c1 e2 07             	shl    $0x7,%edx
  802737:	29 ca                	sub    %ecx,%edx
  802739:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80273f:	8b 52 50             	mov    0x50(%edx),%edx
  802742:	39 da                	cmp    %ebx,%edx
  802744:	75 0f                	jne    802755 <ipc_find_env+0x36>
			return envs[i].env_id;
  802746:	c1 e0 07             	shl    $0x7,%eax
  802749:	29 c8                	sub    %ecx,%eax
  80274b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802750:	8b 40 40             	mov    0x40(%eax),%eax
  802753:	eb 0c                	jmp    802761 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802755:	40                   	inc    %eax
  802756:	3d 00 04 00 00       	cmp    $0x400,%eax
  80275b:	75 ce                	jne    80272b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80275d:	66 b8 00 00          	mov    $0x0,%ax
}
  802761:	5b                   	pop    %ebx
  802762:	5d                   	pop    %ebp
  802763:	c3                   	ret    

00802764 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802764:	55                   	push   %ebp
  802765:	89 e5                	mov    %esp,%ebp
  802767:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80276a:	89 c2                	mov    %eax,%edx
  80276c:	c1 ea 16             	shr    $0x16,%edx
  80276f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802776:	f6 c2 01             	test   $0x1,%dl
  802779:	74 1e                	je     802799 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80277b:	c1 e8 0c             	shr    $0xc,%eax
  80277e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802785:	a8 01                	test   $0x1,%al
  802787:	74 17                	je     8027a0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802789:	c1 e8 0c             	shr    $0xc,%eax
  80278c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802793:	ef 
  802794:	0f b7 c0             	movzwl %ax,%eax
  802797:	eb 0c                	jmp    8027a5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802799:	b8 00 00 00 00       	mov    $0x0,%eax
  80279e:	eb 05                	jmp    8027a5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8027a0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8027a5:	5d                   	pop    %ebp
  8027a6:	c3                   	ret    
	...

008027a8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8027a8:	55                   	push   %ebp
  8027a9:	57                   	push   %edi
  8027aa:	56                   	push   %esi
  8027ab:	83 ec 10             	sub    $0x10,%esp
  8027ae:	8b 74 24 20          	mov    0x20(%esp),%esi
  8027b2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8027b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027ba:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8027be:	89 cd                	mov    %ecx,%ebp
  8027c0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8027c4:	85 c0                	test   %eax,%eax
  8027c6:	75 2c                	jne    8027f4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8027c8:	39 f9                	cmp    %edi,%ecx
  8027ca:	77 68                	ja     802834 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8027cc:	85 c9                	test   %ecx,%ecx
  8027ce:	75 0b                	jne    8027db <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8027d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8027d5:	31 d2                	xor    %edx,%edx
  8027d7:	f7 f1                	div    %ecx
  8027d9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8027db:	31 d2                	xor    %edx,%edx
  8027dd:	89 f8                	mov    %edi,%eax
  8027df:	f7 f1                	div    %ecx
  8027e1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027e3:	89 f0                	mov    %esi,%eax
  8027e5:	f7 f1                	div    %ecx
  8027e7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027e9:	89 f0                	mov    %esi,%eax
  8027eb:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027ed:	83 c4 10             	add    $0x10,%esp
  8027f0:	5e                   	pop    %esi
  8027f1:	5f                   	pop    %edi
  8027f2:	5d                   	pop    %ebp
  8027f3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8027f4:	39 f8                	cmp    %edi,%eax
  8027f6:	77 2c                	ja     802824 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8027f8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8027fb:	83 f6 1f             	xor    $0x1f,%esi
  8027fe:	75 4c                	jne    80284c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802800:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802802:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802807:	72 0a                	jb     802813 <__udivdi3+0x6b>
  802809:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80280d:	0f 87 ad 00 00 00    	ja     8028c0 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802813:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802818:	89 f0                	mov    %esi,%eax
  80281a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80281c:	83 c4 10             	add    $0x10,%esp
  80281f:	5e                   	pop    %esi
  802820:	5f                   	pop    %edi
  802821:	5d                   	pop    %ebp
  802822:	c3                   	ret    
  802823:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802824:	31 ff                	xor    %edi,%edi
  802826:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802828:	89 f0                	mov    %esi,%eax
  80282a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80282c:	83 c4 10             	add    $0x10,%esp
  80282f:	5e                   	pop    %esi
  802830:	5f                   	pop    %edi
  802831:	5d                   	pop    %ebp
  802832:	c3                   	ret    
  802833:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802834:	89 fa                	mov    %edi,%edx
  802836:	89 f0                	mov    %esi,%eax
  802838:	f7 f1                	div    %ecx
  80283a:	89 c6                	mov    %eax,%esi
  80283c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80283e:	89 f0                	mov    %esi,%eax
  802840:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802842:	83 c4 10             	add    $0x10,%esp
  802845:	5e                   	pop    %esi
  802846:	5f                   	pop    %edi
  802847:	5d                   	pop    %ebp
  802848:	c3                   	ret    
  802849:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80284c:	89 f1                	mov    %esi,%ecx
  80284e:	d3 e0                	shl    %cl,%eax
  802850:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802854:	b8 20 00 00 00       	mov    $0x20,%eax
  802859:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80285b:	89 ea                	mov    %ebp,%edx
  80285d:	88 c1                	mov    %al,%cl
  80285f:	d3 ea                	shr    %cl,%edx
  802861:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802865:	09 ca                	or     %ecx,%edx
  802867:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80286b:	89 f1                	mov    %esi,%ecx
  80286d:	d3 e5                	shl    %cl,%ebp
  80286f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802873:	89 fd                	mov    %edi,%ebp
  802875:	88 c1                	mov    %al,%cl
  802877:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802879:	89 fa                	mov    %edi,%edx
  80287b:	89 f1                	mov    %esi,%ecx
  80287d:	d3 e2                	shl    %cl,%edx
  80287f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802883:	88 c1                	mov    %al,%cl
  802885:	d3 ef                	shr    %cl,%edi
  802887:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802889:	89 f8                	mov    %edi,%eax
  80288b:	89 ea                	mov    %ebp,%edx
  80288d:	f7 74 24 08          	divl   0x8(%esp)
  802891:	89 d1                	mov    %edx,%ecx
  802893:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802895:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802899:	39 d1                	cmp    %edx,%ecx
  80289b:	72 17                	jb     8028b4 <__udivdi3+0x10c>
  80289d:	74 09                	je     8028a8 <__udivdi3+0x100>
  80289f:	89 fe                	mov    %edi,%esi
  8028a1:	31 ff                	xor    %edi,%edi
  8028a3:	e9 41 ff ff ff       	jmp    8027e9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8028a8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8028ac:	89 f1                	mov    %esi,%ecx
  8028ae:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028b0:	39 c2                	cmp    %eax,%edx
  8028b2:	73 eb                	jae    80289f <__udivdi3+0xf7>
		{
		  q0--;
  8028b4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8028b7:	31 ff                	xor    %edi,%edi
  8028b9:	e9 2b ff ff ff       	jmp    8027e9 <__udivdi3+0x41>
  8028be:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8028c0:	31 f6                	xor    %esi,%esi
  8028c2:	e9 22 ff ff ff       	jmp    8027e9 <__udivdi3+0x41>
	...

008028c8 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8028c8:	55                   	push   %ebp
  8028c9:	57                   	push   %edi
  8028ca:	56                   	push   %esi
  8028cb:	83 ec 20             	sub    $0x20,%esp
  8028ce:	8b 44 24 30          	mov    0x30(%esp),%eax
  8028d2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8028d6:	89 44 24 14          	mov    %eax,0x14(%esp)
  8028da:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8028de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8028e2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8028e6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8028e8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8028ea:	85 ed                	test   %ebp,%ebp
  8028ec:	75 16                	jne    802904 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8028ee:	39 f1                	cmp    %esi,%ecx
  8028f0:	0f 86 a6 00 00 00    	jbe    80299c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8028f6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8028f8:	89 d0                	mov    %edx,%eax
  8028fa:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028fc:	83 c4 20             	add    $0x20,%esp
  8028ff:	5e                   	pop    %esi
  802900:	5f                   	pop    %edi
  802901:	5d                   	pop    %ebp
  802902:	c3                   	ret    
  802903:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802904:	39 f5                	cmp    %esi,%ebp
  802906:	0f 87 ac 00 00 00    	ja     8029b8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80290c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80290f:	83 f0 1f             	xor    $0x1f,%eax
  802912:	89 44 24 10          	mov    %eax,0x10(%esp)
  802916:	0f 84 a8 00 00 00    	je     8029c4 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80291c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802920:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802922:	bf 20 00 00 00       	mov    $0x20,%edi
  802927:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80292b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80292f:	89 f9                	mov    %edi,%ecx
  802931:	d3 e8                	shr    %cl,%eax
  802933:	09 e8                	or     %ebp,%eax
  802935:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802939:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80293d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802941:	d3 e0                	shl    %cl,%eax
  802943:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802947:	89 f2                	mov    %esi,%edx
  802949:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80294b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80294f:	d3 e0                	shl    %cl,%eax
  802951:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802955:	8b 44 24 14          	mov    0x14(%esp),%eax
  802959:	89 f9                	mov    %edi,%ecx
  80295b:	d3 e8                	shr    %cl,%eax
  80295d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80295f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802961:	89 f2                	mov    %esi,%edx
  802963:	f7 74 24 18          	divl   0x18(%esp)
  802967:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802969:	f7 64 24 0c          	mull   0xc(%esp)
  80296d:	89 c5                	mov    %eax,%ebp
  80296f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802971:	39 d6                	cmp    %edx,%esi
  802973:	72 67                	jb     8029dc <__umoddi3+0x114>
  802975:	74 75                	je     8029ec <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802977:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80297b:	29 e8                	sub    %ebp,%eax
  80297d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80297f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802983:	d3 e8                	shr    %cl,%eax
  802985:	89 f2                	mov    %esi,%edx
  802987:	89 f9                	mov    %edi,%ecx
  802989:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80298b:	09 d0                	or     %edx,%eax
  80298d:	89 f2                	mov    %esi,%edx
  80298f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802993:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802995:	83 c4 20             	add    $0x20,%esp
  802998:	5e                   	pop    %esi
  802999:	5f                   	pop    %edi
  80299a:	5d                   	pop    %ebp
  80299b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80299c:	85 c9                	test   %ecx,%ecx
  80299e:	75 0b                	jne    8029ab <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8029a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8029a5:	31 d2                	xor    %edx,%edx
  8029a7:	f7 f1                	div    %ecx
  8029a9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8029ab:	89 f0                	mov    %esi,%eax
  8029ad:	31 d2                	xor    %edx,%edx
  8029af:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8029b1:	89 f8                	mov    %edi,%eax
  8029b3:	e9 3e ff ff ff       	jmp    8028f6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8029b8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8029ba:	83 c4 20             	add    $0x20,%esp
  8029bd:	5e                   	pop    %esi
  8029be:	5f                   	pop    %edi
  8029bf:	5d                   	pop    %ebp
  8029c0:	c3                   	ret    
  8029c1:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8029c4:	39 f5                	cmp    %esi,%ebp
  8029c6:	72 04                	jb     8029cc <__umoddi3+0x104>
  8029c8:	39 f9                	cmp    %edi,%ecx
  8029ca:	77 06                	ja     8029d2 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8029cc:	89 f2                	mov    %esi,%edx
  8029ce:	29 cf                	sub    %ecx,%edi
  8029d0:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8029d2:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8029d4:	83 c4 20             	add    $0x20,%esp
  8029d7:	5e                   	pop    %esi
  8029d8:	5f                   	pop    %edi
  8029d9:	5d                   	pop    %ebp
  8029da:	c3                   	ret    
  8029db:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8029dc:	89 d1                	mov    %edx,%ecx
  8029de:	89 c5                	mov    %eax,%ebp
  8029e0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8029e4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8029e8:	eb 8d                	jmp    802977 <__umoddi3+0xaf>
  8029ea:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8029ec:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8029f0:	72 ea                	jb     8029dc <__umoddi3+0x114>
  8029f2:	89 f1                	mov    %esi,%ecx
  8029f4:	eb 81                	jmp    802977 <__umoddi3+0xaf>
