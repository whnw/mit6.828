
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	56                   	push   %esi
  800040:	53                   	push   %ebx
  800041:	83 ec 10             	sub    $0x10,%esp
  800044:	8b 75 08             	mov    0x8(%ebp),%esi
  800047:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004a:	e8 ec 00 00 00       	call   80013b <sys_getenvid>
  80004f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800054:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80005b:	c1 e0 07             	shl    $0x7,%eax
  80005e:	29 d0                	sub    %edx,%eax
  800060:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800065:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 f6                	test   %esi,%esi
  80006c:	7e 07                	jle    800075 <libmain+0x39>
		binaryname = argv[0];
  80006e:	8b 03                	mov    (%ebx),%eax
  800070:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800075:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800079:	89 34 24             	mov    %esi,(%esp)
  80007c:	e8 b3 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    
  80008d:	00 00                	add    %al,(%eax)
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800096:	e8 90 05 00 00       	call   80062b <close_all>
	sys_env_destroy(0);
  80009b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    
  8000a9:	00 00                	add    %al,(%eax)
	...

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 28                	jle    800133 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80010f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800116:	00 
  800117:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800126:	00 
  800127:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  80012e:	e8 b5 15 00 00       	call   8016e8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800133:	83 c4 2c             	add    $0x2c,%esp
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 02 00 00 00       	mov    $0x2,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_yield>:

void
sys_yield(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800182:	be 00 00 00 00       	mov    $0x0,%esi
  800187:	b8 04 00 00 00       	mov    $0x4,%eax
  80018c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800192:	8b 55 08             	mov    0x8(%ebp),%edx
  800195:	89 f7                	mov    %esi,%edi
  800197:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	7e 28                	jle    8001c5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80019d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001a8:	00 
  8001a9:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  8001b0:	00 
  8001b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001b8:	00 
  8001b9:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  8001c0:	e8 23 15 00 00       	call   8016e8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c5:	83 c4 2c             	add    $0x2c,%esp
  8001c8:	5b                   	pop    %ebx
  8001c9:	5e                   	pop    %esi
  8001ca:	5f                   	pop    %edi
  8001cb:	5d                   	pop    %ebp
  8001cc:	c3                   	ret    

008001cd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	57                   	push   %edi
  8001d1:	56                   	push   %esi
  8001d2:	53                   	push   %ebx
  8001d3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001db:	8b 75 18             	mov    0x18(%ebp),%esi
  8001de:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ec:	85 c0                	test   %eax,%eax
  8001ee:	7e 28                	jle    800218 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001fb:	00 
  8001fc:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  800203:	00 
  800204:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020b:	00 
  80020c:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  800213:	e8 d0 14 00 00       	call   8016e8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800218:	83 c4 2c             	add    $0x2c,%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5e                   	pop    %esi
  80021d:	5f                   	pop    %edi
  80021e:	5d                   	pop    %ebp
  80021f:	c3                   	ret    

00800220 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800229:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022e:	b8 06 00 00 00       	mov    $0x6,%eax
  800233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800236:	8b 55 08             	mov    0x8(%ebp),%edx
  800239:	89 df                	mov    %ebx,%edi
  80023b:	89 de                	mov    %ebx,%esi
  80023d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023f:	85 c0                	test   %eax,%eax
  800241:	7e 28                	jle    80026b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800243:	89 44 24 10          	mov    %eax,0x10(%esp)
  800247:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80024e:	00 
  80024f:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  800256:	00 
  800257:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025e:	00 
  80025f:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  800266:	e8 7d 14 00 00       	call   8016e8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026b:	83 c4 2c             	add    $0x2c,%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 08 00 00 00       	mov    $0x8,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 28                	jle    8002be <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a1:	00 
  8002a2:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  8002a9:	00 
  8002aa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b1:	00 
  8002b2:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  8002b9:	e8 2a 14 00 00       	call   8016e8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002be:	83 c4 2c             	add    $0x2c,%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	57                   	push   %edi
  8002ca:	56                   	push   %esi
  8002cb:	53                   	push   %ebx
  8002cc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002df:	89 df                	mov    %ebx,%edi
  8002e1:	89 de                	mov    %ebx,%esi
  8002e3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002e5:	85 c0                	test   %eax,%eax
  8002e7:	7e 28                	jle    800311 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ed:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f4:	00 
  8002f5:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  8002fc:	00 
  8002fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800304:	00 
  800305:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  80030c:	e8 d7 13 00 00       	call   8016e8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800311:	83 c4 2c             	add    $0x2c,%esp
  800314:	5b                   	pop    %ebx
  800315:	5e                   	pop    %esi
  800316:	5f                   	pop    %edi
  800317:	5d                   	pop    %ebp
  800318:	c3                   	ret    

00800319 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	57                   	push   %edi
  80031d:	56                   	push   %esi
  80031e:	53                   	push   %ebx
  80031f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800322:	bb 00 00 00 00       	mov    $0x0,%ebx
  800327:	b8 0a 00 00 00       	mov    $0xa,%eax
  80032c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80032f:	8b 55 08             	mov    0x8(%ebp),%edx
  800332:	89 df                	mov    %ebx,%edi
  800334:	89 de                	mov    %ebx,%esi
  800336:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 28                	jle    800364 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800340:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800347:	00 
  800348:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  80034f:	00 
  800350:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800357:	00 
  800358:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  80035f:	e8 84 13 00 00       	call   8016e8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800364:	83 c4 2c             	add    $0x2c,%esp
  800367:	5b                   	pop    %ebx
  800368:	5e                   	pop    %esi
  800369:	5f                   	pop    %edi
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	57                   	push   %edi
  800370:	56                   	push   %esi
  800371:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800372:	be 00 00 00 00       	mov    $0x0,%esi
  800377:	b8 0c 00 00 00       	mov    $0xc,%eax
  80037c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80037f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800382:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800385:	8b 55 08             	mov    0x8(%ebp),%edx
  800388:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5f                   	pop    %edi
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	57                   	push   %edi
  800393:	56                   	push   %esi
  800394:	53                   	push   %ebx
  800395:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800398:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039d:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a5:	89 cb                	mov    %ecx,%ebx
  8003a7:	89 cf                	mov    %ecx,%edi
  8003a9:	89 ce                	mov    %ecx,%esi
  8003ab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003ad:	85 c0                	test   %eax,%eax
  8003af:	7e 28                	jle    8003d9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003b5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003bc:	00 
  8003bd:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  8003c4:	00 
  8003c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003cc:	00 
  8003cd:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  8003d4:	e8 0f 13 00 00       	call   8016e8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003d9:	83 c4 2c             	add    $0x2c,%esp
  8003dc:	5b                   	pop    %ebx
  8003dd:	5e                   	pop    %esi
  8003de:	5f                   	pop    %edi
  8003df:	5d                   	pop    %ebp
  8003e0:	c3                   	ret    

008003e1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8003e1:	55                   	push   %ebp
  8003e2:	89 e5                	mov    %esp,%ebp
  8003e4:	57                   	push   %edi
  8003e5:	56                   	push   %esi
  8003e6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ec:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003f1:	89 d1                	mov    %edx,%ecx
  8003f3:	89 d3                	mov    %edx,%ebx
  8003f5:	89 d7                	mov    %edx,%edi
  8003f7:	89 d6                	mov    %edx,%esi
  8003f9:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8003fb:	5b                   	pop    %ebx
  8003fc:	5e                   	pop    %esi
  8003fd:	5f                   	pop    %edi
  8003fe:	5d                   	pop    %ebp
  8003ff:	c3                   	ret    

00800400 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	57                   	push   %edi
  800404:	56                   	push   %esi
  800405:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800406:	bb 00 00 00 00       	mov    $0x0,%ebx
  80040b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800410:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800413:	8b 55 08             	mov    0x8(%ebp),%edx
  800416:	89 df                	mov    %ebx,%edi
  800418:	89 de                	mov    %ebx,%esi
  80041a:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  80041c:	5b                   	pop    %ebx
  80041d:	5e                   	pop    %esi
  80041e:	5f                   	pop    %edi
  80041f:	5d                   	pop    %ebp
  800420:	c3                   	ret    

00800421 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	57                   	push   %edi
  800425:	56                   	push   %esi
  800426:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800427:	bb 00 00 00 00       	mov    $0x0,%ebx
  80042c:	b8 10 00 00 00       	mov    $0x10,%eax
  800431:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800434:	8b 55 08             	mov    0x8(%ebp),%edx
  800437:	89 df                	mov    %ebx,%edi
  800439:	89 de                	mov    %ebx,%esi
  80043b:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  80043d:	5b                   	pop    %ebx
  80043e:	5e                   	pop    %esi
  80043f:	5f                   	pop    %edi
  800440:	5d                   	pop    %ebp
  800441:	c3                   	ret    
	...

00800444 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800444:	55                   	push   %ebp
  800445:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800447:	8b 45 08             	mov    0x8(%ebp),%eax
  80044a:	05 00 00 00 30       	add    $0x30000000,%eax
  80044f:	c1 e8 0c             	shr    $0xc,%eax
}
  800452:	5d                   	pop    %ebp
  800453:	c3                   	ret    

00800454 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80045a:	8b 45 08             	mov    0x8(%ebp),%eax
  80045d:	89 04 24             	mov    %eax,(%esp)
  800460:	e8 df ff ff ff       	call   800444 <fd2num>
  800465:	c1 e0 0c             	shl    $0xc,%eax
  800468:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80046d:	c9                   	leave  
  80046e:	c3                   	ret    

0080046f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80046f:	55                   	push   %ebp
  800470:	89 e5                	mov    %esp,%ebp
  800472:	53                   	push   %ebx
  800473:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800476:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80047b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80047d:	89 c2                	mov    %eax,%edx
  80047f:	c1 ea 16             	shr    $0x16,%edx
  800482:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800489:	f6 c2 01             	test   $0x1,%dl
  80048c:	74 11                	je     80049f <fd_alloc+0x30>
  80048e:	89 c2                	mov    %eax,%edx
  800490:	c1 ea 0c             	shr    $0xc,%edx
  800493:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80049a:	f6 c2 01             	test   $0x1,%dl
  80049d:	75 09                	jne    8004a8 <fd_alloc+0x39>
			*fd_store = fd;
  80049f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8004a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a6:	eb 17                	jmp    8004bf <fd_alloc+0x50>
  8004a8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8004ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8004b2:	75 c7                	jne    80047b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8004b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8004ba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8004bf:	5b                   	pop    %ebx
  8004c0:	5d                   	pop    %ebp
  8004c1:	c3                   	ret    

008004c2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004c8:	83 f8 1f             	cmp    $0x1f,%eax
  8004cb:	77 36                	ja     800503 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004cd:	c1 e0 0c             	shl    $0xc,%eax
  8004d0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004d5:	89 c2                	mov    %eax,%edx
  8004d7:	c1 ea 16             	shr    $0x16,%edx
  8004da:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004e1:	f6 c2 01             	test   $0x1,%dl
  8004e4:	74 24                	je     80050a <fd_lookup+0x48>
  8004e6:	89 c2                	mov    %eax,%edx
  8004e8:	c1 ea 0c             	shr    $0xc,%edx
  8004eb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004f2:	f6 c2 01             	test   $0x1,%dl
  8004f5:	74 1a                	je     800511 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004fa:	89 02                	mov    %eax,(%edx)
	return 0;
  8004fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800501:	eb 13                	jmp    800516 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800503:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800508:	eb 0c                	jmp    800516 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80050a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80050f:	eb 05                	jmp    800516 <fd_lookup+0x54>
  800511:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800516:	5d                   	pop    %ebp
  800517:	c3                   	ret    

00800518 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800518:	55                   	push   %ebp
  800519:	89 e5                	mov    %esp,%ebp
  80051b:	53                   	push   %ebx
  80051c:	83 ec 14             	sub    $0x14,%esp
  80051f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800522:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800525:	ba 00 00 00 00       	mov    $0x0,%edx
  80052a:	eb 0e                	jmp    80053a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80052c:	39 08                	cmp    %ecx,(%eax)
  80052e:	75 09                	jne    800539 <dev_lookup+0x21>
			*dev = devtab[i];
  800530:	89 03                	mov    %eax,(%ebx)
			return 0;
  800532:	b8 00 00 00 00       	mov    $0x0,%eax
  800537:	eb 33                	jmp    80056c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800539:	42                   	inc    %edx
  80053a:	8b 04 95 34 25 80 00 	mov    0x802534(,%edx,4),%eax
  800541:	85 c0                	test   %eax,%eax
  800543:	75 e7                	jne    80052c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800545:	a1 08 40 80 00       	mov    0x804008,%eax
  80054a:	8b 40 48             	mov    0x48(%eax),%eax
  80054d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800551:	89 44 24 04          	mov    %eax,0x4(%esp)
  800555:	c7 04 24 b8 24 80 00 	movl   $0x8024b8,(%esp)
  80055c:	e8 7f 12 00 00       	call   8017e0 <cprintf>
	*dev = 0;
  800561:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800567:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80056c:	83 c4 14             	add    $0x14,%esp
  80056f:	5b                   	pop    %ebx
  800570:	5d                   	pop    %ebp
  800571:	c3                   	ret    

00800572 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800572:	55                   	push   %ebp
  800573:	89 e5                	mov    %esp,%ebp
  800575:	56                   	push   %esi
  800576:	53                   	push   %ebx
  800577:	83 ec 30             	sub    $0x30,%esp
  80057a:	8b 75 08             	mov    0x8(%ebp),%esi
  80057d:	8a 45 0c             	mov    0xc(%ebp),%al
  800580:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800583:	89 34 24             	mov    %esi,(%esp)
  800586:	e8 b9 fe ff ff       	call   800444 <fd2num>
  80058b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80058e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800592:	89 04 24             	mov    %eax,(%esp)
  800595:	e8 28 ff ff ff       	call   8004c2 <fd_lookup>
  80059a:	89 c3                	mov    %eax,%ebx
  80059c:	85 c0                	test   %eax,%eax
  80059e:	78 05                	js     8005a5 <fd_close+0x33>
	    || fd != fd2)
  8005a0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8005a3:	74 0d                	je     8005b2 <fd_close+0x40>
		return (must_exist ? r : 0);
  8005a5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8005a9:	75 46                	jne    8005f1 <fd_close+0x7f>
  8005ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005b0:	eb 3f                	jmp    8005f1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8005b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8005b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b9:	8b 06                	mov    (%esi),%eax
  8005bb:	89 04 24             	mov    %eax,(%esp)
  8005be:	e8 55 ff ff ff       	call   800518 <dev_lookup>
  8005c3:	89 c3                	mov    %eax,%ebx
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	78 18                	js     8005e1 <fd_close+0x6f>
		if (dev->dev_close)
  8005c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005cc:	8b 40 10             	mov    0x10(%eax),%eax
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	74 09                	je     8005dc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005d3:	89 34 24             	mov    %esi,(%esp)
  8005d6:	ff d0                	call   *%eax
  8005d8:	89 c3                	mov    %eax,%ebx
  8005da:	eb 05                	jmp    8005e1 <fd_close+0x6f>
		else
			r = 0;
  8005dc:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005ec:	e8 2f fc ff ff       	call   800220 <sys_page_unmap>
	return r;
}
  8005f1:	89 d8                	mov    %ebx,%eax
  8005f3:	83 c4 30             	add    $0x30,%esp
  8005f6:	5b                   	pop    %ebx
  8005f7:	5e                   	pop    %esi
  8005f8:	5d                   	pop    %ebp
  8005f9:	c3                   	ret    

