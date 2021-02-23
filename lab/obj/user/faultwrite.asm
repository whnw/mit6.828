
obj/user/faultwrite.debug:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	83 ec 10             	sub    $0x10,%esp
  80004c:	8b 75 08             	mov    0x8(%ebp),%esi
  80004f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 ec 00 00 00       	call   800143 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800063:	c1 e0 07             	shl    $0x7,%eax
  800066:	29 d0                	sub    %edx,%eax
  800068:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006d:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800072:	85 f6                	test   %esi,%esi
  800074:	7e 07                	jle    80007d <libmain+0x39>
		binaryname = argv[0];
  800076:	8b 03                	mov    (%ebx),%eax
  800078:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800081:	89 34 24             	mov    %esi,(%esp)
  800084:	e8 ab ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800089:	e8 0a 00 00 00       	call   800098 <exit>
}
  80008e:	83 c4 10             	add    $0x10,%esp
  800091:	5b                   	pop    %ebx
  800092:	5e                   	pop    %esi
  800093:	5d                   	pop    %ebp
  800094:	c3                   	ret    
  800095:	00 00                	add    %al,(%eax)
	...

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80009e:	e8 90 05 00 00       	call   800633 <close_all>
	sys_env_destroy(0);
  8000a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	c9                   	leave  
  8000b0:	c3                   	ret    
  8000b1:	00 00                	add    %al,(%eax)
	...

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 28                	jle    80013b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	89 44 24 10          	mov    %eax,0x10(%esp)
  800117:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011e:	00 
  80011f:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  800126:	00 
  800127:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012e:	00 
  80012f:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  800136:	e8 b5 15 00 00       	call   8016f0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	83 c4 2c             	add    $0x2c,%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800197:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019a:	8b 55 08             	mov    0x8(%ebp),%edx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 28                	jle    8001cd <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a9:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001b0:	00 
  8001b1:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  8001b8:	00 
  8001b9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001c0:	00 
  8001c1:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  8001c8:	e8 23 15 00 00       	call   8016f0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001cd:	83 c4 2c             	add    $0x2c,%esp
  8001d0:	5b                   	pop    %ebx
  8001d1:	5e                   	pop    %esi
  8001d2:	5f                   	pop    %edi
  8001d3:	5d                   	pop    %ebp
  8001d4:	c3                   	ret    

008001d5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	57                   	push   %edi
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001de:	b8 05 00 00 00       	mov    $0x5,%eax
  8001e3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f4:	85 c0                	test   %eax,%eax
  8001f6:	7e 28                	jle    800220 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001fc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800203:	00 
  800204:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800213:	00 
  800214:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  80021b:	e8 d0 14 00 00       	call   8016f0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800220:	83 c4 2c             	add    $0x2c,%esp
  800223:	5b                   	pop    %ebx
  800224:	5e                   	pop    %esi
  800225:	5f                   	pop    %edi
  800226:	5d                   	pop    %ebp
  800227:	c3                   	ret    

00800228 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800231:	bb 00 00 00 00       	mov    $0x0,%ebx
  800236:	b8 06 00 00 00       	mov    $0x6,%eax
  80023b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023e:	8b 55 08             	mov    0x8(%ebp),%edx
  800241:	89 df                	mov    %ebx,%edi
  800243:	89 de                	mov    %ebx,%esi
  800245:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800247:	85 c0                	test   %eax,%eax
  800249:	7e 28                	jle    800273 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800256:	00 
  800257:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  80025e:	00 
  80025f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800266:	00 
  800267:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  80026e:	e8 7d 14 00 00       	call   8016f0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800273:	83 c4 2c             	add    $0x2c,%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5f                   	pop    %edi
  800279:	5d                   	pop    %ebp
  80027a:	c3                   	ret    

0080027b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80027b:	55                   	push   %ebp
  80027c:	89 e5                	mov    %esp,%ebp
  80027e:	57                   	push   %edi
  80027f:	56                   	push   %esi
  800280:	53                   	push   %ebx
  800281:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800284:	bb 00 00 00 00       	mov    $0x0,%ebx
  800289:	b8 08 00 00 00       	mov    $0x8,%eax
  80028e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800291:	8b 55 08             	mov    0x8(%ebp),%edx
  800294:	89 df                	mov    %ebx,%edi
  800296:	89 de                	mov    %ebx,%esi
  800298:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80029a:	85 c0                	test   %eax,%eax
  80029c:	7e 28                	jle    8002c6 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a2:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a9:	00 
  8002aa:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  8002b1:	00 
  8002b2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b9:	00 
  8002ba:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  8002c1:	e8 2a 14 00 00       	call   8016f0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c6:	83 c4 2c             	add    $0x2c,%esp
  8002c9:	5b                   	pop    %ebx
  8002ca:	5e                   	pop    %esi
  8002cb:	5f                   	pop    %edi
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	57                   	push   %edi
  8002d2:	56                   	push   %esi
  8002d3:	53                   	push   %ebx
  8002d4:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002dc:	b8 09 00 00 00       	mov    $0x9,%eax
  8002e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	89 df                	mov    %ebx,%edi
  8002e9:	89 de                	mov    %ebx,%esi
  8002eb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ed:	85 c0                	test   %eax,%eax
  8002ef:	7e 28                	jle    800319 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002fc:	00 
  8002fd:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  800304:	00 
  800305:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80030c:	00 
  80030d:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  800314:	e8 d7 13 00 00       	call   8016f0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800319:	83 c4 2c             	add    $0x2c,%esp
  80031c:	5b                   	pop    %ebx
  80031d:	5e                   	pop    %esi
  80031e:	5f                   	pop    %edi
  80031f:	5d                   	pop    %ebp
  800320:	c3                   	ret    

00800321 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	57                   	push   %edi
  800325:	56                   	push   %esi
  800326:	53                   	push   %ebx
  800327:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80032f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800334:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800337:	8b 55 08             	mov    0x8(%ebp),%edx
  80033a:	89 df                	mov    %ebx,%edi
  80033c:	89 de                	mov    %ebx,%esi
  80033e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800340:	85 c0                	test   %eax,%eax
  800342:	7e 28                	jle    80036c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800344:	89 44 24 10          	mov    %eax,0x10(%esp)
  800348:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80034f:	00 
  800350:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  800357:	00 
  800358:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80035f:	00 
  800360:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  800367:	e8 84 13 00 00       	call   8016f0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80036c:	83 c4 2c             	add    $0x2c,%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5f                   	pop    %edi
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	57                   	push   %edi
  800378:	56                   	push   %esi
  800379:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037a:	be 00 00 00 00       	mov    $0x0,%esi
  80037f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800384:	8b 7d 14             	mov    0x14(%ebp),%edi
  800387:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80038a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038d:	8b 55 08             	mov    0x8(%ebp),%edx
  800390:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
  80039d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8003ad:	89 cb                	mov    %ecx,%ebx
  8003af:	89 cf                	mov    %ecx,%edi
  8003b1:	89 ce                	mov    %ecx,%esi
  8003b3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003b5:	85 c0                	test   %eax,%eax
  8003b7:	7e 28                	jle    8003e1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003bd:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c4:	00 
  8003c5:	c7 44 24 08 aa 24 80 	movl   $0x8024aa,0x8(%esp)
  8003cc:	00 
  8003cd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d4:	00 
  8003d5:	c7 04 24 c7 24 80 00 	movl   $0x8024c7,(%esp)
  8003dc:	e8 0f 13 00 00       	call   8016f0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003e1:	83 c4 2c             	add    $0x2c,%esp
  8003e4:	5b                   	pop    %ebx
  8003e5:	5e                   	pop    %esi
  8003e6:	5f                   	pop    %edi
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	57                   	push   %edi
  8003ed:	56                   	push   %esi
  8003ee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f4:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003f9:	89 d1                	mov    %edx,%ecx
  8003fb:	89 d3                	mov    %edx,%ebx
  8003fd:	89 d7                	mov    %edx,%edi
  8003ff:	89 d6                	mov    %edx,%esi
  800401:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800403:	5b                   	pop    %ebx
  800404:	5e                   	pop    %esi
  800405:	5f                   	pop    %edi
  800406:	5d                   	pop    %ebp
  800407:	c3                   	ret    

00800408 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	57                   	push   %edi
  80040c:	56                   	push   %esi
  80040d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80040e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800413:	b8 0f 00 00 00       	mov    $0xf,%eax
  800418:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80041b:	8b 55 08             	mov    0x8(%ebp),%edx
  80041e:	89 df                	mov    %ebx,%edi
  800420:	89 de                	mov    %ebx,%esi
  800422:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800424:	5b                   	pop    %ebx
  800425:	5e                   	pop    %esi
  800426:	5f                   	pop    %edi
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	57                   	push   %edi
  80042d:	56                   	push   %esi
  80042e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80042f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800434:	b8 10 00 00 00       	mov    $0x10,%eax
  800439:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043c:	8b 55 08             	mov    0x8(%ebp),%edx
  80043f:	89 df                	mov    %ebx,%edi
  800441:	89 de                	mov    %ebx,%esi
  800443:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800445:	5b                   	pop    %ebx
  800446:	5e                   	pop    %esi
  800447:	5f                   	pop    %edi
  800448:	5d                   	pop    %ebp
  800449:	c3                   	ret    
	...

0080044c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80044f:	8b 45 08             	mov    0x8(%ebp),%eax
  800452:	05 00 00 00 30       	add    $0x30000000,%eax
  800457:	c1 e8 0c             	shr    $0xc,%eax
}
  80045a:	5d                   	pop    %ebp
  80045b:	c3                   	ret    

0080045c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80045c:	55                   	push   %ebp
  80045d:	89 e5                	mov    %esp,%ebp
  80045f:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800462:	8b 45 08             	mov    0x8(%ebp),%eax
  800465:	89 04 24             	mov    %eax,(%esp)
  800468:	e8 df ff ff ff       	call   80044c <fd2num>
  80046d:	c1 e0 0c             	shl    $0xc,%eax
  800470:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800475:	c9                   	leave  
  800476:	c3                   	ret    

00800477 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800477:	55                   	push   %ebp
  800478:	89 e5                	mov    %esp,%ebp
  80047a:	53                   	push   %ebx
  80047b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80047e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800483:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800485:	89 c2                	mov    %eax,%edx
  800487:	c1 ea 16             	shr    $0x16,%edx
  80048a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800491:	f6 c2 01             	test   $0x1,%dl
  800494:	74 11                	je     8004a7 <fd_alloc+0x30>
  800496:	89 c2                	mov    %eax,%edx
  800498:	c1 ea 0c             	shr    $0xc,%edx
  80049b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004a2:	f6 c2 01             	test   $0x1,%dl
  8004a5:	75 09                	jne    8004b0 <fd_alloc+0x39>
			*fd_store = fd;
  8004a7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8004a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ae:	eb 17                	jmp    8004c7 <fd_alloc+0x50>
  8004b0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8004b5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8004ba:	75 c7                	jne    800483 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8004bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8004c2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8004c7:	5b                   	pop    %ebx
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004d0:	83 f8 1f             	cmp    $0x1f,%eax
  8004d3:	77 36                	ja     80050b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004d5:	c1 e0 0c             	shl    $0xc,%eax
  8004d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004dd:	89 c2                	mov    %eax,%edx
  8004df:	c1 ea 16             	shr    $0x16,%edx
  8004e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004e9:	f6 c2 01             	test   $0x1,%dl
  8004ec:	74 24                	je     800512 <fd_lookup+0x48>
  8004ee:	89 c2                	mov    %eax,%edx
  8004f0:	c1 ea 0c             	shr    $0xc,%edx
  8004f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004fa:	f6 c2 01             	test   $0x1,%dl
  8004fd:	74 1a                	je     800519 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800502:	89 02                	mov    %eax,(%edx)
	return 0;
  800504:	b8 00 00 00 00       	mov    $0x0,%eax
  800509:	eb 13                	jmp    80051e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80050b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800510:	eb 0c                	jmp    80051e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800512:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800517:	eb 05                	jmp    80051e <fd_lookup+0x54>
  800519:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80051e:	5d                   	pop    %ebp
  80051f:	c3                   	ret    

00800520 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	53                   	push   %ebx
  800524:	83 ec 14             	sub    $0x14,%esp
  800527:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80052a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80052d:	ba 00 00 00 00       	mov    $0x0,%edx
  800532:	eb 0e                	jmp    800542 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800534:	39 08                	cmp    %ecx,(%eax)
  800536:	75 09                	jne    800541 <dev_lookup+0x21>
			*dev = devtab[i];
  800538:	89 03                	mov    %eax,(%ebx)
			return 0;
  80053a:	b8 00 00 00 00       	mov    $0x0,%eax
  80053f:	eb 33                	jmp    800574 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800541:	42                   	inc    %edx
  800542:	8b 04 95 54 25 80 00 	mov    0x802554(,%edx,4),%eax
  800549:	85 c0                	test   %eax,%eax
  80054b:	75 e7                	jne    800534 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80054d:	a1 08 40 80 00       	mov    0x804008,%eax
  800552:	8b 40 48             	mov    0x48(%eax),%eax
  800555:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800559:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055d:	c7 04 24 d8 24 80 00 	movl   $0x8024d8,(%esp)
  800564:	e8 7f 12 00 00       	call   8017e8 <cprintf>
	*dev = 0;
  800569:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80056f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800574:	83 c4 14             	add    $0x14,%esp
  800577:	5b                   	pop    %ebx
  800578:	5d                   	pop    %ebp
  800579:	c3                   	ret    

0080057a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
  80057d:	56                   	push   %esi
  80057e:	53                   	push   %ebx
  80057f:	83 ec 30             	sub    $0x30,%esp
  800582:	8b 75 08             	mov    0x8(%ebp),%esi
  800585:	8a 45 0c             	mov    0xc(%ebp),%al
  800588:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80058b:	89 34 24             	mov    %esi,(%esp)
  80058e:	e8 b9 fe ff ff       	call   80044c <fd2num>
  800593:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800596:	89 54 24 04          	mov    %edx,0x4(%esp)
  80059a:	89 04 24             	mov    %eax,(%esp)
  80059d:	e8 28 ff ff ff       	call   8004ca <fd_lookup>
  8005a2:	89 c3                	mov    %eax,%ebx
  8005a4:	85 c0                	test   %eax,%eax
  8005a6:	78 05                	js     8005ad <fd_close+0x33>
	    || fd != fd2)
  8005a8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8005ab:	74 0d                	je     8005ba <fd_close+0x40>
		return (must_exist ? r : 0);
  8005ad:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8005b1:	75 46                	jne    8005f9 <fd_close+0x7f>
  8005b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005b8:	eb 3f                	jmp    8005f9 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8005ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8005bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c1:	8b 06                	mov    (%esi),%eax
  8005c3:	89 04 24             	mov    %eax,(%esp)
  8005c6:	e8 55 ff ff ff       	call   800520 <dev_lookup>
  8005cb:	89 c3                	mov    %eax,%ebx
  8005cd:	85 c0                	test   %eax,%eax
  8005cf:	78 18                	js     8005e9 <fd_close+0x6f>
		if (dev->dev_close)
  8005d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005d4:	8b 40 10             	mov    0x10(%eax),%eax
  8005d7:	85 c0                	test   %eax,%eax
  8005d9:	74 09                	je     8005e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005db:	89 34 24             	mov    %esi,(%esp)
  8005de:	ff d0                	call   *%eax
  8005e0:	89 c3                	mov    %eax,%ebx
  8005e2:	eb 05                	jmp    8005e9 <fd_close+0x6f>
		else
			r = 0;
  8005e4:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005f4:	e8 2f fc ff ff       	call   800228 <sys_page_unmap>
	return r;
}
  8005f9:	89 d8                	mov    %ebx,%eax
  8005fb:	83 c4 30             	add    $0x30,%esp
  8005fe:	5b                   	pop    %ebx
  8005ff:	5e                   	pop    %esi
  800600:	5d                   	pop    %ebp
  800601:	c3                   	ret    

