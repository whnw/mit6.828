
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 64 04 80 	movl   $0x800464,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 eb 02 00 00       	call   800339 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	56                   	push   %esi
  800060:	53                   	push   %ebx
  800061:	83 ec 10             	sub    $0x10,%esp
  800064:	8b 75 08             	mov    0x8(%ebp),%esi
  800067:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80006a:	e8 ec 00 00 00       	call   80015b <sys_getenvid>
  80006f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800074:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80007b:	c1 e0 07             	shl    $0x7,%eax
  80007e:	29 d0                	sub    %edx,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 f6                	test   %esi,%esi
  80008c:	7e 07                	jle    800095 <libmain+0x39>
		binaryname = argv[0];
  80008e:	8b 03                	mov    (%ebx),%eax
  800090:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800095:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800099:	89 34 24             	mov    %esi,(%esp)
  80009c:	e8 93 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a1:	e8 0a 00 00 00       	call   8000b0 <exit>
}
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	5d                   	pop    %ebp
  8000ac:	c3                   	ret    
  8000ad:	00 00                	add    %al,(%eax)
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000b6:	e8 b8 05 00 00       	call   800673 <close_all>
	sys_env_destroy(0);
  8000bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c2:	e8 42 00 00 00       	call   800109 <sys_env_destroy>
}
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    
  8000c9:	00 00                	add    %al,(%eax)
	...

008000cc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000da:	8b 55 08             	mov    0x8(%ebp),%edx
  8000dd:	89 c3                	mov    %eax,%ebx
  8000df:	89 c7                	mov    %eax,%edi
  8000e1:	89 c6                	mov    %eax,%esi
  8000e3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e5:	5b                   	pop    %ebx
  8000e6:	5e                   	pop    %esi
  8000e7:	5f                   	pop    %edi
  8000e8:	5d                   	pop    %ebp
  8000e9:	c3                   	ret    

008000ea <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	57                   	push   %edi
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fa:	89 d1                	mov    %edx,%ecx
  8000fc:	89 d3                	mov    %edx,%ebx
  8000fe:	89 d7                	mov    %edx,%edi
  800100:	89 d6                	mov    %edx,%esi
  800102:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	5f                   	pop    %edi
  800107:	5d                   	pop    %ebp
  800108:	c3                   	ret    

00800109 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800109:	55                   	push   %ebp
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	57                   	push   %edi
  80010d:	56                   	push   %esi
  80010e:	53                   	push   %ebx
  80010f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800112:	b9 00 00 00 00       	mov    $0x0,%ecx
  800117:	b8 03 00 00 00       	mov    $0x3,%eax
  80011c:	8b 55 08             	mov    0x8(%ebp),%edx
  80011f:	89 cb                	mov    %ecx,%ebx
  800121:	89 cf                	mov    %ecx,%edi
  800123:	89 ce                	mov    %ecx,%esi
  800125:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800127:	85 c0                	test   %eax,%eax
  800129:	7e 28                	jle    800153 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80012b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80012f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800136:	00 
  800137:	c7 44 24 08 2a 25 80 	movl   $0x80252a,0x8(%esp)
  80013e:	00 
  80013f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800146:	00 
  800147:	c7 04 24 47 25 80 00 	movl   $0x802547,(%esp)
  80014e:	e8 dd 15 00 00       	call   801730 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800153:	83 c4 2c             	add    $0x2c,%esp
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800161:	ba 00 00 00 00       	mov    $0x0,%edx
  800166:	b8 02 00 00 00       	mov    $0x2,%eax
  80016b:	89 d1                	mov    %edx,%ecx
  80016d:	89 d3                	mov    %edx,%ebx
  80016f:	89 d7                	mov    %edx,%edi
  800171:	89 d6                	mov    %edx,%esi
  800173:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5f                   	pop    %edi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    

0080017a <sys_yield>:

void
sys_yield(void)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	57                   	push   %edi
  80017e:	56                   	push   %esi
  80017f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800180:	ba 00 00 00 00       	mov    $0x0,%edx
  800185:	b8 0b 00 00 00       	mov    $0xb,%eax
  80018a:	89 d1                	mov    %edx,%ecx
  80018c:	89 d3                	mov    %edx,%ebx
  80018e:	89 d7                	mov    %edx,%edi
  800190:	89 d6                	mov    %edx,%esi
  800192:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	be 00 00 00 00       	mov    $0x0,%esi
  8001a7:	b8 04 00 00 00       	mov    $0x4,%eax
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	89 f7                	mov    %esi,%edi
  8001b7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b9:	85 c0                	test   %eax,%eax
  8001bb:	7e 28                	jle    8001e5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001c1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 08 2a 25 80 	movl   $0x80252a,0x8(%esp)
  8001d0:	00 
  8001d1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001d8:	00 
  8001d9:	c7 04 24 47 25 80 00 	movl   $0x802547,(%esp)
  8001e0:	e8 4b 15 00 00       	call   801730 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001e5:	83 c4 2c             	add    $0x2c,%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5e                   	pop    %esi
  8001ea:	5f                   	pop    %edi
  8001eb:	5d                   	pop    %ebp
  8001ec:	c3                   	ret    

008001ed <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001fb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001fe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800201:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800204:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800207:	8b 55 08             	mov    0x8(%ebp),%edx
  80020a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7e 28                	jle    800238 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800210:	89 44 24 10          	mov    %eax,0x10(%esp)
  800214:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80021b:	00 
  80021c:	c7 44 24 08 2a 25 80 	movl   $0x80252a,0x8(%esp)
  800223:	00 
  800224:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80022b:	00 
  80022c:	c7 04 24 47 25 80 00 	movl   $0x802547,(%esp)
  800233:	e8 f8 14 00 00       	call   801730 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800238:	83 c4 2c             	add    $0x2c,%esp
  80023b:	5b                   	pop    %ebx
  80023c:	5e                   	pop    %esi
  80023d:	5f                   	pop    %edi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024e:	b8 06 00 00 00       	mov    $0x6,%eax
  800253:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	89 df                	mov    %ebx,%edi
  80025b:	89 de                	mov    %ebx,%esi
  80025d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80025f:	85 c0                	test   %eax,%eax
  800261:	7e 28                	jle    80028b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800263:	89 44 24 10          	mov    %eax,0x10(%esp)
  800267:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80026e:	00 
  80026f:	c7 44 24 08 2a 25 80 	movl   $0x80252a,0x8(%esp)
  800276:	00 
  800277:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80027e:	00 
  80027f:	c7 04 24 47 25 80 00 	movl   $0x802547,(%esp)
  800286:	e8 a5 14 00 00       	call   801730 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80028b:	83 c4 2c             	add    $0x2c,%esp
  80028e:	5b                   	pop    %ebx
  80028f:	5e                   	pop    %esi
  800290:	5f                   	pop    %edi
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    

00800293 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	57                   	push   %edi
  800297:	56                   	push   %esi
  800298:	53                   	push   %ebx
  800299:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80029c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002a1:	b8 08 00 00 00       	mov    $0x8,%eax
  8002a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ac:	89 df                	mov    %ebx,%edi
  8002ae:	89 de                	mov    %ebx,%esi
  8002b0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002b2:	85 c0                	test   %eax,%eax
  8002b4:	7e 28                	jle    8002de <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ba:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 08 2a 25 80 	movl   $0x80252a,0x8(%esp)
  8002c9:	00 
  8002ca:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002d1:	00 
  8002d2:	c7 04 24 47 25 80 00 	movl   $0x802547,(%esp)
  8002d9:	e8 52 14 00 00       	call   801730 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002de:	83 c4 2c             	add    $0x2c,%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	57                   	push   %edi
  8002ea:	56                   	push   %esi
  8002eb:	53                   	push   %ebx
  8002ec:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002f4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ff:	89 df                	mov    %ebx,%edi
  800301:	89 de                	mov    %ebx,%esi
  800303:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800305:	85 c0                	test   %eax,%eax
  800307:	7e 28                	jle    800331 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800309:	89 44 24 10          	mov    %eax,0x10(%esp)
  80030d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800314:	00 
  800315:	c7 44 24 08 2a 25 80 	movl   $0x80252a,0x8(%esp)
  80031c:	00 
  80031d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800324:	00 
  800325:	c7 04 24 47 25 80 00 	movl   $0x802547,(%esp)
  80032c:	e8 ff 13 00 00       	call   801730 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800331:	83 c4 2c             	add    $0x2c,%esp
  800334:	5b                   	pop    %ebx
  800335:	5e                   	pop    %esi
  800336:	5f                   	pop    %edi
  800337:	5d                   	pop    %ebp
  800338:	c3                   	ret    

00800339 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	57                   	push   %edi
  80033d:	56                   	push   %esi
  80033e:	53                   	push   %ebx
  80033f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800342:	bb 00 00 00 00       	mov    $0x0,%ebx
  800347:	b8 0a 00 00 00       	mov    $0xa,%eax
  80034c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034f:	8b 55 08             	mov    0x8(%ebp),%edx
  800352:	89 df                	mov    %ebx,%edi
  800354:	89 de                	mov    %ebx,%esi
  800356:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800358:	85 c0                	test   %eax,%eax
  80035a:	7e 28                	jle    800384 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800360:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800367:	00 
  800368:	c7 44 24 08 2a 25 80 	movl   $0x80252a,0x8(%esp)
  80036f:	00 
  800370:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800377:	00 
  800378:	c7 04 24 47 25 80 00 	movl   $0x802547,(%esp)
  80037f:	e8 ac 13 00 00       	call   801730 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800384:	83 c4 2c             	add    $0x2c,%esp
  800387:	5b                   	pop    %ebx
  800388:	5e                   	pop    %esi
  800389:	5f                   	pop    %edi
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	57                   	push   %edi
  800390:	56                   	push   %esi
  800391:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800392:	be 00 00 00 00       	mov    $0x0,%esi
  800397:	b8 0c 00 00 00       	mov    $0xc,%eax
  80039c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80039f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003aa:	5b                   	pop    %ebx
  8003ab:	5e                   	pop    %esi
  8003ac:	5f                   	pop    %edi
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003af:	55                   	push   %ebp
  8003b0:	89 e5                	mov    %esp,%ebp
  8003b2:	57                   	push   %edi
  8003b3:	56                   	push   %esi
  8003b4:	53                   	push   %ebx
  8003b5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003bd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c5:	89 cb                	mov    %ecx,%ebx
  8003c7:	89 cf                	mov    %ecx,%edi
  8003c9:	89 ce                	mov    %ecx,%esi
  8003cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003cd:	85 c0                	test   %eax,%eax
  8003cf:	7e 28                	jle    8003f9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003d5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003dc:	00 
  8003dd:	c7 44 24 08 2a 25 80 	movl   $0x80252a,0x8(%esp)
  8003e4:	00 
  8003e5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003ec:	00 
  8003ed:	c7 04 24 47 25 80 00 	movl   $0x802547,(%esp)
  8003f4:	e8 37 13 00 00       	call   801730 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003f9:	83 c4 2c             	add    $0x2c,%esp
  8003fc:	5b                   	pop    %ebx
  8003fd:	5e                   	pop    %esi
  8003fe:	5f                   	pop    %edi
  8003ff:	5d                   	pop    %ebp
  800400:	c3                   	ret    

00800401 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800401:	55                   	push   %ebp
  800402:	89 e5                	mov    %esp,%ebp
  800404:	57                   	push   %edi
  800405:	56                   	push   %esi
  800406:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800407:	ba 00 00 00 00       	mov    $0x0,%edx
  80040c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800411:	89 d1                	mov    %edx,%ecx
  800413:	89 d3                	mov    %edx,%ebx
  800415:	89 d7                	mov    %edx,%edi
  800417:	89 d6                	mov    %edx,%esi
  800419:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80041b:	5b                   	pop    %ebx
  80041c:	5e                   	pop    %esi
  80041d:	5f                   	pop    %edi
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	57                   	push   %edi
  800424:	56                   	push   %esi
  800425:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800426:	bb 00 00 00 00       	mov    $0x0,%ebx
  80042b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800430:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800433:	8b 55 08             	mov    0x8(%ebp),%edx
  800436:	89 df                	mov    %ebx,%edi
  800438:	89 de                	mov    %ebx,%esi
  80043a:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  80043c:	5b                   	pop    %ebx
  80043d:	5e                   	pop    %esi
  80043e:	5f                   	pop    %edi
  80043f:	5d                   	pop    %ebp
  800440:	c3                   	ret    

00800441 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800441:	55                   	push   %ebp
  800442:	89 e5                	mov    %esp,%ebp
  800444:	57                   	push   %edi
  800445:	56                   	push   %esi
  800446:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800447:	bb 00 00 00 00       	mov    $0x0,%ebx
  80044c:	b8 10 00 00 00       	mov    $0x10,%eax
  800451:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800454:	8b 55 08             	mov    0x8(%ebp),%edx
  800457:	89 df                	mov    %ebx,%edi
  800459:	89 de                	mov    %ebx,%esi
  80045b:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  80045d:	5b                   	pop    %ebx
  80045e:	5e                   	pop    %esi
  80045f:	5f                   	pop    %edi
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    
	...

00800464 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800464:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800465:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80046a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80046c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  80046f:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  800473:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  800477:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  80047a:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  80047c:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  800480:	83 c4 08             	add    $0x8,%esp
	popal
  800483:	61                   	popa   

	addl $4,%esp 
  800484:	83 c4 04             	add    $0x4,%esp
	popfl
  800487:	9d                   	popf   

	popl %esp
  800488:	5c                   	pop    %esp

	ret
  800489:	c3                   	ret    
	...

0080048c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80048c:	55                   	push   %ebp
  80048d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80048f:	8b 45 08             	mov    0x8(%ebp),%eax
  800492:	05 00 00 00 30       	add    $0x30000000,%eax
  800497:	c1 e8 0c             	shr    $0xc,%eax
}
  80049a:	5d                   	pop    %ebp
  80049b:	c3                   	ret    

0080049c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80049c:	55                   	push   %ebp
  80049d:	89 e5                	mov    %esp,%ebp
  80049f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8004a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a5:	89 04 24             	mov    %eax,(%esp)
  8004a8:	e8 df ff ff ff       	call   80048c <fd2num>
  8004ad:	c1 e0 0c             	shl    $0xc,%eax
  8004b0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8004b5:	c9                   	leave  
  8004b6:	c3                   	ret    

008004b7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8004b7:	55                   	push   %ebp
  8004b8:	89 e5                	mov    %esp,%ebp
  8004ba:	53                   	push   %ebx
  8004bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004be:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8004c3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8004c5:	89 c2                	mov    %eax,%edx
  8004c7:	c1 ea 16             	shr    $0x16,%edx
  8004ca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004d1:	f6 c2 01             	test   $0x1,%dl
  8004d4:	74 11                	je     8004e7 <fd_alloc+0x30>
  8004d6:	89 c2                	mov    %eax,%edx
  8004d8:	c1 ea 0c             	shr    $0xc,%edx
  8004db:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004e2:	f6 c2 01             	test   $0x1,%dl
  8004e5:	75 09                	jne    8004f0 <fd_alloc+0x39>
			*fd_store = fd;
  8004e7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8004e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ee:	eb 17                	jmp    800507 <fd_alloc+0x50>
  8004f0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8004f5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8004fa:	75 c7                	jne    8004c3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8004fc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800502:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800507:	5b                   	pop    %ebx
  800508:	5d                   	pop    %ebp
  800509:	c3                   	ret    

0080050a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80050a:	55                   	push   %ebp
  80050b:	89 e5                	mov    %esp,%ebp
  80050d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800510:	83 f8 1f             	cmp    $0x1f,%eax
  800513:	77 36                	ja     80054b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800515:	c1 e0 0c             	shl    $0xc,%eax
  800518:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80051d:	89 c2                	mov    %eax,%edx
  80051f:	c1 ea 16             	shr    $0x16,%edx
  800522:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800529:	f6 c2 01             	test   $0x1,%dl
  80052c:	74 24                	je     800552 <fd_lookup+0x48>
  80052e:	89 c2                	mov    %eax,%edx
  800530:	c1 ea 0c             	shr    $0xc,%edx
  800533:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80053a:	f6 c2 01             	test   $0x1,%dl
  80053d:	74 1a                	je     800559 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80053f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800542:	89 02                	mov    %eax,(%edx)
	return 0;
  800544:	b8 00 00 00 00       	mov    $0x0,%eax
  800549:	eb 13                	jmp    80055e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80054b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800550:	eb 0c                	jmp    80055e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800552:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800557:	eb 05                	jmp    80055e <fd_lookup+0x54>
  800559:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80055e:	5d                   	pop    %ebp
  80055f:	c3                   	ret    

