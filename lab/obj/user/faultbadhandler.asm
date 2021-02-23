
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 5f 01 00 00       	call   8001b5 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800056:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005d:	de 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 eb 02 00 00       	call   800355 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	56                   	push   %esi
  80007c:	53                   	push   %ebx
  80007d:	83 ec 10             	sub    $0x10,%esp
  800080:	8b 75 08             	mov    0x8(%ebp),%esi
  800083:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800086:	e8 ec 00 00 00       	call   800177 <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800097:	c1 e0 07             	shl    $0x7,%eax
  80009a:	29 d0                	sub    %edx,%eax
  80009c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a1:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a6:	85 f6                	test   %esi,%esi
  8000a8:	7e 07                	jle    8000b1 <libmain+0x39>
		binaryname = argv[0];
  8000aa:	8b 03                	mov    (%ebx),%eax
  8000ac:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b5:	89 34 24             	mov    %esi,(%esp)
  8000b8:	e8 77 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000bd:	e8 0a 00 00 00       	call   8000cc <exit>
}
  8000c2:	83 c4 10             	add    $0x10,%esp
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5d                   	pop    %ebp
  8000c8:	c3                   	ret    
  8000c9:	00 00                	add    %al,(%eax)
	...

008000cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000d2:	e8 90 05 00 00       	call   800667 <close_all>
	sys_env_destroy(0);
  8000d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000de:	e8 42 00 00 00       	call   800125 <sys_env_destroy>
}
  8000e3:	c9                   	leave  
  8000e4:	c3                   	ret    
  8000e5:	00 00                	add    %al,(%eax)
	...

008000e8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	57                   	push   %edi
  8000ec:	56                   	push   %esi
  8000ed:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f9:	89 c3                	mov    %eax,%ebx
  8000fb:	89 c7                	mov    %eax,%edi
  8000fd:	89 c6                	mov    %eax,%esi
  8000ff:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800101:	5b                   	pop    %ebx
  800102:	5e                   	pop    %esi
  800103:	5f                   	pop    %edi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <sys_cgetc>:

int
sys_cgetc(void)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	57                   	push   %edi
  80010a:	56                   	push   %esi
  80010b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010c:	ba 00 00 00 00       	mov    $0x0,%edx
  800111:	b8 01 00 00 00       	mov    $0x1,%eax
  800116:	89 d1                	mov    %edx,%ecx
  800118:	89 d3                	mov    %edx,%ebx
  80011a:	89 d7                	mov    %edx,%edi
  80011c:	89 d6                	mov    %edx,%esi
  80011e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
  80012b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800133:	b8 03 00 00 00       	mov    $0x3,%eax
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	89 cb                	mov    %ecx,%ebx
  80013d:	89 cf                	mov    %ecx,%edi
  80013f:	89 ce                	mov    %ecx,%esi
  800141:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800143:	85 c0                	test   %eax,%eax
  800145:	7e 28                	jle    80016f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800147:	89 44 24 10          	mov    %eax,0x10(%esp)
  80014b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800152:	00 
  800153:	c7 44 24 08 ca 24 80 	movl   $0x8024ca,0x8(%esp)
  80015a:	00 
  80015b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800162:	00 
  800163:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
  80016a:	e8 b5 15 00 00       	call   801724 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80016f:	83 c4 2c             	add    $0x2c,%esp
  800172:	5b                   	pop    %ebx
  800173:	5e                   	pop    %esi
  800174:	5f                   	pop    %edi
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	57                   	push   %edi
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017d:	ba 00 00 00 00       	mov    $0x0,%edx
  800182:	b8 02 00 00 00       	mov    $0x2,%eax
  800187:	89 d1                	mov    %edx,%ecx
  800189:	89 d3                	mov    %edx,%ebx
  80018b:	89 d7                	mov    %edx,%edi
  80018d:	89 d6                	mov    %edx,%esi
  80018f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800191:	5b                   	pop    %ebx
  800192:	5e                   	pop    %esi
  800193:	5f                   	pop    %edi
  800194:	5d                   	pop    %ebp
  800195:	c3                   	ret    

00800196 <sys_yield>:

void
sys_yield(void)
{
  800196:	55                   	push   %ebp
  800197:	89 e5                	mov    %esp,%ebp
  800199:	57                   	push   %edi
  80019a:	56                   	push   %esi
  80019b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019c:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a1:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001a6:	89 d1                	mov    %edx,%ecx
  8001a8:	89 d3                	mov    %edx,%ebx
  8001aa:	89 d7                	mov    %edx,%edi
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8001b0:	5b                   	pop    %ebx
  8001b1:	5e                   	pop    %esi
  8001b2:	5f                   	pop    %edi
  8001b3:	5d                   	pop    %ebp
  8001b4:	c3                   	ret    

008001b5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	57                   	push   %edi
  8001b9:	56                   	push   %esi
  8001ba:	53                   	push   %ebx
  8001bb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001be:	be 00 00 00 00       	mov    $0x0,%esi
  8001c3:	b8 04 00 00 00       	mov    $0x4,%eax
  8001c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d1:	89 f7                	mov    %esi,%edi
  8001d3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7e 28                	jle    800201 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001dd:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001e4:	00 
  8001e5:	c7 44 24 08 ca 24 80 	movl   $0x8024ca,0x8(%esp)
  8001ec:	00 
  8001ed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001f4:	00 
  8001f5:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
  8001fc:	e8 23 15 00 00       	call   801724 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800201:	83 c4 2c             	add    $0x2c,%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5f                   	pop    %edi
  800207:	5d                   	pop    %ebp
  800208:	c3                   	ret    

00800209 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800212:	b8 05 00 00 00       	mov    $0x5,%eax
  800217:	8b 75 18             	mov    0x18(%ebp),%esi
  80021a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80021d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800223:	8b 55 08             	mov    0x8(%ebp),%edx
  800226:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800228:	85 c0                	test   %eax,%eax
  80022a:	7e 28                	jle    800254 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800230:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800237:	00 
  800238:	c7 44 24 08 ca 24 80 	movl   $0x8024ca,0x8(%esp)
  80023f:	00 
  800240:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800247:	00 
  800248:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
  80024f:	e8 d0 14 00 00       	call   801724 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800254:	83 c4 2c             	add    $0x2c,%esp
  800257:	5b                   	pop    %ebx
  800258:	5e                   	pop    %esi
  800259:	5f                   	pop    %edi
  80025a:	5d                   	pop    %ebp
  80025b:	c3                   	ret    

0080025c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	57                   	push   %edi
  800260:	56                   	push   %esi
  800261:	53                   	push   %ebx
  800262:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800265:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026a:	b8 06 00 00 00       	mov    $0x6,%eax
  80026f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800272:	8b 55 08             	mov    0x8(%ebp),%edx
  800275:	89 df                	mov    %ebx,%edi
  800277:	89 de                	mov    %ebx,%esi
  800279:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027b:	85 c0                	test   %eax,%eax
  80027d:	7e 28                	jle    8002a7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800283:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80028a:	00 
  80028b:	c7 44 24 08 ca 24 80 	movl   $0x8024ca,0x8(%esp)
  800292:	00 
  800293:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80029a:	00 
  80029b:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
  8002a2:	e8 7d 14 00 00       	call   801724 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002a7:	83 c4 2c             	add    $0x2c,%esp
  8002aa:	5b                   	pop    %ebx
  8002ab:	5e                   	pop    %esi
  8002ac:	5f                   	pop    %edi
  8002ad:	5d                   	pop    %ebp
  8002ae:	c3                   	ret    

008002af <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	57                   	push   %edi
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bd:	b8 08 00 00 00       	mov    $0x8,%eax
  8002c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c8:	89 df                	mov    %ebx,%edi
  8002ca:	89 de                	mov    %ebx,%esi
  8002cc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ce:	85 c0                	test   %eax,%eax
  8002d0:	7e 28                	jle    8002fa <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002d6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002dd:	00 
  8002de:	c7 44 24 08 ca 24 80 	movl   $0x8024ca,0x8(%esp)
  8002e5:	00 
  8002e6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002ed:	00 
  8002ee:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
  8002f5:	e8 2a 14 00 00       	call   801724 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002fa:	83 c4 2c             	add    $0x2c,%esp
  8002fd:	5b                   	pop    %ebx
  8002fe:	5e                   	pop    %esi
  8002ff:	5f                   	pop    %edi
  800300:	5d                   	pop    %ebp
  800301:	c3                   	ret    

00800302 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	57                   	push   %edi
  800306:	56                   	push   %esi
  800307:	53                   	push   %ebx
  800308:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800310:	b8 09 00 00 00       	mov    $0x9,%eax
  800315:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 df                	mov    %ebx,%edi
  80031d:	89 de                	mov    %ebx,%esi
  80031f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800321:	85 c0                	test   %eax,%eax
  800323:	7e 28                	jle    80034d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800325:	89 44 24 10          	mov    %eax,0x10(%esp)
  800329:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800330:	00 
  800331:	c7 44 24 08 ca 24 80 	movl   $0x8024ca,0x8(%esp)
  800338:	00 
  800339:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800340:	00 
  800341:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
  800348:	e8 d7 13 00 00       	call   801724 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80034d:	83 c4 2c             	add    $0x2c,%esp
  800350:	5b                   	pop    %ebx
  800351:	5e                   	pop    %esi
  800352:	5f                   	pop    %edi
  800353:	5d                   	pop    %ebp
  800354:	c3                   	ret    

00800355 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	57                   	push   %edi
  800359:	56                   	push   %esi
  80035a:	53                   	push   %ebx
  80035b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800363:	b8 0a 00 00 00       	mov    $0xa,%eax
  800368:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80036b:	8b 55 08             	mov    0x8(%ebp),%edx
  80036e:	89 df                	mov    %ebx,%edi
  800370:	89 de                	mov    %ebx,%esi
  800372:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800374:	85 c0                	test   %eax,%eax
  800376:	7e 28                	jle    8003a0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800378:	89 44 24 10          	mov    %eax,0x10(%esp)
  80037c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800383:	00 
  800384:	c7 44 24 08 ca 24 80 	movl   $0x8024ca,0x8(%esp)
  80038b:	00 
  80038c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800393:	00 
  800394:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
  80039b:	e8 84 13 00 00       	call   801724 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8003a0:	83 c4 2c             	add    $0x2c,%esp
  8003a3:	5b                   	pop    %ebx
  8003a4:	5e                   	pop    %esi
  8003a5:	5f                   	pop    %edi
  8003a6:	5d                   	pop    %ebp
  8003a7:	c3                   	ret    

008003a8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
  8003ab:	57                   	push   %edi
  8003ac:	56                   	push   %esi
  8003ad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ae:	be 00 00 00 00       	mov    $0x0,%esi
  8003b3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8003bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8003be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003c6:	5b                   	pop    %ebx
  8003c7:	5e                   	pop    %esi
  8003c8:	5f                   	pop    %edi
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	57                   	push   %edi
  8003cf:	56                   	push   %esi
  8003d0:	53                   	push   %ebx
  8003d1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003de:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e1:	89 cb                	mov    %ecx,%ebx
  8003e3:	89 cf                	mov    %ecx,%edi
  8003e5:	89 ce                	mov    %ecx,%esi
  8003e7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003e9:	85 c0                	test   %eax,%eax
  8003eb:	7e 28                	jle    800415 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003f1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003f8:	00 
  8003f9:	c7 44 24 08 ca 24 80 	movl   $0x8024ca,0x8(%esp)
  800400:	00 
  800401:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800408:	00 
  800409:	c7 04 24 e7 24 80 00 	movl   $0x8024e7,(%esp)
  800410:	e8 0f 13 00 00       	call   801724 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800415:	83 c4 2c             	add    $0x2c,%esp
  800418:	5b                   	pop    %ebx
  800419:	5e                   	pop    %esi
  80041a:	5f                   	pop    %edi
  80041b:	5d                   	pop    %ebp
  80041c:	c3                   	ret    

0080041d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
  800420:	57                   	push   %edi
  800421:	56                   	push   %esi
  800422:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800423:	ba 00 00 00 00       	mov    $0x0,%edx
  800428:	b8 0e 00 00 00       	mov    $0xe,%eax
  80042d:	89 d1                	mov    %edx,%ecx
  80042f:	89 d3                	mov    %edx,%ebx
  800431:	89 d7                	mov    %edx,%edi
  800433:	89 d6                	mov    %edx,%esi
  800435:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800437:	5b                   	pop    %ebx
  800438:	5e                   	pop    %esi
  800439:	5f                   	pop    %edi
  80043a:	5d                   	pop    %ebp
  80043b:	c3                   	ret    

0080043c <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  80043c:	55                   	push   %ebp
  80043d:	89 e5                	mov    %esp,%ebp
  80043f:	57                   	push   %edi
  800440:	56                   	push   %esi
  800441:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800442:	bb 00 00 00 00       	mov    $0x0,%ebx
  800447:	b8 0f 00 00 00       	mov    $0xf,%eax
  80044c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80044f:	8b 55 08             	mov    0x8(%ebp),%edx
  800452:	89 df                	mov    %ebx,%edi
  800454:	89 de                	mov    %ebx,%esi
  800456:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800458:	5b                   	pop    %ebx
  800459:	5e                   	pop    %esi
  80045a:	5f                   	pop    %edi
  80045b:	5d                   	pop    %ebp
  80045c:	c3                   	ret    

0080045d <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  80045d:	55                   	push   %ebp
  80045e:	89 e5                	mov    %esp,%ebp
  800460:	57                   	push   %edi
  800461:	56                   	push   %esi
  800462:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800463:	bb 00 00 00 00       	mov    $0x0,%ebx
  800468:	b8 10 00 00 00       	mov    $0x10,%eax
  80046d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800470:	8b 55 08             	mov    0x8(%ebp),%edx
  800473:	89 df                	mov    %ebx,%edi
  800475:	89 de                	mov    %ebx,%esi
  800477:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800479:	5b                   	pop    %ebx
  80047a:	5e                   	pop    %esi
  80047b:	5f                   	pop    %edi
  80047c:	5d                   	pop    %ebp
  80047d:	c3                   	ret    
	...

00800480 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800483:	8b 45 08             	mov    0x8(%ebp),%eax
  800486:	05 00 00 00 30       	add    $0x30000000,%eax
  80048b:	c1 e8 0c             	shr    $0xc,%eax
}
  80048e:	5d                   	pop    %ebp
  80048f:	c3                   	ret    

00800490 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800496:	8b 45 08             	mov    0x8(%ebp),%eax
  800499:	89 04 24             	mov    %eax,(%esp)
  80049c:	e8 df ff ff ff       	call   800480 <fd2num>
  8004a1:	c1 e0 0c             	shl    $0xc,%eax
  8004a4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8004a9:	c9                   	leave  
  8004aa:	c3                   	ret    

008004ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8004ab:	55                   	push   %ebp
  8004ac:	89 e5                	mov    %esp,%ebp
  8004ae:	53                   	push   %ebx
  8004af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004b2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8004b7:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8004b9:	89 c2                	mov    %eax,%edx
  8004bb:	c1 ea 16             	shr    $0x16,%edx
  8004be:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004c5:	f6 c2 01             	test   $0x1,%dl
  8004c8:	74 11                	je     8004db <fd_alloc+0x30>
  8004ca:	89 c2                	mov    %eax,%edx
  8004cc:	c1 ea 0c             	shr    $0xc,%edx
  8004cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004d6:	f6 c2 01             	test   $0x1,%dl
  8004d9:	75 09                	jne    8004e4 <fd_alloc+0x39>
			*fd_store = fd;
  8004db:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8004dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e2:	eb 17                	jmp    8004fb <fd_alloc+0x50>
  8004e4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8004e9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8004ee:	75 c7                	jne    8004b7 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8004f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8004f6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8004fb:	5b                   	pop    %ebx
  8004fc:	5d                   	pop    %ebp
  8004fd:	c3                   	ret    

