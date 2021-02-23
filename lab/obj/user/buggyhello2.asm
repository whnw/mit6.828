
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 30 80 00       	mov    0x803000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 75 00 00 00       	call   8000c4 <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 10             	sub    $0x10,%esp
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800062:	e8 ec 00 00 00       	call   800153 <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800073:	c1 e0 07             	shl    $0x7,%eax
  800076:	29 d0                	sub    %edx,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 f6                	test   %esi,%esi
  800084:	7e 07                	jle    80008d <libmain+0x39>
		binaryname = argv[0];
  800086:	8b 03                	mov    (%ebx),%eax
  800088:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80008d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800091:	89 34 24             	mov    %esi,(%esp)
  800094:	e8 9b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800099:	e8 0a 00 00 00       	call   8000a8 <exit>
}
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5d                   	pop    %ebp
  8000a4:	c3                   	ret    
  8000a5:	00 00                	add    %al,(%eax)
	...

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ae:	e8 90 05 00 00       	call   800643 <close_all>
	sys_env_destroy(0);
  8000b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ba:	e8 42 00 00 00       	call   800101 <sys_env_destroy>
}
  8000bf:	c9                   	leave  
  8000c0:	c3                   	ret    
  8000c1:	00 00                	add    %al,(%eax)
	...

008000c4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d5:	89 c3                	mov    %eax,%ebx
  8000d7:	89 c7                	mov    %eax,%edi
  8000d9:	89 c6                	mov    %eax,%esi
  8000db:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000dd:	5b                   	pop    %ebx
  8000de:	5e                   	pop    %esi
  8000df:	5f                   	pop    %edi
  8000e0:	5d                   	pop    %ebp
  8000e1:	c3                   	ret    

008000e2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	57                   	push   %edi
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f2:	89 d1                	mov    %edx,%ecx
  8000f4:	89 d3                	mov    %edx,%ebx
  8000f6:	89 d7                	mov    %edx,%edi
  8000f8:	89 d6                	mov    %edx,%esi
  8000fa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    

00800101 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	57                   	push   %edi
  800105:	56                   	push   %esi
  800106:	53                   	push   %ebx
  800107:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010f:	b8 03 00 00 00       	mov    $0x3,%eax
  800114:	8b 55 08             	mov    0x8(%ebp),%edx
  800117:	89 cb                	mov    %ecx,%ebx
  800119:	89 cf                	mov    %ecx,%edi
  80011b:	89 ce                	mov    %ecx,%esi
  80011d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80011f:	85 c0                	test   %eax,%eax
  800121:	7e 28                	jle    80014b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800123:	89 44 24 10          	mov    %eax,0x10(%esp)
  800127:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80012e:	00 
  80012f:	c7 44 24 08 b8 24 80 	movl   $0x8024b8,0x8(%esp)
  800136:	00 
  800137:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80013e:	00 
  80013f:	c7 04 24 d5 24 80 00 	movl   $0x8024d5,(%esp)
  800146:	e8 b5 15 00 00       	call   801700 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80014b:	83 c4 2c             	add    $0x2c,%esp
  80014e:	5b                   	pop    %ebx
  80014f:	5e                   	pop    %esi
  800150:	5f                   	pop    %edi
  800151:	5d                   	pop    %ebp
  800152:	c3                   	ret    

00800153 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	57                   	push   %edi
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	b8 02 00 00 00       	mov    $0x2,%eax
  800163:	89 d1                	mov    %edx,%ecx
  800165:	89 d3                	mov    %edx,%ebx
  800167:	89 d7                	mov    %edx,%edi
  800169:	89 d6                	mov    %edx,%esi
  80016b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016d:	5b                   	pop    %ebx
  80016e:	5e                   	pop    %esi
  80016f:	5f                   	pop    %edi
  800170:	5d                   	pop    %ebp
  800171:	c3                   	ret    

00800172 <sys_yield>:

void
sys_yield(void)
{
  800172:	55                   	push   %ebp
  800173:	89 e5                	mov    %esp,%ebp
  800175:	57                   	push   %edi
  800176:	56                   	push   %esi
  800177:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800178:	ba 00 00 00 00       	mov    $0x0,%edx
  80017d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800182:	89 d1                	mov    %edx,%ecx
  800184:	89 d3                	mov    %edx,%ebx
  800186:	89 d7                	mov    %edx,%edi
  800188:	89 d6                	mov    %edx,%esi
  80018a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80018c:	5b                   	pop    %ebx
  80018d:	5e                   	pop    %esi
  80018e:	5f                   	pop    %edi
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    

00800191 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019a:	be 00 00 00 00       	mov    $0x0,%esi
  80019f:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	89 f7                	mov    %esi,%edi
  8001af:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b1:	85 c0                	test   %eax,%eax
  8001b3:	7e 28                	jle    8001dd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001c0:	00 
  8001c1:	c7 44 24 08 b8 24 80 	movl   $0x8024b8,0x8(%esp)
  8001c8:	00 
  8001c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001d0:	00 
  8001d1:	c7 04 24 d5 24 80 00 	movl   $0x8024d5,(%esp)
  8001d8:	e8 23 15 00 00       	call   801700 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001dd:	83 c4 2c             	add    $0x2c,%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5f                   	pop    %edi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    

008001e5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	57                   	push   %edi
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8001f3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800202:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800204:	85 c0                	test   %eax,%eax
  800206:	7e 28                	jle    800230 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800208:	89 44 24 10          	mov    %eax,0x10(%esp)
  80020c:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800213:	00 
  800214:	c7 44 24 08 b8 24 80 	movl   $0x8024b8,0x8(%esp)
  80021b:	00 
  80021c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800223:	00 
  800224:	c7 04 24 d5 24 80 00 	movl   $0x8024d5,(%esp)
  80022b:	e8 d0 14 00 00       	call   801700 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800230:	83 c4 2c             	add    $0x2c,%esp
  800233:	5b                   	pop    %ebx
  800234:	5e                   	pop    %esi
  800235:	5f                   	pop    %edi
  800236:	5d                   	pop    %ebp
  800237:	c3                   	ret    

00800238 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
  80023e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800241:	bb 00 00 00 00       	mov    $0x0,%ebx
  800246:	b8 06 00 00 00       	mov    $0x6,%eax
  80024b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024e:	8b 55 08             	mov    0x8(%ebp),%edx
  800251:	89 df                	mov    %ebx,%edi
  800253:	89 de                	mov    %ebx,%esi
  800255:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800257:	85 c0                	test   %eax,%eax
  800259:	7e 28                	jle    800283 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80025f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800266:	00 
  800267:	c7 44 24 08 b8 24 80 	movl   $0x8024b8,0x8(%esp)
  80026e:	00 
  80026f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800276:	00 
  800277:	c7 04 24 d5 24 80 00 	movl   $0x8024d5,(%esp)
  80027e:	e8 7d 14 00 00       	call   801700 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800283:	83 c4 2c             	add    $0x2c,%esp
  800286:	5b                   	pop    %ebx
  800287:	5e                   	pop    %esi
  800288:	5f                   	pop    %edi
  800289:	5d                   	pop    %ebp
  80028a:	c3                   	ret    

0080028b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	57                   	push   %edi
  80028f:	56                   	push   %esi
  800290:	53                   	push   %ebx
  800291:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800294:	bb 00 00 00 00       	mov    $0x0,%ebx
  800299:	b8 08 00 00 00       	mov    $0x8,%eax
  80029e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a4:	89 df                	mov    %ebx,%edi
  8002a6:	89 de                	mov    %ebx,%esi
  8002a8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002aa:	85 c0                	test   %eax,%eax
  8002ac:	7e 28                	jle    8002d6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002b2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 08 b8 24 80 	movl   $0x8024b8,0x8(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c9:	00 
  8002ca:	c7 04 24 d5 24 80 00 	movl   $0x8024d5,(%esp)
  8002d1:	e8 2a 14 00 00       	call   801700 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002d6:	83 c4 2c             	add    $0x2c,%esp
  8002d9:	5b                   	pop    %ebx
  8002da:	5e                   	pop    %esi
  8002db:	5f                   	pop    %edi
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	57                   	push   %edi
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ec:	b8 09 00 00 00       	mov    $0x9,%eax
  8002f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f7:	89 df                	mov    %ebx,%edi
  8002f9:	89 de                	mov    %ebx,%esi
  8002fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002fd:	85 c0                	test   %eax,%eax
  8002ff:	7e 28                	jle    800329 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800301:	89 44 24 10          	mov    %eax,0x10(%esp)
  800305:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  80030c:	00 
  80030d:	c7 44 24 08 b8 24 80 	movl   $0x8024b8,0x8(%esp)
  800314:	00 
  800315:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80031c:	00 
  80031d:	c7 04 24 d5 24 80 00 	movl   $0x8024d5,(%esp)
  800324:	e8 d7 13 00 00       	call   801700 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800329:	83 c4 2c             	add    $0x2c,%esp
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800344:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800347:	8b 55 08             	mov    0x8(%ebp),%edx
  80034a:	89 df                	mov    %ebx,%edi
  80034c:	89 de                	mov    %ebx,%esi
  80034e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800350:	85 c0                	test   %eax,%eax
  800352:	7e 28                	jle    80037c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800354:	89 44 24 10          	mov    %eax,0x10(%esp)
  800358:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80035f:	00 
  800360:	c7 44 24 08 b8 24 80 	movl   $0x8024b8,0x8(%esp)
  800367:	00 
  800368:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80036f:	00 
  800370:	c7 04 24 d5 24 80 00 	movl   $0x8024d5,(%esp)
  800377:	e8 84 13 00 00       	call   801700 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80037c:	83 c4 2c             	add    $0x2c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038a:	be 00 00 00 00       	mov    $0x0,%esi
  80038f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800394:	8b 7d 14             	mov    0x14(%ebp),%edi
  800397:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80039a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80039d:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8003a2:	5b                   	pop    %ebx
  8003a3:	5e                   	pop    %esi
  8003a4:	5f                   	pop    %edi
  8003a5:	5d                   	pop    %ebp
  8003a6:	c3                   	ret    

008003a7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003a7:	55                   	push   %ebp
  8003a8:	89 e5                	mov    %esp,%ebp
  8003aa:	57                   	push   %edi
  8003ab:	56                   	push   %esi
  8003ac:	53                   	push   %ebx
  8003ad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bd:	89 cb                	mov    %ecx,%ebx
  8003bf:	89 cf                	mov    %ecx,%edi
  8003c1:	89 ce                	mov    %ecx,%esi
  8003c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003c5:	85 c0                	test   %eax,%eax
  8003c7:	7e 28                	jle    8003f1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003cd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003d4:	00 
  8003d5:	c7 44 24 08 b8 24 80 	movl   $0x8024b8,0x8(%esp)
  8003dc:	00 
  8003dd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003e4:	00 
  8003e5:	c7 04 24 d5 24 80 00 	movl   $0x8024d5,(%esp)
  8003ec:	e8 0f 13 00 00       	call   801700 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003f1:	83 c4 2c             	add    $0x2c,%esp
  8003f4:	5b                   	pop    %ebx
  8003f5:	5e                   	pop    %esi
  8003f6:	5f                   	pop    %edi
  8003f7:	5d                   	pop    %ebp
  8003f8:	c3                   	ret    

008003f9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8003f9:	55                   	push   %ebp
  8003fa:	89 e5                	mov    %esp,%ebp
  8003fc:	57                   	push   %edi
  8003fd:	56                   	push   %esi
  8003fe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800404:	b8 0e 00 00 00       	mov    $0xe,%eax
  800409:	89 d1                	mov    %edx,%ecx
  80040b:	89 d3                	mov    %edx,%ebx
  80040d:	89 d7                	mov    %edx,%edi
  80040f:	89 d6                	mov    %edx,%esi
  800411:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800413:	5b                   	pop    %ebx
  800414:	5e                   	pop    %esi
  800415:	5f                   	pop    %edi
  800416:	5d                   	pop    %ebp
  800417:	c3                   	ret    

00800418 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	57                   	push   %edi
  80041c:	56                   	push   %esi
  80041d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80041e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800423:	b8 0f 00 00 00       	mov    $0xf,%eax
  800428:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042b:	8b 55 08             	mov    0x8(%ebp),%edx
  80042e:	89 df                	mov    %ebx,%edi
  800430:	89 de                	mov    %ebx,%esi
  800432:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800434:	5b                   	pop    %ebx
  800435:	5e                   	pop    %esi
  800436:	5f                   	pop    %edi
  800437:	5d                   	pop    %ebp
  800438:	c3                   	ret    

00800439 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800439:	55                   	push   %ebp
  80043a:	89 e5                	mov    %esp,%ebp
  80043c:	57                   	push   %edi
  80043d:	56                   	push   %esi
  80043e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80043f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800444:	b8 10 00 00 00       	mov    $0x10,%eax
  800449:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80044c:	8b 55 08             	mov    0x8(%ebp),%edx
  80044f:	89 df                	mov    %ebx,%edi
  800451:	89 de                	mov    %ebx,%esi
  800453:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800455:	5b                   	pop    %ebx
  800456:	5e                   	pop    %esi
  800457:	5f                   	pop    %edi
  800458:	5d                   	pop    %ebp
  800459:	c3                   	ret    
	...

0080045c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80045c:	55                   	push   %ebp
  80045d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80045f:	8b 45 08             	mov    0x8(%ebp),%eax
  800462:	05 00 00 00 30       	add    $0x30000000,%eax
  800467:	c1 e8 0c             	shr    $0xc,%eax
}
  80046a:	5d                   	pop    %ebp
  80046b:	c3                   	ret    

0080046c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80046c:	55                   	push   %ebp
  80046d:	89 e5                	mov    %esp,%ebp
  80046f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800472:	8b 45 08             	mov    0x8(%ebp),%eax
  800475:	89 04 24             	mov    %eax,(%esp)
  800478:	e8 df ff ff ff       	call   80045c <fd2num>
  80047d:	c1 e0 0c             	shl    $0xc,%eax
  800480:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800485:	c9                   	leave  
  800486:	c3                   	ret    

00800487 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800487:	55                   	push   %ebp
  800488:	89 e5                	mov    %esp,%ebp
  80048a:	53                   	push   %ebx
  80048b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800493:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800495:	89 c2                	mov    %eax,%edx
  800497:	c1 ea 16             	shr    $0x16,%edx
  80049a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004a1:	f6 c2 01             	test   $0x1,%dl
  8004a4:	74 11                	je     8004b7 <fd_alloc+0x30>
  8004a6:	89 c2                	mov    %eax,%edx
  8004a8:	c1 ea 0c             	shr    $0xc,%edx
  8004ab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004b2:	f6 c2 01             	test   $0x1,%dl
  8004b5:	75 09                	jne    8004c0 <fd_alloc+0x39>
			*fd_store = fd;
  8004b7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8004b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004be:	eb 17                	jmp    8004d7 <fd_alloc+0x50>
  8004c0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8004c5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8004ca:	75 c7                	jne    800493 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8004cc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8004d2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8004d7:	5b                   	pop    %ebx
  8004d8:	5d                   	pop    %ebp
  8004d9:	c3                   	ret    

008004da <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004da:	55                   	push   %ebp
  8004db:	89 e5                	mov    %esp,%ebp
  8004dd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004e0:	83 f8 1f             	cmp    $0x1f,%eax
  8004e3:	77 36                	ja     80051b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004e5:	c1 e0 0c             	shl    $0xc,%eax
  8004e8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004ed:	89 c2                	mov    %eax,%edx
  8004ef:	c1 ea 16             	shr    $0x16,%edx
  8004f2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004f9:	f6 c2 01             	test   $0x1,%dl
  8004fc:	74 24                	je     800522 <fd_lookup+0x48>
  8004fe:	89 c2                	mov    %eax,%edx
  800500:	c1 ea 0c             	shr    $0xc,%edx
  800503:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80050a:	f6 c2 01             	test   $0x1,%dl
  80050d:	74 1a                	je     800529 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80050f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800512:	89 02                	mov    %eax,(%edx)
	return 0;
  800514:	b8 00 00 00 00       	mov    $0x0,%eax
  800519:	eb 13                	jmp    80052e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80051b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800520:	eb 0c                	jmp    80052e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800522:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800527:	eb 05                	jmp    80052e <fd_lookup+0x54>
  800529:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80052e:	5d                   	pop    %ebp
  80052f:	c3                   	ret    

00800530 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	53                   	push   %ebx
  800534:	83 ec 14             	sub    $0x14,%esp
  800537:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80053a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80053d:	ba 00 00 00 00       	mov    $0x0,%edx
  800542:	eb 0e                	jmp    800552 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800544:	39 08                	cmp    %ecx,(%eax)
  800546:	75 09                	jne    800551 <dev_lookup+0x21>
			*dev = devtab[i];
  800548:	89 03                	mov    %eax,(%ebx)
			return 0;
  80054a:	b8 00 00 00 00       	mov    $0x0,%eax
  80054f:	eb 33                	jmp    800584 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800551:	42                   	inc    %edx
  800552:	8b 04 95 60 25 80 00 	mov    0x802560(,%edx,4),%eax
  800559:	85 c0                	test   %eax,%eax
  80055b:	75 e7                	jne    800544 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80055d:	a1 08 40 80 00       	mov    0x804008,%eax
  800562:	8b 40 48             	mov    0x48(%eax),%eax
  800565:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800569:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056d:	c7 04 24 e4 24 80 00 	movl   $0x8024e4,(%esp)
  800574:	e8 7f 12 00 00       	call   8017f8 <cprintf>
	*dev = 0;
  800579:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80057f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800584:	83 c4 14             	add    $0x14,%esp
  800587:	5b                   	pop    %ebx
  800588:	5d                   	pop    %ebp
  800589:	c3                   	ret    

0080058a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80058a:	55                   	push   %ebp
  80058b:	89 e5                	mov    %esp,%ebp
  80058d:	56                   	push   %esi
  80058e:	53                   	push   %ebx
  80058f:	83 ec 30             	sub    $0x30,%esp
  800592:	8b 75 08             	mov    0x8(%ebp),%esi
  800595:	8a 45 0c             	mov    0xc(%ebp),%al
  800598:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80059b:	89 34 24             	mov    %esi,(%esp)
  80059e:	e8 b9 fe ff ff       	call   80045c <fd2num>
  8005a3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8005a6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005aa:	89 04 24             	mov    %eax,(%esp)
  8005ad:	e8 28 ff ff ff       	call   8004da <fd_lookup>
  8005b2:	89 c3                	mov    %eax,%ebx
  8005b4:	85 c0                	test   %eax,%eax
  8005b6:	78 05                	js     8005bd <fd_close+0x33>
	    || fd != fd2)
  8005b8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8005bb:	74 0d                	je     8005ca <fd_close+0x40>
		return (must_exist ? r : 0);
  8005bd:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8005c1:	75 46                	jne    800609 <fd_close+0x7f>
  8005c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005c8:	eb 3f                	jmp    800609 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8005ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8005cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d1:	8b 06                	mov    (%esi),%eax
  8005d3:	89 04 24             	mov    %eax,(%esp)
  8005d6:	e8 55 ff ff ff       	call   800530 <dev_lookup>
  8005db:	89 c3                	mov    %eax,%ebx
  8005dd:	85 c0                	test   %eax,%eax
  8005df:	78 18                	js     8005f9 <fd_close+0x6f>
		if (dev->dev_close)
  8005e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005e4:	8b 40 10             	mov    0x10(%eax),%eax
  8005e7:	85 c0                	test   %eax,%eax
  8005e9:	74 09                	je     8005f4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005eb:	89 34 24             	mov    %esi,(%esp)
  8005ee:	ff d0                	call   *%eax
  8005f0:	89 c3                	mov    %eax,%ebx
  8005f2:	eb 05                	jmp    8005f9 <fd_close+0x6f>
		else
			r = 0;
  8005f4:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800604:	e8 2f fc ff ff       	call   800238 <sys_page_unmap>
	return r;
}
  800609:	89 d8                	mov    %ebx,%eax
  80060b:	83 c4 30             	add    $0x30,%esp
  80060e:	5b                   	pop    %ebx
  80060f:	5e                   	pop    %esi
  800610:	5d                   	pop    %ebp
  800611:	c3                   	ret    

