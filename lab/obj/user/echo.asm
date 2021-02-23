
obj/user/echo.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
  80003d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800040:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800043:	83 ff 01             	cmp    $0x1,%edi
  800046:	7e 24                	jle    80006c <umain+0x38>
  800048:	c7 44 24 04 40 25 80 	movl   $0x802540,0x4(%esp)
  80004f:	00 
  800050:	8b 46 04             	mov    0x4(%esi),%eax
  800053:	89 04 24             	mov    %eax,(%esp)
  800056:	e8 e7 01 00 00       	call   800242 <strcmp>
  80005b:	85 c0                	test   %eax,%eax
  80005d:	75 16                	jne    800075 <umain+0x41>
		nflag = 1;
		argc--;
  80005f:	4f                   	dec    %edi
		argv++;
  800060:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800063:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  80006a:	eb 10                	jmp    80007c <umain+0x48>
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  80006c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800073:	eb 07                	jmp    80007c <umain+0x48>
  800075:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  80007c:	bb 01 00 00 00       	mov    $0x1,%ebx
  800081:	eb 44                	jmp    8000c7 <umain+0x93>
		if (i > 1)
  800083:	83 fb 01             	cmp    $0x1,%ebx
  800086:	7e 1c                	jle    8000a4 <umain+0x70>
			write(1, " ", 1);
  800088:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80008f:	00 
  800090:	c7 44 24 04 43 25 80 	movl   $0x802543,0x4(%esp)
  800097:	00 
  800098:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80009f:	e8 ab 0b 00 00       	call   800c4f <write>
		write(1, argv[i], strlen(argv[i]));
  8000a4:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000a7:	89 04 24             	mov    %eax,(%esp)
  8000aa:	e8 b9 00 00 00       	call   800168 <strlen>
  8000af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b3:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8000b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000c1:	e8 89 0b 00 00       	call   800c4f <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000c6:	43                   	inc    %ebx
  8000c7:	39 df                	cmp    %ebx,%edi
  8000c9:	7f b8                	jg     800083 <umain+0x4f>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000cf:	75 1c                	jne    8000ed <umain+0xb9>
		write(1, "\n", 1);
  8000d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8000d8:	00 
  8000d9:	c7 44 24 04 90 26 80 	movl   $0x802690,0x4(%esp)
  8000e0:	00 
  8000e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8000e8:	e8 62 0b 00 00       	call   800c4f <write>
}
  8000ed:	83 c4 2c             	add    $0x2c,%esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5e                   	pop    %esi
  8000f2:	5f                   	pop    %edi
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	83 ec 10             	sub    $0x10,%esp
  800100:	8b 75 08             	mov    0x8(%ebp),%esi
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800106:	e8 44 04 00 00       	call   80054f <sys_getenvid>
  80010b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800110:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800117:	c1 e0 07             	shl    $0x7,%eax
  80011a:	29 d0                	sub    %edx,%eax
  80011c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800121:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800126:	85 f6                	test   %esi,%esi
  800128:	7e 07                	jle    800131 <libmain+0x39>
		binaryname = argv[0];
  80012a:	8b 03                	mov    (%ebx),%eax
  80012c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800135:	89 34 24             	mov    %esi,(%esp)
  800138:	e8 f7 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80013d:	e8 0a 00 00 00       	call   80014c <exit>
}
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800152:	e8 e8 08 00 00       	call   800a3f <close_all>
	sys_env_destroy(0);
  800157:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015e:	e8 9a 03 00 00       	call   8004fd <sys_env_destroy>
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    
  800165:	00 00                	add    %al,(%eax)
	...

00800168 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80016e:	b8 00 00 00 00       	mov    $0x0,%eax
  800173:	eb 01                	jmp    800176 <strlen+0xe>
		n++;
  800175:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800176:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80017a:	75 f9                	jne    800175 <strlen+0xd>
		n++;
	return n;
}
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    

0080017e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80017e:	55                   	push   %ebp
  80017f:	89 e5                	mov    %esp,%ebp
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800184:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800187:	b8 00 00 00 00       	mov    $0x0,%eax
  80018c:	eb 01                	jmp    80018f <strnlen+0x11>
		n++;
  80018e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80018f:	39 d0                	cmp    %edx,%eax
  800191:	74 06                	je     800199 <strnlen+0x1b>
  800193:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800197:	75 f5                	jne    80018e <strnlen+0x10>
		n++;
	return n;
}
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    

0080019b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	53                   	push   %ebx
  80019f:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8001a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001aa:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8001ad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8001b0:	42                   	inc    %edx
  8001b1:	84 c9                	test   %cl,%cl
  8001b3:	75 f5                	jne    8001aa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8001b5:	5b                   	pop    %ebx
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8001c2:	89 1c 24             	mov    %ebx,(%esp)
  8001c5:	e8 9e ff ff ff       	call   800168 <strlen>
	strcpy(dst + len, src);
  8001ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001d1:	01 d8                	add    %ebx,%eax
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	e8 c0 ff ff ff       	call   80019b <strcpy>
	return dst;
}
  8001db:	89 d8                	mov    %ebx,%eax
  8001dd:	83 c4 08             	add    $0x8,%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	56                   	push   %esi
  8001e7:	53                   	push   %ebx
  8001e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ee:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001f6:	eb 0c                	jmp    800204 <strncpy+0x21>
		*dst++ = *src;
  8001f8:	8a 1a                	mov    (%edx),%bl
  8001fa:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001fd:	80 3a 01             	cmpb   $0x1,(%edx)
  800200:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800203:	41                   	inc    %ecx
  800204:	39 f1                	cmp    %esi,%ecx
  800206:	75 f0                	jne    8001f8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800208:	5b                   	pop    %ebx
  800209:	5e                   	pop    %esi
  80020a:	5d                   	pop    %ebp
  80020b:	c3                   	ret    

0080020c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	56                   	push   %esi
  800210:	53                   	push   %ebx
  800211:	8b 75 08             	mov    0x8(%ebp),%esi
  800214:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800217:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80021a:	85 d2                	test   %edx,%edx
  80021c:	75 0a                	jne    800228 <strlcpy+0x1c>
  80021e:	89 f0                	mov    %esi,%eax
  800220:	eb 1a                	jmp    80023c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800222:	88 18                	mov    %bl,(%eax)
  800224:	40                   	inc    %eax
  800225:	41                   	inc    %ecx
  800226:	eb 02                	jmp    80022a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800228:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80022a:	4a                   	dec    %edx
  80022b:	74 0a                	je     800237 <strlcpy+0x2b>
  80022d:	8a 19                	mov    (%ecx),%bl
  80022f:	84 db                	test   %bl,%bl
  800231:	75 ef                	jne    800222 <strlcpy+0x16>
  800233:	89 c2                	mov    %eax,%edx
  800235:	eb 02                	jmp    800239 <strlcpy+0x2d>
  800237:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800239:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80023c:	29 f0                	sub    %esi,%eax
}
  80023e:	5b                   	pop    %ebx
  80023f:	5e                   	pop    %esi
  800240:	5d                   	pop    %ebp
  800241:	c3                   	ret    

00800242 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800242:	55                   	push   %ebp
  800243:	89 e5                	mov    %esp,%ebp
  800245:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800248:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80024b:	eb 02                	jmp    80024f <strcmp+0xd>
		p++, q++;
  80024d:	41                   	inc    %ecx
  80024e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80024f:	8a 01                	mov    (%ecx),%al
  800251:	84 c0                	test   %al,%al
  800253:	74 04                	je     800259 <strcmp+0x17>
  800255:	3a 02                	cmp    (%edx),%al
  800257:	74 f4                	je     80024d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800259:	0f b6 c0             	movzbl %al,%eax
  80025c:	0f b6 12             	movzbl (%edx),%edx
  80025f:	29 d0                	sub    %edx,%eax
}
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	53                   	push   %ebx
  800267:	8b 45 08             	mov    0x8(%ebp),%eax
  80026a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800270:	eb 03                	jmp    800275 <strncmp+0x12>
		n--, p++, q++;
  800272:	4a                   	dec    %edx
  800273:	40                   	inc    %eax
  800274:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800275:	85 d2                	test   %edx,%edx
  800277:	74 14                	je     80028d <strncmp+0x2a>
  800279:	8a 18                	mov    (%eax),%bl
  80027b:	84 db                	test   %bl,%bl
  80027d:	74 04                	je     800283 <strncmp+0x20>
  80027f:	3a 19                	cmp    (%ecx),%bl
  800281:	74 ef                	je     800272 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800283:	0f b6 00             	movzbl (%eax),%eax
  800286:	0f b6 11             	movzbl (%ecx),%edx
  800289:	29 d0                	sub    %edx,%eax
  80028b:	eb 05                	jmp    800292 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80028d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800292:	5b                   	pop    %ebx
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	8b 45 08             	mov    0x8(%ebp),%eax
  80029b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80029e:	eb 05                	jmp    8002a5 <strchr+0x10>
		if (*s == c)
  8002a0:	38 ca                	cmp    %cl,%dl
  8002a2:	74 0c                	je     8002b0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8002a4:	40                   	inc    %eax
  8002a5:	8a 10                	mov    (%eax),%dl
  8002a7:	84 d2                	test   %dl,%dl
  8002a9:	75 f5                	jne    8002a0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8002ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8002bb:	eb 05                	jmp    8002c2 <strfind+0x10>
		if (*s == c)
  8002bd:	38 ca                	cmp    %cl,%dl
  8002bf:	74 07                	je     8002c8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8002c1:	40                   	inc    %eax
  8002c2:	8a 10                	mov    (%eax),%dl
  8002c4:	84 d2                	test   %dl,%dl
  8002c6:	75 f5                	jne    8002bd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	57                   	push   %edi
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8002d9:	85 c9                	test   %ecx,%ecx
  8002db:	74 30                	je     80030d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002dd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002e3:	75 25                	jne    80030a <memset+0x40>
  8002e5:	f6 c1 03             	test   $0x3,%cl
  8002e8:	75 20                	jne    80030a <memset+0x40>
		c &= 0xFF;
  8002ea:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002ed:	89 d3                	mov    %edx,%ebx
  8002ef:	c1 e3 08             	shl    $0x8,%ebx
  8002f2:	89 d6                	mov    %edx,%esi
  8002f4:	c1 e6 18             	shl    $0x18,%esi
  8002f7:	89 d0                	mov    %edx,%eax
  8002f9:	c1 e0 10             	shl    $0x10,%eax
  8002fc:	09 f0                	or     %esi,%eax
  8002fe:	09 d0                	or     %edx,%eax
  800300:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800302:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800305:	fc                   	cld    
  800306:	f3 ab                	rep stos %eax,%es:(%edi)
  800308:	eb 03                	jmp    80030d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80030a:	fc                   	cld    
  80030b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80030d:	89 f8                	mov    %edi,%eax
  80030f:	5b                   	pop    %ebx
  800310:	5e                   	pop    %esi
  800311:	5f                   	pop    %edi
  800312:	5d                   	pop    %ebp
  800313:	c3                   	ret    

00800314 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	57                   	push   %edi
  800318:	56                   	push   %esi
  800319:	8b 45 08             	mov    0x8(%ebp),%eax
  80031c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80031f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800322:	39 c6                	cmp    %eax,%esi
  800324:	73 34                	jae    80035a <memmove+0x46>
  800326:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800329:	39 d0                	cmp    %edx,%eax
  80032b:	73 2d                	jae    80035a <memmove+0x46>
		s += n;
		d += n;
  80032d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800330:	f6 c2 03             	test   $0x3,%dl
  800333:	75 1b                	jne    800350 <memmove+0x3c>
  800335:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80033b:	75 13                	jne    800350 <memmove+0x3c>
  80033d:	f6 c1 03             	test   $0x3,%cl
  800340:	75 0e                	jne    800350 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800342:	83 ef 04             	sub    $0x4,%edi
  800345:	8d 72 fc             	lea    -0x4(%edx),%esi
  800348:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80034b:	fd                   	std    
  80034c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80034e:	eb 07                	jmp    800357 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800350:	4f                   	dec    %edi
  800351:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800354:	fd                   	std    
  800355:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800357:	fc                   	cld    
  800358:	eb 20                	jmp    80037a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80035a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800360:	75 13                	jne    800375 <memmove+0x61>
  800362:	a8 03                	test   $0x3,%al
  800364:	75 0f                	jne    800375 <memmove+0x61>
  800366:	f6 c1 03             	test   $0x3,%cl
  800369:	75 0a                	jne    800375 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80036b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80036e:	89 c7                	mov    %eax,%edi
  800370:	fc                   	cld    
  800371:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800373:	eb 05                	jmp    80037a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800375:	89 c7                	mov    %eax,%edi
  800377:	fc                   	cld    
  800378:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80037a:	5e                   	pop    %esi
  80037b:	5f                   	pop    %edi
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800384:	8b 45 10             	mov    0x10(%ebp),%eax
  800387:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80038e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	89 04 24             	mov    %eax,(%esp)
  800398:	e8 77 ff ff ff       	call   800314 <memmove>
}
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	57                   	push   %edi
  8003a3:	56                   	push   %esi
  8003a4:	53                   	push   %ebx
  8003a5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b3:	eb 16                	jmp    8003cb <memcmp+0x2c>
		if (*s1 != *s2)
  8003b5:	8a 04 17             	mov    (%edi,%edx,1),%al
  8003b8:	42                   	inc    %edx
  8003b9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8003bd:	38 c8                	cmp    %cl,%al
  8003bf:	74 0a                	je     8003cb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8003c1:	0f b6 c0             	movzbl %al,%eax
  8003c4:	0f b6 c9             	movzbl %cl,%ecx
  8003c7:	29 c8                	sub    %ecx,%eax
  8003c9:	eb 09                	jmp    8003d4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003cb:	39 da                	cmp    %ebx,%edx
  8003cd:	75 e6                	jne    8003b5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003d4:	5b                   	pop    %ebx
  8003d5:	5e                   	pop    %esi
  8003d6:	5f                   	pop    %edi
  8003d7:	5d                   	pop    %ebp
  8003d8:	c3                   	ret    

