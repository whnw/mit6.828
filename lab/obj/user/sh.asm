
obj/user/sh.debug:     file format elf32-i386


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
  80002c:	e8 9f 09 00 00       	call   8009d0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int t;

	if (s == 0) {
  800043:	85 db                	test   %ebx,%ebx
  800045:	75 1e                	jne    800065 <_gettoken+0x31>
		if (debug > 1)
  800047:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  80004e:	0f 8e 19 01 00 00    	jle    80016d <_gettoken+0x139>
			cprintf("GETTOKEN NULL\n");
  800054:	c7 04 24 00 3b 80 00 	movl   $0x803b00,(%esp)
  80005b:	e8 d8 0a 00 00       	call   800b38 <cprintf>
  800060:	e9 1b 01 00 00       	jmp    800180 <_gettoken+0x14c>
		return 0;
	}

	if (debug > 1)
  800065:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  80006c:	7e 10                	jle    80007e <_gettoken+0x4a>
		cprintf("GETTOKEN: %s\n", s);
  80006e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800072:	c7 04 24 0f 3b 80 00 	movl   $0x803b0f,(%esp)
  800079:	e8 ba 0a 00 00       	call   800b38 <cprintf>

	*p1 = 0;
  80007e:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	*p2 = 0;
  800084:	8b 45 10             	mov    0x10(%ebp),%eax
  800087:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80008d:	eb 04                	jmp    800093 <_gettoken+0x5f>
		*s++ = 0;
  80008f:	c6 03 00             	movb   $0x0,(%ebx)
  800092:	43                   	inc    %ebx
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  800093:	0f be 03             	movsbl (%ebx),%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 1d 3b 80 00 	movl   $0x803b1d,(%esp)
  8000a1:	e8 17 12 00 00       	call   8012bd <strchr>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 e5                	jne    80008f <_gettoken+0x5b>
  8000aa:	89 de                	mov    %ebx,%esi
		*s++ = 0;
	if (*s == 0) {
  8000ac:	8a 03                	mov    (%ebx),%al
  8000ae:	84 c0                	test   %al,%al
  8000b0:	75 23                	jne    8000d5 <_gettoken+0xa1>
		if (debug > 1)
  8000b2:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  8000b9:	0f 8e b5 00 00 00    	jle    800174 <_gettoken+0x140>
			cprintf("EOL\n");
  8000bf:	c7 04 24 22 3b 80 00 	movl   $0x803b22,(%esp)
  8000c6:	e8 6d 0a 00 00       	call   800b38 <cprintf>
		return 0;
  8000cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8000d0:	e9 ab 00 00 00       	jmp    800180 <_gettoken+0x14c>
	}
	if (strchr(SYMBOLS, *s)) {
  8000d5:	0f be c0             	movsbl %al,%eax
  8000d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000dc:	c7 04 24 33 3b 80 00 	movl   $0x803b33,(%esp)
  8000e3:	e8 d5 11 00 00       	call   8012bd <strchr>
  8000e8:	85 c0                	test   %eax,%eax
  8000ea:	74 29                	je     800115 <_gettoken+0xe1>
		t = *s;
  8000ec:	0f be 1b             	movsbl (%ebx),%ebx
		*p1 = s;
  8000ef:	89 37                	mov    %esi,(%edi)
		*s++ = 0;
  8000f1:	c6 06 00             	movb   $0x0,(%esi)
  8000f4:	46                   	inc    %esi
  8000f5:	8b 55 10             	mov    0x10(%ebp),%edx
  8000f8:	89 32                	mov    %esi,(%edx)
		*p2 = s;
		if (debug > 1)
  8000fa:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800101:	7e 7d                	jle    800180 <_gettoken+0x14c>
			cprintf("TOK %c\n", t);
  800103:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800107:	c7 04 24 27 3b 80 00 	movl   $0x803b27,(%esp)
  80010e:	e8 25 0a 00 00       	call   800b38 <cprintf>
  800113:	eb 6b                	jmp    800180 <_gettoken+0x14c>
		return t;
	}
	*p1 = s;
  800115:	89 1f                	mov    %ebx,(%edi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800117:	eb 01                	jmp    80011a <_gettoken+0xe6>
		s++;
  800119:	43                   	inc    %ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80011a:	8a 03                	mov    (%ebx),%al
  80011c:	84 c0                	test   %al,%al
  80011e:	74 17                	je     800137 <_gettoken+0x103>
  800120:	0f be c0             	movsbl %al,%eax
  800123:	89 44 24 04          	mov    %eax,0x4(%esp)
  800127:	c7 04 24 2f 3b 80 00 	movl   $0x803b2f,(%esp)
  80012e:	e8 8a 11 00 00       	call   8012bd <strchr>
  800133:	85 c0                	test   %eax,%eax
  800135:	74 e2                	je     800119 <_gettoken+0xe5>
		s++;
	*p2 = s;
  800137:	8b 45 10             	mov    0x10(%ebp),%eax
  80013a:	89 18                	mov    %ebx,(%eax)
	if (debug > 1) {
  80013c:	83 3d 00 60 80 00 01 	cmpl   $0x1,0x806000
  800143:	7e 36                	jle    80017b <_gettoken+0x147>
		t = **p2;
  800145:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  800148:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  80014b:	8b 07                	mov    (%edi),%eax
  80014d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800151:	c7 04 24 3b 3b 80 00 	movl   $0x803b3b,(%esp)
  800158:	e8 db 09 00 00       	call   800b38 <cprintf>
		**p2 = t;
  80015d:	8b 55 10             	mov    0x10(%ebp),%edx
  800160:	8b 02                	mov    (%edx),%eax
  800162:	89 f2                	mov    %esi,%edx
  800164:	88 10                	mov    %dl,(%eax)
	}
	return 'w';
  800166:	bb 77 00 00 00       	mov    $0x77,%ebx
  80016b:	eb 13                	jmp    800180 <_gettoken+0x14c>
	int t;

	if (s == 0) {
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  80016d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800172:	eb 0c                	jmp    800180 <_gettoken+0x14c>
	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  800174:	bb 00 00 00 00       	mov    $0x0,%ebx
  800179:	eb 05                	jmp    800180 <_gettoken+0x14c>
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  80017b:	bb 77 00 00 00       	mov    $0x77,%ebx
}
  800180:	89 d8                	mov    %ebx,%eax
  800182:	83 c4 1c             	add    $0x1c,%esp
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    

0080018a <gettoken>:

int
gettoken(char *s, char **p1)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	83 ec 18             	sub    $0x18,%esp
  800190:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  800193:	85 c0                	test   %eax,%eax
  800195:	74 24                	je     8001bb <gettoken+0x31>
		nc = _gettoken(s, &np1, &np2);
  800197:	c7 44 24 08 08 60 80 	movl   $0x806008,0x8(%esp)
  80019e:	00 
  80019f:	c7 44 24 04 04 60 80 	movl   $0x806004,0x4(%esp)
  8001a6:	00 
  8001a7:	89 04 24             	mov    %eax,(%esp)
  8001aa:	e8 85 fe ff ff       	call   800034 <_gettoken>
  8001af:	a3 0c 60 80 00       	mov    %eax,0x80600c
		return 0;
  8001b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001b9:	eb 3c                	jmp    8001f7 <gettoken+0x6d>
	}
	c = nc;
  8001bb:	a1 0c 60 80 00       	mov    0x80600c,%eax
  8001c0:	a3 10 60 80 00       	mov    %eax,0x806010
	*p1 = np1;
  8001c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c8:	8b 15 04 60 80 00    	mov    0x806004,%edx
  8001ce:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001d0:	c7 44 24 08 08 60 80 	movl   $0x806008,0x8(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 04 04 60 80 	movl   $0x806004,0x4(%esp)
  8001df:	00 
  8001e0:	a1 08 60 80 00       	mov    0x806008,%eax
  8001e5:	89 04 24             	mov    %eax,(%esp)
  8001e8:	e8 47 fe ff ff       	call   800034 <_gettoken>
  8001ed:	a3 0c 60 80 00       	mov    %eax,0x80600c
	return c;
  8001f2:	a1 10 60 80 00       	mov    0x806010,%eax
}
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	57                   	push   %edi
  8001fd:	56                   	push   %esi
  8001fe:	53                   	push   %ebx
  8001ff:	81 ec 6c 04 00 00    	sub    $0x46c,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800205:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80020c:	00 
  80020d:	8b 45 08             	mov    0x8(%ebp),%eax
  800210:	89 04 24             	mov    %eax,(%esp)
  800213:	e8 72 ff ff ff       	call   80018a <gettoken>

again:
	argc = 0;
  800218:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80021d:	8d 5d a4             	lea    -0x5c(%ebp),%ebx
  800220:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800224:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80022b:	e8 5a ff ff ff       	call   80018a <gettoken>
  800230:	83 f8 77             	cmp    $0x77,%eax
  800233:	74 2e                	je     800263 <runcmd+0x6a>
  800235:	83 f8 77             	cmp    $0x77,%eax
  800238:	7f 1b                	jg     800255 <runcmd+0x5c>
  80023a:	83 f8 3c             	cmp    $0x3c,%eax
  80023d:	74 44                	je     800283 <runcmd+0x8a>
  80023f:	83 f8 3e             	cmp    $0x3e,%eax
  800242:	0f 84 bd 00 00 00    	je     800305 <runcmd+0x10c>
  800248:	85 c0                	test   %eax,%eax
  80024a:	0f 84 43 02 00 00    	je     800493 <runcmd+0x29a>
  800250:	e9 1e 02 00 00       	jmp    800473 <runcmd+0x27a>
  800255:	83 f8 7c             	cmp    $0x7c,%eax
  800258:	0f 85 15 02 00 00    	jne    800473 <runcmd+0x27a>
  80025e:	e9 23 01 00 00       	jmp    800386 <runcmd+0x18d>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  800263:	83 fe 10             	cmp    $0x10,%esi
  800266:	75 11                	jne    800279 <runcmd+0x80>
				cprintf("too many arguments\n");
  800268:	c7 04 24 45 3b 80 00 	movl   $0x803b45,(%esp)
  80026f:	e8 c4 08 00 00       	call   800b38 <cprintf>
				exit();
  800274:	e8 ab 07 00 00       	call   800a24 <exit>
			}
			argv[argc++] = t;
  800279:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80027c:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  800280:	46                   	inc    %esi
			break;
  800281:	eb 9d                	jmp    800220 <runcmd+0x27>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800283:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800287:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80028e:	e8 f7 fe ff ff       	call   80018a <gettoken>
  800293:	83 f8 77             	cmp    $0x77,%eax
  800296:	74 11                	je     8002a9 <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  800298:	c7 04 24 90 3c 80 00 	movl   $0x803c90,(%esp)
  80029f:	e8 94 08 00 00       	call   800b38 <cprintf>
				exit();
  8002a4:	e8 7b 07 00 00       	call   800a24 <exit>
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 5: Your code here.
			if ((fd = open(t, O_RDONLY)) < 0)
  8002a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002b0:	00 
  8002b1:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  8002b4:	89 04 24             	mov    %eax,(%esp)
  8002b7:	e8 c7 22 00 00       	call   802583 <open>
  8002bc:	89 c7                	mov    %eax,%edi
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	79 1e                	jns    8002e0 <runcmd+0xe7>
			{
				cprintf("open %s for read: %e", t, fd);
  8002c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c6:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  8002c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002cd:	c7 04 24 59 3b 80 00 	movl   $0x803b59,(%esp)
  8002d4:	e8 5f 08 00 00       	call   800b38 <cprintf>
				exit();
  8002d9:	e8 46 07 00 00       	call   800a24 <exit>
  8002de:	eb 08                	jmp    8002e8 <runcmd+0xef>
			}
			if (fd != 0)
  8002e0:	85 c0                	test   %eax,%eax
  8002e2:	0f 84 38 ff ff ff    	je     800220 <runcmd+0x27>
			{
				dup(fd, 0);
  8002e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002ef:	00 
  8002f0:	89 3c 24             	mov    %edi,(%esp)
  8002f3:	e8 a3 1c 00 00       	call   801f9b <dup>
				close(fd);
  8002f8:	89 3c 24             	mov    %edi,(%esp)
  8002fb:	e8 4a 1c 00 00       	call   801f4a <close>
  800300:	e9 1b ff ff ff       	jmp    800220 <runcmd+0x27>
			// panic("< redirection not implemented");
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800305:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800309:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800310:	e8 75 fe ff ff       	call   80018a <gettoken>
  800315:	83 f8 77             	cmp    $0x77,%eax
  800318:	74 11                	je     80032b <runcmd+0x132>
				cprintf("syntax error: > not followed by word\n");
  80031a:	c7 04 24 b8 3c 80 00 	movl   $0x803cb8,(%esp)
  800321:	e8 12 08 00 00       	call   800b38 <cprintf>
				exit();
  800326:	e8 f9 06 00 00       	call   800a24 <exit>
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  80032b:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
  800332:	00 
  800333:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  800336:	89 04 24             	mov    %eax,(%esp)
  800339:	e8 45 22 00 00       	call   802583 <open>
  80033e:	89 c7                	mov    %eax,%edi
  800340:	85 c0                	test   %eax,%eax
  800342:	79 1c                	jns    800360 <runcmd+0x167>
				cprintf("open %s for write: %e", t, fd);
  800344:	89 44 24 08          	mov    %eax,0x8(%esp)
  800348:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80034b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034f:	c7 04 24 6e 3b 80 00 	movl   $0x803b6e,(%esp)
  800356:	e8 dd 07 00 00       	call   800b38 <cprintf>
				exit();
  80035b:	e8 c4 06 00 00       	call   800a24 <exit>
			}
			if (fd != 1) {
  800360:	83 ff 01             	cmp    $0x1,%edi
  800363:	0f 84 b7 fe ff ff    	je     800220 <runcmd+0x27>
				dup(fd, 1);
  800369:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800370:	00 
  800371:	89 3c 24             	mov    %edi,(%esp)
  800374:	e8 22 1c 00 00       	call   801f9b <dup>
				close(fd);
  800379:	89 3c 24             	mov    %edi,(%esp)
  80037c:	e8 c9 1b 00 00       	call   801f4a <close>
  800381:	e9 9a fe ff ff       	jmp    800220 <runcmd+0x27>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  800386:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  80038c:	89 04 24             	mov    %eax,(%esp)
  80038f:	e8 09 31 00 00       	call   80349d <pipe>
  800394:	85 c0                	test   %eax,%eax
  800396:	79 15                	jns    8003ad <runcmd+0x1b4>
				cprintf("pipe: %e", r);
  800398:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039c:	c7 04 24 84 3b 80 00 	movl   $0x803b84,(%esp)
  8003a3:	e8 90 07 00 00       	call   800b38 <cprintf>
				exit();
  8003a8:	e8 77 06 00 00       	call   800a24 <exit>
			}
			if (debug)
  8003ad:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8003b4:	74 20                	je     8003d6 <runcmd+0x1dd>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003b6:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  8003bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c0:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8003c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ca:	c7 04 24 8d 3b 80 00 	movl   $0x803b8d,(%esp)
  8003d1:	e8 62 07 00 00       	call   800b38 <cprintf>
			if ((r = fork()) < 0) {
  8003d6:	e8 7c 15 00 00       	call   801957 <fork>
  8003db:	89 c7                	mov    %eax,%edi
  8003dd:	85 c0                	test   %eax,%eax
  8003df:	79 15                	jns    8003f6 <runcmd+0x1fd>
				cprintf("fork: %e", r);
  8003e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e5:	c7 04 24 d5 40 80 00 	movl   $0x8040d5,(%esp)
  8003ec:	e8 47 07 00 00       	call   800b38 <cprintf>
				exit();
  8003f1:	e8 2e 06 00 00       	call   800a24 <exit>
			}
			if (r == 0) {
  8003f6:	85 ff                	test   %edi,%edi
  8003f8:	75 40                	jne    80043a <runcmd+0x241>
				if (p[0] != 0) {
  8003fa:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800400:	85 c0                	test   %eax,%eax
  800402:	74 1e                	je     800422 <runcmd+0x229>
					dup(p[0], 0);
  800404:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80040b:	00 
  80040c:	89 04 24             	mov    %eax,(%esp)
  80040f:	e8 87 1b 00 00       	call   801f9b <dup>
					close(p[0]);
  800414:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  80041a:	89 04 24             	mov    %eax,(%esp)
  80041d:	e8 28 1b 00 00       	call   801f4a <close>
				}
				close(p[1]);
  800422:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800428:	89 04 24             	mov    %eax,(%esp)
  80042b:	e8 1a 1b 00 00       	call   801f4a <close>

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800430:	be 00 00 00 00       	mov    $0x0,%esi
				if (p[0] != 0) {
					dup(p[0], 0);
					close(p[0]);
				}
				close(p[1]);
				goto again;
  800435:	e9 e6 fd ff ff       	jmp    800220 <runcmd+0x27>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80043a:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800440:	83 f8 01             	cmp    $0x1,%eax
  800443:	74 1e                	je     800463 <runcmd+0x26a>
					dup(p[1], 1);
  800445:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80044c:	00 
  80044d:	89 04 24             	mov    %eax,(%esp)
  800450:	e8 46 1b 00 00       	call   801f9b <dup>
					close(p[1]);
  800455:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  80045b:	89 04 24             	mov    %eax,(%esp)
  80045e:	e8 e7 1a 00 00       	call   801f4a <close>
				}
				close(p[0]);
  800463:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800469:	89 04 24             	mov    %eax,(%esp)
  80046c:	e8 d9 1a 00 00       	call   801f4a <close>
				goto runit;
  800471:	eb 25                	jmp    800498 <runcmd+0x29f>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800473:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800477:	c7 44 24 08 9a 3b 80 	movl   $0x803b9a,0x8(%esp)
  80047e:	00 
  80047f:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  800486:	00 
  800487:	c7 04 24 b6 3b 80 00 	movl   $0x803bb6,(%esp)
  80048e:	e8 ad 05 00 00       	call   800a40 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  800493:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  800498:	85 f6                	test   %esi,%esi
  80049a:	75 1e                	jne    8004ba <runcmd+0x2c1>
		if (debug)
  80049c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8004a3:	0f 84 76 01 00 00    	je     80061f <runcmd+0x426>
			cprintf("EMPTY COMMAND\n");
  8004a9:	c7 04 24 c0 3b 80 00 	movl   $0x803bc0,(%esp)
  8004b0:	e8 83 06 00 00       	call   800b38 <cprintf>
  8004b5:	e9 65 01 00 00       	jmp    80061f <runcmd+0x426>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004ba:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004bd:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004c0:	74 22                	je     8004e4 <runcmd+0x2eb>
		argv0buf[0] = '/';
  8004c2:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004cd:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004d3:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004d9:	89 04 24             	mov    %eax,(%esp)
  8004dc:	e8 e2 0c 00 00       	call   8011c3 <strcpy>
		argv[0] = argv0buf;
  8004e1:	89 5d a8             	mov    %ebx,-0x58(%ebp)
	}
	argv[argc] = 0;
  8004e4:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004eb:	00 

	// Print the command.
	if (debug) {
  8004ec:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8004f3:	74 43                	je     800538 <runcmd+0x33f>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f5:	a1 28 64 80 00       	mov    0x806428,%eax
  8004fa:	8b 40 48             	mov    0x48(%eax),%eax
  8004fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800501:	c7 04 24 cf 3b 80 00 	movl   $0x803bcf,(%esp)
  800508:	e8 2b 06 00 00       	call   800b38 <cprintf>
  80050d:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  800510:	eb 10                	jmp    800522 <runcmd+0x329>
			cprintf(" %s", argv[i]);
  800512:	89 44 24 04          	mov    %eax,0x4(%esp)
  800516:	c7 04 24 5a 3c 80 00 	movl   $0x803c5a,(%esp)
  80051d:	e8 16 06 00 00       	call   800b38 <cprintf>
  800522:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800525:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800528:	85 c0                	test   %eax,%eax
  80052a:	75 e6                	jne    800512 <runcmd+0x319>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  80052c:	c7 04 24 20 3b 80 00 	movl   $0x803b20,(%esp)
  800533:	e8 00 06 00 00       	call   800b38 <cprintf>
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  800538:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80053b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053f:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800542:	89 04 24             	mov    %eax,(%esp)
  800545:	e8 12 22 00 00       	call   80275c <spawn>
  80054a:	89 c3                	mov    %eax,%ebx
  80054c:	85 c0                	test   %eax,%eax
  80054e:	79 1e                	jns    80056e <runcmd+0x375>
		cprintf("spawn %s: %e\n", argv[0], r);
  800550:	89 44 24 08          	mov    %eax,0x8(%esp)
  800554:	8b 45 a8             	mov    -0x58(%ebp),%eax
  800557:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055b:	c7 04 24 dd 3b 80 00 	movl   $0x803bdd,(%esp)
  800562:	e8 d1 05 00 00       	call   800b38 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800567:	e8 0f 1a 00 00       	call   801f7b <close_all>
  80056c:	eb 5a                	jmp    8005c8 <runcmd+0x3cf>
  80056e:	e8 08 1a 00 00       	call   801f7b <close_all>
	if (r >= 0) {
		if (debug)
  800573:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80057a:	74 23                	je     80059f <runcmd+0x3a6>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  80057c:	a1 28 64 80 00       	mov    0x806428,%eax
  800581:	8b 40 48             	mov    0x48(%eax),%eax
  800584:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800588:	8b 55 a8             	mov    -0x58(%ebp),%edx
  80058b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80058f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800593:	c7 04 24 eb 3b 80 00 	movl   $0x803beb,(%esp)
  80059a:	e8 99 05 00 00       	call   800b38 <cprintf>
		wait(r);
  80059f:	89 1c 24             	mov    %ebx,(%esp)
  8005a2:	e8 99 30 00 00       	call   803640 <wait>
		if (debug)
  8005a7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8005ae:	74 18                	je     8005c8 <runcmd+0x3cf>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005b0:	a1 28 64 80 00       	mov    0x806428,%eax
  8005b5:	8b 40 48             	mov    0x48(%eax),%eax
  8005b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bc:	c7 04 24 00 3c 80 00 	movl   $0x803c00,(%esp)
  8005c3:	e8 70 05 00 00       	call   800b38 <cprintf>
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005c8:	85 ff                	test   %edi,%edi
  8005ca:	74 4e                	je     80061a <runcmd+0x421>
		if (debug)
  8005cc:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8005d3:	74 1c                	je     8005f1 <runcmd+0x3f8>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005d5:	a1 28 64 80 00       	mov    0x806428,%eax
  8005da:	8b 40 48             	mov    0x48(%eax),%eax
  8005dd:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8005e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e5:	c7 04 24 16 3c 80 00 	movl   $0x803c16,(%esp)
  8005ec:	e8 47 05 00 00       	call   800b38 <cprintf>
		wait(pipe_child);
  8005f1:	89 3c 24             	mov    %edi,(%esp)
  8005f4:	e8 47 30 00 00       	call   803640 <wait>
		if (debug)
  8005f9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800600:	74 18                	je     80061a <runcmd+0x421>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800602:	a1 28 64 80 00       	mov    0x806428,%eax
  800607:	8b 40 48             	mov    0x48(%eax),%eax
  80060a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060e:	c7 04 24 00 3c 80 00 	movl   $0x803c00,(%esp)
  800615:	e8 1e 05 00 00       	call   800b38 <cprintf>
	}

	// Done!
	exit();
  80061a:	e8 05 04 00 00       	call   800a24 <exit>
}
  80061f:	81 c4 6c 04 00 00    	add    $0x46c,%esp
  800625:	5b                   	pop    %ebx
  800626:	5e                   	pop    %esi
  800627:	5f                   	pop    %edi
  800628:	5d                   	pop    %ebp
  800629:	c3                   	ret    

0080062a <usage>:
}


void
usage(void)
{
  80062a:	55                   	push   %ebp
  80062b:	89 e5                	mov    %esp,%ebp
  80062d:	83 ec 18             	sub    $0x18,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800630:	c7 04 24 e0 3c 80 00 	movl   $0x803ce0,(%esp)
  800637:	e8 fc 04 00 00       	call   800b38 <cprintf>
	exit();
  80063c:	e8 e3 03 00 00       	call   800a24 <exit>
}
  800641:	c9                   	leave  
  800642:	c3                   	ret    

00800643 <umain>:

void
umain(int argc, char **argv)
{
  800643:	55                   	push   %ebp
  800644:	89 e5                	mov    %esp,%ebp
  800646:	57                   	push   %edi
  800647:	56                   	push   %esi
  800648:	53                   	push   %ebx
  800649:	83 ec 4c             	sub    $0x4c,%esp
  80064c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  80064f:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800652:	89 44 24 08          	mov    %eax,0x8(%esp)
  800656:	89 74 24 04          	mov    %esi,0x4(%esp)
  80065a:	8d 45 08             	lea    0x8(%ebp),%eax
  80065d:	89 04 24             	mov    %eax,(%esp)
  800660:	e8 d7 15 00 00       	call   801c3c <argstart>
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800665:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80066c:	bf 3f 00 00 00       	mov    $0x3f,%edi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800671:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800674:	eb 2e                	jmp    8006a4 <umain+0x61>
		switch (r) {
  800676:	83 f8 69             	cmp    $0x69,%eax
  800679:	74 0c                	je     800687 <umain+0x44>
  80067b:	83 f8 78             	cmp    $0x78,%eax
  80067e:	74 1d                	je     80069d <umain+0x5a>
  800680:	83 f8 64             	cmp    $0x64,%eax
  800683:	75 11                	jne    800696 <umain+0x53>
  800685:	eb 07                	jmp    80068e <umain+0x4b>
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  800687:	bf 01 00 00 00       	mov    $0x1,%edi
  80068c:	eb 16                	jmp    8006a4 <umain+0x61>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  80068e:	ff 05 00 60 80 00    	incl   0x806000
			break;
  800694:	eb 0e                	jmp    8006a4 <umain+0x61>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  800696:	e8 8f ff ff ff       	call   80062a <usage>
  80069b:	eb 07                	jmp    8006a4 <umain+0x61>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  80069d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006a4:	89 1c 24             	mov    %ebx,(%esp)
  8006a7:	e8 c9 15 00 00       	call   801c75 <argnext>
  8006ac:	85 c0                	test   %eax,%eax
  8006ae:	79 c6                	jns    800676 <umain+0x33>
  8006b0:	89 fb                	mov    %edi,%ebx
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006b2:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006b6:	7e 05                	jle    8006bd <umain+0x7a>
		usage();
  8006b8:	e8 6d ff ff ff       	call   80062a <usage>
	if (argc == 2) {
  8006bd:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006c1:	75 72                	jne    800735 <umain+0xf2>
		close(0);
  8006c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006ca:	e8 7b 18 00 00       	call   801f4a <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8006d6:	00 
  8006d7:	8b 46 04             	mov    0x4(%esi),%eax
  8006da:	89 04 24             	mov    %eax,(%esp)
  8006dd:	e8 a1 1e 00 00       	call   802583 <open>
  8006e2:	85 c0                	test   %eax,%eax
  8006e4:	79 27                	jns    80070d <umain+0xca>
			panic("open %s: %e", argv[1], r);
  8006e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ea:	8b 46 04             	mov    0x4(%esi),%eax
  8006ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006f1:	c7 44 24 08 36 3c 80 	movl   $0x803c36,0x8(%esp)
  8006f8:	00 
  8006f9:	c7 44 24 04 2a 01 00 	movl   $0x12a,0x4(%esp)
  800700:	00 
  800701:	c7 04 24 b6 3b 80 00 	movl   $0x803bb6,(%esp)
  800708:	e8 33 03 00 00       	call   800a40 <_panic>
		assert(r == 0);
  80070d:	85 c0                	test   %eax,%eax
  80070f:	74 24                	je     800735 <umain+0xf2>
  800711:	c7 44 24 0c 42 3c 80 	movl   $0x803c42,0xc(%esp)
  800718:	00 
  800719:	c7 44 24 08 49 3c 80 	movl   $0x803c49,0x8(%esp)
  800720:	00 
  800721:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
  800728:	00 
  800729:	c7 04 24 b6 3b 80 00 	movl   $0x803bb6,(%esp)
  800730:	e8 0b 03 00 00       	call   800a40 <_panic>
	}
	if (interactive == '?')
  800735:	83 fb 3f             	cmp    $0x3f,%ebx
  800738:	75 0e                	jne    800748 <umain+0x105>
		interactive = iscons(0);
  80073a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800741:	e8 07 02 00 00       	call   80094d <iscons>
  800746:	89 c7                	mov    %eax,%edi

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  800748:	85 ff                	test   %edi,%edi
  80074a:	74 07                	je     800753 <umain+0x110>
  80074c:	b8 33 3c 80 00       	mov    $0x803c33,%eax
  800751:	eb 05                	jmp    800758 <umain+0x115>
  800753:	b8 00 00 00 00       	mov    $0x0,%eax
  800758:	89 04 24             	mov    %eax,(%esp)
  80075b:	e8 50 09 00 00       	call   8010b0 <readline>
  800760:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800762:	85 c0                	test   %eax,%eax
  800764:	75 1a                	jne    800780 <umain+0x13d>
			if (debug)
  800766:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80076d:	74 0c                	je     80077b <umain+0x138>
				cprintf("EXITING\n");
  80076f:	c7 04 24 5e 3c 80 00 	movl   $0x803c5e,(%esp)
  800776:	e8 bd 03 00 00       	call   800b38 <cprintf>
			exit();	// end of file
  80077b:	e8 a4 02 00 00       	call   800a24 <exit>
		}
		if (debug)
  800780:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800787:	74 10                	je     800799 <umain+0x156>
			cprintf("LINE: %s\n", buf);
  800789:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80078d:	c7 04 24 67 3c 80 00 	movl   $0x803c67,(%esp)
  800794:	e8 9f 03 00 00       	call   800b38 <cprintf>
		if (buf[0] == '#')
  800799:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079c:	74 aa                	je     800748 <umain+0x105>
			continue;
		if (echocmds)
  80079e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a2:	74 10                	je     8007b4 <umain+0x171>
			printf("# %s\n", buf);
  8007a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a8:	c7 04 24 71 3c 80 00 	movl   $0x803c71,(%esp)
  8007af:	e8 85 1f 00 00       	call   802739 <printf>
		if (debug)
  8007b4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8007bb:	74 0c                	je     8007c9 <umain+0x186>
			cprintf("BEFORE FORK\n");
  8007bd:	c7 04 24 77 3c 80 00 	movl   $0x803c77,(%esp)
  8007c4:	e8 6f 03 00 00       	call   800b38 <cprintf>
		if ((r = fork()) < 0)
  8007c9:	e8 89 11 00 00       	call   801957 <fork>
  8007ce:	89 c6                	mov    %eax,%esi
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	79 20                	jns    8007f4 <umain+0x1b1>
			panic("fork: %e", r);
  8007d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d8:	c7 44 24 08 d5 40 80 	movl   $0x8040d5,0x8(%esp)
  8007df:	00 
  8007e0:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
  8007e7:	00 
  8007e8:	c7 04 24 b6 3b 80 00 	movl   $0x803bb6,(%esp)
  8007ef:	e8 4c 02 00 00       	call   800a40 <_panic>
		if (debug)
  8007f4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8007fb:	74 10                	je     80080d <umain+0x1ca>
			cprintf("FORK: %d\n", r);
  8007fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800801:	c7 04 24 84 3c 80 00 	movl   $0x803c84,(%esp)
  800808:	e8 2b 03 00 00       	call   800b38 <cprintf>
		if (r == 0) {
  80080d:	85 f6                	test   %esi,%esi
  80080f:	75 12                	jne    800823 <umain+0x1e0>
			runcmd(buf);
  800811:	89 1c 24             	mov    %ebx,(%esp)
  800814:	e8 e0 f9 ff ff       	call   8001f9 <runcmd>
			exit();
  800819:	e8 06 02 00 00       	call   800a24 <exit>
  80081e:	e9 25 ff ff ff       	jmp    800748 <umain+0x105>
		} else
			wait(r);
  800823:	89 34 24             	mov    %esi,(%esp)
  800826:	e8 15 2e 00 00       	call   803640 <wait>
  80082b:	e9 18 ff ff ff       	jmp    800748 <umain+0x105>

00800830 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800833:	b8 00 00 00 00       	mov    $0x0,%eax
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  800840:	c7 44 24 04 01 3d 80 	movl   $0x803d01,0x4(%esp)
  800847:	00 
  800848:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084b:	89 04 24             	mov    %eax,(%esp)
  80084e:	e8 70 09 00 00       	call   8011c3 <strcpy>
	return 0;
}
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	c9                   	leave  
  800859:	c3                   	ret    

0080085a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	57                   	push   %edi
  80085e:	56                   	push   %esi
  80085f:	53                   	push   %ebx
  800860:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800866:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80086b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800871:	eb 30                	jmp    8008a3 <devcons_write+0x49>
		m = n - tot;
  800873:	8b 75 10             	mov    0x10(%ebp),%esi
  800876:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  800878:	83 fe 7f             	cmp    $0x7f,%esi
  80087b:	76 05                	jbe    800882 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80087d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800882:	89 74 24 08          	mov    %esi,0x8(%esp)
  800886:	03 45 0c             	add    0xc(%ebp),%eax
  800889:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088d:	89 3c 24             	mov    %edi,(%esp)
  800890:	e8 a7 0a 00 00       	call   80133c <memmove>
		sys_cputs(buf, m);
  800895:	89 74 24 04          	mov    %esi,0x4(%esp)
  800899:	89 3c 24             	mov    %edi,(%esp)
  80089c:	e8 47 0c 00 00       	call   8014e8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8008a1:	01 f3                	add    %esi,%ebx
  8008a3:	89 d8                	mov    %ebx,%eax
  8008a5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8008a8:	72 c9                	jb     800873 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008aa:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8008b0:	5b                   	pop    %ebx
  8008b1:	5e                   	pop    %esi
  8008b2:	5f                   	pop    %edi
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8008bb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008bf:	75 07                	jne    8008c8 <devcons_read+0x13>
  8008c1:	eb 25                	jmp    8008e8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008c3:	e8 ce 0c 00 00       	call   801596 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c8:	e8 39 0c 00 00       	call   801506 <sys_cgetc>
  8008cd:	85 c0                	test   %eax,%eax
  8008cf:	74 f2                	je     8008c3 <devcons_read+0xe>
  8008d1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8008d3:	85 c0                	test   %eax,%eax
  8008d5:	78 1d                	js     8008f4 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008d7:	83 f8 04             	cmp    $0x4,%eax
  8008da:	74 13                	je     8008ef <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008df:	88 10                	mov    %dl,(%eax)
	return 1;
  8008e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8008e6:	eb 0c                	jmp    8008f4 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8008e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ed:	eb 05                	jmp    8008f4 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008f4:	c9                   	leave  
  8008f5:	c3                   	ret    

008008f6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8008fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ff:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800902:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800909:	00 
  80090a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80090d:	89 04 24             	mov    %eax,(%esp)
  800910:	e8 d3 0b 00 00       	call   8014e8 <sys_cputs>
}
  800915:	c9                   	leave  
  800916:	c3                   	ret    

00800917 <getchar>:

int
getchar(void)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80091d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  800924:	00 
  800925:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800928:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800933:	e8 78 17 00 00       	call   8020b0 <read>
	if (r < 0)
  800938:	85 c0                	test   %eax,%eax
  80093a:	78 0f                	js     80094b <getchar+0x34>
		return r;
	if (r < 1)
  80093c:	85 c0                	test   %eax,%eax
  80093e:	7e 06                	jle    800946 <getchar+0x2f>
		return -E_EOF;
	return c;
  800940:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800944:	eb 05                	jmp    80094b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800946:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800953:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800956:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	89 04 24             	mov    %eax,(%esp)
  800960:	e8 ad 14 00 00       	call   801e12 <fd_lookup>
  800965:	85 c0                	test   %eax,%eax
  800967:	78 11                	js     80097a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800969:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80096c:	8b 15 00 50 80 00    	mov    0x805000,%edx
  800972:	39 10                	cmp    %edx,(%eax)
  800974:	0f 94 c0             	sete   %al
  800977:	0f b6 c0             	movzbl %al,%eax
}
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <opencons>:

int
opencons(void)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800982:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800985:	89 04 24             	mov    %eax,(%esp)
  800988:	e8 32 14 00 00       	call   801dbf <fd_alloc>
  80098d:	85 c0                	test   %eax,%eax
  80098f:	78 3c                	js     8009cd <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800991:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800998:	00 
  800999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009a7:	e8 09 0c 00 00       	call   8015b5 <sys_page_alloc>
  8009ac:	85 c0                	test   %eax,%eax
  8009ae:	78 1d                	js     8009cd <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8009b0:	8b 15 00 50 80 00    	mov    0x805000,%edx
  8009b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009be:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009c5:	89 04 24             	mov    %eax,(%esp)
  8009c8:	e8 c7 13 00 00       	call   801d94 <fd2num>
}
  8009cd:	c9                   	leave  
  8009ce:	c3                   	ret    
	...

008009d0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	56                   	push   %esi
  8009d4:	53                   	push   %ebx
  8009d5:	83 ec 10             	sub    $0x10,%esp
  8009d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8009db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8009de:	e8 94 0b 00 00       	call   801577 <sys_getenvid>
  8009e3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009e8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8009ef:	c1 e0 07             	shl    $0x7,%eax
  8009f2:	29 d0                	sub    %edx,%eax
  8009f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009f9:	a3 28 64 80 00       	mov    %eax,0x806428


	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009fe:	85 f6                	test   %esi,%esi
  800a00:	7e 07                	jle    800a09 <libmain+0x39>
		binaryname = argv[0];
  800a02:	8b 03                	mov    (%ebx),%eax
  800a04:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// call user main routine
	umain(argc, argv);
  800a09:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a0d:	89 34 24             	mov    %esi,(%esp)
  800a10:	e8 2e fc ff ff       	call   800643 <umain>

	// exit gracefully
	exit();
  800a15:	e8 0a 00 00 00       	call   800a24 <exit>
}
  800a1a:	83 c4 10             	add    $0x10,%esp
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    
  800a21:	00 00                	add    %al,(%eax)
	...

00800a24 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800a2a:	e8 4c 15 00 00       	call   801f7b <close_all>
	sys_env_destroy(0);
  800a2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a36:	e8 ea 0a 00 00       	call   801525 <sys_env_destroy>
}
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    
  800a3d:	00 00                	add    %al,(%eax)
	...

00800a40 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
  800a45:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800a48:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a4b:	8b 1d 1c 50 80 00    	mov    0x80501c,%ebx
  800a51:	e8 21 0b 00 00       	call   801577 <sys_getenvid>
  800a56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a59:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a60:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a64:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a68:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6c:	c7 04 24 18 3d 80 00 	movl   $0x803d18,(%esp)
  800a73:	e8 c0 00 00 00       	call   800b38 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a78:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7f:	89 04 24             	mov    %eax,(%esp)
  800a82:	e8 50 00 00 00       	call   800ad7 <vcprintf>
	cprintf("\n");
  800a87:	c7 04 24 20 3b 80 00 	movl   $0x803b20,(%esp)
  800a8e:	e8 a5 00 00 00       	call   800b38 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a93:	cc                   	int3   
  800a94:	eb fd                	jmp    800a93 <_panic+0x53>
	...

00800a98 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	53                   	push   %ebx
  800a9c:	83 ec 14             	sub    $0x14,%esp
  800a9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800aa2:	8b 03                	mov    (%ebx),%eax
  800aa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800aab:	40                   	inc    %eax
  800aac:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800aae:	3d ff 00 00 00       	cmp    $0xff,%eax
  800ab3:	75 19                	jne    800ace <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800ab5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800abc:	00 
  800abd:	8d 43 08             	lea    0x8(%ebx),%eax
  800ac0:	89 04 24             	mov    %eax,(%esp)
  800ac3:	e8 20 0a 00 00       	call   8014e8 <sys_cputs>
		b->idx = 0;
  800ac8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800ace:	ff 43 04             	incl   0x4(%ebx)
}
  800ad1:	83 c4 14             	add    $0x14,%esp
  800ad4:	5b                   	pop    %ebx
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800ae0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800ae7:	00 00 00 
	b.cnt = 0;
  800aea:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800af1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b02:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800b08:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b0c:	c7 04 24 98 0a 80 00 	movl   $0x800a98,(%esp)
  800b13:	e8 82 01 00 00       	call   800c9a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b18:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b22:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b28:	89 04 24             	mov    %eax,(%esp)
  800b2b:	e8 b8 09 00 00       	call   8014e8 <sys_cputs>

	return b.cnt;
}
  800b30:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b36:	c9                   	leave  
  800b37:	c3                   	ret    

00800b38 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b3e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b41:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
  800b48:	89 04 24             	mov    %eax,(%esp)
  800b4b:	e8 87 ff ff ff       	call   800ad7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800b50:	c9                   	leave  
  800b51:	c3                   	ret    
	...

00800b54 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	57                   	push   %edi
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
  800b5a:	83 ec 3c             	sub    $0x3c,%esp
  800b5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b60:	89 d7                	mov    %edx,%edi
  800b62:	8b 45 08             	mov    0x8(%ebp),%eax
  800b65:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b6e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800b71:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b74:	85 c0                	test   %eax,%eax
  800b76:	75 08                	jne    800b80 <printnum+0x2c>
  800b78:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b7b:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b7e:	77 57                	ja     800bd7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b80:	89 74 24 10          	mov    %esi,0x10(%esp)
  800b84:	4b                   	dec    %ebx
  800b85:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800b89:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b90:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800b94:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800b98:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b9f:	00 
  800ba0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800ba3:	89 04 24             	mov    %eax,(%esp)
  800ba6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ba9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bad:	e8 ea 2c 00 00       	call   80389c <__udivdi3>
  800bb2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800bb6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800bba:	89 04 24             	mov    %eax,(%esp)
  800bbd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bc1:	89 fa                	mov    %edi,%edx
  800bc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800bc6:	e8 89 ff ff ff       	call   800b54 <printnum>
  800bcb:	eb 0f                	jmp    800bdc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800bcd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bd1:	89 34 24             	mov    %esi,(%esp)
  800bd4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800bd7:	4b                   	dec    %ebx
  800bd8:	85 db                	test   %ebx,%ebx
  800bda:	7f f1                	jg     800bcd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800bdc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800be0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800be4:	8b 45 10             	mov    0x10(%ebp),%eax
  800be7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800beb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800bf2:	00 
  800bf3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800bf6:	89 04 24             	mov    %eax,(%esp)
  800bf9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800bfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c00:	e8 b7 2d 00 00       	call   8039bc <__umoddi3>
  800c05:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c09:	0f be 80 3b 3d 80 00 	movsbl 0x803d3b(%eax),%eax
  800c10:	89 04 24             	mov    %eax,(%esp)
  800c13:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800c16:	83 c4 3c             	add    $0x3c,%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800c21:	83 fa 01             	cmp    $0x1,%edx
  800c24:	7e 0e                	jle    800c34 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800c26:	8b 10                	mov    (%eax),%edx
  800c28:	8d 4a 08             	lea    0x8(%edx),%ecx
  800c2b:	89 08                	mov    %ecx,(%eax)
  800c2d:	8b 02                	mov    (%edx),%eax
  800c2f:	8b 52 04             	mov    0x4(%edx),%edx
  800c32:	eb 22                	jmp    800c56 <getuint+0x38>
	else if (lflag)
  800c34:	85 d2                	test   %edx,%edx
  800c36:	74 10                	je     800c48 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800c38:	8b 10                	mov    (%eax),%edx
  800c3a:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c3d:	89 08                	mov    %ecx,(%eax)
  800c3f:	8b 02                	mov    (%edx),%eax
  800c41:	ba 00 00 00 00       	mov    $0x0,%edx
  800c46:	eb 0e                	jmp    800c56 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800c48:	8b 10                	mov    (%eax),%edx
  800c4a:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c4d:	89 08                	mov    %ecx,(%eax)
  800c4f:	8b 02                	mov    (%edx),%eax
  800c51:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c5e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800c61:	8b 10                	mov    (%eax),%edx
  800c63:	3b 50 04             	cmp    0x4(%eax),%edx
  800c66:	73 08                	jae    800c70 <sprintputch+0x18>
		*b->buf++ = ch;
  800c68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6b:	88 0a                	mov    %cl,(%edx)
  800c6d:	42                   	inc    %edx
  800c6e:	89 10                	mov    %edx,(%eax)
}
  800c70:	5d                   	pop    %ebp
  800c71:	c3                   	ret    

00800c72 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c78:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c7f:	8b 45 10             	mov    0x10(%ebp),%eax
  800c82:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c89:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c90:	89 04 24             	mov    %eax,(%esp)
  800c93:	e8 02 00 00 00       	call   800c9a <vprintfmt>
	va_end(ap);
}
  800c98:	c9                   	leave  
  800c99:	c3                   	ret    

00800c9a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 4c             	sub    $0x4c,%esp
  800ca3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ca6:	8b 75 10             	mov    0x10(%ebp),%esi
  800ca9:	eb 12                	jmp    800cbd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800cab:	85 c0                	test   %eax,%eax
  800cad:	0f 84 6b 03 00 00    	je     80101e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800cb3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cb7:	89 04 24             	mov    %eax,(%esp)
  800cba:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800cbd:	0f b6 06             	movzbl (%esi),%eax
  800cc0:	46                   	inc    %esi
  800cc1:	83 f8 25             	cmp    $0x25,%eax
  800cc4:	75 e5                	jne    800cab <vprintfmt+0x11>
  800cc6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800cca:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800cd1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800cd6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800cdd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce2:	eb 26                	jmp    800d0a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ce4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800ce7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800ceb:	eb 1d                	jmp    800d0a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ced:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800cf0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800cf4:	eb 14                	jmp    800d0a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cf6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800cf9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800d00:	eb 08                	jmp    800d0a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800d02:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800d05:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d0a:	0f b6 06             	movzbl (%esi),%eax
  800d0d:	8d 56 01             	lea    0x1(%esi),%edx
  800d10:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800d13:	8a 16                	mov    (%esi),%dl
  800d15:	83 ea 23             	sub    $0x23,%edx
  800d18:	80 fa 55             	cmp    $0x55,%dl
  800d1b:	0f 87 e1 02 00 00    	ja     801002 <vprintfmt+0x368>
  800d21:	0f b6 d2             	movzbl %dl,%edx
  800d24:	ff 24 95 80 3e 80 00 	jmp    *0x803e80(,%edx,4)
  800d2b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d2e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800d33:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800d36:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800d3a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800d3d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800d40:	83 fa 09             	cmp    $0x9,%edx
  800d43:	77 2a                	ja     800d6f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800d45:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800d46:	eb eb                	jmp    800d33 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800d48:	8b 45 14             	mov    0x14(%ebp),%eax
  800d4b:	8d 50 04             	lea    0x4(%eax),%edx
  800d4e:	89 55 14             	mov    %edx,0x14(%ebp)
  800d51:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d53:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800d56:	eb 17                	jmp    800d6f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800d58:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d5c:	78 98                	js     800cf6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d5e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d61:	eb a7                	jmp    800d0a <vprintfmt+0x70>
  800d63:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d66:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800d6d:	eb 9b                	jmp    800d0a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800d6f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d73:	79 95                	jns    800d0a <vprintfmt+0x70>
  800d75:	eb 8b                	jmp    800d02 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d77:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d78:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d7b:	eb 8d                	jmp    800d0a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d7d:	8b 45 14             	mov    0x14(%ebp),%eax
  800d80:	8d 50 04             	lea    0x4(%eax),%edx
  800d83:	89 55 14             	mov    %edx,0x14(%ebp)
  800d86:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d8a:	8b 00                	mov    (%eax),%eax
  800d8c:	89 04 24             	mov    %eax,(%esp)
  800d8f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d92:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d95:	e9 23 ff ff ff       	jmp    800cbd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d9a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d9d:	8d 50 04             	lea    0x4(%eax),%edx
  800da0:	89 55 14             	mov    %edx,0x14(%ebp)
  800da3:	8b 00                	mov    (%eax),%eax
  800da5:	85 c0                	test   %eax,%eax
  800da7:	79 02                	jns    800dab <vprintfmt+0x111>
  800da9:	f7 d8                	neg    %eax
  800dab:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800dad:	83 f8 10             	cmp    $0x10,%eax
  800db0:	7f 0b                	jg     800dbd <vprintfmt+0x123>
  800db2:	8b 04 85 e0 3f 80 00 	mov    0x803fe0(,%eax,4),%eax
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	75 23                	jne    800de0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800dbd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dc1:	c7 44 24 08 53 3d 80 	movl   $0x803d53,0x8(%esp)
  800dc8:	00 
  800dc9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd0:	89 04 24             	mov    %eax,(%esp)
  800dd3:	e8 9a fe ff ff       	call   800c72 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dd8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800ddb:	e9 dd fe ff ff       	jmp    800cbd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800de0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800de4:	c7 44 24 08 5b 3c 80 	movl   $0x803c5b,0x8(%esp)
  800deb:	00 
  800dec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	89 14 24             	mov    %edx,(%esp)
  800df6:	e8 77 fe ff ff       	call   800c72 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800dfb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800dfe:	e9 ba fe ff ff       	jmp    800cbd <vprintfmt+0x23>
  800e03:	89 f9                	mov    %edi,%ecx
  800e05:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e08:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800e0b:	8b 45 14             	mov    0x14(%ebp),%eax
  800e0e:	8d 50 04             	lea    0x4(%eax),%edx
  800e11:	89 55 14             	mov    %edx,0x14(%ebp)
  800e14:	8b 30                	mov    (%eax),%esi
  800e16:	85 f6                	test   %esi,%esi
  800e18:	75 05                	jne    800e1f <vprintfmt+0x185>
				p = "(null)";
  800e1a:	be 4c 3d 80 00       	mov    $0x803d4c,%esi
			if (width > 0 && padc != '-')
  800e1f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800e23:	0f 8e 84 00 00 00    	jle    800ead <vprintfmt+0x213>
  800e29:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800e2d:	74 7e                	je     800ead <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e2f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e33:	89 34 24             	mov    %esi,(%esp)
  800e36:	e8 6b 03 00 00       	call   8011a6 <strnlen>
  800e3b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800e3e:	29 c2                	sub    %eax,%edx
  800e40:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800e43:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800e47:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800e4a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800e4d:	89 de                	mov    %ebx,%esi
  800e4f:	89 d3                	mov    %edx,%ebx
  800e51:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e53:	eb 0b                	jmp    800e60 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800e55:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e59:	89 3c 24             	mov    %edi,(%esp)
  800e5c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e5f:	4b                   	dec    %ebx
  800e60:	85 db                	test   %ebx,%ebx
  800e62:	7f f1                	jg     800e55 <vprintfmt+0x1bb>
  800e64:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800e67:	89 f3                	mov    %esi,%ebx
  800e69:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800e6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	79 05                	jns    800e78 <vprintfmt+0x1de>
  800e73:	b8 00 00 00 00       	mov    $0x0,%eax
  800e78:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e7b:	29 c2                	sub    %eax,%edx
  800e7d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e80:	eb 2b                	jmp    800ead <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e82:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e86:	74 18                	je     800ea0 <vprintfmt+0x206>
  800e88:	8d 50 e0             	lea    -0x20(%eax),%edx
  800e8b:	83 fa 5e             	cmp    $0x5e,%edx
  800e8e:	76 10                	jbe    800ea0 <vprintfmt+0x206>
					putch('?', putdat);
  800e90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e94:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800e9b:	ff 55 08             	call   *0x8(%ebp)
  800e9e:	eb 0a                	jmp    800eaa <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800ea0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ea4:	89 04 24             	mov    %eax,(%esp)
  800ea7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800eaa:	ff 4d e4             	decl   -0x1c(%ebp)
  800ead:	0f be 06             	movsbl (%esi),%eax
  800eb0:	46                   	inc    %esi
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	74 21                	je     800ed6 <vprintfmt+0x23c>
  800eb5:	85 ff                	test   %edi,%edi
  800eb7:	78 c9                	js     800e82 <vprintfmt+0x1e8>
  800eb9:	4f                   	dec    %edi
  800eba:	79 c6                	jns    800e82 <vprintfmt+0x1e8>
  800ebc:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ebf:	89 de                	mov    %ebx,%esi
  800ec1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ec4:	eb 18                	jmp    800ede <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800ec6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eca:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800ed1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ed3:	4b                   	dec    %ebx
  800ed4:	eb 08                	jmp    800ede <vprintfmt+0x244>
  800ed6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ed9:	89 de                	mov    %ebx,%esi
  800edb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800ede:	85 db                	test   %ebx,%ebx
  800ee0:	7f e4                	jg     800ec6 <vprintfmt+0x22c>
  800ee2:	89 7d 08             	mov    %edi,0x8(%ebp)
  800ee5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ee7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800eea:	e9 ce fd ff ff       	jmp    800cbd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800eef:	83 f9 01             	cmp    $0x1,%ecx
  800ef2:	7e 10                	jle    800f04 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800ef4:	8b 45 14             	mov    0x14(%ebp),%eax
  800ef7:	8d 50 08             	lea    0x8(%eax),%edx
  800efa:	89 55 14             	mov    %edx,0x14(%ebp)
  800efd:	8b 30                	mov    (%eax),%esi
  800eff:	8b 78 04             	mov    0x4(%eax),%edi
  800f02:	eb 26                	jmp    800f2a <vprintfmt+0x290>
	else if (lflag)
  800f04:	85 c9                	test   %ecx,%ecx
  800f06:	74 12                	je     800f1a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800f08:	8b 45 14             	mov    0x14(%ebp),%eax
  800f0b:	8d 50 04             	lea    0x4(%eax),%edx
  800f0e:	89 55 14             	mov    %edx,0x14(%ebp)
  800f11:	8b 30                	mov    (%eax),%esi
  800f13:	89 f7                	mov    %esi,%edi
  800f15:	c1 ff 1f             	sar    $0x1f,%edi
  800f18:	eb 10                	jmp    800f2a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800f1a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1d:	8d 50 04             	lea    0x4(%eax),%edx
  800f20:	89 55 14             	mov    %edx,0x14(%ebp)
  800f23:	8b 30                	mov    (%eax),%esi
  800f25:	89 f7                	mov    %esi,%edi
  800f27:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f2a:	85 ff                	test   %edi,%edi
  800f2c:	78 0a                	js     800f38 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800f2e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f33:	e9 8c 00 00 00       	jmp    800fc4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800f38:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f3c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800f43:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800f46:	f7 de                	neg    %esi
  800f48:	83 d7 00             	adc    $0x0,%edi
  800f4b:	f7 df                	neg    %edi
			}
			base = 10;
  800f4d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f52:	eb 70                	jmp    800fc4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f54:	89 ca                	mov    %ecx,%edx
  800f56:	8d 45 14             	lea    0x14(%ebp),%eax
  800f59:	e8 c0 fc ff ff       	call   800c1e <getuint>
  800f5e:	89 c6                	mov    %eax,%esi
  800f60:	89 d7                	mov    %edx,%edi
			base = 10;
  800f62:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800f67:	eb 5b                	jmp    800fc4 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800f69:	89 ca                	mov    %ecx,%edx
  800f6b:	8d 45 14             	lea    0x14(%ebp),%eax
  800f6e:	e8 ab fc ff ff       	call   800c1e <getuint>
  800f73:	89 c6                	mov    %eax,%esi
  800f75:	89 d7                	mov    %edx,%edi
			base = 8;
  800f77:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800f7c:	eb 46                	jmp    800fc4 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800f7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f82:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800f89:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800f8c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f90:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800f97:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f9a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f9d:	8d 50 04             	lea    0x4(%eax),%edx
  800fa0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800fa3:	8b 30                	mov    (%eax),%esi
  800fa5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800faa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800faf:	eb 13                	jmp    800fc4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800fb1:	89 ca                	mov    %ecx,%edx
  800fb3:	8d 45 14             	lea    0x14(%ebp),%eax
  800fb6:	e8 63 fc ff ff       	call   800c1e <getuint>
  800fbb:	89 c6                	mov    %eax,%esi
  800fbd:	89 d7                	mov    %edx,%edi
			base = 16;
  800fbf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800fc4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800fc8:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fcc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fcf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fd3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd7:	89 34 24             	mov    %esi,(%esp)
  800fda:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fde:	89 da                	mov    %ebx,%edx
  800fe0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe3:	e8 6c fb ff ff       	call   800b54 <printnum>
			break;
  800fe8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800feb:	e9 cd fc ff ff       	jmp    800cbd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ff0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ff4:	89 04 24             	mov    %eax,(%esp)
  800ff7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ffa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ffd:	e9 bb fc ff ff       	jmp    800cbd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801002:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801006:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80100d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801010:	eb 01                	jmp    801013 <vprintfmt+0x379>
  801012:	4e                   	dec    %esi
  801013:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801017:	75 f9                	jne    801012 <vprintfmt+0x378>
  801019:	e9 9f fc ff ff       	jmp    800cbd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80101e:	83 c4 4c             	add    $0x4c,%esp
  801021:	5b                   	pop    %ebx
  801022:	5e                   	pop    %esi
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	83 ec 28             	sub    $0x28,%esp
  80102c:	8b 45 08             	mov    0x8(%ebp),%eax
  80102f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801032:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801035:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801039:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80103c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801043:	85 c0                	test   %eax,%eax
  801045:	74 30                	je     801077 <vsnprintf+0x51>
  801047:	85 d2                	test   %edx,%edx
  801049:	7e 33                	jle    80107e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80104b:	8b 45 14             	mov    0x14(%ebp),%eax
  80104e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801052:	8b 45 10             	mov    0x10(%ebp),%eax
  801055:	89 44 24 08          	mov    %eax,0x8(%esp)
  801059:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80105c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801060:	c7 04 24 58 0c 80 00 	movl   $0x800c58,(%esp)
  801067:	e8 2e fc ff ff       	call   800c9a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80106c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80106f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801072:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801075:	eb 0c                	jmp    801083 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801077:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80107c:	eb 05                	jmp    801083 <vsnprintf+0x5d>
  80107e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801083:	c9                   	leave  
  801084:	c3                   	ret    