00800560 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	53                   	push   %ebx
  800564:	83 ec 14             	sub    $0x14,%esp
  800567:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80056a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80056d:	ba 00 00 00 00       	mov    $0x0,%edx
  800572:	eb 0e                	jmp    800582 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800574:	39 08                	cmp    %ecx,(%eax)
  800576:	75 09                	jne    800581 <dev_lookup+0x21>
			*dev = devtab[i];
  800578:	89 03                	mov    %eax,(%ebx)
			return 0;
  80057a:	b8 00 00 00 00       	mov    $0x0,%eax
  80057f:	eb 33                	jmp    8005b4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800581:	42                   	inc    %edx
  800582:	8b 04 95 d4 25 80 00 	mov    0x8025d4(,%edx,4),%eax
  800589:	85 c0                	test   %eax,%eax
  80058b:	75 e7                	jne    800574 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80058d:	a1 08 40 80 00       	mov    0x804008,%eax
  800592:	8b 40 48             	mov    0x48(%eax),%eax
  800595:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800599:	89 44 24 04          	mov    %eax,0x4(%esp)
  80059d:	c7 04 24 58 25 80 00 	movl   $0x802558,(%esp)
  8005a4:	e8 7f 12 00 00       	call   801828 <cprintf>
	*dev = 0;
  8005a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8005af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8005b4:	83 c4 14             	add    $0x14,%esp
  8005b7:	5b                   	pop    %ebx
  8005b8:	5d                   	pop    %ebp
  8005b9:	c3                   	ret    

008005ba <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8005ba:	55                   	push   %ebp
  8005bb:	89 e5                	mov    %esp,%ebp
  8005bd:	56                   	push   %esi
  8005be:	53                   	push   %ebx
  8005bf:	83 ec 30             	sub    $0x30,%esp
  8005c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c5:	8a 45 0c             	mov    0xc(%ebp),%al
  8005c8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8005cb:	89 34 24             	mov    %esi,(%esp)
  8005ce:	e8 b9 fe ff ff       	call   80048c <fd2num>
  8005d3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8005d6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005da:	89 04 24             	mov    %eax,(%esp)
  8005dd:	e8 28 ff ff ff       	call   80050a <fd_lookup>
  8005e2:	89 c3                	mov    %eax,%ebx
  8005e4:	85 c0                	test   %eax,%eax
  8005e6:	78 05                	js     8005ed <fd_close+0x33>
	    || fd != fd2)
  8005e8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8005eb:	74 0d                	je     8005fa <fd_close+0x40>
		return (must_exist ? r : 0);
  8005ed:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8005f1:	75 46                	jne    800639 <fd_close+0x7f>
  8005f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005f8:	eb 3f                	jmp    800639 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8005fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800601:	8b 06                	mov    (%esi),%eax
  800603:	89 04 24             	mov    %eax,(%esp)
  800606:	e8 55 ff ff ff       	call   800560 <dev_lookup>
  80060b:	89 c3                	mov    %eax,%ebx
  80060d:	85 c0                	test   %eax,%eax
  80060f:	78 18                	js     800629 <fd_close+0x6f>
		if (dev->dev_close)
  800611:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800614:	8b 40 10             	mov    0x10(%eax),%eax
  800617:	85 c0                	test   %eax,%eax
  800619:	74 09                	je     800624 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80061b:	89 34 24             	mov    %esi,(%esp)
  80061e:	ff d0                	call   *%eax
  800620:	89 c3                	mov    %eax,%ebx
  800622:	eb 05                	jmp    800629 <fd_close+0x6f>
		else
			r = 0;
  800624:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800629:	89 74 24 04          	mov    %esi,0x4(%esp)
  80062d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800634:	e8 07 fc ff ff       	call   800240 <sys_page_unmap>
	return r;
}
  800639:	89 d8                	mov    %ebx,%eax
  80063b:	83 c4 30             	add    $0x30,%esp
  80063e:	5b                   	pop    %ebx
  80063f:	5e                   	pop    %esi
  800640:	5d                   	pop    %ebp
  800641:	c3                   	ret    

00800642 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800642:	55                   	push   %ebp
  800643:	89 e5                	mov    %esp,%ebp
  800645:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800648:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80064f:	8b 45 08             	mov    0x8(%ebp),%eax
  800652:	89 04 24             	mov    %eax,(%esp)
  800655:	e8 b0 fe ff ff       	call   80050a <fd_lookup>
  80065a:	85 c0                	test   %eax,%eax
  80065c:	78 13                	js     800671 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80065e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800665:	00 
  800666:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800669:	89 04 24             	mov    %eax,(%esp)
  80066c:	e8 49 ff ff ff       	call   8005ba <fd_close>
}
  800671:	c9                   	leave  
  800672:	c3                   	ret    

00800673 <close_all>:

void
close_all(void)
{
  800673:	55                   	push   %ebp
  800674:	89 e5                	mov    %esp,%ebp
  800676:	53                   	push   %ebx
  800677:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80067a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80067f:	89 1c 24             	mov    %ebx,(%esp)
  800682:	e8 bb ff ff ff       	call   800642 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800687:	43                   	inc    %ebx
  800688:	83 fb 20             	cmp    $0x20,%ebx
  80068b:	75 f2                	jne    80067f <close_all+0xc>
		close(i);
}
  80068d:	83 c4 14             	add    $0x14,%esp
  800690:	5b                   	pop    %ebx
  800691:	5d                   	pop    %ebp
  800692:	c3                   	ret    

00800693 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800693:	55                   	push   %ebp
  800694:	89 e5                	mov    %esp,%ebp
  800696:	57                   	push   %edi
  800697:	56                   	push   %esi
  800698:	53                   	push   %ebx
  800699:	83 ec 4c             	sub    $0x4c,%esp
  80069c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80069f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8006a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a9:	89 04 24             	mov    %eax,(%esp)
  8006ac:	e8 59 fe ff ff       	call   80050a <fd_lookup>
  8006b1:	89 c3                	mov    %eax,%ebx
  8006b3:	85 c0                	test   %eax,%eax
  8006b5:	0f 88 e3 00 00 00    	js     80079e <dup+0x10b>
		return r;
	close(newfdnum);
  8006bb:	89 3c 24             	mov    %edi,(%esp)
  8006be:	e8 7f ff ff ff       	call   800642 <close>

	newfd = INDEX2FD(newfdnum);
  8006c3:	89 fe                	mov    %edi,%esi
  8006c5:	c1 e6 0c             	shl    $0xc,%esi
  8006c8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8006ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006d1:	89 04 24             	mov    %eax,(%esp)
  8006d4:	e8 c3 fd ff ff       	call   80049c <fd2data>
  8006d9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8006db:	89 34 24             	mov    %esi,(%esp)
  8006de:	e8 b9 fd ff ff       	call   80049c <fd2data>
  8006e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8006e6:	89 d8                	mov    %ebx,%eax
  8006e8:	c1 e8 16             	shr    $0x16,%eax
  8006eb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8006f2:	a8 01                	test   $0x1,%al
  8006f4:	74 46                	je     80073c <dup+0xa9>
  8006f6:	89 d8                	mov    %ebx,%eax
  8006f8:	c1 e8 0c             	shr    $0xc,%eax
  8006fb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800702:	f6 c2 01             	test   $0x1,%dl
  800705:	74 35                	je     80073c <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800707:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80070e:	25 07 0e 00 00       	and    $0xe07,%eax
  800713:	89 44 24 10          	mov    %eax,0x10(%esp)
  800717:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80071a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80071e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800725:	00 
  800726:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800731:	e8 b7 fa ff ff       	call   8001ed <sys_page_map>
  800736:	89 c3                	mov    %eax,%ebx
  800738:	85 c0                	test   %eax,%eax
  80073a:	78 3b                	js     800777 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80073c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80073f:	89 c2                	mov    %eax,%edx
  800741:	c1 ea 0c             	shr    $0xc,%edx
  800744:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80074b:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800751:	89 54 24 10          	mov    %edx,0x10(%esp)
  800755:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800759:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800760:	00 
  800761:	89 44 24 04          	mov    %eax,0x4(%esp)
  800765:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80076c:	e8 7c fa ff ff       	call   8001ed <sys_page_map>
  800771:	89 c3                	mov    %eax,%ebx
  800773:	85 c0                	test   %eax,%eax
  800775:	79 25                	jns    80079c <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800777:	89 74 24 04          	mov    %esi,0x4(%esp)
  80077b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800782:	e8 b9 fa ff ff       	call   800240 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800787:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80078a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800795:	e8 a6 fa ff ff       	call   800240 <sys_page_unmap>
	return r;
  80079a:	eb 02                	jmp    80079e <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80079c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80079e:	89 d8                	mov    %ebx,%eax
  8007a0:	83 c4 4c             	add    $0x4c,%esp
  8007a3:	5b                   	pop    %ebx
  8007a4:	5e                   	pop    %esi
  8007a5:	5f                   	pop    %edi
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	83 ec 24             	sub    $0x24,%esp
  8007af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b9:	89 1c 24             	mov    %ebx,(%esp)
  8007bc:	e8 49 fd ff ff       	call   80050a <fd_lookup>
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	78 6d                	js     800832 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007cf:	8b 00                	mov    (%eax),%eax
  8007d1:	89 04 24             	mov    %eax,(%esp)
  8007d4:	e8 87 fd ff ff       	call   800560 <dev_lookup>
  8007d9:	85 c0                	test   %eax,%eax
  8007db:	78 55                	js     800832 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8007dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e0:	8b 50 08             	mov    0x8(%eax),%edx
  8007e3:	83 e2 03             	and    $0x3,%edx
  8007e6:	83 fa 01             	cmp    $0x1,%edx
  8007e9:	75 23                	jne    80080e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8007eb:	a1 08 40 80 00       	mov    0x804008,%eax
  8007f0:	8b 40 48             	mov    0x48(%eax),%eax
  8007f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fb:	c7 04 24 99 25 80 00 	movl   $0x802599,(%esp)
  800802:	e8 21 10 00 00       	call   801828 <cprintf>
		return -E_INVAL;
  800807:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80080c:	eb 24                	jmp    800832 <read+0x8a>
	}
	if (!dev->dev_read)
  80080e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800811:	8b 52 08             	mov    0x8(%edx),%edx
  800814:	85 d2                	test   %edx,%edx
  800816:	74 15                	je     80082d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800818:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80081b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80081f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800822:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800826:	89 04 24             	mov    %eax,(%esp)
  800829:	ff d2                	call   *%edx
  80082b:	eb 05                	jmp    800832 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80082d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800832:	83 c4 24             	add    $0x24,%esp
  800835:	5b                   	pop    %ebx
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	57                   	push   %edi
  80083c:	56                   	push   %esi
  80083d:	53                   	push   %ebx
  80083e:	83 ec 1c             	sub    $0x1c,%esp
  800841:	8b 7d 08             	mov    0x8(%ebp),%edi
  800844:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800847:	bb 00 00 00 00       	mov    $0x0,%ebx
  80084c:	eb 23                	jmp    800871 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80084e:	89 f0                	mov    %esi,%eax
  800850:	29 d8                	sub    %ebx,%eax
  800852:	89 44 24 08          	mov    %eax,0x8(%esp)
  800856:	8b 45 0c             	mov    0xc(%ebp),%eax
  800859:	01 d8                	add    %ebx,%eax
  80085b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085f:	89 3c 24             	mov    %edi,(%esp)
  800862:	e8 41 ff ff ff       	call   8007a8 <read>
		if (m < 0)
  800867:	85 c0                	test   %eax,%eax
  800869:	78 10                	js     80087b <readn+0x43>
			return m;
		if (m == 0)
  80086b:	85 c0                	test   %eax,%eax
  80086d:	74 0a                	je     800879 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80086f:	01 c3                	add    %eax,%ebx
  800871:	39 f3                	cmp    %esi,%ebx
  800873:	72 d9                	jb     80084e <readn+0x16>
  800875:	89 d8                	mov    %ebx,%eax
  800877:	eb 02                	jmp    80087b <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800879:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80087b:	83 c4 1c             	add    $0x1c,%esp
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5f                   	pop    %edi
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	53                   	push   %ebx
  800887:	83 ec 24             	sub    $0x24,%esp
  80088a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800890:	89 44 24 04          	mov    %eax,0x4(%esp)
  800894:	89 1c 24             	mov    %ebx,(%esp)
  800897:	e8 6e fc ff ff       	call   80050a <fd_lookup>
  80089c:	85 c0                	test   %eax,%eax
  80089e:	78 68                	js     800908 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008aa:	8b 00                	mov    (%eax),%eax
  8008ac:	89 04 24             	mov    %eax,(%esp)
  8008af:	e8 ac fc ff ff       	call   800560 <dev_lookup>
  8008b4:	85 c0                	test   %eax,%eax
  8008b6:	78 50                	js     800908 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008bb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008bf:	75 23                	jne    8008e4 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8008c1:	a1 08 40 80 00       	mov    0x804008,%eax
  8008c6:	8b 40 48             	mov    0x48(%eax),%eax
  8008c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d1:	c7 04 24 b5 25 80 00 	movl   $0x8025b5,(%esp)
  8008d8:	e8 4b 0f 00 00       	call   801828 <cprintf>
		return -E_INVAL;
  8008dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008e2:	eb 24                	jmp    800908 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8008e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008e7:	8b 52 0c             	mov    0xc(%edx),%edx
  8008ea:	85 d2                	test   %edx,%edx
  8008ec:	74 15                	je     800903 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8008ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008f1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008f8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008fc:	89 04 24             	mov    %eax,(%esp)
  8008ff:	ff d2                	call   *%edx
  800901:	eb 05                	jmp    800908 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800903:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  800908:	83 c4 24             	add    $0x24,%esp
  80090b:	5b                   	pop    %ebx
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <seek>:

int
seek(int fdnum, off_t offset)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800914:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800917:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	89 04 24             	mov    %eax,(%esp)
  800921:	e8 e4 fb ff ff       	call   80050a <fd_lookup>
  800926:	85 c0                	test   %eax,%eax
  800928:	78 0e                	js     800938 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80092a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80092d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800930:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800933:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800938:	c9                   	leave  
  800939:	c3                   	ret    

