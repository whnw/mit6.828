
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80004e:	e8 ec 00 00 00       	call   80013f <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80005f:	c1 e0 07             	shl    $0x7,%eax
  800062:	29 d0                	sub    %edx,%eax
  800064:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800069:	a3 08 40 80 00       	mov    %eax,0x804008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006e:	85 f6                	test   %esi,%esi
  800070:	7e 07                	jle    800079 <libmain+0x39>
		binaryname = argv[0];
  800072:	8b 03                	mov    (%ebx),%eax
  800074:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800079:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007d:	89 34 24             	mov    %esi,(%esp)
  800080:	e8 af ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	5b                   	pop    %ebx
  80008e:	5e                   	pop    %esi
  80008f:	5d                   	pop    %ebp
  800090:	c3                   	ret    
  800091:	00 00                	add    %al,(%eax)
	...

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80009a:	e8 90 05 00 00       	call   80062f <close_all>
	sys_env_destroy(0);
  80009f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a6:	e8 42 00 00 00       	call   8000ed <sys_env_destroy>
}
  8000ab:	c9                   	leave  
  8000ac:	c3                   	ret    
  8000ad:	00 00                	add    %al,(%eax)
	...

008000b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000be:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c1:	89 c3                	mov    %eax,%ebx
  8000c3:	89 c7                	mov    %eax,%edi
  8000c5:	89 c6                	mov    %eax,%esi
  8000c7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000de:	89 d1                	mov    %edx,%ecx
  8000e0:	89 d3                	mov    %edx,%ebx
  8000e2:	89 d7                	mov    %edx,%edi
  8000e4:	89 d6                	mov    %edx,%esi
  8000e6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e8:	5b                   	pop    %ebx
  8000e9:	5e                   	pop    %esi
  8000ea:	5f                   	pop    %edi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fb:	b8 03 00 00 00       	mov    $0x3,%eax
  800100:	8b 55 08             	mov    0x8(%ebp),%edx
  800103:	89 cb                	mov    %ecx,%ebx
  800105:	89 cf                	mov    %ecx,%edi
  800107:	89 ce                	mov    %ecx,%esi
  800109:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010b:	85 c0                	test   %eax,%eax
  80010d:	7e 28                	jle    800137 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800113:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011a:	00 
  80011b:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  800122:	00 
  800123:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012a:	00 
  80012b:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  800132:	e8 b5 15 00 00       	call   8016ec <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800137:	83 c4 2c             	add    $0x2c,%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 02 00 00 00       	mov    $0x2,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_yield>:

void
sys_yield(void)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800164:	ba 00 00 00 00       	mov    $0x0,%edx
  800169:	b8 0b 00 00 00       	mov    $0xb,%eax
  80016e:	89 d1                	mov    %edx,%ecx
  800170:	89 d3                	mov    %edx,%ebx
  800172:	89 d7                	mov    %edx,%edi
  800174:	89 d6                	mov    %edx,%esi
  800176:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800178:	5b                   	pop    %ebx
  800179:	5e                   	pop    %esi
  80017a:	5f                   	pop    %edi
  80017b:	5d                   	pop    %ebp
  80017c:	c3                   	ret    

0080017d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	57                   	push   %edi
  800181:	56                   	push   %esi
  800182:	53                   	push   %ebx
  800183:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800186:	be 00 00 00 00       	mov    $0x0,%esi
  80018b:	b8 04 00 00 00       	mov    $0x4,%eax
  800190:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800193:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800196:	8b 55 08             	mov    0x8(%ebp),%edx
  800199:	89 f7                	mov    %esi,%edi
  80019b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80019d:	85 c0                	test   %eax,%eax
  80019f:	7e 28                	jle    8001c9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001a5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8001ac:	00 
  8001ad:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  8001b4:	00 
  8001b5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001bc:	00 
  8001bd:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  8001c4:	e8 23 15 00 00       	call   8016ec <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001c9:	83 c4 2c             	add    $0x2c,%esp
  8001cc:	5b                   	pop    %ebx
  8001cd:	5e                   	pop    %esi
  8001ce:	5f                   	pop    %edi
  8001cf:	5d                   	pop    %ebp
  8001d0:	c3                   	ret    

008001d1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	57                   	push   %edi
  8001d5:	56                   	push   %esi
  8001d6:	53                   	push   %ebx
  8001d7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001da:	b8 05 00 00 00       	mov    $0x5,%eax
  8001df:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f0:	85 c0                	test   %eax,%eax
  8001f2:	7e 28                	jle    80021c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8001ff:	00 
  800200:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  800207:	00 
  800208:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80020f:	00 
  800210:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  800217:	e8 d0 14 00 00       	call   8016ec <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80021c:	83 c4 2c             	add    $0x2c,%esp
  80021f:	5b                   	pop    %ebx
  800220:	5e                   	pop    %esi
  800221:	5f                   	pop    %edi
  800222:	5d                   	pop    %ebp
  800223:	c3                   	ret    

00800224 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	57                   	push   %edi
  800228:	56                   	push   %esi
  800229:	53                   	push   %ebx
  80022a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800232:	b8 06 00 00 00       	mov    $0x6,%eax
  800237:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023a:	8b 55 08             	mov    0x8(%ebp),%edx
  80023d:	89 df                	mov    %ebx,%edi
  80023f:	89 de                	mov    %ebx,%esi
  800241:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800243:	85 c0                	test   %eax,%eax
  800245:	7e 28                	jle    80026f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800247:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800252:	00 
  800253:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  80025a:	00 
  80025b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800262:	00 
  800263:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  80026a:	e8 7d 14 00 00       	call   8016ec <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80026f:	83 c4 2c             	add    $0x2c,%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	57                   	push   %edi
  80027b:	56                   	push   %esi
  80027c:	53                   	push   %ebx
  80027d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800280:	bb 00 00 00 00       	mov    $0x0,%ebx
  800285:	b8 08 00 00 00       	mov    $0x8,%eax
  80028a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028d:	8b 55 08             	mov    0x8(%ebp),%edx
  800290:	89 df                	mov    %ebx,%edi
  800292:	89 de                	mov    %ebx,%esi
  800294:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800296:	85 c0                	test   %eax,%eax
  800298:	7e 28                	jle    8002c2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80029e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8002a5:	00 
  8002a6:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  8002ad:	00 
  8002ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b5:	00 
  8002b6:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  8002bd:	e8 2a 14 00 00       	call   8016ec <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8002c2:	83 c4 2c             	add    $0x2c,%esp
  8002c5:	5b                   	pop    %ebx
  8002c6:	5e                   	pop    %esi
  8002c7:	5f                   	pop    %edi
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	57                   	push   %edi
  8002ce:	56                   	push   %esi
  8002cf:	53                   	push   %ebx
  8002d0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002d8:	b8 09 00 00 00       	mov    $0x9,%eax
  8002dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e3:	89 df                	mov    %ebx,%edi
  8002e5:	89 de                	mov    %ebx,%esi
  8002e7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002e9:	85 c0                	test   %eax,%eax
  8002eb:	7e 28                	jle    800315 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002f1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8002f8:	00 
  8002f9:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  800300:	00 
  800301:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800308:	00 
  800309:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  800310:	e8 d7 13 00 00       	call   8016ec <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800315:	83 c4 2c             	add    $0x2c,%esp
  800318:	5b                   	pop    %ebx
  800319:	5e                   	pop    %esi
  80031a:	5f                   	pop    %edi
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800326:	bb 00 00 00 00       	mov    $0x0,%ebx
  80032b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800330:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 df                	mov    %ebx,%edi
  800338:	89 de                	mov    %ebx,%esi
  80033a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80033c:	85 c0                	test   %eax,%eax
  80033e:	7e 28                	jle    800368 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800340:	89 44 24 10          	mov    %eax,0x10(%esp)
  800344:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80034b:	00 
  80034c:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  800353:	00 
  800354:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80035b:	00 
  80035c:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  800363:	e8 84 13 00 00       	call   8016ec <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800368:	83 c4 2c             	add    $0x2c,%esp
  80036b:	5b                   	pop    %ebx
  80036c:	5e                   	pop    %esi
  80036d:	5f                   	pop    %edi
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	57                   	push   %edi
  800374:	56                   	push   %esi
  800375:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800376:	be 00 00 00 00       	mov    $0x0,%esi
  80037b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800380:	8b 7d 14             	mov    0x14(%ebp),%edi
  800383:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800386:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800389:	8b 55 08             	mov    0x8(%ebp),%edx
  80038c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80038e:	5b                   	pop    %ebx
  80038f:	5e                   	pop    %esi
  800390:	5f                   	pop    %edi
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
  800396:	57                   	push   %edi
  800397:	56                   	push   %esi
  800398:	53                   	push   %ebx
  800399:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80039c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003a1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8003a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a9:	89 cb                	mov    %ecx,%ebx
  8003ab:	89 cf                	mov    %ecx,%edi
  8003ad:	89 ce                	mov    %ecx,%esi
  8003af:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8003b1:	85 c0                	test   %eax,%eax
  8003b3:	7e 28                	jle    8003dd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8003b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003b9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8003c0:	00 
  8003c1:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  8003c8:	00 
  8003c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8003d0:	00 
  8003d1:	c7 04 24 a7 24 80 00 	movl   $0x8024a7,(%esp)
  8003d8:	e8 0f 13 00 00       	call   8016ec <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8003dd:	83 c4 2c             	add    $0x2c,%esp
  8003e0:	5b                   	pop    %ebx
  8003e1:	5e                   	pop    %esi
  8003e2:	5f                   	pop    %edi
  8003e3:	5d                   	pop    %ebp
  8003e4:	c3                   	ret    

008003e5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	57                   	push   %edi
  8003e9:	56                   	push   %esi
  8003ea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8003f5:	89 d1                	mov    %edx,%ecx
  8003f7:	89 d3                	mov    %edx,%ebx
  8003f9:	89 d7                	mov    %edx,%edi
  8003fb:	89 d6                	mov    %edx,%esi
  8003fd:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8003ff:	5b                   	pop    %ebx
  800400:	5e                   	pop    %esi
  800401:	5f                   	pop    %edi
  800402:	5d                   	pop    %ebp
  800403:	c3                   	ret    

00800404 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	57                   	push   %edi
  800408:	56                   	push   %esi
  800409:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80040a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80040f:	b8 0f 00 00 00       	mov    $0xf,%eax
  800414:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800417:	8b 55 08             	mov    0x8(%ebp),%edx
  80041a:	89 df                	mov    %ebx,%edi
  80041c:	89 de                	mov    %ebx,%esi
  80041e:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800420:	5b                   	pop    %ebx
  800421:	5e                   	pop    %esi
  800422:	5f                   	pop    %edi
  800423:	5d                   	pop    %ebp
  800424:	c3                   	ret    

00800425 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  800425:	55                   	push   %ebp
  800426:	89 e5                	mov    %esp,%ebp
  800428:	57                   	push   %edi
  800429:	56                   	push   %esi
  80042a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80042b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800430:	b8 10 00 00 00       	mov    $0x10,%eax
  800435:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800438:	8b 55 08             	mov    0x8(%ebp),%edx
  80043b:	89 df                	mov    %ebx,%edi
  80043d:	89 de                	mov    %ebx,%esi
  80043f:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  800441:	5b                   	pop    %ebx
  800442:	5e                   	pop    %esi
  800443:	5f                   	pop    %edi
  800444:	5d                   	pop    %ebp
  800445:	c3                   	ret    
	...

00800448 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80044b:	8b 45 08             	mov    0x8(%ebp),%eax
  80044e:	05 00 00 00 30       	add    $0x30000000,%eax
  800453:	c1 e8 0c             	shr    $0xc,%eax
}
  800456:	5d                   	pop    %ebp
  800457:	c3                   	ret    

00800458 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800458:	55                   	push   %ebp
  800459:	89 e5                	mov    %esp,%ebp
  80045b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80045e:	8b 45 08             	mov    0x8(%ebp),%eax
  800461:	89 04 24             	mov    %eax,(%esp)
  800464:	e8 df ff ff ff       	call   800448 <fd2num>
  800469:	c1 e0 0c             	shl    $0xc,%eax
  80046c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800471:	c9                   	leave  
  800472:	c3                   	ret    

00800473 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	53                   	push   %ebx
  800477:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80047a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80047f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800481:	89 c2                	mov    %eax,%edx
  800483:	c1 ea 16             	shr    $0x16,%edx
  800486:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80048d:	f6 c2 01             	test   $0x1,%dl
  800490:	74 11                	je     8004a3 <fd_alloc+0x30>
  800492:	89 c2                	mov    %eax,%edx
  800494:	c1 ea 0c             	shr    $0xc,%edx
  800497:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80049e:	f6 c2 01             	test   $0x1,%dl
  8004a1:	75 09                	jne    8004ac <fd_alloc+0x39>
			*fd_store = fd;
  8004a3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8004a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004aa:	eb 17                	jmp    8004c3 <fd_alloc+0x50>
  8004ac:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8004b1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8004b6:	75 c7                	jne    80047f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8004b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8004be:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8004c3:	5b                   	pop    %ebx
  8004c4:	5d                   	pop    %ebp
  8004c5:	c3                   	ret    

008004c6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
  8004c9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004cc:	83 f8 1f             	cmp    $0x1f,%eax
  8004cf:	77 36                	ja     800507 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004d1:	c1 e0 0c             	shl    $0xc,%eax
  8004d4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8004d9:	89 c2                	mov    %eax,%edx
  8004db:	c1 ea 16             	shr    $0x16,%edx
  8004de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004e5:	f6 c2 01             	test   $0x1,%dl
  8004e8:	74 24                	je     80050e <fd_lookup+0x48>
  8004ea:	89 c2                	mov    %eax,%edx
  8004ec:	c1 ea 0c             	shr    $0xc,%edx
  8004ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8004f6:	f6 c2 01             	test   $0x1,%dl
  8004f9:	74 1a                	je     800515 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8004fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004fe:	89 02                	mov    %eax,(%edx)
	return 0;
  800500:	b8 00 00 00 00       	mov    $0x0,%eax
  800505:	eb 13                	jmp    80051a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800507:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80050c:	eb 0c                	jmp    80051a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80050e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800513:	eb 05                	jmp    80051a <fd_lookup+0x54>
  800515:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80051a:	5d                   	pop    %ebp
  80051b:	c3                   	ret    

0080051c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80051c:	55                   	push   %ebp
  80051d:	89 e5                	mov    %esp,%ebp
  80051f:	53                   	push   %ebx
  800520:	83 ec 14             	sub    $0x14,%esp
  800523:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800529:	ba 00 00 00 00       	mov    $0x0,%edx
  80052e:	eb 0e                	jmp    80053e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800530:	39 08                	cmp    %ecx,(%eax)
  800532:	75 09                	jne    80053d <dev_lookup+0x21>
			*dev = devtab[i];
  800534:	89 03                	mov    %eax,(%ebx)
			return 0;
  800536:	b8 00 00 00 00       	mov    $0x0,%eax
  80053b:	eb 33                	jmp    800570 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80053d:	42                   	inc    %edx
  80053e:	8b 04 95 34 25 80 00 	mov    0x802534(,%edx,4),%eax
  800545:	85 c0                	test   %eax,%eax
  800547:	75 e7                	jne    800530 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800549:	a1 08 40 80 00       	mov    0x804008,%eax
  80054e:	8b 40 48             	mov    0x48(%eax),%eax
  800551:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800555:	89 44 24 04          	mov    %eax,0x4(%esp)
  800559:	c7 04 24 b8 24 80 00 	movl   $0x8024b8,(%esp)
  800560:	e8 7f 12 00 00       	call   8017e4 <cprintf>
	*dev = 0;
  800565:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80056b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800570:	83 c4 14             	add    $0x14,%esp
  800573:	5b                   	pop    %ebx
  800574:	5d                   	pop    %ebp
  800575:	c3                   	ret    

