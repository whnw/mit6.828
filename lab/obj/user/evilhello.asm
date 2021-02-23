
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800049:	e8 72 00 00 00       	call   8000c0 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	56                   	push   %esi
  800054:	53                   	push   %ebx
  800055:	83 ec 10             	sub    $0x10,%esp
  800058:	8b 75 08             	mov    0x8(%ebp),%esi
  80005b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80005e:	e8 ec 00 00 00       	call   80014f <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80006f:	c1 e0 07             	shl    $0x7,%eax
  800072:	29 d0                	sub    %edx,%eax
  800074:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800079:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007e:	85 f6                	test   %esi,%esi
  800080:	7e 07                	jle    800089 <libmain+0x39>
		binaryname = argv[0];
  800082:	8b 03                	mov    (%ebx),%eax
  800084:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800089:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008d:	89 34 24             	mov    %esi,(%esp)
  800090:	e8 9f ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	5b                   	pop    %ebx
  80009e:	5e                   	pop    %esi
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    
  8000a1:	00 00                	add    %al,(%eax)
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000aa:	e8 90 05 00 00       	call   80063f <close_all>
	sys_env_destroy(0);
  8000af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b6:	e8 42 00 00 00       	call   8000fd <sys_env_destroy>
}
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    
  8000bd:	00 00                	add    %al,(%eax)
	...

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d1:	89 c3                	mov    %eax,%ebx
  8000d3:	89 c7                	mov    %eax,%edi
  8000d5:	89 c6                	mov    %eax,%esi
  8000d7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <sys_cgetc>:

int
sys_cgetc(void)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	57                   	push   %edi
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ee:	89 d1                	mov    %edx,%ecx
  8000f0:	89 d3                	mov    %edx,%ebx
  8000f2:	89 d7                	mov    %edx,%edi
  8000f4:	89 d6                	mov    %edx,%esi
  8000f6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    

008000fd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	57                   	push   %edi
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800106:	b9 00 00 00 00       	mov    $0x0,%ecx
  80010b:	b8 03 00 00 00       	mov    $0x3,%eax
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	89 cb                	mov    %ecx,%ebx
  800115:	89 cf                	mov    %ecx,%edi
  800117:	89 ce                	mov    %ecx,%esi
  800119:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80011b:	85 c0                	test   %eax,%eax
  80011d:	7e 28                	jle    800147 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80011f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800123:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80012a:	00 
  80012b:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  800132:	00 
  800133:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80013a:	00 
  80013b:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  800142:	e8 b5 15 00 00       	call   8016fc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800147:	83 c4 2c             	add    $0x2c,%esp
  80014a:	5b                   	pop    %ebx
  80014b:	5e                   	pop    %esi
  80014c:	5f                   	pop    %edi
  80014d:	5d                   	pop    %ebp
  80014e:	c3                   	ret    

0080014f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800155:	ba 00 00 00 00       	mov    $0x0,%edx
  80015a:	b8 02 00 00 00       	mov    $0x2,%eax
  80015f:	89 d1                	mov    %edx,%ecx
  800161:	89 d3                	mov    %edx,%ebx
  800163:	89 d7                	mov    %edx,%edi
  800165:	89 d6                	mov    %edx,%esi
  800167:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800169:	5b                   	pop    %ebx
  80016a:	5e                   	pop    %esi
  80016b:	5f                   	pop    %edi
  80016c:	5d                   	pop    %ebp
  80016d:	c3                   	ret    

0080016e <sys_yield>:

void
sys_yield(void)
{
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	57                   	push   %edi
  800172:	56                   	push   %esi
  800173:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800174:	ba 00 00 00 00       	mov    $0x0,%edx
  800179:	b8 0b 00 00 00       	mov    $0xb,%eax
  80017e:	89 d1                	mov    %edx,%ecx
  800180:	89 d3                	mov    %edx,%ebx
  800182:	89 d7                	mov    %edx,%edi
  800184:	89 d6                	mov    %edx,%esi
  800186:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800188:	5b                   	pop    %ebx
  800189:	5e                   	pop    %esi
  80018a:	5f                   	pop    %edi
  80018b:	5d                   	pop    %ebp
  80018c:	c3                   	ret    

0080018d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	57                   	push   %edi
  800191:	56                   	push   %esi
  800192:	53                   	push   %ebx
  800193:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800196:	be 00 00 00 00       	mov    $0x0,%esi
  80019b:	b8 04 00 00 00       	mov    $0x4,%eax
  8001a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	89 f7                	mov    %esi,%edi
  8001ab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001ad:	85 c0                	test   %eax,%eax
  8001af:	7e 28                	jle    8001d9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001b5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001bc:	00 
  8001bd:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  8001c4:	00 
  8001c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001cc:	00 
  8001cd:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  8001d4:	e8 23 15 00 00       	call   8016fc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001d9:	83 c4 2c             	add    $0x2c,%esp
  8001dc:	5b                   	pop    %ebx
  8001dd:	5e                   	pop    %esi
  8001de:	5f                   	pop    %edi
  8001df:	5d                   	pop    %ebp
  8001e0:	c3                   	ret    

008001e1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	57                   	push   %edi
  8001e5:	56                   	push   %esi
  8001e6:	53                   	push   %ebx
  8001e7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ef:	8b 75 18             	mov    0x18(%ebp),%esi
  8001f2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800200:	85 c0                	test   %eax,%eax
  800202:	7e 28                	jle    80022c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800204:	89 44 24 10          	mov    %eax,0x10(%esp)
  800208:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80020f:	00 
  800210:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  800217:	00 
  800218:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80021f:	00 
  800220:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  800227:	e8 d0 14 00 00       	call   8016fc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80022c:	83 c4 2c             	add    $0x2c,%esp
  80022f:	5b                   	pop    %ebx
  800230:	5e                   	pop    %esi
  800231:	5f                   	pop    %edi
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    

00800234 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	57                   	push   %edi
  800238:	56                   	push   %esi
  800239:	53                   	push   %ebx
  80023a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800242:	b8 06 00 00 00       	mov    $0x6,%eax
  800247:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024a:	8b 55 08             	mov    0x8(%ebp),%edx
  80024d:	89 df                	mov    %ebx,%edi
  80024f:	89 de                	mov    %ebx,%esi
  800251:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800253:	85 c0                	test   %eax,%eax
  800255:	7e 28                	jle    80027f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800257:	89 44 24 10          	mov    %eax,0x10(%esp)
  80025b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800262:	00 
  800263:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  80026a:	00 
  80026b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800272:	00 
  800273:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  80027a:	e8 7d 14 00 00       	call   8016fc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80027f:	83 c4 2c             	add    $0x2c,%esp
  800282:	5b                   	pop    %ebx
  800283:	5e                   	pop    %esi
  800284:	5f                   	pop    %edi
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	57                   	push   %edi
  80028b:	56                   	push   %esi
  80028c:	53                   	push   %ebx
  80028d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800290:	bb 00 00 00 00       	mov    $0x0,%ebx
  800295:	b8 08 00 00 00       	mov    $0x8,%eax
  80029a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029d:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a0:	89 df                	mov    %ebx,%edi
  8002a2:	89 de                	mov    %ebx,%esi
  8002a4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a6:	85 c0                	test   %eax,%eax
  8002a8:	7e 28                	jle    8002d2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ae:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  8002bd:	00 
  8002be:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c5:	00 
  8002c6:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  8002cd:	e8 2a 14 00 00       	call   8016fc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002d2:	83 c4 2c             	add    $0x2c,%esp
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5f                   	pop    %edi
  8002d8:	5d                   	pop    %ebp
  8002d9:	c3                   	ret    

008002da <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	57                   	push   %edi
  8002de:	56                   	push   %esi
  8002df:	53                   	push   %ebx
  8002e0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e8:	b8 09 00 00 00       	mov    $0x9,%eax
  8002ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f3:	89 df                	mov    %ebx,%edi
  8002f5:	89 de                	mov    %ebx,%esi
  8002f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002f9:	85 c0                	test   %eax,%eax
  8002fb:	7e 28                	jle    800325 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800301:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800308:	00 
  800309:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  800310:	00 
  800311:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800318:	00 
  800319:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  800320:	e8 d7 13 00 00       	call   8016fc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800325:	83 c4 2c             	add    $0x2c,%esp
  800328:	5b                   	pop    %ebx
  800329:	5e                   	pop    %esi
  80032a:	5f                   	pop    %edi
  80032b:	5d                   	pop    %ebp
  80032c:	c3                   	ret    

0080032d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	57                   	push   %edi
  800331:	56                   	push   %esi
  800332:	53                   	push   %ebx
  800333:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800336:	bb 00 00 00 00       	mov    $0x0,%ebx
  80033b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800340:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800343:	8b 55 08             	mov    0x8(%ebp),%edx
  800346:	89 df                	mov    %ebx,%edi
  800348:	89 de                	mov    %ebx,%esi
  80034a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80034c:	85 c0                	test   %eax,%eax
  80034e:	7e 28                	jle    800378 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800350:	89 44 24 10          	mov    %eax,0x10(%esp)
  800354:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80035b:	00 
  80035c:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  800363:	00 
  800364:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80036b:	00 
  80036c:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  800373:	e8 84 13 00 00       	call   8016fc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800378:	83 c4 2c             	add    $0x2c,%esp
  80037b:	5b                   	pop    %ebx
  80037c:	5e                   	pop    %esi
  80037d:	5f                   	pop    %edi
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	57                   	push   %edi
  800384:	56                   	push   %esi
  800385:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800386:	be 00 00 00 00       	mov    $0x0,%esi
  80038b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800390:	8b 7d 14             	mov    0x14(%ebp),%edi
  800393:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800396:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800399:	8b 55 08             	mov    0x8(%ebp),%edx
  80039c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80039e:	5b                   	pop    %ebx
  80039f:	5e                   	pop    %esi
  8003a0:	5f                   	pop    %edi
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	57                   	push   %edi
  8003a7:	56                   	push   %esi
  8003a8:	53                   	push   %ebx
  8003a9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b9:	89 cb                	mov    %ecx,%ebx
  8003bb:	89 cf                	mov    %ecx,%edi
  8003bd:	89 ce                	mov    %ecx,%esi
  8003bf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003c1:	85 c0                	test   %eax,%eax
  8003c3:	7e 28                	jle    8003ed <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003c9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003d0:	00 
  8003d1:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  8003d8:	00 
  8003d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003e0:	00 
  8003e1:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  8003e8:	e8 0f 13 00 00       	call   8016fc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003ed:	83 c4 2c             	add    $0x2c,%esp
  8003f0:	5b                   	pop    %ebx
  8003f1:	5e                   	pop    %esi
  8003f2:	5f                   	pop    %edi
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    

008003f5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	57                   	push   %edi
  8003f9:	56                   	push   %esi
  8003fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800400:	b8 0e 00 00 00       	mov    $0xe,%eax
  800405:	89 d1                	mov    %edx,%ecx
  800407:	89 d3                	mov    %edx,%ebx
  800409:	89 d7                	mov    %edx,%edi
  80040b:	89 d6                	mov    %edx,%esi
  80040d:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80040f:	5b                   	pop    %ebx
  800410:	5e                   	pop    %esi
  800411:	5f                   	pop    %edi
  800412:	5d                   	pop    %ebp
  800413:	c3                   	ret    

00800414 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	57                   	push   %edi
  800418:	56                   	push   %esi
  800419:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80041a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800424:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800427:	8b 55 08             	mov    0x8(%ebp),%edx
  80042a:	89 df                	mov    %ebx,%edi
  80042c:	89 de                	mov    %ebx,%esi
  80042e:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800430:	5b                   	pop    %ebx
  800431:	5e                   	pop    %esi
  800432:	5f                   	pop    %edi
  800433:	5d                   	pop    %ebp
  800434:	c3                   	ret    

00800435 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
  800438:	57                   	push   %edi
  800439:	56                   	push   %esi
  80043a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80043b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800440:	b8 10 00 00 00       	mov    $0x10,%eax
  800445:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800448:	8b 55 08             	mov    0x8(%ebp),%edx
  80044b:	89 df                	mov    %ebx,%edi
  80044d:	89 de                	mov    %ebx,%esi
  80044f:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800451:	5b                   	pop    %ebx
  800452:	5e                   	pop    %esi
  800453:	5f                   	pop    %edi
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    
	...

00800458 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800458:	55                   	push   %ebp
  800459:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80045b:	8b 45 08             	mov    0x8(%ebp),%eax
  80045e:	05 00 00 00 30       	add    $0x30000000,%eax
  800463:	c1 e8 0c             	shr    $0xc,%eax
}
  800466:	5d                   	pop    %ebp
  800467:	c3                   	ret    

00800468 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80046e:	8b 45 08             	mov    0x8(%ebp),%eax
  800471:	89 04 24             	mov    %eax,(%esp)
  800474:	e8 df ff ff ff       	call   800458 <fd2num>
  800479:	c1 e0 0c             	shl    $0xc,%eax
  80047c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800481:	c9                   	leave  
  800482:	c3                   	ret    

00800483 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800483:	55                   	push   %ebp
  800484:	89 e5                	mov    %esp,%ebp
  800486:	53                   	push   %ebx
  800487:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80048a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80048f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800491:	89 c2                	mov    %eax,%edx
  800493:	c1 ea 16             	shr    $0x16,%edx
  800496:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80049d:	f6 c2 01             	test   $0x1,%dl
  8004a0:	74 11                	je     8004b3 <fd_alloc+0x30>
  8004a2:	89 c2                	mov    %eax,%edx
  8004a4:	c1 ea 0c             	shr    $0xc,%edx
  8004a7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004ae:	f6 c2 01             	test   $0x1,%dl
  8004b1:	75 09                	jne    8004bc <fd_alloc+0x39>
			*fd_store = fd;
  8004b3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8004b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ba:	eb 17                	jmp    8004d3 <fd_alloc+0x50>
  8004bc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8004c1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8004c6:	75 c7                	jne    80048f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8004c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8004ce:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8004d3:	5b                   	pop    %ebx
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    

008004d6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004d6:	55                   	push   %ebp
  8004d7:	89 e5                	mov    %esp,%ebp
  8004d9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004dc:	83 f8 1f             	cmp    $0x1f,%eax
  8004df:	77 36                	ja     800517 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004e1:	c1 e0 0c             	shl    $0xc,%eax
  8004e4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004e9:	89 c2                	mov    %eax,%edx
  8004eb:	c1 ea 16             	shr    $0x16,%edx
  8004ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004f5:	f6 c2 01             	test   $0x1,%dl
  8004f8:	74 24                	je     80051e <fd_lookup+0x48>
  8004fa:	89 c2                	mov    %eax,%edx
  8004fc:	c1 ea 0c             	shr    $0xc,%edx
  8004ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800506:	f6 c2 01             	test   $0x1,%dl
  800509:	74 1a                	je     800525 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80050b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80050e:	89 02                	mov    %eax,(%edx)
	return 0;
  800510:	b8 00 00 00 00       	mov    $0x0,%eax
  800515:	eb 13                	jmp    80052a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800517:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80051c:	eb 0c                	jmp    80052a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80051e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800523:	eb 05                	jmp    80052a <fd_lookup+0x54>
  800525:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80052a:	5d                   	pop    %ebp
  80052b:	c3                   	ret    