0080093a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	53                   	push   %ebx
  80093e:	83 ec 24             	sub    $0x24,%esp
  800941:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800944:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800947:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094b:	89 1c 24             	mov    %ebx,(%esp)
  80094e:	e8 b7 fb ff ff       	call   80050a <fd_lookup>
  800953:	85 c0                	test   %eax,%eax
  800955:	78 61                	js     8009b8 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800957:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80095a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800961:	8b 00                	mov    (%eax),%eax
  800963:	89 04 24             	mov    %eax,(%esp)
  800966:	e8 f5 fb ff ff       	call   800560 <dev_lookup>
  80096b:	85 c0                	test   %eax,%eax
  80096d:	78 49                	js     8009b8 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80096f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800972:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800976:	75 23                	jne    80099b <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800978:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80097d:	8b 40 48             	mov    0x48(%eax),%eax
  800980:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800984:	89 44 24 04          	mov    %eax,0x4(%esp)
  800988:	c7 04 24 78 25 80 00 	movl   $0x802578,(%esp)
  80098f:	e8 94 0e 00 00       	call   801828 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800994:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800999:	eb 1d                	jmp    8009b8 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80099b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80099e:	8b 52 18             	mov    0x18(%edx),%edx
  8009a1:	85 d2                	test   %edx,%edx
  8009a3:	74 0e                	je     8009b3 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8009a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009ac:	89 04 24             	mov    %eax,(%esp)
  8009af:	ff d2                	call   *%edx
  8009b1:	eb 05                	jmp    8009b8 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8009b3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8009b8:	83 c4 24             	add    $0x24,%esp
  8009bb:	5b                   	pop    %ebx
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	53                   	push   %ebx
  8009c2:	83 ec 24             	sub    $0x24,%esp
  8009c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d2:	89 04 24             	mov    %eax,(%esp)
  8009d5:	e8 30 fb ff ff       	call   80050a <fd_lookup>
  8009da:	85 c0                	test   %eax,%eax
  8009dc:	78 52                	js     800a30 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009e8:	8b 00                	mov    (%eax),%eax
  8009ea:	89 04 24             	mov    %eax,(%esp)
  8009ed:	e8 6e fb ff ff       	call   800560 <dev_lookup>
  8009f2:	85 c0                	test   %eax,%eax
  8009f4:	78 3a                	js     800a30 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8009f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8009fd:	74 2c                	je     800a2b <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8009ff:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800a02:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800a09:	00 00 00 
	stat->st_isdir = 0;
  800a0c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800a13:	00 00 00 
	stat->st_dev = dev;
  800a16:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800a1c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a20:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a23:	89 14 24             	mov    %edx,(%esp)
  800a26:	ff 50 14             	call   *0x14(%eax)
  800a29:	eb 05                	jmp    800a30 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800a2b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800a30:	83 c4 24             	add    $0x24,%esp
  800a33:	5b                   	pop    %ebx
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
  800a3b:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800a3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a45:	00 
  800a46:	8b 45 08             	mov    0x8(%ebp),%eax
  800a49:	89 04 24             	mov    %eax,(%esp)
  800a4c:	e8 2a 02 00 00       	call   800c7b <open>
  800a51:	89 c3                	mov    %eax,%ebx
  800a53:	85 c0                	test   %eax,%eax
  800a55:	78 1b                	js     800a72 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800a57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5e:	89 1c 24             	mov    %ebx,(%esp)
  800a61:	e8 58 ff ff ff       	call   8009be <fstat>
  800a66:	89 c6                	mov    %eax,%esi
	close(fd);
  800a68:	89 1c 24             	mov    %ebx,(%esp)
  800a6b:	e8 d2 fb ff ff       	call   800642 <close>
	return r;
  800a70:	89 f3                	mov    %esi,%ebx
}
  800a72:	89 d8                	mov    %ebx,%eax
  800a74:	83 c4 10             	add    $0x10,%esp
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    
	...

00800a7c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	83 ec 10             	sub    $0x10,%esp
  800a84:	89 c3                	mov    %eax,%ebx
  800a86:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a88:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a8f:	75 11                	jne    800aa2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a91:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a98:	e8 9a 17 00 00       	call   802237 <ipc_find_env>
  800a9d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800aa2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800aa9:	00 
  800aaa:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800ab1:	00 
  800ab2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ab6:	a1 00 40 80 00       	mov    0x804000,%eax
  800abb:	89 04 24             	mov    %eax,(%esp)
  800abe:	e8 f1 16 00 00       	call   8021b4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ac3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800aca:	00 
  800acb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800acf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ad6:	e8 69 16 00 00       	call   802144 <ipc_recv>
}
  800adb:	83 c4 10             	add    $0x10,%esp
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ae8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aeb:	8b 40 0c             	mov    0xc(%eax),%eax
  800aee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800af3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800afb:	ba 00 00 00 00       	mov    $0x0,%edx
  800b00:	b8 02 00 00 00       	mov    $0x2,%eax
  800b05:	e8 72 ff ff ff       	call   800a7c <fsipc>
}
  800b0a:	c9                   	leave  
  800b0b:	c3                   	ret    

00800b0c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
  800b15:	8b 40 0c             	mov    0xc(%eax),%eax
  800b18:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800b1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b22:	b8 06 00 00 00       	mov    $0x6,%eax
  800b27:	e8 50 ff ff ff       	call   800a7c <fsipc>
}
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	53                   	push   %ebx
  800b32:	83 ec 14             	sub    $0x14,%esp
  800b35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800b38:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3b:	8b 40 0c             	mov    0xc(%eax),%eax
  800b3e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 05 00 00 00       	mov    $0x5,%eax
  800b4d:	e8 2a ff ff ff       	call   800a7c <fsipc>
  800b52:	85 c0                	test   %eax,%eax
  800b54:	78 2b                	js     800b81 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800b56:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b5d:	00 
  800b5e:	89 1c 24             	mov    %ebx,(%esp)
  800b61:	e8 6d 12 00 00       	call   801dd3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b66:	a1 80 50 80 00       	mov    0x805080,%eax
  800b6b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b71:	a1 84 50 80 00       	mov    0x805084,%eax
  800b76:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b81:	83 c4 14             	add    $0x14,%esp
  800b84:	5b                   	pop    %ebx
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	83 ec 18             	sub    $0x18,%esp
  800b8d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	8b 52 0c             	mov    0xc(%edx),%edx
  800b96:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800b9c:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  800ba1:	89 c2                	mov    %eax,%edx
  800ba3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800ba8:	76 05                	jbe    800baf <devfile_write+0x28>
  800baa:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  800baf:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bba:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800bc1:	e8 f0 13 00 00       	call   801fb6 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800bc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcb:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd0:	e8 a7 fe ff ff       	call   800a7c <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    

00800bd7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	83 ec 10             	sub    $0x10,%esp
  800bdf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800be2:	8b 45 08             	mov    0x8(%ebp),%eax
  800be5:	8b 40 0c             	mov    0xc(%eax),%eax
  800be8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800bed:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800bf3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bfd:	e8 7a fe ff ff       	call   800a7c <fsipc>
  800c02:	89 c3                	mov    %eax,%ebx
  800c04:	85 c0                	test   %eax,%eax
  800c06:	78 6a                	js     800c72 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800c08:	39 c6                	cmp    %eax,%esi
  800c0a:	73 24                	jae    800c30 <devfile_read+0x59>
  800c0c:	c7 44 24 0c e8 25 80 	movl   $0x8025e8,0xc(%esp)
  800c13:	00 
  800c14:	c7 44 24 08 ef 25 80 	movl   $0x8025ef,0x8(%esp)
  800c1b:	00 
  800c1c:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800c23:	00 
  800c24:	c7 04 24 04 26 80 00 	movl   $0x802604,(%esp)
  800c2b:	e8 00 0b 00 00       	call   801730 <_panic>
	assert(r <= PGSIZE);
  800c30:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c35:	7e 24                	jle    800c5b <devfile_read+0x84>
  800c37:	c7 44 24 0c 0f 26 80 	movl   $0x80260f,0xc(%esp)
  800c3e:	00 
  800c3f:	c7 44 24 08 ef 25 80 	movl   $0x8025ef,0x8(%esp)
  800c46:	00 
  800c47:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800c4e:	00 
  800c4f:	c7 04 24 04 26 80 00 	movl   $0x802604,(%esp)
  800c56:	e8 d5 0a 00 00       	call   801730 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c5f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c66:	00 
  800c67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c6a:	89 04 24             	mov    %eax,(%esp)
  800c6d:	e8 da 12 00 00       	call   801f4c <memmove>
	return r;
}
  800c72:	89 d8                	mov    %ebx,%eax
  800c74:	83 c4 10             	add    $0x10,%esp
  800c77:	5b                   	pop    %ebx
  800c78:	5e                   	pop    %esi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 20             	sub    $0x20,%esp
  800c83:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c86:	89 34 24             	mov    %esi,(%esp)
  800c89:	e8 12 11 00 00       	call   801da0 <strlen>
  800c8e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c93:	7f 60                	jg     800cf5 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c98:	89 04 24             	mov    %eax,(%esp)
  800c9b:	e8 17 f8 ff ff       	call   8004b7 <fd_alloc>
  800ca0:	89 c3                	mov    %eax,%ebx
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	78 54                	js     800cfa <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ca6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800caa:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800cb1:	e8 1d 11 00 00       	call   801dd3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cb9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800cbe:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cc1:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc6:	e8 b1 fd ff ff       	call   800a7c <fsipc>
  800ccb:	89 c3                	mov    %eax,%ebx
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	79 15                	jns    800ce6 <open+0x6b>
		fd_close(fd, 0);
  800cd1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800cd8:	00 
  800cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cdc:	89 04 24             	mov    %eax,(%esp)
  800cdf:	e8 d6 f8 ff ff       	call   8005ba <fd_close>
		return r;
  800ce4:	eb 14                	jmp    800cfa <open+0x7f>
	}

	return fd2num(fd);
  800ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ce9:	89 04 24             	mov    %eax,(%esp)
  800cec:	e8 9b f7 ff ff       	call   80048c <fd2num>
  800cf1:	89 c3                	mov    %eax,%ebx
  800cf3:	eb 05                	jmp    800cfa <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cf5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800cfa:	89 d8                	mov    %ebx,%eax
  800cfc:	83 c4 20             	add    $0x20,%esp
  800cff:	5b                   	pop    %ebx
  800d00:	5e                   	pop    %esi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800d09:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d13:	e8 64 fd ff ff       	call   800a7c <fsipc>
}
  800d18:	c9                   	leave  
  800d19:	c3                   	ret    
	...

00800d1c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800d22:	c7 44 24 04 1b 26 80 	movl   $0x80261b,0x4(%esp)
  800d29:	00 
  800d2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2d:	89 04 24             	mov    %eax,(%esp)
  800d30:	e8 9e 10 00 00       	call   801dd3 <strcpy>
	return 0;
}
  800d35:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3a:	c9                   	leave  
  800d3b:	c3                   	ret    

00800d3c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 14             	sub    $0x14,%esp
  800d43:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800d46:	89 1c 24             	mov    %ebx,(%esp)
  800d49:	e8 2e 15 00 00       	call   80227c <pageref>
  800d4e:	83 f8 01             	cmp    $0x1,%eax
  800d51:	75 0d                	jne    800d60 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  800d53:	8b 43 0c             	mov    0xc(%ebx),%eax
  800d56:	89 04 24             	mov    %eax,(%esp)
  800d59:	e8 1f 03 00 00       	call   80107d <nsipc_close>
  800d5e:	eb 05                	jmp    800d65 <devsock_close+0x29>
	else
		return 0;
  800d60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d65:	83 c4 14             	add    $0x14,%esp
  800d68:	5b                   	pop    %ebx
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800d71:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d78:	00 
  800d79:	8b 45 10             	mov    0x10(%ebp),%eax
  800d7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d87:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8a:	8b 40 0c             	mov    0xc(%eax),%eax
  800d8d:	89 04 24             	mov    %eax,(%esp)
  800d90:	e8 e3 03 00 00       	call   801178 <nsipc_send>
}
  800d95:	c9                   	leave  
  800d96:	c3                   	ret    

00800d97 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800d9d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800da4:	00 
  800da5:	8b 45 10             	mov    0x10(%ebp),%eax
  800da8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dac:	8b 45 0c             	mov    0xc(%ebp),%eax
  800daf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db3:	8b 45 08             	mov    0x8(%ebp),%eax
  800db6:	8b 40 0c             	mov    0xc(%eax),%eax
  800db9:	89 04 24             	mov    %eax,(%esp)
  800dbc:	e8 37 03 00 00       	call   8010f8 <nsipc_recv>
}
  800dc1:	c9                   	leave  
  800dc2:	c3                   	ret    

00800dc3 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	83 ec 20             	sub    $0x20,%esp
  800dcb:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800dcd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dd0:	89 04 24             	mov    %eax,(%esp)
  800dd3:	e8 df f6 ff ff       	call   8004b7 <fd_alloc>
  800dd8:	89 c3                	mov    %eax,%ebx
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	78 21                	js     800dff <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800dde:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800de5:	00 
  800de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ded:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800df4:	e8 a0 f3 ff ff       	call   800199 <sys_page_alloc>
  800df9:	89 c3                	mov    %eax,%ebx
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	79 0a                	jns    800e09 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  800dff:	89 34 24             	mov    %esi,(%esp)
  800e02:	e8 76 02 00 00       	call   80107d <nsipc_close>
		return r;
  800e07:	eb 22                	jmp    800e2b <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800e09:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e12:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800e14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e17:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800e1e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800e21:	89 04 24             	mov    %eax,(%esp)
  800e24:	e8 63 f6 ff ff       	call   80048c <fd2num>
  800e29:	89 c3                	mov    %eax,%ebx
}
  800e2b:	89 d8                	mov    %ebx,%eax
  800e2d:	83 c4 20             	add    $0x20,%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800e3a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800e3d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e41:	89 04 24             	mov    %eax,(%esp)
  800e44:	e8 c1 f6 ff ff       	call   80050a <fd_lookup>
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	78 17                	js     800e64 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800e4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e50:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e56:	39 10                	cmp    %edx,(%eax)
  800e58:	75 05                	jne    800e5f <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800e5a:	8b 40 0c             	mov    0xc(%eax),%eax
  800e5d:	eb 05                	jmp    800e64 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800e5f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800e64:	c9                   	leave  
  800e65:	c3                   	ret    

00800e66 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6f:	e8 c0 ff ff ff       	call   800e34 <fd2sockid>
  800e74:	85 c0                	test   %eax,%eax
  800e76:	78 1f                	js     800e97 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800e78:	8b 55 10             	mov    0x10(%ebp),%edx
  800e7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e82:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e86:	89 04 24             	mov    %eax,(%esp)
  800e89:	e8 38 01 00 00       	call   800fc6 <nsipc_accept>
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	78 05                	js     800e97 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  800e92:	e8 2c ff ff ff       	call   800dc3 <alloc_sockfd>
}
  800e97:	c9                   	leave  
  800e98:	c3                   	ret    

00800e99 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea2:	e8 8d ff ff ff       	call   800e34 <fd2sockid>
  800ea7:	85 c0                	test   %eax,%eax
  800ea9:	78 16                	js     800ec1 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  800eab:	8b 55 10             	mov    0x10(%ebp),%edx
  800eae:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eb9:	89 04 24             	mov    %eax,(%esp)
  800ebc:	e8 5b 01 00 00       	call   80101c <nsipc_bind>
}
  800ec1:	c9                   	leave  
  800ec2:	c3                   	ret    

00800ec3 <shutdown>:

int
shutdown(int s, int how)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecc:	e8 63 ff ff ff       	call   800e34 <fd2sockid>
  800ed1:	85 c0                	test   %eax,%eax
  800ed3:	78 0f                	js     800ee4 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800ed5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800edc:	89 04 24             	mov    %eax,(%esp)
  800edf:	e8 77 01 00 00       	call   80105b <nsipc_shutdown>
}
  800ee4:	c9                   	leave  
  800ee5:	c3                   	ret    

00800ee6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800eec:	8b 45 08             	mov    0x8(%ebp),%eax
  800eef:	e8 40 ff ff ff       	call   800e34 <fd2sockid>
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	78 16                	js     800f0e <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  800ef8:	8b 55 10             	mov    0x10(%ebp),%edx
  800efb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f02:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f06:	89 04 24             	mov    %eax,(%esp)
  800f09:	e8 89 01 00 00       	call   801097 <nsipc_connect>
}
  800f0e:	c9                   	leave  
  800f0f:	c3                   	ret    

00800f10 <listen>:

int
listen(int s, int backlog)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f16:	8b 45 08             	mov    0x8(%ebp),%eax
  800f19:	e8 16 ff ff ff       	call   800e34 <fd2sockid>
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	78 0f                	js     800f31 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800f22:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f25:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f29:	89 04 24             	mov    %eax,(%esp)
  800f2c:	e8 a5 01 00 00       	call   8010d6 <nsipc_listen>
}
  800f31:	c9                   	leave  
  800f32:	c3                   	ret    

00800f33 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800f39:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f43:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f47:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4a:	89 04 24             	mov    %eax,(%esp)
  800f4d:	e8 99 02 00 00       	call   8011eb <nsipc_socket>
  800f52:	85 c0                	test   %eax,%eax
  800f54:	78 05                	js     800f5b <socket+0x28>
		return r;
	return alloc_sockfd(r);
  800f56:	e8 68 fe ff ff       	call   800dc3 <alloc_sockfd>
}
  800f5b:	c9                   	leave  
  800f5c:	c3                   	ret    
  800f5d:	00 00                	add    %al,(%eax)
	...