00800576 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800576:	55                   	push   %ebp
  800577:	89 e5                	mov    %esp,%ebp
  800579:	56                   	push   %esi
  80057a:	53                   	push   %ebx
  80057b:	83 ec 30             	sub    $0x30,%esp
  80057e:	8b 75 08             	mov    0x8(%ebp),%esi
  800581:	8a 45 0c             	mov    0xc(%ebp),%al
  800584:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800587:	89 34 24             	mov    %esi,(%esp)
  80058a:	e8 b9 fe ff ff       	call   800448 <fd2num>
  80058f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800592:	89 54 24 04          	mov    %edx,0x4(%esp)
  800596:	89 04 24             	mov    %eax,(%esp)
  800599:	e8 28 ff ff ff       	call   8004c6 <fd_lookup>
  80059e:	89 c3                	mov    %eax,%ebx
  8005a0:	85 c0                	test   %eax,%eax
  8005a2:	78 05                	js     8005a9 <fd_close+0x33>
	    || fd != fd2)
  8005a4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8005a7:	74 0d                	je     8005b6 <fd_close+0x40>
		return (must_exist ? r : 0);
  8005a9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8005ad:	75 46                	jne    8005f5 <fd_close+0x7f>
  8005af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8005b4:	eb 3f                	jmp    8005f5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8005b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8005b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005bd:	8b 06                	mov    (%esi),%eax
  8005bf:	89 04 24             	mov    %eax,(%esp)
  8005c2:	e8 55 ff ff ff       	call   80051c <dev_lookup>
  8005c7:	89 c3                	mov    %eax,%ebx
  8005c9:	85 c0                	test   %eax,%eax
  8005cb:	78 18                	js     8005e5 <fd_close+0x6f>
		if (dev->dev_close)
  8005cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005d0:	8b 40 10             	mov    0x10(%eax),%eax
  8005d3:	85 c0                	test   %eax,%eax
  8005d5:	74 09                	je     8005e0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8005d7:	89 34 24             	mov    %esi,(%esp)
  8005da:	ff d0                	call   *%eax
  8005dc:	89 c3                	mov    %eax,%ebx
  8005de:	eb 05                	jmp    8005e5 <fd_close+0x6f>
		else
			r = 0;
  8005e0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8005e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005f0:	e8 2f fc ff ff       	call   800224 <sys_page_unmap>
	return r;
}
  8005f5:	89 d8                	mov    %ebx,%eax
  8005f7:	83 c4 30             	add    $0x30,%esp
  8005fa:	5b                   	pop    %ebx
  8005fb:	5e                   	pop    %esi
  8005fc:	5d                   	pop    %ebp
  8005fd:	c3                   	ret    

008005fe <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8005fe:	55                   	push   %ebp
  8005ff:	89 e5                	mov    %esp,%ebp
  800601:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800604:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800607:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060b:	8b 45 08             	mov    0x8(%ebp),%eax
  80060e:	89 04 24             	mov    %eax,(%esp)
  800611:	e8 b0 fe ff ff       	call   8004c6 <fd_lookup>
  800616:	85 c0                	test   %eax,%eax
  800618:	78 13                	js     80062d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80061a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800621:	00 
  800622:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800625:	89 04 24             	mov    %eax,(%esp)
  800628:	e8 49 ff ff ff       	call   800576 <fd_close>
}
  80062d:	c9                   	leave  
  80062e:	c3                   	ret    

0080062f <close_all>:

void
close_all(void)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	53                   	push   %ebx
  800633:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800636:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80063b:	89 1c 24             	mov    %ebx,(%esp)
  80063e:	e8 bb ff ff ff       	call   8005fe <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800643:	43                   	inc    %ebx
  800644:	83 fb 20             	cmp    $0x20,%ebx
  800647:	75 f2                	jne    80063b <close_all+0xc>
		close(i);
}
  800649:	83 c4 14             	add    $0x14,%esp
  80064c:	5b                   	pop    %ebx
  80064d:	5d                   	pop    %ebp
  80064e:	c3                   	ret    

0080064f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80064f:	55                   	push   %ebp
  800650:	89 e5                	mov    %esp,%ebp
  800652:	57                   	push   %edi
  800653:	56                   	push   %esi
  800654:	53                   	push   %ebx
  800655:	83 ec 4c             	sub    $0x4c,%esp
  800658:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80065b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80065e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800662:	8b 45 08             	mov    0x8(%ebp),%eax
  800665:	89 04 24             	mov    %eax,(%esp)
  800668:	e8 59 fe ff ff       	call   8004c6 <fd_lookup>
  80066d:	89 c3                	mov    %eax,%ebx
  80066f:	85 c0                	test   %eax,%eax
  800671:	0f 88 e3 00 00 00    	js     80075a <dup+0x10b>
		return r;
	close(newfdnum);
  800677:	89 3c 24             	mov    %edi,(%esp)
  80067a:	e8 7f ff ff ff       	call   8005fe <close>

	newfd = INDEX2FD(newfdnum);
  80067f:	89 fe                	mov    %edi,%esi
  800681:	c1 e6 0c             	shl    $0xc,%esi
  800684:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80068a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80068d:	89 04 24             	mov    %eax,(%esp)
  800690:	e8 c3 fd ff ff       	call   800458 <fd2data>
  800695:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800697:	89 34 24             	mov    %esi,(%esp)
  80069a:	e8 b9 fd ff ff       	call   800458 <fd2data>
  80069f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8006a2:	89 d8                	mov    %ebx,%eax
  8006a4:	c1 e8 16             	shr    $0x16,%eax
  8006a7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8006ae:	a8 01                	test   $0x1,%al
  8006b0:	74 46                	je     8006f8 <dup+0xa9>
  8006b2:	89 d8                	mov    %ebx,%eax
  8006b4:	c1 e8 0c             	shr    $0xc,%eax
  8006b7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8006be:	f6 c2 01             	test   $0x1,%dl
  8006c1:	74 35                	je     8006f8 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8006c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8006ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8006cf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8006e1:	00 
  8006e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006ed:	e8 df fa ff ff       	call   8001d1 <sys_page_map>
  8006f2:	89 c3                	mov    %eax,%ebx
  8006f4:	85 c0                	test   %eax,%eax
  8006f6:	78 3b                	js     800733 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8006f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006fb:	89 c2                	mov    %eax,%edx
  8006fd:	c1 ea 0c             	shr    $0xc,%edx
  800700:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800707:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80070d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800711:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800715:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80071c:	00 
  80071d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800721:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800728:	e8 a4 fa ff ff       	call   8001d1 <sys_page_map>
  80072d:	89 c3                	mov    %eax,%ebx
  80072f:	85 c0                	test   %eax,%eax
  800731:	79 25                	jns    800758 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800733:	89 74 24 04          	mov    %esi,0x4(%esp)
  800737:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80073e:	e8 e1 fa ff ff       	call   800224 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800743:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800746:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800751:	e8 ce fa ff ff       	call   800224 <sys_page_unmap>
	return r;
  800756:	eb 02                	jmp    80075a <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  800758:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80075a:	89 d8                	mov    %ebx,%eax
  80075c:	83 c4 4c             	add    $0x4c,%esp
  80075f:	5b                   	pop    %ebx
  800760:	5e                   	pop    %esi
  800761:	5f                   	pop    %edi
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	53                   	push   %ebx
  800768:	83 ec 24             	sub    $0x24,%esp
  80076b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80076e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800771:	89 44 24 04          	mov    %eax,0x4(%esp)
  800775:	89 1c 24             	mov    %ebx,(%esp)
  800778:	e8 49 fd ff ff       	call   8004c6 <fd_lookup>
  80077d:	85 c0                	test   %eax,%eax
  80077f:	78 6d                	js     8007ee <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800781:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800784:	89 44 24 04          	mov    %eax,0x4(%esp)
  800788:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80078b:	8b 00                	mov    (%eax),%eax
  80078d:	89 04 24             	mov    %eax,(%esp)
  800790:	e8 87 fd ff ff       	call   80051c <dev_lookup>
  800795:	85 c0                	test   %eax,%eax
  800797:	78 55                	js     8007ee <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800799:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80079c:	8b 50 08             	mov    0x8(%eax),%edx
  80079f:	83 e2 03             	and    $0x3,%edx
  8007a2:	83 fa 01             	cmp    $0x1,%edx
  8007a5:	75 23                	jne    8007ca <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8007a7:	a1 08 40 80 00       	mov    0x804008,%eax
  8007ac:	8b 40 48             	mov    0x48(%eax),%eax
  8007af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b7:	c7 04 24 f9 24 80 00 	movl   $0x8024f9,(%esp)
  8007be:	e8 21 10 00 00       	call   8017e4 <cprintf>
		return -E_INVAL;
  8007c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c8:	eb 24                	jmp    8007ee <read+0x8a>
	}
	if (!dev->dev_read)
  8007ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007cd:	8b 52 08             	mov    0x8(%edx),%edx
  8007d0:	85 d2                	test   %edx,%edx
  8007d2:	74 15                	je     8007e9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8007d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007d7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007e2:	89 04 24             	mov    %eax,(%esp)
  8007e5:	ff d2                	call   *%edx
  8007e7:	eb 05                	jmp    8007ee <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8007e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8007ee:	83 c4 24             	add    $0x24,%esp
  8007f1:	5b                   	pop    %ebx
  8007f2:	5d                   	pop    %ebp
  8007f3:	c3                   	ret    

008007f4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	57                   	push   %edi
  8007f8:	56                   	push   %esi
  8007f9:	53                   	push   %ebx
  8007fa:	83 ec 1c             	sub    $0x1c,%esp
  8007fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800800:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800803:	bb 00 00 00 00       	mov    $0x0,%ebx
  800808:	eb 23                	jmp    80082d <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80080a:	89 f0                	mov    %esi,%eax
  80080c:	29 d8                	sub    %ebx,%eax
  80080e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800812:	8b 45 0c             	mov    0xc(%ebp),%eax
  800815:	01 d8                	add    %ebx,%eax
  800817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081b:	89 3c 24             	mov    %edi,(%esp)
  80081e:	e8 41 ff ff ff       	call   800764 <read>
		if (m < 0)
  800823:	85 c0                	test   %eax,%eax
  800825:	78 10                	js     800837 <readn+0x43>
			return m;
		if (m == 0)
  800827:	85 c0                	test   %eax,%eax
  800829:	74 0a                	je     800835 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80082b:	01 c3                	add    %eax,%ebx
  80082d:	39 f3                	cmp    %esi,%ebx
  80082f:	72 d9                	jb     80080a <readn+0x16>
  800831:	89 d8                	mov    %ebx,%eax
  800833:	eb 02                	jmp    800837 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  800835:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  800837:	83 c4 1c             	add    $0x1c,%esp
  80083a:	5b                   	pop    %ebx
  80083b:	5e                   	pop    %esi
  80083c:	5f                   	pop    %edi
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	83 ec 24             	sub    $0x24,%esp
  800846:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800849:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800850:	89 1c 24             	mov    %ebx,(%esp)
  800853:	e8 6e fc ff ff       	call   8004c6 <fd_lookup>
  800858:	85 c0                	test   %eax,%eax
  80085a:	78 68                	js     8008c4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80085f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800863:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800866:	8b 00                	mov    (%eax),%eax
  800868:	89 04 24             	mov    %eax,(%esp)
  80086b:	e8 ac fc ff ff       	call   80051c <dev_lookup>
  800870:	85 c0                	test   %eax,%eax
  800872:	78 50                	js     8008c4 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800874:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800877:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80087b:	75 23                	jne    8008a0 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80087d:	a1 08 40 80 00       	mov    0x804008,%eax
  800882:	8b 40 48             	mov    0x48(%eax),%eax
  800885:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800889:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088d:	c7 04 24 15 25 80 00 	movl   $0x802515,(%esp)
  800894:	e8 4b 0f 00 00       	call   8017e4 <cprintf>
		return -E_INVAL;
  800899:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80089e:	eb 24                	jmp    8008c4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8008a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8008a3:	8b 52 0c             	mov    0xc(%edx),%edx
  8008a6:	85 d2                	test   %edx,%edx
  8008a8:	74 15                	je     8008bf <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8008aa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8008b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008b8:	89 04 24             	mov    %eax,(%esp)
  8008bb:	ff d2                	call   *%edx
  8008bd:	eb 05                	jmp    8008c4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8008bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8008c4:	83 c4 24             	add    $0x24,%esp
  8008c7:	5b                   	pop    %ebx
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <seek>:

int
seek(int fdnum, off_t offset)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008d0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8008d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	89 04 24             	mov    %eax,(%esp)
  8008dd:	e8 e4 fb ff ff       	call   8004c6 <fd_lookup>
  8008e2:	85 c0                	test   %eax,%eax
  8008e4:	78 0e                	js     8008f4 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8008e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ec:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f4:	c9                   	leave  
  8008f5:	c3                   	ret    

008008f6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	53                   	push   %ebx
  8008fa:	83 ec 24             	sub    $0x24,%esp
  8008fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800900:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800903:	89 44 24 04          	mov    %eax,0x4(%esp)
  800907:	89 1c 24             	mov    %ebx,(%esp)
  80090a:	e8 b7 fb ff ff       	call   8004c6 <fd_lookup>
  80090f:	85 c0                	test   %eax,%eax
  800911:	78 61                	js     800974 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800913:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800916:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80091d:	8b 00                	mov    (%eax),%eax
  80091f:	89 04 24             	mov    %eax,(%esp)
  800922:	e8 f5 fb ff ff       	call   80051c <dev_lookup>
  800927:	85 c0                	test   %eax,%eax
  800929:	78 49                	js     800974 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80092b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80092e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800932:	75 23                	jne    800957 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800934:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800939:	8b 40 48             	mov    0x48(%eax),%eax
  80093c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800940:	89 44 24 04          	mov    %eax,0x4(%esp)
  800944:	c7 04 24 d8 24 80 00 	movl   $0x8024d8,(%esp)
  80094b:	e8 94 0e 00 00       	call   8017e4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800950:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800955:	eb 1d                	jmp    800974 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  800957:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80095a:	8b 52 18             	mov    0x18(%edx),%edx
  80095d:	85 d2                	test   %edx,%edx
  80095f:	74 0e                	je     80096f <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800961:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800964:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800968:	89 04 24             	mov    %eax,(%esp)
  80096b:	ff d2                	call   *%edx
  80096d:	eb 05                	jmp    800974 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80096f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  800974:	83 c4 24             	add    $0x24,%esp
  800977:	5b                   	pop    %ebx
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	53                   	push   %ebx
  80097e:	83 ec 24             	sub    $0x24,%esp
  800981:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800984:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800987:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	89 04 24             	mov    %eax,(%esp)
  800991:	e8 30 fb ff ff       	call   8004c6 <fd_lookup>
  800996:	85 c0                	test   %eax,%eax
  800998:	78 52                	js     8009ec <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80099a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80099d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009a4:	8b 00                	mov    (%eax),%eax
  8009a6:	89 04 24             	mov    %eax,(%esp)
  8009a9:	e8 6e fb ff ff       	call   80051c <dev_lookup>
  8009ae:	85 c0                	test   %eax,%eax
  8009b0:	78 3a                	js     8009ec <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8009b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8009b9:	74 2c                	je     8009e7 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8009bb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8009be:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8009c5:	00 00 00 
	stat->st_isdir = 0;
  8009c8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8009cf:	00 00 00 
	stat->st_dev = dev;
  8009d2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8009d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8009df:	89 14 24             	mov    %edx,(%esp)
  8009e2:	ff 50 14             	call   *0x14(%eax)
  8009e5:	eb 05                	jmp    8009ec <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8009e7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8009ec:	83 c4 24             	add    $0x24,%esp
  8009ef:	5b                   	pop    %ebx
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	56                   	push   %esi
  8009f6:	53                   	push   %ebx
  8009f7:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a01:	00 
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	89 04 24             	mov    %eax,(%esp)
  800a08:	e8 2a 02 00 00       	call   800c37 <open>
  800a0d:	89 c3                	mov    %eax,%ebx
  800a0f:	85 c0                	test   %eax,%eax
  800a11:	78 1b                	js     800a2e <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  800a13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a16:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1a:	89 1c 24             	mov    %ebx,(%esp)
  800a1d:	e8 58 ff ff ff       	call   80097a <fstat>
  800a22:	89 c6                	mov    %eax,%esi
	close(fd);
  800a24:	89 1c 24             	mov    %ebx,(%esp)
  800a27:	e8 d2 fb ff ff       	call   8005fe <close>
	return r;
  800a2c:	89 f3                	mov    %esi,%ebx
}
  800a2e:	89 d8                	mov    %ebx,%eax
  800a30:	83 c4 10             	add    $0x10,%esp
  800a33:	5b                   	pop    %ebx
  800a34:	5e                   	pop    %esi
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    
	...