008005fa <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005fa:	55                   	push   %ebp
  8005fb:	89 e5                	mov    %esp,%ebp
  8005fd:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800600:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800603:	89 44 24 04          	mov    %eax,0x4(%esp)
  800607:	8b 45 08             	mov    0x8(%ebp),%eax
  80060a:	89 04 24             	mov    %eax,(%esp)
  80060d:	e8 b0 fe ff ff       	call   8004c2 <fd_lookup>
  800612:	85 c0                	test   %eax,%eax
  800614:	78 13                	js     800629 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800616:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80061d:	00 
  80061e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800621:	89 04 24             	mov    %eax,(%esp)
  800624:	e8 49 ff ff ff       	call   800572 <fd_close>
}
  800629:	c9                   	leave  
  80062a:	c3                   	ret    

0080062b <close_all>:

void
close_all(void)
{
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
  80062e:	53                   	push   %ebx
  80062f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800632:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800637:	89 1c 24             	mov    %ebx,(%esp)
  80063a:	e8 bb ff ff ff       	call   8005fa <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80063f:	43                   	inc    %ebx
  800640:	83 fb 20             	cmp    $0x20,%ebx
  800643:	75 f2                	jne    800637 <close_all+0xc>
		close(i);
}
  800645:	83 c4 14             	add    $0x14,%esp
  800648:	5b                   	pop    %ebx
  800649:	5d                   	pop    %ebp
  80064a:	c3                   	ret    

0080064b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80064b:	55                   	push   %ebp
  80064c:	89 e5                	mov    %esp,%ebp
  80064e:	57                   	push   %edi
  80064f:	56                   	push   %esi
  800650:	53                   	push   %ebx
  800651:	83 ec 4c             	sub    $0x4c,%esp
  800654:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800657:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80065a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065e:	8b 45 08             	mov    0x8(%ebp),%eax
  800661:	89 04 24             	mov    %eax,(%esp)
  800664:	e8 59 fe ff ff       	call   8004c2 <fd_lookup>
  800669:	89 c3                	mov    %eax,%ebx
  80066b:	85 c0                	test   %eax,%eax
  80066d:	0f 88 e3 00 00 00    	js     800756 <dup+0x10b>
		return r;
	close(newfdnum);
  800673:	89 3c 24             	mov    %edi,(%esp)
  800676:	e8 7f ff ff ff       	call   8005fa <close>

	newfd = INDEX2FD(newfdnum);
  80067b:	89 fe                	mov    %edi,%esi
  80067d:	c1 e6 0c             	shl    $0xc,%esi
  800680:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800686:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800689:	89 04 24             	mov    %eax,(%esp)
  80068c:	e8 c3 fd ff ff       	call   800454 <fd2data>
  800691:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800693:	89 34 24             	mov    %esi,(%esp)
  800696:	e8 b9 fd ff ff       	call   800454 <fd2data>
  80069b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80069e:	89 d8                	mov    %ebx,%eax
  8006a0:	c1 e8 16             	shr    $0x16,%eax
  8006a3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8006aa:	a8 01                	test   $0x1,%al
  8006ac:	74 46                	je     8006f4 <dup+0xa9>
  8006ae:	89 d8                	mov    %ebx,%eax
  8006b0:	c1 e8 0c             	shr    $0xc,%eax
  8006b3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8006ba:	f6 c2 01             	test   $0x1,%dl
  8006bd:	74 35                	je     8006f4 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8006bf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8006cb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006dd:	00 
  8006de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006e9:	e8 df fa ff ff       	call   8001cd <sys_page_map>
  8006ee:	89 c3                	mov    %eax,%ebx
  8006f0:	85 c0                	test   %eax,%eax
  8006f2:	78 3b                	js     80072f <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006f7:	89 c2                	mov    %eax,%edx
  8006f9:	c1 ea 0c             	shr    $0xc,%edx
  8006fc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800703:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800709:	89 54 24 10          	mov    %edx,0x10(%esp)
  80070d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800711:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800718:	00 
  800719:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800724:	e8 a4 fa ff ff       	call   8001cd <sys_page_map>
  800729:	89 c3                	mov    %eax,%ebx
  80072b:	85 c0                	test   %eax,%eax
  80072d:	79 25                	jns    800754 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80072f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800733:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80073a:	e8 e1 fa ff ff       	call   800220 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80073f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800742:	89 44 24 04          	mov    %eax,0x4(%esp)
  800746:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80074d:	e8 ce fa ff ff       	call   800220 <sys_page_unmap>
	return r;
  800752:	eb 02                	jmp    800756 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800754:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800756:	89 d8                	mov    %ebx,%eax
  800758:	83 c4 4c             	add    $0x4c,%esp
  80075b:	5b                   	pop    %ebx
  80075c:	5e                   	pop    %esi
  80075d:	5f                   	pop    %edi
  80075e:	5d                   	pop    %ebp
  80075f:	c3                   	ret    

00800760 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	53                   	push   %ebx
  800764:	83 ec 24             	sub    $0x24,%esp
  800767:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80076a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80076d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800771:	89 1c 24             	mov    %ebx,(%esp)
  800774:	e8 49 fd ff ff       	call   8004c2 <fd_lookup>
  800779:	85 c0                	test   %eax,%eax
  80077b:	78 6d                	js     8007ea <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80077d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800780:	89 44 24 04          	mov    %eax,0x4(%esp)
  800784:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800787:	8b 00                	mov    (%eax),%eax
  800789:	89 04 24             	mov    %eax,(%esp)
  80078c:	e8 87 fd ff ff       	call   800518 <dev_lookup>
  800791:	85 c0                	test   %eax,%eax
  800793:	78 55                	js     8007ea <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800795:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800798:	8b 50 08             	mov    0x8(%eax),%edx
  80079b:	83 e2 03             	and    $0x3,%edx
  80079e:	83 fa 01             	cmp    $0x1,%edx
  8007a1:	75 23                	jne    8007c6 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8007a3:	a1 08 40 80 00       	mov    0x804008,%eax
  8007a8:	8b 40 48             	mov    0x48(%eax),%eax
  8007ab:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b3:	c7 04 24 f9 24 80 00 	movl   $0x8024f9,(%esp)
  8007ba:	e8 21 10 00 00       	call   8017e0 <cprintf>
		return -E_INVAL;
  8007bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c4:	eb 24                	jmp    8007ea <read+0x8a>
	}
	if (!dev->dev_read)
  8007c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007c9:	8b 52 08             	mov    0x8(%edx),%edx
  8007cc:	85 d2                	test   %edx,%edx
  8007ce:	74 15                	je     8007e5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8007d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007da:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007de:	89 04 24             	mov    %eax,(%esp)
  8007e1:	ff d2                	call   *%edx
  8007e3:	eb 05                	jmp    8007ea <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8007e5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8007ea:	83 c4 24             	add    $0x24,%esp
  8007ed:	5b                   	pop    %ebx
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	57                   	push   %edi
  8007f4:	56                   	push   %esi
  8007f5:	53                   	push   %ebx
  8007f6:	83 ec 1c             	sub    $0x1c,%esp
  8007f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007fc:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800804:	eb 23                	jmp    800829 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800806:	89 f0                	mov    %esi,%eax
  800808:	29 d8                	sub    %ebx,%eax
  80080a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800811:	01 d8                	add    %ebx,%eax
  800813:	89 44 24 04          	mov    %eax,0x4(%esp)
  800817:	89 3c 24             	mov    %edi,(%esp)
  80081a:	e8 41 ff ff ff       	call   800760 <read>
		if (m < 0)
  80081f:	85 c0                	test   %eax,%eax
  800821:	78 10                	js     800833 <readn+0x43>
			return m;
		if (m == 0)
  800823:	85 c0                	test   %eax,%eax
  800825:	74 0a                	je     800831 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800827:	01 c3                	add    %eax,%ebx
  800829:	39 f3                	cmp    %esi,%ebx
  80082b:	72 d9                	jb     800806 <readn+0x16>
  80082d:	89 d8                	mov    %ebx,%eax
  80082f:	eb 02                	jmp    800833 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800831:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800833:	83 c4 1c             	add    $0x1c,%esp
  800836:	5b                   	pop    %ebx
  800837:	5e                   	pop    %esi
  800838:	5f                   	pop    %edi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	83 ec 24             	sub    $0x24,%esp
  800842:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800845:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800848:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084c:	89 1c 24             	mov    %ebx,(%esp)
  80084f:	e8 6e fc ff ff       	call   8004c2 <fd_lookup>
  800854:	85 c0                	test   %eax,%eax
  800856:	78 68                	js     8008c0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800858:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800862:	8b 00                	mov    (%eax),%eax
  800864:	89 04 24             	mov    %eax,(%esp)
  800867:	e8 ac fc ff ff       	call   800518 <dev_lookup>
  80086c:	85 c0                	test   %eax,%eax
  80086e:	78 50                	js     8008c0 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800870:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800873:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800877:	75 23                	jne    80089c <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800879:	a1 08 40 80 00       	mov    0x804008,%eax
  80087e:	8b 40 48             	mov    0x48(%eax),%eax
  800881:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800885:	89 44 24 04          	mov    %eax,0x4(%esp)
  800889:	c7 04 24 15 25 80 00 	movl   $0x802515,(%esp)
  800890:	e8 4b 0f 00 00       	call   8017e0 <cprintf>
		return -E_INVAL;
  800895:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80089a:	eb 24                	jmp    8008c0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80089c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80089f:	8b 52 0c             	mov    0xc(%edx),%edx
  8008a2:	85 d2                	test   %edx,%edx
  8008a4:	74 15                	je     8008bb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8008a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008b4:	89 04 24             	mov    %eax,(%esp)
  8008b7:	ff d2                	call   *%edx
  8008b9:	eb 05                	jmp    8008c0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8008bb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8008c0:	83 c4 24             	add    $0x24,%esp
  8008c3:	5b                   	pop    %ebx
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008cc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8008cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	89 04 24             	mov    %eax,(%esp)
  8008d9:	e8 e4 fb ff ff       	call   8004c2 <fd_lookup>
  8008de:	85 c0                	test   %eax,%eax
  8008e0:	78 0e                	js     8008f0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    

008008f2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	53                   	push   %ebx
  8008f6:	83 ec 24             	sub    $0x24,%esp
  8008f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800903:	89 1c 24             	mov    %ebx,(%esp)
  800906:	e8 b7 fb ff ff       	call   8004c2 <fd_lookup>
  80090b:	85 c0                	test   %eax,%eax
  80090d:	78 61                	js     800970 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80090f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800912:	89 44 24 04          	mov    %eax,0x4(%esp)
  800916:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800919:	8b 00                	mov    (%eax),%eax
  80091b:	89 04 24             	mov    %eax,(%esp)
  80091e:	e8 f5 fb ff ff       	call   800518 <dev_lookup>
  800923:	85 c0                	test   %eax,%eax
  800925:	78 49                	js     800970 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800927:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80092a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80092e:	75 23                	jne    800953 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800930:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800935:	8b 40 48             	mov    0x48(%eax),%eax
  800938:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80093c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800940:	c7 04 24 d8 24 80 00 	movl   $0x8024d8,(%esp)
  800947:	e8 94 0e 00 00       	call   8017e0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80094c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800951:	eb 1d                	jmp    800970 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800953:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800956:	8b 52 18             	mov    0x18(%edx),%edx
  800959:	85 d2                	test   %edx,%edx
  80095b:	74 0e                	je     80096b <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80095d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800960:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800964:	89 04 24             	mov    %eax,(%esp)
  800967:	ff d2                	call   *%edx
  800969:	eb 05                	jmp    800970 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80096b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800970:	83 c4 24             	add    $0x24,%esp
  800973:	5b                   	pop    %ebx
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	53                   	push   %ebx
  80097a:	83 ec 24             	sub    $0x24,%esp
  80097d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800980:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800983:	89 44 24 04          	mov    %eax,0x4(%esp)
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	89 04 24             	mov    %eax,(%esp)
  80098d:	e8 30 fb ff ff       	call   8004c2 <fd_lookup>
  800992:	85 c0                	test   %eax,%eax
  800994:	78 52                	js     8009e8 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800996:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800999:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009a0:	8b 00                	mov    (%eax),%eax
  8009a2:	89 04 24             	mov    %eax,(%esp)
  8009a5:	e8 6e fb ff ff       	call   800518 <dev_lookup>
  8009aa:	85 c0                	test   %eax,%eax
  8009ac:	78 3a                	js     8009e8 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8009ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8009b5:	74 2c                	je     8009e3 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8009b7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8009ba:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8009c1:	00 00 00 
	stat->st_isdir = 0;
  8009c4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8009cb:	00 00 00 
	stat->st_dev = dev;
  8009ce:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009db:	89 14 24             	mov    %edx,(%esp)
  8009de:	ff 50 14             	call   *0x14(%eax)
  8009e1:	eb 05                	jmp    8009e8 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8009e3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8009e8:	83 c4 24             	add    $0x24,%esp
  8009eb:	5b                   	pop    %ebx
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    

008009ee <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	56                   	push   %esi
  8009f2:	53                   	push   %ebx
  8009f3:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009fd:	00 
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	89 04 24             	mov    %eax,(%esp)
  800a04:	e8 2a 02 00 00       	call   800c33 <open>
  800a09:	89 c3                	mov    %eax,%ebx
  800a0b:	85 c0                	test   %eax,%eax
  800a0d:	78 1b                	js     800a2a <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a12:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a16:	89 1c 24             	mov    %ebx,(%esp)
  800a19:	e8 58 ff ff ff       	call   800976 <fstat>
  800a1e:	89 c6                	mov    %eax,%esi
	close(fd);
  800a20:	89 1c 24             	mov    %ebx,(%esp)
  800a23:	e8 d2 fb ff ff       	call   8005fa <close>
	return r;
  800a28:	89 f3                	mov    %esi,%ebx
}
  800a2a:	89 d8                	mov    %ebx,%eax
  800a2c:	83 c4 10             	add    $0x10,%esp
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5d                   	pop    %ebp
  800a32:	c3                   	ret    
	...

00800a34 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	83 ec 10             	sub    $0x10,%esp
  800a3c:	89 c3                	mov    %eax,%ebx
  800a3e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a40:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a47:	75 11                	jne    800a5a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a50:	e8 4e 17 00 00       	call   8021a3 <ipc_find_env>
  800a55:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a5a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a61:	00 
  800a62:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a69:	00 
  800a6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a6e:	a1 00 40 80 00       	mov    0x804000,%eax
  800a73:	89 04 24             	mov    %eax,(%esp)
  800a76:	e8 a5 16 00 00       	call   802120 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a7b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a82:	00 
  800a83:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a8e:	e8 1d 16 00 00       	call   8020b0 <ipc_recv>
}
  800a93:	83 c4 10             	add    $0x10,%esp
  800a96:	5b                   	pop    %ebx
  800a97:	5e                   	pop    %esi
  800a98:	5d                   	pop    %ebp
  800a99:	c3                   	ret    

00800a9a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a9a:	55                   	push   %ebp
  800a9b:	89 e5                	mov    %esp,%ebp
  800a9d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	8b 40 0c             	mov    0xc(%eax),%eax
  800aa6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aae:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800ab3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab8:	b8 02 00 00 00       	mov    $0x2,%eax
  800abd:	e8 72 ff ff ff       	call   800a34 <fsipc>
}
  800ac2:	c9                   	leave  
  800ac3:	c3                   	ret    