008004fe <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004fe:	55                   	push   %ebp
  8004ff:	89 e5                	mov    %esp,%ebp
  800501:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800504:	83 f8 1f             	cmp    $0x1f,%eax
  800507:	77 36                	ja     80053f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800509:	c1 e0 0c             	shl    $0xc,%eax
  80050c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800511:	89 c2                	mov    %eax,%edx
  800513:	c1 ea 16             	shr    $0x16,%edx
  800516:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80051d:	f6 c2 01             	test   $0x1,%dl
  800520:	74 24                	je     800546 <fd_lookup+0x48>
  800522:	89 c2                	mov    %eax,%edx
  800524:	c1 ea 0c             	shr    $0xc,%edx
  800527:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80052e:	f6 c2 01             	test   $0x1,%dl
  800531:	74 1a                	je     80054d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800533:	8b 55 0c             	mov    0xc(%ebp),%edx
  800536:	89 02                	mov    %eax,(%edx)
	return 0;
  800538:	b8 00 00 00 00       	mov    $0x0,%eax
  80053d:	eb 13                	jmp    800552 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80053f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800544:	eb 0c                	jmp    800552 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800546:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80054b:	eb 05                	jmp    800552 <fd_lookup+0x54>
  80054d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800552:	5d                   	pop    %ebp
  800553:	c3                   	ret    

00800554 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800554:	55                   	push   %ebp
  800555:	89 e5                	mov    %esp,%ebp
  800557:	53                   	push   %ebx
  800558:	83 ec 14             	sub    $0x14,%esp
  80055b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80055e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800561:	ba 00 00 00 00       	mov    $0x0,%edx
  800566:	eb 0e                	jmp    800576 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800568:	39 08                	cmp    %ecx,(%eax)
  80056a:	75 09                	jne    800575 <dev_lookup+0x21>
			*dev = devtab[i];
  80056c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80056e:	b8 00 00 00 00       	mov    $0x0,%eax
  800573:	eb 33                	jmp    8005a8 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800575:	42                   	inc    %edx
  800576:	8b 04 95 74 25 80 00 	mov    0x802574(,%edx,4),%eax
  80057d:	85 c0                	test   %eax,%eax
  80057f:	75 e7                	jne    800568 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800581:	a1 08 40 80 00       	mov    0x804008,%eax
  800586:	8b 40 48             	mov    0x48(%eax),%eax
  800589:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80058d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800591:	c7 04 24 f8 24 80 00 	movl   $0x8024f8,(%esp)
  800598:	e8 7f 12 00 00       	call   80181c <cprintf>
	*dev = 0;
  80059d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8005a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8005a8:	83 c4 14             	add    $0x14,%esp
  8005ab:	5b                   	pop    %ebx
  8005ac:	5d                   	pop    %ebp
  8005ad:	c3                   	ret    

008005ae <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8005ae:	55                   	push   %ebp
  8005af:	89 e5                	mov    %esp,%ebp
  8005b1:	56                   	push   %esi
  8005b2:	53                   	push   %ebx
  8005b3:	83 ec 30             	sub    $0x30,%esp
  8005b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b9:	8a 45 0c             	mov    0xc(%ebp),%al
  8005bc:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8005bf:	89 34 24             	mov    %esi,(%esp)
  8005c2:	e8 b9 fe ff ff       	call   800480 <fd2num>
  8005c7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8005ca:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ce:	89 04 24             	mov    %eax,(%esp)
  8005d1:	e8 28 ff ff ff       	call   8004fe <fd_lookup>
  8005d6:	89 c3                	mov    %eax,%ebx
  8005d8:	85 c0                	test   %eax,%eax
  8005da:	78 05                	js     8005e1 <fd_close+0x33>
	    || fd != fd2)
  8005dc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8005df:	74 0d                	je     8005ee <fd_close+0x40>
		return (must_exist ? r : 0);
  8005e1:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8005e5:	75 46                	jne    80062d <fd_close+0x7f>
  8005e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005ec:	eb 3f                	jmp    80062d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8005ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8005f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f5:	8b 06                	mov    (%esi),%eax
  8005f7:	89 04 24             	mov    %eax,(%esp)
  8005fa:	e8 55 ff ff ff       	call   800554 <dev_lookup>
  8005ff:	89 c3                	mov    %eax,%ebx
  800601:	85 c0                	test   %eax,%eax
  800603:	78 18                	js     80061d <fd_close+0x6f>
		if (dev->dev_close)
  800605:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800608:	8b 40 10             	mov    0x10(%eax),%eax
  80060b:	85 c0                	test   %eax,%eax
  80060d:	74 09                	je     800618 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80060f:	89 34 24             	mov    %esi,(%esp)
  800612:	ff d0                	call   *%eax
  800614:	89 c3                	mov    %eax,%ebx
  800616:	eb 05                	jmp    80061d <fd_close+0x6f>
		else
			r = 0;
  800618:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80061d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800621:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800628:	e8 2f fc ff ff       	call   80025c <sys_page_unmap>
	return r;
}
  80062d:	89 d8                	mov    %ebx,%eax
  80062f:	83 c4 30             	add    $0x30,%esp
  800632:	5b                   	pop    %ebx
  800633:	5e                   	pop    %esi
  800634:	5d                   	pop    %ebp
  800635:	c3                   	ret    

00800636 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800636:	55                   	push   %ebp
  800637:	89 e5                	mov    %esp,%ebp
  800639:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80063c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80063f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800643:	8b 45 08             	mov    0x8(%ebp),%eax
  800646:	89 04 24             	mov    %eax,(%esp)
  800649:	e8 b0 fe ff ff       	call   8004fe <fd_lookup>
  80064e:	85 c0                	test   %eax,%eax
  800650:	78 13                	js     800665 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800652:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800659:	00 
  80065a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80065d:	89 04 24             	mov    %eax,(%esp)
  800660:	e8 49 ff ff ff       	call   8005ae <fd_close>
}
  800665:	c9                   	leave  
  800666:	c3                   	ret    

00800667 <close_all>:

void
close_all(void)
{
  800667:	55                   	push   %ebp
  800668:	89 e5                	mov    %esp,%ebp
  80066a:	53                   	push   %ebx
  80066b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80066e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800673:	89 1c 24             	mov    %ebx,(%esp)
  800676:	e8 bb ff ff ff       	call   800636 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80067b:	43                   	inc    %ebx
  80067c:	83 fb 20             	cmp    $0x20,%ebx
  80067f:	75 f2                	jne    800673 <close_all+0xc>
		close(i);
}
  800681:	83 c4 14             	add    $0x14,%esp
  800684:	5b                   	pop    %ebx
  800685:	5d                   	pop    %ebp
  800686:	c3                   	ret    

00800687 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	57                   	push   %edi
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
  80068d:	83 ec 4c             	sub    $0x4c,%esp
  800690:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800693:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800696:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069a:	8b 45 08             	mov    0x8(%ebp),%eax
  80069d:	89 04 24             	mov    %eax,(%esp)
  8006a0:	e8 59 fe ff ff       	call   8004fe <fd_lookup>
  8006a5:	89 c3                	mov    %eax,%ebx
  8006a7:	85 c0                	test   %eax,%eax
  8006a9:	0f 88 e3 00 00 00    	js     800792 <dup+0x10b>
		return r;
	close(newfdnum);
  8006af:	89 3c 24             	mov    %edi,(%esp)
  8006b2:	e8 7f ff ff ff       	call   800636 <close>

	newfd = INDEX2FD(newfdnum);
  8006b7:	89 fe                	mov    %edi,%esi
  8006b9:	c1 e6 0c             	shl    $0xc,%esi
  8006bc:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8006c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006c5:	89 04 24             	mov    %eax,(%esp)
  8006c8:	e8 c3 fd ff ff       	call   800490 <fd2data>
  8006cd:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8006cf:	89 34 24             	mov    %esi,(%esp)
  8006d2:	e8 b9 fd ff ff       	call   800490 <fd2data>
  8006d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8006da:	89 d8                	mov    %ebx,%eax
  8006dc:	c1 e8 16             	shr    $0x16,%eax
  8006df:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8006e6:	a8 01                	test   $0x1,%al
  8006e8:	74 46                	je     800730 <dup+0xa9>
  8006ea:	89 d8                	mov    %ebx,%eax
  8006ec:	c1 e8 0c             	shr    $0xc,%eax
  8006ef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8006f6:	f6 c2 01             	test   $0x1,%dl
  8006f9:	74 35                	je     800730 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8006fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800702:	25 07 0e 00 00       	and    $0xe07,%eax
  800707:	89 44 24 10          	mov    %eax,0x10(%esp)
  80070b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80070e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800712:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800719:	00 
  80071a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800725:	e8 df fa ff ff       	call   800209 <sys_page_map>
  80072a:	89 c3                	mov    %eax,%ebx
  80072c:	85 c0                	test   %eax,%eax
  80072e:	78 3b                	js     80076b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800730:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800733:	89 c2                	mov    %eax,%edx
  800735:	c1 ea 0c             	shr    $0xc,%edx
  800738:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80073f:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800745:	89 54 24 10          	mov    %edx,0x10(%esp)
  800749:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80074d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800754:	00 
  800755:	89 44 24 04          	mov    %eax,0x4(%esp)
  800759:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800760:	e8 a4 fa ff ff       	call   800209 <sys_page_map>
  800765:	89 c3                	mov    %eax,%ebx
  800767:	85 c0                	test   %eax,%eax
  800769:	79 25                	jns    800790 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80076b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80076f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800776:	e8 e1 fa ff ff       	call   80025c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80077b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80077e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800782:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800789:	e8 ce fa ff ff       	call   80025c <sys_page_unmap>
	return r;
  80078e:	eb 02                	jmp    800792 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800790:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800792:	89 d8                	mov    %ebx,%eax
  800794:	83 c4 4c             	add    $0x4c,%esp
  800797:	5b                   	pop    %ebx
  800798:	5e                   	pop    %esi
  800799:	5f                   	pop    %edi
  80079a:	5d                   	pop    %ebp
  80079b:	c3                   	ret    

0080079c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	53                   	push   %ebx
  8007a0:	83 ec 24             	sub    $0x24,%esp
  8007a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ad:	89 1c 24             	mov    %ebx,(%esp)
  8007b0:	e8 49 fd ff ff       	call   8004fe <fd_lookup>
  8007b5:	85 c0                	test   %eax,%eax
  8007b7:	78 6d                	js     800826 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c3:	8b 00                	mov    (%eax),%eax
  8007c5:	89 04 24             	mov    %eax,(%esp)
  8007c8:	e8 87 fd ff ff       	call   800554 <dev_lookup>
  8007cd:	85 c0                	test   %eax,%eax
  8007cf:	78 55                	js     800826 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8007d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d4:	8b 50 08             	mov    0x8(%eax),%edx
  8007d7:	83 e2 03             	and    $0x3,%edx
  8007da:	83 fa 01             	cmp    $0x1,%edx
  8007dd:	75 23                	jne    800802 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8007df:	a1 08 40 80 00       	mov    0x804008,%eax
  8007e4:	8b 40 48             	mov    0x48(%eax),%eax
  8007e7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ef:	c7 04 24 39 25 80 00 	movl   $0x802539,(%esp)
  8007f6:	e8 21 10 00 00       	call   80181c <cprintf>
		return -E_INVAL;
  8007fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800800:	eb 24                	jmp    800826 <read+0x8a>
	}
	if (!dev->dev_read)
  800802:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800805:	8b 52 08             	mov    0x8(%edx),%edx
  800808:	85 d2                	test   %edx,%edx
  80080a:	74 15                	je     800821 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80080c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80080f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800813:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800816:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80081a:	89 04 24             	mov    %eax,(%esp)
  80081d:	ff d2                	call   *%edx
  80081f:	eb 05                	jmp    800826 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800821:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800826:	83 c4 24             	add    $0x24,%esp
  800829:	5b                   	pop    %ebx
  80082a:	5d                   	pop    %ebp
  80082b:	c3                   	ret    

0080082c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	57                   	push   %edi
  800830:	56                   	push   %esi
  800831:	53                   	push   %ebx
  800832:	83 ec 1c             	sub    $0x1c,%esp
  800835:	8b 7d 08             	mov    0x8(%ebp),%edi
  800838:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80083b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800840:	eb 23                	jmp    800865 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800842:	89 f0                	mov    %esi,%eax
  800844:	29 d8                	sub    %ebx,%eax
  800846:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084d:	01 d8                	add    %ebx,%eax
  80084f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800853:	89 3c 24             	mov    %edi,(%esp)
  800856:	e8 41 ff ff ff       	call   80079c <read>
		if (m < 0)
  80085b:	85 c0                	test   %eax,%eax
  80085d:	78 10                	js     80086f <readn+0x43>
			return m;
		if (m == 0)
  80085f:	85 c0                	test   %eax,%eax
  800861:	74 0a                	je     80086d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800863:	01 c3                	add    %eax,%ebx
  800865:	39 f3                	cmp    %esi,%ebx
  800867:	72 d9                	jb     800842 <readn+0x16>
  800869:	89 d8                	mov    %ebx,%eax
  80086b:	eb 02                	jmp    80086f <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80086d:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80086f:	83 c4 1c             	add    $0x1c,%esp
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5f                   	pop    %edi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	53                   	push   %ebx
  80087b:	83 ec 24             	sub    $0x24,%esp
  80087e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800881:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800884:	89 44 24 04          	mov    %eax,0x4(%esp)
  800888:	89 1c 24             	mov    %ebx,(%esp)
  80088b:	e8 6e fc ff ff       	call   8004fe <fd_lookup>
  800890:	85 c0                	test   %eax,%eax
  800892:	78 68                	js     8008fc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800894:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800897:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80089e:	8b 00                	mov    (%eax),%eax
  8008a0:	89 04 24             	mov    %eax,(%esp)
  8008a3:	e8 ac fc ff ff       	call   800554 <dev_lookup>
  8008a8:	85 c0                	test   %eax,%eax
  8008aa:	78 50                	js     8008fc <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8008ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008af:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8008b3:	75 23                	jne    8008d8 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8008b5:	a1 08 40 80 00       	mov    0x804008,%eax
  8008ba:	8b 40 48             	mov    0x48(%eax),%eax
  8008bd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c5:	c7 04 24 55 25 80 00 	movl   $0x802555,(%esp)
  8008cc:	e8 4b 0f 00 00       	call   80181c <cprintf>
		return -E_INVAL;
  8008d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d6:	eb 24                	jmp    8008fc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8008d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008db:	8b 52 0c             	mov    0xc(%edx),%edx
  8008de:	85 d2                	test   %edx,%edx
  8008e0:	74 15                	je     8008f7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008e5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ec:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008f0:	89 04 24             	mov    %eax,(%esp)
  8008f3:	ff d2                	call   *%edx
  8008f5:	eb 05                	jmp    8008fc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8008f7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8008fc:	83 c4 24             	add    $0x24,%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <seek>:

int
seek(int fdnum, off_t offset)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800908:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80090b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090f:	8b 45 08             	mov    0x8(%ebp),%eax
  800912:	89 04 24             	mov    %eax,(%esp)
  800915:	e8 e4 fb ff ff       	call   8004fe <fd_lookup>
  80091a:	85 c0                	test   %eax,%eax
  80091c:	78 0e                	js     80092c <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80091e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800921:	8b 55 0c             	mov    0xc(%ebp),%edx
  800924:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800927:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092c:	c9                   	leave  
  80092d:	c3                   	ret    