00801085 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80108b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80108e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801092:	8b 45 10             	mov    0x10(%ebp),%eax
  801095:	89 44 24 08          	mov    %eax,0x8(%esp)
  801099:	8b 45 0c             	mov    0xc(%ebp),%eax
  80109c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a3:	89 04 24             	mov    %eax,(%esp)
  8010a6:	e8 7b ff ff ff       	call   801026 <vsnprintf>
	va_end(ap);

	return rc;
}
  8010ab:	c9                   	leave  
  8010ac:	c3                   	ret    
  8010ad:	00 00                	add    %al,(%eax)
	...

008010b0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	57                   	push   %edi
  8010b4:	56                   	push   %esi
  8010b5:	53                   	push   %ebx
  8010b6:	83 ec 1c             	sub    $0x1c,%esp
  8010b9:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8010bc:	85 c0                	test   %eax,%eax
  8010be:	74 18                	je     8010d8 <readline+0x28>
		fprintf(1, "%s", prompt);
  8010c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010c4:	c7 44 24 04 5b 3c 80 	movl   $0x803c5b,0x4(%esp)
  8010cb:	00 
  8010cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8010d3:	e8 40 16 00 00       	call   802718 <fprintf>
#endif

	i = 0;
	echoing = iscons(0);
  8010d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010df:	e8 69 f8 ff ff       	call   80094d <iscons>
  8010e4:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
  8010e6:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8010eb:	e8 27 f8 ff ff       	call   800917 <getchar>
  8010f0:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	79 20                	jns    801116 <readline+0x66>
			if (c != -E_EOF)
  8010f6:	83 f8 f8             	cmp    $0xfffffff8,%eax
  8010f9:	0f 84 82 00 00 00    	je     801181 <readline+0xd1>
				cprintf("read error: %e\n", c);
  8010ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801103:	c7 04 24 43 40 80 00 	movl   $0x804043,(%esp)
  80110a:	e8 29 fa ff ff       	call   800b38 <cprintf>
			return NULL;
  80110f:	b8 00 00 00 00       	mov    $0x0,%eax
  801114:	eb 70                	jmp    801186 <readline+0xd6>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801116:	83 f8 08             	cmp    $0x8,%eax
  801119:	74 05                	je     801120 <readline+0x70>
  80111b:	83 f8 7f             	cmp    $0x7f,%eax
  80111e:	75 17                	jne    801137 <readline+0x87>
  801120:	85 f6                	test   %esi,%esi
  801122:	7e 13                	jle    801137 <readline+0x87>
			if (echoing)
  801124:	85 ff                	test   %edi,%edi
  801126:	74 0c                	je     801134 <readline+0x84>
				cputchar('\b');
  801128:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80112f:	e8 c2 f7 ff ff       	call   8008f6 <cputchar>
			i--;
  801134:	4e                   	dec    %esi
  801135:	eb b4                	jmp    8010eb <readline+0x3b>
		} else if (c >= ' ' && i < BUFLEN-1) {
  801137:	83 fb 1f             	cmp    $0x1f,%ebx
  80113a:	7e 1d                	jle    801159 <readline+0xa9>
  80113c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  801142:	7f 15                	jg     801159 <readline+0xa9>
			if (echoing)
  801144:	85 ff                	test   %edi,%edi
  801146:	74 08                	je     801150 <readline+0xa0>
				cputchar(c);
  801148:	89 1c 24             	mov    %ebx,(%esp)
  80114b:	e8 a6 f7 ff ff       	call   8008f6 <cputchar>
			buf[i++] = c;
  801150:	88 9e 20 60 80 00    	mov    %bl,0x806020(%esi)
  801156:	46                   	inc    %esi
  801157:	eb 92                	jmp    8010eb <readline+0x3b>
		} else if (c == '\n' || c == '\r') {
  801159:	83 fb 0a             	cmp    $0xa,%ebx
  80115c:	74 05                	je     801163 <readline+0xb3>
  80115e:	83 fb 0d             	cmp    $0xd,%ebx
  801161:	75 88                	jne    8010eb <readline+0x3b>
			if (echoing)
  801163:	85 ff                	test   %edi,%edi
  801165:	74 0c                	je     801173 <readline+0xc3>
				cputchar('\n');
  801167:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80116e:	e8 83 f7 ff ff       	call   8008f6 <cputchar>
			buf[i] = 0;
  801173:	c6 86 20 60 80 00 00 	movb   $0x0,0x806020(%esi)
			return buf;
  80117a:	b8 20 60 80 00       	mov    $0x806020,%eax
  80117f:	eb 05                	jmp    801186 <readline+0xd6>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  801181:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  801186:	83 c4 1c             	add    $0x1c,%esp
  801189:	5b                   	pop    %ebx
  80118a:	5e                   	pop    %esi
  80118b:	5f                   	pop    %edi
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    
	...

00801190 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801196:	b8 00 00 00 00       	mov    $0x0,%eax
  80119b:	eb 01                	jmp    80119e <strlen+0xe>
		n++;
  80119d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80119e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8011a2:	75 f9                	jne    80119d <strlen+0xd>
		n++;
	return n;
}
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    

008011a6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011a6:	55                   	push   %ebp
  8011a7:	89 e5                	mov    %esp,%ebp
  8011a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8011ac:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011af:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b4:	eb 01                	jmp    8011b7 <strnlen+0x11>
		n++;
  8011b6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011b7:	39 d0                	cmp    %edx,%eax
  8011b9:	74 06                	je     8011c1 <strnlen+0x1b>
  8011bb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8011bf:	75 f5                	jne    8011b6 <strnlen+0x10>
		n++;
	return n;
}
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    

008011c3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	53                   	push   %ebx
  8011c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8011d5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8011d8:	42                   	inc    %edx
  8011d9:	84 c9                	test   %cl,%cl
  8011db:	75 f5                	jne    8011d2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8011dd:	5b                   	pop    %ebx
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	53                   	push   %ebx
  8011e4:	83 ec 08             	sub    $0x8,%esp
  8011e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011ea:	89 1c 24             	mov    %ebx,(%esp)
  8011ed:	e8 9e ff ff ff       	call   801190 <strlen>
	strcpy(dst + len, src);
  8011f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011f9:	01 d8                	add    %ebx,%eax
  8011fb:	89 04 24             	mov    %eax,(%esp)
  8011fe:	e8 c0 ff ff ff       	call   8011c3 <strcpy>
	return dst;
}
  801203:	89 d8                	mov    %ebx,%eax
  801205:	83 c4 08             	add    $0x8,%esp
  801208:	5b                   	pop    %ebx
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	56                   	push   %esi
  80120f:	53                   	push   %ebx
  801210:	8b 45 08             	mov    0x8(%ebp),%eax
  801213:	8b 55 0c             	mov    0xc(%ebp),%edx
  801216:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801219:	b9 00 00 00 00       	mov    $0x0,%ecx
  80121e:	eb 0c                	jmp    80122c <strncpy+0x21>
		*dst++ = *src;
  801220:	8a 1a                	mov    (%edx),%bl
  801222:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801225:	80 3a 01             	cmpb   $0x1,(%edx)
  801228:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80122b:	41                   	inc    %ecx
  80122c:	39 f1                	cmp    %esi,%ecx
  80122e:	75 f0                	jne    801220 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801230:	5b                   	pop    %ebx
  801231:	5e                   	pop    %esi
  801232:	5d                   	pop    %ebp
  801233:	c3                   	ret    

00801234 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	56                   	push   %esi
  801238:	53                   	push   %ebx
  801239:	8b 75 08             	mov    0x8(%ebp),%esi
  80123c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80123f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801242:	85 d2                	test   %edx,%edx
  801244:	75 0a                	jne    801250 <strlcpy+0x1c>
  801246:	89 f0                	mov    %esi,%eax
  801248:	eb 1a                	jmp    801264 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80124a:	88 18                	mov    %bl,(%eax)
  80124c:	40                   	inc    %eax
  80124d:	41                   	inc    %ecx
  80124e:	eb 02                	jmp    801252 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801250:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801252:	4a                   	dec    %edx
  801253:	74 0a                	je     80125f <strlcpy+0x2b>
  801255:	8a 19                	mov    (%ecx),%bl
  801257:	84 db                	test   %bl,%bl
  801259:	75 ef                	jne    80124a <strlcpy+0x16>
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	eb 02                	jmp    801261 <strlcpy+0x2d>
  80125f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801261:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801264:	29 f0                	sub    %esi,%eax
}
  801266:	5b                   	pop    %ebx
  801267:	5e                   	pop    %esi
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801270:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801273:	eb 02                	jmp    801277 <strcmp+0xd>
		p++, q++;
  801275:	41                   	inc    %ecx
  801276:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801277:	8a 01                	mov    (%ecx),%al
  801279:	84 c0                	test   %al,%al
  80127b:	74 04                	je     801281 <strcmp+0x17>
  80127d:	3a 02                	cmp    (%edx),%al
  80127f:	74 f4                	je     801275 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801281:	0f b6 c0             	movzbl %al,%eax
  801284:	0f b6 12             	movzbl (%edx),%edx
  801287:	29 d0                	sub    %edx,%eax
}
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    

0080128b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	53                   	push   %ebx
  80128f:	8b 45 08             	mov    0x8(%ebp),%eax
  801292:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801295:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801298:	eb 03                	jmp    80129d <strncmp+0x12>
		n--, p++, q++;
  80129a:	4a                   	dec    %edx
  80129b:	40                   	inc    %eax
  80129c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80129d:	85 d2                	test   %edx,%edx
  80129f:	74 14                	je     8012b5 <strncmp+0x2a>
  8012a1:	8a 18                	mov    (%eax),%bl
  8012a3:	84 db                	test   %bl,%bl
  8012a5:	74 04                	je     8012ab <strncmp+0x20>
  8012a7:	3a 19                	cmp    (%ecx),%bl
  8012a9:	74 ef                	je     80129a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8012ab:	0f b6 00             	movzbl (%eax),%eax
  8012ae:	0f b6 11             	movzbl (%ecx),%edx
  8012b1:	29 d0                	sub    %edx,%eax
  8012b3:	eb 05                	jmp    8012ba <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8012b5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8012ba:	5b                   	pop    %ebx
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8012c6:	eb 05                	jmp    8012cd <strchr+0x10>
		if (*s == c)
  8012c8:	38 ca                	cmp    %cl,%dl
  8012ca:	74 0c                	je     8012d8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8012cc:	40                   	inc    %eax
  8012cd:	8a 10                	mov    (%eax),%dl
  8012cf:	84 d2                	test   %dl,%dl
  8012d1:	75 f5                	jne    8012c8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8012d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8012e3:	eb 05                	jmp    8012ea <strfind+0x10>
		if (*s == c)
  8012e5:	38 ca                	cmp    %cl,%dl
  8012e7:	74 07                	je     8012f0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8012e9:	40                   	inc    %eax
  8012ea:	8a 10                	mov    (%eax),%dl
  8012ec:	84 d2                	test   %dl,%dl
  8012ee:	75 f5                	jne    8012e5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    

008012f2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	57                   	push   %edi
  8012f6:	56                   	push   %esi
  8012f7:	53                   	push   %ebx
  8012f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801301:	85 c9                	test   %ecx,%ecx
  801303:	74 30                	je     801335 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801305:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80130b:	75 25                	jne    801332 <memset+0x40>
  80130d:	f6 c1 03             	test   $0x3,%cl
  801310:	75 20                	jne    801332 <memset+0x40>
		c &= 0xFF;
  801312:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801315:	89 d3                	mov    %edx,%ebx
  801317:	c1 e3 08             	shl    $0x8,%ebx
  80131a:	89 d6                	mov    %edx,%esi
  80131c:	c1 e6 18             	shl    $0x18,%esi
  80131f:	89 d0                	mov    %edx,%eax
  801321:	c1 e0 10             	shl    $0x10,%eax
  801324:	09 f0                	or     %esi,%eax
  801326:	09 d0                	or     %edx,%eax
  801328:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80132a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80132d:	fc                   	cld    
  80132e:	f3 ab                	rep stos %eax,%es:(%edi)
  801330:	eb 03                	jmp    801335 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801332:	fc                   	cld    
  801333:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801335:	89 f8                	mov    %edi,%eax
  801337:	5b                   	pop    %ebx
  801338:	5e                   	pop    %esi
  801339:	5f                   	pop    %edi
  80133a:	5d                   	pop    %ebp
  80133b:	c3                   	ret    

0080133c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	57                   	push   %edi
  801340:	56                   	push   %esi
  801341:	8b 45 08             	mov    0x8(%ebp),%eax
  801344:	8b 75 0c             	mov    0xc(%ebp),%esi
  801347:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80134a:	39 c6                	cmp    %eax,%esi
  80134c:	73 34                	jae    801382 <memmove+0x46>
  80134e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801351:	39 d0                	cmp    %edx,%eax
  801353:	73 2d                	jae    801382 <memmove+0x46>
		s += n;
		d += n;
  801355:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801358:	f6 c2 03             	test   $0x3,%dl
  80135b:	75 1b                	jne    801378 <memmove+0x3c>
  80135d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801363:	75 13                	jne    801378 <memmove+0x3c>
  801365:	f6 c1 03             	test   $0x3,%cl
  801368:	75 0e                	jne    801378 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80136a:	83 ef 04             	sub    $0x4,%edi
  80136d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801370:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801373:	fd                   	std    
  801374:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801376:	eb 07                	jmp    80137f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801378:	4f                   	dec    %edi
  801379:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80137c:	fd                   	std    
  80137d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80137f:	fc                   	cld    
  801380:	eb 20                	jmp    8013a2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801382:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801388:	75 13                	jne    80139d <memmove+0x61>
  80138a:	a8 03                	test   $0x3,%al
  80138c:	75 0f                	jne    80139d <memmove+0x61>
  80138e:	f6 c1 03             	test   $0x3,%cl
  801391:	75 0a                	jne    80139d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801393:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801396:	89 c7                	mov    %eax,%edi
  801398:	fc                   	cld    
  801399:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80139b:	eb 05                	jmp    8013a2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80139d:	89 c7                	mov    %eax,%edi
  80139f:	fc                   	cld    
  8013a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8013a2:	5e                   	pop    %esi
  8013a3:	5f                   	pop    %edi
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8013ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8013af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bd:	89 04 24             	mov    %eax,(%esp)
  8013c0:	e8 77 ff ff ff       	call   80133c <memmove>
}
  8013c5:	c9                   	leave  
  8013c6:	c3                   	ret    

008013c7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	57                   	push   %edi
  8013cb:	56                   	push   %esi
  8013cc:	53                   	push   %ebx
  8013cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013db:	eb 16                	jmp    8013f3 <memcmp+0x2c>
		if (*s1 != *s2)
  8013dd:	8a 04 17             	mov    (%edi,%edx,1),%al
  8013e0:	42                   	inc    %edx
  8013e1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8013e5:	38 c8                	cmp    %cl,%al
  8013e7:	74 0a                	je     8013f3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8013e9:	0f b6 c0             	movzbl %al,%eax
  8013ec:	0f b6 c9             	movzbl %cl,%ecx
  8013ef:	29 c8                	sub    %ecx,%eax
  8013f1:	eb 09                	jmp    8013fc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8013f3:	39 da                	cmp    %ebx,%edx
  8013f5:	75 e6                	jne    8013dd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8013f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013fc:	5b                   	pop    %ebx
  8013fd:	5e                   	pop    %esi
  8013fe:	5f                   	pop    %edi
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    

00801401 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	8b 45 08             	mov    0x8(%ebp),%eax
  801407:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80140a:	89 c2                	mov    %eax,%edx
  80140c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80140f:	eb 05                	jmp    801416 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801411:	38 08                	cmp    %cl,(%eax)
  801413:	74 05                	je     80141a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801415:	40                   	inc    %eax
  801416:	39 d0                	cmp    %edx,%eax
  801418:	72 f7                	jb     801411 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    

0080141c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	57                   	push   %edi
  801420:	56                   	push   %esi
  801421:	53                   	push   %ebx
  801422:	8b 55 08             	mov    0x8(%ebp),%edx
  801425:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801428:	eb 01                	jmp    80142b <strtol+0xf>
		s++;
  80142a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80142b:	8a 02                	mov    (%edx),%al
  80142d:	3c 20                	cmp    $0x20,%al
  80142f:	74 f9                	je     80142a <strtol+0xe>
  801431:	3c 09                	cmp    $0x9,%al
  801433:	74 f5                	je     80142a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801435:	3c 2b                	cmp    $0x2b,%al
  801437:	75 08                	jne    801441 <strtol+0x25>
		s++;
  801439:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80143a:	bf 00 00 00 00       	mov    $0x0,%edi
  80143f:	eb 13                	jmp    801454 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801441:	3c 2d                	cmp    $0x2d,%al
  801443:	75 0a                	jne    80144f <strtol+0x33>
		s++, neg = 1;
  801445:	8d 52 01             	lea    0x1(%edx),%edx
  801448:	bf 01 00 00 00       	mov    $0x1,%edi
  80144d:	eb 05                	jmp    801454 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80144f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801454:	85 db                	test   %ebx,%ebx
  801456:	74 05                	je     80145d <strtol+0x41>
  801458:	83 fb 10             	cmp    $0x10,%ebx
  80145b:	75 28                	jne    801485 <strtol+0x69>
  80145d:	8a 02                	mov    (%edx),%al
  80145f:	3c 30                	cmp    $0x30,%al
  801461:	75 10                	jne    801473 <strtol+0x57>
  801463:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801467:	75 0a                	jne    801473 <strtol+0x57>
		s += 2, base = 16;
  801469:	83 c2 02             	add    $0x2,%edx
  80146c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801471:	eb 12                	jmp    801485 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801473:	85 db                	test   %ebx,%ebx
  801475:	75 0e                	jne    801485 <strtol+0x69>
  801477:	3c 30                	cmp    $0x30,%al
  801479:	75 05                	jne    801480 <strtol+0x64>
		s++, base = 8;
  80147b:	42                   	inc    %edx
  80147c:	b3 08                	mov    $0x8,%bl
  80147e:	eb 05                	jmp    801485 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801480:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801485:	b8 00 00 00 00       	mov    $0x0,%eax
  80148a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80148c:	8a 0a                	mov    (%edx),%cl
  80148e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801491:	80 fb 09             	cmp    $0x9,%bl
  801494:	77 08                	ja     80149e <strtol+0x82>
			dig = *s - '0';
  801496:	0f be c9             	movsbl %cl,%ecx
  801499:	83 e9 30             	sub    $0x30,%ecx
  80149c:	eb 1e                	jmp    8014bc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80149e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8014a1:	80 fb 19             	cmp    $0x19,%bl
  8014a4:	77 08                	ja     8014ae <strtol+0x92>
			dig = *s - 'a' + 10;
  8014a6:	0f be c9             	movsbl %cl,%ecx
  8014a9:	83 e9 57             	sub    $0x57,%ecx
  8014ac:	eb 0e                	jmp    8014bc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8014ae:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8014b1:	80 fb 19             	cmp    $0x19,%bl
  8014b4:	77 12                	ja     8014c8 <strtol+0xac>
			dig = *s - 'A' + 10;
  8014b6:	0f be c9             	movsbl %cl,%ecx
  8014b9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8014bc:	39 f1                	cmp    %esi,%ecx
  8014be:	7d 0c                	jge    8014cc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8014c0:	42                   	inc    %edx
  8014c1:	0f af c6             	imul   %esi,%eax
  8014c4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8014c6:	eb c4                	jmp    80148c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8014c8:	89 c1                	mov    %eax,%ecx
  8014ca:	eb 02                	jmp    8014ce <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8014cc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8014ce:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014d2:	74 05                	je     8014d9 <strtol+0xbd>
		*endptr = (char *) s;
  8014d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014d7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8014d9:	85 ff                	test   %edi,%edi
  8014db:	74 04                	je     8014e1 <strtol+0xc5>
  8014dd:	89 c8                	mov    %ecx,%eax
  8014df:	f7 d8                	neg    %eax
}
  8014e1:	5b                   	pop    %ebx
  8014e2:	5e                   	pop    %esi
  8014e3:	5f                   	pop    %edi
  8014e4:	5d                   	pop    %ebp
  8014e5:	c3                   	ret    
	...

008014e8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014e8:	55                   	push   %ebp
  8014e9:	89 e5                	mov    %esp,%ebp
  8014eb:	57                   	push   %edi
  8014ec:	56                   	push   %esi
  8014ed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f9:	89 c3                	mov    %eax,%ebx
  8014fb:	89 c7                	mov    %eax,%edi
  8014fd:	89 c6                	mov    %eax,%esi
  8014ff:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801501:	5b                   	pop    %ebx
  801502:	5e                   	pop    %esi
  801503:	5f                   	pop    %edi
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    

00801506 <sys_cgetc>:

int
sys_cgetc(void)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	57                   	push   %edi
  80150a:	56                   	push   %esi
  80150b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80150c:	ba 00 00 00 00       	mov    $0x0,%edx
  801511:	b8 01 00 00 00       	mov    $0x1,%eax
  801516:	89 d1                	mov    %edx,%ecx
  801518:	89 d3                	mov    %edx,%ebx
  80151a:	89 d7                	mov    %edx,%edi
  80151c:	89 d6                	mov    %edx,%esi
  80151e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801520:	5b                   	pop    %ebx
  801521:	5e                   	pop    %esi
  801522:	5f                   	pop    %edi
  801523:	5d                   	pop    %ebp
  801524:	c3                   	ret    

00801525 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	57                   	push   %edi
  801529:	56                   	push   %esi
  80152a:	53                   	push   %ebx
  80152b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80152e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801533:	b8 03 00 00 00       	mov    $0x3,%eax
  801538:	8b 55 08             	mov    0x8(%ebp),%edx
  80153b:	89 cb                	mov    %ecx,%ebx
  80153d:	89 cf                	mov    %ecx,%edi
  80153f:	89 ce                	mov    %ecx,%esi
  801541:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801543:	85 c0                	test   %eax,%eax
  801545:	7e 28                	jle    80156f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801547:	89 44 24 10          	mov    %eax,0x10(%esp)
  80154b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801552:	00 
  801553:	c7 44 24 08 53 40 80 	movl   $0x804053,0x8(%esp)
  80155a:	00 
  80155b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801562:	00 
  801563:	c7 04 24 70 40 80 00 	movl   $0x804070,(%esp)
  80156a:	e8 d1 f4 ff ff       	call   800a40 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80156f:	83 c4 2c             	add    $0x2c,%esp
  801572:	5b                   	pop    %ebx
  801573:	5e                   	pop    %esi
  801574:	5f                   	pop    %edi
  801575:	5d                   	pop    %ebp
  801576:	c3                   	ret    