00800612 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800612:	55                   	push   %ebp
  800613:	89 e5                	mov    %esp,%ebp
  800615:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800618:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80061b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061f:	8b 45 08             	mov    0x8(%ebp),%eax
  800622:	89 04 24             	mov    %eax,(%esp)
  800625:	e8 b0 fe ff ff       	call   8004da <fd_lookup>
  80062a:	85 c0                	test   %eax,%eax
  80062c:	78 13                	js     800641 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80062e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800635:	00 
  800636:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800639:	89 04 24             	mov    %eax,(%esp)
  80063c:	e8 49 ff ff ff       	call   80058a <fd_close>
}
  800641:	c9                   	leave  
  800642:	c3                   	ret    

00800643 <close_all>:

void
close_all(void)
{
  800643:	55                   	push   %ebp
  800644:	89 e5                	mov    %esp,%ebp
  800646:	53                   	push   %ebx
  800647:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80064a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80064f:	89 1c 24             	mov    %ebx,(%esp)
  800652:	e8 bb ff ff ff       	call   800612 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800657:	43                   	inc    %ebx
  800658:	83 fb 20             	cmp    $0x20,%ebx
  80065b:	75 f2                	jne    80064f <close_all+0xc>
		close(i);
}
  80065d:	83 c4 14             	add    $0x14,%esp
  800660:	5b                   	pop    %ebx
  800661:	5d                   	pop    %ebp
  800662:	c3                   	ret    

00800663 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800663:	55                   	push   %ebp
  800664:	89 e5                	mov    %esp,%ebp
  800666:	57                   	push   %edi
  800667:	56                   	push   %esi
  800668:	53                   	push   %ebx
  800669:	83 ec 4c             	sub    $0x4c,%esp
  80066c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80066f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800672:	89 44 24 04          	mov    %eax,0x4(%esp)
  800676:	8b 45 08             	mov    0x8(%ebp),%eax
  800679:	89 04 24             	mov    %eax,(%esp)
  80067c:	e8 59 fe ff ff       	call   8004da <fd_lookup>
  800681:	89 c3                	mov    %eax,%ebx
  800683:	85 c0                	test   %eax,%eax
  800685:	0f 88 e3 00 00 00    	js     80076e <dup+0x10b>
		return r;
	close(newfdnum);
  80068b:	89 3c 24             	mov    %edi,(%esp)
  80068e:	e8 7f ff ff ff       	call   800612 <close>

	newfd = INDEX2FD(newfdnum);
  800693:	89 fe                	mov    %edi,%esi
  800695:	c1 e6 0c             	shl    $0xc,%esi
  800698:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80069e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006a1:	89 04 24             	mov    %eax,(%esp)
  8006a4:	e8 c3 fd ff ff       	call   80046c <fd2data>
  8006a9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8006ab:	89 34 24             	mov    %esi,(%esp)
  8006ae:	e8 b9 fd ff ff       	call   80046c <fd2data>
  8006b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8006b6:	89 d8                	mov    %ebx,%eax
  8006b8:	c1 e8 16             	shr    $0x16,%eax
  8006bb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8006c2:	a8 01                	test   $0x1,%al
  8006c4:	74 46                	je     80070c <dup+0xa9>
  8006c6:	89 d8                	mov    %ebx,%eax
  8006c8:	c1 e8 0c             	shr    $0xc,%eax
  8006cb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8006d2:	f6 c2 01             	test   $0x1,%dl
  8006d5:	74 35                	je     80070c <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8006d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006de:	25 07 0e 00 00       	and    $0xe07,%eax
  8006e3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006e7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006f5:	00 
  8006f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800701:	e8 df fa ff ff       	call   8001e5 <sys_page_map>
  800706:	89 c3                	mov    %eax,%ebx
  800708:	85 c0                	test   %eax,%eax
  80070a:	78 3b                	js     800747 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80070c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80070f:	89 c2                	mov    %eax,%edx
  800711:	c1 ea 0c             	shr    $0xc,%edx
  800714:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80071b:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800721:	89 54 24 10          	mov    %edx,0x10(%esp)
  800725:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800729:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800730:	00 
  800731:	89 44 24 04          	mov    %eax,0x4(%esp)
  800735:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80073c:	e8 a4 fa ff ff       	call   8001e5 <sys_page_map>
  800741:	89 c3                	mov    %eax,%ebx
  800743:	85 c0                	test   %eax,%eax
  800745:	79 25                	jns    80076c <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800747:	89 74 24 04          	mov    %esi,0x4(%esp)
  80074b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800752:	e8 e1 fa ff ff       	call   800238 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800757:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80075a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800765:	e8 ce fa ff ff       	call   800238 <sys_page_unmap>
	return r;
  80076a:	eb 02                	jmp    80076e <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80076c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80076e:	89 d8                	mov    %ebx,%eax
  800770:	83 c4 4c             	add    $0x4c,%esp
  800773:	5b                   	pop    %ebx
  800774:	5e                   	pop    %esi
  800775:	5f                   	pop    %edi
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	53                   	push   %ebx
  80077c:	83 ec 24             	sub    $0x24,%esp
  80077f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800782:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800785:	89 44 24 04          	mov    %eax,0x4(%esp)
  800789:	89 1c 24             	mov    %ebx,(%esp)
  80078c:	e8 49 fd ff ff       	call   8004da <fd_lookup>
  800791:	85 c0                	test   %eax,%eax
  800793:	78 6d                	js     800802 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800795:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800798:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80079f:	8b 00                	mov    (%eax),%eax
  8007a1:	89 04 24             	mov    %eax,(%esp)
  8007a4:	e8 87 fd ff ff       	call   800530 <dev_lookup>
  8007a9:	85 c0                	test   %eax,%eax
  8007ab:	78 55                	js     800802 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8007ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b0:	8b 50 08             	mov    0x8(%eax),%edx
  8007b3:	83 e2 03             	and    $0x3,%edx
  8007b6:	83 fa 01             	cmp    $0x1,%edx
  8007b9:	75 23                	jne    8007de <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8007bb:	a1 08 40 80 00       	mov    0x804008,%eax
  8007c0:	8b 40 48             	mov    0x48(%eax),%eax
  8007c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007cb:	c7 04 24 25 25 80 00 	movl   $0x802525,(%esp)
  8007d2:	e8 21 10 00 00       	call   8017f8 <cprintf>
		return -E_INVAL;
  8007d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007dc:	eb 24                	jmp    800802 <read+0x8a>
	}
	if (!dev->dev_read)
  8007de:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e1:	8b 52 08             	mov    0x8(%edx),%edx
  8007e4:	85 d2                	test   %edx,%edx
  8007e6:	74 15                	je     8007fd <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8007e8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007eb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007f6:	89 04 24             	mov    %eax,(%esp)
  8007f9:	ff d2                	call   *%edx
  8007fb:	eb 05                	jmp    800802 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8007fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  800802:	83 c4 24             	add    $0x24,%esp
  800805:	5b                   	pop    %ebx
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	57                   	push   %edi
  80080c:	56                   	push   %esi
  80080d:	53                   	push   %ebx
  80080e:	83 ec 1c             	sub    $0x1c,%esp
  800811:	8b 7d 08             	mov    0x8(%ebp),%edi
  800814:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800817:	bb 00 00 00 00       	mov    $0x0,%ebx
  80081c:	eb 23                	jmp    800841 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80081e:	89 f0                	mov    %esi,%eax
  800820:	29 d8                	sub    %ebx,%eax
  800822:	89 44 24 08          	mov    %eax,0x8(%esp)
  800826:	8b 45 0c             	mov    0xc(%ebp),%eax
  800829:	01 d8                	add    %ebx,%eax
  80082b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082f:	89 3c 24             	mov    %edi,(%esp)
  800832:	e8 41 ff ff ff       	call   800778 <read>
		if (m < 0)
  800837:	85 c0                	test   %eax,%eax
  800839:	78 10                	js     80084b <readn+0x43>
			return m;
		if (m == 0)
  80083b:	85 c0                	test   %eax,%eax
  80083d:	74 0a                	je     800849 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80083f:	01 c3                	add    %eax,%ebx
  800841:	39 f3                	cmp    %esi,%ebx
  800843:	72 d9                	jb     80081e <readn+0x16>
  800845:	89 d8                	mov    %ebx,%eax
  800847:	eb 02                	jmp    80084b <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800849:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80084b:	83 c4 1c             	add    $0x1c,%esp
  80084e:	5b                   	pop    %ebx
  80084f:	5e                   	pop    %esi
  800850:	5f                   	pop    %edi
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    

00800853 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800853:	55                   	push   %ebp
  800854:	89 e5                	mov    %esp,%ebp
  800856:	53                   	push   %ebx
  800857:	83 ec 24             	sub    $0x24,%esp
  80085a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80085d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800860:	89 44 24 04          	mov    %eax,0x4(%esp)
  800864:	89 1c 24             	mov    %ebx,(%esp)
  800867:	e8 6e fc ff ff       	call   8004da <fd_lookup>
  80086c:	85 c0                	test   %eax,%eax
  80086e:	78 68                	js     8008d8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800870:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800873:	89 44 24 04          	mov    %eax,0x4(%esp)
  800877:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80087a:	8b 00                	mov    (%eax),%eax
  80087c:	89 04 24             	mov    %eax,(%esp)
  80087f:	e8 ac fc ff ff       	call   800530 <dev_lookup>
  800884:	85 c0                	test   %eax,%eax
  800886:	78 50                	js     8008d8 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800888:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80088f:	75 23                	jne    8008b4 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800891:	a1 08 40 80 00       	mov    0x804008,%eax
  800896:	8b 40 48             	mov    0x48(%eax),%eax
  800899:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80089d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a1:	c7 04 24 41 25 80 00 	movl   $0x802541,(%esp)
  8008a8:	e8 4b 0f 00 00       	call   8017f8 <cprintf>
		return -E_INVAL;
  8008ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008b2:	eb 24                	jmp    8008d8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8008b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008b7:	8b 52 0c             	mov    0xc(%edx),%edx
  8008ba:	85 d2                	test   %edx,%edx
  8008bc:	74 15                	je     8008d3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8008be:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008c1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008cc:	89 04 24             	mov    %eax,(%esp)
  8008cf:	ff d2                	call   *%edx
  8008d1:	eb 05                	jmp    8008d8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8008d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8008d8:	83 c4 24             	add    $0x24,%esp
  8008db:	5b                   	pop    %ebx
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <seek>:

int
seek(int fdnum, off_t offset)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008e4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8008e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	89 04 24             	mov    %eax,(%esp)
  8008f1:	e8 e4 fb ff ff       	call   8004da <fd_lookup>
  8008f6:	85 c0                	test   %eax,%eax
  8008f8:	78 0e                	js     800908 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800900:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800908:	c9                   	leave  
  800909:	c3                   	ret    