008003d9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003d9:	55                   	push   %ebp
  8003da:	89 e5                	mov    %esp,%ebp
  8003dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8003df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8003e2:	89 c2                	mov    %eax,%edx
  8003e4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8003e7:	eb 05                	jmp    8003ee <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003e9:	38 08                	cmp    %cl,(%eax)
  8003eb:	74 05                	je     8003f2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003ed:	40                   	inc    %eax
  8003ee:	39 d0                	cmp    %edx,%eax
  8003f0:	72 f7                	jb     8003e9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	57                   	push   %edi
  8003f8:	56                   	push   %esi
  8003f9:	53                   	push   %ebx
  8003fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800400:	eb 01                	jmp    800403 <strtol+0xf>
		s++;
  800402:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800403:	8a 02                	mov    (%edx),%al
  800405:	3c 20                	cmp    $0x20,%al
  800407:	74 f9                	je     800402 <strtol+0xe>
  800409:	3c 09                	cmp    $0x9,%al
  80040b:	74 f5                	je     800402 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80040d:	3c 2b                	cmp    $0x2b,%al
  80040f:	75 08                	jne    800419 <strtol+0x25>
		s++;
  800411:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800412:	bf 00 00 00 00       	mov    $0x0,%edi
  800417:	eb 13                	jmp    80042c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800419:	3c 2d                	cmp    $0x2d,%al
  80041b:	75 0a                	jne    800427 <strtol+0x33>
		s++, neg = 1;
  80041d:	8d 52 01             	lea    0x1(%edx),%edx
  800420:	bf 01 00 00 00       	mov    $0x1,%edi
  800425:	eb 05                	jmp    80042c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800427:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80042c:	85 db                	test   %ebx,%ebx
  80042e:	74 05                	je     800435 <strtol+0x41>
  800430:	83 fb 10             	cmp    $0x10,%ebx
  800433:	75 28                	jne    80045d <strtol+0x69>
  800435:	8a 02                	mov    (%edx),%al
  800437:	3c 30                	cmp    $0x30,%al
  800439:	75 10                	jne    80044b <strtol+0x57>
  80043b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80043f:	75 0a                	jne    80044b <strtol+0x57>
		s += 2, base = 16;
  800441:	83 c2 02             	add    $0x2,%edx
  800444:	bb 10 00 00 00       	mov    $0x10,%ebx
  800449:	eb 12                	jmp    80045d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80044b:	85 db                	test   %ebx,%ebx
  80044d:	75 0e                	jne    80045d <strtol+0x69>
  80044f:	3c 30                	cmp    $0x30,%al
  800451:	75 05                	jne    800458 <strtol+0x64>
		s++, base = 8;
  800453:	42                   	inc    %edx
  800454:	b3 08                	mov    $0x8,%bl
  800456:	eb 05                	jmp    80045d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800458:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80045d:	b8 00 00 00 00       	mov    $0x0,%eax
  800462:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800464:	8a 0a                	mov    (%edx),%cl
  800466:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800469:	80 fb 09             	cmp    $0x9,%bl
  80046c:	77 08                	ja     800476 <strtol+0x82>
			dig = *s - '0';
  80046e:	0f be c9             	movsbl %cl,%ecx
  800471:	83 e9 30             	sub    $0x30,%ecx
  800474:	eb 1e                	jmp    800494 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800476:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800479:	80 fb 19             	cmp    $0x19,%bl
  80047c:	77 08                	ja     800486 <strtol+0x92>
			dig = *s - 'a' + 10;
  80047e:	0f be c9             	movsbl %cl,%ecx
  800481:	83 e9 57             	sub    $0x57,%ecx
  800484:	eb 0e                	jmp    800494 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800486:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800489:	80 fb 19             	cmp    $0x19,%bl
  80048c:	77 12                	ja     8004a0 <strtol+0xac>
			dig = *s - 'A' + 10;
  80048e:	0f be c9             	movsbl %cl,%ecx
  800491:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800494:	39 f1                	cmp    %esi,%ecx
  800496:	7d 0c                	jge    8004a4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800498:	42                   	inc    %edx
  800499:	0f af c6             	imul   %esi,%eax
  80049c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80049e:	eb c4                	jmp    800464 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8004a0:	89 c1                	mov    %eax,%ecx
  8004a2:	eb 02                	jmp    8004a6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8004a4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8004a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004aa:	74 05                	je     8004b1 <strtol+0xbd>
		*endptr = (char *) s;
  8004ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004af:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8004b1:	85 ff                	test   %edi,%edi
  8004b3:	74 04                	je     8004b9 <strtol+0xc5>
  8004b5:	89 c8                	mov    %ecx,%eax
  8004b7:	f7 d8                	neg    %eax
}
  8004b9:	5b                   	pop    %ebx
  8004ba:	5e                   	pop    %esi
  8004bb:	5f                   	pop    %edi
  8004bc:	5d                   	pop    %ebp
  8004bd:	c3                   	ret    
	...

008004c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	57                   	push   %edi
  8004c4:	56                   	push   %esi
  8004c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d1:	89 c3                	mov    %eax,%ebx
  8004d3:	89 c7                	mov    %eax,%edi
  8004d5:	89 c6                	mov    %eax,%esi
  8004d7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004d9:	5b                   	pop    %ebx
  8004da:	5e                   	pop    %esi
  8004db:	5f                   	pop    %edi
  8004dc:	5d                   	pop    %ebp
  8004dd:	c3                   	ret    

008004de <sys_cgetc>:

int
sys_cgetc(void)
{
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	57                   	push   %edi
  8004e2:	56                   	push   %esi
  8004e3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8004ee:	89 d1                	mov    %edx,%ecx
  8004f0:	89 d3                	mov    %edx,%ebx
  8004f2:	89 d7                	mov    %edx,%edi
  8004f4:	89 d6                	mov    %edx,%esi
  8004f6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004f8:	5b                   	pop    %ebx
  8004f9:	5e                   	pop    %esi
  8004fa:	5f                   	pop    %edi
  8004fb:	5d                   	pop    %ebp
  8004fc:	c3                   	ret    

008004fd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8004fd:	55                   	push   %ebp
  8004fe:	89 e5                	mov    %esp,%ebp
  800500:	57                   	push   %edi
  800501:	56                   	push   %esi
  800502:	53                   	push   %ebx
  800503:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800506:	b9 00 00 00 00       	mov    $0x0,%ecx
  80050b:	b8 03 00 00 00       	mov    $0x3,%eax
  800510:	8b 55 08             	mov    0x8(%ebp),%edx
  800513:	89 cb                	mov    %ecx,%ebx
  800515:	89 cf                	mov    %ecx,%edi
  800517:	89 ce                	mov    %ecx,%esi
  800519:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80051b:	85 c0                	test   %eax,%eax
  80051d:	7e 28                	jle    800547 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80051f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800523:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80052a:	00 
  80052b:	c7 44 24 08 4f 25 80 	movl   $0x80254f,0x8(%esp)
  800532:	00 
  800533:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80053a:	00 
  80053b:	c7 04 24 6c 25 80 00 	movl   $0x80256c,(%esp)
  800542:	e8 b5 15 00 00       	call   801afc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800547:	83 c4 2c             	add    $0x2c,%esp
  80054a:	5b                   	pop    %ebx
  80054b:	5e                   	pop    %esi
  80054c:	5f                   	pop    %edi
  80054d:	5d                   	pop    %ebp
  80054e:	c3                   	ret    

0080054f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80054f:	55                   	push   %ebp
  800550:	89 e5                	mov    %esp,%ebp
  800552:	57                   	push   %edi
  800553:	56                   	push   %esi
  800554:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800555:	ba 00 00 00 00       	mov    $0x0,%edx
  80055a:	b8 02 00 00 00       	mov    $0x2,%eax
  80055f:	89 d1                	mov    %edx,%ecx
  800561:	89 d3                	mov    %edx,%ebx
  800563:	89 d7                	mov    %edx,%edi
  800565:	89 d6                	mov    %edx,%esi
  800567:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800569:	5b                   	pop    %ebx
  80056a:	5e                   	pop    %esi
  80056b:	5f                   	pop    %edi
  80056c:	5d                   	pop    %ebp
  80056d:	c3                   	ret    

0080056e <sys_yield>:

void
sys_yield(void)
{
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
  800571:	57                   	push   %edi
  800572:	56                   	push   %esi
  800573:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800574:	ba 00 00 00 00       	mov    $0x0,%edx
  800579:	b8 0b 00 00 00       	mov    $0xb,%eax
  80057e:	89 d1                	mov    %edx,%ecx
  800580:	89 d3                	mov    %edx,%ebx
  800582:	89 d7                	mov    %edx,%edi
  800584:	89 d6                	mov    %edx,%esi
  800586:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800588:	5b                   	pop    %ebx
  800589:	5e                   	pop    %esi
  80058a:	5f                   	pop    %edi
  80058b:	5d                   	pop    %ebp
  80058c:	c3                   	ret    

0080058d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80058d:	55                   	push   %ebp
  80058e:	89 e5                	mov    %esp,%ebp
  800590:	57                   	push   %edi
  800591:	56                   	push   %esi
  800592:	53                   	push   %ebx
  800593:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800596:	be 00 00 00 00       	mov    $0x0,%esi
  80059b:	b8 04 00 00 00       	mov    $0x4,%eax
  8005a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a9:	89 f7                	mov    %esi,%edi
  8005ab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8005ad:	85 c0                	test   %eax,%eax
  8005af:	7e 28                	jle    8005d9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8005b5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8005bc:	00 
  8005bd:	c7 44 24 08 4f 25 80 	movl   $0x80254f,0x8(%esp)
  8005c4:	00 
  8005c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8005cc:	00 
  8005cd:	c7 04 24 6c 25 80 00 	movl   $0x80256c,(%esp)
  8005d4:	e8 23 15 00 00       	call   801afc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005d9:	83 c4 2c             	add    $0x2c,%esp
  8005dc:	5b                   	pop    %ebx
  8005dd:	5e                   	pop    %esi
  8005de:	5f                   	pop    %edi
  8005df:	5d                   	pop    %ebp
  8005e0:	c3                   	ret    

008005e1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005e1:	55                   	push   %ebp
  8005e2:	89 e5                	mov    %esp,%ebp
  8005e4:	57                   	push   %edi
  8005e5:	56                   	push   %esi
  8005e6:	53                   	push   %ebx
  8005e7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8005ef:	8b 75 18             	mov    0x18(%ebp),%esi
  8005f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8005fe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800600:	85 c0                	test   %eax,%eax
  800602:	7e 28                	jle    80062c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800604:	89 44 24 10          	mov    %eax,0x10(%esp)
  800608:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80060f:	00 
  800610:	c7 44 24 08 4f 25 80 	movl   $0x80254f,0x8(%esp)
  800617:	00 
  800618:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80061f:	00 
  800620:	c7 04 24 6c 25 80 00 	movl   $0x80256c,(%esp)
  800627:	e8 d0 14 00 00       	call   801afc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80062c:	83 c4 2c             	add    $0x2c,%esp
  80062f:	5b                   	pop    %ebx
  800630:	5e                   	pop    %esi
  800631:	5f                   	pop    %edi
  800632:	5d                   	pop    %ebp
  800633:	c3                   	ret    

00800634 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800634:	55                   	push   %ebp
  800635:	89 e5                	mov    %esp,%ebp
  800637:	57                   	push   %edi
  800638:	56                   	push   %esi
  800639:	53                   	push   %ebx
  80063a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80063d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800642:	b8 06 00 00 00       	mov    $0x6,%eax
  800647:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80064a:	8b 55 08             	mov    0x8(%ebp),%edx
  80064d:	89 df                	mov    %ebx,%edi
  80064f:	89 de                	mov    %ebx,%esi
  800651:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800653:	85 c0                	test   %eax,%eax
  800655:	7e 28                	jle    80067f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800657:	89 44 24 10          	mov    %eax,0x10(%esp)
  80065b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800662:	00 
  800663:	c7 44 24 08 4f 25 80 	movl   $0x80254f,0x8(%esp)
  80066a:	00 
  80066b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800672:	00 
  800673:	c7 04 24 6c 25 80 00 	movl   $0x80256c,(%esp)
  80067a:	e8 7d 14 00 00       	call   801afc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80067f:	83 c4 2c             	add    $0x2c,%esp
  800682:	5b                   	pop    %ebx
  800683:	5e                   	pop    %esi
  800684:	5f                   	pop    %edi
  800685:	5d                   	pop    %ebp
  800686:	c3                   	ret    

00800687 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	57                   	push   %edi
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
  80068d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800690:	bb 00 00 00 00       	mov    $0x0,%ebx
  800695:	b8 08 00 00 00       	mov    $0x8,%eax
  80069a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80069d:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a0:	89 df                	mov    %ebx,%edi
  8006a2:	89 de                	mov    %ebx,%esi
  8006a4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006a6:	85 c0                	test   %eax,%eax
  8006a8:	7e 28                	jle    8006d2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006ae:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8006b5:	00 
  8006b6:	c7 44 24 08 4f 25 80 	movl   $0x80254f,0x8(%esp)
  8006bd:	00 
  8006be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8006c5:	00 
  8006c6:	c7 04 24 6c 25 80 00 	movl   $0x80256c,(%esp)
  8006cd:	e8 2a 14 00 00       	call   801afc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8006d2:	83 c4 2c             	add    $0x2c,%esp
  8006d5:	5b                   	pop    %ebx
  8006d6:	5e                   	pop    %esi
  8006d7:	5f                   	pop    %edi
  8006d8:	5d                   	pop    %ebp
  8006d9:	c3                   	ret    

008006da <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	57                   	push   %edi
  8006de:	56                   	push   %esi
  8006df:	53                   	push   %ebx
  8006e0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e8:	b8 09 00 00 00       	mov    $0x9,%eax
  8006ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f3:	89 df                	mov    %ebx,%edi
  8006f5:	89 de                	mov    %ebx,%esi
  8006f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	7e 28                	jle    800725 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800701:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800708:	00 
  800709:	c7 44 24 08 4f 25 80 	movl   $0x80254f,0x8(%esp)
  800710:	00 
  800711:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800718:	00 
  800719:	c7 04 24 6c 25 80 00 	movl   $0x80256c,(%esp)
  800720:	e8 d7 13 00 00       	call   801afc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800725:	83 c4 2c             	add    $0x2c,%esp
  800728:	5b                   	pop    %ebx
  800729:	5e                   	pop    %esi
  80072a:	5f                   	pop    %edi
  80072b:	5d                   	pop    %ebp
  80072c:	c3                   	ret    

0080072d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	57                   	push   %edi
  800731:	56                   	push   %esi
  800732:	53                   	push   %ebx
  800733:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800736:	bb 00 00 00 00       	mov    $0x0,%ebx
  80073b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800740:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800743:	8b 55 08             	mov    0x8(%ebp),%edx
  800746:	89 df                	mov    %ebx,%edi
  800748:	89 de                	mov    %ebx,%esi
  80074a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80074c:	85 c0                	test   %eax,%eax
  80074e:	7e 28                	jle    800778 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800750:	89 44 24 10          	mov    %eax,0x10(%esp)
  800754:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80075b:	00 
  80075c:	c7 44 24 08 4f 25 80 	movl   $0x80254f,0x8(%esp)
  800763:	00 
  800764:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80076b:	00 
  80076c:	c7 04 24 6c 25 80 00 	movl   $0x80256c,(%esp)
  800773:	e8 84 13 00 00       	call   801afc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800778:	83 c4 2c             	add    $0x2c,%esp
  80077b:	5b                   	pop    %ebx
  80077c:	5e                   	pop    %esi
  80077d:	5f                   	pop    %edi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	57                   	push   %edi
  800784:	56                   	push   %esi
  800785:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800786:	be 00 00 00 00       	mov    $0x0,%esi
  80078b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800790:	8b 7d 14             	mov    0x14(%ebp),%edi
  800793:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800796:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800799:	8b 55 08             	mov    0x8(%ebp),%edx
  80079c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80079e:	5b                   	pop    %ebx
  80079f:	5e                   	pop    %esi
  8007a0:	5f                   	pop    %edi
  8007a1:	5d                   	pop    %ebp
  8007a2:	c3                   	ret    

008007a3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8007a3:	55                   	push   %ebp
  8007a4:	89 e5                	mov    %esp,%ebp
  8007a6:	57                   	push   %edi
  8007a7:	56                   	push   %esi
  8007a8:	53                   	push   %ebx
  8007a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8007b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8007b9:	89 cb                	mov    %ecx,%ebx
  8007bb:	89 cf                	mov    %ecx,%edi
  8007bd:	89 ce                	mov    %ecx,%esi
  8007bf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	7e 28                	jle    8007ed <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8007c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8007c9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8007d0:	00 
  8007d1:	c7 44 24 08 4f 25 80 	movl   $0x80254f,0x8(%esp)
  8007d8:	00 
  8007d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8007e0:	00 
  8007e1:	c7 04 24 6c 25 80 00 	movl   $0x80256c,(%esp)
  8007e8:	e8 0f 13 00 00       	call   801afc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8007ed:	83 c4 2c             	add    $0x2c,%esp
  8007f0:	5b                   	pop    %ebx
  8007f1:	5e                   	pop    %esi
  8007f2:	5f                   	pop    %edi
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	57                   	push   %edi
  8007f9:	56                   	push   %esi
  8007fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8007fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800800:	b8 0e 00 00 00       	mov    $0xe,%eax
  800805:	89 d1                	mov    %edx,%ecx
  800807:	89 d3                	mov    %edx,%ebx
  800809:	89 d7                	mov    %edx,%edi
  80080b:	89 d6                	mov    %edx,%esi
  80080d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80080f:	5b                   	pop    %ebx
  800810:	5e                   	pop    %esi
  800811:	5f                   	pop    %edi
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	57                   	push   %edi
  800818:	56                   	push   %esi
  800819:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80081a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80081f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800824:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800827:	8b 55 08             	mov    0x8(%ebp),%edx
  80082a:	89 df                	mov    %ebx,%edi
  80082c:	89 de                	mov    %ebx,%esi
  80082e:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800830:	5b                   	pop    %ebx
  800831:	5e                   	pop    %esi
  800832:	5f                   	pop    %edi
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	57                   	push   %edi
  800839:	56                   	push   %esi
  80083a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80083b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800840:	b8 10 00 00 00       	mov    $0x10,%eax
  800845:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800848:	8b 55 08             	mov    0x8(%ebp),%edx
  80084b:	89 df                	mov    %ebx,%edi
  80084d:	89 de                	mov    %ebx,%esi
  80084f:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800851:	5b                   	pop    %ebx
  800852:	5e                   	pop    %esi
  800853:	5f                   	pop    %edi
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    
	...

00800858 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	05 00 00 00 30       	add    $0x30000000,%eax
  800863:	c1 e8 0c             	shr    $0xc,%eax
}
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	89 04 24             	mov    %eax,(%esp)
  800874:	e8 df ff ff ff       	call   800858 <fd2num>
  800879:	c1 e0 0c             	shl    $0xc,%eax
  80087c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800881:	c9                   	leave  
  800882:	c3                   	ret    

00800883 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	53                   	push   %ebx
  800887:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80088a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80088f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800891:	89 c2                	mov    %eax,%edx
  800893:	c1 ea 16             	shr    $0x16,%edx
  800896:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80089d:	f6 c2 01             	test   $0x1,%dl
  8008a0:	74 11                	je     8008b3 <fd_alloc+0x30>
  8008a2:	89 c2                	mov    %eax,%edx
  8008a4:	c1 ea 0c             	shr    $0xc,%edx
  8008a7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8008ae:	f6 c2 01             	test   $0x1,%dl
  8008b1:	75 09                	jne    8008bc <fd_alloc+0x39>
			*fd_store = fd;
  8008b3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ba:	eb 17                	jmp    8008d3 <fd_alloc+0x50>
  8008bc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8008c1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8008c6:	75 c7                	jne    80088f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8008c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8008ce:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8008d3:	5b                   	pop    %ebx
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8008dc:	83 f8 1f             	cmp    $0x1f,%eax
  8008df:	77 36                	ja     800917 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8008e1:	c1 e0 0c             	shl    $0xc,%eax
  8008e4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8008e9:	89 c2                	mov    %eax,%edx
  8008eb:	c1 ea 16             	shr    $0x16,%edx
  8008ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8008f5:	f6 c2 01             	test   $0x1,%dl
  8008f8:	74 24                	je     80091e <fd_lookup+0x48>
  8008fa:	89 c2                	mov    %eax,%edx
  8008fc:	c1 ea 0c             	shr    $0xc,%edx
  8008ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800906:	f6 c2 01             	test   $0x1,%dl
  800909:	74 1a                	je     800925 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090e:	89 02                	mov    %eax,(%edx)
	return 0;
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
  800915:	eb 13                	jmp    80092a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800917:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80091c:	eb 0c                	jmp    80092a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80091e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800923:	eb 05                	jmp    80092a <fd_lookup+0x54>
  800925:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	53                   	push   %ebx
  800930:	83 ec 14             	sub    $0x14,%esp
  800933:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800936:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800939:	ba 00 00 00 00       	mov    $0x0,%edx
  80093e:	eb 0e                	jmp    80094e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800940:	39 08                	cmp    %ecx,(%eax)
  800942:	75 09                	jne    80094d <dev_lookup+0x21>
			*dev = devtab[i];
  800944:	89 03                	mov    %eax,(%ebx)
			return 0;
  800946:	b8 00 00 00 00       	mov    $0x0,%eax
  80094b:	eb 33                	jmp    800980 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80094d:	42                   	inc    %edx
  80094e:	8b 04 95 f8 25 80 00 	mov    0x8025f8(,%edx,4),%eax
  800955:	85 c0                	test   %eax,%eax
  800957:	75 e7                	jne    800940 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800959:	a1 08 40 80 00       	mov    0x804008,%eax
  80095e:	8b 40 48             	mov    0x48(%eax),%eax
  800961:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800965:	89 44 24 04          	mov    %eax,0x4(%esp)
  800969:	c7 04 24 7c 25 80 00 	movl   $0x80257c,(%esp)
  800970:	e8 7f 12 00 00       	call   801bf4 <cprintf>
	*dev = 0;
  800975:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80097b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800980:	83 c4 14             	add    $0x14,%esp
  800983:	5b                   	pop    %ebx
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	56                   	push   %esi
  80098a:	53                   	push   %ebx
  80098b:	83 ec 30             	sub    $0x30,%esp
  80098e:	8b 75 08             	mov    0x8(%ebp),%esi
  800991:	8a 45 0c             	mov    0xc(%ebp),%al
  800994:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800997:	89 34 24             	mov    %esi,(%esp)
  80099a:	e8 b9 fe ff ff       	call   800858 <fd2num>
  80099f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8009a2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009a6:	89 04 24             	mov    %eax,(%esp)
  8009a9:	e8 28 ff ff ff       	call   8008d6 <fd_lookup>
  8009ae:	89 c3                	mov    %eax,%ebx
  8009b0:	85 c0                	test   %eax,%eax
  8009b2:	78 05                	js     8009b9 <fd_close+0x33>
	    || fd != fd2)
  8009b4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8009b7:	74 0d                	je     8009c6 <fd_close+0x40>
		return (must_exist ? r : 0);
  8009b9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8009bd:	75 46                	jne    800a05 <fd_close+0x7f>
  8009bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8009c4:	eb 3f                	jmp    800a05 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8009c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cd:	8b 06                	mov    (%esi),%eax
  8009cf:	89 04 24             	mov    %eax,(%esp)
  8009d2:	e8 55 ff ff ff       	call   80092c <dev_lookup>
  8009d7:	89 c3                	mov    %eax,%ebx
  8009d9:	85 c0                	test   %eax,%eax
  8009db:	78 18                	js     8009f5 <fd_close+0x6f>
		if (dev->dev_close)
  8009dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009e0:	8b 40 10             	mov    0x10(%eax),%eax
  8009e3:	85 c0                	test   %eax,%eax
  8009e5:	74 09                	je     8009f0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8009e7:	89 34 24             	mov    %esi,(%esp)
  8009ea:	ff d0                	call   *%eax
  8009ec:	89 c3                	mov    %eax,%ebx
  8009ee:	eb 05                	jmp    8009f5 <fd_close+0x6f>
		else
			r = 0;
  8009f0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8009f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a00:	e8 2f fc ff ff       	call   800634 <sys_page_unmap>
	return r;
}
  800a05:	89 d8                	mov    %ebx,%eax
  800a07:	83 c4 30             	add    $0x30,%esp
  800a0a:	5b                   	pop    %ebx
  800a0b:	5e                   	pop    %esi
  800a0c:	5d                   	pop    %ebp
  800a0d:	c3                   	ret    

