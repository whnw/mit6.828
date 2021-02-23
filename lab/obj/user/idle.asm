
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 30 80 00 a0 	movl   $0x8024a0,0x803000
  800041:	24 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 21 01 00 00       	call   80016a <sys_yield>
  800049:	eb f9                	jmp    800044 <umain+0x10>
	...

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	56                   	push   %esi
  800050:	53                   	push   %ebx
  800051:	83 ec 10             	sub    $0x10,%esp
  800054:	8b 75 08             	mov    0x8(%ebp),%esi
  800057:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005a:	e8 ec 00 00 00       	call   80014b <sys_getenvid>
  80005f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800064:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006b:	c1 e0 07             	shl    $0x7,%eax
  80006e:	29 d0                	sub    %edx,%eax
  800070:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800075:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007a:	85 f6                	test   %esi,%esi
  80007c:	7e 07                	jle    800085 <libmain+0x39>
		binaryname = argv[0];
  80007e:	8b 03                	mov    (%ebx),%eax
  800080:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800085:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800089:	89 34 24             	mov    %esi,(%esp)
  80008c:	e8 a3 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800091:	e8 0a 00 00 00       	call   8000a0 <exit>
}
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	5b                   	pop    %ebx
  80009a:	5e                   	pop    %esi
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    
  80009d:	00 00                	add    %al,(%eax)
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000a6:	e8 90 05 00 00       	call   80063b <close_all>
	sys_env_destroy(0);
  8000ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b2:	e8 42 00 00 00       	call   8000f9 <sys_env_destroy>
}
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    
  8000b9:	00 00                	add    %al,(%eax)
	...

008000bc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cd:	89 c3                	mov    %eax,%ebx
  8000cf:	89 c7                	mov    %eax,%edi
  8000d1:	89 c6                	mov    %eax,%esi
  8000d3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <sys_cgetc>:

int
sys_cgetc(void)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	57                   	push   %edi
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ea:	89 d1                	mov    %edx,%ecx
  8000ec:	89 d3                	mov    %edx,%ebx
  8000ee:	89 d7                	mov    %edx,%edi
  8000f0:	89 d6                	mov    %edx,%esi
  8000f2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    

008000f9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f9:	55                   	push   %ebp
  8000fa:	89 e5                	mov    %esp,%ebp
  8000fc:	57                   	push   %edi
  8000fd:	56                   	push   %esi
  8000fe:	53                   	push   %ebx
  8000ff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800102:	b9 00 00 00 00       	mov    $0x0,%ecx
  800107:	b8 03 00 00 00       	mov    $0x3,%eax
  80010c:	8b 55 08             	mov    0x8(%ebp),%edx
  80010f:	89 cb                	mov    %ecx,%ebx
  800111:	89 cf                	mov    %ecx,%edi
  800113:	89 ce                	mov    %ecx,%esi
  800115:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800117:	85 c0                	test   %eax,%eax
  800119:	7e 28                	jle    800143 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80011f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800126:	00 
  800127:	c7 44 24 08 af 24 80 	movl   $0x8024af,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 cc 24 80 00 	movl   $0x8024cc,(%esp)
  80013e:	e8 b5 15 00 00       	call   8016f8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800143:	83 c4 2c             	add    $0x2c,%esp
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 02 00 00 00       	mov    $0x2,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_yield>:

void
sys_yield(void)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800170:	ba 00 00 00 00       	mov    $0x0,%edx
  800175:	b8 0b 00 00 00       	mov    $0xb,%eax
  80017a:	89 d1                	mov    %edx,%ecx
  80017c:	89 d3                	mov    %edx,%ebx
  80017e:	89 d7                	mov    %edx,%edi
  800180:	89 d6                	mov    %edx,%esi
  800182:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800184:	5b                   	pop    %ebx
  800185:	5e                   	pop    %esi
  800186:	5f                   	pop    %edi
  800187:	5d                   	pop    %ebp
  800188:	c3                   	ret    

00800189 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800189:	55                   	push   %ebp
  80018a:	89 e5                	mov    %esp,%ebp
  80018c:	57                   	push   %edi
  80018d:	56                   	push   %esi
  80018e:	53                   	push   %ebx
  80018f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800192:	be 00 00 00 00       	mov    $0x0,%esi
  800197:	b8 04 00 00 00       	mov    $0x4,%eax
  80019c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a5:	89 f7                	mov    %esi,%edi
  8001a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	7e 28                	jle    8001d5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b8:	00 
  8001b9:	c7 44 24 08 af 24 80 	movl   $0x8024af,0x8(%esp)
  8001c0:	00 
  8001c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c8:	00 
  8001c9:	c7 04 24 cc 24 80 00 	movl   $0x8024cc,(%esp)
  8001d0:	e8 23 15 00 00       	call   8016f8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d5:	83 c4 2c             	add    $0x2c,%esp
  8001d8:	5b                   	pop    %ebx
  8001d9:	5e                   	pop    %esi
  8001da:	5f                   	pop    %edi
  8001db:	5d                   	pop    %ebp
  8001dc:	c3                   	ret    

008001dd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001dd:	55                   	push   %ebp
  8001de:	89 e5                	mov    %esp,%ebp
  8001e0:	57                   	push   %edi
  8001e1:	56                   	push   %esi
  8001e2:	53                   	push   %ebx
  8001e3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001eb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ee:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fc:	85 c0                	test   %eax,%eax
  8001fe:	7e 28                	jle    800228 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800200:	89 44 24 10          	mov    %eax,0x10(%esp)
  800204:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80020b:	00 
  80020c:	c7 44 24 08 af 24 80 	movl   $0x8024af,0x8(%esp)
  800213:	00 
  800214:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80021b:	00 
  80021c:	c7 04 24 cc 24 80 00 	movl   $0x8024cc,(%esp)
  800223:	e8 d0 14 00 00       	call   8016f8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800228:	83 c4 2c             	add    $0x2c,%esp
  80022b:	5b                   	pop    %ebx
  80022c:	5e                   	pop    %esi
  80022d:	5f                   	pop    %edi
  80022e:	5d                   	pop    %ebp
  80022f:	c3                   	ret    

00800230 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800239:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023e:	b8 06 00 00 00       	mov    $0x6,%eax
  800243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800246:	8b 55 08             	mov    0x8(%ebp),%edx
  800249:	89 df                	mov    %ebx,%edi
  80024b:	89 de                	mov    %ebx,%esi
  80024d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024f:	85 c0                	test   %eax,%eax
  800251:	7e 28                	jle    80027b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800253:	89 44 24 10          	mov    %eax,0x10(%esp)
  800257:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80025e:	00 
  80025f:	c7 44 24 08 af 24 80 	movl   $0x8024af,0x8(%esp)
  800266:	00 
  800267:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80026e:	00 
  80026f:	c7 04 24 cc 24 80 00 	movl   $0x8024cc,(%esp)
  800276:	e8 7d 14 00 00       	call   8016f8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80027b:	83 c4 2c             	add    $0x2c,%esp
  80027e:	5b                   	pop    %ebx
  80027f:	5e                   	pop    %esi
  800280:	5f                   	pop    %edi
  800281:	5d                   	pop    %ebp
  800282:	c3                   	ret    

00800283 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800283:	55                   	push   %ebp
  800284:	89 e5                	mov    %esp,%ebp
  800286:	57                   	push   %edi
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800291:	b8 08 00 00 00       	mov    $0x8,%eax
  800296:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800299:	8b 55 08             	mov    0x8(%ebp),%edx
  80029c:	89 df                	mov    %ebx,%edi
  80029e:	89 de                	mov    %ebx,%esi
  8002a0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a2:	85 c0                	test   %eax,%eax
  8002a4:	7e 28                	jle    8002ce <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002aa:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002b1:	00 
  8002b2:	c7 44 24 08 af 24 80 	movl   $0x8024af,0x8(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c1:	00 
  8002c2:	c7 04 24 cc 24 80 00 	movl   $0x8024cc,(%esp)
  8002c9:	e8 2a 14 00 00       	call   8016f8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002ce:	83 c4 2c             	add    $0x2c,%esp
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ef:	89 df                	mov    %ebx,%edi
  8002f1:	89 de                	mov    %ebx,%esi
  8002f3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f5:	85 c0                	test   %eax,%eax
  8002f7:	7e 28                	jle    800321 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002fd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800304:	00 
  800305:	c7 44 24 08 af 24 80 	movl   $0x8024af,0x8(%esp)
  80030c:	00 
  80030d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800314:	00 
  800315:	c7 04 24 cc 24 80 00 	movl   $0x8024cc,(%esp)
  80031c:	e8 d7 13 00 00       	call   8016f8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800321:	83 c4 2c             	add    $0x2c,%esp
  800324:	5b                   	pop    %ebx
  800325:	5e                   	pop    %esi
  800326:	5f                   	pop    %edi
  800327:	5d                   	pop    %ebp
  800328:	c3                   	ret    

00800329 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800329:	55                   	push   %ebp
  80032a:	89 e5                	mov    %esp,%ebp
  80032c:	57                   	push   %edi
  80032d:	56                   	push   %esi
  80032e:	53                   	push   %ebx
  80032f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800332:	bb 00 00 00 00       	mov    $0x0,%ebx
  800337:	b8 0a 00 00 00       	mov    $0xa,%eax
  80033c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033f:	8b 55 08             	mov    0x8(%ebp),%edx
  800342:	89 df                	mov    %ebx,%edi
  800344:	89 de                	mov    %ebx,%esi
  800346:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800348:	85 c0                	test   %eax,%eax
  80034a:	7e 28                	jle    800374 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80034c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800350:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800357:	00 
  800358:	c7 44 24 08 af 24 80 	movl   $0x8024af,0x8(%esp)
  80035f:	00 
  800360:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800367:	00 
  800368:	c7 04 24 cc 24 80 00 	movl   $0x8024cc,(%esp)
  80036f:	e8 84 13 00 00       	call   8016f8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800374:	83 c4 2c             	add    $0x2c,%esp
  800377:	5b                   	pop    %ebx
  800378:	5e                   	pop    %esi
  800379:	5f                   	pop    %edi
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	57                   	push   %edi
  800380:	56                   	push   %esi
  800381:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800382:	be 00 00 00 00       	mov    $0x0,%esi
  800387:	b8 0c 00 00 00       	mov    $0xc,%eax
  80038c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80038f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800392:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800395:	8b 55 08             	mov    0x8(%ebp),%edx
  800398:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80039a:	5b                   	pop    %ebx
  80039b:	5e                   	pop    %esi
  80039c:	5f                   	pop    %edi
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    

0080039f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	57                   	push   %edi
  8003a3:	56                   	push   %esi
  8003a4:	53                   	push   %ebx
  8003a5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ad:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b5:	89 cb                	mov    %ecx,%ebx
  8003b7:	89 cf                	mov    %ecx,%edi
  8003b9:	89 ce                	mov    %ecx,%esi
  8003bb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003bd:	85 c0                	test   %eax,%eax
  8003bf:	7e 28                	jle    8003e9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003cc:	00 
  8003cd:	c7 44 24 08 af 24 80 	movl   $0x8024af,0x8(%esp)
  8003d4:	00 
  8003d5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003dc:	00 
  8003dd:	c7 04 24 cc 24 80 00 	movl   $0x8024cc,(%esp)
  8003e4:	e8 0f 13 00 00       	call   8016f8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003e9:	83 c4 2c             	add    $0x2c,%esp
  8003ec:	5b                   	pop    %ebx
  8003ed:	5e                   	pop    %esi
  8003ee:	5f                   	pop    %edi
  8003ef:	5d                   	pop    %ebp
  8003f0:	c3                   	ret    

008003f1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8003f1:	55                   	push   %ebp
  8003f2:	89 e5                	mov    %esp,%ebp
  8003f4:	57                   	push   %edi
  8003f5:	56                   	push   %esi
  8003f6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fc:	b8 0e 00 00 00       	mov    $0xe,%eax
  800401:	89 d1                	mov    %edx,%ecx
  800403:	89 d3                	mov    %edx,%ebx
  800405:	89 d7                	mov    %edx,%edi
  800407:	89 d6                	mov    %edx,%esi
  800409:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80040b:	5b                   	pop    %ebx
  80040c:	5e                   	pop    %esi
  80040d:	5f                   	pop    %edi
  80040e:	5d                   	pop    %ebp
  80040f:	c3                   	ret    

00800410 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	57                   	push   %edi
  800414:	56                   	push   %esi
  800415:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800416:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800420:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800423:	8b 55 08             	mov    0x8(%ebp),%edx
  800426:	89 df                	mov    %ebx,%edi
  800428:	89 de                	mov    %ebx,%esi
  80042a:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  80042c:	5b                   	pop    %ebx
  80042d:	5e                   	pop    %esi
  80042e:	5f                   	pop    %edi
  80042f:	5d                   	pop    %ebp
  800430:	c3                   	ret    

00800431 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	57                   	push   %edi
  800435:	56                   	push   %esi
  800436:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800437:	bb 00 00 00 00       	mov    $0x0,%ebx
  80043c:	b8 10 00 00 00       	mov    $0x10,%eax
  800441:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800444:	8b 55 08             	mov    0x8(%ebp),%edx
  800447:	89 df                	mov    %ebx,%edi
  800449:	89 de                	mov    %ebx,%esi
  80044b:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  80044d:	5b                   	pop    %ebx
  80044e:	5e                   	pop    %esi
  80044f:	5f                   	pop    %edi
  800450:	5d                   	pop    %ebp
  800451:	c3                   	ret    
	...

00800454 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800457:	8b 45 08             	mov    0x8(%ebp),%eax
  80045a:	05 00 00 00 30       	add    $0x30000000,%eax
  80045f:	c1 e8 0c             	shr    $0xc,%eax
}
  800462:	5d                   	pop    %ebp
  800463:	c3                   	ret    

00800464 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
  800467:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80046a:	8b 45 08             	mov    0x8(%ebp),%eax
  80046d:	89 04 24             	mov    %eax,(%esp)
  800470:	e8 df ff ff ff       	call   800454 <fd2num>
  800475:	c1 e0 0c             	shl    $0xc,%eax
  800478:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80047d:	c9                   	leave  
  80047e:	c3                   	ret    

0080047f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
  800482:	53                   	push   %ebx
  800483:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800486:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80048b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80048d:	89 c2                	mov    %eax,%edx
  80048f:	c1 ea 16             	shr    $0x16,%edx
  800492:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800499:	f6 c2 01             	test   $0x1,%dl
  80049c:	74 11                	je     8004af <fd_alloc+0x30>
  80049e:	89 c2                	mov    %eax,%edx
  8004a0:	c1 ea 0c             	shr    $0xc,%edx
  8004a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004aa:	f6 c2 01             	test   $0x1,%dl
  8004ad:	75 09                	jne    8004b8 <fd_alloc+0x39>
			*fd_store = fd;
  8004af:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8004b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b6:	eb 17                	jmp    8004cf <fd_alloc+0x50>
  8004b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8004bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8004c2:	75 c7                	jne    80048b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8004c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8004ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8004cf:	5b                   	pop    %ebx
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004d8:	83 f8 1f             	cmp    $0x1f,%eax
  8004db:	77 36                	ja     800513 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004dd:	c1 e0 0c             	shl    $0xc,%eax
  8004e0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004e5:	89 c2                	mov    %eax,%edx
  8004e7:	c1 ea 16             	shr    $0x16,%edx
  8004ea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004f1:	f6 c2 01             	test   $0x1,%dl
  8004f4:	74 24                	je     80051a <fd_lookup+0x48>
  8004f6:	89 c2                	mov    %eax,%edx
  8004f8:	c1 ea 0c             	shr    $0xc,%edx
  8004fb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800502:	f6 c2 01             	test   $0x1,%dl
  800505:	74 1a                	je     800521 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800507:	8b 55 0c             	mov    0xc(%ebp),%edx
  80050a:	89 02                	mov    %eax,(%edx)
	return 0;
  80050c:	b8 00 00 00 00       	mov    $0x0,%eax
  800511:	eb 13                	jmp    800526 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800513:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800518:	eb 0c                	jmp    800526 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80051a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80051f:	eb 05                	jmp    800526 <fd_lookup+0x54>
  800521:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800526:	5d                   	pop    %ebp
  800527:	c3                   	ret    