00800f60 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	53                   	push   %ebx
  800f64:	83 ec 14             	sub    $0x14,%esp
  800f67:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800f69:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800f70:	75 11                	jne    800f83 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800f72:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f79:	e8 b9 12 00 00       	call   802237 <ipc_find_env>
  800f7e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800f83:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800f8a:	00 
  800f8b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  800f92:	00 
  800f93:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f97:	a1 04 40 80 00       	mov    0x804004,%eax
  800f9c:	89 04 24             	mov    %eax,(%esp)
  800f9f:	e8 10 12 00 00       	call   8021b4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800fa4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fab:	00 
  800fac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fb3:	00 
  800fb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fbb:	e8 84 11 00 00       	call   802144 <ipc_recv>
}
  800fc0:	83 c4 14             	add    $0x14,%esp
  800fc3:	5b                   	pop    %ebx
  800fc4:	5d                   	pop    %ebp
  800fc5:	c3                   	ret    

00800fc6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	56                   	push   %esi
  800fca:	53                   	push   %ebx
  800fcb:	83 ec 10             	sub    $0x10,%esp
  800fce:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800fd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800fd9:	8b 06                	mov    (%esi),%eax
  800fdb:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800fe0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe5:	e8 76 ff ff ff       	call   800f60 <nsipc>
  800fea:	89 c3                	mov    %eax,%ebx
  800fec:	85 c0                	test   %eax,%eax
  800fee:	78 23                	js     801013 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800ff0:	a1 10 60 80 00       	mov    0x806010,%eax
  800ff5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ff9:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801000:	00 
  801001:	8b 45 0c             	mov    0xc(%ebp),%eax
  801004:	89 04 24             	mov    %eax,(%esp)
  801007:	e8 40 0f 00 00       	call   801f4c <memmove>
		*addrlen = ret->ret_addrlen;
  80100c:	a1 10 60 80 00       	mov    0x806010,%eax
  801011:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801013:	89 d8                	mov    %ebx,%eax
  801015:	83 c4 10             	add    $0x10,%esp
  801018:	5b                   	pop    %ebx
  801019:	5e                   	pop    %esi
  80101a:	5d                   	pop    %ebp
  80101b:	c3                   	ret    

0080101c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	53                   	push   %ebx
  801020:	83 ec 14             	sub    $0x14,%esp
  801023:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801026:	8b 45 08             	mov    0x8(%ebp),%eax
  801029:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80102e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801032:	8b 45 0c             	mov    0xc(%ebp),%eax
  801035:	89 44 24 04          	mov    %eax,0x4(%esp)
  801039:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801040:	e8 07 0f 00 00       	call   801f4c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801045:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80104b:	b8 02 00 00 00       	mov    $0x2,%eax
  801050:	e8 0b ff ff ff       	call   800f60 <nsipc>
}
  801055:	83 c4 14             	add    $0x14,%esp
  801058:	5b                   	pop    %ebx
  801059:	5d                   	pop    %ebp
  80105a:	c3                   	ret    

0080105b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801061:	8b 45 08             	mov    0x8(%ebp),%eax
  801064:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801069:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801071:	b8 03 00 00 00       	mov    $0x3,%eax
  801076:	e8 e5 fe ff ff       	call   800f60 <nsipc>
}
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <nsipc_close>:

int
nsipc_close(int s)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801083:	8b 45 08             	mov    0x8(%ebp),%eax
  801086:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80108b:	b8 04 00 00 00       	mov    $0x4,%eax
  801090:	e8 cb fe ff ff       	call   800f60 <nsipc>
}
  801095:	c9                   	leave  
  801096:	c3                   	ret    

00801097 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	53                   	push   %ebx
  80109b:	83 ec 14             	sub    $0x14,%esp
  80109e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8010a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8010a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b4:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8010bb:	e8 8c 0e 00 00       	call   801f4c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8010c0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8010c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8010cb:	e8 90 fe ff ff       	call   800f60 <nsipc>
}
  8010d0:	83 c4 14             	add    $0x14,%esp
  8010d3:	5b                   	pop    %ebx
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    

008010d6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8010dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010df:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8010e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8010ec:	b8 06 00 00 00       	mov    $0x6,%eax
  8010f1:	e8 6a fe ff ff       	call   800f60 <nsipc>
}
  8010f6:	c9                   	leave  
  8010f7:	c3                   	ret    

008010f8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	56                   	push   %esi
  8010fc:	53                   	push   %ebx
  8010fd:	83 ec 10             	sub    $0x10,%esp
  801100:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801103:	8b 45 08             	mov    0x8(%ebp),%eax
  801106:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80110b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801111:	8b 45 14             	mov    0x14(%ebp),%eax
  801114:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801119:	b8 07 00 00 00       	mov    $0x7,%eax
  80111e:	e8 3d fe ff ff       	call   800f60 <nsipc>
  801123:	89 c3                	mov    %eax,%ebx
  801125:	85 c0                	test   %eax,%eax
  801127:	78 46                	js     80116f <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801129:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80112e:	7f 04                	jg     801134 <nsipc_recv+0x3c>
  801130:	39 c6                	cmp    %eax,%esi
  801132:	7d 24                	jge    801158 <nsipc_recv+0x60>
  801134:	c7 44 24 0c 27 26 80 	movl   $0x802627,0xc(%esp)
  80113b:	00 
  80113c:	c7 44 24 08 ef 25 80 	movl   $0x8025ef,0x8(%esp)
  801143:	00 
  801144:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80114b:	00 
  80114c:	c7 04 24 3c 26 80 00 	movl   $0x80263c,(%esp)
  801153:	e8 d8 05 00 00       	call   801730 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801158:	89 44 24 08          	mov    %eax,0x8(%esp)
  80115c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801163:	00 
  801164:	8b 45 0c             	mov    0xc(%ebp),%eax
  801167:	89 04 24             	mov    %eax,(%esp)
  80116a:	e8 dd 0d 00 00       	call   801f4c <memmove>
	}

	return r;
}
  80116f:	89 d8                	mov    %ebx,%eax
  801171:	83 c4 10             	add    $0x10,%esp
  801174:	5b                   	pop    %ebx
  801175:	5e                   	pop    %esi
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	53                   	push   %ebx
  80117c:	83 ec 14             	sub    $0x14,%esp
  80117f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801182:	8b 45 08             	mov    0x8(%ebp),%eax
  801185:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80118a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801190:	7e 24                	jle    8011b6 <nsipc_send+0x3e>
  801192:	c7 44 24 0c 48 26 80 	movl   $0x802648,0xc(%esp)
  801199:	00 
  80119a:	c7 44 24 08 ef 25 80 	movl   $0x8025ef,0x8(%esp)
  8011a1:	00 
  8011a2:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8011a9:	00 
  8011aa:	c7 04 24 3c 26 80 00 	movl   $0x80263c,(%esp)
  8011b1:	e8 7a 05 00 00       	call   801730 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8011b6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c1:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8011c8:	e8 7f 0d 00 00       	call   801f4c <memmove>
	nsipcbuf.send.req_size = size;
  8011cd:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8011d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8011d6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8011db:	b8 08 00 00 00       	mov    $0x8,%eax
  8011e0:	e8 7b fd ff ff       	call   800f60 <nsipc>
}
  8011e5:	83 c4 14             	add    $0x14,%esp
  8011e8:	5b                   	pop    %ebx
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    

008011eb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8011f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8011f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011fc:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801201:	8b 45 10             	mov    0x10(%ebp),%eax
  801204:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801209:	b8 09 00 00 00       	mov    $0x9,%eax
  80120e:	e8 4d fd ff ff       	call   800f60 <nsipc>
}
  801213:	c9                   	leave  
  801214:	c3                   	ret    
  801215:	00 00                	add    %al,(%eax)
	...

00801218 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	56                   	push   %esi
  80121c:	53                   	push   %ebx
  80121d:	83 ec 10             	sub    $0x10,%esp
  801220:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801223:	8b 45 08             	mov    0x8(%ebp),%eax
  801226:	89 04 24             	mov    %eax,(%esp)
  801229:	e8 6e f2 ff ff       	call   80049c <fd2data>
  80122e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801230:	c7 44 24 04 54 26 80 	movl   $0x802654,0x4(%esp)
  801237:	00 
  801238:	89 34 24             	mov    %esi,(%esp)
  80123b:	e8 93 0b 00 00       	call   801dd3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801240:	8b 43 04             	mov    0x4(%ebx),%eax
  801243:	2b 03                	sub    (%ebx),%eax
  801245:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80124b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801252:	00 00 00 
	stat->st_dev = &devpipe;
  801255:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  80125c:	30 80 00 
	return 0;
}
  80125f:	b8 00 00 00 00       	mov    $0x0,%eax
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	5b                   	pop    %ebx
  801268:	5e                   	pop    %esi
  801269:	5d                   	pop    %ebp
  80126a:	c3                   	ret    

0080126b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	53                   	push   %ebx
  80126f:	83 ec 14             	sub    $0x14,%esp
  801272:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801275:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801279:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801280:	e8 bb ef ff ff       	call   800240 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801285:	89 1c 24             	mov    %ebx,(%esp)
  801288:	e8 0f f2 ff ff       	call   80049c <fd2data>
  80128d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801291:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801298:	e8 a3 ef ff ff       	call   800240 <sys_page_unmap>
}
  80129d:	83 c4 14             	add    $0x14,%esp
  8012a0:	5b                   	pop    %ebx
  8012a1:	5d                   	pop    %ebp
  8012a2:	c3                   	ret    

008012a3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8012a3:	55                   	push   %ebp
  8012a4:	89 e5                	mov    %esp,%ebp
  8012a6:	57                   	push   %edi
  8012a7:	56                   	push   %esi
  8012a8:	53                   	push   %ebx
  8012a9:	83 ec 2c             	sub    $0x2c,%esp
  8012ac:	89 c7                	mov    %eax,%edi
  8012ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8012b1:	a1 08 40 80 00       	mov    0x804008,%eax
  8012b6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8012b9:	89 3c 24             	mov    %edi,(%esp)
  8012bc:	e8 bb 0f 00 00       	call   80227c <pageref>
  8012c1:	89 c6                	mov    %eax,%esi
  8012c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c6:	89 04 24             	mov    %eax,(%esp)
  8012c9:	e8 ae 0f 00 00       	call   80227c <pageref>
  8012ce:	39 c6                	cmp    %eax,%esi
  8012d0:	0f 94 c0             	sete   %al
  8012d3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8012d6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8012dc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8012df:	39 cb                	cmp    %ecx,%ebx
  8012e1:	75 08                	jne    8012eb <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8012e3:	83 c4 2c             	add    $0x2c,%esp
  8012e6:	5b                   	pop    %ebx
  8012e7:	5e                   	pop    %esi
  8012e8:	5f                   	pop    %edi
  8012e9:	5d                   	pop    %ebp
  8012ea:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8012eb:	83 f8 01             	cmp    $0x1,%eax
  8012ee:	75 c1                	jne    8012b1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8012f0:	8b 42 58             	mov    0x58(%edx),%eax
  8012f3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8012fa:	00 
  8012fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801303:	c7 04 24 5b 26 80 00 	movl   $0x80265b,(%esp)
  80130a:	e8 19 05 00 00       	call   801828 <cprintf>
  80130f:	eb a0                	jmp    8012b1 <_pipeisclosed+0xe>

00801311 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801311:	55                   	push   %ebp
  801312:	89 e5                	mov    %esp,%ebp
  801314:	57                   	push   %edi
  801315:	56                   	push   %esi
  801316:	53                   	push   %ebx
  801317:	83 ec 1c             	sub    $0x1c,%esp
  80131a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80131d:	89 34 24             	mov    %esi,(%esp)
  801320:	e8 77 f1 ff ff       	call   80049c <fd2data>
  801325:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801327:	bf 00 00 00 00       	mov    $0x0,%edi
  80132c:	eb 3c                	jmp    80136a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80132e:	89 da                	mov    %ebx,%edx
  801330:	89 f0                	mov    %esi,%eax
  801332:	e8 6c ff ff ff       	call   8012a3 <_pipeisclosed>
  801337:	85 c0                	test   %eax,%eax
  801339:	75 38                	jne    801373 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80133b:	e8 3a ee ff ff       	call   80017a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801340:	8b 43 04             	mov    0x4(%ebx),%eax
  801343:	8b 13                	mov    (%ebx),%edx
  801345:	83 c2 20             	add    $0x20,%edx
  801348:	39 d0                	cmp    %edx,%eax
  80134a:	73 e2                	jae    80132e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80134c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80134f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801352:	89 c2                	mov    %eax,%edx
  801354:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80135a:	79 05                	jns    801361 <devpipe_write+0x50>
  80135c:	4a                   	dec    %edx
  80135d:	83 ca e0             	or     $0xffffffe0,%edx
  801360:	42                   	inc    %edx
  801361:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801365:	40                   	inc    %eax
  801366:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801369:	47                   	inc    %edi
  80136a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80136d:	75 d1                	jne    801340 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80136f:	89 f8                	mov    %edi,%eax
  801371:	eb 05                	jmp    801378 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801373:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801378:	83 c4 1c             	add    $0x1c,%esp
  80137b:	5b                   	pop    %ebx
  80137c:	5e                   	pop    %esi
  80137d:	5f                   	pop    %edi
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	57                   	push   %edi
  801384:	56                   	push   %esi
  801385:	53                   	push   %ebx
  801386:	83 ec 1c             	sub    $0x1c,%esp
  801389:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80138c:	89 3c 24             	mov    %edi,(%esp)
  80138f:	e8 08 f1 ff ff       	call   80049c <fd2data>
  801394:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801396:	be 00 00 00 00       	mov    $0x0,%esi
  80139b:	eb 3a                	jmp    8013d7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80139d:	85 f6                	test   %esi,%esi
  80139f:	74 04                	je     8013a5 <devpipe_read+0x25>
				return i;
  8013a1:	89 f0                	mov    %esi,%eax
  8013a3:	eb 40                	jmp    8013e5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8013a5:	89 da                	mov    %ebx,%edx
  8013a7:	89 f8                	mov    %edi,%eax
  8013a9:	e8 f5 fe ff ff       	call   8012a3 <_pipeisclosed>
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	75 2e                	jne    8013e0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8013b2:	e8 c3 ed ff ff       	call   80017a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8013b7:	8b 03                	mov    (%ebx),%eax
  8013b9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8013bc:	74 df                	je     80139d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8013be:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8013c3:	79 05                	jns    8013ca <devpipe_read+0x4a>
  8013c5:	48                   	dec    %eax
  8013c6:	83 c8 e0             	or     $0xffffffe0,%eax
  8013c9:	40                   	inc    %eax
  8013ca:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8013ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8013d4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8013d6:	46                   	inc    %esi
  8013d7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013da:	75 db                	jne    8013b7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8013dc:	89 f0                	mov    %esi,%eax
  8013de:	eb 05                	jmp    8013e5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8013e0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8013e5:	83 c4 1c             	add    $0x1c,%esp
  8013e8:	5b                   	pop    %ebx
  8013e9:	5e                   	pop    %esi
  8013ea:	5f                   	pop    %edi
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    