0080092e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80092e:	55                   	push   %ebp
  80092f:	89 e5                	mov    %esp,%ebp
  800931:	53                   	push   %ebx
  800932:	83 ec 24             	sub    $0x24,%esp
  800935:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800938:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80093b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093f:	89 1c 24             	mov    %ebx,(%esp)
  800942:	e8 b7 fb ff ff       	call   8004fe <fd_lookup>
  800947:	85 c0                	test   %eax,%eax
  800949:	78 61                	js     8009ac <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80094b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80094e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800952:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800955:	8b 00                	mov    (%eax),%eax
  800957:	89 04 24             	mov    %eax,(%esp)
  80095a:	e8 f5 fb ff ff       	call   800554 <dev_lookup>
  80095f:	85 c0                	test   %eax,%eax
  800961:	78 49                	js     8009ac <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800963:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800966:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80096a:	75 23                	jne    80098f <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80096c:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800971:	8b 40 48             	mov    0x48(%eax),%eax
  800974:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800978:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097c:	c7 04 24 18 25 80 00 	movl   $0x802518,(%esp)
  800983:	e8 94 0e 00 00       	call   80181c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800988:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80098d:	eb 1d                	jmp    8009ac <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80098f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800992:	8b 52 18             	mov    0x18(%edx),%edx
  800995:	85 d2                	test   %edx,%edx
  800997:	74 0e                	je     8009a7 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800999:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80099c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009a0:	89 04 24             	mov    %eax,(%esp)
  8009a3:	ff d2                	call   *%edx
  8009a5:	eb 05                	jmp    8009ac <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8009a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8009ac:	83 c4 24             	add    $0x24,%esp
  8009af:	5b                   	pop    %ebx
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	53                   	push   %ebx
  8009b6:	83 ec 24             	sub    $0x24,%esp
  8009b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8009bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c6:	89 04 24             	mov    %eax,(%esp)
  8009c9:	e8 30 fb ff ff       	call   8004fe <fd_lookup>
  8009ce:	85 c0                	test   %eax,%eax
  8009d0:	78 52                	js     800a24 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009dc:	8b 00                	mov    (%eax),%eax
  8009de:	89 04 24             	mov    %eax,(%esp)
  8009e1:	e8 6e fb ff ff       	call   800554 <dev_lookup>
  8009e6:	85 c0                	test   %eax,%eax
  8009e8:	78 3a                	js     800a24 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8009ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ed:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8009f1:	74 2c                	je     800a1f <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8009f3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8009f6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8009fd:	00 00 00 
	stat->st_isdir = 0;
  800a00:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800a07:	00 00 00 
	stat->st_dev = dev;
  800a0a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800a10:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a14:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800a17:	89 14 24             	mov    %edx,(%esp)
  800a1a:	ff 50 14             	call   *0x14(%eax)
  800a1d:	eb 05                	jmp    800a24 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800a1f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800a24:	83 c4 24             	add    $0x24,%esp
  800a27:	5b                   	pop    %ebx
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800a32:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a39:	00 
  800a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3d:	89 04 24             	mov    %eax,(%esp)
  800a40:	e8 2a 02 00 00       	call   800c6f <open>
  800a45:	89 c3                	mov    %eax,%ebx
  800a47:	85 c0                	test   %eax,%eax
  800a49:	78 1b                	js     800a66 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800a4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a52:	89 1c 24             	mov    %ebx,(%esp)
  800a55:	e8 58 ff ff ff       	call   8009b2 <fstat>
  800a5a:	89 c6                	mov    %eax,%esi
	close(fd);
  800a5c:	89 1c 24             	mov    %ebx,(%esp)
  800a5f:	e8 d2 fb ff ff       	call   800636 <close>
	return r;
  800a64:	89 f3                	mov    %esi,%ebx
}
  800a66:	89 d8                	mov    %ebx,%eax
  800a68:	83 c4 10             	add    $0x10,%esp
  800a6b:	5b                   	pop    %ebx
  800a6c:	5e                   	pop    %esi
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    
	...

00800a70 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	83 ec 10             	sub    $0x10,%esp
  800a78:	89 c3                	mov    %eax,%ebx
  800a7a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a7c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a83:	75 11                	jne    800a96 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a85:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a8c:	e8 4e 17 00 00       	call   8021df <ipc_find_env>
  800a91:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a96:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a9d:	00 
  800a9e:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800aa5:	00 
  800aa6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aaa:	a1 00 40 80 00       	mov    0x804000,%eax
  800aaf:	89 04 24             	mov    %eax,(%esp)
  800ab2:	e8 a5 16 00 00       	call   80215c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ab7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800abe:	00 
  800abf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ac3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800aca:	e8 1d 16 00 00       	call   8020ec <ipc_recv>
}
  800acf:	83 c4 10             	add    $0x10,%esp
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8b 40 0c             	mov    0xc(%eax),%eax
  800ae2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ae7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aea:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800aef:	ba 00 00 00 00       	mov    $0x0,%edx
  800af4:	b8 02 00 00 00       	mov    $0x2,%eax
  800af9:	e8 72 ff ff ff       	call   800a70 <fsipc>
}
  800afe:	c9                   	leave  
  800aff:	c3                   	ret    

00800b00 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	8b 40 0c             	mov    0xc(%eax),%eax
  800b0c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800b11:	ba 00 00 00 00       	mov    $0x0,%edx
  800b16:	b8 06 00 00 00       	mov    $0x6,%eax
  800b1b:	e8 50 ff ff ff       	call   800a70 <fsipc>
}
  800b20:	c9                   	leave  
  800b21:	c3                   	ret    

00800b22 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	53                   	push   %ebx
  800b26:	83 ec 14             	sub    $0x14,%esp
  800b29:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	8b 40 0c             	mov    0xc(%eax),%eax
  800b32:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800b37:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3c:	b8 05 00 00 00       	mov    $0x5,%eax
  800b41:	e8 2a ff ff ff       	call   800a70 <fsipc>
  800b46:	85 c0                	test   %eax,%eax
  800b48:	78 2b                	js     800b75 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800b4a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b51:	00 
  800b52:	89 1c 24             	mov    %ebx,(%esp)
  800b55:	e8 6d 12 00 00       	call   801dc7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b5a:	a1 80 50 80 00       	mov    0x805080,%eax
  800b5f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b65:	a1 84 50 80 00       	mov    0x805084,%eax
  800b6a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800b70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b75:	83 c4 14             	add    $0x14,%esp
  800b78:	5b                   	pop    %ebx
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	83 ec 18             	sub    $0x18,%esp
  800b81:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	8b 52 0c             	mov    0xc(%edx),%edx
  800b8a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800b90:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  800b95:	89 c2                	mov    %eax,%edx
  800b97:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800b9c:	76 05                	jbe    800ba3 <devfile_write+0x28>
  800b9e:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  800ba3:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ba7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800baa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bae:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800bb5:	e8 f0 13 00 00       	call   801faa <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800bba:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbf:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc4:	e8 a7 fe ff ff       	call   800a70 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    

00800bcb <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
  800bd0:	83 ec 10             	sub    $0x10,%esp
  800bd3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd9:	8b 40 0c             	mov    0xc(%eax),%eax
  800bdc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800be1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800be7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bec:	b8 03 00 00 00       	mov    $0x3,%eax
  800bf1:	e8 7a fe ff ff       	call   800a70 <fsipc>
  800bf6:	89 c3                	mov    %eax,%ebx
  800bf8:	85 c0                	test   %eax,%eax
  800bfa:	78 6a                	js     800c66 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800bfc:	39 c6                	cmp    %eax,%esi
  800bfe:	73 24                	jae    800c24 <devfile_read+0x59>
  800c00:	c7 44 24 0c 88 25 80 	movl   $0x802588,0xc(%esp)
  800c07:	00 
  800c08:	c7 44 24 08 8f 25 80 	movl   $0x80258f,0x8(%esp)
  800c0f:	00 
  800c10:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800c17:	00 
  800c18:	c7 04 24 a4 25 80 00 	movl   $0x8025a4,(%esp)
  800c1f:	e8 00 0b 00 00       	call   801724 <_panic>
	assert(r <= PGSIZE);
  800c24:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c29:	7e 24                	jle    800c4f <devfile_read+0x84>
  800c2b:	c7 44 24 0c af 25 80 	movl   $0x8025af,0xc(%esp)
  800c32:	00 
  800c33:	c7 44 24 08 8f 25 80 	movl   $0x80258f,0x8(%esp)
  800c3a:	00 
  800c3b:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800c42:	00 
  800c43:	c7 04 24 a4 25 80 00 	movl   $0x8025a4,(%esp)
  800c4a:	e8 d5 0a 00 00       	call   801724 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c53:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c5a:	00 
  800c5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5e:	89 04 24             	mov    %eax,(%esp)
  800c61:	e8 da 12 00 00       	call   801f40 <memmove>
	return r;
}
  800c66:	89 d8                	mov    %ebx,%eax
  800c68:	83 c4 10             	add    $0x10,%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 20             	sub    $0x20,%esp
  800c77:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c7a:	89 34 24             	mov    %esi,(%esp)
  800c7d:	e8 12 11 00 00       	call   801d94 <strlen>
  800c82:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c87:	7f 60                	jg     800ce9 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c8c:	89 04 24             	mov    %eax,(%esp)
  800c8f:	e8 17 f8 ff ff       	call   8004ab <fd_alloc>
  800c94:	89 c3                	mov    %eax,%ebx
  800c96:	85 c0                	test   %eax,%eax
  800c98:	78 54                	js     800cee <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800c9a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c9e:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800ca5:	e8 1d 11 00 00       	call   801dc7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800caa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cad:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800cb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cb5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cba:	e8 b1 fd ff ff       	call   800a70 <fsipc>
  800cbf:	89 c3                	mov    %eax,%ebx
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	79 15                	jns    800cda <open+0x6b>
		fd_close(fd, 0);
  800cc5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ccc:	00 
  800ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd0:	89 04 24             	mov    %eax,(%esp)
  800cd3:	e8 d6 f8 ff ff       	call   8005ae <fd_close>
		return r;
  800cd8:	eb 14                	jmp    800cee <open+0x7f>
	}

	return fd2num(fd);
  800cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cdd:	89 04 24             	mov    %eax,(%esp)
  800ce0:	e8 9b f7 ff ff       	call   800480 <fd2num>
  800ce5:	89 c3                	mov    %eax,%ebx
  800ce7:	eb 05                	jmp    800cee <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800ce9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800cee:	89 d8                	mov    %ebx,%eax
  800cf0:	83 c4 20             	add    $0x20,%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800cfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800d02:	b8 08 00 00 00       	mov    $0x8,%eax
  800d07:	e8 64 fd ff ff       	call   800a70 <fsipc>
}
  800d0c:	c9                   	leave  
  800d0d:	c3                   	ret    
	...

00800d10 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800d16:	c7 44 24 04 bb 25 80 	movl   $0x8025bb,0x4(%esp)
  800d1d:	00 
  800d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d21:	89 04 24             	mov    %eax,(%esp)
  800d24:	e8 9e 10 00 00       	call   801dc7 <strcpy>
	return 0;
}
  800d29:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2e:	c9                   	leave  
  800d2f:	c3                   	ret    

00800d30 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	53                   	push   %ebx
  800d34:	83 ec 14             	sub    $0x14,%esp
  800d37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800d3a:	89 1c 24             	mov    %ebx,(%esp)
  800d3d:	e8 e2 14 00 00       	call   802224 <pageref>
  800d42:	83 f8 01             	cmp    $0x1,%eax
  800d45:	75 0d                	jne    800d54 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  800d47:	8b 43 0c             	mov    0xc(%ebx),%eax
  800d4a:	89 04 24             	mov    %eax,(%esp)
  800d4d:	e8 1f 03 00 00       	call   801071 <nsipc_close>
  800d52:	eb 05                	jmp    800d59 <devsock_close+0x29>
	else
		return 0;
  800d54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d59:	83 c4 14             	add    $0x14,%esp
  800d5c:	5b                   	pop    %ebx
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800d65:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d6c:	00 
  800d6d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d70:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7e:	8b 40 0c             	mov    0xc(%eax),%eax
  800d81:	89 04 24             	mov    %eax,(%esp)
  800d84:	e8 e3 03 00 00       	call   80116c <nsipc_send>
}
  800d89:	c9                   	leave  
  800d8a:	c3                   	ret    

00800d8b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800d91:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d98:	00 
  800d99:	8b 45 10             	mov    0x10(%ebp),%eax
  800d9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800da0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da7:	8b 45 08             	mov    0x8(%ebp),%eax
  800daa:	8b 40 0c             	mov    0xc(%eax),%eax
  800dad:	89 04 24             	mov    %eax,(%esp)
  800db0:	e8 37 03 00 00       	call   8010ec <nsipc_recv>
}
  800db5:	c9                   	leave  
  800db6:	c3                   	ret    

00800db7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
  800dba:	56                   	push   %esi
  800dbb:	53                   	push   %ebx
  800dbc:	83 ec 20             	sub    $0x20,%esp
  800dbf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800dc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dc4:	89 04 24             	mov    %eax,(%esp)
  800dc7:	e8 df f6 ff ff       	call   8004ab <fd_alloc>
  800dcc:	89 c3                	mov    %eax,%ebx
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	78 21                	js     800df3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800dd2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800dd9:	00 
  800dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ddd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800de8:	e8 c8 f3 ff ff       	call   8001b5 <sys_page_alloc>
  800ded:	89 c3                	mov    %eax,%ebx
  800def:	85 c0                	test   %eax,%eax
  800df1:	79 0a                	jns    800dfd <alloc_sockfd+0x46>
		nsipc_close(sockid);
  800df3:	89 34 24             	mov    %esi,(%esp)
  800df6:	e8 76 02 00 00       	call   801071 <nsipc_close>
		return r;
  800dfb:	eb 22                	jmp    800e1f <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800dfd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e06:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800e12:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800e15:	89 04 24             	mov    %eax,(%esp)
  800e18:	e8 63 f6 ff ff       	call   800480 <fd2num>
  800e1d:	89 c3                	mov    %eax,%ebx
}
  800e1f:	89 d8                	mov    %ebx,%eax
  800e21:	83 c4 20             	add    $0x20,%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5d                   	pop    %ebp
  800e27:	c3                   	ret    

00800e28 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800e28:	55                   	push   %ebp
  800e29:	89 e5                	mov    %esp,%ebp
  800e2b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800e2e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800e31:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e35:	89 04 24             	mov    %eax,(%esp)
  800e38:	e8 c1 f6 ff ff       	call   8004fe <fd_lookup>
  800e3d:	85 c0                	test   %eax,%eax
  800e3f:	78 17                	js     800e58 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e44:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e4a:	39 10                	cmp    %edx,(%eax)
  800e4c:	75 05                	jne    800e53 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800e4e:	8b 40 0c             	mov    0xc(%eax),%eax
  800e51:	eb 05                	jmp    800e58 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800e53:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800e58:	c9                   	leave  
  800e59:	c3                   	ret    

00800e5a <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e60:	8b 45 08             	mov    0x8(%ebp),%eax
  800e63:	e8 c0 ff ff ff       	call   800e28 <fd2sockid>
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	78 1f                	js     800e8b <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800e6c:	8b 55 10             	mov    0x10(%ebp),%edx
  800e6f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e76:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e7a:	89 04 24             	mov    %eax,(%esp)
  800e7d:	e8 38 01 00 00       	call   800fba <nsipc_accept>
  800e82:	85 c0                	test   %eax,%eax
  800e84:	78 05                	js     800e8b <accept+0x31>
		return r;
	return alloc_sockfd(r);
  800e86:	e8 2c ff ff ff       	call   800db7 <alloc_sockfd>
}
  800e8b:	c9                   	leave  
  800e8c:	c3                   	ret    

00800e8d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e93:	8b 45 08             	mov    0x8(%ebp),%eax
  800e96:	e8 8d ff ff ff       	call   800e28 <fd2sockid>
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	78 16                	js     800eb5 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  800e9f:	8b 55 10             	mov    0x10(%ebp),%edx
  800ea2:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ea6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ead:	89 04 24             	mov    %eax,(%esp)
  800eb0:	e8 5b 01 00 00       	call   801010 <nsipc_bind>
}
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <shutdown>:

int
shutdown(int s, int how)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec0:	e8 63 ff ff ff       	call   800e28 <fd2sockid>
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	78 0f                	js     800ed8 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800ec9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ecc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ed0:	89 04 24             	mov    %eax,(%esp)
  800ed3:	e8 77 01 00 00       	call   80104f <nsipc_shutdown>
}
  800ed8:	c9                   	leave  
  800ed9:	c3                   	ret    

00800eda <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee3:	e8 40 ff ff ff       	call   800e28 <fd2sockid>
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	78 16                	js     800f02 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  800eec:	8b 55 10             	mov    0x10(%ebp),%edx
  800eef:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ef3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ef6:	89 54 24 04          	mov    %edx,0x4(%esp)
  800efa:	89 04 24             	mov    %eax,(%esp)
  800efd:	e8 89 01 00 00       	call   80108b <nsipc_connect>
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <listen>:

int
listen(int s, int backlog)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0d:	e8 16 ff ff ff       	call   800e28 <fd2sockid>
  800f12:	85 c0                	test   %eax,%eax
  800f14:	78 0f                	js     800f25 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800f16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f19:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f1d:	89 04 24             	mov    %eax,(%esp)
  800f20:	e8 a5 01 00 00       	call   8010ca <nsipc_listen>
}
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    