00800a0e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a17:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	89 04 24             	mov    %eax,(%esp)
  800a21:	e8 b0 fe ff ff       	call   8008d6 <fd_lookup>
  800a26:	85 c0                	test   %eax,%eax
  800a28:	78 13                	js     800a3d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800a2a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800a31:	00 
  800a32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a35:	89 04 24             	mov    %eax,(%esp)
  800a38:	e8 49 ff ff ff       	call   800986 <fd_close>
}
  800a3d:	c9                   	leave  
  800a3e:	c3                   	ret    

00800a3f <close_all>:

void
close_all(void)
{
  800a3f:	55                   	push   %ebp
  800a40:	89 e5                	mov    %esp,%ebp
  800a42:	53                   	push   %ebx
  800a43:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800a46:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800a4b:	89 1c 24             	mov    %ebx,(%esp)
  800a4e:	e8 bb ff ff ff       	call   800a0e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800a53:	43                   	inc    %ebx
  800a54:	83 fb 20             	cmp    $0x20,%ebx
  800a57:	75 f2                	jne    800a4b <close_all+0xc>
		close(i);
}
  800a59:	83 c4 14             	add    $0x14,%esp
  800a5c:	5b                   	pop    %ebx
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
  800a65:	83 ec 4c             	sub    $0x4c,%esp
  800a68:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800a6b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	89 04 24             	mov    %eax,(%esp)
  800a78:	e8 59 fe ff ff       	call   8008d6 <fd_lookup>
  800a7d:	89 c3                	mov    %eax,%ebx
  800a7f:	85 c0                	test   %eax,%eax
  800a81:	0f 88 e3 00 00 00    	js     800b6a <dup+0x10b>
		return r;
	close(newfdnum);
  800a87:	89 3c 24             	mov    %edi,(%esp)
  800a8a:	e8 7f ff ff ff       	call   800a0e <close>

	newfd = INDEX2FD(newfdnum);
  800a8f:	89 fe                	mov    %edi,%esi
  800a91:	c1 e6 0c             	shl    $0xc,%esi
  800a94:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800a9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a9d:	89 04 24             	mov    %eax,(%esp)
  800aa0:	e8 c3 fd ff ff       	call   800868 <fd2data>
  800aa5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800aa7:	89 34 24             	mov    %esi,(%esp)
  800aaa:	e8 b9 fd ff ff       	call   800868 <fd2data>
  800aaf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800ab2:	89 d8                	mov    %ebx,%eax
  800ab4:	c1 e8 16             	shr    $0x16,%eax
  800ab7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800abe:	a8 01                	test   $0x1,%al
  800ac0:	74 46                	je     800b08 <dup+0xa9>
  800ac2:	89 d8                	mov    %ebx,%eax
  800ac4:	c1 e8 0c             	shr    $0xc,%eax
  800ac7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ace:	f6 c2 01             	test   $0x1,%dl
  800ad1:	74 35                	je     800b08 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800ad3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ada:	25 07 0e 00 00       	and    $0xe07,%eax
  800adf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ae3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ae6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800af1:	00 
  800af2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800af6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800afd:	e8 df fa ff ff       	call   8005e1 <sys_page_map>
  800b02:	89 c3                	mov    %eax,%ebx
  800b04:	85 c0                	test   %eax,%eax
  800b06:	78 3b                	js     800b43 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b0b:	89 c2                	mov    %eax,%edx
  800b0d:	c1 ea 0c             	shr    $0xc,%edx
  800b10:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800b17:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800b1d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b21:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b25:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b2c:	00 
  800b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b38:	e8 a4 fa ff ff       	call   8005e1 <sys_page_map>
  800b3d:	89 c3                	mov    %eax,%ebx
  800b3f:	85 c0                	test   %eax,%eax
  800b41:	79 25                	jns    800b68 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800b43:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b4e:	e8 e1 fa ff ff       	call   800634 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800b53:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800b56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b61:	e8 ce fa ff ff       	call   800634 <sys_page_unmap>
	return r;
  800b66:	eb 02                	jmp    800b6a <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800b68:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800b6a:	89 d8                	mov    %ebx,%eax
  800b6c:	83 c4 4c             	add    $0x4c,%esp
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5f                   	pop    %edi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	53                   	push   %ebx
  800b78:	83 ec 24             	sub    $0x24,%esp
  800b7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b7e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b85:	89 1c 24             	mov    %ebx,(%esp)
  800b88:	e8 49 fd ff ff       	call   8008d6 <fd_lookup>
  800b8d:	85 c0                	test   %eax,%eax
  800b8f:	78 6d                	js     800bfe <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b94:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b9b:	8b 00                	mov    (%eax),%eax
  800b9d:	89 04 24             	mov    %eax,(%esp)
  800ba0:	e8 87 fd ff ff       	call   80092c <dev_lookup>
  800ba5:	85 c0                	test   %eax,%eax
  800ba7:	78 55                	js     800bfe <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800ba9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bac:	8b 50 08             	mov    0x8(%eax),%edx
  800baf:	83 e2 03             	and    $0x3,%edx
  800bb2:	83 fa 01             	cmp    $0x1,%edx
  800bb5:	75 23                	jne    800bda <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800bb7:	a1 08 40 80 00       	mov    0x804008,%eax
  800bbc:	8b 40 48             	mov    0x48(%eax),%eax
  800bbf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800bc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc7:	c7 04 24 bd 25 80 00 	movl   $0x8025bd,(%esp)
  800bce:	e8 21 10 00 00       	call   801bf4 <cprintf>
		return -E_INVAL;
  800bd3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bd8:	eb 24                	jmp    800bfe <read+0x8a>
	}
	if (!dev->dev_read)
  800bda:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800bdd:	8b 52 08             	mov    0x8(%edx),%edx
  800be0:	85 d2                	test   %edx,%edx
  800be2:	74 15                	je     800bf9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800be4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800be7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800bf2:	89 04 24             	mov    %eax,(%esp)
  800bf5:	ff d2                	call   *%edx
  800bf7:	eb 05                	jmp    800bfe <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800bf9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800bfe:	83 c4 24             	add    $0x24,%esp
  800c01:	5b                   	pop    %ebx
  800c02:	5d                   	pop    %ebp
  800c03:	c3                   	ret    

00800c04 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 1c             	sub    $0x1c,%esp
  800c0d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c10:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c18:	eb 23                	jmp    800c3d <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800c1a:	89 f0                	mov    %esi,%eax
  800c1c:	29 d8                	sub    %ebx,%eax
  800c1e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c25:	01 d8                	add    %ebx,%eax
  800c27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c2b:	89 3c 24             	mov    %edi,(%esp)
  800c2e:	e8 41 ff ff ff       	call   800b74 <read>
		if (m < 0)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	78 10                	js     800c47 <readn+0x43>
			return m;
		if (m == 0)
  800c37:	85 c0                	test   %eax,%eax
  800c39:	74 0a                	je     800c45 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800c3b:	01 c3                	add    %eax,%ebx
  800c3d:	39 f3                	cmp    %esi,%ebx
  800c3f:	72 d9                	jb     800c1a <readn+0x16>
  800c41:	89 d8                	mov    %ebx,%eax
  800c43:	eb 02                	jmp    800c47 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800c45:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800c47:	83 c4 1c             	add    $0x1c,%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    

00800c4f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	53                   	push   %ebx
  800c53:	83 ec 24             	sub    $0x24,%esp
  800c56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c59:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c60:	89 1c 24             	mov    %ebx,(%esp)
  800c63:	e8 6e fc ff ff       	call   8008d6 <fd_lookup>
  800c68:	85 c0                	test   %eax,%eax
  800c6a:	78 68                	js     800cd4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c76:	8b 00                	mov    (%eax),%eax
  800c78:	89 04 24             	mov    %eax,(%esp)
  800c7b:	e8 ac fc ff ff       	call   80092c <dev_lookup>
  800c80:	85 c0                	test   %eax,%eax
  800c82:	78 50                	js     800cd4 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c84:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c87:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c8b:	75 23                	jne    800cb0 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800c8d:	a1 08 40 80 00       	mov    0x804008,%eax
  800c92:	8b 40 48             	mov    0x48(%eax),%eax
  800c95:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c9d:	c7 04 24 d9 25 80 00 	movl   $0x8025d9,(%esp)
  800ca4:	e8 4b 0f 00 00       	call   801bf4 <cprintf>
		return -E_INVAL;
  800ca9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800cae:	eb 24                	jmp    800cd4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800cb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cb3:	8b 52 0c             	mov    0xc(%edx),%edx
  800cb6:	85 d2                	test   %edx,%edx
  800cb8:	74 15                	je     800ccf <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800cba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800cbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800cc8:	89 04 24             	mov    %eax,(%esp)
  800ccb:	ff d2                	call   *%edx
  800ccd:	eb 05                	jmp    800cd4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800ccf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800cd4:	83 c4 24             	add    $0x24,%esp
  800cd7:	5b                   	pop    %ebx
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <seek>:

int
seek(int fdnum, off_t offset)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ce0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800ce3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cea:	89 04 24             	mov    %eax,(%esp)
  800ced:	e8 e4 fb ff ff       	call   8008d6 <fd_lookup>
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	78 0e                	js     800d04 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800cf6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cf9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cfc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800cff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d04:	c9                   	leave  
  800d05:	c3                   	ret    