008013ed <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	57                   	push   %edi
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 3c             	sub    $0x3c,%esp
  8013f6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8013f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013fc:	89 04 24             	mov    %eax,(%esp)
  8013ff:	e8 b3 f0 ff ff       	call   8004b7 <fd_alloc>
  801404:	89 c3                	mov    %eax,%ebx
  801406:	85 c0                	test   %eax,%eax
  801408:	0f 88 45 01 00 00    	js     801553 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80140e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801415:	00 
  801416:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801419:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801424:	e8 70 ed ff ff       	call   800199 <sys_page_alloc>
  801429:	89 c3                	mov    %eax,%ebx
  80142b:	85 c0                	test   %eax,%eax
  80142d:	0f 88 20 01 00 00    	js     801553 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801433:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801436:	89 04 24             	mov    %eax,(%esp)
  801439:	e8 79 f0 ff ff       	call   8004b7 <fd_alloc>
  80143e:	89 c3                	mov    %eax,%ebx
  801440:	85 c0                	test   %eax,%eax
  801442:	0f 88 f8 00 00 00    	js     801540 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801448:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80144f:	00 
  801450:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801453:	89 44 24 04          	mov    %eax,0x4(%esp)
  801457:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80145e:	e8 36 ed ff ff       	call   800199 <sys_page_alloc>
  801463:	89 c3                	mov    %eax,%ebx
  801465:	85 c0                	test   %eax,%eax
  801467:	0f 88 d3 00 00 00    	js     801540 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80146d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801470:	89 04 24             	mov    %eax,(%esp)
  801473:	e8 24 f0 ff ff       	call   80049c <fd2data>
  801478:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80147a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801481:	00 
  801482:	89 44 24 04          	mov    %eax,0x4(%esp)
  801486:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80148d:	e8 07 ed ff ff       	call   800199 <sys_page_alloc>
  801492:	89 c3                	mov    %eax,%ebx
  801494:	85 c0                	test   %eax,%eax
  801496:	0f 88 91 00 00 00    	js     80152d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80149c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80149f:	89 04 24             	mov    %eax,(%esp)
  8014a2:	e8 f5 ef ff ff       	call   80049c <fd2data>
  8014a7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8014ae:	00 
  8014af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014ba:	00 
  8014bb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c6:	e8 22 ed ff ff       	call   8001ed <sys_page_map>
  8014cb:	89 c3                	mov    %eax,%ebx
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 4c                	js     80151d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8014d1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8014d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014da:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8014dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014df:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8014e6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8014ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014ef:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8014f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014f4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8014fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014fe:	89 04 24             	mov    %eax,(%esp)
  801501:	e8 86 ef ff ff       	call   80048c <fd2num>
  801506:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801508:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80150b:	89 04 24             	mov    %eax,(%esp)
  80150e:	e8 79 ef ff ff       	call   80048c <fd2num>
  801513:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801516:	bb 00 00 00 00       	mov    $0x0,%ebx
  80151b:	eb 36                	jmp    801553 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80151d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801521:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801528:	e8 13 ed ff ff       	call   800240 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80152d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801530:	89 44 24 04          	mov    %eax,0x4(%esp)
  801534:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80153b:	e8 00 ed ff ff       	call   800240 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801540:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801543:	89 44 24 04          	mov    %eax,0x4(%esp)
  801547:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80154e:	e8 ed ec ff ff       	call   800240 <sys_page_unmap>
    err:
	return r;
}
  801553:	89 d8                	mov    %ebx,%eax
  801555:	83 c4 3c             	add    $0x3c,%esp
  801558:	5b                   	pop    %ebx
  801559:	5e                   	pop    %esi
  80155a:	5f                   	pop    %edi
  80155b:	5d                   	pop    %ebp
  80155c:	c3                   	ret    

0080155d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801563:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801566:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156a:	8b 45 08             	mov    0x8(%ebp),%eax
  80156d:	89 04 24             	mov    %eax,(%esp)
  801570:	e8 95 ef ff ff       	call   80050a <fd_lookup>
  801575:	85 c0                	test   %eax,%eax
  801577:	78 15                	js     80158e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801579:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157c:	89 04 24             	mov    %eax,(%esp)
  80157f:	e8 18 ef ff ff       	call   80049c <fd2data>
	return _pipeisclosed(fd, p);
  801584:	89 c2                	mov    %eax,%edx
  801586:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801589:	e8 15 fd ff ff       	call   8012a3 <_pipeisclosed>
}
  80158e:	c9                   	leave  
  80158f:	c3                   	ret    

00801590 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801593:	b8 00 00 00 00       	mov    $0x0,%eax
  801598:	5d                   	pop    %ebp
  801599:	c3                   	ret    

0080159a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8015a0:	c7 44 24 04 73 26 80 	movl   $0x802673,0x4(%esp)
  8015a7:	00 
  8015a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ab:	89 04 24             	mov    %eax,(%esp)
  8015ae:	e8 20 08 00 00       	call   801dd3 <strcpy>
	return 0;
}
  8015b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b8:	c9                   	leave  
  8015b9:	c3                   	ret    

008015ba <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015ba:	55                   	push   %ebp
  8015bb:	89 e5                	mov    %esp,%ebp
  8015bd:	57                   	push   %edi
  8015be:	56                   	push   %esi
  8015bf:	53                   	push   %ebx
  8015c0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8015c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8015cb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8015d1:	eb 30                	jmp    801603 <devcons_write+0x49>
		m = n - tot;
  8015d3:	8b 75 10             	mov    0x10(%ebp),%esi
  8015d6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8015d8:	83 fe 7f             	cmp    $0x7f,%esi
  8015db:	76 05                	jbe    8015e2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8015dd:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8015e2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8015e6:	03 45 0c             	add    0xc(%ebp),%eax
  8015e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ed:	89 3c 24             	mov    %edi,(%esp)
  8015f0:	e8 57 09 00 00       	call   801f4c <memmove>
		sys_cputs(buf, m);
  8015f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015f9:	89 3c 24             	mov    %edi,(%esp)
  8015fc:	e8 cb ea ff ff       	call   8000cc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801601:	01 f3                	add    %esi,%ebx
  801603:	89 d8                	mov    %ebx,%eax
  801605:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801608:	72 c9                	jb     8015d3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80160a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801610:	5b                   	pop    %ebx
  801611:	5e                   	pop    %esi
  801612:	5f                   	pop    %edi
  801613:	5d                   	pop    %ebp
  801614:	c3                   	ret    

00801615 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80161b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80161f:	75 07                	jne    801628 <devcons_read+0x13>
  801621:	eb 25                	jmp    801648 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801623:	e8 52 eb ff ff       	call   80017a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801628:	e8 bd ea ff ff       	call   8000ea <sys_cgetc>
  80162d:	85 c0                	test   %eax,%eax
  80162f:	74 f2                	je     801623 <devcons_read+0xe>
  801631:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801633:	85 c0                	test   %eax,%eax
  801635:	78 1d                	js     801654 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801637:	83 f8 04             	cmp    $0x4,%eax
  80163a:	74 13                	je     80164f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80163c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80163f:	88 10                	mov    %dl,(%eax)
	return 1;
  801641:	b8 01 00 00 00       	mov    $0x1,%eax
  801646:	eb 0c                	jmp    801654 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801648:	b8 00 00 00 00       	mov    $0x0,%eax
  80164d:	eb 05                	jmp    801654 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80164f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80165c:	8b 45 08             	mov    0x8(%ebp),%eax
  80165f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801662:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801669:	00 
  80166a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80166d:	89 04 24             	mov    %eax,(%esp)
  801670:	e8 57 ea ff ff       	call   8000cc <sys_cputs>
}
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <getchar>:

int
getchar(void)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80167d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801684:	00 
  801685:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801688:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801693:	e8 10 f1 ff ff       	call   8007a8 <read>
	if (r < 0)
  801698:	85 c0                	test   %eax,%eax
  80169a:	78 0f                	js     8016ab <getchar+0x34>
		return r;
	if (r < 1)
  80169c:	85 c0                	test   %eax,%eax
  80169e:	7e 06                	jle    8016a6 <getchar+0x2f>
		return -E_EOF;
	return c;
  8016a0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8016a4:	eb 05                	jmp    8016ab <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8016a6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    

008016ad <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bd:	89 04 24             	mov    %eax,(%esp)
  8016c0:	e8 45 ee ff ff       	call   80050a <fd_lookup>
  8016c5:	85 c0                	test   %eax,%eax
  8016c7:	78 11                	js     8016da <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8016c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016cc:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8016d2:	39 10                	cmp    %edx,(%eax)
  8016d4:	0f 94 c0             	sete   %al
  8016d7:	0f b6 c0             	movzbl %al,%eax
}
  8016da:	c9                   	leave  
  8016db:	c3                   	ret    

008016dc <opencons>:

int
opencons(void)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8016e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e5:	89 04 24             	mov    %eax,(%esp)
  8016e8:	e8 ca ed ff ff       	call   8004b7 <fd_alloc>
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	78 3c                	js     80172d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8016f1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8016f8:	00 
  8016f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801700:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801707:	e8 8d ea ff ff       	call   800199 <sys_page_alloc>
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 1d                	js     80172d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801710:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801716:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801719:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80171b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801725:	89 04 24             	mov    %eax,(%esp)
  801728:	e8 5f ed ff ff       	call   80048c <fd2num>
}
  80172d:	c9                   	leave  
  80172e:	c3                   	ret    
	...

00801730 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	56                   	push   %esi
  801734:	53                   	push   %ebx
  801735:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801738:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80173b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801741:	e8 15 ea ff ff       	call   80015b <sys_getenvid>
  801746:	8b 55 0c             	mov    0xc(%ebp),%edx
  801749:	89 54 24 10          	mov    %edx,0x10(%esp)
  80174d:	8b 55 08             	mov    0x8(%ebp),%edx
  801750:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801754:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801758:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175c:	c7 04 24 80 26 80 00 	movl   $0x802680,(%esp)
  801763:	e8 c0 00 00 00       	call   801828 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801768:	89 74 24 04          	mov    %esi,0x4(%esp)
  80176c:	8b 45 10             	mov    0x10(%ebp),%eax
  80176f:	89 04 24             	mov    %eax,(%esp)
  801772:	e8 50 00 00 00       	call   8017c7 <vcprintf>
	cprintf("\n");
  801777:	c7 04 24 6c 26 80 00 	movl   $0x80266c,(%esp)
  80177e:	e8 a5 00 00 00       	call   801828 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801783:	cc                   	int3   
  801784:	eb fd                	jmp    801783 <_panic+0x53>
	...

00801788 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	53                   	push   %ebx
  80178c:	83 ec 14             	sub    $0x14,%esp
  80178f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801792:	8b 03                	mov    (%ebx),%eax
  801794:	8b 55 08             	mov    0x8(%ebp),%edx
  801797:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80179b:	40                   	inc    %eax
  80179c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80179e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8017a3:	75 19                	jne    8017be <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8017a5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8017ac:	00 
  8017ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8017b0:	89 04 24             	mov    %eax,(%esp)
  8017b3:	e8 14 e9 ff ff       	call   8000cc <sys_cputs>
		b->idx = 0;
  8017b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8017be:	ff 43 04             	incl   0x4(%ebx)
}
  8017c1:	83 c4 14             	add    $0x14,%esp
  8017c4:	5b                   	pop    %ebx
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    

008017c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8017d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017d7:	00 00 00 
	b.cnt = 0;
  8017da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8017e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8017e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8017f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fc:	c7 04 24 88 17 80 00 	movl   $0x801788,(%esp)
  801803:	e8 82 01 00 00       	call   80198a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801808:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80180e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801812:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801818:	89 04 24             	mov    %eax,(%esp)
  80181b:	e8 ac e8 ff ff       	call   8000cc <sys_cputs>

	return b.cnt;
}
  801820:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801826:	c9                   	leave  
  801827:	c3                   	ret    

00801828 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80182e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801831:	89 44 24 04          	mov    %eax,0x4(%esp)
  801835:	8b 45 08             	mov    0x8(%ebp),%eax
  801838:	89 04 24             	mov    %eax,(%esp)
  80183b:	e8 87 ff ff ff       	call   8017c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  801840:	c9                   	leave  
  801841:	c3                   	ret    
	...

00801844 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	57                   	push   %edi
  801848:	56                   	push   %esi
  801849:	53                   	push   %ebx
  80184a:	83 ec 3c             	sub    $0x3c,%esp
  80184d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801850:	89 d7                	mov    %edx,%edi
  801852:	8b 45 08             	mov    0x8(%ebp),%eax
  801855:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801858:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80185e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801861:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801864:	85 c0                	test   %eax,%eax
  801866:	75 08                	jne    801870 <printnum+0x2c>
  801868:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80186b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80186e:	77 57                	ja     8018c7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801870:	89 74 24 10          	mov    %esi,0x10(%esp)
  801874:	4b                   	dec    %ebx
  801875:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801879:	8b 45 10             	mov    0x10(%ebp),%eax
  80187c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801880:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801884:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801888:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80188f:	00 
  801890:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801893:	89 04 24             	mov    %eax,(%esp)
  801896:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801899:	89 44 24 04          	mov    %eax,0x4(%esp)
  80189d:	e8 1e 0a 00 00       	call   8022c0 <__udivdi3>
  8018a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018a6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018aa:	89 04 24             	mov    %eax,(%esp)
  8018ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018b1:	89 fa                	mov    %edi,%edx
  8018b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018b6:	e8 89 ff ff ff       	call   801844 <printnum>
  8018bb:	eb 0f                	jmp    8018cc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8018bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018c1:	89 34 24             	mov    %esi,(%esp)
  8018c4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8018c7:	4b                   	dec    %ebx
  8018c8:	85 db                	test   %ebx,%ebx
  8018ca:	7f f1                	jg     8018bd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8018cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8018e2:	00 
  8018e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8018e6:	89 04 24             	mov    %eax,(%esp)
  8018e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f0:	e8 eb 0a 00 00       	call   8023e0 <__umoddi3>
  8018f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018f9:	0f be 80 a3 26 80 00 	movsbl 0x8026a3(%eax),%eax
  801900:	89 04 24             	mov    %eax,(%esp)
  801903:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801906:	83 c4 3c             	add    $0x3c,%esp
  801909:	5b                   	pop    %ebx
  80190a:	5e                   	pop    %esi
  80190b:	5f                   	pop    %edi
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801911:	83 fa 01             	cmp    $0x1,%edx
  801914:	7e 0e                	jle    801924 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801916:	8b 10                	mov    (%eax),%edx
  801918:	8d 4a 08             	lea    0x8(%edx),%ecx
  80191b:	89 08                	mov    %ecx,(%eax)
  80191d:	8b 02                	mov    (%edx),%eax
  80191f:	8b 52 04             	mov    0x4(%edx),%edx
  801922:	eb 22                	jmp    801946 <getuint+0x38>
	else if (lflag)
  801924:	85 d2                	test   %edx,%edx
  801926:	74 10                	je     801938 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801928:	8b 10                	mov    (%eax),%edx
  80192a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80192d:	89 08                	mov    %ecx,(%eax)
  80192f:	8b 02                	mov    (%edx),%eax
  801931:	ba 00 00 00 00       	mov    $0x0,%edx
  801936:	eb 0e                	jmp    801946 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801938:	8b 10                	mov    (%eax),%edx
  80193a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80193d:	89 08                	mov    %ecx,(%eax)
  80193f:	8b 02                	mov    (%edx),%eax
  801941:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80194e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801951:	8b 10                	mov    (%eax),%edx
  801953:	3b 50 04             	cmp    0x4(%eax),%edx
  801956:	73 08                	jae    801960 <sprintputch+0x18>
		*b->buf++ = ch;
  801958:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80195b:	88 0a                	mov    %cl,(%edx)
  80195d:	42                   	inc    %edx
  80195e:	89 10                	mov    %edx,(%eax)
}
  801960:	5d                   	pop    %ebp
  801961:	c3                   	ret    

00801962 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801968:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80196b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80196f:	8b 45 10             	mov    0x10(%ebp),%eax
  801972:	89 44 24 08          	mov    %eax,0x8(%esp)
  801976:	8b 45 0c             	mov    0xc(%ebp),%eax
  801979:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197d:	8b 45 08             	mov    0x8(%ebp),%eax
  801980:	89 04 24             	mov    %eax,(%esp)
  801983:	e8 02 00 00 00       	call   80198a <vprintfmt>
	va_end(ap);
}
  801988:	c9                   	leave  
  801989:	c3                   	ret    