00800f27 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800f2d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f30:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f34:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f37:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3e:	89 04 24             	mov    %eax,(%esp)
  800f41:	e8 99 02 00 00       	call   8011df <nsipc_socket>
  800f46:	85 c0                	test   %eax,%eax
  800f48:	78 05                	js     800f4f <socket+0x28>
		return r;
	return alloc_sockfd(r);
  800f4a:	e8 68 fe ff ff       	call   800db7 <alloc_sockfd>
}
  800f4f:	c9                   	leave  
  800f50:	c3                   	ret    
  800f51:	00 00                	add    %al,(%eax)
	...

00800f54 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	53                   	push   %ebx
  800f58:	83 ec 14             	sub    $0x14,%esp
  800f5b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800f5d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800f64:	75 11                	jne    800f77 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800f66:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f6d:	e8 6d 12 00 00       	call   8021df <ipc_find_env>
  800f72:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800f77:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800f7e:	00 
  800f7f:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  800f86:	00 
  800f87:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f8b:	a1 04 40 80 00       	mov    0x804004,%eax
  800f90:	89 04 24             	mov    %eax,(%esp)
  800f93:	e8 c4 11 00 00       	call   80215c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800f98:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f9f:	00 
  800fa0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fa7:	00 
  800fa8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800faf:	e8 38 11 00 00       	call   8020ec <ipc_recv>
}
  800fb4:	83 c4 14             	add    $0x14,%esp
  800fb7:	5b                   	pop    %ebx
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	56                   	push   %esi
  800fbe:	53                   	push   %ebx
  800fbf:	83 ec 10             	sub    $0x10,%esp
  800fc2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800fc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800fcd:	8b 06                	mov    (%esi),%eax
  800fcf:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800fd4:	b8 01 00 00 00       	mov    $0x1,%eax
  800fd9:	e8 76 ff ff ff       	call   800f54 <nsipc>
  800fde:	89 c3                	mov    %eax,%ebx
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	78 23                	js     801007 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800fe4:	a1 10 60 80 00       	mov    0x806010,%eax
  800fe9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fed:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  800ff4:	00 
  800ff5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff8:	89 04 24             	mov    %eax,(%esp)
  800ffb:	e8 40 0f 00 00       	call   801f40 <memmove>
		*addrlen = ret->ret_addrlen;
  801000:	a1 10 60 80 00       	mov    0x806010,%eax
  801005:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801007:	89 d8                	mov    %ebx,%eax
  801009:	83 c4 10             	add    $0x10,%esp
  80100c:	5b                   	pop    %ebx
  80100d:	5e                   	pop    %esi
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	53                   	push   %ebx
  801014:	83 ec 14             	sub    $0x14,%esp
  801017:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80101a:	8b 45 08             	mov    0x8(%ebp),%eax
  80101d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801022:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801026:	8b 45 0c             	mov    0xc(%ebp),%eax
  801029:	89 44 24 04          	mov    %eax,0x4(%esp)
  80102d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801034:	e8 07 0f 00 00       	call   801f40 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801039:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80103f:	b8 02 00 00 00       	mov    $0x2,%eax
  801044:	e8 0b ff ff ff       	call   800f54 <nsipc>
}
  801049:	83 c4 14             	add    $0x14,%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    

0080104f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801055:	8b 45 08             	mov    0x8(%ebp),%eax
  801058:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80105d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801060:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801065:	b8 03 00 00 00       	mov    $0x3,%eax
  80106a:	e8 e5 fe ff ff       	call   800f54 <nsipc>
}
  80106f:	c9                   	leave  
  801070:	c3                   	ret    

00801071 <nsipc_close>:

int
nsipc_close(int s)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801077:	8b 45 08             	mov    0x8(%ebp),%eax
  80107a:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80107f:	b8 04 00 00 00       	mov    $0x4,%eax
  801084:	e8 cb fe ff ff       	call   800f54 <nsipc>
}
  801089:	c9                   	leave  
  80108a:	c3                   	ret    

0080108b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	53                   	push   %ebx
  80108f:	83 ec 14             	sub    $0x14,%esp
  801092:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801095:	8b 45 08             	mov    0x8(%ebp),%eax
  801098:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80109d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8010a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010a8:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8010af:	e8 8c 0e 00 00       	call   801f40 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8010b4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8010ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8010bf:	e8 90 fe ff ff       	call   800f54 <nsipc>
}
  8010c4:	83 c4 14             	add    $0x14,%esp
  8010c7:	5b                   	pop    %ebx
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8010d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8010d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010db:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8010e0:	b8 06 00 00 00       	mov    $0x6,%eax
  8010e5:	e8 6a fe ff ff       	call   800f54 <nsipc>
}
  8010ea:	c9                   	leave  
  8010eb:	c3                   	ret    

008010ec <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	56                   	push   %esi
  8010f0:	53                   	push   %ebx
  8010f1:	83 ec 10             	sub    $0x10,%esp
  8010f4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8010f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fa:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8010ff:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801105:	8b 45 14             	mov    0x14(%ebp),%eax
  801108:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80110d:	b8 07 00 00 00       	mov    $0x7,%eax
  801112:	e8 3d fe ff ff       	call   800f54 <nsipc>
  801117:	89 c3                	mov    %eax,%ebx
  801119:	85 c0                	test   %eax,%eax
  80111b:	78 46                	js     801163 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  80111d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801122:	7f 04                	jg     801128 <nsipc_recv+0x3c>
  801124:	39 c6                	cmp    %eax,%esi
  801126:	7d 24                	jge    80114c <nsipc_recv+0x60>
  801128:	c7 44 24 0c c7 25 80 	movl   $0x8025c7,0xc(%esp)
  80112f:	00 
  801130:	c7 44 24 08 8f 25 80 	movl   $0x80258f,0x8(%esp)
  801137:	00 
  801138:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80113f:	00 
  801140:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  801147:	e8 d8 05 00 00       	call   801724 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80114c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801150:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801157:	00 
  801158:	8b 45 0c             	mov    0xc(%ebp),%eax
  80115b:	89 04 24             	mov    %eax,(%esp)
  80115e:	e8 dd 0d 00 00       	call   801f40 <memmove>
	}

	return r;
}
  801163:	89 d8                	mov    %ebx,%eax
  801165:	83 c4 10             	add    $0x10,%esp
  801168:	5b                   	pop    %ebx
  801169:	5e                   	pop    %esi
  80116a:	5d                   	pop    %ebp
  80116b:	c3                   	ret    

0080116c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	53                   	push   %ebx
  801170:	83 ec 14             	sub    $0x14,%esp
  801173:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801176:	8b 45 08             	mov    0x8(%ebp),%eax
  801179:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80117e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801184:	7e 24                	jle    8011aa <nsipc_send+0x3e>
  801186:	c7 44 24 0c e8 25 80 	movl   $0x8025e8,0xc(%esp)
  80118d:	00 
  80118e:	c7 44 24 08 8f 25 80 	movl   $0x80258f,0x8(%esp)
  801195:	00 
  801196:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80119d:	00 
  80119e:	c7 04 24 dc 25 80 00 	movl   $0x8025dc,(%esp)
  8011a5:	e8 7a 05 00 00       	call   801724 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8011aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b5:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8011bc:	e8 7f 0d 00 00       	call   801f40 <memmove>
	nsipcbuf.send.req_size = size;
  8011c1:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8011c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8011ca:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8011cf:	b8 08 00 00 00       	mov    $0x8,%eax
  8011d4:	e8 7b fd ff ff       	call   800f54 <nsipc>
}
  8011d9:	83 c4 14             	add    $0x14,%esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8011e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8011ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f0:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8011f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8011f8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8011fd:	b8 09 00 00 00       	mov    $0x9,%eax
  801202:	e8 4d fd ff ff       	call   800f54 <nsipc>
}
  801207:	c9                   	leave  
  801208:	c3                   	ret    
  801209:	00 00                	add    %al,(%eax)
	...

0080120c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	56                   	push   %esi
  801210:	53                   	push   %ebx
  801211:	83 ec 10             	sub    $0x10,%esp
  801214:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801217:	8b 45 08             	mov    0x8(%ebp),%eax
  80121a:	89 04 24             	mov    %eax,(%esp)
  80121d:	e8 6e f2 ff ff       	call   800490 <fd2data>
  801222:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801224:	c7 44 24 04 f4 25 80 	movl   $0x8025f4,0x4(%esp)
  80122b:	00 
  80122c:	89 34 24             	mov    %esi,(%esp)
  80122f:	e8 93 0b 00 00       	call   801dc7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801234:	8b 43 04             	mov    0x4(%ebx),%eax
  801237:	2b 03                	sub    (%ebx),%eax
  801239:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80123f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801246:	00 00 00 
	stat->st_dev = &devpipe;
  801249:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801250:	30 80 00 
	return 0;
}
  801253:	b8 00 00 00 00       	mov    $0x0,%eax
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	5b                   	pop    %ebx
  80125c:	5e                   	pop    %esi
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	53                   	push   %ebx
  801263:	83 ec 14             	sub    $0x14,%esp
  801266:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801269:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80126d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801274:	e8 e3 ef ff ff       	call   80025c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801279:	89 1c 24             	mov    %ebx,(%esp)
  80127c:	e8 0f f2 ff ff       	call   800490 <fd2data>
  801281:	89 44 24 04          	mov    %eax,0x4(%esp)
  801285:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80128c:	e8 cb ef ff ff       	call   80025c <sys_page_unmap>
}
  801291:	83 c4 14             	add    $0x14,%esp
  801294:	5b                   	pop    %ebx
  801295:	5d                   	pop    %ebp
  801296:	c3                   	ret    

00801297 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801297:	55                   	push   %ebp
  801298:	89 e5                	mov    %esp,%ebp
  80129a:	57                   	push   %edi
  80129b:	56                   	push   %esi
  80129c:	53                   	push   %ebx
  80129d:	83 ec 2c             	sub    $0x2c,%esp
  8012a0:	89 c7                	mov    %eax,%edi
  8012a2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8012a5:	a1 08 40 80 00       	mov    0x804008,%eax
  8012aa:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8012ad:	89 3c 24             	mov    %edi,(%esp)
  8012b0:	e8 6f 0f 00 00       	call   802224 <pageref>
  8012b5:	89 c6                	mov    %eax,%esi
  8012b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012ba:	89 04 24             	mov    %eax,(%esp)
  8012bd:	e8 62 0f 00 00       	call   802224 <pageref>
  8012c2:	39 c6                	cmp    %eax,%esi
  8012c4:	0f 94 c0             	sete   %al
  8012c7:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8012ca:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8012d0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8012d3:	39 cb                	cmp    %ecx,%ebx
  8012d5:	75 08                	jne    8012df <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8012d7:	83 c4 2c             	add    $0x2c,%esp
  8012da:	5b                   	pop    %ebx
  8012db:	5e                   	pop    %esi
  8012dc:	5f                   	pop    %edi
  8012dd:	5d                   	pop    %ebp
  8012de:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8012df:	83 f8 01             	cmp    $0x1,%eax
  8012e2:	75 c1                	jne    8012a5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8012e4:	8b 42 58             	mov    0x58(%edx),%eax
  8012e7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8012ee:	00 
  8012ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012f7:	c7 04 24 fb 25 80 00 	movl   $0x8025fb,(%esp)
  8012fe:	e8 19 05 00 00       	call   80181c <cprintf>
  801303:	eb a0                	jmp    8012a5 <_pipeisclosed+0xe>

00801305 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	57                   	push   %edi
  801309:	56                   	push   %esi
  80130a:	53                   	push   %ebx
  80130b:	83 ec 1c             	sub    $0x1c,%esp
  80130e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801311:	89 34 24             	mov    %esi,(%esp)
  801314:	e8 77 f1 ff ff       	call   800490 <fd2data>
  801319:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80131b:	bf 00 00 00 00       	mov    $0x0,%edi
  801320:	eb 3c                	jmp    80135e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801322:	89 da                	mov    %ebx,%edx
  801324:	89 f0                	mov    %esi,%eax
  801326:	e8 6c ff ff ff       	call   801297 <_pipeisclosed>
  80132b:	85 c0                	test   %eax,%eax
  80132d:	75 38                	jne    801367 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80132f:	e8 62 ee ff ff       	call   800196 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801334:	8b 43 04             	mov    0x4(%ebx),%eax
  801337:	8b 13                	mov    (%ebx),%edx
  801339:	83 c2 20             	add    $0x20,%edx
  80133c:	39 d0                	cmp    %edx,%eax
  80133e:	73 e2                	jae    801322 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801340:	8b 55 0c             	mov    0xc(%ebp),%edx
  801343:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801346:	89 c2                	mov    %eax,%edx
  801348:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80134e:	79 05                	jns    801355 <devpipe_write+0x50>
  801350:	4a                   	dec    %edx
  801351:	83 ca e0             	or     $0xffffffe0,%edx
  801354:	42                   	inc    %edx
  801355:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801359:	40                   	inc    %eax
  80135a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80135d:	47                   	inc    %edi
  80135e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801361:	75 d1                	jne    801334 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801363:	89 f8                	mov    %edi,%eax
  801365:	eb 05                	jmp    80136c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801367:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80136c:	83 c4 1c             	add    $0x1c,%esp
  80136f:	5b                   	pop    %ebx
  801370:	5e                   	pop    %esi
  801371:	5f                   	pop    %edi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	57                   	push   %edi
  801378:	56                   	push   %esi
  801379:	53                   	push   %ebx
  80137a:	83 ec 1c             	sub    $0x1c,%esp
  80137d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801380:	89 3c 24             	mov    %edi,(%esp)
  801383:	e8 08 f1 ff ff       	call   800490 <fd2data>
  801388:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80138a:	be 00 00 00 00       	mov    $0x0,%esi
  80138f:	eb 3a                	jmp    8013cb <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801391:	85 f6                	test   %esi,%esi
  801393:	74 04                	je     801399 <devpipe_read+0x25>
				return i;
  801395:	89 f0                	mov    %esi,%eax
  801397:	eb 40                	jmp    8013d9 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801399:	89 da                	mov    %ebx,%edx
  80139b:	89 f8                	mov    %edi,%eax
  80139d:	e8 f5 fe ff ff       	call   801297 <_pipeisclosed>
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	75 2e                	jne    8013d4 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8013a6:	e8 eb ed ff ff       	call   800196 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8013ab:	8b 03                	mov    (%ebx),%eax
  8013ad:	3b 43 04             	cmp    0x4(%ebx),%eax
  8013b0:	74 df                	je     801391 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8013b2:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8013b7:	79 05                	jns    8013be <devpipe_read+0x4a>
  8013b9:	48                   	dec    %eax
  8013ba:	83 c8 e0             	or     $0xffffffe0,%eax
  8013bd:	40                   	inc    %eax
  8013be:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8013c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c5:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8013c8:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8013ca:	46                   	inc    %esi
  8013cb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013ce:	75 db                	jne    8013ab <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8013d0:	89 f0                	mov    %esi,%eax
  8013d2:	eb 05                	jmp    8013d9 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8013d4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8013d9:	83 c4 1c             	add    $0x1c,%esp
  8013dc:	5b                   	pop    %ebx
  8013dd:	5e                   	pop    %esi
  8013de:	5f                   	pop    %edi
  8013df:	5d                   	pop    %ebp
  8013e0:	c3                   	ret    