00800d06 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	53                   	push   %ebx
  800d0a:	83 ec 24             	sub    $0x24,%esp
  800d0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d10:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d17:	89 1c 24             	mov    %ebx,(%esp)
  800d1a:	e8 b7 fb ff ff       	call   8008d6 <fd_lookup>
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	78 61                	js     800d84 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800d23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d2d:	8b 00                	mov    (%eax),%eax
  800d2f:	89 04 24             	mov    %eax,(%esp)
  800d32:	e8 f5 fb ff ff       	call   80092c <dev_lookup>
  800d37:	85 c0                	test   %eax,%eax
  800d39:	78 49                	js     800d84 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800d3e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800d42:	75 23                	jne    800d67 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800d44:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800d49:	8b 40 48             	mov    0x48(%eax),%eax
  800d4c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d50:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d54:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  800d5b:	e8 94 0e 00 00       	call   801bf4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800d60:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d65:	eb 1d                	jmp    800d84 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800d67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d6a:	8b 52 18             	mov    0x18(%edx),%edx
  800d6d:	85 d2                	test   %edx,%edx
  800d6f:	74 0e                	je     800d7f <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d78:	89 04 24             	mov    %eax,(%esp)
  800d7b:	ff d2                	call   *%edx
  800d7d:	eb 05                	jmp    800d84 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800d7f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800d84:	83 c4 24             	add    $0x24,%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	53                   	push   %ebx
  800d8e:	83 ec 24             	sub    $0x24,%esp
  800d91:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800d94:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	89 04 24             	mov    %eax,(%esp)
  800da1:	e8 30 fb ff ff       	call   8008d6 <fd_lookup>
  800da6:	85 c0                	test   %eax,%eax
  800da8:	78 52                	js     800dfc <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800daa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dad:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800db4:	8b 00                	mov    (%eax),%eax
  800db6:	89 04 24             	mov    %eax,(%esp)
  800db9:	e8 6e fb ff ff       	call   80092c <dev_lookup>
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	78 3a                	js     800dfc <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  800dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dc5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800dc9:	74 2c                	je     800df7 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800dcb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800dce:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800dd5:	00 00 00 
	stat->st_isdir = 0;
  800dd8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800ddf:	00 00 00 
	stat->st_dev = dev;
  800de2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800de8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800dec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800def:	89 14 24             	mov    %edx,(%esp)
  800df2:	ff 50 14             	call   *0x14(%eax)
  800df5:	eb 05                	jmp    800dfc <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800df7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800dfc:	83 c4 24             	add    $0x24,%esp
  800dff:	5b                   	pop    %ebx
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
  800e07:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800e0a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e11:	00 
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
  800e15:	89 04 24             	mov    %eax,(%esp)
  800e18:	e8 2a 02 00 00       	call   801047 <open>
  800e1d:	89 c3                	mov    %eax,%ebx
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	78 1b                	js     800e3e <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800e23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e2a:	89 1c 24             	mov    %ebx,(%esp)
  800e2d:	e8 58 ff ff ff       	call   800d8a <fstat>
  800e32:	89 c6                	mov    %eax,%esi
	close(fd);
  800e34:	89 1c 24             	mov    %ebx,(%esp)
  800e37:	e8 d2 fb ff ff       	call   800a0e <close>
	return r;
  800e3c:	89 f3                	mov    %esi,%ebx
}
  800e3e:	89 d8                	mov    %ebx,%eax
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    
	...

00800e48 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 10             	sub    $0x10,%esp
  800e50:	89 c3                	mov    %eax,%ebx
  800e52:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800e54:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800e5b:	75 11                	jne    800e6e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800e5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800e64:	e8 f6 13 00 00       	call   80225f <ipc_find_env>
  800e69:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800e6e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800e75:	00 
  800e76:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800e7d:	00 
  800e7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e82:	a1 00 40 80 00       	mov    0x804000,%eax
  800e87:	89 04 24             	mov    %eax,(%esp)
  800e8a:	e8 4d 13 00 00       	call   8021dc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800e8f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e96:	00 
  800e97:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ea2:	e8 c5 12 00 00       	call   80216c <ipc_recv>
}
  800ea7:	83 c4 10             	add    $0x10,%esp
  800eaa:	5b                   	pop    %ebx
  800eab:	5e                   	pop    %esi
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    

00800eae <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb7:	8b 40 0c             	mov    0xc(%eax),%eax
  800eba:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800ec7:	ba 00 00 00 00       	mov    $0x0,%edx
  800ecc:	b8 02 00 00 00       	mov    $0x2,%eax
  800ed1:	e8 72 ff ff ff       	call   800e48 <fsipc>
}
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    

00800ed8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ede:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee1:	8b 40 0c             	mov    0xc(%eax),%eax
  800ee4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ee9:	ba 00 00 00 00       	mov    $0x0,%edx
  800eee:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef3:	e8 50 ff ff ff       	call   800e48 <fsipc>
}
  800ef8:	c9                   	leave  
  800ef9:	c3                   	ret    

00800efa <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	53                   	push   %ebx
  800efe:	83 ec 14             	sub    $0x14,%esp
  800f01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800f04:	8b 45 08             	mov    0x8(%ebp),%eax
  800f07:	8b 40 0c             	mov    0xc(%eax),%eax
  800f0a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800f0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f14:	b8 05 00 00 00       	mov    $0x5,%eax
  800f19:	e8 2a ff ff ff       	call   800e48 <fsipc>
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	78 2b                	js     800f4d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800f22:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800f29:	00 
  800f2a:	89 1c 24             	mov    %ebx,(%esp)
  800f2d:	e8 69 f2 ff ff       	call   80019b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800f32:	a1 80 50 80 00       	mov    0x805080,%eax
  800f37:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800f3d:	a1 84 50 80 00       	mov    0x805084,%eax
  800f42:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800f48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f4d:	83 c4 14             	add    $0x14,%esp
  800f50:	5b                   	pop    %ebx
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    

00800f53 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	83 ec 18             	sub    $0x18,%esp
  800f59:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800f5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f5f:	8b 52 0c             	mov    0xc(%edx),%edx
  800f62:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800f68:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  800f6d:	89 c2                	mov    %eax,%edx
  800f6f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800f74:	76 05                	jbe    800f7b <devfile_write+0x28>
  800f76:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  800f7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f82:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f86:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800f8d:	e8 ec f3 ff ff       	call   80037e <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800f92:	ba 00 00 00 00       	mov    $0x0,%edx
  800f97:	b8 04 00 00 00       	mov    $0x4,%eax
  800f9c:	e8 a7 fe ff ff       	call   800e48 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    

00800fa3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	56                   	push   %esi
  800fa7:	53                   	push   %ebx
  800fa8:	83 ec 10             	sub    $0x10,%esp
  800fab:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800fae:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb1:	8b 40 0c             	mov    0xc(%eax),%eax
  800fb4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800fb9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800fbf:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc4:	b8 03 00 00 00       	mov    $0x3,%eax
  800fc9:	e8 7a fe ff ff       	call   800e48 <fsipc>
  800fce:	89 c3                	mov    %eax,%ebx
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 6a                	js     80103e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800fd4:	39 c6                	cmp    %eax,%esi
  800fd6:	73 24                	jae    800ffc <devfile_read+0x59>
  800fd8:	c7 44 24 0c 0c 26 80 	movl   $0x80260c,0xc(%esp)
  800fdf:	00 
  800fe0:	c7 44 24 08 13 26 80 	movl   $0x802613,0x8(%esp)
  800fe7:	00 
  800fe8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800fef:	00 
  800ff0:	c7 04 24 28 26 80 00 	movl   $0x802628,(%esp)
  800ff7:	e8 00 0b 00 00       	call   801afc <_panic>
	assert(r <= PGSIZE);
  800ffc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801001:	7e 24                	jle    801027 <devfile_read+0x84>
  801003:	c7 44 24 0c 33 26 80 	movl   $0x802633,0xc(%esp)
  80100a:	00 
  80100b:	c7 44 24 08 13 26 80 	movl   $0x802613,0x8(%esp)
  801012:	00 
  801013:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80101a:	00 
  80101b:	c7 04 24 28 26 80 00 	movl   $0x802628,(%esp)
  801022:	e8 d5 0a 00 00       	call   801afc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801027:	89 44 24 08          	mov    %eax,0x8(%esp)
  80102b:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801032:	00 
  801033:	8b 45 0c             	mov    0xc(%ebp),%eax
  801036:	89 04 24             	mov    %eax,(%esp)
  801039:	e8 d6 f2 ff ff       	call   800314 <memmove>
	return r;
}
  80103e:	89 d8                	mov    %ebx,%eax
  801040:	83 c4 10             	add    $0x10,%esp
  801043:	5b                   	pop    %ebx
  801044:	5e                   	pop    %esi
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    

00801047 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	56                   	push   %esi
  80104b:	53                   	push   %ebx
  80104c:	83 ec 20             	sub    $0x20,%esp
  80104f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801052:	89 34 24             	mov    %esi,(%esp)
  801055:	e8 0e f1 ff ff       	call   800168 <strlen>
  80105a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80105f:	7f 60                	jg     8010c1 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801061:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801064:	89 04 24             	mov    %eax,(%esp)
  801067:	e8 17 f8 ff ff       	call   800883 <fd_alloc>
  80106c:	89 c3                	mov    %eax,%ebx
  80106e:	85 c0                	test   %eax,%eax
  801070:	78 54                	js     8010c6 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801072:	89 74 24 04          	mov    %esi,0x4(%esp)
  801076:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80107d:	e8 19 f1 ff ff       	call   80019b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801082:	8b 45 0c             	mov    0xc(%ebp),%eax
  801085:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80108a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80108d:	b8 01 00 00 00       	mov    $0x1,%eax
  801092:	e8 b1 fd ff ff       	call   800e48 <fsipc>
  801097:	89 c3                	mov    %eax,%ebx
  801099:	85 c0                	test   %eax,%eax
  80109b:	79 15                	jns    8010b2 <open+0x6b>
		fd_close(fd, 0);
  80109d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010a4:	00 
  8010a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010a8:	89 04 24             	mov    %eax,(%esp)
  8010ab:	e8 d6 f8 ff ff       	call   800986 <fd_close>
		return r;
  8010b0:	eb 14                	jmp    8010c6 <open+0x7f>
	}

	return fd2num(fd);
  8010b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010b5:	89 04 24             	mov    %eax,(%esp)
  8010b8:	e8 9b f7 ff ff       	call   800858 <fd2num>
  8010bd:	89 c3                	mov    %eax,%ebx
  8010bf:	eb 05                	jmp    8010c6 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8010c1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8010c6:	89 d8                	mov    %ebx,%eax
  8010c8:	83 c4 20             	add    $0x20,%esp
  8010cb:	5b                   	pop    %ebx
  8010cc:	5e                   	pop    %esi
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8010d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8010da:	b8 08 00 00 00       	mov    $0x8,%eax
  8010df:	e8 64 fd ff ff       	call   800e48 <fsipc>
}
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    
	...

008010e8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8010ee:	c7 44 24 04 3f 26 80 	movl   $0x80263f,0x4(%esp)
  8010f5:	00 
  8010f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f9:	89 04 24             	mov    %eax,(%esp)
  8010fc:	e8 9a f0 ff ff       	call   80019b <strcpy>
	return 0;
}
  801101:	b8 00 00 00 00       	mov    $0x0,%eax
  801106:	c9                   	leave  
  801107:	c3                   	ret    

00801108 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	53                   	push   %ebx
  80110c:	83 ec 14             	sub    $0x14,%esp
  80110f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801112:	89 1c 24             	mov    %ebx,(%esp)
  801115:	e8 8a 11 00 00       	call   8022a4 <pageref>
  80111a:	83 f8 01             	cmp    $0x1,%eax
  80111d:	75 0d                	jne    80112c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  80111f:	8b 43 0c             	mov    0xc(%ebx),%eax
  801122:	89 04 24             	mov    %eax,(%esp)
  801125:	e8 1f 03 00 00       	call   801449 <nsipc_close>
  80112a:	eb 05                	jmp    801131 <devsock_close+0x29>
	else
		return 0;
  80112c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801131:	83 c4 14             	add    $0x14,%esp
  801134:	5b                   	pop    %ebx
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    

00801137 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80113d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801144:	00 
  801145:	8b 45 10             	mov    0x10(%ebp),%eax
  801148:	89 44 24 08          	mov    %eax,0x8(%esp)
  80114c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80114f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801153:	8b 45 08             	mov    0x8(%ebp),%eax
  801156:	8b 40 0c             	mov    0xc(%eax),%eax
  801159:	89 04 24             	mov    %eax,(%esp)
  80115c:	e8 e3 03 00 00       	call   801544 <nsipc_send>
}
  801161:	c9                   	leave  
  801162:	c3                   	ret    

00801163 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801169:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801170:	00 
  801171:	8b 45 10             	mov    0x10(%ebp),%eax
  801174:	89 44 24 08          	mov    %eax,0x8(%esp)
  801178:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117f:	8b 45 08             	mov    0x8(%ebp),%eax
  801182:	8b 40 0c             	mov    0xc(%eax),%eax
  801185:	89 04 24             	mov    %eax,(%esp)
  801188:	e8 37 03 00 00       	call   8014c4 <nsipc_recv>
}
  80118d:	c9                   	leave  
  80118e:	c3                   	ret    

0080118f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	56                   	push   %esi
  801193:	53                   	push   %ebx
  801194:	83 ec 20             	sub    $0x20,%esp
  801197:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801199:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80119c:	89 04 24             	mov    %eax,(%esp)
  80119f:	e8 df f6 ff ff       	call   800883 <fd_alloc>
  8011a4:	89 c3                	mov    %eax,%ebx
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	78 21                	js     8011cb <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8011aa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8011b1:	00 
  8011b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011c0:	e8 c8 f3 ff ff       	call   80058d <sys_page_alloc>
  8011c5:	89 c3                	mov    %eax,%ebx
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	79 0a                	jns    8011d5 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  8011cb:	89 34 24             	mov    %esi,(%esp)
  8011ce:	e8 76 02 00 00       	call   801449 <nsipc_close>
		return r;
  8011d3:	eb 22                	jmp    8011f7 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8011d5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8011db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011de:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8011e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8011ea:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8011ed:	89 04 24             	mov    %eax,(%esp)
  8011f0:	e8 63 f6 ff ff       	call   800858 <fd2num>
  8011f5:	89 c3                	mov    %eax,%ebx
}
  8011f7:	89 d8                	mov    %ebx,%eax
  8011f9:	83 c4 20             	add    $0x20,%esp
  8011fc:	5b                   	pop    %ebx
  8011fd:	5e                   	pop    %esi
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801206:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801209:	89 54 24 04          	mov    %edx,0x4(%esp)
  80120d:	89 04 24             	mov    %eax,(%esp)
  801210:	e8 c1 f6 ff ff       	call   8008d6 <fd_lookup>
  801215:	85 c0                	test   %eax,%eax
  801217:	78 17                	js     801230 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801219:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80121c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801222:	39 10                	cmp    %edx,(%eax)
  801224:	75 05                	jne    80122b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801226:	8b 40 0c             	mov    0xc(%eax),%eax
  801229:	eb 05                	jmp    801230 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80122b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801230:	c9                   	leave  
  801231:	c3                   	ret    

00801232 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801238:	8b 45 08             	mov    0x8(%ebp),%eax
  80123b:	e8 c0 ff ff ff       	call   801200 <fd2sockid>
  801240:	85 c0                	test   %eax,%eax
  801242:	78 1f                	js     801263 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801244:	8b 55 10             	mov    0x10(%ebp),%edx
  801247:	89 54 24 08          	mov    %edx,0x8(%esp)
  80124b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801252:	89 04 24             	mov    %eax,(%esp)
  801255:	e8 38 01 00 00       	call   801392 <nsipc_accept>
  80125a:	85 c0                	test   %eax,%eax
  80125c:	78 05                	js     801263 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80125e:	e8 2c ff ff ff       	call   80118f <alloc_sockfd>
}
  801263:	c9                   	leave  
  801264:	c3                   	ret    

00801265 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80126b:	8b 45 08             	mov    0x8(%ebp),%eax
  80126e:	e8 8d ff ff ff       	call   801200 <fd2sockid>
  801273:	85 c0                	test   %eax,%eax
  801275:	78 16                	js     80128d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801277:	8b 55 10             	mov    0x10(%ebp),%edx
  80127a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80127e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801281:	89 54 24 04          	mov    %edx,0x4(%esp)
  801285:	89 04 24             	mov    %eax,(%esp)
  801288:	e8 5b 01 00 00       	call   8013e8 <nsipc_bind>
}
  80128d:	c9                   	leave  
  80128e:	c3                   	ret    

0080128f <shutdown>:

int
shutdown(int s, int how)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801295:	8b 45 08             	mov    0x8(%ebp),%eax
  801298:	e8 63 ff ff ff       	call   801200 <fd2sockid>
  80129d:	85 c0                	test   %eax,%eax
  80129f:	78 0f                	js     8012b0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8012a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012a8:	89 04 24             	mov    %eax,(%esp)
  8012ab:	e8 77 01 00 00       	call   801427 <nsipc_shutdown>
}
  8012b0:	c9                   	leave  
  8012b1:	c3                   	ret    