00800528 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800528:	55                   	push   %ebp
  800529:	89 e5                	mov    %esp,%ebp
  80052b:	53                   	push   %ebx
  80052c:	83 ec 14             	sub    $0x14,%esp
  80052f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800535:	ba 00 00 00 00       	mov    $0x0,%edx
  80053a:	eb 0e                	jmp    80054a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80053c:	39 08                	cmp    %ecx,(%eax)
  80053e:	75 09                	jne    800549 <dev_lookup+0x21>
			*dev = devtab[i];
  800540:	89 03                	mov    %eax,(%ebx)
			return 0;
  800542:	b8 00 00 00 00       	mov    $0x0,%eax
  800547:	eb 33                	jmp    80057c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800549:	42                   	inc    %edx
  80054a:	8b 04 95 58 25 80 00 	mov    0x802558(,%edx,4),%eax
  800551:	85 c0                	test   %eax,%eax
  800553:	75 e7                	jne    80053c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800555:	a1 08 40 80 00       	mov    0x804008,%eax
  80055a:	8b 40 48             	mov    0x48(%eax),%eax
  80055d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800561:	89 44 24 04          	mov    %eax,0x4(%esp)
  800565:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  80056c:	e8 7f 12 00 00       	call   8017f0 <cprintf>
	*dev = 0;
  800571:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800577:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80057c:	83 c4 14             	add    $0x14,%esp
  80057f:	5b                   	pop    %ebx
  800580:	5d                   	pop    %ebp
  800581:	c3                   	ret    

00800582 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800582:	55                   	push   %ebp
  800583:	89 e5                	mov    %esp,%ebp
  800585:	56                   	push   %esi
  800586:	53                   	push   %ebx
  800587:	83 ec 30             	sub    $0x30,%esp
  80058a:	8b 75 08             	mov    0x8(%ebp),%esi
  80058d:	8a 45 0c             	mov    0xc(%ebp),%al
  800590:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800593:	89 34 24             	mov    %esi,(%esp)
  800596:	e8 b9 fe ff ff       	call   800454 <fd2num>
  80059b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80059e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005a2:	89 04 24             	mov    %eax,(%esp)
  8005a5:	e8 28 ff ff ff       	call   8004d2 <fd_lookup>
  8005aa:	89 c3                	mov    %eax,%ebx
  8005ac:	85 c0                	test   %eax,%eax
  8005ae:	78 05                	js     8005b5 <fd_close+0x33>
	    || fd != fd2)
  8005b0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8005b3:	74 0d                	je     8005c2 <fd_close+0x40>
		return (must_exist ? r : 0);
  8005b5:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8005b9:	75 46                	jne    800601 <fd_close+0x7f>
  8005bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005c0:	eb 3f                	jmp    800601 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8005c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8005c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c9:	8b 06                	mov    (%esi),%eax
  8005cb:	89 04 24             	mov    %eax,(%esp)
  8005ce:	e8 55 ff ff ff       	call   800528 <dev_lookup>
  8005d3:	89 c3                	mov    %eax,%ebx
  8005d5:	85 c0                	test   %eax,%eax
  8005d7:	78 18                	js     8005f1 <fd_close+0x6f>
		if (dev->dev_close)
  8005d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005dc:	8b 40 10             	mov    0x10(%eax),%eax
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	74 09                	je     8005ec <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005e3:	89 34 24             	mov    %esi,(%esp)
  8005e6:	ff d0                	call   *%eax
  8005e8:	89 c3                	mov    %eax,%ebx
  8005ea:	eb 05                	jmp    8005f1 <fd_close+0x6f>
		else
			r = 0;
  8005ec:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005fc:	e8 2f fc ff ff       	call   800230 <sys_page_unmap>
	return r;
}
  800601:	89 d8                	mov    %ebx,%eax
  800603:	83 c4 30             	add    $0x30,%esp
  800606:	5b                   	pop    %ebx
  800607:	5e                   	pop    %esi
  800608:	5d                   	pop    %ebp
  800609:	c3                   	ret    

0080060a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80060a:	55                   	push   %ebp
  80060b:	89 e5                	mov    %esp,%ebp
  80060d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800610:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800613:	89 44 24 04          	mov    %eax,0x4(%esp)
  800617:	8b 45 08             	mov    0x8(%ebp),%eax
  80061a:	89 04 24             	mov    %eax,(%esp)
  80061d:	e8 b0 fe ff ff       	call   8004d2 <fd_lookup>
  800622:	85 c0                	test   %eax,%eax
  800624:	78 13                	js     800639 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800626:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80062d:	00 
  80062e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800631:	89 04 24             	mov    %eax,(%esp)
  800634:	e8 49 ff ff ff       	call   800582 <fd_close>
}
  800639:	c9                   	leave  
  80063a:	c3                   	ret    

0080063b <close_all>:

void
close_all(void)
{
  80063b:	55                   	push   %ebp
  80063c:	89 e5                	mov    %esp,%ebp
  80063e:	53                   	push   %ebx
  80063f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800642:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800647:	89 1c 24             	mov    %ebx,(%esp)
  80064a:	e8 bb ff ff ff       	call   80060a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80064f:	43                   	inc    %ebx
  800650:	83 fb 20             	cmp    $0x20,%ebx
  800653:	75 f2                	jne    800647 <close_all+0xc>
		close(i);
}
  800655:	83 c4 14             	add    $0x14,%esp
  800658:	5b                   	pop    %ebx
  800659:	5d                   	pop    %ebp
  80065a:	c3                   	ret    

0080065b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80065b:	55                   	push   %ebp
  80065c:	89 e5                	mov    %esp,%ebp
  80065e:	57                   	push   %edi
  80065f:	56                   	push   %esi
  800660:	53                   	push   %ebx
  800661:	83 ec 4c             	sub    $0x4c,%esp
  800664:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800667:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80066a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066e:	8b 45 08             	mov    0x8(%ebp),%eax
  800671:	89 04 24             	mov    %eax,(%esp)
  800674:	e8 59 fe ff ff       	call   8004d2 <fd_lookup>
  800679:	89 c3                	mov    %eax,%ebx
  80067b:	85 c0                	test   %eax,%eax
  80067d:	0f 88 e3 00 00 00    	js     800766 <dup+0x10b>
		return r;
	close(newfdnum);
  800683:	89 3c 24             	mov    %edi,(%esp)
  800686:	e8 7f ff ff ff       	call   80060a <close>

	newfd = INDEX2FD(newfdnum);
  80068b:	89 fe                	mov    %edi,%esi
  80068d:	c1 e6 0c             	shl    $0xc,%esi
  800690:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800696:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800699:	89 04 24             	mov    %eax,(%esp)
  80069c:	e8 c3 fd ff ff       	call   800464 <fd2data>
  8006a1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8006a3:	89 34 24             	mov    %esi,(%esp)
  8006a6:	e8 b9 fd ff ff       	call   800464 <fd2data>
  8006ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8006ae:	89 d8                	mov    %ebx,%eax
  8006b0:	c1 e8 16             	shr    $0x16,%eax
  8006b3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8006ba:	a8 01                	test   $0x1,%al
  8006bc:	74 46                	je     800704 <dup+0xa9>
  8006be:	89 d8                	mov    %ebx,%eax
  8006c0:	c1 e8 0c             	shr    $0xc,%eax
  8006c3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8006ca:	f6 c2 01             	test   $0x1,%dl
  8006cd:	74 35                	je     800704 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8006cf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006d6:	25 07 0e 00 00       	and    $0xe07,%eax
  8006db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006df:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006e6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006ed:	00 
  8006ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006f9:	e8 df fa ff ff       	call   8001dd <sys_page_map>
  8006fe:	89 c3                	mov    %eax,%ebx
  800700:	85 c0                	test   %eax,%eax
  800702:	78 3b                	js     80073f <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800704:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800707:	89 c2                	mov    %eax,%edx
  800709:	c1 ea 0c             	shr    $0xc,%edx
  80070c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800713:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800719:	89 54 24 10          	mov    %edx,0x10(%esp)
  80071d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800721:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800728:	00 
  800729:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800734:	e8 a4 fa ff ff       	call   8001dd <sys_page_map>
  800739:	89 c3                	mov    %eax,%ebx
  80073b:	85 c0                	test   %eax,%eax
  80073d:	79 25                	jns    800764 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80073f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800743:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80074a:	e8 e1 fa ff ff       	call   800230 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80074f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800752:	89 44 24 04          	mov    %eax,0x4(%esp)
  800756:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80075d:	e8 ce fa ff ff       	call   800230 <sys_page_unmap>
	return r;
  800762:	eb 02                	jmp    800766 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800764:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800766:	89 d8                	mov    %ebx,%eax
  800768:	83 c4 4c             	add    $0x4c,%esp
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5f                   	pop    %edi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	53                   	push   %ebx
  800774:	83 ec 24             	sub    $0x24,%esp
  800777:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80077a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80077d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800781:	89 1c 24             	mov    %ebx,(%esp)
  800784:	e8 49 fd ff ff       	call   8004d2 <fd_lookup>
  800789:	85 c0                	test   %eax,%eax
  80078b:	78 6d                	js     8007fa <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800790:	89 44 24 04          	mov    %eax,0x4(%esp)
  800794:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800797:	8b 00                	mov    (%eax),%eax
  800799:	89 04 24             	mov    %eax,(%esp)
  80079c:	e8 87 fd ff ff       	call   800528 <dev_lookup>
  8007a1:	85 c0                	test   %eax,%eax
  8007a3:	78 55                	js     8007fa <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8007a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a8:	8b 50 08             	mov    0x8(%eax),%edx
  8007ab:	83 e2 03             	and    $0x3,%edx
  8007ae:	83 fa 01             	cmp    $0x1,%edx
  8007b1:	75 23                	jne    8007d6 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8007b3:	a1 08 40 80 00       	mov    0x804008,%eax
  8007b8:	8b 40 48             	mov    0x48(%eax),%eax
  8007bb:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c3:	c7 04 24 1d 25 80 00 	movl   $0x80251d,(%esp)
  8007ca:	e8 21 10 00 00       	call   8017f0 <cprintf>
		return -E_INVAL;
  8007cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d4:	eb 24                	jmp    8007fa <read+0x8a>
	}
	if (!dev->dev_read)
  8007d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d9:	8b 52 08             	mov    0x8(%edx),%edx
  8007dc:	85 d2                	test   %edx,%edx
  8007de:	74 15                	je     8007f5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8007e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ea:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007ee:	89 04 24             	mov    %eax,(%esp)
  8007f1:	ff d2                	call   *%edx
  8007f3:	eb 05                	jmp    8007fa <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8007f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8007fa:	83 c4 24             	add    $0x24,%esp
  8007fd:	5b                   	pop    %ebx
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	57                   	push   %edi
  800804:	56                   	push   %esi
  800805:	53                   	push   %ebx
  800806:	83 ec 1c             	sub    $0x1c,%esp
  800809:	8b 7d 08             	mov    0x8(%ebp),%edi
  80080c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80080f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800814:	eb 23                	jmp    800839 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800816:	89 f0                	mov    %esi,%eax
  800818:	29 d8                	sub    %ebx,%eax
  80081a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800821:	01 d8                	add    %ebx,%eax
  800823:	89 44 24 04          	mov    %eax,0x4(%esp)
  800827:	89 3c 24             	mov    %edi,(%esp)
  80082a:	e8 41 ff ff ff       	call   800770 <read>
		if (m < 0)
  80082f:	85 c0                	test   %eax,%eax
  800831:	78 10                	js     800843 <readn+0x43>
			return m;
		if (m == 0)
  800833:	85 c0                	test   %eax,%eax
  800835:	74 0a                	je     800841 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800837:	01 c3                	add    %eax,%ebx
  800839:	39 f3                	cmp    %esi,%ebx
  80083b:	72 d9                	jb     800816 <readn+0x16>
  80083d:	89 d8                	mov    %ebx,%eax
  80083f:	eb 02                	jmp    800843 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800841:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800843:	83 c4 1c             	add    $0x1c,%esp
  800846:	5b                   	pop    %ebx
  800847:	5e                   	pop    %esi
  800848:	5f                   	pop    %edi
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	83 ec 24             	sub    $0x24,%esp
  800852:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800855:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800858:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085c:	89 1c 24             	mov    %ebx,(%esp)
  80085f:	e8 6e fc ff ff       	call   8004d2 <fd_lookup>
  800864:	85 c0                	test   %eax,%eax
  800866:	78 68                	js     8008d0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800868:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800872:	8b 00                	mov    (%eax),%eax
  800874:	89 04 24             	mov    %eax,(%esp)
  800877:	e8 ac fc ff ff       	call   800528 <dev_lookup>
  80087c:	85 c0                	test   %eax,%eax
  80087e:	78 50                	js     8008d0 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800880:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800883:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800887:	75 23                	jne    8008ac <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800889:	a1 08 40 80 00       	mov    0x804008,%eax
  80088e:	8b 40 48             	mov    0x48(%eax),%eax
  800891:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800895:	89 44 24 04          	mov    %eax,0x4(%esp)
  800899:	c7 04 24 39 25 80 00 	movl   $0x802539,(%esp)
  8008a0:	e8 4b 0f 00 00       	call   8017f0 <cprintf>
		return -E_INVAL;
  8008a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008aa:	eb 24                	jmp    8008d0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8008ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008af:	8b 52 0c             	mov    0xc(%edx),%edx
  8008b2:	85 d2                	test   %edx,%edx
  8008b4:	74 15                	je     8008cb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8008b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008c4:	89 04 24             	mov    %eax,(%esp)
  8008c7:	ff d2                	call   *%edx
  8008c9:	eb 05                	jmp    8008d0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8008cb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8008d0:	83 c4 24             	add    $0x24,%esp
  8008d3:	5b                   	pop    %ebx
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008dc:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8008df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	89 04 24             	mov    %eax,(%esp)
  8008e9:	e8 e4 fb ff ff       	call   8004d2 <fd_lookup>
  8008ee:	85 c0                	test   %eax,%eax
  8008f0:	78 0e                	js     800900 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	53                   	push   %ebx
  800906:	83 ec 24             	sub    $0x24,%esp
  800909:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80090c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80090f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800913:	89 1c 24             	mov    %ebx,(%esp)
  800916:	e8 b7 fb ff ff       	call   8004d2 <fd_lookup>
  80091b:	85 c0                	test   %eax,%eax
  80091d:	78 61                	js     800980 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80091f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800922:	89 44 24 04          	mov    %eax,0x4(%esp)
  800926:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800929:	8b 00                	mov    (%eax),%eax
  80092b:	89 04 24             	mov    %eax,(%esp)
  80092e:	e8 f5 fb ff ff       	call   800528 <dev_lookup>
  800933:	85 c0                	test   %eax,%eax
  800935:	78 49                	js     800980 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800937:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80093a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80093e:	75 23                	jne    800963 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800940:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800945:	8b 40 48             	mov    0x48(%eax),%eax
  800948:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80094c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800950:	c7 04 24 fc 24 80 00 	movl   $0x8024fc,(%esp)
  800957:	e8 94 0e 00 00       	call   8017f0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80095c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800961:	eb 1d                	jmp    800980 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800963:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800966:	8b 52 18             	mov    0x18(%edx),%edx
  800969:	85 d2                	test   %edx,%edx
  80096b:	74 0e                	je     80097b <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80096d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800970:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800974:	89 04 24             	mov    %eax,(%esp)
  800977:	ff d2                	call   *%edx
  800979:	eb 05                	jmp    800980 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80097b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800980:	83 c4 24             	add    $0x24,%esp
  800983:	5b                   	pop    %ebx
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	53                   	push   %ebx
  80098a:	83 ec 24             	sub    $0x24,%esp
  80098d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800990:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800993:	89 44 24 04          	mov    %eax,0x4(%esp)
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	89 04 24             	mov    %eax,(%esp)
  80099d:	e8 30 fb ff ff       	call   8004d2 <fd_lookup>
  8009a2:	85 c0                	test   %eax,%eax
  8009a4:	78 52                	js     8009f8 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b0:	8b 00                	mov    (%eax),%eax
  8009b2:	89 04 24             	mov    %eax,(%esp)
  8009b5:	e8 6e fb ff ff       	call   800528 <dev_lookup>
  8009ba:	85 c0                	test   %eax,%eax
  8009bc:	78 3a                	js     8009f8 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8009be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8009c5:	74 2c                	je     8009f3 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8009c7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8009ca:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8009d1:	00 00 00 
	stat->st_isdir = 0;
  8009d4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8009db:	00 00 00 
	stat->st_dev = dev;
  8009de:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009eb:	89 14 24             	mov    %edx,(%esp)
  8009ee:	ff 50 14             	call   *0x14(%eax)
  8009f1:	eb 05                	jmp    8009f8 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8009f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8009f8:	83 c4 24             	add    $0x24,%esp
  8009fb:	5b                   	pop    %ebx
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800a06:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a0d:	00 
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	89 04 24             	mov    %eax,(%esp)
  800a14:	e8 2a 02 00 00       	call   800c43 <open>
  800a19:	89 c3                	mov    %eax,%ebx
  800a1b:	85 c0                	test   %eax,%eax
  800a1d:	78 1b                	js     800a3a <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a26:	89 1c 24             	mov    %ebx,(%esp)
  800a29:	e8 58 ff ff ff       	call   800986 <fstat>
  800a2e:	89 c6                	mov    %eax,%esi
	close(fd);
  800a30:	89 1c 24             	mov    %ebx,(%esp)
  800a33:	e8 d2 fb ff ff       	call   80060a <close>
	return r;
  800a38:	89 f3                	mov    %esi,%ebx
}
  800a3a:	89 d8                	mov    %ebx,%eax
  800a3c:	83 c4 10             	add    $0x10,%esp
  800a3f:	5b                   	pop    %ebx
  800a40:	5e                   	pop    %esi
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    
	...