008013e1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	57                   	push   %edi
  8013e5:	56                   	push   %esi
  8013e6:	53                   	push   %ebx
  8013e7:	83 ec 3c             	sub    $0x3c,%esp
  8013ea:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8013ed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013f0:	89 04 24             	mov    %eax,(%esp)
  8013f3:	e8 b3 f0 ff ff       	call   8004ab <fd_alloc>
  8013f8:	89 c3                	mov    %eax,%ebx
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	0f 88 45 01 00 00    	js     801547 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801402:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801409:	00 
  80140a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80140d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801411:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801418:	e8 98 ed ff ff       	call   8001b5 <sys_page_alloc>
  80141d:	89 c3                	mov    %eax,%ebx
  80141f:	85 c0                	test   %eax,%eax
  801421:	0f 88 20 01 00 00    	js     801547 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801427:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80142a:	89 04 24             	mov    %eax,(%esp)
  80142d:	e8 79 f0 ff ff       	call   8004ab <fd_alloc>
  801432:	89 c3                	mov    %eax,%ebx
  801434:	85 c0                	test   %eax,%eax
  801436:	0f 88 f8 00 00 00    	js     801534 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80143c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801443:	00 
  801444:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801447:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801452:	e8 5e ed ff ff       	call   8001b5 <sys_page_alloc>
  801457:	89 c3                	mov    %eax,%ebx
  801459:	85 c0                	test   %eax,%eax
  80145b:	0f 88 d3 00 00 00    	js     801534 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801461:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801464:	89 04 24             	mov    %eax,(%esp)
  801467:	e8 24 f0 ff ff       	call   800490 <fd2data>
  80146c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80146e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801475:	00 
  801476:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801481:	e8 2f ed ff ff       	call   8001b5 <sys_page_alloc>
  801486:	89 c3                	mov    %eax,%ebx
  801488:	85 c0                	test   %eax,%eax
  80148a:	0f 88 91 00 00 00    	js     801521 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801490:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801493:	89 04 24             	mov    %eax,(%esp)
  801496:	e8 f5 ef ff ff       	call   800490 <fd2data>
  80149b:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8014a2:	00 
  8014a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014ae:	00 
  8014af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ba:	e8 4a ed ff ff       	call   800209 <sys_page_map>
  8014bf:	89 c3                	mov    %eax,%ebx
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	78 4c                	js     801511 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8014c5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8014cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014ce:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8014d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014d3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8014da:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8014e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014e3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8014e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014e8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8014ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014f2:	89 04 24             	mov    %eax,(%esp)
  8014f5:	e8 86 ef ff ff       	call   800480 <fd2num>
  8014fa:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8014fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014ff:	89 04 24             	mov    %eax,(%esp)
  801502:	e8 79 ef ff ff       	call   800480 <fd2num>
  801507:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80150a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80150f:	eb 36                	jmp    801547 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801511:	89 74 24 04          	mov    %esi,0x4(%esp)
  801515:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80151c:	e8 3b ed ff ff       	call   80025c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801521:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801524:	89 44 24 04          	mov    %eax,0x4(%esp)
  801528:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80152f:	e8 28 ed ff ff       	call   80025c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801534:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801537:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801542:	e8 15 ed ff ff       	call   80025c <sys_page_unmap>
    err:
	return r;
}
  801547:	89 d8                	mov    %ebx,%eax
  801549:	83 c4 3c             	add    $0x3c,%esp
  80154c:	5b                   	pop    %ebx
  80154d:	5e                   	pop    %esi
  80154e:	5f                   	pop    %edi
  80154f:	5d                   	pop    %ebp
  801550:	c3                   	ret    

00801551 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801557:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155e:	8b 45 08             	mov    0x8(%ebp),%eax
  801561:	89 04 24             	mov    %eax,(%esp)
  801564:	e8 95 ef ff ff       	call   8004fe <fd_lookup>
  801569:	85 c0                	test   %eax,%eax
  80156b:	78 15                	js     801582 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80156d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801570:	89 04 24             	mov    %eax,(%esp)
  801573:	e8 18 ef ff ff       	call   800490 <fd2data>
	return _pipeisclosed(fd, p);
  801578:	89 c2                	mov    %eax,%edx
  80157a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157d:	e8 15 fd ff ff       	call   801297 <_pipeisclosed>
}
  801582:	c9                   	leave  
  801583:	c3                   	ret    

00801584 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801584:	55                   	push   %ebp
  801585:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801587:	b8 00 00 00 00       	mov    $0x0,%eax
  80158c:	5d                   	pop    %ebp
  80158d:	c3                   	ret    

0080158e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80158e:	55                   	push   %ebp
  80158f:	89 e5                	mov    %esp,%ebp
  801591:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801594:	c7 44 24 04 13 26 80 	movl   $0x802613,0x4(%esp)
  80159b:	00 
  80159c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80159f:	89 04 24             	mov    %eax,(%esp)
  8015a2:	e8 20 08 00 00       	call   801dc7 <strcpy>
	return 0;
}
  8015a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ac:	c9                   	leave  
  8015ad:	c3                   	ret    

008015ae <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	57                   	push   %edi
  8015b2:	56                   	push   %esi
  8015b3:	53                   	push   %ebx
  8015b4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8015ba:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8015bf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8015c5:	eb 30                	jmp    8015f7 <devcons_write+0x49>
		m = n - tot;
  8015c7:	8b 75 10             	mov    0x10(%ebp),%esi
  8015ca:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8015cc:	83 fe 7f             	cmp    $0x7f,%esi
  8015cf:	76 05                	jbe    8015d6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8015d1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8015d6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8015da:	03 45 0c             	add    0xc(%ebp),%eax
  8015dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e1:	89 3c 24             	mov    %edi,(%esp)
  8015e4:	e8 57 09 00 00       	call   801f40 <memmove>
		sys_cputs(buf, m);
  8015e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015ed:	89 3c 24             	mov    %edi,(%esp)
  8015f0:	e8 f3 ea ff ff       	call   8000e8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8015f5:	01 f3                	add    %esi,%ebx
  8015f7:	89 d8                	mov    %ebx,%eax
  8015f9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8015fc:	72 c9                	jb     8015c7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8015fe:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801604:	5b                   	pop    %ebx
  801605:	5e                   	pop    %esi
  801606:	5f                   	pop    %edi
  801607:	5d                   	pop    %ebp
  801608:	c3                   	ret    

00801609 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801609:	55                   	push   %ebp
  80160a:	89 e5                	mov    %esp,%ebp
  80160c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80160f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801613:	75 07                	jne    80161c <devcons_read+0x13>
  801615:	eb 25                	jmp    80163c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801617:	e8 7a eb ff ff       	call   800196 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80161c:	e8 e5 ea ff ff       	call   800106 <sys_cgetc>
  801621:	85 c0                	test   %eax,%eax
  801623:	74 f2                	je     801617 <devcons_read+0xe>
  801625:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801627:	85 c0                	test   %eax,%eax
  801629:	78 1d                	js     801648 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80162b:	83 f8 04             	cmp    $0x4,%eax
  80162e:	74 13                	je     801643 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801630:	8b 45 0c             	mov    0xc(%ebp),%eax
  801633:	88 10                	mov    %dl,(%eax)
	return 1;
  801635:	b8 01 00 00 00       	mov    $0x1,%eax
  80163a:	eb 0c                	jmp    801648 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80163c:	b8 00 00 00 00       	mov    $0x0,%eax
  801641:	eb 05                	jmp    801648 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801643:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801648:	c9                   	leave  
  801649:	c3                   	ret    

0080164a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801650:	8b 45 08             	mov    0x8(%ebp),%eax
  801653:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801656:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80165d:	00 
  80165e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801661:	89 04 24             	mov    %eax,(%esp)
  801664:	e8 7f ea ff ff       	call   8000e8 <sys_cputs>
}
  801669:	c9                   	leave  
  80166a:	c3                   	ret    

0080166b <getchar>:

int
getchar(void)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801671:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801678:	00 
  801679:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80167c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801680:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801687:	e8 10 f1 ff ff       	call   80079c <read>
	if (r < 0)
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 0f                	js     80169f <getchar+0x34>
		return r;
	if (r < 1)
  801690:	85 c0                	test   %eax,%eax
  801692:	7e 06                	jle    80169a <getchar+0x2f>
		return -E_EOF;
	return c;
  801694:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801698:	eb 05                	jmp    80169f <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80169a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b1:	89 04 24             	mov    %eax,(%esp)
  8016b4:	e8 45 ee ff ff       	call   8004fe <fd_lookup>
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 11                	js     8016ce <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8016bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8016c6:	39 10                	cmp    %edx,(%eax)
  8016c8:	0f 94 c0             	sete   %al
  8016cb:	0f b6 c0             	movzbl %al,%eax
}
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <opencons>:

int
opencons(void)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8016d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d9:	89 04 24             	mov    %eax,(%esp)
  8016dc:	e8 ca ed ff ff       	call   8004ab <fd_alloc>
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 3c                	js     801721 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8016e5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8016ec:	00 
  8016ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016fb:	e8 b5 ea ff ff       	call   8001b5 <sys_page_alloc>
  801700:	85 c0                	test   %eax,%eax
  801702:	78 1d                	js     801721 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801704:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80170a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80170f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801712:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801719:	89 04 24             	mov    %eax,(%esp)
  80171c:	e8 5f ed ff ff       	call   800480 <fd2num>
}
  801721:	c9                   	leave  
  801722:	c3                   	ret    
	...

00801724 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	56                   	push   %esi
  801728:	53                   	push   %ebx
  801729:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80172c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80172f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801735:	e8 3d ea ff ff       	call   800177 <sys_getenvid>
  80173a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80173d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801741:	8b 55 08             	mov    0x8(%ebp),%edx
  801744:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801748:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80174c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801750:	c7 04 24 20 26 80 00 	movl   $0x802620,(%esp)
  801757:	e8 c0 00 00 00       	call   80181c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80175c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801760:	8b 45 10             	mov    0x10(%ebp),%eax
  801763:	89 04 24             	mov    %eax,(%esp)
  801766:	e8 50 00 00 00       	call   8017bb <vcprintf>
	cprintf("\n");
  80176b:	c7 04 24 0c 26 80 00 	movl   $0x80260c,(%esp)
  801772:	e8 a5 00 00 00       	call   80181c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801777:	cc                   	int3   
  801778:	eb fd                	jmp    801777 <_panic+0x53>
	...

0080177c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	53                   	push   %ebx
  801780:	83 ec 14             	sub    $0x14,%esp
  801783:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801786:	8b 03                	mov    (%ebx),%eax
  801788:	8b 55 08             	mov    0x8(%ebp),%edx
  80178b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80178f:	40                   	inc    %eax
  801790:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801792:	3d ff 00 00 00       	cmp    $0xff,%eax
  801797:	75 19                	jne    8017b2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801799:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8017a0:	00 
  8017a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8017a4:	89 04 24             	mov    %eax,(%esp)
  8017a7:	e8 3c e9 ff ff       	call   8000e8 <sys_cputs>
		b->idx = 0;
  8017ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8017b2:	ff 43 04             	incl   0x4(%ebx)
}
  8017b5:	83 c4 14             	add    $0x14,%esp
  8017b8:	5b                   	pop    %ebx
  8017b9:	5d                   	pop    %ebp
  8017ba:	c3                   	ret    

008017bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8017c4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017cb:	00 00 00 
	b.cnt = 0;
  8017ce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8017d5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8017d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017df:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8017ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f0:	c7 04 24 7c 17 80 00 	movl   $0x80177c,(%esp)
  8017f7:	e8 82 01 00 00       	call   80197e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8017fc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801802:	89 44 24 04          	mov    %eax,0x4(%esp)
  801806:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80180c:	89 04 24             	mov    %eax,(%esp)
  80180f:	e8 d4 e8 ff ff       	call   8000e8 <sys_cputs>

	return b.cnt;
}
  801814:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80181a:	c9                   	leave  
  80181b:	c3                   	ret    

0080181c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801822:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801825:	89 44 24 04          	mov    %eax,0x4(%esp)
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	89 04 24             	mov    %eax,(%esp)
  80182f:	e8 87 ff ff ff       	call   8017bb <vcprintf>
	va_end(ap);

	return cnt;
}
  801834:	c9                   	leave  
  801835:	c3                   	ret    
	...

00801838 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	57                   	push   %edi
  80183c:	56                   	push   %esi
  80183d:	53                   	push   %ebx
  80183e:	83 ec 3c             	sub    $0x3c,%esp
  801841:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801844:	89 d7                	mov    %edx,%edi
  801846:	8b 45 08             	mov    0x8(%ebp),%eax
  801849:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80184c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801852:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801855:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801858:	85 c0                	test   %eax,%eax
  80185a:	75 08                	jne    801864 <printnum+0x2c>
  80185c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80185f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801862:	77 57                	ja     8018bb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801864:	89 74 24 10          	mov    %esi,0x10(%esp)
  801868:	4b                   	dec    %ebx
  801869:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80186d:	8b 45 10             	mov    0x10(%ebp),%eax
  801870:	89 44 24 08          	mov    %eax,0x8(%esp)
  801874:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801878:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80187c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801883:	00 
  801884:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801887:	89 04 24             	mov    %eax,(%esp)
  80188a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80188d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801891:	e8 d2 09 00 00       	call   802268 <__udivdi3>
  801896:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80189a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80189e:	89 04 24             	mov    %eax,(%esp)
  8018a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018a5:	89 fa                	mov    %edi,%edx
  8018a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018aa:	e8 89 ff ff ff       	call   801838 <printnum>
  8018af:	eb 0f                	jmp    8018c0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8018b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018b5:	89 34 24             	mov    %esi,(%esp)
  8018b8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8018bb:	4b                   	dec    %ebx
  8018bc:	85 db                	test   %ebx,%ebx
  8018be:	7f f1                	jg     8018b1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8018c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018c4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8018cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8018d6:	00 
  8018d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8018da:	89 04 24             	mov    %eax,(%esp)
  8018dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e4:	e8 9f 0a 00 00       	call   802388 <__umoddi3>
  8018e9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018ed:	0f be 80 43 26 80 00 	movsbl 0x802643(%eax),%eax
  8018f4:	89 04 24             	mov    %eax,(%esp)
  8018f7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8018fa:	83 c4 3c             	add    $0x3c,%esp
  8018fd:	5b                   	pop    %ebx
  8018fe:	5e                   	pop    %esi
  8018ff:	5f                   	pop    %edi
  801900:	5d                   	pop    %ebp
  801901:	c3                   	ret    

00801902 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801905:	83 fa 01             	cmp    $0x1,%edx
  801908:	7e 0e                	jle    801918 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80190a:	8b 10                	mov    (%eax),%edx
  80190c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80190f:	89 08                	mov    %ecx,(%eax)
  801911:	8b 02                	mov    (%edx),%eax
  801913:	8b 52 04             	mov    0x4(%edx),%edx
  801916:	eb 22                	jmp    80193a <getuint+0x38>
	else if (lflag)
  801918:	85 d2                	test   %edx,%edx
  80191a:	74 10                	je     80192c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80191c:	8b 10                	mov    (%eax),%edx
  80191e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801921:	89 08                	mov    %ecx,(%eax)
  801923:	8b 02                	mov    (%edx),%eax
  801925:	ba 00 00 00 00       	mov    $0x0,%edx
  80192a:	eb 0e                	jmp    80193a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80192c:	8b 10                	mov    (%eax),%edx
  80192e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801931:	89 08                	mov    %ecx,(%eax)
  801933:	8b 02                	mov    (%edx),%eax
  801935:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80193a:	5d                   	pop    %ebp
  80193b:	c3                   	ret    

0080193c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801942:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801945:	8b 10                	mov    (%eax),%edx
  801947:	3b 50 04             	cmp    0x4(%eax),%edx
  80194a:	73 08                	jae    801954 <sprintputch+0x18>
		*b->buf++ = ch;
  80194c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80194f:	88 0a                	mov    %cl,(%edx)
  801951:	42                   	inc    %edx
  801952:	89 10                	mov    %edx,(%eax)
}
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80195c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80195f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801963:	8b 45 10             	mov    0x10(%ebp),%eax
  801966:	89 44 24 08          	mov    %eax,0x8(%esp)
  80196a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801971:	8b 45 08             	mov    0x8(%ebp),%eax
  801974:	89 04 24             	mov    %eax,(%esp)
  801977:	e8 02 00 00 00       	call   80197e <vprintfmt>
	va_end(ap);
}
  80197c:	c9                   	leave  
  80197d:	c3                   	ret    