0080052c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80052c:	55                   	push   %ebp
  80052d:	89 e5                	mov    %esp,%ebp
  80052f:	53                   	push   %ebx
  800530:	83 ec 14             	sub    $0x14,%esp
  800533:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800536:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800539:	ba 00 00 00 00       	mov    $0x0,%edx
  80053e:	eb 0e                	jmp    80054e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800540:	39 08                	cmp    %ecx,(%eax)
  800542:	75 09                	jne    80054d <dev_lookup+0x21>
			*dev = devtab[i];
  800544:	89 03                	mov    %eax,(%ebx)
			return 0;
  800546:	b8 00 00 00 00       	mov    $0x0,%eax
  80054b:	eb 33                	jmp    800580 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80054d:	42                   	inc    %edx
  80054e:	8b 04 95 54 25 80 00 	mov    0x802554(,%edx,4),%eax
  800555:	85 c0                	test   %eax,%eax
  800557:	75 e7                	jne    800540 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800559:	a1 08 40 80 00       	mov    0x804008,%eax
  80055e:	8b 40 48             	mov    0x48(%eax),%eax
  800561:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800565:	89 44 24 04          	mov    %eax,0x4(%esp)
  800569:	c7 04 24 d8 24 80 00 	movl   $0x8024d8,(%esp)
  800570:	e8 7f 12 00 00       	call   8017f4 <cprintf>
	*dev = 0;
  800575:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80057b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800580:	83 c4 14             	add    $0x14,%esp
  800583:	5b                   	pop    %ebx
  800584:	5d                   	pop    %ebp
  800585:	c3                   	ret    

00800586 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800586:	55                   	push   %ebp
  800587:	89 e5                	mov    %esp,%ebp
  800589:	56                   	push   %esi
  80058a:	53                   	push   %ebx
  80058b:	83 ec 30             	sub    $0x30,%esp
  80058e:	8b 75 08             	mov    0x8(%ebp),%esi
  800591:	8a 45 0c             	mov    0xc(%ebp),%al
  800594:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800597:	89 34 24             	mov    %esi,(%esp)
  80059a:	e8 b9 fe ff ff       	call   800458 <fd2num>
  80059f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8005a2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005a6:	89 04 24             	mov    %eax,(%esp)
  8005a9:	e8 28 ff ff ff       	call   8004d6 <fd_lookup>
  8005ae:	89 c3                	mov    %eax,%ebx
  8005b0:	85 c0                	test   %eax,%eax
  8005b2:	78 05                	js     8005b9 <fd_close+0x33>
	    || fd != fd2)
  8005b4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8005b7:	74 0d                	je     8005c6 <fd_close+0x40>
		return (must_exist ? r : 0);
  8005b9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8005bd:	75 46                	jne    800605 <fd_close+0x7f>
  8005bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005c4:	eb 3f                	jmp    800605 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8005c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8005c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005cd:	8b 06                	mov    (%esi),%eax
  8005cf:	89 04 24             	mov    %eax,(%esp)
  8005d2:	e8 55 ff ff ff       	call   80052c <dev_lookup>
  8005d7:	89 c3                	mov    %eax,%ebx
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	78 18                	js     8005f5 <fd_close+0x6f>
		if (dev->dev_close)
  8005dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005e0:	8b 40 10             	mov    0x10(%eax),%eax
  8005e3:	85 c0                	test   %eax,%eax
  8005e5:	74 09                	je     8005f0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005e7:	89 34 24             	mov    %esi,(%esp)
  8005ea:	ff d0                	call   *%eax
  8005ec:	89 c3                	mov    %eax,%ebx
  8005ee:	eb 05                	jmp    8005f5 <fd_close+0x6f>
		else
			r = 0;
  8005f0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800600:	e8 2f fc ff ff       	call   800234 <sys_page_unmap>
	return r;
}
  800605:	89 d8                	mov    %ebx,%eax
  800607:	83 c4 30             	add    $0x30,%esp
  80060a:	5b                   	pop    %ebx
  80060b:	5e                   	pop    %esi
  80060c:	5d                   	pop    %ebp
  80060d:	c3                   	ret    

0080060e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80060e:	55                   	push   %ebp
  80060f:	89 e5                	mov    %esp,%ebp
  800611:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800614:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800617:	89 44 24 04          	mov    %eax,0x4(%esp)
  80061b:	8b 45 08             	mov    0x8(%ebp),%eax
  80061e:	89 04 24             	mov    %eax,(%esp)
  800621:	e8 b0 fe ff ff       	call   8004d6 <fd_lookup>
  800626:	85 c0                	test   %eax,%eax
  800628:	78 13                	js     80063d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80062a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800631:	00 
  800632:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800635:	89 04 24             	mov    %eax,(%esp)
  800638:	e8 49 ff ff ff       	call   800586 <fd_close>
}
  80063d:	c9                   	leave  
  80063e:	c3                   	ret    

0080063f <close_all>:

void
close_all(void)
{
  80063f:	55                   	push   %ebp
  800640:	89 e5                	mov    %esp,%ebp
  800642:	53                   	push   %ebx
  800643:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800646:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80064b:	89 1c 24             	mov    %ebx,(%esp)
  80064e:	e8 bb ff ff ff       	call   80060e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800653:	43                   	inc    %ebx
  800654:	83 fb 20             	cmp    $0x20,%ebx
  800657:	75 f2                	jne    80064b <close_all+0xc>
		close(i);
}
  800659:	83 c4 14             	add    $0x14,%esp
  80065c:	5b                   	pop    %ebx
  80065d:	5d                   	pop    %ebp
  80065e:	c3                   	ret    

0080065f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80065f:	55                   	push   %ebp
  800660:	89 e5                	mov    %esp,%ebp
  800662:	57                   	push   %edi
  800663:	56                   	push   %esi
  800664:	53                   	push   %ebx
  800665:	83 ec 4c             	sub    $0x4c,%esp
  800668:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80066b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80066e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800672:	8b 45 08             	mov    0x8(%ebp),%eax
  800675:	89 04 24             	mov    %eax,(%esp)
  800678:	e8 59 fe ff ff       	call   8004d6 <fd_lookup>
  80067d:	89 c3                	mov    %eax,%ebx
  80067f:	85 c0                	test   %eax,%eax
  800681:	0f 88 e3 00 00 00    	js     80076a <dup+0x10b>
		return r;
	close(newfdnum);
  800687:	89 3c 24             	mov    %edi,(%esp)
  80068a:	e8 7f ff ff ff       	call   80060e <close>

	newfd = INDEX2FD(newfdnum);
  80068f:	89 fe                	mov    %edi,%esi
  800691:	c1 e6 0c             	shl    $0xc,%esi
  800694:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80069a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80069d:	89 04 24             	mov    %eax,(%esp)
  8006a0:	e8 c3 fd ff ff       	call   800468 <fd2data>
  8006a5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8006a7:	89 34 24             	mov    %esi,(%esp)
  8006aa:	e8 b9 fd ff ff       	call   800468 <fd2data>
  8006af:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8006b2:	89 d8                	mov    %ebx,%eax
  8006b4:	c1 e8 16             	shr    $0x16,%eax
  8006b7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8006be:	a8 01                	test   $0x1,%al
  8006c0:	74 46                	je     800708 <dup+0xa9>
  8006c2:	89 d8                	mov    %ebx,%eax
  8006c4:	c1 e8 0c             	shr    $0xc,%eax
  8006c7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8006ce:	f6 c2 01             	test   $0x1,%dl
  8006d1:	74 35                	je     800708 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8006d3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006da:	25 07 0e 00 00       	and    $0xe07,%eax
  8006df:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006ea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006f1:	00 
  8006f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006fd:	e8 df fa ff ff       	call   8001e1 <sys_page_map>
  800702:	89 c3                	mov    %eax,%ebx
  800704:	85 c0                	test   %eax,%eax
  800706:	78 3b                	js     800743 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800708:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80070b:	89 c2                	mov    %eax,%edx
  80070d:	c1 ea 0c             	shr    $0xc,%edx
  800710:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800717:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80071d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800721:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800725:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80072c:	00 
  80072d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800731:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800738:	e8 a4 fa ff ff       	call   8001e1 <sys_page_map>
  80073d:	89 c3                	mov    %eax,%ebx
  80073f:	85 c0                	test   %eax,%eax
  800741:	79 25                	jns    800768 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800743:	89 74 24 04          	mov    %esi,0x4(%esp)
  800747:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80074e:	e8 e1 fa ff ff       	call   800234 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800753:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800756:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800761:	e8 ce fa ff ff       	call   800234 <sys_page_unmap>
	return r;
  800766:	eb 02                	jmp    80076a <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800768:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80076a:	89 d8                	mov    %ebx,%eax
  80076c:	83 c4 4c             	add    $0x4c,%esp
  80076f:	5b                   	pop    %ebx
  800770:	5e                   	pop    %esi
  800771:	5f                   	pop    %edi
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	53                   	push   %ebx
  800778:	83 ec 24             	sub    $0x24,%esp
  80077b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80077e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800781:	89 44 24 04          	mov    %eax,0x4(%esp)
  800785:	89 1c 24             	mov    %ebx,(%esp)
  800788:	e8 49 fd ff ff       	call   8004d6 <fd_lookup>
  80078d:	85 c0                	test   %eax,%eax
  80078f:	78 6d                	js     8007fe <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800791:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800794:	89 44 24 04          	mov    %eax,0x4(%esp)
  800798:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80079b:	8b 00                	mov    (%eax),%eax
  80079d:	89 04 24             	mov    %eax,(%esp)
  8007a0:	e8 87 fd ff ff       	call   80052c <dev_lookup>
  8007a5:	85 c0                	test   %eax,%eax
  8007a7:	78 55                	js     8007fe <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8007a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ac:	8b 50 08             	mov    0x8(%eax),%edx
  8007af:	83 e2 03             	and    $0x3,%edx
  8007b2:	83 fa 01             	cmp    $0x1,%edx
  8007b5:	75 23                	jne    8007da <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8007b7:	a1 08 40 80 00       	mov    0x804008,%eax
  8007bc:	8b 40 48             	mov    0x48(%eax),%eax
  8007bf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c7:	c7 04 24 19 25 80 00 	movl   $0x802519,(%esp)
  8007ce:	e8 21 10 00 00       	call   8017f4 <cprintf>
		return -E_INVAL;
  8007d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d8:	eb 24                	jmp    8007fe <read+0x8a>
	}
	if (!dev->dev_read)
  8007da:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007dd:	8b 52 08             	mov    0x8(%edx),%edx
  8007e0:	85 d2                	test   %edx,%edx
  8007e2:	74 15                	je     8007f9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8007e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007e7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007ee:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007f2:	89 04 24             	mov    %eax,(%esp)
  8007f5:	ff d2                	call   *%edx
  8007f7:	eb 05                	jmp    8007fe <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8007f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8007fe:	83 c4 24             	add    $0x24,%esp
  800801:	5b                   	pop    %ebx
  800802:	5d                   	pop    %ebp
  800803:	c3                   	ret    

00800804 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	57                   	push   %edi
  800808:	56                   	push   %esi
  800809:	53                   	push   %ebx
  80080a:	83 ec 1c             	sub    $0x1c,%esp
  80080d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800810:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800813:	bb 00 00 00 00       	mov    $0x0,%ebx
  800818:	eb 23                	jmp    80083d <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80081a:	89 f0                	mov    %esi,%eax
  80081c:	29 d8                	sub    %ebx,%eax
  80081e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800822:	8b 45 0c             	mov    0xc(%ebp),%eax
  800825:	01 d8                	add    %ebx,%eax
  800827:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082b:	89 3c 24             	mov    %edi,(%esp)
  80082e:	e8 41 ff ff ff       	call   800774 <read>
		if (m < 0)
  800833:	85 c0                	test   %eax,%eax
  800835:	78 10                	js     800847 <readn+0x43>
			return m;
		if (m == 0)
  800837:	85 c0                	test   %eax,%eax
  800839:	74 0a                	je     800845 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80083b:	01 c3                	add    %eax,%ebx
  80083d:	39 f3                	cmp    %esi,%ebx
  80083f:	72 d9                	jb     80081a <readn+0x16>
  800841:	89 d8                	mov    %ebx,%eax
  800843:	eb 02                	jmp    800847 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800845:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800847:	83 c4 1c             	add    $0x1c,%esp
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5f                   	pop    %edi
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	83 ec 24             	sub    $0x24,%esp
  800856:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800860:	89 1c 24             	mov    %ebx,(%esp)
  800863:	e8 6e fc ff ff       	call   8004d6 <fd_lookup>
  800868:	85 c0                	test   %eax,%eax
  80086a:	78 68                	js     8008d4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800873:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800876:	8b 00                	mov    (%eax),%eax
  800878:	89 04 24             	mov    %eax,(%esp)
  80087b:	e8 ac fc ff ff       	call   80052c <dev_lookup>
  800880:	85 c0                	test   %eax,%eax
  800882:	78 50                	js     8008d4 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800884:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800887:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80088b:	75 23                	jne    8008b0 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80088d:	a1 08 40 80 00       	mov    0x804008,%eax
  800892:	8b 40 48             	mov    0x48(%eax),%eax
  800895:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800899:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089d:	c7 04 24 35 25 80 00 	movl   $0x802535,(%esp)
  8008a4:	e8 4b 0f 00 00       	call   8017f4 <cprintf>
		return -E_INVAL;
  8008a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ae:	eb 24                	jmp    8008d4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8008b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008b3:	8b 52 0c             	mov    0xc(%edx),%edx
  8008b6:	85 d2                	test   %edx,%edx
  8008b8:	74 15                	je     8008cf <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8008ba:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008c8:	89 04 24             	mov    %eax,(%esp)
  8008cb:	ff d2                	call   *%edx
  8008cd:	eb 05                	jmp    8008d4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8008cf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8008d4:	83 c4 24             	add    $0x24,%esp
  8008d7:	5b                   	pop    %ebx
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <seek>:

int
seek(int fdnum, off_t offset)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008e0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8008e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ea:	89 04 24             	mov    %eax,(%esp)
  8008ed:	e8 e4 fb ff ff       	call   8004d6 <fd_lookup>
  8008f2:	85 c0                	test   %eax,%eax
  8008f4:	78 0e                	js     800904 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008fc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800904:	c9                   	leave  
  800905:	c3                   	ret    

00800906 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	53                   	push   %ebx
  80090a:	83 ec 24             	sub    $0x24,%esp
  80090d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800910:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800913:	89 44 24 04          	mov    %eax,0x4(%esp)
  800917:	89 1c 24             	mov    %ebx,(%esp)
  80091a:	e8 b7 fb ff ff       	call   8004d6 <fd_lookup>
  80091f:	85 c0                	test   %eax,%eax
  800921:	78 61                	js     800984 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800923:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80092d:	8b 00                	mov    (%eax),%eax
  80092f:	89 04 24             	mov    %eax,(%esp)
  800932:	e8 f5 fb ff ff       	call   80052c <dev_lookup>
  800937:	85 c0                	test   %eax,%eax
  800939:	78 49                	js     800984 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80093b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80093e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800942:	75 23                	jne    800967 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800944:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800949:	8b 40 48             	mov    0x48(%eax),%eax
  80094c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800950:	89 44 24 04          	mov    %eax,0x4(%esp)
  800954:	c7 04 24 f8 24 80 00 	movl   $0x8024f8,(%esp)
  80095b:	e8 94 0e 00 00       	call   8017f4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800960:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800965:	eb 1d                	jmp    800984 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800967:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80096a:	8b 52 18             	mov    0x18(%edx),%edx
  80096d:	85 d2                	test   %edx,%edx
  80096f:	74 0e                	je     80097f <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800971:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800974:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800978:	89 04 24             	mov    %eax,(%esp)
  80097b:	ff d2                	call   *%edx
  80097d:	eb 05                	jmp    800984 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80097f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800984:	83 c4 24             	add    $0x24,%esp
  800987:	5b                   	pop    %ebx
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	53                   	push   %ebx
  80098e:	83 ec 24             	sub    $0x24,%esp
  800991:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800994:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	89 04 24             	mov    %eax,(%esp)
  8009a1:	e8 30 fb ff ff       	call   8004d6 <fd_lookup>
  8009a6:	85 c0                	test   %eax,%eax
  8009a8:	78 52                	js     8009fc <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8009aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b4:	8b 00                	mov    (%eax),%eax
  8009b6:	89 04 24             	mov    %eax,(%esp)
  8009b9:	e8 6e fb ff ff       	call   80052c <dev_lookup>
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 3a                	js     8009fc <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8009c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8009c9:	74 2c                	je     8009f7 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8009cb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8009ce:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8009d5:	00 00 00 
	stat->st_isdir = 0;
  8009d8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8009df:	00 00 00 
	stat->st_dev = dev;
  8009e2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009ef:	89 14 24             	mov    %edx,(%esp)
  8009f2:	ff 50 14             	call   *0x14(%eax)
  8009f5:	eb 05                	jmp    8009fc <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8009f7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8009fc:	83 c4 24             	add    $0x24,%esp
  8009ff:	5b                   	pop    %ebx
  800a00:	5d                   	pop    %ebp
  800a01:	c3                   	ret    