00800a44 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	56                   	push   %esi
  800a48:	53                   	push   %ebx
  800a49:	83 ec 10             	sub    $0x10,%esp
  800a4c:	89 c3                	mov    %eax,%ebx
  800a4e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a50:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a57:	75 11                	jne    800a6a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a59:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a60:	e8 4e 17 00 00       	call   8021b3 <ipc_find_env>
  800a65:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a6a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a71:	00 
  800a72:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a79:	00 
  800a7a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a7e:	a1 00 40 80 00       	mov    0x804000,%eax
  800a83:	89 04 24             	mov    %eax,(%esp)
  800a86:	e8 a5 16 00 00       	call   802130 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a8b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a92:	00 
  800a93:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a9e:	e8 1d 16 00 00       	call   8020c0 <ipc_recv>
}
  800aa3:	83 c4 10             	add    $0x10,%esp
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800abb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abe:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800ac3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac8:	b8 02 00 00 00       	mov    $0x2,%eax
  800acd:	e8 72 ff ff ff       	call   800a44 <fsipc>
}
  800ad2:	c9                   	leave  
  800ad3:	c3                   	ret    

00800ad4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ada:	8b 45 08             	mov    0x8(%ebp),%eax
  800add:	8b 40 0c             	mov    0xc(%eax),%eax
  800ae0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ae5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aea:	b8 06 00 00 00       	mov    $0x6,%eax
  800aef:	e8 50 ff ff ff       	call   800a44 <fsipc>
}
  800af4:	c9                   	leave  
  800af5:	c3                   	ret    

00800af6 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	53                   	push   %ebx
  800afa:	83 ec 14             	sub    $0x14,%esp
  800afd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800b00:	8b 45 08             	mov    0x8(%ebp),%eax
  800b03:	8b 40 0c             	mov    0xc(%eax),%eax
  800b06:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800b0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b10:	b8 05 00 00 00       	mov    $0x5,%eax
  800b15:	e8 2a ff ff ff       	call   800a44 <fsipc>
  800b1a:	85 c0                	test   %eax,%eax
  800b1c:	78 2b                	js     800b49 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800b1e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b25:	00 
  800b26:	89 1c 24             	mov    %ebx,(%esp)
  800b29:	e8 6d 12 00 00       	call   801d9b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b2e:	a1 80 50 80 00       	mov    0x805080,%eax
  800b33:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b39:	a1 84 50 80 00       	mov    0x805084,%eax
  800b3e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800b44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b49:	83 c4 14             	add    $0x14,%esp
  800b4c:	5b                   	pop    %ebx
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	83 ec 18             	sub    $0x18,%esp
  800b55:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800b58:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5b:	8b 52 0c             	mov    0xc(%edx),%edx
  800b5e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800b64:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  800b69:	89 c2                	mov    %eax,%edx
  800b6b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800b70:	76 05                	jbe    800b77 <devfile_write+0x28>
  800b72:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  800b77:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b82:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b89:	e8 f0 13 00 00       	call   801f7e <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800b8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b93:	b8 04 00 00 00       	mov    $0x4,%eax
  800b98:	e8 a7 fe ff ff       	call   800a44 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    

00800b9f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 10             	sub    $0x10,%esp
  800ba7:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800baa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bad:	8b 40 0c             	mov    0xc(%eax),%eax
  800bb0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800bb5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800bbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc0:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc5:	e8 7a fe ff ff       	call   800a44 <fsipc>
  800bca:	89 c3                	mov    %eax,%ebx
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	78 6a                	js     800c3a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800bd0:	39 c6                	cmp    %eax,%esi
  800bd2:	73 24                	jae    800bf8 <devfile_read+0x59>
  800bd4:	c7 44 24 0c 6c 25 80 	movl   $0x80256c,0xc(%esp)
  800bdb:	00 
  800bdc:	c7 44 24 08 73 25 80 	movl   $0x802573,0x8(%esp)
  800be3:	00 
  800be4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800beb:	00 
  800bec:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  800bf3:	e8 00 0b 00 00       	call   8016f8 <_panic>
	assert(r <= PGSIZE);
  800bf8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800bfd:	7e 24                	jle    800c23 <devfile_read+0x84>
  800bff:	c7 44 24 0c 93 25 80 	movl   $0x802593,0xc(%esp)
  800c06:	00 
  800c07:	c7 44 24 08 73 25 80 	movl   $0x802573,0x8(%esp)
  800c0e:	00 
  800c0f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800c16:	00 
  800c17:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  800c1e:	e8 d5 0a 00 00       	call   8016f8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c23:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c27:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c2e:	00 
  800c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c32:	89 04 24             	mov    %eax,(%esp)
  800c35:	e8 da 12 00 00       	call   801f14 <memmove>
	return r;
}
  800c3a:	89 d8                	mov    %ebx,%eax
  800c3c:	83 c4 10             	add    $0x10,%esp
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	83 ec 20             	sub    $0x20,%esp
  800c4b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c4e:	89 34 24             	mov    %esi,(%esp)
  800c51:	e8 12 11 00 00       	call   801d68 <strlen>
  800c56:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c5b:	7f 60                	jg     800cbd <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c60:	89 04 24             	mov    %eax,(%esp)
  800c63:	e8 17 f8 ff ff       	call   80047f <fd_alloc>
  800c68:	89 c3                	mov    %eax,%ebx
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	78 54                	js     800cc2 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800c6e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c72:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c79:	e8 1d 11 00 00       	call   801d9b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c81:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c86:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c89:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8e:	e8 b1 fd ff ff       	call   800a44 <fsipc>
  800c93:	89 c3                	mov    %eax,%ebx
  800c95:	85 c0                	test   %eax,%eax
  800c97:	79 15                	jns    800cae <open+0x6b>
		fd_close(fd, 0);
  800c99:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ca0:	00 
  800ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca4:	89 04 24             	mov    %eax,(%esp)
  800ca7:	e8 d6 f8 ff ff       	call   800582 <fd_close>
		return r;
  800cac:	eb 14                	jmp    800cc2 <open+0x7f>
	}

	return fd2num(fd);
  800cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb1:	89 04 24             	mov    %eax,(%esp)
  800cb4:	e8 9b f7 ff ff       	call   800454 <fd2num>
  800cb9:	89 c3                	mov    %eax,%ebx
  800cbb:	eb 05                	jmp    800cc2 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cbd:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800cc2:	89 d8                	mov    %ebx,%eax
  800cc4:	83 c4 20             	add    $0x20,%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800cd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd6:	b8 08 00 00 00       	mov    $0x8,%eax
  800cdb:	e8 64 fd ff ff       	call   800a44 <fsipc>
}
  800ce0:	c9                   	leave  
  800ce1:	c3                   	ret    
	...

00800ce4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800cea:	c7 44 24 04 9f 25 80 	movl   $0x80259f,0x4(%esp)
  800cf1:	00 
  800cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf5:	89 04 24             	mov    %eax,(%esp)
  800cf8:	e8 9e 10 00 00       	call   801d9b <strcpy>
	return 0;
}
  800cfd:	b8 00 00 00 00       	mov    $0x0,%eax
  800d02:	c9                   	leave  
  800d03:	c3                   	ret    

00800d04 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	53                   	push   %ebx
  800d08:	83 ec 14             	sub    $0x14,%esp
  800d0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800d0e:	89 1c 24             	mov    %ebx,(%esp)
  800d11:	e8 e2 14 00 00       	call   8021f8 <pageref>
  800d16:	83 f8 01             	cmp    $0x1,%eax
  800d19:	75 0d                	jne    800d28 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  800d1b:	8b 43 0c             	mov    0xc(%ebx),%eax
  800d1e:	89 04 24             	mov    %eax,(%esp)
  800d21:	e8 1f 03 00 00       	call   801045 <nsipc_close>
  800d26:	eb 05                	jmp    800d2d <devsock_close+0x29>
	else
		return 0;
  800d28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d2d:	83 c4 14             	add    $0x14,%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    

00800d33 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800d39:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d40:	00 
  800d41:	8b 45 10             	mov    0x10(%ebp),%eax
  800d44:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d52:	8b 40 0c             	mov    0xc(%eax),%eax
  800d55:	89 04 24             	mov    %eax,(%esp)
  800d58:	e8 e3 03 00 00       	call   801140 <nsipc_send>
}
  800d5d:	c9                   	leave  
  800d5e:	c3                   	ret    

00800d5f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800d65:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d6c:	00 
  800d6d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d70:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7e:	8b 40 0c             	mov    0xc(%eax),%eax
  800d81:	89 04 24             	mov    %eax,(%esp)
  800d84:	e8 37 03 00 00       	call   8010c0 <nsipc_recv>
}
  800d89:	c9                   	leave  
  800d8a:	c3                   	ret    

00800d8b <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 20             	sub    $0x20,%esp
  800d93:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800d95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d98:	89 04 24             	mov    %eax,(%esp)
  800d9b:	e8 df f6 ff ff       	call   80047f <fd_alloc>
  800da0:	89 c3                	mov    %eax,%ebx
  800da2:	85 c0                	test   %eax,%eax
  800da4:	78 21                	js     800dc7 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800da6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800dad:	00 
  800dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800db1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800dbc:	e8 c8 f3 ff ff       	call   800189 <sys_page_alloc>
  800dc1:	89 c3                	mov    %eax,%ebx
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	79 0a                	jns    800dd1 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  800dc7:	89 34 24             	mov    %esi,(%esp)
  800dca:	e8 76 02 00 00       	call   801045 <nsipc_close>
		return r;
  800dcf:	eb 22                	jmp    800df3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800dd1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dda:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ddf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800de6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800de9:	89 04 24             	mov    %eax,(%esp)
  800dec:	e8 63 f6 ff ff       	call   800454 <fd2num>
  800df1:	89 c3                	mov    %eax,%ebx
}
  800df3:	89 d8                	mov    %ebx,%eax
  800df5:	83 c4 20             	add    $0x20,%esp
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800e02:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800e05:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e09:	89 04 24             	mov    %eax,(%esp)
  800e0c:	e8 c1 f6 ff ff       	call   8004d2 <fd_lookup>
  800e11:	85 c0                	test   %eax,%eax
  800e13:	78 17                	js     800e2c <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1e:	39 10                	cmp    %edx,(%eax)
  800e20:	75 05                	jne    800e27 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800e22:	8b 40 0c             	mov    0xc(%eax),%eax
  800e25:	eb 05                	jmp    800e2c <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800e27:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800e2c:	c9                   	leave  
  800e2d:	c3                   	ret    

00800e2e <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
  800e37:	e8 c0 ff ff ff       	call   800dfc <fd2sockid>
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	78 1f                	js     800e5f <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800e40:	8b 55 10             	mov    0x10(%ebp),%edx
  800e43:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e4a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e4e:	89 04 24             	mov    %eax,(%esp)
  800e51:	e8 38 01 00 00       	call   800f8e <nsipc_accept>
  800e56:	85 c0                	test   %eax,%eax
  800e58:	78 05                	js     800e5f <accept+0x31>
		return r;
	return alloc_sockfd(r);
  800e5a:	e8 2c ff ff ff       	call   800d8b <alloc_sockfd>
}
  800e5f:	c9                   	leave  
  800e60:	c3                   	ret    

00800e61 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e67:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6a:	e8 8d ff ff ff       	call   800dfc <fd2sockid>
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	78 16                	js     800e89 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  800e73:	8b 55 10             	mov    0x10(%ebp),%edx
  800e76:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e81:	89 04 24             	mov    %eax,(%esp)
  800e84:	e8 5b 01 00 00       	call   800fe4 <nsipc_bind>
}
  800e89:	c9                   	leave  
  800e8a:	c3                   	ret    

00800e8b <shutdown>:

int
shutdown(int s, int how)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e91:	8b 45 08             	mov    0x8(%ebp),%eax
  800e94:	e8 63 ff ff ff       	call   800dfc <fd2sockid>
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	78 0f                	js     800eac <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800e9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ea4:	89 04 24             	mov    %eax,(%esp)
  800ea7:	e8 77 01 00 00       	call   801023 <nsipc_shutdown>
}
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    

00800eae <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb7:	e8 40 ff ff ff       	call   800dfc <fd2sockid>
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	78 16                	js     800ed6 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  800ec0:	8b 55 10             	mov    0x10(%ebp),%edx
  800ec3:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ec7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eca:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ece:	89 04 24             	mov    %eax,(%esp)
  800ed1:	e8 89 01 00 00       	call   80105f <nsipc_connect>
}
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    

00800ed8 <listen>:

int
listen(int s, int backlog)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ede:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee1:	e8 16 ff ff ff       	call   800dfc <fd2sockid>
  800ee6:	85 c0                	test   %eax,%eax
  800ee8:	78 0f                	js     800ef9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800eea:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eed:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ef1:	89 04 24             	mov    %eax,(%esp)
  800ef4:	e8 a5 01 00 00       	call   80109e <nsipc_listen>
}
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800f01:	8b 45 10             	mov    0x10(%ebp),%eax
  800f04:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f12:	89 04 24             	mov    %eax,(%esp)
  800f15:	e8 99 02 00 00       	call   8011b3 <nsipc_socket>
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	78 05                	js     800f23 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  800f1e:	e8 68 fe ff ff       	call   800d8b <alloc_sockfd>
}
  800f23:	c9                   	leave  
  800f24:	c3                   	ret    
  800f25:	00 00                	add    %al,(%eax)
	...