008012b2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8012b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bb:	e8 40 ff ff ff       	call   801200 <fd2sockid>
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 16                	js     8012da <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8012c4:	8b 55 10             	mov    0x10(%ebp),%edx
  8012c7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8012cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012d2:	89 04 24             	mov    %eax,(%esp)
  8012d5:	e8 89 01 00 00       	call   801463 <nsipc_connect>
}
  8012da:	c9                   	leave  
  8012db:	c3                   	ret    

008012dc <listen>:

int
listen(int s, int backlog)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8012e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e5:	e8 16 ff ff ff       	call   801200 <fd2sockid>
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 0f                	js     8012fd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8012ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012f5:	89 04 24             	mov    %eax,(%esp)
  8012f8:	e8 a5 01 00 00       	call   8014a2 <nsipc_listen>
}
  8012fd:	c9                   	leave  
  8012fe:	c3                   	ret    

008012ff <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801305:	8b 45 10             	mov    0x10(%ebp),%eax
  801308:	89 44 24 08          	mov    %eax,0x8(%esp)
  80130c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801313:	8b 45 08             	mov    0x8(%ebp),%eax
  801316:	89 04 24             	mov    %eax,(%esp)
  801319:	e8 99 02 00 00       	call   8015b7 <nsipc_socket>
  80131e:	85 c0                	test   %eax,%eax
  801320:	78 05                	js     801327 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801322:	e8 68 fe ff ff       	call   80118f <alloc_sockfd>
}
  801327:	c9                   	leave  
  801328:	c3                   	ret    
  801329:	00 00                	add    %al,(%eax)
	...

0080132c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80132c:	55                   	push   %ebp
  80132d:	89 e5                	mov    %esp,%ebp
  80132f:	53                   	push   %ebx
  801330:	83 ec 14             	sub    $0x14,%esp
  801333:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801335:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80133c:	75 11                	jne    80134f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80133e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801345:	e8 15 0f 00 00       	call   80225f <ipc_find_env>
  80134a:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80134f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801356:	00 
  801357:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80135e:	00 
  80135f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801363:	a1 04 40 80 00       	mov    0x804004,%eax
  801368:	89 04 24             	mov    %eax,(%esp)
  80136b:	e8 6c 0e 00 00       	call   8021dc <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801370:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801377:	00 
  801378:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80137f:	00 
  801380:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801387:	e8 e0 0d 00 00       	call   80216c <ipc_recv>
}
  80138c:	83 c4 14             	add    $0x14,%esp
  80138f:	5b                   	pop    %ebx
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	56                   	push   %esi
  801396:	53                   	push   %ebx
  801397:	83 ec 10             	sub    $0x10,%esp
  80139a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80139d:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8013a5:	8b 06                	mov    (%esi),%eax
  8013a7:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8013ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8013b1:	e8 76 ff ff ff       	call   80132c <nsipc>
  8013b6:	89 c3                	mov    %eax,%ebx
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 23                	js     8013df <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8013bc:	a1 10 60 80 00       	mov    0x806010,%eax
  8013c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013c5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8013cc:	00 
  8013cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d0:	89 04 24             	mov    %eax,(%esp)
  8013d3:	e8 3c ef ff ff       	call   800314 <memmove>
		*addrlen = ret->ret_addrlen;
  8013d8:	a1 10 60 80 00       	mov    0x806010,%eax
  8013dd:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8013df:	89 d8                	mov    %ebx,%eax
  8013e1:	83 c4 10             	add    $0x10,%esp
  8013e4:	5b                   	pop    %ebx
  8013e5:	5e                   	pop    %esi
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    

008013e8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	53                   	push   %ebx
  8013ec:	83 ec 14             	sub    $0x14,%esp
  8013ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8013f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8013fa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801401:	89 44 24 04          	mov    %eax,0x4(%esp)
  801405:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  80140c:	e8 03 ef ff ff       	call   800314 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801411:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801417:	b8 02 00 00 00       	mov    $0x2,%eax
  80141c:	e8 0b ff ff ff       	call   80132c <nsipc>
}
  801421:	83 c4 14             	add    $0x14,%esp
  801424:	5b                   	pop    %ebx
  801425:	5d                   	pop    %ebp
  801426:	c3                   	ret    

00801427 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80142d:	8b 45 08             	mov    0x8(%ebp),%eax
  801430:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801435:	8b 45 0c             	mov    0xc(%ebp),%eax
  801438:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80143d:	b8 03 00 00 00       	mov    $0x3,%eax
  801442:	e8 e5 fe ff ff       	call   80132c <nsipc>
}
  801447:	c9                   	leave  
  801448:	c3                   	ret    

00801449 <nsipc_close>:

int
nsipc_close(int s)
{
  801449:	55                   	push   %ebp
  80144a:	89 e5                	mov    %esp,%ebp
  80144c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80144f:	8b 45 08             	mov    0x8(%ebp),%eax
  801452:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801457:	b8 04 00 00 00       	mov    $0x4,%eax
  80145c:	e8 cb fe ff ff       	call   80132c <nsipc>
}
  801461:	c9                   	leave  
  801462:	c3                   	ret    

00801463 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	53                   	push   %ebx
  801467:	83 ec 14             	sub    $0x14,%esp
  80146a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80146d:	8b 45 08             	mov    0x8(%ebp),%eax
  801470:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801475:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801479:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801480:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801487:	e8 88 ee ff ff       	call   800314 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80148c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801492:	b8 05 00 00 00       	mov    $0x5,%eax
  801497:	e8 90 fe ff ff       	call   80132c <nsipc>
}
  80149c:	83 c4 14             	add    $0x14,%esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5d                   	pop    %ebp
  8014a1:	c3                   	ret    

008014a2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8014a2:	55                   	push   %ebp
  8014a3:	89 e5                	mov    %esp,%ebp
  8014a5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8014a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ab:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8014b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b3:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8014b8:	b8 06 00 00 00       	mov    $0x6,%eax
  8014bd:	e8 6a fe ff ff       	call   80132c <nsipc>
}
  8014c2:	c9                   	leave  
  8014c3:	c3                   	ret    

008014c4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8014c4:	55                   	push   %ebp
  8014c5:	89 e5                	mov    %esp,%ebp
  8014c7:	56                   	push   %esi
  8014c8:	53                   	push   %ebx
  8014c9:	83 ec 10             	sub    $0x10,%esp
  8014cc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8014cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8014d7:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8014dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e0:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8014e5:	b8 07 00 00 00       	mov    $0x7,%eax
  8014ea:	e8 3d fe ff ff       	call   80132c <nsipc>
  8014ef:	89 c3                	mov    %eax,%ebx
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	78 46                	js     80153b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8014f5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8014fa:	7f 04                	jg     801500 <nsipc_recv+0x3c>
  8014fc:	39 c6                	cmp    %eax,%esi
  8014fe:	7d 24                	jge    801524 <nsipc_recv+0x60>
  801500:	c7 44 24 0c 4b 26 80 	movl   $0x80264b,0xc(%esp)
  801507:	00 
  801508:	c7 44 24 08 13 26 80 	movl   $0x802613,0x8(%esp)
  80150f:	00 
  801510:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801517:	00 
  801518:	c7 04 24 60 26 80 00 	movl   $0x802660,(%esp)
  80151f:	e8 d8 05 00 00       	call   801afc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801524:	89 44 24 08          	mov    %eax,0x8(%esp)
  801528:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80152f:	00 
  801530:	8b 45 0c             	mov    0xc(%ebp),%eax
  801533:	89 04 24             	mov    %eax,(%esp)
  801536:	e8 d9 ed ff ff       	call   800314 <memmove>
	}

	return r;
}
  80153b:	89 d8                	mov    %ebx,%eax
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	5b                   	pop    %ebx
  801541:	5e                   	pop    %esi
  801542:	5d                   	pop    %ebp
  801543:	c3                   	ret    

00801544 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	53                   	push   %ebx
  801548:	83 ec 14             	sub    $0x14,%esp
  80154b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80154e:	8b 45 08             	mov    0x8(%ebp),%eax
  801551:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801556:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80155c:	7e 24                	jle    801582 <nsipc_send+0x3e>
  80155e:	c7 44 24 0c 6c 26 80 	movl   $0x80266c,0xc(%esp)
  801565:	00 
  801566:	c7 44 24 08 13 26 80 	movl   $0x802613,0x8(%esp)
  80156d:	00 
  80156e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801575:	00 
  801576:	c7 04 24 60 26 80 00 	movl   $0x802660,(%esp)
  80157d:	e8 7a 05 00 00       	call   801afc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801582:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801586:	8b 45 0c             	mov    0xc(%ebp),%eax
  801589:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158d:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801594:	e8 7b ed ff ff       	call   800314 <memmove>
	nsipcbuf.send.req_size = size;
  801599:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80159f:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8015a7:	b8 08 00 00 00       	mov    $0x8,%eax
  8015ac:	e8 7b fd ff ff       	call   80132c <nsipc>
}
  8015b1:	83 c4 14             	add    $0x14,%esp
  8015b4:	5b                   	pop    %ebx
  8015b5:	5d                   	pop    %ebp
  8015b6:	c3                   	ret    

008015b7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8015bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8015c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c8:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8015cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8015d0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8015d5:	b8 09 00 00 00       	mov    $0x9,%eax
  8015da:	e8 4d fd ff ff       	call   80132c <nsipc>
}
  8015df:	c9                   	leave  
  8015e0:	c3                   	ret    
  8015e1:	00 00                	add    %al,(%eax)
	...

008015e4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	56                   	push   %esi
  8015e8:	53                   	push   %ebx
  8015e9:	83 ec 10             	sub    $0x10,%esp
  8015ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f2:	89 04 24             	mov    %eax,(%esp)
  8015f5:	e8 6e f2 ff ff       	call   800868 <fd2data>
  8015fa:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8015fc:	c7 44 24 04 78 26 80 	movl   $0x802678,0x4(%esp)
  801603:	00 
  801604:	89 34 24             	mov    %esi,(%esp)
  801607:	e8 8f eb ff ff       	call   80019b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80160c:	8b 43 04             	mov    0x4(%ebx),%eax
  80160f:	2b 03                	sub    (%ebx),%eax
  801611:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801617:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80161e:	00 00 00 
	stat->st_dev = &devpipe;
  801621:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801628:	30 80 00 
	return 0;
}
  80162b:	b8 00 00 00 00       	mov    $0x0,%eax
  801630:	83 c4 10             	add    $0x10,%esp
  801633:	5b                   	pop    %ebx
  801634:	5e                   	pop    %esi
  801635:	5d                   	pop    %ebp
  801636:	c3                   	ret    

00801637 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	53                   	push   %ebx
  80163b:	83 ec 14             	sub    $0x14,%esp
  80163e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801641:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801645:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164c:	e8 e3 ef ff ff       	call   800634 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801651:	89 1c 24             	mov    %ebx,(%esp)
  801654:	e8 0f f2 ff ff       	call   800868 <fd2data>
  801659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801664:	e8 cb ef ff ff       	call   800634 <sys_page_unmap>
}
  801669:	83 c4 14             	add    $0x14,%esp
  80166c:	5b                   	pop    %ebx
  80166d:	5d                   	pop    %ebp
  80166e:	c3                   	ret    

0080166f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	57                   	push   %edi
  801673:	56                   	push   %esi
  801674:	53                   	push   %ebx
  801675:	83 ec 2c             	sub    $0x2c,%esp
  801678:	89 c7                	mov    %eax,%edi
  80167a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80167d:	a1 08 40 80 00       	mov    0x804008,%eax
  801682:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801685:	89 3c 24             	mov    %edi,(%esp)
  801688:	e8 17 0c 00 00       	call   8022a4 <pageref>
  80168d:	89 c6                	mov    %eax,%esi
  80168f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801692:	89 04 24             	mov    %eax,(%esp)
  801695:	e8 0a 0c 00 00       	call   8022a4 <pageref>
  80169a:	39 c6                	cmp    %eax,%esi
  80169c:	0f 94 c0             	sete   %al
  80169f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8016a2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8016a8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016ab:	39 cb                	cmp    %ecx,%ebx
  8016ad:	75 08                	jne    8016b7 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8016af:	83 c4 2c             	add    $0x2c,%esp
  8016b2:	5b                   	pop    %ebx
  8016b3:	5e                   	pop    %esi
  8016b4:	5f                   	pop    %edi
  8016b5:	5d                   	pop    %ebp
  8016b6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8016b7:	83 f8 01             	cmp    $0x1,%eax
  8016ba:	75 c1                	jne    80167d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016bc:	8b 42 58             	mov    0x58(%edx),%eax
  8016bf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8016c6:	00 
  8016c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016cf:	c7 04 24 7f 26 80 00 	movl   $0x80267f,(%esp)
  8016d6:	e8 19 05 00 00       	call   801bf4 <cprintf>
  8016db:	eb a0                	jmp    80167d <_pipeisclosed+0xe>

008016dd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	57                   	push   %edi
  8016e1:	56                   	push   %esi
  8016e2:	53                   	push   %ebx
  8016e3:	83 ec 1c             	sub    $0x1c,%esp
  8016e6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016e9:	89 34 24             	mov    %esi,(%esp)
  8016ec:	e8 77 f1 ff ff       	call   800868 <fd2data>
  8016f1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016f3:	bf 00 00 00 00       	mov    $0x0,%edi
  8016f8:	eb 3c                	jmp    801736 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016fa:	89 da                	mov    %ebx,%edx
  8016fc:	89 f0                	mov    %esi,%eax
  8016fe:	e8 6c ff ff ff       	call   80166f <_pipeisclosed>
  801703:	85 c0                	test   %eax,%eax
  801705:	75 38                	jne    80173f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801707:	e8 62 ee ff ff       	call   80056e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80170c:	8b 43 04             	mov    0x4(%ebx),%eax
  80170f:	8b 13                	mov    (%ebx),%edx
  801711:	83 c2 20             	add    $0x20,%edx
  801714:	39 d0                	cmp    %edx,%eax
  801716:	73 e2                	jae    8016fa <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801718:	8b 55 0c             	mov    0xc(%ebp),%edx
  80171b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80171e:	89 c2                	mov    %eax,%edx
  801720:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801726:	79 05                	jns    80172d <devpipe_write+0x50>
  801728:	4a                   	dec    %edx
  801729:	83 ca e0             	or     $0xffffffe0,%edx
  80172c:	42                   	inc    %edx
  80172d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801731:	40                   	inc    %eax
  801732:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801735:	47                   	inc    %edi
  801736:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801739:	75 d1                	jne    80170c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80173b:	89 f8                	mov    %edi,%eax
  80173d:	eb 05                	jmp    801744 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80173f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801744:	83 c4 1c             	add    $0x1c,%esp
  801747:	5b                   	pop    %ebx
  801748:	5e                   	pop    %esi
  801749:	5f                   	pop    %edi
  80174a:	5d                   	pop    %ebp
  80174b:	c3                   	ret    

0080174c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	57                   	push   %edi
  801750:	56                   	push   %esi
  801751:	53                   	push   %ebx
  801752:	83 ec 1c             	sub    $0x1c,%esp
  801755:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801758:	89 3c 24             	mov    %edi,(%esp)
  80175b:	e8 08 f1 ff ff       	call   800868 <fd2data>
  801760:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801762:	be 00 00 00 00       	mov    $0x0,%esi
  801767:	eb 3a                	jmp    8017a3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801769:	85 f6                	test   %esi,%esi
  80176b:	74 04                	je     801771 <devpipe_read+0x25>
				return i;
  80176d:	89 f0                	mov    %esi,%eax
  80176f:	eb 40                	jmp    8017b1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801771:	89 da                	mov    %ebx,%edx
  801773:	89 f8                	mov    %edi,%eax
  801775:	e8 f5 fe ff ff       	call   80166f <_pipeisclosed>
  80177a:	85 c0                	test   %eax,%eax
  80177c:	75 2e                	jne    8017ac <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80177e:	e8 eb ed ff ff       	call   80056e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801783:	8b 03                	mov    (%ebx),%eax
  801785:	3b 43 04             	cmp    0x4(%ebx),%eax
  801788:	74 df                	je     801769 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80178a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80178f:	79 05                	jns    801796 <devpipe_read+0x4a>
  801791:	48                   	dec    %eax
  801792:	83 c8 e0             	or     $0xffffffe0,%eax
  801795:	40                   	inc    %eax
  801796:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80179a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80179d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8017a0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017a2:	46                   	inc    %esi
  8017a3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017a6:	75 db                	jne    801783 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017a8:	89 f0                	mov    %esi,%eax
  8017aa:	eb 05                	jmp    8017b1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017ac:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017b1:	83 c4 1c             	add    $0x1c,%esp
  8017b4:	5b                   	pop    %ebx
  8017b5:	5e                   	pop    %esi
  8017b6:	5f                   	pop    %edi
  8017b7:	5d                   	pop    %ebp
  8017b8:	c3                   	ret    