00800ac4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800ac4:	55                   	push   %ebp
  800ac5:	89 e5                	mov    %esp,%ebp
  800ac7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
  800acd:	8b 40 0c             	mov    0xc(%eax),%eax
  800ad0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ad5:	ba 00 00 00 00       	mov    $0x0,%edx
  800ada:	b8 06 00 00 00       	mov    $0x6,%eax
  800adf:	e8 50 ff ff ff       	call   800a34 <fsipc>
}
  800ae4:	c9                   	leave  
  800ae5:	c3                   	ret    

00800ae6 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	53                   	push   %ebx
  800aea:	83 ec 14             	sub    $0x14,%esp
  800aed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800af0:	8b 45 08             	mov    0x8(%ebp),%eax
  800af3:	8b 40 0c             	mov    0xc(%eax),%eax
  800af6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800afb:	ba 00 00 00 00       	mov    $0x0,%edx
  800b00:	b8 05 00 00 00       	mov    $0x5,%eax
  800b05:	e8 2a ff ff ff       	call   800a34 <fsipc>
  800b0a:	85 c0                	test   %eax,%eax
  800b0c:	78 2b                	js     800b39 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800b0e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b15:	00 
  800b16:	89 1c 24             	mov    %ebx,(%esp)
  800b19:	e8 6d 12 00 00       	call   801d8b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b1e:	a1 80 50 80 00       	mov    0x805080,%eax
  800b23:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b29:	a1 84 50 80 00       	mov    0x805084,%eax
  800b2e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800b34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b39:	83 c4 14             	add    $0x14,%esp
  800b3c:	5b                   	pop    %ebx
  800b3d:	5d                   	pop    %ebp
  800b3e:	c3                   	ret    

00800b3f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	83 ec 18             	sub    $0x18,%esp
  800b45:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800b48:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4b:	8b 52 0c             	mov    0xc(%edx),%edx
  800b4e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800b54:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  800b59:	89 c2                	mov    %eax,%edx
  800b5b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800b60:	76 05                	jbe    800b67 <devfile_write+0x28>
  800b62:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  800b67:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b72:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b79:	e8 f0 13 00 00       	call   801f6e <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800b7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b83:	b8 04 00 00 00       	mov    $0x4,%eax
  800b88:	e8 a7 fe ff ff       	call   800a34 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	56                   	push   %esi
  800b93:	53                   	push   %ebx
  800b94:	83 ec 10             	sub    $0x10,%esp
  800b97:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9d:	8b 40 0c             	mov    0xc(%eax),%eax
  800ba0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ba5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800bab:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb0:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb5:	e8 7a fe ff ff       	call   800a34 <fsipc>
  800bba:	89 c3                	mov    %eax,%ebx
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	78 6a                	js     800c2a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800bc0:	39 c6                	cmp    %eax,%esi
  800bc2:	73 24                	jae    800be8 <devfile_read+0x59>
  800bc4:	c7 44 24 0c 48 25 80 	movl   $0x802548,0xc(%esp)
  800bcb:	00 
  800bcc:	c7 44 24 08 4f 25 80 	movl   $0x80254f,0x8(%esp)
  800bd3:	00 
  800bd4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800bdb:	00 
  800bdc:	c7 04 24 64 25 80 00 	movl   $0x802564,(%esp)
  800be3:	e8 00 0b 00 00       	call   8016e8 <_panic>
	assert(r <= PGSIZE);
  800be8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800bed:	7e 24                	jle    800c13 <devfile_read+0x84>
  800bef:	c7 44 24 0c 6f 25 80 	movl   $0x80256f,0xc(%esp)
  800bf6:	00 
  800bf7:	c7 44 24 08 4f 25 80 	movl   $0x80254f,0x8(%esp)
  800bfe:	00 
  800bff:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800c06:	00 
  800c07:	c7 04 24 64 25 80 00 	movl   $0x802564,(%esp)
  800c0e:	e8 d5 0a 00 00       	call   8016e8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c13:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c17:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c1e:	00 
  800c1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c22:	89 04 24             	mov    %eax,(%esp)
  800c25:	e8 da 12 00 00       	call   801f04 <memmove>
	return r;
}
  800c2a:	89 d8                	mov    %ebx,%eax
  800c2c:	83 c4 10             	add    $0x10,%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 20             	sub    $0x20,%esp
  800c3b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c3e:	89 34 24             	mov    %esi,(%esp)
  800c41:	e8 12 11 00 00       	call   801d58 <strlen>
  800c46:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c4b:	7f 60                	jg     800cad <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c50:	89 04 24             	mov    %eax,(%esp)
  800c53:	e8 17 f8 ff ff       	call   80046f <fd_alloc>
  800c58:	89 c3                	mov    %eax,%ebx
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	78 54                	js     800cb2 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800c5e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c62:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c69:	e8 1d 11 00 00       	call   801d8b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c71:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c76:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c79:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7e:	e8 b1 fd ff ff       	call   800a34 <fsipc>
  800c83:	89 c3                	mov    %eax,%ebx
  800c85:	85 c0                	test   %eax,%eax
  800c87:	79 15                	jns    800c9e <open+0x6b>
		fd_close(fd, 0);
  800c89:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c90:	00 
  800c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c94:	89 04 24             	mov    %eax,(%esp)
  800c97:	e8 d6 f8 ff ff       	call   800572 <fd_close>
		return r;
  800c9c:	eb 14                	jmp    800cb2 <open+0x7f>
	}

	return fd2num(fd);
  800c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca1:	89 04 24             	mov    %eax,(%esp)
  800ca4:	e8 9b f7 ff ff       	call   800444 <fd2num>
  800ca9:	89 c3                	mov    %eax,%ebx
  800cab:	eb 05                	jmp    800cb2 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cad:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800cb2:	89 d8                	mov    %ebx,%eax
  800cb4:	83 c4 20             	add    $0x20,%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800cc1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc6:	b8 08 00 00 00       	mov    $0x8,%eax
  800ccb:	e8 64 fd ff ff       	call   800a34 <fsipc>
}
  800cd0:	c9                   	leave  
  800cd1:	c3                   	ret    
	...

00800cd4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800cda:	c7 44 24 04 7b 25 80 	movl   $0x80257b,0x4(%esp)
  800ce1:	00 
  800ce2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce5:	89 04 24             	mov    %eax,(%esp)
  800ce8:	e8 9e 10 00 00       	call   801d8b <strcpy>
	return 0;
}
  800ced:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf2:	c9                   	leave  
  800cf3:	c3                   	ret    

00800cf4 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 14             	sub    $0x14,%esp
  800cfb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800cfe:	89 1c 24             	mov    %ebx,(%esp)
  800d01:	e8 e2 14 00 00       	call   8021e8 <pageref>
  800d06:	83 f8 01             	cmp    $0x1,%eax
  800d09:	75 0d                	jne    800d18 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  800d0b:	8b 43 0c             	mov    0xc(%ebx),%eax
  800d0e:	89 04 24             	mov    %eax,(%esp)
  800d11:	e8 1f 03 00 00       	call   801035 <nsipc_close>
  800d16:	eb 05                	jmp    800d1d <devsock_close+0x29>
	else
		return 0;
  800d18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d1d:	83 c4 14             	add    $0x14,%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5d                   	pop    %ebp
  800d22:	c3                   	ret    

00800d23 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800d29:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d30:	00 
  800d31:	8b 45 10             	mov    0x10(%ebp),%eax
  800d34:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d42:	8b 40 0c             	mov    0xc(%eax),%eax
  800d45:	89 04 24             	mov    %eax,(%esp)
  800d48:	e8 e3 03 00 00       	call   801130 <nsipc_send>
}
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800d55:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d5c:	00 
  800d5d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d60:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d67:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	8b 40 0c             	mov    0xc(%eax),%eax
  800d71:	89 04 24             	mov    %eax,(%esp)
  800d74:	e8 37 03 00 00       	call   8010b0 <nsipc_recv>
}
  800d79:	c9                   	leave  
  800d7a:	c3                   	ret    

00800d7b <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	56                   	push   %esi
  800d7f:	53                   	push   %ebx
  800d80:	83 ec 20             	sub    $0x20,%esp
  800d83:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800d85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d88:	89 04 24             	mov    %eax,(%esp)
  800d8b:	e8 df f6 ff ff       	call   80046f <fd_alloc>
  800d90:	89 c3                	mov    %eax,%ebx
  800d92:	85 c0                	test   %eax,%eax
  800d94:	78 21                	js     800db7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800d96:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800d9d:	00 
  800d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800dac:	e8 c8 f3 ff ff       	call   800179 <sys_page_alloc>
  800db1:	89 c3                	mov    %eax,%ebx
  800db3:	85 c0                	test   %eax,%eax
  800db5:	79 0a                	jns    800dc1 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  800db7:	89 34 24             	mov    %esi,(%esp)
  800dba:	e8 76 02 00 00       	call   801035 <nsipc_close>
		return r;
  800dbf:	eb 22                	jmp    800de3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800dc1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dca:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dcf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800dd6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800dd9:	89 04 24             	mov    %eax,(%esp)
  800ddc:	e8 63 f6 ff ff       	call   800444 <fd2num>
  800de1:	89 c3                	mov    %eax,%ebx
}
  800de3:	89 d8                	mov    %ebx,%eax
  800de5:	83 c4 20             	add    $0x20,%esp
  800de8:	5b                   	pop    %ebx
  800de9:	5e                   	pop    %esi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800df2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800df5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800df9:	89 04 24             	mov    %eax,(%esp)
  800dfc:	e8 c1 f6 ff ff       	call   8004c2 <fd_lookup>
  800e01:	85 c0                	test   %eax,%eax
  800e03:	78 17                	js     800e1c <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e08:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e0e:	39 10                	cmp    %edx,(%eax)
  800e10:	75 05                	jne    800e17 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800e12:	8b 40 0c             	mov    0xc(%eax),%eax
  800e15:	eb 05                	jmp    800e1c <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800e17:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800e1c:	c9                   	leave  
  800e1d:	c3                   	ret    

00800e1e <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e24:	8b 45 08             	mov    0x8(%ebp),%eax
  800e27:	e8 c0 ff ff ff       	call   800dec <fd2sockid>
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	78 1f                	js     800e4f <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800e30:	8b 55 10             	mov    0x10(%ebp),%edx
  800e33:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e3e:	89 04 24             	mov    %eax,(%esp)
  800e41:	e8 38 01 00 00       	call   800f7e <nsipc_accept>
  800e46:	85 c0                	test   %eax,%eax
  800e48:	78 05                	js     800e4f <accept+0x31>
		return r;
	return alloc_sockfd(r);
  800e4a:	e8 2c ff ff ff       	call   800d7b <alloc_sockfd>
}
  800e4f:	c9                   	leave  
  800e50:	c3                   	ret    

00800e51 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e57:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5a:	e8 8d ff ff ff       	call   800dec <fd2sockid>
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	78 16                	js     800e79 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  800e63:	8b 55 10             	mov    0x10(%ebp),%edx
  800e66:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e71:	89 04 24             	mov    %eax,(%esp)
  800e74:	e8 5b 01 00 00       	call   800fd4 <nsipc_bind>
}
  800e79:	c9                   	leave  
  800e7a:	c3                   	ret    

00800e7b <shutdown>:

int
shutdown(int s, int how)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e81:	8b 45 08             	mov    0x8(%ebp),%eax
  800e84:	e8 63 ff ff ff       	call   800dec <fd2sockid>
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	78 0f                	js     800e9c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800e8d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e90:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e94:	89 04 24             	mov    %eax,(%esp)
  800e97:	e8 77 01 00 00       	call   801013 <nsipc_shutdown>
}
  800e9c:	c9                   	leave  
  800e9d:	c3                   	ret    

00800e9e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ea4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea7:	e8 40 ff ff ff       	call   800dec <fd2sockid>
  800eac:	85 c0                	test   %eax,%eax
  800eae:	78 16                	js     800ec6 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  800eb0:	8b 55 10             	mov    0x10(%ebp),%edx
  800eb3:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eba:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ebe:	89 04 24             	mov    %eax,(%esp)
  800ec1:	e8 89 01 00 00       	call   80104f <nsipc_connect>
}
  800ec6:	c9                   	leave  
  800ec7:	c3                   	ret    

00800ec8 <listen>:

int
listen(int s, int backlog)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ece:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed1:	e8 16 ff ff ff       	call   800dec <fd2sockid>
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	78 0f                	js     800ee9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800eda:	8b 55 0c             	mov    0xc(%ebp),%edx
  800edd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ee1:	89 04 24             	mov    %eax,(%esp)
  800ee4:	e8 a5 01 00 00       	call   80108e <nsipc_listen>
}
  800ee9:	c9                   	leave  
  800eea:	c3                   	ret    

00800eeb <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800ef1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ef8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eff:	8b 45 08             	mov    0x8(%ebp),%eax
  800f02:	89 04 24             	mov    %eax,(%esp)
  800f05:	e8 99 02 00 00       	call   8011a3 <nsipc_socket>
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	78 05                	js     800f13 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  800f0e:	e8 68 fe ff ff       	call   800d7b <alloc_sockfd>
}
  800f13:	c9                   	leave  
  800f14:	c3                   	ret    
  800f15:	00 00                	add    %al,(%eax)
	...

00800f18 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	53                   	push   %ebx
  800f1c:	83 ec 14             	sub    $0x14,%esp
  800f1f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800f21:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800f28:	75 11                	jne    800f3b <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800f2a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f31:	e8 6d 12 00 00       	call   8021a3 <ipc_find_env>
  800f36:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800f3b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800f42:	00 
  800f43:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  800f4a:	00 
  800f4b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f4f:	a1 04 40 80 00       	mov    0x804004,%eax
  800f54:	89 04 24             	mov    %eax,(%esp)
  800f57:	e8 c4 11 00 00       	call   802120 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800f5c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f63:	00 
  800f64:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f6b:	00 
  800f6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f73:	e8 38 11 00 00       	call   8020b0 <ipc_recv>
}
  800f78:	83 c4 14             	add    $0x14,%esp
  800f7b:	5b                   	pop    %ebx
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    

00800f7e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	56                   	push   %esi
  800f82:	53                   	push   %ebx
  800f83:	83 ec 10             	sub    $0x10,%esp
  800f86:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800f89:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800f91:	8b 06                	mov    (%esi),%eax
  800f93:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800f98:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9d:	e8 76 ff ff ff       	call   800f18 <nsipc>
  800fa2:	89 c3                	mov    %eax,%ebx
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	78 23                	js     800fcb <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800fa8:	a1 10 60 80 00       	mov    0x806010,%eax
  800fad:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb1:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  800fb8:	00 
  800fb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbc:	89 04 24             	mov    %eax,(%esp)
  800fbf:	e8 40 0f 00 00       	call   801f04 <memmove>
		*addrlen = ret->ret_addrlen;
  800fc4:	a1 10 60 80 00       	mov    0x806010,%eax
  800fc9:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  800fcb:	89 d8                	mov    %ebx,%eax
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	5b                   	pop    %ebx
  800fd1:	5e                   	pop    %esi
  800fd2:	5d                   	pop    %ebp
  800fd3:	c3                   	ret    