00800602 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800602:	55                   	push   %ebp
  800603:	89 e5                	mov    %esp,%ebp
  800605:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800608:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80060b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060f:	8b 45 08             	mov    0x8(%ebp),%eax
  800612:	89 04 24             	mov    %eax,(%esp)
  800615:	e8 b0 fe ff ff       	call   8004ca <fd_lookup>
  80061a:	85 c0                	test   %eax,%eax
  80061c:	78 13                	js     800631 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80061e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800625:	00 
  800626:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800629:	89 04 24             	mov    %eax,(%esp)
  80062c:	e8 49 ff ff ff       	call   80057a <fd_close>
}
  800631:	c9                   	leave  
  800632:	c3                   	ret    

00800633 <close_all>:

void
close_all(void)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	53                   	push   %ebx
  800637:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80063a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80063f:	89 1c 24             	mov    %ebx,(%esp)
  800642:	e8 bb ff ff ff       	call   800602 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800647:	43                   	inc    %ebx
  800648:	83 fb 20             	cmp    $0x20,%ebx
  80064b:	75 f2                	jne    80063f <close_all+0xc>
		close(i);
}
  80064d:	83 c4 14             	add    $0x14,%esp
  800650:	5b                   	pop    %ebx
  800651:	5d                   	pop    %ebp
  800652:	c3                   	ret    

00800653 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800653:	55                   	push   %ebp
  800654:	89 e5                	mov    %esp,%ebp
  800656:	57                   	push   %edi
  800657:	56                   	push   %esi
  800658:	53                   	push   %ebx
  800659:	83 ec 4c             	sub    $0x4c,%esp
  80065c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80065f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800662:	89 44 24 04          	mov    %eax,0x4(%esp)
  800666:	8b 45 08             	mov    0x8(%ebp),%eax
  800669:	89 04 24             	mov    %eax,(%esp)
  80066c:	e8 59 fe ff ff       	call   8004ca <fd_lookup>
  800671:	89 c3                	mov    %eax,%ebx
  800673:	85 c0                	test   %eax,%eax
  800675:	0f 88 e3 00 00 00    	js     80075e <dup+0x10b>
		return r;
	close(newfdnum);
  80067b:	89 3c 24             	mov    %edi,(%esp)
  80067e:	e8 7f ff ff ff       	call   800602 <close>

	newfd = INDEX2FD(newfdnum);
  800683:	89 fe                	mov    %edi,%esi
  800685:	c1 e6 0c             	shl    $0xc,%esi
  800688:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80068e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800691:	89 04 24             	mov    %eax,(%esp)
  800694:	e8 c3 fd ff ff       	call   80045c <fd2data>
  800699:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80069b:	89 34 24             	mov    %esi,(%esp)
  80069e:	e8 b9 fd ff ff       	call   80045c <fd2data>
  8006a3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8006a6:	89 d8                	mov    %ebx,%eax
  8006a8:	c1 e8 16             	shr    $0x16,%eax
  8006ab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8006b2:	a8 01                	test   $0x1,%al
  8006b4:	74 46                	je     8006fc <dup+0xa9>
  8006b6:	89 d8                	mov    %ebx,%eax
  8006b8:	c1 e8 0c             	shr    $0xc,%eax
  8006bb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8006c2:	f6 c2 01             	test   $0x1,%dl
  8006c5:	74 35                	je     8006fc <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8006c7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006ce:	25 07 0e 00 00       	and    $0xe07,%eax
  8006d3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006de:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006e5:	00 
  8006e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006f1:	e8 df fa ff ff       	call   8001d5 <sys_page_map>
  8006f6:	89 c3                	mov    %eax,%ebx
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	78 3b                	js     800737 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006ff:	89 c2                	mov    %eax,%edx
  800701:	c1 ea 0c             	shr    $0xc,%edx
  800704:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80070b:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800711:	89 54 24 10          	mov    %edx,0x10(%esp)
  800715:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800719:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800720:	00 
  800721:	89 44 24 04          	mov    %eax,0x4(%esp)
  800725:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80072c:	e8 a4 fa ff ff       	call   8001d5 <sys_page_map>
  800731:	89 c3                	mov    %eax,%ebx
  800733:	85 c0                	test   %eax,%eax
  800735:	79 25                	jns    80075c <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800737:	89 74 24 04          	mov    %esi,0x4(%esp)
  80073b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800742:	e8 e1 fa ff ff       	call   800228 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800747:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80074a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800755:	e8 ce fa ff ff       	call   800228 <sys_page_unmap>
	return r;
  80075a:	eb 02                	jmp    80075e <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  80075c:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80075e:	89 d8                	mov    %ebx,%eax
  800760:	83 c4 4c             	add    $0x4c,%esp
  800763:	5b                   	pop    %ebx
  800764:	5e                   	pop    %esi
  800765:	5f                   	pop    %edi
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	53                   	push   %ebx
  80076c:	83 ec 24             	sub    $0x24,%esp
  80076f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800772:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800775:	89 44 24 04          	mov    %eax,0x4(%esp)
  800779:	89 1c 24             	mov    %ebx,(%esp)
  80077c:	e8 49 fd ff ff       	call   8004ca <fd_lookup>
  800781:	85 c0                	test   %eax,%eax
  800783:	78 6d                	js     8007f2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800785:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80078f:	8b 00                	mov    (%eax),%eax
  800791:	89 04 24             	mov    %eax,(%esp)
  800794:	e8 87 fd ff ff       	call   800520 <dev_lookup>
  800799:	85 c0                	test   %eax,%eax
  80079b:	78 55                	js     8007f2 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80079d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a0:	8b 50 08             	mov    0x8(%eax),%edx
  8007a3:	83 e2 03             	and    $0x3,%edx
  8007a6:	83 fa 01             	cmp    $0x1,%edx
  8007a9:	75 23                	jne    8007ce <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8007ab:	a1 08 40 80 00       	mov    0x804008,%eax
  8007b0:	8b 40 48             	mov    0x48(%eax),%eax
  8007b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007bb:	c7 04 24 19 25 80 00 	movl   $0x802519,(%esp)
  8007c2:	e8 21 10 00 00       	call   8017e8 <cprintf>
		return -E_INVAL;
  8007c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007cc:	eb 24                	jmp    8007f2 <read+0x8a>
	}
	if (!dev->dev_read)
  8007ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d1:	8b 52 08             	mov    0x8(%edx),%edx
  8007d4:	85 d2                	test   %edx,%edx
  8007d6:	74 15                	je     8007ed <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8007d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007e6:	89 04 24             	mov    %eax,(%esp)
  8007e9:	ff d2                	call   *%edx
  8007eb:	eb 05                	jmp    8007f2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8007ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8007f2:	83 c4 24             	add    $0x24,%esp
  8007f5:	5b                   	pop    %ebx
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	57                   	push   %edi
  8007fc:	56                   	push   %esi
  8007fd:	53                   	push   %ebx
  8007fe:	83 ec 1c             	sub    $0x1c,%esp
  800801:	8b 7d 08             	mov    0x8(%ebp),%edi
  800804:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800807:	bb 00 00 00 00       	mov    $0x0,%ebx
  80080c:	eb 23                	jmp    800831 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80080e:	89 f0                	mov    %esi,%eax
  800810:	29 d8                	sub    %ebx,%eax
  800812:	89 44 24 08          	mov    %eax,0x8(%esp)
  800816:	8b 45 0c             	mov    0xc(%ebp),%eax
  800819:	01 d8                	add    %ebx,%eax
  80081b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081f:	89 3c 24             	mov    %edi,(%esp)
  800822:	e8 41 ff ff ff       	call   800768 <read>
		if (m < 0)
  800827:	85 c0                	test   %eax,%eax
  800829:	78 10                	js     80083b <readn+0x43>
			return m;
		if (m == 0)
  80082b:	85 c0                	test   %eax,%eax
  80082d:	74 0a                	je     800839 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80082f:	01 c3                	add    %eax,%ebx
  800831:	39 f3                	cmp    %esi,%ebx
  800833:	72 d9                	jb     80080e <readn+0x16>
  800835:	89 d8                	mov    %ebx,%eax
  800837:	eb 02                	jmp    80083b <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800839:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80083b:	83 c4 1c             	add    $0x1c,%esp
  80083e:	5b                   	pop    %ebx
  80083f:	5e                   	pop    %esi
  800840:	5f                   	pop    %edi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	83 ec 24             	sub    $0x24,%esp
  80084a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80084d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800850:	89 44 24 04          	mov    %eax,0x4(%esp)
  800854:	89 1c 24             	mov    %ebx,(%esp)
  800857:	e8 6e fc ff ff       	call   8004ca <fd_lookup>
  80085c:	85 c0                	test   %eax,%eax
  80085e:	78 68                	js     8008c8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800860:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800863:	89 44 24 04          	mov    %eax,0x4(%esp)
  800867:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80086a:	8b 00                	mov    (%eax),%eax
  80086c:	89 04 24             	mov    %eax,(%esp)
  80086f:	e8 ac fc ff ff       	call   800520 <dev_lookup>
  800874:	85 c0                	test   %eax,%eax
  800876:	78 50                	js     8008c8 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800878:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80087b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80087f:	75 23                	jne    8008a4 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800881:	a1 08 40 80 00       	mov    0x804008,%eax
  800886:	8b 40 48             	mov    0x48(%eax),%eax
  800889:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80088d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800891:	c7 04 24 35 25 80 00 	movl   $0x802535,(%esp)
  800898:	e8 4b 0f 00 00       	call   8017e8 <cprintf>
		return -E_INVAL;
  80089d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a2:	eb 24                	jmp    8008c8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8008a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008a7:	8b 52 0c             	mov    0xc(%edx),%edx
  8008aa:	85 d2                	test   %edx,%edx
  8008ac:	74 15                	je     8008c3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8008ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008b1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008bc:	89 04 24             	mov    %eax,(%esp)
  8008bf:	ff d2                	call   *%edx
  8008c1:	eb 05                	jmp    8008c8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8008c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8008c8:	83 c4 24             	add    $0x24,%esp
  8008cb:	5b                   	pop    %ebx
  8008cc:	5d                   	pop    %ebp
  8008cd:	c3                   	ret    

008008ce <seek>:

int
seek(int fdnum, off_t offset)
{
  8008ce:	55                   	push   %ebp
  8008cf:	89 e5                	mov    %esp,%ebp
  8008d1:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008d4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8008d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	89 04 24             	mov    %eax,(%esp)
  8008e1:	e8 e4 fb ff ff       	call   8004ca <fd_lookup>
  8008e6:	85 c0                	test   %eax,%eax
  8008e8:	78 0e                	js     8008f8 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f8:	c9                   	leave  
  8008f9:	c3                   	ret    

008008fa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	53                   	push   %ebx
  8008fe:	83 ec 24             	sub    $0x24,%esp
  800901:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800904:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800907:	89 44 24 04          	mov    %eax,0x4(%esp)
  80090b:	89 1c 24             	mov    %ebx,(%esp)
  80090e:	e8 b7 fb ff ff       	call   8004ca <fd_lookup>
  800913:	85 c0                	test   %eax,%eax
  800915:	78 61                	js     800978 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800917:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80091a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800921:	8b 00                	mov    (%eax),%eax
  800923:	89 04 24             	mov    %eax,(%esp)
  800926:	e8 f5 fb ff ff       	call   800520 <dev_lookup>
  80092b:	85 c0                	test   %eax,%eax
  80092d:	78 49                	js     800978 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80092f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800932:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800936:	75 23                	jne    80095b <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800938:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80093d:	8b 40 48             	mov    0x48(%eax),%eax
  800940:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800944:	89 44 24 04          	mov    %eax,0x4(%esp)
  800948:	c7 04 24 f8 24 80 00 	movl   $0x8024f8,(%esp)
  80094f:	e8 94 0e 00 00       	call   8017e8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800954:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800959:	eb 1d                	jmp    800978 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80095b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80095e:	8b 52 18             	mov    0x18(%edx),%edx
  800961:	85 d2                	test   %edx,%edx
  800963:	74 0e                	je     800973 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800965:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800968:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80096c:	89 04 24             	mov    %eax,(%esp)
  80096f:	ff d2                	call   *%edx
  800971:	eb 05                	jmp    800978 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800973:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800978:	83 c4 24             	add    $0x24,%esp
  80097b:	5b                   	pop    %ebx
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	53                   	push   %ebx
  800982:	83 ec 24             	sub    $0x24,%esp
  800985:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800988:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80098b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	89 04 24             	mov    %eax,(%esp)
  800995:	e8 30 fb ff ff       	call   8004ca <fd_lookup>
  80099a:	85 c0                	test   %eax,%eax
  80099c:	78 52                	js     8009f0 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80099e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009a8:	8b 00                	mov    (%eax),%eax
  8009aa:	89 04 24             	mov    %eax,(%esp)
  8009ad:	e8 6e fb ff ff       	call   800520 <dev_lookup>
  8009b2:	85 c0                	test   %eax,%eax
  8009b4:	78 3a                	js     8009f0 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8009b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8009bd:	74 2c                	je     8009eb <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8009bf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8009c2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8009c9:	00 00 00 
	stat->st_isdir = 0;
  8009cc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8009d3:	00 00 00 
	stat->st_dev = dev;
  8009d6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009e3:	89 14 24             	mov    %edx,(%esp)
  8009e6:	ff 50 14             	call   *0x14(%eax)
  8009e9:	eb 05                	jmp    8009f0 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8009eb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8009f0:	83 c4 24             	add    $0x24,%esp
  8009f3:	5b                   	pop    %ebx
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
  8009fb:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a05:	00 
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	89 04 24             	mov    %eax,(%esp)
  800a0c:	e8 2a 02 00 00       	call   800c3b <open>
  800a11:	89 c3                	mov    %eax,%ebx
  800a13:	85 c0                	test   %eax,%eax
  800a15:	78 1b                	js     800a32 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1e:	89 1c 24             	mov    %ebx,(%esp)
  800a21:	e8 58 ff ff ff       	call   80097e <fstat>
  800a26:	89 c6                	mov    %eax,%esi
	close(fd);
  800a28:	89 1c 24             	mov    %ebx,(%esp)
  800a2b:	e8 d2 fb ff ff       	call   800602 <close>
	return r;
  800a30:	89 f3                	mov    %esi,%ebx
}
  800a32:	89 d8                	mov    %ebx,%eax
  800a34:	83 c4 10             	add    $0x10,%esp
  800a37:	5b                   	pop    %ebx
  800a38:	5e                   	pop    %esi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    
	...