00800a02 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800a0a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a11:	00 
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	89 04 24             	mov    %eax,(%esp)
  800a18:	e8 2a 02 00 00       	call   800c47 <open>
  800a1d:	89 c3                	mov    %eax,%ebx
  800a1f:	85 c0                	test   %eax,%eax
  800a21:	78 1b                	js     800a3e <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800a23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2a:	89 1c 24             	mov    %ebx,(%esp)
  800a2d:	e8 58 ff ff ff       	call   80098a <fstat>
  800a32:	89 c6                	mov    %eax,%esi
	close(fd);
  800a34:	89 1c 24             	mov    %ebx,(%esp)
  800a37:	e8 d2 fb ff ff       	call   80060e <close>
	return r;
  800a3c:	89 f3                	mov    %esi,%ebx
}
  800a3e:	89 d8                	mov    %ebx,%eax
  800a40:	83 c4 10             	add    $0x10,%esp
  800a43:	5b                   	pop    %ebx
  800a44:	5e                   	pop    %esi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    
	...

00800a48 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	56                   	push   %esi
  800a4c:	53                   	push   %ebx
  800a4d:	83 ec 10             	sub    $0x10,%esp
  800a50:	89 c3                	mov    %eax,%ebx
  800a52:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a54:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a5b:	75 11                	jne    800a6e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a64:	e8 4e 17 00 00       	call   8021b7 <ipc_find_env>
  800a69:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a6e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a75:	00 
  800a76:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a7d:	00 
  800a7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a82:	a1 00 40 80 00       	mov    0x804000,%eax
  800a87:	89 04 24             	mov    %eax,(%esp)
  800a8a:	e8 a5 16 00 00       	call   802134 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a8f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a96:	00 
  800a97:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800aa2:	e8 1d 16 00 00       	call   8020c4 <ipc_recv>
}
  800aa7:	83 c4 10             	add    $0x10,%esp
  800aaa:	5b                   	pop    %ebx
  800aab:	5e                   	pop    %esi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8b 40 0c             	mov    0xc(%eax),%eax
  800aba:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800ac7:	ba 00 00 00 00       	mov    $0x0,%edx
  800acc:	b8 02 00 00 00       	mov    $0x2,%eax
  800ad1:	e8 72 ff ff ff       	call   800a48 <fsipc>
}
  800ad6:	c9                   	leave  
  800ad7:	c3                   	ret    

00800ad8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae1:	8b 40 0c             	mov    0xc(%eax),%eax
  800ae4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ae9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aee:	b8 06 00 00 00       	mov    $0x6,%eax
  800af3:	e8 50 ff ff ff       	call   800a48 <fsipc>
}
  800af8:	c9                   	leave  
  800af9:	c3                   	ret    

00800afa <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	53                   	push   %ebx
  800afe:	83 ec 14             	sub    $0x14,%esp
  800b01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	8b 40 0c             	mov    0xc(%eax),%eax
  800b0a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800b0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b14:	b8 05 00 00 00       	mov    $0x5,%eax
  800b19:	e8 2a ff ff ff       	call   800a48 <fsipc>
  800b1e:	85 c0                	test   %eax,%eax
  800b20:	78 2b                	js     800b4d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800b22:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b29:	00 
  800b2a:	89 1c 24             	mov    %ebx,(%esp)
  800b2d:	e8 6d 12 00 00       	call   801d9f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b32:	a1 80 50 80 00       	mov    0x805080,%eax
  800b37:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b3d:	a1 84 50 80 00       	mov    0x805084,%eax
  800b42:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800b48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b4d:	83 c4 14             	add    $0x14,%esp
  800b50:	5b                   	pop    %ebx
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	83 ec 18             	sub    $0x18,%esp
  800b59:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800b5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5f:	8b 52 0c             	mov    0xc(%edx),%edx
  800b62:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800b68:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  800b6d:	89 c2                	mov    %eax,%edx
  800b6f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800b74:	76 05                	jbe    800b7b <devfile_write+0x28>
  800b76:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  800b7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b82:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b86:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b8d:	e8 f0 13 00 00       	call   801f82 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800b92:	ba 00 00 00 00       	mov    $0x0,%edx
  800b97:	b8 04 00 00 00       	mov    $0x4,%eax
  800b9c:	e8 a7 fe ff ff       	call   800a48 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  800ba1:	c9                   	leave  
  800ba2:	c3                   	ret    

00800ba3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 10             	sub    $0x10,%esp
  800bab:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800bae:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb1:	8b 40 0c             	mov    0xc(%eax),%eax
  800bb4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800bb9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800bbf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc4:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc9:	e8 7a fe ff ff       	call   800a48 <fsipc>
  800bce:	89 c3                	mov    %eax,%ebx
  800bd0:	85 c0                	test   %eax,%eax
  800bd2:	78 6a                	js     800c3e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800bd4:	39 c6                	cmp    %eax,%esi
  800bd6:	73 24                	jae    800bfc <devfile_read+0x59>
  800bd8:	c7 44 24 0c 68 25 80 	movl   $0x802568,0xc(%esp)
  800bdf:	00 
  800be0:	c7 44 24 08 6f 25 80 	movl   $0x80256f,0x8(%esp)
  800be7:	00 
  800be8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800bef:	00 
  800bf0:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  800bf7:	e8 00 0b 00 00       	call   8016fc <_panic>
	assert(r <= PGSIZE);
  800bfc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800c01:	7e 24                	jle    800c27 <devfile_read+0x84>
  800c03:	c7 44 24 0c 8f 25 80 	movl   $0x80258f,0xc(%esp)
  800c0a:	00 
  800c0b:	c7 44 24 08 6f 25 80 	movl   $0x80256f,0x8(%esp)
  800c12:	00 
  800c13:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800c1a:	00 
  800c1b:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  800c22:	e8 d5 0a 00 00       	call   8016fc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c27:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c2b:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c32:	00 
  800c33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c36:	89 04 24             	mov    %eax,(%esp)
  800c39:	e8 da 12 00 00       	call   801f18 <memmove>
	return r;
}
  800c3e:	89 d8                	mov    %ebx,%eax
  800c40:	83 c4 10             	add    $0x10,%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5e                   	pop    %esi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 20             	sub    $0x20,%esp
  800c4f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c52:	89 34 24             	mov    %esi,(%esp)
  800c55:	e8 12 11 00 00       	call   801d6c <strlen>
  800c5a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c5f:	7f 60                	jg     800cc1 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c64:	89 04 24             	mov    %eax,(%esp)
  800c67:	e8 17 f8 ff ff       	call   800483 <fd_alloc>
  800c6c:	89 c3                	mov    %eax,%ebx
  800c6e:	85 c0                	test   %eax,%eax
  800c70:	78 54                	js     800cc6 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800c72:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c76:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c7d:	e8 1d 11 00 00       	call   801d9f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c85:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c8d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c92:	e8 b1 fd ff ff       	call   800a48 <fsipc>
  800c97:	89 c3                	mov    %eax,%ebx
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	79 15                	jns    800cb2 <open+0x6b>
		fd_close(fd, 0);
  800c9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ca4:	00 
  800ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca8:	89 04 24             	mov    %eax,(%esp)
  800cab:	e8 d6 f8 ff ff       	call   800586 <fd_close>
		return r;
  800cb0:	eb 14                	jmp    800cc6 <open+0x7f>
	}

	return fd2num(fd);
  800cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb5:	89 04 24             	mov    %eax,(%esp)
  800cb8:	e8 9b f7 ff ff       	call   800458 <fd2num>
  800cbd:	89 c3                	mov    %eax,%ebx
  800cbf:	eb 05                	jmp    800cc6 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cc1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800cc6:	89 d8                	mov    %ebx,%eax
  800cc8:	83 c4 20             	add    $0x20,%esp
  800ccb:	5b                   	pop    %ebx
  800ccc:	5e                   	pop    %esi
  800ccd:	5d                   	pop    %ebp
  800cce:	c3                   	ret    

00800ccf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ccf:	55                   	push   %ebp
  800cd0:	89 e5                	mov    %esp,%ebp
  800cd2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800cd5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cda:	b8 08 00 00 00       	mov    $0x8,%eax
  800cdf:	e8 64 fd ff ff       	call   800a48 <fsipc>
}
  800ce4:	c9                   	leave  
  800ce5:	c3                   	ret    
	...

00800ce8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800cee:	c7 44 24 04 9b 25 80 	movl   $0x80259b,0x4(%esp)
  800cf5:	00 
  800cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf9:	89 04 24             	mov    %eax,(%esp)
  800cfc:	e8 9e 10 00 00       	call   801d9f <strcpy>
	return 0;
}
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
  800d06:	c9                   	leave  
  800d07:	c3                   	ret    

00800d08 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 14             	sub    $0x14,%esp
  800d0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800d12:	89 1c 24             	mov    %ebx,(%esp)
  800d15:	e8 e2 14 00 00       	call   8021fc <pageref>
  800d1a:	83 f8 01             	cmp    $0x1,%eax
  800d1d:	75 0d                	jne    800d2c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  800d1f:	8b 43 0c             	mov    0xc(%ebx),%eax
  800d22:	89 04 24             	mov    %eax,(%esp)
  800d25:	e8 1f 03 00 00       	call   801049 <nsipc_close>
  800d2a:	eb 05                	jmp    800d31 <devsock_close+0x29>
	else
		return 0;
  800d2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d31:	83 c4 14             	add    $0x14,%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    

00800d37 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800d3d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d44:	00 
  800d45:	8b 45 10             	mov    0x10(%ebp),%eax
  800d48:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d53:	8b 45 08             	mov    0x8(%ebp),%eax
  800d56:	8b 40 0c             	mov    0xc(%eax),%eax
  800d59:	89 04 24             	mov    %eax,(%esp)
  800d5c:	e8 e3 03 00 00       	call   801144 <nsipc_send>
}
  800d61:	c9                   	leave  
  800d62:	c3                   	ret    

00800d63 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800d63:	55                   	push   %ebp
  800d64:	89 e5                	mov    %esp,%ebp
  800d66:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800d69:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d70:	00 
  800d71:	8b 45 10             	mov    0x10(%ebp),%eax
  800d74:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d82:	8b 40 0c             	mov    0xc(%eax),%eax
  800d85:	89 04 24             	mov    %eax,(%esp)
  800d88:	e8 37 03 00 00       	call   8010c4 <nsipc_recv>
}
  800d8d:	c9                   	leave  
  800d8e:	c3                   	ret    

00800d8f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 20             	sub    $0x20,%esp
  800d97:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800d99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d9c:	89 04 24             	mov    %eax,(%esp)
  800d9f:	e8 df f6 ff ff       	call   800483 <fd_alloc>
  800da4:	89 c3                	mov    %eax,%ebx
  800da6:	85 c0                	test   %eax,%eax
  800da8:	78 21                	js     800dcb <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800daa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800db1:	00 
  800db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800db5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800db9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800dc0:	e8 c8 f3 ff ff       	call   80018d <sys_page_alloc>
  800dc5:	89 c3                	mov    %eax,%ebx
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	79 0a                	jns    800dd5 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  800dcb:	89 34 24             	mov    %esi,(%esp)
  800dce:	e8 76 02 00 00       	call   801049 <nsipc_close>
		return r;
  800dd3:	eb 22                	jmp    800df7 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800dd5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ddb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dde:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800dea:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ded:	89 04 24             	mov    %eax,(%esp)
  800df0:	e8 63 f6 ff ff       	call   800458 <fd2num>
  800df5:	89 c3                	mov    %eax,%ebx
}
  800df7:	89 d8                	mov    %ebx,%eax
  800df9:	83 c4 20             	add    $0x20,%esp
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800e06:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800e09:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e0d:	89 04 24             	mov    %eax,(%esp)
  800e10:	e8 c1 f6 ff ff       	call   8004d6 <fd_lookup>
  800e15:	85 c0                	test   %eax,%eax
  800e17:	78 17                	js     800e30 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e22:	39 10                	cmp    %edx,(%eax)
  800e24:	75 05                	jne    800e2b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800e26:	8b 40 0c             	mov    0xc(%eax),%eax
  800e29:	eb 05                	jmp    800e30 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800e2b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800e30:	c9                   	leave  
  800e31:	c3                   	ret    

00800e32 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e38:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3b:	e8 c0 ff ff ff       	call   800e00 <fd2sockid>
  800e40:	85 c0                	test   %eax,%eax
  800e42:	78 1f                	js     800e63 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800e44:	8b 55 10             	mov    0x10(%ebp),%edx
  800e47:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e4e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e52:	89 04 24             	mov    %eax,(%esp)
  800e55:	e8 38 01 00 00       	call   800f92 <nsipc_accept>
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	78 05                	js     800e63 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  800e5e:	e8 2c ff ff ff       	call   800d8f <alloc_sockfd>
}
  800e63:	c9                   	leave  
  800e64:	c3                   	ret    

00800e65 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6e:	e8 8d ff ff ff       	call   800e00 <fd2sockid>
  800e73:	85 c0                	test   %eax,%eax
  800e75:	78 16                	js     800e8d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  800e77:	8b 55 10             	mov    0x10(%ebp),%edx
  800e7a:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e81:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e85:	89 04 24             	mov    %eax,(%esp)
  800e88:	e8 5b 01 00 00       	call   800fe8 <nsipc_bind>
}
  800e8d:	c9                   	leave  
  800e8e:	c3                   	ret    

00800e8f <shutdown>:

int
shutdown(int s, int how)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e95:	8b 45 08             	mov    0x8(%ebp),%eax
  800e98:	e8 63 ff ff ff       	call   800e00 <fd2sockid>
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	78 0f                	js     800eb0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800ea1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea4:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ea8:	89 04 24             	mov    %eax,(%esp)
  800eab:	e8 77 01 00 00       	call   801027 <nsipc_shutdown>
}
  800eb0:	c9                   	leave  
  800eb1:	c3                   	ret    

00800eb2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800eb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebb:	e8 40 ff ff ff       	call   800e00 <fd2sockid>
  800ec0:	85 c0                	test   %eax,%eax
  800ec2:	78 16                	js     800eda <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  800ec4:	8b 55 10             	mov    0x10(%ebp),%edx
  800ec7:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ecb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ece:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ed2:	89 04 24             	mov    %eax,(%esp)
  800ed5:	e8 89 01 00 00       	call   801063 <nsipc_connect>
}
  800eda:	c9                   	leave  
  800edb:	c3                   	ret    

00800edc <listen>:

int
listen(int s, int backlog)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee5:	e8 16 ff ff ff       	call   800e00 <fd2sockid>
  800eea:	85 c0                	test   %eax,%eax
  800eec:	78 0f                	js     800efd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800eee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ef1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ef5:	89 04 24             	mov    %eax,(%esp)
  800ef8:	e8 a5 01 00 00       	call   8010a2 <nsipc_listen>
}
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800f05:	8b 45 10             	mov    0x10(%ebp),%eax
  800f08:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f13:	8b 45 08             	mov    0x8(%ebp),%eax
  800f16:	89 04 24             	mov    %eax,(%esp)
  800f19:	e8 99 02 00 00       	call   8011b7 <nsipc_socket>
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	78 05                	js     800f27 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  800f22:	e8 68 fe ff ff       	call   800d8f <alloc_sockfd>
}
  800f27:	c9                   	leave  
  800f28:	c3                   	ret    
  800f29:	00 00                	add    %al,(%eax)
	...