00800fd4 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	53                   	push   %ebx
  800fd8:	83 ec 14             	sub    $0x14,%esp
  800fdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800fde:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800fe6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fed:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff1:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  800ff8:	e8 07 0f 00 00       	call   801f04 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800ffd:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801003:	b8 02 00 00 00       	mov    $0x2,%eax
  801008:	e8 0b ff ff ff       	call   800f18 <nsipc>
}
  80100d:	83 c4 14             	add    $0x14,%esp
  801010:	5b                   	pop    %ebx
  801011:	5d                   	pop    %ebp
  801012:	c3                   	ret    

00801013 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801019:	8b 45 08             	mov    0x8(%ebp),%eax
  80101c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801021:	8b 45 0c             	mov    0xc(%ebp),%eax
  801024:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801029:	b8 03 00 00 00       	mov    $0x3,%eax
  80102e:	e8 e5 fe ff ff       	call   800f18 <nsipc>
}
  801033:	c9                   	leave  
  801034:	c3                   	ret    

00801035 <nsipc_close>:

int
nsipc_close(int s)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80103b:	8b 45 08             	mov    0x8(%ebp),%eax
  80103e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801043:	b8 04 00 00 00       	mov    $0x4,%eax
  801048:	e8 cb fe ff ff       	call   800f18 <nsipc>
}
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    

0080104f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	53                   	push   %ebx
  801053:	83 ec 14             	sub    $0x14,%esp
  801056:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801059:	8b 45 08             	mov    0x8(%ebp),%eax
  80105c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801061:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801065:	8b 45 0c             	mov    0xc(%ebp),%eax
  801068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80106c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801073:	e8 8c 0e 00 00       	call   801f04 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801078:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80107e:	b8 05 00 00 00       	mov    $0x5,%eax
  801083:	e8 90 fe ff ff       	call   800f18 <nsipc>
}
  801088:	83 c4 14             	add    $0x14,%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    

0080108e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801094:	8b 45 08             	mov    0x8(%ebp),%eax
  801097:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80109c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80109f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8010a4:	b8 06 00 00 00       	mov    $0x6,%eax
  8010a9:	e8 6a fe ff ff       	call   800f18 <nsipc>
}
  8010ae:	c9                   	leave  
  8010af:	c3                   	ret    

008010b0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	56                   	push   %esi
  8010b4:	53                   	push   %ebx
  8010b5:	83 ec 10             	sub    $0x10,%esp
  8010b8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010be:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8010c3:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8010c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8010cc:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8010d1:	b8 07 00 00 00       	mov    $0x7,%eax
  8010d6:	e8 3d fe ff ff       	call   800f18 <nsipc>
  8010db:	89 c3                	mov    %eax,%ebx
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	78 46                	js     801127 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8010e1:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8010e6:	7f 04                	jg     8010ec <nsipc_recv+0x3c>
  8010e8:	39 c6                	cmp    %eax,%esi
  8010ea:	7d 24                	jge    801110 <nsipc_recv+0x60>
  8010ec:	c7 44 24 0c 87 25 80 	movl   $0x802587,0xc(%esp)
  8010f3:	00 
  8010f4:	c7 44 24 08 4f 25 80 	movl   $0x80254f,0x8(%esp)
  8010fb:	00 
  8010fc:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801103:	00 
  801104:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  80110b:	e8 d8 05 00 00       	call   8016e8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801110:	89 44 24 08          	mov    %eax,0x8(%esp)
  801114:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80111b:	00 
  80111c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80111f:	89 04 24             	mov    %eax,(%esp)
  801122:	e8 dd 0d 00 00       	call   801f04 <memmove>
	}

	return r;
}
  801127:	89 d8                	mov    %ebx,%eax
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	5b                   	pop    %ebx
  80112d:	5e                   	pop    %esi
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    

00801130 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	53                   	push   %ebx
  801134:	83 ec 14             	sub    $0x14,%esp
  801137:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80113a:	8b 45 08             	mov    0x8(%ebp),%eax
  80113d:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801142:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801148:	7e 24                	jle    80116e <nsipc_send+0x3e>
  80114a:	c7 44 24 0c a8 25 80 	movl   $0x8025a8,0xc(%esp)
  801151:	00 
  801152:	c7 44 24 08 4f 25 80 	movl   $0x80254f,0x8(%esp)
  801159:	00 
  80115a:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801161:	00 
  801162:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  801169:	e8 7a 05 00 00       	call   8016e8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80116e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801172:	8b 45 0c             	mov    0xc(%ebp),%eax
  801175:	89 44 24 04          	mov    %eax,0x4(%esp)
  801179:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801180:	e8 7f 0d 00 00       	call   801f04 <memmove>
	nsipcbuf.send.req_size = size;
  801185:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80118b:	8b 45 14             	mov    0x14(%ebp),%eax
  80118e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801193:	b8 08 00 00 00       	mov    $0x8,%eax
  801198:	e8 7b fd ff ff       	call   800f18 <nsipc>
}
  80119d:	83 c4 14             	add    $0x14,%esp
  8011a0:	5b                   	pop    %ebx
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    

008011a3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8011a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ac:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8011b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b4:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8011b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8011bc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8011c1:	b8 09 00 00 00       	mov    $0x9,%eax
  8011c6:	e8 4d fd ff ff       	call   800f18 <nsipc>
}
  8011cb:	c9                   	leave  
  8011cc:	c3                   	ret    
  8011cd:	00 00                	add    %al,(%eax)
	...

008011d0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	56                   	push   %esi
  8011d4:	53                   	push   %ebx
  8011d5:	83 ec 10             	sub    $0x10,%esp
  8011d8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8011db:	8b 45 08             	mov    0x8(%ebp),%eax
  8011de:	89 04 24             	mov    %eax,(%esp)
  8011e1:	e8 6e f2 ff ff       	call   800454 <fd2data>
  8011e6:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8011e8:	c7 44 24 04 b4 25 80 	movl   $0x8025b4,0x4(%esp)
  8011ef:	00 
  8011f0:	89 34 24             	mov    %esi,(%esp)
  8011f3:	e8 93 0b 00 00       	call   801d8b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8011f8:	8b 43 04             	mov    0x4(%ebx),%eax
  8011fb:	2b 03                	sub    (%ebx),%eax
  8011fd:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801203:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80120a:	00 00 00 
	stat->st_dev = &devpipe;
  80120d:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801214:	30 80 00 
	return 0;
}
  801217:	b8 00 00 00 00       	mov    $0x0,%eax
  80121c:	83 c4 10             	add    $0x10,%esp
  80121f:	5b                   	pop    %ebx
  801220:	5e                   	pop    %esi
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    

00801223 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
  801226:	53                   	push   %ebx
  801227:	83 ec 14             	sub    $0x14,%esp
  80122a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80122d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801231:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801238:	e8 e3 ef ff ff       	call   800220 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80123d:	89 1c 24             	mov    %ebx,(%esp)
  801240:	e8 0f f2 ff ff       	call   800454 <fd2data>
  801245:	89 44 24 04          	mov    %eax,0x4(%esp)
  801249:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801250:	e8 cb ef ff ff       	call   800220 <sys_page_unmap>
}
  801255:	83 c4 14             	add    $0x14,%esp
  801258:	5b                   	pop    %ebx
  801259:	5d                   	pop    %ebp
  80125a:	c3                   	ret    

0080125b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	57                   	push   %edi
  80125f:	56                   	push   %esi
  801260:	53                   	push   %ebx
  801261:	83 ec 2c             	sub    $0x2c,%esp
  801264:	89 c7                	mov    %eax,%edi
  801266:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801269:	a1 08 40 80 00       	mov    0x804008,%eax
  80126e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801271:	89 3c 24             	mov    %edi,(%esp)
  801274:	e8 6f 0f 00 00       	call   8021e8 <pageref>
  801279:	89 c6                	mov    %eax,%esi
  80127b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80127e:	89 04 24             	mov    %eax,(%esp)
  801281:	e8 62 0f 00 00       	call   8021e8 <pageref>
  801286:	39 c6                	cmp    %eax,%esi
  801288:	0f 94 c0             	sete   %al
  80128b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80128e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801294:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801297:	39 cb                	cmp    %ecx,%ebx
  801299:	75 08                	jne    8012a3 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80129b:	83 c4 2c             	add    $0x2c,%esp
  80129e:	5b                   	pop    %ebx
  80129f:	5e                   	pop    %esi
  8012a0:	5f                   	pop    %edi
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8012a3:	83 f8 01             	cmp    $0x1,%eax
  8012a6:	75 c1                	jne    801269 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8012a8:	8b 42 58             	mov    0x58(%edx),%eax
  8012ab:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8012b2:	00 
  8012b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012b7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012bb:	c7 04 24 bb 25 80 00 	movl   $0x8025bb,(%esp)
  8012c2:	e8 19 05 00 00       	call   8017e0 <cprintf>
  8012c7:	eb a0                	jmp    801269 <_pipeisclosed+0xe>

008012c9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	57                   	push   %edi
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	83 ec 1c             	sub    $0x1c,%esp
  8012d2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8012d5:	89 34 24             	mov    %esi,(%esp)
  8012d8:	e8 77 f1 ff ff       	call   800454 <fd2data>
  8012dd:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012df:	bf 00 00 00 00       	mov    $0x0,%edi
  8012e4:	eb 3c                	jmp    801322 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8012e6:	89 da                	mov    %ebx,%edx
  8012e8:	89 f0                	mov    %esi,%eax
  8012ea:	e8 6c ff ff ff       	call   80125b <_pipeisclosed>
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	75 38                	jne    80132b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8012f3:	e8 62 ee ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8012f8:	8b 43 04             	mov    0x4(%ebx),%eax
  8012fb:	8b 13                	mov    (%ebx),%edx
  8012fd:	83 c2 20             	add    $0x20,%edx
  801300:	39 d0                	cmp    %edx,%eax
  801302:	73 e2                	jae    8012e6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801304:	8b 55 0c             	mov    0xc(%ebp),%edx
  801307:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80130a:	89 c2                	mov    %eax,%edx
  80130c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801312:	79 05                	jns    801319 <devpipe_write+0x50>
  801314:	4a                   	dec    %edx
  801315:	83 ca e0             	or     $0xffffffe0,%edx
  801318:	42                   	inc    %edx
  801319:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80131d:	40                   	inc    %eax
  80131e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801321:	47                   	inc    %edi
  801322:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801325:	75 d1                	jne    8012f8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801327:	89 f8                	mov    %edi,%eax
  801329:	eb 05                	jmp    801330 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80132b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801330:	83 c4 1c             	add    $0x1c,%esp
  801333:	5b                   	pop    %ebx
  801334:	5e                   	pop    %esi
  801335:	5f                   	pop    %edi
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    

00801338 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	57                   	push   %edi
  80133c:	56                   	push   %esi
  80133d:	53                   	push   %ebx
  80133e:	83 ec 1c             	sub    $0x1c,%esp
  801341:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801344:	89 3c 24             	mov    %edi,(%esp)
  801347:	e8 08 f1 ff ff       	call   800454 <fd2data>
  80134c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80134e:	be 00 00 00 00       	mov    $0x0,%esi
  801353:	eb 3a                	jmp    80138f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801355:	85 f6                	test   %esi,%esi
  801357:	74 04                	je     80135d <devpipe_read+0x25>
				return i;
  801359:	89 f0                	mov    %esi,%eax
  80135b:	eb 40                	jmp    80139d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80135d:	89 da                	mov    %ebx,%edx
  80135f:	89 f8                	mov    %edi,%eax
  801361:	e8 f5 fe ff ff       	call   80125b <_pipeisclosed>
  801366:	85 c0                	test   %eax,%eax
  801368:	75 2e                	jne    801398 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80136a:	e8 eb ed ff ff       	call   80015a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80136f:	8b 03                	mov    (%ebx),%eax
  801371:	3b 43 04             	cmp    0x4(%ebx),%eax
  801374:	74 df                	je     801355 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801376:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80137b:	79 05                	jns    801382 <devpipe_read+0x4a>
  80137d:	48                   	dec    %eax
  80137e:	83 c8 e0             	or     $0xffffffe0,%eax
  801381:	40                   	inc    %eax
  801382:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801386:	8b 55 0c             	mov    0xc(%ebp),%edx
  801389:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80138c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80138e:	46                   	inc    %esi
  80138f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801392:	75 db                	jne    80136f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801394:	89 f0                	mov    %esi,%eax
  801396:	eb 05                	jmp    80139d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801398:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80139d:	83 c4 1c             	add    $0x1c,%esp
  8013a0:	5b                   	pop    %ebx
  8013a1:	5e                   	pop    %esi
  8013a2:	5f                   	pop    %edi
  8013a3:	5d                   	pop    %ebp
  8013a4:	c3                   	ret    

008013a5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	57                   	push   %edi
  8013a9:	56                   	push   %esi
  8013aa:	53                   	push   %ebx
  8013ab:	83 ec 3c             	sub    $0x3c,%esp
  8013ae:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8013b1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013b4:	89 04 24             	mov    %eax,(%esp)
  8013b7:	e8 b3 f0 ff ff       	call   80046f <fd_alloc>
  8013bc:	89 c3                	mov    %eax,%ebx
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	0f 88 45 01 00 00    	js     80150b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013c6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8013cd:	00 
  8013ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013dc:	e8 98 ed ff ff       	call   800179 <sys_page_alloc>
  8013e1:	89 c3                	mov    %eax,%ebx
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	0f 88 20 01 00 00    	js     80150b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8013eb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013ee:	89 04 24             	mov    %eax,(%esp)
  8013f1:	e8 79 f0 ff ff       	call   80046f <fd_alloc>
  8013f6:	89 c3                	mov    %eax,%ebx
  8013f8:	85 c0                	test   %eax,%eax
  8013fa:	0f 88 f8 00 00 00    	js     8014f8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801400:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801407:	00 
  801408:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80140b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801416:	e8 5e ed ff ff       	call   800179 <sys_page_alloc>
  80141b:	89 c3                	mov    %eax,%ebx
  80141d:	85 c0                	test   %eax,%eax
  80141f:	0f 88 d3 00 00 00    	js     8014f8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801425:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801428:	89 04 24             	mov    %eax,(%esp)
  80142b:	e8 24 f0 ff ff       	call   800454 <fd2data>
  801430:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801432:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801439:	00 
  80143a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801445:	e8 2f ed ff ff       	call   800179 <sys_page_alloc>
  80144a:	89 c3                	mov    %eax,%ebx
  80144c:	85 c0                	test   %eax,%eax
  80144e:	0f 88 91 00 00 00    	js     8014e5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801454:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801457:	89 04 24             	mov    %eax,(%esp)
  80145a:	e8 f5 ef ff ff       	call   800454 <fd2data>
  80145f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801466:	00 
  801467:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80146b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801472:	00 
  801473:	89 74 24 04          	mov    %esi,0x4(%esp)
  801477:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80147e:	e8 4a ed ff ff       	call   8001cd <sys_page_map>
  801483:	89 c3                	mov    %eax,%ebx
  801485:	85 c0                	test   %eax,%eax
  801487:	78 4c                	js     8014d5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801489:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80148f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801492:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801494:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801497:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80149e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8014a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014a7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8014a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014ac:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8014b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014b6:	89 04 24             	mov    %eax,(%esp)
  8014b9:	e8 86 ef ff ff       	call   800444 <fd2num>
  8014be:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8014c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014c3:	89 04 24             	mov    %eax,(%esp)
  8014c6:	e8 79 ef ff ff       	call   800444 <fd2num>
  8014cb:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8014ce:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d3:	eb 36                	jmp    80150b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8014d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014e0:	e8 3b ed ff ff       	call   800220 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8014e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f3:	e8 28 ed ff ff       	call   800220 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8014f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801506:	e8 15 ed ff ff       	call   800220 <sys_page_unmap>
    err:
	return r;
}
  80150b:	89 d8                	mov    %ebx,%eax
  80150d:	83 c4 3c             	add    $0x3c,%esp
  801510:	5b                   	pop    %ebx
  801511:	5e                   	pop    %esi
  801512:	5f                   	pop    %edi
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801522:	8b 45 08             	mov    0x8(%ebp),%eax
  801525:	89 04 24             	mov    %eax,(%esp)
  801528:	e8 95 ef ff ff       	call   8004c2 <fd_lookup>
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 15                	js     801546 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801531:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801534:	89 04 24             	mov    %eax,(%esp)
  801537:	e8 18 ef ff ff       	call   800454 <fd2data>
	return _pipeisclosed(fd, p);
  80153c:	89 c2                	mov    %eax,%edx
  80153e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801541:	e8 15 fd ff ff       	call   80125b <_pipeisclosed>
}
  801546:	c9                   	leave  
  801547:	c3                   	ret    