0080197e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80197e:	55                   	push   %ebp
  80197f:	89 e5                	mov    %esp,%ebp
  801981:	57                   	push   %edi
  801982:	56                   	push   %esi
  801983:	53                   	push   %ebx
  801984:	83 ec 4c             	sub    $0x4c,%esp
  801987:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80198a:	8b 75 10             	mov    0x10(%ebp),%esi
  80198d:	eb 12                	jmp    8019a1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80198f:	85 c0                	test   %eax,%eax
  801991:	0f 84 6b 03 00 00    	je     801d02 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  801997:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80199b:	89 04 24             	mov    %eax,(%esp)
  80199e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8019a1:	0f b6 06             	movzbl (%esi),%eax
  8019a4:	46                   	inc    %esi
  8019a5:	83 f8 25             	cmp    $0x25,%eax
  8019a8:	75 e5                	jne    80198f <vprintfmt+0x11>
  8019aa:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8019ae:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8019b5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8019ba:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8019c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019c6:	eb 26                	jmp    8019ee <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019c8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8019cb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8019cf:	eb 1d                	jmp    8019ee <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019d1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8019d4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8019d8:	eb 14                	jmp    8019ee <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019da:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8019dd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8019e4:	eb 08                	jmp    8019ee <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8019e6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8019e9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019ee:	0f b6 06             	movzbl (%esi),%eax
  8019f1:	8d 56 01             	lea    0x1(%esi),%edx
  8019f4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8019f7:	8a 16                	mov    (%esi),%dl
  8019f9:	83 ea 23             	sub    $0x23,%edx
  8019fc:	80 fa 55             	cmp    $0x55,%dl
  8019ff:	0f 87 e1 02 00 00    	ja     801ce6 <vprintfmt+0x368>
  801a05:	0f b6 d2             	movzbl %dl,%edx
  801a08:	ff 24 95 80 27 80 00 	jmp    *0x802780(,%edx,4)
  801a0f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801a12:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801a17:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801a1a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  801a1e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801a21:	8d 50 d0             	lea    -0x30(%eax),%edx
  801a24:	83 fa 09             	cmp    $0x9,%edx
  801a27:	77 2a                	ja     801a53 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801a29:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801a2a:	eb eb                	jmp    801a17 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801a2c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2f:	8d 50 04             	lea    0x4(%eax),%edx
  801a32:	89 55 14             	mov    %edx,0x14(%ebp)
  801a35:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a37:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801a3a:	eb 17                	jmp    801a53 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801a3c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801a40:	78 98                	js     8019da <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a42:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801a45:	eb a7                	jmp    8019ee <vprintfmt+0x70>
  801a47:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801a4a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801a51:	eb 9b                	jmp    8019ee <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801a53:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801a57:	79 95                	jns    8019ee <vprintfmt+0x70>
  801a59:	eb 8b                	jmp    8019e6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801a5b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a5c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801a5f:	eb 8d                	jmp    8019ee <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801a61:	8b 45 14             	mov    0x14(%ebp),%eax
  801a64:	8d 50 04             	lea    0x4(%eax),%edx
  801a67:	89 55 14             	mov    %edx,0x14(%ebp)
  801a6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a6e:	8b 00                	mov    (%eax),%eax
  801a70:	89 04 24             	mov    %eax,(%esp)
  801a73:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a76:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801a79:	e9 23 ff ff ff       	jmp    8019a1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801a7e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a81:	8d 50 04             	lea    0x4(%eax),%edx
  801a84:	89 55 14             	mov    %edx,0x14(%ebp)
  801a87:	8b 00                	mov    (%eax),%eax
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	79 02                	jns    801a8f <vprintfmt+0x111>
  801a8d:	f7 d8                	neg    %eax
  801a8f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801a91:	83 f8 10             	cmp    $0x10,%eax
  801a94:	7f 0b                	jg     801aa1 <vprintfmt+0x123>
  801a96:	8b 04 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%eax
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	75 23                	jne    801ac4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801aa1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801aa5:	c7 44 24 08 5b 26 80 	movl   $0x80265b,0x8(%esp)
  801aac:	00 
  801aad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab4:	89 04 24             	mov    %eax,(%esp)
  801ab7:	e8 9a fe ff ff       	call   801956 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801abc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801abf:	e9 dd fe ff ff       	jmp    8019a1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801ac4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ac8:	c7 44 24 08 a1 25 80 	movl   $0x8025a1,0x8(%esp)
  801acf:	00 
  801ad0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ad4:	8b 55 08             	mov    0x8(%ebp),%edx
  801ad7:	89 14 24             	mov    %edx,(%esp)
  801ada:	e8 77 fe ff ff       	call   801956 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801adf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801ae2:	e9 ba fe ff ff       	jmp    8019a1 <vprintfmt+0x23>
  801ae7:	89 f9                	mov    %edi,%ecx
  801ae9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801aef:	8b 45 14             	mov    0x14(%ebp),%eax
  801af2:	8d 50 04             	lea    0x4(%eax),%edx
  801af5:	89 55 14             	mov    %edx,0x14(%ebp)
  801af8:	8b 30                	mov    (%eax),%esi
  801afa:	85 f6                	test   %esi,%esi
  801afc:	75 05                	jne    801b03 <vprintfmt+0x185>
				p = "(null)";
  801afe:	be 54 26 80 00       	mov    $0x802654,%esi
			if (width > 0 && padc != '-')
  801b03:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801b07:	0f 8e 84 00 00 00    	jle    801b91 <vprintfmt+0x213>
  801b0d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801b11:	74 7e                	je     801b91 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  801b13:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b17:	89 34 24             	mov    %esi,(%esp)
  801b1a:	e8 8b 02 00 00       	call   801daa <strnlen>
  801b1f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801b22:	29 c2                	sub    %eax,%edx
  801b24:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801b27:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801b2b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801b2e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801b31:	89 de                	mov    %ebx,%esi
  801b33:	89 d3                	mov    %edx,%ebx
  801b35:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b37:	eb 0b                	jmp    801b44 <vprintfmt+0x1c6>
					putch(padc, putdat);
  801b39:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b3d:	89 3c 24             	mov    %edi,(%esp)
  801b40:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b43:	4b                   	dec    %ebx
  801b44:	85 db                	test   %ebx,%ebx
  801b46:	7f f1                	jg     801b39 <vprintfmt+0x1bb>
  801b48:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801b4b:	89 f3                	mov    %esi,%ebx
  801b4d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801b50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b53:	85 c0                	test   %eax,%eax
  801b55:	79 05                	jns    801b5c <vprintfmt+0x1de>
  801b57:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b5f:	29 c2                	sub    %eax,%edx
  801b61:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801b64:	eb 2b                	jmp    801b91 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801b66:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b6a:	74 18                	je     801b84 <vprintfmt+0x206>
  801b6c:	8d 50 e0             	lea    -0x20(%eax),%edx
  801b6f:	83 fa 5e             	cmp    $0x5e,%edx
  801b72:	76 10                	jbe    801b84 <vprintfmt+0x206>
					putch('?', putdat);
  801b74:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b78:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801b7f:	ff 55 08             	call   *0x8(%ebp)
  801b82:	eb 0a                	jmp    801b8e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801b84:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b88:	89 04 24             	mov    %eax,(%esp)
  801b8b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801b8e:	ff 4d e4             	decl   -0x1c(%ebp)
  801b91:	0f be 06             	movsbl (%esi),%eax
  801b94:	46                   	inc    %esi
  801b95:	85 c0                	test   %eax,%eax
  801b97:	74 21                	je     801bba <vprintfmt+0x23c>
  801b99:	85 ff                	test   %edi,%edi
  801b9b:	78 c9                	js     801b66 <vprintfmt+0x1e8>
  801b9d:	4f                   	dec    %edi
  801b9e:	79 c6                	jns    801b66 <vprintfmt+0x1e8>
  801ba0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ba3:	89 de                	mov    %ebx,%esi
  801ba5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801ba8:	eb 18                	jmp    801bc2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801baa:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bae:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801bb5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801bb7:	4b                   	dec    %ebx
  801bb8:	eb 08                	jmp    801bc2 <vprintfmt+0x244>
  801bba:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bbd:	89 de                	mov    %ebx,%esi
  801bbf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801bc2:	85 db                	test   %ebx,%ebx
  801bc4:	7f e4                	jg     801baa <vprintfmt+0x22c>
  801bc6:	89 7d 08             	mov    %edi,0x8(%ebp)
  801bc9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bcb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801bce:	e9 ce fd ff ff       	jmp    8019a1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801bd3:	83 f9 01             	cmp    $0x1,%ecx
  801bd6:	7e 10                	jle    801be8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801bd8:	8b 45 14             	mov    0x14(%ebp),%eax
  801bdb:	8d 50 08             	lea    0x8(%eax),%edx
  801bde:	89 55 14             	mov    %edx,0x14(%ebp)
  801be1:	8b 30                	mov    (%eax),%esi
  801be3:	8b 78 04             	mov    0x4(%eax),%edi
  801be6:	eb 26                	jmp    801c0e <vprintfmt+0x290>
	else if (lflag)
  801be8:	85 c9                	test   %ecx,%ecx
  801bea:	74 12                	je     801bfe <vprintfmt+0x280>
		return va_arg(*ap, long);
  801bec:	8b 45 14             	mov    0x14(%ebp),%eax
  801bef:	8d 50 04             	lea    0x4(%eax),%edx
  801bf2:	89 55 14             	mov    %edx,0x14(%ebp)
  801bf5:	8b 30                	mov    (%eax),%esi
  801bf7:	89 f7                	mov    %esi,%edi
  801bf9:	c1 ff 1f             	sar    $0x1f,%edi
  801bfc:	eb 10                	jmp    801c0e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801bfe:	8b 45 14             	mov    0x14(%ebp),%eax
  801c01:	8d 50 04             	lea    0x4(%eax),%edx
  801c04:	89 55 14             	mov    %edx,0x14(%ebp)
  801c07:	8b 30                	mov    (%eax),%esi
  801c09:	89 f7                	mov    %esi,%edi
  801c0b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801c0e:	85 ff                	test   %edi,%edi
  801c10:	78 0a                	js     801c1c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801c12:	b8 0a 00 00 00       	mov    $0xa,%eax
  801c17:	e9 8c 00 00 00       	jmp    801ca8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801c1c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c20:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801c27:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801c2a:	f7 de                	neg    %esi
  801c2c:	83 d7 00             	adc    $0x0,%edi
  801c2f:	f7 df                	neg    %edi
			}
			base = 10;
  801c31:	b8 0a 00 00 00       	mov    $0xa,%eax
  801c36:	eb 70                	jmp    801ca8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801c38:	89 ca                	mov    %ecx,%edx
  801c3a:	8d 45 14             	lea    0x14(%ebp),%eax
  801c3d:	e8 c0 fc ff ff       	call   801902 <getuint>
  801c42:	89 c6                	mov    %eax,%esi
  801c44:	89 d7                	mov    %edx,%edi
			base = 10;
  801c46:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801c4b:	eb 5b                	jmp    801ca8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  801c4d:	89 ca                	mov    %ecx,%edx
  801c4f:	8d 45 14             	lea    0x14(%ebp),%eax
  801c52:	e8 ab fc ff ff       	call   801902 <getuint>
  801c57:	89 c6                	mov    %eax,%esi
  801c59:	89 d7                	mov    %edx,%edi
			base = 8;
  801c5b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801c60:	eb 46                	jmp    801ca8 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  801c62:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c66:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801c6d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801c70:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c74:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801c7b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801c7e:	8b 45 14             	mov    0x14(%ebp),%eax
  801c81:	8d 50 04             	lea    0x4(%eax),%edx
  801c84:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801c87:	8b 30                	mov    (%eax),%esi
  801c89:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801c8e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801c93:	eb 13                	jmp    801ca8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801c95:	89 ca                	mov    %ecx,%edx
  801c97:	8d 45 14             	lea    0x14(%ebp),%eax
  801c9a:	e8 63 fc ff ff       	call   801902 <getuint>
  801c9f:	89 c6                	mov    %eax,%esi
  801ca1:	89 d7                	mov    %edx,%edi
			base = 16;
  801ca3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ca8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801cac:	89 54 24 10          	mov    %edx,0x10(%esp)
  801cb0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801cb3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cb7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cbb:	89 34 24             	mov    %esi,(%esp)
  801cbe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801cc2:	89 da                	mov    %ebx,%edx
  801cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc7:	e8 6c fb ff ff       	call   801838 <printnum>
			break;
  801ccc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801ccf:	e9 cd fc ff ff       	jmp    8019a1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801cd4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cd8:	89 04 24             	mov    %eax,(%esp)
  801cdb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cde:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ce1:	e9 bb fc ff ff       	jmp    8019a1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801ce6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cea:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801cf1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801cf4:	eb 01                	jmp    801cf7 <vprintfmt+0x379>
  801cf6:	4e                   	dec    %esi
  801cf7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801cfb:	75 f9                	jne    801cf6 <vprintfmt+0x378>
  801cfd:	e9 9f fc ff ff       	jmp    8019a1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801d02:	83 c4 4c             	add    $0x4c,%esp
  801d05:	5b                   	pop    %ebx
  801d06:	5e                   	pop    %esi
  801d07:	5f                   	pop    %edi
  801d08:	5d                   	pop    %ebp
  801d09:	c3                   	ret    

00801d0a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	83 ec 28             	sub    $0x28,%esp
  801d10:	8b 45 08             	mov    0x8(%ebp),%eax
  801d13:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801d16:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d19:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801d1d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801d20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801d27:	85 c0                	test   %eax,%eax
  801d29:	74 30                	je     801d5b <vsnprintf+0x51>
  801d2b:	85 d2                	test   %edx,%edx
  801d2d:	7e 33                	jle    801d62 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801d2f:	8b 45 14             	mov    0x14(%ebp),%eax
  801d32:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d36:	8b 45 10             	mov    0x10(%ebp),%eax
  801d39:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d3d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801d40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d44:	c7 04 24 3c 19 80 00 	movl   $0x80193c,(%esp)
  801d4b:	e8 2e fc ff ff       	call   80197e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801d50:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d53:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d59:	eb 0c                	jmp    801d67 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801d5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d60:	eb 05                	jmp    801d67 <vsnprintf+0x5d>
  801d62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801d67:	c9                   	leave  
  801d68:	c3                   	ret    

00801d69 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801d6f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801d72:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d76:	8b 45 10             	mov    0x10(%ebp),%eax
  801d79:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d80:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d84:	8b 45 08             	mov    0x8(%ebp),%eax
  801d87:	89 04 24             	mov    %eax,(%esp)
  801d8a:	e8 7b ff ff ff       	call   801d0a <vsnprintf>
	va_end(ap);

	return rc;
}
  801d8f:	c9                   	leave  
  801d90:	c3                   	ret    
  801d91:	00 00                	add    %al,(%eax)
	...

00801d94 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801d9a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9f:	eb 01                	jmp    801da2 <strlen+0xe>
		n++;
  801da1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801da2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801da6:	75 f9                	jne    801da1 <strlen+0xd>
		n++;
	return n;
}
  801da8:	5d                   	pop    %ebp
  801da9:	c3                   	ret    

00801daa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801db0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801db3:	b8 00 00 00 00       	mov    $0x0,%eax
  801db8:	eb 01                	jmp    801dbb <strnlen+0x11>
		n++;
  801dba:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801dbb:	39 d0                	cmp    %edx,%eax
  801dbd:	74 06                	je     801dc5 <strnlen+0x1b>
  801dbf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801dc3:	75 f5                	jne    801dba <strnlen+0x10>
		n++;
	return n;
}
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    

00801dc7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801dc7:	55                   	push   %ebp
  801dc8:	89 e5                	mov    %esp,%ebp
  801dca:	53                   	push   %ebx
  801dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801dd1:	ba 00 00 00 00       	mov    $0x0,%edx
  801dd6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801dd9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801ddc:	42                   	inc    %edx
  801ddd:	84 c9                	test   %cl,%cl
  801ddf:	75 f5                	jne    801dd6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801de1:	5b                   	pop    %ebx
  801de2:	5d                   	pop    %ebp
  801de3:	c3                   	ret    

00801de4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801de4:	55                   	push   %ebp
  801de5:	89 e5                	mov    %esp,%ebp
  801de7:	53                   	push   %ebx
  801de8:	83 ec 08             	sub    $0x8,%esp
  801deb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801dee:	89 1c 24             	mov    %ebx,(%esp)
  801df1:	e8 9e ff ff ff       	call   801d94 <strlen>
	strcpy(dst + len, src);
  801df6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dfd:	01 d8                	add    %ebx,%eax
  801dff:	89 04 24             	mov    %eax,(%esp)
  801e02:	e8 c0 ff ff ff       	call   801dc7 <strcpy>
	return dst;
}
  801e07:	89 d8                	mov    %ebx,%eax
  801e09:	83 c4 08             	add    $0x8,%esp
  801e0c:	5b                   	pop    %ebx
  801e0d:	5d                   	pop    %ebp
  801e0e:	c3                   	ret    