00800a38 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
  800a3d:	83 ec 10             	sub    $0x10,%esp
  800a40:	89 c3                	mov    %eax,%ebx
  800a42:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a44:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a4b:	75 11                	jne    800a5e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800a54:	e8 4e 17 00 00       	call   8021a7 <ipc_find_env>
  800a59:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a5e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a65:	00 
  800a66:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800a6d:	00 
  800a6e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a72:	a1 00 40 80 00       	mov    0x804000,%eax
  800a77:	89 04 24             	mov    %eax,(%esp)
  800a7a:	e8 a5 16 00 00       	call   802124 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800a7f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a86:	00 
  800a87:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a92:	e8 1d 16 00 00       	call   8020b4 <ipc_recv>
}
  800a97:	83 c4 10             	add    $0x10,%esp
  800a9a:	5b                   	pop    %ebx
  800a9b:	5e                   	pop    %esi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800aa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa7:	8b 40 0c             	mov    0xc(%eax),%eax
  800aaa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800ab7:	ba 00 00 00 00       	mov    $0x0,%edx
  800abc:	b8 02 00 00 00       	mov    $0x2,%eax
  800ac1:	e8 72 ff ff ff       	call   800a38 <fsipc>
}
  800ac6:	c9                   	leave  
  800ac7:	c3                   	ret    

00800ac8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800ac8:	55                   	push   %ebp
  800ac9:	89 e5                	mov    %esp,%ebp
  800acb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad1:	8b 40 0c             	mov    0xc(%eax),%eax
  800ad4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ad9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ade:	b8 06 00 00 00       	mov    $0x6,%eax
  800ae3:	e8 50 ff ff ff       	call   800a38 <fsipc>
}
  800ae8:	c9                   	leave  
  800ae9:	c3                   	ret    

00800aea <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	53                   	push   %ebx
  800aee:	83 ec 14             	sub    $0x14,%esp
  800af1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800af4:	8b 45 08             	mov    0x8(%ebp),%eax
  800af7:	8b 40 0c             	mov    0xc(%eax),%eax
  800afa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800aff:	ba 00 00 00 00       	mov    $0x0,%edx
  800b04:	b8 05 00 00 00       	mov    $0x5,%eax
  800b09:	e8 2a ff ff ff       	call   800a38 <fsipc>
  800b0e:	85 c0                	test   %eax,%eax
  800b10:	78 2b                	js     800b3d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800b12:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b19:	00 
  800b1a:	89 1c 24             	mov    %ebx,(%esp)
  800b1d:	e8 6d 12 00 00       	call   801d8f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b22:	a1 80 50 80 00       	mov    0x805080,%eax
  800b27:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b2d:	a1 84 50 80 00       	mov    0x805084,%eax
  800b32:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800b38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b3d:	83 c4 14             	add    $0x14,%esp
  800b40:	5b                   	pop    %ebx
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	83 ec 18             	sub    $0x18,%esp
  800b49:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800b4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4f:	8b 52 0c             	mov    0xc(%edx),%edx
  800b52:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800b58:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  800b5d:	89 c2                	mov    %eax,%edx
  800b5f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800b64:	76 05                	jbe    800b6b <devfile_write+0x28>
  800b66:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  800b6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800b6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b72:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b76:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800b7d:	e8 f0 13 00 00       	call   801f72 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  800b82:	ba 00 00 00 00       	mov    $0x0,%edx
  800b87:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8c:	e8 a7 fe ff ff       	call   800a38 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  800b91:	c9                   	leave  
  800b92:	c3                   	ret    

00800b93 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
  800b98:	83 ec 10             	sub    $0x10,%esp
  800b9b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba1:	8b 40 0c             	mov    0xc(%eax),%eax
  800ba4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800ba9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800baf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb4:	b8 03 00 00 00       	mov    $0x3,%eax
  800bb9:	e8 7a fe ff ff       	call   800a38 <fsipc>
  800bbe:	89 c3                	mov    %eax,%ebx
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	78 6a                	js     800c2e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  800bc4:	39 c6                	cmp    %eax,%esi
  800bc6:	73 24                	jae    800bec <devfile_read+0x59>
  800bc8:	c7 44 24 0c 48 25 80 	movl   $0x802548,0xc(%esp)
  800bcf:	00 
  800bd0:	c7 44 24 08 4f 25 80 	movl   $0x80254f,0x8(%esp)
  800bd7:	00 
  800bd8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  800bdf:	00 
  800be0:	c7 04 24 64 25 80 00 	movl   $0x802564,(%esp)
  800be7:	e8 00 0b 00 00       	call   8016ec <_panic>
	assert(r <= PGSIZE);
  800bec:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800bf1:	7e 24                	jle    800c17 <devfile_read+0x84>
  800bf3:	c7 44 24 0c 6f 25 80 	movl   $0x80256f,0xc(%esp)
  800bfa:	00 
  800bfb:	c7 44 24 08 4f 25 80 	movl   $0x80254f,0x8(%esp)
  800c02:	00 
  800c03:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  800c0a:	00 
  800c0b:	c7 04 24 64 25 80 00 	movl   $0x802564,(%esp)
  800c12:	e8 d5 0a 00 00       	call   8016ec <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c1b:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c22:	00 
  800c23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c26:	89 04 24             	mov    %eax,(%esp)
  800c29:	e8 da 12 00 00       	call   801f08 <memmove>
	return r;
}
  800c2e:	89 d8                	mov    %ebx,%eax
  800c30:	83 c4 10             	add    $0x10,%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 20             	sub    $0x20,%esp
  800c3f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800c42:	89 34 24             	mov    %esi,(%esp)
  800c45:	e8 12 11 00 00       	call   801d5c <strlen>
  800c4a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800c4f:	7f 60                	jg     800cb1 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800c51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c54:	89 04 24             	mov    %eax,(%esp)
  800c57:	e8 17 f8 ff ff       	call   800473 <fd_alloc>
  800c5c:	89 c3                	mov    %eax,%ebx
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	78 54                	js     800cb6 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800c62:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c66:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c6d:	e8 1d 11 00 00       	call   801d8f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800c72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c75:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800c7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800c82:	e8 b1 fd ff ff       	call   800a38 <fsipc>
  800c87:	89 c3                	mov    %eax,%ebx
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	79 15                	jns    800ca2 <open+0x6b>
		fd_close(fd, 0);
  800c8d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c94:	00 
  800c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c98:	89 04 24             	mov    %eax,(%esp)
  800c9b:	e8 d6 f8 ff ff       	call   800576 <fd_close>
		return r;
  800ca0:	eb 14                	jmp    800cb6 <open+0x7f>
	}

	return fd2num(fd);
  800ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca5:	89 04 24             	mov    %eax,(%esp)
  800ca8:	e8 9b f7 ff ff       	call   800448 <fd2num>
  800cad:	89 c3                	mov    %eax,%ebx
  800caf:	eb 05                	jmp    800cb6 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800cb1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800cb6:	89 d8                	mov    %ebx,%eax
  800cb8:	83 c4 20             	add    $0x20,%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800cc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cca:	b8 08 00 00 00       	mov    $0x8,%eax
  800ccf:	e8 64 fd ff ff       	call   800a38 <fsipc>
}
  800cd4:	c9                   	leave  
  800cd5:	c3                   	ret    
	...

00800cd8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800cde:	c7 44 24 04 7b 25 80 	movl   $0x80257b,0x4(%esp)
  800ce5:	00 
  800ce6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce9:	89 04 24             	mov    %eax,(%esp)
  800cec:	e8 9e 10 00 00       	call   801d8f <strcpy>
	return 0;
}
  800cf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf6:	c9                   	leave  
  800cf7:	c3                   	ret    

00800cf8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	53                   	push   %ebx
  800cfc:	83 ec 14             	sub    $0x14,%esp
  800cff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800d02:	89 1c 24             	mov    %ebx,(%esp)
  800d05:	e8 e2 14 00 00       	call   8021ec <pageref>
  800d0a:	83 f8 01             	cmp    $0x1,%eax
  800d0d:	75 0d                	jne    800d1c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  800d0f:	8b 43 0c             	mov    0xc(%ebx),%eax
  800d12:	89 04 24             	mov    %eax,(%esp)
  800d15:	e8 1f 03 00 00       	call   801039 <nsipc_close>
  800d1a:	eb 05                	jmp    800d21 <devsock_close+0x29>
	else
		return 0;
  800d1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d21:	83 c4 14             	add    $0x14,%esp
  800d24:	5b                   	pop    %ebx
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800d2d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d34:	00 
  800d35:	8b 45 10             	mov    0x10(%ebp),%eax
  800d38:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d43:	8b 45 08             	mov    0x8(%ebp),%eax
  800d46:	8b 40 0c             	mov    0xc(%eax),%eax
  800d49:	89 04 24             	mov    %eax,(%esp)
  800d4c:	e8 e3 03 00 00       	call   801134 <nsipc_send>
}
  800d51:	c9                   	leave  
  800d52:	c3                   	ret    

00800d53 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800d59:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d60:	00 
  800d61:	8b 45 10             	mov    0x10(%ebp),%eax
  800d64:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d72:	8b 40 0c             	mov    0xc(%eax),%eax
  800d75:	89 04 24             	mov    %eax,(%esp)
  800d78:	e8 37 03 00 00       	call   8010b4 <nsipc_recv>
}
  800d7d:	c9                   	leave  
  800d7e:	c3                   	ret    

00800d7f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 20             	sub    $0x20,%esp
  800d87:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800d89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d8c:	89 04 24             	mov    %eax,(%esp)
  800d8f:	e8 df f6 ff ff       	call   800473 <fd_alloc>
  800d94:	89 c3                	mov    %eax,%ebx
  800d96:	85 c0                	test   %eax,%eax
  800d98:	78 21                	js     800dbb <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800d9a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800da1:	00 
  800da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800db0:	e8 c8 f3 ff ff       	call   80017d <sys_page_alloc>
  800db5:	89 c3                	mov    %eax,%ebx
  800db7:	85 c0                	test   %eax,%eax
  800db9:	79 0a                	jns    800dc5 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  800dbb:	89 34 24             	mov    %esi,(%esp)
  800dbe:	e8 76 02 00 00       	call   801039 <nsipc_close>
		return r;
  800dc3:	eb 22                	jmp    800de7 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800dc5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dce:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800dd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800dda:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ddd:	89 04 24             	mov    %eax,(%esp)
  800de0:	e8 63 f6 ff ff       	call   800448 <fd2num>
  800de5:	89 c3                	mov    %eax,%ebx
}
  800de7:	89 d8                	mov    %ebx,%eax
  800de9:	83 c4 20             	add    $0x20,%esp
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800df6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800df9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800dfd:	89 04 24             	mov    %eax,(%esp)
  800e00:	e8 c1 f6 ff ff       	call   8004c6 <fd_lookup>
  800e05:	85 c0                	test   %eax,%eax
  800e07:	78 17                	js     800e20 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e12:	39 10                	cmp    %edx,(%eax)
  800e14:	75 05                	jne    800e1b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800e16:	8b 40 0c             	mov    0xc(%eax),%eax
  800e19:	eb 05                	jmp    800e20 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800e1b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800e20:	c9                   	leave  
  800e21:	c3                   	ret    

00800e22 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	e8 c0 ff ff ff       	call   800df0 <fd2sockid>
  800e30:	85 c0                	test   %eax,%eax
  800e32:	78 1f                	js     800e53 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800e34:	8b 55 10             	mov    0x10(%ebp),%edx
  800e37:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e42:	89 04 24             	mov    %eax,(%esp)
  800e45:	e8 38 01 00 00       	call   800f82 <nsipc_accept>
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	78 05                	js     800e53 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  800e4e:	e8 2c ff ff ff       	call   800d7f <alloc_sockfd>
}
  800e53:	c9                   	leave  
  800e54:	c3                   	ret    

00800e55 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5e:	e8 8d ff ff ff       	call   800df0 <fd2sockid>
  800e63:	85 c0                	test   %eax,%eax
  800e65:	78 16                	js     800e7d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  800e67:	8b 55 10             	mov    0x10(%ebp),%edx
  800e6a:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e71:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e75:	89 04 24             	mov    %eax,(%esp)
  800e78:	e8 5b 01 00 00       	call   800fd8 <nsipc_bind>
}
  800e7d:	c9                   	leave  
  800e7e:	c3                   	ret    

00800e7f <shutdown>:

int
shutdown(int s, int how)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800e85:	8b 45 08             	mov    0x8(%ebp),%eax
  800e88:	e8 63 ff ff ff       	call   800df0 <fd2sockid>
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	78 0f                	js     800ea0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800e91:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e94:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e98:	89 04 24             	mov    %eax,(%esp)
  800e9b:	e8 77 01 00 00       	call   801017 <nsipc_shutdown>
}
  800ea0:	c9                   	leave  
  800ea1:	c3                   	ret    

00800ea2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ea8:	8b 45 08             	mov    0x8(%ebp),%eax
  800eab:	e8 40 ff ff ff       	call   800df0 <fd2sockid>
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	78 16                	js     800eca <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  800eb4:	8b 55 10             	mov    0x10(%ebp),%edx
  800eb7:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ebb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ebe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ec2:	89 04 24             	mov    %eax,(%esp)
  800ec5:	e8 89 01 00 00       	call   801053 <nsipc_connect>
}
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    

00800ecc <listen>:

int
listen(int s, int backlog)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed5:	e8 16 ff ff ff       	call   800df0 <fd2sockid>
  800eda:	85 c0                	test   %eax,%eax
  800edc:	78 0f                	js     800eed <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800ede:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ee1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ee5:	89 04 24             	mov    %eax,(%esp)
  800ee8:	e8 a5 01 00 00       	call   801092 <nsipc_listen>
}
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800ef5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800efc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f03:	8b 45 08             	mov    0x8(%ebp),%eax
  800f06:	89 04 24             	mov    %eax,(%esp)
  800f09:	e8 99 02 00 00       	call   8011a7 <nsipc_socket>
  800f0e:	85 c0                	test   %eax,%eax
  800f10:	78 05                	js     800f17 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  800f12:	e8 68 fe ff ff       	call   800d7f <alloc_sockfd>
}
  800f17:	c9                   	leave  
  800f18:	c3                   	ret    
  800f19:	00 00                	add    %al,(%eax)
	...

00800f1c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	53                   	push   %ebx
  800f20:	83 ec 14             	sub    $0x14,%esp
  800f23:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800f25:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800f2c:	75 11                	jne    800f3f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800f2e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800f35:	e8 6d 12 00 00       	call   8021a7 <ipc_find_env>
  800f3a:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800f3f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800f46:	00 
  800f47:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  800f4e:	00 
  800f4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f53:	a1 04 40 80 00       	mov    0x804004,%eax
  800f58:	89 04 24             	mov    %eax,(%esp)
  800f5b:	e8 c4 11 00 00       	call   802124 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800f60:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f67:	00 
  800f68:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f6f:	00 
  800f70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f77:	e8 38 11 00 00       	call   8020b4 <ipc_recv>
}
  800f7c:	83 c4 14             	add    $0x14,%esp
  800f7f:	5b                   	pop    %ebx
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    