00800f28 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	53                   	push   %ebx
  800f2c:	83 ec 14             	sub    $0x14,%esp
  800f2f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800f31:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800f38:	75 11                	jne    800f4b <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800f3a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f41:	e8 6d 12 00 00       	call   8021b3 <ipc_find_env>
  800f46:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800f4b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800f52:	00 
  800f53:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  800f5a:	00 
  800f5b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f5f:	a1 04 40 80 00       	mov    0x804004,%eax
  800f64:	89 04 24             	mov    %eax,(%esp)
  800f67:	e8 c4 11 00 00       	call   802130 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800f6c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f73:	00 
  800f74:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f7b:	00 
  800f7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f83:	e8 38 11 00 00       	call   8020c0 <ipc_recv>
}
  800f88:	83 c4 14             	add    $0x14,%esp
  800f8b:	5b                   	pop    %ebx
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	56                   	push   %esi
  800f92:	53                   	push   %ebx
  800f93:	83 ec 10             	sub    $0x10,%esp
  800f96:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800f99:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800fa1:	8b 06                	mov    (%esi),%eax
  800fa3:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800fa8:	b8 01 00 00 00       	mov    $0x1,%eax
  800fad:	e8 76 ff ff ff       	call   800f28 <nsipc>
  800fb2:	89 c3                	mov    %eax,%ebx
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	78 23                	js     800fdb <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800fb8:	a1 10 60 80 00       	mov    0x806010,%eax
  800fbd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc1:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  800fc8:	00 
  800fc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fcc:	89 04 24             	mov    %eax,(%esp)
  800fcf:	e8 40 0f 00 00       	call   801f14 <memmove>
		*addrlen = ret->ret_addrlen;
  800fd4:	a1 10 60 80 00       	mov    0x806010,%eax
  800fd9:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  800fdb:	89 d8                	mov    %ebx,%eax
  800fdd:	83 c4 10             	add    $0x10,%esp
  800fe0:	5b                   	pop    %ebx
  800fe1:	5e                   	pop    %esi
  800fe2:	5d                   	pop    %ebp
  800fe3:	c3                   	ret    

00800fe4 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 14             	sub    $0x14,%esp
  800feb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800fee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ff6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801001:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801008:	e8 07 0f 00 00       	call   801f14 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80100d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801013:	b8 02 00 00 00       	mov    $0x2,%eax
  801018:	e8 0b ff ff ff       	call   800f28 <nsipc>
}
  80101d:	83 c4 14             	add    $0x14,%esp
  801020:	5b                   	pop    %ebx
  801021:	5d                   	pop    %ebp
  801022:	c3                   	ret    

00801023 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801029:	8b 45 08             	mov    0x8(%ebp),%eax
  80102c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801031:	8b 45 0c             	mov    0xc(%ebp),%eax
  801034:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801039:	b8 03 00 00 00       	mov    $0x3,%eax
  80103e:	e8 e5 fe ff ff       	call   800f28 <nsipc>
}
  801043:	c9                   	leave  
  801044:	c3                   	ret    

00801045 <nsipc_close>:

int
nsipc_close(int s)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80104b:	8b 45 08             	mov    0x8(%ebp),%eax
  80104e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801053:	b8 04 00 00 00       	mov    $0x4,%eax
  801058:	e8 cb fe ff ff       	call   800f28 <nsipc>
}
  80105d:	c9                   	leave  
  80105e:	c3                   	ret    

0080105f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	53                   	push   %ebx
  801063:	83 ec 14             	sub    $0x14,%esp
  801066:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801069:	8b 45 08             	mov    0x8(%ebp),%eax
  80106c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801071:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801075:	8b 45 0c             	mov    0xc(%ebp),%eax
  801078:	89 44 24 04          	mov    %eax,0x4(%esp)
  80107c:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801083:	e8 8c 0e 00 00       	call   801f14 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801088:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80108e:	b8 05 00 00 00       	mov    $0x5,%eax
  801093:	e8 90 fe ff ff       	call   800f28 <nsipc>
}
  801098:	83 c4 14             	add    $0x14,%esp
  80109b:	5b                   	pop    %ebx
  80109c:	5d                   	pop    %ebp
  80109d:	c3                   	ret    

0080109e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8010a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8010ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010af:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8010b4:	b8 06 00 00 00       	mov    $0x6,%eax
  8010b9:	e8 6a fe ff ff       	call   800f28 <nsipc>
}
  8010be:	c9                   	leave  
  8010bf:	c3                   	ret    

008010c0 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	56                   	push   %esi
  8010c4:	53                   	push   %ebx
  8010c5:	83 ec 10             	sub    $0x10,%esp
  8010c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8010cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ce:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8010d3:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8010d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8010dc:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8010e1:	b8 07 00 00 00       	mov    $0x7,%eax
  8010e6:	e8 3d fe ff ff       	call   800f28 <nsipc>
  8010eb:	89 c3                	mov    %eax,%ebx
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	78 46                	js     801137 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8010f1:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8010f6:	7f 04                	jg     8010fc <nsipc_recv+0x3c>
  8010f8:	39 c6                	cmp    %eax,%esi
  8010fa:	7d 24                	jge    801120 <nsipc_recv+0x60>
  8010fc:	c7 44 24 0c ab 25 80 	movl   $0x8025ab,0xc(%esp)
  801103:	00 
  801104:	c7 44 24 08 73 25 80 	movl   $0x802573,0x8(%esp)
  80110b:	00 
  80110c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801113:	00 
  801114:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  80111b:	e8 d8 05 00 00       	call   8016f8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801120:	89 44 24 08          	mov    %eax,0x8(%esp)
  801124:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80112b:	00 
  80112c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80112f:	89 04 24             	mov    %eax,(%esp)
  801132:	e8 dd 0d 00 00       	call   801f14 <memmove>
	}

	return r;
}
  801137:	89 d8                	mov    %ebx,%eax
  801139:	83 c4 10             	add    $0x10,%esp
  80113c:	5b                   	pop    %ebx
  80113d:	5e                   	pop    %esi
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	53                   	push   %ebx
  801144:	83 ec 14             	sub    $0x14,%esp
  801147:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80114a:	8b 45 08             	mov    0x8(%ebp),%eax
  80114d:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801152:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801158:	7e 24                	jle    80117e <nsipc_send+0x3e>
  80115a:	c7 44 24 0c cc 25 80 	movl   $0x8025cc,0xc(%esp)
  801161:	00 
  801162:	c7 44 24 08 73 25 80 	movl   $0x802573,0x8(%esp)
  801169:	00 
  80116a:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801171:	00 
  801172:	c7 04 24 c0 25 80 00 	movl   $0x8025c0,(%esp)
  801179:	e8 7a 05 00 00       	call   8016f8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80117e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801182:	8b 45 0c             	mov    0xc(%ebp),%eax
  801185:	89 44 24 04          	mov    %eax,0x4(%esp)
  801189:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801190:	e8 7f 0d 00 00       	call   801f14 <memmove>
	nsipcbuf.send.req_size = size;
  801195:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80119b:	8b 45 14             	mov    0x14(%ebp),%eax
  80119e:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8011a3:	b8 08 00 00 00       	mov    $0x8,%eax
  8011a8:	e8 7b fd ff ff       	call   800f28 <nsipc>
}
  8011ad:	83 c4 14             	add    $0x14,%esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5d                   	pop    %ebp
  8011b2:	c3                   	ret    

008011b3 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8011b3:	55                   	push   %ebp
  8011b4:	89 e5                	mov    %esp,%ebp
  8011b6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8011b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8011c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c4:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8011c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8011cc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8011d1:	b8 09 00 00 00       	mov    $0x9,%eax
  8011d6:	e8 4d fd ff ff       	call   800f28 <nsipc>
}
  8011db:	c9                   	leave  
  8011dc:	c3                   	ret    
  8011dd:	00 00                	add    %al,(%eax)
	...

008011e0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	56                   	push   %esi
  8011e4:	53                   	push   %ebx
  8011e5:	83 ec 10             	sub    $0x10,%esp
  8011e8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8011eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ee:	89 04 24             	mov    %eax,(%esp)
  8011f1:	e8 6e f2 ff ff       	call   800464 <fd2data>
  8011f6:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8011f8:	c7 44 24 04 d8 25 80 	movl   $0x8025d8,0x4(%esp)
  8011ff:	00 
  801200:	89 34 24             	mov    %esi,(%esp)
  801203:	e8 93 0b 00 00       	call   801d9b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801208:	8b 43 04             	mov    0x4(%ebx),%eax
  80120b:	2b 03                	sub    (%ebx),%eax
  80120d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801213:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80121a:	00 00 00 
	stat->st_dev = &devpipe;
  80121d:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801224:	30 80 00 
	return 0;
}
  801227:	b8 00 00 00 00       	mov    $0x0,%eax
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	5b                   	pop    %ebx
  801230:	5e                   	pop    %esi
  801231:	5d                   	pop    %ebp
  801232:	c3                   	ret    

00801233 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	53                   	push   %ebx
  801237:	83 ec 14             	sub    $0x14,%esp
  80123a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80123d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801241:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801248:	e8 e3 ef ff ff       	call   800230 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80124d:	89 1c 24             	mov    %ebx,(%esp)
  801250:	e8 0f f2 ff ff       	call   800464 <fd2data>
  801255:	89 44 24 04          	mov    %eax,0x4(%esp)
  801259:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801260:	e8 cb ef ff ff       	call   800230 <sys_page_unmap>
}
  801265:	83 c4 14             	add    $0x14,%esp
  801268:	5b                   	pop    %ebx
  801269:	5d                   	pop    %ebp
  80126a:	c3                   	ret    

0080126b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80126b:	55                   	push   %ebp
  80126c:	89 e5                	mov    %esp,%ebp
  80126e:	57                   	push   %edi
  80126f:	56                   	push   %esi
  801270:	53                   	push   %ebx
  801271:	83 ec 2c             	sub    $0x2c,%esp
  801274:	89 c7                	mov    %eax,%edi
  801276:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801279:	a1 08 40 80 00       	mov    0x804008,%eax
  80127e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801281:	89 3c 24             	mov    %edi,(%esp)
  801284:	e8 6f 0f 00 00       	call   8021f8 <pageref>
  801289:	89 c6                	mov    %eax,%esi
  80128b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80128e:	89 04 24             	mov    %eax,(%esp)
  801291:	e8 62 0f 00 00       	call   8021f8 <pageref>
  801296:	39 c6                	cmp    %eax,%esi
  801298:	0f 94 c0             	sete   %al
  80129b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80129e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8012a4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8012a7:	39 cb                	cmp    %ecx,%ebx
  8012a9:	75 08                	jne    8012b3 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8012ab:	83 c4 2c             	add    $0x2c,%esp
  8012ae:	5b                   	pop    %ebx
  8012af:	5e                   	pop    %esi
  8012b0:	5f                   	pop    %edi
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8012b3:	83 f8 01             	cmp    $0x1,%eax
  8012b6:	75 c1                	jne    801279 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8012b8:	8b 42 58             	mov    0x58(%edx),%eax
  8012bb:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8012c2:	00 
  8012c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012cb:	c7 04 24 df 25 80 00 	movl   $0x8025df,(%esp)
  8012d2:	e8 19 05 00 00       	call   8017f0 <cprintf>
  8012d7:	eb a0                	jmp    801279 <_pipeisclosed+0xe>

008012d9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	57                   	push   %edi
  8012dd:	56                   	push   %esi
  8012de:	53                   	push   %ebx
  8012df:	83 ec 1c             	sub    $0x1c,%esp
  8012e2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8012e5:	89 34 24             	mov    %esi,(%esp)
  8012e8:	e8 77 f1 ff ff       	call   800464 <fd2data>
  8012ed:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8012f4:	eb 3c                	jmp    801332 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8012f6:	89 da                	mov    %ebx,%edx
  8012f8:	89 f0                	mov    %esi,%eax
  8012fa:	e8 6c ff ff ff       	call   80126b <_pipeisclosed>
  8012ff:	85 c0                	test   %eax,%eax
  801301:	75 38                	jne    80133b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801303:	e8 62 ee ff ff       	call   80016a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801308:	8b 43 04             	mov    0x4(%ebx),%eax
  80130b:	8b 13                	mov    (%ebx),%edx
  80130d:	83 c2 20             	add    $0x20,%edx
  801310:	39 d0                	cmp    %edx,%eax
  801312:	73 e2                	jae    8012f6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801314:	8b 55 0c             	mov    0xc(%ebp),%edx
  801317:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80131a:	89 c2                	mov    %eax,%edx
  80131c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801322:	79 05                	jns    801329 <devpipe_write+0x50>
  801324:	4a                   	dec    %edx
  801325:	83 ca e0             	or     $0xffffffe0,%edx
  801328:	42                   	inc    %edx
  801329:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80132d:	40                   	inc    %eax
  80132e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801331:	47                   	inc    %edi
  801332:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801335:	75 d1                	jne    801308 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801337:	89 f8                	mov    %edi,%eax
  801339:	eb 05                	jmp    801340 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80133b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801340:	83 c4 1c             	add    $0x1c,%esp
  801343:	5b                   	pop    %ebx
  801344:	5e                   	pop    %esi
  801345:	5f                   	pop    %edi
  801346:	5d                   	pop    %ebp
  801347:	c3                   	ret    

00801348 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	57                   	push   %edi
  80134c:	56                   	push   %esi
  80134d:	53                   	push   %ebx
  80134e:	83 ec 1c             	sub    $0x1c,%esp
  801351:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801354:	89 3c 24             	mov    %edi,(%esp)
  801357:	e8 08 f1 ff ff       	call   800464 <fd2data>
  80135c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80135e:	be 00 00 00 00       	mov    $0x0,%esi
  801363:	eb 3a                	jmp    80139f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801365:	85 f6                	test   %esi,%esi
  801367:	74 04                	je     80136d <devpipe_read+0x25>
				return i;
  801369:	89 f0                	mov    %esi,%eax
  80136b:	eb 40                	jmp    8013ad <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80136d:	89 da                	mov    %ebx,%edx
  80136f:	89 f8                	mov    %edi,%eax
  801371:	e8 f5 fe ff ff       	call   80126b <_pipeisclosed>
  801376:	85 c0                	test   %eax,%eax
  801378:	75 2e                	jne    8013a8 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80137a:	e8 eb ed ff ff       	call   80016a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80137f:	8b 03                	mov    (%ebx),%eax
  801381:	3b 43 04             	cmp    0x4(%ebx),%eax
  801384:	74 df                	je     801365 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801386:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80138b:	79 05                	jns    801392 <devpipe_read+0x4a>
  80138d:	48                   	dec    %eax
  80138e:	83 c8 e0             	or     $0xffffffe0,%eax
  801391:	40                   	inc    %eax
  801392:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801396:	8b 55 0c             	mov    0xc(%ebp),%edx
  801399:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80139c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80139e:	46                   	inc    %esi
  80139f:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013a2:	75 db                	jne    80137f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8013a4:	89 f0                	mov    %esi,%eax
  8013a6:	eb 05                	jmp    8013ad <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8013a8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8013ad:	83 c4 1c             	add    $0x1c,%esp
  8013b0:	5b                   	pop    %ebx
  8013b1:	5e                   	pop    %esi
  8013b2:	5f                   	pop    %edi
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    