00800a3c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	83 ec 10             	sub    $0x10,%esp
  800a44:	89 c3                	mov    %eax,%ebx
  800a46:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a48:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a4f:	75 11                	jne    800a62 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a51:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a58:	e8 4e 17 00 00       	call   8021ab <ipc_find_env>
  800a5d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a62:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a69:	00 
  800a6a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a71:	00 
  800a72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a76:	a1 00 40 80 00       	mov    0x804000,%eax
  800a7b:	89 04 24             	mov    %eax,(%esp)
  800a7e:	e8 a5 16 00 00       	call   802128 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a83:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a8a:	00 
  800a8b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a96:	e8 1d 16 00 00       	call   8020b8 <ipc_recv>
}
  800a9b:	83 c4 10             	add    $0x10,%esp
  800a9e:	5b                   	pop    %ebx
  800a9f:	5e                   	pop    %esi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	8b 40 0c             	mov    0xc(%eax),%eax
  800aae:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800abb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ac5:	e8 72 ff ff ff       	call   800a3c <fsipc>
}
  800aca:	c9                   	leave  
  800acb:	c3                   	ret    

00800acc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 40 0c             	mov    0xc(%eax),%eax
  800ad8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800add:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae2:	b8 06 00 00 00       	mov    $0x6,%eax
  800ae7:	e8 50 ff ff ff       	call   800a3c <fsipc>
}
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	53                   	push   %ebx
  800af2:	83 ec 14             	sub    $0x14,%esp
  800af5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	8b 40 0c             	mov    0xc(%eax),%eax
  800afe:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800b03:	ba 00 00 00 00       	mov    $0x0,%edx
  800b08:	b8 05 00 00 00       	mov    $0x5,%eax
  800b0d:	e8 2a ff ff ff       	call   800a3c <fsipc>
  800b12:	85 c0                	test   %eax,%eax
  800b14:	78 2b                	js     800b41 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800b16:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b1d:	00 
  800b1e:	89 1c 24             	mov    %ebx,(%esp)
  800b21:	e8 6d 12 00 00       	call   801d93 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b26:	a1 80 50 80 00       	mov    0x805080,%eax
  800b2b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b31:	a1 84 50 80 00       	mov    0x805084,%eax
  800b36:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800b3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b41:	83 c4 14             	add    $0x14,%esp
  800b44:	5b                   	pop    %ebx
  800b45:	5d                   	pop    %ebp
  800b46:	c3                   	ret    

00800b47 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	83 ec 18             	sub    $0x18,%esp
  800b4d:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800b50:	8b 55 08             	mov    0x8(%ebp),%edx
  800b53:	8b 52 0c             	mov    0xc(%edx),%edx
  800b56:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800b5c:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  800b61:	89 c2                	mov    %eax,%edx
  800b63:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800b68:	76 05                	jbe    800b6f <devfile_write+0x28>
  800b6a:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  800b6f:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b7a:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b81:	e8 f0 13 00 00       	call   801f76 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800b86:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8b:	b8 04 00 00 00       	mov    $0x4,%eax
  800b90:	e8 a7 fe ff ff       	call   800a3c <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  800b95:	c9                   	leave  
  800b96:	c3                   	ret    

00800b97 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b97:	55                   	push   %ebp
  800b98:	89 e5                	mov    %esp,%ebp
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	83 ec 10             	sub    $0x10,%esp
  800b9f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ba2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba5:	8b 40 0c             	mov    0xc(%eax),%eax
  800ba8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800bad:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800bb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bbd:	e8 7a fe ff ff       	call   800a3c <fsipc>
  800bc2:	89 c3                	mov    %eax,%ebx
  800bc4:	85 c0                	test   %eax,%eax
  800bc6:	78 6a                	js     800c32 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800bc8:	39 c6                	cmp    %eax,%esi
  800bca:	73 24                	jae    800bf0 <devfile_read+0x59>
  800bcc:	c7 44 24 0c 68 25 80 	movl   $0x802568,0xc(%esp)
  800bd3:	00 
  800bd4:	c7 44 24 08 6f 25 80 	movl   $0x80256f,0x8(%esp)
  800bdb:	00 
  800bdc:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800be3:	00 
  800be4:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  800beb:	e8 00 0b 00 00       	call   8016f0 <_panic>
	assert(r <= PGSIZE);
  800bf0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800bf5:	7e 24                	jle    800c1b <devfile_read+0x84>
  800bf7:	c7 44 24 0c 8f 25 80 	movl   $0x80258f,0xc(%esp)
  800bfe:	00 
  800bff:	c7 44 24 08 6f 25 80 	movl   $0x80256f,0x8(%esp)
  800c06:	00 
  800c07:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800c0e:	00 
  800c0f:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  800c16:	e8 d5 0a 00 00       	call   8016f0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c1f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c26:	00 
  800c27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2a:	89 04 24             	mov    %eax,(%esp)
  800c2d:	e8 da 12 00 00       	call   801f0c <memmove>
	return r;
}
  800c32:	89 d8                	mov    %ebx,%eax
  800c34:	83 c4 10             	add    $0x10,%esp
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	56                   	push   %esi
  800c3f:	53                   	push   %ebx
  800c40:	83 ec 20             	sub    $0x20,%esp
  800c43:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c46:	89 34 24             	mov    %esi,(%esp)
  800c49:	e8 12 11 00 00       	call   801d60 <strlen>
  800c4e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c53:	7f 60                	jg     800cb5 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c58:	89 04 24             	mov    %eax,(%esp)
  800c5b:	e8 17 f8 ff ff       	call   800477 <fd_alloc>
  800c60:	89 c3                	mov    %eax,%ebx
  800c62:	85 c0                	test   %eax,%eax
  800c64:	78 54                	js     800cba <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800c66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c6a:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c71:	e8 1d 11 00 00       	call   801d93 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c79:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c7e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c81:	b8 01 00 00 00       	mov    $0x1,%eax
  800c86:	e8 b1 fd ff ff       	call   800a3c <fsipc>
  800c8b:	89 c3                	mov    %eax,%ebx
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	79 15                	jns    800ca6 <open+0x6b>
		fd_close(fd, 0);
  800c91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c98:	00 
  800c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c9c:	89 04 24             	mov    %eax,(%esp)
  800c9f:	e8 d6 f8 ff ff       	call   80057a <fd_close>
		return r;
  800ca4:	eb 14                	jmp    800cba <open+0x7f>
	}

	return fd2num(fd);
  800ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca9:	89 04 24             	mov    %eax,(%esp)
  800cac:	e8 9b f7 ff ff       	call   80044c <fd2num>
  800cb1:	89 c3                	mov    %eax,%ebx
  800cb3:	eb 05                	jmp    800cba <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cb5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800cba:	89 d8                	mov    %ebx,%eax
  800cbc:	83 c4 20             	add    $0x20,%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800cc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cce:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd3:	e8 64 fd ff ff       	call   800a3c <fsipc>
}
  800cd8:	c9                   	leave  
  800cd9:	c3                   	ret    
	...

00800cdc <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800ce2:	c7 44 24 04 9b 25 80 	movl   $0x80259b,0x4(%esp)
  800ce9:	00 
  800cea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ced:	89 04 24             	mov    %eax,(%esp)
  800cf0:	e8 9e 10 00 00       	call   801d93 <strcpy>
	return 0;
}
  800cf5:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfa:	c9                   	leave  
  800cfb:	c3                   	ret    

00800cfc <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	53                   	push   %ebx
  800d00:	83 ec 14             	sub    $0x14,%esp
  800d03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800d06:	89 1c 24             	mov    %ebx,(%esp)
  800d09:	e8 e2 14 00 00       	call   8021f0 <pageref>
  800d0e:	83 f8 01             	cmp    $0x1,%eax
  800d11:	75 0d                	jne    800d20 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  800d13:	8b 43 0c             	mov    0xc(%ebx),%eax
  800d16:	89 04 24             	mov    %eax,(%esp)
  800d19:	e8 1f 03 00 00       	call   80103d <nsipc_close>
  800d1e:	eb 05                	jmp    800d25 <devsock_close+0x29>
	else
		return 0;
  800d20:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d25:	83 c4 14             	add    $0x14,%esp
  800d28:	5b                   	pop    %ebx
  800d29:	5d                   	pop    %ebp
  800d2a:	c3                   	ret    

00800d2b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800d31:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d38:	00 
  800d39:	8b 45 10             	mov    0x10(%ebp),%eax
  800d3c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d43:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d47:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4a:	8b 40 0c             	mov    0xc(%eax),%eax
  800d4d:	89 04 24             	mov    %eax,(%esp)
  800d50:	e8 e3 03 00 00       	call   801138 <nsipc_send>
}
  800d55:	c9                   	leave  
  800d56:	c3                   	ret    

00800d57 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800d5d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d64:	00 
  800d65:	8b 45 10             	mov    0x10(%ebp),%eax
  800d68:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d73:	8b 45 08             	mov    0x8(%ebp),%eax
  800d76:	8b 40 0c             	mov    0xc(%eax),%eax
  800d79:	89 04 24             	mov    %eax,(%esp)
  800d7c:	e8 37 03 00 00       	call   8010b8 <nsipc_recv>
}
  800d81:	c9                   	leave  
  800d82:	c3                   	ret    

00800d83 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	83 ec 20             	sub    $0x20,%esp
  800d8b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800d8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d90:	89 04 24             	mov    %eax,(%esp)
  800d93:	e8 df f6 ff ff       	call   800477 <fd_alloc>
  800d98:	89 c3                	mov    %eax,%ebx
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	78 21                	js     800dbf <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800d9e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800da5:	00 
  800da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800db4:	e8 c8 f3 ff ff       	call   800181 <sys_page_alloc>
  800db9:	89 c3                	mov    %eax,%ebx
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	79 0a                	jns    800dc9 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  800dbf:	89 34 24             	mov    %esi,(%esp)
  800dc2:	e8 76 02 00 00       	call   80103d <nsipc_close>
		return r;
  800dc7:	eb 22                	jmp    800deb <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800dc9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800dde:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800de1:	89 04 24             	mov    %eax,(%esp)
  800de4:	e8 63 f6 ff ff       	call   80044c <fd2num>
  800de9:	89 c3                	mov    %eax,%ebx
}
  800deb:	89 d8                	mov    %ebx,%eax
  800ded:	83 c4 20             	add    $0x20,%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800dfa:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800dfd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e01:	89 04 24             	mov    %eax,(%esp)
  800e04:	e8 c1 f6 ff ff       	call   8004ca <fd_lookup>
  800e09:	85 c0                	test   %eax,%eax
  800e0b:	78 17                	js     800e24 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e10:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e16:	39 10                	cmp    %edx,(%eax)
  800e18:	75 05                	jne    800e1f <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800e1a:	8b 40 0c             	mov    0xc(%eax),%eax
  800e1d:	eb 05                	jmp    800e24 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800e1f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800e24:	c9                   	leave  
  800e25:	c3                   	ret    

00800e26 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2f:	e8 c0 ff ff ff       	call   800df4 <fd2sockid>
  800e34:	85 c0                	test   %eax,%eax
  800e36:	78 1f                	js     800e57 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800e38:	8b 55 10             	mov    0x10(%ebp),%edx
  800e3b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e42:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e46:	89 04 24             	mov    %eax,(%esp)
  800e49:	e8 38 01 00 00       	call   800f86 <nsipc_accept>
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	78 05                	js     800e57 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  800e52:	e8 2c ff ff ff       	call   800d83 <alloc_sockfd>
}
  800e57:	c9                   	leave  
  800e58:	c3                   	ret    

00800e59 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e62:	e8 8d ff ff ff       	call   800df4 <fd2sockid>
  800e67:	85 c0                	test   %eax,%eax
  800e69:	78 16                	js     800e81 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  800e6b:	8b 55 10             	mov    0x10(%ebp),%edx
  800e6e:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e75:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e79:	89 04 24             	mov    %eax,(%esp)
  800e7c:	e8 5b 01 00 00       	call   800fdc <nsipc_bind>
}
  800e81:	c9                   	leave  
  800e82:	c3                   	ret    

00800e83 <shutdown>:

int
shutdown(int s, int how)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e89:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8c:	e8 63 ff ff ff       	call   800df4 <fd2sockid>
  800e91:	85 c0                	test   %eax,%eax
  800e93:	78 0f                	js     800ea4 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800e95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e98:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e9c:	89 04 24             	mov    %eax,(%esp)
  800e9f:	e8 77 01 00 00       	call   80101b <nsipc_shutdown>
}
  800ea4:	c9                   	leave  
  800ea5:	c3                   	ret    

00800ea6 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800eac:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaf:	e8 40 ff ff ff       	call   800df4 <fd2sockid>
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	78 16                	js     800ece <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  800eb8:	8b 55 10             	mov    0x10(%ebp),%edx
  800ebb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ebf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ec2:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ec6:	89 04 24             	mov    %eax,(%esp)
  800ec9:	e8 89 01 00 00       	call   801057 <nsipc_connect>
}
  800ece:	c9                   	leave  
  800ecf:	c3                   	ret    

00800ed0 <listen>:

int
listen(int s, int backlog)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed9:	e8 16 ff ff ff       	call   800df4 <fd2sockid>
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	78 0f                	js     800ef1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800ee2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ee9:	89 04 24             	mov    %eax,(%esp)
  800eec:	e8 a5 01 00 00       	call   801096 <nsipc_listen>
}
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    

00800ef3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800ef9:	8b 45 10             	mov    0x10(%ebp),%eax
  800efc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f03:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f07:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0a:	89 04 24             	mov    %eax,(%esp)
  800f0d:	e8 99 02 00 00       	call   8011ab <nsipc_socket>
  800f12:	85 c0                	test   %eax,%eax
  800f14:	78 05                	js     800f1b <socket+0x28>
		return r;
	return alloc_sockfd(r);
  800f16:	e8 68 fe ff ff       	call   800d83 <alloc_sockfd>
}
  800f1b:	c9                   	leave  
  800f1c:	c3                   	ret    
  800f1d:	00 00                	add    %al,(%eax)
	...

00800f20 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	53                   	push   %ebx
  800f24:	83 ec 14             	sub    $0x14,%esp
  800f27:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800f29:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800f30:	75 11                	jne    800f43 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800f32:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f39:	e8 6d 12 00 00       	call   8021ab <ipc_find_env>
  800f3e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800f43:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800f4a:	00 
  800f4b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  800f52:	00 
  800f53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f57:	a1 04 40 80 00       	mov    0x804004,%eax
  800f5c:	89 04 24             	mov    %eax,(%esp)
  800f5f:	e8 c4 11 00 00       	call   802128 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800f64:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f6b:	00 
  800f6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f73:	00 
  800f74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f7b:	e8 38 11 00 00       	call   8020b8 <ipc_recv>
}
  800f80:	83 c4 14             	add    $0x14,%esp
  800f83:	5b                   	pop    %ebx
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	56                   	push   %esi
  800f8a:	53                   	push   %ebx
  800f8b:	83 ec 10             	sub    $0x10,%esp
  800f8e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800f91:	8b 45 08             	mov    0x8(%ebp),%eax
  800f94:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800f99:	8b 06                	mov    (%esi),%eax
  800f9b:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800fa0:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa5:	e8 76 ff ff ff       	call   800f20 <nsipc>
  800faa:	89 c3                	mov    %eax,%ebx
  800fac:	85 c0                	test   %eax,%eax
  800fae:	78 23                	js     800fd3 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800fb0:	a1 10 60 80 00       	mov    0x806010,%eax
  800fb5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb9:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  800fc0:	00 
  800fc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc4:	89 04 24             	mov    %eax,(%esp)
  800fc7:	e8 40 0f 00 00       	call   801f0c <memmove>
		*addrlen = ret->ret_addrlen;
  800fcc:	a1 10 60 80 00       	mov    0x806010,%eax
  800fd1:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  800fd3:	89 d8                	mov    %ebx,%eax
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	53                   	push   %ebx
  800fe0:	83 ec 14             	sub    $0x14,%esp
  800fe3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800fe6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe9:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800fee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff9:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801000:	e8 07 0f 00 00       	call   801f0c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801005:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80100b:	b8 02 00 00 00       	mov    $0x2,%eax
  801010:	e8 0b ff ff ff       	call   800f20 <nsipc>
}
  801015:	83 c4 14             	add    $0x14,%esp
  801018:	5b                   	pop    %ebx
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    