00801577 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801577:	55                   	push   %ebp
  801578:	89 e5                	mov    %esp,%ebp
  80157a:	57                   	push   %edi
  80157b:	56                   	push   %esi
  80157c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80157d:	ba 00 00 00 00       	mov    $0x0,%edx
  801582:	b8 02 00 00 00       	mov    $0x2,%eax
  801587:	89 d1                	mov    %edx,%ecx
  801589:	89 d3                	mov    %edx,%ebx
  80158b:	89 d7                	mov    %edx,%edi
  80158d:	89 d6                	mov    %edx,%esi
  80158f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801591:	5b                   	pop    %ebx
  801592:	5e                   	pop    %esi
  801593:	5f                   	pop    %edi
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    

00801596 <sys_yield>:

void
sys_yield(void)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
  801599:	57                   	push   %edi
  80159a:	56                   	push   %esi
  80159b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80159c:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8015a6:	89 d1                	mov    %edx,%ecx
  8015a8:	89 d3                	mov    %edx,%ebx
  8015aa:	89 d7                	mov    %edx,%edi
  8015ac:	89 d6                	mov    %edx,%esi
  8015ae:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8015b0:	5b                   	pop    %ebx
  8015b1:	5e                   	pop    %esi
  8015b2:	5f                   	pop    %edi
  8015b3:	5d                   	pop    %ebp
  8015b4:	c3                   	ret    

008015b5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	57                   	push   %edi
  8015b9:	56                   	push   %esi
  8015ba:	53                   	push   %ebx
  8015bb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015be:	be 00 00 00 00       	mov    $0x0,%esi
  8015c3:	b8 04 00 00 00       	mov    $0x4,%eax
  8015c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8015d1:	89 f7                	mov    %esi,%edi
  8015d3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015d5:	85 c0                	test   %eax,%eax
  8015d7:	7e 28                	jle    801601 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015dd:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8015e4:	00 
  8015e5:	c7 44 24 08 53 40 80 	movl   $0x804053,0x8(%esp)
  8015ec:	00 
  8015ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015f4:	00 
  8015f5:	c7 04 24 70 40 80 00 	movl   $0x804070,(%esp)
  8015fc:	e8 3f f4 ff ff       	call   800a40 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801601:	83 c4 2c             	add    $0x2c,%esp
  801604:	5b                   	pop    %ebx
  801605:	5e                   	pop    %esi
  801606:	5f                   	pop    %edi
  801607:	5d                   	pop    %ebp
  801608:	c3                   	ret    

00801609 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801609:	55                   	push   %ebp
  80160a:	89 e5                	mov    %esp,%ebp
  80160c:	57                   	push   %edi
  80160d:	56                   	push   %esi
  80160e:	53                   	push   %ebx
  80160f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801612:	b8 05 00 00 00       	mov    $0x5,%eax
  801617:	8b 75 18             	mov    0x18(%ebp),%esi
  80161a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80161d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801620:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801623:	8b 55 08             	mov    0x8(%ebp),%edx
  801626:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801628:	85 c0                	test   %eax,%eax
  80162a:	7e 28                	jle    801654 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80162c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801630:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801637:	00 
  801638:	c7 44 24 08 53 40 80 	movl   $0x804053,0x8(%esp)
  80163f:	00 
  801640:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801647:	00 
  801648:	c7 04 24 70 40 80 00 	movl   $0x804070,(%esp)
  80164f:	e8 ec f3 ff ff       	call   800a40 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801654:	83 c4 2c             	add    $0x2c,%esp
  801657:	5b                   	pop    %ebx
  801658:	5e                   	pop    %esi
  801659:	5f                   	pop    %edi
  80165a:	5d                   	pop    %ebp
  80165b:	c3                   	ret    

0080165c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	57                   	push   %edi
  801660:	56                   	push   %esi
  801661:	53                   	push   %ebx
  801662:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801665:	bb 00 00 00 00       	mov    $0x0,%ebx
  80166a:	b8 06 00 00 00       	mov    $0x6,%eax
  80166f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801672:	8b 55 08             	mov    0x8(%ebp),%edx
  801675:	89 df                	mov    %ebx,%edi
  801677:	89 de                	mov    %ebx,%esi
  801679:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80167b:	85 c0                	test   %eax,%eax
  80167d:	7e 28                	jle    8016a7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80167f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801683:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80168a:	00 
  80168b:	c7 44 24 08 53 40 80 	movl   $0x804053,0x8(%esp)
  801692:	00 
  801693:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80169a:	00 
  80169b:	c7 04 24 70 40 80 00 	movl   $0x804070,(%esp)
  8016a2:	e8 99 f3 ff ff       	call   800a40 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8016a7:	83 c4 2c             	add    $0x2c,%esp
  8016aa:	5b                   	pop    %ebx
  8016ab:	5e                   	pop    %esi
  8016ac:	5f                   	pop    %edi
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    

008016af <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	57                   	push   %edi
  8016b3:	56                   	push   %esi
  8016b4:	53                   	push   %ebx
  8016b5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016bd:	b8 08 00 00 00       	mov    $0x8,%eax
  8016c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8016c8:	89 df                	mov    %ebx,%edi
  8016ca:	89 de                	mov    %ebx,%esi
  8016cc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	7e 28                	jle    8016fa <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016d6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8016dd:	00 
  8016de:	c7 44 24 08 53 40 80 	movl   $0x804053,0x8(%esp)
  8016e5:	00 
  8016e6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016ed:	00 
  8016ee:	c7 04 24 70 40 80 00 	movl   $0x804070,(%esp)
  8016f5:	e8 46 f3 ff ff       	call   800a40 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8016fa:	83 c4 2c             	add    $0x2c,%esp
  8016fd:	5b                   	pop    %ebx
  8016fe:	5e                   	pop    %esi
  8016ff:	5f                   	pop    %edi
  801700:	5d                   	pop    %ebp
  801701:	c3                   	ret    

00801702 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	57                   	push   %edi
  801706:	56                   	push   %esi
  801707:	53                   	push   %ebx
  801708:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80170b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801710:	b8 09 00 00 00       	mov    $0x9,%eax
  801715:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801718:	8b 55 08             	mov    0x8(%ebp),%edx
  80171b:	89 df                	mov    %ebx,%edi
  80171d:	89 de                	mov    %ebx,%esi
  80171f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801721:	85 c0                	test   %eax,%eax
  801723:	7e 28                	jle    80174d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801725:	89 44 24 10          	mov    %eax,0x10(%esp)
  801729:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801730:	00 
  801731:	c7 44 24 08 53 40 80 	movl   $0x804053,0x8(%esp)
  801738:	00 
  801739:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801740:	00 
  801741:	c7 04 24 70 40 80 00 	movl   $0x804070,(%esp)
  801748:	e8 f3 f2 ff ff       	call   800a40 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80174d:	83 c4 2c             	add    $0x2c,%esp
  801750:	5b                   	pop    %ebx
  801751:	5e                   	pop    %esi
  801752:	5f                   	pop    %edi
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	57                   	push   %edi
  801759:	56                   	push   %esi
  80175a:	53                   	push   %ebx
  80175b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80175e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801763:	b8 0a 00 00 00       	mov    $0xa,%eax
  801768:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80176b:	8b 55 08             	mov    0x8(%ebp),%edx
  80176e:	89 df                	mov    %ebx,%edi
  801770:	89 de                	mov    %ebx,%esi
  801772:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801774:	85 c0                	test   %eax,%eax
  801776:	7e 28                	jle    8017a0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801778:	89 44 24 10          	mov    %eax,0x10(%esp)
  80177c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801783:	00 
  801784:	c7 44 24 08 53 40 80 	movl   $0x804053,0x8(%esp)
  80178b:	00 
  80178c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801793:	00 
  801794:	c7 04 24 70 40 80 00 	movl   $0x804070,(%esp)
  80179b:	e8 a0 f2 ff ff       	call   800a40 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8017a0:	83 c4 2c             	add    $0x2c,%esp
  8017a3:	5b                   	pop    %ebx
  8017a4:	5e                   	pop    %esi
  8017a5:	5f                   	pop    %edi
  8017a6:	5d                   	pop    %ebp
  8017a7:	c3                   	ret    

008017a8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	57                   	push   %edi
  8017ac:	56                   	push   %esi
  8017ad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017ae:	be 00 00 00 00       	mov    $0x0,%esi
  8017b3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8017b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8017bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8017be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8017c4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8017c6:	5b                   	pop    %ebx
  8017c7:	5e                   	pop    %esi
  8017c8:	5f                   	pop    %edi
  8017c9:	5d                   	pop    %ebp
  8017ca:	c3                   	ret    

008017cb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	57                   	push   %edi
  8017cf:	56                   	push   %esi
  8017d0:	53                   	push   %ebx
  8017d1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8017d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8017d9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8017de:	8b 55 08             	mov    0x8(%ebp),%edx
  8017e1:	89 cb                	mov    %ecx,%ebx
  8017e3:	89 cf                	mov    %ecx,%edi
  8017e5:	89 ce                	mov    %ecx,%esi
  8017e7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8017e9:	85 c0                	test   %eax,%eax
  8017eb:	7e 28                	jle    801815 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8017ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017f1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8017f8:	00 
  8017f9:	c7 44 24 08 53 40 80 	movl   $0x804053,0x8(%esp)
  801800:	00 
  801801:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801808:	00 
  801809:	c7 04 24 70 40 80 00 	movl   $0x804070,(%esp)
  801810:	e8 2b f2 ff ff       	call   800a40 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801815:	83 c4 2c             	add    $0x2c,%esp
  801818:	5b                   	pop    %ebx
  801819:	5e                   	pop    %esi
  80181a:	5f                   	pop    %edi
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	57                   	push   %edi
  801821:	56                   	push   %esi
  801822:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801823:	ba 00 00 00 00       	mov    $0x0,%edx
  801828:	b8 0e 00 00 00       	mov    $0xe,%eax
  80182d:	89 d1                	mov    %edx,%ecx
  80182f:	89 d3                	mov    %edx,%ebx
  801831:	89 d7                	mov    %edx,%edi
  801833:	89 d6                	mov    %edx,%esi
  801835:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801837:	5b                   	pop    %ebx
  801838:	5e                   	pop    %esi
  801839:	5f                   	pop    %edi
  80183a:	5d                   	pop    %ebp
  80183b:	c3                   	ret    

0080183c <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  80183c:	55                   	push   %ebp
  80183d:	89 e5                	mov    %esp,%ebp
  80183f:	57                   	push   %edi
  801840:	56                   	push   %esi
  801841:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801842:	bb 00 00 00 00       	mov    $0x0,%ebx
  801847:	b8 0f 00 00 00       	mov    $0xf,%eax
  80184c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80184f:	8b 55 08             	mov    0x8(%ebp),%edx
  801852:	89 df                	mov    %ebx,%edi
  801854:	89 de                	mov    %ebx,%esi
  801856:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  801858:	5b                   	pop    %ebx
  801859:	5e                   	pop    %esi
  80185a:	5f                   	pop    %edi
  80185b:	5d                   	pop    %ebp
  80185c:	c3                   	ret    

0080185d <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	57                   	push   %edi
  801861:	56                   	push   %esi
  801862:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801863:	bb 00 00 00 00       	mov    $0x0,%ebx
  801868:	b8 10 00 00 00       	mov    $0x10,%eax
  80186d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801870:	8b 55 08             	mov    0x8(%ebp),%edx
  801873:	89 df                	mov    %ebx,%edi
  801875:	89 de                	mov    %ebx,%esi
  801877:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  801879:	5b                   	pop    %ebx
  80187a:	5e                   	pop    %esi
  80187b:	5f                   	pop    %edi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    
	...

00801880 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	53                   	push   %ebx
  801884:	83 ec 24             	sub    $0x24,%esp
  801887:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80188a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  80188c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801890:	74 2d                	je     8018bf <pgfault+0x3f>
  801892:	89 d8                	mov    %ebx,%eax
  801894:	c1 e8 16             	shr    $0x16,%eax
  801897:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80189e:	a8 01                	test   $0x1,%al
  8018a0:	74 1d                	je     8018bf <pgfault+0x3f>
  8018a2:	89 d8                	mov    %ebx,%eax
  8018a4:	c1 e8 0c             	shr    $0xc,%eax
  8018a7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018ae:	f6 c2 01             	test   $0x1,%dl
  8018b1:	74 0c                	je     8018bf <pgfault+0x3f>
  8018b3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018ba:	f6 c4 08             	test   $0x8,%ah
  8018bd:	75 1c                	jne    8018db <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  8018bf:	c7 44 24 08 80 40 80 	movl   $0x804080,0x8(%esp)
  8018c6:	00 
  8018c7:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8018ce:	00 
  8018cf:	c7 04 24 c3 40 80 00 	movl   $0x8040c3,(%esp)
  8018d6:	e8 65 f1 ff ff       	call   800a40 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  8018db:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  8018e1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8018e8:	00 
  8018e9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8018f0:	00 
  8018f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018f8:	e8 b8 fc ff ff       	call   8015b5 <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  8018fd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801904:	00 
  801905:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801909:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801910:	e8 91 fa ff ff       	call   8013a6 <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  801915:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80191c:	00 
  80191d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801921:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801928:	00 
  801929:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801930:	00 
  801931:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801938:	e8 cc fc ff ff       	call   801609 <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  80193d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801944:	00 
  801945:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80194c:	e8 0b fd ff ff       	call   80165c <sys_page_unmap>

	// panic("pgfault not implemented");
}
  801951:	83 c4 24             	add    $0x24,%esp
  801954:	5b                   	pop    %ebx
  801955:	5d                   	pop    %ebp
  801956:	c3                   	ret    

00801957 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	57                   	push   %edi
  80195b:	56                   	push   %esi
  80195c:	53                   	push   %ebx
  80195d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801960:	c7 04 24 80 18 80 00 	movl   $0x801880,(%esp)
  801967:	e8 40 1d 00 00       	call   8036ac <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80196c:	ba 07 00 00 00       	mov    $0x7,%edx
  801971:	89 d0                	mov    %edx,%eax
  801973:	cd 30                	int    $0x30
  801975:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801978:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80197a:	85 c0                	test   %eax,%eax
  80197c:	79 20                	jns    80199e <fork+0x47>
		panic("sys_exofork: %e", envid);
  80197e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801982:	c7 44 24 08 ce 40 80 	movl   $0x8040ce,0x8(%esp)
  801989:	00 
  80198a:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  801991:	00 
  801992:	c7 04 24 c3 40 80 00 	movl   $0x8040c3,(%esp)
  801999:	e8 a2 f0 ff ff       	call   800a40 <_panic>
	if (envid == 0)
  80199e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8019a2:	75 25                	jne    8019c9 <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8019a4:	e8 ce fb ff ff       	call   801577 <sys_getenvid>
  8019a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8019ae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8019b5:	c1 e0 07             	shl    $0x7,%eax
  8019b8:	29 d0                	sub    %edx,%eax
  8019ba:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8019bf:	a3 28 64 80 00       	mov    %eax,0x806428
		return 0;
  8019c4:	e9 43 02 00 00       	jmp    801c0c <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  8019c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  8019ce:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8019d4:	0f 84 85 01 00 00    	je     801b5f <fork+0x208>
  8019da:	89 d8                	mov    %ebx,%eax
  8019dc:	c1 e8 16             	shr    $0x16,%eax
  8019df:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019e6:	a8 01                	test   $0x1,%al
  8019e8:	0f 84 5f 01 00 00    	je     801b4d <fork+0x1f6>
  8019ee:	89 d8                	mov    %ebx,%eax
  8019f0:	c1 e8 0c             	shr    $0xc,%eax
  8019f3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8019fa:	f6 c2 01             	test   $0x1,%dl
  8019fd:	0f 84 4a 01 00 00    	je     801b4d <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  801a03:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  801a05:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a0c:	f6 c6 04             	test   $0x4,%dh
  801a0f:	74 50                	je     801a61 <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  801a11:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a18:	25 07 0e 00 00       	and    $0xe07,%eax
  801a1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a21:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801a25:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801a29:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a34:	e8 d0 fb ff ff       	call   801609 <sys_page_map>
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	0f 89 0c 01 00 00    	jns    801b4d <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  801a41:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a45:	c7 44 24 08 de 40 80 	movl   $0x8040de,0x8(%esp)
  801a4c:	00 
  801a4d:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  801a54:	00 
  801a55:	c7 04 24 c3 40 80 00 	movl   $0x8040c3,(%esp)
  801a5c:	e8 df ef ff ff       	call   800a40 <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  801a61:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801a68:	f6 c2 02             	test   $0x2,%dl
  801a6b:	75 10                	jne    801a7d <fork+0x126>
  801a6d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a74:	f6 c4 08             	test   $0x8,%ah
  801a77:	0f 84 8c 00 00 00    	je     801b09 <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  801a7d:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801a84:	00 
  801a85:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a89:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801a8d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a98:	e8 6c fb ff ff       	call   801609 <sys_page_map>
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	79 20                	jns    801ac1 <fork+0x16a>
		{
			panic("duppage error: %e",e);
  801aa1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801aa5:	c7 44 24 08 de 40 80 	movl   $0x8040de,0x8(%esp)
  801aac:	00 
  801aad:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801ab4:	00 
  801ab5:	c7 04 24 c3 40 80 00 	movl   $0x8040c3,(%esp)
  801abc:	e8 7f ef ff ff       	call   800a40 <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  801ac1:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801ac8:	00 
  801ac9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801acd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ad4:	00 
  801ad5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ad9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ae0:	e8 24 fb ff ff       	call   801609 <sys_page_map>
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	79 64                	jns    801b4d <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801ae9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801aed:	c7 44 24 08 de 40 80 	movl   $0x8040de,0x8(%esp)
  801af4:	00 
  801af5:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  801afc:	00 
  801afd:	c7 04 24 c3 40 80 00 	movl   $0x8040c3,(%esp)
  801b04:	e8 37 ef ff ff       	call   800a40 <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  801b09:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  801b10:	00 
  801b11:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801b15:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801b19:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b24:	e8 e0 fa ff ff       	call   801609 <sys_page_map>
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	79 20                	jns    801b4d <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801b2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b31:	c7 44 24 08 de 40 80 	movl   $0x8040de,0x8(%esp)
  801b38:	00 
  801b39:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801b40:	00 
  801b41:	c7 04 24 c3 40 80 00 	movl   $0x8040c3,(%esp)
  801b48:	e8 f3 ee ff ff       	call   800a40 <_panic>
  801b4d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  801b53:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801b59:	0f 85 6f fe ff ff    	jne    8019ce <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  801b5f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801b66:	00 
  801b67:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801b6e:	ee 
  801b6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b72:	89 04 24             	mov    %eax,(%esp)
  801b75:	e8 3b fa ff ff       	call   8015b5 <sys_page_alloc>
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	79 20                	jns    801b9e <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  801b7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b82:	c7 44 24 08 f0 40 80 	movl   $0x8040f0,0x8(%esp)
  801b89:	00 
  801b8a:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  801b91:	00 
  801b92:	c7 04 24 c3 40 80 00 	movl   $0x8040c3,(%esp)
  801b99:	e8 a2 ee ff ff       	call   800a40 <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801b9e:	c7 44 24 04 f8 36 80 	movl   $0x8036f8,0x4(%esp)
  801ba5:	00 
  801ba6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ba9:	89 04 24             	mov    %eax,(%esp)
  801bac:	e8 a4 fb ff ff       	call   801755 <sys_env_set_pgfault_upcall>
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	79 20                	jns    801bd5 <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  801bb5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bb9:	c7 44 24 08 a4 40 80 	movl   $0x8040a4,0x8(%esp)
  801bc0:	00 
  801bc1:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  801bc8:	00 
  801bc9:	c7 04 24 c3 40 80 00 	movl   $0x8040c3,(%esp)
  801bd0:	e8 6b ee ff ff       	call   800a40 <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801bd5:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801bdc:	00 
  801bdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801be0:	89 04 24             	mov    %eax,(%esp)
  801be3:	e8 c7 fa ff ff       	call   8016af <sys_env_set_status>
  801be8:	85 c0                	test   %eax,%eax
  801bea:	79 20                	jns    801c0c <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  801bec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bf0:	c7 44 24 08 03 41 80 	movl   $0x804103,0x8(%esp)
  801bf7:	00 
  801bf8:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801bff:	00 
  801c00:	c7 04 24 c3 40 80 00 	movl   $0x8040c3,(%esp)
  801c07:	e8 34 ee ff ff       	call   800a40 <_panic>

	return envid;
	// panic("fork not implemented");
}
  801c0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c0f:	83 c4 3c             	add    $0x3c,%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5f                   	pop    %edi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <sfork>:

// Challenge!
int
sfork(void)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801c1d:	c7 44 24 08 1a 41 80 	movl   $0x80411a,0x8(%esp)
  801c24:	00 
  801c25:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801c2c:	00 
  801c2d:	c7 04 24 c3 40 80 00 	movl   $0x8040c3,(%esp)
  801c34:	e8 07 ee ff ff       	call   800a40 <_panic>
  801c39:	00 00                	add    %al,(%eax)
	...

00801c3c <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	8b 55 08             	mov    0x8(%ebp),%edx
  801c42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c45:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801c48:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801c4a:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801c4d:	83 3a 01             	cmpl   $0x1,(%edx)
  801c50:	7e 0b                	jle    801c5d <argstart+0x21>
  801c52:	85 c9                	test   %ecx,%ecx
  801c54:	75 0e                	jne    801c64 <argstart+0x28>
  801c56:	ba 00 00 00 00       	mov    $0x0,%edx
  801c5b:	eb 0c                	jmp    801c69 <argstart+0x2d>
  801c5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c62:	eb 05                	jmp    801c69 <argstart+0x2d>
  801c64:	ba 21 3b 80 00       	mov    $0x803b21,%edx
  801c69:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801c6c:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    

00801c75 <argnext>:

int
argnext(struct Argstate *args)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	53                   	push   %ebx
  801c79:	83 ec 14             	sub    $0x14,%esp
  801c7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801c7f:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801c86:	8b 43 08             	mov    0x8(%ebx),%eax
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	74 6c                	je     801cf9 <argnext+0x84>
		return -1;

	if (!*args->curarg) {
  801c8d:	80 38 00             	cmpb   $0x0,(%eax)
  801c90:	75 4d                	jne    801cdf <argnext+0x6a>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801c92:	8b 0b                	mov    (%ebx),%ecx
  801c94:	83 39 01             	cmpl   $0x1,(%ecx)
  801c97:	74 52                	je     801ceb <argnext+0x76>
		    || args->argv[1][0] != '-'
  801c99:	8b 53 04             	mov    0x4(%ebx),%edx
  801c9c:	8b 42 04             	mov    0x4(%edx),%eax
  801c9f:	80 38 2d             	cmpb   $0x2d,(%eax)
  801ca2:	75 47                	jne    801ceb <argnext+0x76>
		    || args->argv[1][1] == '\0')
  801ca4:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801ca8:	74 41                	je     801ceb <argnext+0x76>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801caa:	40                   	inc    %eax
  801cab:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801cae:	8b 01                	mov    (%ecx),%eax
  801cb0:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801cb7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cbb:	8d 42 08             	lea    0x8(%edx),%eax
  801cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc2:	83 c2 04             	add    $0x4,%edx
  801cc5:	89 14 24             	mov    %edx,(%esp)
  801cc8:	e8 6f f6 ff ff       	call   80133c <memmove>
		(*args->argc)--;
  801ccd:	8b 03                	mov    (%ebx),%eax
  801ccf:	ff 08                	decl   (%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801cd1:	8b 43 08             	mov    0x8(%ebx),%eax
  801cd4:	80 38 2d             	cmpb   $0x2d,(%eax)
  801cd7:	75 06                	jne    801cdf <argnext+0x6a>
  801cd9:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801cdd:	74 0c                	je     801ceb <argnext+0x76>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801cdf:	8b 53 08             	mov    0x8(%ebx),%edx
  801ce2:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801ce5:	42                   	inc    %edx
  801ce6:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801ce9:	eb 13                	jmp    801cfe <argnext+0x89>

    endofargs:
	args->curarg = 0;
  801ceb:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801cf2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801cf7:	eb 05                	jmp    801cfe <argnext+0x89>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801cf9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801cfe:	83 c4 14             	add    $0x14,%esp
  801d01:	5b                   	pop    %ebx
  801d02:	5d                   	pop    %ebp
  801d03:	c3                   	ret    

00801d04 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	53                   	push   %ebx
  801d08:	83 ec 14             	sub    $0x14,%esp
  801d0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801d0e:	8b 43 08             	mov    0x8(%ebx),%eax
  801d11:	85 c0                	test   %eax,%eax
  801d13:	74 59                	je     801d6e <argnextvalue+0x6a>
		return 0;
	if (*args->curarg) {
  801d15:	80 38 00             	cmpb   $0x0,(%eax)
  801d18:	74 0c                	je     801d26 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801d1a:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801d1d:	c7 43 08 21 3b 80 00 	movl   $0x803b21,0x8(%ebx)
  801d24:	eb 43                	jmp    801d69 <argnextvalue+0x65>
	} else if (*args->argc > 1) {
  801d26:	8b 03                	mov    (%ebx),%eax
  801d28:	83 38 01             	cmpl   $0x1,(%eax)
  801d2b:	7e 2e                	jle    801d5b <argnextvalue+0x57>
		args->argvalue = args->argv[1];
  801d2d:	8b 53 04             	mov    0x4(%ebx),%edx
  801d30:	8b 4a 04             	mov    0x4(%edx),%ecx
  801d33:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801d36:	8b 00                	mov    (%eax),%eax
  801d38:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801d3f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d43:	8d 42 08             	lea    0x8(%edx),%eax
  801d46:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4a:	83 c2 04             	add    $0x4,%edx
  801d4d:	89 14 24             	mov    %edx,(%esp)
  801d50:	e8 e7 f5 ff ff       	call   80133c <memmove>
		(*args->argc)--;
  801d55:	8b 03                	mov    (%ebx),%eax
  801d57:	ff 08                	decl   (%eax)
  801d59:	eb 0e                	jmp    801d69 <argnextvalue+0x65>
	} else {
		args->argvalue = 0;
  801d5b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801d62:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801d69:	8b 43 0c             	mov    0xc(%ebx),%eax
  801d6c:	eb 05                	jmp    801d73 <argnextvalue+0x6f>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801d6e:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801d73:	83 c4 14             	add    $0x14,%esp
  801d76:	5b                   	pop    %ebx
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    

00801d79 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	83 ec 18             	sub    $0x18,%esp
  801d7f:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801d82:	8b 42 0c             	mov    0xc(%edx),%eax
  801d85:	85 c0                	test   %eax,%eax
  801d87:	75 08                	jne    801d91 <argvalue+0x18>
  801d89:	89 14 24             	mov    %edx,(%esp)
  801d8c:	e8 73 ff ff ff       	call   801d04 <argnextvalue>
}
  801d91:	c9                   	leave  
  801d92:	c3                   	ret    
	...

00801d94 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801d97:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9a:	05 00 00 00 30       	add    $0x30000000,%eax
  801d9f:	c1 e8 0c             	shr    $0xc,%eax
}
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    