00801548 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80154b:	b8 00 00 00 00       	mov    $0x0,%eax
  801550:	5d                   	pop    %ebp
  801551:	c3                   	ret    

00801552 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801558:	c7 44 24 04 d3 25 80 	movl   $0x8025d3,0x4(%esp)
  80155f:	00 
  801560:	8b 45 0c             	mov    0xc(%ebp),%eax
  801563:	89 04 24             	mov    %eax,(%esp)
  801566:	e8 20 08 00 00       	call   801d8b <strcpy>
	return 0;
}
  80156b:	b8 00 00 00 00       	mov    $0x0,%eax
  801570:	c9                   	leave  
  801571:	c3                   	ret    

00801572 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
  801575:	57                   	push   %edi
  801576:	56                   	push   %esi
  801577:	53                   	push   %ebx
  801578:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80157e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801583:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801589:	eb 30                	jmp    8015bb <devcons_write+0x49>
		m = n - tot;
  80158b:	8b 75 10             	mov    0x10(%ebp),%esi
  80158e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801590:	83 fe 7f             	cmp    $0x7f,%esi
  801593:	76 05                	jbe    80159a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801595:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80159a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80159e:	03 45 0c             	add    0xc(%ebp),%eax
  8015a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a5:	89 3c 24             	mov    %edi,(%esp)
  8015a8:	e8 57 09 00 00       	call   801f04 <memmove>
		sys_cputs(buf, m);
  8015ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015b1:	89 3c 24             	mov    %edi,(%esp)
  8015b4:	e8 f3 ea ff ff       	call   8000ac <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8015b9:	01 f3                	add    %esi,%ebx
  8015bb:	89 d8                	mov    %ebx,%eax
  8015bd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8015c0:	72 c9                	jb     80158b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8015c2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8015c8:	5b                   	pop    %ebx
  8015c9:	5e                   	pop    %esi
  8015ca:	5f                   	pop    %edi
  8015cb:	5d                   	pop    %ebp
  8015cc:	c3                   	ret    

008015cd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8015d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8015d7:	75 07                	jne    8015e0 <devcons_read+0x13>
  8015d9:	eb 25                	jmp    801600 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8015db:	e8 7a eb ff ff       	call   80015a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8015e0:	e8 e5 ea ff ff       	call   8000ca <sys_cgetc>
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	74 f2                	je     8015db <devcons_read+0xe>
  8015e9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 1d                	js     80160c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8015ef:	83 f8 04             	cmp    $0x4,%eax
  8015f2:	74 13                	je     801607 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8015f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f7:	88 10                	mov    %dl,(%eax)
	return 1;
  8015f9:	b8 01 00 00 00       	mov    $0x1,%eax
  8015fe:	eb 0c                	jmp    80160c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801600:	b8 00 00 00 00       	mov    $0x0,%eax
  801605:	eb 05                	jmp    80160c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801607:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80160c:	c9                   	leave  
  80160d:	c3                   	ret    

0080160e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801614:	8b 45 08             	mov    0x8(%ebp),%eax
  801617:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80161a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801621:	00 
  801622:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801625:	89 04 24             	mov    %eax,(%esp)
  801628:	e8 7f ea ff ff       	call   8000ac <sys_cputs>
}
  80162d:	c9                   	leave  
  80162e:	c3                   	ret    

0080162f <getchar>:

int
getchar(void)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801635:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80163c:	00 
  80163d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801640:	89 44 24 04          	mov    %eax,0x4(%esp)
  801644:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164b:	e8 10 f1 ff ff       	call   800760 <read>
	if (r < 0)
  801650:	85 c0                	test   %eax,%eax
  801652:	78 0f                	js     801663 <getchar+0x34>
		return r;
	if (r < 1)
  801654:	85 c0                	test   %eax,%eax
  801656:	7e 06                	jle    80165e <getchar+0x2f>
		return -E_EOF;
	return c;
  801658:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80165c:	eb 05                	jmp    801663 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80165e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801663:	c9                   	leave  
  801664:	c3                   	ret    

00801665 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80166b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801672:	8b 45 08             	mov    0x8(%ebp),%eax
  801675:	89 04 24             	mov    %eax,(%esp)
  801678:	e8 45 ee ff ff       	call   8004c2 <fd_lookup>
  80167d:	85 c0                	test   %eax,%eax
  80167f:	78 11                	js     801692 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801681:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801684:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80168a:	39 10                	cmp    %edx,(%eax)
  80168c:	0f 94 c0             	sete   %al
  80168f:	0f b6 c0             	movzbl %al,%eax
}
  801692:	c9                   	leave  
  801693:	c3                   	ret    

00801694 <opencons>:

int
opencons(void)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80169a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80169d:	89 04 24             	mov    %eax,(%esp)
  8016a0:	e8 ca ed ff ff       	call   80046f <fd_alloc>
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	78 3c                	js     8016e5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8016a9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8016b0:	00 
  8016b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016bf:	e8 b5 ea ff ff       	call   800179 <sys_page_alloc>
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 1d                	js     8016e5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8016c8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8016ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8016d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8016dd:	89 04 24             	mov    %eax,(%esp)
  8016e0:	e8 5f ed ff ff       	call   800444 <fd2num>
}
  8016e5:	c9                   	leave  
  8016e6:	c3                   	ret    
	...

008016e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	56                   	push   %esi
  8016ec:	53                   	push   %ebx
  8016ed:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8016f0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8016f3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8016f9:	e8 3d ea ff ff       	call   80013b <sys_getenvid>
  8016fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801701:	89 54 24 10          	mov    %edx,0x10(%esp)
  801705:	8b 55 08             	mov    0x8(%ebp),%edx
  801708:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80170c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801710:	89 44 24 04          	mov    %eax,0x4(%esp)
  801714:	c7 04 24 e0 25 80 00 	movl   $0x8025e0,(%esp)
  80171b:	e8 c0 00 00 00       	call   8017e0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801720:	89 74 24 04          	mov    %esi,0x4(%esp)
  801724:	8b 45 10             	mov    0x10(%ebp),%eax
  801727:	89 04 24             	mov    %eax,(%esp)
  80172a:	e8 50 00 00 00       	call   80177f <vcprintf>
	cprintf("\n");
  80172f:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  801736:	e8 a5 00 00 00       	call   8017e0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80173b:	cc                   	int3   
  80173c:	eb fd                	jmp    80173b <_panic+0x53>
	...

00801740 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	53                   	push   %ebx
  801744:	83 ec 14             	sub    $0x14,%esp
  801747:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80174a:	8b 03                	mov    (%ebx),%eax
  80174c:	8b 55 08             	mov    0x8(%ebp),%edx
  80174f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801753:	40                   	inc    %eax
  801754:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801756:	3d ff 00 00 00       	cmp    $0xff,%eax
  80175b:	75 19                	jne    801776 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80175d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801764:	00 
  801765:	8d 43 08             	lea    0x8(%ebx),%eax
  801768:	89 04 24             	mov    %eax,(%esp)
  80176b:	e8 3c e9 ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  801770:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801776:	ff 43 04             	incl   0x4(%ebx)
}
  801779:	83 c4 14             	add    $0x14,%esp
  80177c:	5b                   	pop    %ebx
  80177d:	5d                   	pop    %ebp
  80177e:	c3                   	ret    

0080177f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801788:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80178f:	00 00 00 
	b.cnt = 0;
  801792:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801799:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80179c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8017b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b4:	c7 04 24 40 17 80 00 	movl   $0x801740,(%esp)
  8017bb:	e8 82 01 00 00       	call   801942 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8017c0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ca:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8017d0:	89 04 24             	mov    %eax,(%esp)
  8017d3:	e8 d4 e8 ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  8017d8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8017de:	c9                   	leave  
  8017df:	c3                   	ret    

008017e0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017e6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8017e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f0:	89 04 24             	mov    %eax,(%esp)
  8017f3:	e8 87 ff ff ff       	call   80177f <vcprintf>
	va_end(ap);

	return cnt;
}
  8017f8:	c9                   	leave  
  8017f9:	c3                   	ret    
	...

008017fc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	57                   	push   %edi
  801800:	56                   	push   %esi
  801801:	53                   	push   %ebx
  801802:	83 ec 3c             	sub    $0x3c,%esp
  801805:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801808:	89 d7                	mov    %edx,%edi
  80180a:	8b 45 08             	mov    0x8(%ebp),%eax
  80180d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801810:	8b 45 0c             	mov    0xc(%ebp),%eax
  801813:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801816:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801819:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80181c:	85 c0                	test   %eax,%eax
  80181e:	75 08                	jne    801828 <printnum+0x2c>
  801820:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801823:	39 45 10             	cmp    %eax,0x10(%ebp)
  801826:	77 57                	ja     80187f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801828:	89 74 24 10          	mov    %esi,0x10(%esp)
  80182c:	4b                   	dec    %ebx
  80182d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801831:	8b 45 10             	mov    0x10(%ebp),%eax
  801834:	89 44 24 08          	mov    %eax,0x8(%esp)
  801838:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80183c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801840:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801847:	00 
  801848:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80184b:	89 04 24             	mov    %eax,(%esp)
  80184e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801851:	89 44 24 04          	mov    %eax,0x4(%esp)
  801855:	e8 d2 09 00 00       	call   80222c <__udivdi3>
  80185a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80185e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801862:	89 04 24             	mov    %eax,(%esp)
  801865:	89 54 24 04          	mov    %edx,0x4(%esp)
  801869:	89 fa                	mov    %edi,%edx
  80186b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80186e:	e8 89 ff ff ff       	call   8017fc <printnum>
  801873:	eb 0f                	jmp    801884 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801875:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801879:	89 34 24             	mov    %esi,(%esp)
  80187c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80187f:	4b                   	dec    %ebx
  801880:	85 db                	test   %ebx,%ebx
  801882:	7f f1                	jg     801875 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801884:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801888:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80188c:	8b 45 10             	mov    0x10(%ebp),%eax
  80188f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801893:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80189a:	00 
  80189b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80189e:	89 04 24             	mov    %eax,(%esp)
  8018a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a8:	e8 9f 0a 00 00       	call   80234c <__umoddi3>
  8018ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018b1:	0f be 80 03 26 80 00 	movsbl 0x802603(%eax),%eax
  8018b8:	89 04 24             	mov    %eax,(%esp)
  8018bb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8018be:	83 c4 3c             	add    $0x3c,%esp
  8018c1:	5b                   	pop    %ebx
  8018c2:	5e                   	pop    %esi
  8018c3:	5f                   	pop    %edi
  8018c4:	5d                   	pop    %ebp
  8018c5:	c3                   	ret    

008018c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8018c9:	83 fa 01             	cmp    $0x1,%edx
  8018cc:	7e 0e                	jle    8018dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8018ce:	8b 10                	mov    (%eax),%edx
  8018d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8018d3:	89 08                	mov    %ecx,(%eax)
  8018d5:	8b 02                	mov    (%edx),%eax
  8018d7:	8b 52 04             	mov    0x4(%edx),%edx
  8018da:	eb 22                	jmp    8018fe <getuint+0x38>
	else if (lflag)
  8018dc:	85 d2                	test   %edx,%edx
  8018de:	74 10                	je     8018f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8018e0:	8b 10                	mov    (%eax),%edx
  8018e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8018e5:	89 08                	mov    %ecx,(%eax)
  8018e7:	8b 02                	mov    (%edx),%eax
  8018e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ee:	eb 0e                	jmp    8018fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8018f0:	8b 10                	mov    (%eax),%edx
  8018f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8018f5:	89 08                	mov    %ecx,(%eax)
  8018f7:	8b 02                	mov    (%edx),%eax
  8018f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8018fe:	5d                   	pop    %ebp
  8018ff:	c3                   	ret    

00801900 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801906:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801909:	8b 10                	mov    (%eax),%edx
  80190b:	3b 50 04             	cmp    0x4(%eax),%edx
  80190e:	73 08                	jae    801918 <sprintputch+0x18>
		*b->buf++ = ch;
  801910:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801913:	88 0a                	mov    %cl,(%edx)
  801915:	42                   	inc    %edx
  801916:	89 10                	mov    %edx,(%eax)
}
  801918:	5d                   	pop    %ebp
  801919:	c3                   	ret    

0080191a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801920:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801923:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801927:	8b 45 10             	mov    0x10(%ebp),%eax
  80192a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80192e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801931:	89 44 24 04          	mov    %eax,0x4(%esp)
  801935:	8b 45 08             	mov    0x8(%ebp),%eax
  801938:	89 04 24             	mov    %eax,(%esp)
  80193b:	e8 02 00 00 00       	call   801942 <vprintfmt>
	va_end(ap);
}
  801940:	c9                   	leave  
  801941:	c3                   	ret    