00800f82 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	56                   	push   %esi
  800f86:	53                   	push   %ebx
  800f87:	83 ec 10             	sub    $0x10,%esp
  800f8a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f90:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800f95:	8b 06                	mov    (%esi),%eax
  800f97:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800f9c:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa1:	e8 76 ff ff ff       	call   800f1c <nsipc>
  800fa6:	89 c3                	mov    %eax,%ebx
  800fa8:	85 c0                	test   %eax,%eax
  800faa:	78 23                	js     800fcf <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800fac:	a1 10 60 80 00       	mov    0x806010,%eax
  800fb1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fb5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  800fbc:	00 
  800fbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc0:	89 04 24             	mov    %eax,(%esp)
  800fc3:	e8 40 0f 00 00       	call   801f08 <memmove>
		*addrlen = ret->ret_addrlen;
  800fc8:	a1 10 60 80 00       	mov    0x806010,%eax
  800fcd:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  800fcf:	89 d8                	mov    %ebx,%eax
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	53                   	push   %ebx
  800fdc:	83 ec 14             	sub    $0x14,%esp
  800fdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800fe2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800fea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff5:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  800ffc:	e8 07 0f 00 00       	call   801f08 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801001:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801007:	b8 02 00 00 00       	mov    $0x2,%eax
  80100c:	e8 0b ff ff ff       	call   800f1c <nsipc>
}
  801011:	83 c4 14             	add    $0x14,%esp
  801014:	5b                   	pop    %ebx
  801015:	5d                   	pop    %ebp
  801016:	c3                   	ret    

00801017 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80101d:	8b 45 08             	mov    0x8(%ebp),%eax
  801020:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801025:	8b 45 0c             	mov    0xc(%ebp),%eax
  801028:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80102d:	b8 03 00 00 00       	mov    $0x3,%eax
  801032:	e8 e5 fe ff ff       	call   800f1c <nsipc>
}
  801037:	c9                   	leave  
  801038:	c3                   	ret    

00801039 <nsipc_close>:

int
nsipc_close(int s)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80103f:	8b 45 08             	mov    0x8(%ebp),%eax
  801042:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801047:	b8 04 00 00 00       	mov    $0x4,%eax
  80104c:	e8 cb fe ff ff       	call   800f1c <nsipc>
}
  801051:	c9                   	leave  
  801052:	c3                   	ret    

00801053 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	53                   	push   %ebx
  801057:	83 ec 14             	sub    $0x14,%esp
  80105a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80105d:	8b 45 08             	mov    0x8(%ebp),%eax
  801060:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801069:	8b 45 0c             	mov    0xc(%ebp),%eax
  80106c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801070:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801077:	e8 8c 0e 00 00       	call   801f08 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80107c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801082:	b8 05 00 00 00       	mov    $0x5,%eax
  801087:	e8 90 fe ff ff       	call   800f1c <nsipc>
}
  80108c:	83 c4 14             	add    $0x14,%esp
  80108f:	5b                   	pop    %ebx
  801090:	5d                   	pop    %ebp
  801091:	c3                   	ret    

00801092 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801098:	8b 45 08             	mov    0x8(%ebp),%eax
  80109b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8010a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a3:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8010a8:	b8 06 00 00 00       	mov    $0x6,%eax
  8010ad:	e8 6a fe ff ff       	call   800f1c <nsipc>
}
  8010b2:	c9                   	leave  
  8010b3:	c3                   	ret    

008010b4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	56                   	push   %esi
  8010b8:	53                   	push   %ebx
  8010b9:	83 ec 10             	sub    $0x10,%esp
  8010bc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8010bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8010c7:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8010cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8010d0:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8010d5:	b8 07 00 00 00       	mov    $0x7,%eax
  8010da:	e8 3d fe ff ff       	call   800f1c <nsipc>
  8010df:	89 c3                	mov    %eax,%ebx
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	78 46                	js     80112b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8010e5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8010ea:	7f 04                	jg     8010f0 <nsipc_recv+0x3c>
  8010ec:	39 c6                	cmp    %eax,%esi
  8010ee:	7d 24                	jge    801114 <nsipc_recv+0x60>
  8010f0:	c7 44 24 0c 87 25 80 	movl   $0x802587,0xc(%esp)
  8010f7:	00 
  8010f8:	c7 44 24 08 4f 25 80 	movl   $0x80254f,0x8(%esp)
  8010ff:	00 
  801100:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801107:	00 
  801108:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  80110f:	e8 d8 05 00 00       	call   8016ec <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801114:	89 44 24 08          	mov    %eax,0x8(%esp)
  801118:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80111f:	00 
  801120:	8b 45 0c             	mov    0xc(%ebp),%eax
  801123:	89 04 24             	mov    %eax,(%esp)
  801126:	e8 dd 0d 00 00       	call   801f08 <memmove>
	}

	return r;
}
  80112b:	89 d8                	mov    %ebx,%eax
  80112d:	83 c4 10             	add    $0x10,%esp
  801130:	5b                   	pop    %ebx
  801131:	5e                   	pop    %esi
  801132:	5d                   	pop    %ebp
  801133:	c3                   	ret    

00801134 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	53                   	push   %ebx
  801138:	83 ec 14             	sub    $0x14,%esp
  80113b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80113e:	8b 45 08             	mov    0x8(%ebp),%eax
  801141:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801146:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80114c:	7e 24                	jle    801172 <nsipc_send+0x3e>
  80114e:	c7 44 24 0c a8 25 80 	movl   $0x8025a8,0xc(%esp)
  801155:	00 
  801156:	c7 44 24 08 4f 25 80 	movl   $0x80254f,0x8(%esp)
  80115d:	00 
  80115e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801165:	00 
  801166:	c7 04 24 9c 25 80 00 	movl   $0x80259c,(%esp)
  80116d:	e8 7a 05 00 00       	call   8016ec <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801172:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801176:	8b 45 0c             	mov    0xc(%ebp),%eax
  801179:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117d:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801184:	e8 7f 0d 00 00       	call   801f08 <memmove>
	nsipcbuf.send.req_size = size;
  801189:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  80118f:	8b 45 14             	mov    0x14(%ebp),%eax
  801192:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801197:	b8 08 00 00 00       	mov    $0x8,%eax
  80119c:	e8 7b fd ff ff       	call   800f1c <nsipc>
}
  8011a1:	83 c4 14             	add    $0x14,%esp
  8011a4:	5b                   	pop    %ebx
  8011a5:	5d                   	pop    %ebp
  8011a6:	c3                   	ret    

008011a7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8011ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8011b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011b8:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8011bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c0:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8011c5:	b8 09 00 00 00       	mov    $0x9,%eax
  8011ca:	e8 4d fd ff ff       	call   800f1c <nsipc>
}
  8011cf:	c9                   	leave  
  8011d0:	c3                   	ret    
  8011d1:	00 00                	add    %al,(%eax)
	...

008011d4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8011d4:	55                   	push   %ebp
  8011d5:	89 e5                	mov    %esp,%ebp
  8011d7:	56                   	push   %esi
  8011d8:	53                   	push   %ebx
  8011d9:	83 ec 10             	sub    $0x10,%esp
  8011dc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8011df:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e2:	89 04 24             	mov    %eax,(%esp)
  8011e5:	e8 6e f2 ff ff       	call   800458 <fd2data>
  8011ea:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8011ec:	c7 44 24 04 b4 25 80 	movl   $0x8025b4,0x4(%esp)
  8011f3:	00 
  8011f4:	89 34 24             	mov    %esi,(%esp)
  8011f7:	e8 93 0b 00 00       	call   801d8f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8011fc:	8b 43 04             	mov    0x4(%ebx),%eax
  8011ff:	2b 03                	sub    (%ebx),%eax
  801201:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801207:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80120e:	00 00 00 
	stat->st_dev = &devpipe;
  801211:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  801218:	30 80 00 
	return 0;
}
  80121b:	b8 00 00 00 00       	mov    $0x0,%eax
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	5b                   	pop    %ebx
  801224:	5e                   	pop    %esi
  801225:	5d                   	pop    %ebp
  801226:	c3                   	ret    

00801227 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801227:	55                   	push   %ebp
  801228:	89 e5                	mov    %esp,%ebp
  80122a:	53                   	push   %ebx
  80122b:	83 ec 14             	sub    $0x14,%esp
  80122e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801231:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801235:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80123c:	e8 e3 ef ff ff       	call   800224 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801241:	89 1c 24             	mov    %ebx,(%esp)
  801244:	e8 0f f2 ff ff       	call   800458 <fd2data>
  801249:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801254:	e8 cb ef ff ff       	call   800224 <sys_page_unmap>
}
  801259:	83 c4 14             	add    $0x14,%esp
  80125c:	5b                   	pop    %ebx
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	57                   	push   %edi
  801263:	56                   	push   %esi
  801264:	53                   	push   %ebx
  801265:	83 ec 2c             	sub    $0x2c,%esp
  801268:	89 c7                	mov    %eax,%edi
  80126a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80126d:	a1 08 40 80 00       	mov    0x804008,%eax
  801272:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801275:	89 3c 24             	mov    %edi,(%esp)
  801278:	e8 6f 0f 00 00       	call   8021ec <pageref>
  80127d:	89 c6                	mov    %eax,%esi
  80127f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801282:	89 04 24             	mov    %eax,(%esp)
  801285:	e8 62 0f 00 00       	call   8021ec <pageref>
  80128a:	39 c6                	cmp    %eax,%esi
  80128c:	0f 94 c0             	sete   %al
  80128f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801292:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801298:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80129b:	39 cb                	cmp    %ecx,%ebx
  80129d:	75 08                	jne    8012a7 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80129f:	83 c4 2c             	add    $0x2c,%esp
  8012a2:	5b                   	pop    %ebx
  8012a3:	5e                   	pop    %esi
  8012a4:	5f                   	pop    %edi
  8012a5:	5d                   	pop    %ebp
  8012a6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8012a7:	83 f8 01             	cmp    $0x1,%eax
  8012aa:	75 c1                	jne    80126d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8012ac:	8b 42 58             	mov    0x58(%edx),%eax
  8012af:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8012b6:	00 
  8012b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012bb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012bf:	c7 04 24 bb 25 80 00 	movl   $0x8025bb,(%esp)
  8012c6:	e8 19 05 00 00       	call   8017e4 <cprintf>
  8012cb:	eb a0                	jmp    80126d <_pipeisclosed+0xe>

008012cd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	57                   	push   %edi
  8012d1:	56                   	push   %esi
  8012d2:	53                   	push   %ebx
  8012d3:	83 ec 1c             	sub    $0x1c,%esp
  8012d6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8012d9:	89 34 24             	mov    %esi,(%esp)
  8012dc:	e8 77 f1 ff ff       	call   800458 <fd2data>
  8012e1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8012e3:	bf 00 00 00 00       	mov    $0x0,%edi
  8012e8:	eb 3c                	jmp    801326 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8012ea:	89 da                	mov    %ebx,%edx
  8012ec:	89 f0                	mov    %esi,%eax
  8012ee:	e8 6c ff ff ff       	call   80125f <_pipeisclosed>
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	75 38                	jne    80132f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8012f7:	e8 62 ee ff ff       	call   80015e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8012fc:	8b 43 04             	mov    0x4(%ebx),%eax
  8012ff:	8b 13                	mov    (%ebx),%edx
  801301:	83 c2 20             	add    $0x20,%edx
  801304:	39 d0                	cmp    %edx,%eax
  801306:	73 e2                	jae    8012ea <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801308:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80130e:	89 c2                	mov    %eax,%edx
  801310:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801316:	79 05                	jns    80131d <devpipe_write+0x50>
  801318:	4a                   	dec    %edx
  801319:	83 ca e0             	or     $0xffffffe0,%edx
  80131c:	42                   	inc    %edx
  80131d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801321:	40                   	inc    %eax
  801322:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801325:	47                   	inc    %edi
  801326:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801329:	75 d1                	jne    8012fc <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80132b:	89 f8                	mov    %edi,%eax
  80132d:	eb 05                	jmp    801334 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80132f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801334:	83 c4 1c             	add    $0x1c,%esp
  801337:	5b                   	pop    %ebx
  801338:	5e                   	pop    %esi
  801339:	5f                   	pop    %edi
  80133a:	5d                   	pop    %ebp
  80133b:	c3                   	ret    

0080133c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	57                   	push   %edi
  801340:	56                   	push   %esi
  801341:	53                   	push   %ebx
  801342:	83 ec 1c             	sub    $0x1c,%esp
  801345:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801348:	89 3c 24             	mov    %edi,(%esp)
  80134b:	e8 08 f1 ff ff       	call   800458 <fd2data>
  801350:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801352:	be 00 00 00 00       	mov    $0x0,%esi
  801357:	eb 3a                	jmp    801393 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801359:	85 f6                	test   %esi,%esi
  80135b:	74 04                	je     801361 <devpipe_read+0x25>
				return i;
  80135d:	89 f0                	mov    %esi,%eax
  80135f:	eb 40                	jmp    8013a1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801361:	89 da                	mov    %ebx,%edx
  801363:	89 f8                	mov    %edi,%eax
  801365:	e8 f5 fe ff ff       	call   80125f <_pipeisclosed>
  80136a:	85 c0                	test   %eax,%eax
  80136c:	75 2e                	jne    80139c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80136e:	e8 eb ed ff ff       	call   80015e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801373:	8b 03                	mov    (%ebx),%eax
  801375:	3b 43 04             	cmp    0x4(%ebx),%eax
  801378:	74 df                	je     801359 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80137a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80137f:	79 05                	jns    801386 <devpipe_read+0x4a>
  801381:	48                   	dec    %eax
  801382:	83 c8 e0             	or     $0xffffffe0,%eax
  801385:	40                   	inc    %eax
  801386:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  80138a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80138d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801390:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801392:	46                   	inc    %esi
  801393:	3b 75 10             	cmp    0x10(%ebp),%esi
  801396:	75 db                	jne    801373 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801398:	89 f0                	mov    %esi,%eax
  80139a:	eb 05                	jmp    8013a1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80139c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8013a1:	83 c4 1c             	add    $0x1c,%esp
  8013a4:	5b                   	pop    %ebx
  8013a5:	5e                   	pop    %esi
  8013a6:	5f                   	pop    %edi
  8013a7:	5d                   	pop    %ebp
  8013a8:	c3                   	ret    