00801da4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801daa:	8b 45 08             	mov    0x8(%ebp),%eax
  801dad:	89 04 24             	mov    %eax,(%esp)
  801db0:	e8 df ff ff ff       	call   801d94 <fd2num>
  801db5:	c1 e0 0c             	shl    $0xc,%eax
  801db8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801dbd:	c9                   	leave  
  801dbe:	c3                   	ret    

00801dbf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	53                   	push   %ebx
  801dc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801dc6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801dcb:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801dcd:	89 c2                	mov    %eax,%edx
  801dcf:	c1 ea 16             	shr    $0x16,%edx
  801dd2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801dd9:	f6 c2 01             	test   $0x1,%dl
  801ddc:	74 11                	je     801def <fd_alloc+0x30>
  801dde:	89 c2                	mov    %eax,%edx
  801de0:	c1 ea 0c             	shr    $0xc,%edx
  801de3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801dea:	f6 c2 01             	test   $0x1,%dl
  801ded:	75 09                	jne    801df8 <fd_alloc+0x39>
			*fd_store = fd;
  801def:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801df1:	b8 00 00 00 00       	mov    $0x0,%eax
  801df6:	eb 17                	jmp    801e0f <fd_alloc+0x50>
  801df8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801dfd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801e02:	75 c7                	jne    801dcb <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801e04:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801e0a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801e0f:	5b                   	pop    %ebx
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    

00801e12 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801e18:	83 f8 1f             	cmp    $0x1f,%eax
  801e1b:	77 36                	ja     801e53 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801e1d:	c1 e0 0c             	shl    $0xc,%eax
  801e20:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801e25:	89 c2                	mov    %eax,%edx
  801e27:	c1 ea 16             	shr    $0x16,%edx
  801e2a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e31:	f6 c2 01             	test   $0x1,%dl
  801e34:	74 24                	je     801e5a <fd_lookup+0x48>
  801e36:	89 c2                	mov    %eax,%edx
  801e38:	c1 ea 0c             	shr    $0xc,%edx
  801e3b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e42:	f6 c2 01             	test   $0x1,%dl
  801e45:	74 1a                	je     801e61 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801e47:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e4a:	89 02                	mov    %eax,(%edx)
	return 0;
  801e4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e51:	eb 13                	jmp    801e66 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801e53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e58:	eb 0c                	jmp    801e66 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801e5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801e5f:	eb 05                	jmp    801e66 <fd_lookup+0x54>
  801e61:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801e66:	5d                   	pop    %ebp
  801e67:	c3                   	ret    

00801e68 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	53                   	push   %ebx
  801e6c:	83 ec 14             	sub    $0x14,%esp
  801e6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801e75:	ba 00 00 00 00       	mov    $0x0,%edx
  801e7a:	eb 0e                	jmp    801e8a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801e7c:	39 08                	cmp    %ecx,(%eax)
  801e7e:	75 09                	jne    801e89 <dev_lookup+0x21>
			*dev = devtab[i];
  801e80:	89 03                	mov    %eax,(%ebx)
			return 0;
  801e82:	b8 00 00 00 00       	mov    $0x0,%eax
  801e87:	eb 33                	jmp    801ebc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801e89:	42                   	inc    %edx
  801e8a:	8b 04 95 ac 41 80 00 	mov    0x8041ac(,%edx,4),%eax
  801e91:	85 c0                	test   %eax,%eax
  801e93:	75 e7                	jne    801e7c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801e95:	a1 28 64 80 00       	mov    0x806428,%eax
  801e9a:	8b 40 48             	mov    0x48(%eax),%eax
  801e9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ea1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea5:	c7 04 24 30 41 80 00 	movl   $0x804130,(%esp)
  801eac:	e8 87 ec ff ff       	call   800b38 <cprintf>
	*dev = 0;
  801eb1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801eb7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801ebc:	83 c4 14             	add    $0x14,%esp
  801ebf:	5b                   	pop    %ebx
  801ec0:	5d                   	pop    %ebp
  801ec1:	c3                   	ret    

00801ec2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	56                   	push   %esi
  801ec6:	53                   	push   %ebx
  801ec7:	83 ec 30             	sub    $0x30,%esp
  801eca:	8b 75 08             	mov    0x8(%ebp),%esi
  801ecd:	8a 45 0c             	mov    0xc(%ebp),%al
  801ed0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801ed3:	89 34 24             	mov    %esi,(%esp)
  801ed6:	e8 b9 fe ff ff       	call   801d94 <fd2num>
  801edb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ede:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ee2:	89 04 24             	mov    %eax,(%esp)
  801ee5:	e8 28 ff ff ff       	call   801e12 <fd_lookup>
  801eea:	89 c3                	mov    %eax,%ebx
  801eec:	85 c0                	test   %eax,%eax
  801eee:	78 05                	js     801ef5 <fd_close+0x33>
	    || fd != fd2)
  801ef0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801ef3:	74 0d                	je     801f02 <fd_close+0x40>
		return (must_exist ? r : 0);
  801ef5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801ef9:	75 46                	jne    801f41 <fd_close+0x7f>
  801efb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f00:	eb 3f                	jmp    801f41 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801f02:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f09:	8b 06                	mov    (%esi),%eax
  801f0b:	89 04 24             	mov    %eax,(%esp)
  801f0e:	e8 55 ff ff ff       	call   801e68 <dev_lookup>
  801f13:	89 c3                	mov    %eax,%ebx
  801f15:	85 c0                	test   %eax,%eax
  801f17:	78 18                	js     801f31 <fd_close+0x6f>
		if (dev->dev_close)
  801f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f1c:	8b 40 10             	mov    0x10(%eax),%eax
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	74 09                	je     801f2c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801f23:	89 34 24             	mov    %esi,(%esp)
  801f26:	ff d0                	call   *%eax
  801f28:	89 c3                	mov    %eax,%ebx
  801f2a:	eb 05                	jmp    801f31 <fd_close+0x6f>
		else
			r = 0;
  801f2c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801f31:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3c:	e8 1b f7 ff ff       	call   80165c <sys_page_unmap>
	return r;
}
  801f41:	89 d8                	mov    %ebx,%eax
  801f43:	83 c4 30             	add    $0x30,%esp
  801f46:	5b                   	pop    %ebx
  801f47:	5e                   	pop    %esi
  801f48:	5d                   	pop    %ebp
  801f49:	c3                   	ret    

00801f4a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801f4a:	55                   	push   %ebp
  801f4b:	89 e5                	mov    %esp,%ebp
  801f4d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f50:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f57:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5a:	89 04 24             	mov    %eax,(%esp)
  801f5d:	e8 b0 fe ff ff       	call   801e12 <fd_lookup>
  801f62:	85 c0                	test   %eax,%eax
  801f64:	78 13                	js     801f79 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801f66:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801f6d:	00 
  801f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f71:	89 04 24             	mov    %eax,(%esp)
  801f74:	e8 49 ff ff ff       	call   801ec2 <fd_close>
}
  801f79:	c9                   	leave  
  801f7a:	c3                   	ret    

00801f7b <close_all>:

void
close_all(void)
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	53                   	push   %ebx
  801f7f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801f82:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801f87:	89 1c 24             	mov    %ebx,(%esp)
  801f8a:	e8 bb ff ff ff       	call   801f4a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801f8f:	43                   	inc    %ebx
  801f90:	83 fb 20             	cmp    $0x20,%ebx
  801f93:	75 f2                	jne    801f87 <close_all+0xc>
		close(i);
}
  801f95:	83 c4 14             	add    $0x14,%esp
  801f98:	5b                   	pop    %ebx
  801f99:	5d                   	pop    %ebp
  801f9a:	c3                   	ret    

00801f9b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	57                   	push   %edi
  801f9f:	56                   	push   %esi
  801fa0:	53                   	push   %ebx
  801fa1:	83 ec 4c             	sub    $0x4c,%esp
  801fa4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801fa7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801faa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fae:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb1:	89 04 24             	mov    %eax,(%esp)
  801fb4:	e8 59 fe ff ff       	call   801e12 <fd_lookup>
  801fb9:	89 c3                	mov    %eax,%ebx
  801fbb:	85 c0                	test   %eax,%eax
  801fbd:	0f 88 e3 00 00 00    	js     8020a6 <dup+0x10b>
		return r;
	close(newfdnum);
  801fc3:	89 3c 24             	mov    %edi,(%esp)
  801fc6:	e8 7f ff ff ff       	call   801f4a <close>

	newfd = INDEX2FD(newfdnum);
  801fcb:	89 fe                	mov    %edi,%esi
  801fcd:	c1 e6 0c             	shl    $0xc,%esi
  801fd0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801fd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fd9:	89 04 24             	mov    %eax,(%esp)
  801fdc:	e8 c3 fd ff ff       	call   801da4 <fd2data>
  801fe1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801fe3:	89 34 24             	mov    %esi,(%esp)
  801fe6:	e8 b9 fd ff ff       	call   801da4 <fd2data>
  801feb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801fee:	89 d8                	mov    %ebx,%eax
  801ff0:	c1 e8 16             	shr    $0x16,%eax
  801ff3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ffa:	a8 01                	test   $0x1,%al
  801ffc:	74 46                	je     802044 <dup+0xa9>
  801ffe:	89 d8                	mov    %ebx,%eax
  802000:	c1 e8 0c             	shr    $0xc,%eax
  802003:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80200a:	f6 c2 01             	test   $0x1,%dl
  80200d:	74 35                	je     802044 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80200f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802016:	25 07 0e 00 00       	and    $0xe07,%eax
  80201b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80201f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802022:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802026:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80202d:	00 
  80202e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802032:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802039:	e8 cb f5 ff ff       	call   801609 <sys_page_map>
  80203e:	89 c3                	mov    %eax,%ebx
  802040:	85 c0                	test   %eax,%eax
  802042:	78 3b                	js     80207f <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802044:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802047:	89 c2                	mov    %eax,%edx
  802049:	c1 ea 0c             	shr    $0xc,%edx
  80204c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802053:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  802059:	89 54 24 10          	mov    %edx,0x10(%esp)
  80205d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802061:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802068:	00 
  802069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80206d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802074:	e8 90 f5 ff ff       	call   801609 <sys_page_map>
  802079:	89 c3                	mov    %eax,%ebx
  80207b:	85 c0                	test   %eax,%eax
  80207d:	79 25                	jns    8020a4 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80207f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802083:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80208a:	e8 cd f5 ff ff       	call   80165c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80208f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802092:	89 44 24 04          	mov    %eax,0x4(%esp)
  802096:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80209d:	e8 ba f5 ff ff       	call   80165c <sys_page_unmap>
	return r;
  8020a2:	eb 02                	jmp    8020a6 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8020a4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8020a6:	89 d8                	mov    %ebx,%eax
  8020a8:	83 c4 4c             	add    $0x4c,%esp
  8020ab:	5b                   	pop    %ebx
  8020ac:	5e                   	pop    %esi
  8020ad:	5f                   	pop    %edi
  8020ae:	5d                   	pop    %ebp
  8020af:	c3                   	ret    

008020b0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8020b0:	55                   	push   %ebp
  8020b1:	89 e5                	mov    %esp,%ebp
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 24             	sub    $0x24,%esp
  8020b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c1:	89 1c 24             	mov    %ebx,(%esp)
  8020c4:	e8 49 fd ff ff       	call   801e12 <fd_lookup>
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	78 6d                	js     80213a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020d7:	8b 00                	mov    (%eax),%eax
  8020d9:	89 04 24             	mov    %eax,(%esp)
  8020dc:	e8 87 fd ff ff       	call   801e68 <dev_lookup>
  8020e1:	85 c0                	test   %eax,%eax
  8020e3:	78 55                	js     80213a <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8020e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020e8:	8b 50 08             	mov    0x8(%eax),%edx
  8020eb:	83 e2 03             	and    $0x3,%edx
  8020ee:	83 fa 01             	cmp    $0x1,%edx
  8020f1:	75 23                	jne    802116 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8020f3:	a1 28 64 80 00       	mov    0x806428,%eax
  8020f8:	8b 40 48             	mov    0x48(%eax),%eax
  8020fb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  802103:	c7 04 24 71 41 80 00 	movl   $0x804171,(%esp)
  80210a:	e8 29 ea ff ff       	call   800b38 <cprintf>
		return -E_INVAL;
  80210f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802114:	eb 24                	jmp    80213a <read+0x8a>
	}
	if (!dev->dev_read)
  802116:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802119:	8b 52 08             	mov    0x8(%edx),%edx
  80211c:	85 d2                	test   %edx,%edx
  80211e:	74 15                	je     802135 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802120:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802123:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802127:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80212a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80212e:	89 04 24             	mov    %eax,(%esp)
  802131:	ff d2                	call   *%edx
  802133:	eb 05                	jmp    80213a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802135:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80213a:	83 c4 24             	add    $0x24,%esp
  80213d:	5b                   	pop    %ebx
  80213e:	5d                   	pop    %ebp
  80213f:	c3                   	ret    

00802140 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802140:	55                   	push   %ebp
  802141:	89 e5                	mov    %esp,%ebp
  802143:	57                   	push   %edi
  802144:	56                   	push   %esi
  802145:	53                   	push   %ebx
  802146:	83 ec 1c             	sub    $0x1c,%esp
  802149:	8b 7d 08             	mov    0x8(%ebp),%edi
  80214c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80214f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802154:	eb 23                	jmp    802179 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802156:	89 f0                	mov    %esi,%eax
  802158:	29 d8                	sub    %ebx,%eax
  80215a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80215e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802161:	01 d8                	add    %ebx,%eax
  802163:	89 44 24 04          	mov    %eax,0x4(%esp)
  802167:	89 3c 24             	mov    %edi,(%esp)
  80216a:	e8 41 ff ff ff       	call   8020b0 <read>
		if (m < 0)
  80216f:	85 c0                	test   %eax,%eax
  802171:	78 10                	js     802183 <readn+0x43>
			return m;
		if (m == 0)
  802173:	85 c0                	test   %eax,%eax
  802175:	74 0a                	je     802181 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802177:	01 c3                	add    %eax,%ebx
  802179:	39 f3                	cmp    %esi,%ebx
  80217b:	72 d9                	jb     802156 <readn+0x16>
  80217d:	89 d8                	mov    %ebx,%eax
  80217f:	eb 02                	jmp    802183 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  802181:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  802183:	83 c4 1c             	add    $0x1c,%esp
  802186:	5b                   	pop    %ebx
  802187:	5e                   	pop    %esi
  802188:	5f                   	pop    %edi
  802189:	5d                   	pop    %ebp
  80218a:	c3                   	ret    

0080218b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80218b:	55                   	push   %ebp
  80218c:	89 e5                	mov    %esp,%ebp
  80218e:	53                   	push   %ebx
  80218f:	83 ec 24             	sub    $0x24,%esp
  802192:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802195:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802198:	89 44 24 04          	mov    %eax,0x4(%esp)
  80219c:	89 1c 24             	mov    %ebx,(%esp)
  80219f:	e8 6e fc ff ff       	call   801e12 <fd_lookup>
  8021a4:	85 c0                	test   %eax,%eax
  8021a6:	78 68                	js     802210 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8021a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021b2:	8b 00                	mov    (%eax),%eax
  8021b4:	89 04 24             	mov    %eax,(%esp)
  8021b7:	e8 ac fc ff ff       	call   801e68 <dev_lookup>
  8021bc:	85 c0                	test   %eax,%eax
  8021be:	78 50                	js     802210 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8021c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021c3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8021c7:	75 23                	jne    8021ec <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8021c9:	a1 28 64 80 00       	mov    0x806428,%eax
  8021ce:	8b 40 48             	mov    0x48(%eax),%eax
  8021d1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d9:	c7 04 24 8d 41 80 00 	movl   $0x80418d,(%esp)
  8021e0:	e8 53 e9 ff ff       	call   800b38 <cprintf>
		return -E_INVAL;
  8021e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8021ea:	eb 24                	jmp    802210 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8021ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021ef:	8b 52 0c             	mov    0xc(%edx),%edx
  8021f2:	85 d2                	test   %edx,%edx
  8021f4:	74 15                	je     80220b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8021f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8021f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802200:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802204:	89 04 24             	mov    %eax,(%esp)
  802207:	ff d2                	call   *%edx
  802209:	eb 05                	jmp    802210 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80220b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  802210:	83 c4 24             	add    $0x24,%esp
  802213:	5b                   	pop    %ebx
  802214:	5d                   	pop    %ebp
  802215:	c3                   	ret    

00802216 <seek>:

int
seek(int fdnum, off_t offset)
{
  802216:	55                   	push   %ebp
  802217:	89 e5                	mov    %esp,%ebp
  802219:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80221c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80221f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802223:	8b 45 08             	mov    0x8(%ebp),%eax
  802226:	89 04 24             	mov    %eax,(%esp)
  802229:	e8 e4 fb ff ff       	call   801e12 <fd_lookup>
  80222e:	85 c0                	test   %eax,%eax
  802230:	78 0e                	js     802240 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  802232:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802235:	8b 55 0c             	mov    0xc(%ebp),%edx
  802238:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80223b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802240:	c9                   	leave  
  802241:	c3                   	ret    

00802242 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802242:	55                   	push   %ebp
  802243:	89 e5                	mov    %esp,%ebp
  802245:	53                   	push   %ebx
  802246:	83 ec 24             	sub    $0x24,%esp
  802249:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80224c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80224f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802253:	89 1c 24             	mov    %ebx,(%esp)
  802256:	e8 b7 fb ff ff       	call   801e12 <fd_lookup>
  80225b:	85 c0                	test   %eax,%eax
  80225d:	78 61                	js     8022c0 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80225f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802262:	89 44 24 04          	mov    %eax,0x4(%esp)
  802266:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802269:	8b 00                	mov    (%eax),%eax
  80226b:	89 04 24             	mov    %eax,(%esp)
  80226e:	e8 f5 fb ff ff       	call   801e68 <dev_lookup>
  802273:	85 c0                	test   %eax,%eax
  802275:	78 49                	js     8022c0 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802277:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80227a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80227e:	75 23                	jne    8022a3 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802280:	a1 28 64 80 00       	mov    0x806428,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802285:	8b 40 48             	mov    0x48(%eax),%eax
  802288:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80228c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802290:	c7 04 24 50 41 80 00 	movl   $0x804150,(%esp)
  802297:	e8 9c e8 ff ff       	call   800b38 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80229c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8022a1:	eb 1d                	jmp    8022c0 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8022a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022a6:	8b 52 18             	mov    0x18(%edx),%edx
  8022a9:	85 d2                	test   %edx,%edx
  8022ab:	74 0e                	je     8022bb <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8022ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022b0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8022b4:	89 04 24             	mov    %eax,(%esp)
  8022b7:	ff d2                	call   *%edx
  8022b9:	eb 05                	jmp    8022c0 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8022bb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8022c0:	83 c4 24             	add    $0x24,%esp
  8022c3:	5b                   	pop    %ebx
  8022c4:	5d                   	pop    %ebp
  8022c5:	c3                   	ret    

008022c6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8022c6:	55                   	push   %ebp
  8022c7:	89 e5                	mov    %esp,%ebp
  8022c9:	53                   	push   %ebx
  8022ca:	83 ec 24             	sub    $0x24,%esp
  8022cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8022d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8022da:	89 04 24             	mov    %eax,(%esp)
  8022dd:	e8 30 fb ff ff       	call   801e12 <fd_lookup>
  8022e2:	85 c0                	test   %eax,%eax
  8022e4:	78 52                	js     802338 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8022e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022f0:	8b 00                	mov    (%eax),%eax
  8022f2:	89 04 24             	mov    %eax,(%esp)
  8022f5:	e8 6e fb ff ff       	call   801e68 <dev_lookup>
  8022fa:	85 c0                	test   %eax,%eax
  8022fc:	78 3a                	js     802338 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8022fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802301:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802305:	74 2c                	je     802333 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802307:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80230a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802311:	00 00 00 
	stat->st_isdir = 0;
  802314:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80231b:	00 00 00 
	stat->st_dev = dev;
  80231e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802324:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802328:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80232b:	89 14 24             	mov    %edx,(%esp)
  80232e:	ff 50 14             	call   *0x14(%eax)
  802331:	eb 05                	jmp    802338 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802333:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802338:	83 c4 24             	add    $0x24,%esp
  80233b:	5b                   	pop    %ebx
  80233c:	5d                   	pop    %ebp
  80233d:	c3                   	ret    

0080233e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80233e:	55                   	push   %ebp
  80233f:	89 e5                	mov    %esp,%ebp
  802341:	56                   	push   %esi
  802342:	53                   	push   %ebx
  802343:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802346:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80234d:	00 
  80234e:	8b 45 08             	mov    0x8(%ebp),%eax
  802351:	89 04 24             	mov    %eax,(%esp)
  802354:	e8 2a 02 00 00       	call   802583 <open>
  802359:	89 c3                	mov    %eax,%ebx
  80235b:	85 c0                	test   %eax,%eax
  80235d:	78 1b                	js     80237a <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80235f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802362:	89 44 24 04          	mov    %eax,0x4(%esp)
  802366:	89 1c 24             	mov    %ebx,(%esp)
  802369:	e8 58 ff ff ff       	call   8022c6 <fstat>
  80236e:	89 c6                	mov    %eax,%esi
	close(fd);
  802370:	89 1c 24             	mov    %ebx,(%esp)
  802373:	e8 d2 fb ff ff       	call   801f4a <close>
	return r;
  802378:	89 f3                	mov    %esi,%ebx
}
  80237a:	89 d8                	mov    %ebx,%eax
  80237c:	83 c4 10             	add    $0x10,%esp
  80237f:	5b                   	pop    %ebx
  802380:	5e                   	pop    %esi
  802381:	5d                   	pop    %ebp
  802382:	c3                   	ret    
	...

00802384 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802384:	55                   	push   %ebp
  802385:	89 e5                	mov    %esp,%ebp
  802387:	56                   	push   %esi
  802388:	53                   	push   %ebx
  802389:	83 ec 10             	sub    $0x10,%esp
  80238c:	89 c3                	mov    %eax,%ebx
  80238e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  802390:	83 3d 20 64 80 00 00 	cmpl   $0x0,0x806420
  802397:	75 11                	jne    8023aa <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802399:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8023a0:	e8 6e 14 00 00       	call   803813 <ipc_find_env>
  8023a5:	a3 20 64 80 00       	mov    %eax,0x806420
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8023aa:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8023b1:	00 
  8023b2:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8023b9:	00 
  8023ba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023be:	a1 20 64 80 00       	mov    0x806420,%eax
  8023c3:	89 04 24             	mov    %eax,(%esp)
  8023c6:	e8 c5 13 00 00       	call   803790 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8023cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8023d2:	00 
  8023d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023de:	e8 3d 13 00 00       	call   803720 <ipc_recv>
}
  8023e3:	83 c4 10             	add    $0x10,%esp
  8023e6:	5b                   	pop    %ebx
  8023e7:	5e                   	pop    %esi
  8023e8:	5d                   	pop    %ebp
  8023e9:	c3                   	ret    

008023ea <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8023ea:	55                   	push   %ebp
  8023eb:	89 e5                	mov    %esp,%ebp
  8023ed:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8023f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f3:	8b 40 0c             	mov    0xc(%eax),%eax
  8023f6:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8023fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023fe:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802403:	ba 00 00 00 00       	mov    $0x0,%edx
  802408:	b8 02 00 00 00       	mov    $0x2,%eax
  80240d:	e8 72 ff ff ff       	call   802384 <fsipc>
}
  802412:	c9                   	leave  
  802413:	c3                   	ret    

00802414 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802414:	55                   	push   %ebp
  802415:	89 e5                	mov    %esp,%ebp
  802417:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80241a:	8b 45 08             	mov    0x8(%ebp),%eax
  80241d:	8b 40 0c             	mov    0xc(%eax),%eax
  802420:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  802425:	ba 00 00 00 00       	mov    $0x0,%edx
  80242a:	b8 06 00 00 00       	mov    $0x6,%eax
  80242f:	e8 50 ff ff ff       	call   802384 <fsipc>
}
  802434:	c9                   	leave  
  802435:	c3                   	ret    

00802436 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802436:	55                   	push   %ebp
  802437:	89 e5                	mov    %esp,%ebp
  802439:	53                   	push   %ebx
  80243a:	83 ec 14             	sub    $0x14,%esp
  80243d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802440:	8b 45 08             	mov    0x8(%ebp),%eax
  802443:	8b 40 0c             	mov    0xc(%eax),%eax
  802446:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80244b:	ba 00 00 00 00       	mov    $0x0,%edx
  802450:	b8 05 00 00 00       	mov    $0x5,%eax
  802455:	e8 2a ff ff ff       	call   802384 <fsipc>
  80245a:	85 c0                	test   %eax,%eax
  80245c:	78 2b                	js     802489 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80245e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802465:	00 
  802466:	89 1c 24             	mov    %ebx,(%esp)
  802469:	e8 55 ed ff ff       	call   8011c3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80246e:	a1 80 70 80 00       	mov    0x807080,%eax
  802473:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802479:	a1 84 70 80 00       	mov    0x807084,%eax
  80247e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802484:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802489:	83 c4 14             	add    $0x14,%esp
  80248c:	5b                   	pop    %ebx
  80248d:	5d                   	pop    %ebp
  80248e:	c3                   	ret    

0080248f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80248f:	55                   	push   %ebp
  802490:	89 e5                	mov    %esp,%ebp
  802492:	83 ec 18             	sub    $0x18,%esp
  802495:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  802498:	8b 55 08             	mov    0x8(%ebp),%edx
  80249b:	8b 52 0c             	mov    0xc(%edx),%edx
  80249e:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  8024a4:	a3 04 70 80 00       	mov    %eax,0x807004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  8024a9:	89 c2                	mov    %eax,%edx
  8024ab:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8024b0:	76 05                	jbe    8024b7 <devfile_write+0x28>
  8024b2:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  8024b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8024bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024c2:	c7 04 24 08 70 80 00 	movl   $0x807008,(%esp)
  8024c9:	e8 d8 ee ff ff       	call   8013a6 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8024ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8024d3:	b8 04 00 00 00       	mov    $0x4,%eax
  8024d8:	e8 a7 fe ff ff       	call   802384 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  8024dd:	c9                   	leave  
  8024de:	c3                   	ret    