00801e0f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	56                   	push   %esi
  801e13:	53                   	push   %ebx
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
  801e17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e1a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801e1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e22:	eb 0c                	jmp    801e30 <strncpy+0x21>
		*dst++ = *src;
  801e24:	8a 1a                	mov    (%edx),%bl
  801e26:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801e29:	80 3a 01             	cmpb   $0x1,(%edx)
  801e2c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801e2f:	41                   	inc    %ecx
  801e30:	39 f1                	cmp    %esi,%ecx
  801e32:	75 f0                	jne    801e24 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801e34:	5b                   	pop    %ebx
  801e35:	5e                   	pop    %esi
  801e36:	5d                   	pop    %ebp
  801e37:	c3                   	ret    

00801e38 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	56                   	push   %esi
  801e3c:	53                   	push   %ebx
  801e3d:	8b 75 08             	mov    0x8(%ebp),%esi
  801e40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e43:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e46:	85 d2                	test   %edx,%edx
  801e48:	75 0a                	jne    801e54 <strlcpy+0x1c>
  801e4a:	89 f0                	mov    %esi,%eax
  801e4c:	eb 1a                	jmp    801e68 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801e4e:	88 18                	mov    %bl,(%eax)
  801e50:	40                   	inc    %eax
  801e51:	41                   	inc    %ecx
  801e52:	eb 02                	jmp    801e56 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e54:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801e56:	4a                   	dec    %edx
  801e57:	74 0a                	je     801e63 <strlcpy+0x2b>
  801e59:	8a 19                	mov    (%ecx),%bl
  801e5b:	84 db                	test   %bl,%bl
  801e5d:	75 ef                	jne    801e4e <strlcpy+0x16>
  801e5f:	89 c2                	mov    %eax,%edx
  801e61:	eb 02                	jmp    801e65 <strlcpy+0x2d>
  801e63:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801e65:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801e68:	29 f0                	sub    %esi,%eax
}
  801e6a:	5b                   	pop    %ebx
  801e6b:	5e                   	pop    %esi
  801e6c:	5d                   	pop    %ebp
  801e6d:	c3                   	ret    

00801e6e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e74:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801e77:	eb 02                	jmp    801e7b <strcmp+0xd>
		p++, q++;
  801e79:	41                   	inc    %ecx
  801e7a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801e7b:	8a 01                	mov    (%ecx),%al
  801e7d:	84 c0                	test   %al,%al
  801e7f:	74 04                	je     801e85 <strcmp+0x17>
  801e81:	3a 02                	cmp    (%edx),%al
  801e83:	74 f4                	je     801e79 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801e85:	0f b6 c0             	movzbl %al,%eax
  801e88:	0f b6 12             	movzbl (%edx),%edx
  801e8b:	29 d0                	sub    %edx,%eax
}
  801e8d:	5d                   	pop    %ebp
  801e8e:	c3                   	ret    

00801e8f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801e8f:	55                   	push   %ebp
  801e90:	89 e5                	mov    %esp,%ebp
  801e92:	53                   	push   %ebx
  801e93:	8b 45 08             	mov    0x8(%ebp),%eax
  801e96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e99:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801e9c:	eb 03                	jmp    801ea1 <strncmp+0x12>
		n--, p++, q++;
  801e9e:	4a                   	dec    %edx
  801e9f:	40                   	inc    %eax
  801ea0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801ea1:	85 d2                	test   %edx,%edx
  801ea3:	74 14                	je     801eb9 <strncmp+0x2a>
  801ea5:	8a 18                	mov    (%eax),%bl
  801ea7:	84 db                	test   %bl,%bl
  801ea9:	74 04                	je     801eaf <strncmp+0x20>
  801eab:	3a 19                	cmp    (%ecx),%bl
  801ead:	74 ef                	je     801e9e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801eaf:	0f b6 00             	movzbl (%eax),%eax
  801eb2:	0f b6 11             	movzbl (%ecx),%edx
  801eb5:	29 d0                	sub    %edx,%eax
  801eb7:	eb 05                	jmp    801ebe <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801eb9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801ebe:	5b                   	pop    %ebx
  801ebf:	5d                   	pop    %ebp
  801ec0:	c3                   	ret    

00801ec1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
  801ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801eca:	eb 05                	jmp    801ed1 <strchr+0x10>
		if (*s == c)
  801ecc:	38 ca                	cmp    %cl,%dl
  801ece:	74 0c                	je     801edc <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ed0:	40                   	inc    %eax
  801ed1:	8a 10                	mov    (%eax),%dl
  801ed3:	84 d2                	test   %dl,%dl
  801ed5:	75 f5                	jne    801ecc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801ed7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801edc:	5d                   	pop    %ebp
  801edd:	c3                   	ret    

00801ede <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801ede:	55                   	push   %ebp
  801edf:	89 e5                	mov    %esp,%ebp
  801ee1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801ee7:	eb 05                	jmp    801eee <strfind+0x10>
		if (*s == c)
  801ee9:	38 ca                	cmp    %cl,%dl
  801eeb:	74 07                	je     801ef4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801eed:	40                   	inc    %eax
  801eee:	8a 10                	mov    (%eax),%dl
  801ef0:	84 d2                	test   %dl,%dl
  801ef2:	75 f5                	jne    801ee9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801ef4:	5d                   	pop    %ebp
  801ef5:	c3                   	ret    

00801ef6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ef6:	55                   	push   %ebp
  801ef7:	89 e5                	mov    %esp,%ebp
  801ef9:	57                   	push   %edi
  801efa:	56                   	push   %esi
  801efb:	53                   	push   %ebx
  801efc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801eff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801f05:	85 c9                	test   %ecx,%ecx
  801f07:	74 30                	je     801f39 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801f09:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801f0f:	75 25                	jne    801f36 <memset+0x40>
  801f11:	f6 c1 03             	test   $0x3,%cl
  801f14:	75 20                	jne    801f36 <memset+0x40>
		c &= 0xFF;
  801f16:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801f19:	89 d3                	mov    %edx,%ebx
  801f1b:	c1 e3 08             	shl    $0x8,%ebx
  801f1e:	89 d6                	mov    %edx,%esi
  801f20:	c1 e6 18             	shl    $0x18,%esi
  801f23:	89 d0                	mov    %edx,%eax
  801f25:	c1 e0 10             	shl    $0x10,%eax
  801f28:	09 f0                	or     %esi,%eax
  801f2a:	09 d0                	or     %edx,%eax
  801f2c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801f2e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801f31:	fc                   	cld    
  801f32:	f3 ab                	rep stos %eax,%es:(%edi)
  801f34:	eb 03                	jmp    801f39 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801f36:	fc                   	cld    
  801f37:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801f39:	89 f8                	mov    %edi,%eax
  801f3b:	5b                   	pop    %ebx
  801f3c:	5e                   	pop    %esi
  801f3d:	5f                   	pop    %edi
  801f3e:	5d                   	pop    %ebp
  801f3f:	c3                   	ret    

00801f40 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	57                   	push   %edi
  801f44:	56                   	push   %esi
  801f45:	8b 45 08             	mov    0x8(%ebp),%eax
  801f48:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f4b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801f4e:	39 c6                	cmp    %eax,%esi
  801f50:	73 34                	jae    801f86 <memmove+0x46>
  801f52:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801f55:	39 d0                	cmp    %edx,%eax
  801f57:	73 2d                	jae    801f86 <memmove+0x46>
		s += n;
		d += n;
  801f59:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f5c:	f6 c2 03             	test   $0x3,%dl
  801f5f:	75 1b                	jne    801f7c <memmove+0x3c>
  801f61:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801f67:	75 13                	jne    801f7c <memmove+0x3c>
  801f69:	f6 c1 03             	test   $0x3,%cl
  801f6c:	75 0e                	jne    801f7c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801f6e:	83 ef 04             	sub    $0x4,%edi
  801f71:	8d 72 fc             	lea    -0x4(%edx),%esi
  801f74:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801f77:	fd                   	std    
  801f78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f7a:	eb 07                	jmp    801f83 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801f7c:	4f                   	dec    %edi
  801f7d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801f80:	fd                   	std    
  801f81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801f83:	fc                   	cld    
  801f84:	eb 20                	jmp    801fa6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801f8c:	75 13                	jne    801fa1 <memmove+0x61>
  801f8e:	a8 03                	test   $0x3,%al
  801f90:	75 0f                	jne    801fa1 <memmove+0x61>
  801f92:	f6 c1 03             	test   $0x3,%cl
  801f95:	75 0a                	jne    801fa1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801f97:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801f9a:	89 c7                	mov    %eax,%edi
  801f9c:	fc                   	cld    
  801f9d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f9f:	eb 05                	jmp    801fa6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801fa1:	89 c7                	mov    %eax,%edi
  801fa3:	fc                   	cld    
  801fa4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801fa6:	5e                   	pop    %esi
  801fa7:	5f                   	pop    %edi
  801fa8:	5d                   	pop    %ebp
  801fa9:	c3                   	ret    

00801faa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801faa:	55                   	push   %ebp
  801fab:	89 e5                	mov    %esp,%ebp
  801fad:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801fb0:	8b 45 10             	mov    0x10(%ebp),%eax
  801fb3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fba:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc1:	89 04 24             	mov    %eax,(%esp)
  801fc4:	e8 77 ff ff ff       	call   801f40 <memmove>
}
  801fc9:	c9                   	leave  
  801fca:	c3                   	ret    

00801fcb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801fcb:	55                   	push   %ebp
  801fcc:	89 e5                	mov    %esp,%ebp
  801fce:	57                   	push   %edi
  801fcf:	56                   	push   %esi
  801fd0:	53                   	push   %ebx
  801fd1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fd4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801fda:	ba 00 00 00 00       	mov    $0x0,%edx
  801fdf:	eb 16                	jmp    801ff7 <memcmp+0x2c>
		if (*s1 != *s2)
  801fe1:	8a 04 17             	mov    (%edi,%edx,1),%al
  801fe4:	42                   	inc    %edx
  801fe5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801fe9:	38 c8                	cmp    %cl,%al
  801feb:	74 0a                	je     801ff7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801fed:	0f b6 c0             	movzbl %al,%eax
  801ff0:	0f b6 c9             	movzbl %cl,%ecx
  801ff3:	29 c8                	sub    %ecx,%eax
  801ff5:	eb 09                	jmp    802000 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ff7:	39 da                	cmp    %ebx,%edx
  801ff9:	75 e6                	jne    801fe1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801ffb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802000:	5b                   	pop    %ebx
  802001:	5e                   	pop    %esi
  802002:	5f                   	pop    %edi
  802003:	5d                   	pop    %ebp
  802004:	c3                   	ret    

00802005 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	8b 45 08             	mov    0x8(%ebp),%eax
  80200b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80200e:	89 c2                	mov    %eax,%edx
  802010:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802013:	eb 05                	jmp    80201a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  802015:	38 08                	cmp    %cl,(%eax)
  802017:	74 05                	je     80201e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802019:	40                   	inc    %eax
  80201a:	39 d0                	cmp    %edx,%eax
  80201c:	72 f7                	jb     802015 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80201e:	5d                   	pop    %ebp
  80201f:	c3                   	ret    

00802020 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	57                   	push   %edi
  802024:	56                   	push   %esi
  802025:	53                   	push   %ebx
  802026:	8b 55 08             	mov    0x8(%ebp),%edx
  802029:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80202c:	eb 01                	jmp    80202f <strtol+0xf>
		s++;
  80202e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80202f:	8a 02                	mov    (%edx),%al
  802031:	3c 20                	cmp    $0x20,%al
  802033:	74 f9                	je     80202e <strtol+0xe>
  802035:	3c 09                	cmp    $0x9,%al
  802037:	74 f5                	je     80202e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802039:	3c 2b                	cmp    $0x2b,%al
  80203b:	75 08                	jne    802045 <strtol+0x25>
		s++;
  80203d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80203e:	bf 00 00 00 00       	mov    $0x0,%edi
  802043:	eb 13                	jmp    802058 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802045:	3c 2d                	cmp    $0x2d,%al
  802047:	75 0a                	jne    802053 <strtol+0x33>
		s++, neg = 1;
  802049:	8d 52 01             	lea    0x1(%edx),%edx
  80204c:	bf 01 00 00 00       	mov    $0x1,%edi
  802051:	eb 05                	jmp    802058 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802053:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802058:	85 db                	test   %ebx,%ebx
  80205a:	74 05                	je     802061 <strtol+0x41>
  80205c:	83 fb 10             	cmp    $0x10,%ebx
  80205f:	75 28                	jne    802089 <strtol+0x69>
  802061:	8a 02                	mov    (%edx),%al
  802063:	3c 30                	cmp    $0x30,%al
  802065:	75 10                	jne    802077 <strtol+0x57>
  802067:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80206b:	75 0a                	jne    802077 <strtol+0x57>
		s += 2, base = 16;
  80206d:	83 c2 02             	add    $0x2,%edx
  802070:	bb 10 00 00 00       	mov    $0x10,%ebx
  802075:	eb 12                	jmp    802089 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  802077:	85 db                	test   %ebx,%ebx
  802079:	75 0e                	jne    802089 <strtol+0x69>
  80207b:	3c 30                	cmp    $0x30,%al
  80207d:	75 05                	jne    802084 <strtol+0x64>
		s++, base = 8;
  80207f:	42                   	inc    %edx
  802080:	b3 08                	mov    $0x8,%bl
  802082:	eb 05                	jmp    802089 <strtol+0x69>
	else if (base == 0)
		base = 10;
  802084:	bb 0a 00 00 00       	mov    $0xa,%ebx
  802089:	b8 00 00 00 00       	mov    $0x0,%eax
  80208e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802090:	8a 0a                	mov    (%edx),%cl
  802092:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  802095:	80 fb 09             	cmp    $0x9,%bl
  802098:	77 08                	ja     8020a2 <strtol+0x82>
			dig = *s - '0';
  80209a:	0f be c9             	movsbl %cl,%ecx
  80209d:	83 e9 30             	sub    $0x30,%ecx
  8020a0:	eb 1e                	jmp    8020c0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  8020a2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8020a5:	80 fb 19             	cmp    $0x19,%bl
  8020a8:	77 08                	ja     8020b2 <strtol+0x92>
			dig = *s - 'a' + 10;
  8020aa:	0f be c9             	movsbl %cl,%ecx
  8020ad:	83 e9 57             	sub    $0x57,%ecx
  8020b0:	eb 0e                	jmp    8020c0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  8020b2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8020b5:	80 fb 19             	cmp    $0x19,%bl
  8020b8:	77 12                	ja     8020cc <strtol+0xac>
			dig = *s - 'A' + 10;
  8020ba:	0f be c9             	movsbl %cl,%ecx
  8020bd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8020c0:	39 f1                	cmp    %esi,%ecx
  8020c2:	7d 0c                	jge    8020d0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8020c4:	42                   	inc    %edx
  8020c5:	0f af c6             	imul   %esi,%eax
  8020c8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8020ca:	eb c4                	jmp    802090 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8020cc:	89 c1                	mov    %eax,%ecx
  8020ce:	eb 02                	jmp    8020d2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8020d0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8020d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8020d6:	74 05                	je     8020dd <strtol+0xbd>
		*endptr = (char *) s;
  8020d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8020db:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8020dd:	85 ff                	test   %edi,%edi
  8020df:	74 04                	je     8020e5 <strtol+0xc5>
  8020e1:	89 c8                	mov    %ecx,%eax
  8020e3:	f7 d8                	neg    %eax
}
  8020e5:	5b                   	pop    %ebx
  8020e6:	5e                   	pop    %esi
  8020e7:	5f                   	pop    %edi
  8020e8:	5d                   	pop    %ebp
  8020e9:	c3                   	ret    
	...