00801942 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801942:	55                   	push   %ebp
  801943:	89 e5                	mov    %esp,%ebp
  801945:	57                   	push   %edi
  801946:	56                   	push   %esi
  801947:	53                   	push   %ebx
  801948:	83 ec 4c             	sub    $0x4c,%esp
  80194b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80194e:	8b 75 10             	mov    0x10(%ebp),%esi
  801951:	eb 12                	jmp    801965 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801953:	85 c0                	test   %eax,%eax
  801955:	0f 84 6b 03 00 00    	je     801cc6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80195b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80195f:	89 04 24             	mov    %eax,(%esp)
  801962:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801965:	0f b6 06             	movzbl (%esi),%eax
  801968:	46                   	inc    %esi
  801969:	83 f8 25             	cmp    $0x25,%eax
  80196c:	75 e5                	jne    801953 <vprintfmt+0x11>
  80196e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801972:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801979:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80197e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801985:	b9 00 00 00 00       	mov    $0x0,%ecx
  80198a:	eb 26                	jmp    8019b2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80198c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80198f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801993:	eb 1d                	jmp    8019b2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801995:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801998:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80199c:	eb 14                	jmp    8019b2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80199e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8019a1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8019a8:	eb 08                	jmp    8019b2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8019aa:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8019ad:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019b2:	0f b6 06             	movzbl (%esi),%eax
  8019b5:	8d 56 01             	lea    0x1(%esi),%edx
  8019b8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8019bb:	8a 16                	mov    (%esi),%dl
  8019bd:	83 ea 23             	sub    $0x23,%edx
  8019c0:	80 fa 55             	cmp    $0x55,%dl
  8019c3:	0f 87 e1 02 00 00    	ja     801caa <vprintfmt+0x368>
  8019c9:	0f b6 d2             	movzbl %dl,%edx
  8019cc:	ff 24 95 40 27 80 00 	jmp    *0x802740(,%edx,4)
  8019d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8019d6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8019db:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8019de:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8019e2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8019e5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8019e8:	83 fa 09             	cmp    $0x9,%edx
  8019eb:	77 2a                	ja     801a17 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8019ed:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8019ee:	eb eb                	jmp    8019db <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8019f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f3:	8d 50 04             	lea    0x4(%eax),%edx
  8019f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8019f9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8019fe:	eb 17                	jmp    801a17 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801a00:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801a04:	78 98                	js     80199e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a06:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801a09:	eb a7                	jmp    8019b2 <vprintfmt+0x70>
  801a0b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801a0e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801a15:	eb 9b                	jmp    8019b2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801a17:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801a1b:	79 95                	jns    8019b2 <vprintfmt+0x70>
  801a1d:	eb 8b                	jmp    8019aa <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801a1f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a20:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801a23:	eb 8d                	jmp    8019b2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801a25:	8b 45 14             	mov    0x14(%ebp),%eax
  801a28:	8d 50 04             	lea    0x4(%eax),%edx
  801a2b:	89 55 14             	mov    %edx,0x14(%ebp)
  801a2e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a32:	8b 00                	mov    (%eax),%eax
  801a34:	89 04 24             	mov    %eax,(%esp)
  801a37:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a3a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801a3d:	e9 23 ff ff ff       	jmp    801965 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801a42:	8b 45 14             	mov    0x14(%ebp),%eax
  801a45:	8d 50 04             	lea    0x4(%eax),%edx
  801a48:	89 55 14             	mov    %edx,0x14(%ebp)
  801a4b:	8b 00                	mov    (%eax),%eax
  801a4d:	85 c0                	test   %eax,%eax
  801a4f:	79 02                	jns    801a53 <vprintfmt+0x111>
  801a51:	f7 d8                	neg    %eax
  801a53:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801a55:	83 f8 10             	cmp    $0x10,%eax
  801a58:	7f 0b                	jg     801a65 <vprintfmt+0x123>
  801a5a:	8b 04 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%eax
  801a61:	85 c0                	test   %eax,%eax
  801a63:	75 23                	jne    801a88 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801a65:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801a69:	c7 44 24 08 1b 26 80 	movl   $0x80261b,0x8(%esp)
  801a70:	00 
  801a71:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a75:	8b 45 08             	mov    0x8(%ebp),%eax
  801a78:	89 04 24             	mov    %eax,(%esp)
  801a7b:	e8 9a fe ff ff       	call   80191a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a80:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801a83:	e9 dd fe ff ff       	jmp    801965 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801a88:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a8c:	c7 44 24 08 61 25 80 	movl   $0x802561,0x8(%esp)
  801a93:	00 
  801a94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a98:	8b 55 08             	mov    0x8(%ebp),%edx
  801a9b:	89 14 24             	mov    %edx,(%esp)
  801a9e:	e8 77 fe ff ff       	call   80191a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aa3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801aa6:	e9 ba fe ff ff       	jmp    801965 <vprintfmt+0x23>
  801aab:	89 f9                	mov    %edi,%ecx
  801aad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ab0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801ab3:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab6:	8d 50 04             	lea    0x4(%eax),%edx
  801ab9:	89 55 14             	mov    %edx,0x14(%ebp)
  801abc:	8b 30                	mov    (%eax),%esi
  801abe:	85 f6                	test   %esi,%esi
  801ac0:	75 05                	jne    801ac7 <vprintfmt+0x185>
				p = "(null)";
  801ac2:	be 14 26 80 00       	mov    $0x802614,%esi
			if (width > 0 && padc != '-')
  801ac7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801acb:	0f 8e 84 00 00 00    	jle    801b55 <vprintfmt+0x213>
  801ad1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801ad5:	74 7e                	je     801b55 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  801ad7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801adb:	89 34 24             	mov    %esi,(%esp)
  801ade:	e8 8b 02 00 00       	call   801d6e <strnlen>
  801ae3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801ae6:	29 c2                	sub    %eax,%edx
  801ae8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801aeb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801aef:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801af2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801af5:	89 de                	mov    %ebx,%esi
  801af7:	89 d3                	mov    %edx,%ebx
  801af9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801afb:	eb 0b                	jmp    801b08 <vprintfmt+0x1c6>
					putch(padc, putdat);
  801afd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b01:	89 3c 24             	mov    %edi,(%esp)
  801b04:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b07:	4b                   	dec    %ebx
  801b08:	85 db                	test   %ebx,%ebx
  801b0a:	7f f1                	jg     801afd <vprintfmt+0x1bb>
  801b0c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801b0f:	89 f3                	mov    %esi,%ebx
  801b11:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801b14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b17:	85 c0                	test   %eax,%eax
  801b19:	79 05                	jns    801b20 <vprintfmt+0x1de>
  801b1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b20:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b23:	29 c2                	sub    %eax,%edx
  801b25:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801b28:	eb 2b                	jmp    801b55 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801b2a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b2e:	74 18                	je     801b48 <vprintfmt+0x206>
  801b30:	8d 50 e0             	lea    -0x20(%eax),%edx
  801b33:	83 fa 5e             	cmp    $0x5e,%edx
  801b36:	76 10                	jbe    801b48 <vprintfmt+0x206>
					putch('?', putdat);
  801b38:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b3c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801b43:	ff 55 08             	call   *0x8(%ebp)
  801b46:	eb 0a                	jmp    801b52 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801b48:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b4c:	89 04 24             	mov    %eax,(%esp)
  801b4f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801b52:	ff 4d e4             	decl   -0x1c(%ebp)
  801b55:	0f be 06             	movsbl (%esi),%eax
  801b58:	46                   	inc    %esi
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	74 21                	je     801b7e <vprintfmt+0x23c>
  801b5d:	85 ff                	test   %edi,%edi
  801b5f:	78 c9                	js     801b2a <vprintfmt+0x1e8>
  801b61:	4f                   	dec    %edi
  801b62:	79 c6                	jns    801b2a <vprintfmt+0x1e8>
  801b64:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b67:	89 de                	mov    %ebx,%esi
  801b69:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801b6c:	eb 18                	jmp    801b86 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801b6e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b72:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801b79:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801b7b:	4b                   	dec    %ebx
  801b7c:	eb 08                	jmp    801b86 <vprintfmt+0x244>
  801b7e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b81:	89 de                	mov    %ebx,%esi
  801b83:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801b86:	85 db                	test   %ebx,%ebx
  801b88:	7f e4                	jg     801b6e <vprintfmt+0x22c>
  801b8a:	89 7d 08             	mov    %edi,0x8(%ebp)
  801b8d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b8f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801b92:	e9 ce fd ff ff       	jmp    801965 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801b97:	83 f9 01             	cmp    $0x1,%ecx
  801b9a:	7e 10                	jle    801bac <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801b9c:	8b 45 14             	mov    0x14(%ebp),%eax
  801b9f:	8d 50 08             	lea    0x8(%eax),%edx
  801ba2:	89 55 14             	mov    %edx,0x14(%ebp)
  801ba5:	8b 30                	mov    (%eax),%esi
  801ba7:	8b 78 04             	mov    0x4(%eax),%edi
  801baa:	eb 26                	jmp    801bd2 <vprintfmt+0x290>
	else if (lflag)
  801bac:	85 c9                	test   %ecx,%ecx
  801bae:	74 12                	je     801bc2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  801bb0:	8b 45 14             	mov    0x14(%ebp),%eax
  801bb3:	8d 50 04             	lea    0x4(%eax),%edx
  801bb6:	89 55 14             	mov    %edx,0x14(%ebp)
  801bb9:	8b 30                	mov    (%eax),%esi
  801bbb:	89 f7                	mov    %esi,%edi
  801bbd:	c1 ff 1f             	sar    $0x1f,%edi
  801bc0:	eb 10                	jmp    801bd2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801bc2:	8b 45 14             	mov    0x14(%ebp),%eax
  801bc5:	8d 50 04             	lea    0x4(%eax),%edx
  801bc8:	89 55 14             	mov    %edx,0x14(%ebp)
  801bcb:	8b 30                	mov    (%eax),%esi
  801bcd:	89 f7                	mov    %esi,%edi
  801bcf:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801bd2:	85 ff                	test   %edi,%edi
  801bd4:	78 0a                	js     801be0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801bd6:	b8 0a 00 00 00       	mov    $0xa,%eax
  801bdb:	e9 8c 00 00 00       	jmp    801c6c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801be0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801be4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801beb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801bee:	f7 de                	neg    %esi
  801bf0:	83 d7 00             	adc    $0x0,%edi
  801bf3:	f7 df                	neg    %edi
			}
			base = 10;
  801bf5:	b8 0a 00 00 00       	mov    $0xa,%eax
  801bfa:	eb 70                	jmp    801c6c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801bfc:	89 ca                	mov    %ecx,%edx
  801bfe:	8d 45 14             	lea    0x14(%ebp),%eax
  801c01:	e8 c0 fc ff ff       	call   8018c6 <getuint>
  801c06:	89 c6                	mov    %eax,%esi
  801c08:	89 d7                	mov    %edx,%edi
			base = 10;
  801c0a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801c0f:	eb 5b                	jmp    801c6c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  801c11:	89 ca                	mov    %ecx,%edx
  801c13:	8d 45 14             	lea    0x14(%ebp),%eax
  801c16:	e8 ab fc ff ff       	call   8018c6 <getuint>
  801c1b:	89 c6                	mov    %eax,%esi
  801c1d:	89 d7                	mov    %edx,%edi
			base = 8;
  801c1f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801c24:	eb 46                	jmp    801c6c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  801c26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c2a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801c31:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801c34:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c38:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801c3f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801c42:	8b 45 14             	mov    0x14(%ebp),%eax
  801c45:	8d 50 04             	lea    0x4(%eax),%edx
  801c48:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801c4b:	8b 30                	mov    (%eax),%esi
  801c4d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801c52:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801c57:	eb 13                	jmp    801c6c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801c59:	89 ca                	mov    %ecx,%edx
  801c5b:	8d 45 14             	lea    0x14(%ebp),%eax
  801c5e:	e8 63 fc ff ff       	call   8018c6 <getuint>
  801c63:	89 c6                	mov    %eax,%esi
  801c65:	89 d7                	mov    %edx,%edi
			base = 16;
  801c67:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801c6c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801c70:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c74:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c77:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c7f:	89 34 24             	mov    %esi,(%esp)
  801c82:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c86:	89 da                	mov    %ebx,%edx
  801c88:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8b:	e8 6c fb ff ff       	call   8017fc <printnum>
			break;
  801c90:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801c93:	e9 cd fc ff ff       	jmp    801965 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801c98:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c9c:	89 04 24             	mov    %eax,(%esp)
  801c9f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ca2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ca5:	e9 bb fc ff ff       	jmp    801965 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801caa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801cb5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801cb8:	eb 01                	jmp    801cbb <vprintfmt+0x379>
  801cba:	4e                   	dec    %esi
  801cbb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801cbf:	75 f9                	jne    801cba <vprintfmt+0x378>
  801cc1:	e9 9f fc ff ff       	jmp    801965 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801cc6:	83 c4 4c             	add    $0x4c,%esp
  801cc9:	5b                   	pop    %ebx
  801cca:	5e                   	pop    %esi
  801ccb:	5f                   	pop    %edi
  801ccc:	5d                   	pop    %ebp
  801ccd:	c3                   	ret    

00801cce <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	83 ec 28             	sub    $0x28,%esp
  801cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801cda:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cdd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ce1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ce4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ceb:	85 c0                	test   %eax,%eax
  801ced:	74 30                	je     801d1f <vsnprintf+0x51>
  801cef:	85 d2                	test   %edx,%edx
  801cf1:	7e 33                	jle    801d26 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801cf3:	8b 45 14             	mov    0x14(%ebp),%eax
  801cf6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cfa:	8b 45 10             	mov    0x10(%ebp),%eax
  801cfd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d01:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801d04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d08:	c7 04 24 00 19 80 00 	movl   $0x801900,(%esp)
  801d0f:	e8 2e fc ff ff       	call   801942 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801d14:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d17:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1d:	eb 0c                	jmp    801d2b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801d1f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d24:	eb 05                	jmp    801d2b <vsnprintf+0x5d>
  801d26:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801d2b:	c9                   	leave  
  801d2c:	c3                   	ret    

00801d2d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801d2d:	55                   	push   %ebp
  801d2e:	89 e5                	mov    %esp,%ebp
  801d30:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801d33:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801d36:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d3a:	8b 45 10             	mov    0x10(%ebp),%eax
  801d3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d44:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d48:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4b:	89 04 24             	mov    %eax,(%esp)
  801d4e:	e8 7b ff ff ff       	call   801cce <vsnprintf>
	va_end(ap);

	return rc;
}
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    
  801d55:	00 00                	add    %al,(%eax)
	...

00801d58 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801d5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d63:	eb 01                	jmp    801d66 <strlen+0xe>
		n++;
  801d65:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801d66:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801d6a:	75 f9                	jne    801d65 <strlen+0xd>
		n++;
	return n;
}
  801d6c:	5d                   	pop    %ebp
  801d6d:	c3                   	ret    

00801d6e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801d74:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801d77:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7c:	eb 01                	jmp    801d7f <strnlen+0x11>
		n++;
  801d7e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801d7f:	39 d0                	cmp    %edx,%eax
  801d81:	74 06                	je     801d89 <strnlen+0x1b>
  801d83:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801d87:	75 f5                	jne    801d7e <strnlen+0x10>
		n++;
	return n;
}
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    

00801d8b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	53                   	push   %ebx
  801d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801d95:	ba 00 00 00 00       	mov    $0x0,%edx
  801d9a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801d9d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801da0:	42                   	inc    %edx
  801da1:	84 c9                	test   %cl,%cl
  801da3:	75 f5                	jne    801d9a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801da5:	5b                   	pop    %ebx
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    

00801da8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	53                   	push   %ebx
  801dac:	83 ec 08             	sub    $0x8,%esp
  801daf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801db2:	89 1c 24             	mov    %ebx,(%esp)
  801db5:	e8 9e ff ff ff       	call   801d58 <strlen>
	strcpy(dst + len, src);
  801dba:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dbd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc1:	01 d8                	add    %ebx,%eax
  801dc3:	89 04 24             	mov    %eax,(%esp)
  801dc6:	e8 c0 ff ff ff       	call   801d8b <strcpy>
	return dst;
}
  801dcb:	89 d8                	mov    %ebx,%eax
  801dcd:	83 c4 08             	add    $0x8,%esp
  801dd0:	5b                   	pop    %ebx
  801dd1:	5d                   	pop    %ebp
  801dd2:	c3                   	ret    

00801dd3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	56                   	push   %esi
  801dd7:	53                   	push   %ebx
  801dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dde:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801de1:	b9 00 00 00 00       	mov    $0x0,%ecx
  801de6:	eb 0c                	jmp    801df4 <strncpy+0x21>
		*dst++ = *src;
  801de8:	8a 1a                	mov    (%edx),%bl
  801dea:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801ded:	80 3a 01             	cmpb   $0x1,(%edx)
  801df0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801df3:	41                   	inc    %ecx
  801df4:	39 f1                	cmp    %esi,%ecx
  801df6:	75 f0                	jne    801de8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801df8:	5b                   	pop    %ebx
  801df9:	5e                   	pop    %esi
  801dfa:	5d                   	pop    %ebp
  801dfb:	c3                   	ret    