0080198a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80198a:	55                   	push   %ebp
  80198b:	89 e5                	mov    %esp,%ebp
  80198d:	57                   	push   %edi
  80198e:	56                   	push   %esi
  80198f:	53                   	push   %ebx
  801990:	83 ec 4c             	sub    $0x4c,%esp
  801993:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801996:	8b 75 10             	mov    0x10(%ebp),%esi
  801999:	eb 12                	jmp    8019ad <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80199b:	85 c0                	test   %eax,%eax
  80199d:	0f 84 6b 03 00 00    	je     801d0e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8019a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019a7:	89 04 24             	mov    %eax,(%esp)
  8019aa:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8019ad:	0f b6 06             	movzbl (%esi),%eax
  8019b0:	46                   	inc    %esi
  8019b1:	83 f8 25             	cmp    $0x25,%eax
  8019b4:	75 e5                	jne    80199b <vprintfmt+0x11>
  8019b6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8019ba:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8019c1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8019c6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8019cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019d2:	eb 26                	jmp    8019fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019d4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8019d7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8019db:	eb 1d                	jmp    8019fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8019e0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8019e4:	eb 14                	jmp    8019fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8019e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8019f0:	eb 08                	jmp    8019fa <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8019f2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8019f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019fa:	0f b6 06             	movzbl (%esi),%eax
  8019fd:	8d 56 01             	lea    0x1(%esi),%edx
  801a00:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801a03:	8a 16                	mov    (%esi),%dl
  801a05:	83 ea 23             	sub    $0x23,%edx
  801a08:	80 fa 55             	cmp    $0x55,%dl
  801a0b:	0f 87 e1 02 00 00    	ja     801cf2 <vprintfmt+0x368>
  801a11:	0f b6 d2             	movzbl %dl,%edx
  801a14:	ff 24 95 e0 27 80 00 	jmp    *0x8027e0(,%edx,4)
  801a1b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801a1e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801a23:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801a26:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  801a2a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801a2d:	8d 50 d0             	lea    -0x30(%eax),%edx
  801a30:	83 fa 09             	cmp    $0x9,%edx
  801a33:	77 2a                	ja     801a5f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801a35:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801a36:	eb eb                	jmp    801a23 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801a38:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3b:	8d 50 04             	lea    0x4(%eax),%edx
  801a3e:	89 55 14             	mov    %edx,0x14(%ebp)
  801a41:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a43:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801a46:	eb 17                	jmp    801a5f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801a48:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801a4c:	78 98                	js     8019e6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a4e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801a51:	eb a7                	jmp    8019fa <vprintfmt+0x70>
  801a53:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801a56:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801a5d:	eb 9b                	jmp    8019fa <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801a5f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801a63:	79 95                	jns    8019fa <vprintfmt+0x70>
  801a65:	eb 8b                	jmp    8019f2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801a67:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a68:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801a6b:	eb 8d                	jmp    8019fa <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801a6d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a70:	8d 50 04             	lea    0x4(%eax),%edx
  801a73:	89 55 14             	mov    %edx,0x14(%ebp)
  801a76:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a7a:	8b 00                	mov    (%eax),%eax
  801a7c:	89 04 24             	mov    %eax,(%esp)
  801a7f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a82:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801a85:	e9 23 ff ff ff       	jmp    8019ad <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801a8a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8d:	8d 50 04             	lea    0x4(%eax),%edx
  801a90:	89 55 14             	mov    %edx,0x14(%ebp)
  801a93:	8b 00                	mov    (%eax),%eax
  801a95:	85 c0                	test   %eax,%eax
  801a97:	79 02                	jns    801a9b <vprintfmt+0x111>
  801a99:	f7 d8                	neg    %eax
  801a9b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801a9d:	83 f8 10             	cmp    $0x10,%eax
  801aa0:	7f 0b                	jg     801aad <vprintfmt+0x123>
  801aa2:	8b 04 85 40 29 80 00 	mov    0x802940(,%eax,4),%eax
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	75 23                	jne    801ad0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801aad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801ab1:	c7 44 24 08 bb 26 80 	movl   $0x8026bb,0x8(%esp)
  801ab8:	00 
  801ab9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801abd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac0:	89 04 24             	mov    %eax,(%esp)
  801ac3:	e8 9a fe ff ff       	call   801962 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ac8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801acb:	e9 dd fe ff ff       	jmp    8019ad <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801ad0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ad4:	c7 44 24 08 01 26 80 	movl   $0x802601,0x8(%esp)
  801adb:	00 
  801adc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ae0:	8b 55 08             	mov    0x8(%ebp),%edx
  801ae3:	89 14 24             	mov    %edx,(%esp)
  801ae6:	e8 77 fe ff ff       	call   801962 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aeb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801aee:	e9 ba fe ff ff       	jmp    8019ad <vprintfmt+0x23>
  801af3:	89 f9                	mov    %edi,%ecx
  801af5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801af8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801afb:	8b 45 14             	mov    0x14(%ebp),%eax
  801afe:	8d 50 04             	lea    0x4(%eax),%edx
  801b01:	89 55 14             	mov    %edx,0x14(%ebp)
  801b04:	8b 30                	mov    (%eax),%esi
  801b06:	85 f6                	test   %esi,%esi
  801b08:	75 05                	jne    801b0f <vprintfmt+0x185>
				p = "(null)";
  801b0a:	be b4 26 80 00       	mov    $0x8026b4,%esi
			if (width > 0 && padc != '-')
  801b0f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801b13:	0f 8e 84 00 00 00    	jle    801b9d <vprintfmt+0x213>
  801b19:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801b1d:	74 7e                	je     801b9d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  801b1f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b23:	89 34 24             	mov    %esi,(%esp)
  801b26:	e8 8b 02 00 00       	call   801db6 <strnlen>
  801b2b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801b2e:	29 c2                	sub    %eax,%edx
  801b30:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801b33:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801b37:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801b3a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801b3d:	89 de                	mov    %ebx,%esi
  801b3f:	89 d3                	mov    %edx,%ebx
  801b41:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b43:	eb 0b                	jmp    801b50 <vprintfmt+0x1c6>
					putch(padc, putdat);
  801b45:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b49:	89 3c 24             	mov    %edi,(%esp)
  801b4c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b4f:	4b                   	dec    %ebx
  801b50:	85 db                	test   %ebx,%ebx
  801b52:	7f f1                	jg     801b45 <vprintfmt+0x1bb>
  801b54:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801b57:	89 f3                	mov    %esi,%ebx
  801b59:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801b5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b5f:	85 c0                	test   %eax,%eax
  801b61:	79 05                	jns    801b68 <vprintfmt+0x1de>
  801b63:	b8 00 00 00 00       	mov    $0x0,%eax
  801b68:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b6b:	29 c2                	sub    %eax,%edx
  801b6d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801b70:	eb 2b                	jmp    801b9d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801b72:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b76:	74 18                	je     801b90 <vprintfmt+0x206>
  801b78:	8d 50 e0             	lea    -0x20(%eax),%edx
  801b7b:	83 fa 5e             	cmp    $0x5e,%edx
  801b7e:	76 10                	jbe    801b90 <vprintfmt+0x206>
					putch('?', putdat);
  801b80:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b84:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801b8b:	ff 55 08             	call   *0x8(%ebp)
  801b8e:	eb 0a                	jmp    801b9a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801b90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b94:	89 04 24             	mov    %eax,(%esp)
  801b97:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801b9a:	ff 4d e4             	decl   -0x1c(%ebp)
  801b9d:	0f be 06             	movsbl (%esi),%eax
  801ba0:	46                   	inc    %esi
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	74 21                	je     801bc6 <vprintfmt+0x23c>
  801ba5:	85 ff                	test   %edi,%edi
  801ba7:	78 c9                	js     801b72 <vprintfmt+0x1e8>
  801ba9:	4f                   	dec    %edi
  801baa:	79 c6                	jns    801b72 <vprintfmt+0x1e8>
  801bac:	8b 7d 08             	mov    0x8(%ebp),%edi
  801baf:	89 de                	mov    %ebx,%esi
  801bb1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801bb4:	eb 18                	jmp    801bce <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801bb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bba:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801bc1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801bc3:	4b                   	dec    %ebx
  801bc4:	eb 08                	jmp    801bce <vprintfmt+0x244>
  801bc6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bc9:	89 de                	mov    %ebx,%esi
  801bcb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801bce:	85 db                	test   %ebx,%ebx
  801bd0:	7f e4                	jg     801bb6 <vprintfmt+0x22c>
  801bd2:	89 7d 08             	mov    %edi,0x8(%ebp)
  801bd5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bd7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801bda:	e9 ce fd ff ff       	jmp    8019ad <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801bdf:	83 f9 01             	cmp    $0x1,%ecx
  801be2:	7e 10                	jle    801bf4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801be4:	8b 45 14             	mov    0x14(%ebp),%eax
  801be7:	8d 50 08             	lea    0x8(%eax),%edx
  801bea:	89 55 14             	mov    %edx,0x14(%ebp)
  801bed:	8b 30                	mov    (%eax),%esi
  801bef:	8b 78 04             	mov    0x4(%eax),%edi
  801bf2:	eb 26                	jmp    801c1a <vprintfmt+0x290>
	else if (lflag)
  801bf4:	85 c9                	test   %ecx,%ecx
  801bf6:	74 12                	je     801c0a <vprintfmt+0x280>
		return va_arg(*ap, long);
  801bf8:	8b 45 14             	mov    0x14(%ebp),%eax
  801bfb:	8d 50 04             	lea    0x4(%eax),%edx
  801bfe:	89 55 14             	mov    %edx,0x14(%ebp)
  801c01:	8b 30                	mov    (%eax),%esi
  801c03:	89 f7                	mov    %esi,%edi
  801c05:	c1 ff 1f             	sar    $0x1f,%edi
  801c08:	eb 10                	jmp    801c1a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801c0a:	8b 45 14             	mov    0x14(%ebp),%eax
  801c0d:	8d 50 04             	lea    0x4(%eax),%edx
  801c10:	89 55 14             	mov    %edx,0x14(%ebp)
  801c13:	8b 30                	mov    (%eax),%esi
  801c15:	89 f7                	mov    %esi,%edi
  801c17:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801c1a:	85 ff                	test   %edi,%edi
  801c1c:	78 0a                	js     801c28 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801c1e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801c23:	e9 8c 00 00 00       	jmp    801cb4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801c28:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c2c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801c33:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801c36:	f7 de                	neg    %esi
  801c38:	83 d7 00             	adc    $0x0,%edi
  801c3b:	f7 df                	neg    %edi
			}
			base = 10;
  801c3d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801c42:	eb 70                	jmp    801cb4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801c44:	89 ca                	mov    %ecx,%edx
  801c46:	8d 45 14             	lea    0x14(%ebp),%eax
  801c49:	e8 c0 fc ff ff       	call   80190e <getuint>
  801c4e:	89 c6                	mov    %eax,%esi
  801c50:	89 d7                	mov    %edx,%edi
			base = 10;
  801c52:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801c57:	eb 5b                	jmp    801cb4 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  801c59:	89 ca                	mov    %ecx,%edx
  801c5b:	8d 45 14             	lea    0x14(%ebp),%eax
  801c5e:	e8 ab fc ff ff       	call   80190e <getuint>
  801c63:	89 c6                	mov    %eax,%esi
  801c65:	89 d7                	mov    %edx,%edi
			base = 8;
  801c67:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801c6c:	eb 46                	jmp    801cb4 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  801c6e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c72:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801c79:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801c7c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c80:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801c87:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801c8a:	8b 45 14             	mov    0x14(%ebp),%eax
  801c8d:	8d 50 04             	lea    0x4(%eax),%edx
  801c90:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801c93:	8b 30                	mov    (%eax),%esi
  801c95:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801c9a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801c9f:	eb 13                	jmp    801cb4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801ca1:	89 ca                	mov    %ecx,%edx
  801ca3:	8d 45 14             	lea    0x14(%ebp),%eax
  801ca6:	e8 63 fc ff ff       	call   80190e <getuint>
  801cab:	89 c6                	mov    %eax,%esi
  801cad:	89 d7                	mov    %edx,%edi
			base = 16;
  801caf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801cb4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801cb8:	89 54 24 10          	mov    %edx,0x10(%esp)
  801cbc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801cbf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cc3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cc7:	89 34 24             	mov    %esi,(%esp)
  801cca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801cce:	89 da                	mov    %ebx,%edx
  801cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd3:	e8 6c fb ff ff       	call   801844 <printnum>
			break;
  801cd8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801cdb:	e9 cd fc ff ff       	jmp    8019ad <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801ce0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ce4:	89 04 24             	mov    %eax,(%esp)
  801ce7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ced:	e9 bb fc ff ff       	jmp    8019ad <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801cf2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cf6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801cfd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801d00:	eb 01                	jmp    801d03 <vprintfmt+0x379>
  801d02:	4e                   	dec    %esi
  801d03:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801d07:	75 f9                	jne    801d02 <vprintfmt+0x378>
  801d09:	e9 9f fc ff ff       	jmp    8019ad <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801d0e:	83 c4 4c             	add    $0x4c,%esp
  801d11:	5b                   	pop    %ebx
  801d12:	5e                   	pop    %esi
  801d13:	5f                   	pop    %edi
  801d14:	5d                   	pop    %ebp
  801d15:	c3                   	ret    

00801d16 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
  801d19:	83 ec 28             	sub    $0x28,%esp
  801d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801d22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d25:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801d29:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801d2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801d33:	85 c0                	test   %eax,%eax
  801d35:	74 30                	je     801d67 <vsnprintf+0x51>
  801d37:	85 d2                	test   %edx,%edx
  801d39:	7e 33                	jle    801d6e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801d3b:	8b 45 14             	mov    0x14(%ebp),%eax
  801d3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d42:	8b 45 10             	mov    0x10(%ebp),%eax
  801d45:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d49:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d50:	c7 04 24 48 19 80 00 	movl   $0x801948,(%esp)
  801d57:	e8 2e fc ff ff       	call   80198a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801d5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d5f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d65:	eb 0c                	jmp    801d73 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801d67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d6c:	eb 05                	jmp    801d73 <vsnprintf+0x5d>
  801d6e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801d73:	c9                   	leave  
  801d74:	c3                   	ret    

00801d75 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801d7b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801d7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d82:	8b 45 10             	mov    0x10(%ebp),%eax
  801d85:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d89:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d90:	8b 45 08             	mov    0x8(%ebp),%eax
  801d93:	89 04 24             	mov    %eax,(%esp)
  801d96:	e8 7b ff ff ff       	call   801d16 <vsnprintf>
	va_end(ap);

	return rc;
}
  801d9b:	c9                   	leave  
  801d9c:	c3                   	ret    
  801d9d:	00 00                	add    %al,(%eax)
	...

00801da0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801da6:	b8 00 00 00 00       	mov    $0x0,%eax
  801dab:	eb 01                	jmp    801dae <strlen+0xe>
		n++;
  801dad:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801dae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801db2:	75 f9                	jne    801dad <strlen+0xd>
		n++;
	return n;
}
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    

00801db6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801dbc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801dbf:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc4:	eb 01                	jmp    801dc7 <strnlen+0x11>
		n++;
  801dc6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801dc7:	39 d0                	cmp    %edx,%eax
  801dc9:	74 06                	je     801dd1 <strnlen+0x1b>
  801dcb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801dcf:	75 f5                	jne    801dc6 <strnlen+0x10>
		n++;
	return n;
}
  801dd1:	5d                   	pop    %ebp
  801dd2:	c3                   	ret    

00801dd3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	53                   	push   %ebx
  801dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801ddd:	ba 00 00 00 00       	mov    $0x0,%edx
  801de2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801de5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801de8:	42                   	inc    %edx
  801de9:	84 c9                	test   %cl,%cl
  801deb:	75 f5                	jne    801de2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801ded:	5b                   	pop    %ebx
  801dee:	5d                   	pop    %ebp
  801def:	c3                   	ret    

00801df0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	53                   	push   %ebx
  801df4:	83 ec 08             	sub    $0x8,%esp
  801df7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801dfa:	89 1c 24             	mov    %ebx,(%esp)
  801dfd:	e8 9e ff ff ff       	call   801da0 <strlen>
	strcpy(dst + len, src);
  801e02:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e05:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e09:	01 d8                	add    %ebx,%eax
  801e0b:	89 04 24             	mov    %eax,(%esp)
  801e0e:	e8 c0 ff ff ff       	call   801dd3 <strcpy>
	return dst;
}
  801e13:	89 d8                	mov    %ebx,%eax
  801e15:	83 c4 08             	add    $0x8,%esp
  801e18:	5b                   	pop    %ebx
  801e19:	5d                   	pop    %ebp
  801e1a:	c3                   	ret    