008024df <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8024df:	55                   	push   %ebp
  8024e0:	89 e5                	mov    %esp,%ebp
  8024e2:	56                   	push   %esi
  8024e3:	53                   	push   %ebx
  8024e4:	83 ec 10             	sub    $0x10,%esp
  8024e7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8024ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8024f0:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8024f5:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8024fb:	ba 00 00 00 00       	mov    $0x0,%edx
  802500:	b8 03 00 00 00       	mov    $0x3,%eax
  802505:	e8 7a fe ff ff       	call   802384 <fsipc>
  80250a:	89 c3                	mov    %eax,%ebx
  80250c:	85 c0                	test   %eax,%eax
  80250e:	78 6a                	js     80257a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  802510:	39 c6                	cmp    %eax,%esi
  802512:	73 24                	jae    802538 <devfile_read+0x59>
  802514:	c7 44 24 0c c0 41 80 	movl   $0x8041c0,0xc(%esp)
  80251b:	00 
  80251c:	c7 44 24 08 49 3c 80 	movl   $0x803c49,0x8(%esp)
  802523:	00 
  802524:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80252b:	00 
  80252c:	c7 04 24 c7 41 80 00 	movl   $0x8041c7,(%esp)
  802533:	e8 08 e5 ff ff       	call   800a40 <_panic>
	assert(r <= PGSIZE);
  802538:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80253d:	7e 24                	jle    802563 <devfile_read+0x84>
  80253f:	c7 44 24 0c d2 41 80 	movl   $0x8041d2,0xc(%esp)
  802546:	00 
  802547:	c7 44 24 08 49 3c 80 	movl   $0x803c49,0x8(%esp)
  80254e:	00 
  80254f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  802556:	00 
  802557:	c7 04 24 c7 41 80 00 	movl   $0x8041c7,(%esp)
  80255e:	e8 dd e4 ff ff       	call   800a40 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802563:	89 44 24 08          	mov    %eax,0x8(%esp)
  802567:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80256e:	00 
  80256f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802572:	89 04 24             	mov    %eax,(%esp)
  802575:	e8 c2 ed ff ff       	call   80133c <memmove>
	return r;
}
  80257a:	89 d8                	mov    %ebx,%eax
  80257c:	83 c4 10             	add    $0x10,%esp
  80257f:	5b                   	pop    %ebx
  802580:	5e                   	pop    %esi
  802581:	5d                   	pop    %ebp
  802582:	c3                   	ret    

00802583 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802583:	55                   	push   %ebp
  802584:	89 e5                	mov    %esp,%ebp
  802586:	56                   	push   %esi
  802587:	53                   	push   %ebx
  802588:	83 ec 20             	sub    $0x20,%esp
  80258b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80258e:	89 34 24             	mov    %esi,(%esp)
  802591:	e8 fa eb ff ff       	call   801190 <strlen>
  802596:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80259b:	7f 60                	jg     8025fd <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80259d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025a0:	89 04 24             	mov    %eax,(%esp)
  8025a3:	e8 17 f8 ff ff       	call   801dbf <fd_alloc>
  8025a8:	89 c3                	mov    %eax,%ebx
  8025aa:	85 c0                	test   %eax,%eax
  8025ac:	78 54                	js     802602 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8025ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025b2:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  8025b9:	e8 05 ec ff ff       	call   8011c3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8025be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025c1:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8025c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8025ce:	e8 b1 fd ff ff       	call   802384 <fsipc>
  8025d3:	89 c3                	mov    %eax,%ebx
  8025d5:	85 c0                	test   %eax,%eax
  8025d7:	79 15                	jns    8025ee <open+0x6b>
		fd_close(fd, 0);
  8025d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8025e0:	00 
  8025e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025e4:	89 04 24             	mov    %eax,(%esp)
  8025e7:	e8 d6 f8 ff ff       	call   801ec2 <fd_close>
		return r;
  8025ec:	eb 14                	jmp    802602 <open+0x7f>
	}

	return fd2num(fd);
  8025ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025f1:	89 04 24             	mov    %eax,(%esp)
  8025f4:	e8 9b f7 ff ff       	call   801d94 <fd2num>
  8025f9:	89 c3                	mov    %eax,%ebx
  8025fb:	eb 05                	jmp    802602 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8025fd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802602:	89 d8                	mov    %ebx,%eax
  802604:	83 c4 20             	add    $0x20,%esp
  802607:	5b                   	pop    %ebx
  802608:	5e                   	pop    %esi
  802609:	5d                   	pop    %ebp
  80260a:	c3                   	ret    

0080260b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80260b:	55                   	push   %ebp
  80260c:	89 e5                	mov    %esp,%ebp
  80260e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802611:	ba 00 00 00 00       	mov    $0x0,%edx
  802616:	b8 08 00 00 00       	mov    $0x8,%eax
  80261b:	e8 64 fd ff ff       	call   802384 <fsipc>
}
  802620:	c9                   	leave  
  802621:	c3                   	ret    
	...

00802624 <writebuf>:
};


static void
writebuf(struct printbuf *b)
{
  802624:	55                   	push   %ebp
  802625:	89 e5                	mov    %esp,%ebp
  802627:	53                   	push   %ebx
  802628:	83 ec 14             	sub    $0x14,%esp
  80262b:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
  80262d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802631:	7e 32                	jle    802665 <writebuf+0x41>
		ssize_t result = write(b->fd, b->buf, b->idx);
  802633:	8b 40 04             	mov    0x4(%eax),%eax
  802636:	89 44 24 08          	mov    %eax,0x8(%esp)
  80263a:	8d 43 10             	lea    0x10(%ebx),%eax
  80263d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802641:	8b 03                	mov    (%ebx),%eax
  802643:	89 04 24             	mov    %eax,(%esp)
  802646:	e8 40 fb ff ff       	call   80218b <write>
		if (result > 0)
  80264b:	85 c0                	test   %eax,%eax
  80264d:	7e 03                	jle    802652 <writebuf+0x2e>
			b->result += result;
  80264f:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  802652:	39 43 04             	cmp    %eax,0x4(%ebx)
  802655:	74 0e                	je     802665 <writebuf+0x41>
			b->error = (result < 0 ? result : 0);
  802657:	89 c2                	mov    %eax,%edx
  802659:	85 c0                	test   %eax,%eax
  80265b:	7e 05                	jle    802662 <writebuf+0x3e>
  80265d:	ba 00 00 00 00       	mov    $0x0,%edx
  802662:	89 53 0c             	mov    %edx,0xc(%ebx)
	}
}
  802665:	83 c4 14             	add    $0x14,%esp
  802668:	5b                   	pop    %ebx
  802669:	5d                   	pop    %ebp
  80266a:	c3                   	ret    

0080266b <putch>:

static void
putch(int ch, void *thunk)
{
  80266b:	55                   	push   %ebp
  80266c:	89 e5                	mov    %esp,%ebp
  80266e:	53                   	push   %ebx
  80266f:	83 ec 04             	sub    $0x4,%esp
  802672:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802675:	8b 43 04             	mov    0x4(%ebx),%eax
  802678:	8b 55 08             	mov    0x8(%ebp),%edx
  80267b:	88 54 03 10          	mov    %dl,0x10(%ebx,%eax,1)
  80267f:	40                   	inc    %eax
  802680:	89 43 04             	mov    %eax,0x4(%ebx)
	if (b->idx == 256) {
  802683:	3d 00 01 00 00       	cmp    $0x100,%eax
  802688:	75 0e                	jne    802698 <putch+0x2d>
		writebuf(b);
  80268a:	89 d8                	mov    %ebx,%eax
  80268c:	e8 93 ff ff ff       	call   802624 <writebuf>
		b->idx = 0;
  802691:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  802698:	83 c4 04             	add    $0x4,%esp
  80269b:	5b                   	pop    %ebx
  80269c:	5d                   	pop    %ebp
  80269d:	c3                   	ret    

0080269e <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80269e:	55                   	push   %ebp
  80269f:	89 e5                	mov    %esp,%ebp
  8026a1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.fd = fd;
  8026a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8026aa:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8026b0:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8026b7:	00 00 00 
	b.result = 0;
  8026ba:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8026c1:	00 00 00 
	b.error = 1;
  8026c4:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8026cb:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8026ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8026d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026dc:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8026e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026e6:	c7 04 24 6b 26 80 00 	movl   $0x80266b,(%esp)
  8026ed:	e8 a8 e5 ff ff       	call   800c9a <vprintfmt>
	if (b.idx > 0)
  8026f2:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8026f9:	7e 0b                	jle    802706 <vfprintf+0x68>
		writebuf(&b);
  8026fb:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802701:	e8 1e ff ff ff       	call   802624 <writebuf>

	return (b.result ? b.result : b.error);
  802706:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80270c:	85 c0                	test   %eax,%eax
  80270e:	75 06                	jne    802716 <vfprintf+0x78>
  802710:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  802716:	c9                   	leave  
  802717:	c3                   	ret    

00802718 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  802718:	55                   	push   %ebp
  802719:	89 e5                	mov    %esp,%ebp
  80271b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80271e:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802721:	89 44 24 08          	mov    %eax,0x8(%esp)
  802725:	8b 45 0c             	mov    0xc(%ebp),%eax
  802728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80272c:	8b 45 08             	mov    0x8(%ebp),%eax
  80272f:	89 04 24             	mov    %eax,(%esp)
  802732:	e8 67 ff ff ff       	call   80269e <vfprintf>
	va_end(ap);

	return cnt;
}
  802737:	c9                   	leave  
  802738:	c3                   	ret    

00802739 <printf>:

int
printf(const char *fmt, ...)
{
  802739:	55                   	push   %ebp
  80273a:	89 e5                	mov    %esp,%ebp
  80273c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80273f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802742:	89 44 24 08          	mov    %eax,0x8(%esp)
  802746:	8b 45 08             	mov    0x8(%ebp),%eax
  802749:	89 44 24 04          	mov    %eax,0x4(%esp)
  80274d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  802754:	e8 45 ff ff ff       	call   80269e <vfprintf>
	va_end(ap);

	return cnt;
}
  802759:	c9                   	leave  
  80275a:	c3                   	ret    
	...

0080275c <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80275c:	55                   	push   %ebp
  80275d:	89 e5                	mov    %esp,%ebp
  80275f:	57                   	push   %edi
  802760:	56                   	push   %esi
  802761:	53                   	push   %ebx
  802762:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  802768:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80276f:	00 
  802770:	8b 45 08             	mov    0x8(%ebp),%eax
  802773:	89 04 24             	mov    %eax,(%esp)
  802776:	e8 08 fe ff ff       	call   802583 <open>
  80277b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  802781:	85 c0                	test   %eax,%eax
  802783:	0f 88 a9 05 00 00    	js     802d32 <spawn+0x5d6>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802789:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  802790:	00 
  802791:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802797:	89 44 24 04          	mov    %eax,0x4(%esp)
  80279b:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8027a1:	89 04 24             	mov    %eax,(%esp)
  8027a4:	e8 97 f9 ff ff       	call   802140 <readn>
  8027a9:	3d 00 02 00 00       	cmp    $0x200,%eax
  8027ae:	75 0c                	jne    8027bc <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  8027b0:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8027b7:	45 4c 46 
  8027ba:	74 3b                	je     8027f7 <spawn+0x9b>
		close(fd);
  8027bc:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8027c2:	89 04 24             	mov    %eax,(%esp)
  8027c5:	e8 80 f7 ff ff       	call   801f4a <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8027ca:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  8027d1:	46 
  8027d2:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  8027d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027dc:	c7 04 24 de 41 80 00 	movl   $0x8041de,(%esp)
  8027e3:	e8 50 e3 ff ff       	call   800b38 <cprintf>
		return -E_NOT_EXEC;
  8027e8:	c7 85 88 fd ff ff f2 	movl   $0xfffffff2,-0x278(%ebp)
  8027ef:	ff ff ff 
  8027f2:	e9 47 05 00 00       	jmp    802d3e <spawn+0x5e2>
  8027f7:	ba 07 00 00 00       	mov    $0x7,%edx
  8027fc:	89 d0                	mov    %edx,%eax
  8027fe:	cd 30                	int    $0x30
  802800:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  802806:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80280c:	85 c0                	test   %eax,%eax
  80280e:	0f 88 2a 05 00 00    	js     802d3e <spawn+0x5e2>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  802814:	25 ff 03 00 00       	and    $0x3ff,%eax
  802819:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  802820:	c1 e0 07             	shl    $0x7,%eax
  802823:	29 d0                	sub    %edx,%eax
  802825:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  80282b:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802831:	b9 11 00 00 00       	mov    $0x11,%ecx
  802836:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802838:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80283e:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802844:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  802849:	bb 00 00 00 00       	mov    $0x0,%ebx
  80284e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802851:	eb 0d                	jmp    802860 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  802853:	89 04 24             	mov    %eax,(%esp)
  802856:	e8 35 e9 ff ff       	call   801190 <strlen>
  80285b:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80285f:	46                   	inc    %esi
  802860:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802862:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  802869:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  80286c:	85 c0                	test   %eax,%eax
  80286e:	75 e3                	jne    802853 <spawn+0xf7>
  802870:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  802876:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80287c:	bf 00 10 40 00       	mov    $0x401000,%edi
  802881:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802883:	89 f8                	mov    %edi,%eax
  802885:	83 e0 fc             	and    $0xfffffffc,%eax
  802888:	f7 d2                	not    %edx
  80288a:	8d 14 90             	lea    (%eax,%edx,4),%edx
  80288d:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  802893:	89 d0                	mov    %edx,%eax
  802895:	83 e8 08             	sub    $0x8,%eax
  802898:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80289d:	0f 86 ac 04 00 00    	jbe    802d4f <spawn+0x5f3>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8028a3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8028aa:	00 
  8028ab:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8028b2:	00 
  8028b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028ba:	e8 f6 ec ff ff       	call   8015b5 <sys_page_alloc>
  8028bf:	85 c0                	test   %eax,%eax
  8028c1:	0f 88 8d 04 00 00    	js     802d54 <spawn+0x5f8>
  8028c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028cc:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  8028d2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8028d5:	eb 2e                	jmp    802905 <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8028d7:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8028dd:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  8028e3:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  8028e6:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8028e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028ed:	89 3c 24             	mov    %edi,(%esp)
  8028f0:	e8 ce e8 ff ff       	call   8011c3 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8028f5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8028f8:	89 04 24             	mov    %eax,(%esp)
  8028fb:	e8 90 e8 ff ff       	call   801190 <strlen>
  802900:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802904:	43                   	inc    %ebx
  802905:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  80290b:	7c ca                	jl     8028d7 <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80290d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  802913:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802919:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802920:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802926:	74 24                	je     80294c <spawn+0x1f0>
  802928:	c7 44 24 0c 3c 42 80 	movl   $0x80423c,0xc(%esp)
  80292f:	00 
  802930:	c7 44 24 08 49 3c 80 	movl   $0x803c49,0x8(%esp)
  802937:	00 
  802938:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  80293f:	00 
  802940:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  802947:	e8 f4 e0 ff ff       	call   800a40 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  80294c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802952:	2d 00 30 80 11       	sub    $0x11803000,%eax
  802957:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80295d:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802960:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802966:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802969:	89 d0                	mov    %edx,%eax
  80296b:	2d 08 30 80 11       	sub    $0x11803008,%eax
  802970:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  802976:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80297d:	00 
  80297e:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  802985:	ee 
  802986:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  80298c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802990:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802997:	00 
  802998:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80299f:	e8 65 ec ff ff       	call   801609 <sys_page_map>
  8029a4:	89 c3                	mov    %eax,%ebx
  8029a6:	85 c0                	test   %eax,%eax
  8029a8:	78 1a                	js     8029c4 <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8029aa:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8029b1:	00 
  8029b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029b9:	e8 9e ec ff ff       	call   80165c <sys_page_unmap>
  8029be:	89 c3                	mov    %eax,%ebx
  8029c0:	85 c0                	test   %eax,%eax
  8029c2:	79 1f                	jns    8029e3 <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8029c4:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8029cb:	00 
  8029cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029d3:	e8 84 ec ff ff       	call   80165c <sys_page_unmap>
	return r;
  8029d8:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8029de:	e9 5b 03 00 00       	jmp    802d3e <spawn+0x5e2>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8029e3:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  8029e9:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  8029ef:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8029f5:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  8029fc:	00 00 00 
  8029ff:	e9 bb 01 00 00       	jmp    802bbf <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  802a04:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802a0a:	83 38 01             	cmpl   $0x1,(%eax)
  802a0d:	0f 85 9f 01 00 00    	jne    802bb2 <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802a13:	89 c2                	mov    %eax,%edx
  802a15:	8b 40 18             	mov    0x18(%eax),%eax
  802a18:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  802a1b:	83 f8 01             	cmp    $0x1,%eax
  802a1e:	19 c0                	sbb    %eax,%eax
  802a20:	83 e0 fe             	and    $0xfffffffe,%eax
  802a23:	83 c0 07             	add    $0x7,%eax
  802a26:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  802a2c:	8b 52 04             	mov    0x4(%edx),%edx
  802a2f:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  802a35:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802a3b:	8b 40 10             	mov    0x10(%eax),%eax
  802a3e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802a44:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  802a4a:	8b 52 14             	mov    0x14(%edx),%edx
  802a4d:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  802a53:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  802a59:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802a5c:	89 f8                	mov    %edi,%eax
  802a5e:	25 ff 0f 00 00       	and    $0xfff,%eax
  802a63:	74 16                	je     802a7b <spawn+0x31f>
		va -= i;
  802a65:	29 c7                	sub    %eax,%edi
		memsz += i;
  802a67:	01 c2                	add    %eax,%edx
  802a69:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  802a6f:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  802a75:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802a7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802a80:	e9 1f 01 00 00       	jmp    802ba4 <spawn+0x448>
		if (i >= filesz) {
  802a85:	3b 9d 94 fd ff ff    	cmp    -0x26c(%ebp),%ebx
  802a8b:	72 2b                	jb     802ab8 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  802a8d:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  802a93:	89 54 24 08          	mov    %edx,0x8(%esp)
  802a97:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802a9b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802aa1:	89 04 24             	mov    %eax,(%esp)
  802aa4:	e8 0c eb ff ff       	call   8015b5 <sys_page_alloc>
  802aa9:	85 c0                	test   %eax,%eax
  802aab:	0f 89 e7 00 00 00    	jns    802b98 <spawn+0x43c>
  802ab1:	89 c6                	mov    %eax,%esi
  802ab3:	e9 56 02 00 00       	jmp    802d0e <spawn+0x5b2>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  802ab8:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802abf:	00 
  802ac0:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802ac7:	00 
  802ac8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802acf:	e8 e1 ea ff ff       	call   8015b5 <sys_page_alloc>
  802ad4:	85 c0                	test   %eax,%eax
  802ad6:	0f 88 28 02 00 00    	js     802d04 <spawn+0x5a8>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802adc:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  802ae2:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  802ae4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ae8:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802aee:	89 04 24             	mov    %eax,(%esp)
  802af1:	e8 20 f7 ff ff       	call   802216 <seek>
  802af6:	85 c0                	test   %eax,%eax
  802af8:	0f 88 0a 02 00 00    	js     802d08 <spawn+0x5ac>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  802afe:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802b04:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802b06:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802b0b:	76 05                	jbe    802b12 <spawn+0x3b6>
  802b0d:	b8 00 10 00 00       	mov    $0x1000,%eax
  802b12:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b16:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b1d:	00 
  802b1e:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802b24:	89 04 24             	mov    %eax,(%esp)
  802b27:	e8 14 f6 ff ff       	call   802140 <readn>
  802b2c:	85 c0                	test   %eax,%eax
  802b2e:	0f 88 d8 01 00 00    	js     802d0c <spawn+0x5b0>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  802b34:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  802b3a:	89 54 24 10          	mov    %edx,0x10(%esp)
  802b3e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b42:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802b48:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b4c:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b53:	00 
  802b54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b5b:	e8 a9 ea ff ff       	call   801609 <sys_page_map>
  802b60:	85 c0                	test   %eax,%eax
  802b62:	79 20                	jns    802b84 <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  802b64:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802b68:	c7 44 24 08 04 42 80 	movl   $0x804204,0x8(%esp)
  802b6f:	00 
  802b70:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  802b77:	00 
  802b78:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  802b7f:	e8 bc de ff ff       	call   800a40 <_panic>
			sys_page_unmap(0, UTEMP);
  802b84:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  802b8b:	00 
  802b8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b93:	e8 c4 ea ff ff       	call   80165c <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802b98:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802b9e:	81 c7 00 10 00 00    	add    $0x1000,%edi
  802ba4:	89 de                	mov    %ebx,%esi
  802ba6:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  802bac:	0f 82 d3 fe ff ff    	jb     802a85 <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802bb2:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  802bb8:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  802bbf:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802bc6:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  802bcc:	0f 8c 32 fe ff ff    	jl     802a04 <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  802bd2:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802bd8:	89 04 24             	mov    %eax,(%esp)
  802bdb:	e8 6a f3 ff ff       	call   801f4a <close>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int e;
	for (uint32_t addr = 0; addr < UTOP ; addr+=PGSIZE)
  802be0:	be 00 00 00 00       	mov    $0x0,%esi
  802be5:	eb 0c                	jmp    802bf3 <spawn+0x497>
	{
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  802be7:	81 fe 00 f0 bf ee    	cmp    $0xeebff000,%esi
  802bed:	0f 84 91 00 00 00    	je     802c84 <spawn+0x528>
  802bf3:	89 f0                	mov    %esi,%eax
  802bf5:	c1 e8 16             	shr    $0x16,%eax
  802bf8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802bff:	a8 01                	test   $0x1,%al
  802c01:	74 6f                	je     802c72 <spawn+0x516>
  802c03:	89 f0                	mov    %esi,%eax
  802c05:	c1 e8 0c             	shr    $0xc,%eax
  802c08:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802c0f:	f6 c2 01             	test   $0x1,%dl
  802c12:	74 5e                	je     802c72 <spawn+0x516>
		{
			continue;
		}
		if ((uvpt[PGNUM(addr)] & PTE_SHARE))
  802c14:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802c1b:	f6 c6 04             	test   $0x4,%dh
  802c1e:	74 52                	je     802c72 <spawn+0x516>
		{
			if ((e = sys_page_map(0, (void *)addr, child, (void*)addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  802c20:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802c27:	25 07 0e 00 00       	and    $0xe07,%eax
  802c2c:	89 44 24 10          	mov    %eax,0x10(%esp)
  802c30:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802c34:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802c3a:	89 44 24 08          	mov    %eax,0x8(%esp)
  802c3e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c49:	e8 bb e9 ff ff       	call   801609 <sys_page_map>
  802c4e:	85 c0                	test   %eax,%eax
  802c50:	79 20                	jns    802c72 <spawn+0x516>
			{
				panic("duppage error: %e", e);
  802c52:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c56:	c7 44 24 08 de 40 80 	movl   $0x8040de,0x8(%esp)
  802c5d:	00 
  802c5e:	c7 44 24 04 3c 01 00 	movl   $0x13c,0x4(%esp)
  802c65:	00 
  802c66:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  802c6d:	e8 ce dd ff ff       	call   800a40 <_panic>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int e;
	for (uint32_t addr = 0; addr < UTOP ; addr+=PGSIZE)
  802c72:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802c78:	81 fe 00 00 c0 ee    	cmp    $0xeec00000,%esi
  802c7e:	0f 85 63 ff ff ff    	jne    802be7 <spawn+0x48b>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  802c84:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802c8b:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802c8e:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802c94:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c98:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802c9e:	89 04 24             	mov    %eax,(%esp)
  802ca1:	e8 5c ea ff ff       	call   801702 <sys_env_set_trapframe>
  802ca6:	85 c0                	test   %eax,%eax
  802ca8:	79 20                	jns    802cca <spawn+0x56e>
		panic("sys_env_set_trapframe: %e", r);
  802caa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802cae:	c7 44 24 08 21 42 80 	movl   $0x804221,0x8(%esp)
  802cb5:	00 
  802cb6:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  802cbd:	00 
  802cbe:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  802cc5:	e8 76 dd ff ff       	call   800a40 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802cca:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  802cd1:	00 
  802cd2:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802cd8:	89 04 24             	mov    %eax,(%esp)
  802cdb:	e8 cf e9 ff ff       	call   8016af <sys_env_set_status>
  802ce0:	85 c0                	test   %eax,%eax
  802ce2:	79 5a                	jns    802d3e <spawn+0x5e2>
		panic("sys_env_set_status: %e", r);
  802ce4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ce8:	c7 44 24 08 03 41 80 	movl   $0x804103,0x8(%esp)
  802cef:	00 
  802cf0:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  802cf7:	00 
  802cf8:	c7 04 24 f8 41 80 00 	movl   $0x8041f8,(%esp)
  802cff:	e8 3c dd ff ff       	call   800a40 <_panic>
  802d04:	89 c6                	mov    %eax,%esi
  802d06:	eb 06                	jmp    802d0e <spawn+0x5b2>
  802d08:	89 c6                	mov    %eax,%esi
  802d0a:	eb 02                	jmp    802d0e <spawn+0x5b2>
  802d0c:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  802d0e:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  802d14:	89 04 24             	mov    %eax,(%esp)
  802d17:	e8 09 e8 ff ff       	call   801525 <sys_env_destroy>
	close(fd);
  802d1c:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802d22:	89 04 24             	mov    %eax,(%esp)
  802d25:	e8 20 f2 ff ff       	call   801f4a <close>
	return r;
  802d2a:	89 b5 88 fd ff ff    	mov    %esi,-0x278(%ebp)
  802d30:	eb 0c                	jmp    802d3e <spawn+0x5e2>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  802d32:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  802d38:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802d3e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  802d44:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  802d4a:	5b                   	pop    %ebx
  802d4b:	5e                   	pop    %esi
  802d4c:	5f                   	pop    %edi
  802d4d:	5d                   	pop    %ebp
  802d4e:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  802d4f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  802d54:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  802d5a:	eb e2                	jmp    802d3e <spawn+0x5e2>

00802d5c <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802d5c:	55                   	push   %ebp
  802d5d:	89 e5                	mov    %esp,%ebp
  802d5f:	57                   	push   %edi
  802d60:	56                   	push   %esi
  802d61:	53                   	push   %ebx
  802d62:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  802d65:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802d68:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802d6d:	eb 03                	jmp    802d72 <spawnl+0x16>
		argc++;
  802d6f:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802d70:	89 d0                	mov    %edx,%eax
  802d72:	8d 50 04             	lea    0x4(%eax),%edx
  802d75:	83 38 00             	cmpl   $0x0,(%eax)
  802d78:	75 f5                	jne    802d6f <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802d7a:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  802d81:	83 e0 f0             	and    $0xfffffff0,%eax
  802d84:	29 c4                	sub    %eax,%esp
  802d86:	8d 7c 24 17          	lea    0x17(%esp),%edi
  802d8a:	83 e7 f0             	and    $0xfffffff0,%edi
  802d8d:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  802d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d92:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  802d94:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  802d9b:	00 

	va_start(vl, arg0);
  802d9c:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  802d9f:	b8 00 00 00 00       	mov    $0x0,%eax
  802da4:	eb 09                	jmp    802daf <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  802da6:	40                   	inc    %eax
  802da7:	8b 1a                	mov    (%edx),%ebx
  802da9:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  802dac:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802daf:	39 c8                	cmp    %ecx,%eax
  802db1:	75 f3                	jne    802da6 <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802db3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802db7:	8b 45 08             	mov    0x8(%ebp),%eax
  802dba:	89 04 24             	mov    %eax,(%esp)
  802dbd:	e8 9a f9 ff ff       	call   80275c <spawn>
}
  802dc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802dc5:	5b                   	pop    %ebx
  802dc6:	5e                   	pop    %esi
  802dc7:	5f                   	pop    %edi
  802dc8:	5d                   	pop    %ebp
  802dc9:	c3                   	ret    
	...

00802dcc <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802dcc:	55                   	push   %ebp
  802dcd:	89 e5                	mov    %esp,%ebp
  802dcf:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802dd2:	c7 44 24 04 64 42 80 	movl   $0x804264,0x4(%esp)
  802dd9:	00 
  802dda:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ddd:	89 04 24             	mov    %eax,(%esp)
  802de0:	e8 de e3 ff ff       	call   8011c3 <strcpy>
	return 0;
}
  802de5:	b8 00 00 00 00       	mov    $0x0,%eax
  802dea:	c9                   	leave  
  802deb:	c3                   	ret    

00802dec <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802dec:	55                   	push   %ebp
  802ded:	89 e5                	mov    %esp,%ebp
  802def:	53                   	push   %ebx
  802df0:	83 ec 14             	sub    $0x14,%esp
  802df3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  802df6:	89 1c 24             	mov    %ebx,(%esp)
  802df9:	e8 5a 0a 00 00       	call   803858 <pageref>
  802dfe:	83 f8 01             	cmp    $0x1,%eax
  802e01:	75 0d                	jne    802e10 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  802e03:	8b 43 0c             	mov    0xc(%ebx),%eax
  802e06:	89 04 24             	mov    %eax,(%esp)
  802e09:	e8 1f 03 00 00       	call   80312d <nsipc_close>
  802e0e:	eb 05                	jmp    802e15 <devsock_close+0x29>
	else
		return 0;
  802e10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802e15:	83 c4 14             	add    $0x14,%esp
  802e18:	5b                   	pop    %ebx
  802e19:	5d                   	pop    %ebp
  802e1a:	c3                   	ret    

00802e1b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802e1b:	55                   	push   %ebp
  802e1c:	89 e5                	mov    %esp,%ebp
  802e1e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802e21:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802e28:	00 
  802e29:	8b 45 10             	mov    0x10(%ebp),%eax
  802e2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802e30:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e33:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e37:	8b 45 08             	mov    0x8(%ebp),%eax
  802e3a:	8b 40 0c             	mov    0xc(%eax),%eax
  802e3d:	89 04 24             	mov    %eax,(%esp)
  802e40:	e8 e3 03 00 00       	call   803228 <nsipc_send>
}
  802e45:	c9                   	leave  
  802e46:	c3                   	ret    

00802e47 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802e47:	55                   	push   %ebp
  802e48:	89 e5                	mov    %esp,%ebp
  802e4a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802e4d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802e54:	00 
  802e55:	8b 45 10             	mov    0x10(%ebp),%eax
  802e58:	89 44 24 08          	mov    %eax,0x8(%esp)
  802e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e63:	8b 45 08             	mov    0x8(%ebp),%eax
  802e66:	8b 40 0c             	mov    0xc(%eax),%eax
  802e69:	89 04 24             	mov    %eax,(%esp)
  802e6c:	e8 37 03 00 00       	call   8031a8 <nsipc_recv>
}
  802e71:	c9                   	leave  
  802e72:	c3                   	ret    

00802e73 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802e73:	55                   	push   %ebp
  802e74:	89 e5                	mov    %esp,%ebp
  802e76:	56                   	push   %esi
  802e77:	53                   	push   %ebx
  802e78:	83 ec 20             	sub    $0x20,%esp
  802e7b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802e7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e80:	89 04 24             	mov    %eax,(%esp)
  802e83:	e8 37 ef ff ff       	call   801dbf <fd_alloc>
  802e88:	89 c3                	mov    %eax,%ebx
  802e8a:	85 c0                	test   %eax,%eax
  802e8c:	78 21                	js     802eaf <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802e8e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802e95:	00 
  802e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e99:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ea4:	e8 0c e7 ff ff       	call   8015b5 <sys_page_alloc>
  802ea9:	89 c3                	mov    %eax,%ebx
  802eab:	85 c0                	test   %eax,%eax
  802ead:	79 0a                	jns    802eb9 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  802eaf:	89 34 24             	mov    %esi,(%esp)
  802eb2:	e8 76 02 00 00       	call   80312d <nsipc_close>
		return r;
  802eb7:	eb 22                	jmp    802edb <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  802eb9:	8b 15 3c 50 80 00    	mov    0x80503c,%edx
  802ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ec2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ec7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802ece:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802ed1:	89 04 24             	mov    %eax,(%esp)
  802ed4:	e8 bb ee ff ff       	call   801d94 <fd2num>
  802ed9:	89 c3                	mov    %eax,%ebx
}
  802edb:	89 d8                	mov    %ebx,%eax
  802edd:	83 c4 20             	add    $0x20,%esp
  802ee0:	5b                   	pop    %ebx
  802ee1:	5e                   	pop    %esi
  802ee2:	5d                   	pop    %ebp
  802ee3:	c3                   	ret    

00802ee4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802ee4:	55                   	push   %ebp
  802ee5:	89 e5                	mov    %esp,%ebp
  802ee7:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802eea:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802eed:	89 54 24 04          	mov    %edx,0x4(%esp)
  802ef1:	89 04 24             	mov    %eax,(%esp)
  802ef4:	e8 19 ef ff ff       	call   801e12 <fd_lookup>
  802ef9:	85 c0                	test   %eax,%eax
  802efb:	78 17                	js     802f14 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f00:	8b 15 3c 50 80 00    	mov    0x80503c,%edx
  802f06:	39 10                	cmp    %edx,(%eax)
  802f08:	75 05                	jne    802f0f <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802f0a:	8b 40 0c             	mov    0xc(%eax),%eax
  802f0d:	eb 05                	jmp    802f14 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  802f0f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802f14:	c9                   	leave  
  802f15:	c3                   	ret    

00802f16 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802f16:	55                   	push   %ebp
  802f17:	89 e5                	mov    %esp,%ebp
  802f19:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802f1c:	8b 45 08             	mov    0x8(%ebp),%eax
  802f1f:	e8 c0 ff ff ff       	call   802ee4 <fd2sockid>
  802f24:	85 c0                	test   %eax,%eax
  802f26:	78 1f                	js     802f47 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802f28:	8b 55 10             	mov    0x10(%ebp),%edx
  802f2b:	89 54 24 08          	mov    %edx,0x8(%esp)
  802f2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802f32:	89 54 24 04          	mov    %edx,0x4(%esp)
  802f36:	89 04 24             	mov    %eax,(%esp)
  802f39:	e8 38 01 00 00       	call   803076 <nsipc_accept>
  802f3e:	85 c0                	test   %eax,%eax
  802f40:	78 05                	js     802f47 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  802f42:	e8 2c ff ff ff       	call   802e73 <alloc_sockfd>
}
  802f47:	c9                   	leave  
  802f48:	c3                   	ret    

00802f49 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802f49:	55                   	push   %ebp
  802f4a:	89 e5                	mov    %esp,%ebp
  802f4c:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  802f52:	e8 8d ff ff ff       	call   802ee4 <fd2sockid>
  802f57:	85 c0                	test   %eax,%eax
  802f59:	78 16                	js     802f71 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  802f5b:	8b 55 10             	mov    0x10(%ebp),%edx
  802f5e:	89 54 24 08          	mov    %edx,0x8(%esp)
  802f62:	8b 55 0c             	mov    0xc(%ebp),%edx
  802f65:	89 54 24 04          	mov    %edx,0x4(%esp)
  802f69:	89 04 24             	mov    %eax,(%esp)
  802f6c:	e8 5b 01 00 00       	call   8030cc <nsipc_bind>
}
  802f71:	c9                   	leave  
  802f72:	c3                   	ret    

00802f73 <shutdown>:

int
shutdown(int s, int how)
{
  802f73:	55                   	push   %ebp
  802f74:	89 e5                	mov    %esp,%ebp
  802f76:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802f79:	8b 45 08             	mov    0x8(%ebp),%eax
  802f7c:	e8 63 ff ff ff       	call   802ee4 <fd2sockid>
  802f81:	85 c0                	test   %eax,%eax
  802f83:	78 0f                	js     802f94 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802f85:	8b 55 0c             	mov    0xc(%ebp),%edx
  802f88:	89 54 24 04          	mov    %edx,0x4(%esp)
  802f8c:	89 04 24             	mov    %eax,(%esp)
  802f8f:	e8 77 01 00 00       	call   80310b <nsipc_shutdown>
}
  802f94:	c9                   	leave  
  802f95:	c3                   	ret    

00802f96 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802f96:	55                   	push   %ebp
  802f97:	89 e5                	mov    %esp,%ebp
  802f99:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802f9c:	8b 45 08             	mov    0x8(%ebp),%eax
  802f9f:	e8 40 ff ff ff       	call   802ee4 <fd2sockid>
  802fa4:	85 c0                	test   %eax,%eax
  802fa6:	78 16                	js     802fbe <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  802fa8:	8b 55 10             	mov    0x10(%ebp),%edx
  802fab:	89 54 24 08          	mov    %edx,0x8(%esp)
  802faf:	8b 55 0c             	mov    0xc(%ebp),%edx
  802fb2:	89 54 24 04          	mov    %edx,0x4(%esp)
  802fb6:	89 04 24             	mov    %eax,(%esp)
  802fb9:	e8 89 01 00 00       	call   803147 <nsipc_connect>
}
  802fbe:	c9                   	leave  
  802fbf:	c3                   	ret    