008013b5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	57                   	push   %edi
  8013b9:	56                   	push   %esi
  8013ba:	53                   	push   %ebx
  8013bb:	83 ec 3c             	sub    $0x3c,%esp
  8013be:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8013c1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013c4:	89 04 24             	mov    %eax,(%esp)
  8013c7:	e8 b3 f0 ff ff       	call   80047f <fd_alloc>
  8013cc:	89 c3                	mov    %eax,%ebx
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	0f 88 45 01 00 00    	js     80151b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013d6:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8013dd:	00 
  8013de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013ec:	e8 98 ed ff ff       	call   800189 <sys_page_alloc>
  8013f1:	89 c3                	mov    %eax,%ebx
  8013f3:	85 c0                	test   %eax,%eax
  8013f5:	0f 88 20 01 00 00    	js     80151b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8013fb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013fe:	89 04 24             	mov    %eax,(%esp)
  801401:	e8 79 f0 ff ff       	call   80047f <fd_alloc>
  801406:	89 c3                	mov    %eax,%ebx
  801408:	85 c0                	test   %eax,%eax
  80140a:	0f 88 f8 00 00 00    	js     801508 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801410:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801417:	00 
  801418:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80141b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801426:	e8 5e ed ff ff       	call   800189 <sys_page_alloc>
  80142b:	89 c3                	mov    %eax,%ebx
  80142d:	85 c0                	test   %eax,%eax
  80142f:	0f 88 d3 00 00 00    	js     801508 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801435:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801438:	89 04 24             	mov    %eax,(%esp)
  80143b:	e8 24 f0 ff ff       	call   800464 <fd2data>
  801440:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801442:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801449:	00 
  80144a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801455:	e8 2f ed ff ff       	call   800189 <sys_page_alloc>
  80145a:	89 c3                	mov    %eax,%ebx
  80145c:	85 c0                	test   %eax,%eax
  80145e:	0f 88 91 00 00 00    	js     8014f5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801464:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801467:	89 04 24             	mov    %eax,(%esp)
  80146a:	e8 f5 ef ff ff       	call   800464 <fd2data>
  80146f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801476:	00 
  801477:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80147b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801482:	00 
  801483:	89 74 24 04          	mov    %esi,0x4(%esp)
  801487:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80148e:	e8 4a ed ff ff       	call   8001dd <sys_page_map>
  801493:	89 c3                	mov    %eax,%ebx
  801495:	85 c0                	test   %eax,%eax
  801497:	78 4c                	js     8014e5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801499:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80149f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014a2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8014a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014a7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8014ae:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8014b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014b7:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8014b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014bc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8014c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014c6:	89 04 24             	mov    %eax,(%esp)
  8014c9:	e8 86 ef ff ff       	call   800454 <fd2num>
  8014ce:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8014d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014d3:	89 04 24             	mov    %eax,(%esp)
  8014d6:	e8 79 ef ff ff       	call   800454 <fd2num>
  8014db:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8014de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014e3:	eb 36                	jmp    80151b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8014e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f0:	e8 3b ed ff ff       	call   800230 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8014f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801503:	e8 28 ed ff ff       	call   800230 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801508:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80150b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801516:	e8 15 ed ff ff       	call   800230 <sys_page_unmap>
    err:
	return r;
}
  80151b:	89 d8                	mov    %ebx,%eax
  80151d:	83 c4 3c             	add    $0x3c,%esp
  801520:	5b                   	pop    %ebx
  801521:	5e                   	pop    %esi
  801522:	5f                   	pop    %edi
  801523:	5d                   	pop    %ebp
  801524:	c3                   	ret    

00801525 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80152b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801532:	8b 45 08             	mov    0x8(%ebp),%eax
  801535:	89 04 24             	mov    %eax,(%esp)
  801538:	e8 95 ef ff ff       	call   8004d2 <fd_lookup>
  80153d:	85 c0                	test   %eax,%eax
  80153f:	78 15                	js     801556 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801541:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801544:	89 04 24             	mov    %eax,(%esp)
  801547:	e8 18 ef ff ff       	call   800464 <fd2data>
	return _pipeisclosed(fd, p);
  80154c:	89 c2                	mov    %eax,%edx
  80154e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801551:	e8 15 fd ff ff       	call   80126b <_pipeisclosed>
}
  801556:	c9                   	leave  
  801557:	c3                   	ret    

00801558 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80155b:	b8 00 00 00 00       	mov    $0x0,%eax
  801560:	5d                   	pop    %ebp
  801561:	c3                   	ret    

00801562 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801562:	55                   	push   %ebp
  801563:	89 e5                	mov    %esp,%ebp
  801565:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801568:	c7 44 24 04 f7 25 80 	movl   $0x8025f7,0x4(%esp)
  80156f:	00 
  801570:	8b 45 0c             	mov    0xc(%ebp),%eax
  801573:	89 04 24             	mov    %eax,(%esp)
  801576:	e8 20 08 00 00       	call   801d9b <strcpy>
	return 0;
}
  80157b:	b8 00 00 00 00       	mov    $0x0,%eax
  801580:	c9                   	leave  
  801581:	c3                   	ret    

00801582 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	57                   	push   %edi
  801586:	56                   	push   %esi
  801587:	53                   	push   %ebx
  801588:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80158e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801593:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801599:	eb 30                	jmp    8015cb <devcons_write+0x49>
		m = n - tot;
  80159b:	8b 75 10             	mov    0x10(%ebp),%esi
  80159e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8015a0:	83 fe 7f             	cmp    $0x7f,%esi
  8015a3:	76 05                	jbe    8015aa <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8015a5:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8015aa:	89 74 24 08          	mov    %esi,0x8(%esp)
  8015ae:	03 45 0c             	add    0xc(%ebp),%eax
  8015b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b5:	89 3c 24             	mov    %edi,(%esp)
  8015b8:	e8 57 09 00 00       	call   801f14 <memmove>
		sys_cputs(buf, m);
  8015bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015c1:	89 3c 24             	mov    %edi,(%esp)
  8015c4:	e8 f3 ea ff ff       	call   8000bc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8015c9:	01 f3                	add    %esi,%ebx
  8015cb:	89 d8                	mov    %ebx,%eax
  8015cd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8015d0:	72 c9                	jb     80159b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8015d2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8015d8:	5b                   	pop    %ebx
  8015d9:	5e                   	pop    %esi
  8015da:	5f                   	pop    %edi
  8015db:	5d                   	pop    %ebp
  8015dc:	c3                   	ret    

008015dd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8015e3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8015e7:	75 07                	jne    8015f0 <devcons_read+0x13>
  8015e9:	eb 25                	jmp    801610 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8015eb:	e8 7a eb ff ff       	call   80016a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8015f0:	e8 e5 ea ff ff       	call   8000da <sys_cgetc>
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	74 f2                	je     8015eb <devcons_read+0xe>
  8015f9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	78 1d                	js     80161c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8015ff:	83 f8 04             	cmp    $0x4,%eax
  801602:	74 13                	je     801617 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801604:	8b 45 0c             	mov    0xc(%ebp),%eax
  801607:	88 10                	mov    %dl,(%eax)
	return 1;
  801609:	b8 01 00 00 00       	mov    $0x1,%eax
  80160e:	eb 0c                	jmp    80161c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801610:	b8 00 00 00 00       	mov    $0x0,%eax
  801615:	eb 05                	jmp    80161c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801617:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801624:	8b 45 08             	mov    0x8(%ebp),%eax
  801627:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80162a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801631:	00 
  801632:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801635:	89 04 24             	mov    %eax,(%esp)
  801638:	e8 7f ea ff ff       	call   8000bc <sys_cputs>
}
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <getchar>:

int
getchar(void)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801645:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80164c:	00 
  80164d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801650:	89 44 24 04          	mov    %eax,0x4(%esp)
  801654:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80165b:	e8 10 f1 ff ff       	call   800770 <read>
	if (r < 0)
  801660:	85 c0                	test   %eax,%eax
  801662:	78 0f                	js     801673 <getchar+0x34>
		return r;
	if (r < 1)
  801664:	85 c0                	test   %eax,%eax
  801666:	7e 06                	jle    80166e <getchar+0x2f>
		return -E_EOF;
	return c;
  801668:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80166c:	eb 05                	jmp    801673 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80166e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801673:	c9                   	leave  
  801674:	c3                   	ret    

00801675 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80167b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801682:	8b 45 08             	mov    0x8(%ebp),%eax
  801685:	89 04 24             	mov    %eax,(%esp)
  801688:	e8 45 ee ff ff       	call   8004d2 <fd_lookup>
  80168d:	85 c0                	test   %eax,%eax
  80168f:	78 11                	js     8016a2 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801691:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801694:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80169a:	39 10                	cmp    %edx,(%eax)
  80169c:	0f 94 c0             	sete   %al
  80169f:	0f b6 c0             	movzbl %al,%eax
}
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    

008016a4 <opencons>:

int
opencons(void)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8016aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ad:	89 04 24             	mov    %eax,(%esp)
  8016b0:	e8 ca ed ff ff       	call   80047f <fd_alloc>
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	78 3c                	js     8016f5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8016b9:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8016c0:	00 
  8016c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016cf:	e8 b5 ea ff ff       	call   800189 <sys_page_alloc>
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	78 1d                	js     8016f5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8016d8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8016de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8016e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8016ed:	89 04 24             	mov    %eax,(%esp)
  8016f0:	e8 5f ed ff ff       	call   800454 <fd2num>
}
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    
	...

008016f8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	56                   	push   %esi
  8016fc:	53                   	push   %ebx
  8016fd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801700:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801703:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801709:	e8 3d ea ff ff       	call   80014b <sys_getenvid>
  80170e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801711:	89 54 24 10          	mov    %edx,0x10(%esp)
  801715:	8b 55 08             	mov    0x8(%ebp),%edx
  801718:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80171c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801720:	89 44 24 04          	mov    %eax,0x4(%esp)
  801724:	c7 04 24 04 26 80 00 	movl   $0x802604,(%esp)
  80172b:	e8 c0 00 00 00       	call   8017f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801730:	89 74 24 04          	mov    %esi,0x4(%esp)
  801734:	8b 45 10             	mov    0x10(%ebp),%eax
  801737:	89 04 24             	mov    %eax,(%esp)
  80173a:	e8 50 00 00 00       	call   80178f <vcprintf>
	cprintf("\n");
  80173f:	c7 04 24 f0 25 80 00 	movl   $0x8025f0,(%esp)
  801746:	e8 a5 00 00 00       	call   8017f0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80174b:	cc                   	int3   
  80174c:	eb fd                	jmp    80174b <_panic+0x53>
	...

00801750 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	53                   	push   %ebx
  801754:	83 ec 14             	sub    $0x14,%esp
  801757:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80175a:	8b 03                	mov    (%ebx),%eax
  80175c:	8b 55 08             	mov    0x8(%ebp),%edx
  80175f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801763:	40                   	inc    %eax
  801764:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801766:	3d ff 00 00 00       	cmp    $0xff,%eax
  80176b:	75 19                	jne    801786 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80176d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801774:	00 
  801775:	8d 43 08             	lea    0x8(%ebx),%eax
  801778:	89 04 24             	mov    %eax,(%esp)
  80177b:	e8 3c e9 ff ff       	call   8000bc <sys_cputs>
		b->idx = 0;
  801780:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801786:	ff 43 04             	incl   0x4(%ebx)
}
  801789:	83 c4 14             	add    $0x14,%esp
  80178c:	5b                   	pop    %ebx
  80178d:	5d                   	pop    %ebp
  80178e:	c3                   	ret    

0080178f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801798:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80179f:	00 00 00 
	b.cnt = 0;
  8017a2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8017a9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8017ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8017c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c4:	c7 04 24 50 17 80 00 	movl   $0x801750,(%esp)
  8017cb:	e8 82 01 00 00       	call   801952 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8017d0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8017e0:	89 04 24             	mov    %eax,(%esp)
  8017e3:	e8 d4 e8 ff ff       	call   8000bc <sys_cputs>

	return b.cnt;
}
  8017e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    

008017f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8017f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801800:	89 04 24             	mov    %eax,(%esp)
  801803:	e8 87 ff ff ff       	call   80178f <vcprintf>
	va_end(ap);

	return cnt;
}
  801808:	c9                   	leave  
  801809:	c3                   	ret    
	...

0080180c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	57                   	push   %edi
  801810:	56                   	push   %esi
  801811:	53                   	push   %ebx
  801812:	83 ec 3c             	sub    $0x3c,%esp
  801815:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801818:	89 d7                	mov    %edx,%edi
  80181a:	8b 45 08             	mov    0x8(%ebp),%eax
  80181d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801820:	8b 45 0c             	mov    0xc(%ebp),%eax
  801823:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801826:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801829:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80182c:	85 c0                	test   %eax,%eax
  80182e:	75 08                	jne    801838 <printnum+0x2c>
  801830:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801833:	39 45 10             	cmp    %eax,0x10(%ebp)
  801836:	77 57                	ja     80188f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801838:	89 74 24 10          	mov    %esi,0x10(%esp)
  80183c:	4b                   	dec    %ebx
  80183d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801841:	8b 45 10             	mov    0x10(%ebp),%eax
  801844:	89 44 24 08          	mov    %eax,0x8(%esp)
  801848:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80184c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801850:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801857:	00 
  801858:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80185b:	89 04 24             	mov    %eax,(%esp)
  80185e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801861:	89 44 24 04          	mov    %eax,0x4(%esp)
  801865:	e8 d2 09 00 00       	call   80223c <__udivdi3>
  80186a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80186e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801872:	89 04 24             	mov    %eax,(%esp)
  801875:	89 54 24 04          	mov    %edx,0x4(%esp)
  801879:	89 fa                	mov    %edi,%edx
  80187b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80187e:	e8 89 ff ff ff       	call   80180c <printnum>
  801883:	eb 0f                	jmp    801894 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801885:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801889:	89 34 24             	mov    %esi,(%esp)
  80188c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80188f:	4b                   	dec    %ebx
  801890:	85 db                	test   %ebx,%ebx
  801892:	7f f1                	jg     801885 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801894:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801898:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80189c:	8b 45 10             	mov    0x10(%ebp),%eax
  80189f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8018aa:	00 
  8018ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8018ae:	89 04 24             	mov    %eax,(%esp)
  8018b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b8:	e8 9f 0a 00 00       	call   80235c <__umoddi3>
  8018bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018c1:	0f be 80 27 26 80 00 	movsbl 0x802627(%eax),%eax
  8018c8:	89 04 24             	mov    %eax,(%esp)
  8018cb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8018ce:	83 c4 3c             	add    $0x3c,%esp
  8018d1:	5b                   	pop    %ebx
  8018d2:	5e                   	pop    %esi
  8018d3:	5f                   	pop    %edi
  8018d4:	5d                   	pop    %ebp
  8018d5:	c3                   	ret    

008018d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8018d9:	83 fa 01             	cmp    $0x1,%edx
  8018dc:	7e 0e                	jle    8018ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8018de:	8b 10                	mov    (%eax),%edx
  8018e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8018e3:	89 08                	mov    %ecx,(%eax)
  8018e5:	8b 02                	mov    (%edx),%eax
  8018e7:	8b 52 04             	mov    0x4(%edx),%edx
  8018ea:	eb 22                	jmp    80190e <getuint+0x38>
	else if (lflag)
  8018ec:	85 d2                	test   %edx,%edx
  8018ee:	74 10                	je     801900 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8018f0:	8b 10                	mov    (%eax),%edx
  8018f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8018f5:	89 08                	mov    %ecx,(%eax)
  8018f7:	8b 02                	mov    (%edx),%eax
  8018f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fe:	eb 0e                	jmp    80190e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801900:	8b 10                	mov    (%eax),%edx
  801902:	8d 4a 04             	lea    0x4(%edx),%ecx
  801905:	89 08                	mov    %ecx,(%eax)
  801907:	8b 02                	mov    (%edx),%eax
  801909:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    

00801910 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801916:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801919:	8b 10                	mov    (%eax),%edx
  80191b:	3b 50 04             	cmp    0x4(%eax),%edx
  80191e:	73 08                	jae    801928 <sprintputch+0x18>
		*b->buf++ = ch;
  801920:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801923:	88 0a                	mov    %cl,(%edx)
  801925:	42                   	inc    %edx
  801926:	89 10                	mov    %edx,(%eax)
}
  801928:	5d                   	pop    %ebp
  801929:	c3                   	ret    

0080192a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80192a:	55                   	push   %ebp
  80192b:	89 e5                	mov    %esp,%ebp
  80192d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801930:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801933:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801937:	8b 45 10             	mov    0x10(%ebp),%eax
  80193a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80193e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801941:	89 44 24 04          	mov    %eax,0x4(%esp)
  801945:	8b 45 08             	mov    0x8(%ebp),%eax
  801948:	89 04 24             	mov    %eax,(%esp)
  80194b:	e8 02 00 00 00       	call   801952 <vprintfmt>
	va_end(ap);
}
  801950:	c9                   	leave  
  801951:	c3                   	ret    