00801e1b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	56                   	push   %esi
  801e1f:	53                   	push   %ebx
  801e20:	8b 45 08             	mov    0x8(%ebp),%eax
  801e23:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e26:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801e29:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e2e:	eb 0c                	jmp    801e3c <strncpy+0x21>
		*dst++ = *src;
  801e30:	8a 1a                	mov    (%edx),%bl
  801e32:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801e35:	80 3a 01             	cmpb   $0x1,(%edx)
  801e38:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801e3b:	41                   	inc    %ecx
  801e3c:	39 f1                	cmp    %esi,%ecx
  801e3e:	75 f0                	jne    801e30 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801e40:	5b                   	pop    %ebx
  801e41:	5e                   	pop    %esi
  801e42:	5d                   	pop    %ebp
  801e43:	c3                   	ret    

00801e44 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	56                   	push   %esi
  801e48:	53                   	push   %ebx
  801e49:	8b 75 08             	mov    0x8(%ebp),%esi
  801e4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e4f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e52:	85 d2                	test   %edx,%edx
  801e54:	75 0a                	jne    801e60 <strlcpy+0x1c>
  801e56:	89 f0                	mov    %esi,%eax
  801e58:	eb 1a                	jmp    801e74 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801e5a:	88 18                	mov    %bl,(%eax)
  801e5c:	40                   	inc    %eax
  801e5d:	41                   	inc    %ecx
  801e5e:	eb 02                	jmp    801e62 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e60:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801e62:	4a                   	dec    %edx
  801e63:	74 0a                	je     801e6f <strlcpy+0x2b>
  801e65:	8a 19                	mov    (%ecx),%bl
  801e67:	84 db                	test   %bl,%bl
  801e69:	75 ef                	jne    801e5a <strlcpy+0x16>
  801e6b:	89 c2                	mov    %eax,%edx
  801e6d:	eb 02                	jmp    801e71 <strlcpy+0x2d>
  801e6f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801e71:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801e74:	29 f0                	sub    %esi,%eax
}
  801e76:	5b                   	pop    %ebx
  801e77:	5e                   	pop    %esi
  801e78:	5d                   	pop    %ebp
  801e79:	c3                   	ret    

00801e7a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801e7a:	55                   	push   %ebp
  801e7b:	89 e5                	mov    %esp,%ebp
  801e7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e80:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801e83:	eb 02                	jmp    801e87 <strcmp+0xd>
		p++, q++;
  801e85:	41                   	inc    %ecx
  801e86:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801e87:	8a 01                	mov    (%ecx),%al
  801e89:	84 c0                	test   %al,%al
  801e8b:	74 04                	je     801e91 <strcmp+0x17>
  801e8d:	3a 02                	cmp    (%edx),%al
  801e8f:	74 f4                	je     801e85 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801e91:	0f b6 c0             	movzbl %al,%eax
  801e94:	0f b6 12             	movzbl (%edx),%edx
  801e97:	29 d0                	sub    %edx,%eax
}
  801e99:	5d                   	pop    %ebp
  801e9a:	c3                   	ret    

00801e9b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	53                   	push   %ebx
  801e9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ea5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801ea8:	eb 03                	jmp    801ead <strncmp+0x12>
		n--, p++, q++;
  801eaa:	4a                   	dec    %edx
  801eab:	40                   	inc    %eax
  801eac:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801ead:	85 d2                	test   %edx,%edx
  801eaf:	74 14                	je     801ec5 <strncmp+0x2a>
  801eb1:	8a 18                	mov    (%eax),%bl
  801eb3:	84 db                	test   %bl,%bl
  801eb5:	74 04                	je     801ebb <strncmp+0x20>
  801eb7:	3a 19                	cmp    (%ecx),%bl
  801eb9:	74 ef                	je     801eaa <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801ebb:	0f b6 00             	movzbl (%eax),%eax
  801ebe:	0f b6 11             	movzbl (%ecx),%edx
  801ec1:	29 d0                	sub    %edx,%eax
  801ec3:	eb 05                	jmp    801eca <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801ec5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801eca:	5b                   	pop    %ebx
  801ecb:	5d                   	pop    %ebp
  801ecc:	c3                   	ret    

00801ecd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801ecd:	55                   	push   %ebp
  801ece:	89 e5                	mov    %esp,%ebp
  801ed0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801ed6:	eb 05                	jmp    801edd <strchr+0x10>
		if (*s == c)
  801ed8:	38 ca                	cmp    %cl,%dl
  801eda:	74 0c                	je     801ee8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801edc:	40                   	inc    %eax
  801edd:	8a 10                	mov    (%eax),%dl
  801edf:	84 d2                	test   %dl,%dl
  801ee1:	75 f5                	jne    801ed8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801ee3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ee8:	5d                   	pop    %ebp
  801ee9:	c3                   	ret    

00801eea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801ef3:	eb 05                	jmp    801efa <strfind+0x10>
		if (*s == c)
  801ef5:	38 ca                	cmp    %cl,%dl
  801ef7:	74 07                	je     801f00 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801ef9:	40                   	inc    %eax
  801efa:	8a 10                	mov    (%eax),%dl
  801efc:	84 d2                	test   %dl,%dl
  801efe:	75 f5                	jne    801ef5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801f00:	5d                   	pop    %ebp
  801f01:	c3                   	ret    

00801f02 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801f02:	55                   	push   %ebp
  801f03:	89 e5                	mov    %esp,%ebp
  801f05:	57                   	push   %edi
  801f06:	56                   	push   %esi
  801f07:	53                   	push   %ebx
  801f08:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801f11:	85 c9                	test   %ecx,%ecx
  801f13:	74 30                	je     801f45 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801f15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801f1b:	75 25                	jne    801f42 <memset+0x40>
  801f1d:	f6 c1 03             	test   $0x3,%cl
  801f20:	75 20                	jne    801f42 <memset+0x40>
		c &= 0xFF;
  801f22:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801f25:	89 d3                	mov    %edx,%ebx
  801f27:	c1 e3 08             	shl    $0x8,%ebx
  801f2a:	89 d6                	mov    %edx,%esi
  801f2c:	c1 e6 18             	shl    $0x18,%esi
  801f2f:	89 d0                	mov    %edx,%eax
  801f31:	c1 e0 10             	shl    $0x10,%eax
  801f34:	09 f0                	or     %esi,%eax
  801f36:	09 d0                	or     %edx,%eax
  801f38:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801f3a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801f3d:	fc                   	cld    
  801f3e:	f3 ab                	rep stos %eax,%es:(%edi)
  801f40:	eb 03                	jmp    801f45 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801f42:	fc                   	cld    
  801f43:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801f45:	89 f8                	mov    %edi,%eax
  801f47:	5b                   	pop    %ebx
  801f48:	5e                   	pop    %esi
  801f49:	5f                   	pop    %edi
  801f4a:	5d                   	pop    %ebp
  801f4b:	c3                   	ret    

00801f4c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801f4c:	55                   	push   %ebp
  801f4d:	89 e5                	mov    %esp,%ebp
  801f4f:	57                   	push   %edi
  801f50:	56                   	push   %esi
  801f51:	8b 45 08             	mov    0x8(%ebp),%eax
  801f54:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f57:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801f5a:	39 c6                	cmp    %eax,%esi
  801f5c:	73 34                	jae    801f92 <memmove+0x46>
  801f5e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801f61:	39 d0                	cmp    %edx,%eax
  801f63:	73 2d                	jae    801f92 <memmove+0x46>
		s += n;
		d += n;
  801f65:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f68:	f6 c2 03             	test   $0x3,%dl
  801f6b:	75 1b                	jne    801f88 <memmove+0x3c>
  801f6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801f73:	75 13                	jne    801f88 <memmove+0x3c>
  801f75:	f6 c1 03             	test   $0x3,%cl
  801f78:	75 0e                	jne    801f88 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801f7a:	83 ef 04             	sub    $0x4,%edi
  801f7d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801f80:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801f83:	fd                   	std    
  801f84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f86:	eb 07                	jmp    801f8f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801f88:	4f                   	dec    %edi
  801f89:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801f8c:	fd                   	std    
  801f8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801f8f:	fc                   	cld    
  801f90:	eb 20                	jmp    801fb2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f92:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801f98:	75 13                	jne    801fad <memmove+0x61>
  801f9a:	a8 03                	test   $0x3,%al
  801f9c:	75 0f                	jne    801fad <memmove+0x61>
  801f9e:	f6 c1 03             	test   $0x3,%cl
  801fa1:	75 0a                	jne    801fad <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801fa3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801fa6:	89 c7                	mov    %eax,%edi
  801fa8:	fc                   	cld    
  801fa9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801fab:	eb 05                	jmp    801fb2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801fad:	89 c7                	mov    %eax,%edi
  801faf:	fc                   	cld    
  801fb0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801fb2:	5e                   	pop    %esi
  801fb3:	5f                   	pop    %edi
  801fb4:	5d                   	pop    %ebp
  801fb5:	c3                   	ret    

00801fb6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801fb6:	55                   	push   %ebp
  801fb7:	89 e5                	mov    %esp,%ebp
  801fb9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801fbc:	8b 45 10             	mov    0x10(%ebp),%eax
  801fbf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fca:	8b 45 08             	mov    0x8(%ebp),%eax
  801fcd:	89 04 24             	mov    %eax,(%esp)
  801fd0:	e8 77 ff ff ff       	call   801f4c <memmove>
}
  801fd5:	c9                   	leave  
  801fd6:	c3                   	ret    

00801fd7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801fd7:	55                   	push   %ebp
  801fd8:	89 e5                	mov    %esp,%ebp
  801fda:	57                   	push   %edi
  801fdb:	56                   	push   %esi
  801fdc:	53                   	push   %ebx
  801fdd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fe0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fe3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801fe6:	ba 00 00 00 00       	mov    $0x0,%edx
  801feb:	eb 16                	jmp    802003 <memcmp+0x2c>
		if (*s1 != *s2)
  801fed:	8a 04 17             	mov    (%edi,%edx,1),%al
  801ff0:	42                   	inc    %edx
  801ff1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801ff5:	38 c8                	cmp    %cl,%al
  801ff7:	74 0a                	je     802003 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801ff9:	0f b6 c0             	movzbl %al,%eax
  801ffc:	0f b6 c9             	movzbl %cl,%ecx
  801fff:	29 c8                	sub    %ecx,%eax
  802001:	eb 09                	jmp    80200c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802003:	39 da                	cmp    %ebx,%edx
  802005:	75 e6                	jne    801fed <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802007:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80200c:	5b                   	pop    %ebx
  80200d:	5e                   	pop    %esi
  80200e:	5f                   	pop    %edi
  80200f:	5d                   	pop    %ebp
  802010:	c3                   	ret    

00802011 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802011:	55                   	push   %ebp
  802012:	89 e5                	mov    %esp,%ebp
  802014:	8b 45 08             	mov    0x8(%ebp),%eax
  802017:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80201a:	89 c2                	mov    %eax,%edx
  80201c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80201f:	eb 05                	jmp    802026 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  802021:	38 08                	cmp    %cl,(%eax)
  802023:	74 05                	je     80202a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802025:	40                   	inc    %eax
  802026:	39 d0                	cmp    %edx,%eax
  802028:	72 f7                	jb     802021 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80202a:	5d                   	pop    %ebp
  80202b:	c3                   	ret    

0080202c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	57                   	push   %edi
  802030:	56                   	push   %esi
  802031:	53                   	push   %ebx
  802032:	8b 55 08             	mov    0x8(%ebp),%edx
  802035:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802038:	eb 01                	jmp    80203b <strtol+0xf>
		s++;
  80203a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80203b:	8a 02                	mov    (%edx),%al
  80203d:	3c 20                	cmp    $0x20,%al
  80203f:	74 f9                	je     80203a <strtol+0xe>
  802041:	3c 09                	cmp    $0x9,%al
  802043:	74 f5                	je     80203a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802045:	3c 2b                	cmp    $0x2b,%al
  802047:	75 08                	jne    802051 <strtol+0x25>
		s++;
  802049:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80204a:	bf 00 00 00 00       	mov    $0x0,%edi
  80204f:	eb 13                	jmp    802064 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802051:	3c 2d                	cmp    $0x2d,%al
  802053:	75 0a                	jne    80205f <strtol+0x33>
		s++, neg = 1;
  802055:	8d 52 01             	lea    0x1(%edx),%edx
  802058:	bf 01 00 00 00       	mov    $0x1,%edi
  80205d:	eb 05                	jmp    802064 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80205f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802064:	85 db                	test   %ebx,%ebx
  802066:	74 05                	je     80206d <strtol+0x41>
  802068:	83 fb 10             	cmp    $0x10,%ebx
  80206b:	75 28                	jne    802095 <strtol+0x69>
  80206d:	8a 02                	mov    (%edx),%al
  80206f:	3c 30                	cmp    $0x30,%al
  802071:	75 10                	jne    802083 <strtol+0x57>
  802073:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802077:	75 0a                	jne    802083 <strtol+0x57>
		s += 2, base = 16;
  802079:	83 c2 02             	add    $0x2,%edx
  80207c:	bb 10 00 00 00       	mov    $0x10,%ebx
  802081:	eb 12                	jmp    802095 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  802083:	85 db                	test   %ebx,%ebx
  802085:	75 0e                	jne    802095 <strtol+0x69>
  802087:	3c 30                	cmp    $0x30,%al
  802089:	75 05                	jne    802090 <strtol+0x64>
		s++, base = 8;
  80208b:	42                   	inc    %edx
  80208c:	b3 08                	mov    $0x8,%bl
  80208e:	eb 05                	jmp    802095 <strtol+0x69>
	else if (base == 0)
		base = 10;
  802090:	bb 0a 00 00 00       	mov    $0xa,%ebx
  802095:	b8 00 00 00 00       	mov    $0x0,%eax
  80209a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80209c:	8a 0a                	mov    (%edx),%cl
  80209e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8020a1:	80 fb 09             	cmp    $0x9,%bl
  8020a4:	77 08                	ja     8020ae <strtol+0x82>
			dig = *s - '0';
  8020a6:	0f be c9             	movsbl %cl,%ecx
  8020a9:	83 e9 30             	sub    $0x30,%ecx
  8020ac:	eb 1e                	jmp    8020cc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8020ae:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8020b1:	80 fb 19             	cmp    $0x19,%bl
  8020b4:	77 08                	ja     8020be <strtol+0x92>
			dig = *s - 'a' + 10;
  8020b6:	0f be c9             	movsbl %cl,%ecx
  8020b9:	83 e9 57             	sub    $0x57,%ecx
  8020bc:	eb 0e                	jmp    8020cc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8020be:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8020c1:	80 fb 19             	cmp    $0x19,%bl
  8020c4:	77 12                	ja     8020d8 <strtol+0xac>
			dig = *s - 'A' + 10;
  8020c6:	0f be c9             	movsbl %cl,%ecx
  8020c9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8020cc:	39 f1                	cmp    %esi,%ecx
  8020ce:	7d 0c                	jge    8020dc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8020d0:	42                   	inc    %edx
  8020d1:	0f af c6             	imul   %esi,%eax
  8020d4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8020d6:	eb c4                	jmp    80209c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8020d8:	89 c1                	mov    %eax,%ecx
  8020da:	eb 02                	jmp    8020de <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8020dc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8020de:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8020e2:	74 05                	je     8020e9 <strtol+0xbd>
		*endptr = (char *) s;
  8020e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8020e7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8020e9:	85 ff                	test   %edi,%edi
  8020eb:	74 04                	je     8020f1 <strtol+0xc5>
  8020ed:	89 c8                	mov    %ecx,%eax
  8020ef:	f7 d8                	neg    %eax
}
  8020f1:	5b                   	pop    %ebx
  8020f2:	5e                   	pop    %esi
  8020f3:	5f                   	pop    %edi
  8020f4:	5d                   	pop    %ebp
  8020f5:	c3                   	ret    
	...

008020f8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8020fe:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802105:	75 30                	jne    802137 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  802107:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80210e:	00 
  80210f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802116:	ee 
  802117:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80211e:	e8 76 e0 ff ff       	call   800199 <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  802123:	c7 44 24 04 64 04 80 	movl   $0x800464,0x4(%esp)
  80212a:	00 
  80212b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802132:	e8 02 e2 ff ff       	call   800339 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802137:	8b 45 08             	mov    0x8(%ebp),%eax
  80213a:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80213f:	c9                   	leave  
  802140:	c3                   	ret    
  802141:	00 00                	add    %al,(%eax)
	...