00801dfc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	56                   	push   %esi
  801e00:	53                   	push   %ebx
  801e01:	8b 75 08             	mov    0x8(%ebp),%esi
  801e04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e07:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e0a:	85 d2                	test   %edx,%edx
  801e0c:	75 0a                	jne    801e18 <strlcpy+0x1c>
  801e0e:	89 f0                	mov    %esi,%eax
  801e10:	eb 1a                	jmp    801e2c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801e12:	88 18                	mov    %bl,(%eax)
  801e14:	40                   	inc    %eax
  801e15:	41                   	inc    %ecx
  801e16:	eb 02                	jmp    801e1a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e18:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801e1a:	4a                   	dec    %edx
  801e1b:	74 0a                	je     801e27 <strlcpy+0x2b>
  801e1d:	8a 19                	mov    (%ecx),%bl
  801e1f:	84 db                	test   %bl,%bl
  801e21:	75 ef                	jne    801e12 <strlcpy+0x16>
  801e23:	89 c2                	mov    %eax,%edx
  801e25:	eb 02                	jmp    801e29 <strlcpy+0x2d>
  801e27:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801e29:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801e2c:	29 f0                	sub    %esi,%eax
}
  801e2e:	5b                   	pop    %ebx
  801e2f:	5e                   	pop    %esi
  801e30:	5d                   	pop    %ebp
  801e31:	c3                   	ret    

00801e32 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e38:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801e3b:	eb 02                	jmp    801e3f <strcmp+0xd>
		p++, q++;
  801e3d:	41                   	inc    %ecx
  801e3e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801e3f:	8a 01                	mov    (%ecx),%al
  801e41:	84 c0                	test   %al,%al
  801e43:	74 04                	je     801e49 <strcmp+0x17>
  801e45:	3a 02                	cmp    (%edx),%al
  801e47:	74 f4                	je     801e3d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801e49:	0f b6 c0             	movzbl %al,%eax
  801e4c:	0f b6 12             	movzbl (%edx),%edx
  801e4f:	29 d0                	sub    %edx,%eax
}
  801e51:	5d                   	pop    %ebp
  801e52:	c3                   	ret    

00801e53 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	53                   	push   %ebx
  801e57:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e5d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801e60:	eb 03                	jmp    801e65 <strncmp+0x12>
		n--, p++, q++;
  801e62:	4a                   	dec    %edx
  801e63:	40                   	inc    %eax
  801e64:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801e65:	85 d2                	test   %edx,%edx
  801e67:	74 14                	je     801e7d <strncmp+0x2a>
  801e69:	8a 18                	mov    (%eax),%bl
  801e6b:	84 db                	test   %bl,%bl
  801e6d:	74 04                	je     801e73 <strncmp+0x20>
  801e6f:	3a 19                	cmp    (%ecx),%bl
  801e71:	74 ef                	je     801e62 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801e73:	0f b6 00             	movzbl (%eax),%eax
  801e76:	0f b6 11             	movzbl (%ecx),%edx
  801e79:	29 d0                	sub    %edx,%eax
  801e7b:	eb 05                	jmp    801e82 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801e7d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801e82:	5b                   	pop    %ebx
  801e83:	5d                   	pop    %ebp
  801e84:	c3                   	ret    

00801e85 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801e85:	55                   	push   %ebp
  801e86:	89 e5                	mov    %esp,%ebp
  801e88:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801e8e:	eb 05                	jmp    801e95 <strchr+0x10>
		if (*s == c)
  801e90:	38 ca                	cmp    %cl,%dl
  801e92:	74 0c                	je     801ea0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801e94:	40                   	inc    %eax
  801e95:	8a 10                	mov    (%eax),%dl
  801e97:	84 d2                	test   %dl,%dl
  801e99:	75 f5                	jne    801e90 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801e9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ea0:	5d                   	pop    %ebp
  801ea1:	c3                   	ret    

00801ea2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801eab:	eb 05                	jmp    801eb2 <strfind+0x10>
		if (*s == c)
  801ead:	38 ca                	cmp    %cl,%dl
  801eaf:	74 07                	je     801eb8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801eb1:	40                   	inc    %eax
  801eb2:	8a 10                	mov    (%eax),%dl
  801eb4:	84 d2                	test   %dl,%dl
  801eb6:	75 f5                	jne    801ead <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801eb8:	5d                   	pop    %ebp
  801eb9:	c3                   	ret    

00801eba <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	57                   	push   %edi
  801ebe:	56                   	push   %esi
  801ebf:	53                   	push   %ebx
  801ec0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ec9:	85 c9                	test   %ecx,%ecx
  801ecb:	74 30                	je     801efd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ecd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ed3:	75 25                	jne    801efa <memset+0x40>
  801ed5:	f6 c1 03             	test   $0x3,%cl
  801ed8:	75 20                	jne    801efa <memset+0x40>
		c &= 0xFF;
  801eda:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801edd:	89 d3                	mov    %edx,%ebx
  801edf:	c1 e3 08             	shl    $0x8,%ebx
  801ee2:	89 d6                	mov    %edx,%esi
  801ee4:	c1 e6 18             	shl    $0x18,%esi
  801ee7:	89 d0                	mov    %edx,%eax
  801ee9:	c1 e0 10             	shl    $0x10,%eax
  801eec:	09 f0                	or     %esi,%eax
  801eee:	09 d0                	or     %edx,%eax
  801ef0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801ef2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801ef5:	fc                   	cld    
  801ef6:	f3 ab                	rep stos %eax,%es:(%edi)
  801ef8:	eb 03                	jmp    801efd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801efa:	fc                   	cld    
  801efb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801efd:	89 f8                	mov    %edi,%eax
  801eff:	5b                   	pop    %ebx
  801f00:	5e                   	pop    %esi
  801f01:	5f                   	pop    %edi
  801f02:	5d                   	pop    %ebp
  801f03:	c3                   	ret    

00801f04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801f04:	55                   	push   %ebp
  801f05:	89 e5                	mov    %esp,%ebp
  801f07:	57                   	push   %edi
  801f08:	56                   	push   %esi
  801f09:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801f12:	39 c6                	cmp    %eax,%esi
  801f14:	73 34                	jae    801f4a <memmove+0x46>
  801f16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801f19:	39 d0                	cmp    %edx,%eax
  801f1b:	73 2d                	jae    801f4a <memmove+0x46>
		s += n;
		d += n;
  801f1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f20:	f6 c2 03             	test   $0x3,%dl
  801f23:	75 1b                	jne    801f40 <memmove+0x3c>
  801f25:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801f2b:	75 13                	jne    801f40 <memmove+0x3c>
  801f2d:	f6 c1 03             	test   $0x3,%cl
  801f30:	75 0e                	jne    801f40 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801f32:	83 ef 04             	sub    $0x4,%edi
  801f35:	8d 72 fc             	lea    -0x4(%edx),%esi
  801f38:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801f3b:	fd                   	std    
  801f3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f3e:	eb 07                	jmp    801f47 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801f40:	4f                   	dec    %edi
  801f41:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801f44:	fd                   	std    
  801f45:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801f47:	fc                   	cld    
  801f48:	eb 20                	jmp    801f6a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f4a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801f50:	75 13                	jne    801f65 <memmove+0x61>
  801f52:	a8 03                	test   $0x3,%al
  801f54:	75 0f                	jne    801f65 <memmove+0x61>
  801f56:	f6 c1 03             	test   $0x3,%cl
  801f59:	75 0a                	jne    801f65 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801f5b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801f5e:	89 c7                	mov    %eax,%edi
  801f60:	fc                   	cld    
  801f61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f63:	eb 05                	jmp    801f6a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801f65:	89 c7                	mov    %eax,%edi
  801f67:	fc                   	cld    
  801f68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801f6a:	5e                   	pop    %esi
  801f6b:	5f                   	pop    %edi
  801f6c:	5d                   	pop    %ebp
  801f6d:	c3                   	ret    

00801f6e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801f6e:	55                   	push   %ebp
  801f6f:	89 e5                	mov    %esp,%ebp
  801f71:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801f74:	8b 45 10             	mov    0x10(%ebp),%eax
  801f77:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f82:	8b 45 08             	mov    0x8(%ebp),%eax
  801f85:	89 04 24             	mov    %eax,(%esp)
  801f88:	e8 77 ff ff ff       	call   801f04 <memmove>
}
  801f8d:	c9                   	leave  
  801f8e:	c3                   	ret    

00801f8f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	57                   	push   %edi
  801f93:	56                   	push   %esi
  801f94:	53                   	push   %ebx
  801f95:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f98:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801f9e:	ba 00 00 00 00       	mov    $0x0,%edx
  801fa3:	eb 16                	jmp    801fbb <memcmp+0x2c>
		if (*s1 != *s2)
  801fa5:	8a 04 17             	mov    (%edi,%edx,1),%al
  801fa8:	42                   	inc    %edx
  801fa9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801fad:	38 c8                	cmp    %cl,%al
  801faf:	74 0a                	je     801fbb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801fb1:	0f b6 c0             	movzbl %al,%eax
  801fb4:	0f b6 c9             	movzbl %cl,%ecx
  801fb7:	29 c8                	sub    %ecx,%eax
  801fb9:	eb 09                	jmp    801fc4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801fbb:	39 da                	cmp    %ebx,%edx
  801fbd:	75 e6                	jne    801fa5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801fbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fc4:	5b                   	pop    %ebx
  801fc5:	5e                   	pop    %esi
  801fc6:	5f                   	pop    %edi
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    

00801fc9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801fc9:	55                   	push   %ebp
  801fca:	89 e5                	mov    %esp,%ebp
  801fcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801fd2:	89 c2                	mov    %eax,%edx
  801fd4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801fd7:	eb 05                	jmp    801fde <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801fd9:	38 08                	cmp    %cl,(%eax)
  801fdb:	74 05                	je     801fe2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801fdd:	40                   	inc    %eax
  801fde:	39 d0                	cmp    %edx,%eax
  801fe0:	72 f7                	jb     801fd9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    

00801fe4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	57                   	push   %edi
  801fe8:	56                   	push   %esi
  801fe9:	53                   	push   %ebx
  801fea:	8b 55 08             	mov    0x8(%ebp),%edx
  801fed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ff0:	eb 01                	jmp    801ff3 <strtol+0xf>
		s++;
  801ff2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ff3:	8a 02                	mov    (%edx),%al
  801ff5:	3c 20                	cmp    $0x20,%al
  801ff7:	74 f9                	je     801ff2 <strtol+0xe>
  801ff9:	3c 09                	cmp    $0x9,%al
  801ffb:	74 f5                	je     801ff2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ffd:	3c 2b                	cmp    $0x2b,%al
  801fff:	75 08                	jne    802009 <strtol+0x25>
		s++;
  802001:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802002:	bf 00 00 00 00       	mov    $0x0,%edi
  802007:	eb 13                	jmp    80201c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802009:	3c 2d                	cmp    $0x2d,%al
  80200b:	75 0a                	jne    802017 <strtol+0x33>
		s++, neg = 1;
  80200d:	8d 52 01             	lea    0x1(%edx),%edx
  802010:	bf 01 00 00 00       	mov    $0x1,%edi
  802015:	eb 05                	jmp    80201c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802017:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80201c:	85 db                	test   %ebx,%ebx
  80201e:	74 05                	je     802025 <strtol+0x41>
  802020:	83 fb 10             	cmp    $0x10,%ebx
  802023:	75 28                	jne    80204d <strtol+0x69>
  802025:	8a 02                	mov    (%edx),%al
  802027:	3c 30                	cmp    $0x30,%al
  802029:	75 10                	jne    80203b <strtol+0x57>
  80202b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80202f:	75 0a                	jne    80203b <strtol+0x57>
		s += 2, base = 16;
  802031:	83 c2 02             	add    $0x2,%edx
  802034:	bb 10 00 00 00       	mov    $0x10,%ebx
  802039:	eb 12                	jmp    80204d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80203b:	85 db                	test   %ebx,%ebx
  80203d:	75 0e                	jne    80204d <strtol+0x69>
  80203f:	3c 30                	cmp    $0x30,%al
  802041:	75 05                	jne    802048 <strtol+0x64>
		s++, base = 8;
  802043:	42                   	inc    %edx
  802044:	b3 08                	mov    $0x8,%bl
  802046:	eb 05                	jmp    80204d <strtol+0x69>
	else if (base == 0)
		base = 10;
  802048:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80204d:	b8 00 00 00 00       	mov    $0x0,%eax
  802052:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802054:	8a 0a                	mov    (%edx),%cl
  802056:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  802059:	80 fb 09             	cmp    $0x9,%bl
  80205c:	77 08                	ja     802066 <strtol+0x82>
			dig = *s - '0';
  80205e:	0f be c9             	movsbl %cl,%ecx
  802061:	83 e9 30             	sub    $0x30,%ecx
  802064:	eb 1e                	jmp    802084 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  802066:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  802069:	80 fb 19             	cmp    $0x19,%bl
  80206c:	77 08                	ja     802076 <strtol+0x92>
			dig = *s - 'a' + 10;
  80206e:	0f be c9             	movsbl %cl,%ecx
  802071:	83 e9 57             	sub    $0x57,%ecx
  802074:	eb 0e                	jmp    802084 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  802076:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  802079:	80 fb 19             	cmp    $0x19,%bl
  80207c:	77 12                	ja     802090 <strtol+0xac>
			dig = *s - 'A' + 10;
  80207e:	0f be c9             	movsbl %cl,%ecx
  802081:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  802084:	39 f1                	cmp    %esi,%ecx
  802086:	7d 0c                	jge    802094 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  802088:	42                   	inc    %edx
  802089:	0f af c6             	imul   %esi,%eax
  80208c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80208e:	eb c4                	jmp    802054 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  802090:	89 c1                	mov    %eax,%ecx
  802092:	eb 02                	jmp    802096 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  802094:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  802096:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80209a:	74 05                	je     8020a1 <strtol+0xbd>
		*endptr = (char *) s;
  80209c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80209f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8020a1:	85 ff                	test   %edi,%edi
  8020a3:	74 04                	je     8020a9 <strtol+0xc5>
  8020a5:	89 c8                	mov    %ecx,%eax
  8020a7:	f7 d8                	neg    %eax
}
  8020a9:	5b                   	pop    %ebx
  8020aa:	5e                   	pop    %esi
  8020ab:	5f                   	pop    %edi
  8020ac:	5d                   	pop    %ebp
  8020ad:	c3                   	ret    
	...