0080090a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	53                   	push   %ebx
  80090e:	83 ec 24             	sub    $0x24,%esp
  800911:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800914:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800917:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091b:	89 1c 24             	mov    %ebx,(%esp)
  80091e:	e8 b7 fb ff ff       	call   8004da <fd_lookup>
  800923:	85 c0                	test   %eax,%eax
  800925:	78 61                	js     800988 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800927:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80092a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800931:	8b 00                	mov    (%eax),%eax
  800933:	89 04 24             	mov    %eax,(%esp)
  800936:	e8 f5 fb ff ff       	call   800530 <dev_lookup>
  80093b:	85 c0                	test   %eax,%eax
  80093d:	78 49                	js     800988 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80093f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800942:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800946:	75 23                	jne    80096b <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800948:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80094d:	8b 40 48             	mov    0x48(%eax),%eax
  800950:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800954:	89 44 24 04          	mov    %eax,0x4(%esp)
  800958:	c7 04 24 04 25 80 00 	movl   $0x802504,(%esp)
  80095f:	e8 94 0e 00 00       	call   8017f8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800964:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800969:	eb 1d                	jmp    800988 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80096b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80096e:	8b 52 18             	mov    0x18(%edx),%edx
  800971:	85 d2                	test   %edx,%edx
  800973:	74 0e                	je     800983 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800975:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800978:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80097c:	89 04 24             	mov    %eax,(%esp)
  80097f:	ff d2                	call   *%edx
  800981:	eb 05                	jmp    800988 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800983:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800988:	83 c4 24             	add    $0x24,%esp
  80098b:	5b                   	pop    %ebx
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80098e:	55                   	push   %ebp
  80098f:	89 e5                	mov    %esp,%ebp
  800991:	53                   	push   %ebx
  800992:	83 ec 24             	sub    $0x24,%esp
  800995:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800998:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80099b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	89 04 24             	mov    %eax,(%esp)
  8009a5:	e8 30 fb ff ff       	call   8004da <fd_lookup>
  8009aa:	85 c0                	test   %eax,%eax
  8009ac:	78 52                	js     800a00 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b8:	8b 00                	mov    (%eax),%eax
  8009ba:	89 04 24             	mov    %eax,(%esp)
  8009bd:	e8 6e fb ff ff       	call   800530 <dev_lookup>
  8009c2:	85 c0                	test   %eax,%eax
  8009c4:	78 3a                	js     800a00 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8009c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8009cd:	74 2c                	je     8009fb <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8009cf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8009d2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8009d9:	00 00 00 
	stat->st_isdir = 0;
  8009dc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8009e3:	00 00 00 
	stat->st_dev = dev;
  8009e6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009f3:	89 14 24             	mov    %edx,(%esp)
  8009f6:	ff 50 14             	call   *0x14(%eax)
  8009f9:	eb 05                	jmp    800a00 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8009fb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800a00:	83 c4 24             	add    $0x24,%esp
  800a03:	5b                   	pop    %ebx
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800a0e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a15:	00 
  800a16:	8b 45 08             	mov    0x8(%ebp),%eax
  800a19:	89 04 24             	mov    %eax,(%esp)
  800a1c:	e8 2a 02 00 00       	call   800c4b <open>
  800a21:	89 c3                	mov    %eax,%ebx
  800a23:	85 c0                	test   %eax,%eax
  800a25:	78 1b                	js     800a42 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2e:	89 1c 24             	mov    %ebx,(%esp)
  800a31:	e8 58 ff ff ff       	call   80098e <fstat>
  800a36:	89 c6                	mov    %eax,%esi
	close(fd);
  800a38:	89 1c 24             	mov    %ebx,(%esp)
  800a3b:	e8 d2 fb ff ff       	call   800612 <close>
	return r;
  800a40:	89 f3                	mov    %esi,%ebx
}
  800a42:	89 d8                	mov    %ebx,%eax
  800a44:	83 c4 10             	add    $0x10,%esp
  800a47:	5b                   	pop    %ebx
  800a48:	5e                   	pop    %esi
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    
	...

00800a4c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	56                   	push   %esi
  800a50:	53                   	push   %ebx
  800a51:	83 ec 10             	sub    $0x10,%esp
  800a54:	89 c3                	mov    %eax,%ebx
  800a56:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a58:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a5f:	75 11                	jne    800a72 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a68:	e8 4e 17 00 00       	call   8021bb <ipc_find_env>
  800a6d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a72:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a79:	00 
  800a7a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a81:	00 
  800a82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a86:	a1 00 40 80 00       	mov    0x804000,%eax
  800a8b:	89 04 24             	mov    %eax,(%esp)
  800a8e:	e8 a5 16 00 00       	call   802138 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a93:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a9a:	00 
  800a9b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800aa6:	e8 1d 16 00 00       	call   8020c8 <ipc_recv>
}
  800aab:	83 c4 10             	add    $0x10,%esp
  800aae:	5b                   	pop    %ebx
  800aaf:	5e                   	pop    %esi
  800ab0:	5d                   	pop    %ebp
  800ab1:	c3                   	ret    

00800ab2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	8b 40 0c             	mov    0xc(%eax),%eax
  800abe:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800acb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad5:	e8 72 ff ff ff       	call   800a4c <fsipc>
}
  800ada:	c9                   	leave  
  800adb:	c3                   	ret    

00800adc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae5:	8b 40 0c             	mov    0xc(%eax),%eax
  800ae8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800aed:	ba 00 00 00 00       	mov    $0x0,%edx
  800af2:	b8 06 00 00 00       	mov    $0x6,%eax
  800af7:	e8 50 ff ff ff       	call   800a4c <fsipc>
}
  800afc:	c9                   	leave  
  800afd:	c3                   	ret    

00800afe <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	53                   	push   %ebx
  800b02:	83 ec 14             	sub    $0x14,%esp
  800b05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800b08:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0b:	8b 40 0c             	mov    0xc(%eax),%eax
  800b0e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800b13:	ba 00 00 00 00       	mov    $0x0,%edx
  800b18:	b8 05 00 00 00       	mov    $0x5,%eax
  800b1d:	e8 2a ff ff ff       	call   800a4c <fsipc>
  800b22:	85 c0                	test   %eax,%eax
  800b24:	78 2b                	js     800b51 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800b26:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b2d:	00 
  800b2e:	89 1c 24             	mov    %ebx,(%esp)
  800b31:	e8 6d 12 00 00       	call   801da3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b36:	a1 80 50 80 00       	mov    0x805080,%eax
  800b3b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b41:	a1 84 50 80 00       	mov    0x805084,%eax
  800b46:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800b4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b51:	83 c4 14             	add    $0x14,%esp
  800b54:	5b                   	pop    %ebx
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	83 ec 18             	sub    $0x18,%esp
  800b5d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800b60:	8b 55 08             	mov    0x8(%ebp),%edx
  800b63:	8b 52 0c             	mov    0xc(%edx),%edx
  800b66:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800b6c:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  800b71:	89 c2                	mov    %eax,%edx
  800b73:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800b78:	76 05                	jbe    800b7f <devfile_write+0x28>
  800b7a:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  800b7f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b83:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b8a:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b91:	e8 f0 13 00 00       	call   801f86 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba0:	e8 a7 fe ff ff       	call   800a4c <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  800ba5:	c9                   	leave  
  800ba6:	c3                   	ret    

00800ba7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	83 ec 10             	sub    $0x10,%esp
  800baf:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb5:	8b 40 0c             	mov    0xc(%eax),%eax
  800bb8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800bbd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800bc3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bcd:	e8 7a fe ff ff       	call   800a4c <fsipc>
  800bd2:	89 c3                	mov    %eax,%ebx
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	78 6a                	js     800c42 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800bd8:	39 c6                	cmp    %eax,%esi
  800bda:	73 24                	jae    800c00 <devfile_read+0x59>
  800bdc:	c7 44 24 0c 74 25 80 	movl   $0x802574,0xc(%esp)
  800be3:	00 
  800be4:	c7 44 24 08 7b 25 80 	movl   $0x80257b,0x8(%esp)
  800beb:	00 
  800bec:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800bf3:	00 
  800bf4:	c7 04 24 90 25 80 00 	movl   $0x802590,(%esp)
  800bfb:	e8 00 0b 00 00       	call   801700 <_panic>
	assert(r <= PGSIZE);
  800c00:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c05:	7e 24                	jle    800c2b <devfile_read+0x84>
  800c07:	c7 44 24 0c 9b 25 80 	movl   $0x80259b,0xc(%esp)
  800c0e:	00 
  800c0f:	c7 44 24 08 7b 25 80 	movl   $0x80257b,0x8(%esp)
  800c16:	00 
  800c17:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800c1e:	00 
  800c1f:	c7 04 24 90 25 80 00 	movl   $0x802590,(%esp)
  800c26:	e8 d5 0a 00 00       	call   801700 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c2b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c2f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c36:	00 
  800c37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3a:	89 04 24             	mov    %eax,(%esp)
  800c3d:	e8 da 12 00 00       	call   801f1c <memmove>
	return r;
}
  800c42:	89 d8                	mov    %ebx,%eax
  800c44:	83 c4 10             	add    $0x10,%esp
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 20             	sub    $0x20,%esp
  800c53:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c56:	89 34 24             	mov    %esi,(%esp)
  800c59:	e8 12 11 00 00       	call   801d70 <strlen>
  800c5e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c63:	7f 60                	jg     800cc5 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c65:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c68:	89 04 24             	mov    %eax,(%esp)
  800c6b:	e8 17 f8 ff ff       	call   800487 <fd_alloc>
  800c70:	89 c3                	mov    %eax,%ebx
  800c72:	85 c0                	test   %eax,%eax
  800c74:	78 54                	js     800cca <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800c76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c7a:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c81:	e8 1d 11 00 00       	call   801da3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c89:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c91:	b8 01 00 00 00       	mov    $0x1,%eax
  800c96:	e8 b1 fd ff ff       	call   800a4c <fsipc>
  800c9b:	89 c3                	mov    %eax,%ebx
  800c9d:	85 c0                	test   %eax,%eax
  800c9f:	79 15                	jns    800cb6 <open+0x6b>
		fd_close(fd, 0);
  800ca1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ca8:	00 
  800ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cac:	89 04 24             	mov    %eax,(%esp)
  800caf:	e8 d6 f8 ff ff       	call   80058a <fd_close>
		return r;
  800cb4:	eb 14                	jmp    800cca <open+0x7f>
	}

	return fd2num(fd);
  800cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb9:	89 04 24             	mov    %eax,(%esp)
  800cbc:	e8 9b f7 ff ff       	call   80045c <fd2num>
  800cc1:	89 c3                	mov    %eax,%ebx
  800cc3:	eb 05                	jmp    800cca <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cc5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800cca:	89 d8                	mov    %ebx,%eax
  800ccc:	83 c4 20             	add    $0x20,%esp
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800cd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cde:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce3:	e8 64 fd ff ff       	call   800a4c <fsipc>
}
  800ce8:	c9                   	leave  
  800ce9:	c3                   	ret    
	...

00800cec <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800cf2:	c7 44 24 04 a7 25 80 	movl   $0x8025a7,0x4(%esp)
  800cf9:	00 
  800cfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfd:	89 04 24             	mov    %eax,(%esp)
  800d00:	e8 9e 10 00 00       	call   801da3 <strcpy>
	return 0;
}
  800d05:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0a:	c9                   	leave  
  800d0b:	c3                   	ret    

00800d0c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800d0c:	55                   	push   %ebp
  800d0d:	89 e5                	mov    %esp,%ebp
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 14             	sub    $0x14,%esp
  800d13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800d16:	89 1c 24             	mov    %ebx,(%esp)
  800d19:	e8 e2 14 00 00       	call   802200 <pageref>
  800d1e:	83 f8 01             	cmp    $0x1,%eax
  800d21:	75 0d                	jne    800d30 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  800d23:	8b 43 0c             	mov    0xc(%ebx),%eax
  800d26:	89 04 24             	mov    %eax,(%esp)
  800d29:	e8 1f 03 00 00       	call   80104d <nsipc_close>
  800d2e:	eb 05                	jmp    800d35 <devsock_close+0x29>
	else
		return 0;
  800d30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d35:	83 c4 14             	add    $0x14,%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800d41:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d48:	00 
  800d49:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d53:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d57:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5a:	8b 40 0c             	mov    0xc(%eax),%eax
  800d5d:	89 04 24             	mov    %eax,(%esp)
  800d60:	e8 e3 03 00 00       	call   801148 <nsipc_send>
}
  800d65:	c9                   	leave  
  800d66:	c3                   	ret    

00800d67 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800d6d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d74:	00 
  800d75:	8b 45 10             	mov    0x10(%ebp),%eax
  800d78:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d83:	8b 45 08             	mov    0x8(%ebp),%eax
  800d86:	8b 40 0c             	mov    0xc(%eax),%eax
  800d89:	89 04 24             	mov    %eax,(%esp)
  800d8c:	e8 37 03 00 00       	call   8010c8 <nsipc_recv>
}
  800d91:	c9                   	leave  
  800d92:	c3                   	ret    

00800d93 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	56                   	push   %esi
  800d97:	53                   	push   %ebx
  800d98:	83 ec 20             	sub    $0x20,%esp
  800d9b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800d9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800da0:	89 04 24             	mov    %eax,(%esp)
  800da3:	e8 df f6 ff ff       	call   800487 <fd_alloc>
  800da8:	89 c3                	mov    %eax,%ebx
  800daa:	85 c0                	test   %eax,%eax
  800dac:	78 21                	js     800dcf <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800dae:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800db5:	00 
  800db6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800db9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800dc4:	e8 c8 f3 ff ff       	call   800191 <sys_page_alloc>
  800dc9:	89 c3                	mov    %eax,%ebx
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	79 0a                	jns    800dd9 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  800dcf:	89 34 24             	mov    %esi,(%esp)
  800dd2:	e8 76 02 00 00       	call   80104d <nsipc_close>
		return r;
  800dd7:	eb 22                	jmp    800dfb <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800dd9:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800de4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800dee:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800df1:	89 04 24             	mov    %eax,(%esp)
  800df4:	e8 63 f6 ff ff       	call   80045c <fd2num>
  800df9:	89 c3                	mov    %eax,%ebx
}
  800dfb:	89 d8                	mov    %ebx,%eax
  800dfd:	83 c4 20             	add    $0x20,%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800e0a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800e0d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e11:	89 04 24             	mov    %eax,(%esp)
  800e14:	e8 c1 f6 ff ff       	call   8004da <fd_lookup>
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	78 17                	js     800e34 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e20:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e26:	39 10                	cmp    %edx,(%eax)
  800e28:	75 05                	jne    800e2f <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800e2a:	8b 40 0c             	mov    0xc(%eax),%eax
  800e2d:	eb 05                	jmp    800e34 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800e2f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800e34:	c9                   	leave  
  800e35:	c3                   	ret    

00800e36 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3f:	e8 c0 ff ff ff       	call   800e04 <fd2sockid>
  800e44:	85 c0                	test   %eax,%eax
  800e46:	78 1f                	js     800e67 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800e48:	8b 55 10             	mov    0x10(%ebp),%edx
  800e4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e52:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e56:	89 04 24             	mov    %eax,(%esp)
  800e59:	e8 38 01 00 00       	call   800f96 <nsipc_accept>
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	78 05                	js     800e67 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  800e62:	e8 2c ff ff ff       	call   800d93 <alloc_sockfd>
}
  800e67:	c9                   	leave  
  800e68:	c3                   	ret    

00800e69 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e72:	e8 8d ff ff ff       	call   800e04 <fd2sockid>
  800e77:	85 c0                	test   %eax,%eax
  800e79:	78 16                	js     800e91 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  800e7b:	8b 55 10             	mov    0x10(%ebp),%edx
  800e7e:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e82:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e85:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e89:	89 04 24             	mov    %eax,(%esp)
  800e8c:	e8 5b 01 00 00       	call   800fec <nsipc_bind>
}
  800e91:	c9                   	leave  
  800e92:	c3                   	ret    

00800e93 <shutdown>:

int
shutdown(int s, int how)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e99:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9c:	e8 63 ff ff ff       	call   800e04 <fd2sockid>
  800ea1:	85 c0                	test   %eax,%eax
  800ea3:	78 0f                	js     800eb4 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800ea5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea8:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eac:	89 04 24             	mov    %eax,(%esp)
  800eaf:	e8 77 01 00 00       	call   80102b <nsipc_shutdown>
}
  800eb4:	c9                   	leave  
  800eb5:	c3                   	ret    

00800eb6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebf:	e8 40 ff ff ff       	call   800e04 <fd2sockid>
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	78 16                	js     800ede <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  800ec8:	8b 55 10             	mov    0x10(%ebp),%edx
  800ecb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ecf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed2:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ed6:	89 04 24             	mov    %eax,(%esp)
  800ed9:	e8 89 01 00 00       	call   801067 <nsipc_connect>
}
  800ede:	c9                   	leave  
  800edf:	c3                   	ret    

00800ee0 <listen>:

int
listen(int s, int backlog)
{
  800ee0:	55                   	push   %ebp
  800ee1:	89 e5                	mov    %esp,%ebp
  800ee3:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee9:	e8 16 ff ff ff       	call   800e04 <fd2sockid>
  800eee:	85 c0                	test   %eax,%eax
  800ef0:	78 0f                	js     800f01 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800ef2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ef5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ef9:	89 04 24             	mov    %eax,(%esp)
  800efc:	e8 a5 01 00 00       	call   8010a6 <nsipc_listen>
}
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800f09:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f17:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1a:	89 04 24             	mov    %eax,(%esp)
  800f1d:	e8 99 02 00 00       	call   8011bb <nsipc_socket>
  800f22:	85 c0                	test   %eax,%eax
  800f24:	78 05                	js     800f2b <socket+0x28>
		return r;
	return alloc_sockfd(r);
  800f26:	e8 68 fe ff ff       	call   800d93 <alloc_sockfd>
}
  800f2b:	c9                   	leave  
  800f2c:	c3                   	ret    
  800f2d:	00 00                	add    %al,(%eax)
	...

00800f30 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	53                   	push   %ebx
  800f34:	83 ec 14             	sub    $0x14,%esp
  800f37:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800f39:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800f40:	75 11                	jne    800f53 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800f42:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f49:	e8 6d 12 00 00       	call   8021bb <ipc_find_env>
  800f4e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800f53:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800f5a:	00 
  800f5b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  800f62:	00 
  800f63:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f67:	a1 04 40 80 00       	mov    0x804004,%eax
  800f6c:	89 04 24             	mov    %eax,(%esp)
  800f6f:	e8 c4 11 00 00       	call   802138 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800f74:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f7b:	00 
  800f7c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f83:	00 
  800f84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f8b:	e8 38 11 00 00       	call   8020c8 <ipc_recv>
}
  800f90:	83 c4 14             	add    $0x14,%esp
  800f93:	5b                   	pop    %ebx
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	56                   	push   %esi
  800f9a:	53                   	push   %ebx
  800f9b:	83 ec 10             	sub    $0x10,%esp
  800f9e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800fa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800fa9:	8b 06                	mov    (%esi),%eax
  800fab:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800fb0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb5:	e8 76 ff ff ff       	call   800f30 <nsipc>
  800fba:	89 c3                	mov    %eax,%ebx
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 23                	js     800fe3 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800fc0:	a1 10 60 80 00       	mov    0x806010,%eax
  800fc5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc9:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  800fd0:	00 
  800fd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd4:	89 04 24             	mov    %eax,(%esp)
  800fd7:	e8 40 0f 00 00       	call   801f1c <memmove>
		*addrlen = ret->ret_addrlen;
  800fdc:	a1 10 60 80 00       	mov    0x806010,%eax
  800fe1:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  800fe3:	89 d8                	mov    %ebx,%eax
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	5b                   	pop    %ebx
  800fe9:	5e                   	pop    %esi
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    

00800fec <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	53                   	push   %ebx
  800ff0:	83 ec 14             	sub    $0x14,%esp
  800ff3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800ff6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff9:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ffe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801002:	8b 45 0c             	mov    0xc(%ebp),%eax
  801005:	89 44 24 04          	mov    %eax,0x4(%esp)
  801009:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801010:	e8 07 0f 00 00       	call   801f1c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801015:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80101b:	b8 02 00 00 00       	mov    $0x2,%eax
  801020:	e8 0b ff ff ff       	call   800f30 <nsipc>
}
  801025:	83 c4 14             	add    $0x14,%esp
  801028:	5b                   	pop    %ebx
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    

0080102b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801031:	8b 45 08             	mov    0x8(%ebp),%eax
  801034:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801039:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801041:	b8 03 00 00 00       	mov    $0x3,%eax
  801046:	e8 e5 fe ff ff       	call   800f30 <nsipc>
}
  80104b:	c9                   	leave  
  80104c:	c3                   	ret    

0080104d <nsipc_close>:

int
nsipc_close(int s)
{
  80104d:	55                   	push   %ebp
  80104e:	89 e5                	mov    %esp,%ebp
  801050:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80105b:	b8 04 00 00 00       	mov    $0x4,%eax
  801060:	e8 cb fe ff ff       	call   800f30 <nsipc>
}
  801065:	c9                   	leave  
  801066:	c3                   	ret    

00801067 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	53                   	push   %ebx
  80106b:	83 ec 14             	sub    $0x14,%esp
  80106e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801071:	8b 45 08             	mov    0x8(%ebp),%eax
  801074:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801079:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80107d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801080:	89 44 24 04          	mov    %eax,0x4(%esp)
  801084:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  80108b:	e8 8c 0e 00 00       	call   801f1c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801090:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801096:	b8 05 00 00 00       	mov    $0x5,%eax
  80109b:	e8 90 fe ff ff       	call   800f30 <nsipc>
}
  8010a0:	83 c4 14             	add    $0x14,%esp
  8010a3:	5b                   	pop    %ebx
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8010ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8010af:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8010b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8010bc:	b8 06 00 00 00       	mov    $0x6,%eax
  8010c1:	e8 6a fe ff ff       	call   800f30 <nsipc>
}
  8010c6:	c9                   	leave  
  8010c7:	c3                   	ret    

008010c8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	56                   	push   %esi
  8010cc:	53                   	push   %ebx
  8010cd:	83 ec 10             	sub    $0x10,%esp
  8010d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8010d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8010db:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8010e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8010e4:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8010e9:	b8 07 00 00 00       	mov    $0x7,%eax
  8010ee:	e8 3d fe ff ff       	call   800f30 <nsipc>
  8010f3:	89 c3                	mov    %eax,%ebx
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	78 46                	js     80113f <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8010f9:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8010fe:	7f 04                	jg     801104 <nsipc_recv+0x3c>
  801100:	39 c6                	cmp    %eax,%esi
  801102:	7d 24                	jge    801128 <nsipc_recv+0x60>
  801104:	c7 44 24 0c b3 25 80 	movl   $0x8025b3,0xc(%esp)
  80110b:	00 
  80110c:	c7 44 24 08 7b 25 80 	movl   $0x80257b,0x8(%esp)
  801113:	00 
  801114:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80111b:	00 
  80111c:	c7 04 24 c8 25 80 00 	movl   $0x8025c8,(%esp)
  801123:	e8 d8 05 00 00       	call   801700 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801128:	89 44 24 08          	mov    %eax,0x8(%esp)
  80112c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801133:	00 
  801134:	8b 45 0c             	mov    0xc(%ebp),%eax
  801137:	89 04 24             	mov    %eax,(%esp)
  80113a:	e8 dd 0d 00 00       	call   801f1c <memmove>
	}

	return r;
}
  80113f:	89 d8                	mov    %ebx,%eax
  801141:	83 c4 10             	add    $0x10,%esp
  801144:	5b                   	pop    %ebx
  801145:	5e                   	pop    %esi
  801146:	5d                   	pop    %ebp
  801147:	c3                   	ret    

00801148 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	53                   	push   %ebx
  80114c:	83 ec 14             	sub    $0x14,%esp
  80114f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801152:	8b 45 08             	mov    0x8(%ebp),%eax
  801155:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80115a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801160:	7e 24                	jle    801186 <nsipc_send+0x3e>
  801162:	c7 44 24 0c d4 25 80 	movl   $0x8025d4,0xc(%esp)
  801169:	00 
  80116a:	c7 44 24 08 7b 25 80 	movl   $0x80257b,0x8(%esp)
  801171:	00 
  801172:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801179:	00 
  80117a:	c7 04 24 c8 25 80 00 	movl   $0x8025c8,(%esp)
  801181:	e8 7a 05 00 00       	call   801700 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801186:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80118a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80118d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801191:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801198:	e8 7f 0d 00 00       	call   801f1c <memmove>
	nsipcbuf.send.req_size = size;
  80119d:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8011a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8011a6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8011ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8011b0:	e8 7b fd ff ff       	call   800f30 <nsipc>
}
  8011b5:	83 c4 14             	add    $0x14,%esp
  8011b8:	5b                   	pop    %ebx
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8011c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8011c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011cc:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8011d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8011d9:	b8 09 00 00 00       	mov    $0x9,%eax
  8011de:	e8 4d fd ff ff       	call   800f30 <nsipc>
}
  8011e3:	c9                   	leave  
  8011e4:	c3                   	ret    
  8011e5:	00 00                	add    %al,(%eax)
	...

008011e8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	56                   	push   %esi
  8011ec:	53                   	push   %ebx
  8011ed:	83 ec 10             	sub    $0x10,%esp
  8011f0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8011f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f6:	89 04 24             	mov    %eax,(%esp)
  8011f9:	e8 6e f2 ff ff       	call   80046c <fd2data>
  8011fe:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801200:	c7 44 24 04 e0 25 80 	movl   $0x8025e0,0x4(%esp)
  801207:	00 
  801208:	89 34 24             	mov    %esi,(%esp)
  80120b:	e8 93 0b 00 00       	call   801da3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801210:	8b 43 04             	mov    0x4(%ebx),%eax
  801213:	2b 03                	sub    (%ebx),%eax
  801215:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80121b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801222:	00 00 00 
	stat->st_dev = &devpipe;
  801225:	c7 86 88 00 00 00 40 	movl   $0x803040,0x88(%esi)
  80122c:	30 80 00 
	return 0;
}
  80122f:	b8 00 00 00 00       	mov    $0x0,%eax
  801234:	83 c4 10             	add    $0x10,%esp
  801237:	5b                   	pop    %ebx
  801238:	5e                   	pop    %esi
  801239:	5d                   	pop    %ebp
  80123a:	c3                   	ret    

0080123b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	53                   	push   %ebx
  80123f:	83 ec 14             	sub    $0x14,%esp
  801242:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801245:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801249:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801250:	e8 e3 ef ff ff       	call   800238 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801255:	89 1c 24             	mov    %ebx,(%esp)
  801258:	e8 0f f2 ff ff       	call   80046c <fd2data>
  80125d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801261:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801268:	e8 cb ef ff ff       	call   800238 <sys_page_unmap>
}
  80126d:	83 c4 14             	add    $0x14,%esp
  801270:	5b                   	pop    %ebx
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    

00801273 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	57                   	push   %edi
  801277:	56                   	push   %esi
  801278:	53                   	push   %ebx
  801279:	83 ec 2c             	sub    $0x2c,%esp
  80127c:	89 c7                	mov    %eax,%edi
  80127e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801281:	a1 08 40 80 00       	mov    0x804008,%eax
  801286:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801289:	89 3c 24             	mov    %edi,(%esp)
  80128c:	e8 6f 0f 00 00       	call   802200 <pageref>
  801291:	89 c6                	mov    %eax,%esi
  801293:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801296:	89 04 24             	mov    %eax,(%esp)
  801299:	e8 62 0f 00 00       	call   802200 <pageref>
  80129e:	39 c6                	cmp    %eax,%esi
  8012a0:	0f 94 c0             	sete   %al
  8012a3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8012a6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8012ac:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8012af:	39 cb                	cmp    %ecx,%ebx
  8012b1:	75 08                	jne    8012bb <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8012b3:	83 c4 2c             	add    $0x2c,%esp
  8012b6:	5b                   	pop    %ebx
  8012b7:	5e                   	pop    %esi
  8012b8:	5f                   	pop    %edi
  8012b9:	5d                   	pop    %ebp
  8012ba:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8012bb:	83 f8 01             	cmp    $0x1,%eax
  8012be:	75 c1                	jne    801281 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8012c0:	8b 42 58             	mov    0x58(%edx),%eax
  8012c3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8012ca:	00 
  8012cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012d3:	c7 04 24 e7 25 80 00 	movl   $0x8025e7,(%esp)
  8012da:	e8 19 05 00 00       	call   8017f8 <cprintf>
  8012df:	eb a0                	jmp    801281 <_pipeisclosed+0xe>

008012e1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	57                   	push   %edi
  8012e5:	56                   	push   %esi
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 1c             	sub    $0x1c,%esp
  8012ea:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8012ed:	89 34 24             	mov    %esi,(%esp)
  8012f0:	e8 77 f1 ff ff       	call   80046c <fd2data>
  8012f5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012f7:	bf 00 00 00 00       	mov    $0x0,%edi
  8012fc:	eb 3c                	jmp    80133a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8012fe:	89 da                	mov    %ebx,%edx
  801300:	89 f0                	mov    %esi,%eax
  801302:	e8 6c ff ff ff       	call   801273 <_pipeisclosed>
  801307:	85 c0                	test   %eax,%eax
  801309:	75 38                	jne    801343 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80130b:	e8 62 ee ff ff       	call   800172 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801310:	8b 43 04             	mov    0x4(%ebx),%eax
  801313:	8b 13                	mov    (%ebx),%edx
  801315:	83 c2 20             	add    $0x20,%edx
  801318:	39 d0                	cmp    %edx,%eax
  80131a:	73 e2                	jae    8012fe <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80131c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801322:	89 c2                	mov    %eax,%edx
  801324:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80132a:	79 05                	jns    801331 <devpipe_write+0x50>
  80132c:	4a                   	dec    %edx
  80132d:	83 ca e0             	or     $0xffffffe0,%edx
  801330:	42                   	inc    %edx
  801331:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801335:	40                   	inc    %eax
  801336:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801339:	47                   	inc    %edi
  80133a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80133d:	75 d1                	jne    801310 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80133f:	89 f8                	mov    %edi,%eax
  801341:	eb 05                	jmp    801348 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801343:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801348:	83 c4 1c             	add    $0x1c,%esp
  80134b:	5b                   	pop    %ebx
  80134c:	5e                   	pop    %esi
  80134d:	5f                   	pop    %edi
  80134e:	5d                   	pop    %ebp
  80134f:	c3                   	ret    

00801350 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	57                   	push   %edi
  801354:	56                   	push   %esi
  801355:	53                   	push   %ebx
  801356:	83 ec 1c             	sub    $0x1c,%esp
  801359:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80135c:	89 3c 24             	mov    %edi,(%esp)
  80135f:	e8 08 f1 ff ff       	call   80046c <fd2data>
  801364:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801366:	be 00 00 00 00       	mov    $0x0,%esi
  80136b:	eb 3a                	jmp    8013a7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80136d:	85 f6                	test   %esi,%esi
  80136f:	74 04                	je     801375 <devpipe_read+0x25>
				return i;
  801371:	89 f0                	mov    %esi,%eax
  801373:	eb 40                	jmp    8013b5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801375:	89 da                	mov    %ebx,%edx
  801377:	89 f8                	mov    %edi,%eax
  801379:	e8 f5 fe ff ff       	call   801273 <_pipeisclosed>
  80137e:	85 c0                	test   %eax,%eax
  801380:	75 2e                	jne    8013b0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801382:	e8 eb ed ff ff       	call   800172 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801387:	8b 03                	mov    (%ebx),%eax
  801389:	3b 43 04             	cmp    0x4(%ebx),%eax
  80138c:	74 df                	je     80136d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80138e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801393:	79 05                	jns    80139a <devpipe_read+0x4a>
  801395:	48                   	dec    %eax
  801396:	83 c8 e0             	or     $0xffffffe0,%eax
  801399:	40                   	inc    %eax
  80139a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80139e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8013a4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8013a6:	46                   	inc    %esi
  8013a7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013aa:	75 db                	jne    801387 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8013ac:	89 f0                	mov    %esi,%eax
  8013ae:	eb 05                	jmp    8013b5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8013b0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8013b5:	83 c4 1c             	add    $0x1c,%esp
  8013b8:	5b                   	pop    %ebx
  8013b9:	5e                   	pop    %esi
  8013ba:	5f                   	pop    %edi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    