00801952 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801952:	55                   	push   %ebp
  801953:	89 e5                	mov    %esp,%ebp
  801955:	57                   	push   %edi
  801956:	56                   	push   %esi
  801957:	53                   	push   %ebx
  801958:	83 ec 4c             	sub    $0x4c,%esp
  80195b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80195e:	8b 75 10             	mov    0x10(%ebp),%esi
  801961:	eb 12                	jmp    801975 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801963:	85 c0                	test   %eax,%eax
  801965:	0f 84 6b 03 00 00    	je     801cd6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80196b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80196f:	89 04 24             	mov    %eax,(%esp)
  801972:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801975:	0f b6 06             	movzbl (%esi),%eax
  801978:	46                   	inc    %esi
  801979:	83 f8 25             	cmp    $0x25,%eax
  80197c:	75 e5                	jne    801963 <vprintfmt+0x11>
  80197e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801982:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801989:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80198e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801995:	b9 00 00 00 00       	mov    $0x0,%ecx
  80199a:	eb 26                	jmp    8019c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80199c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80199f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8019a3:	eb 1d                	jmp    8019c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8019a8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8019ac:	eb 14                	jmp    8019c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8019b1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8019b8:	eb 08                	jmp    8019c2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8019ba:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8019bd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019c2:	0f b6 06             	movzbl (%esi),%eax
  8019c5:	8d 56 01             	lea    0x1(%esi),%edx
  8019c8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8019cb:	8a 16                	mov    (%esi),%dl
  8019cd:	83 ea 23             	sub    $0x23,%edx
  8019d0:	80 fa 55             	cmp    $0x55,%dl
  8019d3:	0f 87 e1 02 00 00    	ja     801cba <vprintfmt+0x368>
  8019d9:	0f b6 d2             	movzbl %dl,%edx
  8019dc:	ff 24 95 60 27 80 00 	jmp    *0x802760(,%edx,4)
  8019e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8019e6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8019eb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8019ee:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8019f2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8019f5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8019f8:	83 fa 09             	cmp    $0x9,%edx
  8019fb:	77 2a                	ja     801a27 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8019fd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8019fe:	eb eb                	jmp    8019eb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801a00:	8b 45 14             	mov    0x14(%ebp),%eax
  801a03:	8d 50 04             	lea    0x4(%eax),%edx
  801a06:	89 55 14             	mov    %edx,0x14(%ebp)
  801a09:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a0b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801a0e:	eb 17                	jmp    801a27 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801a10:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801a14:	78 98                	js     8019ae <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a16:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801a19:	eb a7                	jmp    8019c2 <vprintfmt+0x70>
  801a1b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801a1e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801a25:	eb 9b                	jmp    8019c2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801a27:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801a2b:	79 95                	jns    8019c2 <vprintfmt+0x70>
  801a2d:	eb 8b                	jmp    8019ba <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801a2f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a30:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801a33:	eb 8d                	jmp    8019c2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801a35:	8b 45 14             	mov    0x14(%ebp),%eax
  801a38:	8d 50 04             	lea    0x4(%eax),%edx
  801a3b:	89 55 14             	mov    %edx,0x14(%ebp)
  801a3e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a42:	8b 00                	mov    (%eax),%eax
  801a44:	89 04 24             	mov    %eax,(%esp)
  801a47:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a4a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801a4d:	e9 23 ff ff ff       	jmp    801975 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801a52:	8b 45 14             	mov    0x14(%ebp),%eax
  801a55:	8d 50 04             	lea    0x4(%eax),%edx
  801a58:	89 55 14             	mov    %edx,0x14(%ebp)
  801a5b:	8b 00                	mov    (%eax),%eax
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	79 02                	jns    801a63 <vprintfmt+0x111>
  801a61:	f7 d8                	neg    %eax
  801a63:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801a65:	83 f8 10             	cmp    $0x10,%eax
  801a68:	7f 0b                	jg     801a75 <vprintfmt+0x123>
  801a6a:	8b 04 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%eax
  801a71:	85 c0                	test   %eax,%eax
  801a73:	75 23                	jne    801a98 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801a75:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801a79:	c7 44 24 08 3f 26 80 	movl   $0x80263f,0x8(%esp)
  801a80:	00 
  801a81:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a85:	8b 45 08             	mov    0x8(%ebp),%eax
  801a88:	89 04 24             	mov    %eax,(%esp)
  801a8b:	e8 9a fe ff ff       	call   80192a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a90:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801a93:	e9 dd fe ff ff       	jmp    801975 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801a98:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a9c:	c7 44 24 08 85 25 80 	movl   $0x802585,0x8(%esp)
  801aa3:	00 
  801aa4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aa8:	8b 55 08             	mov    0x8(%ebp),%edx
  801aab:	89 14 24             	mov    %edx,(%esp)
  801aae:	e8 77 fe ff ff       	call   80192a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ab3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801ab6:	e9 ba fe ff ff       	jmp    801975 <vprintfmt+0x23>
  801abb:	89 f9                	mov    %edi,%ecx
  801abd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801ac3:	8b 45 14             	mov    0x14(%ebp),%eax
  801ac6:	8d 50 04             	lea    0x4(%eax),%edx
  801ac9:	89 55 14             	mov    %edx,0x14(%ebp)
  801acc:	8b 30                	mov    (%eax),%esi
  801ace:	85 f6                	test   %esi,%esi
  801ad0:	75 05                	jne    801ad7 <vprintfmt+0x185>
				p = "(null)";
  801ad2:	be 38 26 80 00       	mov    $0x802638,%esi
			if (width > 0 && padc != '-')
  801ad7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801adb:	0f 8e 84 00 00 00    	jle    801b65 <vprintfmt+0x213>
  801ae1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801ae5:	74 7e                	je     801b65 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  801ae7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801aeb:	89 34 24             	mov    %esi,(%esp)
  801aee:	e8 8b 02 00 00       	call   801d7e <strnlen>
  801af3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801af6:	29 c2                	sub    %eax,%edx
  801af8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801afb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801aff:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801b02:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801b05:	89 de                	mov    %ebx,%esi
  801b07:	89 d3                	mov    %edx,%ebx
  801b09:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b0b:	eb 0b                	jmp    801b18 <vprintfmt+0x1c6>
					putch(padc, putdat);
  801b0d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b11:	89 3c 24             	mov    %edi,(%esp)
  801b14:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b17:	4b                   	dec    %ebx
  801b18:	85 db                	test   %ebx,%ebx
  801b1a:	7f f1                	jg     801b0d <vprintfmt+0x1bb>
  801b1c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801b1f:	89 f3                	mov    %esi,%ebx
  801b21:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801b24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b27:	85 c0                	test   %eax,%eax
  801b29:	79 05                	jns    801b30 <vprintfmt+0x1de>
  801b2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b30:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b33:	29 c2                	sub    %eax,%edx
  801b35:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801b38:	eb 2b                	jmp    801b65 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801b3a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b3e:	74 18                	je     801b58 <vprintfmt+0x206>
  801b40:	8d 50 e0             	lea    -0x20(%eax),%edx
  801b43:	83 fa 5e             	cmp    $0x5e,%edx
  801b46:	76 10                	jbe    801b58 <vprintfmt+0x206>
					putch('?', putdat);
  801b48:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b4c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801b53:	ff 55 08             	call   *0x8(%ebp)
  801b56:	eb 0a                	jmp    801b62 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801b58:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b5c:	89 04 24             	mov    %eax,(%esp)
  801b5f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801b62:	ff 4d e4             	decl   -0x1c(%ebp)
  801b65:	0f be 06             	movsbl (%esi),%eax
  801b68:	46                   	inc    %esi
  801b69:	85 c0                	test   %eax,%eax
  801b6b:	74 21                	je     801b8e <vprintfmt+0x23c>
  801b6d:	85 ff                	test   %edi,%edi
  801b6f:	78 c9                	js     801b3a <vprintfmt+0x1e8>
  801b71:	4f                   	dec    %edi
  801b72:	79 c6                	jns    801b3a <vprintfmt+0x1e8>
  801b74:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b77:	89 de                	mov    %ebx,%esi
  801b79:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801b7c:	eb 18                	jmp    801b96 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801b7e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b82:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801b89:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801b8b:	4b                   	dec    %ebx
  801b8c:	eb 08                	jmp    801b96 <vprintfmt+0x244>
  801b8e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b91:	89 de                	mov    %ebx,%esi
  801b93:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801b96:	85 db                	test   %ebx,%ebx
  801b98:	7f e4                	jg     801b7e <vprintfmt+0x22c>
  801b9a:	89 7d 08             	mov    %edi,0x8(%ebp)
  801b9d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b9f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801ba2:	e9 ce fd ff ff       	jmp    801975 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801ba7:	83 f9 01             	cmp    $0x1,%ecx
  801baa:	7e 10                	jle    801bbc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801bac:	8b 45 14             	mov    0x14(%ebp),%eax
  801baf:	8d 50 08             	lea    0x8(%eax),%edx
  801bb2:	89 55 14             	mov    %edx,0x14(%ebp)
  801bb5:	8b 30                	mov    (%eax),%esi
  801bb7:	8b 78 04             	mov    0x4(%eax),%edi
  801bba:	eb 26                	jmp    801be2 <vprintfmt+0x290>
	else if (lflag)
  801bbc:	85 c9                	test   %ecx,%ecx
  801bbe:	74 12                	je     801bd2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  801bc0:	8b 45 14             	mov    0x14(%ebp),%eax
  801bc3:	8d 50 04             	lea    0x4(%eax),%edx
  801bc6:	89 55 14             	mov    %edx,0x14(%ebp)
  801bc9:	8b 30                	mov    (%eax),%esi
  801bcb:	89 f7                	mov    %esi,%edi
  801bcd:	c1 ff 1f             	sar    $0x1f,%edi
  801bd0:	eb 10                	jmp    801be2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801bd2:	8b 45 14             	mov    0x14(%ebp),%eax
  801bd5:	8d 50 04             	lea    0x4(%eax),%edx
  801bd8:	89 55 14             	mov    %edx,0x14(%ebp)
  801bdb:	8b 30                	mov    (%eax),%esi
  801bdd:	89 f7                	mov    %esi,%edi
  801bdf:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801be2:	85 ff                	test   %edi,%edi
  801be4:	78 0a                	js     801bf0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801be6:	b8 0a 00 00 00       	mov    $0xa,%eax
  801beb:	e9 8c 00 00 00       	jmp    801c7c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801bf0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bf4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801bfb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801bfe:	f7 de                	neg    %esi
  801c00:	83 d7 00             	adc    $0x0,%edi
  801c03:	f7 df                	neg    %edi
			}
			base = 10;
  801c05:	b8 0a 00 00 00       	mov    $0xa,%eax
  801c0a:	eb 70                	jmp    801c7c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801c0c:	89 ca                	mov    %ecx,%edx
  801c0e:	8d 45 14             	lea    0x14(%ebp),%eax
  801c11:	e8 c0 fc ff ff       	call   8018d6 <getuint>
  801c16:	89 c6                	mov    %eax,%esi
  801c18:	89 d7                	mov    %edx,%edi
			base = 10;
  801c1a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801c1f:	eb 5b                	jmp    801c7c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  801c21:	89 ca                	mov    %ecx,%edx
  801c23:	8d 45 14             	lea    0x14(%ebp),%eax
  801c26:	e8 ab fc ff ff       	call   8018d6 <getuint>
  801c2b:	89 c6                	mov    %eax,%esi
  801c2d:	89 d7                	mov    %edx,%edi
			base = 8;
  801c2f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801c34:	eb 46                	jmp    801c7c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  801c36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c3a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801c41:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801c44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c48:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801c4f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801c52:	8b 45 14             	mov    0x14(%ebp),%eax
  801c55:	8d 50 04             	lea    0x4(%eax),%edx
  801c58:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801c5b:	8b 30                	mov    (%eax),%esi
  801c5d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801c62:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801c67:	eb 13                	jmp    801c7c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801c69:	89 ca                	mov    %ecx,%edx
  801c6b:	8d 45 14             	lea    0x14(%ebp),%eax
  801c6e:	e8 63 fc ff ff       	call   8018d6 <getuint>
  801c73:	89 c6                	mov    %eax,%esi
  801c75:	89 d7                	mov    %edx,%edi
			base = 16;
  801c77:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801c7c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801c80:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c84:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c87:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c8f:	89 34 24             	mov    %esi,(%esp)
  801c92:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c96:	89 da                	mov    %ebx,%edx
  801c98:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9b:	e8 6c fb ff ff       	call   80180c <printnum>
			break;
  801ca0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801ca3:	e9 cd fc ff ff       	jmp    801975 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801ca8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cac:	89 04 24             	mov    %eax,(%esp)
  801caf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cb2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801cb5:	e9 bb fc ff ff       	jmp    801975 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801cba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cbe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801cc5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801cc8:	eb 01                	jmp    801ccb <vprintfmt+0x379>
  801cca:	4e                   	dec    %esi
  801ccb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801ccf:	75 f9                	jne    801cca <vprintfmt+0x378>
  801cd1:	e9 9f fc ff ff       	jmp    801975 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801cd6:	83 c4 4c             	add    $0x4c,%esp
  801cd9:	5b                   	pop    %ebx
  801cda:	5e                   	pop    %esi
  801cdb:	5f                   	pop    %edi
  801cdc:	5d                   	pop    %ebp
  801cdd:	c3                   	ret    

00801cde <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	83 ec 28             	sub    $0x28,%esp
  801ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801cea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ced:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801cf1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801cf4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801cfb:	85 c0                	test   %eax,%eax
  801cfd:	74 30                	je     801d2f <vsnprintf+0x51>
  801cff:	85 d2                	test   %edx,%edx
  801d01:	7e 33                	jle    801d36 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801d03:	8b 45 14             	mov    0x14(%ebp),%eax
  801d06:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d0a:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d11:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801d14:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d18:	c7 04 24 10 19 80 00 	movl   $0x801910,(%esp)
  801d1f:	e8 2e fc ff ff       	call   801952 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801d24:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d27:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2d:	eb 0c                	jmp    801d3b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801d2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d34:	eb 05                	jmp    801d3b <vsnprintf+0x5d>
  801d36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801d3b:	c9                   	leave  
  801d3c:	c3                   	ret    

00801d3d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801d3d:	55                   	push   %ebp
  801d3e:	89 e5                	mov    %esp,%ebp
  801d40:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801d43:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801d46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d4a:	8b 45 10             	mov    0x10(%ebp),%eax
  801d4d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d51:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d58:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5b:	89 04 24             	mov    %eax,(%esp)
  801d5e:	e8 7b ff ff ff       	call   801cde <vsnprintf>
	va_end(ap);

	return rc;
}
  801d63:	c9                   	leave  
  801d64:	c3                   	ret    
  801d65:	00 00                	add    %al,(%eax)
	...

00801d68 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801d6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801d73:	eb 01                	jmp    801d76 <strlen+0xe>
		n++;
  801d75:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801d76:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801d7a:	75 f9                	jne    801d75 <strlen+0xd>
		n++;
	return n;
}
  801d7c:	5d                   	pop    %ebp
  801d7d:	c3                   	ret    

00801d7e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801d7e:	55                   	push   %ebp
  801d7f:	89 e5                	mov    %esp,%ebp
  801d81:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801d84:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801d87:	b8 00 00 00 00       	mov    $0x0,%eax
  801d8c:	eb 01                	jmp    801d8f <strnlen+0x11>
		n++;
  801d8e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801d8f:	39 d0                	cmp    %edx,%eax
  801d91:	74 06                	je     801d99 <strnlen+0x1b>
  801d93:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801d97:	75 f5                	jne    801d8e <strnlen+0x10>
		n++;
	return n;
}
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    

00801d9b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	53                   	push   %ebx
  801d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801da2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801da5:	ba 00 00 00 00       	mov    $0x0,%edx
  801daa:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801dad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801db0:	42                   	inc    %edx
  801db1:	84 c9                	test   %cl,%cl
  801db3:	75 f5                	jne    801daa <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801db5:	5b                   	pop    %ebx
  801db6:	5d                   	pop    %ebp
  801db7:	c3                   	ret    