00800f2c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	53                   	push   %ebx
  800f30:	83 ec 14             	sub    $0x14,%esp
  800f33:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800f35:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800f3c:	75 11                	jne    800f4f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800f3e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f45:	e8 6d 12 00 00       	call   8021b7 <ipc_find_env>
  800f4a:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800f4f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800f56:	00 
  800f57:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  800f5e:	00 
  800f5f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f63:	a1 04 40 80 00       	mov    0x804004,%eax
  800f68:	89 04 24             	mov    %eax,(%esp)
  800f6b:	e8 c4 11 00 00       	call   802134 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800f70:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f77:	00 
  800f78:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f7f:	00 
  800f80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f87:	e8 38 11 00 00       	call   8020c4 <ipc_recv>
}
  800f8c:	83 c4 14             	add    $0x14,%esp
  800f8f:	5b                   	pop    %ebx
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	56                   	push   %esi
  800f96:	53                   	push   %ebx
  800f97:	83 ec 10             	sub    $0x10,%esp
  800f9a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800fa5:	8b 06                	mov    (%esi),%eax
  800fa7:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800fac:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb1:	e8 76 ff ff ff       	call   800f2c <nsipc>
  800fb6:	89 c3                	mov    %eax,%ebx
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	78 23                	js     800fdf <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800fbc:	a1 10 60 80 00       	mov    0x806010,%eax
  800fc1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  800fcc:	00 
  800fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd0:	89 04 24             	mov    %eax,(%esp)
  800fd3:	e8 40 0f 00 00       	call   801f18 <memmove>
		*addrlen = ret->ret_addrlen;
  800fd8:	a1 10 60 80 00       	mov    0x806010,%eax
  800fdd:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  800fdf:	89 d8                	mov    %ebx,%eax
  800fe1:	83 c4 10             	add    $0x10,%esp
  800fe4:	5b                   	pop    %ebx
  800fe5:	5e                   	pop    %esi
  800fe6:	5d                   	pop    %ebp
  800fe7:	c3                   	ret    

00800fe8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	53                   	push   %ebx
  800fec:	83 ec 14             	sub    $0x14,%esp
  800fef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800ff2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800ffa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ffe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801001:	89 44 24 04          	mov    %eax,0x4(%esp)
  801005:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  80100c:	e8 07 0f 00 00       	call   801f18 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801011:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801017:	b8 02 00 00 00       	mov    $0x2,%eax
  80101c:	e8 0b ff ff ff       	call   800f2c <nsipc>
}
  801021:	83 c4 14             	add    $0x14,%esp
  801024:	5b                   	pop    %ebx
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    

00801027 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80102d:	8b 45 08             	mov    0x8(%ebp),%eax
  801030:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801035:	8b 45 0c             	mov    0xc(%ebp),%eax
  801038:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80103d:	b8 03 00 00 00       	mov    $0x3,%eax
  801042:	e8 e5 fe ff ff       	call   800f2c <nsipc>
}
  801047:	c9                   	leave  
  801048:	c3                   	ret    

00801049 <nsipc_close>:

int
nsipc_close(int s)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80104f:	8b 45 08             	mov    0x8(%ebp),%eax
  801052:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801057:	b8 04 00 00 00       	mov    $0x4,%eax
  80105c:	e8 cb fe ff ff       	call   800f2c <nsipc>
}
  801061:	c9                   	leave  
  801062:	c3                   	ret    

00801063 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801063:	55                   	push   %ebp
  801064:	89 e5                	mov    %esp,%ebp
  801066:	53                   	push   %ebx
  801067:	83 ec 14             	sub    $0x14,%esp
  80106a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80106d:	8b 45 08             	mov    0x8(%ebp),%eax
  801070:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801075:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801079:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801080:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801087:	e8 8c 0e 00 00       	call   801f18 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80108c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801092:	b8 05 00 00 00       	mov    $0x5,%eax
  801097:	e8 90 fe ff ff       	call   800f2c <nsipc>
}
  80109c:	83 c4 14             	add    $0x14,%esp
  80109f:	5b                   	pop    %ebx
  8010a0:	5d                   	pop    %ebp
  8010a1:	c3                   	ret    

008010a2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8010a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ab:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8010b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b3:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8010b8:	b8 06 00 00 00       	mov    $0x6,%eax
  8010bd:	e8 6a fe ff ff       	call   800f2c <nsipc>
}
  8010c2:	c9                   	leave  
  8010c3:	c3                   	ret    

008010c4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	56                   	push   %esi
  8010c8:	53                   	push   %ebx
  8010c9:	83 ec 10             	sub    $0x10,%esp
  8010cc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8010cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8010d7:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8010dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8010e0:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8010e5:	b8 07 00 00 00       	mov    $0x7,%eax
  8010ea:	e8 3d fe ff ff       	call   800f2c <nsipc>
  8010ef:	89 c3                	mov    %eax,%ebx
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	78 46                	js     80113b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8010f5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8010fa:	7f 04                	jg     801100 <nsipc_recv+0x3c>
  8010fc:	39 c6                	cmp    %eax,%esi
  8010fe:	7d 24                	jge    801124 <nsipc_recv+0x60>
  801100:	c7 44 24 0c a7 25 80 	movl   $0x8025a7,0xc(%esp)
  801107:	00 
  801108:	c7 44 24 08 6f 25 80 	movl   $0x80256f,0x8(%esp)
  80110f:	00 
  801110:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801117:	00 
  801118:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  80111f:	e8 d8 05 00 00       	call   8016fc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801124:	89 44 24 08          	mov    %eax,0x8(%esp)
  801128:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80112f:	00 
  801130:	8b 45 0c             	mov    0xc(%ebp),%eax
  801133:	89 04 24             	mov    %eax,(%esp)
  801136:	e8 dd 0d 00 00       	call   801f18 <memmove>
	}

	return r;
}
  80113b:	89 d8                	mov    %ebx,%eax
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	5b                   	pop    %ebx
  801141:	5e                   	pop    %esi
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	53                   	push   %ebx
  801148:	83 ec 14             	sub    $0x14,%esp
  80114b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80114e:	8b 45 08             	mov    0x8(%ebp),%eax
  801151:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801156:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80115c:	7e 24                	jle    801182 <nsipc_send+0x3e>
  80115e:	c7 44 24 0c c8 25 80 	movl   $0x8025c8,0xc(%esp)
  801165:	00 
  801166:	c7 44 24 08 6f 25 80 	movl   $0x80256f,0x8(%esp)
  80116d:	00 
  80116e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801175:	00 
  801176:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  80117d:	e8 7a 05 00 00       	call   8016fc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801182:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801186:	8b 45 0c             	mov    0xc(%ebp),%eax
  801189:	89 44 24 04          	mov    %eax,0x4(%esp)
  80118d:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801194:	e8 7f 0d 00 00       	call   801f18 <memmove>
	nsipcbuf.send.req_size = size;
  801199:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80119f:	8b 45 14             	mov    0x14(%ebp),%eax
  8011a2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8011a7:	b8 08 00 00 00       	mov    $0x8,%eax
  8011ac:	e8 7b fd ff ff       	call   800f2c <nsipc>
}
  8011b1:	83 c4 14             	add    $0x14,%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    

008011b7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8011bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8011c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c8:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8011cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8011d5:	b8 09 00 00 00       	mov    $0x9,%eax
  8011da:	e8 4d fd ff ff       	call   800f2c <nsipc>
}
  8011df:	c9                   	leave  
  8011e0:	c3                   	ret    
  8011e1:	00 00                	add    %al,(%eax)
	...

008011e4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	56                   	push   %esi
  8011e8:	53                   	push   %ebx
  8011e9:	83 ec 10             	sub    $0x10,%esp
  8011ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8011ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f2:	89 04 24             	mov    %eax,(%esp)
  8011f5:	e8 6e f2 ff ff       	call   800468 <fd2data>
  8011fa:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8011fc:	c7 44 24 04 d4 25 80 	movl   $0x8025d4,0x4(%esp)
  801203:	00 
  801204:	89 34 24             	mov    %esi,(%esp)
  801207:	e8 93 0b 00 00       	call   801d9f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80120c:	8b 43 04             	mov    0x4(%ebx),%eax
  80120f:	2b 03                	sub    (%ebx),%eax
  801211:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801217:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80121e:	00 00 00 
	stat->st_dev = &devpipe;
  801221:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801228:	30 80 00 
	return 0;
}
  80122b:	b8 00 00 00 00       	mov    $0x0,%eax
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	5b                   	pop    %ebx
  801234:	5e                   	pop    %esi
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	53                   	push   %ebx
  80123b:	83 ec 14             	sub    $0x14,%esp
  80123e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801241:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801245:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80124c:	e8 e3 ef ff ff       	call   800234 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801251:	89 1c 24             	mov    %ebx,(%esp)
  801254:	e8 0f f2 ff ff       	call   800468 <fd2data>
  801259:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801264:	e8 cb ef ff ff       	call   800234 <sys_page_unmap>
}
  801269:	83 c4 14             	add    $0x14,%esp
  80126c:	5b                   	pop    %ebx
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    

0080126f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	57                   	push   %edi
  801273:	56                   	push   %esi
  801274:	53                   	push   %ebx
  801275:	83 ec 2c             	sub    $0x2c,%esp
  801278:	89 c7                	mov    %eax,%edi
  80127a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80127d:	a1 08 40 80 00       	mov    0x804008,%eax
  801282:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801285:	89 3c 24             	mov    %edi,(%esp)
  801288:	e8 6f 0f 00 00       	call   8021fc <pageref>
  80128d:	89 c6                	mov    %eax,%esi
  80128f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801292:	89 04 24             	mov    %eax,(%esp)
  801295:	e8 62 0f 00 00       	call   8021fc <pageref>
  80129a:	39 c6                	cmp    %eax,%esi
  80129c:	0f 94 c0             	sete   %al
  80129f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8012a2:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8012a8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8012ab:	39 cb                	cmp    %ecx,%ebx
  8012ad:	75 08                	jne    8012b7 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8012af:	83 c4 2c             	add    $0x2c,%esp
  8012b2:	5b                   	pop    %ebx
  8012b3:	5e                   	pop    %esi
  8012b4:	5f                   	pop    %edi
  8012b5:	5d                   	pop    %ebp
  8012b6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8012b7:	83 f8 01             	cmp    $0x1,%eax
  8012ba:	75 c1                	jne    80127d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8012bc:	8b 42 58             	mov    0x58(%edx),%eax
  8012bf:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8012c6:	00 
  8012c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012cf:	c7 04 24 db 25 80 00 	movl   $0x8025db,(%esp)
  8012d6:	e8 19 05 00 00       	call   8017f4 <cprintf>
  8012db:	eb a0                	jmp    80127d <_pipeisclosed+0xe>

008012dd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8012dd:	55                   	push   %ebp
  8012de:	89 e5                	mov    %esp,%ebp
  8012e0:	57                   	push   %edi
  8012e1:	56                   	push   %esi
  8012e2:	53                   	push   %ebx
  8012e3:	83 ec 1c             	sub    $0x1c,%esp
  8012e6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8012e9:	89 34 24             	mov    %esi,(%esp)
  8012ec:	e8 77 f1 ff ff       	call   800468 <fd2data>
  8012f1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012f3:	bf 00 00 00 00       	mov    $0x0,%edi
  8012f8:	eb 3c                	jmp    801336 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8012fa:	89 da                	mov    %ebx,%edx
  8012fc:	89 f0                	mov    %esi,%eax
  8012fe:	e8 6c ff ff ff       	call   80126f <_pipeisclosed>
  801303:	85 c0                	test   %eax,%eax
  801305:	75 38                	jne    80133f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801307:	e8 62 ee ff ff       	call   80016e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80130c:	8b 43 04             	mov    0x4(%ebx),%eax
  80130f:	8b 13                	mov    (%ebx),%edx
  801311:	83 c2 20             	add    $0x20,%edx
  801314:	39 d0                	cmp    %edx,%eax
  801316:	73 e2                	jae    8012fa <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801318:	8b 55 0c             	mov    0xc(%ebp),%edx
  80131b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80131e:	89 c2                	mov    %eax,%edx
  801320:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801326:	79 05                	jns    80132d <devpipe_write+0x50>
  801328:	4a                   	dec    %edx
  801329:	83 ca e0             	or     $0xffffffe0,%edx
  80132c:	42                   	inc    %edx
  80132d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801331:	40                   	inc    %eax
  801332:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801335:	47                   	inc    %edi
  801336:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801339:	75 d1                	jne    80130c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80133b:	89 f8                	mov    %edi,%eax
  80133d:	eb 05                	jmp    801344 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80133f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801344:	83 c4 1c             	add    $0x1c,%esp
  801347:	5b                   	pop    %ebx
  801348:	5e                   	pop    %esi
  801349:	5f                   	pop    %edi
  80134a:	5d                   	pop    %ebp
  80134b:	c3                   	ret    

0080134c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	57                   	push   %edi
  801350:	56                   	push   %esi
  801351:	53                   	push   %ebx
  801352:	83 ec 1c             	sub    $0x1c,%esp
  801355:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801358:	89 3c 24             	mov    %edi,(%esp)
  80135b:	e8 08 f1 ff ff       	call   800468 <fd2data>
  801360:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801362:	be 00 00 00 00       	mov    $0x0,%esi
  801367:	eb 3a                	jmp    8013a3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801369:	85 f6                	test   %esi,%esi
  80136b:	74 04                	je     801371 <devpipe_read+0x25>
				return i;
  80136d:	89 f0                	mov    %esi,%eax
  80136f:	eb 40                	jmp    8013b1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801371:	89 da                	mov    %ebx,%edx
  801373:	89 f8                	mov    %edi,%eax
  801375:	e8 f5 fe ff ff       	call   80126f <_pipeisclosed>
  80137a:	85 c0                	test   %eax,%eax
  80137c:	75 2e                	jne    8013ac <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80137e:	e8 eb ed ff ff       	call   80016e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801383:	8b 03                	mov    (%ebx),%eax
  801385:	3b 43 04             	cmp    0x4(%ebx),%eax
  801388:	74 df                	je     801369 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80138a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80138f:	79 05                	jns    801396 <devpipe_read+0x4a>
  801391:	48                   	dec    %eax
  801392:	83 c8 e0             	or     $0xffffffe0,%eax
  801395:	40                   	inc    %eax
  801396:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80139a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80139d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8013a0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8013a2:	46                   	inc    %esi
  8013a3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013a6:	75 db                	jne    801383 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8013a8:	89 f0                	mov    %esi,%eax
  8013aa:	eb 05                	jmp    8013b1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8013ac:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8013b1:	83 c4 1c             	add    $0x1c,%esp
  8013b4:	5b                   	pop    %ebx
  8013b5:	5e                   	pop    %esi
  8013b6:	5f                   	pop    %edi
  8013b7:	5d                   	pop    %ebp
  8013b8:	c3                   	ret    