008013bd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8013bd:	55                   	push   %ebp
  8013be:	89 e5                	mov    %esp,%ebp
  8013c0:	57                   	push   %edi
  8013c1:	56                   	push   %esi
  8013c2:	53                   	push   %ebx
  8013c3:	83 ec 3c             	sub    $0x3c,%esp
  8013c6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8013c9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013cc:	89 04 24             	mov    %eax,(%esp)
  8013cf:	e8 b3 f0 ff ff       	call   800487 <fd_alloc>
  8013d4:	89 c3                	mov    %eax,%ebx
  8013d6:	85 c0                	test   %eax,%eax
  8013d8:	0f 88 45 01 00 00    	js     801523 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013de:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8013e5:	00 
  8013e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013f4:	e8 98 ed ff ff       	call   800191 <sys_page_alloc>
  8013f9:	89 c3                	mov    %eax,%ebx
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	0f 88 20 01 00 00    	js     801523 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801403:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801406:	89 04 24             	mov    %eax,(%esp)
  801409:	e8 79 f0 ff ff       	call   800487 <fd_alloc>
  80140e:	89 c3                	mov    %eax,%ebx
  801410:	85 c0                	test   %eax,%eax
  801412:	0f 88 f8 00 00 00    	js     801510 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801418:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80141f:	00 
  801420:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801423:	89 44 24 04          	mov    %eax,0x4(%esp)
  801427:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80142e:	e8 5e ed ff ff       	call   800191 <sys_page_alloc>
  801433:	89 c3                	mov    %eax,%ebx
  801435:	85 c0                	test   %eax,%eax
  801437:	0f 88 d3 00 00 00    	js     801510 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80143d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801440:	89 04 24             	mov    %eax,(%esp)
  801443:	e8 24 f0 ff ff       	call   80046c <fd2data>
  801448:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80144a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801451:	00 
  801452:	89 44 24 04          	mov    %eax,0x4(%esp)
  801456:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80145d:	e8 2f ed ff ff       	call   800191 <sys_page_alloc>
  801462:	89 c3                	mov    %eax,%ebx
  801464:	85 c0                	test   %eax,%eax
  801466:	0f 88 91 00 00 00    	js     8014fd <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80146c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80146f:	89 04 24             	mov    %eax,(%esp)
  801472:	e8 f5 ef ff ff       	call   80046c <fd2data>
  801477:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80147e:	00 
  80147f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801483:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80148a:	00 
  80148b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80148f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801496:	e8 4a ed ff ff       	call   8001e5 <sys_page_map>
  80149b:	89 c3                	mov    %eax,%ebx
  80149d:	85 c0                	test   %eax,%eax
  80149f:	78 4c                	js     8014ed <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8014a1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8014a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014aa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8014ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014af:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8014b6:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8014bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014bf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8014c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014c4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8014cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014ce:	89 04 24             	mov    %eax,(%esp)
  8014d1:	e8 86 ef ff ff       	call   80045c <fd2num>
  8014d6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8014d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014db:	89 04 24             	mov    %eax,(%esp)
  8014de:	e8 79 ef ff ff       	call   80045c <fd2num>
  8014e3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8014e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014eb:	eb 36                	jmp    801523 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8014ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f8:	e8 3b ed ff ff       	call   800238 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8014fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801500:	89 44 24 04          	mov    %eax,0x4(%esp)
  801504:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80150b:	e8 28 ed ff ff       	call   800238 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801510:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801513:	89 44 24 04          	mov    %eax,0x4(%esp)
  801517:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80151e:	e8 15 ed ff ff       	call   800238 <sys_page_unmap>
    err:
	return r;
}
  801523:	89 d8                	mov    %ebx,%eax
  801525:	83 c4 3c             	add    $0x3c,%esp
  801528:	5b                   	pop    %ebx
  801529:	5e                   	pop    %esi
  80152a:	5f                   	pop    %edi
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    

0080152d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801533:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801536:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153a:	8b 45 08             	mov    0x8(%ebp),%eax
  80153d:	89 04 24             	mov    %eax,(%esp)
  801540:	e8 95 ef ff ff       	call   8004da <fd_lookup>
  801545:	85 c0                	test   %eax,%eax
  801547:	78 15                	js     80155e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801549:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154c:	89 04 24             	mov    %eax,(%esp)
  80154f:	e8 18 ef ff ff       	call   80046c <fd2data>
	return _pipeisclosed(fd, p);
  801554:	89 c2                	mov    %eax,%edx
  801556:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801559:	e8 15 fd ff ff       	call   801273 <_pipeisclosed>
}
  80155e:	c9                   	leave  
  80155f:	c3                   	ret    

00801560 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801560:	55                   	push   %ebp
  801561:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801563:	b8 00 00 00 00       	mov    $0x0,%eax
  801568:	5d                   	pop    %ebp
  801569:	c3                   	ret    

0080156a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801570:	c7 44 24 04 ff 25 80 	movl   $0x8025ff,0x4(%esp)
  801577:	00 
  801578:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157b:	89 04 24             	mov    %eax,(%esp)
  80157e:	e8 20 08 00 00       	call   801da3 <strcpy>
	return 0;
}
  801583:	b8 00 00 00 00       	mov    $0x0,%eax
  801588:	c9                   	leave  
  801589:	c3                   	ret    

0080158a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	57                   	push   %edi
  80158e:	56                   	push   %esi
  80158f:	53                   	push   %ebx
  801590:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801596:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80159b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8015a1:	eb 30                	jmp    8015d3 <devcons_write+0x49>
		m = n - tot;
  8015a3:	8b 75 10             	mov    0x10(%ebp),%esi
  8015a6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8015a8:	83 fe 7f             	cmp    $0x7f,%esi
  8015ab:	76 05                	jbe    8015b2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8015ad:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8015b2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8015b6:	03 45 0c             	add    0xc(%ebp),%eax
  8015b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bd:	89 3c 24             	mov    %edi,(%esp)
  8015c0:	e8 57 09 00 00       	call   801f1c <memmove>
		sys_cputs(buf, m);
  8015c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015c9:	89 3c 24             	mov    %edi,(%esp)
  8015cc:	e8 f3 ea ff ff       	call   8000c4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8015d1:	01 f3                	add    %esi,%ebx
  8015d3:	89 d8                	mov    %ebx,%eax
  8015d5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8015d8:	72 c9                	jb     8015a3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8015da:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8015e0:	5b                   	pop    %ebx
  8015e1:	5e                   	pop    %esi
  8015e2:	5f                   	pop    %edi
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8015eb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8015ef:	75 07                	jne    8015f8 <devcons_read+0x13>
  8015f1:	eb 25                	jmp    801618 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8015f3:	e8 7a eb ff ff       	call   800172 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8015f8:	e8 e5 ea ff ff       	call   8000e2 <sys_cgetc>
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	74 f2                	je     8015f3 <devcons_read+0xe>
  801601:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801603:	85 c0                	test   %eax,%eax
  801605:	78 1d                	js     801624 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801607:	83 f8 04             	cmp    $0x4,%eax
  80160a:	74 13                	je     80161f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80160c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160f:	88 10                	mov    %dl,(%eax)
	return 1;
  801611:	b8 01 00 00 00       	mov    $0x1,%eax
  801616:	eb 0c                	jmp    801624 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801618:	b8 00 00 00 00       	mov    $0x0,%eax
  80161d:	eb 05                	jmp    801624 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80161f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801624:	c9                   	leave  
  801625:	c3                   	ret    

00801626 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80162c:	8b 45 08             	mov    0x8(%ebp),%eax
  80162f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801632:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801639:	00 
  80163a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80163d:	89 04 24             	mov    %eax,(%esp)
  801640:	e8 7f ea ff ff       	call   8000c4 <sys_cputs>
}
  801645:	c9                   	leave  
  801646:	c3                   	ret    

00801647 <getchar>:

int
getchar(void)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80164d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801654:	00 
  801655:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801658:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801663:	e8 10 f1 ff ff       	call   800778 <read>
	if (r < 0)
  801668:	85 c0                	test   %eax,%eax
  80166a:	78 0f                	js     80167b <getchar+0x34>
		return r;
	if (r < 1)
  80166c:	85 c0                	test   %eax,%eax
  80166e:	7e 06                	jle    801676 <getchar+0x2f>
		return -E_EOF;
	return c;
  801670:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801674:	eb 05                	jmp    80167b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801676:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80167b:	c9                   	leave  
  80167c:	c3                   	ret    

0080167d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801683:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801686:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168a:	8b 45 08             	mov    0x8(%ebp),%eax
  80168d:	89 04 24             	mov    %eax,(%esp)
  801690:	e8 45 ee ff ff       	call   8004da <fd_lookup>
  801695:	85 c0                	test   %eax,%eax
  801697:	78 11                	js     8016aa <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801699:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169c:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8016a2:	39 10                	cmp    %edx,(%eax)
  8016a4:	0f 94 c0             	sete   %al
  8016a7:	0f b6 c0             	movzbl %al,%eax
}
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <opencons>:

int
opencons(void)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8016b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b5:	89 04 24             	mov    %eax,(%esp)
  8016b8:	e8 ca ed ff ff       	call   800487 <fd_alloc>
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	78 3c                	js     8016fd <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8016c1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8016c8:	00 
  8016c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d7:	e8 b5 ea ff ff       	call   800191 <sys_page_alloc>
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 1d                	js     8016fd <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8016e0:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8016e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8016eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ee:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8016f5:	89 04 24             	mov    %eax,(%esp)
  8016f8:	e8 5f ed ff ff       	call   80045c <fd2num>
}
  8016fd:	c9                   	leave  
  8016fe:	c3                   	ret    
	...

00801700 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	56                   	push   %esi
  801704:	53                   	push   %ebx
  801705:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801708:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80170b:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  801711:	e8 3d ea ff ff       	call   800153 <sys_getenvid>
  801716:	8b 55 0c             	mov    0xc(%ebp),%edx
  801719:	89 54 24 10          	mov    %edx,0x10(%esp)
  80171d:	8b 55 08             	mov    0x8(%ebp),%edx
  801720:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801724:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172c:	c7 04 24 0c 26 80 00 	movl   $0x80260c,(%esp)
  801733:	e8 c0 00 00 00       	call   8017f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801738:	89 74 24 04          	mov    %esi,0x4(%esp)
  80173c:	8b 45 10             	mov    0x10(%ebp),%eax
  80173f:	89 04 24             	mov    %eax,(%esp)
  801742:	e8 50 00 00 00       	call   801797 <vcprintf>
	cprintf("\n");
  801747:	c7 04 24 f8 25 80 00 	movl   $0x8025f8,(%esp)
  80174e:	e8 a5 00 00 00       	call   8017f8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801753:	cc                   	int3   
  801754:	eb fd                	jmp    801753 <_panic+0x53>
	...

00801758 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	53                   	push   %ebx
  80175c:	83 ec 14             	sub    $0x14,%esp
  80175f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801762:	8b 03                	mov    (%ebx),%eax
  801764:	8b 55 08             	mov    0x8(%ebp),%edx
  801767:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80176b:	40                   	inc    %eax
  80176c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80176e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801773:	75 19                	jne    80178e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801775:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80177c:	00 
  80177d:	8d 43 08             	lea    0x8(%ebx),%eax
  801780:	89 04 24             	mov    %eax,(%esp)
  801783:	e8 3c e9 ff ff       	call   8000c4 <sys_cputs>
		b->idx = 0;
  801788:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80178e:	ff 43 04             	incl   0x4(%ebx)
}
  801791:	83 c4 14             	add    $0x14,%esp
  801794:	5b                   	pop    %ebx
  801795:	5d                   	pop    %ebp
  801796:	c3                   	ret    

00801797 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801797:	55                   	push   %ebp
  801798:	89 e5                	mov    %esp,%ebp
  80179a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8017a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017a7:	00 00 00 
	b.cnt = 0;
  8017aa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8017b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8017b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017c2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8017c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cc:	c7 04 24 58 17 80 00 	movl   $0x801758,(%esp)
  8017d3:	e8 82 01 00 00       	call   80195a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8017d8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8017e8:	89 04 24             	mov    %eax,(%esp)
  8017eb:	e8 d4 e8 ff ff       	call   8000c4 <sys_cputs>

	return b.cnt;
}
  8017f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801801:	89 44 24 04          	mov    %eax,0x4(%esp)
  801805:	8b 45 08             	mov    0x8(%ebp),%eax
  801808:	89 04 24             	mov    %eax,(%esp)
  80180b:	e8 87 ff ff ff       	call   801797 <vcprintf>
	va_end(ap);

	return cnt;
}
  801810:	c9                   	leave  
  801811:	c3                   	ret    
	...

00801814 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	57                   	push   %edi
  801818:	56                   	push   %esi
  801819:	53                   	push   %ebx
  80181a:	83 ec 3c             	sub    $0x3c,%esp
  80181d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801820:	89 d7                	mov    %edx,%edi
  801822:	8b 45 08             	mov    0x8(%ebp),%eax
  801825:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801828:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80182e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801831:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801834:	85 c0                	test   %eax,%eax
  801836:	75 08                	jne    801840 <printnum+0x2c>
  801838:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80183b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80183e:	77 57                	ja     801897 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801840:	89 74 24 10          	mov    %esi,0x10(%esp)
  801844:	4b                   	dec    %ebx
  801845:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801849:	8b 45 10             	mov    0x10(%ebp),%eax
  80184c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801850:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801854:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801858:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80185f:	00 
  801860:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801863:	89 04 24             	mov    %eax,(%esp)
  801866:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801869:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186d:	e8 d2 09 00 00       	call   802244 <__udivdi3>
  801872:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801876:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80187a:	89 04 24             	mov    %eax,(%esp)
  80187d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801881:	89 fa                	mov    %edi,%edx
  801883:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801886:	e8 89 ff ff ff       	call   801814 <printnum>
  80188b:	eb 0f                	jmp    80189c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80188d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801891:	89 34 24             	mov    %esi,(%esp)
  801894:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801897:	4b                   	dec    %ebx
  801898:	85 db                	test   %ebx,%ebx
  80189a:	7f f1                	jg     80188d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80189c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018a0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8018a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018ab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8018b2:	00 
  8018b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8018b6:	89 04 24             	mov    %eax,(%esp)
  8018b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c0:	e8 9f 0a 00 00       	call   802364 <__umoddi3>
  8018c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018c9:	0f be 80 2f 26 80 00 	movsbl 0x80262f(%eax),%eax
  8018d0:	89 04 24             	mov    %eax,(%esp)
  8018d3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8018d6:	83 c4 3c             	add    $0x3c,%esp
  8018d9:	5b                   	pop    %ebx
  8018da:	5e                   	pop    %esi
  8018db:	5f                   	pop    %edi
  8018dc:	5d                   	pop    %ebp
  8018dd:	c3                   	ret    

008018de <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8018e1:	83 fa 01             	cmp    $0x1,%edx
  8018e4:	7e 0e                	jle    8018f4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8018e6:	8b 10                	mov    (%eax),%edx
  8018e8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8018eb:	89 08                	mov    %ecx,(%eax)
  8018ed:	8b 02                	mov    (%edx),%eax
  8018ef:	8b 52 04             	mov    0x4(%edx),%edx
  8018f2:	eb 22                	jmp    801916 <getuint+0x38>
	else if (lflag)
  8018f4:	85 d2                	test   %edx,%edx
  8018f6:	74 10                	je     801908 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8018f8:	8b 10                	mov    (%eax),%edx
  8018fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8018fd:	89 08                	mov    %ecx,(%eax)
  8018ff:	8b 02                	mov    (%edx),%eax
  801901:	ba 00 00 00 00       	mov    $0x0,%edx
  801906:	eb 0e                	jmp    801916 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801908:	8b 10                	mov    (%eax),%edx
  80190a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80190d:	89 08                	mov    %ecx,(%eax)
  80190f:	8b 02                	mov    (%edx),%eax
  801911:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801916:	5d                   	pop    %ebp
  801917:	c3                   	ret    

00801918 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80191e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801921:	8b 10                	mov    (%eax),%edx
  801923:	3b 50 04             	cmp    0x4(%eax),%edx
  801926:	73 08                	jae    801930 <sprintputch+0x18>
		*b->buf++ = ch;
  801928:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80192b:	88 0a                	mov    %cl,(%edx)
  80192d:	42                   	inc    %edx
  80192e:	89 10                	mov    %edx,(%eax)
}
  801930:	5d                   	pop    %ebp
  801931:	c3                   	ret    