00801db8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	53                   	push   %ebx
  801dbc:	83 ec 08             	sub    $0x8,%esp
  801dbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801dc2:	89 1c 24             	mov    %ebx,(%esp)
  801dc5:	e8 9e ff ff ff       	call   801d68 <strlen>
	strcpy(dst + len, src);
  801dca:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dcd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dd1:	01 d8                	add    %ebx,%eax
  801dd3:	89 04 24             	mov    %eax,(%esp)
  801dd6:	e8 c0 ff ff ff       	call   801d9b <strcpy>
	return dst;
}
  801ddb:	89 d8                	mov    %ebx,%eax
  801ddd:	83 c4 08             	add    $0x8,%esp
  801de0:	5b                   	pop    %ebx
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    

00801de3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	56                   	push   %esi
  801de7:	53                   	push   %ebx
  801de8:	8b 45 08             	mov    0x8(%ebp),%eax
  801deb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dee:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801df1:	b9 00 00 00 00       	mov    $0x0,%ecx
  801df6:	eb 0c                	jmp    801e04 <strncpy+0x21>
		*dst++ = *src;
  801df8:	8a 1a                	mov    (%edx),%bl
  801dfa:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801dfd:	80 3a 01             	cmpb   $0x1,(%edx)
  801e00:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801e03:	41                   	inc    %ecx
  801e04:	39 f1                	cmp    %esi,%ecx
  801e06:	75 f0                	jne    801df8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801e08:	5b                   	pop    %ebx
  801e09:	5e                   	pop    %esi
  801e0a:	5d                   	pop    %ebp
  801e0b:	c3                   	ret    

00801e0c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	56                   	push   %esi
  801e10:	53                   	push   %ebx
  801e11:	8b 75 08             	mov    0x8(%ebp),%esi
  801e14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e17:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e1a:	85 d2                	test   %edx,%edx
  801e1c:	75 0a                	jne    801e28 <strlcpy+0x1c>
  801e1e:	89 f0                	mov    %esi,%eax
  801e20:	eb 1a                	jmp    801e3c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801e22:	88 18                	mov    %bl,(%eax)
  801e24:	40                   	inc    %eax
  801e25:	41                   	inc    %ecx
  801e26:	eb 02                	jmp    801e2a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e28:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801e2a:	4a                   	dec    %edx
  801e2b:	74 0a                	je     801e37 <strlcpy+0x2b>
  801e2d:	8a 19                	mov    (%ecx),%bl
  801e2f:	84 db                	test   %bl,%bl
  801e31:	75 ef                	jne    801e22 <strlcpy+0x16>
  801e33:	89 c2                	mov    %eax,%edx
  801e35:	eb 02                	jmp    801e39 <strlcpy+0x2d>
  801e37:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801e39:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801e3c:	29 f0                	sub    %esi,%eax
}
  801e3e:	5b                   	pop    %ebx
  801e3f:	5e                   	pop    %esi
  801e40:	5d                   	pop    %ebp
  801e41:	c3                   	ret    

00801e42 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e48:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801e4b:	eb 02                	jmp    801e4f <strcmp+0xd>
		p++, q++;
  801e4d:	41                   	inc    %ecx
  801e4e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801e4f:	8a 01                	mov    (%ecx),%al
  801e51:	84 c0                	test   %al,%al
  801e53:	74 04                	je     801e59 <strcmp+0x17>
  801e55:	3a 02                	cmp    (%edx),%al
  801e57:	74 f4                	je     801e4d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801e59:	0f b6 c0             	movzbl %al,%eax
  801e5c:	0f b6 12             	movzbl (%edx),%edx
  801e5f:	29 d0                	sub    %edx,%eax
}
  801e61:	5d                   	pop    %ebp
  801e62:	c3                   	ret    

00801e63 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801e63:	55                   	push   %ebp
  801e64:	89 e5                	mov    %esp,%ebp
  801e66:	53                   	push   %ebx
  801e67:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e6d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801e70:	eb 03                	jmp    801e75 <strncmp+0x12>
		n--, p++, q++;
  801e72:	4a                   	dec    %edx
  801e73:	40                   	inc    %eax
  801e74:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801e75:	85 d2                	test   %edx,%edx
  801e77:	74 14                	je     801e8d <strncmp+0x2a>
  801e79:	8a 18                	mov    (%eax),%bl
  801e7b:	84 db                	test   %bl,%bl
  801e7d:	74 04                	je     801e83 <strncmp+0x20>
  801e7f:	3a 19                	cmp    (%ecx),%bl
  801e81:	74 ef                	je     801e72 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801e83:	0f b6 00             	movzbl (%eax),%eax
  801e86:	0f b6 11             	movzbl (%ecx),%edx
  801e89:	29 d0                	sub    %edx,%eax
  801e8b:	eb 05                	jmp    801e92 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801e8d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801e92:	5b                   	pop    %ebx
  801e93:	5d                   	pop    %ebp
  801e94:	c3                   	ret    

00801e95 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801e9e:	eb 05                	jmp    801ea5 <strchr+0x10>
		if (*s == c)
  801ea0:	38 ca                	cmp    %cl,%dl
  801ea2:	74 0c                	je     801eb0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ea4:	40                   	inc    %eax
  801ea5:	8a 10                	mov    (%eax),%dl
  801ea7:	84 d2                	test   %dl,%dl
  801ea9:	75 f5                	jne    801ea0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801eab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eb0:	5d                   	pop    %ebp
  801eb1:	c3                   	ret    

00801eb2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801ebb:	eb 05                	jmp    801ec2 <strfind+0x10>
		if (*s == c)
  801ebd:	38 ca                	cmp    %cl,%dl
  801ebf:	74 07                	je     801ec8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801ec1:	40                   	inc    %eax
  801ec2:	8a 10                	mov    (%eax),%dl
  801ec4:	84 d2                	test   %dl,%dl
  801ec6:	75 f5                	jne    801ebd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801ec8:	5d                   	pop    %ebp
  801ec9:	c3                   	ret    

00801eca <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801eca:	55                   	push   %ebp
  801ecb:	89 e5                	mov    %esp,%ebp
  801ecd:	57                   	push   %edi
  801ece:	56                   	push   %esi
  801ecf:	53                   	push   %ebx
  801ed0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ed3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ed6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ed9:	85 c9                	test   %ecx,%ecx
  801edb:	74 30                	je     801f0d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801edd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ee3:	75 25                	jne    801f0a <memset+0x40>
  801ee5:	f6 c1 03             	test   $0x3,%cl
  801ee8:	75 20                	jne    801f0a <memset+0x40>
		c &= 0xFF;
  801eea:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801eed:	89 d3                	mov    %edx,%ebx
  801eef:	c1 e3 08             	shl    $0x8,%ebx
  801ef2:	89 d6                	mov    %edx,%esi
  801ef4:	c1 e6 18             	shl    $0x18,%esi
  801ef7:	89 d0                	mov    %edx,%eax
  801ef9:	c1 e0 10             	shl    $0x10,%eax
  801efc:	09 f0                	or     %esi,%eax
  801efe:	09 d0                	or     %edx,%eax
  801f00:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801f02:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801f05:	fc                   	cld    
  801f06:	f3 ab                	rep stos %eax,%es:(%edi)
  801f08:	eb 03                	jmp    801f0d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801f0a:	fc                   	cld    
  801f0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801f0d:	89 f8                	mov    %edi,%eax
  801f0f:	5b                   	pop    %ebx
  801f10:	5e                   	pop    %esi
  801f11:	5f                   	pop    %edi
  801f12:	5d                   	pop    %ebp
  801f13:	c3                   	ret    

00801f14 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	57                   	push   %edi
  801f18:	56                   	push   %esi
  801f19:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801f22:	39 c6                	cmp    %eax,%esi
  801f24:	73 34                	jae    801f5a <memmove+0x46>
  801f26:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801f29:	39 d0                	cmp    %edx,%eax
  801f2b:	73 2d                	jae    801f5a <memmove+0x46>
		s += n;
		d += n;
  801f2d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f30:	f6 c2 03             	test   $0x3,%dl
  801f33:	75 1b                	jne    801f50 <memmove+0x3c>
  801f35:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801f3b:	75 13                	jne    801f50 <memmove+0x3c>
  801f3d:	f6 c1 03             	test   $0x3,%cl
  801f40:	75 0e                	jne    801f50 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801f42:	83 ef 04             	sub    $0x4,%edi
  801f45:	8d 72 fc             	lea    -0x4(%edx),%esi
  801f48:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801f4b:	fd                   	std    
  801f4c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f4e:	eb 07                	jmp    801f57 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801f50:	4f                   	dec    %edi
  801f51:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801f54:	fd                   	std    
  801f55:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801f57:	fc                   	cld    
  801f58:	eb 20                	jmp    801f7a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f5a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801f60:	75 13                	jne    801f75 <memmove+0x61>
  801f62:	a8 03                	test   $0x3,%al
  801f64:	75 0f                	jne    801f75 <memmove+0x61>
  801f66:	f6 c1 03             	test   $0x3,%cl
  801f69:	75 0a                	jne    801f75 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801f6b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801f6e:	89 c7                	mov    %eax,%edi
  801f70:	fc                   	cld    
  801f71:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f73:	eb 05                	jmp    801f7a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801f75:	89 c7                	mov    %eax,%edi
  801f77:	fc                   	cld    
  801f78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801f7a:	5e                   	pop    %esi
  801f7b:	5f                   	pop    %edi
  801f7c:	5d                   	pop    %ebp
  801f7d:	c3                   	ret    

00801f7e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801f84:	8b 45 10             	mov    0x10(%ebp),%eax
  801f87:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f92:	8b 45 08             	mov    0x8(%ebp),%eax
  801f95:	89 04 24             	mov    %eax,(%esp)
  801f98:	e8 77 ff ff ff       	call   801f14 <memmove>
}
  801f9d:	c9                   	leave  
  801f9e:	c3                   	ret    

00801f9f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801f9f:	55                   	push   %ebp
  801fa0:	89 e5                	mov    %esp,%ebp
  801fa2:	57                   	push   %edi
  801fa3:	56                   	push   %esi
  801fa4:	53                   	push   %ebx
  801fa5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fa8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801fae:	ba 00 00 00 00       	mov    $0x0,%edx
  801fb3:	eb 16                	jmp    801fcb <memcmp+0x2c>
		if (*s1 != *s2)
  801fb5:	8a 04 17             	mov    (%edi,%edx,1),%al
  801fb8:	42                   	inc    %edx
  801fb9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801fbd:	38 c8                	cmp    %cl,%al
  801fbf:	74 0a                	je     801fcb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801fc1:	0f b6 c0             	movzbl %al,%eax
  801fc4:	0f b6 c9             	movzbl %cl,%ecx
  801fc7:	29 c8                	sub    %ecx,%eax
  801fc9:	eb 09                	jmp    801fd4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801fcb:	39 da                	cmp    %ebx,%edx
  801fcd:	75 e6                	jne    801fb5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801fcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fd4:	5b                   	pop    %ebx
  801fd5:	5e                   	pop    %esi
  801fd6:	5f                   	pop    %edi
  801fd7:	5d                   	pop    %ebp
  801fd8:	c3                   	ret    

00801fd9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801fd9:	55                   	push   %ebp
  801fda:	89 e5                	mov    %esp,%ebp
  801fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801fdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801fe2:	89 c2                	mov    %eax,%edx
  801fe4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801fe7:	eb 05                	jmp    801fee <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801fe9:	38 08                	cmp    %cl,(%eax)
  801feb:	74 05                	je     801ff2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801fed:	40                   	inc    %eax
  801fee:	39 d0                	cmp    %edx,%eax
  801ff0:	72 f7                	jb     801fe9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801ff2:	5d                   	pop    %ebp
  801ff3:	c3                   	ret    

00801ff4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ff4:	55                   	push   %ebp
  801ff5:	89 e5                	mov    %esp,%ebp
  801ff7:	57                   	push   %edi
  801ff8:	56                   	push   %esi
  801ff9:	53                   	push   %ebx
  801ffa:	8b 55 08             	mov    0x8(%ebp),%edx
  801ffd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802000:	eb 01                	jmp    802003 <strtol+0xf>
		s++;
  802002:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802003:	8a 02                	mov    (%edx),%al
  802005:	3c 20                	cmp    $0x20,%al
  802007:	74 f9                	je     802002 <strtol+0xe>
  802009:	3c 09                	cmp    $0x9,%al
  80200b:	74 f5                	je     802002 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80200d:	3c 2b                	cmp    $0x2b,%al
  80200f:	75 08                	jne    802019 <strtol+0x25>
		s++;
  802011:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802012:	bf 00 00 00 00       	mov    $0x0,%edi
  802017:	eb 13                	jmp    80202c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802019:	3c 2d                	cmp    $0x2d,%al
  80201b:	75 0a                	jne    802027 <strtol+0x33>
		s++, neg = 1;
  80201d:	8d 52 01             	lea    0x1(%edx),%edx
  802020:	bf 01 00 00 00       	mov    $0x1,%edi
  802025:	eb 05                	jmp    80202c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802027:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80202c:	85 db                	test   %ebx,%ebx
  80202e:	74 05                	je     802035 <strtol+0x41>
  802030:	83 fb 10             	cmp    $0x10,%ebx
  802033:	75 28                	jne    80205d <strtol+0x69>
  802035:	8a 02                	mov    (%edx),%al
  802037:	3c 30                	cmp    $0x30,%al
  802039:	75 10                	jne    80204b <strtol+0x57>
  80203b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80203f:	75 0a                	jne    80204b <strtol+0x57>
		s += 2, base = 16;
  802041:	83 c2 02             	add    $0x2,%edx
  802044:	bb 10 00 00 00       	mov    $0x10,%ebx
  802049:	eb 12                	jmp    80205d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80204b:	85 db                	test   %ebx,%ebx
  80204d:	75 0e                	jne    80205d <strtol+0x69>
  80204f:	3c 30                	cmp    $0x30,%al
  802051:	75 05                	jne    802058 <strtol+0x64>
		s++, base = 8;
  802053:	42                   	inc    %edx
  802054:	b3 08                	mov    $0x8,%bl
  802056:	eb 05                	jmp    80205d <strtol+0x69>
	else if (base == 0)
		base = 10;
  802058:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80205d:	b8 00 00 00 00       	mov    $0x0,%eax
  802062:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802064:	8a 0a                	mov    (%edx),%cl
  802066:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  802069:	80 fb 09             	cmp    $0x9,%bl
  80206c:	77 08                	ja     802076 <strtol+0x82>
			dig = *s - '0';
  80206e:	0f be c9             	movsbl %cl,%ecx
  802071:	83 e9 30             	sub    $0x30,%ecx
  802074:	eb 1e                	jmp    802094 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  802076:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  802079:	80 fb 19             	cmp    $0x19,%bl
  80207c:	77 08                	ja     802086 <strtol+0x92>
			dig = *s - 'a' + 10;
  80207e:	0f be c9             	movsbl %cl,%ecx
  802081:	83 e9 57             	sub    $0x57,%ecx
  802084:	eb 0e                	jmp    802094 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  802086:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  802089:	80 fb 19             	cmp    $0x19,%bl
  80208c:	77 12                	ja     8020a0 <strtol+0xac>
			dig = *s - 'A' + 10;
  80208e:	0f be c9             	movsbl %cl,%ecx
  802091:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  802094:	39 f1                	cmp    %esi,%ecx
  802096:	7d 0c                	jge    8020a4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  802098:	42                   	inc    %edx
  802099:	0f af c6             	imul   %esi,%eax
  80209c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80209e:	eb c4                	jmp    802064 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8020a0:	89 c1                	mov    %eax,%ecx
  8020a2:	eb 02                	jmp    8020a6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8020a4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8020a6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8020aa:	74 05                	je     8020b1 <strtol+0xbd>
		*endptr = (char *) s;
  8020ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8020af:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8020b1:	85 ff                	test   %edi,%edi
  8020b3:	74 04                	je     8020b9 <strtol+0xc5>
  8020b5:	89 c8                	mov    %ecx,%eax
  8020b7:	f7 d8                	neg    %eax
}
  8020b9:	5b                   	pop    %ebx
  8020ba:	5e                   	pop    %esi
  8020bb:	5f                   	pop    %edi
  8020bc:	5d                   	pop    %ebp
  8020bd:	c3                   	ret    
	...