008013a9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	57                   	push   %edi
  8013ad:	56                   	push   %esi
  8013ae:	53                   	push   %ebx
  8013af:	83 ec 3c             	sub    $0x3c,%esp
  8013b2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8013b5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013b8:	89 04 24             	mov    %eax,(%esp)
  8013bb:	e8 b3 f0 ff ff       	call   800473 <fd_alloc>
  8013c0:	89 c3                	mov    %eax,%ebx
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	0f 88 45 01 00 00    	js     80150f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8013ca:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8013d1:	00 
  8013d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013e0:	e8 98 ed ff ff       	call   80017d <sys_page_alloc>
  8013e5:	89 c3                	mov    %eax,%ebx
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	0f 88 20 01 00 00    	js     80150f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8013ef:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013f2:	89 04 24             	mov    %eax,(%esp)
  8013f5:	e8 79 f0 ff ff       	call   800473 <fd_alloc>
  8013fa:	89 c3                	mov    %eax,%ebx
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	0f 88 f8 00 00 00    	js     8014fc <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801404:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80140b:	00 
  80140c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80140f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801413:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80141a:	e8 5e ed ff ff       	call   80017d <sys_page_alloc>
  80141f:	89 c3                	mov    %eax,%ebx
  801421:	85 c0                	test   %eax,%eax
  801423:	0f 88 d3 00 00 00    	js     8014fc <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801429:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80142c:	89 04 24             	mov    %eax,(%esp)
  80142f:	e8 24 f0 ff ff       	call   800458 <fd2data>
  801434:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801436:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80143d:	00 
  80143e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801442:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801449:	e8 2f ed ff ff       	call   80017d <sys_page_alloc>
  80144e:	89 c3                	mov    %eax,%ebx
  801450:	85 c0                	test   %eax,%eax
  801452:	0f 88 91 00 00 00    	js     8014e9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801458:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80145b:	89 04 24             	mov    %eax,(%esp)
  80145e:	e8 f5 ef ff ff       	call   800458 <fd2data>
  801463:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80146a:	00 
  80146b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80146f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801476:	00 
  801477:	89 74 24 04          	mov    %esi,0x4(%esp)
  80147b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801482:	e8 4a ed ff ff       	call   8001d1 <sys_page_map>
  801487:	89 c3                	mov    %eax,%ebx
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 4c                	js     8014d9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80148d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801493:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801496:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801498:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80149b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8014a2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8014a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014ab:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8014ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014b0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8014b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014ba:	89 04 24             	mov    %eax,(%esp)
  8014bd:	e8 86 ef ff ff       	call   800448 <fd2num>
  8014c2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8014c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014c7:	89 04 24             	mov    %eax,(%esp)
  8014ca:	e8 79 ef ff ff       	call   800448 <fd2num>
  8014cf:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  8014d2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d7:	eb 36                	jmp    80150f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8014d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014e4:	e8 3b ed ff ff       	call   800224 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8014e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f7:	e8 28 ed ff ff       	call   800224 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8014fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801503:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80150a:	e8 15 ed ff ff       	call   800224 <sys_page_unmap>
    err:
	return r;
}
  80150f:	89 d8                	mov    %ebx,%eax
  801511:	83 c4 3c             	add    $0x3c,%esp
  801514:	5b                   	pop    %ebx
  801515:	5e                   	pop    %esi
  801516:	5f                   	pop    %edi
  801517:	5d                   	pop    %ebp
  801518:	c3                   	ret    

00801519 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801519:	55                   	push   %ebp
  80151a:	89 e5                	mov    %esp,%ebp
  80151c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801522:	89 44 24 04          	mov    %eax,0x4(%esp)
  801526:	8b 45 08             	mov    0x8(%ebp),%eax
  801529:	89 04 24             	mov    %eax,(%esp)
  80152c:	e8 95 ef ff ff       	call   8004c6 <fd_lookup>
  801531:	85 c0                	test   %eax,%eax
  801533:	78 15                	js     80154a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801535:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801538:	89 04 24             	mov    %eax,(%esp)
  80153b:	e8 18 ef ff ff       	call   800458 <fd2data>
	return _pipeisclosed(fd, p);
  801540:	89 c2                	mov    %eax,%edx
  801542:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801545:	e8 15 fd ff ff       	call   80125f <_pipeisclosed>
}
  80154a:	c9                   	leave  
  80154b:	c3                   	ret    

0080154c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80154f:	b8 00 00 00 00       	mov    $0x0,%eax
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    

00801556 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80155c:	c7 44 24 04 d3 25 80 	movl   $0x8025d3,0x4(%esp)
  801563:	00 
  801564:	8b 45 0c             	mov    0xc(%ebp),%eax
  801567:	89 04 24             	mov    %eax,(%esp)
  80156a:	e8 20 08 00 00       	call   801d8f <strcpy>
	return 0;
}
  80156f:	b8 00 00 00 00       	mov    $0x0,%eax
  801574:	c9                   	leave  
  801575:	c3                   	ret    

00801576 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	57                   	push   %edi
  80157a:	56                   	push   %esi
  80157b:	53                   	push   %ebx
  80157c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801582:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801587:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80158d:	eb 30                	jmp    8015bf <devcons_write+0x49>
		m = n - tot;
  80158f:	8b 75 10             	mov    0x10(%ebp),%esi
  801592:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801594:	83 fe 7f             	cmp    $0x7f,%esi
  801597:	76 05                	jbe    80159e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801599:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80159e:	89 74 24 08          	mov    %esi,0x8(%esp)
  8015a2:	03 45 0c             	add    0xc(%ebp),%eax
  8015a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a9:	89 3c 24             	mov    %edi,(%esp)
  8015ac:	e8 57 09 00 00       	call   801f08 <memmove>
		sys_cputs(buf, m);
  8015b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015b5:	89 3c 24             	mov    %edi,(%esp)
  8015b8:	e8 f3 ea ff ff       	call   8000b0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8015bd:	01 f3                	add    %esi,%ebx
  8015bf:	89 d8                	mov    %ebx,%eax
  8015c1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8015c4:	72 c9                	jb     80158f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8015c6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8015cc:	5b                   	pop    %ebx
  8015cd:	5e                   	pop    %esi
  8015ce:	5f                   	pop    %edi
  8015cf:	5d                   	pop    %ebp
  8015d0:	c3                   	ret    

008015d1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8015d7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8015db:	75 07                	jne    8015e4 <devcons_read+0x13>
  8015dd:	eb 25                	jmp    801604 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8015df:	e8 7a eb ff ff       	call   80015e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8015e4:	e8 e5 ea ff ff       	call   8000ce <sys_cgetc>
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	74 f2                	je     8015df <devcons_read+0xe>
  8015ed:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	78 1d                	js     801610 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8015f3:	83 f8 04             	cmp    $0x4,%eax
  8015f6:	74 13                	je     80160b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8015f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015fb:	88 10                	mov    %dl,(%eax)
	return 1;
  8015fd:	b8 01 00 00 00       	mov    $0x1,%eax
  801602:	eb 0c                	jmp    801610 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801604:	b8 00 00 00 00       	mov    $0x0,%eax
  801609:	eb 05                	jmp    801610 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80160b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801610:	c9                   	leave  
  801611:	c3                   	ret    

00801612 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801618:	8b 45 08             	mov    0x8(%ebp),%eax
  80161b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80161e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801625:	00 
  801626:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801629:	89 04 24             	mov    %eax,(%esp)
  80162c:	e8 7f ea ff ff       	call   8000b0 <sys_cputs>
}
  801631:	c9                   	leave  
  801632:	c3                   	ret    

00801633 <getchar>:

int
getchar(void)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801639:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801640:	00 
  801641:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801644:	89 44 24 04          	mov    %eax,0x4(%esp)
  801648:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164f:	e8 10 f1 ff ff       	call   800764 <read>
	if (r < 0)
  801654:	85 c0                	test   %eax,%eax
  801656:	78 0f                	js     801667 <getchar+0x34>
		return r;
	if (r < 1)
  801658:	85 c0                	test   %eax,%eax
  80165a:	7e 06                	jle    801662 <getchar+0x2f>
		return -E_EOF;
	return c;
  80165c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801660:	eb 05                	jmp    801667 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801662:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801667:	c9                   	leave  
  801668:	c3                   	ret    

00801669 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80166f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801672:	89 44 24 04          	mov    %eax,0x4(%esp)
  801676:	8b 45 08             	mov    0x8(%ebp),%eax
  801679:	89 04 24             	mov    %eax,(%esp)
  80167c:	e8 45 ee ff ff       	call   8004c6 <fd_lookup>
  801681:	85 c0                	test   %eax,%eax
  801683:	78 11                	js     801696 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801685:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801688:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80168e:	39 10                	cmp    %edx,(%eax)
  801690:	0f 94 c0             	sete   %al
  801693:	0f b6 c0             	movzbl %al,%eax
}
  801696:	c9                   	leave  
  801697:	c3                   	ret    

00801698 <opencons>:

int
opencons(void)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80169e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a1:	89 04 24             	mov    %eax,(%esp)
  8016a4:	e8 ca ed ff ff       	call   800473 <fd_alloc>
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 3c                	js     8016e9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8016ad:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8016b4:	00 
  8016b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016c3:	e8 b5 ea ff ff       	call   80017d <sys_page_alloc>
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	78 1d                	js     8016e9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8016cc:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8016d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8016d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016da:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8016e1:	89 04 24             	mov    %eax,(%esp)
  8016e4:	e8 5f ed ff ff       	call   800448 <fd2num>
}
  8016e9:	c9                   	leave  
  8016ea:	c3                   	ret    
	...

008016ec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	56                   	push   %esi
  8016f0:	53                   	push   %ebx
  8016f1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8016f4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8016f7:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8016fd:	e8 3d ea ff ff       	call   80013f <sys_getenvid>
  801702:	8b 55 0c             	mov    0xc(%ebp),%edx
  801705:	89 54 24 10          	mov    %edx,0x10(%esp)
  801709:	8b 55 08             	mov    0x8(%ebp),%edx
  80170c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801710:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801714:	89 44 24 04          	mov    %eax,0x4(%esp)
  801718:	c7 04 24 e0 25 80 00 	movl   $0x8025e0,(%esp)
  80171f:	e8 c0 00 00 00       	call   8017e4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801724:	89 74 24 04          	mov    %esi,0x4(%esp)
  801728:	8b 45 10             	mov    0x10(%ebp),%eax
  80172b:	89 04 24             	mov    %eax,(%esp)
  80172e:	e8 50 00 00 00       	call   801783 <vcprintf>
	cprintf("\n");
  801733:	c7 04 24 cc 25 80 00 	movl   $0x8025cc,(%esp)
  80173a:	e8 a5 00 00 00       	call   8017e4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80173f:	cc                   	int3   
  801740:	eb fd                	jmp    80173f <_panic+0x53>
	...

00801744 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	53                   	push   %ebx
  801748:	83 ec 14             	sub    $0x14,%esp
  80174b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80174e:	8b 03                	mov    (%ebx),%eax
  801750:	8b 55 08             	mov    0x8(%ebp),%edx
  801753:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801757:	40                   	inc    %eax
  801758:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80175a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80175f:	75 19                	jne    80177a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801761:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801768:	00 
  801769:	8d 43 08             	lea    0x8(%ebx),%eax
  80176c:	89 04 24             	mov    %eax,(%esp)
  80176f:	e8 3c e9 ff ff       	call   8000b0 <sys_cputs>
		b->idx = 0;
  801774:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80177a:	ff 43 04             	incl   0x4(%ebx)
}
  80177d:	83 c4 14             	add    $0x14,%esp
  801780:	5b                   	pop    %ebx
  801781:	5d                   	pop    %ebp
  801782:	c3                   	ret    

00801783 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80178c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801793:	00 00 00 
	b.cnt = 0;
  801796:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80179d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8017a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8017b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b8:	c7 04 24 44 17 80 00 	movl   $0x801744,(%esp)
  8017bf:	e8 82 01 00 00       	call   801946 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8017c4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ce:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8017d4:	89 04 24             	mov    %eax,(%esp)
  8017d7:	e8 d4 e8 ff ff       	call   8000b0 <sys_cputs>

	return b.cnt;
}
  8017dc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8017e2:	c9                   	leave  
  8017e3:	c3                   	ret    

008017e4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017ea:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8017ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f4:	89 04 24             	mov    %eax,(%esp)
  8017f7:	e8 87 ff ff ff       	call   801783 <vcprintf>
	va_end(ap);

	return cnt;
}
  8017fc:	c9                   	leave  
  8017fd:	c3                   	ret    
	...

00801800 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	57                   	push   %edi
  801804:	56                   	push   %esi
  801805:	53                   	push   %ebx
  801806:	83 ec 3c             	sub    $0x3c,%esp
  801809:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80180c:	89 d7                	mov    %edx,%edi
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801814:	8b 45 0c             	mov    0xc(%ebp),%eax
  801817:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80181a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80181d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801820:	85 c0                	test   %eax,%eax
  801822:	75 08                	jne    80182c <printnum+0x2c>
  801824:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801827:	39 45 10             	cmp    %eax,0x10(%ebp)
  80182a:	77 57                	ja     801883 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80182c:	89 74 24 10          	mov    %esi,0x10(%esp)
  801830:	4b                   	dec    %ebx
  801831:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801835:	8b 45 10             	mov    0x10(%ebp),%eax
  801838:	89 44 24 08          	mov    %eax,0x8(%esp)
  80183c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801840:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801844:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80184b:	00 
  80184c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80184f:	89 04 24             	mov    %eax,(%esp)
  801852:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801855:	89 44 24 04          	mov    %eax,0x4(%esp)
  801859:	e8 d2 09 00 00       	call   802230 <__udivdi3>
  80185e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801862:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801866:	89 04 24             	mov    %eax,(%esp)
  801869:	89 54 24 04          	mov    %edx,0x4(%esp)
  80186d:	89 fa                	mov    %edi,%edx
  80186f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801872:	e8 89 ff ff ff       	call   801800 <printnum>
  801877:	eb 0f                	jmp    801888 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801879:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80187d:	89 34 24             	mov    %esi,(%esp)
  801880:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801883:	4b                   	dec    %ebx
  801884:	85 db                	test   %ebx,%ebx
  801886:	7f f1                	jg     801879 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801888:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80188c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801890:	8b 45 10             	mov    0x10(%ebp),%eax
  801893:	89 44 24 08          	mov    %eax,0x8(%esp)
  801897:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80189e:	00 
  80189f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8018a2:	89 04 24             	mov    %eax,(%esp)
  8018a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ac:	e8 9f 0a 00 00       	call   802350 <__umoddi3>
  8018b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8018b5:	0f be 80 03 26 80 00 	movsbl 0x802603(%eax),%eax
  8018bc:	89 04 24             	mov    %eax,(%esp)
  8018bf:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8018c2:	83 c4 3c             	add    $0x3c,%esp
  8018c5:	5b                   	pop    %ebx
  8018c6:	5e                   	pop    %esi
  8018c7:	5f                   	pop    %edi
  8018c8:	5d                   	pop    %ebp
  8018c9:	c3                   	ret    

008018ca <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8018cd:	83 fa 01             	cmp    $0x1,%edx
  8018d0:	7e 0e                	jle    8018e0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8018d2:	8b 10                	mov    (%eax),%edx
  8018d4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8018d7:	89 08                	mov    %ecx,(%eax)
  8018d9:	8b 02                	mov    (%edx),%eax
  8018db:	8b 52 04             	mov    0x4(%edx),%edx
  8018de:	eb 22                	jmp    801902 <getuint+0x38>
	else if (lflag)
  8018e0:	85 d2                	test   %edx,%edx
  8018e2:	74 10                	je     8018f4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8018e4:	8b 10                	mov    (%eax),%edx
  8018e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8018e9:	89 08                	mov    %ecx,(%eax)
  8018eb:	8b 02                	mov    (%edx),%eax
  8018ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f2:	eb 0e                	jmp    801902 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8018f4:	8b 10                	mov    (%eax),%edx
  8018f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8018f9:	89 08                	mov    %ecx,(%eax)
  8018fb:	8b 02                	mov    (%edx),%eax
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801902:	5d                   	pop    %ebp
  801903:	c3                   	ret    

00801904 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80190a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80190d:	8b 10                	mov    (%eax),%edx
  80190f:	3b 50 04             	cmp    0x4(%eax),%edx
  801912:	73 08                	jae    80191c <sprintputch+0x18>
		*b->buf++ = ch;
  801914:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801917:	88 0a                	mov    %cl,(%edx)
  801919:	42                   	inc    %edx
  80191a:	89 10                	mov    %edx,(%eax)
}
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    

0080191e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801924:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801927:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80192b:	8b 45 10             	mov    0x10(%ebp),%eax
  80192e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801932:	8b 45 0c             	mov    0xc(%ebp),%eax
  801935:	89 44 24 04          	mov    %eax,0x4(%esp)
  801939:	8b 45 08             	mov    0x8(%ebp),%eax
  80193c:	89 04 24             	mov    %eax,(%esp)
  80193f:	e8 02 00 00 00       	call   801946 <vprintfmt>
	va_end(ap);
}
  801944:	c9                   	leave  
  801945:	c3                   	ret    