008013b9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	57                   	push   %edi
  8013bd:	56                   	push   %esi
  8013be:	53                   	push   %ebx
  8013bf:	83 ec 3c             	sub    $0x3c,%esp
  8013c2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8013c5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013c8:	89 04 24             	mov    %eax,(%esp)
  8013cb:	e8 b3 f0 ff ff       	call   800483 <fd_alloc>
  8013d0:	89 c3                	mov    %eax,%ebx
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	0f 88 45 01 00 00    	js     80151f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013da:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8013e1:	00 
  8013e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013f0:	e8 98 ed ff ff       	call   80018d <sys_page_alloc>
  8013f5:	89 c3                	mov    %eax,%ebx
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	0f 88 20 01 00 00    	js     80151f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8013ff:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801402:	89 04 24             	mov    %eax,(%esp)
  801405:	e8 79 f0 ff ff       	call   800483 <fd_alloc>
  80140a:	89 c3                	mov    %eax,%ebx
  80140c:	85 c0                	test   %eax,%eax
  80140e:	0f 88 f8 00 00 00    	js     80150c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801414:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80141b:	00 
  80141c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80141f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801423:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80142a:	e8 5e ed ff ff       	call   80018d <sys_page_alloc>
  80142f:	89 c3                	mov    %eax,%ebx
  801431:	85 c0                	test   %eax,%eax
  801433:	0f 88 d3 00 00 00    	js     80150c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801439:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80143c:	89 04 24             	mov    %eax,(%esp)
  80143f:	e8 24 f0 ff ff       	call   800468 <fd2data>
  801444:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801446:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80144d:	00 
  80144e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801452:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801459:	e8 2f ed ff ff       	call   80018d <sys_page_alloc>
  80145e:	89 c3                	mov    %eax,%ebx
  801460:	85 c0                	test   %eax,%eax
  801462:	0f 88 91 00 00 00    	js     8014f9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801468:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80146b:	89 04 24             	mov    %eax,(%esp)
  80146e:	e8 f5 ef ff ff       	call   800468 <fd2data>
  801473:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80147a:	00 
  80147b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80147f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801486:	00 
  801487:	89 74 24 04          	mov    %esi,0x4(%esp)
  80148b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801492:	e8 4a ed ff ff       	call   8001e1 <sys_page_map>
  801497:	89 c3                	mov    %eax,%ebx
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 4c                	js     8014e9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80149d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8014a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014a6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8014a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014ab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8014b2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8014b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014bb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8014bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014c0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8014c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014ca:	89 04 24             	mov    %eax,(%esp)
  8014cd:	e8 86 ef ff ff       	call   800458 <fd2num>
  8014d2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8014d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014d7:	89 04 24             	mov    %eax,(%esp)
  8014da:	e8 79 ef ff ff       	call   800458 <fd2num>
  8014df:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8014e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014e7:	eb 36                	jmp    80151f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8014e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f4:	e8 3b ed ff ff       	call   800234 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8014f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801500:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801507:	e8 28 ed ff ff       	call   800234 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80150c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80150f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801513:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80151a:	e8 15 ed ff ff       	call   800234 <sys_page_unmap>
    err:
	return r;
}
  80151f:	89 d8                	mov    %ebx,%eax
  801521:	83 c4 3c             	add    $0x3c,%esp
  801524:	5b                   	pop    %ebx
  801525:	5e                   	pop    %esi
  801526:	5f                   	pop    %edi
  801527:	5d                   	pop    %ebp
  801528:	c3                   	ret    

00801529 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801529:	55                   	push   %ebp
  80152a:	89 e5                	mov    %esp,%ebp
  80152c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80152f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801532:	89 44 24 04          	mov    %eax,0x4(%esp)
  801536:	8b 45 08             	mov    0x8(%ebp),%eax
  801539:	89 04 24             	mov    %eax,(%esp)
  80153c:	e8 95 ef ff ff       	call   8004d6 <fd_lookup>
  801541:	85 c0                	test   %eax,%eax
  801543:	78 15                	js     80155a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801545:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801548:	89 04 24             	mov    %eax,(%esp)
  80154b:	e8 18 ef ff ff       	call   800468 <fd2data>
	return _pipeisclosed(fd, p);
  801550:	89 c2                	mov    %eax,%edx
  801552:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801555:	e8 15 fd ff ff       	call   80126f <_pipeisclosed>
}
  80155a:	c9                   	leave  
  80155b:	c3                   	ret    

0080155c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80155f:	b8 00 00 00 00       	mov    $0x0,%eax
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    

00801566 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80156c:	c7 44 24 04 f3 25 80 	movl   $0x8025f3,0x4(%esp)
  801573:	00 
  801574:	8b 45 0c             	mov    0xc(%ebp),%eax
  801577:	89 04 24             	mov    %eax,(%esp)
  80157a:	e8 20 08 00 00       	call   801d9f <strcpy>
	return 0;
}
  80157f:	b8 00 00 00 00       	mov    $0x0,%eax
  801584:	c9                   	leave  
  801585:	c3                   	ret    

00801586 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801586:	55                   	push   %ebp
  801587:	89 e5                	mov    %esp,%ebp
  801589:	57                   	push   %edi
  80158a:	56                   	push   %esi
  80158b:	53                   	push   %ebx
  80158c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801592:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801597:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80159d:	eb 30                	jmp    8015cf <devcons_write+0x49>
		m = n - tot;
  80159f:	8b 75 10             	mov    0x10(%ebp),%esi
  8015a2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8015a4:	83 fe 7f             	cmp    $0x7f,%esi
  8015a7:	76 05                	jbe    8015ae <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8015a9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8015ae:	89 74 24 08          	mov    %esi,0x8(%esp)
  8015b2:	03 45 0c             	add    0xc(%ebp),%eax
  8015b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b9:	89 3c 24             	mov    %edi,(%esp)
  8015bc:	e8 57 09 00 00       	call   801f18 <memmove>
		sys_cputs(buf, m);
  8015c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015c5:	89 3c 24             	mov    %edi,(%esp)
  8015c8:	e8 f3 ea ff ff       	call   8000c0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8015cd:	01 f3                	add    %esi,%ebx
  8015cf:	89 d8                	mov    %ebx,%eax
  8015d1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8015d4:	72 c9                	jb     80159f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8015d6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8015dc:	5b                   	pop    %ebx
  8015dd:	5e                   	pop    %esi
  8015de:	5f                   	pop    %edi
  8015df:	5d                   	pop    %ebp
  8015e0:	c3                   	ret    

008015e1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8015e7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8015eb:	75 07                	jne    8015f4 <devcons_read+0x13>
  8015ed:	eb 25                	jmp    801614 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8015ef:	e8 7a eb ff ff       	call   80016e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8015f4:	e8 e5 ea ff ff       	call   8000de <sys_cgetc>
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	74 f2                	je     8015ef <devcons_read+0xe>
  8015fd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 1d                	js     801620 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801603:	83 f8 04             	cmp    $0x4,%eax
  801606:	74 13                	je     80161b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801608:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160b:	88 10                	mov    %dl,(%eax)
	return 1;
  80160d:	b8 01 00 00 00       	mov    $0x1,%eax
  801612:	eb 0c                	jmp    801620 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801614:	b8 00 00 00 00       	mov    $0x0,%eax
  801619:	eb 05                	jmp    801620 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80161b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801620:	c9                   	leave  
  801621:	c3                   	ret    

00801622 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801622:	55                   	push   %ebp
  801623:	89 e5                	mov    %esp,%ebp
  801625:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801628:	8b 45 08             	mov    0x8(%ebp),%eax
  80162b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80162e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801635:	00 
  801636:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801639:	89 04 24             	mov    %eax,(%esp)
  80163c:	e8 7f ea ff ff       	call   8000c0 <sys_cputs>
}
  801641:	c9                   	leave  
  801642:	c3                   	ret    

00801643 <getchar>:

int
getchar(void)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801649:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801650:	00 
  801651:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801654:	89 44 24 04          	mov    %eax,0x4(%esp)
  801658:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80165f:	e8 10 f1 ff ff       	call   800774 <read>
	if (r < 0)
  801664:	85 c0                	test   %eax,%eax
  801666:	78 0f                	js     801677 <getchar+0x34>
		return r;
	if (r < 1)
  801668:	85 c0                	test   %eax,%eax
  80166a:	7e 06                	jle    801672 <getchar+0x2f>
		return -E_EOF;
	return c;
  80166c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801670:	eb 05                	jmp    801677 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801672:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801677:	c9                   	leave  
  801678:	c3                   	ret    

00801679 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80167f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801682:	89 44 24 04          	mov    %eax,0x4(%esp)
  801686:	8b 45 08             	mov    0x8(%ebp),%eax
  801689:	89 04 24             	mov    %eax,(%esp)
  80168c:	e8 45 ee ff ff       	call   8004d6 <fd_lookup>
  801691:	85 c0                	test   %eax,%eax
  801693:	78 11                	js     8016a6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801695:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801698:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80169e:	39 10                	cmp    %edx,(%eax)
  8016a0:	0f 94 c0             	sete   %al
  8016a3:	0f b6 c0             	movzbl %al,%eax
}
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    

008016a8 <opencons>:

int
opencons(void)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8016ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b1:	89 04 24             	mov    %eax,(%esp)
  8016b4:	e8 ca ed ff ff       	call   800483 <fd_alloc>
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 3c                	js     8016f9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8016bd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8016c4:	00 
  8016c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d3:	e8 b5 ea ff ff       	call   80018d <sys_page_alloc>
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	78 1d                	js     8016f9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8016dc:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8016e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8016e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ea:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8016f1:	89 04 24             	mov    %eax,(%esp)
  8016f4:	e8 5f ed ff ff       	call   800458 <fd2num>
}
  8016f9:	c9                   	leave  
  8016fa:	c3                   	ret    
	...

008016fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	56                   	push   %esi
  801700:	53                   	push   %ebx
  801701:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801704:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801707:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  80170d:	e8 3d ea ff ff       	call   80014f <sys_getenvid>
  801712:	8b 55 0c             	mov    0xc(%ebp),%edx
  801715:	89 54 24 10          	mov    %edx,0x10(%esp)
  801719:	8b 55 08             	mov    0x8(%ebp),%edx
  80171c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801720:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801724:	89 44 24 04          	mov    %eax,0x4(%esp)
  801728:	c7 04 24 00 26 80 00 	movl   $0x802600,(%esp)
  80172f:	e8 c0 00 00 00       	call   8017f4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801734:	89 74 24 04          	mov    %esi,0x4(%esp)
  801738:	8b 45 10             	mov    0x10(%ebp),%eax
  80173b:	89 04 24             	mov    %eax,(%esp)
  80173e:	e8 50 00 00 00       	call   801793 <vcprintf>
	cprintf("\n");
  801743:	c7 04 24 ec 25 80 00 	movl   $0x8025ec,(%esp)
  80174a:	e8 a5 00 00 00       	call   8017f4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80174f:	cc                   	int3   
  801750:	eb fd                	jmp    80174f <_panic+0x53>
	...

00801754 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	53                   	push   %ebx
  801758:	83 ec 14             	sub    $0x14,%esp
  80175b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80175e:	8b 03                	mov    (%ebx),%eax
  801760:	8b 55 08             	mov    0x8(%ebp),%edx
  801763:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801767:	40                   	inc    %eax
  801768:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80176a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80176f:	75 19                	jne    80178a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801771:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801778:	00 
  801779:	8d 43 08             	lea    0x8(%ebx),%eax
  80177c:	89 04 24             	mov    %eax,(%esp)
  80177f:	e8 3c e9 ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  801784:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80178a:	ff 43 04             	incl   0x4(%ebx)
}
  80178d:	83 c4 14             	add    $0x14,%esp
  801790:	5b                   	pop    %ebx
  801791:	5d                   	pop    %ebp
  801792:	c3                   	ret    

00801793 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80179c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017a3:	00 00 00 
	b.cnt = 0;
  8017a6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8017ad:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8017b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017be:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8017c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c8:	c7 04 24 54 17 80 00 	movl   $0x801754,(%esp)
  8017cf:	e8 82 01 00 00       	call   801956 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8017d4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017de:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8017e4:	89 04 24             	mov    %eax,(%esp)
  8017e7:	e8 d4 e8 ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  8017ec:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8017f2:	c9                   	leave  
  8017f3:	c3                   	ret    

008017f4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017fa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801801:	8b 45 08             	mov    0x8(%ebp),%eax
  801804:	89 04 24             	mov    %eax,(%esp)
  801807:	e8 87 ff ff ff       	call   801793 <vcprintf>
	va_end(ap);

	return cnt;
}
  80180c:	c9                   	leave  
  80180d:	c3                   	ret    
	...

00801810 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	57                   	push   %edi
  801814:	56                   	push   %esi
  801815:	53                   	push   %ebx
  801816:	83 ec 3c             	sub    $0x3c,%esp
  801819:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80181c:	89 d7                	mov    %edx,%edi
  80181e:	8b 45 08             	mov    0x8(%ebp),%eax
  801821:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801824:	8b 45 0c             	mov    0xc(%ebp),%eax
  801827:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80182a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80182d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801830:	85 c0                	test   %eax,%eax
  801832:	75 08                	jne    80183c <printnum+0x2c>
  801834:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801837:	39 45 10             	cmp    %eax,0x10(%ebp)
  80183a:	77 57                	ja     801893 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80183c:	89 74 24 10          	mov    %esi,0x10(%esp)
  801840:	4b                   	dec    %ebx
  801841:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801845:	8b 45 10             	mov    0x10(%ebp),%eax
  801848:	89 44 24 08          	mov    %eax,0x8(%esp)
  80184c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801850:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801854:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80185b:	00 
  80185c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80185f:	89 04 24             	mov    %eax,(%esp)
  801862:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801865:	89 44 24 04          	mov    %eax,0x4(%esp)
  801869:	e8 d2 09 00 00       	call   802240 <__udivdi3>
  80186e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801872:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801876:	89 04 24             	mov    %eax,(%esp)
  801879:	89 54 24 04          	mov    %edx,0x4(%esp)
  80187d:	89 fa                	mov    %edi,%edx
  80187f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801882:	e8 89 ff ff ff       	call   801810 <printnum>
  801887:	eb 0f                	jmp    801898 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801889:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80188d:	89 34 24             	mov    %esi,(%esp)
  801890:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801893:	4b                   	dec    %ebx
  801894:	85 db                	test   %ebx,%ebx
  801896:	7f f1                	jg     801889 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801898:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80189c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8018a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8018a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018a7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8018ae:	00 
  8018af:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8018b2:	89 04 24             	mov    %eax,(%esp)
  8018b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bc:	e8 9f 0a 00 00       	call   802360 <__umoddi3>
  8018c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018c5:	0f be 80 23 26 80 00 	movsbl 0x802623(%eax),%eax
  8018cc:	89 04 24             	mov    %eax,(%esp)
  8018cf:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8018d2:	83 c4 3c             	add    $0x3c,%esp
  8018d5:	5b                   	pop    %ebx
  8018d6:	5e                   	pop    %esi
  8018d7:	5f                   	pop    %edi
  8018d8:	5d                   	pop    %ebp
  8018d9:	c3                   	ret    

008018da <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8018dd:	83 fa 01             	cmp    $0x1,%edx
  8018e0:	7e 0e                	jle    8018f0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8018e2:	8b 10                	mov    (%eax),%edx
  8018e4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8018e7:	89 08                	mov    %ecx,(%eax)
  8018e9:	8b 02                	mov    (%edx),%eax
  8018eb:	8b 52 04             	mov    0x4(%edx),%edx
  8018ee:	eb 22                	jmp    801912 <getuint+0x38>
	else if (lflag)
  8018f0:	85 d2                	test   %edx,%edx
  8018f2:	74 10                	je     801904 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8018f4:	8b 10                	mov    (%eax),%edx
  8018f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8018f9:	89 08                	mov    %ecx,(%eax)
  8018fb:	8b 02                	mov    (%edx),%eax
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801902:	eb 0e                	jmp    801912 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801904:	8b 10                	mov    (%eax),%edx
  801906:	8d 4a 04             	lea    0x4(%edx),%ecx
  801909:	89 08                	mov    %ecx,(%eax)
  80190b:	8b 02                	mov    (%edx),%eax
  80190d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801912:	5d                   	pop    %ebp
  801913:	c3                   	ret    

00801914 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80191a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80191d:	8b 10                	mov    (%eax),%edx
  80191f:	3b 50 04             	cmp    0x4(%eax),%edx
  801922:	73 08                	jae    80192c <sprintputch+0x18>
		*b->buf++ = ch;
  801924:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801927:	88 0a                	mov    %cl,(%edx)
  801929:	42                   	inc    %edx
  80192a:	89 10                	mov    %edx,(%eax)
}
  80192c:	5d                   	pop    %ebp
  80192d:	c3                   	ret    