008017b9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017b9:	55                   	push   %ebp
  8017ba:	89 e5                	mov    %esp,%ebp
  8017bc:	57                   	push   %edi
  8017bd:	56                   	push   %esi
  8017be:	53                   	push   %ebx
  8017bf:	83 ec 3c             	sub    $0x3c,%esp
  8017c2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017c5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017c8:	89 04 24             	mov    %eax,(%esp)
  8017cb:	e8 b3 f0 ff ff       	call   800883 <fd_alloc>
  8017d0:	89 c3                	mov    %eax,%ebx
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	0f 88 45 01 00 00    	js     80191f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017da:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8017e1:	00 
  8017e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f0:	e8 98 ed ff ff       	call   80058d <sys_page_alloc>
  8017f5:	89 c3                	mov    %eax,%ebx
  8017f7:	85 c0                	test   %eax,%eax
  8017f9:	0f 88 20 01 00 00    	js     80191f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801802:	89 04 24             	mov    %eax,(%esp)
  801805:	e8 79 f0 ff ff       	call   800883 <fd_alloc>
  80180a:	89 c3                	mov    %eax,%ebx
  80180c:	85 c0                	test   %eax,%eax
  80180e:	0f 88 f8 00 00 00    	js     80190c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801814:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80181b:	00 
  80181c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80181f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801823:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80182a:	e8 5e ed ff ff       	call   80058d <sys_page_alloc>
  80182f:	89 c3                	mov    %eax,%ebx
  801831:	85 c0                	test   %eax,%eax
  801833:	0f 88 d3 00 00 00    	js     80190c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801839:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80183c:	89 04 24             	mov    %eax,(%esp)
  80183f:	e8 24 f0 ff ff       	call   800868 <fd2data>
  801844:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801846:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80184d:	00 
  80184e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801852:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801859:	e8 2f ed ff ff       	call   80058d <sys_page_alloc>
  80185e:	89 c3                	mov    %eax,%ebx
  801860:	85 c0                	test   %eax,%eax
  801862:	0f 88 91 00 00 00    	js     8018f9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801868:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80186b:	89 04 24             	mov    %eax,(%esp)
  80186e:	e8 f5 ef ff ff       	call   800868 <fd2data>
  801873:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80187a:	00 
  80187b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80187f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801886:	00 
  801887:	89 74 24 04          	mov    %esi,0x4(%esp)
  80188b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801892:	e8 4a ed ff ff       	call   8005e1 <sys_page_map>
  801897:	89 c3                	mov    %eax,%ebx
  801899:	85 c0                	test   %eax,%eax
  80189b:	78 4c                	js     8018e9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80189d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8018a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018a6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018ab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018b2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8018b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018bb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018c0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018ca:	89 04 24             	mov    %eax,(%esp)
  8018cd:	e8 86 ef ff ff       	call   800858 <fd2num>
  8018d2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8018d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018d7:	89 04 24             	mov    %eax,(%esp)
  8018da:	e8 79 ef ff ff       	call   800858 <fd2num>
  8018df:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8018e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018e7:	eb 36                	jmp    80191f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8018e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018f4:	e8 3b ed ff ff       	call   800634 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8018f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801900:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801907:	e8 28 ed ff ff       	call   800634 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80190c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80190f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801913:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80191a:	e8 15 ed ff ff       	call   800634 <sys_page_unmap>
    err:
	return r;
}
  80191f:	89 d8                	mov    %ebx,%eax
  801921:	83 c4 3c             	add    $0x3c,%esp
  801924:	5b                   	pop    %ebx
  801925:	5e                   	pop    %esi
  801926:	5f                   	pop    %edi
  801927:	5d                   	pop    %ebp
  801928:	c3                   	ret    

00801929 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80192f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801932:	89 44 24 04          	mov    %eax,0x4(%esp)
  801936:	8b 45 08             	mov    0x8(%ebp),%eax
  801939:	89 04 24             	mov    %eax,(%esp)
  80193c:	e8 95 ef ff ff       	call   8008d6 <fd_lookup>
  801941:	85 c0                	test   %eax,%eax
  801943:	78 15                	js     80195a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801945:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801948:	89 04 24             	mov    %eax,(%esp)
  80194b:	e8 18 ef ff ff       	call   800868 <fd2data>
	return _pipeisclosed(fd, p);
  801950:	89 c2                	mov    %eax,%edx
  801952:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801955:	e8 15 fd ff ff       	call   80166f <_pipeisclosed>
}
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80195f:	b8 00 00 00 00       	mov    $0x0,%eax
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    

00801966 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80196c:	c7 44 24 04 97 26 80 	movl   $0x802697,0x4(%esp)
  801973:	00 
  801974:	8b 45 0c             	mov    0xc(%ebp),%eax
  801977:	89 04 24             	mov    %eax,(%esp)
  80197a:	e8 1c e8 ff ff       	call   80019b <strcpy>
	return 0;
}
  80197f:	b8 00 00 00 00       	mov    $0x0,%eax
  801984:	c9                   	leave  
  801985:	c3                   	ret    

00801986 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801986:	55                   	push   %ebp
  801987:	89 e5                	mov    %esp,%ebp
  801989:	57                   	push   %edi
  80198a:	56                   	push   %esi
  80198b:	53                   	push   %ebx
  80198c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801992:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801997:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80199d:	eb 30                	jmp    8019cf <devcons_write+0x49>
		m = n - tot;
  80199f:	8b 75 10             	mov    0x10(%ebp),%esi
  8019a2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8019a4:	83 fe 7f             	cmp    $0x7f,%esi
  8019a7:	76 05                	jbe    8019ae <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8019a9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019ae:	89 74 24 08          	mov    %esi,0x8(%esp)
  8019b2:	03 45 0c             	add    0xc(%ebp),%eax
  8019b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b9:	89 3c 24             	mov    %edi,(%esp)
  8019bc:	e8 53 e9 ff ff       	call   800314 <memmove>
		sys_cputs(buf, m);
  8019c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019c5:	89 3c 24             	mov    %edi,(%esp)
  8019c8:	e8 f3 ea ff ff       	call   8004c0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019cd:	01 f3                	add    %esi,%ebx
  8019cf:	89 d8                	mov    %ebx,%eax
  8019d1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019d4:	72 c9                	jb     80199f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019d6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8019dc:	5b                   	pop    %ebx
  8019dd:	5e                   	pop    %esi
  8019de:	5f                   	pop    %edi
  8019df:	5d                   	pop    %ebp
  8019e0:	c3                   	ret    

008019e1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8019e7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019eb:	75 07                	jne    8019f4 <devcons_read+0x13>
  8019ed:	eb 25                	jmp    801a14 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019ef:	e8 7a eb ff ff       	call   80056e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019f4:	e8 e5 ea ff ff       	call   8004de <sys_cgetc>
  8019f9:	85 c0                	test   %eax,%eax
  8019fb:	74 f2                	je     8019ef <devcons_read+0xe>
  8019fd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	78 1d                	js     801a20 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a03:	83 f8 04             	cmp    $0x4,%eax
  801a06:	74 13                	je     801a1b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0b:	88 10                	mov    %dl,(%eax)
	return 1;
  801a0d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a12:	eb 0c                	jmp    801a20 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801a14:	b8 00 00 00 00       	mov    $0x0,%eax
  801a19:	eb 05                	jmp    801a20 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a1b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a20:	c9                   	leave  
  801a21:	c3                   	ret    

00801a22 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801a28:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a2e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a35:	00 
  801a36:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a39:	89 04 24             	mov    %eax,(%esp)
  801a3c:	e8 7f ea ff ff       	call   8004c0 <sys_cputs>
}
  801a41:	c9                   	leave  
  801a42:	c3                   	ret    

00801a43 <getchar>:

int
getchar(void)
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a49:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801a50:	00 
  801a51:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a5f:	e8 10 f1 ff ff       	call   800b74 <read>
	if (r < 0)
  801a64:	85 c0                	test   %eax,%eax
  801a66:	78 0f                	js     801a77 <getchar+0x34>
		return r;
	if (r < 1)
  801a68:	85 c0                	test   %eax,%eax
  801a6a:	7e 06                	jle    801a72 <getchar+0x2f>
		return -E_EOF;
	return c;
  801a6c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a70:	eb 05                	jmp    801a77 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a72:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a77:	c9                   	leave  
  801a78:	c3                   	ret    

00801a79 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a86:	8b 45 08             	mov    0x8(%ebp),%eax
  801a89:	89 04 24             	mov    %eax,(%esp)
  801a8c:	e8 45 ee ff ff       	call   8008d6 <fd_lookup>
  801a91:	85 c0                	test   %eax,%eax
  801a93:	78 11                	js     801aa6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a98:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801a9e:	39 10                	cmp    %edx,(%eax)
  801aa0:	0f 94 c0             	sete   %al
  801aa3:	0f b6 c0             	movzbl %al,%eax
}
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <opencons>:

int
opencons(void)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801aae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ab1:	89 04 24             	mov    %eax,(%esp)
  801ab4:	e8 ca ed ff ff       	call   800883 <fd_alloc>
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	78 3c                	js     801af9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801abd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ac4:	00 
  801ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801acc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ad3:	e8 b5 ea ff ff       	call   80058d <sys_page_alloc>
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	78 1d                	js     801af9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801adc:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aea:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801af1:	89 04 24             	mov    %eax,(%esp)
  801af4:	e8 5f ed ff ff       	call   800858 <fd2num>
}
  801af9:	c9                   	leave  
  801afa:	c3                   	ret    
	...

00801afc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	56                   	push   %esi
  801b00:	53                   	push   %ebx
  801b01:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801b04:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b07:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801b0d:	e8 3d ea ff ff       	call   80054f <sys_getenvid>
  801b12:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b15:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b19:	8b 55 08             	mov    0x8(%ebp),%edx
  801b1c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b20:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b24:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b28:	c7 04 24 a4 26 80 00 	movl   $0x8026a4,(%esp)
  801b2f:	e8 c0 00 00 00       	call   801bf4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b38:	8b 45 10             	mov    0x10(%ebp),%eax
  801b3b:	89 04 24             	mov    %eax,(%esp)
  801b3e:	e8 50 00 00 00       	call   801b93 <vcprintf>
	cprintf("\n");
  801b43:	c7 04 24 90 26 80 00 	movl   $0x802690,(%esp)
  801b4a:	e8 a5 00 00 00       	call   801bf4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b4f:	cc                   	int3   
  801b50:	eb fd                	jmp    801b4f <_panic+0x53>
	...

00801b54 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	53                   	push   %ebx
  801b58:	83 ec 14             	sub    $0x14,%esp
  801b5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801b5e:	8b 03                	mov    (%ebx),%eax
  801b60:	8b 55 08             	mov    0x8(%ebp),%edx
  801b63:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801b67:	40                   	inc    %eax
  801b68:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801b6a:	3d ff 00 00 00       	cmp    $0xff,%eax
  801b6f:	75 19                	jne    801b8a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801b71:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801b78:	00 
  801b79:	8d 43 08             	lea    0x8(%ebx),%eax
  801b7c:	89 04 24             	mov    %eax,(%esp)
  801b7f:	e8 3c e9 ff ff       	call   8004c0 <sys_cputs>
		b->idx = 0;
  801b84:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801b8a:	ff 43 04             	incl   0x4(%ebx)
}
  801b8d:	83 c4 14             	add    $0x14,%esp
  801b90:	5b                   	pop    %ebx
  801b91:	5d                   	pop    %ebp
  801b92:	c3                   	ret    

00801b93 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801b9c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801ba3:	00 00 00 
	b.cnt = 0;
  801ba6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801bad:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801bb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bba:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bbe:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801bc4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc8:	c7 04 24 54 1b 80 00 	movl   $0x801b54,(%esp)
  801bcf:	e8 82 01 00 00       	call   801d56 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801bd4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801bda:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bde:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801be4:	89 04 24             	mov    %eax,(%esp)
  801be7:	e8 d4 e8 ff ff       	call   8004c0 <sys_cputs>

	return b.cnt;
}
  801bec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801bf2:	c9                   	leave  
  801bf3:	c3                   	ret    

00801bf4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801bfa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c01:	8b 45 08             	mov    0x8(%ebp),%eax
  801c04:	89 04 24             	mov    %eax,(%esp)
  801c07:	e8 87 ff ff ff       	call   801b93 <vcprintf>
	va_end(ap);

	return cnt;
}
  801c0c:	c9                   	leave  
  801c0d:	c3                   	ret    
	...

00801c10 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801c10:	55                   	push   %ebp
  801c11:	89 e5                	mov    %esp,%ebp
  801c13:	57                   	push   %edi
  801c14:	56                   	push   %esi
  801c15:	53                   	push   %ebx
  801c16:	83 ec 3c             	sub    $0x3c,%esp
  801c19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c1c:	89 d7                	mov    %edx,%edi
  801c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c21:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801c24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c27:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c2a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801c2d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801c30:	85 c0                	test   %eax,%eax
  801c32:	75 08                	jne    801c3c <printnum+0x2c>
  801c34:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801c37:	39 45 10             	cmp    %eax,0x10(%ebp)
  801c3a:	77 57                	ja     801c93 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801c3c:	89 74 24 10          	mov    %esi,0x10(%esp)
  801c40:	4b                   	dec    %ebx
  801c41:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c45:	8b 45 10             	mov    0x10(%ebp),%eax
  801c48:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c4c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801c50:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801c54:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c5b:	00 
  801c5c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801c5f:	89 04 24             	mov    %eax,(%esp)
  801c62:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c65:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c69:	e8 7a 06 00 00       	call   8022e8 <__udivdi3>
  801c6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c72:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c76:	89 04 24             	mov    %eax,(%esp)
  801c79:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c7d:	89 fa                	mov    %edi,%edx
  801c7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c82:	e8 89 ff ff ff       	call   801c10 <printnum>
  801c87:	eb 0f                	jmp    801c98 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801c89:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c8d:	89 34 24             	mov    %esi,(%esp)
  801c90:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801c93:	4b                   	dec    %ebx
  801c94:	85 db                	test   %ebx,%ebx
  801c96:	7f f1                	jg     801c89 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801c98:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c9c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ca0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ca7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801cae:	00 
  801caf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801cb2:	89 04 24             	mov    %eax,(%esp)
  801cb5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cbc:	e8 47 07 00 00       	call   802408 <__umoddi3>
  801cc1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801cc5:	0f be 80 c7 26 80 00 	movsbl 0x8026c7(%eax),%eax
  801ccc:	89 04 24             	mov    %eax,(%esp)
  801ccf:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801cd2:	83 c4 3c             	add    $0x3c,%esp
  801cd5:	5b                   	pop    %ebx
  801cd6:	5e                   	pop    %esi
  801cd7:	5f                   	pop    %edi
  801cd8:	5d                   	pop    %ebp
  801cd9:	c3                   	ret    

00801cda <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801cda:	55                   	push   %ebp
  801cdb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801cdd:	83 fa 01             	cmp    $0x1,%edx
  801ce0:	7e 0e                	jle    801cf0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801ce2:	8b 10                	mov    (%eax),%edx
  801ce4:	8d 4a 08             	lea    0x8(%edx),%ecx
  801ce7:	89 08                	mov    %ecx,(%eax)
  801ce9:	8b 02                	mov    (%edx),%eax
  801ceb:	8b 52 04             	mov    0x4(%edx),%edx
  801cee:	eb 22                	jmp    801d12 <getuint+0x38>
	else if (lflag)
  801cf0:	85 d2                	test   %edx,%edx
  801cf2:	74 10                	je     801d04 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801cf4:	8b 10                	mov    (%eax),%edx
  801cf6:	8d 4a 04             	lea    0x4(%edx),%ecx
  801cf9:	89 08                	mov    %ecx,(%eax)
  801cfb:	8b 02                	mov    (%edx),%eax
  801cfd:	ba 00 00 00 00       	mov    $0x0,%edx
  801d02:	eb 0e                	jmp    801d12 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801d04:	8b 10                	mov    (%eax),%edx
  801d06:	8d 4a 04             	lea    0x4(%edx),%ecx
  801d09:	89 08                	mov    %ecx,(%eax)
  801d0b:	8b 02                	mov    (%edx),%eax
  801d0d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801d12:	5d                   	pop    %ebp
  801d13:	c3                   	ret    