00802144 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802144:	55                   	push   %ebp
  802145:	89 e5                	mov    %esp,%ebp
  802147:	56                   	push   %esi
  802148:	53                   	push   %ebx
  802149:	83 ec 10             	sub    $0x10,%esp
  80214c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80214f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802152:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  802155:	85 c0                	test   %eax,%eax
  802157:	74 0a                	je     802163 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802159:	89 04 24             	mov    %eax,(%esp)
  80215c:	e8 4e e2 ff ff       	call   8003af <sys_ipc_recv>
  802161:	eb 0c                	jmp    80216f <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  802163:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  80216a:	e8 40 e2 ff ff       	call   8003af <sys_ipc_recv>
	}
	if (r < 0)
  80216f:	85 c0                	test   %eax,%eax
  802171:	79 16                	jns    802189 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  802173:	85 db                	test   %ebx,%ebx
  802175:	74 06                	je     80217d <ipc_recv+0x39>
  802177:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  80217d:	85 f6                	test   %esi,%esi
  80217f:	74 2c                	je     8021ad <ipc_recv+0x69>
  802181:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802187:	eb 24                	jmp    8021ad <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802189:	85 db                	test   %ebx,%ebx
  80218b:	74 0a                	je     802197 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  80218d:	a1 08 40 80 00       	mov    0x804008,%eax
  802192:	8b 40 74             	mov    0x74(%eax),%eax
  802195:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  802197:	85 f6                	test   %esi,%esi
  802199:	74 0a                	je     8021a5 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  80219b:	a1 08 40 80 00       	mov    0x804008,%eax
  8021a0:	8b 40 78             	mov    0x78(%eax),%eax
  8021a3:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8021a5:	a1 08 40 80 00       	mov    0x804008,%eax
  8021aa:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8021ad:	83 c4 10             	add    $0x10,%esp
  8021b0:	5b                   	pop    %ebx
  8021b1:	5e                   	pop    %esi
  8021b2:	5d                   	pop    %ebp
  8021b3:	c3                   	ret    

008021b4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021b4:	55                   	push   %ebp
  8021b5:	89 e5                	mov    %esp,%ebp
  8021b7:	57                   	push   %edi
  8021b8:	56                   	push   %esi
  8021b9:	53                   	push   %ebx
  8021ba:	83 ec 1c             	sub    $0x1c,%esp
  8021bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8021c0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8021c6:	85 db                	test   %ebx,%ebx
  8021c8:	74 19                	je     8021e3 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8021ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8021cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021d1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021d5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021d9:	89 34 24             	mov    %esi,(%esp)
  8021dc:	e8 ab e1 ff ff       	call   80038c <sys_ipc_try_send>
  8021e1:	eb 1c                	jmp    8021ff <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  8021e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8021ea:	00 
  8021eb:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8021f2:	ee 
  8021f3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8021f7:	89 34 24             	mov    %esi,(%esp)
  8021fa:	e8 8d e1 ff ff       	call   80038c <sys_ipc_try_send>
		}
		if (r == 0)
  8021ff:	85 c0                	test   %eax,%eax
  802201:	74 2c                	je     80222f <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802203:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802206:	74 20                	je     802228 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802208:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80220c:	c7 44 24 08 a4 29 80 	movl   $0x8029a4,0x8(%esp)
  802213:	00 
  802214:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80221b:	00 
  80221c:	c7 04 24 b7 29 80 00 	movl   $0x8029b7,(%esp)
  802223:	e8 08 f5 ff ff       	call   801730 <_panic>
		}
		sys_yield();
  802228:	e8 4d df ff ff       	call   80017a <sys_yield>
	}
  80222d:	eb 97                	jmp    8021c6 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  80222f:	83 c4 1c             	add    $0x1c,%esp
  802232:	5b                   	pop    %ebx
  802233:	5e                   	pop    %esi
  802234:	5f                   	pop    %edi
  802235:	5d                   	pop    %ebp
  802236:	c3                   	ret    

00802237 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802237:	55                   	push   %ebp
  802238:	89 e5                	mov    %esp,%ebp
  80223a:	53                   	push   %ebx
  80223b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80223e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802243:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80224a:	89 c2                	mov    %eax,%edx
  80224c:	c1 e2 07             	shl    $0x7,%edx
  80224f:	29 ca                	sub    %ecx,%edx
  802251:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802257:	8b 52 50             	mov    0x50(%edx),%edx
  80225a:	39 da                	cmp    %ebx,%edx
  80225c:	75 0f                	jne    80226d <ipc_find_env+0x36>
			return envs[i].env_id;
  80225e:	c1 e0 07             	shl    $0x7,%eax
  802261:	29 c8                	sub    %ecx,%eax
  802263:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802268:	8b 40 40             	mov    0x40(%eax),%eax
  80226b:	eb 0c                	jmp    802279 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80226d:	40                   	inc    %eax
  80226e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802273:	75 ce                	jne    802243 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802275:	66 b8 00 00          	mov    $0x0,%ax
}
  802279:	5b                   	pop    %ebx
  80227a:	5d                   	pop    %ebp
  80227b:	c3                   	ret    

0080227c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80227c:	55                   	push   %ebp
  80227d:	89 e5                	mov    %esp,%ebp
  80227f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802282:	89 c2                	mov    %eax,%edx
  802284:	c1 ea 16             	shr    $0x16,%edx
  802287:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80228e:	f6 c2 01             	test   $0x1,%dl
  802291:	74 1e                	je     8022b1 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802293:	c1 e8 0c             	shr    $0xc,%eax
  802296:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80229d:	a8 01                	test   $0x1,%al
  80229f:	74 17                	je     8022b8 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022a1:	c1 e8 0c             	shr    $0xc,%eax
  8022a4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8022ab:	ef 
  8022ac:	0f b7 c0             	movzwl %ax,%eax
  8022af:	eb 0c                	jmp    8022bd <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8022b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b6:	eb 05                	jmp    8022bd <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8022b8:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8022bd:	5d                   	pop    %ebp
  8022be:	c3                   	ret    
	...

008022c0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8022c0:	55                   	push   %ebp
  8022c1:	57                   	push   %edi
  8022c2:	56                   	push   %esi
  8022c3:	83 ec 10             	sub    $0x10,%esp
  8022c6:	8b 74 24 20          	mov    0x20(%esp),%esi
  8022ca:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8022ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022d2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8022d6:	89 cd                	mov    %ecx,%ebp
  8022d8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8022dc:	85 c0                	test   %eax,%eax
  8022de:	75 2c                	jne    80230c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8022e0:	39 f9                	cmp    %edi,%ecx
  8022e2:	77 68                	ja     80234c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8022e4:	85 c9                	test   %ecx,%ecx
  8022e6:	75 0b                	jne    8022f3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8022e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8022ed:	31 d2                	xor    %edx,%edx
  8022ef:	f7 f1                	div    %ecx
  8022f1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8022f3:	31 d2                	xor    %edx,%edx
  8022f5:	89 f8                	mov    %edi,%eax
  8022f7:	f7 f1                	div    %ecx
  8022f9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022fb:	89 f0                	mov    %esi,%eax
  8022fd:	f7 f1                	div    %ecx
  8022ff:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802301:	89 f0                	mov    %esi,%eax
  802303:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802305:	83 c4 10             	add    $0x10,%esp
  802308:	5e                   	pop    %esi
  802309:	5f                   	pop    %edi
  80230a:	5d                   	pop    %ebp
  80230b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80230c:	39 f8                	cmp    %edi,%eax
  80230e:	77 2c                	ja     80233c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802310:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802313:	83 f6 1f             	xor    $0x1f,%esi
  802316:	75 4c                	jne    802364 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802318:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80231a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80231f:	72 0a                	jb     80232b <__udivdi3+0x6b>
  802321:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802325:	0f 87 ad 00 00 00    	ja     8023d8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80232b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802330:	89 f0                	mov    %esi,%eax
  802332:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802334:	83 c4 10             	add    $0x10,%esp
  802337:	5e                   	pop    %esi
  802338:	5f                   	pop    %edi
  802339:	5d                   	pop    %ebp
  80233a:	c3                   	ret    
  80233b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80233c:	31 ff                	xor    %edi,%edi
  80233e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802340:	89 f0                	mov    %esi,%eax
  802342:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802344:	83 c4 10             	add    $0x10,%esp
  802347:	5e                   	pop    %esi
  802348:	5f                   	pop    %edi
  802349:	5d                   	pop    %ebp
  80234a:	c3                   	ret    
  80234b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80234c:	89 fa                	mov    %edi,%edx
  80234e:	89 f0                	mov    %esi,%eax
  802350:	f7 f1                	div    %ecx
  802352:	89 c6                	mov    %eax,%esi
  802354:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802356:	89 f0                	mov    %esi,%eax
  802358:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80235a:	83 c4 10             	add    $0x10,%esp
  80235d:	5e                   	pop    %esi
  80235e:	5f                   	pop    %edi
  80235f:	5d                   	pop    %ebp
  802360:	c3                   	ret    
  802361:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802364:	89 f1                	mov    %esi,%ecx
  802366:	d3 e0                	shl    %cl,%eax
  802368:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80236c:	b8 20 00 00 00       	mov    $0x20,%eax
  802371:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802373:	89 ea                	mov    %ebp,%edx
  802375:	88 c1                	mov    %al,%cl
  802377:	d3 ea                	shr    %cl,%edx
  802379:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80237d:	09 ca                	or     %ecx,%edx
  80237f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802383:	89 f1                	mov    %esi,%ecx
  802385:	d3 e5                	shl    %cl,%ebp
  802387:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80238b:	89 fd                	mov    %edi,%ebp
  80238d:	88 c1                	mov    %al,%cl
  80238f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802391:	89 fa                	mov    %edi,%edx
  802393:	89 f1                	mov    %esi,%ecx
  802395:	d3 e2                	shl    %cl,%edx
  802397:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80239b:	88 c1                	mov    %al,%cl
  80239d:	d3 ef                	shr    %cl,%edi
  80239f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023a1:	89 f8                	mov    %edi,%eax
  8023a3:	89 ea                	mov    %ebp,%edx
  8023a5:	f7 74 24 08          	divl   0x8(%esp)
  8023a9:	89 d1                	mov    %edx,%ecx
  8023ab:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8023ad:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023b1:	39 d1                	cmp    %edx,%ecx
  8023b3:	72 17                	jb     8023cc <__udivdi3+0x10c>
  8023b5:	74 09                	je     8023c0 <__udivdi3+0x100>
  8023b7:	89 fe                	mov    %edi,%esi
  8023b9:	31 ff                	xor    %edi,%edi
  8023bb:	e9 41 ff ff ff       	jmp    802301 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8023c0:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023c4:	89 f1                	mov    %esi,%ecx
  8023c6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023c8:	39 c2                	cmp    %eax,%edx
  8023ca:	73 eb                	jae    8023b7 <__udivdi3+0xf7>
		{
		  q0--;
  8023cc:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8023cf:	31 ff                	xor    %edi,%edi
  8023d1:	e9 2b ff ff ff       	jmp    802301 <__udivdi3+0x41>
  8023d6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8023d8:	31 f6                	xor    %esi,%esi
  8023da:	e9 22 ff ff ff       	jmp    802301 <__udivdi3+0x41>
	...

008023e0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8023e0:	55                   	push   %ebp
  8023e1:	57                   	push   %edi
  8023e2:	56                   	push   %esi
  8023e3:	83 ec 20             	sub    $0x20,%esp
  8023e6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8023ea:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8023ee:	89 44 24 14          	mov    %eax,0x14(%esp)
  8023f2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8023f6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023fa:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8023fe:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802400:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802402:	85 ed                	test   %ebp,%ebp
  802404:	75 16                	jne    80241c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802406:	39 f1                	cmp    %esi,%ecx
  802408:	0f 86 a6 00 00 00    	jbe    8024b4 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80240e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802410:	89 d0                	mov    %edx,%eax
  802412:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802414:	83 c4 20             	add    $0x20,%esp
  802417:	5e                   	pop    %esi
  802418:	5f                   	pop    %edi
  802419:	5d                   	pop    %ebp
  80241a:	c3                   	ret    
  80241b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80241c:	39 f5                	cmp    %esi,%ebp
  80241e:	0f 87 ac 00 00 00    	ja     8024d0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802424:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802427:	83 f0 1f             	xor    $0x1f,%eax
  80242a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80242e:	0f 84 a8 00 00 00    	je     8024dc <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802434:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802438:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80243a:	bf 20 00 00 00       	mov    $0x20,%edi
  80243f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802443:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802447:	89 f9                	mov    %edi,%ecx
  802449:	d3 e8                	shr    %cl,%eax
  80244b:	09 e8                	or     %ebp,%eax
  80244d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802451:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802455:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802459:	d3 e0                	shl    %cl,%eax
  80245b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80245f:	89 f2                	mov    %esi,%edx
  802461:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802463:	8b 44 24 14          	mov    0x14(%esp),%eax
  802467:	d3 e0                	shl    %cl,%eax
  802469:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80246d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802471:	89 f9                	mov    %edi,%ecx
  802473:	d3 e8                	shr    %cl,%eax
  802475:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802477:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802479:	89 f2                	mov    %esi,%edx
  80247b:	f7 74 24 18          	divl   0x18(%esp)
  80247f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802481:	f7 64 24 0c          	mull   0xc(%esp)
  802485:	89 c5                	mov    %eax,%ebp
  802487:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802489:	39 d6                	cmp    %edx,%esi
  80248b:	72 67                	jb     8024f4 <__umoddi3+0x114>
  80248d:	74 75                	je     802504 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80248f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802493:	29 e8                	sub    %ebp,%eax
  802495:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802497:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80249b:	d3 e8                	shr    %cl,%eax
  80249d:	89 f2                	mov    %esi,%edx
  80249f:	89 f9                	mov    %edi,%ecx
  8024a1:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8024a3:	09 d0                	or     %edx,%eax
  8024a5:	89 f2                	mov    %esi,%edx
  8024a7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024ab:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024ad:	83 c4 20             	add    $0x20,%esp
  8024b0:	5e                   	pop    %esi
  8024b1:	5f                   	pop    %edi
  8024b2:	5d                   	pop    %ebp
  8024b3:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8024b4:	85 c9                	test   %ecx,%ecx
  8024b6:	75 0b                	jne    8024c3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8024b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8024bd:	31 d2                	xor    %edx,%edx
  8024bf:	f7 f1                	div    %ecx
  8024c1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8024c3:	89 f0                	mov    %esi,%eax
  8024c5:	31 d2                	xor    %edx,%edx
  8024c7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8024c9:	89 f8                	mov    %edi,%eax
  8024cb:	e9 3e ff ff ff       	jmp    80240e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8024d0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024d2:	83 c4 20             	add    $0x20,%esp
  8024d5:	5e                   	pop    %esi
  8024d6:	5f                   	pop    %edi
  8024d7:	5d                   	pop    %ebp
  8024d8:	c3                   	ret    
  8024d9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8024dc:	39 f5                	cmp    %esi,%ebp
  8024de:	72 04                	jb     8024e4 <__umoddi3+0x104>
  8024e0:	39 f9                	cmp    %edi,%ecx
  8024e2:	77 06                	ja     8024ea <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8024e4:	89 f2                	mov    %esi,%edx
  8024e6:	29 cf                	sub    %ecx,%edi
  8024e8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8024ea:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8024ec:	83 c4 20             	add    $0x20,%esp
  8024ef:	5e                   	pop    %esi
  8024f0:	5f                   	pop    %edi
  8024f1:	5d                   	pop    %ebp
  8024f2:	c3                   	ret    
  8024f3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8024f4:	89 d1                	mov    %edx,%ecx
  8024f6:	89 c5                	mov    %eax,%ebp
  8024f8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8024fc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802500:	eb 8d                	jmp    80248f <__umoddi3+0xaf>
  802502:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802504:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802508:	72 ea                	jb     8024f4 <__umoddi3+0x114>
  80250a:	89 f1                	mov    %esi,%ecx
  80250c:	eb 81                	jmp    80248f <__umoddi3+0xaf>