0080192e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801934:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801937:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80193b:	8b 45 10             	mov    0x10(%ebp),%eax
  80193e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801942:	8b 45 0c             	mov    0xc(%ebp),%eax
  801945:	89 44 24 04          	mov    %eax,0x4(%esp)
  801949:	8b 45 08             	mov    0x8(%ebp),%eax
  80194c:	89 04 24             	mov    %eax,(%esp)
  80194f:	e8 02 00 00 00       	call   801956 <vprintfmt>
	va_end(ap);
}
  801954:	c9                   	leave  
  801955:	c3                   	ret    

00801956 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	57                   	push   %edi
  80195a:	56                   	push   %esi
  80195b:	53                   	push   %ebx
  80195c:	83 ec 4c             	sub    $0x4c,%esp
  80195f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801962:	8b 75 10             	mov    0x10(%ebp),%esi
  801965:	eb 12                	jmp    801979 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801967:	85 c0                	test   %eax,%eax
  801969:	0f 84 6b 03 00 00    	je     801cda <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80196f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801973:	89 04 24             	mov    %eax,(%esp)
  801976:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801979:	0f b6 06             	movzbl (%esi),%eax
  80197c:	46                   	inc    %esi
  80197d:	83 f8 25             	cmp    $0x25,%eax
  801980:	75 e5                	jne    801967 <vprintfmt+0x11>
  801982:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801986:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80198d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801992:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801999:	b9 00 00 00 00       	mov    $0x0,%ecx
  80199e:	eb 26                	jmp    8019c6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019a0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8019a3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8019a7:	eb 1d                	jmp    8019c6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019a9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8019ac:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8019b0:	eb 14                	jmp    8019c6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019b2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8019b5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8019bc:	eb 08                	jmp    8019c6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8019be:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8019c1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019c6:	0f b6 06             	movzbl (%esi),%eax
  8019c9:	8d 56 01             	lea    0x1(%esi),%edx
  8019cc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8019cf:	8a 16                	mov    (%esi),%dl
  8019d1:	83 ea 23             	sub    $0x23,%edx
  8019d4:	80 fa 55             	cmp    $0x55,%dl
  8019d7:	0f 87 e1 02 00 00    	ja     801cbe <vprintfmt+0x368>
  8019dd:	0f b6 d2             	movzbl %dl,%edx
  8019e0:	ff 24 95 60 27 80 00 	jmp    *0x802760(,%edx,4)
  8019e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8019ea:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8019ef:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8019f2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8019f6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8019f9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8019fc:	83 fa 09             	cmp    $0x9,%edx
  8019ff:	77 2a                	ja     801a2b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801a01:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801a02:	eb eb                	jmp    8019ef <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801a04:	8b 45 14             	mov    0x14(%ebp),%eax
  801a07:	8d 50 04             	lea    0x4(%eax),%edx
  801a0a:	89 55 14             	mov    %edx,0x14(%ebp)
  801a0d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a0f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801a12:	eb 17                	jmp    801a2b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801a14:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801a18:	78 98                	js     8019b2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a1a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801a1d:	eb a7                	jmp    8019c6 <vprintfmt+0x70>
  801a1f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801a22:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801a29:	eb 9b                	jmp    8019c6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801a2b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801a2f:	79 95                	jns    8019c6 <vprintfmt+0x70>
  801a31:	eb 8b                	jmp    8019be <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801a33:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a34:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801a37:	eb 8d                	jmp    8019c6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801a39:	8b 45 14             	mov    0x14(%ebp),%eax
  801a3c:	8d 50 04             	lea    0x4(%eax),%edx
  801a3f:	89 55 14             	mov    %edx,0x14(%ebp)
  801a42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a46:	8b 00                	mov    (%eax),%eax
  801a48:	89 04 24             	mov    %eax,(%esp)
  801a4b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a4e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801a51:	e9 23 ff ff ff       	jmp    801979 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801a56:	8b 45 14             	mov    0x14(%ebp),%eax
  801a59:	8d 50 04             	lea    0x4(%eax),%edx
  801a5c:	89 55 14             	mov    %edx,0x14(%ebp)
  801a5f:	8b 00                	mov    (%eax),%eax
  801a61:	85 c0                	test   %eax,%eax
  801a63:	79 02                	jns    801a67 <vprintfmt+0x111>
  801a65:	f7 d8                	neg    %eax
  801a67:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801a69:	83 f8 10             	cmp    $0x10,%eax
  801a6c:	7f 0b                	jg     801a79 <vprintfmt+0x123>
  801a6e:	8b 04 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%eax
  801a75:	85 c0                	test   %eax,%eax
  801a77:	75 23                	jne    801a9c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801a79:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801a7d:	c7 44 24 08 3b 26 80 	movl   $0x80263b,0x8(%esp)
  801a84:	00 
  801a85:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a89:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8c:	89 04 24             	mov    %eax,(%esp)
  801a8f:	e8 9a fe ff ff       	call   80192e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a94:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801a97:	e9 dd fe ff ff       	jmp    801979 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801a9c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801aa0:	c7 44 24 08 81 25 80 	movl   $0x802581,0x8(%esp)
  801aa7:	00 
  801aa8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aac:	8b 55 08             	mov    0x8(%ebp),%edx
  801aaf:	89 14 24             	mov    %edx,(%esp)
  801ab2:	e8 77 fe ff ff       	call   80192e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ab7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801aba:	e9 ba fe ff ff       	jmp    801979 <vprintfmt+0x23>
  801abf:	89 f9                	mov    %edi,%ecx
  801ac1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801ac7:	8b 45 14             	mov    0x14(%ebp),%eax
  801aca:	8d 50 04             	lea    0x4(%eax),%edx
  801acd:	89 55 14             	mov    %edx,0x14(%ebp)
  801ad0:	8b 30                	mov    (%eax),%esi
  801ad2:	85 f6                	test   %esi,%esi
  801ad4:	75 05                	jne    801adb <vprintfmt+0x185>
				p = "(null)";
  801ad6:	be 34 26 80 00       	mov    $0x802634,%esi
			if (width > 0 && padc != '-')
  801adb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801adf:	0f 8e 84 00 00 00    	jle    801b69 <vprintfmt+0x213>
  801ae5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801ae9:	74 7e                	je     801b69 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  801aeb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801aef:	89 34 24             	mov    %esi,(%esp)
  801af2:	e8 8b 02 00 00       	call   801d82 <strnlen>
  801af7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801afa:	29 c2                	sub    %eax,%edx
  801afc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801aff:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801b03:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801b06:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801b09:	89 de                	mov    %ebx,%esi
  801b0b:	89 d3                	mov    %edx,%ebx
  801b0d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b0f:	eb 0b                	jmp    801b1c <vprintfmt+0x1c6>
					putch(padc, putdat);
  801b11:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b15:	89 3c 24             	mov    %edi,(%esp)
  801b18:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b1b:	4b                   	dec    %ebx
  801b1c:	85 db                	test   %ebx,%ebx
  801b1e:	7f f1                	jg     801b11 <vprintfmt+0x1bb>
  801b20:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801b23:	89 f3                	mov    %esi,%ebx
  801b25:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801b28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	79 05                	jns    801b34 <vprintfmt+0x1de>
  801b2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b34:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b37:	29 c2                	sub    %eax,%edx
  801b39:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801b3c:	eb 2b                	jmp    801b69 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801b3e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b42:	74 18                	je     801b5c <vprintfmt+0x206>
  801b44:	8d 50 e0             	lea    -0x20(%eax),%edx
  801b47:	83 fa 5e             	cmp    $0x5e,%edx
  801b4a:	76 10                	jbe    801b5c <vprintfmt+0x206>
					putch('?', putdat);
  801b4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b50:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801b57:	ff 55 08             	call   *0x8(%ebp)
  801b5a:	eb 0a                	jmp    801b66 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801b5c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b60:	89 04 24             	mov    %eax,(%esp)
  801b63:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801b66:	ff 4d e4             	decl   -0x1c(%ebp)
  801b69:	0f be 06             	movsbl (%esi),%eax
  801b6c:	46                   	inc    %esi
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	74 21                	je     801b92 <vprintfmt+0x23c>
  801b71:	85 ff                	test   %edi,%edi
  801b73:	78 c9                	js     801b3e <vprintfmt+0x1e8>
  801b75:	4f                   	dec    %edi
  801b76:	79 c6                	jns    801b3e <vprintfmt+0x1e8>
  801b78:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b7b:	89 de                	mov    %ebx,%esi
  801b7d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801b80:	eb 18                	jmp    801b9a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801b82:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b86:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801b8d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801b8f:	4b                   	dec    %ebx
  801b90:	eb 08                	jmp    801b9a <vprintfmt+0x244>
  801b92:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b95:	89 de                	mov    %ebx,%esi
  801b97:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801b9a:	85 db                	test   %ebx,%ebx
  801b9c:	7f e4                	jg     801b82 <vprintfmt+0x22c>
  801b9e:	89 7d 08             	mov    %edi,0x8(%ebp)
  801ba1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ba3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801ba6:	e9 ce fd ff ff       	jmp    801979 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801bab:	83 f9 01             	cmp    $0x1,%ecx
  801bae:	7e 10                	jle    801bc0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801bb0:	8b 45 14             	mov    0x14(%ebp),%eax
  801bb3:	8d 50 08             	lea    0x8(%eax),%edx
  801bb6:	89 55 14             	mov    %edx,0x14(%ebp)
  801bb9:	8b 30                	mov    (%eax),%esi
  801bbb:	8b 78 04             	mov    0x4(%eax),%edi
  801bbe:	eb 26                	jmp    801be6 <vprintfmt+0x290>
	else if (lflag)
  801bc0:	85 c9                	test   %ecx,%ecx
  801bc2:	74 12                	je     801bd6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  801bc4:	8b 45 14             	mov    0x14(%ebp),%eax
  801bc7:	8d 50 04             	lea    0x4(%eax),%edx
  801bca:	89 55 14             	mov    %edx,0x14(%ebp)
  801bcd:	8b 30                	mov    (%eax),%esi
  801bcf:	89 f7                	mov    %esi,%edi
  801bd1:	c1 ff 1f             	sar    $0x1f,%edi
  801bd4:	eb 10                	jmp    801be6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801bd6:	8b 45 14             	mov    0x14(%ebp),%eax
  801bd9:	8d 50 04             	lea    0x4(%eax),%edx
  801bdc:	89 55 14             	mov    %edx,0x14(%ebp)
  801bdf:	8b 30                	mov    (%eax),%esi
  801be1:	89 f7                	mov    %esi,%edi
  801be3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801be6:	85 ff                	test   %edi,%edi
  801be8:	78 0a                	js     801bf4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801bea:	b8 0a 00 00 00       	mov    $0xa,%eax
  801bef:	e9 8c 00 00 00       	jmp    801c80 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801bf4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bf8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801bff:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801c02:	f7 de                	neg    %esi
  801c04:	83 d7 00             	adc    $0x0,%edi
  801c07:	f7 df                	neg    %edi
			}
			base = 10;
  801c09:	b8 0a 00 00 00       	mov    $0xa,%eax
  801c0e:	eb 70                	jmp    801c80 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801c10:	89 ca                	mov    %ecx,%edx
  801c12:	8d 45 14             	lea    0x14(%ebp),%eax
  801c15:	e8 c0 fc ff ff       	call   8018da <getuint>
  801c1a:	89 c6                	mov    %eax,%esi
  801c1c:	89 d7                	mov    %edx,%edi
			base = 10;
  801c1e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801c23:	eb 5b                	jmp    801c80 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  801c25:	89 ca                	mov    %ecx,%edx
  801c27:	8d 45 14             	lea    0x14(%ebp),%eax
  801c2a:	e8 ab fc ff ff       	call   8018da <getuint>
  801c2f:	89 c6                	mov    %eax,%esi
  801c31:	89 d7                	mov    %edx,%edi
			base = 8;
  801c33:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801c38:	eb 46                	jmp    801c80 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  801c3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c3e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801c45:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801c48:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c4c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801c53:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801c56:	8b 45 14             	mov    0x14(%ebp),%eax
  801c59:	8d 50 04             	lea    0x4(%eax),%edx
  801c5c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801c5f:	8b 30                	mov    (%eax),%esi
  801c61:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801c66:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801c6b:	eb 13                	jmp    801c80 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801c6d:	89 ca                	mov    %ecx,%edx
  801c6f:	8d 45 14             	lea    0x14(%ebp),%eax
  801c72:	e8 63 fc ff ff       	call   8018da <getuint>
  801c77:	89 c6                	mov    %eax,%esi
  801c79:	89 d7                	mov    %edx,%edi
			base = 16;
  801c7b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801c80:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801c84:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c88:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c8b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c93:	89 34 24             	mov    %esi,(%esp)
  801c96:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c9a:	89 da                	mov    %ebx,%edx
  801c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9f:	e8 6c fb ff ff       	call   801810 <printnum>
			break;
  801ca4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801ca7:	e9 cd fc ff ff       	jmp    801979 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801cac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cb0:	89 04 24             	mov    %eax,(%esp)
  801cb3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cb6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801cb9:	e9 bb fc ff ff       	jmp    801979 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801cbe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cc2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801cc9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ccc:	eb 01                	jmp    801ccf <vprintfmt+0x379>
  801cce:	4e                   	dec    %esi
  801ccf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801cd3:	75 f9                	jne    801cce <vprintfmt+0x378>
  801cd5:	e9 9f fc ff ff       	jmp    801979 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801cda:	83 c4 4c             	add    $0x4c,%esp
  801cdd:	5b                   	pop    %ebx
  801cde:	5e                   	pop    %esi
  801cdf:	5f                   	pop    %edi
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    

00801ce2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	83 ec 28             	sub    $0x28,%esp
  801ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ceb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801cee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801cf1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801cf5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801cf8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801cff:	85 c0                	test   %eax,%eax
  801d01:	74 30                	je     801d33 <vsnprintf+0x51>
  801d03:	85 d2                	test   %edx,%edx
  801d05:	7e 33                	jle    801d3a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801d07:	8b 45 14             	mov    0x14(%ebp),%eax
  801d0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d0e:	8b 45 10             	mov    0x10(%ebp),%eax
  801d11:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d15:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801d18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d1c:	c7 04 24 14 19 80 00 	movl   $0x801914,(%esp)
  801d23:	e8 2e fc ff ff       	call   801956 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801d28:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d2b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d31:	eb 0c                	jmp    801d3f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801d33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d38:	eb 05                	jmp    801d3f <vsnprintf+0x5d>
  801d3a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801d3f:	c9                   	leave  
  801d40:	c3                   	ret    

00801d41 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801d47:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801d4a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d4e:	8b 45 10             	mov    0x10(%ebp),%eax
  801d51:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d58:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5f:	89 04 24             	mov    %eax,(%esp)
  801d62:	e8 7b ff ff ff       	call   801ce2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801d67:	c9                   	leave  
  801d68:	c3                   	ret    
  801d69:	00 00                	add    %al,(%eax)
	...

00801d6c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
  801d6f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801d72:	b8 00 00 00 00       	mov    $0x0,%eax
  801d77:	eb 01                	jmp    801d7a <strlen+0xe>
		n++;
  801d79:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801d7a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801d7e:	75 f9                	jne    801d79 <strlen+0xd>
		n++;
	return n;
}
  801d80:	5d                   	pop    %ebp
  801d81:	c3                   	ret    

00801d82 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801d88:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801d8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d90:	eb 01                	jmp    801d93 <strnlen+0x11>
		n++;
  801d92:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801d93:	39 d0                	cmp    %edx,%eax
  801d95:	74 06                	je     801d9d <strnlen+0x1b>
  801d97:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801d9b:	75 f5                	jne    801d92 <strnlen+0x10>
		n++;
	return n;
}
  801d9d:	5d                   	pop    %ebp
  801d9e:	c3                   	ret    

00801d9f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	53                   	push   %ebx
  801da3:	8b 45 08             	mov    0x8(%ebp),%eax
  801da6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801da9:	ba 00 00 00 00       	mov    $0x0,%edx
  801dae:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801db1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801db4:	42                   	inc    %edx
  801db5:	84 c9                	test   %cl,%cl
  801db7:	75 f5                	jne    801dae <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801db9:	5b                   	pop    %ebx
  801dba:	5d                   	pop    %ebp
  801dbb:	c3                   	ret    