0080101b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801021:	8b 45 08             	mov    0x8(%ebp),%eax
  801024:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801029:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801031:	b8 03 00 00 00       	mov    $0x3,%eax
  801036:	e8 e5 fe ff ff       	call   800f20 <nsipc>
}
  80103b:	c9                   	leave  
  80103c:	c3                   	ret    

0080103d <nsipc_close>:

int
nsipc_close(int s)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801043:	8b 45 08             	mov    0x8(%ebp),%eax
  801046:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80104b:	b8 04 00 00 00       	mov    $0x4,%eax
  801050:	e8 cb fe ff ff       	call   800f20 <nsipc>
}
  801055:	c9                   	leave  
  801056:	c3                   	ret    

00801057 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	53                   	push   %ebx
  80105b:	83 ec 14             	sub    $0x14,%esp
  80105e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801061:	8b 45 08             	mov    0x8(%ebp),%eax
  801064:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801069:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80106d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801070:	89 44 24 04          	mov    %eax,0x4(%esp)
  801074:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  80107b:	e8 8c 0e 00 00       	call   801f0c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801080:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801086:	b8 05 00 00 00       	mov    $0x5,%eax
  80108b:	e8 90 fe ff ff       	call   800f20 <nsipc>
}
  801090:	83 c4 14             	add    $0x14,%esp
  801093:	5b                   	pop    %ebx
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80109c:	8b 45 08             	mov    0x8(%ebp),%eax
  80109f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8010a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8010ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8010b1:	e8 6a fe ff ff       	call   800f20 <nsipc>
}
  8010b6:	c9                   	leave  
  8010b7:	c3                   	ret    

008010b8 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	56                   	push   %esi
  8010bc:	53                   	push   %ebx
  8010bd:	83 ec 10             	sub    $0x10,%esp
  8010c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8010c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8010cb:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8010d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8010d4:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8010d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8010de:	e8 3d fe ff ff       	call   800f20 <nsipc>
  8010e3:	89 c3                	mov    %eax,%ebx
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	78 46                	js     80112f <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8010e9:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8010ee:	7f 04                	jg     8010f4 <nsipc_recv+0x3c>
  8010f0:	39 c6                	cmp    %eax,%esi
  8010f2:	7d 24                	jge    801118 <nsipc_recv+0x60>
  8010f4:	c7 44 24 0c a7 25 80 	movl   $0x8025a7,0xc(%esp)
  8010fb:	00 
  8010fc:	c7 44 24 08 6f 25 80 	movl   $0x80256f,0x8(%esp)
  801103:	00 
  801104:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80110b:	00 
  80110c:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  801113:	e8 d8 05 00 00       	call   8016f0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801118:	89 44 24 08          	mov    %eax,0x8(%esp)
  80111c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801123:	00 
  801124:	8b 45 0c             	mov    0xc(%ebp),%eax
  801127:	89 04 24             	mov    %eax,(%esp)
  80112a:	e8 dd 0d 00 00       	call   801f0c <memmove>
	}

	return r;
}
  80112f:	89 d8                	mov    %ebx,%eax
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	5b                   	pop    %ebx
  801135:	5e                   	pop    %esi
  801136:	5d                   	pop    %ebp
  801137:	c3                   	ret    

00801138 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	53                   	push   %ebx
  80113c:	83 ec 14             	sub    $0x14,%esp
  80113f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801142:	8b 45 08             	mov    0x8(%ebp),%eax
  801145:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  80114a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801150:	7e 24                	jle    801176 <nsipc_send+0x3e>
  801152:	c7 44 24 0c c8 25 80 	movl   $0x8025c8,0xc(%esp)
  801159:	00 
  80115a:	c7 44 24 08 6f 25 80 	movl   $0x80256f,0x8(%esp)
  801161:	00 
  801162:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801169:	00 
  80116a:	c7 04 24 bc 25 80 00 	movl   $0x8025bc,(%esp)
  801171:	e8 7a 05 00 00       	call   8016f0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801176:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80117a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801181:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801188:	e8 7f 0d 00 00       	call   801f0c <memmove>
	nsipcbuf.send.req_size = size;
  80118d:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801193:	8b 45 14             	mov    0x14(%ebp),%eax
  801196:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  80119b:	b8 08 00 00 00       	mov    $0x8,%eax
  8011a0:	e8 7b fd ff ff       	call   800f20 <nsipc>
}
  8011a5:	83 c4 14             	add    $0x14,%esp
  8011a8:	5b                   	pop    %ebx
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8011b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8011b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011bc:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8011c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8011c9:	b8 09 00 00 00       	mov    $0x9,%eax
  8011ce:	e8 4d fd ff ff       	call   800f20 <nsipc>
}
  8011d3:	c9                   	leave  
  8011d4:	c3                   	ret    
  8011d5:	00 00                	add    %al,(%eax)
	...

008011d8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	56                   	push   %esi
  8011dc:	53                   	push   %ebx
  8011dd:	83 ec 10             	sub    $0x10,%esp
  8011e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8011e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e6:	89 04 24             	mov    %eax,(%esp)
  8011e9:	e8 6e f2 ff ff       	call   80045c <fd2data>
  8011ee:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8011f0:	c7 44 24 04 d4 25 80 	movl   $0x8025d4,0x4(%esp)
  8011f7:	00 
  8011f8:	89 34 24             	mov    %esi,(%esp)
  8011fb:	e8 93 0b 00 00       	call   801d93 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801200:	8b 43 04             	mov    0x4(%ebx),%eax
  801203:	2b 03                	sub    (%ebx),%eax
  801205:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80120b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801212:	00 00 00 
	stat->st_dev = &devpipe;
  801215:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  80121c:	30 80 00 
	return 0;
}
  80121f:	b8 00 00 00 00       	mov    $0x0,%eax
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	5b                   	pop    %ebx
  801228:	5e                   	pop    %esi
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	53                   	push   %ebx
  80122f:	83 ec 14             	sub    $0x14,%esp
  801232:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801235:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801239:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801240:	e8 e3 ef ff ff       	call   800228 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801245:	89 1c 24             	mov    %ebx,(%esp)
  801248:	e8 0f f2 ff ff       	call   80045c <fd2data>
  80124d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801251:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801258:	e8 cb ef ff ff       	call   800228 <sys_page_unmap>
}
  80125d:	83 c4 14             	add    $0x14,%esp
  801260:	5b                   	pop    %ebx
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    

00801263 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	57                   	push   %edi
  801267:	56                   	push   %esi
  801268:	53                   	push   %ebx
  801269:	83 ec 2c             	sub    $0x2c,%esp
  80126c:	89 c7                	mov    %eax,%edi
  80126e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801271:	a1 08 40 80 00       	mov    0x804008,%eax
  801276:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801279:	89 3c 24             	mov    %edi,(%esp)
  80127c:	e8 6f 0f 00 00       	call   8021f0 <pageref>
  801281:	89 c6                	mov    %eax,%esi
  801283:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801286:	89 04 24             	mov    %eax,(%esp)
  801289:	e8 62 0f 00 00       	call   8021f0 <pageref>
  80128e:	39 c6                	cmp    %eax,%esi
  801290:	0f 94 c0             	sete   %al
  801293:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801296:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80129c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80129f:	39 cb                	cmp    %ecx,%ebx
  8012a1:	75 08                	jne    8012ab <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8012a3:	83 c4 2c             	add    $0x2c,%esp
  8012a6:	5b                   	pop    %ebx
  8012a7:	5e                   	pop    %esi
  8012a8:	5f                   	pop    %edi
  8012a9:	5d                   	pop    %ebp
  8012aa:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8012ab:	83 f8 01             	cmp    $0x1,%eax
  8012ae:	75 c1                	jne    801271 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8012b0:	8b 42 58             	mov    0x58(%edx),%eax
  8012b3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8012ba:	00 
  8012bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012c3:	c7 04 24 db 25 80 00 	movl   $0x8025db,(%esp)
  8012ca:	e8 19 05 00 00       	call   8017e8 <cprintf>
  8012cf:	eb a0                	jmp    801271 <_pipeisclosed+0xe>

008012d1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
  8012d4:	57                   	push   %edi
  8012d5:	56                   	push   %esi
  8012d6:	53                   	push   %ebx
  8012d7:	83 ec 1c             	sub    $0x1c,%esp
  8012da:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8012dd:	89 34 24             	mov    %esi,(%esp)
  8012e0:	e8 77 f1 ff ff       	call   80045c <fd2data>
  8012e5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8012ec:	eb 3c                	jmp    80132a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8012ee:	89 da                	mov    %ebx,%edx
  8012f0:	89 f0                	mov    %esi,%eax
  8012f2:	e8 6c ff ff ff       	call   801263 <_pipeisclosed>
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	75 38                	jne    801333 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8012fb:	e8 62 ee ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801300:	8b 43 04             	mov    0x4(%ebx),%eax
  801303:	8b 13                	mov    (%ebx),%edx
  801305:	83 c2 20             	add    $0x20,%edx
  801308:	39 d0                	cmp    %edx,%eax
  80130a:	73 e2                	jae    8012ee <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80130c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801312:	89 c2                	mov    %eax,%edx
  801314:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80131a:	79 05                	jns    801321 <devpipe_write+0x50>
  80131c:	4a                   	dec    %edx
  80131d:	83 ca e0             	or     $0xffffffe0,%edx
  801320:	42                   	inc    %edx
  801321:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801325:	40                   	inc    %eax
  801326:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801329:	47                   	inc    %edi
  80132a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80132d:	75 d1                	jne    801300 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80132f:	89 f8                	mov    %edi,%eax
  801331:	eb 05                	jmp    801338 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801333:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801338:	83 c4 1c             	add    $0x1c,%esp
  80133b:	5b                   	pop    %ebx
  80133c:	5e                   	pop    %esi
  80133d:	5f                   	pop    %edi
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    

00801340 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801340:	55                   	push   %ebp
  801341:	89 e5                	mov    %esp,%ebp
  801343:	57                   	push   %edi
  801344:	56                   	push   %esi
  801345:	53                   	push   %ebx
  801346:	83 ec 1c             	sub    $0x1c,%esp
  801349:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80134c:	89 3c 24             	mov    %edi,(%esp)
  80134f:	e8 08 f1 ff ff       	call   80045c <fd2data>
  801354:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801356:	be 00 00 00 00       	mov    $0x0,%esi
  80135b:	eb 3a                	jmp    801397 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80135d:	85 f6                	test   %esi,%esi
  80135f:	74 04                	je     801365 <devpipe_read+0x25>
				return i;
  801361:	89 f0                	mov    %esi,%eax
  801363:	eb 40                	jmp    8013a5 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801365:	89 da                	mov    %ebx,%edx
  801367:	89 f8                	mov    %edi,%eax
  801369:	e8 f5 fe ff ff       	call   801263 <_pipeisclosed>
  80136e:	85 c0                	test   %eax,%eax
  801370:	75 2e                	jne    8013a0 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801372:	e8 eb ed ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801377:	8b 03                	mov    (%ebx),%eax
  801379:	3b 43 04             	cmp    0x4(%ebx),%eax
  80137c:	74 df                	je     80135d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80137e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801383:	79 05                	jns    80138a <devpipe_read+0x4a>
  801385:	48                   	dec    %eax
  801386:	83 c8 e0             	or     $0xffffffe0,%eax
  801389:	40                   	inc    %eax
  80138a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80138e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801391:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801394:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801396:	46                   	inc    %esi
  801397:	3b 75 10             	cmp    0x10(%ebp),%esi
  80139a:	75 db                	jne    801377 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80139c:	89 f0                	mov    %esi,%eax
  80139e:	eb 05                	jmp    8013a5 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8013a0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8013a5:	83 c4 1c             	add    $0x1c,%esp
  8013a8:	5b                   	pop    %ebx
  8013a9:	5e                   	pop    %esi
  8013aa:	5f                   	pop    %edi
  8013ab:	5d                   	pop    %ebp
  8013ac:	c3                   	ret    

008013ad <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	57                   	push   %edi
  8013b1:	56                   	push   %esi
  8013b2:	53                   	push   %ebx
  8013b3:	83 ec 3c             	sub    $0x3c,%esp
  8013b6:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8013b9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013bc:	89 04 24             	mov    %eax,(%esp)
  8013bf:	e8 b3 f0 ff ff       	call   800477 <fd_alloc>
  8013c4:	89 c3                	mov    %eax,%ebx
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	0f 88 45 01 00 00    	js     801513 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013ce:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8013d5:	00 
  8013d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013e4:	e8 98 ed ff ff       	call   800181 <sys_page_alloc>
  8013e9:	89 c3                	mov    %eax,%ebx
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	0f 88 20 01 00 00    	js     801513 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8013f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013f6:	89 04 24             	mov    %eax,(%esp)
  8013f9:	e8 79 f0 ff ff       	call   800477 <fd_alloc>
  8013fe:	89 c3                	mov    %eax,%ebx
  801400:	85 c0                	test   %eax,%eax
  801402:	0f 88 f8 00 00 00    	js     801500 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801408:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80140f:	00 
  801410:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801413:	89 44 24 04          	mov    %eax,0x4(%esp)
  801417:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80141e:	e8 5e ed ff ff       	call   800181 <sys_page_alloc>
  801423:	89 c3                	mov    %eax,%ebx
  801425:	85 c0                	test   %eax,%eax
  801427:	0f 88 d3 00 00 00    	js     801500 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80142d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801430:	89 04 24             	mov    %eax,(%esp)
  801433:	e8 24 f0 ff ff       	call   80045c <fd2data>
  801438:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80143a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801441:	00 
  801442:	89 44 24 04          	mov    %eax,0x4(%esp)
  801446:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80144d:	e8 2f ed ff ff       	call   800181 <sys_page_alloc>
  801452:	89 c3                	mov    %eax,%ebx
  801454:	85 c0                	test   %eax,%eax
  801456:	0f 88 91 00 00 00    	js     8014ed <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80145c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80145f:	89 04 24             	mov    %eax,(%esp)
  801462:	e8 f5 ef ff ff       	call   80045c <fd2data>
  801467:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80146e:	00 
  80146f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801473:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80147a:	00 
  80147b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80147f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801486:	e8 4a ed ff ff       	call   8001d5 <sys_page_map>
  80148b:	89 c3                	mov    %eax,%ebx
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 4c                	js     8014dd <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801491:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801497:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80149a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80149c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80149f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8014a6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8014ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014af:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8014b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014b4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8014bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014be:	89 04 24             	mov    %eax,(%esp)
  8014c1:	e8 86 ef ff ff       	call   80044c <fd2num>
  8014c6:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8014c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014cb:	89 04 24             	mov    %eax,(%esp)
  8014ce:	e8 79 ef ff ff       	call   80044c <fd2num>
  8014d3:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8014d6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014db:	eb 36                	jmp    801513 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8014dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014e8:	e8 3b ed ff ff       	call   800228 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8014ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014fb:	e8 28 ed ff ff       	call   800228 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801500:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801503:	89 44 24 04          	mov    %eax,0x4(%esp)
  801507:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80150e:	e8 15 ed ff ff       	call   800228 <sys_page_unmap>
    err:
	return r;
}
  801513:	89 d8                	mov    %ebx,%eax
  801515:	83 c4 3c             	add    $0x3c,%esp
  801518:	5b                   	pop    %ebx
  801519:	5e                   	pop    %esi
  80151a:	5f                   	pop    %edi
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    