00801932 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801938:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80193b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80193f:	8b 45 10             	mov    0x10(%ebp),%eax
  801942:	89 44 24 08          	mov    %eax,0x8(%esp)
  801946:	8b 45 0c             	mov    0xc(%ebp),%eax
  801949:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194d:	8b 45 08             	mov    0x8(%ebp),%eax
  801950:	89 04 24             	mov    %eax,(%esp)
  801953:	e8 02 00 00 00       	call   80195a <vprintfmt>
	va_end(ap);
}
  801958:	c9                   	leave  
  801959:	c3                   	ret    

0080195a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	57                   	push   %edi
  80195e:	56                   	push   %esi
  80195f:	53                   	push   %ebx
  801960:	83 ec 4c             	sub    $0x4c,%esp
  801963:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801966:	8b 75 10             	mov    0x10(%ebp),%esi
  801969:	eb 12                	jmp    80197d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80196b:	85 c0                	test   %eax,%eax
  80196d:	0f 84 6b 03 00 00    	je     801cde <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  801973:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801977:	89 04 24             	mov    %eax,(%esp)
  80197a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80197d:	0f b6 06             	movzbl (%esi),%eax
  801980:	46                   	inc    %esi
  801981:	83 f8 25             	cmp    $0x25,%eax
  801984:	75 e5                	jne    80196b <vprintfmt+0x11>
  801986:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80198a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801991:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801996:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80199d:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019a2:	eb 26                	jmp    8019ca <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019a4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8019a7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8019ab:	eb 1d                	jmp    8019ca <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019ad:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8019b0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8019b4:	eb 14                	jmp    8019ca <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8019b9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8019c0:	eb 08                	jmp    8019ca <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8019c2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8019c5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019ca:	0f b6 06             	movzbl (%esi),%eax
  8019cd:	8d 56 01             	lea    0x1(%esi),%edx
  8019d0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8019d3:	8a 16                	mov    (%esi),%dl
  8019d5:	83 ea 23             	sub    $0x23,%edx
  8019d8:	80 fa 55             	cmp    $0x55,%dl
  8019db:	0f 87 e1 02 00 00    	ja     801cc2 <vprintfmt+0x368>
  8019e1:	0f b6 d2             	movzbl %dl,%edx
  8019e4:	ff 24 95 80 27 80 00 	jmp    *0x802780(,%edx,4)
  8019eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8019ee:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8019f3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8019f6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8019fa:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8019fd:	8d 50 d0             	lea    -0x30(%eax),%edx
  801a00:	83 fa 09             	cmp    $0x9,%edx
  801a03:	77 2a                	ja     801a2f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801a05:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801a06:	eb eb                	jmp    8019f3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801a08:	8b 45 14             	mov    0x14(%ebp),%eax
  801a0b:	8d 50 04             	lea    0x4(%eax),%edx
  801a0e:	89 55 14             	mov    %edx,0x14(%ebp)
  801a11:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a13:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801a16:	eb 17                	jmp    801a2f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801a18:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801a1c:	78 98                	js     8019b6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a1e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801a21:	eb a7                	jmp    8019ca <vprintfmt+0x70>
  801a23:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801a26:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801a2d:	eb 9b                	jmp    8019ca <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801a2f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801a33:	79 95                	jns    8019ca <vprintfmt+0x70>
  801a35:	eb 8b                	jmp    8019c2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801a37:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a38:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801a3b:	eb 8d                	jmp    8019ca <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801a3d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a40:	8d 50 04             	lea    0x4(%eax),%edx
  801a43:	89 55 14             	mov    %edx,0x14(%ebp)
  801a46:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a4a:	8b 00                	mov    (%eax),%eax
  801a4c:	89 04 24             	mov    %eax,(%esp)
  801a4f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a52:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801a55:	e9 23 ff ff ff       	jmp    80197d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801a5a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5d:	8d 50 04             	lea    0x4(%eax),%edx
  801a60:	89 55 14             	mov    %edx,0x14(%ebp)
  801a63:	8b 00                	mov    (%eax),%eax
  801a65:	85 c0                	test   %eax,%eax
  801a67:	79 02                	jns    801a6b <vprintfmt+0x111>
  801a69:	f7 d8                	neg    %eax
  801a6b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801a6d:	83 f8 10             	cmp    $0x10,%eax
  801a70:	7f 0b                	jg     801a7d <vprintfmt+0x123>
  801a72:	8b 04 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%eax
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	75 23                	jne    801aa0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801a7d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801a81:	c7 44 24 08 47 26 80 	movl   $0x802647,0x8(%esp)
  801a88:	00 
  801a89:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a90:	89 04 24             	mov    %eax,(%esp)
  801a93:	e8 9a fe ff ff       	call   801932 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a98:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801a9b:	e9 dd fe ff ff       	jmp    80197d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801aa0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801aa4:	c7 44 24 08 8d 25 80 	movl   $0x80258d,0x8(%esp)
  801aab:	00 
  801aac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ab0:	8b 55 08             	mov    0x8(%ebp),%edx
  801ab3:	89 14 24             	mov    %edx,(%esp)
  801ab6:	e8 77 fe ff ff       	call   801932 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801abb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801abe:	e9 ba fe ff ff       	jmp    80197d <vprintfmt+0x23>
  801ac3:	89 f9                	mov    %edi,%ecx
  801ac5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801acb:	8b 45 14             	mov    0x14(%ebp),%eax
  801ace:	8d 50 04             	lea    0x4(%eax),%edx
  801ad1:	89 55 14             	mov    %edx,0x14(%ebp)
  801ad4:	8b 30                	mov    (%eax),%esi
  801ad6:	85 f6                	test   %esi,%esi
  801ad8:	75 05                	jne    801adf <vprintfmt+0x185>
				p = "(null)";
  801ada:	be 40 26 80 00       	mov    $0x802640,%esi
			if (width > 0 && padc != '-')
  801adf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801ae3:	0f 8e 84 00 00 00    	jle    801b6d <vprintfmt+0x213>
  801ae9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801aed:	74 7e                	je     801b6d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  801aef:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801af3:	89 34 24             	mov    %esi,(%esp)
  801af6:	e8 8b 02 00 00       	call   801d86 <strnlen>
  801afb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801afe:	29 c2                	sub    %eax,%edx
  801b00:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801b03:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801b07:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801b0a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801b0d:	89 de                	mov    %ebx,%esi
  801b0f:	89 d3                	mov    %edx,%ebx
  801b11:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b13:	eb 0b                	jmp    801b20 <vprintfmt+0x1c6>
					putch(padc, putdat);
  801b15:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b19:	89 3c 24             	mov    %edi,(%esp)
  801b1c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b1f:	4b                   	dec    %ebx
  801b20:	85 db                	test   %ebx,%ebx
  801b22:	7f f1                	jg     801b15 <vprintfmt+0x1bb>
  801b24:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801b27:	89 f3                	mov    %esi,%ebx
  801b29:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801b2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	79 05                	jns    801b38 <vprintfmt+0x1de>
  801b33:	b8 00 00 00 00       	mov    $0x0,%eax
  801b38:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b3b:	29 c2                	sub    %eax,%edx
  801b3d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801b40:	eb 2b                	jmp    801b6d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801b42:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b46:	74 18                	je     801b60 <vprintfmt+0x206>
  801b48:	8d 50 e0             	lea    -0x20(%eax),%edx
  801b4b:	83 fa 5e             	cmp    $0x5e,%edx
  801b4e:	76 10                	jbe    801b60 <vprintfmt+0x206>
					putch('?', putdat);
  801b50:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b54:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801b5b:	ff 55 08             	call   *0x8(%ebp)
  801b5e:	eb 0a                	jmp    801b6a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801b60:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b64:	89 04 24             	mov    %eax,(%esp)
  801b67:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801b6a:	ff 4d e4             	decl   -0x1c(%ebp)
  801b6d:	0f be 06             	movsbl (%esi),%eax
  801b70:	46                   	inc    %esi
  801b71:	85 c0                	test   %eax,%eax
  801b73:	74 21                	je     801b96 <vprintfmt+0x23c>
  801b75:	85 ff                	test   %edi,%edi
  801b77:	78 c9                	js     801b42 <vprintfmt+0x1e8>
  801b79:	4f                   	dec    %edi
  801b7a:	79 c6                	jns    801b42 <vprintfmt+0x1e8>
  801b7c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b7f:	89 de                	mov    %ebx,%esi
  801b81:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801b84:	eb 18                	jmp    801b9e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801b86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b8a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801b91:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801b93:	4b                   	dec    %ebx
  801b94:	eb 08                	jmp    801b9e <vprintfmt+0x244>
  801b96:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b99:	89 de                	mov    %ebx,%esi
  801b9b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801b9e:	85 db                	test   %ebx,%ebx
  801ba0:	7f e4                	jg     801b86 <vprintfmt+0x22c>
  801ba2:	89 7d 08             	mov    %edi,0x8(%ebp)
  801ba5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ba7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801baa:	e9 ce fd ff ff       	jmp    80197d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801baf:	83 f9 01             	cmp    $0x1,%ecx
  801bb2:	7e 10                	jle    801bc4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801bb4:	8b 45 14             	mov    0x14(%ebp),%eax
  801bb7:	8d 50 08             	lea    0x8(%eax),%edx
  801bba:	89 55 14             	mov    %edx,0x14(%ebp)
  801bbd:	8b 30                	mov    (%eax),%esi
  801bbf:	8b 78 04             	mov    0x4(%eax),%edi
  801bc2:	eb 26                	jmp    801bea <vprintfmt+0x290>
	else if (lflag)
  801bc4:	85 c9                	test   %ecx,%ecx
  801bc6:	74 12                	je     801bda <vprintfmt+0x280>
		return va_arg(*ap, long);
  801bc8:	8b 45 14             	mov    0x14(%ebp),%eax
  801bcb:	8d 50 04             	lea    0x4(%eax),%edx
  801bce:	89 55 14             	mov    %edx,0x14(%ebp)
  801bd1:	8b 30                	mov    (%eax),%esi
  801bd3:	89 f7                	mov    %esi,%edi
  801bd5:	c1 ff 1f             	sar    $0x1f,%edi
  801bd8:	eb 10                	jmp    801bea <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801bda:	8b 45 14             	mov    0x14(%ebp),%eax
  801bdd:	8d 50 04             	lea    0x4(%eax),%edx
  801be0:	89 55 14             	mov    %edx,0x14(%ebp)
  801be3:	8b 30                	mov    (%eax),%esi
  801be5:	89 f7                	mov    %esi,%edi
  801be7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801bea:	85 ff                	test   %edi,%edi
  801bec:	78 0a                	js     801bf8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801bee:	b8 0a 00 00 00       	mov    $0xa,%eax
  801bf3:	e9 8c 00 00 00       	jmp    801c84 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801bf8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bfc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801c03:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801c06:	f7 de                	neg    %esi
  801c08:	83 d7 00             	adc    $0x0,%edi
  801c0b:	f7 df                	neg    %edi
			}
			base = 10;
  801c0d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801c12:	eb 70                	jmp    801c84 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801c14:	89 ca                	mov    %ecx,%edx
  801c16:	8d 45 14             	lea    0x14(%ebp),%eax
  801c19:	e8 c0 fc ff ff       	call   8018de <getuint>
  801c1e:	89 c6                	mov    %eax,%esi
  801c20:	89 d7                	mov    %edx,%edi
			base = 10;
  801c22:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801c27:	eb 5b                	jmp    801c84 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  801c29:	89 ca                	mov    %ecx,%edx
  801c2b:	8d 45 14             	lea    0x14(%ebp),%eax
  801c2e:	e8 ab fc ff ff       	call   8018de <getuint>
  801c33:	89 c6                	mov    %eax,%esi
  801c35:	89 d7                	mov    %edx,%edi
			base = 8;
  801c37:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801c3c:	eb 46                	jmp    801c84 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  801c3e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c42:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801c49:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801c4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c50:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801c57:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801c5a:	8b 45 14             	mov    0x14(%ebp),%eax
  801c5d:	8d 50 04             	lea    0x4(%eax),%edx
  801c60:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801c63:	8b 30                	mov    (%eax),%esi
  801c65:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801c6a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801c6f:	eb 13                	jmp    801c84 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801c71:	89 ca                	mov    %ecx,%edx
  801c73:	8d 45 14             	lea    0x14(%ebp),%eax
  801c76:	e8 63 fc ff ff       	call   8018de <getuint>
  801c7b:	89 c6                	mov    %eax,%esi
  801c7d:	89 d7                	mov    %edx,%edi
			base = 16;
  801c7f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801c84:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801c88:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c8c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c8f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c93:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c97:	89 34 24             	mov    %esi,(%esp)
  801c9a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c9e:	89 da                	mov    %ebx,%edx
  801ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca3:	e8 6c fb ff ff       	call   801814 <printnum>
			break;
  801ca8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801cab:	e9 cd fc ff ff       	jmp    80197d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801cb0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cb4:	89 04 24             	mov    %eax,(%esp)
  801cb7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801cbd:	e9 bb fc ff ff       	jmp    80197d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801cc2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cc6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801ccd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801cd0:	eb 01                	jmp    801cd3 <vprintfmt+0x379>
  801cd2:	4e                   	dec    %esi
  801cd3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801cd7:	75 f9                	jne    801cd2 <vprintfmt+0x378>
  801cd9:	e9 9f fc ff ff       	jmp    80197d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801cde:	83 c4 4c             	add    $0x4c,%esp
  801ce1:	5b                   	pop    %ebx
  801ce2:	5e                   	pop    %esi
  801ce3:	5f                   	pop    %edi
  801ce4:	5d                   	pop    %ebp
  801ce5:	c3                   	ret    

00801ce6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	83 ec 28             	sub    $0x28,%esp
  801cec:	8b 45 08             	mov    0x8(%ebp),%eax
  801cef:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801cf2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cf5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801cf9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801cfc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801d03:	85 c0                	test   %eax,%eax
  801d05:	74 30                	je     801d37 <vsnprintf+0x51>
  801d07:	85 d2                	test   %edx,%edx
  801d09:	7e 33                	jle    801d3e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801d0b:	8b 45 14             	mov    0x14(%ebp),%eax
  801d0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d12:	8b 45 10             	mov    0x10(%ebp),%eax
  801d15:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d19:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d20:	c7 04 24 18 19 80 00 	movl   $0x801918,(%esp)
  801d27:	e8 2e fc ff ff       	call   80195a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801d2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d2f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d35:	eb 0c                	jmp    801d43 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801d37:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d3c:	eb 05                	jmp    801d43 <vsnprintf+0x5d>
  801d3e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    

00801d45 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801d4b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801d4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d52:	8b 45 10             	mov    0x10(%ebp),%eax
  801d55:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d59:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d60:	8b 45 08             	mov    0x8(%ebp),%eax
  801d63:	89 04 24             	mov    %eax,(%esp)
  801d66:	e8 7b ff ff ff       	call   801ce6 <vsnprintf>
	va_end(ap);

	return rc;
}
  801d6b:	c9                   	leave  
  801d6c:	c3                   	ret    
  801d6d:	00 00                	add    %al,(%eax)
	...

00801d70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801d76:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7b:	eb 01                	jmp    801d7e <strlen+0xe>
		n++;
  801d7d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801d7e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801d82:	75 f9                	jne    801d7d <strlen+0xd>
		n++;
	return n;
}
  801d84:	5d                   	pop    %ebp
  801d85:	c3                   	ret    

00801d86 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801d8c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801d8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d94:	eb 01                	jmp    801d97 <strnlen+0x11>
		n++;
  801d96:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801d97:	39 d0                	cmp    %edx,%eax
  801d99:	74 06                	je     801da1 <strnlen+0x1b>
  801d9b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801d9f:	75 f5                	jne    801d96 <strnlen+0x10>
		n++;
	return n;
}
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    

00801da3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	53                   	push   %ebx
  801da7:	8b 45 08             	mov    0x8(%ebp),%eax
  801daa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801dad:	ba 00 00 00 00       	mov    $0x0,%edx
  801db2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801db5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801db8:	42                   	inc    %edx
  801db9:	84 c9                	test   %cl,%cl
  801dbb:	75 f5                	jne    801db2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801dbd:	5b                   	pop    %ebx
  801dbe:	5d                   	pop    %ebp
  801dbf:	c3                   	ret    