00801946 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	57                   	push   %edi
  80194a:	56                   	push   %esi
  80194b:	53                   	push   %ebx
  80194c:	83 ec 4c             	sub    $0x4c,%esp
  80194f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801952:	8b 75 10             	mov    0x10(%ebp),%esi
  801955:	eb 12                	jmp    801969 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801957:	85 c0                	test   %eax,%eax
  801959:	0f 84 6b 03 00 00    	je     801cca <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80195f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801963:	89 04 24             	mov    %eax,(%esp)
  801966:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801969:	0f b6 06             	movzbl (%esi),%eax
  80196c:	46                   	inc    %esi
  80196d:	83 f8 25             	cmp    $0x25,%eax
  801970:	75 e5                	jne    801957 <vprintfmt+0x11>
  801972:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801976:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80197d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801982:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801989:	b9 00 00 00 00       	mov    $0x0,%ecx
  80198e:	eb 26                	jmp    8019b6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801990:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801993:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801997:	eb 1d                	jmp    8019b6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801999:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80199c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8019a0:	eb 14                	jmp    8019b6 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8019a5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8019ac:	eb 08                	jmp    8019b6 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8019ae:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8019b1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019b6:	0f b6 06             	movzbl (%esi),%eax
  8019b9:	8d 56 01             	lea    0x1(%esi),%edx
  8019bc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8019bf:	8a 16                	mov    (%esi),%dl
  8019c1:	83 ea 23             	sub    $0x23,%edx
  8019c4:	80 fa 55             	cmp    $0x55,%dl
  8019c7:	0f 87 e1 02 00 00    	ja     801cae <vprintfmt+0x368>
  8019cd:	0f b6 d2             	movzbl %dl,%edx
  8019d0:	ff 24 95 40 27 80 00 	jmp    *0x802740(,%edx,4)
  8019d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8019da:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8019df:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8019e2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8019e6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8019e9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8019ec:	83 fa 09             	cmp    $0x9,%edx
  8019ef:	77 2a                	ja     801a1b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8019f1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8019f2:	eb eb                	jmp    8019df <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8019f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f7:	8d 50 04             	lea    0x4(%eax),%edx
  8019fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8019fd:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8019ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801a02:	eb 17                	jmp    801a1b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801a04:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801a08:	78 98                	js     8019a2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a0a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801a0d:	eb a7                	jmp    8019b6 <vprintfmt+0x70>
  801a0f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801a12:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801a19:	eb 9b                	jmp    8019b6 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801a1b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801a1f:	79 95                	jns    8019b6 <vprintfmt+0x70>
  801a21:	eb 8b                	jmp    8019ae <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801a23:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a24:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801a27:	eb 8d                	jmp    8019b6 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801a29:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2c:	8d 50 04             	lea    0x4(%eax),%edx
  801a2f:	89 55 14             	mov    %edx,0x14(%ebp)
  801a32:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a36:	8b 00                	mov    (%eax),%eax
  801a38:	89 04 24             	mov    %eax,(%esp)
  801a3b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a3e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801a41:	e9 23 ff ff ff       	jmp    801969 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801a46:	8b 45 14             	mov    0x14(%ebp),%eax
  801a49:	8d 50 04             	lea    0x4(%eax),%edx
  801a4c:	89 55 14             	mov    %edx,0x14(%ebp)
  801a4f:	8b 00                	mov    (%eax),%eax
  801a51:	85 c0                	test   %eax,%eax
  801a53:	79 02                	jns    801a57 <vprintfmt+0x111>
  801a55:	f7 d8                	neg    %eax
  801a57:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801a59:	83 f8 10             	cmp    $0x10,%eax
  801a5c:	7f 0b                	jg     801a69 <vprintfmt+0x123>
  801a5e:	8b 04 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%eax
  801a65:	85 c0                	test   %eax,%eax
  801a67:	75 23                	jne    801a8c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801a69:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801a6d:	c7 44 24 08 1b 26 80 	movl   $0x80261b,0x8(%esp)
  801a74:	00 
  801a75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a79:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7c:	89 04 24             	mov    %eax,(%esp)
  801a7f:	e8 9a fe ff ff       	call   80191e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a84:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801a87:	e9 dd fe ff ff       	jmp    801969 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801a8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a90:	c7 44 24 08 61 25 80 	movl   $0x802561,0x8(%esp)
  801a97:	00 
  801a98:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a9c:	8b 55 08             	mov    0x8(%ebp),%edx
  801a9f:	89 14 24             	mov    %edx,(%esp)
  801aa2:	e8 77 fe ff ff       	call   80191e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801aa7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801aaa:	e9 ba fe ff ff       	jmp    801969 <vprintfmt+0x23>
  801aaf:	89 f9                	mov    %edi,%ecx
  801ab1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ab4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801ab7:	8b 45 14             	mov    0x14(%ebp),%eax
  801aba:	8d 50 04             	lea    0x4(%eax),%edx
  801abd:	89 55 14             	mov    %edx,0x14(%ebp)
  801ac0:	8b 30                	mov    (%eax),%esi
  801ac2:	85 f6                	test   %esi,%esi
  801ac4:	75 05                	jne    801acb <vprintfmt+0x185>
				p = "(null)";
  801ac6:	be 14 26 80 00       	mov    $0x802614,%esi
			if (width > 0 && padc != '-')
  801acb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801acf:	0f 8e 84 00 00 00    	jle    801b59 <vprintfmt+0x213>
  801ad5:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  801ad9:	74 7e                	je     801b59 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  801adb:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801adf:	89 34 24             	mov    %esi,(%esp)
  801ae2:	e8 8b 02 00 00       	call   801d72 <strnlen>
  801ae7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801aea:	29 c2                	sub    %eax,%edx
  801aec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  801aef:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  801af3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  801af6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  801af9:	89 de                	mov    %ebx,%esi
  801afb:	89 d3                	mov    %edx,%ebx
  801afd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801aff:	eb 0b                	jmp    801b0c <vprintfmt+0x1c6>
					putch(padc, putdat);
  801b01:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b05:	89 3c 24             	mov    %edi,(%esp)
  801b08:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801b0b:	4b                   	dec    %ebx
  801b0c:	85 db                	test   %ebx,%ebx
  801b0e:	7f f1                	jg     801b01 <vprintfmt+0x1bb>
  801b10:	8b 7d cc             	mov    -0x34(%ebp),%edi
  801b13:	89 f3                	mov    %esi,%ebx
  801b15:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  801b18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	79 05                	jns    801b24 <vprintfmt+0x1de>
  801b1f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b24:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b27:	29 c2                	sub    %eax,%edx
  801b29:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801b2c:	eb 2b                	jmp    801b59 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801b2e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801b32:	74 18                	je     801b4c <vprintfmt+0x206>
  801b34:	8d 50 e0             	lea    -0x20(%eax),%edx
  801b37:	83 fa 5e             	cmp    $0x5e,%edx
  801b3a:	76 10                	jbe    801b4c <vprintfmt+0x206>
					putch('?', putdat);
  801b3c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b40:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801b47:	ff 55 08             	call   *0x8(%ebp)
  801b4a:	eb 0a                	jmp    801b56 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801b4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b50:	89 04 24             	mov    %eax,(%esp)
  801b53:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801b56:	ff 4d e4             	decl   -0x1c(%ebp)
  801b59:	0f be 06             	movsbl (%esi),%eax
  801b5c:	46                   	inc    %esi
  801b5d:	85 c0                	test   %eax,%eax
  801b5f:	74 21                	je     801b82 <vprintfmt+0x23c>
  801b61:	85 ff                	test   %edi,%edi
  801b63:	78 c9                	js     801b2e <vprintfmt+0x1e8>
  801b65:	4f                   	dec    %edi
  801b66:	79 c6                	jns    801b2e <vprintfmt+0x1e8>
  801b68:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b6b:	89 de                	mov    %ebx,%esi
  801b6d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801b70:	eb 18                	jmp    801b8a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801b72:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b76:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801b7d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801b7f:	4b                   	dec    %ebx
  801b80:	eb 08                	jmp    801b8a <vprintfmt+0x244>
  801b82:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b85:	89 de                	mov    %ebx,%esi
  801b87:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801b8a:	85 db                	test   %ebx,%ebx
  801b8c:	7f e4                	jg     801b72 <vprintfmt+0x22c>
  801b8e:	89 7d 08             	mov    %edi,0x8(%ebp)
  801b91:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b93:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801b96:	e9 ce fd ff ff       	jmp    801969 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801b9b:	83 f9 01             	cmp    $0x1,%ecx
  801b9e:	7e 10                	jle    801bb0 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801ba0:	8b 45 14             	mov    0x14(%ebp),%eax
  801ba3:	8d 50 08             	lea    0x8(%eax),%edx
  801ba6:	89 55 14             	mov    %edx,0x14(%ebp)
  801ba9:	8b 30                	mov    (%eax),%esi
  801bab:	8b 78 04             	mov    0x4(%eax),%edi
  801bae:	eb 26                	jmp    801bd6 <vprintfmt+0x290>
	else if (lflag)
  801bb0:	85 c9                	test   %ecx,%ecx
  801bb2:	74 12                	je     801bc6 <vprintfmt+0x280>
		return va_arg(*ap, long);
  801bb4:	8b 45 14             	mov    0x14(%ebp),%eax
  801bb7:	8d 50 04             	lea    0x4(%eax),%edx
  801bba:	89 55 14             	mov    %edx,0x14(%ebp)
  801bbd:	8b 30                	mov    (%eax),%esi
  801bbf:	89 f7                	mov    %esi,%edi
  801bc1:	c1 ff 1f             	sar    $0x1f,%edi
  801bc4:	eb 10                	jmp    801bd6 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801bc6:	8b 45 14             	mov    0x14(%ebp),%eax
  801bc9:	8d 50 04             	lea    0x4(%eax),%edx
  801bcc:	89 55 14             	mov    %edx,0x14(%ebp)
  801bcf:	8b 30                	mov    (%eax),%esi
  801bd1:	89 f7                	mov    %esi,%edi
  801bd3:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801bd6:	85 ff                	test   %edi,%edi
  801bd8:	78 0a                	js     801be4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801bda:	b8 0a 00 00 00       	mov    $0xa,%eax
  801bdf:	e9 8c 00 00 00       	jmp    801c70 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801be4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801be8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801bef:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801bf2:	f7 de                	neg    %esi
  801bf4:	83 d7 00             	adc    $0x0,%edi
  801bf7:	f7 df                	neg    %edi
			}
			base = 10;
  801bf9:	b8 0a 00 00 00       	mov    $0xa,%eax
  801bfe:	eb 70                	jmp    801c70 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801c00:	89 ca                	mov    %ecx,%edx
  801c02:	8d 45 14             	lea    0x14(%ebp),%eax
  801c05:	e8 c0 fc ff ff       	call   8018ca <getuint>
  801c0a:	89 c6                	mov    %eax,%esi
  801c0c:	89 d7                	mov    %edx,%edi
			base = 10;
  801c0e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801c13:	eb 5b                	jmp    801c70 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  801c15:	89 ca                	mov    %ecx,%edx
  801c17:	8d 45 14             	lea    0x14(%ebp),%eax
  801c1a:	e8 ab fc ff ff       	call   8018ca <getuint>
  801c1f:	89 c6                	mov    %eax,%esi
  801c21:	89 d7                	mov    %edx,%edi
			base = 8;
  801c23:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801c28:	eb 46                	jmp    801c70 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  801c2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c2e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801c35:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801c38:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c3c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801c43:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801c46:	8b 45 14             	mov    0x14(%ebp),%eax
  801c49:	8d 50 04             	lea    0x4(%eax),%edx
  801c4c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801c4f:	8b 30                	mov    (%eax),%esi
  801c51:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801c56:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801c5b:	eb 13                	jmp    801c70 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801c5d:	89 ca                	mov    %ecx,%edx
  801c5f:	8d 45 14             	lea    0x14(%ebp),%eax
  801c62:	e8 63 fc ff ff       	call   8018ca <getuint>
  801c67:	89 c6                	mov    %eax,%esi
  801c69:	89 d7                	mov    %edx,%edi
			base = 16;
  801c6b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801c70:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801c74:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c78:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c7b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801c7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c83:	89 34 24             	mov    %esi,(%esp)
  801c86:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c8a:	89 da                	mov    %ebx,%edx
  801c8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8f:	e8 6c fb ff ff       	call   801800 <printnum>
			break;
  801c94:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801c97:	e9 cd fc ff ff       	jmp    801969 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801c9c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ca0:	89 04 24             	mov    %eax,(%esp)
  801ca3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ca6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801ca9:	e9 bb fc ff ff       	jmp    801969 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801cae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cb2:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801cb9:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801cbc:	eb 01                	jmp    801cbf <vprintfmt+0x379>
  801cbe:	4e                   	dec    %esi
  801cbf:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801cc3:	75 f9                	jne    801cbe <vprintfmt+0x378>
  801cc5:	e9 9f fc ff ff       	jmp    801969 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801cca:	83 c4 4c             	add    $0x4c,%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    

00801cd2 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	83 ec 28             	sub    $0x28,%esp
  801cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801cde:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ce1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ce5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ce8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801cef:	85 c0                	test   %eax,%eax
  801cf1:	74 30                	je     801d23 <vsnprintf+0x51>
  801cf3:	85 d2                	test   %edx,%edx
  801cf5:	7e 33                	jle    801d2a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801cf7:	8b 45 14             	mov    0x14(%ebp),%eax
  801cfa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cfe:	8b 45 10             	mov    0x10(%ebp),%eax
  801d01:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d05:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801d08:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d0c:	c7 04 24 04 19 80 00 	movl   $0x801904,(%esp)
  801d13:	e8 2e fc ff ff       	call   801946 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801d18:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801d1b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801d1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d21:	eb 0c                	jmp    801d2f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801d23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d28:	eb 05                	jmp    801d2f <vsnprintf+0x5d>
  801d2a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801d2f:	c9                   	leave  
  801d30:	c3                   	ret    

00801d31 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801d37:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801d3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d3e:	8b 45 10             	mov    0x10(%ebp),%eax
  801d41:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d48:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4f:	89 04 24             	mov    %eax,(%esp)
  801d52:	e8 7b ff ff ff       	call   801cd2 <vsnprintf>
	va_end(ap);

	return rc;
}
  801d57:	c9                   	leave  
  801d58:	c3                   	ret    
  801d59:	00 00                	add    %al,(%eax)
	...

00801d5c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801d5c:	55                   	push   %ebp
  801d5d:	89 e5                	mov    %esp,%ebp
  801d5f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801d62:	b8 00 00 00 00       	mov    $0x0,%eax
  801d67:	eb 01                	jmp    801d6a <strlen+0xe>
		n++;
  801d69:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801d6a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801d6e:	75 f9                	jne    801d69 <strlen+0xd>
		n++;
	return n;
}
  801d70:	5d                   	pop    %ebp
  801d71:	c3                   	ret    

00801d72 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801d78:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801d7b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d80:	eb 01                	jmp    801d83 <strnlen+0x11>
		n++;
  801d82:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801d83:	39 d0                	cmp    %edx,%eax
  801d85:	74 06                	je     801d8d <strnlen+0x1b>
  801d87:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801d8b:	75 f5                	jne    801d82 <strnlen+0x10>
		n++;
	return n;
}
  801d8d:	5d                   	pop    %ebp
  801d8e:	c3                   	ret    

00801d8f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801d8f:	55                   	push   %ebp
  801d90:	89 e5                	mov    %esp,%ebp
  801d92:	53                   	push   %ebx
  801d93:	8b 45 08             	mov    0x8(%ebp),%eax
  801d96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801d99:	ba 00 00 00 00       	mov    $0x0,%edx
  801d9e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801da1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801da4:	42                   	inc    %edx
  801da5:	84 c9                	test   %cl,%cl
  801da7:	75 f5                	jne    801d9e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801da9:	5b                   	pop    %ebx
  801daa:	5d                   	pop    %ebp
  801dab:	c3                   	ret    

00801dac <strcat>:

char *
strcat(char *dst, const char *src)
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	53                   	push   %ebx
  801db0:	83 ec 08             	sub    $0x8,%esp
  801db3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801db6:	89 1c 24             	mov    %ebx,(%esp)
  801db9:	e8 9e ff ff ff       	call   801d5c <strlen>
	strcpy(dst + len, src);
  801dbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc5:	01 d8                	add    %ebx,%eax
  801dc7:	89 04 24             	mov    %eax,(%esp)
  801dca:	e8 c0 ff ff ff       	call   801d8f <strcpy>
	return dst;
}
  801dcf:	89 d8                	mov    %ebx,%eax
  801dd1:	83 c4 08             	add    $0x8,%esp
  801dd4:	5b                   	pop    %ebx
  801dd5:	5d                   	pop    %ebp
  801dd6:	c3                   	ret    

00801dd7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	56                   	push   %esi
  801ddb:	53                   	push   %ebx
  801ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801de5:	b9 00 00 00 00       	mov    $0x0,%ecx
  801dea:	eb 0c                	jmp    801df8 <strncpy+0x21>
		*dst++ = *src;
  801dec:	8a 1a                	mov    (%edx),%bl
  801dee:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801df1:	80 3a 01             	cmpb   $0x1,(%edx)
  801df4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801df7:	41                   	inc    %ecx
  801df8:	39 f1                	cmp    %esi,%ecx
  801dfa:	75 f0                	jne    801dec <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801dfc:	5b                   	pop    %ebx
  801dfd:	5e                   	pop    %esi
  801dfe:	5d                   	pop    %ebp
  801dff:	c3                   	ret    

00801e00 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	56                   	push   %esi
  801e04:	53                   	push   %ebx
  801e05:	8b 75 08             	mov    0x8(%ebp),%esi
  801e08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e0b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e0e:	85 d2                	test   %edx,%edx
  801e10:	75 0a                	jne    801e1c <strlcpy+0x1c>
  801e12:	89 f0                	mov    %esi,%eax
  801e14:	eb 1a                	jmp    801e30 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801e16:	88 18                	mov    %bl,(%eax)
  801e18:	40                   	inc    %eax
  801e19:	41                   	inc    %ecx
  801e1a:	eb 02                	jmp    801e1e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801e1c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801e1e:	4a                   	dec    %edx
  801e1f:	74 0a                	je     801e2b <strlcpy+0x2b>
  801e21:	8a 19                	mov    (%ecx),%bl
  801e23:	84 db                	test   %bl,%bl
  801e25:	75 ef                	jne    801e16 <strlcpy+0x16>
  801e27:	89 c2                	mov    %eax,%edx
  801e29:	eb 02                	jmp    801e2d <strlcpy+0x2d>
  801e2b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801e2d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801e30:	29 f0                	sub    %esi,%eax
}
  801e32:	5b                   	pop    %ebx
  801e33:	5e                   	pop    %esi
  801e34:	5d                   	pop    %ebp
  801e35:	c3                   	ret    

00801e36 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e3c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801e3f:	eb 02                	jmp    801e43 <strcmp+0xd>
		p++, q++;
  801e41:	41                   	inc    %ecx
  801e42:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801e43:	8a 01                	mov    (%ecx),%al
  801e45:	84 c0                	test   %al,%al
  801e47:	74 04                	je     801e4d <strcmp+0x17>
  801e49:	3a 02                	cmp    (%edx),%al
  801e4b:	74 f4                	je     801e41 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801e4d:	0f b6 c0             	movzbl %al,%eax
  801e50:	0f b6 12             	movzbl (%edx),%edx
  801e53:	29 d0                	sub    %edx,%eax
}
  801e55:	5d                   	pop    %ebp
  801e56:	c3                   	ret    

00801e57 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801e57:	55                   	push   %ebp
  801e58:	89 e5                	mov    %esp,%ebp
  801e5a:	53                   	push   %ebx
  801e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e61:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801e64:	eb 03                	jmp    801e69 <strncmp+0x12>
		n--, p++, q++;
  801e66:	4a                   	dec    %edx
  801e67:	40                   	inc    %eax
  801e68:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801e69:	85 d2                	test   %edx,%edx
  801e6b:	74 14                	je     801e81 <strncmp+0x2a>
  801e6d:	8a 18                	mov    (%eax),%bl
  801e6f:	84 db                	test   %bl,%bl
  801e71:	74 04                	je     801e77 <strncmp+0x20>
  801e73:	3a 19                	cmp    (%ecx),%bl
  801e75:	74 ef                	je     801e66 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801e77:	0f b6 00             	movzbl (%eax),%eax
  801e7a:	0f b6 11             	movzbl (%ecx),%edx
  801e7d:	29 d0                	sub    %edx,%eax
  801e7f:	eb 05                	jmp    801e86 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801e81:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801e86:	5b                   	pop    %ebx
  801e87:	5d                   	pop    %ebp
  801e88:	c3                   	ret    

00801e89 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801e89:	55                   	push   %ebp
  801e8a:	89 e5                	mov    %esp,%ebp
  801e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801e92:	eb 05                	jmp    801e99 <strchr+0x10>
		if (*s == c)
  801e94:	38 ca                	cmp    %cl,%dl
  801e96:	74 0c                	je     801ea4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801e98:	40                   	inc    %eax
  801e99:	8a 10                	mov    (%eax),%dl
  801e9b:	84 d2                	test   %dl,%dl
  801e9d:	75 f5                	jne    801e94 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801e9f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ea4:	5d                   	pop    %ebp
  801ea5:	c3                   	ret    

00801ea6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	8b 45 08             	mov    0x8(%ebp),%eax
  801eac:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801eaf:	eb 05                	jmp    801eb6 <strfind+0x10>
		if (*s == c)
  801eb1:	38 ca                	cmp    %cl,%dl
  801eb3:	74 07                	je     801ebc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801eb5:	40                   	inc    %eax
  801eb6:	8a 10                	mov    (%eax),%dl
  801eb8:	84 d2                	test   %dl,%dl
  801eba:	75 f5                	jne    801eb1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801ebc:	5d                   	pop    %ebp
  801ebd:	c3                   	ret    

00801ebe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ebe:	55                   	push   %ebp
  801ebf:	89 e5                	mov    %esp,%ebp
  801ec1:	57                   	push   %edi
  801ec2:	56                   	push   %esi
  801ec3:	53                   	push   %ebx
  801ec4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801ecd:	85 c9                	test   %ecx,%ecx
  801ecf:	74 30                	je     801f01 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801ed1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ed7:	75 25                	jne    801efe <memset+0x40>
  801ed9:	f6 c1 03             	test   $0x3,%cl
  801edc:	75 20                	jne    801efe <memset+0x40>
		c &= 0xFF;
  801ede:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ee1:	89 d3                	mov    %edx,%ebx
  801ee3:	c1 e3 08             	shl    $0x8,%ebx
  801ee6:	89 d6                	mov    %edx,%esi
  801ee8:	c1 e6 18             	shl    $0x18,%esi
  801eeb:	89 d0                	mov    %edx,%eax
  801eed:	c1 e0 10             	shl    $0x10,%eax
  801ef0:	09 f0                	or     %esi,%eax
  801ef2:	09 d0                	or     %edx,%eax
  801ef4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801ef6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801ef9:	fc                   	cld    
  801efa:	f3 ab                	rep stos %eax,%es:(%edi)
  801efc:	eb 03                	jmp    801f01 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801efe:	fc                   	cld    
  801eff:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801f01:	89 f8                	mov    %edi,%eax
  801f03:	5b                   	pop    %ebx
  801f04:	5e                   	pop    %esi
  801f05:	5f                   	pop    %edi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    

00801f08 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	57                   	push   %edi
  801f0c:	56                   	push   %esi
  801f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f10:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f13:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801f16:	39 c6                	cmp    %eax,%esi
  801f18:	73 34                	jae    801f4e <memmove+0x46>
  801f1a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801f1d:	39 d0                	cmp    %edx,%eax
  801f1f:	73 2d                	jae    801f4e <memmove+0x46>
		s += n;
		d += n;
  801f21:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f24:	f6 c2 03             	test   $0x3,%dl
  801f27:	75 1b                	jne    801f44 <memmove+0x3c>
  801f29:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801f2f:	75 13                	jne    801f44 <memmove+0x3c>
  801f31:	f6 c1 03             	test   $0x3,%cl
  801f34:	75 0e                	jne    801f44 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801f36:	83 ef 04             	sub    $0x4,%edi
  801f39:	8d 72 fc             	lea    -0x4(%edx),%esi
  801f3c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801f3f:	fd                   	std    
  801f40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f42:	eb 07                	jmp    801f4b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801f44:	4f                   	dec    %edi
  801f45:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801f48:	fd                   	std    
  801f49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801f4b:	fc                   	cld    
  801f4c:	eb 20                	jmp    801f6e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801f4e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801f54:	75 13                	jne    801f69 <memmove+0x61>
  801f56:	a8 03                	test   $0x3,%al
  801f58:	75 0f                	jne    801f69 <memmove+0x61>
  801f5a:	f6 c1 03             	test   $0x3,%cl
  801f5d:	75 0a                	jne    801f69 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801f5f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801f62:	89 c7                	mov    %eax,%edi
  801f64:	fc                   	cld    
  801f65:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801f67:	eb 05                	jmp    801f6e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801f69:	89 c7                	mov    %eax,%edi
  801f6b:	fc                   	cld    
  801f6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801f6e:	5e                   	pop    %esi
  801f6f:	5f                   	pop    %edi
  801f70:	5d                   	pop    %ebp
  801f71:	c3                   	ret    

00801f72 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801f78:	8b 45 10             	mov    0x10(%ebp),%eax
  801f7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f86:	8b 45 08             	mov    0x8(%ebp),%eax
  801f89:	89 04 24             	mov    %eax,(%esp)
  801f8c:	e8 77 ff ff ff       	call   801f08 <memmove>
}
  801f91:	c9                   	leave  
  801f92:	c3                   	ret    

00801f93 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801f93:	55                   	push   %ebp
  801f94:	89 e5                	mov    %esp,%ebp
  801f96:	57                   	push   %edi
  801f97:	56                   	push   %esi
  801f98:	53                   	push   %ebx
  801f99:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f9c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801fa2:	ba 00 00 00 00       	mov    $0x0,%edx
  801fa7:	eb 16                	jmp    801fbf <memcmp+0x2c>
		if (*s1 != *s2)
  801fa9:	8a 04 17             	mov    (%edi,%edx,1),%al
  801fac:	42                   	inc    %edx
  801fad:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801fb1:	38 c8                	cmp    %cl,%al
  801fb3:	74 0a                	je     801fbf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801fb5:	0f b6 c0             	movzbl %al,%eax
  801fb8:	0f b6 c9             	movzbl %cl,%ecx
  801fbb:	29 c8                	sub    %ecx,%eax
  801fbd:	eb 09                	jmp    801fc8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801fbf:	39 da                	cmp    %ebx,%edx
  801fc1:	75 e6                	jne    801fa9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801fc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fc8:	5b                   	pop    %ebx
  801fc9:	5e                   	pop    %esi
  801fca:	5f                   	pop    %edi
  801fcb:	5d                   	pop    %ebp
  801fcc:	c3                   	ret    

00801fcd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801fd6:	89 c2                	mov    %eax,%edx
  801fd8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801fdb:	eb 05                	jmp    801fe2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801fdd:	38 08                	cmp    %cl,(%eax)
  801fdf:	74 05                	je     801fe6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801fe1:	40                   	inc    %eax
  801fe2:	39 d0                	cmp    %edx,%eax
  801fe4:	72 f7                	jb     801fdd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    

00801fe8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	57                   	push   %edi
  801fec:	56                   	push   %esi
  801fed:	53                   	push   %ebx
  801fee:	8b 55 08             	mov    0x8(%ebp),%edx
  801ff1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ff4:	eb 01                	jmp    801ff7 <strtol+0xf>
		s++;
  801ff6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ff7:	8a 02                	mov    (%edx),%al
  801ff9:	3c 20                	cmp    $0x20,%al
  801ffb:	74 f9                	je     801ff6 <strtol+0xe>
  801ffd:	3c 09                	cmp    $0x9,%al
  801fff:	74 f5                	je     801ff6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802001:	3c 2b                	cmp    $0x2b,%al
  802003:	75 08                	jne    80200d <strtol+0x25>
		s++;
  802005:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  802006:	bf 00 00 00 00       	mov    $0x0,%edi
  80200b:	eb 13                	jmp    802020 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80200d:	3c 2d                	cmp    $0x2d,%al
  80200f:	75 0a                	jne    80201b <strtol+0x33>
		s++, neg = 1;
  802011:	8d 52 01             	lea    0x1(%edx),%edx
  802014:	bf 01 00 00 00       	mov    $0x1,%edi
  802019:	eb 05                	jmp    802020 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80201b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802020:	85 db                	test   %ebx,%ebx
  802022:	74 05                	je     802029 <strtol+0x41>
  802024:	83 fb 10             	cmp    $0x10,%ebx
  802027:	75 28                	jne    802051 <strtol+0x69>
  802029:	8a 02                	mov    (%edx),%al
  80202b:	3c 30                	cmp    $0x30,%al
  80202d:	75 10                	jne    80203f <strtol+0x57>
  80202f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802033:	75 0a                	jne    80203f <strtol+0x57>
		s += 2, base = 16;
  802035:	83 c2 02             	add    $0x2,%edx
  802038:	bb 10 00 00 00       	mov    $0x10,%ebx
  80203d:	eb 12                	jmp    802051 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80203f:	85 db                	test   %ebx,%ebx
  802041:	75 0e                	jne    802051 <strtol+0x69>
  802043:	3c 30                	cmp    $0x30,%al
  802045:	75 05                	jne    80204c <strtol+0x64>
		s++, base = 8;
  802047:	42                   	inc    %edx
  802048:	b3 08                	mov    $0x8,%bl
  80204a:	eb 05                	jmp    802051 <strtol+0x69>
	else if (base == 0)
		base = 10;
  80204c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  802051:	b8 00 00 00 00       	mov    $0x0,%eax
  802056:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802058:	8a 0a                	mov    (%edx),%cl
  80205a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80205d:	80 fb 09             	cmp    $0x9,%bl
  802060:	77 08                	ja     80206a <strtol+0x82>
			dig = *s - '0';
  802062:	0f be c9             	movsbl %cl,%ecx
  802065:	83 e9 30             	sub    $0x30,%ecx
  802068:	eb 1e                	jmp    802088 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80206a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80206d:	80 fb 19             	cmp    $0x19,%bl
  802070:	77 08                	ja     80207a <strtol+0x92>
			dig = *s - 'a' + 10;
  802072:	0f be c9             	movsbl %cl,%ecx
  802075:	83 e9 57             	sub    $0x57,%ecx
  802078:	eb 0e                	jmp    802088 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80207a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80207d:	80 fb 19             	cmp    $0x19,%bl
  802080:	77 12                	ja     802094 <strtol+0xac>
			dig = *s - 'A' + 10;
  802082:	0f be c9             	movsbl %cl,%ecx
  802085:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  802088:	39 f1                	cmp    %esi,%ecx
  80208a:	7d 0c                	jge    802098 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  80208c:	42                   	inc    %edx
  80208d:	0f af c6             	imul   %esi,%eax
  802090:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  802092:	eb c4                	jmp    802058 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  802094:	89 c1                	mov    %eax,%ecx
  802096:	eb 02                	jmp    80209a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  802098:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  80209a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80209e:	74 05                	je     8020a5 <strtol+0xbd>
		*endptr = (char *) s;
  8020a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8020a3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8020a5:	85 ff                	test   %edi,%edi
  8020a7:	74 04                	je     8020ad <strtol+0xc5>
  8020a9:	89 c8                	mov    %ecx,%eax
  8020ab:	f7 d8                	neg    %eax
}
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
	...