00802fc0 <listen>:

int
listen(int s, int backlog)
{
  802fc0:	55                   	push   %ebp
  802fc1:	89 e5                	mov    %esp,%ebp
  802fc3:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  802fc9:	e8 16 ff ff ff       	call   802ee4 <fd2sockid>
  802fce:	85 c0                	test   %eax,%eax
  802fd0:	78 0f                	js     802fe1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  802fd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  802fd5:	89 54 24 04          	mov    %edx,0x4(%esp)
  802fd9:	89 04 24             	mov    %eax,(%esp)
  802fdc:	e8 a5 01 00 00       	call   803186 <nsipc_listen>
}
  802fe1:	c9                   	leave  
  802fe2:	c3                   	ret    

00802fe3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  802fe3:	55                   	push   %ebp
  802fe4:	89 e5                	mov    %esp,%ebp
  802fe6:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802fe9:	8b 45 10             	mov    0x10(%ebp),%eax
  802fec:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ff0:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ff3:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ff7:	8b 45 08             	mov    0x8(%ebp),%eax
  802ffa:	89 04 24             	mov    %eax,(%esp)
  802ffd:	e8 99 02 00 00       	call   80329b <nsipc_socket>
  803002:	85 c0                	test   %eax,%eax
  803004:	78 05                	js     80300b <socket+0x28>
		return r;
	return alloc_sockfd(r);
  803006:	e8 68 fe ff ff       	call   802e73 <alloc_sockfd>
}
  80300b:	c9                   	leave  
  80300c:	c3                   	ret    
  80300d:	00 00                	add    %al,(%eax)
	...

00803010 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  803010:	55                   	push   %ebp
  803011:	89 e5                	mov    %esp,%ebp
  803013:	53                   	push   %ebx
  803014:	83 ec 14             	sub    $0x14,%esp
  803017:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  803019:	83 3d 24 64 80 00 00 	cmpl   $0x0,0x806424
  803020:	75 11                	jne    803033 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  803022:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  803029:	e8 e5 07 00 00       	call   803813 <ipc_find_env>
  80302e:	a3 24 64 80 00       	mov    %eax,0x806424
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  803033:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80303a:	00 
  80303b:	c7 44 24 08 00 80 80 	movl   $0x808000,0x8(%esp)
  803042:	00 
  803043:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803047:	a1 24 64 80 00       	mov    0x806424,%eax
  80304c:	89 04 24             	mov    %eax,(%esp)
  80304f:	e8 3c 07 00 00       	call   803790 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  803054:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80305b:	00 
  80305c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803063:	00 
  803064:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80306b:	e8 b0 06 00 00       	call   803720 <ipc_recv>
}
  803070:	83 c4 14             	add    $0x14,%esp
  803073:	5b                   	pop    %ebx
  803074:	5d                   	pop    %ebp
  803075:	c3                   	ret    

00803076 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  803076:	55                   	push   %ebp
  803077:	89 e5                	mov    %esp,%ebp
  803079:	56                   	push   %esi
  80307a:	53                   	push   %ebx
  80307b:	83 ec 10             	sub    $0x10,%esp
  80307e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  803081:	8b 45 08             	mov    0x8(%ebp),%eax
  803084:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.accept.req_addrlen = *addrlen;
  803089:	8b 06                	mov    (%esi),%eax
  80308b:	a3 04 80 80 00       	mov    %eax,0x808004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  803090:	b8 01 00 00 00       	mov    $0x1,%eax
  803095:	e8 76 ff ff ff       	call   803010 <nsipc>
  80309a:	89 c3                	mov    %eax,%ebx
  80309c:	85 c0                	test   %eax,%eax
  80309e:	78 23                	js     8030c3 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8030a0:	a1 10 80 80 00       	mov    0x808010,%eax
  8030a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8030a9:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  8030b0:	00 
  8030b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030b4:	89 04 24             	mov    %eax,(%esp)
  8030b7:	e8 80 e2 ff ff       	call   80133c <memmove>
		*addrlen = ret->ret_addrlen;
  8030bc:	a1 10 80 80 00       	mov    0x808010,%eax
  8030c1:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8030c3:	89 d8                	mov    %ebx,%eax
  8030c5:	83 c4 10             	add    $0x10,%esp
  8030c8:	5b                   	pop    %ebx
  8030c9:	5e                   	pop    %esi
  8030ca:	5d                   	pop    %ebp
  8030cb:	c3                   	ret    

008030cc <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8030cc:	55                   	push   %ebp
  8030cd:	89 e5                	mov    %esp,%ebp
  8030cf:	53                   	push   %ebx
  8030d0:	83 ec 14             	sub    $0x14,%esp
  8030d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8030d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8030d9:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8030de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8030e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030e9:	c7 04 24 04 80 80 00 	movl   $0x808004,(%esp)
  8030f0:	e8 47 e2 ff ff       	call   80133c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8030f5:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  8030fb:	b8 02 00 00 00       	mov    $0x2,%eax
  803100:	e8 0b ff ff ff       	call   803010 <nsipc>
}
  803105:	83 c4 14             	add    $0x14,%esp
  803108:	5b                   	pop    %ebx
  803109:	5d                   	pop    %ebp
  80310a:	c3                   	ret    

0080310b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80310b:	55                   	push   %ebp
  80310c:	89 e5                	mov    %esp,%ebp
  80310e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  803111:	8b 45 08             	mov    0x8(%ebp),%eax
  803114:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  803119:	8b 45 0c             	mov    0xc(%ebp),%eax
  80311c:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  803121:	b8 03 00 00 00       	mov    $0x3,%eax
  803126:	e8 e5 fe ff ff       	call   803010 <nsipc>
}
  80312b:	c9                   	leave  
  80312c:	c3                   	ret    

0080312d <nsipc_close>:

int
nsipc_close(int s)
{
  80312d:	55                   	push   %ebp
  80312e:	89 e5                	mov    %esp,%ebp
  803130:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  803133:	8b 45 08             	mov    0x8(%ebp),%eax
  803136:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  80313b:	b8 04 00 00 00       	mov    $0x4,%eax
  803140:	e8 cb fe ff ff       	call   803010 <nsipc>
}
  803145:	c9                   	leave  
  803146:	c3                   	ret    

00803147 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803147:	55                   	push   %ebp
  803148:	89 e5                	mov    %esp,%ebp
  80314a:	53                   	push   %ebx
  80314b:	83 ec 14             	sub    $0x14,%esp
  80314e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  803151:	8b 45 08             	mov    0x8(%ebp),%eax
  803154:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  803159:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80315d:	8b 45 0c             	mov    0xc(%ebp),%eax
  803160:	89 44 24 04          	mov    %eax,0x4(%esp)
  803164:	c7 04 24 04 80 80 00 	movl   $0x808004,(%esp)
  80316b:	e8 cc e1 ff ff       	call   80133c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  803170:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  803176:	b8 05 00 00 00       	mov    $0x5,%eax
  80317b:	e8 90 fe ff ff       	call   803010 <nsipc>
}
  803180:	83 c4 14             	add    $0x14,%esp
  803183:	5b                   	pop    %ebx
  803184:	5d                   	pop    %ebp
  803185:	c3                   	ret    

00803186 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  803186:	55                   	push   %ebp
  803187:	89 e5                	mov    %esp,%ebp
  803189:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80318c:	8b 45 08             	mov    0x8(%ebp),%eax
  80318f:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  803194:	8b 45 0c             	mov    0xc(%ebp),%eax
  803197:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  80319c:	b8 06 00 00 00       	mov    $0x6,%eax
  8031a1:	e8 6a fe ff ff       	call   803010 <nsipc>
}
  8031a6:	c9                   	leave  
  8031a7:	c3                   	ret    

008031a8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8031a8:	55                   	push   %ebp
  8031a9:	89 e5                	mov    %esp,%ebp
  8031ab:	56                   	push   %esi
  8031ac:	53                   	push   %ebx
  8031ad:	83 ec 10             	sub    $0x10,%esp
  8031b0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8031b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8031b6:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  8031bb:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  8031c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8031c4:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8031c9:	b8 07 00 00 00       	mov    $0x7,%eax
  8031ce:	e8 3d fe ff ff       	call   803010 <nsipc>
  8031d3:	89 c3                	mov    %eax,%ebx
  8031d5:	85 c0                	test   %eax,%eax
  8031d7:	78 46                	js     80321f <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8031d9:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8031de:	7f 04                	jg     8031e4 <nsipc_recv+0x3c>
  8031e0:	39 c6                	cmp    %eax,%esi
  8031e2:	7d 24                	jge    803208 <nsipc_recv+0x60>
  8031e4:	c7 44 24 0c 70 42 80 	movl   $0x804270,0xc(%esp)
  8031eb:	00 
  8031ec:	c7 44 24 08 49 3c 80 	movl   $0x803c49,0x8(%esp)
  8031f3:	00 
  8031f4:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8031fb:	00 
  8031fc:	c7 04 24 85 42 80 00 	movl   $0x804285,(%esp)
  803203:	e8 38 d8 ff ff       	call   800a40 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  803208:	89 44 24 08          	mov    %eax,0x8(%esp)
  80320c:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  803213:	00 
  803214:	8b 45 0c             	mov    0xc(%ebp),%eax
  803217:	89 04 24             	mov    %eax,(%esp)
  80321a:	e8 1d e1 ff ff       	call   80133c <memmove>
	}

	return r;
}
  80321f:	89 d8                	mov    %ebx,%eax
  803221:	83 c4 10             	add    $0x10,%esp
  803224:	5b                   	pop    %ebx
  803225:	5e                   	pop    %esi
  803226:	5d                   	pop    %ebp
  803227:	c3                   	ret    

00803228 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  803228:	55                   	push   %ebp
  803229:	89 e5                	mov    %esp,%ebp
  80322b:	53                   	push   %ebx
  80322c:	83 ec 14             	sub    $0x14,%esp
  80322f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  803232:	8b 45 08             	mov    0x8(%ebp),%eax
  803235:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  80323a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  803240:	7e 24                	jle    803266 <nsipc_send+0x3e>
  803242:	c7 44 24 0c 91 42 80 	movl   $0x804291,0xc(%esp)
  803249:	00 
  80324a:	c7 44 24 08 49 3c 80 	movl   $0x803c49,0x8(%esp)
  803251:	00 
  803252:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  803259:	00 
  80325a:	c7 04 24 85 42 80 00 	movl   $0x804285,(%esp)
  803261:	e8 da d7 ff ff       	call   800a40 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  803266:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80326a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80326d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803271:	c7 04 24 0c 80 80 00 	movl   $0x80800c,(%esp)
  803278:	e8 bf e0 ff ff       	call   80133c <memmove>
	nsipcbuf.send.req_size = size;
  80327d:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  803283:	8b 45 14             	mov    0x14(%ebp),%eax
  803286:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  80328b:	b8 08 00 00 00       	mov    $0x8,%eax
  803290:	e8 7b fd ff ff       	call   803010 <nsipc>
}
  803295:	83 c4 14             	add    $0x14,%esp
  803298:	5b                   	pop    %ebx
  803299:	5d                   	pop    %ebp
  80329a:	c3                   	ret    

0080329b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80329b:	55                   	push   %ebp
  80329c:	89 e5                	mov    %esp,%ebp
  80329e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8032a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8032a4:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  8032a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032ac:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  8032b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8032b4:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  8032b9:	b8 09 00 00 00       	mov    $0x9,%eax
  8032be:	e8 4d fd ff ff       	call   803010 <nsipc>
}
  8032c3:	c9                   	leave  
  8032c4:	c3                   	ret    
  8032c5:	00 00                	add    %al,(%eax)
	...

008032c8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8032c8:	55                   	push   %ebp
  8032c9:	89 e5                	mov    %esp,%ebp
  8032cb:	56                   	push   %esi
  8032cc:	53                   	push   %ebx
  8032cd:	83 ec 10             	sub    $0x10,%esp
  8032d0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8032d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8032d6:	89 04 24             	mov    %eax,(%esp)
  8032d9:	e8 c6 ea ff ff       	call   801da4 <fd2data>
  8032de:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8032e0:	c7 44 24 04 9d 42 80 	movl   $0x80429d,0x4(%esp)
  8032e7:	00 
  8032e8:	89 34 24             	mov    %esi,(%esp)
  8032eb:	e8 d3 de ff ff       	call   8011c3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8032f0:	8b 43 04             	mov    0x4(%ebx),%eax
  8032f3:	2b 03                	sub    (%ebx),%eax
  8032f5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8032fb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  803302:	00 00 00 
	stat->st_dev = &devpipe;
  803305:	c7 86 88 00 00 00 58 	movl   $0x805058,0x88(%esi)
  80330c:	50 80 00 
	return 0;
}
  80330f:	b8 00 00 00 00       	mov    $0x0,%eax
  803314:	83 c4 10             	add    $0x10,%esp
  803317:	5b                   	pop    %ebx
  803318:	5e                   	pop    %esi
  803319:	5d                   	pop    %ebp
  80331a:	c3                   	ret    

0080331b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80331b:	55                   	push   %ebp
  80331c:	89 e5                	mov    %esp,%ebp
  80331e:	53                   	push   %ebx
  80331f:	83 ec 14             	sub    $0x14,%esp
  803322:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803325:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803329:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803330:	e8 27 e3 ff ff       	call   80165c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803335:	89 1c 24             	mov    %ebx,(%esp)
  803338:	e8 67 ea ff ff       	call   801da4 <fd2data>
  80333d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803341:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803348:	e8 0f e3 ff ff       	call   80165c <sys_page_unmap>
}
  80334d:	83 c4 14             	add    $0x14,%esp
  803350:	5b                   	pop    %ebx
  803351:	5d                   	pop    %ebp
  803352:	c3                   	ret    

00803353 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803353:	55                   	push   %ebp
  803354:	89 e5                	mov    %esp,%ebp
  803356:	57                   	push   %edi
  803357:	56                   	push   %esi
  803358:	53                   	push   %ebx
  803359:	83 ec 2c             	sub    $0x2c,%esp
  80335c:	89 c7                	mov    %eax,%edi
  80335e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803361:	a1 28 64 80 00       	mov    0x806428,%eax
  803366:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  803369:	89 3c 24             	mov    %edi,(%esp)
  80336c:	e8 e7 04 00 00       	call   803858 <pageref>
  803371:	89 c6                	mov    %eax,%esi
  803373:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803376:	89 04 24             	mov    %eax,(%esp)
  803379:	e8 da 04 00 00       	call   803858 <pageref>
  80337e:	39 c6                	cmp    %eax,%esi
  803380:	0f 94 c0             	sete   %al
  803383:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  803386:	8b 15 28 64 80 00    	mov    0x806428,%edx
  80338c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80338f:	39 cb                	cmp    %ecx,%ebx
  803391:	75 08                	jne    80339b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  803393:	83 c4 2c             	add    $0x2c,%esp
  803396:	5b                   	pop    %ebx
  803397:	5e                   	pop    %esi
  803398:	5f                   	pop    %edi
  803399:	5d                   	pop    %ebp
  80339a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80339b:	83 f8 01             	cmp    $0x1,%eax
  80339e:	75 c1                	jne    803361 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8033a0:	8b 42 58             	mov    0x58(%edx),%eax
  8033a3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8033aa:	00 
  8033ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8033af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8033b3:	c7 04 24 a4 42 80 00 	movl   $0x8042a4,(%esp)
  8033ba:	e8 79 d7 ff ff       	call   800b38 <cprintf>
  8033bf:	eb a0                	jmp    803361 <_pipeisclosed+0xe>

008033c1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8033c1:	55                   	push   %ebp
  8033c2:	89 e5                	mov    %esp,%ebp
  8033c4:	57                   	push   %edi
  8033c5:	56                   	push   %esi
  8033c6:	53                   	push   %ebx
  8033c7:	83 ec 1c             	sub    $0x1c,%esp
  8033ca:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8033cd:	89 34 24             	mov    %esi,(%esp)
  8033d0:	e8 cf e9 ff ff       	call   801da4 <fd2data>
  8033d5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8033d7:	bf 00 00 00 00       	mov    $0x0,%edi
  8033dc:	eb 3c                	jmp    80341a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8033de:	89 da                	mov    %ebx,%edx
  8033e0:	89 f0                	mov    %esi,%eax
  8033e2:	e8 6c ff ff ff       	call   803353 <_pipeisclosed>
  8033e7:	85 c0                	test   %eax,%eax
  8033e9:	75 38                	jne    803423 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8033eb:	e8 a6 e1 ff ff       	call   801596 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8033f0:	8b 43 04             	mov    0x4(%ebx),%eax
  8033f3:	8b 13                	mov    (%ebx),%edx
  8033f5:	83 c2 20             	add    $0x20,%edx
  8033f8:	39 d0                	cmp    %edx,%eax
  8033fa:	73 e2                	jae    8033de <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8033fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8033ff:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  803402:	89 c2                	mov    %eax,%edx
  803404:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80340a:	79 05                	jns    803411 <devpipe_write+0x50>
  80340c:	4a                   	dec    %edx
  80340d:	83 ca e0             	or     $0xffffffe0,%edx
  803410:	42                   	inc    %edx
  803411:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803415:	40                   	inc    %eax
  803416:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803419:	47                   	inc    %edi
  80341a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80341d:	75 d1                	jne    8033f0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80341f:	89 f8                	mov    %edi,%eax
  803421:	eb 05                	jmp    803428 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803423:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803428:	83 c4 1c             	add    $0x1c,%esp
  80342b:	5b                   	pop    %ebx
  80342c:	5e                   	pop    %esi
  80342d:	5f                   	pop    %edi
  80342e:	5d                   	pop    %ebp
  80342f:	c3                   	ret    