00801dbc <strcat>:

char *
strcat(char *dst, const char *src)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	53                   	push   %ebx
  801dc0:	83 ec 08             	sub    $0x8,%esp
  801dc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801dc6:	89 1c 24             	mov    %ebx,(%esp)
  801dc9:	e8 9e ff ff ff       	call   801d6c <strlen>
	strcpy(dst + len, src);
  801dce:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dd5:	01 d8                	add    %ebx,%eax
  801dd7:	89 04 24             	mov    %eax,(%esp)
  801dda:	e8 c0 ff ff ff       	call   801d9f <strcpy>
	return dst;
}
  801ddf:	89 d8                	mov    %ebx,%eax
  801de1:	83 c4 08             	add    $0x8,%esp
  801de4:	5b                   	pop    %ebx
  801de5:	5d                   	pop    %ebp
  801de6:	c3                   	ret    

00801de7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	56                   	push   %esi
  801deb:	53                   	push   %ebx
  801dec:	8b 45 08             	mov    0x8(%ebp),%eax
  801def:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801df5:	b9 00 00 00 00       	mov    $0x0,%ecx
  801dfa:	eb 0c                	jmp    801e08 <strncpy+0x21>
		*dst++ = *src;
  801dfc:	8a 1a                	mov    (%edx),%bl
  801dfe:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801e01:	80 3a 01             	cmpb   $0x1,(%edx)
  801e04:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801e07:	41                   	inc    %ecx
  801e08:	39 f1                	cmp    %esi,%ecx
  801e0a:	75 f0                	jne    801dfc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801e0c:	5b                   	pop    %ebx
  801e0d:	5e                   	pop    %esi
  801e0e:	5d                   	pop    %ebp
  801e0f:	c3                   	ret    

00801e10 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	56                   	push   %esi
  801e14:	53                   	push   %ebx
  801e15:	8b 75 08             	mov    0x8(%ebp),%esi
  801e18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e1b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e1e:	85 d2                	test   %edx,%edx
  801e20:	75 0a                	jne    801e2c <strlcpy+0x1c>
  801e22:	89 f0                	mov    %esi,%eax
  801e24:	eb 1a                	jmp    801e40 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801e26:	88 18                	mov    %bl,(%eax)
  801e28:	40                   	inc    %eax
  801e29:	41                   	inc    %ecx
  801e2a:	eb 02                	jmp    801e2e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e2c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801e2e:	4a                   	dec    %edx
  801e2f:	74 0a                	je     801e3b <strlcpy+0x2b>
  801e31:	8a 19                	mov    (%ecx),%bl
  801e33:	84 db                	test   %bl,%bl
  801e35:	75 ef                	jne    801e26 <strlcpy+0x16>
  801e37:	89 c2                	mov    %eax,%edx
  801e39:	eb 02                	jmp    801e3d <strlcpy+0x2d>
  801e3b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801e3d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801e40:	29 f0                	sub    %esi,%eax
}
  801e42:	5b                   	pop    %ebx
  801e43:	5e                   	pop    %esi
  801e44:	5d                   	pop    %ebp
  801e45:	c3                   	ret    

00801e46 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801e4f:	eb 02                	jmp    801e53 <strcmp+0xd>
		p++, q++;
  801e51:	41                   	inc    %ecx
  801e52:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801e53:	8a 01                	mov    (%ecx),%al
  801e55:	84 c0                	test   %al,%al
  801e57:	74 04                	je     801e5d <strcmp+0x17>
  801e59:	3a 02                	cmp    (%edx),%al
  801e5b:	74 f4                	je     801e51 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801e5d:	0f b6 c0             	movzbl %al,%eax
  801e60:	0f b6 12             	movzbl (%edx),%edx
  801e63:	29 d0                	sub    %edx,%eax
}
  801e65:	5d                   	pop    %ebp
  801e66:	c3                   	ret    

00801e67 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	53                   	push   %ebx
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e71:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801e74:	eb 03                	jmp    801e79 <strncmp+0x12>
		n--, p++, q++;
  801e76:	4a                   	dec    %edx
  801e77:	40                   	inc    %eax
  801e78:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801e79:	85 d2                	test   %edx,%edx
  801e7b:	74 14                	je     801e91 <strncmp+0x2a>
  801e7d:	8a 18                	mov    (%eax),%bl
  801e7f:	84 db                	test   %bl,%bl
  801e81:	74 04                	je     801e87 <strncmp+0x20>
  801e83:	3a 19                	cmp    (%ecx),%bl
  801e85:	74 ef                	je     801e76 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801e87:	0f b6 00             	movzbl (%eax),%eax
  801e8a:	0f b6 11             	movzbl (%ecx),%edx
  801e8d:	29 d0                	sub    %edx,%eax
  801e8f:	eb 05                	jmp    801e96 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801e91:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801e96:	5b                   	pop    %ebx
  801e97:	5d                   	pop    %ebp
  801e98:	c3                   	ret    

00801e99 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801e99:	55                   	push   %ebp
  801e9a:	89 e5                	mov    %esp,%ebp
  801e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801ea2:	eb 05                	jmp    801ea9 <strchr+0x10>
		if (*s == c)
  801ea4:	38 ca                	cmp    %cl,%dl
  801ea6:	74 0c                	je     801eb4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ea8:	40                   	inc    %eax
  801ea9:	8a 10                	mov    (%eax),%dl
  801eab:	84 d2                	test   %dl,%dl
  801ead:	75 f5                	jne    801ea4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801eaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eb4:	5d                   	pop    %ebp
  801eb5:	c3                   	ret    

00801eb6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801eb6:	55                   	push   %ebp
  801eb7:	89 e5                	mov    %esp,%ebp
  801eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801ebf:	eb 05                	jmp    801ec6 <strfind+0x10>
		if (*s == c)
  801ec1:	38 ca                	cmp    %cl,%dl
  801ec3:	74 07                	je     801ecc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801ec5:	40                   	inc    %eax
  801ec6:	8a 10                	mov    (%eax),%dl
  801ec8:	84 d2                	test   %dl,%dl
  801eca:	75 f5                	jne    801ec1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801ecc:	5d                   	pop    %ebp
  801ecd:	c3                   	ret    

00801ece <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	57                   	push   %edi
  801ed2:	56                   	push   %esi
  801ed3:	53                   	push   %ebx
  801ed4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eda:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801edd:	85 c9                	test   %ecx,%ecx
  801edf:	74 30                	je     801f11 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ee1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ee7:	75 25                	jne    801f0e <memset+0x40>
  801ee9:	f6 c1 03             	test   $0x3,%cl
  801eec:	75 20                	jne    801f0e <memset+0x40>
		c &= 0xFF;
  801eee:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ef1:	89 d3                	mov    %edx,%ebx
  801ef3:	c1 e3 08             	shl    $0x8,%ebx
  801ef6:	89 d6                	mov    %edx,%esi
  801ef8:	c1 e6 18             	shl    $0x18,%esi
  801efb:	89 d0                	mov    %edx,%eax
  801efd:	c1 e0 10             	shl    $0x10,%eax
  801f00:	09 f0                	or     %esi,%eax
  801f02:	09 d0                	or     %edx,%eax
  801f04:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801f06:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801f09:	fc                   	cld    
  801f0a:	f3 ab                	rep stos %eax,%es:(%edi)
  801f0c:	eb 03                	jmp    801f11 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801f0e:	fc                   	cld    
  801f0f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801f11:	89 f8                	mov    %edi,%eax
  801f13:	5b                   	pop    %ebx
  801f14:	5e                   	pop    %esi
  801f15:	5f                   	pop    %edi
  801f16:	5d                   	pop    %ebp
  801f17:	c3                   	ret    

00801f18 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	57                   	push   %edi
  801f1c:	56                   	push   %esi
  801f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f20:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801f26:	39 c6                	cmp    %eax,%esi
  801f28:	73 34                	jae    801f5e <memmove+0x46>
  801f2a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801f2d:	39 d0                	cmp    %edx,%eax
  801f2f:	73 2d                	jae    801f5e <memmove+0x46>
		s += n;
		d += n;
  801f31:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f34:	f6 c2 03             	test   $0x3,%dl
  801f37:	75 1b                	jne    801f54 <memmove+0x3c>
  801f39:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801f3f:	75 13                	jne    801f54 <memmove+0x3c>
  801f41:	f6 c1 03             	test   $0x3,%cl
  801f44:	75 0e                	jne    801f54 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801f46:	83 ef 04             	sub    $0x4,%edi
  801f49:	8d 72 fc             	lea    -0x4(%edx),%esi
  801f4c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801f4f:	fd                   	std    
  801f50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f52:	eb 07                	jmp    801f5b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801f54:	4f                   	dec    %edi
  801f55:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801f58:	fd                   	std    
  801f59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801f5b:	fc                   	cld    
  801f5c:	eb 20                	jmp    801f7e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f5e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801f64:	75 13                	jne    801f79 <memmove+0x61>
  801f66:	a8 03                	test   $0x3,%al
  801f68:	75 0f                	jne    801f79 <memmove+0x61>
  801f6a:	f6 c1 03             	test   $0x3,%cl
  801f6d:	75 0a                	jne    801f79 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801f6f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801f72:	89 c7                	mov    %eax,%edi
  801f74:	fc                   	cld    
  801f75:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f77:	eb 05                	jmp    801f7e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801f79:	89 c7                	mov    %eax,%edi
  801f7b:	fc                   	cld    
  801f7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801f7e:	5e                   	pop    %esi
  801f7f:	5f                   	pop    %edi
  801f80:	5d                   	pop    %ebp
  801f81:	c3                   	ret    

00801f82 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801f88:	8b 45 10             	mov    0x10(%ebp),%eax
  801f8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f96:	8b 45 08             	mov    0x8(%ebp),%eax
  801f99:	89 04 24             	mov    %eax,(%esp)
  801f9c:	e8 77 ff ff ff       	call   801f18 <memmove>
}
  801fa1:	c9                   	leave  
  801fa2:	c3                   	ret    

00801fa3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	57                   	push   %edi
  801fa7:	56                   	push   %esi
  801fa8:	53                   	push   %ebx
  801fa9:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fac:	8b 75 0c             	mov    0xc(%ebp),%esi
  801faf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801fb2:	ba 00 00 00 00       	mov    $0x0,%edx
  801fb7:	eb 16                	jmp    801fcf <memcmp+0x2c>
		if (*s1 != *s2)
  801fb9:	8a 04 17             	mov    (%edi,%edx,1),%al
  801fbc:	42                   	inc    %edx
  801fbd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801fc1:	38 c8                	cmp    %cl,%al
  801fc3:	74 0a                	je     801fcf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801fc5:	0f b6 c0             	movzbl %al,%eax
  801fc8:	0f b6 c9             	movzbl %cl,%ecx
  801fcb:	29 c8                	sub    %ecx,%eax
  801fcd:	eb 09                	jmp    801fd8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801fcf:	39 da                	cmp    %ebx,%edx
  801fd1:	75 e6                	jne    801fb9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801fd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fd8:	5b                   	pop    %ebx
  801fd9:	5e                   	pop    %esi
  801fda:	5f                   	pop    %edi
  801fdb:	5d                   	pop    %ebp
  801fdc:	c3                   	ret    

00801fdd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801fe6:	89 c2                	mov    %eax,%edx
  801fe8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801feb:	eb 05                	jmp    801ff2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801fed:	38 08                	cmp    %cl,(%eax)
  801fef:	74 05                	je     801ff6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ff1:	40                   	inc    %eax
  801ff2:	39 d0                	cmp    %edx,%eax
  801ff4:	72 f7                	jb     801fed <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801ff6:	5d                   	pop    %ebp
  801ff7:	c3                   	ret    

00801ff8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ff8:	55                   	push   %ebp
  801ff9:	89 e5                	mov    %esp,%ebp
  801ffb:	57                   	push   %edi
  801ffc:	56                   	push   %esi
  801ffd:	53                   	push   %ebx
  801ffe:	8b 55 08             	mov    0x8(%ebp),%edx
  802001:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802004:	eb 01                	jmp    802007 <strtol+0xf>
		s++;
  802006:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802007:	8a 02                	mov    (%edx),%al
  802009:	3c 20                	cmp    $0x20,%al
  80200b:	74 f9                	je     802006 <strtol+0xe>
  80200d:	3c 09                	cmp    $0x9,%al
  80200f:	74 f5                	je     802006 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802011:	3c 2b                	cmp    $0x2b,%al
  802013:	75 08                	jne    80201d <strtol+0x25>
		s++;
  802015:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802016:	bf 00 00 00 00       	mov    $0x0,%edi
  80201b:	eb 13                	jmp    802030 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80201d:	3c 2d                	cmp    $0x2d,%al
  80201f:	75 0a                	jne    80202b <strtol+0x33>
		s++, neg = 1;
  802021:	8d 52 01             	lea    0x1(%edx),%edx
  802024:	bf 01 00 00 00       	mov    $0x1,%edi
  802029:	eb 05                	jmp    802030 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80202b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802030:	85 db                	test   %ebx,%ebx
  802032:	74 05                	je     802039 <strtol+0x41>
  802034:	83 fb 10             	cmp    $0x10,%ebx
  802037:	75 28                	jne    802061 <strtol+0x69>
  802039:	8a 02                	mov    (%edx),%al
  80203b:	3c 30                	cmp    $0x30,%al
  80203d:	75 10                	jne    80204f <strtol+0x57>
  80203f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802043:	75 0a                	jne    80204f <strtol+0x57>
		s += 2, base = 16;
  802045:	83 c2 02             	add    $0x2,%edx
  802048:	bb 10 00 00 00       	mov    $0x10,%ebx
  80204d:	eb 12                	jmp    802061 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80204f:	85 db                	test   %ebx,%ebx
  802051:	75 0e                	jne    802061 <strtol+0x69>
  802053:	3c 30                	cmp    $0x30,%al
  802055:	75 05                	jne    80205c <strtol+0x64>
		s++, base = 8;
  802057:	42                   	inc    %edx
  802058:	b3 08                	mov    $0x8,%bl
  80205a:	eb 05                	jmp    802061 <strtol+0x69>
	else if (base == 0)
		base = 10;
  80205c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  802061:	b8 00 00 00 00       	mov    $0x0,%eax
  802066:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802068:	8a 0a                	mov    (%edx),%cl
  80206a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80206d:	80 fb 09             	cmp    $0x9,%bl
  802070:	77 08                	ja     80207a <strtol+0x82>
			dig = *s - '0';
  802072:	0f be c9             	movsbl %cl,%ecx
  802075:	83 e9 30             	sub    $0x30,%ecx
  802078:	eb 1e                	jmp    802098 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80207a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80207d:	80 fb 19             	cmp    $0x19,%bl
  802080:	77 08                	ja     80208a <strtol+0x92>
			dig = *s - 'a' + 10;
  802082:	0f be c9             	movsbl %cl,%ecx
  802085:	83 e9 57             	sub    $0x57,%ecx
  802088:	eb 0e                	jmp    802098 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80208a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80208d:	80 fb 19             	cmp    $0x19,%bl
  802090:	77 12                	ja     8020a4 <strtol+0xac>
			dig = *s - 'A' + 10;
  802092:	0f be c9             	movsbl %cl,%ecx
  802095:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  802098:	39 f1                	cmp    %esi,%ecx
  80209a:	7d 0c                	jge    8020a8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  80209c:	42                   	inc    %edx
  80209d:	0f af c6             	imul   %esi,%eax
  8020a0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  8020a2:	eb c4                	jmp    802068 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  8020a4:	89 c1                	mov    %eax,%ecx
  8020a6:	eb 02                	jmp    8020aa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8020a8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  8020aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8020ae:	74 05                	je     8020b5 <strtol+0xbd>
		*endptr = (char *) s;
  8020b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8020b3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8020b5:	85 ff                	test   %edi,%edi
  8020b7:	74 04                	je     8020bd <strtol+0xc5>
  8020b9:	89 c8                	mov    %ecx,%eax
  8020bb:	f7 d8                	neg    %eax
}
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
	...