008020b4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020b4:	55                   	push   %ebp
  8020b5:	89 e5                	mov    %esp,%ebp
  8020b7:	56                   	push   %esi
  8020b8:	53                   	push   %ebx
  8020b9:	83 ec 10             	sub    $0x10,%esp
  8020bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8020bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c2:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8020c5:	85 c0                	test   %eax,%eax
  8020c7:	74 0a                	je     8020d3 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8020c9:	89 04 24             	mov    %eax,(%esp)
  8020cc:	e8 c2 e2 ff ff       	call   800393 <sys_ipc_recv>
  8020d1:	eb 0c                	jmp    8020df <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8020d3:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8020da:	e8 b4 e2 ff ff       	call   800393 <sys_ipc_recv>
	}
	if (r < 0)
  8020df:	85 c0                	test   %eax,%eax
  8020e1:	79 16                	jns    8020f9 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8020e3:	85 db                	test   %ebx,%ebx
  8020e5:	74 06                	je     8020ed <ipc_recv+0x39>
  8020e7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8020ed:	85 f6                	test   %esi,%esi
  8020ef:	74 2c                	je     80211d <ipc_recv+0x69>
  8020f1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8020f7:	eb 24                	jmp    80211d <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8020f9:	85 db                	test   %ebx,%ebx
  8020fb:	74 0a                	je     802107 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  8020fd:	a1 08 40 80 00       	mov    0x804008,%eax
  802102:	8b 40 74             	mov    0x74(%eax),%eax
  802105:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  802107:	85 f6                	test   %esi,%esi
  802109:	74 0a                	je     802115 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  80210b:	a1 08 40 80 00       	mov    0x804008,%eax
  802110:	8b 40 78             	mov    0x78(%eax),%eax
  802113:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802115:	a1 08 40 80 00       	mov    0x804008,%eax
  80211a:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  80211d:	83 c4 10             	add    $0x10,%esp
  802120:	5b                   	pop    %ebx
  802121:	5e                   	pop    %esi
  802122:	5d                   	pop    %ebp
  802123:	c3                   	ret    

00802124 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802124:	55                   	push   %ebp
  802125:	89 e5                	mov    %esp,%ebp
  802127:	57                   	push   %edi
  802128:	56                   	push   %esi
  802129:	53                   	push   %ebx
  80212a:	83 ec 1c             	sub    $0x1c,%esp
  80212d:	8b 75 08             	mov    0x8(%ebp),%esi
  802130:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802133:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  802136:	85 db                	test   %ebx,%ebx
  802138:	74 19                	je     802153 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  80213a:	8b 45 14             	mov    0x14(%ebp),%eax
  80213d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802141:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802145:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802149:	89 34 24             	mov    %esi,(%esp)
  80214c:	e8 1f e2 ff ff       	call   800370 <sys_ipc_try_send>
  802151:	eb 1c                	jmp    80216f <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  802153:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80215a:	00 
  80215b:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802162:	ee 
  802163:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802167:	89 34 24             	mov    %esi,(%esp)
  80216a:	e8 01 e2 ff ff       	call   800370 <sys_ipc_try_send>
		}
		if (r == 0)
  80216f:	85 c0                	test   %eax,%eax
  802171:	74 2c                	je     80219f <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802173:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802176:	74 20                	je     802198 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802178:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80217c:	c7 44 24 08 04 29 80 	movl   $0x802904,0x8(%esp)
  802183:	00 
  802184:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  80218b:	00 
  80218c:	c7 04 24 17 29 80 00 	movl   $0x802917,(%esp)
  802193:	e8 54 f5 ff ff       	call   8016ec <_panic>
		}
		sys_yield();
  802198:	e8 c1 df ff ff       	call   80015e <sys_yield>
	}
  80219d:	eb 97                	jmp    802136 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  80219f:	83 c4 1c             	add    $0x1c,%esp
  8021a2:	5b                   	pop    %ebx
  8021a3:	5e                   	pop    %esi
  8021a4:	5f                   	pop    %edi
  8021a5:	5d                   	pop    %ebp
  8021a6:	c3                   	ret    

008021a7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021a7:	55                   	push   %ebp
  8021a8:	89 e5                	mov    %esp,%ebp
  8021aa:	53                   	push   %ebx
  8021ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8021ae:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021b3:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8021ba:	89 c2                	mov    %eax,%edx
  8021bc:	c1 e2 07             	shl    $0x7,%edx
  8021bf:	29 ca                	sub    %ecx,%edx
  8021c1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021c7:	8b 52 50             	mov    0x50(%edx),%edx
  8021ca:	39 da                	cmp    %ebx,%edx
  8021cc:	75 0f                	jne    8021dd <ipc_find_env+0x36>
			return envs[i].env_id;
  8021ce:	c1 e0 07             	shl    $0x7,%eax
  8021d1:	29 c8                	sub    %ecx,%eax
  8021d3:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8021d8:	8b 40 40             	mov    0x40(%eax),%eax
  8021db:	eb 0c                	jmp    8021e9 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8021dd:	40                   	inc    %eax
  8021de:	3d 00 04 00 00       	cmp    $0x400,%eax
  8021e3:	75 ce                	jne    8021b3 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8021e5:	66 b8 00 00          	mov    $0x0,%ax
}
  8021e9:	5b                   	pop    %ebx
  8021ea:	5d                   	pop    %ebp
  8021eb:	c3                   	ret    

008021ec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021ec:	55                   	push   %ebp
  8021ed:	89 e5                	mov    %esp,%ebp
  8021ef:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021f2:	89 c2                	mov    %eax,%edx
  8021f4:	c1 ea 16             	shr    $0x16,%edx
  8021f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021fe:	f6 c2 01             	test   $0x1,%dl
  802201:	74 1e                	je     802221 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802203:	c1 e8 0c             	shr    $0xc,%eax
  802206:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80220d:	a8 01                	test   $0x1,%al
  80220f:	74 17                	je     802228 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802211:	c1 e8 0c             	shr    $0xc,%eax
  802214:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80221b:	ef 
  80221c:	0f b7 c0             	movzwl %ax,%eax
  80221f:	eb 0c                	jmp    80222d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802221:	b8 00 00 00 00       	mov    $0x0,%eax
  802226:	eb 05                	jmp    80222d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802228:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80222d:	5d                   	pop    %ebp
  80222e:	c3                   	ret    
	...

00802230 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802230:	55                   	push   %ebp
  802231:	57                   	push   %edi
  802232:	56                   	push   %esi
  802233:	83 ec 10             	sub    $0x10,%esp
  802236:	8b 74 24 20          	mov    0x20(%esp),%esi
  80223a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80223e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802242:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802246:	89 cd                	mov    %ecx,%ebp
  802248:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80224c:	85 c0                	test   %eax,%eax
  80224e:	75 2c                	jne    80227c <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802250:	39 f9                	cmp    %edi,%ecx
  802252:	77 68                	ja     8022bc <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802254:	85 c9                	test   %ecx,%ecx
  802256:	75 0b                	jne    802263 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802258:	b8 01 00 00 00       	mov    $0x1,%eax
  80225d:	31 d2                	xor    %edx,%edx
  80225f:	f7 f1                	div    %ecx
  802261:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802263:	31 d2                	xor    %edx,%edx
  802265:	89 f8                	mov    %edi,%eax
  802267:	f7 f1                	div    %ecx
  802269:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80226b:	89 f0                	mov    %esi,%eax
  80226d:	f7 f1                	div    %ecx
  80226f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802271:	89 f0                	mov    %esi,%eax
  802273:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802275:	83 c4 10             	add    $0x10,%esp
  802278:	5e                   	pop    %esi
  802279:	5f                   	pop    %edi
  80227a:	5d                   	pop    %ebp
  80227b:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80227c:	39 f8                	cmp    %edi,%eax
  80227e:	77 2c                	ja     8022ac <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802280:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802283:	83 f6 1f             	xor    $0x1f,%esi
  802286:	75 4c                	jne    8022d4 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802288:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80228a:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80228f:	72 0a                	jb     80229b <__udivdi3+0x6b>
  802291:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802295:	0f 87 ad 00 00 00    	ja     802348 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80229b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022a0:	89 f0                	mov    %esi,%eax
  8022a2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022a4:	83 c4 10             	add    $0x10,%esp
  8022a7:	5e                   	pop    %esi
  8022a8:	5f                   	pop    %edi
  8022a9:	5d                   	pop    %ebp
  8022aa:	c3                   	ret    
  8022ab:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8022ac:	31 ff                	xor    %edi,%edi
  8022ae:	31 f6                	xor    %esi,%esi
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
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8022bc:	89 fa                	mov    %edi,%edx
  8022be:	89 f0                	mov    %esi,%eax
  8022c0:	f7 f1                	div    %ecx
  8022c2:	89 c6                	mov    %eax,%esi
  8022c4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8022c6:	89 f0                	mov    %esi,%eax
  8022c8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8022ca:	83 c4 10             	add    $0x10,%esp
  8022cd:	5e                   	pop    %esi
  8022ce:	5f                   	pop    %edi
  8022cf:	5d                   	pop    %ebp
  8022d0:	c3                   	ret    
  8022d1:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8022d4:	89 f1                	mov    %esi,%ecx
  8022d6:	d3 e0                	shl    %cl,%eax
  8022d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8022dc:	b8 20 00 00 00       	mov    $0x20,%eax
  8022e1:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8022e3:	89 ea                	mov    %ebp,%edx
  8022e5:	88 c1                	mov    %al,%cl
  8022e7:	d3 ea                	shr    %cl,%edx
  8022e9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8022ed:	09 ca                	or     %ecx,%edx
  8022ef:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8022f3:	89 f1                	mov    %esi,%ecx
  8022f5:	d3 e5                	shl    %cl,%ebp
  8022f7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8022fb:	89 fd                	mov    %edi,%ebp
  8022fd:	88 c1                	mov    %al,%cl
  8022ff:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802301:	89 fa                	mov    %edi,%edx
  802303:	89 f1                	mov    %esi,%ecx
  802305:	d3 e2                	shl    %cl,%edx
  802307:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80230b:	88 c1                	mov    %al,%cl
  80230d:	d3 ef                	shr    %cl,%edi
  80230f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802311:	89 f8                	mov    %edi,%eax
  802313:	89 ea                	mov    %ebp,%edx
  802315:	f7 74 24 08          	divl   0x8(%esp)
  802319:	89 d1                	mov    %edx,%ecx
  80231b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  80231d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802321:	39 d1                	cmp    %edx,%ecx
  802323:	72 17                	jb     80233c <__udivdi3+0x10c>
  802325:	74 09                	je     802330 <__udivdi3+0x100>
  802327:	89 fe                	mov    %edi,%esi
  802329:	31 ff                	xor    %edi,%edi
  80232b:	e9 41 ff ff ff       	jmp    802271 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802330:	8b 54 24 04          	mov    0x4(%esp),%edx
  802334:	89 f1                	mov    %esi,%ecx
  802336:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802338:	39 c2                	cmp    %eax,%edx
  80233a:	73 eb                	jae    802327 <__udivdi3+0xf7>
		{
		  q0--;
  80233c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80233f:	31 ff                	xor    %edi,%edi
  802341:	e9 2b ff ff ff       	jmp    802271 <__udivdi3+0x41>
  802346:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802348:	31 f6                	xor    %esi,%esi
  80234a:	e9 22 ff ff ff       	jmp    802271 <__udivdi3+0x41>
	...

00802350 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802350:	55                   	push   %ebp
  802351:	57                   	push   %edi
  802352:	56                   	push   %esi
  802353:	83 ec 20             	sub    $0x20,%esp
  802356:	8b 44 24 30          	mov    0x30(%esp),%eax
  80235a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80235e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802362:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802366:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80236a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80236e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802370:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802372:	85 ed                	test   %ebp,%ebp
  802374:	75 16                	jne    80238c <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802376:	39 f1                	cmp    %esi,%ecx
  802378:	0f 86 a6 00 00 00    	jbe    802424 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80237e:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802380:	89 d0                	mov    %edx,%eax
  802382:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802384:	83 c4 20             	add    $0x20,%esp
  802387:	5e                   	pop    %esi
  802388:	5f                   	pop    %edi
  802389:	5d                   	pop    %ebp
  80238a:	c3                   	ret    
  80238b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80238c:	39 f5                	cmp    %esi,%ebp
  80238e:	0f 87 ac 00 00 00    	ja     802440 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802394:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802397:	83 f0 1f             	xor    $0x1f,%eax
  80239a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80239e:	0f 84 a8 00 00 00    	je     80244c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8023a4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023a8:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8023aa:	bf 20 00 00 00       	mov    $0x20,%edi
  8023af:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8023b3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023b7:	89 f9                	mov    %edi,%ecx
  8023b9:	d3 e8                	shr    %cl,%eax
  8023bb:	09 e8                	or     %ebp,%eax
  8023bd:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8023c1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8023c5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8023c9:	d3 e0                	shl    %cl,%eax
  8023cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023cf:	89 f2                	mov    %esi,%edx
  8023d1:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8023d3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023d7:	d3 e0                	shl    %cl,%eax
  8023d9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8023dd:	8b 44 24 14          	mov    0x14(%esp),%eax
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	d3 e8                	shr    %cl,%eax
  8023e5:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8023e7:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8023e9:	89 f2                	mov    %esi,%edx
  8023eb:	f7 74 24 18          	divl   0x18(%esp)
  8023ef:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8023f1:	f7 64 24 0c          	mull   0xc(%esp)
  8023f5:	89 c5                	mov    %eax,%ebp
  8023f7:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8023f9:	39 d6                	cmp    %edx,%esi
  8023fb:	72 67                	jb     802464 <__umoddi3+0x114>
  8023fd:	74 75                	je     802474 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8023ff:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802403:	29 e8                	sub    %ebp,%eax
  802405:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802407:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80240b:	d3 e8                	shr    %cl,%eax
  80240d:	89 f2                	mov    %esi,%edx
  80240f:	89 f9                	mov    %edi,%ecx
  802411:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802413:	09 d0                	or     %edx,%eax
  802415:	89 f2                	mov    %esi,%edx
  802417:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80241b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80241d:	83 c4 20             	add    $0x20,%esp
  802420:	5e                   	pop    %esi
  802421:	5f                   	pop    %edi
  802422:	5d                   	pop    %ebp
  802423:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802424:	85 c9                	test   %ecx,%ecx
  802426:	75 0b                	jne    802433 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802428:	b8 01 00 00 00       	mov    $0x1,%eax
  80242d:	31 d2                	xor    %edx,%edx
  80242f:	f7 f1                	div    %ecx
  802431:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802433:	89 f0                	mov    %esi,%eax
  802435:	31 d2                	xor    %edx,%edx
  802437:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802439:	89 f8                	mov    %edi,%eax
  80243b:	e9 3e ff ff ff       	jmp    80237e <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802440:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802442:	83 c4 20             	add    $0x20,%esp
  802445:	5e                   	pop    %esi
  802446:	5f                   	pop    %edi
  802447:	5d                   	pop    %ebp
  802448:	c3                   	ret    
  802449:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80244c:	39 f5                	cmp    %esi,%ebp
  80244e:	72 04                	jb     802454 <__umoddi3+0x104>
  802450:	39 f9                	cmp    %edi,%ecx
  802452:	77 06                	ja     80245a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802454:	89 f2                	mov    %esi,%edx
  802456:	29 cf                	sub    %ecx,%edi
  802458:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  80245a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80245c:	83 c4 20             	add    $0x20,%esp
  80245f:	5e                   	pop    %esi
  802460:	5f                   	pop    %edi
  802461:	5d                   	pop    %ebp
  802462:	c3                   	ret    
  802463:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802464:	89 d1                	mov    %edx,%ecx
  802466:	89 c5                	mov    %eax,%ebp
  802468:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80246c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802470:	eb 8d                	jmp    8023ff <__umoddi3+0xaf>
  802472:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802474:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802478:	72 ea                	jb     802464 <__umoddi3+0x114>
  80247a:	89 f1                	mov    %esi,%ecx
  80247c:	eb 81                	jmp    8023ff <__umoddi3+0xaf>