00801dc0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	53                   	push   %ebx
  801dc4:	83 ec 08             	sub    $0x8,%esp
  801dc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801dca:	89 1c 24             	mov    %ebx,(%esp)
  801dcd:	e8 9e ff ff ff       	call   801d70 <strlen>
	strcpy(dst + len, src);
  801dd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dd9:	01 d8                	add    %ebx,%eax
  801ddb:	89 04 24             	mov    %eax,(%esp)
  801dde:	e8 c0 ff ff ff       	call   801da3 <strcpy>
	return dst;
}
  801de3:	89 d8                	mov    %ebx,%eax
  801de5:	83 c4 08             	add    $0x8,%esp
  801de8:	5b                   	pop    %ebx
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    

00801deb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	56                   	push   %esi
  801def:	53                   	push   %ebx
  801df0:	8b 45 08             	mov    0x8(%ebp),%eax
  801df3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801df9:	b9 00 00 00 00       	mov    $0x0,%ecx
  801dfe:	eb 0c                	jmp    801e0c <strncpy+0x21>
		*dst++ = *src;
  801e00:	8a 1a                	mov    (%edx),%bl
  801e02:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801e05:	80 3a 01             	cmpb   $0x1,(%edx)
  801e08:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801e0b:	41                   	inc    %ecx
  801e0c:	39 f1                	cmp    %esi,%ecx
  801e0e:	75 f0                	jne    801e00 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801e10:	5b                   	pop    %ebx
  801e11:	5e                   	pop    %esi
  801e12:	5d                   	pop    %ebp
  801e13:	c3                   	ret    

00801e14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	56                   	push   %esi
  801e18:	53                   	push   %ebx
  801e19:	8b 75 08             	mov    0x8(%ebp),%esi
  801e1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e1f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e22:	85 d2                	test   %edx,%edx
  801e24:	75 0a                	jne    801e30 <strlcpy+0x1c>
  801e26:	89 f0                	mov    %esi,%eax
  801e28:	eb 1a                	jmp    801e44 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801e2a:	88 18                	mov    %bl,(%eax)
  801e2c:	40                   	inc    %eax
  801e2d:	41                   	inc    %ecx
  801e2e:	eb 02                	jmp    801e32 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e30:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801e32:	4a                   	dec    %edx
  801e33:	74 0a                	je     801e3f <strlcpy+0x2b>
  801e35:	8a 19                	mov    (%ecx),%bl
  801e37:	84 db                	test   %bl,%bl
  801e39:	75 ef                	jne    801e2a <strlcpy+0x16>
  801e3b:	89 c2                	mov    %eax,%edx
  801e3d:	eb 02                	jmp    801e41 <strlcpy+0x2d>
  801e3f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801e41:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801e44:	29 f0                	sub    %esi,%eax
}
  801e46:	5b                   	pop    %ebx
  801e47:	5e                   	pop    %esi
  801e48:	5d                   	pop    %ebp
  801e49:	c3                   	ret    

00801e4a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e50:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801e53:	eb 02                	jmp    801e57 <strcmp+0xd>
		p++, q++;
  801e55:	41                   	inc    %ecx
  801e56:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801e57:	8a 01                	mov    (%ecx),%al
  801e59:	84 c0                	test   %al,%al
  801e5b:	74 04                	je     801e61 <strcmp+0x17>
  801e5d:	3a 02                	cmp    (%edx),%al
  801e5f:	74 f4                	je     801e55 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801e61:	0f b6 c0             	movzbl %al,%eax
  801e64:	0f b6 12             	movzbl (%edx),%edx
  801e67:	29 d0                	sub    %edx,%eax
}
  801e69:	5d                   	pop    %ebp
  801e6a:	c3                   	ret    

00801e6b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	53                   	push   %ebx
  801e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e75:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801e78:	eb 03                	jmp    801e7d <strncmp+0x12>
		n--, p++, q++;
  801e7a:	4a                   	dec    %edx
  801e7b:	40                   	inc    %eax
  801e7c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801e7d:	85 d2                	test   %edx,%edx
  801e7f:	74 14                	je     801e95 <strncmp+0x2a>
  801e81:	8a 18                	mov    (%eax),%bl
  801e83:	84 db                	test   %bl,%bl
  801e85:	74 04                	je     801e8b <strncmp+0x20>
  801e87:	3a 19                	cmp    (%ecx),%bl
  801e89:	74 ef                	je     801e7a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801e8b:	0f b6 00             	movzbl (%eax),%eax
  801e8e:	0f b6 11             	movzbl (%ecx),%edx
  801e91:	29 d0                	sub    %edx,%eax
  801e93:	eb 05                	jmp    801e9a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801e95:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801e9a:	5b                   	pop    %ebx
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    

00801e9d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801ea6:	eb 05                	jmp    801ead <strchr+0x10>
		if (*s == c)
  801ea8:	38 ca                	cmp    %cl,%dl
  801eaa:	74 0c                	je     801eb8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801eac:	40                   	inc    %eax
  801ead:	8a 10                	mov    (%eax),%dl
  801eaf:	84 d2                	test   %dl,%dl
  801eb1:	75 f5                	jne    801ea8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801eb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eb8:	5d                   	pop    %ebp
  801eb9:	c3                   	ret    

00801eba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801eba:	55                   	push   %ebp
  801ebb:	89 e5                	mov    %esp,%ebp
  801ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801ec3:	eb 05                	jmp    801eca <strfind+0x10>
		if (*s == c)
  801ec5:	38 ca                	cmp    %cl,%dl
  801ec7:	74 07                	je     801ed0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801ec9:	40                   	inc    %eax
  801eca:	8a 10                	mov    (%eax),%dl
  801ecc:	84 d2                	test   %dl,%dl
  801ece:	75 f5                	jne    801ec5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801ed0:	5d                   	pop    %ebp
  801ed1:	c3                   	ret    

00801ed2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	57                   	push   %edi
  801ed6:	56                   	push   %esi
  801ed7:	53                   	push   %ebx
  801ed8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801edb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ede:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ee1:	85 c9                	test   %ecx,%ecx
  801ee3:	74 30                	je     801f15 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ee5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801eeb:	75 25                	jne    801f12 <memset+0x40>
  801eed:	f6 c1 03             	test   $0x3,%cl
  801ef0:	75 20                	jne    801f12 <memset+0x40>
		c &= 0xFF;
  801ef2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ef5:	89 d3                	mov    %edx,%ebx
  801ef7:	c1 e3 08             	shl    $0x8,%ebx
  801efa:	89 d6                	mov    %edx,%esi
  801efc:	c1 e6 18             	shl    $0x18,%esi
  801eff:	89 d0                	mov    %edx,%eax
  801f01:	c1 e0 10             	shl    $0x10,%eax
  801f04:	09 f0                	or     %esi,%eax
  801f06:	09 d0                	or     %edx,%eax
  801f08:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801f0a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801f0d:	fc                   	cld    
  801f0e:	f3 ab                	rep stos %eax,%es:(%edi)
  801f10:	eb 03                	jmp    801f15 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801f12:	fc                   	cld    
  801f13:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801f15:	89 f8                	mov    %edi,%eax
  801f17:	5b                   	pop    %ebx
  801f18:	5e                   	pop    %esi
  801f19:	5f                   	pop    %edi
  801f1a:	5d                   	pop    %ebp
  801f1b:	c3                   	ret    

00801f1c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801f1c:	55                   	push   %ebp
  801f1d:	89 e5                	mov    %esp,%ebp
  801f1f:	57                   	push   %edi
  801f20:	56                   	push   %esi
  801f21:	8b 45 08             	mov    0x8(%ebp),%eax
  801f24:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f27:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801f2a:	39 c6                	cmp    %eax,%esi
  801f2c:	73 34                	jae    801f62 <memmove+0x46>
  801f2e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801f31:	39 d0                	cmp    %edx,%eax
  801f33:	73 2d                	jae    801f62 <memmove+0x46>
		s += n;
		d += n;
  801f35:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f38:	f6 c2 03             	test   $0x3,%dl
  801f3b:	75 1b                	jne    801f58 <memmove+0x3c>
  801f3d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801f43:	75 13                	jne    801f58 <memmove+0x3c>
  801f45:	f6 c1 03             	test   $0x3,%cl
  801f48:	75 0e                	jne    801f58 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801f4a:	83 ef 04             	sub    $0x4,%edi
  801f4d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801f50:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801f53:	fd                   	std    
  801f54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f56:	eb 07                	jmp    801f5f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801f58:	4f                   	dec    %edi
  801f59:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801f5c:	fd                   	std    
  801f5d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801f5f:	fc                   	cld    
  801f60:	eb 20                	jmp    801f82 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f62:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801f68:	75 13                	jne    801f7d <memmove+0x61>
  801f6a:	a8 03                	test   $0x3,%al
  801f6c:	75 0f                	jne    801f7d <memmove+0x61>
  801f6e:	f6 c1 03             	test   $0x3,%cl
  801f71:	75 0a                	jne    801f7d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801f73:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801f76:	89 c7                	mov    %eax,%edi
  801f78:	fc                   	cld    
  801f79:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f7b:	eb 05                	jmp    801f82 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801f7d:	89 c7                	mov    %eax,%edi
  801f7f:	fc                   	cld    
  801f80:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801f82:	5e                   	pop    %esi
  801f83:	5f                   	pop    %edi
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    

00801f86 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801f86:	55                   	push   %ebp
  801f87:	89 e5                	mov    %esp,%ebp
  801f89:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801f8c:	8b 45 10             	mov    0x10(%ebp),%eax
  801f8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f93:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f96:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9d:	89 04 24             	mov    %eax,(%esp)
  801fa0:	e8 77 ff ff ff       	call   801f1c <memmove>
}
  801fa5:	c9                   	leave  
  801fa6:	c3                   	ret    

00801fa7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801fa7:	55                   	push   %ebp
  801fa8:	89 e5                	mov    %esp,%ebp
  801faa:	57                   	push   %edi
  801fab:	56                   	push   %esi
  801fac:	53                   	push   %ebx
  801fad:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fb0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801fb6:	ba 00 00 00 00       	mov    $0x0,%edx
  801fbb:	eb 16                	jmp    801fd3 <memcmp+0x2c>
		if (*s1 != *s2)
  801fbd:	8a 04 17             	mov    (%edi,%edx,1),%al
  801fc0:	42                   	inc    %edx
  801fc1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801fc5:	38 c8                	cmp    %cl,%al
  801fc7:	74 0a                	je     801fd3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801fc9:	0f b6 c0             	movzbl %al,%eax
  801fcc:	0f b6 c9             	movzbl %cl,%ecx
  801fcf:	29 c8                	sub    %ecx,%eax
  801fd1:	eb 09                	jmp    801fdc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801fd3:	39 da                	cmp    %ebx,%edx
  801fd5:	75 e6                	jne    801fbd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801fd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fdc:	5b                   	pop    %ebx
  801fdd:	5e                   	pop    %esi
  801fde:	5f                   	pop    %edi
  801fdf:	5d                   	pop    %ebp
  801fe0:	c3                   	ret    

00801fe1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801fe1:	55                   	push   %ebp
  801fe2:	89 e5                	mov    %esp,%ebp
  801fe4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801fea:	89 c2                	mov    %eax,%edx
  801fec:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801fef:	eb 05                	jmp    801ff6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ff1:	38 08                	cmp    %cl,(%eax)
  801ff3:	74 05                	je     801ffa <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ff5:	40                   	inc    %eax
  801ff6:	39 d0                	cmp    %edx,%eax
  801ff8:	72 f7                	jb     801ff1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801ffa:	5d                   	pop    %ebp
  801ffb:	c3                   	ret    

00801ffc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ffc:	55                   	push   %ebp
  801ffd:	89 e5                	mov    %esp,%ebp
  801fff:	57                   	push   %edi
  802000:	56                   	push   %esi
  802001:	53                   	push   %ebx
  802002:	8b 55 08             	mov    0x8(%ebp),%edx
  802005:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802008:	eb 01                	jmp    80200b <strtol+0xf>
		s++;
  80200a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80200b:	8a 02                	mov    (%edx),%al
  80200d:	3c 20                	cmp    $0x20,%al
  80200f:	74 f9                	je     80200a <strtol+0xe>
  802011:	3c 09                	cmp    $0x9,%al
  802013:	74 f5                	je     80200a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802015:	3c 2b                	cmp    $0x2b,%al
  802017:	75 08                	jne    802021 <strtol+0x25>
		s++;
  802019:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80201a:	bf 00 00 00 00       	mov    $0x0,%edi
  80201f:	eb 13                	jmp    802034 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802021:	3c 2d                	cmp    $0x2d,%al
  802023:	75 0a                	jne    80202f <strtol+0x33>
		s++, neg = 1;
  802025:	8d 52 01             	lea    0x1(%edx),%edx
  802028:	bf 01 00 00 00       	mov    $0x1,%edi
  80202d:	eb 05                	jmp    802034 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80202f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802034:	85 db                	test   %ebx,%ebx
  802036:	74 05                	je     80203d <strtol+0x41>
  802038:	83 fb 10             	cmp    $0x10,%ebx
  80203b:	75 28                	jne    802065 <strtol+0x69>
  80203d:	8a 02                	mov    (%edx),%al
  80203f:	3c 30                	cmp    $0x30,%al
  802041:	75 10                	jne    802053 <strtol+0x57>
  802043:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802047:	75 0a                	jne    802053 <strtol+0x57>
		s += 2, base = 16;
  802049:	83 c2 02             	add    $0x2,%edx
  80204c:	bb 10 00 00 00       	mov    $0x10,%ebx
  802051:	eb 12                	jmp    802065 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  802053:	85 db                	test   %ebx,%ebx
  802055:	75 0e                	jne    802065 <strtol+0x69>
  802057:	3c 30                	cmp    $0x30,%al
  802059:	75 05                	jne    802060 <strtol+0x64>
		s++, base = 8;
  80205b:	42                   	inc    %edx
  80205c:	b3 08                	mov    $0x8,%bl
  80205e:	eb 05                	jmp    802065 <strtol+0x69>
	else if (base == 0)
		base = 10;
  802060:	bb 0a 00 00 00       	mov    $0xa,%ebx
  802065:	b8 00 00 00 00       	mov    $0x0,%eax
  80206a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80206c:	8a 0a                	mov    (%edx),%cl
  80206e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  802071:	80 fb 09             	cmp    $0x9,%bl
  802074:	77 08                	ja     80207e <strtol+0x82>
			dig = *s - '0';
  802076:	0f be c9             	movsbl %cl,%ecx
  802079:	83 e9 30             	sub    $0x30,%ecx
  80207c:	eb 1e                	jmp    80209c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80207e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  802081:	80 fb 19             	cmp    $0x19,%bl
  802084:	77 08                	ja     80208e <strtol+0x92>
			dig = *s - 'a' + 10;
  802086:	0f be c9             	movsbl %cl,%ecx
  802089:	83 e9 57             	sub    $0x57,%ecx
  80208c:	eb 0e                	jmp    80209c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80208e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  802091:	80 fb 19             	cmp    $0x19,%bl
  802094:	77 12                	ja     8020a8 <strtol+0xac>
			dig = *s - 'A' + 10;
  802096:	0f be c9             	movsbl %cl,%ecx
  802099:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80209c:	39 f1                	cmp    %esi,%ecx
  80209e:	7d 0c                	jge    8020ac <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  8020a0:	42                   	inc    %edx
  8020a1:	0f af c6             	imul   %esi,%eax
  8020a4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8020a6:	eb c4                	jmp    80206c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8020a8:	89 c1                	mov    %eax,%ecx
  8020aa:	eb 02                	jmp    8020ae <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8020ac:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8020ae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8020b2:	74 05                	je     8020b9 <strtol+0xbd>
		*endptr = (char *) s;
  8020b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8020b7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8020b9:	85 ff                	test   %edi,%edi
  8020bb:	74 04                	je     8020c1 <strtol+0xc5>
  8020bd:	89 c8                	mov    %ecx,%eax
  8020bf:	f7 d8                	neg    %eax
}
  8020c1:	5b                   	pop    %ebx
  8020c2:	5e                   	pop    %esi
  8020c3:	5f                   	pop    %edi
  8020c4:	5d                   	pop    %ebp
  8020c5:	c3                   	ret    
	...