0080151d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801523:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801526:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152a:	8b 45 08             	mov    0x8(%ebp),%eax
  80152d:	89 04 24             	mov    %eax,(%esp)
  801530:	e8 95 ef ff ff       	call   8004ca <fd_lookup>
  801535:	85 c0                	test   %eax,%eax
  801537:	78 15                	js     80154e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801539:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153c:	89 04 24             	mov    %eax,(%esp)
  80153f:	e8 18 ef ff ff       	call   80045c <fd2data>
	return _pipeisclosed(fd, p);
  801544:	89 c2                	mov    %eax,%edx
  801546:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801549:	e8 15 fd ff ff       	call   801263 <_pipeisclosed>
}
  80154e:	c9                   	leave  
  80154f:	c3                   	ret    

00801550 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801553:	b8 00 00 00 00       	mov    $0x0,%eax
  801558:	5d                   	pop    %ebp
  801559:	c3                   	ret    

0080155a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80155a:	55                   	push   %ebp
  80155b:	89 e5                	mov    %esp,%ebp
  80155d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801560:	c7 44 24 04 f3 25 80 	movl   $0x8025f3,0x4(%esp)
  801567:	00 
  801568:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156b:	89 04 24             	mov    %eax,(%esp)
  80156e:	e8 20 08 00 00       	call   801d93 <strcpy>
	return 0;
}
  801573:	b8 00 00 00 00       	mov    $0x0,%eax
  801578:	c9                   	leave  
  801579:	c3                   	ret    

0080157a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	57                   	push   %edi
  80157e:	56                   	push   %esi
  80157f:	53                   	push   %ebx
  801580:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801586:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80158b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801591:	eb 30                	jmp    8015c3 <devcons_write+0x49>
		m = n - tot;
  801593:	8b 75 10             	mov    0x10(%ebp),%esi
  801596:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801598:	83 fe 7f             	cmp    $0x7f,%esi
  80159b:	76 05                	jbe    8015a2 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80159d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8015a2:	89 74 24 08          	mov    %esi,0x8(%esp)
  8015a6:	03 45 0c             	add    0xc(%ebp),%eax
  8015a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ad:	89 3c 24             	mov    %edi,(%esp)
  8015b0:	e8 57 09 00 00       	call   801f0c <memmove>
		sys_cputs(buf, m);
  8015b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015b9:	89 3c 24             	mov    %edi,(%esp)
  8015bc:	e8 f3 ea ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8015c1:	01 f3                	add    %esi,%ebx
  8015c3:	89 d8                	mov    %ebx,%eax
  8015c5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8015c8:	72 c9                	jb     801593 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8015ca:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8015d0:	5b                   	pop    %ebx
  8015d1:	5e                   	pop    %esi
  8015d2:	5f                   	pop    %edi
  8015d3:	5d                   	pop    %ebp
  8015d4:	c3                   	ret    

008015d5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8015d5:	55                   	push   %ebp
  8015d6:	89 e5                	mov    %esp,%ebp
  8015d8:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8015db:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8015df:	75 07                	jne    8015e8 <devcons_read+0x13>
  8015e1:	eb 25                	jmp    801608 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8015e3:	e8 7a eb ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8015e8:	e8 e5 ea ff ff       	call   8000d2 <sys_cgetc>
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	74 f2                	je     8015e3 <devcons_read+0xe>
  8015f1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 1d                	js     801614 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8015f7:	83 f8 04             	cmp    $0x4,%eax
  8015fa:	74 13                	je     80160f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8015fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015ff:	88 10                	mov    %dl,(%eax)
	return 1;
  801601:	b8 01 00 00 00       	mov    $0x1,%eax
  801606:	eb 0c                	jmp    801614 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801608:	b8 00 00 00 00       	mov    $0x0,%eax
  80160d:	eb 05                	jmp    801614 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80160f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80161c:	8b 45 08             	mov    0x8(%ebp),%eax
  80161f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801622:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801629:	00 
  80162a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80162d:	89 04 24             	mov    %eax,(%esp)
  801630:	e8 7f ea ff ff       	call   8000b4 <sys_cputs>
}
  801635:	c9                   	leave  
  801636:	c3                   	ret    

00801637 <getchar>:

int
getchar(void)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80163d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801644:	00 
  801645:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801648:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801653:	e8 10 f1 ff ff       	call   800768 <read>
	if (r < 0)
  801658:	85 c0                	test   %eax,%eax
  80165a:	78 0f                	js     80166b <getchar+0x34>
		return r;
	if (r < 1)
  80165c:	85 c0                	test   %eax,%eax
  80165e:	7e 06                	jle    801666 <getchar+0x2f>
		return -E_EOF;
	return c;
  801660:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801664:	eb 05                	jmp    80166b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801666:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80166b:	c9                   	leave  
  80166c:	c3                   	ret    

0080166d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801673:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801676:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167a:	8b 45 08             	mov    0x8(%ebp),%eax
  80167d:	89 04 24             	mov    %eax,(%esp)
  801680:	e8 45 ee ff ff       	call   8004ca <fd_lookup>
  801685:	85 c0                	test   %eax,%eax
  801687:	78 11                	js     80169a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801692:	39 10                	cmp    %edx,(%eax)
  801694:	0f 94 c0             	sete   %al
  801697:	0f b6 c0             	movzbl %al,%eax
}
  80169a:	c9                   	leave  
  80169b:	c3                   	ret    

0080169c <opencons>:

int
opencons(void)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8016a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a5:	89 04 24             	mov    %eax,(%esp)
  8016a8:	e8 ca ed ff ff       	call   800477 <fd_alloc>
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	78 3c                	js     8016ed <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8016b1:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8016b8:	00 
  8016b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016c7:	e8 b5 ea ff ff       	call   800181 <sys_page_alloc>
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	78 1d                	js     8016ed <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8016d0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8016d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8016db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016de:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8016e5:	89 04 24             	mov    %eax,(%esp)
  8016e8:	e8 5f ed ff ff       	call   80044c <fd2num>
}
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    
	...

008016f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	56                   	push   %esi
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8016f8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8016fb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801701:	e8 3d ea ff ff       	call   800143 <sys_getenvid>
  801706:	8b 55 0c             	mov    0xc(%ebp),%edx
  801709:	89 54 24 10          	mov    %edx,0x10(%esp)
  80170d:	8b 55 08             	mov    0x8(%ebp),%edx
  801710:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801714:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801718:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171c:	c7 04 24 00 26 80 00 	movl   $0x802600,(%esp)
  801723:	e8 c0 00 00 00       	call   8017e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801728:	89 74 24 04          	mov    %esi,0x4(%esp)
  80172c:	8b 45 10             	mov    0x10(%ebp),%eax
  80172f:	89 04 24             	mov    %eax,(%esp)
  801732:	e8 50 00 00 00       	call   801787 <vcprintf>
	cprintf("\n");
  801737:	c7 04 24 ec 25 80 00 	movl   $0x8025ec,(%esp)
  80173e:	e8 a5 00 00 00       	call   8017e8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801743:	cc                   	int3   
  801744:	eb fd                	jmp    801743 <_panic+0x53>
	...

00801748 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	53                   	push   %ebx
  80174c:	83 ec 14             	sub    $0x14,%esp
  80174f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801752:	8b 03                	mov    (%ebx),%eax
  801754:	8b 55 08             	mov    0x8(%ebp),%edx
  801757:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80175b:	40                   	inc    %eax
  80175c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80175e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801763:	75 19                	jne    80177e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801765:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80176c:	00 
  80176d:	8d 43 08             	lea    0x8(%ebx),%eax
  801770:	89 04 24             	mov    %eax,(%esp)
  801773:	e8 3c e9 ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  801778:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80177e:	ff 43 04             	incl   0x4(%ebx)
}
  801781:	83 c4 14             	add    $0x14,%esp
  801784:	5b                   	pop    %ebx
  801785:	5d                   	pop    %ebp
  801786:	c3                   	ret    

00801787 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801790:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801797:	00 00 00 
	b.cnt = 0;
  80179a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8017a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8017a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017b2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8017b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bc:	c7 04 24 48 17 80 00 	movl   $0x801748,(%esp)
  8017c3:	e8 82 01 00 00       	call   80194a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8017c8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8017d8:	89 04 24             	mov    %eax,(%esp)
  8017db:	e8 d4 e8 ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  8017e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8017e6:	c9                   	leave  
  8017e7:	c3                   	ret    

008017e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8017f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f8:	89 04 24             	mov    %eax,(%esp)
  8017fb:	e8 87 ff ff ff       	call   801787 <vcprintf>
	va_end(ap);

	return cnt;
}
  801800:	c9                   	leave  
  801801:	c3                   	ret    
	...

00801804 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	57                   	push   %edi
  801808:	56                   	push   %esi
  801809:	53                   	push   %ebx
  80180a:	83 ec 3c             	sub    $0x3c,%esp
  80180d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801810:	89 d7                	mov    %edx,%edi
  801812:	8b 45 08             	mov    0x8(%ebp),%eax
  801815:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801818:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80181e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801821:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801824:	85 c0                	test   %eax,%eax
  801826:	75 08                	jne    801830 <printnum+0x2c>
  801828:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80182b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80182e:	77 57                	ja     801887 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801830:	89 74 24 10          	mov    %esi,0x10(%esp)
  801834:	4b                   	dec    %ebx
  801835:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801839:	8b 45 10             	mov    0x10(%ebp),%eax
  80183c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801840:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801844:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801848:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80184f:	00 
  801850:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801853:	89 04 24             	mov    %eax,(%esp)
  801856:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801859:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185d:	e8 d2 09 00 00       	call   802234 <__udivdi3>
  801862:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801866:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80186a:	89 04 24             	mov    %eax,(%esp)
  80186d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801871:	89 fa                	mov    %edi,%edx
  801873:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801876:	e8 89 ff ff ff       	call   801804 <printnum>
  80187b:	eb 0f                	jmp    80188c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80187d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801881:	89 34 24             	mov    %esi,(%esp)
  801884:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801887:	4b                   	dec    %ebx
  801888:	85 db                	test   %ebx,%ebx
  80188a:	7f f1                	jg     80187d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80188c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801890:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801894:	8b 45 10             	mov    0x10(%ebp),%eax
  801897:	89 44 24 08          	mov    %eax,0x8(%esp)
  80189b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8018a2:	00 
  8018a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8018a6:	89 04 24             	mov    %eax,(%esp)
  8018a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b0:	e8 9f 0a 00 00       	call   802354 <__umoddi3>
  8018b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018b9:	0f be 80 23 26 80 00 	movsbl 0x802623(%eax),%eax
  8018c0:	89 04 24             	mov    %eax,(%esp)
  8018c3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8018c6:	83 c4 3c             	add    $0x3c,%esp
  8018c9:	5b                   	pop    %ebx
  8018ca:	5e                   	pop    %esi
  8018cb:	5f                   	pop    %edi
  8018cc:	5d                   	pop    %ebp
  8018cd:	c3                   	ret    

008018ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8018ce:	55                   	push   %ebp
  8018cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8018d1:	83 fa 01             	cmp    $0x1,%edx
  8018d4:	7e 0e                	jle    8018e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8018d6:	8b 10                	mov    (%eax),%edx
  8018d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8018db:	89 08                	mov    %ecx,(%eax)
  8018dd:	8b 02                	mov    (%edx),%eax
  8018df:	8b 52 04             	mov    0x4(%edx),%edx
  8018e2:	eb 22                	jmp    801906 <getuint+0x38>
	else if (lflag)
  8018e4:	85 d2                	test   %edx,%edx
  8018e6:	74 10                	je     8018f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8018e8:	8b 10                	mov    (%eax),%edx
  8018ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8018ed:	89 08                	mov    %ecx,(%eax)
  8018ef:	8b 02                	mov    (%edx),%eax
  8018f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f6:	eb 0e                	jmp    801906 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8018f8:	8b 10                	mov    (%eax),%edx
  8018fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8018fd:	89 08                	mov    %ecx,(%eax)
  8018ff:	8b 02                	mov    (%edx),%eax
  801901:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801906:	5d                   	pop    %ebp
  801907:	c3                   	ret    

00801908 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80190e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801911:	8b 10                	mov    (%eax),%edx
  801913:	3b 50 04             	cmp    0x4(%eax),%edx
  801916:	73 08                	jae    801920 <sprintputch+0x18>
		*b->buf++ = ch;
  801918:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80191b:	88 0a                	mov    %cl,(%edx)
  80191d:	42                   	inc    %edx
  80191e:	89 10                	mov    %edx,(%eax)
}
  801920:	5d                   	pop    %ebp
  801921:	c3                   	ret    

00801922 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801928:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80192b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80192f:	8b 45 10             	mov    0x10(%ebp),%eax
  801932:	89 44 24 08          	mov    %eax,0x8(%esp)
  801936:	8b 45 0c             	mov    0xc(%ebp),%eax
  801939:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193d:	8b 45 08             	mov    0x8(%ebp),%eax
  801940:	89 04 24             	mov    %eax,(%esp)
  801943:	e8 02 00 00 00       	call   80194a <vprintfmt>
	va_end(ap);
}
  801948:	c9                   	leave  
  801949:	c3                   	ret    