008020c4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	56                   	push   %esi
  8020c8:	53                   	push   %ebx
  8020c9:	83 ec 10             	sub    $0x10,%esp
  8020cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8020d5:	85 c0                	test   %eax,%eax
  8020d7:	74 0a                	je     8020e3 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8020d9:	89 04 24             	mov    %eax,(%esp)
  8020dc:	e8 c2 e2 ff ff       	call   8003a3 <sys_ipc_recv>
  8020e1:	eb 0c                	jmp    8020ef <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8020e3:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8020ea:	e8 b4 e2 ff ff       	call   8003a3 <sys_ipc_recv>
	}
	if (r < 0)
  8020ef:	85 c0                	test   %eax,%eax
  8020f1:	79 16                	jns    802109 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8020f3:	85 db                	test   %ebx,%ebx
  8020f5:	74 06                	je     8020fd <ipc_recv+0x39>
  8020f7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8020fd:	85 f6                	test   %esi,%esi
  8020ff:	74 2c                	je     80212d <ipc_recv+0x69>
  802101:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802107:	eb 24                	jmp    80212d <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802109:	85 db                	test   %ebx,%ebx
  80210b:	74 0a                	je     802117 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  80210d:	a1 08 40 80 00       	mov    0x804008,%eax
  802112:	8b 40 74             	mov    0x74(%eax),%eax
  802115:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  802117:	85 f6                	test   %esi,%esi
  802119:	74 0a                	je     802125 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  80211b:	a1 08 40 80 00       	mov    0x804008,%eax
  802120:	8b 40 78             	mov    0x78(%eax),%eax
  802123:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802125:	a1 08 40 80 00       	mov    0x804008,%eax
  80212a:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  80212d:	83 c4 10             	add    $0x10,%esp
  802130:	5b                   	pop    %ebx
  802131:	5e                   	pop    %esi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    

00802134 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
  802137:	57                   	push   %edi
  802138:	56                   	push   %esi
  802139:	53                   	push   %ebx
  80213a:	83 ec 1c             	sub    $0x1c,%esp
  80213d:	8b 75 08             	mov    0x8(%ebp),%esi
  802140:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802143:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  802146:	85 db                	test   %ebx,%ebx
  802148:	74 19                	je     802163 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  80214a:	8b 45 14             	mov    0x14(%ebp),%eax
  80214d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802151:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802155:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802159:	89 34 24             	mov    %esi,(%esp)
  80215c:	e8 1f e2 ff ff       	call   800380 <sys_ipc_try_send>
  802161:	eb 1c                	jmp    80217f <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  802163:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80216a:	00 
  80216b:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802172:	ee 
  802173:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802177:	89 34 24             	mov    %esi,(%esp)
  80217a:	e8 01 e2 ff ff       	call   800380 <sys_ipc_try_send>
		}
		if (r == 0)
  80217f:	85 c0                	test   %eax,%eax
  802181:	74 2c                	je     8021af <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802183:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802186:	74 20                	je     8021a8 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80218c:	c7 44 24 08 24 29 80 	movl   $0x802924,0x8(%esp)
  802193:	00 
  802194:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80219b:	00 
  80219c:	c7 04 24 37 29 80 00 	movl   $0x802937,(%esp)
  8021a3:	e8 54 f5 ff ff       	call   8016fc <_panic>
		}
		sys_yield();
  8021a8:	e8 c1 df ff ff       	call   80016e <sys_yield>
	}
  8021ad:	eb 97                	jmp    802146 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8021af:	83 c4 1c             	add    $0x1c,%esp
  8021b2:	5b                   	pop    %ebx
  8021b3:	5e                   	pop    %esi
  8021b4:	5f                   	pop    %edi
  8021b5:	5d                   	pop    %ebp
  8021b6:	c3                   	ret    

008021b7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021b7:	55                   	push   %ebp
  8021b8:	89 e5                	mov    %esp,%ebp
  8021ba:	53                   	push   %ebx
  8021bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8021be:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021c3:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8021ca:	89 c2                	mov    %eax,%edx
  8021cc:	c1 e2 07             	shl    $0x7,%edx
  8021cf:	29 ca                	sub    %ecx,%edx
  8021d1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021d7:	8b 52 50             	mov    0x50(%edx),%edx
  8021da:	39 da                	cmp    %ebx,%edx
  8021dc:	75 0f                	jne    8021ed <ipc_find_env+0x36>
			return envs[i].env_id;
  8021de:	c1 e0 07             	shl    $0x7,%eax
  8021e1:	29 c8                	sub    %ecx,%eax
  8021e3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021e8:	8b 40 40             	mov    0x40(%eax),%eax
  8021eb:	eb 0c                	jmp    8021f9 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021ed:	40                   	inc    %eax
  8021ee:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021f3:	75 ce                	jne    8021c3 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021f5:	66 b8 00 00          	mov    $0x0,%ax
}
  8021f9:	5b                   	pop    %ebx
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    

008021fc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021fc:	55                   	push   %ebp
  8021fd:	89 e5                	mov    %esp,%ebp
  8021ff:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802202:	89 c2                	mov    %eax,%edx
  802204:	c1 ea 16             	shr    $0x16,%edx
  802207:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80220e:	f6 c2 01             	test   $0x1,%dl
  802211:	74 1e                	je     802231 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802213:	c1 e8 0c             	shr    $0xc,%eax
  802216:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80221d:	a8 01                	test   $0x1,%al
  80221f:	74 17                	je     802238 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802221:	c1 e8 0c             	shr    $0xc,%eax
  802224:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80222b:	ef 
  80222c:	0f b7 c0             	movzwl %ax,%eax
  80222f:	eb 0c                	jmp    80223d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802231:	b8 00 00 00 00       	mov    $0x0,%eax
  802236:	eb 05                	jmp    80223d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802238:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80223d:	5d                   	pop    %ebp
  80223e:	c3                   	ret    
	...

00802240 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802240:	55                   	push   %ebp
  802241:	57                   	push   %edi
  802242:	56                   	push   %esi
  802243:	83 ec 10             	sub    $0x10,%esp
  802246:	8b 74 24 20          	mov    0x20(%esp),%esi
  80224a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80224e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802252:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802256:	89 cd                	mov    %ecx,%ebp
  802258:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80225c:	85 c0                	test   %eax,%eax
  80225e:	75 2c                	jne    80228c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802260:	39 f9                	cmp    %edi,%ecx
  802262:	77 68                	ja     8022cc <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802264:	85 c9                	test   %ecx,%ecx
  802266:	75 0b                	jne    802273 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802268:	b8 01 00 00 00       	mov    $0x1,%eax
  80226d:	31 d2                	xor    %edx,%edx
  80226f:	f7 f1                	div    %ecx
  802271:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802273:	31 d2                	xor    %edx,%edx
  802275:	89 f8                	mov    %edi,%eax
  802277:	f7 f1                	div    %ecx
  802279:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80227b:	89 f0                	mov    %esi,%eax
  80227d:	f7 f1                	div    %ecx
  80227f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802281:	89 f0                	mov    %esi,%eax
  802283:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802285:	83 c4 10             	add    $0x10,%esp
  802288:	5e                   	pop    %esi
  802289:	5f                   	pop    %edi
  80228a:	5d                   	pop    %ebp
  80228b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80228c:	39 f8                	cmp    %edi,%eax
  80228e:	77 2c                	ja     8022bc <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802290:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802293:	83 f6 1f             	xor    $0x1f,%esi
  802296:	75 4c                	jne    8022e4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802298:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80229a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80229f:	72 0a                	jb     8022ab <__udivdi3+0x6b>
  8022a1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8022a5:	0f 87 ad 00 00 00    	ja     802358 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8022ab:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022b0:	89 f0                	mov    %esi,%eax
  8022b2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022b4:	83 c4 10             	add    $0x10,%esp
  8022b7:	5e                   	pop    %esi
  8022b8:	5f                   	pop    %edi
  8022b9:	5d                   	pop    %ebp
  8022ba:	c3                   	ret    
  8022bb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022bc:	31 ff                	xor    %edi,%edi
  8022be:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022c0:	89 f0                	mov    %esi,%eax
  8022c2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022c4:	83 c4 10             	add    $0x10,%esp
  8022c7:	5e                   	pop    %esi
  8022c8:	5f                   	pop    %edi
  8022c9:	5d                   	pop    %ebp
  8022ca:	c3                   	ret    
  8022cb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022cc:	89 fa                	mov    %edi,%edx
  8022ce:	89 f0                	mov    %esi,%eax
  8022d0:	f7 f1                	div    %ecx
  8022d2:	89 c6                	mov    %eax,%esi
  8022d4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022d6:	89 f0                	mov    %esi,%eax
  8022d8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022da:	83 c4 10             	add    $0x10,%esp
  8022dd:	5e                   	pop    %esi
  8022de:	5f                   	pop    %edi
  8022df:	5d                   	pop    %ebp
  8022e0:	c3                   	ret    
  8022e1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8022e4:	89 f1                	mov    %esi,%ecx
  8022e6:	d3 e0                	shl    %cl,%eax
  8022e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022ec:	b8 20 00 00 00       	mov    $0x20,%eax
  8022f1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8022f3:	89 ea                	mov    %ebp,%edx
  8022f5:	88 c1                	mov    %al,%cl
  8022f7:	d3 ea                	shr    %cl,%edx
  8022f9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8022fd:	09 ca                	or     %ecx,%edx
  8022ff:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802303:	89 f1                	mov    %esi,%ecx
  802305:	d3 e5                	shl    %cl,%ebp
  802307:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80230b:	89 fd                	mov    %edi,%ebp
  80230d:	88 c1                	mov    %al,%cl
  80230f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802311:	89 fa                	mov    %edi,%edx
  802313:	89 f1                	mov    %esi,%ecx
  802315:	d3 e2                	shl    %cl,%edx
  802317:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80231b:	88 c1                	mov    %al,%cl
  80231d:	d3 ef                	shr    %cl,%edi
  80231f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802321:	89 f8                	mov    %edi,%eax
  802323:	89 ea                	mov    %ebp,%edx
  802325:	f7 74 24 08          	divl   0x8(%esp)
  802329:	89 d1                	mov    %edx,%ecx
  80232b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  80232d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802331:	39 d1                	cmp    %edx,%ecx
  802333:	72 17                	jb     80234c <__udivdi3+0x10c>
  802335:	74 09                	je     802340 <__udivdi3+0x100>
  802337:	89 fe                	mov    %edi,%esi
  802339:	31 ff                	xor    %edi,%edi
  80233b:	e9 41 ff ff ff       	jmp    802281 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802340:	8b 54 24 04          	mov    0x4(%esp),%edx
  802344:	89 f1                	mov    %esi,%ecx
  802346:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802348:	39 c2                	cmp    %eax,%edx
  80234a:	73 eb                	jae    802337 <__udivdi3+0xf7>
		{
		  q0--;
  80234c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80234f:	31 ff                	xor    %edi,%edi
  802351:	e9 2b ff ff ff       	jmp    802281 <__udivdi3+0x41>
  802356:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802358:	31 f6                	xor    %esi,%esi
  80235a:	e9 22 ff ff ff       	jmp    802281 <__udivdi3+0x41>
	...

00802360 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802360:	55                   	push   %ebp
  802361:	57                   	push   %edi
  802362:	56                   	push   %esi
  802363:	83 ec 20             	sub    $0x20,%esp
  802366:	8b 44 24 30          	mov    0x30(%esp),%eax
  80236a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80236e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802372:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802376:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80237a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80237e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802380:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802382:	85 ed                	test   %ebp,%ebp
  802384:	75 16                	jne    80239c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802386:	39 f1                	cmp    %esi,%ecx
  802388:	0f 86 a6 00 00 00    	jbe    802434 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80238e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802390:	89 d0                	mov    %edx,%eax
  802392:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802394:	83 c4 20             	add    $0x20,%esp
  802397:	5e                   	pop    %esi
  802398:	5f                   	pop    %edi
  802399:	5d                   	pop    %ebp
  80239a:	c3                   	ret    
  80239b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80239c:	39 f5                	cmp    %esi,%ebp
  80239e:	0f 87 ac 00 00 00    	ja     802450 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8023a4:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8023a7:	83 f0 1f             	xor    $0x1f,%eax
  8023aa:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023ae:	0f 84 a8 00 00 00    	je     80245c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8023b4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023b8:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023ba:	bf 20 00 00 00       	mov    $0x20,%edi
  8023bf:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8023c3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023c7:	89 f9                	mov    %edi,%ecx
  8023c9:	d3 e8                	shr    %cl,%eax
  8023cb:	09 e8                	or     %ebp,%eax
  8023cd:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8023d1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023d5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023d9:	d3 e0                	shl    %cl,%eax
  8023db:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023df:	89 f2                	mov    %esi,%edx
  8023e1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8023e3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023e7:	d3 e0                	shl    %cl,%eax
  8023e9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023ed:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023f1:	89 f9                	mov    %edi,%ecx
  8023f3:	d3 e8                	shr    %cl,%eax
  8023f5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8023f7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023f9:	89 f2                	mov    %esi,%edx
  8023fb:	f7 74 24 18          	divl   0x18(%esp)
  8023ff:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802401:	f7 64 24 0c          	mull   0xc(%esp)
  802405:	89 c5                	mov    %eax,%ebp
  802407:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802409:	39 d6                	cmp    %edx,%esi
  80240b:	72 67                	jb     802474 <__umoddi3+0x114>
  80240d:	74 75                	je     802484 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80240f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802413:	29 e8                	sub    %ebp,%eax
  802415:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802417:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80241b:	d3 e8                	shr    %cl,%eax
  80241d:	89 f2                	mov    %esi,%edx
  80241f:	89 f9                	mov    %edi,%ecx
  802421:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802423:	09 d0                	or     %edx,%eax
  802425:	89 f2                	mov    %esi,%edx
  802427:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80242b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80242d:	83 c4 20             	add    $0x20,%esp
  802430:	5e                   	pop    %esi
  802431:	5f                   	pop    %edi
  802432:	5d                   	pop    %ebp
  802433:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802434:	85 c9                	test   %ecx,%ecx
  802436:	75 0b                	jne    802443 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802438:	b8 01 00 00 00       	mov    $0x1,%eax
  80243d:	31 d2                	xor    %edx,%edx
  80243f:	f7 f1                	div    %ecx
  802441:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802443:	89 f0                	mov    %esi,%eax
  802445:	31 d2                	xor    %edx,%edx
  802447:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802449:	89 f8                	mov    %edi,%eax
  80244b:	e9 3e ff ff ff       	jmp    80238e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802450:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802452:	83 c4 20             	add    $0x20,%esp
  802455:	5e                   	pop    %esi
  802456:	5f                   	pop    %edi
  802457:	5d                   	pop    %ebp
  802458:	c3                   	ret    
  802459:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80245c:	39 f5                	cmp    %esi,%ebp
  80245e:	72 04                	jb     802464 <__umoddi3+0x104>
  802460:	39 f9                	cmp    %edi,%ecx
  802462:	77 06                	ja     80246a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802464:	89 f2                	mov    %esi,%edx
  802466:	29 cf                	sub    %ecx,%edi
  802468:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80246a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80246c:	83 c4 20             	add    $0x20,%esp
  80246f:	5e                   	pop    %esi
  802470:	5f                   	pop    %edi
  802471:	5d                   	pop    %ebp
  802472:	c3                   	ret    
  802473:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802474:	89 d1                	mov    %edx,%ecx
  802476:	89 c5                	mov    %eax,%ebp
  802478:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80247c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802480:	eb 8d                	jmp    80240f <__umoddi3+0xaf>
  802482:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802484:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802488:	72 ea                	jb     802474 <__umoddi3+0x114>
  80248a:	89 f1                	mov    %esi,%ecx
  80248c:	eb 81                	jmp    80240f <__umoddi3+0xaf>