00803430 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803430:	55                   	push   %ebp
  803431:	89 e5                	mov    %esp,%ebp
  803433:	57                   	push   %edi
  803434:	56                   	push   %esi
  803435:	53                   	push   %ebx
  803436:	83 ec 1c             	sub    $0x1c,%esp
  803439:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80343c:	89 3c 24             	mov    %edi,(%esp)
  80343f:	e8 60 e9 ff ff       	call   801da4 <fd2data>
  803444:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803446:	be 00 00 00 00       	mov    $0x0,%esi
  80344b:	eb 3a                	jmp    803487 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80344d:	85 f6                	test   %esi,%esi
  80344f:	74 04                	je     803455 <devpipe_read+0x25>
				return i;
  803451:	89 f0                	mov    %esi,%eax
  803453:	eb 40                	jmp    803495 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  803455:	89 da                	mov    %ebx,%edx
  803457:	89 f8                	mov    %edi,%eax
  803459:	e8 f5 fe ff ff       	call   803353 <_pipeisclosed>
  80345e:	85 c0                	test   %eax,%eax
  803460:	75 2e                	jne    803490 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803462:	e8 2f e1 ff ff       	call   801596 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  803467:	8b 03                	mov    (%ebx),%eax
  803469:	3b 43 04             	cmp    0x4(%ebx),%eax
  80346c:	74 df                	je     80344d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80346e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  803473:	79 05                	jns    80347a <devpipe_read+0x4a>
  803475:	48                   	dec    %eax
  803476:	83 c8 e0             	or     $0xffffffe0,%eax
  803479:	40                   	inc    %eax
  80347a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80347e:	8b 55 0c             	mov    0xc(%ebp),%edx
  803481:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  803484:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803486:	46                   	inc    %esi
  803487:	3b 75 10             	cmp    0x10(%ebp),%esi
  80348a:	75 db                	jne    803467 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80348c:	89 f0                	mov    %esi,%eax
  80348e:	eb 05                	jmp    803495 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803490:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803495:	83 c4 1c             	add    $0x1c,%esp
  803498:	5b                   	pop    %ebx
  803499:	5e                   	pop    %esi
  80349a:	5f                   	pop    %edi
  80349b:	5d                   	pop    %ebp
  80349c:	c3                   	ret    

0080349d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80349d:	55                   	push   %ebp
  80349e:	89 e5                	mov    %esp,%ebp
  8034a0:	57                   	push   %edi
  8034a1:	56                   	push   %esi
  8034a2:	53                   	push   %ebx
  8034a3:	83 ec 3c             	sub    $0x3c,%esp
  8034a6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8034a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8034ac:	89 04 24             	mov    %eax,(%esp)
  8034af:	e8 0b e9 ff ff       	call   801dbf <fd_alloc>
  8034b4:	89 c3                	mov    %eax,%ebx
  8034b6:	85 c0                	test   %eax,%eax
  8034b8:	0f 88 45 01 00 00    	js     803603 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8034be:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8034c5:	00 
  8034c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8034c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8034cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8034d4:	e8 dc e0 ff ff       	call   8015b5 <sys_page_alloc>
  8034d9:	89 c3                	mov    %eax,%ebx
  8034db:	85 c0                	test   %eax,%eax
  8034dd:	0f 88 20 01 00 00    	js     803603 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8034e3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8034e6:	89 04 24             	mov    %eax,(%esp)
  8034e9:	e8 d1 e8 ff ff       	call   801dbf <fd_alloc>
  8034ee:	89 c3                	mov    %eax,%ebx
  8034f0:	85 c0                	test   %eax,%eax
  8034f2:	0f 88 f8 00 00 00    	js     8035f0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8034f8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8034ff:	00 
  803500:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803503:	89 44 24 04          	mov    %eax,0x4(%esp)
  803507:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80350e:	e8 a2 e0 ff ff       	call   8015b5 <sys_page_alloc>
  803513:	89 c3                	mov    %eax,%ebx
  803515:	85 c0                	test   %eax,%eax
  803517:	0f 88 d3 00 00 00    	js     8035f0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80351d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803520:	89 04 24             	mov    %eax,(%esp)
  803523:	e8 7c e8 ff ff       	call   801da4 <fd2data>
  803528:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80352a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803531:	00 
  803532:	89 44 24 04          	mov    %eax,0x4(%esp)
  803536:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80353d:	e8 73 e0 ff ff       	call   8015b5 <sys_page_alloc>
  803542:	89 c3                	mov    %eax,%ebx
  803544:	85 c0                	test   %eax,%eax
  803546:	0f 88 91 00 00 00    	js     8035dd <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80354c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80354f:	89 04 24             	mov    %eax,(%esp)
  803552:	e8 4d e8 ff ff       	call   801da4 <fd2data>
  803557:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80355e:	00 
  80355f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803563:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80356a:	00 
  80356b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80356f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803576:	e8 8e e0 ff ff       	call   801609 <sys_page_map>
  80357b:	89 c3                	mov    %eax,%ebx
  80357d:	85 c0                	test   %eax,%eax
  80357f:	78 4c                	js     8035cd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803581:	8b 15 58 50 80 00    	mov    0x805058,%edx
  803587:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80358a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80358c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80358f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803596:	8b 15 58 50 80 00    	mov    0x805058,%edx
  80359c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80359f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8035a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8035a4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8035ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8035ae:	89 04 24             	mov    %eax,(%esp)
  8035b1:	e8 de e7 ff ff       	call   801d94 <fd2num>
  8035b6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8035b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8035bb:	89 04 24             	mov    %eax,(%esp)
  8035be:	e8 d1 e7 ff ff       	call   801d94 <fd2num>
  8035c3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8035c6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8035cb:	eb 36                	jmp    803603 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8035cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8035d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035d8:	e8 7f e0 ff ff       	call   80165c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8035dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8035e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035eb:	e8 6c e0 ff ff       	call   80165c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8035f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8035f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035fe:	e8 59 e0 ff ff       	call   80165c <sys_page_unmap>
    err:
	return r;
}
  803603:	89 d8                	mov    %ebx,%eax
  803605:	83 c4 3c             	add    $0x3c,%esp
  803608:	5b                   	pop    %ebx
  803609:	5e                   	pop    %esi
  80360a:	5f                   	pop    %edi
  80360b:	5d                   	pop    %ebp
  80360c:	c3                   	ret    

0080360d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80360d:	55                   	push   %ebp
  80360e:	89 e5                	mov    %esp,%ebp
  803610:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803613:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803616:	89 44 24 04          	mov    %eax,0x4(%esp)
  80361a:	8b 45 08             	mov    0x8(%ebp),%eax
  80361d:	89 04 24             	mov    %eax,(%esp)
  803620:	e8 ed e7 ff ff       	call   801e12 <fd_lookup>
  803625:	85 c0                	test   %eax,%eax
  803627:	78 15                	js     80363e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803629:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80362c:	89 04 24             	mov    %eax,(%esp)
  80362f:	e8 70 e7 ff ff       	call   801da4 <fd2data>
	return _pipeisclosed(fd, p);
  803634:	89 c2                	mov    %eax,%edx
  803636:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803639:	e8 15 fd ff ff       	call   803353 <_pipeisclosed>
}
  80363e:	c9                   	leave  
  80363f:	c3                   	ret    

00803640 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  803640:	55                   	push   %ebp
  803641:	89 e5                	mov    %esp,%ebp
  803643:	56                   	push   %esi
  803644:	53                   	push   %ebx
  803645:	83 ec 10             	sub    $0x10,%esp
  803648:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80364b:	85 f6                	test   %esi,%esi
  80364d:	75 24                	jne    803673 <wait+0x33>
  80364f:	c7 44 24 0c bc 42 80 	movl   $0x8042bc,0xc(%esp)
  803656:	00 
  803657:	c7 44 24 08 49 3c 80 	movl   $0x803c49,0x8(%esp)
  80365e:	00 
  80365f:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  803666:	00 
  803667:	c7 04 24 c7 42 80 00 	movl   $0x8042c7,(%esp)
  80366e:	e8 cd d3 ff ff       	call   800a40 <_panic>
	e = &envs[ENVX(envid)];
  803673:	89 f3                	mov    %esi,%ebx
  803675:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80367b:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  803682:	c1 e3 07             	shl    $0x7,%ebx
  803685:	29 c3                	sub    %eax,%ebx
  803687:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80368d:	eb 05                	jmp    803694 <wait+0x54>
		sys_yield();
  80368f:	e8 02 df ff ff       	call   801596 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803694:	8b 43 48             	mov    0x48(%ebx),%eax
  803697:	39 f0                	cmp    %esi,%eax
  803699:	75 07                	jne    8036a2 <wait+0x62>
  80369b:	8b 43 54             	mov    0x54(%ebx),%eax
  80369e:	85 c0                	test   %eax,%eax
  8036a0:	75 ed                	jne    80368f <wait+0x4f>
		sys_yield();
}
  8036a2:	83 c4 10             	add    $0x10,%esp
  8036a5:	5b                   	pop    %ebx
  8036a6:	5e                   	pop    %esi
  8036a7:	5d                   	pop    %ebp
  8036a8:	c3                   	ret    
  8036a9:	00 00                	add    %al,(%eax)
	...

008036ac <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8036ac:	55                   	push   %ebp
  8036ad:	89 e5                	mov    %esp,%ebp
  8036af:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8036b2:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  8036b9:	75 30                	jne    8036eb <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  8036bb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8036c2:	00 
  8036c3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8036ca:	ee 
  8036cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8036d2:	e8 de de ff ff       	call   8015b5 <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8036d7:	c7 44 24 04 f8 36 80 	movl   $0x8036f8,0x4(%esp)
  8036de:	00 
  8036df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8036e6:	e8 6a e0 ff ff       	call   801755 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8036eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8036ee:	a3 00 90 80 00       	mov    %eax,0x809000
}
  8036f3:	c9                   	leave  
  8036f4:	c3                   	ret    
  8036f5:	00 00                	add    %al,(%eax)
	...

008036f8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8036f8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8036f9:	a1 00 90 80 00       	mov    0x809000,%eax
	call *%eax
  8036fe:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  803700:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  803703:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  803707:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  80370b:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  80370e:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  803710:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  803714:	83 c4 08             	add    $0x8,%esp
	popal
  803717:	61                   	popa   

	addl $4,%esp 
  803718:	83 c4 04             	add    $0x4,%esp
	popfl
  80371b:	9d                   	popf   

	popl %esp
  80371c:	5c                   	pop    %esp

	ret
  80371d:	c3                   	ret    
	...

00803720 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  803720:	55                   	push   %ebp
  803721:	89 e5                	mov    %esp,%ebp
  803723:	56                   	push   %esi
  803724:	53                   	push   %ebx
  803725:	83 ec 10             	sub    $0x10,%esp
  803728:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80372b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80372e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  803731:	85 c0                	test   %eax,%eax
  803733:	74 0a                	je     80373f <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  803735:	89 04 24             	mov    %eax,(%esp)
  803738:	e8 8e e0 ff ff       	call   8017cb <sys_ipc_recv>
  80373d:	eb 0c                	jmp    80374b <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80373f:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  803746:	e8 80 e0 ff ff       	call   8017cb <sys_ipc_recv>
	}
	if (r < 0)
  80374b:	85 c0                	test   %eax,%eax
  80374d:	79 16                	jns    803765 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  80374f:	85 db                	test   %ebx,%ebx
  803751:	74 06                	je     803759 <ipc_recv+0x39>
  803753:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  803759:	85 f6                	test   %esi,%esi
  80375b:	74 2c                	je     803789 <ipc_recv+0x69>
  80375d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  803763:	eb 24                	jmp    803789 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  803765:	85 db                	test   %ebx,%ebx
  803767:	74 0a                	je     803773 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  803769:	a1 28 64 80 00       	mov    0x806428,%eax
  80376e:	8b 40 74             	mov    0x74(%eax),%eax
  803771:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  803773:	85 f6                	test   %esi,%esi
  803775:	74 0a                	je     803781 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  803777:	a1 28 64 80 00       	mov    0x806428,%eax
  80377c:	8b 40 78             	mov    0x78(%eax),%eax
  80377f:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  803781:	a1 28 64 80 00       	mov    0x806428,%eax
  803786:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  803789:	83 c4 10             	add    $0x10,%esp
  80378c:	5b                   	pop    %ebx
  80378d:	5e                   	pop    %esi
  80378e:	5d                   	pop    %ebp
  80378f:	c3                   	ret    

00803790 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  803790:	55                   	push   %ebp
  803791:	89 e5                	mov    %esp,%ebp
  803793:	57                   	push   %edi
  803794:	56                   	push   %esi
  803795:	53                   	push   %ebx
  803796:	83 ec 1c             	sub    $0x1c,%esp
  803799:	8b 75 08             	mov    0x8(%ebp),%esi
  80379c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80379f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8037a2:	85 db                	test   %ebx,%ebx
  8037a4:	74 19                	je     8037bf <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8037a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8037a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8037ad:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8037b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8037b5:	89 34 24             	mov    %esi,(%esp)
  8037b8:	e8 eb df ff ff       	call   8017a8 <sys_ipc_try_send>
  8037bd:	eb 1c                	jmp    8037db <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  8037bf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8037c6:	00 
  8037c7:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8037ce:	ee 
  8037cf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8037d3:	89 34 24             	mov    %esi,(%esp)
  8037d6:	e8 cd df ff ff       	call   8017a8 <sys_ipc_try_send>
		}
		if (r == 0)
  8037db:	85 c0                	test   %eax,%eax
  8037dd:	74 2c                	je     80380b <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  8037df:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8037e2:	74 20                	je     803804 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  8037e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8037e8:	c7 44 24 08 d2 42 80 	movl   $0x8042d2,0x8(%esp)
  8037ef:	00 
  8037f0:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8037f7:	00 
  8037f8:	c7 04 24 e5 42 80 00 	movl   $0x8042e5,(%esp)
  8037ff:	e8 3c d2 ff ff       	call   800a40 <_panic>
		}
		sys_yield();
  803804:	e8 8d dd ff ff       	call   801596 <sys_yield>
	}
  803809:	eb 97                	jmp    8037a2 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  80380b:	83 c4 1c             	add    $0x1c,%esp
  80380e:	5b                   	pop    %ebx
  80380f:	5e                   	pop    %esi
  803810:	5f                   	pop    %edi
  803811:	5d                   	pop    %ebp
  803812:	c3                   	ret    

00803813 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  803813:	55                   	push   %ebp
  803814:	89 e5                	mov    %esp,%ebp
  803816:	53                   	push   %ebx
  803817:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80381a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80381f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  803826:	89 c2                	mov    %eax,%edx
  803828:	c1 e2 07             	shl    $0x7,%edx
  80382b:	29 ca                	sub    %ecx,%edx
  80382d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  803833:	8b 52 50             	mov    0x50(%edx),%edx
  803836:	39 da                	cmp    %ebx,%edx
  803838:	75 0f                	jne    803849 <ipc_find_env+0x36>
			return envs[i].env_id;
  80383a:	c1 e0 07             	shl    $0x7,%eax
  80383d:	29 c8                	sub    %ecx,%eax
  80383f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  803844:	8b 40 40             	mov    0x40(%eax),%eax
  803847:	eb 0c                	jmp    803855 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  803849:	40                   	inc    %eax
  80384a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80384f:	75 ce                	jne    80381f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  803851:	66 b8 00 00          	mov    $0x0,%ax
}
  803855:	5b                   	pop    %ebx
  803856:	5d                   	pop    %ebp
  803857:	c3                   	ret    

00803858 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803858:	55                   	push   %ebp
  803859:	89 e5                	mov    %esp,%ebp
  80385b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80385e:	89 c2                	mov    %eax,%edx
  803860:	c1 ea 16             	shr    $0x16,%edx
  803863:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80386a:	f6 c2 01             	test   $0x1,%dl
  80386d:	74 1e                	je     80388d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80386f:	c1 e8 0c             	shr    $0xc,%eax
  803872:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  803879:	a8 01                	test   $0x1,%al
  80387b:	74 17                	je     803894 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80387d:	c1 e8 0c             	shr    $0xc,%eax
  803880:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  803887:	ef 
  803888:	0f b7 c0             	movzwl %ax,%eax
  80388b:	eb 0c                	jmp    803899 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80388d:	b8 00 00 00 00       	mov    $0x0,%eax
  803892:	eb 05                	jmp    803899 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  803894:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  803899:	5d                   	pop    %ebp
  80389a:	c3                   	ret    
	...

0080389c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80389c:	55                   	push   %ebp
  80389d:	57                   	push   %edi
  80389e:	56                   	push   %esi
  80389f:	83 ec 10             	sub    $0x10,%esp
  8038a2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8038a6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8038aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8038ae:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8038b2:	89 cd                	mov    %ecx,%ebp
  8038b4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8038b8:	85 c0                	test   %eax,%eax
  8038ba:	75 2c                	jne    8038e8 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8038bc:	39 f9                	cmp    %edi,%ecx
  8038be:	77 68                	ja     803928 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8038c0:	85 c9                	test   %ecx,%ecx
  8038c2:	75 0b                	jne    8038cf <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8038c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8038c9:	31 d2                	xor    %edx,%edx
  8038cb:	f7 f1                	div    %ecx
  8038cd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8038cf:	31 d2                	xor    %edx,%edx
  8038d1:	89 f8                	mov    %edi,%eax
  8038d3:	f7 f1                	div    %ecx
  8038d5:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8038d7:	89 f0                	mov    %esi,%eax
  8038d9:	f7 f1                	div    %ecx
  8038db:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8038dd:	89 f0                	mov    %esi,%eax
  8038df:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8038e1:	83 c4 10             	add    $0x10,%esp
  8038e4:	5e                   	pop    %esi
  8038e5:	5f                   	pop    %edi
  8038e6:	5d                   	pop    %ebp
  8038e7:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8038e8:	39 f8                	cmp    %edi,%eax
  8038ea:	77 2c                	ja     803918 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8038ec:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8038ef:	83 f6 1f             	xor    $0x1f,%esi
  8038f2:	75 4c                	jne    803940 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8038f4:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8038f6:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8038fb:	72 0a                	jb     803907 <__udivdi3+0x6b>
  8038fd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  803901:	0f 87 ad 00 00 00    	ja     8039b4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  803907:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80390c:	89 f0                	mov    %esi,%eax
  80390e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803910:	83 c4 10             	add    $0x10,%esp
  803913:	5e                   	pop    %esi
  803914:	5f                   	pop    %edi
  803915:	5d                   	pop    %ebp
  803916:	c3                   	ret    
  803917:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803918:	31 ff                	xor    %edi,%edi
  80391a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80391c:	89 f0                	mov    %esi,%eax
  80391e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803920:	83 c4 10             	add    $0x10,%esp
  803923:	5e                   	pop    %esi
  803924:	5f                   	pop    %edi
  803925:	5d                   	pop    %ebp
  803926:	c3                   	ret    
  803927:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803928:	89 fa                	mov    %edi,%edx
  80392a:	89 f0                	mov    %esi,%eax
  80392c:	f7 f1                	div    %ecx
  80392e:	89 c6                	mov    %eax,%esi
  803930:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803932:	89 f0                	mov    %esi,%eax
  803934:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803936:	83 c4 10             	add    $0x10,%esp
  803939:	5e                   	pop    %esi
  80393a:	5f                   	pop    %edi
  80393b:	5d                   	pop    %ebp
  80393c:	c3                   	ret    
  80393d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803940:	89 f1                	mov    %esi,%ecx
  803942:	d3 e0                	shl    %cl,%eax
  803944:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  803948:	b8 20 00 00 00       	mov    $0x20,%eax
  80394d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80394f:	89 ea                	mov    %ebp,%edx
  803951:	88 c1                	mov    %al,%cl
  803953:	d3 ea                	shr    %cl,%edx
  803955:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  803959:	09 ca                	or     %ecx,%edx
  80395b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80395f:	89 f1                	mov    %esi,%ecx
  803961:	d3 e5                	shl    %cl,%ebp
  803963:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  803967:	89 fd                	mov    %edi,%ebp
  803969:	88 c1                	mov    %al,%cl
  80396b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80396d:	89 fa                	mov    %edi,%edx
  80396f:	89 f1                	mov    %esi,%ecx
  803971:	d3 e2                	shl    %cl,%edx
  803973:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803977:	88 c1                	mov    %al,%cl
  803979:	d3 ef                	shr    %cl,%edi
  80397b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80397d:	89 f8                	mov    %edi,%eax
  80397f:	89 ea                	mov    %ebp,%edx
  803981:	f7 74 24 08          	divl   0x8(%esp)
  803985:	89 d1                	mov    %edx,%ecx
  803987:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  803989:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80398d:	39 d1                	cmp    %edx,%ecx
  80398f:	72 17                	jb     8039a8 <__udivdi3+0x10c>
  803991:	74 09                	je     80399c <__udivdi3+0x100>
  803993:	89 fe                	mov    %edi,%esi
  803995:	31 ff                	xor    %edi,%edi
  803997:	e9 41 ff ff ff       	jmp    8038dd <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80399c:	8b 54 24 04          	mov    0x4(%esp),%edx
  8039a0:	89 f1                	mov    %esi,%ecx
  8039a2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8039a4:	39 c2                	cmp    %eax,%edx
  8039a6:	73 eb                	jae    803993 <__udivdi3+0xf7>
		{
		  q0--;
  8039a8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8039ab:	31 ff                	xor    %edi,%edi
  8039ad:	e9 2b ff ff ff       	jmp    8038dd <__udivdi3+0x41>
  8039b2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8039b4:	31 f6                	xor    %esi,%esi
  8039b6:	e9 22 ff ff ff       	jmp    8038dd <__udivdi3+0x41>
	...

008039bc <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8039bc:	55                   	push   %ebp
  8039bd:	57                   	push   %edi
  8039be:	56                   	push   %esi
  8039bf:	83 ec 20             	sub    $0x20,%esp
  8039c2:	8b 44 24 30          	mov    0x30(%esp),%eax
  8039c6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8039ca:	89 44 24 14          	mov    %eax,0x14(%esp)
  8039ce:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8039d2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8039d6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8039da:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8039dc:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8039de:	85 ed                	test   %ebp,%ebp
  8039e0:	75 16                	jne    8039f8 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8039e2:	39 f1                	cmp    %esi,%ecx
  8039e4:	0f 86 a6 00 00 00    	jbe    803a90 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8039ea:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8039ec:	89 d0                	mov    %edx,%eax
  8039ee:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8039f0:	83 c4 20             	add    $0x20,%esp
  8039f3:	5e                   	pop    %esi
  8039f4:	5f                   	pop    %edi
  8039f5:	5d                   	pop    %ebp
  8039f6:	c3                   	ret    
  8039f7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8039f8:	39 f5                	cmp    %esi,%ebp
  8039fa:	0f 87 ac 00 00 00    	ja     803aac <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  803a00:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  803a03:	83 f0 1f             	xor    $0x1f,%eax
  803a06:	89 44 24 10          	mov    %eax,0x10(%esp)
  803a0a:	0f 84 a8 00 00 00    	je     803ab8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803a10:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803a14:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  803a16:	bf 20 00 00 00       	mov    $0x20,%edi
  803a1b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  803a1f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803a23:	89 f9                	mov    %edi,%ecx
  803a25:	d3 e8                	shr    %cl,%eax
  803a27:	09 e8                	or     %ebp,%eax
  803a29:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  803a2d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803a31:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803a35:	d3 e0                	shl    %cl,%eax
  803a37:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803a3b:	89 f2                	mov    %esi,%edx
  803a3d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  803a3f:	8b 44 24 14          	mov    0x14(%esp),%eax
  803a43:	d3 e0                	shl    %cl,%eax
  803a45:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803a49:	8b 44 24 14          	mov    0x14(%esp),%eax
  803a4d:	89 f9                	mov    %edi,%ecx
  803a4f:	d3 e8                	shr    %cl,%eax
  803a51:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  803a53:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803a55:	89 f2                	mov    %esi,%edx
  803a57:	f7 74 24 18          	divl   0x18(%esp)
  803a5b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  803a5d:	f7 64 24 0c          	mull   0xc(%esp)
  803a61:	89 c5                	mov    %eax,%ebp
  803a63:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803a65:	39 d6                	cmp    %edx,%esi
  803a67:	72 67                	jb     803ad0 <__umoddi3+0x114>
  803a69:	74 75                	je     803ae0 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  803a6b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  803a6f:	29 e8                	sub    %ebp,%eax
  803a71:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  803a73:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803a77:	d3 e8                	shr    %cl,%eax
  803a79:	89 f2                	mov    %esi,%edx
  803a7b:	89 f9                	mov    %edi,%ecx
  803a7d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  803a7f:	09 d0                	or     %edx,%eax
  803a81:	89 f2                	mov    %esi,%edx
  803a83:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803a87:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803a89:	83 c4 20             	add    $0x20,%esp
  803a8c:	5e                   	pop    %esi
  803a8d:	5f                   	pop    %edi
  803a8e:	5d                   	pop    %ebp
  803a8f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  803a90:	85 c9                	test   %ecx,%ecx
  803a92:	75 0b                	jne    803a9f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  803a94:	b8 01 00 00 00       	mov    $0x1,%eax
  803a99:	31 d2                	xor    %edx,%edx
  803a9b:	f7 f1                	div    %ecx
  803a9d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803a9f:	89 f0                	mov    %esi,%eax
  803aa1:	31 d2                	xor    %edx,%edx
  803aa3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803aa5:	89 f8                	mov    %edi,%eax
  803aa7:	e9 3e ff ff ff       	jmp    8039ea <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  803aac:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803aae:	83 c4 20             	add    $0x20,%esp
  803ab1:	5e                   	pop    %esi
  803ab2:	5f                   	pop    %edi
  803ab3:	5d                   	pop    %ebp
  803ab4:	c3                   	ret    
  803ab5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803ab8:	39 f5                	cmp    %esi,%ebp
  803aba:	72 04                	jb     803ac0 <__umoddi3+0x104>
  803abc:	39 f9                	cmp    %edi,%ecx
  803abe:	77 06                	ja     803ac6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  803ac0:	89 f2                	mov    %esi,%edx
  803ac2:	29 cf                	sub    %ecx,%edi
  803ac4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  803ac6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803ac8:	83 c4 20             	add    $0x20,%esp
  803acb:	5e                   	pop    %esi
  803acc:	5f                   	pop    %edi
  803acd:	5d                   	pop    %ebp
  803ace:	c3                   	ret    
  803acf:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  803ad0:	89 d1                	mov    %edx,%ecx
  803ad2:	89 c5                	mov    %eax,%ebp
  803ad4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  803ad8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  803adc:	eb 8d                	jmp    803a6b <__umoddi3+0xaf>
  803ade:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803ae0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  803ae4:	72 ea                	jb     803ad0 <__umoddi3+0x114>
  803ae6:	89 f1                	mov    %esi,%ecx
  803ae8:	eb 81                	jmp    803a6b <__umoddi3+0xaf>