00801d14 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801d1a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801d1d:	8b 10                	mov    (%eax),%edx
  801d1f:	3b 50 04             	cmp    0x4(%eax),%edx
  801d22:	73 08                	jae    801d2c <sprintputch+0x18>
		*b->buf++ = ch;
  801d24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d27:	88 0a                	mov    %cl,(%edx)
  801d29:	42                   	inc    %edx
  801d2a:	89 10                	mov    %edx,(%eax)
}
  801d2c:	5d                   	pop    %ebp
  801d2d:	c3                   	ret    

00801d2e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801d34:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801d37:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d3b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d49:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4c:	89 04 24             	mov    %eax,(%esp)
  801d4f:	e8 02 00 00 00       	call   801d56 <vprintfmt>
	va_end(ap);
}
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	57                   	push   %edi
  801d5a:	56                   	push   %esi
  801d5b:	53                   	push   %ebx
  801d5c:	83 ec 4c             	sub    $0x4c,%esp
  801d5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801d62:	8b 75 10             	mov    0x10(%ebp),%esi
  801d65:	eb 12                	jmp    801d79 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801d67:	85 c0                	test   %eax,%eax
  801d69:	0f 84 6b 03 00 00    	je     8020da <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  801d6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d73:	89 04 24             	mov    %eax,(%esp)
  801d76:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801d79:	0f b6 06             	movzbl (%esi),%eax
  801d7c:	46                   	inc    %esi
  801d7d:	83 f8 25             	cmp    $0x25,%eax
  801d80:	75 e5                	jne    801d67 <vprintfmt+0x11>
  801d82:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801d86:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801d8d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801d92:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801d99:	b9 00 00 00 00       	mov    $0x0,%ecx
  801d9e:	eb 26                	jmp    801dc6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801da0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801da3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801da7:	eb 1d                	jmp    801dc6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801da9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801dac:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801db0:	eb 14                	jmp    801dc6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801db2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801db5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801dbc:	eb 08                	jmp    801dc6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801dbe:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801dc1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801dc6:	0f b6 06             	movzbl (%esi),%eax
  801dc9:	8d 56 01             	lea    0x1(%esi),%edx
  801dcc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801dcf:	8a 16                	mov    (%esi),%dl
  801dd1:	83 ea 23             	sub    $0x23,%edx
  801dd4:	80 fa 55             	cmp    $0x55,%dl
  801dd7:	0f 87 e1 02 00 00    	ja     8020be <vprintfmt+0x368>
  801ddd:	0f b6 d2             	movzbl %dl,%edx
  801de0:	ff 24 95 00 28 80 00 	jmp    *0x802800(,%edx,4)
  801de7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801dea:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801def:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801df2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  801df6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801df9:	8d 50 d0             	lea    -0x30(%eax),%edx
  801dfc:	83 fa 09             	cmp    $0x9,%edx
  801dff:	77 2a                	ja     801e2b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801e01:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801e02:	eb eb                	jmp    801def <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801e04:	8b 45 14             	mov    0x14(%ebp),%eax
  801e07:	8d 50 04             	lea    0x4(%eax),%edx
  801e0a:	89 55 14             	mov    %edx,0x14(%ebp)
  801e0d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e0f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801e12:	eb 17                	jmp    801e2b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801e14:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801e18:	78 98                	js     801db2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e1a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801e1d:	eb a7                	jmp    801dc6 <vprintfmt+0x70>
  801e1f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801e22:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801e29:	eb 9b                	jmp    801dc6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801e2b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801e2f:	79 95                	jns    801dc6 <vprintfmt+0x70>
  801e31:	eb 8b                	jmp    801dbe <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801e33:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e34:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801e37:	eb 8d                	jmp    801dc6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801e39:	8b 45 14             	mov    0x14(%ebp),%eax
  801e3c:	8d 50 04             	lea    0x4(%eax),%edx
  801e3f:	89 55 14             	mov    %edx,0x14(%ebp)
  801e42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e46:	8b 00                	mov    (%eax),%eax
  801e48:	89 04 24             	mov    %eax,(%esp)
  801e4b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e4e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801e51:	e9 23 ff ff ff       	jmp    801d79 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801e56:	8b 45 14             	mov    0x14(%ebp),%eax
  801e59:	8d 50 04             	lea    0x4(%eax),%edx
  801e5c:	89 55 14             	mov    %edx,0x14(%ebp)
  801e5f:	8b 00                	mov    (%eax),%eax
  801e61:	85 c0                	test   %eax,%eax
  801e63:	79 02                	jns    801e67 <vprintfmt+0x111>
  801e65:	f7 d8                	neg    %eax
  801e67:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801e69:	83 f8 10             	cmp    $0x10,%eax
  801e6c:	7f 0b                	jg     801e79 <vprintfmt+0x123>
  801e6e:	8b 04 85 60 29 80 00 	mov    0x802960(,%eax,4),%eax
  801e75:	85 c0                	test   %eax,%eax
  801e77:	75 23                	jne    801e9c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801e79:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e7d:	c7 44 24 08 df 26 80 	movl   $0x8026df,0x8(%esp)
  801e84:	00 
  801e85:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e89:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8c:	89 04 24             	mov    %eax,(%esp)
  801e8f:	e8 9a fe ff ff       	call   801d2e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e94:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801e97:	e9 dd fe ff ff       	jmp    801d79 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801e9c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ea0:	c7 44 24 08 25 26 80 	movl   $0x802625,0x8(%esp)
  801ea7:	00 
  801ea8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eac:	8b 55 08             	mov    0x8(%ebp),%edx
  801eaf:	89 14 24             	mov    %edx,(%esp)
  801eb2:	e8 77 fe ff ff       	call   801d2e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801eb7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801eba:	e9 ba fe ff ff       	jmp    801d79 <vprintfmt+0x23>
  801ebf:	89 f9                	mov    %edi,%ecx
  801ec1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ec4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801ec7:	8b 45 14             	mov    0x14(%ebp),%eax
  801eca:	8d 50 04             	lea    0x4(%eax),%edx
  801ecd:	89 55 14             	mov    %edx,0x14(%ebp)
  801ed0:	8b 30                	mov    (%eax),%esi
  801ed2:	85 f6                	test   %esi,%esi
  801ed4:	75 05                	jne    801edb <vprintfmt+0x185>
				p = "(null)";
  801ed6:	be d8 26 80 00       	mov    $0x8026d8,%esi
			if (width > 0 && padc != '-')
  801edb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801edf:	0f 8e 84 00 00 00    	jle    801f69 <vprintfmt+0x213>
  801ee5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801ee9:	74 7e                	je     801f69 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  801eeb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801eef:	89 34 24             	mov    %esi,(%esp)
  801ef2:	e8 87 e2 ff ff       	call   80017e <strnlen>
  801ef7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801efa:	29 c2                	sub    %eax,%edx
  801efc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801eff:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801f03:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801f06:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801f09:	89 de                	mov    %ebx,%esi
  801f0b:	89 d3                	mov    %edx,%ebx
  801f0d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801f0f:	eb 0b                	jmp    801f1c <vprintfmt+0x1c6>
					putch(padc, putdat);
  801f11:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f15:	89 3c 24             	mov    %edi,(%esp)
  801f18:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801f1b:	4b                   	dec    %ebx
  801f1c:	85 db                	test   %ebx,%ebx
  801f1e:	7f f1                	jg     801f11 <vprintfmt+0x1bb>
  801f20:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801f23:	89 f3                	mov    %esi,%ebx
  801f25:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801f28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	79 05                	jns    801f34 <vprintfmt+0x1de>
  801f2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f34:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801f37:	29 c2                	sub    %eax,%edx
  801f39:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801f3c:	eb 2b                	jmp    801f69 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801f3e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801f42:	74 18                	je     801f5c <vprintfmt+0x206>
  801f44:	8d 50 e0             	lea    -0x20(%eax),%edx
  801f47:	83 fa 5e             	cmp    $0x5e,%edx
  801f4a:	76 10                	jbe    801f5c <vprintfmt+0x206>
					putch('?', putdat);
  801f4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f50:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801f57:	ff 55 08             	call   *0x8(%ebp)
  801f5a:	eb 0a                	jmp    801f66 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801f5c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f60:	89 04 24             	mov    %eax,(%esp)
  801f63:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801f66:	ff 4d e4             	decl   -0x1c(%ebp)
  801f69:	0f be 06             	movsbl (%esi),%eax
  801f6c:	46                   	inc    %esi
  801f6d:	85 c0                	test   %eax,%eax
  801f6f:	74 21                	je     801f92 <vprintfmt+0x23c>
  801f71:	85 ff                	test   %edi,%edi
  801f73:	78 c9                	js     801f3e <vprintfmt+0x1e8>
  801f75:	4f                   	dec    %edi
  801f76:	79 c6                	jns    801f3e <vprintfmt+0x1e8>
  801f78:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f7b:	89 de                	mov    %ebx,%esi
  801f7d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801f80:	eb 18                	jmp    801f9a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801f82:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f86:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801f8d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801f8f:	4b                   	dec    %ebx
  801f90:	eb 08                	jmp    801f9a <vprintfmt+0x244>
  801f92:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f95:	89 de                	mov    %ebx,%esi
  801f97:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801f9a:	85 db                	test   %ebx,%ebx
  801f9c:	7f e4                	jg     801f82 <vprintfmt+0x22c>
  801f9e:	89 7d 08             	mov    %edi,0x8(%ebp)
  801fa1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801fa3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801fa6:	e9 ce fd ff ff       	jmp    801d79 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801fab:	83 f9 01             	cmp    $0x1,%ecx
  801fae:	7e 10                	jle    801fc0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801fb0:	8b 45 14             	mov    0x14(%ebp),%eax
  801fb3:	8d 50 08             	lea    0x8(%eax),%edx
  801fb6:	89 55 14             	mov    %edx,0x14(%ebp)
  801fb9:	8b 30                	mov    (%eax),%esi
  801fbb:	8b 78 04             	mov    0x4(%eax),%edi
  801fbe:	eb 26                	jmp    801fe6 <vprintfmt+0x290>
	else if (lflag)
  801fc0:	85 c9                	test   %ecx,%ecx
  801fc2:	74 12                	je     801fd6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  801fc4:	8b 45 14             	mov    0x14(%ebp),%eax
  801fc7:	8d 50 04             	lea    0x4(%eax),%edx
  801fca:	89 55 14             	mov    %edx,0x14(%ebp)
  801fcd:	8b 30                	mov    (%eax),%esi
  801fcf:	89 f7                	mov    %esi,%edi
  801fd1:	c1 ff 1f             	sar    $0x1f,%edi
  801fd4:	eb 10                	jmp    801fe6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801fd6:	8b 45 14             	mov    0x14(%ebp),%eax
  801fd9:	8d 50 04             	lea    0x4(%eax),%edx
  801fdc:	89 55 14             	mov    %edx,0x14(%ebp)
  801fdf:	8b 30                	mov    (%eax),%esi
  801fe1:	89 f7                	mov    %esi,%edi
  801fe3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801fe6:	85 ff                	test   %edi,%edi
  801fe8:	78 0a                	js     801ff4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801fea:	b8 0a 00 00 00       	mov    $0xa,%eax
  801fef:	e9 8c 00 00 00       	jmp    802080 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801ff4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ff8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801fff:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  802002:	f7 de                	neg    %esi
  802004:	83 d7 00             	adc    $0x0,%edi
  802007:	f7 df                	neg    %edi
			}
			base = 10;
  802009:	b8 0a 00 00 00       	mov    $0xa,%eax
  80200e:	eb 70                	jmp    802080 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  802010:	89 ca                	mov    %ecx,%edx
  802012:	8d 45 14             	lea    0x14(%ebp),%eax
  802015:	e8 c0 fc ff ff       	call   801cda <getuint>
  80201a:	89 c6                	mov    %eax,%esi
  80201c:	89 d7                	mov    %edx,%edi
			base = 10;
  80201e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  802023:	eb 5b                	jmp    802080 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  802025:	89 ca                	mov    %ecx,%edx
  802027:	8d 45 14             	lea    0x14(%ebp),%eax
  80202a:	e8 ab fc ff ff       	call   801cda <getuint>
  80202f:	89 c6                	mov    %eax,%esi
  802031:	89 d7                	mov    %edx,%edi
			base = 8;
  802033:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  802038:	eb 46                	jmp    802080 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80203a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80203e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  802045:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  802048:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80204c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  802053:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  802056:	8b 45 14             	mov    0x14(%ebp),%eax
  802059:	8d 50 04             	lea    0x4(%eax),%edx
  80205c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80205f:	8b 30                	mov    (%eax),%esi
  802061:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  802066:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80206b:	eb 13                	jmp    802080 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80206d:	89 ca                	mov    %ecx,%edx
  80206f:	8d 45 14             	lea    0x14(%ebp),%eax
  802072:	e8 63 fc ff ff       	call   801cda <getuint>
  802077:	89 c6                	mov    %eax,%esi
  802079:	89 d7                	mov    %edx,%edi
			base = 16;
  80207b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  802080:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  802084:	89 54 24 10          	mov    %edx,0x10(%esp)
  802088:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80208b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80208f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802093:	89 34 24             	mov    %esi,(%esp)
  802096:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80209a:	89 da                	mov    %ebx,%edx
  80209c:	8b 45 08             	mov    0x8(%ebp),%eax
  80209f:	e8 6c fb ff ff       	call   801c10 <printnum>
			break;
  8020a4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8020a7:	e9 cd fc ff ff       	jmp    801d79 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8020ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020b0:	89 04 24             	mov    %eax,(%esp)
  8020b3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8020b9:	e9 bb fc ff ff       	jmp    801d79 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8020be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020c2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8020c9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8020cc:	eb 01                	jmp    8020cf <vprintfmt+0x379>
  8020ce:	4e                   	dec    %esi
  8020cf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8020d3:	75 f9                	jne    8020ce <vprintfmt+0x378>
  8020d5:	e9 9f fc ff ff       	jmp    801d79 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8020da:	83 c4 4c             	add    $0x4c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    

008020e2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8020e2:	55                   	push   %ebp
  8020e3:	89 e5                	mov    %esp,%ebp
  8020e5:	83 ec 28             	sub    $0x28,%esp
  8020e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8020ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8020f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8020f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8020ff:	85 c0                	test   %eax,%eax
  802101:	74 30                	je     802133 <vsnprintf+0x51>
  802103:	85 d2                	test   %edx,%edx
  802105:	7e 33                	jle    80213a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802107:	8b 45 14             	mov    0x14(%ebp),%eax
  80210a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80210e:	8b 45 10             	mov    0x10(%ebp),%eax
  802111:	89 44 24 08          	mov    %eax,0x8(%esp)
  802115:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802118:	89 44 24 04          	mov    %eax,0x4(%esp)
  80211c:	c7 04 24 14 1d 80 00 	movl   $0x801d14,(%esp)
  802123:	e8 2e fc ff ff       	call   801d56 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802128:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80212b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80212e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802131:	eb 0c                	jmp    80213f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  802133:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802138:	eb 05                	jmp    80213f <vsnprintf+0x5d>
  80213a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80213f:	c9                   	leave  
  802140:	c3                   	ret    

00802141 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802141:	55                   	push   %ebp
  802142:	89 e5                	mov    %esp,%ebp
  802144:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  802147:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80214a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80214e:	8b 45 10             	mov    0x10(%ebp),%eax
  802151:	89 44 24 08          	mov    %eax,0x8(%esp)
  802155:	8b 45 0c             	mov    0xc(%ebp),%eax
  802158:	89 44 24 04          	mov    %eax,0x4(%esp)
  80215c:	8b 45 08             	mov    0x8(%ebp),%eax
  80215f:	89 04 24             	mov    %eax,(%esp)
  802162:	e8 7b ff ff ff       	call   8020e2 <vsnprintf>
	va_end(ap);

	return rc;
}
  802167:	c9                   	leave  
  802168:	c3                   	ret    
  802169:	00 00                	add    %al,(%eax)
	...