008020b0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020b0:	55                   	push   %ebp
  8020b1:	89 e5                	mov    %esp,%ebp
  8020b3:	56                   	push   %esi
  8020b4:	53                   	push   %ebx
  8020b5:	83 ec 10             	sub    $0x10,%esp
  8020b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020be:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8020c1:	85 c0                	test   %eax,%eax
  8020c3:	74 0a                	je     8020cf <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8020c5:	89 04 24             	mov    %eax,(%esp)
  8020c8:	e8 c2 e2 ff ff       	call   80038f <sys_ipc_recv>
  8020cd:	eb 0c                	jmp    8020db <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8020cf:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8020d6:	e8 b4 e2 ff ff       	call   80038f <sys_ipc_recv>
	}
	if (r < 0)
  8020db:	85 c0                	test   %eax,%eax
  8020dd:	79 16                	jns    8020f5 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8020df:	85 db                	test   %ebx,%ebx
  8020e1:	74 06                	je     8020e9 <ipc_recv+0x39>
  8020e3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8020e9:	85 f6                	test   %esi,%esi
  8020eb:	74 2c                	je     802119 <ipc_recv+0x69>
  8020ed:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8020f3:	eb 24                	jmp    802119 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8020f5:	85 db                	test   %ebx,%ebx
  8020f7:	74 0a                	je     802103 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  8020f9:	a1 08 40 80 00       	mov    0x804008,%eax
  8020fe:	8b 40 74             	mov    0x74(%eax),%eax
  802101:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  802103:	85 f6                	test   %esi,%esi
  802105:	74 0a                	je     802111 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  802107:	a1 08 40 80 00       	mov    0x804008,%eax
  80210c:	8b 40 78             	mov    0x78(%eax),%eax
  80210f:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802111:	a1 08 40 80 00       	mov    0x804008,%eax
  802116:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802119:	83 c4 10             	add    $0x10,%esp
  80211c:	5b                   	pop    %ebx
  80211d:	5e                   	pop    %esi
  80211e:	5d                   	pop    %ebp
  80211f:	c3                   	ret    

00802120 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	57                   	push   %edi
  802124:	56                   	push   %esi
  802125:	53                   	push   %ebx
  802126:	83 ec 1c             	sub    $0x1c,%esp
  802129:	8b 75 08             	mov    0x8(%ebp),%esi
  80212c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80212f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  802132:	85 db                	test   %ebx,%ebx
  802134:	74 19                	je     80214f <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802136:	8b 45 14             	mov    0x14(%ebp),%eax
  802139:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80213d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802141:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802145:	89 34 24             	mov    %esi,(%esp)
  802148:	e8 1f e2 ff ff       	call   80036c <sys_ipc_try_send>
  80214d:	eb 1c                	jmp    80216b <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80214f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802156:	00 
  802157:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80215e:	ee 
  80215f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802163:	89 34 24             	mov    %esi,(%esp)
  802166:	e8 01 e2 ff ff       	call   80036c <sys_ipc_try_send>
		}
		if (r == 0)
  80216b:	85 c0                	test   %eax,%eax
  80216d:	74 2c                	je     80219b <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80216f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802172:	74 20                	je     802194 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802174:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802178:	c7 44 24 08 04 29 80 	movl   $0x802904,0x8(%esp)
  80217f:	00 
  802180:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802187:	00 
  802188:	c7 04 24 17 29 80 00 	movl   $0x802917,(%esp)
  80218f:	e8 54 f5 ff ff       	call   8016e8 <_panic>
		}
		sys_yield();
  802194:	e8 c1 df ff ff       	call   80015a <sys_yield>
	}
  802199:	eb 97                	jmp    802132 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  80219b:	83 c4 1c             	add    $0x1c,%esp
  80219e:	5b                   	pop    %ebx
  80219f:	5e                   	pop    %esi
  8021a0:	5f                   	pop    %edi
  8021a1:	5d                   	pop    %ebp
  8021a2:	c3                   	ret    

008021a3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021a3:	55                   	push   %ebp
  8021a4:	89 e5                	mov    %esp,%ebp
  8021a6:	53                   	push   %ebx
  8021a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8021aa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021af:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8021b6:	89 c2                	mov    %eax,%edx
  8021b8:	c1 e2 07             	shl    $0x7,%edx
  8021bb:	29 ca                	sub    %ecx,%edx
  8021bd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021c3:	8b 52 50             	mov    0x50(%edx),%edx
  8021c6:	39 da                	cmp    %ebx,%edx
  8021c8:	75 0f                	jne    8021d9 <ipc_find_env+0x36>
			return envs[i].env_id;
  8021ca:	c1 e0 07             	shl    $0x7,%eax
  8021cd:	29 c8                	sub    %ecx,%eax
  8021cf:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021d4:	8b 40 40             	mov    0x40(%eax),%eax
  8021d7:	eb 0c                	jmp    8021e5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021d9:	40                   	inc    %eax
  8021da:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021df:	75 ce                	jne    8021af <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021e1:	66 b8 00 00          	mov    $0x0,%ax
}
  8021e5:	5b                   	pop    %ebx
  8021e6:	5d                   	pop    %ebp
  8021e7:	c3                   	ret    

008021e8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021e8:	55                   	push   %ebp
  8021e9:	89 e5                	mov    %esp,%ebp
  8021eb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021ee:	89 c2                	mov    %eax,%edx
  8021f0:	c1 ea 16             	shr    $0x16,%edx
  8021f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021fa:	f6 c2 01             	test   $0x1,%dl
  8021fd:	74 1e                	je     80221d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8021ff:	c1 e8 0c             	shr    $0xc,%eax
  802202:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802209:	a8 01                	test   $0x1,%al
  80220b:	74 17                	je     802224 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80220d:	c1 e8 0c             	shr    $0xc,%eax
  802210:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802217:	ef 
  802218:	0f b7 c0             	movzwl %ax,%eax
  80221b:	eb 0c                	jmp    802229 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80221d:	b8 00 00 00 00       	mov    $0x0,%eax
  802222:	eb 05                	jmp    802229 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802224:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802229:	5d                   	pop    %ebp
  80222a:	c3                   	ret    
	...

0080222c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80222c:	55                   	push   %ebp
  80222d:	57                   	push   %edi
  80222e:	56                   	push   %esi
  80222f:	83 ec 10             	sub    $0x10,%esp
  802232:	8b 74 24 20          	mov    0x20(%esp),%esi
  802236:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80223a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80223e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802242:	89 cd                	mov    %ecx,%ebp
  802244:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802248:	85 c0                	test   %eax,%eax
  80224a:	75 2c                	jne    802278 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80224c:	39 f9                	cmp    %edi,%ecx
  80224e:	77 68                	ja     8022b8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802250:	85 c9                	test   %ecx,%ecx
  802252:	75 0b                	jne    80225f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802254:	b8 01 00 00 00       	mov    $0x1,%eax
  802259:	31 d2                	xor    %edx,%edx
  80225b:	f7 f1                	div    %ecx
  80225d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80225f:	31 d2                	xor    %edx,%edx
  802261:	89 f8                	mov    %edi,%eax
  802263:	f7 f1                	div    %ecx
  802265:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802267:	89 f0                	mov    %esi,%eax
  802269:	f7 f1                	div    %ecx
  80226b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80226d:	89 f0                	mov    %esi,%eax
  80226f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802271:	83 c4 10             	add    $0x10,%esp
  802274:	5e                   	pop    %esi
  802275:	5f                   	pop    %edi
  802276:	5d                   	pop    %ebp
  802277:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802278:	39 f8                	cmp    %edi,%eax
  80227a:	77 2c                	ja     8022a8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80227c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80227f:	83 f6 1f             	xor    $0x1f,%esi
  802282:	75 4c                	jne    8022d0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802284:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802286:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80228b:	72 0a                	jb     802297 <__udivdi3+0x6b>
  80228d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802291:	0f 87 ad 00 00 00    	ja     802344 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802297:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80229c:	89 f0                	mov    %esi,%eax
  80229e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022a0:	83 c4 10             	add    $0x10,%esp
  8022a3:	5e                   	pop    %esi
  8022a4:	5f                   	pop    %edi
  8022a5:	5d                   	pop    %ebp
  8022a6:	c3                   	ret    
  8022a7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022a8:	31 ff                	xor    %edi,%edi
  8022aa:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022ac:	89 f0                	mov    %esi,%eax
  8022ae:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022b0:	83 c4 10             	add    $0x10,%esp
  8022b3:	5e                   	pop    %esi
  8022b4:	5f                   	pop    %edi
  8022b5:	5d                   	pop    %ebp
  8022b6:	c3                   	ret    
  8022b7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022b8:	89 fa                	mov    %edi,%edx
  8022ba:	89 f0                	mov    %esi,%eax
  8022bc:	f7 f1                	div    %ecx
  8022be:	89 c6                	mov    %eax,%esi
  8022c0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022c2:	89 f0                	mov    %esi,%eax
  8022c4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022c6:	83 c4 10             	add    $0x10,%esp
  8022c9:	5e                   	pop    %esi
  8022ca:	5f                   	pop    %edi
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    
  8022cd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8022d0:	89 f1                	mov    %esi,%ecx
  8022d2:	d3 e0                	shl    %cl,%eax
  8022d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022d8:	b8 20 00 00 00       	mov    $0x20,%eax
  8022dd:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8022df:	89 ea                	mov    %ebp,%edx
  8022e1:	88 c1                	mov    %al,%cl
  8022e3:	d3 ea                	shr    %cl,%edx
  8022e5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8022e9:	09 ca                	or     %ecx,%edx
  8022eb:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8022ef:	89 f1                	mov    %esi,%ecx
  8022f1:	d3 e5                	shl    %cl,%ebp
  8022f3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8022f7:	89 fd                	mov    %edi,%ebp
  8022f9:	88 c1                	mov    %al,%cl
  8022fb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8022fd:	89 fa                	mov    %edi,%edx
  8022ff:	89 f1                	mov    %esi,%ecx
  802301:	d3 e2                	shl    %cl,%edx
  802303:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802307:	88 c1                	mov    %al,%cl
  802309:	d3 ef                	shr    %cl,%edi
  80230b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80230d:	89 f8                	mov    %edi,%eax
  80230f:	89 ea                	mov    %ebp,%edx
  802311:	f7 74 24 08          	divl   0x8(%esp)
  802315:	89 d1                	mov    %edx,%ecx
  802317:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802319:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80231d:	39 d1                	cmp    %edx,%ecx
  80231f:	72 17                	jb     802338 <__udivdi3+0x10c>
  802321:	74 09                	je     80232c <__udivdi3+0x100>
  802323:	89 fe                	mov    %edi,%esi
  802325:	31 ff                	xor    %edi,%edi
  802327:	e9 41 ff ff ff       	jmp    80226d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80232c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802330:	89 f1                	mov    %esi,%ecx
  802332:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802334:	39 c2                	cmp    %eax,%edx
  802336:	73 eb                	jae    802323 <__udivdi3+0xf7>
		{
		  q0--;
  802338:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80233b:	31 ff                	xor    %edi,%edi
  80233d:	e9 2b ff ff ff       	jmp    80226d <__udivdi3+0x41>
  802342:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802344:	31 f6                	xor    %esi,%esi
  802346:	e9 22 ff ff ff       	jmp    80226d <__udivdi3+0x41>
	...

0080234c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80234c:	55                   	push   %ebp
  80234d:	57                   	push   %edi
  80234e:	56                   	push   %esi
  80234f:	83 ec 20             	sub    $0x20,%esp
  802352:	8b 44 24 30          	mov    0x30(%esp),%eax
  802356:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80235a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80235e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802362:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802366:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80236a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80236c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80236e:	85 ed                	test   %ebp,%ebp
  802370:	75 16                	jne    802388 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802372:	39 f1                	cmp    %esi,%ecx
  802374:	0f 86 a6 00 00 00    	jbe    802420 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80237a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80237c:	89 d0                	mov    %edx,%eax
  80237e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802380:	83 c4 20             	add    $0x20,%esp
  802383:	5e                   	pop    %esi
  802384:	5f                   	pop    %edi
  802385:	5d                   	pop    %ebp
  802386:	c3                   	ret    
  802387:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802388:	39 f5                	cmp    %esi,%ebp
  80238a:	0f 87 ac 00 00 00    	ja     80243c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802390:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802393:	83 f0 1f             	xor    $0x1f,%eax
  802396:	89 44 24 10          	mov    %eax,0x10(%esp)
  80239a:	0f 84 a8 00 00 00    	je     802448 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8023a0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023a4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023a6:	bf 20 00 00 00       	mov    $0x20,%edi
  8023ab:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8023af:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023b3:	89 f9                	mov    %edi,%ecx
  8023b5:	d3 e8                	shr    %cl,%eax
  8023b7:	09 e8                	or     %ebp,%eax
  8023b9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8023bd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023c1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023c5:	d3 e0                	shl    %cl,%eax
  8023c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023cb:	89 f2                	mov    %esi,%edx
  8023cd:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8023cf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023d3:	d3 e0                	shl    %cl,%eax
  8023d5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023d9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023dd:	89 f9                	mov    %edi,%ecx
  8023df:	d3 e8                	shr    %cl,%eax
  8023e1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8023e3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023e5:	89 f2                	mov    %esi,%edx
  8023e7:	f7 74 24 18          	divl   0x18(%esp)
  8023eb:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8023ed:	f7 64 24 0c          	mull   0xc(%esp)
  8023f1:	89 c5                	mov    %eax,%ebp
  8023f3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023f5:	39 d6                	cmp    %edx,%esi
  8023f7:	72 67                	jb     802460 <__umoddi3+0x114>
  8023f9:	74 75                	je     802470 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8023fb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8023ff:	29 e8                	sub    %ebp,%eax
  802401:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802403:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802407:	d3 e8                	shr    %cl,%eax
  802409:	89 f2                	mov    %esi,%edx
  80240b:	89 f9                	mov    %edi,%ecx
  80240d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80240f:	09 d0                	or     %edx,%eax
  802411:	89 f2                	mov    %esi,%edx
  802413:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802417:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802419:	83 c4 20             	add    $0x20,%esp
  80241c:	5e                   	pop    %esi
  80241d:	5f                   	pop    %edi
  80241e:	5d                   	pop    %ebp
  80241f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802420:	85 c9                	test   %ecx,%ecx
  802422:	75 0b                	jne    80242f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802424:	b8 01 00 00 00       	mov    $0x1,%eax
  802429:	31 d2                	xor    %edx,%edx
  80242b:	f7 f1                	div    %ecx
  80242d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80242f:	89 f0                	mov    %esi,%eax
  802431:	31 d2                	xor    %edx,%edx
  802433:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802435:	89 f8                	mov    %edi,%eax
  802437:	e9 3e ff ff ff       	jmp    80237a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80243c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80243e:	83 c4 20             	add    $0x20,%esp
  802441:	5e                   	pop    %esi
  802442:	5f                   	pop    %edi
  802443:	5d                   	pop    %ebp
  802444:	c3                   	ret    
  802445:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802448:	39 f5                	cmp    %esi,%ebp
  80244a:	72 04                	jb     802450 <__umoddi3+0x104>
  80244c:	39 f9                	cmp    %edi,%ecx
  80244e:	77 06                	ja     802456 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802450:	89 f2                	mov    %esi,%edx
  802452:	29 cf                	sub    %ecx,%edi
  802454:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802456:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802458:	83 c4 20             	add    $0x20,%esp
  80245b:	5e                   	pop    %esi
  80245c:	5f                   	pop    %edi
  80245d:	5d                   	pop    %ebp
  80245e:	c3                   	ret    
  80245f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802460:	89 d1                	mov    %edx,%ecx
  802462:	89 c5                	mov    %eax,%ebp
  802464:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802468:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80246c:	eb 8d                	jmp    8023fb <__umoddi3+0xaf>
  80246e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802470:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802474:	72 ea                	jb     802460 <__umoddi3+0x114>
  802476:	89 f1                	mov    %esi,%ecx
  802478:	eb 81                	jmp    8023fb <__umoddi3+0xaf>