0080194a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80194a:	55                   	push   %ebp
  80194b:	89 e5                	mov    %esp,%ebp
  80194d:	57                   	push   %edi
  80194e:	56                   	push   %esi
  80194f:	53                   	push   %ebx
  801950:	83 ec 4c             	sub    $0x4c,%esp
  801953:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801956:	8b 75 10             	mov    0x10(%ebp),%esi
  801959:	eb 12                	jmp    80196d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80195b:	85 c0                	test   %eax,%eax
  80195d:	0f 84 6b 03 00 00    	je     801cce <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  801963:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801967:	89 04 24             	mov    %eax,(%esp)
  80196a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80196d:	0f b6 06             	movzbl (%esi),%eax
  801970:	46                   	inc    %esi
  801971:	83 f8 25             	cmp    $0x25,%eax
  801974:	75 e5                	jne    80195b <vprintfmt+0x11>
  801976:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80197a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801981:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801986:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80198d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801992:	eb 26                	jmp    8019ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801994:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801997:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80199b:	eb 1d                	jmp    8019ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80199d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8019a0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8019a4:	eb 14                	jmp    8019ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8019a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8019b0:	eb 08                	jmp    8019ba <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8019b2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8019b5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019ba:	0f b6 06             	movzbl (%esi),%eax
  8019bd:	8d 56 01             	lea    0x1(%esi),%edx
  8019c0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8019c3:	8a 16                	mov    (%esi),%dl
  8019c5:	83 ea 23             	sub    $0x23,%edx
  8019c8:	80 fa 55             	cmp    $0x55,%dl
  8019cb:	0f 87 e1 02 00 00    	ja     801cb2 <vprintfmt+0x368>
  8019d1:	0f b6 d2             	movzbl %dl,%edx
  8019d4:	ff 24 95 60 27 80 00 	jmp    *0x802760(,%edx,4)
  8019db:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8019de:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8019e3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8019e6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8019ea:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8019ed:	8d 50 d0             	lea    -0x30(%eax),%edx
  8019f0:	83 fa 09             	cmp    $0x9,%edx
  8019f3:	77 2a                	ja     801a1f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8019f5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8019f6:	eb eb                	jmp    8019e3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8019f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019fb:	8d 50 04             	lea    0x4(%eax),%edx
  8019fe:	89 55 14             	mov    %edx,0x14(%ebp)
  801a01:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a03:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801a06:	eb 17                	jmp    801a1f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801a08:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801a0c:	78 98                	js     8019a6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a0e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801a11:	eb a7                	jmp    8019ba <vprintfmt+0x70>
  801a13:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801a16:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801a1d:	eb 9b                	jmp    8019ba <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801a1f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801a23:	79 95                	jns    8019ba <vprintfmt+0x70>
  801a25:	eb 8b                	jmp    8019b2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801a27:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a28:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801a2b:	eb 8d                	jmp    8019ba <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801a2d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a30:	8d 50 04             	lea    0x4(%eax),%edx
  801a33:	89 55 14             	mov    %edx,0x14(%ebp)
  801a36:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a3a:	8b 00                	mov    (%eax),%eax
  801a3c:	89 04 24             	mov    %eax,(%esp)
  801a3f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a42:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801a45:	e9 23 ff ff ff       	jmp    80196d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801a4a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a4d:	8d 50 04             	lea    0x4(%eax),%edx
  801a50:	89 55 14             	mov    %edx,0x14(%ebp)
  801a53:	8b 00                	mov    (%eax),%eax
  801a55:	85 c0                	test   %eax,%eax
  801a57:	79 02                	jns    801a5b <vprintfmt+0x111>
  801a59:	f7 d8                	neg    %eax
  801a5b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801a5d:	83 f8 10             	cmp    $0x10,%eax
  801a60:	7f 0b                	jg     801a6d <vprintfmt+0x123>
  801a62:	8b 04 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%eax
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	75 23                	jne    801a90 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801a6d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801a71:	c7 44 24 08 3b 26 80 	movl   $0x80263b,0x8(%esp)
  801a78:	00 
  801a79:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801a80:	89 04 24             	mov    %eax,(%esp)
  801a83:	e8 9a fe ff ff       	call   801922 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a88:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801a8b:	e9 dd fe ff ff       	jmp    80196d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801a90:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a94:	c7 44 24 08 81 25 80 	movl   $0x802581,0x8(%esp)
  801a9b:	00 
  801a9c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aa0:	8b 55 08             	mov    0x8(%ebp),%edx
  801aa3:	89 14 24             	mov    %edx,(%esp)
  801aa6:	e8 77 fe ff ff       	call   801922 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801aae:	e9 ba fe ff ff       	jmp    80196d <vprintfmt+0x23>
  801ab3:	89 f9                	mov    %edi,%ecx
  801ab5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ab8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801abb:	8b 45 14             	mov    0x14(%ebp),%eax
  801abe:	8d 50 04             	lea    0x4(%eax),%edx
  801ac1:	89 55 14             	mov    %edx,0x14(%ebp)
  801ac4:	8b 30                	mov    (%eax),%esi
  801ac6:	85 f6                	test   %esi,%esi
  801ac8:	75 05                	jne    801acf <vprintfmt+0x185>
				p = "(null)";
  801aca:	be 34 26 80 00       	mov    $0x802634,%esi
			if (width > 0 && padc != '-')
  801acf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801ad3:	0f 8e 84 00 00 00    	jle    801b5d <vprintfmt+0x213>
  801ad9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801add:	74 7e                	je     801b5d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  801adf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ae3:	89 34 24             	mov    %esi,(%esp)
  801ae6:	e8 8b 02 00 00       	call   801d76 <strnlen>
  801aeb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801aee:	29 c2                	sub    %eax,%edx
  801af0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801af3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801af7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801afa:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801afd:	89 de                	mov    %ebx,%esi
  801aff:	89 d3                	mov    %edx,%ebx
  801b01:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b03:	eb 0b                	jmp    801b10 <vprintfmt+0x1c6>
					putch(padc, putdat);
  801b05:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b09:	89 3c 24             	mov    %edi,(%esp)
  801b0c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b0f:	4b                   	dec    %ebx
  801b10:	85 db                	test   %ebx,%ebx
  801b12:	7f f1                	jg     801b05 <vprintfmt+0x1bb>
  801b14:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801b17:	89 f3                	mov    %esi,%ebx
  801b19:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801b1c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b1f:	85 c0                	test   %eax,%eax
  801b21:	79 05                	jns    801b28 <vprintfmt+0x1de>
  801b23:	b8 00 00 00 00       	mov    $0x0,%eax
  801b28:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b2b:	29 c2                	sub    %eax,%edx
  801b2d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801b30:	eb 2b                	jmp    801b5d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801b32:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b36:	74 18                	je     801b50 <vprintfmt+0x206>
  801b38:	8d 50 e0             	lea    -0x20(%eax),%edx
  801b3b:	83 fa 5e             	cmp    $0x5e,%edx
  801b3e:	76 10                	jbe    801b50 <vprintfmt+0x206>
					putch('?', putdat);
  801b40:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b44:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801b4b:	ff 55 08             	call   *0x8(%ebp)
  801b4e:	eb 0a                	jmp    801b5a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801b50:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b54:	89 04 24             	mov    %eax,(%esp)
  801b57:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801b5a:	ff 4d e4             	decl   -0x1c(%ebp)
  801b5d:	0f be 06             	movsbl (%esi),%eax
  801b60:	46                   	inc    %esi
  801b61:	85 c0                	test   %eax,%eax
  801b63:	74 21                	je     801b86 <vprintfmt+0x23c>
  801b65:	85 ff                	test   %edi,%edi
  801b67:	78 c9                	js     801b32 <vprintfmt+0x1e8>
  801b69:	4f                   	dec    %edi
  801b6a:	79 c6                	jns    801b32 <vprintfmt+0x1e8>
  801b6c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b6f:	89 de                	mov    %ebx,%esi
  801b71:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801b74:	eb 18                	jmp    801b8e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801b76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b7a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801b81:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801b83:	4b                   	dec    %ebx
  801b84:	eb 08                	jmp    801b8e <vprintfmt+0x244>
  801b86:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b89:	89 de                	mov    %ebx,%esi
  801b8b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801b8e:	85 db                	test   %ebx,%ebx
  801b90:	7f e4                	jg     801b76 <vprintfmt+0x22c>
  801b92:	89 7d 08             	mov    %edi,0x8(%ebp)
  801b95:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b97:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801b9a:	e9 ce fd ff ff       	jmp    80196d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801b9f:	83 f9 01             	cmp    $0x1,%ecx
  801ba2:	7e 10                	jle    801bb4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801ba4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ba7:	8d 50 08             	lea    0x8(%eax),%edx
  801baa:	89 55 14             	mov    %edx,0x14(%ebp)
  801bad:	8b 30                	mov    (%eax),%esi
  801baf:	8b 78 04             	mov    0x4(%eax),%edi
  801bb2:	eb 26                	jmp    801bda <vprintfmt+0x290>
	else if (lflag)
  801bb4:	85 c9                	test   %ecx,%ecx
  801bb6:	74 12                	je     801bca <vprintfmt+0x280>
		return va_arg(*ap, long);
  801bb8:	8b 45 14             	mov    0x14(%ebp),%eax
  801bbb:	8d 50 04             	lea    0x4(%eax),%edx
  801bbe:	89 55 14             	mov    %edx,0x14(%ebp)
  801bc1:	8b 30                	mov    (%eax),%esi
  801bc3:	89 f7                	mov    %esi,%edi
  801bc5:	c1 ff 1f             	sar    $0x1f,%edi
  801bc8:	eb 10                	jmp    801bda <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801bca:	8b 45 14             	mov    0x14(%ebp),%eax
  801bcd:	8d 50 04             	lea    0x4(%eax),%edx
  801bd0:	89 55 14             	mov    %edx,0x14(%ebp)
  801bd3:	8b 30                	mov    (%eax),%esi
  801bd5:	89 f7                	mov    %esi,%edi
  801bd7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801bda:	85 ff                	test   %edi,%edi
  801bdc:	78 0a                	js     801be8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801bde:	b8 0a 00 00 00       	mov    $0xa,%eax
  801be3:	e9 8c 00 00 00       	jmp    801c74 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801be8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bec:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801bf3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801bf6:	f7 de                	neg    %esi
  801bf8:	83 d7 00             	adc    $0x0,%edi
  801bfb:	f7 df                	neg    %edi
			}
			base = 10;
  801bfd:	b8 0a 00 00 00       	mov    $0xa,%eax
  801c02:	eb 70                	jmp    801c74 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801c04:	89 ca                	mov    %ecx,%edx
  801c06:	8d 45 14             	lea    0x14(%ebp),%eax
  801c09:	e8 c0 fc ff ff       	call   8018ce <getuint>
  801c0e:	89 c6                	mov    %eax,%esi
  801c10:	89 d7                	mov    %edx,%edi
			base = 10;
  801c12:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801c17:	eb 5b                	jmp    801c74 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  801c19:	89 ca                	mov    %ecx,%edx
  801c1b:	8d 45 14             	lea    0x14(%ebp),%eax
  801c1e:	e8 ab fc ff ff       	call   8018ce <getuint>
  801c23:	89 c6                	mov    %eax,%esi
  801c25:	89 d7                	mov    %edx,%edi
			base = 8;
  801c27:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801c2c:	eb 46                	jmp    801c74 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  801c2e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c32:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801c39:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801c3c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c40:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801c47:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801c4a:	8b 45 14             	mov    0x14(%ebp),%eax
  801c4d:	8d 50 04             	lea    0x4(%eax),%edx
  801c50:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801c53:	8b 30                	mov    (%eax),%esi
  801c55:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801c5a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801c5f:	eb 13                	jmp    801c74 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801c61:	89 ca                	mov    %ecx,%edx
  801c63:	8d 45 14             	lea    0x14(%ebp),%eax
  801c66:	e8 63 fc ff ff       	call   8018ce <getuint>
  801c6b:	89 c6                	mov    %eax,%esi
  801c6d:	89 d7                	mov    %edx,%edi
			base = 16;
  801c6f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801c74:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801c78:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c7c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c7f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c83:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c87:	89 34 24             	mov    %esi,(%esp)
  801c8a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c8e:	89 da                	mov    %ebx,%edx
  801c90:	8b 45 08             	mov    0x8(%ebp),%eax
  801c93:	e8 6c fb ff ff       	call   801804 <printnum>
			break;
  801c98:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801c9b:	e9 cd fc ff ff       	jmp    80196d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801ca0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ca4:	89 04 24             	mov    %eax,(%esp)
  801ca7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801caa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801cad:	e9 bb fc ff ff       	jmp    80196d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801cb2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cb6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801cbd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801cc0:	eb 01                	jmp    801cc3 <vprintfmt+0x379>
  801cc2:	4e                   	dec    %esi
  801cc3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801cc7:	75 f9                	jne    801cc2 <vprintfmt+0x378>
  801cc9:	e9 9f fc ff ff       	jmp    80196d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801cce:	83 c4 4c             	add    $0x4c,%esp
  801cd1:	5b                   	pop    %ebx
  801cd2:	5e                   	pop    %esi
  801cd3:	5f                   	pop    %edi
  801cd4:	5d                   	pop    %ebp
  801cd5:	c3                   	ret    

00801cd6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	83 ec 28             	sub    $0x28,%esp
  801cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ce2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ce5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ce9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801cec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	74 30                	je     801d27 <vsnprintf+0x51>
  801cf7:	85 d2                	test   %edx,%edx
  801cf9:	7e 33                	jle    801d2e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801cfb:	8b 45 14             	mov    0x14(%ebp),%eax
  801cfe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d02:	8b 45 10             	mov    0x10(%ebp),%eax
  801d05:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d09:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d10:	c7 04 24 08 19 80 00 	movl   $0x801908,(%esp)
  801d17:	e8 2e fc ff ff       	call   80194a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801d1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d1f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801d22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d25:	eb 0c                	jmp    801d33 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801d27:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d2c:	eb 05                	jmp    801d33 <vsnprintf+0x5d>
  801d2e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801d33:	c9                   	leave  
  801d34:	c3                   	ret    

00801d35 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801d3b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801d3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d42:	8b 45 10             	mov    0x10(%ebp),%eax
  801d45:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d49:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d50:	8b 45 08             	mov    0x8(%ebp),%eax
  801d53:	89 04 24             	mov    %eax,(%esp)
  801d56:	e8 7b ff ff ff       	call   801cd6 <vsnprintf>
	va_end(ap);

	return rc;
}
  801d5b:	c9                   	leave  
  801d5c:	c3                   	ret    
  801d5d:	00 00                	add    %al,(%eax)
	...

00801d60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801d66:	b8 00 00 00 00       	mov    $0x0,%eax
  801d6b:	eb 01                	jmp    801d6e <strlen+0xe>
		n++;
  801d6d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801d6e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801d72:	75 f9                	jne    801d6d <strlen+0xd>
		n++;
	return n;
}
  801d74:	5d                   	pop    %ebp
  801d75:	c3                   	ret    

00801d76 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801d7c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801d7f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d84:	eb 01                	jmp    801d87 <strnlen+0x11>
		n++;
  801d86:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801d87:	39 d0                	cmp    %edx,%eax
  801d89:	74 06                	je     801d91 <strnlen+0x1b>
  801d8b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801d8f:	75 f5                	jne    801d86 <strnlen+0x10>
		n++;
	return n;
}
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    

00801d93 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	53                   	push   %ebx
  801d97:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801d9d:	ba 00 00 00 00       	mov    $0x0,%edx
  801da2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801da5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801da8:	42                   	inc    %edx
  801da9:	84 c9                	test   %cl,%cl
  801dab:	75 f5                	jne    801da2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801dad:	5b                   	pop    %ebx
  801dae:	5d                   	pop    %ebp
  801daf:	c3                   	ret    

00801db0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	53                   	push   %ebx
  801db4:	83 ec 08             	sub    $0x8,%esp
  801db7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801dba:	89 1c 24             	mov    %ebx,(%esp)
  801dbd:	e8 9e ff ff ff       	call   801d60 <strlen>
	strcpy(dst + len, src);
  801dc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc9:	01 d8                	add    %ebx,%eax
  801dcb:	89 04 24             	mov    %eax,(%esp)
  801dce:	e8 c0 ff ff ff       	call   801d93 <strcpy>
	return dst;
}
  801dd3:	89 d8                	mov    %ebx,%eax
  801dd5:	83 c4 08             	add    $0x8,%esp
  801dd8:	5b                   	pop    %ebx
  801dd9:	5d                   	pop    %ebp
  801dda:	c3                   	ret    

00801ddb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	56                   	push   %esi
  801ddf:	53                   	push   %ebx
  801de0:	8b 45 08             	mov    0x8(%ebp),%eax
  801de3:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801de9:	b9 00 00 00 00       	mov    $0x0,%ecx
  801dee:	eb 0c                	jmp    801dfc <strncpy+0x21>
		*dst++ = *src;
  801df0:	8a 1a                	mov    (%edx),%bl
  801df2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801df5:	80 3a 01             	cmpb   $0x1,(%edx)
  801df8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801dfb:	41                   	inc    %ecx
  801dfc:	39 f1                	cmp    %esi,%ecx
  801dfe:	75 f0                	jne    801df0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801e00:	5b                   	pop    %ebx
  801e01:	5e                   	pop    %esi
  801e02:	5d                   	pop    %ebp
  801e03:	c3                   	ret    