0080216c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80216c:	55                   	push   %ebp
  80216d:	89 e5                	mov    %esp,%ebp
  80216f:	56                   	push   %esi
  802170:	53                   	push   %ebx
  802171:	83 ec 10             	sub    $0x10,%esp
  802174:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802177:	8b 45 0c             	mov    0xc(%ebp),%eax
  80217a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  80217d:	85 c0                	test   %eax,%eax
  80217f:	74 0a                	je     80218b <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802181:	89 04 24             	mov    %eax,(%esp)
  802184:	e8 1a e6 ff ff       	call   8007a3 <sys_ipc_recv>
  802189:	eb 0c                	jmp    802197 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80218b:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802192:	e8 0c e6 ff ff       	call   8007a3 <sys_ipc_recv>
	}
	if (r < 0)
  802197:	85 c0                	test   %eax,%eax
  802199:	79 16                	jns    8021b1 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  80219b:	85 db                	test   %ebx,%ebx
  80219d:	74 06                	je     8021a5 <ipc_recv+0x39>
  80219f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8021a5:	85 f6                	test   %esi,%esi
  8021a7:	74 2c                	je     8021d5 <ipc_recv+0x69>
  8021a9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8021af:	eb 24                	jmp    8021d5 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8021b1:	85 db                	test   %ebx,%ebx
  8021b3:	74 0a                	je     8021bf <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  8021b5:	a1 08 40 80 00       	mov    0x804008,%eax
  8021ba:	8b 40 74             	mov    0x74(%eax),%eax
  8021bd:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  8021bf:	85 f6                	test   %esi,%esi
  8021c1:	74 0a                	je     8021cd <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  8021c3:	a1 08 40 80 00       	mov    0x804008,%eax
  8021c8:	8b 40 78             	mov    0x78(%eax),%eax
  8021cb:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8021cd:	a1 08 40 80 00       	mov    0x804008,%eax
  8021d2:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8021d5:	83 c4 10             	add    $0x10,%esp
  8021d8:	5b                   	pop    %ebx
  8021d9:	5e                   	pop    %esi
  8021da:	5d                   	pop    %ebp
  8021db:	c3                   	ret    

008021dc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021dc:	55                   	push   %ebp
  8021dd:	89 e5                	mov    %esp,%ebp
  8021df:	57                   	push   %edi
  8021e0:	56                   	push   %esi
  8021e1:	53                   	push   %ebx
  8021e2:	83 ec 1c             	sub    $0x1c,%esp
  8021e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8021e8:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8021ee:	85 db                	test   %ebx,%ebx
  8021f0:	74 19                	je     80220b <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8021f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8021f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802201:	89 34 24             	mov    %esi,(%esp)
  802204:	e8 77 e5 ff ff       	call   800780 <sys_ipc_try_send>
  802209:	eb 1c                	jmp    802227 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80220b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802212:	00 
  802213:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80221a:	ee 
  80221b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80221f:	89 34 24             	mov    %esi,(%esp)
  802222:	e8 59 e5 ff ff       	call   800780 <sys_ipc_try_send>
		}
		if (r == 0)
  802227:	85 c0                	test   %eax,%eax
  802229:	74 2c                	je     802257 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80222b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80222e:	74 20                	je     802250 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802230:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802234:	c7 44 24 08 c4 29 80 	movl   $0x8029c4,0x8(%esp)
  80223b:	00 
  80223c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802243:	00 
  802244:	c7 04 24 d7 29 80 00 	movl   $0x8029d7,(%esp)
  80224b:	e8 ac f8 ff ff       	call   801afc <_panic>
		}
		sys_yield();
  802250:	e8 19 e3 ff ff       	call   80056e <sys_yield>
	}
  802255:	eb 97                	jmp    8021ee <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802257:	83 c4 1c             	add    $0x1c,%esp
  80225a:	5b                   	pop    %ebx
  80225b:	5e                   	pop    %esi
  80225c:	5f                   	pop    %edi
  80225d:	5d                   	pop    %ebp
  80225e:	c3                   	ret    

0080225f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80225f:	55                   	push   %ebp
  802260:	89 e5                	mov    %esp,%ebp
  802262:	53                   	push   %ebx
  802263:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802266:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80226b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802272:	89 c2                	mov    %eax,%edx
  802274:	c1 e2 07             	shl    $0x7,%edx
  802277:	29 ca                	sub    %ecx,%edx
  802279:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80227f:	8b 52 50             	mov    0x50(%edx),%edx
  802282:	39 da                	cmp    %ebx,%edx
  802284:	75 0f                	jne    802295 <ipc_find_env+0x36>
			return envs[i].env_id;
  802286:	c1 e0 07             	shl    $0x7,%eax
  802289:	29 c8                	sub    %ecx,%eax
  80228b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802290:	8b 40 40             	mov    0x40(%eax),%eax
  802293:	eb 0c                	jmp    8022a1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802295:	40                   	inc    %eax
  802296:	3d 00 04 00 00       	cmp    $0x400,%eax
  80229b:	75 ce                	jne    80226b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80229d:	66 b8 00 00          	mov    $0x0,%ax
}
  8022a1:	5b                   	pop    %ebx
  8022a2:	5d                   	pop    %ebp
  8022a3:	c3                   	ret    

008022a4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022a4:	55                   	push   %ebp
  8022a5:	89 e5                	mov    %esp,%ebp
  8022a7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022aa:	89 c2                	mov    %eax,%edx
  8022ac:	c1 ea 16             	shr    $0x16,%edx
  8022af:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8022b6:	f6 c2 01             	test   $0x1,%dl
  8022b9:	74 1e                	je     8022d9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022bb:	c1 e8 0c             	shr    $0xc,%eax
  8022be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8022c5:	a8 01                	test   $0x1,%al
  8022c7:	74 17                	je     8022e0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022c9:	c1 e8 0c             	shr    $0xc,%eax
  8022cc:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8022d3:	ef 
  8022d4:	0f b7 c0             	movzwl %ax,%eax
  8022d7:	eb 0c                	jmp    8022e5 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8022d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8022de:	eb 05                	jmp    8022e5 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8022e0:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8022e5:	5d                   	pop    %ebp
  8022e6:	c3                   	ret    
	...

008022e8 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8022e8:	55                   	push   %ebp
  8022e9:	57                   	push   %edi
  8022ea:	56                   	push   %esi
  8022eb:	83 ec 10             	sub    $0x10,%esp
  8022ee:	8b 74 24 20          	mov    0x20(%esp),%esi
  8022f2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8022f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022fa:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8022fe:	89 cd                	mov    %ecx,%ebp
  802300:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802304:	85 c0                	test   %eax,%eax
  802306:	75 2c                	jne    802334 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802308:	39 f9                	cmp    %edi,%ecx
  80230a:	77 68                	ja     802374 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80230c:	85 c9                	test   %ecx,%ecx
  80230e:	75 0b                	jne    80231b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802310:	b8 01 00 00 00       	mov    $0x1,%eax
  802315:	31 d2                	xor    %edx,%edx
  802317:	f7 f1                	div    %ecx
  802319:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	89 f8                	mov    %edi,%eax
  80231f:	f7 f1                	div    %ecx
  802321:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802323:	89 f0                	mov    %esi,%eax
  802325:	f7 f1                	div    %ecx
  802327:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802329:	89 f0                	mov    %esi,%eax
  80232b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80232d:	83 c4 10             	add    $0x10,%esp
  802330:	5e                   	pop    %esi
  802331:	5f                   	pop    %edi
  802332:	5d                   	pop    %ebp
  802333:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802334:	39 f8                	cmp    %edi,%eax
  802336:	77 2c                	ja     802364 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802338:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80233b:	83 f6 1f             	xor    $0x1f,%esi
  80233e:	75 4c                	jne    80238c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802340:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802342:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802347:	72 0a                	jb     802353 <__udivdi3+0x6b>
  802349:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80234d:	0f 87 ad 00 00 00    	ja     802400 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802353:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802358:	89 f0                	mov    %esi,%eax
  80235a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80235c:	83 c4 10             	add    $0x10,%esp
  80235f:	5e                   	pop    %esi
  802360:	5f                   	pop    %edi
  802361:	5d                   	pop    %ebp
  802362:	c3                   	ret    
  802363:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802364:	31 ff                	xor    %edi,%edi
  802366:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802368:	89 f0                	mov    %esi,%eax
  80236a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80236c:	83 c4 10             	add    $0x10,%esp
  80236f:	5e                   	pop    %esi
  802370:	5f                   	pop    %edi
  802371:	5d                   	pop    %ebp
  802372:	c3                   	ret    
  802373:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802374:	89 fa                	mov    %edi,%edx
  802376:	89 f0                	mov    %esi,%eax
  802378:	f7 f1                	div    %ecx
  80237a:	89 c6                	mov    %eax,%esi
  80237c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80237e:	89 f0                	mov    %esi,%eax
  802380:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802382:	83 c4 10             	add    $0x10,%esp
  802385:	5e                   	pop    %esi
  802386:	5f                   	pop    %edi
  802387:	5d                   	pop    %ebp
  802388:	c3                   	ret    
  802389:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80238c:	89 f1                	mov    %esi,%ecx
  80238e:	d3 e0                	shl    %cl,%eax
  802390:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802394:	b8 20 00 00 00       	mov    $0x20,%eax
  802399:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80239b:	89 ea                	mov    %ebp,%edx
  80239d:	88 c1                	mov    %al,%cl
  80239f:	d3 ea                	shr    %cl,%edx
  8023a1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8023a5:	09 ca                	or     %ecx,%edx
  8023a7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8023ab:	89 f1                	mov    %esi,%ecx
  8023ad:	d3 e5                	shl    %cl,%ebp
  8023af:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8023b3:	89 fd                	mov    %edi,%ebp
  8023b5:	88 c1                	mov    %al,%cl
  8023b7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8023b9:	89 fa                	mov    %edi,%edx
  8023bb:	89 f1                	mov    %esi,%ecx
  8023bd:	d3 e2                	shl    %cl,%edx
  8023bf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8023c3:	88 c1                	mov    %al,%cl
  8023c5:	d3 ef                	shr    %cl,%edi
  8023c7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023c9:	89 f8                	mov    %edi,%eax
  8023cb:	89 ea                	mov    %ebp,%edx
  8023cd:	f7 74 24 08          	divl   0x8(%esp)
  8023d1:	89 d1                	mov    %edx,%ecx
  8023d3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8023d5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023d9:	39 d1                	cmp    %edx,%ecx
  8023db:	72 17                	jb     8023f4 <__udivdi3+0x10c>
  8023dd:	74 09                	je     8023e8 <__udivdi3+0x100>
  8023df:	89 fe                	mov    %edi,%esi
  8023e1:	31 ff                	xor    %edi,%edi
  8023e3:	e9 41 ff ff ff       	jmp    802329 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8023e8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023ec:	89 f1                	mov    %esi,%ecx
  8023ee:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023f0:	39 c2                	cmp    %eax,%edx
  8023f2:	73 eb                	jae    8023df <__udivdi3+0xf7>
		{
		  q0--;
  8023f4:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8023f7:	31 ff                	xor    %edi,%edi
  8023f9:	e9 2b ff ff ff       	jmp    802329 <__udivdi3+0x41>
  8023fe:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802400:	31 f6                	xor    %esi,%esi
  802402:	e9 22 ff ff ff       	jmp    802329 <__udivdi3+0x41>
	...

00802408 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802408:	55                   	push   %ebp
  802409:	57                   	push   %edi
  80240a:	56                   	push   %esi
  80240b:	83 ec 20             	sub    $0x20,%esp
  80240e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802412:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802416:	89 44 24 14          	mov    %eax,0x14(%esp)
  80241a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80241e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802422:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802426:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802428:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80242a:	85 ed                	test   %ebp,%ebp
  80242c:	75 16                	jne    802444 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80242e:	39 f1                	cmp    %esi,%ecx
  802430:	0f 86 a6 00 00 00    	jbe    8024dc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802436:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802438:	89 d0                	mov    %edx,%eax
  80243a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80243c:	83 c4 20             	add    $0x20,%esp
  80243f:	5e                   	pop    %esi
  802440:	5f                   	pop    %edi
  802441:	5d                   	pop    %ebp
  802442:	c3                   	ret    
  802443:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802444:	39 f5                	cmp    %esi,%ebp
  802446:	0f 87 ac 00 00 00    	ja     8024f8 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80244c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80244f:	83 f0 1f             	xor    $0x1f,%eax
  802452:	89 44 24 10          	mov    %eax,0x10(%esp)
  802456:	0f 84 a8 00 00 00    	je     802504 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80245c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802460:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802462:	bf 20 00 00 00       	mov    $0x20,%edi
  802467:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80246b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80246f:	89 f9                	mov    %edi,%ecx
  802471:	d3 e8                	shr    %cl,%eax
  802473:	09 e8                	or     %ebp,%eax
  802475:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802479:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80247d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802481:	d3 e0                	shl    %cl,%eax
  802483:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802487:	89 f2                	mov    %esi,%edx
  802489:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80248b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80248f:	d3 e0                	shl    %cl,%eax
  802491:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802495:	8b 44 24 14          	mov    0x14(%esp),%eax
  802499:	89 f9                	mov    %edi,%ecx
  80249b:	d3 e8                	shr    %cl,%eax
  80249d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80249f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8024a1:	89 f2                	mov    %esi,%edx
  8024a3:	f7 74 24 18          	divl   0x18(%esp)
  8024a7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8024a9:	f7 64 24 0c          	mull   0xc(%esp)
  8024ad:	89 c5                	mov    %eax,%ebp
  8024af:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024b1:	39 d6                	cmp    %edx,%esi
  8024b3:	72 67                	jb     80251c <__umoddi3+0x114>
  8024b5:	74 75                	je     80252c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8024b7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8024bb:	29 e8                	sub    %ebp,%eax
  8024bd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8024bf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024c3:	d3 e8                	shr    %cl,%eax
  8024c5:	89 f2                	mov    %esi,%edx
  8024c7:	89 f9                	mov    %edi,%ecx
  8024c9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8024cb:	09 d0                	or     %edx,%eax
  8024cd:	89 f2                	mov    %esi,%edx
  8024cf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024d3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024d5:	83 c4 20             	add    $0x20,%esp
  8024d8:	5e                   	pop    %esi
  8024d9:	5f                   	pop    %edi
  8024da:	5d                   	pop    %ebp
  8024db:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8024dc:	85 c9                	test   %ecx,%ecx
  8024de:	75 0b                	jne    8024eb <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e5:	31 d2                	xor    %edx,%edx
  8024e7:	f7 f1                	div    %ecx
  8024e9:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024eb:	89 f0                	mov    %esi,%eax
  8024ed:	31 d2                	xor    %edx,%edx
  8024ef:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024f1:	89 f8                	mov    %edi,%eax
  8024f3:	e9 3e ff ff ff       	jmp    802436 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8024f8:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024fa:	83 c4 20             	add    $0x20,%esp
  8024fd:	5e                   	pop    %esi
  8024fe:	5f                   	pop    %edi
  8024ff:	5d                   	pop    %ebp
  802500:	c3                   	ret    
  802501:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802504:	39 f5                	cmp    %esi,%ebp
  802506:	72 04                	jb     80250c <__umoddi3+0x104>
  802508:	39 f9                	cmp    %edi,%ecx
  80250a:	77 06                	ja     802512 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80250c:	89 f2                	mov    %esi,%edx
  80250e:	29 cf                	sub    %ecx,%edi
  802510:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802512:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802514:	83 c4 20             	add    $0x20,%esp
  802517:	5e                   	pop    %esi
  802518:	5f                   	pop    %edi
  802519:	5d                   	pop    %ebp
  80251a:	c3                   	ret    
  80251b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80251c:	89 d1                	mov    %edx,%ecx
  80251e:	89 c5                	mov    %eax,%ebp
  802520:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802524:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802528:	eb 8d                	jmp    8024b7 <__umoddi3+0xaf>
  80252a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80252c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802530:	72 ea                	jb     80251c <__umoddi3+0x114>
  802532:	89 f1                	mov    %esi,%ecx
  802534:	eb 81                	jmp    8024b7 <__umoddi3+0xaf>