008020c0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020c0:	55                   	push   %ebp
  8020c1:	89 e5                	mov    %esp,%ebp
  8020c3:	56                   	push   %esi
  8020c4:	53                   	push   %ebx
  8020c5:	83 ec 10             	sub    $0x10,%esp
  8020c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ce:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8020d1:	85 c0                	test   %eax,%eax
  8020d3:	74 0a                	je     8020df <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8020d5:	89 04 24             	mov    %eax,(%esp)
  8020d8:	e8 c2 e2 ff ff       	call   80039f <sys_ipc_recv>
  8020dd:	eb 0c                	jmp    8020eb <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8020df:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8020e6:	e8 b4 e2 ff ff       	call   80039f <sys_ipc_recv>
	}
	if (r < 0)
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	79 16                	jns    802105 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8020ef:	85 db                	test   %ebx,%ebx
  8020f1:	74 06                	je     8020f9 <ipc_recv+0x39>
  8020f3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8020f9:	85 f6                	test   %esi,%esi
  8020fb:	74 2c                	je     802129 <ipc_recv+0x69>
  8020fd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802103:	eb 24                	jmp    802129 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802105:	85 db                	test   %ebx,%ebx
  802107:	74 0a                	je     802113 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802109:	a1 08 40 80 00       	mov    0x804008,%eax
  80210e:	8b 40 74             	mov    0x74(%eax),%eax
  802111:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  802113:	85 f6                	test   %esi,%esi
  802115:	74 0a                	je     802121 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  802117:	a1 08 40 80 00       	mov    0x804008,%eax
  80211c:	8b 40 78             	mov    0x78(%eax),%eax
  80211f:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802121:	a1 08 40 80 00       	mov    0x804008,%eax
  802126:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802129:	83 c4 10             	add    $0x10,%esp
  80212c:	5b                   	pop    %ebx
  80212d:	5e                   	pop    %esi
  80212e:	5d                   	pop    %ebp
  80212f:	c3                   	ret    

00802130 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	57                   	push   %edi
  802134:	56                   	push   %esi
  802135:	53                   	push   %ebx
  802136:	83 ec 1c             	sub    $0x1c,%esp
  802139:	8b 75 08             	mov    0x8(%ebp),%esi
  80213c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80213f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  802142:	85 db                	test   %ebx,%ebx
  802144:	74 19                	je     80215f <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802146:	8b 45 14             	mov    0x14(%ebp),%eax
  802149:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80214d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802151:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802155:	89 34 24             	mov    %esi,(%esp)
  802158:	e8 1f e2 ff ff       	call   80037c <sys_ipc_try_send>
  80215d:	eb 1c                	jmp    80217b <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80215f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802166:	00 
  802167:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80216e:	ee 
  80216f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802173:	89 34 24             	mov    %esi,(%esp)
  802176:	e8 01 e2 ff ff       	call   80037c <sys_ipc_try_send>
		}
		if (r == 0)
  80217b:	85 c0                	test   %eax,%eax
  80217d:	74 2c                	je     8021ab <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80217f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802182:	74 20                	je     8021a4 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802184:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802188:	c7 44 24 08 24 29 80 	movl   $0x802924,0x8(%esp)
  80218f:	00 
  802190:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802197:	00 
  802198:	c7 04 24 37 29 80 00 	movl   $0x802937,(%esp)
  80219f:	e8 54 f5 ff ff       	call   8016f8 <_panic>
		}
		sys_yield();
  8021a4:	e8 c1 df ff ff       	call   80016a <sys_yield>
	}
  8021a9:	eb 97                	jmp    802142 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8021ab:	83 c4 1c             	add    $0x1c,%esp
  8021ae:	5b                   	pop    %ebx
  8021af:	5e                   	pop    %esi
  8021b0:	5f                   	pop    %edi
  8021b1:	5d                   	pop    %ebp
  8021b2:	c3                   	ret    

008021b3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021b3:	55                   	push   %ebp
  8021b4:	89 e5                	mov    %esp,%ebp
  8021b6:	53                   	push   %ebx
  8021b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8021ba:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021bf:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8021c6:	89 c2                	mov    %eax,%edx
  8021c8:	c1 e2 07             	shl    $0x7,%edx
  8021cb:	29 ca                	sub    %ecx,%edx
  8021cd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021d3:	8b 52 50             	mov    0x50(%edx),%edx
  8021d6:	39 da                	cmp    %ebx,%edx
  8021d8:	75 0f                	jne    8021e9 <ipc_find_env+0x36>
			return envs[i].env_id;
  8021da:	c1 e0 07             	shl    $0x7,%eax
  8021dd:	29 c8                	sub    %ecx,%eax
  8021df:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021e4:	8b 40 40             	mov    0x40(%eax),%eax
  8021e7:	eb 0c                	jmp    8021f5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021e9:	40                   	inc    %eax
  8021ea:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021ef:	75 ce                	jne    8021bf <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021f1:	66 b8 00 00          	mov    $0x0,%ax
}
  8021f5:	5b                   	pop    %ebx
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    

008021f8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021f8:	55                   	push   %ebp
  8021f9:	89 e5                	mov    %esp,%ebp
  8021fb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021fe:	89 c2                	mov    %eax,%edx
  802200:	c1 ea 16             	shr    $0x16,%edx
  802203:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80220a:	f6 c2 01             	test   $0x1,%dl
  80220d:	74 1e                	je     80222d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80220f:	c1 e8 0c             	shr    $0xc,%eax
  802212:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802219:	a8 01                	test   $0x1,%al
  80221b:	74 17                	je     802234 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80221d:	c1 e8 0c             	shr    $0xc,%eax
  802220:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802227:	ef 
  802228:	0f b7 c0             	movzwl %ax,%eax
  80222b:	eb 0c                	jmp    802239 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80222d:	b8 00 00 00 00       	mov    $0x0,%eax
  802232:	eb 05                	jmp    802239 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802234:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802239:	5d                   	pop    %ebp
  80223a:	c3                   	ret    
	...

0080223c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80223c:	55                   	push   %ebp
  80223d:	57                   	push   %edi
  80223e:	56                   	push   %esi
  80223f:	83 ec 10             	sub    $0x10,%esp
  802242:	8b 74 24 20          	mov    0x20(%esp),%esi
  802246:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80224a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80224e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802252:	89 cd                	mov    %ecx,%ebp
  802254:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802258:	85 c0                	test   %eax,%eax
  80225a:	75 2c                	jne    802288 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80225c:	39 f9                	cmp    %edi,%ecx
  80225e:	77 68                	ja     8022c8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802260:	85 c9                	test   %ecx,%ecx
  802262:	75 0b                	jne    80226f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802264:	b8 01 00 00 00       	mov    $0x1,%eax
  802269:	31 d2                	xor    %edx,%edx
  80226b:	f7 f1                	div    %ecx
  80226d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80226f:	31 d2                	xor    %edx,%edx
  802271:	89 f8                	mov    %edi,%eax
  802273:	f7 f1                	div    %ecx
  802275:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802277:	89 f0                	mov    %esi,%eax
  802279:	f7 f1                	div    %ecx
  80227b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80227d:	89 f0                	mov    %esi,%eax
  80227f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802281:	83 c4 10             	add    $0x10,%esp
  802284:	5e                   	pop    %esi
  802285:	5f                   	pop    %edi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802288:	39 f8                	cmp    %edi,%eax
  80228a:	77 2c                	ja     8022b8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80228c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80228f:	83 f6 1f             	xor    $0x1f,%esi
  802292:	75 4c                	jne    8022e0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802294:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802296:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80229b:	72 0a                	jb     8022a7 <__udivdi3+0x6b>
  80229d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022a1:	0f 87 ad 00 00 00    	ja     802354 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022a7:	be 01 00 00 00       	mov    $0x1,%esi
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
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022b8:	31 ff                	xor    %edi,%edi
  8022ba:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022bc:	89 f0                	mov    %esi,%eax
  8022be:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022c0:	83 c4 10             	add    $0x10,%esp
  8022c3:	5e                   	pop    %esi
  8022c4:	5f                   	pop    %edi
  8022c5:	5d                   	pop    %ebp
  8022c6:	c3                   	ret    
  8022c7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022c8:	89 fa                	mov    %edi,%edx
  8022ca:	89 f0                	mov    %esi,%eax
  8022cc:	f7 f1                	div    %ecx
  8022ce:	89 c6                	mov    %eax,%esi
  8022d0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022d2:	89 f0                	mov    %esi,%eax
  8022d4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022d6:	83 c4 10             	add    $0x10,%esp
  8022d9:	5e                   	pop    %esi
  8022da:	5f                   	pop    %edi
  8022db:	5d                   	pop    %ebp
  8022dc:	c3                   	ret    
  8022dd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8022e0:	89 f1                	mov    %esi,%ecx
  8022e2:	d3 e0                	shl    %cl,%eax
  8022e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022e8:	b8 20 00 00 00       	mov    $0x20,%eax
  8022ed:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8022ef:	89 ea                	mov    %ebp,%edx
  8022f1:	88 c1                	mov    %al,%cl
  8022f3:	d3 ea                	shr    %cl,%edx
  8022f5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8022f9:	09 ca                	or     %ecx,%edx
  8022fb:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8022ff:	89 f1                	mov    %esi,%ecx
  802301:	d3 e5                	shl    %cl,%ebp
  802303:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802307:	89 fd                	mov    %edi,%ebp
  802309:	88 c1                	mov    %al,%cl
  80230b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80230d:	89 fa                	mov    %edi,%edx
  80230f:	89 f1                	mov    %esi,%ecx
  802311:	d3 e2                	shl    %cl,%edx
  802313:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802317:	88 c1                	mov    %al,%cl
  802319:	d3 ef                	shr    %cl,%edi
  80231b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80231d:	89 f8                	mov    %edi,%eax
  80231f:	89 ea                	mov    %ebp,%edx
  802321:	f7 74 24 08          	divl   0x8(%esp)
  802325:	89 d1                	mov    %edx,%ecx
  802327:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802329:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80232d:	39 d1                	cmp    %edx,%ecx
  80232f:	72 17                	jb     802348 <__udivdi3+0x10c>
  802331:	74 09                	je     80233c <__udivdi3+0x100>
  802333:	89 fe                	mov    %edi,%esi
  802335:	31 ff                	xor    %edi,%edi
  802337:	e9 41 ff ff ff       	jmp    80227d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80233c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802340:	89 f1                	mov    %esi,%ecx
  802342:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802344:	39 c2                	cmp    %eax,%edx
  802346:	73 eb                	jae    802333 <__udivdi3+0xf7>
		{
		  q0--;
  802348:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80234b:	31 ff                	xor    %edi,%edi
  80234d:	e9 2b ff ff ff       	jmp    80227d <__udivdi3+0x41>
  802352:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802354:	31 f6                	xor    %esi,%esi
  802356:	e9 22 ff ff ff       	jmp    80227d <__udivdi3+0x41>
	...

0080235c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80235c:	55                   	push   %ebp
  80235d:	57                   	push   %edi
  80235e:	56                   	push   %esi
  80235f:	83 ec 20             	sub    $0x20,%esp
  802362:	8b 44 24 30          	mov    0x30(%esp),%eax
  802366:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80236a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80236e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802372:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802376:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80237a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80237c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80237e:	85 ed                	test   %ebp,%ebp
  802380:	75 16                	jne    802398 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802382:	39 f1                	cmp    %esi,%ecx
  802384:	0f 86 a6 00 00 00    	jbe    802430 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80238a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80238c:	89 d0                	mov    %edx,%eax
  80238e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802390:	83 c4 20             	add    $0x20,%esp
  802393:	5e                   	pop    %esi
  802394:	5f                   	pop    %edi
  802395:	5d                   	pop    %ebp
  802396:	c3                   	ret    
  802397:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802398:	39 f5                	cmp    %esi,%ebp
  80239a:	0f 87 ac 00 00 00    	ja     80244c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8023a0:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8023a3:	83 f0 1f             	xor    $0x1f,%eax
  8023a6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023aa:	0f 84 a8 00 00 00    	je     802458 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8023b0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023b4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023b6:	bf 20 00 00 00       	mov    $0x20,%edi
  8023bb:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8023bf:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023c3:	89 f9                	mov    %edi,%ecx
  8023c5:	d3 e8                	shr    %cl,%eax
  8023c7:	09 e8                	or     %ebp,%eax
  8023c9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8023cd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023d1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023d5:	d3 e0                	shl    %cl,%eax
  8023d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023db:	89 f2                	mov    %esi,%edx
  8023dd:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8023df:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023e3:	d3 e0                	shl    %cl,%eax
  8023e5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023e9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023ed:	89 f9                	mov    %edi,%ecx
  8023ef:	d3 e8                	shr    %cl,%eax
  8023f1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8023f3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023f5:	89 f2                	mov    %esi,%edx
  8023f7:	f7 74 24 18          	divl   0x18(%esp)
  8023fb:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8023fd:	f7 64 24 0c          	mull   0xc(%esp)
  802401:	89 c5                	mov    %eax,%ebp
  802403:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802405:	39 d6                	cmp    %edx,%esi
  802407:	72 67                	jb     802470 <__umoddi3+0x114>
  802409:	74 75                	je     802480 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80240b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80240f:	29 e8                	sub    %ebp,%eax
  802411:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802413:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802417:	d3 e8                	shr    %cl,%eax
  802419:	89 f2                	mov    %esi,%edx
  80241b:	89 f9                	mov    %edi,%ecx
  80241d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80241f:	09 d0                	or     %edx,%eax
  802421:	89 f2                	mov    %esi,%edx
  802423:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802427:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802429:	83 c4 20             	add    $0x20,%esp
  80242c:	5e                   	pop    %esi
  80242d:	5f                   	pop    %edi
  80242e:	5d                   	pop    %ebp
  80242f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802430:	85 c9                	test   %ecx,%ecx
  802432:	75 0b                	jne    80243f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802434:	b8 01 00 00 00       	mov    $0x1,%eax
  802439:	31 d2                	xor    %edx,%edx
  80243b:	f7 f1                	div    %ecx
  80243d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80243f:	89 f0                	mov    %esi,%eax
  802441:	31 d2                	xor    %edx,%edx
  802443:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802445:	89 f8                	mov    %edi,%eax
  802447:	e9 3e ff ff ff       	jmp    80238a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80244c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80244e:	83 c4 20             	add    $0x20,%esp
  802451:	5e                   	pop    %esi
  802452:	5f                   	pop    %edi
  802453:	5d                   	pop    %ebp
  802454:	c3                   	ret    
  802455:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802458:	39 f5                	cmp    %esi,%ebp
  80245a:	72 04                	jb     802460 <__umoddi3+0x104>
  80245c:	39 f9                	cmp    %edi,%ecx
  80245e:	77 06                	ja     802466 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802460:	89 f2                	mov    %esi,%edx
  802462:	29 cf                	sub    %ecx,%edi
  802464:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802466:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802468:	83 c4 20             	add    $0x20,%esp
  80246b:	5e                   	pop    %esi
  80246c:	5f                   	pop    %edi
  80246d:	5d                   	pop    %ebp
  80246e:	c3                   	ret    
  80246f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802470:	89 d1                	mov    %edx,%ecx
  802472:	89 c5                	mov    %eax,%ebp
  802474:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802478:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80247c:	eb 8d                	jmp    80240b <__umoddi3+0xaf>
  80247e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802480:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802484:	72 ea                	jb     802470 <__umoddi3+0x114>
  802486:	89 f1                	mov    %esi,%ecx
  802488:	eb 81                	jmp    80240b <__umoddi3+0xaf>