00801e04 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	56                   	push   %esi
  801e08:	53                   	push   %ebx
  801e09:	8b 75 08             	mov    0x8(%ebp),%esi
  801e0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e0f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e12:	85 d2                	test   %edx,%edx
  801e14:	75 0a                	jne    801e20 <strlcpy+0x1c>
  801e16:	89 f0                	mov    %esi,%eax
  801e18:	eb 1a                	jmp    801e34 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801e1a:	88 18                	mov    %bl,(%eax)
  801e1c:	40                   	inc    %eax
  801e1d:	41                   	inc    %ecx
  801e1e:	eb 02                	jmp    801e22 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e20:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801e22:	4a                   	dec    %edx
  801e23:	74 0a                	je     801e2f <strlcpy+0x2b>
  801e25:	8a 19                	mov    (%ecx),%bl
  801e27:	84 db                	test   %bl,%bl
  801e29:	75 ef                	jne    801e1a <strlcpy+0x16>
  801e2b:	89 c2                	mov    %eax,%edx
  801e2d:	eb 02                	jmp    801e31 <strlcpy+0x2d>
  801e2f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801e31:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801e34:	29 f0                	sub    %esi,%eax
}
  801e36:	5b                   	pop    %ebx
  801e37:	5e                   	pop    %esi
  801e38:	5d                   	pop    %ebp
  801e39:	c3                   	ret    

00801e3a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801e3a:	55                   	push   %ebp
  801e3b:	89 e5                	mov    %esp,%ebp
  801e3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e40:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801e43:	eb 02                	jmp    801e47 <strcmp+0xd>
		p++, q++;
  801e45:	41                   	inc    %ecx
  801e46:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801e47:	8a 01                	mov    (%ecx),%al
  801e49:	84 c0                	test   %al,%al
  801e4b:	74 04                	je     801e51 <strcmp+0x17>
  801e4d:	3a 02                	cmp    (%edx),%al
  801e4f:	74 f4                	je     801e45 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801e51:	0f b6 c0             	movzbl %al,%eax
  801e54:	0f b6 12             	movzbl (%edx),%edx
  801e57:	29 d0                	sub    %edx,%eax
}
  801e59:	5d                   	pop    %ebp
  801e5a:	c3                   	ret    

00801e5b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	53                   	push   %ebx
  801e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e65:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801e68:	eb 03                	jmp    801e6d <strncmp+0x12>
		n--, p++, q++;
  801e6a:	4a                   	dec    %edx
  801e6b:	40                   	inc    %eax
  801e6c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801e6d:	85 d2                	test   %edx,%edx
  801e6f:	74 14                	je     801e85 <strncmp+0x2a>
  801e71:	8a 18                	mov    (%eax),%bl
  801e73:	84 db                	test   %bl,%bl
  801e75:	74 04                	je     801e7b <strncmp+0x20>
  801e77:	3a 19                	cmp    (%ecx),%bl
  801e79:	74 ef                	je     801e6a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801e7b:	0f b6 00             	movzbl (%eax),%eax
  801e7e:	0f b6 11             	movzbl (%ecx),%edx
  801e81:	29 d0                	sub    %edx,%eax
  801e83:	eb 05                	jmp    801e8a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801e85:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801e8a:	5b                   	pop    %ebx
  801e8b:	5d                   	pop    %ebp
  801e8c:	c3                   	ret    

00801e8d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	8b 45 08             	mov    0x8(%ebp),%eax
  801e93:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801e96:	eb 05                	jmp    801e9d <strchr+0x10>
		if (*s == c)
  801e98:	38 ca                	cmp    %cl,%dl
  801e9a:	74 0c                	je     801ea8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801e9c:	40                   	inc    %eax
  801e9d:	8a 10                	mov    (%eax),%dl
  801e9f:	84 d2                	test   %dl,%dl
  801ea1:	75 f5                	jne    801e98 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801ea3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ea8:	5d                   	pop    %ebp
  801ea9:	c3                   	ret    

00801eaa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801eb3:	eb 05                	jmp    801eba <strfind+0x10>
		if (*s == c)
  801eb5:	38 ca                	cmp    %cl,%dl
  801eb7:	74 07                	je     801ec0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801eb9:	40                   	inc    %eax
  801eba:	8a 10                	mov    (%eax),%dl
  801ebc:	84 d2                	test   %dl,%dl
  801ebe:	75 f5                	jne    801eb5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801ec0:	5d                   	pop    %ebp
  801ec1:	c3                   	ret    

00801ec2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ec2:	55                   	push   %ebp
  801ec3:	89 e5                	mov    %esp,%ebp
  801ec5:	57                   	push   %edi
  801ec6:	56                   	push   %esi
  801ec7:	53                   	push   %ebx
  801ec8:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ece:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ed1:	85 c9                	test   %ecx,%ecx
  801ed3:	74 30                	je     801f05 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ed5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801edb:	75 25                	jne    801f02 <memset+0x40>
  801edd:	f6 c1 03             	test   $0x3,%cl
  801ee0:	75 20                	jne    801f02 <memset+0x40>
		c &= 0xFF;
  801ee2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ee5:	89 d3                	mov    %edx,%ebx
  801ee7:	c1 e3 08             	shl    $0x8,%ebx
  801eea:	89 d6                	mov    %edx,%esi
  801eec:	c1 e6 18             	shl    $0x18,%esi
  801eef:	89 d0                	mov    %edx,%eax
  801ef1:	c1 e0 10             	shl    $0x10,%eax
  801ef4:	09 f0                	or     %esi,%eax
  801ef6:	09 d0                	or     %edx,%eax
  801ef8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801efa:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801efd:	fc                   	cld    
  801efe:	f3 ab                	rep stos %eax,%es:(%edi)
  801f00:	eb 03                	jmp    801f05 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801f02:	fc                   	cld    
  801f03:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801f05:	89 f8                	mov    %edi,%eax
  801f07:	5b                   	pop    %ebx
  801f08:	5e                   	pop    %esi
  801f09:	5f                   	pop    %edi
  801f0a:	5d                   	pop    %ebp
  801f0b:	c3                   	ret    

00801f0c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	57                   	push   %edi
  801f10:	56                   	push   %esi
  801f11:	8b 45 08             	mov    0x8(%ebp),%eax
  801f14:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f17:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801f1a:	39 c6                	cmp    %eax,%esi
  801f1c:	73 34                	jae    801f52 <memmove+0x46>
  801f1e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801f21:	39 d0                	cmp    %edx,%eax
  801f23:	73 2d                	jae    801f52 <memmove+0x46>
		s += n;
		d += n;
  801f25:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f28:	f6 c2 03             	test   $0x3,%dl
  801f2b:	75 1b                	jne    801f48 <memmove+0x3c>
  801f2d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801f33:	75 13                	jne    801f48 <memmove+0x3c>
  801f35:	f6 c1 03             	test   $0x3,%cl
  801f38:	75 0e                	jne    801f48 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801f3a:	83 ef 04             	sub    $0x4,%edi
  801f3d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801f40:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801f43:	fd                   	std    
  801f44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f46:	eb 07                	jmp    801f4f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801f48:	4f                   	dec    %edi
  801f49:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801f4c:	fd                   	std    
  801f4d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801f4f:	fc                   	cld    
  801f50:	eb 20                	jmp    801f72 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f52:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801f58:	75 13                	jne    801f6d <memmove+0x61>
  801f5a:	a8 03                	test   $0x3,%al
  801f5c:	75 0f                	jne    801f6d <memmove+0x61>
  801f5e:	f6 c1 03             	test   $0x3,%cl
  801f61:	75 0a                	jne    801f6d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801f63:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801f66:	89 c7                	mov    %eax,%edi
  801f68:	fc                   	cld    
  801f69:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f6b:	eb 05                	jmp    801f72 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801f6d:	89 c7                	mov    %eax,%edi
  801f6f:	fc                   	cld    
  801f70:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801f72:	5e                   	pop    %esi
  801f73:	5f                   	pop    %edi
  801f74:	5d                   	pop    %ebp
  801f75:	c3                   	ret    

00801f76 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801f76:	55                   	push   %ebp
  801f77:	89 e5                	mov    %esp,%ebp
  801f79:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801f7c:	8b 45 10             	mov    0x10(%ebp),%eax
  801f7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f83:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8d:	89 04 24             	mov    %eax,(%esp)
  801f90:	e8 77 ff ff ff       	call   801f0c <memmove>
}
  801f95:	c9                   	leave  
  801f96:	c3                   	ret    

00801f97 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	57                   	push   %edi
  801f9b:	56                   	push   %esi
  801f9c:	53                   	push   %ebx
  801f9d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fa0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fa3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801fa6:	ba 00 00 00 00       	mov    $0x0,%edx
  801fab:	eb 16                	jmp    801fc3 <memcmp+0x2c>
		if (*s1 != *s2)
  801fad:	8a 04 17             	mov    (%edi,%edx,1),%al
  801fb0:	42                   	inc    %edx
  801fb1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801fb5:	38 c8                	cmp    %cl,%al
  801fb7:	74 0a                	je     801fc3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801fb9:	0f b6 c0             	movzbl %al,%eax
  801fbc:	0f b6 c9             	movzbl %cl,%ecx
  801fbf:	29 c8                	sub    %ecx,%eax
  801fc1:	eb 09                	jmp    801fcc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801fc3:	39 da                	cmp    %ebx,%edx
  801fc5:	75 e6                	jne    801fad <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801fc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fcc:	5b                   	pop    %ebx
  801fcd:	5e                   	pop    %esi
  801fce:	5f                   	pop    %edi
  801fcf:	5d                   	pop    %ebp
  801fd0:	c3                   	ret    

00801fd1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801fda:	89 c2                	mov    %eax,%edx
  801fdc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801fdf:	eb 05                	jmp    801fe6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801fe1:	38 08                	cmp    %cl,(%eax)
  801fe3:	74 05                	je     801fea <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801fe5:	40                   	inc    %eax
  801fe6:	39 d0                	cmp    %edx,%eax
  801fe8:	72 f7                	jb     801fe1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801fea:	5d                   	pop    %ebp
  801feb:	c3                   	ret    

00801fec <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801fec:	55                   	push   %ebp
  801fed:	89 e5                	mov    %esp,%ebp
  801fef:	57                   	push   %edi
  801ff0:	56                   	push   %esi
  801ff1:	53                   	push   %ebx
  801ff2:	8b 55 08             	mov    0x8(%ebp),%edx
  801ff5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ff8:	eb 01                	jmp    801ffb <strtol+0xf>
		s++;
  801ffa:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ffb:	8a 02                	mov    (%edx),%al
  801ffd:	3c 20                	cmp    $0x20,%al
  801fff:	74 f9                	je     801ffa <strtol+0xe>
  802001:	3c 09                	cmp    $0x9,%al
  802003:	74 f5                	je     801ffa <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802005:	3c 2b                	cmp    $0x2b,%al
  802007:	75 08                	jne    802011 <strtol+0x25>
		s++;
  802009:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80200a:	bf 00 00 00 00       	mov    $0x0,%edi
  80200f:	eb 13                	jmp    802024 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802011:	3c 2d                	cmp    $0x2d,%al
  802013:	75 0a                	jne    80201f <strtol+0x33>
		s++, neg = 1;
  802015:	8d 52 01             	lea    0x1(%edx),%edx
  802018:	bf 01 00 00 00       	mov    $0x1,%edi
  80201d:	eb 05                	jmp    802024 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80201f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802024:	85 db                	test   %ebx,%ebx
  802026:	74 05                	je     80202d <strtol+0x41>
  802028:	83 fb 10             	cmp    $0x10,%ebx
  80202b:	75 28                	jne    802055 <strtol+0x69>
  80202d:	8a 02                	mov    (%edx),%al
  80202f:	3c 30                	cmp    $0x30,%al
  802031:	75 10                	jne    802043 <strtol+0x57>
  802033:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802037:	75 0a                	jne    802043 <strtol+0x57>
		s += 2, base = 16;
  802039:	83 c2 02             	add    $0x2,%edx
  80203c:	bb 10 00 00 00       	mov    $0x10,%ebx
  802041:	eb 12                	jmp    802055 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  802043:	85 db                	test   %ebx,%ebx
  802045:	75 0e                	jne    802055 <strtol+0x69>
  802047:	3c 30                	cmp    $0x30,%al
  802049:	75 05                	jne    802050 <strtol+0x64>
		s++, base = 8;
  80204b:	42                   	inc    %edx
  80204c:	b3 08                	mov    $0x8,%bl
  80204e:	eb 05                	jmp    802055 <strtol+0x69>
	else if (base == 0)
		base = 10;
  802050:	bb 0a 00 00 00       	mov    $0xa,%ebx
  802055:	b8 00 00 00 00       	mov    $0x0,%eax
  80205a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80205c:	8a 0a                	mov    (%edx),%cl
  80205e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  802061:	80 fb 09             	cmp    $0x9,%bl
  802064:	77 08                	ja     80206e <strtol+0x82>
			dig = *s - '0';
  802066:	0f be c9             	movsbl %cl,%ecx
  802069:	83 e9 30             	sub    $0x30,%ecx
  80206c:	eb 1e                	jmp    80208c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80206e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  802071:	80 fb 19             	cmp    $0x19,%bl
  802074:	77 08                	ja     80207e <strtol+0x92>
			dig = *s - 'a' + 10;
  802076:	0f be c9             	movsbl %cl,%ecx
  802079:	83 e9 57             	sub    $0x57,%ecx
  80207c:	eb 0e                	jmp    80208c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80207e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  802081:	80 fb 19             	cmp    $0x19,%bl
  802084:	77 12                	ja     802098 <strtol+0xac>
			dig = *s - 'A' + 10;
  802086:	0f be c9             	movsbl %cl,%ecx
  802089:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80208c:	39 f1                	cmp    %esi,%ecx
  80208e:	7d 0c                	jge    80209c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  802090:	42                   	inc    %edx
  802091:	0f af c6             	imul   %esi,%eax
  802094:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  802096:	eb c4                	jmp    80205c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  802098:	89 c1                	mov    %eax,%ecx
  80209a:	eb 02                	jmp    80209e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80209c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  80209e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8020a2:	74 05                	je     8020a9 <strtol+0xbd>
		*endptr = (char *) s;
  8020a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8020a7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8020a9:	85 ff                	test   %edi,%edi
  8020ab:	74 04                	je     8020b1 <strtol+0xc5>
  8020ad:	89 c8                	mov    %ecx,%eax
  8020af:	f7 d8                	neg    %eax
}
  8020b1:	5b                   	pop    %ebx
  8020b2:	5e                   	pop    %esi
  8020b3:	5f                   	pop    %edi
  8020b4:	5d                   	pop    %ebp
  8020b5:	c3                   	ret    
	...