008020ec <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020ec:	55                   	push   %ebp
  8020ed:	89 e5                	mov    %esp,%ebp
  8020ef:	56                   	push   %esi
  8020f0:	53                   	push   %ebx
  8020f1:	83 ec 10             	sub    $0x10,%esp
  8020f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020fa:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8020fd:	85 c0                	test   %eax,%eax
  8020ff:	74 0a                	je     80210b <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802101:	89 04 24             	mov    %eax,(%esp)
  802104:	e8 c2 e2 ff ff       	call   8003cb <sys_ipc_recv>
  802109:	eb 0c                	jmp    802117 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80210b:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802112:	e8 b4 e2 ff ff       	call   8003cb <sys_ipc_recv>
	}
	if (r < 0)
  802117:	85 c0                	test   %eax,%eax
  802119:	79 16                	jns    802131 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  80211b:	85 db                	test   %ebx,%ebx
  80211d:	74 06                	je     802125 <ipc_recv+0x39>
  80211f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802125:	85 f6                	test   %esi,%esi
  802127:	74 2c                	je     802155 <ipc_recv+0x69>
  802129:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80212f:	eb 24                	jmp    802155 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802131:	85 db                	test   %ebx,%ebx
  802133:	74 0a                	je     80213f <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802135:	a1 08 40 80 00       	mov    0x804008,%eax
  80213a:	8b 40 74             	mov    0x74(%eax),%eax
  80213d:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  80213f:	85 f6                	test   %esi,%esi
  802141:	74 0a                	je     80214d <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  802143:	a1 08 40 80 00       	mov    0x804008,%eax
  802148:	8b 40 78             	mov    0x78(%eax),%eax
  80214b:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  80214d:	a1 08 40 80 00       	mov    0x804008,%eax
  802152:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802155:	83 c4 10             	add    $0x10,%esp
  802158:	5b                   	pop    %ebx
  802159:	5e                   	pop    %esi
  80215a:	5d                   	pop    %ebp
  80215b:	c3                   	ret    

0080215c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80215c:	55                   	push   %ebp
  80215d:	89 e5                	mov    %esp,%ebp
  80215f:	57                   	push   %edi
  802160:	56                   	push   %esi
  802161:	53                   	push   %ebx
  802162:	83 ec 1c             	sub    $0x1c,%esp
  802165:	8b 75 08             	mov    0x8(%ebp),%esi
  802168:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80216b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  80216e:	85 db                	test   %ebx,%ebx
  802170:	74 19                	je     80218b <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802172:	8b 45 14             	mov    0x14(%ebp),%eax
  802175:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802179:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80217d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802181:	89 34 24             	mov    %esi,(%esp)
  802184:	e8 1f e2 ff ff       	call   8003a8 <sys_ipc_try_send>
  802189:	eb 1c                	jmp    8021a7 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80218b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802192:	00 
  802193:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80219a:	ee 
  80219b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80219f:	89 34 24             	mov    %esi,(%esp)
  8021a2:	e8 01 e2 ff ff       	call   8003a8 <sys_ipc_try_send>
		}
		if (r == 0)
  8021a7:	85 c0                	test   %eax,%eax
  8021a9:	74 2c                	je     8021d7 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  8021ab:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021ae:	74 20                	je     8021d0 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  8021b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021b4:	c7 44 24 08 44 29 80 	movl   $0x802944,0x8(%esp)
  8021bb:	00 
  8021bc:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8021c3:	00 
  8021c4:	c7 04 24 57 29 80 00 	movl   $0x802957,(%esp)
  8021cb:	e8 54 f5 ff ff       	call   801724 <_panic>
		}
		sys_yield();
  8021d0:	e8 c1 df ff ff       	call   800196 <sys_yield>
	}
  8021d5:	eb 97                	jmp    80216e <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8021d7:	83 c4 1c             	add    $0x1c,%esp
  8021da:	5b                   	pop    %ebx
  8021db:	5e                   	pop    %esi
  8021dc:	5f                   	pop    %edi
  8021dd:	5d                   	pop    %ebp
  8021de:	c3                   	ret    

008021df <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021df:	55                   	push   %ebp
  8021e0:	89 e5                	mov    %esp,%ebp
  8021e2:	53                   	push   %ebx
  8021e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8021e6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021eb:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8021f2:	89 c2                	mov    %eax,%edx
  8021f4:	c1 e2 07             	shl    $0x7,%edx
  8021f7:	29 ca                	sub    %ecx,%edx
  8021f9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021ff:	8b 52 50             	mov    0x50(%edx),%edx
  802202:	39 da                	cmp    %ebx,%edx
  802204:	75 0f                	jne    802215 <ipc_find_env+0x36>
			return envs[i].env_id;
  802206:	c1 e0 07             	shl    $0x7,%eax
  802209:	29 c8                	sub    %ecx,%eax
  80220b:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802210:	8b 40 40             	mov    0x40(%eax),%eax
  802213:	eb 0c                	jmp    802221 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802215:	40                   	inc    %eax
  802216:	3d 00 04 00 00       	cmp    $0x400,%eax
  80221b:	75 ce                	jne    8021eb <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80221d:	66 b8 00 00          	mov    $0x0,%ax
}
  802221:	5b                   	pop    %ebx
  802222:	5d                   	pop    %ebp
  802223:	c3                   	ret    

00802224 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802224:	55                   	push   %ebp
  802225:	89 e5                	mov    %esp,%ebp
  802227:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80222a:	89 c2                	mov    %eax,%edx
  80222c:	c1 ea 16             	shr    $0x16,%edx
  80222f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802236:	f6 c2 01             	test   $0x1,%dl
  802239:	74 1e                	je     802259 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80223b:	c1 e8 0c             	shr    $0xc,%eax
  80223e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802245:	a8 01                	test   $0x1,%al
  802247:	74 17                	je     802260 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802249:	c1 e8 0c             	shr    $0xc,%eax
  80224c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802253:	ef 
  802254:	0f b7 c0             	movzwl %ax,%eax
  802257:	eb 0c                	jmp    802265 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802259:	b8 00 00 00 00       	mov    $0x0,%eax
  80225e:	eb 05                	jmp    802265 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802260:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802265:	5d                   	pop    %ebp
  802266:	c3                   	ret    
	...

00802268 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802268:	55                   	push   %ebp
  802269:	57                   	push   %edi
  80226a:	56                   	push   %esi
  80226b:	83 ec 10             	sub    $0x10,%esp
  80226e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802272:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802276:	89 74 24 04          	mov    %esi,0x4(%esp)
  80227a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80227e:	89 cd                	mov    %ecx,%ebp
  802280:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802284:	85 c0                	test   %eax,%eax
  802286:	75 2c                	jne    8022b4 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802288:	39 f9                	cmp    %edi,%ecx
  80228a:	77 68                	ja     8022f4 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80228c:	85 c9                	test   %ecx,%ecx
  80228e:	75 0b                	jne    80229b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802290:	b8 01 00 00 00       	mov    $0x1,%eax
  802295:	31 d2                	xor    %edx,%edx
  802297:	f7 f1                	div    %ecx
  802299:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	89 f8                	mov    %edi,%eax
  80229f:	f7 f1                	div    %ecx
  8022a1:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022a3:	89 f0                	mov    %esi,%eax
  8022a5:	f7 f1                	div    %ecx
  8022a7:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022a9:	89 f0                	mov    %esi,%eax
  8022ab:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022ad:	83 c4 10             	add    $0x10,%esp
  8022b0:	5e                   	pop    %esi
  8022b1:	5f                   	pop    %edi
  8022b2:	5d                   	pop    %ebp
  8022b3:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022b4:	39 f8                	cmp    %edi,%eax
  8022b6:	77 2c                	ja     8022e4 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8022b8:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8022bb:	83 f6 1f             	xor    $0x1f,%esi
  8022be:	75 4c                	jne    80230c <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022c0:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022c2:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022c7:	72 0a                	jb     8022d3 <__udivdi3+0x6b>
  8022c9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022cd:	0f 87 ad 00 00 00    	ja     802380 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022d3:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022d8:	89 f0                	mov    %esi,%eax
  8022da:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022dc:	83 c4 10             	add    $0x10,%esp
  8022df:	5e                   	pop    %esi
  8022e0:	5f                   	pop    %edi
  8022e1:	5d                   	pop    %ebp
  8022e2:	c3                   	ret    
  8022e3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022e4:	31 ff                	xor    %edi,%edi
  8022e6:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022e8:	89 f0                	mov    %esi,%eax
  8022ea:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022ec:	83 c4 10             	add    $0x10,%esp
  8022ef:	5e                   	pop    %esi
  8022f0:	5f                   	pop    %edi
  8022f1:	5d                   	pop    %ebp
  8022f2:	c3                   	ret    
  8022f3:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022f4:	89 fa                	mov    %edi,%edx
  8022f6:	89 f0                	mov    %esi,%eax
  8022f8:	f7 f1                	div    %ecx
  8022fa:	89 c6                	mov    %eax,%esi
  8022fc:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022fe:	89 f0                	mov    %esi,%eax
  802300:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802302:	83 c4 10             	add    $0x10,%esp
  802305:	5e                   	pop    %esi
  802306:	5f                   	pop    %edi
  802307:	5d                   	pop    %ebp
  802308:	c3                   	ret    
  802309:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80230c:	89 f1                	mov    %esi,%ecx
  80230e:	d3 e0                	shl    %cl,%eax
  802310:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802314:	b8 20 00 00 00       	mov    $0x20,%eax
  802319:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80231b:	89 ea                	mov    %ebp,%edx
  80231d:	88 c1                	mov    %al,%cl
  80231f:	d3 ea                	shr    %cl,%edx
  802321:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802325:	09 ca                	or     %ecx,%edx
  802327:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80232b:	89 f1                	mov    %esi,%ecx
  80232d:	d3 e5                	shl    %cl,%ebp
  80232f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802333:	89 fd                	mov    %edi,%ebp
  802335:	88 c1                	mov    %al,%cl
  802337:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802339:	89 fa                	mov    %edi,%edx
  80233b:	89 f1                	mov    %esi,%ecx
  80233d:	d3 e2                	shl    %cl,%edx
  80233f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802343:	88 c1                	mov    %al,%cl
  802345:	d3 ef                	shr    %cl,%edi
  802347:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802349:	89 f8                	mov    %edi,%eax
  80234b:	89 ea                	mov    %ebp,%edx
  80234d:	f7 74 24 08          	divl   0x8(%esp)
  802351:	89 d1                	mov    %edx,%ecx
  802353:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802355:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802359:	39 d1                	cmp    %edx,%ecx
  80235b:	72 17                	jb     802374 <__udivdi3+0x10c>
  80235d:	74 09                	je     802368 <__udivdi3+0x100>
  80235f:	89 fe                	mov    %edi,%esi
  802361:	31 ff                	xor    %edi,%edi
  802363:	e9 41 ff ff ff       	jmp    8022a9 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802368:	8b 54 24 04          	mov    0x4(%esp),%edx
  80236c:	89 f1                	mov    %esi,%ecx
  80236e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802370:	39 c2                	cmp    %eax,%edx
  802372:	73 eb                	jae    80235f <__udivdi3+0xf7>
		{
		  q0--;
  802374:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802377:	31 ff                	xor    %edi,%edi
  802379:	e9 2b ff ff ff       	jmp    8022a9 <__udivdi3+0x41>
  80237e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802380:	31 f6                	xor    %esi,%esi
  802382:	e9 22 ff ff ff       	jmp    8022a9 <__udivdi3+0x41>
	...

00802388 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802388:	55                   	push   %ebp
  802389:	57                   	push   %edi
  80238a:	56                   	push   %esi
  80238b:	83 ec 20             	sub    $0x20,%esp
  80238e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802392:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802396:	89 44 24 14          	mov    %eax,0x14(%esp)
  80239a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80239e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023a2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8023a6:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8023a8:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8023aa:	85 ed                	test   %ebp,%ebp
  8023ac:	75 16                	jne    8023c4 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8023ae:	39 f1                	cmp    %esi,%ecx
  8023b0:	0f 86 a6 00 00 00    	jbe    80245c <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8023b6:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8023b8:	89 d0                	mov    %edx,%eax
  8023ba:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8023bc:	83 c4 20             	add    $0x20,%esp
  8023bf:	5e                   	pop    %esi
  8023c0:	5f                   	pop    %edi
  8023c1:	5d                   	pop    %ebp
  8023c2:	c3                   	ret    
  8023c3:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023c4:	39 f5                	cmp    %esi,%ebp
  8023c6:	0f 87 ac 00 00 00    	ja     802478 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8023cc:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8023cf:	83 f0 1f             	xor    $0x1f,%eax
  8023d2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023d6:	0f 84 a8 00 00 00    	je     802484 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8023dc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023e0:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023e2:	bf 20 00 00 00       	mov    $0x20,%edi
  8023e7:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8023eb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023ef:	89 f9                	mov    %edi,%ecx
  8023f1:	d3 e8                	shr    %cl,%eax
  8023f3:	09 e8                	or     %ebp,%eax
  8023f5:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8023f9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023fd:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802401:	d3 e0                	shl    %cl,%eax
  802403:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802407:	89 f2                	mov    %esi,%edx
  802409:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80240b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80240f:	d3 e0                	shl    %cl,%eax
  802411:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802415:	8b 44 24 14          	mov    0x14(%esp),%eax
  802419:	89 f9                	mov    %edi,%ecx
  80241b:	d3 e8                	shr    %cl,%eax
  80241d:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80241f:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802421:	89 f2                	mov    %esi,%edx
  802423:	f7 74 24 18          	divl   0x18(%esp)
  802427:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802429:	f7 64 24 0c          	mull   0xc(%esp)
  80242d:	89 c5                	mov    %eax,%ebp
  80242f:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802431:	39 d6                	cmp    %edx,%esi
  802433:	72 67                	jb     80249c <__umoddi3+0x114>
  802435:	74 75                	je     8024ac <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802437:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80243b:	29 e8                	sub    %ebp,%eax
  80243d:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80243f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802443:	d3 e8                	shr    %cl,%eax
  802445:	89 f2                	mov    %esi,%edx
  802447:	89 f9                	mov    %edi,%ecx
  802449:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80244b:	09 d0                	or     %edx,%eax
  80244d:	89 f2                	mov    %esi,%edx
  80244f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802453:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802455:	83 c4 20             	add    $0x20,%esp
  802458:	5e                   	pop    %esi
  802459:	5f                   	pop    %edi
  80245a:	5d                   	pop    %ebp
  80245b:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80245c:	85 c9                	test   %ecx,%ecx
  80245e:	75 0b                	jne    80246b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802460:	b8 01 00 00 00       	mov    $0x1,%eax
  802465:	31 d2                	xor    %edx,%edx
  802467:	f7 f1                	div    %ecx
  802469:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80246b:	89 f0                	mov    %esi,%eax
  80246d:	31 d2                	xor    %edx,%edx
  80246f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802471:	89 f8                	mov    %edi,%eax
  802473:	e9 3e ff ff ff       	jmp    8023b6 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802478:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80247a:	83 c4 20             	add    $0x20,%esp
  80247d:	5e                   	pop    %esi
  80247e:	5f                   	pop    %edi
  80247f:	5d                   	pop    %ebp
  802480:	c3                   	ret    
  802481:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802484:	39 f5                	cmp    %esi,%ebp
  802486:	72 04                	jb     80248c <__umoddi3+0x104>
  802488:	39 f9                	cmp    %edi,%ecx
  80248a:	77 06                	ja     802492 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80248c:	89 f2                	mov    %esi,%edx
  80248e:	29 cf                	sub    %ecx,%edi
  802490:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802492:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802494:	83 c4 20             	add    $0x20,%esp
  802497:	5e                   	pop    %esi
  802498:	5f                   	pop    %edi
  802499:	5d                   	pop    %ebp
  80249a:	c3                   	ret    
  80249b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80249c:	89 d1                	mov    %edx,%ecx
  80249e:	89 c5                	mov    %eax,%ebp
  8024a0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8024a4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8024a8:	eb 8d                	jmp    802437 <__umoddi3+0xaf>
  8024aa:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8024ac:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8024b0:	72 ea                	jb     80249c <__umoddi3+0x114>
  8024b2:	89 f1                	mov    %esi,%ecx
  8024b4:	eb 81                	jmp    802437 <__umoddi3+0xaf>