008020c8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	56                   	push   %esi
  8020cc:	53                   	push   %ebx
  8020cd:	83 ec 10             	sub    $0x10,%esp
  8020d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8020d9:	85 c0                	test   %eax,%eax
  8020db:	74 0a                	je     8020e7 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8020dd:	89 04 24             	mov    %eax,(%esp)
  8020e0:	e8 c2 e2 ff ff       	call   8003a7 <sys_ipc_recv>
  8020e5:	eb 0c                	jmp    8020f3 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8020e7:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8020ee:	e8 b4 e2 ff ff       	call   8003a7 <sys_ipc_recv>
	}
	if (r < 0)
  8020f3:	85 c0                	test   %eax,%eax
  8020f5:	79 16                	jns    80210d <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8020f7:	85 db                	test   %ebx,%ebx
  8020f9:	74 06                	je     802101 <ipc_recv+0x39>
  8020fb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802101:	85 f6                	test   %esi,%esi
  802103:	74 2c                	je     802131 <ipc_recv+0x69>
  802105:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80210b:	eb 24                	jmp    802131 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  80210d:	85 db                	test   %ebx,%ebx
  80210f:	74 0a                	je     80211b <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802111:	a1 08 40 80 00       	mov    0x804008,%eax
  802116:	8b 40 74             	mov    0x74(%eax),%eax
  802119:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  80211b:	85 f6                	test   %esi,%esi
  80211d:	74 0a                	je     802129 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  80211f:	a1 08 40 80 00       	mov    0x804008,%eax
  802124:	8b 40 78             	mov    0x78(%eax),%eax
  802127:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802129:	a1 08 40 80 00       	mov    0x804008,%eax
  80212e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802131:	83 c4 10             	add    $0x10,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    

00802138 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	57                   	push   %edi
  80213c:	56                   	push   %esi
  80213d:	53                   	push   %ebx
  80213e:	83 ec 1c             	sub    $0x1c,%esp
  802141:	8b 75 08             	mov    0x8(%ebp),%esi
  802144:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802147:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  80214a:	85 db                	test   %ebx,%ebx
  80214c:	74 19                	je     802167 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  80214e:	8b 45 14             	mov    0x14(%ebp),%eax
  802151:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802155:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802159:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80215d:	89 34 24             	mov    %esi,(%esp)
  802160:	e8 1f e2 ff ff       	call   800384 <sys_ipc_try_send>
  802165:	eb 1c                	jmp    802183 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  802167:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80216e:	00 
  80216f:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802176:	ee 
  802177:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80217b:	89 34 24             	mov    %esi,(%esp)
  80217e:	e8 01 e2 ff ff       	call   800384 <sys_ipc_try_send>
		}
		if (r == 0)
  802183:	85 c0                	test   %eax,%eax
  802185:	74 2c                	je     8021b3 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802187:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80218a:	74 20                	je     8021ac <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  80218c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802190:	c7 44 24 08 44 29 80 	movl   $0x802944,0x8(%esp)
  802197:	00 
  802198:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80219f:	00 
  8021a0:	c7 04 24 57 29 80 00 	movl   $0x802957,(%esp)
  8021a7:	e8 54 f5 ff ff       	call   801700 <_panic>
		}
		sys_yield();
  8021ac:	e8 c1 df ff ff       	call   800172 <sys_yield>
	}
  8021b1:	eb 97                	jmp    80214a <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8021b3:	83 c4 1c             	add    $0x1c,%esp
  8021b6:	5b                   	pop    %ebx
  8021b7:	5e                   	pop    %esi
  8021b8:	5f                   	pop    %edi
  8021b9:	5d                   	pop    %ebp
  8021ba:	c3                   	ret    

008021bb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021bb:	55                   	push   %ebp
  8021bc:	89 e5                	mov    %esp,%ebp
  8021be:	53                   	push   %ebx
  8021bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8021c2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021c7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8021ce:	89 c2                	mov    %eax,%edx
  8021d0:	c1 e2 07             	shl    $0x7,%edx
  8021d3:	29 ca                	sub    %ecx,%edx
  8021d5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021db:	8b 52 50             	mov    0x50(%edx),%edx
  8021de:	39 da                	cmp    %ebx,%edx
  8021e0:	75 0f                	jne    8021f1 <ipc_find_env+0x36>
			return envs[i].env_id;
  8021e2:	c1 e0 07             	shl    $0x7,%eax
  8021e5:	29 c8                	sub    %ecx,%eax
  8021e7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021ec:	8b 40 40             	mov    0x40(%eax),%eax
  8021ef:	eb 0c                	jmp    8021fd <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021f1:	40                   	inc    %eax
  8021f2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021f7:	75 ce                	jne    8021c7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021f9:	66 b8 00 00          	mov    $0x0,%ax
}
  8021fd:	5b                   	pop    %ebx
  8021fe:	5d                   	pop    %ebp
  8021ff:	c3                   	ret    

00802200 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802200:	55                   	push   %ebp
  802201:	89 e5                	mov    %esp,%ebp
  802203:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802206:	89 c2                	mov    %eax,%edx
  802208:	c1 ea 16             	shr    $0x16,%edx
  80220b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802212:	f6 c2 01             	test   $0x1,%dl
  802215:	74 1e                	je     802235 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802217:	c1 e8 0c             	shr    $0xc,%eax
  80221a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802221:	a8 01                	test   $0x1,%al
  802223:	74 17                	je     80223c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802225:	c1 e8 0c             	shr    $0xc,%eax
  802228:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80222f:	ef 
  802230:	0f b7 c0             	movzwl %ax,%eax
  802233:	eb 0c                	jmp    802241 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802235:	b8 00 00 00 00       	mov    $0x0,%eax
  80223a:	eb 05                	jmp    802241 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80223c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802241:	5d                   	pop    %ebp
  802242:	c3                   	ret    
	...

00802244 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802244:	55                   	push   %ebp
  802245:	57                   	push   %edi
  802246:	56                   	push   %esi
  802247:	83 ec 10             	sub    $0x10,%esp
  80224a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80224e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802252:	89 74 24 04          	mov    %esi,0x4(%esp)
  802256:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80225a:	89 cd                	mov    %ecx,%ebp
  80225c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802260:	85 c0                	test   %eax,%eax
  802262:	75 2c                	jne    802290 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802264:	39 f9                	cmp    %edi,%ecx
  802266:	77 68                	ja     8022d0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802268:	85 c9                	test   %ecx,%ecx
  80226a:	75 0b                	jne    802277 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80226c:	b8 01 00 00 00       	mov    $0x1,%eax
  802271:	31 d2                	xor    %edx,%edx
  802273:	f7 f1                	div    %ecx
  802275:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802277:	31 d2                	xor    %edx,%edx
  802279:	89 f8                	mov    %edi,%eax
  80227b:	f7 f1                	div    %ecx
  80227d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80227f:	89 f0                	mov    %esi,%eax
  802281:	f7 f1                	div    %ecx
  802283:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802285:	89 f0                	mov    %esi,%eax
  802287:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802289:	83 c4 10             	add    $0x10,%esp
  80228c:	5e                   	pop    %esi
  80228d:	5f                   	pop    %edi
  80228e:	5d                   	pop    %ebp
  80228f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802290:	39 f8                	cmp    %edi,%eax
  802292:	77 2c                	ja     8022c0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802294:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802297:	83 f6 1f             	xor    $0x1f,%esi
  80229a:	75 4c                	jne    8022e8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80229c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80229e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8022a3:	72 0a                	jb     8022af <__udivdi3+0x6b>
  8022a5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022a9:	0f 87 ad 00 00 00    	ja     80235c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022af:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022b4:	89 f0                	mov    %esi,%eax
  8022b6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022b8:	83 c4 10             	add    $0x10,%esp
  8022bb:	5e                   	pop    %esi
  8022bc:	5f                   	pop    %edi
  8022bd:	5d                   	pop    %ebp
  8022be:	c3                   	ret    
  8022bf:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022c0:	31 ff                	xor    %edi,%edi
  8022c2:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022c4:	89 f0                	mov    %esi,%eax
  8022c6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022c8:	83 c4 10             	add    $0x10,%esp
  8022cb:	5e                   	pop    %esi
  8022cc:	5f                   	pop    %edi
  8022cd:	5d                   	pop    %ebp
  8022ce:	c3                   	ret    
  8022cf:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022d0:	89 fa                	mov    %edi,%edx
  8022d2:	89 f0                	mov    %esi,%eax
  8022d4:	f7 f1                	div    %ecx
  8022d6:	89 c6                	mov    %eax,%esi
  8022d8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022da:	89 f0                	mov    %esi,%eax
  8022dc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022de:	83 c4 10             	add    $0x10,%esp
  8022e1:	5e                   	pop    %esi
  8022e2:	5f                   	pop    %edi
  8022e3:	5d                   	pop    %ebp
  8022e4:	c3                   	ret    
  8022e5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8022e8:	89 f1                	mov    %esi,%ecx
  8022ea:	d3 e0                	shl    %cl,%eax
  8022ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022f0:	b8 20 00 00 00       	mov    $0x20,%eax
  8022f5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8022f7:	89 ea                	mov    %ebp,%edx
  8022f9:	88 c1                	mov    %al,%cl
  8022fb:	d3 ea                	shr    %cl,%edx
  8022fd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802301:	09 ca                	or     %ecx,%edx
  802303:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802307:	89 f1                	mov    %esi,%ecx
  802309:	d3 e5                	shl    %cl,%ebp
  80230b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80230f:	89 fd                	mov    %edi,%ebp
  802311:	88 c1                	mov    %al,%cl
  802313:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802315:	89 fa                	mov    %edi,%edx
  802317:	89 f1                	mov    %esi,%ecx
  802319:	d3 e2                	shl    %cl,%edx
  80231b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80231f:	88 c1                	mov    %al,%cl
  802321:	d3 ef                	shr    %cl,%edi
  802323:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802325:	89 f8                	mov    %edi,%eax
  802327:	89 ea                	mov    %ebp,%edx
  802329:	f7 74 24 08          	divl   0x8(%esp)
  80232d:	89 d1                	mov    %edx,%ecx
  80232f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802331:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802335:	39 d1                	cmp    %edx,%ecx
  802337:	72 17                	jb     802350 <__udivdi3+0x10c>
  802339:	74 09                	je     802344 <__udivdi3+0x100>
  80233b:	89 fe                	mov    %edi,%esi
  80233d:	31 ff                	xor    %edi,%edi
  80233f:	e9 41 ff ff ff       	jmp    802285 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802344:	8b 54 24 04          	mov    0x4(%esp),%edx
  802348:	89 f1                	mov    %esi,%ecx
  80234a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80234c:	39 c2                	cmp    %eax,%edx
  80234e:	73 eb                	jae    80233b <__udivdi3+0xf7>
		{
		  q0--;
  802350:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802353:	31 ff                	xor    %edi,%edi
  802355:	e9 2b ff ff ff       	jmp    802285 <__udivdi3+0x41>
  80235a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80235c:	31 f6                	xor    %esi,%esi
  80235e:	e9 22 ff ff ff       	jmp    802285 <__udivdi3+0x41>
	...

00802364 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802364:	55                   	push   %ebp
  802365:	57                   	push   %edi
  802366:	56                   	push   %esi
  802367:	83 ec 20             	sub    $0x20,%esp
  80236a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80236e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802372:	89 44 24 14          	mov    %eax,0x14(%esp)
  802376:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80237a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80237e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802382:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802384:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802386:	85 ed                	test   %ebp,%ebp
  802388:	75 16                	jne    8023a0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80238a:	39 f1                	cmp    %esi,%ecx
  80238c:	0f 86 a6 00 00 00    	jbe    802438 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802392:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802394:	89 d0                	mov    %edx,%eax
  802396:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802398:	83 c4 20             	add    $0x20,%esp
  80239b:	5e                   	pop    %esi
  80239c:	5f                   	pop    %edi
  80239d:	5d                   	pop    %ebp
  80239e:	c3                   	ret    
  80239f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8023a0:	39 f5                	cmp    %esi,%ebp
  8023a2:	0f 87 ac 00 00 00    	ja     802454 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8023a8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8023ab:	83 f0 1f             	xor    $0x1f,%eax
  8023ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023b2:	0f 84 a8 00 00 00    	je     802460 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8023b8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023bc:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023be:	bf 20 00 00 00       	mov    $0x20,%edi
  8023c3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8023c7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023cb:	89 f9                	mov    %edi,%ecx
  8023cd:	d3 e8                	shr    %cl,%eax
  8023cf:	09 e8                	or     %ebp,%eax
  8023d1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8023d5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023d9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023dd:	d3 e0                	shl    %cl,%eax
  8023df:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023e3:	89 f2                	mov    %esi,%edx
  8023e5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8023e7:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023eb:	d3 e0                	shl    %cl,%eax
  8023ed:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023f1:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023f5:	89 f9                	mov    %edi,%ecx
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8023fb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023fd:	89 f2                	mov    %esi,%edx
  8023ff:	f7 74 24 18          	divl   0x18(%esp)
  802403:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802405:	f7 64 24 0c          	mull   0xc(%esp)
  802409:	89 c5                	mov    %eax,%ebp
  80240b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80240d:	39 d6                	cmp    %edx,%esi
  80240f:	72 67                	jb     802478 <__umoddi3+0x114>
  802411:	74 75                	je     802488 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802413:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802417:	29 e8                	sub    %ebp,%eax
  802419:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80241b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80241f:	d3 e8                	shr    %cl,%eax
  802421:	89 f2                	mov    %esi,%edx
  802423:	89 f9                	mov    %edi,%ecx
  802425:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802427:	09 d0                	or     %edx,%eax
  802429:	89 f2                	mov    %esi,%edx
  80242b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80242f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802431:	83 c4 20             	add    $0x20,%esp
  802434:	5e                   	pop    %esi
  802435:	5f                   	pop    %edi
  802436:	5d                   	pop    %ebp
  802437:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802438:	85 c9                	test   %ecx,%ecx
  80243a:	75 0b                	jne    802447 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80243c:	b8 01 00 00 00       	mov    $0x1,%eax
  802441:	31 d2                	xor    %edx,%edx
  802443:	f7 f1                	div    %ecx
  802445:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802447:	89 f0                	mov    %esi,%eax
  802449:	31 d2                	xor    %edx,%edx
  80244b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80244d:	89 f8                	mov    %edi,%eax
  80244f:	e9 3e ff ff ff       	jmp    802392 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802454:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802456:	83 c4 20             	add    $0x20,%esp
  802459:	5e                   	pop    %esi
  80245a:	5f                   	pop    %edi
  80245b:	5d                   	pop    %ebp
  80245c:	c3                   	ret    
  80245d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802460:	39 f5                	cmp    %esi,%ebp
  802462:	72 04                	jb     802468 <__umoddi3+0x104>
  802464:	39 f9                	cmp    %edi,%ecx
  802466:	77 06                	ja     80246e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802468:	89 f2                	mov    %esi,%edx
  80246a:	29 cf                	sub    %ecx,%edi
  80246c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80246e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802470:	83 c4 20             	add    $0x20,%esp
  802473:	5e                   	pop    %esi
  802474:	5f                   	pop    %edi
  802475:	5d                   	pop    %ebp
  802476:	c3                   	ret    
  802477:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802478:	89 d1                	mov    %edx,%ecx
  80247a:	89 c5                	mov    %eax,%ebp
  80247c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802480:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802484:	eb 8d                	jmp    802413 <__umoddi3+0xaf>
  802486:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802488:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80248c:	72 ea                	jb     802478 <__umoddi3+0x114>
  80248e:	89 f1                	mov    %esi,%ecx
  802490:	eb 81                	jmp    802413 <__umoddi3+0xaf>