008020b8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	56                   	push   %esi
  8020bc:	53                   	push   %ebx
  8020bd:	83 ec 10             	sub    $0x10,%esp
  8020c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c6:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	74 0a                	je     8020d7 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8020cd:	89 04 24             	mov    %eax,(%esp)
  8020d0:	e8 c2 e2 ff ff       	call   800397 <sys_ipc_recv>
  8020d5:	eb 0c                	jmp    8020e3 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8020d7:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8020de:	e8 b4 e2 ff ff       	call   800397 <sys_ipc_recv>
	}
	if (r < 0)
  8020e3:	85 c0                	test   %eax,%eax
  8020e5:	79 16                	jns    8020fd <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8020e7:	85 db                	test   %ebx,%ebx
  8020e9:	74 06                	je     8020f1 <ipc_recv+0x39>
  8020eb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8020f1:	85 f6                	test   %esi,%esi
  8020f3:	74 2c                	je     802121 <ipc_recv+0x69>
  8020f5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8020fb:	eb 24                	jmp    802121 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8020fd:	85 db                	test   %ebx,%ebx
  8020ff:	74 0a                	je     80210b <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802101:	a1 08 40 80 00       	mov    0x804008,%eax
  802106:	8b 40 74             	mov    0x74(%eax),%eax
  802109:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  80210b:	85 f6                	test   %esi,%esi
  80210d:	74 0a                	je     802119 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  80210f:	a1 08 40 80 00       	mov    0x804008,%eax
  802114:	8b 40 78             	mov    0x78(%eax),%eax
  802117:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802119:	a1 08 40 80 00       	mov    0x804008,%eax
  80211e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802121:	83 c4 10             	add    $0x10,%esp
  802124:	5b                   	pop    %ebx
  802125:	5e                   	pop    %esi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    

00802128 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802128:	55                   	push   %ebp
  802129:	89 e5                	mov    %esp,%ebp
  80212b:	57                   	push   %edi
  80212c:	56                   	push   %esi
  80212d:	53                   	push   %ebx
  80212e:	83 ec 1c             	sub    $0x1c,%esp
  802131:	8b 75 08             	mov    0x8(%ebp),%esi
  802134:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802137:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  80213a:	85 db                	test   %ebx,%ebx
  80213c:	74 19                	je     802157 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  80213e:	8b 45 14             	mov    0x14(%ebp),%eax
  802141:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802145:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802149:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80214d:	89 34 24             	mov    %esi,(%esp)
  802150:	e8 1f e2 ff ff       	call   800374 <sys_ipc_try_send>
  802155:	eb 1c                	jmp    802173 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  802157:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80215e:	00 
  80215f:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802166:	ee 
  802167:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80216b:	89 34 24             	mov    %esi,(%esp)
  80216e:	e8 01 e2 ff ff       	call   800374 <sys_ipc_try_send>
		}
		if (r == 0)
  802173:	85 c0                	test   %eax,%eax
  802175:	74 2c                	je     8021a3 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802177:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80217a:	74 20                	je     80219c <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  80217c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802180:	c7 44 24 08 24 29 80 	movl   $0x802924,0x8(%esp)
  802187:	00 
  802188:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80218f:	00 
  802190:	c7 04 24 37 29 80 00 	movl   $0x802937,(%esp)
  802197:	e8 54 f5 ff ff       	call   8016f0 <_panic>
		}
		sys_yield();
  80219c:	e8 c1 df ff ff       	call   800162 <sys_yield>
	}
  8021a1:	eb 97                	jmp    80213a <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8021a3:	83 c4 1c             	add    $0x1c,%esp
  8021a6:	5b                   	pop    %ebx
  8021a7:	5e                   	pop    %esi
  8021a8:	5f                   	pop    %edi
  8021a9:	5d                   	pop    %ebp
  8021aa:	c3                   	ret    

008021ab <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021ab:	55                   	push   %ebp
  8021ac:	89 e5                	mov    %esp,%ebp
  8021ae:	53                   	push   %ebx
  8021af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8021b2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021b7:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8021be:	89 c2                	mov    %eax,%edx
  8021c0:	c1 e2 07             	shl    $0x7,%edx
  8021c3:	29 ca                	sub    %ecx,%edx
  8021c5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021cb:	8b 52 50             	mov    0x50(%edx),%edx
  8021ce:	39 da                	cmp    %ebx,%edx
  8021d0:	75 0f                	jne    8021e1 <ipc_find_env+0x36>
			return envs[i].env_id;
  8021d2:	c1 e0 07             	shl    $0x7,%eax
  8021d5:	29 c8                	sub    %ecx,%eax
  8021d7:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021dc:	8b 40 40             	mov    0x40(%eax),%eax
  8021df:	eb 0c                	jmp    8021ed <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021e1:	40                   	inc    %eax
  8021e2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021e7:	75 ce                	jne    8021b7 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021e9:	66 b8 00 00          	mov    $0x0,%ax
}
  8021ed:	5b                   	pop    %ebx
  8021ee:	5d                   	pop    %ebp
  8021ef:	c3                   	ret    

008021f0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021f0:	55                   	push   %ebp
  8021f1:	89 e5                	mov    %esp,%ebp
  8021f3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021f6:	89 c2                	mov    %eax,%edx
  8021f8:	c1 ea 16             	shr    $0x16,%edx
  8021fb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802202:	f6 c2 01             	test   $0x1,%dl
  802205:	74 1e                	je     802225 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802207:	c1 e8 0c             	shr    $0xc,%eax
  80220a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802211:	a8 01                	test   $0x1,%al
  802213:	74 17                	je     80222c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802215:	c1 e8 0c             	shr    $0xc,%eax
  802218:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80221f:	ef 
  802220:	0f b7 c0             	movzwl %ax,%eax
  802223:	eb 0c                	jmp    802231 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802225:	b8 00 00 00 00       	mov    $0x0,%eax
  80222a:	eb 05                	jmp    802231 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  80222c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802231:	5d                   	pop    %ebp
  802232:	c3                   	ret    
	...

00802234 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802234:	55                   	push   %ebp
  802235:	57                   	push   %edi
  802236:	56                   	push   %esi
  802237:	83 ec 10             	sub    $0x10,%esp
  80223a:	8b 74 24 20          	mov    0x20(%esp),%esi
  80223e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802242:	89 74 24 04          	mov    %esi,0x4(%esp)
  802246:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80224a:	89 cd                	mov    %ecx,%ebp
  80224c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802250:	85 c0                	test   %eax,%eax
  802252:	75 2c                	jne    802280 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802254:	39 f9                	cmp    %edi,%ecx
  802256:	77 68                	ja     8022c0 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802258:	85 c9                	test   %ecx,%ecx
  80225a:	75 0b                	jne    802267 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80225c:	b8 01 00 00 00       	mov    $0x1,%eax
  802261:	31 d2                	xor    %edx,%edx
  802263:	f7 f1                	div    %ecx
  802265:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802267:	31 d2                	xor    %edx,%edx
  802269:	89 f8                	mov    %edi,%eax
  80226b:	f7 f1                	div    %ecx
  80226d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80226f:	89 f0                	mov    %esi,%eax
  802271:	f7 f1                	div    %ecx
  802273:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802275:	89 f0                	mov    %esi,%eax
  802277:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802279:	83 c4 10             	add    $0x10,%esp
  80227c:	5e                   	pop    %esi
  80227d:	5f                   	pop    %edi
  80227e:	5d                   	pop    %ebp
  80227f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802280:	39 f8                	cmp    %edi,%eax
  802282:	77 2c                	ja     8022b0 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802284:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802287:	83 f6 1f             	xor    $0x1f,%esi
  80228a:	75 4c                	jne    8022d8 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80228c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80228e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802293:	72 0a                	jb     80229f <__udivdi3+0x6b>
  802295:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802299:	0f 87 ad 00 00 00    	ja     80234c <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80229f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022a4:	89 f0                	mov    %esi,%eax
  8022a6:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022a8:	83 c4 10             	add    $0x10,%esp
  8022ab:	5e                   	pop    %esi
  8022ac:	5f                   	pop    %edi
  8022ad:	5d                   	pop    %ebp
  8022ae:	c3                   	ret    
  8022af:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022b0:	31 ff                	xor    %edi,%edi
  8022b2:	31 f6                	xor    %esi,%esi
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
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022c0:	89 fa                	mov    %edi,%edx
  8022c2:	89 f0                	mov    %esi,%eax
  8022c4:	f7 f1                	div    %ecx
  8022c6:	89 c6                	mov    %eax,%esi
  8022c8:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022ca:	89 f0                	mov    %esi,%eax
  8022cc:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022ce:	83 c4 10             	add    $0x10,%esp
  8022d1:	5e                   	pop    %esi
  8022d2:	5f                   	pop    %edi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    
  8022d5:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8022d8:	89 f1                	mov    %esi,%ecx
  8022da:	d3 e0                	shl    %cl,%eax
  8022dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022e0:	b8 20 00 00 00       	mov    $0x20,%eax
  8022e5:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8022e7:	89 ea                	mov    %ebp,%edx
  8022e9:	88 c1                	mov    %al,%cl
  8022eb:	d3 ea                	shr    %cl,%edx
  8022ed:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8022f1:	09 ca                	or     %ecx,%edx
  8022f3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8022f7:	89 f1                	mov    %esi,%ecx
  8022f9:	d3 e5                	shl    %cl,%ebp
  8022fb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8022ff:	89 fd                	mov    %edi,%ebp
  802301:	88 c1                	mov    %al,%cl
  802303:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802305:	89 fa                	mov    %edi,%edx
  802307:	89 f1                	mov    %esi,%ecx
  802309:	d3 e2                	shl    %cl,%edx
  80230b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80230f:	88 c1                	mov    %al,%cl
  802311:	d3 ef                	shr    %cl,%edi
  802313:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802315:	89 f8                	mov    %edi,%eax
  802317:	89 ea                	mov    %ebp,%edx
  802319:	f7 74 24 08          	divl   0x8(%esp)
  80231d:	89 d1                	mov    %edx,%ecx
  80231f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802321:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802325:	39 d1                	cmp    %edx,%ecx
  802327:	72 17                	jb     802340 <__udivdi3+0x10c>
  802329:	74 09                	je     802334 <__udivdi3+0x100>
  80232b:	89 fe                	mov    %edi,%esi
  80232d:	31 ff                	xor    %edi,%edi
  80232f:	e9 41 ff ff ff       	jmp    802275 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802334:	8b 54 24 04          	mov    0x4(%esp),%edx
  802338:	89 f1                	mov    %esi,%ecx
  80233a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80233c:	39 c2                	cmp    %eax,%edx
  80233e:	73 eb                	jae    80232b <__udivdi3+0xf7>
		{
		  q0--;
  802340:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802343:	31 ff                	xor    %edi,%edi
  802345:	e9 2b ff ff ff       	jmp    802275 <__udivdi3+0x41>
  80234a:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80234c:	31 f6                	xor    %esi,%esi
  80234e:	e9 22 ff ff ff       	jmp    802275 <__udivdi3+0x41>
	...

00802354 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802354:	55                   	push   %ebp
  802355:	57                   	push   %edi
  802356:	56                   	push   %esi
  802357:	83 ec 20             	sub    $0x20,%esp
  80235a:	8b 44 24 30          	mov    0x30(%esp),%eax
  80235e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802362:	89 44 24 14          	mov    %eax,0x14(%esp)
  802366:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80236a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80236e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802372:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802374:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802376:	85 ed                	test   %ebp,%ebp
  802378:	75 16                	jne    802390 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80237a:	39 f1                	cmp    %esi,%ecx
  80237c:	0f 86 a6 00 00 00    	jbe    802428 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802382:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802384:	89 d0                	mov    %edx,%eax
  802386:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802388:	83 c4 20             	add    $0x20,%esp
  80238b:	5e                   	pop    %esi
  80238c:	5f                   	pop    %edi
  80238d:	5d                   	pop    %ebp
  80238e:	c3                   	ret    
  80238f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802390:	39 f5                	cmp    %esi,%ebp
  802392:	0f 87 ac 00 00 00    	ja     802444 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802398:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80239b:	83 f0 1f             	xor    $0x1f,%eax
  80239e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8023a2:	0f 84 a8 00 00 00    	je     802450 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8023a8:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023ac:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023ae:	bf 20 00 00 00       	mov    $0x20,%edi
  8023b3:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8023b7:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023bb:	89 f9                	mov    %edi,%ecx
  8023bd:	d3 e8                	shr    %cl,%eax
  8023bf:	09 e8                	or     %ebp,%eax
  8023c1:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8023c5:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023c9:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023cd:	d3 e0                	shl    %cl,%eax
  8023cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023d3:	89 f2                	mov    %esi,%edx
  8023d5:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8023d7:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023db:	d3 e0                	shl    %cl,%eax
  8023dd:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023e1:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023e5:	89 f9                	mov    %edi,%ecx
  8023e7:	d3 e8                	shr    %cl,%eax
  8023e9:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8023eb:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023ed:	89 f2                	mov    %esi,%edx
  8023ef:	f7 74 24 18          	divl   0x18(%esp)
  8023f3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8023f5:	f7 64 24 0c          	mull   0xc(%esp)
  8023f9:	89 c5                	mov    %eax,%ebp
  8023fb:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023fd:	39 d6                	cmp    %edx,%esi
  8023ff:	72 67                	jb     802468 <__umoddi3+0x114>
  802401:	74 75                	je     802478 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802403:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802407:	29 e8                	sub    %ebp,%eax
  802409:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80240b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80240f:	d3 e8                	shr    %cl,%eax
  802411:	89 f2                	mov    %esi,%edx
  802413:	89 f9                	mov    %edi,%ecx
  802415:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802417:	09 d0                	or     %edx,%eax
  802419:	89 f2                	mov    %esi,%edx
  80241b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80241f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802421:	83 c4 20             	add    $0x20,%esp
  802424:	5e                   	pop    %esi
  802425:	5f                   	pop    %edi
  802426:	5d                   	pop    %ebp
  802427:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802428:	85 c9                	test   %ecx,%ecx
  80242a:	75 0b                	jne    802437 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80242c:	b8 01 00 00 00       	mov    $0x1,%eax
  802431:	31 d2                	xor    %edx,%edx
  802433:	f7 f1                	div    %ecx
  802435:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802437:	89 f0                	mov    %esi,%eax
  802439:	31 d2                	xor    %edx,%edx
  80243b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80243d:	89 f8                	mov    %edi,%eax
  80243f:	e9 3e ff ff ff       	jmp    802382 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802444:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802446:	83 c4 20             	add    $0x20,%esp
  802449:	5e                   	pop    %esi
  80244a:	5f                   	pop    %edi
  80244b:	5d                   	pop    %ebp
  80244c:	c3                   	ret    
  80244d:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802450:	39 f5                	cmp    %esi,%ebp
  802452:	72 04                	jb     802458 <__umoddi3+0x104>
  802454:	39 f9                	cmp    %edi,%ecx
  802456:	77 06                	ja     80245e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802458:	89 f2                	mov    %esi,%edx
  80245a:	29 cf                	sub    %ecx,%edi
  80245c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80245e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802460:	83 c4 20             	add    $0x20,%esp
  802463:	5e                   	pop    %esi
  802464:	5f                   	pop    %edi
  802465:	5d                   	pop    %ebp
  802466:	c3                   	ret    
  802467:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802468:	89 d1                	mov    %edx,%ecx
  80246a:	89 c5                	mov    %eax,%ebp
  80246c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802470:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802474:	eb 8d                	jmp    802403 <__umoddi3+0xaf>
  802476:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802478:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80247c:	72 ea                	jb     802468 <__umoddi3+0x114>
  80247e:	89 f1                	mov    %esi,%ecx
  802480:	eb 81                	jmp    802403 <__umoddi3+0xaf>
