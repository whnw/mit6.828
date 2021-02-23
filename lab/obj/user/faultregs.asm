
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 37 05 00 00       	call   800568 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 1c             	sub    $0x1c,%esp
  80003d:	89 c3                	mov    %eax,%ebx
  80003f:	89 ce                	mov    %ecx,%esi
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800041:	8b 45 08             	mov    0x8(%ebp),%eax
  800044:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800048:	89 54 24 08          	mov    %edx,0x8(%esp)
  80004c:	c7 44 24 04 51 2a 80 	movl   $0x802a51,0x4(%esp)
  800053:	00 
  800054:	c7 04 24 20 2a 80 00 	movl   $0x802a20,(%esp)
  80005b:	e8 70 06 00 00       	call   8006d0 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800060:	8b 06                	mov    (%esi),%eax
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	8b 03                	mov    (%ebx),%eax
  800068:	89 44 24 08          	mov    %eax,0x8(%esp)
  80006c:	c7 44 24 04 30 2a 80 	movl   $0x802a30,0x4(%esp)
  800073:	00 
  800074:	c7 04 24 34 2a 80 00 	movl   $0x802a34,(%esp)
  80007b:	e8 50 06 00 00       	call   8006d0 <cprintf>
  800080:	8b 06                	mov    (%esi),%eax
  800082:	39 03                	cmp    %eax,(%ebx)
  800084:	75 13                	jne    800099 <check_regs+0x65>
  800086:	c7 04 24 44 2a 80 00 	movl   $0x802a44,(%esp)
  80008d:	e8 3e 06 00 00       	call   8006d0 <cprintf>

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  800092:	bf 00 00 00 00       	mov    $0x0,%edi
  800097:	eb 11                	jmp    8000aa <check_regs+0x76>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800099:	c7 04 24 48 2a 80 00 	movl   $0x802a48,(%esp)
  8000a0:	e8 2b 06 00 00       	call   8006d0 <cprintf>
  8000a5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000aa:	8b 46 04             	mov    0x4(%esi),%eax
  8000ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b1:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b8:	c7 44 24 04 52 2a 80 	movl   $0x802a52,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 34 2a 80 00 	movl   $0x802a34,(%esp)
  8000c7:	e8 04 06 00 00       	call   8006d0 <cprintf>
  8000cc:	8b 46 04             	mov    0x4(%esi),%eax
  8000cf:	39 43 04             	cmp    %eax,0x4(%ebx)
  8000d2:	75 0e                	jne    8000e2 <check_regs+0xae>
  8000d4:	c7 04 24 44 2a 80 00 	movl   $0x802a44,(%esp)
  8000db:	e8 f0 05 00 00       	call   8006d0 <cprintf>
  8000e0:	eb 11                	jmp    8000f3 <check_regs+0xbf>
  8000e2:	c7 04 24 48 2a 80 00 	movl   $0x802a48,(%esp)
  8000e9:	e8 e2 05 00 00       	call   8006d0 <cprintf>
  8000ee:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000f3:	8b 46 08             	mov    0x8(%esi),%eax
  8000f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800101:	c7 44 24 04 56 2a 80 	movl   $0x802a56,0x4(%esp)
  800108:	00 
  800109:	c7 04 24 34 2a 80 00 	movl   $0x802a34,(%esp)
  800110:	e8 bb 05 00 00       	call   8006d0 <cprintf>
  800115:	8b 46 08             	mov    0x8(%esi),%eax
  800118:	39 43 08             	cmp    %eax,0x8(%ebx)
  80011b:	75 0e                	jne    80012b <check_regs+0xf7>
  80011d:	c7 04 24 44 2a 80 00 	movl   $0x802a44,(%esp)
  800124:	e8 a7 05 00 00       	call   8006d0 <cprintf>
  800129:	eb 11                	jmp    80013c <check_regs+0x108>
  80012b:	c7 04 24 48 2a 80 00 	movl   $0x802a48,(%esp)
  800132:	e8 99 05 00 00       	call   8006d0 <cprintf>
  800137:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  80013c:	8b 46 10             	mov    0x10(%esi),%eax
  80013f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800143:	8b 43 10             	mov    0x10(%ebx),%eax
  800146:	89 44 24 08          	mov    %eax,0x8(%esp)
  80014a:	c7 44 24 04 5a 2a 80 	movl   $0x802a5a,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 34 2a 80 00 	movl   $0x802a34,(%esp)
  800159:	e8 72 05 00 00       	call   8006d0 <cprintf>
  80015e:	8b 46 10             	mov    0x10(%esi),%eax
  800161:	39 43 10             	cmp    %eax,0x10(%ebx)
  800164:	75 0e                	jne    800174 <check_regs+0x140>
  800166:	c7 04 24 44 2a 80 00 	movl   $0x802a44,(%esp)
  80016d:	e8 5e 05 00 00       	call   8006d0 <cprintf>
  800172:	eb 11                	jmp    800185 <check_regs+0x151>
  800174:	c7 04 24 48 2a 80 00 	movl   $0x802a48,(%esp)
  80017b:	e8 50 05 00 00       	call   8006d0 <cprintf>
  800180:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800185:	8b 46 14             	mov    0x14(%esi),%eax
  800188:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018c:	8b 43 14             	mov    0x14(%ebx),%eax
  80018f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800193:	c7 44 24 04 5e 2a 80 	movl   $0x802a5e,0x4(%esp)
  80019a:	00 
  80019b:	c7 04 24 34 2a 80 00 	movl   $0x802a34,(%esp)
  8001a2:	e8 29 05 00 00       	call   8006d0 <cprintf>
  8001a7:	8b 46 14             	mov    0x14(%esi),%eax
  8001aa:	39 43 14             	cmp    %eax,0x14(%ebx)
  8001ad:	75 0e                	jne    8001bd <check_regs+0x189>
  8001af:	c7 04 24 44 2a 80 00 	movl   $0x802a44,(%esp)
  8001b6:	e8 15 05 00 00       	call   8006d0 <cprintf>
  8001bb:	eb 11                	jmp    8001ce <check_regs+0x19a>
  8001bd:	c7 04 24 48 2a 80 00 	movl   $0x802a48,(%esp)
  8001c4:	e8 07 05 00 00       	call   8006d0 <cprintf>
  8001c9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001ce:	8b 46 18             	mov    0x18(%esi),%eax
  8001d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001d5:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001dc:	c7 44 24 04 62 2a 80 	movl   $0x802a62,0x4(%esp)
  8001e3:	00 
  8001e4:	c7 04 24 34 2a 80 00 	movl   $0x802a34,(%esp)
  8001eb:	e8 e0 04 00 00       	call   8006d0 <cprintf>
  8001f0:	8b 46 18             	mov    0x18(%esi),%eax
  8001f3:	39 43 18             	cmp    %eax,0x18(%ebx)
  8001f6:	75 0e                	jne    800206 <check_regs+0x1d2>
  8001f8:	c7 04 24 44 2a 80 00 	movl   $0x802a44,(%esp)
  8001ff:	e8 cc 04 00 00       	call   8006d0 <cprintf>
  800204:	eb 11                	jmp    800217 <check_regs+0x1e3>
  800206:	c7 04 24 48 2a 80 00 	movl   $0x802a48,(%esp)
  80020d:	e8 be 04 00 00       	call   8006d0 <cprintf>
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800217:	8b 46 1c             	mov    0x1c(%esi),%eax
  80021a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021e:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800221:	89 44 24 08          	mov    %eax,0x8(%esp)
  800225:	c7 44 24 04 66 2a 80 	movl   $0x802a66,0x4(%esp)
  80022c:	00 
  80022d:	c7 04 24 34 2a 80 00 	movl   $0x802a34,(%esp)
  800234:	e8 97 04 00 00       	call   8006d0 <cprintf>
  800239:	8b 46 1c             	mov    0x1c(%esi),%eax
  80023c:	39 43 1c             	cmp    %eax,0x1c(%ebx)
  80023f:	75 0e                	jne    80024f <check_regs+0x21b>
  800241:	c7 04 24 44 2a 80 00 	movl   $0x802a44,(%esp)
  800248:	e8 83 04 00 00       	call   8006d0 <cprintf>
  80024d:	eb 11                	jmp    800260 <check_regs+0x22c>
  80024f:	c7 04 24 48 2a 80 00 	movl   $0x802a48,(%esp)
  800256:	e8 75 04 00 00       	call   8006d0 <cprintf>
  80025b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800260:	8b 46 20             	mov    0x20(%esi),%eax
  800263:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800267:	8b 43 20             	mov    0x20(%ebx),%eax
  80026a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80026e:	c7 44 24 04 6a 2a 80 	movl   $0x802a6a,0x4(%esp)
  800275:	00 
  800276:	c7 04 24 34 2a 80 00 	movl   $0x802a34,(%esp)
  80027d:	e8 4e 04 00 00       	call   8006d0 <cprintf>
  800282:	8b 46 20             	mov    0x20(%esi),%eax
  800285:	39 43 20             	cmp    %eax,0x20(%ebx)
  800288:	75 0e                	jne    800298 <check_regs+0x264>
  80028a:	c7 04 24 44 2a 80 00 	movl   $0x802a44,(%esp)
  800291:	e8 3a 04 00 00       	call   8006d0 <cprintf>
  800296:	eb 11                	jmp    8002a9 <check_regs+0x275>
  800298:	c7 04 24 48 2a 80 00 	movl   $0x802a48,(%esp)
  80029f:	e8 2c 04 00 00       	call   8006d0 <cprintf>
  8002a4:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002a9:	8b 46 24             	mov    0x24(%esi),%eax
  8002ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b0:	8b 43 24             	mov    0x24(%ebx),%eax
  8002b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b7:	c7 44 24 04 6e 2a 80 	movl   $0x802a6e,0x4(%esp)
  8002be:	00 
  8002bf:	c7 04 24 34 2a 80 00 	movl   $0x802a34,(%esp)
  8002c6:	e8 05 04 00 00       	call   8006d0 <cprintf>
  8002cb:	8b 46 24             	mov    0x24(%esi),%eax
  8002ce:	39 43 24             	cmp    %eax,0x24(%ebx)
  8002d1:	75 0e                	jne    8002e1 <check_regs+0x2ad>
  8002d3:	c7 04 24 44 2a 80 00 	movl   $0x802a44,(%esp)
  8002da:	e8 f1 03 00 00       	call   8006d0 <cprintf>
  8002df:	eb 11                	jmp    8002f2 <check_regs+0x2be>
  8002e1:	c7 04 24 48 2a 80 00 	movl   $0x802a48,(%esp)
  8002e8:	e8 e3 03 00 00       	call   8006d0 <cprintf>
  8002ed:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002f2:	8b 46 28             	mov    0x28(%esi),%eax
  8002f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f9:	8b 43 28             	mov    0x28(%ebx),%eax
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 75 2a 80 	movl   $0x802a75,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 34 2a 80 00 	movl   $0x802a34,(%esp)
  80030f:	e8 bc 03 00 00       	call   8006d0 <cprintf>
  800314:	8b 46 28             	mov    0x28(%esi),%eax
  800317:	39 43 28             	cmp    %eax,0x28(%ebx)
  80031a:	75 25                	jne    800341 <check_regs+0x30d>
  80031c:	c7 04 24 44 2a 80 00 	movl   $0x802a44,(%esp)
  800323:	e8 a8 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032f:	c7 04 24 79 2a 80 00 	movl   $0x802a79,(%esp)
  800336:	e8 95 03 00 00       	call   8006d0 <cprintf>
	if (!mismatch)
  80033b:	85 ff                	test   %edi,%edi
  80033d:	74 23                	je     800362 <check_regs+0x32e>
  80033f:	eb 2f                	jmp    800370 <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800341:	c7 04 24 48 2a 80 00 	movl   $0x802a48,(%esp)
  800348:	e8 83 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800350:	89 44 24 04          	mov    %eax,0x4(%esp)
  800354:	c7 04 24 79 2a 80 00 	movl   $0x802a79,(%esp)
  80035b:	e8 70 03 00 00       	call   8006d0 <cprintf>
  800360:	eb 0e                	jmp    800370 <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  800362:	c7 04 24 44 2a 80 00 	movl   $0x802a44,(%esp)
  800369:	e8 62 03 00 00       	call   8006d0 <cprintf>
  80036e:	eb 0c                	jmp    80037c <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  800370:	c7 04 24 48 2a 80 00 	movl   $0x802a48,(%esp)
  800377:	e8 54 03 00 00       	call   8006d0 <cprintf>
}
  80037c:	83 c4 1c             	add    $0x1c,%esp
  80037f:	5b                   	pop    %ebx
  800380:	5e                   	pop    %esi
  800381:	5f                   	pop    %edi
  800382:	5d                   	pop    %ebp
  800383:	c3                   	ret    

00800384 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	57                   	push   %edi
  800388:	56                   	push   %esi
  800389:	83 ec 20             	sub    $0x20,%esp
  80038c:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  80038f:	8b 10                	mov    (%eax),%edx
  800391:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  800397:	74 27                	je     8003c0 <pgfault+0x3c>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  800399:	8b 40 28             	mov    0x28(%eax),%eax
  80039c:	89 44 24 10          	mov    %eax,0x10(%esp)
  8003a0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a4:	c7 44 24 08 e0 2a 80 	movl   $0x802ae0,0x8(%esp)
  8003ab:	00 
  8003ac:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8003b3:	00 
  8003b4:	c7 04 24 87 2a 80 00 	movl   $0x802a87,(%esp)
  8003bb:	e8 18 02 00 00       	call   8005d8 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003c0:	bf 80 40 80 00       	mov    $0x804080,%edi
  8003c5:	8d 70 08             	lea    0x8(%eax),%esi
  8003c8:	b9 08 00 00 00       	mov    $0x8,%ecx
  8003cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	during.eip = utf->utf_eip;
  8003cf:	8b 50 28             	mov    0x28(%eax),%edx
  8003d2:	89 17                	mov    %edx,(%edi)
	during.eflags = utf->utf_eflags & ~FL_RF;
  8003d4:	8b 50 2c             	mov    0x2c(%eax),%edx
  8003d7:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  8003dd:	89 15 a4 40 80 00    	mov    %edx,0x8040a4
	during.esp = utf->utf_esp;
  8003e3:	8b 40 30             	mov    0x30(%eax),%eax
  8003e6:	a3 a8 40 80 00       	mov    %eax,0x8040a8
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  8003eb:	c7 44 24 04 9f 2a 80 	movl   $0x802a9f,0x4(%esp)
  8003f2:	00 
  8003f3:	c7 04 24 ad 2a 80 00 	movl   $0x802aad,(%esp)
  8003fa:	b9 80 40 80 00       	mov    $0x804080,%ecx
  8003ff:	ba 98 2a 80 00       	mov    $0x802a98,%edx
  800404:	b8 00 40 80 00       	mov    $0x804000,%eax
  800409:	e8 26 fc ff ff       	call   800034 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80040e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800415:	00 
  800416:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80041d:	00 
  80041e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800425:	e8 43 0c 00 00       	call   80106d <sys_page_alloc>
  80042a:	85 c0                	test   %eax,%eax
  80042c:	79 20                	jns    80044e <pgfault+0xca>
		panic("sys_page_alloc: %e", r);
  80042e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800432:	c7 44 24 08 b4 2a 80 	movl   $0x802ab4,0x8(%esp)
  800439:	00 
  80043a:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800441:	00 
  800442:	c7 04 24 87 2a 80 00 	movl   $0x802a87,(%esp)
  800449:	e8 8a 01 00 00       	call   8005d8 <_panic>
}
  80044e:	83 c4 20             	add    $0x20,%esp
  800451:	5e                   	pop    %esi
  800452:	5f                   	pop    %edi
  800453:	5d                   	pop    %ebp
  800454:	c3                   	ret    

00800455 <umain>:

void
umain(int argc, char **argv)
{
  800455:	55                   	push   %ebp
  800456:	89 e5                	mov    %esp,%ebp
  800458:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  80045b:	c7 04 24 84 03 80 00 	movl   $0x800384,(%esp)
  800462:	e8 d1 0e 00 00       	call   801338 <set_pgfault_handler>

	asm volatile(
  800467:	50                   	push   %eax
  800468:	9c                   	pushf  
  800469:	58                   	pop    %eax
  80046a:	0d d5 08 00 00       	or     $0x8d5,%eax
  80046f:	50                   	push   %eax
  800470:	9d                   	popf   
  800471:	a3 24 40 80 00       	mov    %eax,0x804024
  800476:	8d 05 b1 04 80 00    	lea    0x8004b1,%eax
  80047c:	a3 20 40 80 00       	mov    %eax,0x804020
  800481:	58                   	pop    %eax
  800482:	89 3d 00 40 80 00    	mov    %edi,0x804000
  800488:	89 35 04 40 80 00    	mov    %esi,0x804004
  80048e:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  800494:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  80049a:	89 15 14 40 80 00    	mov    %edx,0x804014
  8004a0:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  8004a6:	a3 1c 40 80 00       	mov    %eax,0x80401c
  8004ab:	89 25 28 40 80 00    	mov    %esp,0x804028
  8004b1:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004b8:	00 00 00 
  8004bb:	89 3d 40 40 80 00    	mov    %edi,0x804040
  8004c1:	89 35 44 40 80 00    	mov    %esi,0x804044
  8004c7:	89 2d 48 40 80 00    	mov    %ebp,0x804048
  8004cd:	89 1d 50 40 80 00    	mov    %ebx,0x804050
  8004d3:	89 15 54 40 80 00    	mov    %edx,0x804054
  8004d9:	89 0d 58 40 80 00    	mov    %ecx,0x804058
  8004df:	a3 5c 40 80 00       	mov    %eax,0x80405c
  8004e4:	89 25 68 40 80 00    	mov    %esp,0x804068
  8004ea:	8b 3d 00 40 80 00    	mov    0x804000,%edi
  8004f0:	8b 35 04 40 80 00    	mov    0x804004,%esi
  8004f6:	8b 2d 08 40 80 00    	mov    0x804008,%ebp
  8004fc:	8b 1d 10 40 80 00    	mov    0x804010,%ebx
  800502:	8b 15 14 40 80 00    	mov    0x804014,%edx
  800508:	8b 0d 18 40 80 00    	mov    0x804018,%ecx
  80050e:	a1 1c 40 80 00       	mov    0x80401c,%eax
  800513:	8b 25 28 40 80 00    	mov    0x804028,%esp
  800519:	50                   	push   %eax
  80051a:	9c                   	pushf  
  80051b:	58                   	pop    %eax
  80051c:	a3 64 40 80 00       	mov    %eax,0x804064
  800521:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800522:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800529:	74 0c                	je     800537 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  80052b:	c7 04 24 14 2b 80 00 	movl   $0x802b14,(%esp)
  800532:	e8 99 01 00 00       	call   8006d0 <cprintf>
	after.eip = before.eip;
  800537:	a1 20 40 80 00       	mov    0x804020,%eax
  80053c:	a3 60 40 80 00       	mov    %eax,0x804060

	check_regs(&before, "before", &after, "after", "after page-fault");
  800541:	c7 44 24 04 c7 2a 80 	movl   $0x802ac7,0x4(%esp)
  800548:	00 
  800549:	c7 04 24 d8 2a 80 00 	movl   $0x802ad8,(%esp)
  800550:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800555:	ba 98 2a 80 00       	mov    $0x802a98,%edx
  80055a:	b8 00 40 80 00       	mov    $0x804000,%eax
  80055f:	e8 d0 fa ff ff       	call   800034 <check_regs>
}
  800564:	c9                   	leave  
  800565:	c3                   	ret    
	...

00800568 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800568:	55                   	push   %ebp
  800569:	89 e5                	mov    %esp,%ebp
  80056b:	56                   	push   %esi
  80056c:	53                   	push   %ebx
  80056d:	83 ec 10             	sub    $0x10,%esp
  800570:	8b 75 08             	mov    0x8(%ebp),%esi
  800573:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800576:	e8 b4 0a 00 00       	call   80102f <sys_getenvid>
  80057b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800580:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800587:	c1 e0 07             	shl    $0x7,%eax
  80058a:	29 d0                	sub    %edx,%eax
  80058c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800591:	a3 b4 40 80 00       	mov    %eax,0x8040b4


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800596:	85 f6                	test   %esi,%esi
  800598:	7e 07                	jle    8005a1 <libmain+0x39>
		binaryname = argv[0];
  80059a:	8b 03                	mov    (%ebx),%eax
  80059c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a5:	89 34 24             	mov    %esi,(%esp)
  8005a8:	e8 a8 fe ff ff       	call   800455 <umain>

	// exit gracefully
	exit();
  8005ad:	e8 0a 00 00 00       	call   8005bc <exit>
}
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	5b                   	pop    %ebx
  8005b6:	5e                   	pop    %esi
  8005b7:	5d                   	pop    %ebp
  8005b8:	c3                   	ret    
  8005b9:	00 00                	add    %al,(%eax)
	...

008005bc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005bc:	55                   	push   %ebp
  8005bd:	89 e5                	mov    %esp,%ebp
  8005bf:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8005c2:	e8 cc 0f 00 00       	call   801593 <close_all>
	sys_env_destroy(0);
  8005c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005ce:	e8 0a 0a 00 00       	call   800fdd <sys_env_destroy>
}
  8005d3:	c9                   	leave  
  8005d4:	c3                   	ret    
  8005d5:	00 00                	add    %al,(%eax)
	...

008005d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005d8:	55                   	push   %ebp
  8005d9:	89 e5                	mov    %esp,%ebp
  8005db:	56                   	push   %esi
  8005dc:	53                   	push   %ebx
  8005dd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8005e0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005e3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8005e9:	e8 41 0a 00 00       	call   80102f <sys_getenvid>
  8005ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8005f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8005f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800600:	89 44 24 04          	mov    %eax,0x4(%esp)
  800604:	c7 04 24 40 2b 80 00 	movl   $0x802b40,(%esp)
  80060b:	e8 c0 00 00 00       	call   8006d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800610:	89 74 24 04          	mov    %esi,0x4(%esp)
  800614:	8b 45 10             	mov    0x10(%ebp),%eax
  800617:	89 04 24             	mov    %eax,(%esp)
  80061a:	e8 50 00 00 00       	call   80066f <vcprintf>
	cprintf("\n");
  80061f:	c7 04 24 50 2a 80 00 	movl   $0x802a50,(%esp)
  800626:	e8 a5 00 00 00       	call   8006d0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80062b:	cc                   	int3   
  80062c:	eb fd                	jmp    80062b <_panic+0x53>
	...

00800630 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	53                   	push   %ebx
  800634:	83 ec 14             	sub    $0x14,%esp
  800637:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80063a:	8b 03                	mov    (%ebx),%eax
  80063c:	8b 55 08             	mov    0x8(%ebp),%edx
  80063f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800643:	40                   	inc    %eax
  800644:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800646:	3d ff 00 00 00       	cmp    $0xff,%eax
  80064b:	75 19                	jne    800666 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80064d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800654:	00 
  800655:	8d 43 08             	lea    0x8(%ebx),%eax
  800658:	89 04 24             	mov    %eax,(%esp)
  80065b:	e8 40 09 00 00       	call   800fa0 <sys_cputs>
		b->idx = 0;
  800660:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800666:	ff 43 04             	incl   0x4(%ebx)
}
  800669:	83 c4 14             	add    $0x14,%esp
  80066c:	5b                   	pop    %ebx
  80066d:	5d                   	pop    %ebp
  80066e:	c3                   	ret    

0080066f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
  800672:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800678:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80067f:	00 00 00 
	b.cnt = 0;
  800682:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800689:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80068c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80068f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800693:	8b 45 08             	mov    0x8(%ebp),%eax
  800696:	89 44 24 08          	mov    %eax,0x8(%esp)
  80069a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a4:	c7 04 24 30 06 80 00 	movl   $0x800630,(%esp)
  8006ab:	e8 82 01 00 00       	call   800832 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006b0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ba:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c0:	89 04 24             	mov    %eax,(%esp)
  8006c3:	e8 d8 08 00 00       	call   800fa0 <sys_cputs>

	return b.cnt;
}
  8006c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e0:	89 04 24             	mov    %eax,(%esp)
  8006e3:	e8 87 ff ff ff       	call   80066f <vcprintf>
	va_end(ap);

	return cnt;
}
  8006e8:	c9                   	leave  
  8006e9:	c3                   	ret    
	...

008006ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	57                   	push   %edi
  8006f0:	56                   	push   %esi
  8006f1:	53                   	push   %ebx
  8006f2:	83 ec 3c             	sub    $0x3c,%esp
  8006f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006f8:	89 d7                	mov    %edx,%edi
  8006fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800700:	8b 45 0c             	mov    0xc(%ebp),%eax
  800703:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800706:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800709:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80070c:	85 c0                	test   %eax,%eax
  80070e:	75 08                	jne    800718 <printnum+0x2c>
  800710:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800713:	39 45 10             	cmp    %eax,0x10(%ebp)
  800716:	77 57                	ja     80076f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800718:	89 74 24 10          	mov    %esi,0x10(%esp)
  80071c:	4b                   	dec    %ebx
  80071d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800721:	8b 45 10             	mov    0x10(%ebp),%eax
  800724:	89 44 24 08          	mov    %eax,0x8(%esp)
  800728:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80072c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800730:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800737:	00 
  800738:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80073b:	89 04 24             	mov    %eax,(%esp)
  80073e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800741:	89 44 24 04          	mov    %eax,0x4(%esp)
  800745:	e8 82 20 00 00       	call   8027cc <__udivdi3>
  80074a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80074e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800752:	89 04 24             	mov    %eax,(%esp)
  800755:	89 54 24 04          	mov    %edx,0x4(%esp)
  800759:	89 fa                	mov    %edi,%edx
  80075b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80075e:	e8 89 ff ff ff       	call   8006ec <printnum>
  800763:	eb 0f                	jmp    800774 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800765:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800769:	89 34 24             	mov    %esi,(%esp)
  80076c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80076f:	4b                   	dec    %ebx
  800770:	85 db                	test   %ebx,%ebx
  800772:	7f f1                	jg     800765 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800774:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800778:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80077c:	8b 45 10             	mov    0x10(%ebp),%eax
  80077f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800783:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80078a:	00 
  80078b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80078e:	89 04 24             	mov    %eax,(%esp)
  800791:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800794:	89 44 24 04          	mov    %eax,0x4(%esp)
  800798:	e8 4f 21 00 00       	call   8028ec <__umoddi3>
  80079d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007a1:	0f be 80 63 2b 80 00 	movsbl 0x802b63(%eax),%eax
  8007a8:	89 04 24             	mov    %eax,(%esp)
  8007ab:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8007ae:	83 c4 3c             	add    $0x3c,%esp
  8007b1:	5b                   	pop    %ebx
  8007b2:	5e                   	pop    %esi
  8007b3:	5f                   	pop    %edi
  8007b4:	5d                   	pop    %ebp
  8007b5:	c3                   	ret    

008007b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8007b9:	83 fa 01             	cmp    $0x1,%edx
  8007bc:	7e 0e                	jle    8007cc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8007be:	8b 10                	mov    (%eax),%edx
  8007c0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8007c3:	89 08                	mov    %ecx,(%eax)
  8007c5:	8b 02                	mov    (%edx),%eax
  8007c7:	8b 52 04             	mov    0x4(%edx),%edx
  8007ca:	eb 22                	jmp    8007ee <getuint+0x38>
	else if (lflag)
  8007cc:	85 d2                	test   %edx,%edx
  8007ce:	74 10                	je     8007e0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007d0:	8b 10                	mov    (%eax),%edx
  8007d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007d5:	89 08                	mov    %ecx,(%eax)
  8007d7:	8b 02                	mov    (%edx),%eax
  8007d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007de:	eb 0e                	jmp    8007ee <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007e0:	8b 10                	mov    (%eax),%edx
  8007e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007e5:	89 08                	mov    %ecx,(%eax)
  8007e7:	8b 02                	mov    (%edx),%eax
  8007e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    

008007f0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007f6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8007f9:	8b 10                	mov    (%eax),%edx
  8007fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8007fe:	73 08                	jae    800808 <sprintputch+0x18>
		*b->buf++ = ch;
  800800:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800803:	88 0a                	mov    %cl,(%edx)
  800805:	42                   	inc    %edx
  800806:	89 10                	mov    %edx,(%eax)
}
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800810:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800813:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800817:	8b 45 10             	mov    0x10(%ebp),%eax
  80081a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800821:	89 44 24 04          	mov    %eax,0x4(%esp)
  800825:	8b 45 08             	mov    0x8(%ebp),%eax
  800828:	89 04 24             	mov    %eax,(%esp)
  80082b:	e8 02 00 00 00       	call   800832 <vprintfmt>
	va_end(ap);
}
  800830:	c9                   	leave  
  800831:	c3                   	ret    

00800832 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	57                   	push   %edi
  800836:	56                   	push   %esi
  800837:	53                   	push   %ebx
  800838:	83 ec 4c             	sub    $0x4c,%esp
  80083b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80083e:	8b 75 10             	mov    0x10(%ebp),%esi
  800841:	eb 12                	jmp    800855 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800843:	85 c0                	test   %eax,%eax
  800845:	0f 84 6b 03 00 00    	je     800bb6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80084b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80084f:	89 04 24             	mov    %eax,(%esp)
  800852:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800855:	0f b6 06             	movzbl (%esi),%eax
  800858:	46                   	inc    %esi
  800859:	83 f8 25             	cmp    $0x25,%eax
  80085c:	75 e5                	jne    800843 <vprintfmt+0x11>
  80085e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800862:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800869:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80086e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800875:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087a:	eb 26                	jmp    8008a2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80087f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800883:	eb 1d                	jmp    8008a2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800885:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800888:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80088c:	eb 14                	jmp    8008a2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800891:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800898:	eb 08                	jmp    8008a2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80089a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80089d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a2:	0f b6 06             	movzbl (%esi),%eax
  8008a5:	8d 56 01             	lea    0x1(%esi),%edx
  8008a8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8008ab:	8a 16                	mov    (%esi),%dl
  8008ad:	83 ea 23             	sub    $0x23,%edx
  8008b0:	80 fa 55             	cmp    $0x55,%dl
  8008b3:	0f 87 e1 02 00 00    	ja     800b9a <vprintfmt+0x368>
  8008b9:	0f b6 d2             	movzbl %dl,%edx
  8008bc:	ff 24 95 a0 2c 80 00 	jmp    *0x802ca0(,%edx,4)
  8008c3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008c6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008cb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8008ce:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8008d2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8008d5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8008d8:	83 fa 09             	cmp    $0x9,%edx
  8008db:	77 2a                	ja     800907 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008dd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8008de:	eb eb                	jmp    8008cb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e3:	8d 50 04             	lea    0x4(%eax),%edx
  8008e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008ee:	eb 17                	jmp    800907 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8008f0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008f4:	78 98                	js     80088e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008f9:	eb a7                	jmp    8008a2 <vprintfmt+0x70>
  8008fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008fe:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800905:	eb 9b                	jmp    8008a2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800907:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80090b:	79 95                	jns    8008a2 <vprintfmt+0x70>
  80090d:	eb 8b                	jmp    80089a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80090f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800910:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800913:	eb 8d                	jmp    8008a2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800915:	8b 45 14             	mov    0x14(%ebp),%eax
  800918:	8d 50 04             	lea    0x4(%eax),%edx
  80091b:	89 55 14             	mov    %edx,0x14(%ebp)
  80091e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800922:	8b 00                	mov    (%eax),%eax
  800924:	89 04 24             	mov    %eax,(%esp)
  800927:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80092a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80092d:	e9 23 ff ff ff       	jmp    800855 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800932:	8b 45 14             	mov    0x14(%ebp),%eax
  800935:	8d 50 04             	lea    0x4(%eax),%edx
  800938:	89 55 14             	mov    %edx,0x14(%ebp)
  80093b:	8b 00                	mov    (%eax),%eax
  80093d:	85 c0                	test   %eax,%eax
  80093f:	79 02                	jns    800943 <vprintfmt+0x111>
  800941:	f7 d8                	neg    %eax
  800943:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800945:	83 f8 10             	cmp    $0x10,%eax
  800948:	7f 0b                	jg     800955 <vprintfmt+0x123>
  80094a:	8b 04 85 00 2e 80 00 	mov    0x802e00(,%eax,4),%eax
  800951:	85 c0                	test   %eax,%eax
  800953:	75 23                	jne    800978 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800955:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800959:	c7 44 24 08 7b 2b 80 	movl   $0x802b7b,0x8(%esp)
  800960:	00 
  800961:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	89 04 24             	mov    %eax,(%esp)
  80096b:	e8 9a fe ff ff       	call   80080a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800970:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800973:	e9 dd fe ff ff       	jmp    800855 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800978:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80097c:	c7 44 24 08 3d 2f 80 	movl   $0x802f3d,0x8(%esp)
  800983:	00 
  800984:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800988:	8b 55 08             	mov    0x8(%ebp),%edx
  80098b:	89 14 24             	mov    %edx,(%esp)
  80098e:	e8 77 fe ff ff       	call   80080a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800993:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800996:	e9 ba fe ff ff       	jmp    800855 <vprintfmt+0x23>
  80099b:	89 f9                	mov    %edi,%ecx
  80099d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a6:	8d 50 04             	lea    0x4(%eax),%edx
  8009a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ac:	8b 30                	mov    (%eax),%esi
  8009ae:	85 f6                	test   %esi,%esi
  8009b0:	75 05                	jne    8009b7 <vprintfmt+0x185>
				p = "(null)";
  8009b2:	be 74 2b 80 00       	mov    $0x802b74,%esi
			if (width > 0 && padc != '-')
  8009b7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009bb:	0f 8e 84 00 00 00    	jle    800a45 <vprintfmt+0x213>
  8009c1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8009c5:	74 7e                	je     800a45 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009cb:	89 34 24             	mov    %esi,(%esp)
  8009ce:	e8 8b 02 00 00       	call   800c5e <strnlen>
  8009d3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8009d6:	29 c2                	sub    %eax,%edx
  8009d8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8009db:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8009df:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8009e2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8009e5:	89 de                	mov    %ebx,%esi
  8009e7:	89 d3                	mov    %edx,%ebx
  8009e9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009eb:	eb 0b                	jmp    8009f8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8009ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f1:	89 3c 24             	mov    %edi,(%esp)
  8009f4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009f7:	4b                   	dec    %ebx
  8009f8:	85 db                	test   %ebx,%ebx
  8009fa:	7f f1                	jg     8009ed <vprintfmt+0x1bb>
  8009fc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8009ff:	89 f3                	mov    %esi,%ebx
  800a01:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800a04:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a07:	85 c0                	test   %eax,%eax
  800a09:	79 05                	jns    800a10 <vprintfmt+0x1de>
  800a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a10:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a13:	29 c2                	sub    %eax,%edx
  800a15:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a18:	eb 2b                	jmp    800a45 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a1a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a1e:	74 18                	je     800a38 <vprintfmt+0x206>
  800a20:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a23:	83 fa 5e             	cmp    $0x5e,%edx
  800a26:	76 10                	jbe    800a38 <vprintfmt+0x206>
					putch('?', putdat);
  800a28:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800a33:	ff 55 08             	call   *0x8(%ebp)
  800a36:	eb 0a                	jmp    800a42 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800a38:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a3c:	89 04 24             	mov    %eax,(%esp)
  800a3f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a42:	ff 4d e4             	decl   -0x1c(%ebp)
  800a45:	0f be 06             	movsbl (%esi),%eax
  800a48:	46                   	inc    %esi
  800a49:	85 c0                	test   %eax,%eax
  800a4b:	74 21                	je     800a6e <vprintfmt+0x23c>
  800a4d:	85 ff                	test   %edi,%edi
  800a4f:	78 c9                	js     800a1a <vprintfmt+0x1e8>
  800a51:	4f                   	dec    %edi
  800a52:	79 c6                	jns    800a1a <vprintfmt+0x1e8>
  800a54:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a57:	89 de                	mov    %ebx,%esi
  800a59:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a5c:	eb 18                	jmp    800a76 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a5e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a62:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800a69:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a6b:	4b                   	dec    %ebx
  800a6c:	eb 08                	jmp    800a76 <vprintfmt+0x244>
  800a6e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a71:	89 de                	mov    %ebx,%esi
  800a73:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800a76:	85 db                	test   %ebx,%ebx
  800a78:	7f e4                	jg     800a5e <vprintfmt+0x22c>
  800a7a:	89 7d 08             	mov    %edi,0x8(%ebp)
  800a7d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800a82:	e9 ce fd ff ff       	jmp    800855 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a87:	83 f9 01             	cmp    $0x1,%ecx
  800a8a:	7e 10                	jle    800a9c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800a8c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8f:	8d 50 08             	lea    0x8(%eax),%edx
  800a92:	89 55 14             	mov    %edx,0x14(%ebp)
  800a95:	8b 30                	mov    (%eax),%esi
  800a97:	8b 78 04             	mov    0x4(%eax),%edi
  800a9a:	eb 26                	jmp    800ac2 <vprintfmt+0x290>
	else if (lflag)
  800a9c:	85 c9                	test   %ecx,%ecx
  800a9e:	74 12                	je     800ab2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800aa0:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa3:	8d 50 04             	lea    0x4(%eax),%edx
  800aa6:	89 55 14             	mov    %edx,0x14(%ebp)
  800aa9:	8b 30                	mov    (%eax),%esi
  800aab:	89 f7                	mov    %esi,%edi
  800aad:	c1 ff 1f             	sar    $0x1f,%edi
  800ab0:	eb 10                	jmp    800ac2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800ab2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab5:	8d 50 04             	lea    0x4(%eax),%edx
  800ab8:	89 55 14             	mov    %edx,0x14(%ebp)
  800abb:	8b 30                	mov    (%eax),%esi
  800abd:	89 f7                	mov    %esi,%edi
  800abf:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ac2:	85 ff                	test   %edi,%edi
  800ac4:	78 0a                	js     800ad0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ac6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800acb:	e9 8c 00 00 00       	jmp    800b5c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800ad0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ad4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800adb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ade:	f7 de                	neg    %esi
  800ae0:	83 d7 00             	adc    $0x0,%edi
  800ae3:	f7 df                	neg    %edi
			}
			base = 10;
  800ae5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aea:	eb 70                	jmp    800b5c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800aec:	89 ca                	mov    %ecx,%edx
  800aee:	8d 45 14             	lea    0x14(%ebp),%eax
  800af1:	e8 c0 fc ff ff       	call   8007b6 <getuint>
  800af6:	89 c6                	mov    %eax,%esi
  800af8:	89 d7                	mov    %edx,%edi
			base = 10;
  800afa:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800aff:	eb 5b                	jmp    800b5c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800b01:	89 ca                	mov    %ecx,%edx
  800b03:	8d 45 14             	lea    0x14(%ebp),%eax
  800b06:	e8 ab fc ff ff       	call   8007b6 <getuint>
  800b0b:	89 c6                	mov    %eax,%esi
  800b0d:	89 d7                	mov    %edx,%edi
			base = 8;
  800b0f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800b14:	eb 46                	jmp    800b5c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800b16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b1a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800b21:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800b24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b28:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800b2f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b32:	8b 45 14             	mov    0x14(%ebp),%eax
  800b35:	8d 50 04             	lea    0x4(%eax),%edx
  800b38:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b3b:	8b 30                	mov    (%eax),%esi
  800b3d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b42:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b47:	eb 13                	jmp    800b5c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b49:	89 ca                	mov    %ecx,%edx
  800b4b:	8d 45 14             	lea    0x14(%ebp),%eax
  800b4e:	e8 63 fc ff ff       	call   8007b6 <getuint>
  800b53:	89 c6                	mov    %eax,%esi
  800b55:	89 d7                	mov    %edx,%edi
			base = 16;
  800b57:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b5c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800b60:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b64:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800b67:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b6b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b6f:	89 34 24             	mov    %esi,(%esp)
  800b72:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b76:	89 da                	mov    %ebx,%edx
  800b78:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7b:	e8 6c fb ff ff       	call   8006ec <printnum>
			break;
  800b80:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b83:	e9 cd fc ff ff       	jmp    800855 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b8c:	89 04 24             	mov    %eax,(%esp)
  800b8f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b92:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b95:	e9 bb fc ff ff       	jmp    800855 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b9e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ba5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ba8:	eb 01                	jmp    800bab <vprintfmt+0x379>
  800baa:	4e                   	dec    %esi
  800bab:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800baf:	75 f9                	jne    800baa <vprintfmt+0x378>
  800bb1:	e9 9f fc ff ff       	jmp    800855 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800bb6:	83 c4 4c             	add    $0x4c,%esp
  800bb9:	5b                   	pop    %ebx
  800bba:	5e                   	pop    %esi
  800bbb:	5f                   	pop    %edi
  800bbc:	5d                   	pop    %ebp
  800bbd:	c3                   	ret    

00800bbe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	83 ec 28             	sub    $0x28,%esp
  800bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bcd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bd1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	74 30                	je     800c0f <vsnprintf+0x51>
  800bdf:	85 d2                	test   %edx,%edx
  800be1:	7e 33                	jle    800c16 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800be3:	8b 45 14             	mov    0x14(%ebp),%eax
  800be6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bea:	8b 45 10             	mov    0x10(%ebp),%eax
  800bed:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bf1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf8:	c7 04 24 f0 07 80 00 	movl   $0x8007f0,(%esp)
  800bff:	e8 2e fc ff ff       	call   800832 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c04:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c07:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c0d:	eb 0c                	jmp    800c1b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c14:	eb 05                	jmp    800c1b <vsnprintf+0x5d>
  800c16:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c1b:	c9                   	leave  
  800c1c:	c3                   	ret    

00800c1d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c23:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c38:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3b:	89 04 24             	mov    %eax,(%esp)
  800c3e:	e8 7b ff ff ff       	call   800bbe <vsnprintf>
	va_end(ap);

	return rc;
}
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    
  800c45:	00 00                	add    %al,(%eax)
	...

00800c48 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c53:	eb 01                	jmp    800c56 <strlen+0xe>
		n++;
  800c55:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c56:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c5a:	75 f9                	jne    800c55 <strlen+0xd>
		n++;
	return n;
}
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    

00800c5e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800c64:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c67:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6c:	eb 01                	jmp    800c6f <strnlen+0x11>
		n++;
  800c6e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c6f:	39 d0                	cmp    %edx,%eax
  800c71:	74 06                	je     800c79 <strnlen+0x1b>
  800c73:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800c77:	75 f5                	jne    800c6e <strnlen+0x10>
		n++;
	return n;
}
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	53                   	push   %ebx
  800c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c85:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c8d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c90:	42                   	inc    %edx
  800c91:	84 c9                	test   %cl,%cl
  800c93:	75 f5                	jne    800c8a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c95:	5b                   	pop    %ebx
  800c96:	5d                   	pop    %ebp
  800c97:	c3                   	ret    

00800c98 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	53                   	push   %ebx
  800c9c:	83 ec 08             	sub    $0x8,%esp
  800c9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ca2:	89 1c 24             	mov    %ebx,(%esp)
  800ca5:	e8 9e ff ff ff       	call   800c48 <strlen>
	strcpy(dst + len, src);
  800caa:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cad:	89 54 24 04          	mov    %edx,0x4(%esp)
  800cb1:	01 d8                	add    %ebx,%eax
  800cb3:	89 04 24             	mov    %eax,(%esp)
  800cb6:	e8 c0 ff ff ff       	call   800c7b <strcpy>
	return dst;
}
  800cbb:	89 d8                	mov    %ebx,%eax
  800cbd:	83 c4 08             	add    $0x8,%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	56                   	push   %esi
  800cc7:	53                   	push   %ebx
  800cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cce:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd6:	eb 0c                	jmp    800ce4 <strncpy+0x21>
		*dst++ = *src;
  800cd8:	8a 1a                	mov    (%edx),%bl
  800cda:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cdd:	80 3a 01             	cmpb   $0x1,(%edx)
  800ce0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce3:	41                   	inc    %ecx
  800ce4:	39 f1                	cmp    %esi,%ecx
  800ce6:	75 f0                	jne    800cd8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	56                   	push   %esi
  800cf0:	53                   	push   %ebx
  800cf1:	8b 75 08             	mov    0x8(%ebp),%esi
  800cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800cfa:	85 d2                	test   %edx,%edx
  800cfc:	75 0a                	jne    800d08 <strlcpy+0x1c>
  800cfe:	89 f0                	mov    %esi,%eax
  800d00:	eb 1a                	jmp    800d1c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d02:	88 18                	mov    %bl,(%eax)
  800d04:	40                   	inc    %eax
  800d05:	41                   	inc    %ecx
  800d06:	eb 02                	jmp    800d0a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d08:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800d0a:	4a                   	dec    %edx
  800d0b:	74 0a                	je     800d17 <strlcpy+0x2b>
  800d0d:	8a 19                	mov    (%ecx),%bl
  800d0f:	84 db                	test   %bl,%bl
  800d11:	75 ef                	jne    800d02 <strlcpy+0x16>
  800d13:	89 c2                	mov    %eax,%edx
  800d15:	eb 02                	jmp    800d19 <strlcpy+0x2d>
  800d17:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800d19:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800d1c:	29 f0                	sub    %esi,%eax
}
  800d1e:	5b                   	pop    %ebx
  800d1f:	5e                   	pop    %esi
  800d20:	5d                   	pop    %ebp
  800d21:	c3                   	ret    

00800d22 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d28:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d2b:	eb 02                	jmp    800d2f <strcmp+0xd>
		p++, q++;
  800d2d:	41                   	inc    %ecx
  800d2e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d2f:	8a 01                	mov    (%ecx),%al
  800d31:	84 c0                	test   %al,%al
  800d33:	74 04                	je     800d39 <strcmp+0x17>
  800d35:	3a 02                	cmp    (%edx),%al
  800d37:	74 f4                	je     800d2d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d39:	0f b6 c0             	movzbl %al,%eax
  800d3c:	0f b6 12             	movzbl (%edx),%edx
  800d3f:	29 d0                	sub    %edx,%eax
}
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	53                   	push   %ebx
  800d47:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800d50:	eb 03                	jmp    800d55 <strncmp+0x12>
		n--, p++, q++;
  800d52:	4a                   	dec    %edx
  800d53:	40                   	inc    %eax
  800d54:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d55:	85 d2                	test   %edx,%edx
  800d57:	74 14                	je     800d6d <strncmp+0x2a>
  800d59:	8a 18                	mov    (%eax),%bl
  800d5b:	84 db                	test   %bl,%bl
  800d5d:	74 04                	je     800d63 <strncmp+0x20>
  800d5f:	3a 19                	cmp    (%ecx),%bl
  800d61:	74 ef                	je     800d52 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d63:	0f b6 00             	movzbl (%eax),%eax
  800d66:	0f b6 11             	movzbl (%ecx),%edx
  800d69:	29 d0                	sub    %edx,%eax
  800d6b:	eb 05                	jmp    800d72 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d6d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d72:	5b                   	pop    %ebx
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    

00800d75 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d7e:	eb 05                	jmp    800d85 <strchr+0x10>
		if (*s == c)
  800d80:	38 ca                	cmp    %cl,%dl
  800d82:	74 0c                	je     800d90 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d84:	40                   	inc    %eax
  800d85:	8a 10                	mov    (%eax),%dl
  800d87:	84 d2                	test   %dl,%dl
  800d89:	75 f5                	jne    800d80 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800d8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	8b 45 08             	mov    0x8(%ebp),%eax
  800d98:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d9b:	eb 05                	jmp    800da2 <strfind+0x10>
		if (*s == c)
  800d9d:	38 ca                	cmp    %cl,%dl
  800d9f:	74 07                	je     800da8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800da1:	40                   	inc    %eax
  800da2:	8a 10                	mov    (%eax),%dl
  800da4:	84 d2                	test   %dl,%dl
  800da6:	75 f5                	jne    800d9d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	57                   	push   %edi
  800dae:	56                   	push   %esi
  800daf:	53                   	push   %ebx
  800db0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800db3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800db9:	85 c9                	test   %ecx,%ecx
  800dbb:	74 30                	je     800ded <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dbd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dc3:	75 25                	jne    800dea <memset+0x40>
  800dc5:	f6 c1 03             	test   $0x3,%cl
  800dc8:	75 20                	jne    800dea <memset+0x40>
		c &= 0xFF;
  800dca:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dcd:	89 d3                	mov    %edx,%ebx
  800dcf:	c1 e3 08             	shl    $0x8,%ebx
  800dd2:	89 d6                	mov    %edx,%esi
  800dd4:	c1 e6 18             	shl    $0x18,%esi
  800dd7:	89 d0                	mov    %edx,%eax
  800dd9:	c1 e0 10             	shl    $0x10,%eax
  800ddc:	09 f0                	or     %esi,%eax
  800dde:	09 d0                	or     %edx,%eax
  800de0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800de2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800de5:	fc                   	cld    
  800de6:	f3 ab                	rep stos %eax,%es:(%edi)
  800de8:	eb 03                	jmp    800ded <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dea:	fc                   	cld    
  800deb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ded:	89 f8                	mov    %edi,%eax
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    

00800df4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	57                   	push   %edi
  800df8:	56                   	push   %esi
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800dff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e02:	39 c6                	cmp    %eax,%esi
  800e04:	73 34                	jae    800e3a <memmove+0x46>
  800e06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e09:	39 d0                	cmp    %edx,%eax
  800e0b:	73 2d                	jae    800e3a <memmove+0x46>
		s += n;
		d += n;
  800e0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e10:	f6 c2 03             	test   $0x3,%dl
  800e13:	75 1b                	jne    800e30 <memmove+0x3c>
  800e15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e1b:	75 13                	jne    800e30 <memmove+0x3c>
  800e1d:	f6 c1 03             	test   $0x3,%cl
  800e20:	75 0e                	jne    800e30 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e22:	83 ef 04             	sub    $0x4,%edi
  800e25:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e28:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e2b:	fd                   	std    
  800e2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e2e:	eb 07                	jmp    800e37 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e30:	4f                   	dec    %edi
  800e31:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e34:	fd                   	std    
  800e35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e37:	fc                   	cld    
  800e38:	eb 20                	jmp    800e5a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e3a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e40:	75 13                	jne    800e55 <memmove+0x61>
  800e42:	a8 03                	test   $0x3,%al
  800e44:	75 0f                	jne    800e55 <memmove+0x61>
  800e46:	f6 c1 03             	test   $0x3,%cl
  800e49:	75 0a                	jne    800e55 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e4b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e4e:	89 c7                	mov    %eax,%edi
  800e50:	fc                   	cld    
  800e51:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e53:	eb 05                	jmp    800e5a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e55:	89 c7                	mov    %eax,%edi
  800e57:	fc                   	cld    
  800e58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e5a:	5e                   	pop    %esi
  800e5b:	5f                   	pop    %edi
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    

00800e5e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e64:	8b 45 10             	mov    0x10(%ebp),%eax
  800e67:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e72:	8b 45 08             	mov    0x8(%ebp),%eax
  800e75:	89 04 24             	mov    %eax,(%esp)
  800e78:	e8 77 ff ff ff       	call   800df4 <memmove>
}
  800e7d:	c9                   	leave  
  800e7e:	c3                   	ret    

00800e7f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e7f:	55                   	push   %ebp
  800e80:	89 e5                	mov    %esp,%ebp
  800e82:	57                   	push   %edi
  800e83:	56                   	push   %esi
  800e84:	53                   	push   %ebx
  800e85:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e93:	eb 16                	jmp    800eab <memcmp+0x2c>
		if (*s1 != *s2)
  800e95:	8a 04 17             	mov    (%edi,%edx,1),%al
  800e98:	42                   	inc    %edx
  800e99:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800e9d:	38 c8                	cmp    %cl,%al
  800e9f:	74 0a                	je     800eab <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ea1:	0f b6 c0             	movzbl %al,%eax
  800ea4:	0f b6 c9             	movzbl %cl,%ecx
  800ea7:	29 c8                	sub    %ecx,%eax
  800ea9:	eb 09                	jmp    800eb4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eab:	39 da                	cmp    %ebx,%edx
  800ead:	75 e6                	jne    800e95 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800ec2:	89 c2                	mov    %eax,%edx
  800ec4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ec7:	eb 05                	jmp    800ece <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ec9:	38 08                	cmp    %cl,(%eax)
  800ecb:	74 05                	je     800ed2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ecd:	40                   	inc    %eax
  800ece:	39 d0                	cmp    %edx,%eax
  800ed0:	72 f7                	jb     800ec9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
  800eda:	8b 55 08             	mov    0x8(%ebp),%edx
  800edd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ee0:	eb 01                	jmp    800ee3 <strtol+0xf>
		s++;
  800ee2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ee3:	8a 02                	mov    (%edx),%al
  800ee5:	3c 20                	cmp    $0x20,%al
  800ee7:	74 f9                	je     800ee2 <strtol+0xe>
  800ee9:	3c 09                	cmp    $0x9,%al
  800eeb:	74 f5                	je     800ee2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800eed:	3c 2b                	cmp    $0x2b,%al
  800eef:	75 08                	jne    800ef9 <strtol+0x25>
		s++;
  800ef1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ef2:	bf 00 00 00 00       	mov    $0x0,%edi
  800ef7:	eb 13                	jmp    800f0c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ef9:	3c 2d                	cmp    $0x2d,%al
  800efb:	75 0a                	jne    800f07 <strtol+0x33>
		s++, neg = 1;
  800efd:	8d 52 01             	lea    0x1(%edx),%edx
  800f00:	bf 01 00 00 00       	mov    $0x1,%edi
  800f05:	eb 05                	jmp    800f0c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f0c:	85 db                	test   %ebx,%ebx
  800f0e:	74 05                	je     800f15 <strtol+0x41>
  800f10:	83 fb 10             	cmp    $0x10,%ebx
  800f13:	75 28                	jne    800f3d <strtol+0x69>
  800f15:	8a 02                	mov    (%edx),%al
  800f17:	3c 30                	cmp    $0x30,%al
  800f19:	75 10                	jne    800f2b <strtol+0x57>
  800f1b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f1f:	75 0a                	jne    800f2b <strtol+0x57>
		s += 2, base = 16;
  800f21:	83 c2 02             	add    $0x2,%edx
  800f24:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f29:	eb 12                	jmp    800f3d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800f2b:	85 db                	test   %ebx,%ebx
  800f2d:	75 0e                	jne    800f3d <strtol+0x69>
  800f2f:	3c 30                	cmp    $0x30,%al
  800f31:	75 05                	jne    800f38 <strtol+0x64>
		s++, base = 8;
  800f33:	42                   	inc    %edx
  800f34:	b3 08                	mov    $0x8,%bl
  800f36:	eb 05                	jmp    800f3d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800f38:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800f42:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f44:	8a 0a                	mov    (%edx),%cl
  800f46:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f49:	80 fb 09             	cmp    $0x9,%bl
  800f4c:	77 08                	ja     800f56 <strtol+0x82>
			dig = *s - '0';
  800f4e:	0f be c9             	movsbl %cl,%ecx
  800f51:	83 e9 30             	sub    $0x30,%ecx
  800f54:	eb 1e                	jmp    800f74 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800f56:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800f59:	80 fb 19             	cmp    $0x19,%bl
  800f5c:	77 08                	ja     800f66 <strtol+0x92>
			dig = *s - 'a' + 10;
  800f5e:	0f be c9             	movsbl %cl,%ecx
  800f61:	83 e9 57             	sub    $0x57,%ecx
  800f64:	eb 0e                	jmp    800f74 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800f66:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800f69:	80 fb 19             	cmp    $0x19,%bl
  800f6c:	77 12                	ja     800f80 <strtol+0xac>
			dig = *s - 'A' + 10;
  800f6e:	0f be c9             	movsbl %cl,%ecx
  800f71:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f74:	39 f1                	cmp    %esi,%ecx
  800f76:	7d 0c                	jge    800f84 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800f78:	42                   	inc    %edx
  800f79:	0f af c6             	imul   %esi,%eax
  800f7c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800f7e:	eb c4                	jmp    800f44 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800f80:	89 c1                	mov    %eax,%ecx
  800f82:	eb 02                	jmp    800f86 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f84:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f8a:	74 05                	je     800f91 <strtol+0xbd>
		*endptr = (char *) s;
  800f8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f8f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f91:	85 ff                	test   %edi,%edi
  800f93:	74 04                	je     800f99 <strtol+0xc5>
  800f95:	89 c8                	mov    %ecx,%eax
  800f97:	f7 d8                	neg    %eax
}
  800f99:	5b                   	pop    %ebx
  800f9a:	5e                   	pop    %esi
  800f9b:	5f                   	pop    %edi
  800f9c:	5d                   	pop    %ebp
  800f9d:	c3                   	ret    
	...

00800fa0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	57                   	push   %edi
  800fa4:	56                   	push   %esi
  800fa5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fae:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb1:	89 c3                	mov    %eax,%ebx
  800fb3:	89 c7                	mov    %eax,%edi
  800fb5:	89 c6                	mov    %eax,%esi
  800fb7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fb9:	5b                   	pop    %ebx
  800fba:	5e                   	pop    %esi
  800fbb:	5f                   	pop    %edi
  800fbc:	5d                   	pop    %ebp
  800fbd:	c3                   	ret    

00800fbe <sys_cgetc>:

int
sys_cgetc(void)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800fce:	89 d1                	mov    %edx,%ecx
  800fd0:	89 d3                	mov    %edx,%ebx
  800fd2:	89 d7                	mov    %edx,%edi
  800fd4:	89 d6                	mov    %edx,%esi
  800fd6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fd8:	5b                   	pop    %ebx
  800fd9:	5e                   	pop    %esi
  800fda:	5f                   	pop    %edi
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    

00800fdd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	57                   	push   %edi
  800fe1:	56                   	push   %esi
  800fe2:	53                   	push   %ebx
  800fe3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800feb:	b8 03 00 00 00       	mov    $0x3,%eax
  800ff0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff3:	89 cb                	mov    %ecx,%ebx
  800ff5:	89 cf                	mov    %ecx,%edi
  800ff7:	89 ce                	mov    %ecx,%esi
  800ff9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	7e 28                	jle    801027 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fff:	89 44 24 10          	mov    %eax,0x10(%esp)
  801003:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80100a:	00 
  80100b:	c7 44 24 08 63 2e 80 	movl   $0x802e63,0x8(%esp)
  801012:	00 
  801013:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80101a:	00 
  80101b:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  801022:	e8 b1 f5 ff ff       	call   8005d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801027:	83 c4 2c             	add    $0x2c,%esp
  80102a:	5b                   	pop    %ebx
  80102b:	5e                   	pop    %esi
  80102c:	5f                   	pop    %edi
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    

0080102f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	57                   	push   %edi
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801035:	ba 00 00 00 00       	mov    $0x0,%edx
  80103a:	b8 02 00 00 00       	mov    $0x2,%eax
  80103f:	89 d1                	mov    %edx,%ecx
  801041:	89 d3                	mov    %edx,%ebx
  801043:	89 d7                	mov    %edx,%edi
  801045:	89 d6                	mov    %edx,%esi
  801047:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801049:	5b                   	pop    %ebx
  80104a:	5e                   	pop    %esi
  80104b:	5f                   	pop    %edi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <sys_yield>:

void
sys_yield(void)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	57                   	push   %edi
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801054:	ba 00 00 00 00       	mov    $0x0,%edx
  801059:	b8 0b 00 00 00       	mov    $0xb,%eax
  80105e:	89 d1                	mov    %edx,%ecx
  801060:	89 d3                	mov    %edx,%ebx
  801062:	89 d7                	mov    %edx,%edi
  801064:	89 d6                	mov    %edx,%esi
  801066:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801068:	5b                   	pop    %ebx
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	57                   	push   %edi
  801071:	56                   	push   %esi
  801072:	53                   	push   %ebx
  801073:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801076:	be 00 00 00 00       	mov    $0x0,%esi
  80107b:	b8 04 00 00 00       	mov    $0x4,%eax
  801080:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801083:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801086:	8b 55 08             	mov    0x8(%ebp),%edx
  801089:	89 f7                	mov    %esi,%edi
  80108b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80108d:	85 c0                	test   %eax,%eax
  80108f:	7e 28                	jle    8010b9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801091:	89 44 24 10          	mov    %eax,0x10(%esp)
  801095:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80109c:	00 
  80109d:	c7 44 24 08 63 2e 80 	movl   $0x802e63,0x8(%esp)
  8010a4:	00 
  8010a5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010ac:	00 
  8010ad:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  8010b4:	e8 1f f5 ff ff       	call   8005d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8010b9:	83 c4 2c             	add    $0x2c,%esp
  8010bc:	5b                   	pop    %ebx
  8010bd:	5e                   	pop    %esi
  8010be:	5f                   	pop    %edi
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	57                   	push   %edi
  8010c5:	56                   	push   %esi
  8010c6:	53                   	push   %ebx
  8010c7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8010cf:	8b 75 18             	mov    0x18(%ebp),%esi
  8010d2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010db:	8b 55 08             	mov    0x8(%ebp),%edx
  8010de:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	7e 28                	jle    80110c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8010ef:	00 
  8010f0:	c7 44 24 08 63 2e 80 	movl   $0x802e63,0x8(%esp)
  8010f7:	00 
  8010f8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010ff:	00 
  801100:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  801107:	e8 cc f4 ff ff       	call   8005d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80110c:	83 c4 2c             	add    $0x2c,%esp
  80110f:	5b                   	pop    %ebx
  801110:	5e                   	pop    %esi
  801111:	5f                   	pop    %edi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
  80111a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801122:	b8 06 00 00 00       	mov    $0x6,%eax
  801127:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112a:	8b 55 08             	mov    0x8(%ebp),%edx
  80112d:	89 df                	mov    %ebx,%edi
  80112f:	89 de                	mov    %ebx,%esi
  801131:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801133:	85 c0                	test   %eax,%eax
  801135:	7e 28                	jle    80115f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801137:	89 44 24 10          	mov    %eax,0x10(%esp)
  80113b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801142:	00 
  801143:	c7 44 24 08 63 2e 80 	movl   $0x802e63,0x8(%esp)
  80114a:	00 
  80114b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801152:	00 
  801153:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  80115a:	e8 79 f4 ff ff       	call   8005d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80115f:	83 c4 2c             	add    $0x2c,%esp
  801162:	5b                   	pop    %ebx
  801163:	5e                   	pop    %esi
  801164:	5f                   	pop    %edi
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	57                   	push   %edi
  80116b:	56                   	push   %esi
  80116c:	53                   	push   %ebx
  80116d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801170:	bb 00 00 00 00       	mov    $0x0,%ebx
  801175:	b8 08 00 00 00       	mov    $0x8,%eax
  80117a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117d:	8b 55 08             	mov    0x8(%ebp),%edx
  801180:	89 df                	mov    %ebx,%edi
  801182:	89 de                	mov    %ebx,%esi
  801184:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801186:	85 c0                	test   %eax,%eax
  801188:	7e 28                	jle    8011b2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80118a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80118e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801195:	00 
  801196:	c7 44 24 08 63 2e 80 	movl   $0x802e63,0x8(%esp)
  80119d:	00 
  80119e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011a5:	00 
  8011a6:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  8011ad:	e8 26 f4 ff ff       	call   8005d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011b2:	83 c4 2c             	add    $0x2c,%esp
  8011b5:	5b                   	pop    %ebx
  8011b6:	5e                   	pop    %esi
  8011b7:	5f                   	pop    %edi
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	57                   	push   %edi
  8011be:	56                   	push   %esi
  8011bf:	53                   	push   %ebx
  8011c0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c8:	b8 09 00 00 00       	mov    $0x9,%eax
  8011cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d3:	89 df                	mov    %ebx,%edi
  8011d5:	89 de                	mov    %ebx,%esi
  8011d7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	7e 28                	jle    801205 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011e1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8011e8:	00 
  8011e9:	c7 44 24 08 63 2e 80 	movl   $0x802e63,0x8(%esp)
  8011f0:	00 
  8011f1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011f8:	00 
  8011f9:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  801200:	e8 d3 f3 ff ff       	call   8005d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801205:	83 c4 2c             	add    $0x2c,%esp
  801208:	5b                   	pop    %ebx
  801209:	5e                   	pop    %esi
  80120a:	5f                   	pop    %edi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	57                   	push   %edi
  801211:	56                   	push   %esi
  801212:	53                   	push   %ebx
  801213:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801216:	bb 00 00 00 00       	mov    $0x0,%ebx
  80121b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801223:	8b 55 08             	mov    0x8(%ebp),%edx
  801226:	89 df                	mov    %ebx,%edi
  801228:	89 de                	mov    %ebx,%esi
  80122a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80122c:	85 c0                	test   %eax,%eax
  80122e:	7e 28                	jle    801258 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801230:	89 44 24 10          	mov    %eax,0x10(%esp)
  801234:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80123b:	00 
  80123c:	c7 44 24 08 63 2e 80 	movl   $0x802e63,0x8(%esp)
  801243:	00 
  801244:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80124b:	00 
  80124c:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  801253:	e8 80 f3 ff ff       	call   8005d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801258:	83 c4 2c             	add    $0x2c,%esp
  80125b:	5b                   	pop    %ebx
  80125c:	5e                   	pop    %esi
  80125d:	5f                   	pop    %edi
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    

00801260 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	57                   	push   %edi
  801264:	56                   	push   %esi
  801265:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801266:	be 00 00 00 00       	mov    $0x0,%esi
  80126b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801270:	8b 7d 14             	mov    0x14(%ebp),%edi
  801273:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801279:	8b 55 08             	mov    0x8(%ebp),%edx
  80127c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80127e:	5b                   	pop    %ebx
  80127f:	5e                   	pop    %esi
  801280:	5f                   	pop    %edi
  801281:	5d                   	pop    %ebp
  801282:	c3                   	ret    

00801283 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801283:	55                   	push   %ebp
  801284:	89 e5                	mov    %esp,%ebp
  801286:	57                   	push   %edi
  801287:	56                   	push   %esi
  801288:	53                   	push   %ebx
  801289:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80128c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801291:	b8 0d 00 00 00       	mov    $0xd,%eax
  801296:	8b 55 08             	mov    0x8(%ebp),%edx
  801299:	89 cb                	mov    %ecx,%ebx
  80129b:	89 cf                	mov    %ecx,%edi
  80129d:	89 ce                	mov    %ecx,%esi
  80129f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	7e 28                	jle    8012cd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012a9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8012b0:	00 
  8012b1:	c7 44 24 08 63 2e 80 	movl   $0x802e63,0x8(%esp)
  8012b8:	00 
  8012b9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012c0:	00 
  8012c1:	c7 04 24 80 2e 80 00 	movl   $0x802e80,(%esp)
  8012c8:	e8 0b f3 ff ff       	call   8005d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012cd:	83 c4 2c             	add    $0x2c,%esp
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5f                   	pop    %edi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    

008012d5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	57                   	push   %edi
  8012d9:	56                   	push   %esi
  8012da:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012db:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012e5:	89 d1                	mov    %edx,%ecx
  8012e7:	89 d3                	mov    %edx,%ebx
  8012e9:	89 d7                	mov    %edx,%edi
  8012eb:	89 d6                	mov    %edx,%esi
  8012ed:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8012ef:	5b                   	pop    %ebx
  8012f0:	5e                   	pop    %esi
  8012f1:	5f                   	pop    %edi
  8012f2:	5d                   	pop    %ebp
  8012f3:	c3                   	ret    

008012f4 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	57                   	push   %edi
  8012f8:	56                   	push   %esi
  8012f9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ff:	b8 0f 00 00 00       	mov    $0xf,%eax
  801304:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801307:	8b 55 08             	mov    0x8(%ebp),%edx
  80130a:	89 df                	mov    %ebx,%edi
  80130c:	89 de                	mov    %ebx,%esi
  80130e:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  801310:	5b                   	pop    %ebx
  801311:	5e                   	pop    %esi
  801312:	5f                   	pop    %edi
  801313:	5d                   	pop    %ebp
  801314:	c3                   	ret    

00801315 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	57                   	push   %edi
  801319:	56                   	push   %esi
  80131a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80131b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801320:	b8 10 00 00 00       	mov    $0x10,%eax
  801325:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801328:	8b 55 08             	mov    0x8(%ebp),%edx
  80132b:	89 df                	mov    %ebx,%edi
  80132d:	89 de                	mov    %ebx,%esi
  80132f:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  801331:	5b                   	pop    %ebx
  801332:	5e                   	pop    %esi
  801333:	5f                   	pop    %edi
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    
	...

00801338 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80133e:	83 3d b8 40 80 00 00 	cmpl   $0x0,0x8040b8
  801345:	75 30                	jne    801377 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  801347:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80134e:	00 
  80134f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801356:	ee 
  801357:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80135e:	e8 0a fd ff ff       	call   80106d <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  801363:	c7 44 24 04 84 13 80 	movl   $0x801384,0x4(%esp)
  80136a:	00 
  80136b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801372:	e8 96 fe ff ff       	call   80120d <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801377:	8b 45 08             	mov    0x8(%ebp),%eax
  80137a:	a3 b8 40 80 00       	mov    %eax,0x8040b8
}
  80137f:	c9                   	leave  
  801380:	c3                   	ret    
  801381:	00 00                	add    %al,(%eax)
	...

00801384 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801384:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801385:	a1 b8 40 80 00       	mov    0x8040b8,%eax
	call *%eax
  80138a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80138c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  80138f:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  801393:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  801397:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  80139a:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  80139c:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  8013a0:	83 c4 08             	add    $0x8,%esp
	popal
  8013a3:	61                   	popa   

	addl $4,%esp 
  8013a4:	83 c4 04             	add    $0x4,%esp
	popfl
  8013a7:	9d                   	popf   

	popl %esp
  8013a8:	5c                   	pop    %esp

	ret
  8013a9:	c3                   	ret    
	...

008013ac <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013af:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b2:	05 00 00 00 30       	add    $0x30000000,%eax
  8013b7:	c1 e8 0c             	shr    $0xc,%eax
}
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    

008013bc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013bc:	55                   	push   %ebp
  8013bd:	89 e5                	mov    %esp,%ebp
  8013bf:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8013c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c5:	89 04 24             	mov    %eax,(%esp)
  8013c8:	e8 df ff ff ff       	call   8013ac <fd2num>
  8013cd:	c1 e0 0c             	shl    $0xc,%eax
  8013d0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    

008013d7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013d7:	55                   	push   %ebp
  8013d8:	89 e5                	mov    %esp,%ebp
  8013da:	53                   	push   %ebx
  8013db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8013de:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8013e3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013e5:	89 c2                	mov    %eax,%edx
  8013e7:	c1 ea 16             	shr    $0x16,%edx
  8013ea:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013f1:	f6 c2 01             	test   $0x1,%dl
  8013f4:	74 11                	je     801407 <fd_alloc+0x30>
  8013f6:	89 c2                	mov    %eax,%edx
  8013f8:	c1 ea 0c             	shr    $0xc,%edx
  8013fb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801402:	f6 c2 01             	test   $0x1,%dl
  801405:	75 09                	jne    801410 <fd_alloc+0x39>
			*fd_store = fd;
  801407:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801409:	b8 00 00 00 00       	mov    $0x0,%eax
  80140e:	eb 17                	jmp    801427 <fd_alloc+0x50>
  801410:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801415:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80141a:	75 c7                	jne    8013e3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80141c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801422:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801427:	5b                   	pop    %ebx
  801428:	5d                   	pop    %ebp
  801429:	c3                   	ret    

0080142a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801430:	83 f8 1f             	cmp    $0x1f,%eax
  801433:	77 36                	ja     80146b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801435:	c1 e0 0c             	shl    $0xc,%eax
  801438:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80143d:	89 c2                	mov    %eax,%edx
  80143f:	c1 ea 16             	shr    $0x16,%edx
  801442:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801449:	f6 c2 01             	test   $0x1,%dl
  80144c:	74 24                	je     801472 <fd_lookup+0x48>
  80144e:	89 c2                	mov    %eax,%edx
  801450:	c1 ea 0c             	shr    $0xc,%edx
  801453:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80145a:	f6 c2 01             	test   $0x1,%dl
  80145d:	74 1a                	je     801479 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80145f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801462:	89 02                	mov    %eax,(%edx)
	return 0;
  801464:	b8 00 00 00 00       	mov    $0x0,%eax
  801469:	eb 13                	jmp    80147e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80146b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801470:	eb 0c                	jmp    80147e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801472:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801477:	eb 05                	jmp    80147e <fd_lookup+0x54>
  801479:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80147e:	5d                   	pop    %ebp
  80147f:	c3                   	ret    

00801480 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801480:	55                   	push   %ebp
  801481:	89 e5                	mov    %esp,%ebp
  801483:	53                   	push   %ebx
  801484:	83 ec 14             	sub    $0x14,%esp
  801487:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80148a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  80148d:	ba 00 00 00 00       	mov    $0x0,%edx
  801492:	eb 0e                	jmp    8014a2 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801494:	39 08                	cmp    %ecx,(%eax)
  801496:	75 09                	jne    8014a1 <dev_lookup+0x21>
			*dev = devtab[i];
  801498:	89 03                	mov    %eax,(%ebx)
			return 0;
  80149a:	b8 00 00 00 00       	mov    $0x0,%eax
  80149f:	eb 33                	jmp    8014d4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014a1:	42                   	inc    %edx
  8014a2:	8b 04 95 10 2f 80 00 	mov    0x802f10(,%edx,4),%eax
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	75 e7                	jne    801494 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014ad:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8014b2:	8b 40 48             	mov    0x48(%eax),%eax
  8014b5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8014b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bd:	c7 04 24 90 2e 80 00 	movl   $0x802e90,(%esp)
  8014c4:	e8 07 f2 ff ff       	call   8006d0 <cprintf>
	*dev = 0;
  8014c9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8014cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014d4:	83 c4 14             	add    $0x14,%esp
  8014d7:	5b                   	pop    %ebx
  8014d8:	5d                   	pop    %ebp
  8014d9:	c3                   	ret    

008014da <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	56                   	push   %esi
  8014de:	53                   	push   %ebx
  8014df:	83 ec 30             	sub    $0x30,%esp
  8014e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e5:	8a 45 0c             	mov    0xc(%ebp),%al
  8014e8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014eb:	89 34 24             	mov    %esi,(%esp)
  8014ee:	e8 b9 fe ff ff       	call   8013ac <fd2num>
  8014f3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014f6:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014fa:	89 04 24             	mov    %eax,(%esp)
  8014fd:	e8 28 ff ff ff       	call   80142a <fd_lookup>
  801502:	89 c3                	mov    %eax,%ebx
  801504:	85 c0                	test   %eax,%eax
  801506:	78 05                	js     80150d <fd_close+0x33>
	    || fd != fd2)
  801508:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80150b:	74 0d                	je     80151a <fd_close+0x40>
		return (must_exist ? r : 0);
  80150d:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801511:	75 46                	jne    801559 <fd_close+0x7f>
  801513:	bb 00 00 00 00       	mov    $0x0,%ebx
  801518:	eb 3f                	jmp    801559 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80151a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801521:	8b 06                	mov    (%esi),%eax
  801523:	89 04 24             	mov    %eax,(%esp)
  801526:	e8 55 ff ff ff       	call   801480 <dev_lookup>
  80152b:	89 c3                	mov    %eax,%ebx
  80152d:	85 c0                	test   %eax,%eax
  80152f:	78 18                	js     801549 <fd_close+0x6f>
		if (dev->dev_close)
  801531:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801534:	8b 40 10             	mov    0x10(%eax),%eax
  801537:	85 c0                	test   %eax,%eax
  801539:	74 09                	je     801544 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80153b:	89 34 24             	mov    %esi,(%esp)
  80153e:	ff d0                	call   *%eax
  801540:	89 c3                	mov    %eax,%ebx
  801542:	eb 05                	jmp    801549 <fd_close+0x6f>
		else
			r = 0;
  801544:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801549:	89 74 24 04          	mov    %esi,0x4(%esp)
  80154d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801554:	e8 bb fb ff ff       	call   801114 <sys_page_unmap>
	return r;
}
  801559:	89 d8                	mov    %ebx,%eax
  80155b:	83 c4 30             	add    $0x30,%esp
  80155e:	5b                   	pop    %ebx
  80155f:	5e                   	pop    %esi
  801560:	5d                   	pop    %ebp
  801561:	c3                   	ret    

00801562 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801562:	55                   	push   %ebp
  801563:	89 e5                	mov    %esp,%ebp
  801565:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801568:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80156b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156f:	8b 45 08             	mov    0x8(%ebp),%eax
  801572:	89 04 24             	mov    %eax,(%esp)
  801575:	e8 b0 fe ff ff       	call   80142a <fd_lookup>
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 13                	js     801591 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80157e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801585:	00 
  801586:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801589:	89 04 24             	mov    %eax,(%esp)
  80158c:	e8 49 ff ff ff       	call   8014da <fd_close>
}
  801591:	c9                   	leave  
  801592:	c3                   	ret    

00801593 <close_all>:

void
close_all(void)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	53                   	push   %ebx
  801597:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80159a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80159f:	89 1c 24             	mov    %ebx,(%esp)
  8015a2:	e8 bb ff ff ff       	call   801562 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015a7:	43                   	inc    %ebx
  8015a8:	83 fb 20             	cmp    $0x20,%ebx
  8015ab:	75 f2                	jne    80159f <close_all+0xc>
		close(i);
}
  8015ad:	83 c4 14             	add    $0x14,%esp
  8015b0:	5b                   	pop    %ebx
  8015b1:	5d                   	pop    %ebp
  8015b2:	c3                   	ret    

008015b3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	57                   	push   %edi
  8015b7:	56                   	push   %esi
  8015b8:	53                   	push   %ebx
  8015b9:	83 ec 4c             	sub    $0x4c,%esp
  8015bc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015bf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c9:	89 04 24             	mov    %eax,(%esp)
  8015cc:	e8 59 fe ff ff       	call   80142a <fd_lookup>
  8015d1:	89 c3                	mov    %eax,%ebx
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	0f 88 e3 00 00 00    	js     8016be <dup+0x10b>
		return r;
	close(newfdnum);
  8015db:	89 3c 24             	mov    %edi,(%esp)
  8015de:	e8 7f ff ff ff       	call   801562 <close>

	newfd = INDEX2FD(newfdnum);
  8015e3:	89 fe                	mov    %edi,%esi
  8015e5:	c1 e6 0c             	shl    $0xc,%esi
  8015e8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8015ee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015f1:	89 04 24             	mov    %eax,(%esp)
  8015f4:	e8 c3 fd ff ff       	call   8013bc <fd2data>
  8015f9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015fb:	89 34 24             	mov    %esi,(%esp)
  8015fe:	e8 b9 fd ff ff       	call   8013bc <fd2data>
  801603:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801606:	89 d8                	mov    %ebx,%eax
  801608:	c1 e8 16             	shr    $0x16,%eax
  80160b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801612:	a8 01                	test   $0x1,%al
  801614:	74 46                	je     80165c <dup+0xa9>
  801616:	89 d8                	mov    %ebx,%eax
  801618:	c1 e8 0c             	shr    $0xc,%eax
  80161b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801622:	f6 c2 01             	test   $0x1,%dl
  801625:	74 35                	je     80165c <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801627:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80162e:	25 07 0e 00 00       	and    $0xe07,%eax
  801633:	89 44 24 10          	mov    %eax,0x10(%esp)
  801637:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80163a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80163e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801645:	00 
  801646:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80164a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801651:	e8 6b fa ff ff       	call   8010c1 <sys_page_map>
  801656:	89 c3                	mov    %eax,%ebx
  801658:	85 c0                	test   %eax,%eax
  80165a:	78 3b                	js     801697 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80165c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80165f:	89 c2                	mov    %eax,%edx
  801661:	c1 ea 0c             	shr    $0xc,%edx
  801664:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80166b:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801671:	89 54 24 10          	mov    %edx,0x10(%esp)
  801675:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801679:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801680:	00 
  801681:	89 44 24 04          	mov    %eax,0x4(%esp)
  801685:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80168c:	e8 30 fa ff ff       	call   8010c1 <sys_page_map>
  801691:	89 c3                	mov    %eax,%ebx
  801693:	85 c0                	test   %eax,%eax
  801695:	79 25                	jns    8016bc <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801697:	89 74 24 04          	mov    %esi,0x4(%esp)
  80169b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a2:	e8 6d fa ff ff       	call   801114 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016a7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016b5:	e8 5a fa ff ff       	call   801114 <sys_page_unmap>
	return r;
  8016ba:	eb 02                	jmp    8016be <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8016bc:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016be:	89 d8                	mov    %ebx,%eax
  8016c0:	83 c4 4c             	add    $0x4c,%esp
  8016c3:	5b                   	pop    %ebx
  8016c4:	5e                   	pop    %esi
  8016c5:	5f                   	pop    %edi
  8016c6:	5d                   	pop    %ebp
  8016c7:	c3                   	ret    

008016c8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	53                   	push   %ebx
  8016cc:	83 ec 24             	sub    $0x24,%esp
  8016cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d9:	89 1c 24             	mov    %ebx,(%esp)
  8016dc:	e8 49 fd ff ff       	call   80142a <fd_lookup>
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 6d                	js     801752 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ef:	8b 00                	mov    (%eax),%eax
  8016f1:	89 04 24             	mov    %eax,(%esp)
  8016f4:	e8 87 fd ff ff       	call   801480 <dev_lookup>
  8016f9:	85 c0                	test   %eax,%eax
  8016fb:	78 55                	js     801752 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801700:	8b 50 08             	mov    0x8(%eax),%edx
  801703:	83 e2 03             	and    $0x3,%edx
  801706:	83 fa 01             	cmp    $0x1,%edx
  801709:	75 23                	jne    80172e <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80170b:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  801710:	8b 40 48             	mov    0x48(%eax),%eax
  801713:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801717:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171b:	c7 04 24 d4 2e 80 00 	movl   $0x802ed4,(%esp)
  801722:	e8 a9 ef ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  801727:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80172c:	eb 24                	jmp    801752 <read+0x8a>
	}
	if (!dev->dev_read)
  80172e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801731:	8b 52 08             	mov    0x8(%edx),%edx
  801734:	85 d2                	test   %edx,%edx
  801736:	74 15                	je     80174d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801738:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80173b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80173f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801742:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801746:	89 04 24             	mov    %eax,(%esp)
  801749:	ff d2                	call   *%edx
  80174b:	eb 05                	jmp    801752 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80174d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801752:	83 c4 24             	add    $0x24,%esp
  801755:	5b                   	pop    %ebx
  801756:	5d                   	pop    %ebp
  801757:	c3                   	ret    

00801758 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	57                   	push   %edi
  80175c:	56                   	push   %esi
  80175d:	53                   	push   %ebx
  80175e:	83 ec 1c             	sub    $0x1c,%esp
  801761:	8b 7d 08             	mov    0x8(%ebp),%edi
  801764:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801767:	bb 00 00 00 00       	mov    $0x0,%ebx
  80176c:	eb 23                	jmp    801791 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80176e:	89 f0                	mov    %esi,%eax
  801770:	29 d8                	sub    %ebx,%eax
  801772:	89 44 24 08          	mov    %eax,0x8(%esp)
  801776:	8b 45 0c             	mov    0xc(%ebp),%eax
  801779:	01 d8                	add    %ebx,%eax
  80177b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177f:	89 3c 24             	mov    %edi,(%esp)
  801782:	e8 41 ff ff ff       	call   8016c8 <read>
		if (m < 0)
  801787:	85 c0                	test   %eax,%eax
  801789:	78 10                	js     80179b <readn+0x43>
			return m;
		if (m == 0)
  80178b:	85 c0                	test   %eax,%eax
  80178d:	74 0a                	je     801799 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80178f:	01 c3                	add    %eax,%ebx
  801791:	39 f3                	cmp    %esi,%ebx
  801793:	72 d9                	jb     80176e <readn+0x16>
  801795:	89 d8                	mov    %ebx,%eax
  801797:	eb 02                	jmp    80179b <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801799:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80179b:	83 c4 1c             	add    $0x1c,%esp
  80179e:	5b                   	pop    %ebx
  80179f:	5e                   	pop    %esi
  8017a0:	5f                   	pop    %edi
  8017a1:	5d                   	pop    %ebp
  8017a2:	c3                   	ret    

008017a3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	53                   	push   %ebx
  8017a7:	83 ec 24             	sub    $0x24,%esp
  8017aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b4:	89 1c 24             	mov    %ebx,(%esp)
  8017b7:	e8 6e fc ff ff       	call   80142a <fd_lookup>
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	78 68                	js     801828 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ca:	8b 00                	mov    (%eax),%eax
  8017cc:	89 04 24             	mov    %eax,(%esp)
  8017cf:	e8 ac fc ff ff       	call   801480 <dev_lookup>
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	78 50                	js     801828 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017db:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017df:	75 23                	jne    801804 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017e1:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8017e6:	8b 40 48             	mov    0x48(%eax),%eax
  8017e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f1:	c7 04 24 f0 2e 80 00 	movl   $0x802ef0,(%esp)
  8017f8:	e8 d3 ee ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  8017fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801802:	eb 24                	jmp    801828 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801804:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801807:	8b 52 0c             	mov    0xc(%edx),%edx
  80180a:	85 d2                	test   %edx,%edx
  80180c:	74 15                	je     801823 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80180e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801811:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801815:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801818:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80181c:	89 04 24             	mov    %eax,(%esp)
  80181f:	ff d2                	call   *%edx
  801821:	eb 05                	jmp    801828 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801823:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801828:	83 c4 24             	add    $0x24,%esp
  80182b:	5b                   	pop    %ebx
  80182c:	5d                   	pop    %ebp
  80182d:	c3                   	ret    

0080182e <seek>:

int
seek(int fdnum, off_t offset)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801834:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183b:	8b 45 08             	mov    0x8(%ebp),%eax
  80183e:	89 04 24             	mov    %eax,(%esp)
  801841:	e8 e4 fb ff ff       	call   80142a <fd_lookup>
  801846:	85 c0                	test   %eax,%eax
  801848:	78 0e                	js     801858 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80184a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80184d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801850:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801853:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801858:	c9                   	leave  
  801859:	c3                   	ret    

0080185a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	53                   	push   %ebx
  80185e:	83 ec 24             	sub    $0x24,%esp
  801861:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801864:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801867:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186b:	89 1c 24             	mov    %ebx,(%esp)
  80186e:	e8 b7 fb ff ff       	call   80142a <fd_lookup>
  801873:	85 c0                	test   %eax,%eax
  801875:	78 61                	js     8018d8 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801877:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801881:	8b 00                	mov    (%eax),%eax
  801883:	89 04 24             	mov    %eax,(%esp)
  801886:	e8 f5 fb ff ff       	call   801480 <dev_lookup>
  80188b:	85 c0                	test   %eax,%eax
  80188d:	78 49                	js     8018d8 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80188f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801892:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801896:	75 23                	jne    8018bb <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801898:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80189d:	8b 40 48             	mov    0x48(%eax),%eax
  8018a0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a8:	c7 04 24 b0 2e 80 00 	movl   $0x802eb0,(%esp)
  8018af:	e8 1c ee ff ff       	call   8006d0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018b9:	eb 1d                	jmp    8018d8 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8018bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018be:	8b 52 18             	mov    0x18(%edx),%edx
  8018c1:	85 d2                	test   %edx,%edx
  8018c3:	74 0e                	je     8018d3 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018c8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018cc:	89 04 24             	mov    %eax,(%esp)
  8018cf:	ff d2                	call   *%edx
  8018d1:	eb 05                	jmp    8018d8 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8018d8:	83 c4 24             	add    $0x24,%esp
  8018db:	5b                   	pop    %ebx
  8018dc:	5d                   	pop    %ebp
  8018dd:	c3                   	ret    

008018de <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	53                   	push   %ebx
  8018e2:	83 ec 24             	sub    $0x24,%esp
  8018e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f2:	89 04 24             	mov    %eax,(%esp)
  8018f5:	e8 30 fb ff ff       	call   80142a <fd_lookup>
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	78 52                	js     801950 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801901:	89 44 24 04          	mov    %eax,0x4(%esp)
  801905:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801908:	8b 00                	mov    (%eax),%eax
  80190a:	89 04 24             	mov    %eax,(%esp)
  80190d:	e8 6e fb ff ff       	call   801480 <dev_lookup>
  801912:	85 c0                	test   %eax,%eax
  801914:	78 3a                	js     801950 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801916:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801919:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80191d:	74 2c                	je     80194b <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80191f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801922:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801929:	00 00 00 
	stat->st_isdir = 0;
  80192c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801933:	00 00 00 
	stat->st_dev = dev;
  801936:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80193c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801940:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801943:	89 14 24             	mov    %edx,(%esp)
  801946:	ff 50 14             	call   *0x14(%eax)
  801949:	eb 05                	jmp    801950 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80194b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801950:	83 c4 24             	add    $0x24,%esp
  801953:	5b                   	pop    %ebx
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	56                   	push   %esi
  80195a:	53                   	push   %ebx
  80195b:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80195e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801965:	00 
  801966:	8b 45 08             	mov    0x8(%ebp),%eax
  801969:	89 04 24             	mov    %eax,(%esp)
  80196c:	e8 2a 02 00 00       	call   801b9b <open>
  801971:	89 c3                	mov    %eax,%ebx
  801973:	85 c0                	test   %eax,%eax
  801975:	78 1b                	js     801992 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197e:	89 1c 24             	mov    %ebx,(%esp)
  801981:	e8 58 ff ff ff       	call   8018de <fstat>
  801986:	89 c6                	mov    %eax,%esi
	close(fd);
  801988:	89 1c 24             	mov    %ebx,(%esp)
  80198b:	e8 d2 fb ff ff       	call   801562 <close>
	return r;
  801990:	89 f3                	mov    %esi,%ebx
}
  801992:	89 d8                	mov    %ebx,%eax
  801994:	83 c4 10             	add    $0x10,%esp
  801997:	5b                   	pop    %ebx
  801998:	5e                   	pop    %esi
  801999:	5d                   	pop    %ebp
  80199a:	c3                   	ret    
	...

0080199c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80199c:	55                   	push   %ebp
  80199d:	89 e5                	mov    %esp,%ebp
  80199f:	56                   	push   %esi
  8019a0:	53                   	push   %ebx
  8019a1:	83 ec 10             	sub    $0x10,%esp
  8019a4:	89 c3                	mov    %eax,%ebx
  8019a6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8019a8:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  8019af:	75 11                	jne    8019c2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019b1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8019b8:	e8 86 0d 00 00       	call   802743 <ipc_find_env>
  8019bd:	a3 ac 40 80 00       	mov    %eax,0x8040ac
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019c2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8019c9:	00 
  8019ca:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8019d1:	00 
  8019d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019d6:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  8019db:	89 04 24             	mov    %eax,(%esp)
  8019de:	e8 dd 0c 00 00       	call   8026c0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019ea:	00 
  8019eb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019f6:	e8 55 0c 00 00       	call   802650 <ipc_recv>
}
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	5b                   	pop    %ebx
  8019ff:	5e                   	pop    %esi
  801a00:	5d                   	pop    %ebp
  801a01:	c3                   	ret    

00801a02 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a02:	55                   	push   %ebp
  801a03:	89 e5                	mov    %esp,%ebp
  801a05:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a08:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a16:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a20:	b8 02 00 00 00       	mov    $0x2,%eax
  801a25:	e8 72 ff ff ff       	call   80199c <fsipc>
}
  801a2a:	c9                   	leave  
  801a2b:	c3                   	ret    

00801a2c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a32:	8b 45 08             	mov    0x8(%ebp),%eax
  801a35:	8b 40 0c             	mov    0xc(%eax),%eax
  801a38:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a3d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a42:	b8 06 00 00 00       	mov    $0x6,%eax
  801a47:	e8 50 ff ff ff       	call   80199c <fsipc>
}
  801a4c:	c9                   	leave  
  801a4d:	c3                   	ret    

00801a4e <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	53                   	push   %ebx
  801a52:	83 ec 14             	sub    $0x14,%esp
  801a55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a58:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5e:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a63:	ba 00 00 00 00       	mov    $0x0,%edx
  801a68:	b8 05 00 00 00       	mov    $0x5,%eax
  801a6d:	e8 2a ff ff ff       	call   80199c <fsipc>
  801a72:	85 c0                	test   %eax,%eax
  801a74:	78 2b                	js     801aa1 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a76:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a7d:	00 
  801a7e:	89 1c 24             	mov    %ebx,(%esp)
  801a81:	e8 f5 f1 ff ff       	call   800c7b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a86:	a1 80 50 80 00       	mov    0x805080,%eax
  801a8b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a91:	a1 84 50 80 00       	mov    0x805084,%eax
  801a96:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a9c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aa1:	83 c4 14             	add    $0x14,%esp
  801aa4:	5b                   	pop    %ebx
  801aa5:	5d                   	pop    %ebp
  801aa6:	c3                   	ret    

00801aa7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	83 ec 18             	sub    $0x18,%esp
  801aad:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801ab0:	8b 55 08             	mov    0x8(%ebp),%edx
  801ab3:	8b 52 0c             	mov    0xc(%edx),%edx
  801ab6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801abc:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801ac1:	89 c2                	mov    %eax,%edx
  801ac3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ac8:	76 05                	jbe    801acf <devfile_write+0x28>
  801aca:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801acf:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ada:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801ae1:	e8 78 f3 ff ff       	call   800e5e <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801ae6:	ba 00 00 00 00       	mov    $0x0,%edx
  801aeb:	b8 04 00 00 00       	mov    $0x4,%eax
  801af0:	e8 a7 fe ff ff       	call   80199c <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    

00801af7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	56                   	push   %esi
  801afb:	53                   	push   %ebx
  801afc:	83 ec 10             	sub    $0x10,%esp
  801aff:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b02:	8b 45 08             	mov    0x8(%ebp),%eax
  801b05:	8b 40 0c             	mov    0xc(%eax),%eax
  801b08:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b0d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b13:	ba 00 00 00 00       	mov    $0x0,%edx
  801b18:	b8 03 00 00 00       	mov    $0x3,%eax
  801b1d:	e8 7a fe ff ff       	call   80199c <fsipc>
  801b22:	89 c3                	mov    %eax,%ebx
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 6a                	js     801b92 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b28:	39 c6                	cmp    %eax,%esi
  801b2a:	73 24                	jae    801b50 <devfile_read+0x59>
  801b2c:	c7 44 24 0c 24 2f 80 	movl   $0x802f24,0xc(%esp)
  801b33:	00 
  801b34:	c7 44 24 08 2b 2f 80 	movl   $0x802f2b,0x8(%esp)
  801b3b:	00 
  801b3c:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801b43:	00 
  801b44:	c7 04 24 40 2f 80 00 	movl   $0x802f40,(%esp)
  801b4b:	e8 88 ea ff ff       	call   8005d8 <_panic>
	assert(r <= PGSIZE);
  801b50:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b55:	7e 24                	jle    801b7b <devfile_read+0x84>
  801b57:	c7 44 24 0c 4b 2f 80 	movl   $0x802f4b,0xc(%esp)
  801b5e:	00 
  801b5f:	c7 44 24 08 2b 2f 80 	movl   $0x802f2b,0x8(%esp)
  801b66:	00 
  801b67:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801b6e:	00 
  801b6f:	c7 04 24 40 2f 80 00 	movl   $0x802f40,(%esp)
  801b76:	e8 5d ea ff ff       	call   8005d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b7f:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b86:	00 
  801b87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b8a:	89 04 24             	mov    %eax,(%esp)
  801b8d:	e8 62 f2 ff ff       	call   800df4 <memmove>
	return r;
}
  801b92:	89 d8                	mov    %ebx,%eax
  801b94:	83 c4 10             	add    $0x10,%esp
  801b97:	5b                   	pop    %ebx
  801b98:	5e                   	pop    %esi
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    

00801b9b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	56                   	push   %esi
  801b9f:	53                   	push   %ebx
  801ba0:	83 ec 20             	sub    $0x20,%esp
  801ba3:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801ba6:	89 34 24             	mov    %esi,(%esp)
  801ba9:	e8 9a f0 ff ff       	call   800c48 <strlen>
  801bae:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bb3:	7f 60                	jg     801c15 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801bb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb8:	89 04 24             	mov    %eax,(%esp)
  801bbb:	e8 17 f8 ff ff       	call   8013d7 <fd_alloc>
  801bc0:	89 c3                	mov    %eax,%ebx
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	78 54                	js     801c1a <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801bc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bca:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801bd1:	e8 a5 f0 ff ff       	call   800c7b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801bde:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801be1:	b8 01 00 00 00       	mov    $0x1,%eax
  801be6:	e8 b1 fd ff ff       	call   80199c <fsipc>
  801beb:	89 c3                	mov    %eax,%ebx
  801bed:	85 c0                	test   %eax,%eax
  801bef:	79 15                	jns    801c06 <open+0x6b>
		fd_close(fd, 0);
  801bf1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bf8:	00 
  801bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfc:	89 04 24             	mov    %eax,(%esp)
  801bff:	e8 d6 f8 ff ff       	call   8014da <fd_close>
		return r;
  801c04:	eb 14                	jmp    801c1a <open+0x7f>
	}

	return fd2num(fd);
  801c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c09:	89 04 24             	mov    %eax,(%esp)
  801c0c:	e8 9b f7 ff ff       	call   8013ac <fd2num>
  801c11:	89 c3                	mov    %eax,%ebx
  801c13:	eb 05                	jmp    801c1a <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c15:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c1a:	89 d8                	mov    %ebx,%eax
  801c1c:	83 c4 20             	add    $0x20,%esp
  801c1f:	5b                   	pop    %ebx
  801c20:	5e                   	pop    %esi
  801c21:	5d                   	pop    %ebp
  801c22:	c3                   	ret    

00801c23 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c29:	ba 00 00 00 00       	mov    $0x0,%edx
  801c2e:	b8 08 00 00 00       	mov    $0x8,%eax
  801c33:	e8 64 fd ff ff       	call   80199c <fsipc>
}
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    
	...

00801c3c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c3c:	55                   	push   %ebp
  801c3d:	89 e5                	mov    %esp,%ebp
  801c3f:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801c42:	c7 44 24 04 57 2f 80 	movl   $0x802f57,0x4(%esp)
  801c49:	00 
  801c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4d:	89 04 24             	mov    %eax,(%esp)
  801c50:	e8 26 f0 ff ff       	call   800c7b <strcpy>
	return 0;
}
  801c55:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	53                   	push   %ebx
  801c60:	83 ec 14             	sub    $0x14,%esp
  801c63:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801c66:	89 1c 24             	mov    %ebx,(%esp)
  801c69:	e8 1a 0b 00 00       	call   802788 <pageref>
  801c6e:	83 f8 01             	cmp    $0x1,%eax
  801c71:	75 0d                	jne    801c80 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801c73:	8b 43 0c             	mov    0xc(%ebx),%eax
  801c76:	89 04 24             	mov    %eax,(%esp)
  801c79:	e8 1f 03 00 00       	call   801f9d <nsipc_close>
  801c7e:	eb 05                	jmp    801c85 <devsock_close+0x29>
	else
		return 0;
  801c80:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c85:	83 c4 14             	add    $0x14,%esp
  801c88:	5b                   	pop    %ebx
  801c89:	5d                   	pop    %ebp
  801c8a:	c3                   	ret    

00801c8b <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c8b:	55                   	push   %ebp
  801c8c:	89 e5                	mov    %esp,%ebp
  801c8e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c91:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c98:	00 
  801c99:	8b 45 10             	mov    0x10(%ebp),%eax
  801c9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ca0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  801caa:	8b 40 0c             	mov    0xc(%eax),%eax
  801cad:	89 04 24             	mov    %eax,(%esp)
  801cb0:	e8 e3 03 00 00       	call   802098 <nsipc_send>
}
  801cb5:	c9                   	leave  
  801cb6:	c3                   	ret    

00801cb7 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801cbd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801cc4:	00 
  801cc5:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ccc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ccf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd6:	8b 40 0c             	mov    0xc(%eax),%eax
  801cd9:	89 04 24             	mov    %eax,(%esp)
  801cdc:	e8 37 03 00 00       	call   802018 <nsipc_recv>
}
  801ce1:	c9                   	leave  
  801ce2:	c3                   	ret    

00801ce3 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	56                   	push   %esi
  801ce7:	53                   	push   %ebx
  801ce8:	83 ec 20             	sub    $0x20,%esp
  801ceb:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ced:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf0:	89 04 24             	mov    %eax,(%esp)
  801cf3:	e8 df f6 ff ff       	call   8013d7 <fd_alloc>
  801cf8:	89 c3                	mov    %eax,%ebx
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	78 21                	js     801d1f <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801cfe:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d05:	00 
  801d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d14:	e8 54 f3 ff ff       	call   80106d <sys_page_alloc>
  801d19:	89 c3                	mov    %eax,%ebx
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	79 0a                	jns    801d29 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801d1f:	89 34 24             	mov    %esi,(%esp)
  801d22:	e8 76 02 00 00       	call   801f9d <nsipc_close>
		return r;
  801d27:	eb 22                	jmp    801d4b <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d29:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d32:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d37:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801d3e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801d41:	89 04 24             	mov    %eax,(%esp)
  801d44:	e8 63 f6 ff ff       	call   8013ac <fd2num>
  801d49:	89 c3                	mov    %eax,%ebx
}
  801d4b:	89 d8                	mov    %ebx,%eax
  801d4d:	83 c4 20             	add    $0x20,%esp
  801d50:	5b                   	pop    %ebx
  801d51:	5e                   	pop    %esi
  801d52:	5d                   	pop    %ebp
  801d53:	c3                   	ret    

00801d54 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d5a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d5d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d61:	89 04 24             	mov    %eax,(%esp)
  801d64:	e8 c1 f6 ff ff       	call   80142a <fd_lookup>
  801d69:	85 c0                	test   %eax,%eax
  801d6b:	78 17                	js     801d84 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d70:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801d76:	39 10                	cmp    %edx,(%eax)
  801d78:	75 05                	jne    801d7f <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d7a:	8b 40 0c             	mov    0xc(%eax),%eax
  801d7d:	eb 05                	jmp    801d84 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d7f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d84:	c9                   	leave  
  801d85:	c3                   	ret    

00801d86 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8f:	e8 c0 ff ff ff       	call   801d54 <fd2sockid>
  801d94:	85 c0                	test   %eax,%eax
  801d96:	78 1f                	js     801db7 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d98:	8b 55 10             	mov    0x10(%ebp),%edx
  801d9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801da2:	89 54 24 04          	mov    %edx,0x4(%esp)
  801da6:	89 04 24             	mov    %eax,(%esp)
  801da9:	e8 38 01 00 00       	call   801ee6 <nsipc_accept>
  801dae:	85 c0                	test   %eax,%eax
  801db0:	78 05                	js     801db7 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801db2:	e8 2c ff ff ff       	call   801ce3 <alloc_sockfd>
}
  801db7:	c9                   	leave  
  801db8:	c3                   	ret    

00801db9 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc2:	e8 8d ff ff ff       	call   801d54 <fd2sockid>
  801dc7:	85 c0                	test   %eax,%eax
  801dc9:	78 16                	js     801de1 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801dcb:	8b 55 10             	mov    0x10(%ebp),%edx
  801dce:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dd2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dd9:	89 04 24             	mov    %eax,(%esp)
  801ddc:	e8 5b 01 00 00       	call   801f3c <nsipc_bind>
}
  801de1:	c9                   	leave  
  801de2:	c3                   	ret    

00801de3 <shutdown>:

int
shutdown(int s, int how)
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801de9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dec:	e8 63 ff ff ff       	call   801d54 <fd2sockid>
  801df1:	85 c0                	test   %eax,%eax
  801df3:	78 0f                	js     801e04 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801df5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df8:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dfc:	89 04 24             	mov    %eax,(%esp)
  801dff:	e8 77 01 00 00       	call   801f7b <nsipc_shutdown>
}
  801e04:	c9                   	leave  
  801e05:	c3                   	ret    

00801e06 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e06:	55                   	push   %ebp
  801e07:	89 e5                	mov    %esp,%ebp
  801e09:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0f:	e8 40 ff ff ff       	call   801d54 <fd2sockid>
  801e14:	85 c0                	test   %eax,%eax
  801e16:	78 16                	js     801e2e <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801e18:	8b 55 10             	mov    0x10(%ebp),%edx
  801e1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e1f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e22:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e26:	89 04 24             	mov    %eax,(%esp)
  801e29:	e8 89 01 00 00       	call   801fb7 <nsipc_connect>
}
  801e2e:	c9                   	leave  
  801e2f:	c3                   	ret    

00801e30 <listen>:

int
listen(int s, int backlog)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e36:	8b 45 08             	mov    0x8(%ebp),%eax
  801e39:	e8 16 ff ff ff       	call   801d54 <fd2sockid>
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	78 0f                	js     801e51 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e42:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e45:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e49:	89 04 24             	mov    %eax,(%esp)
  801e4c:	e8 a5 01 00 00       	call   801ff6 <nsipc_listen>
}
  801e51:	c9                   	leave  
  801e52:	c3                   	ret    

00801e53 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e59:	8b 45 10             	mov    0x10(%ebp),%eax
  801e5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e67:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6a:	89 04 24             	mov    %eax,(%esp)
  801e6d:	e8 99 02 00 00       	call   80210b <nsipc_socket>
  801e72:	85 c0                	test   %eax,%eax
  801e74:	78 05                	js     801e7b <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801e76:	e8 68 fe ff ff       	call   801ce3 <alloc_sockfd>
}
  801e7b:	c9                   	leave  
  801e7c:	c3                   	ret    
  801e7d:	00 00                	add    %al,(%eax)
	...

00801e80 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	53                   	push   %ebx
  801e84:	83 ec 14             	sub    $0x14,%esp
  801e87:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801e89:	83 3d b0 40 80 00 00 	cmpl   $0x0,0x8040b0
  801e90:	75 11                	jne    801ea3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801e92:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801e99:	e8 a5 08 00 00       	call   802743 <ipc_find_env>
  801e9e:	a3 b0 40 80 00       	mov    %eax,0x8040b0
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ea3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801eaa:	00 
  801eab:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801eb2:	00 
  801eb3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eb7:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801ebc:	89 04 24             	mov    %eax,(%esp)
  801ebf:	e8 fc 07 00 00       	call   8026c0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ec4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ecb:	00 
  801ecc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ed3:	00 
  801ed4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801edb:	e8 70 07 00 00       	call   802650 <ipc_recv>
}
  801ee0:	83 c4 14             	add    $0x14,%esp
  801ee3:	5b                   	pop    %ebx
  801ee4:	5d                   	pop    %ebp
  801ee5:	c3                   	ret    

00801ee6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	56                   	push   %esi
  801eea:	53                   	push   %ebx
  801eeb:	83 ec 10             	sub    $0x10,%esp
  801eee:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ef1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ef9:	8b 06                	mov    (%esi),%eax
  801efb:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f00:	b8 01 00 00 00       	mov    $0x1,%eax
  801f05:	e8 76 ff ff ff       	call   801e80 <nsipc>
  801f0a:	89 c3                	mov    %eax,%ebx
  801f0c:	85 c0                	test   %eax,%eax
  801f0e:	78 23                	js     801f33 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f10:	a1 10 60 80 00       	mov    0x806010,%eax
  801f15:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f19:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f20:	00 
  801f21:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f24:	89 04 24             	mov    %eax,(%esp)
  801f27:	e8 c8 ee ff ff       	call   800df4 <memmove>
		*addrlen = ret->ret_addrlen;
  801f2c:	a1 10 60 80 00       	mov    0x806010,%eax
  801f31:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801f33:	89 d8                	mov    %ebx,%eax
  801f35:	83 c4 10             	add    $0x10,%esp
  801f38:	5b                   	pop    %ebx
  801f39:	5e                   	pop    %esi
  801f3a:	5d                   	pop    %ebp
  801f3b:	c3                   	ret    

00801f3c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	53                   	push   %ebx
  801f40:	83 ec 14             	sub    $0x14,%esp
  801f43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f46:	8b 45 08             	mov    0x8(%ebp),%eax
  801f49:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f59:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f60:	e8 8f ee ff ff       	call   800df4 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f65:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f6b:	b8 02 00 00 00       	mov    $0x2,%eax
  801f70:	e8 0b ff ff ff       	call   801e80 <nsipc>
}
  801f75:	83 c4 14             	add    $0x14,%esp
  801f78:	5b                   	pop    %ebx
  801f79:	5d                   	pop    %ebp
  801f7a:	c3                   	ret    

00801f7b <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f81:	8b 45 08             	mov    0x8(%ebp),%eax
  801f84:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801f89:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8c:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801f91:	b8 03 00 00 00       	mov    $0x3,%eax
  801f96:	e8 e5 fe ff ff       	call   801e80 <nsipc>
}
  801f9b:	c9                   	leave  
  801f9c:	c3                   	ret    

00801f9d <nsipc_close>:

int
nsipc_close(int s)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa6:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801fab:	b8 04 00 00 00       	mov    $0x4,%eax
  801fb0:	e8 cb fe ff ff       	call   801e80 <nsipc>
}
  801fb5:	c9                   	leave  
  801fb6:	c3                   	ret    

00801fb7 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	53                   	push   %ebx
  801fbb:	83 ec 14             	sub    $0x14,%esp
  801fbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd4:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801fdb:	e8 14 ee ff ff       	call   800df4 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fe0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801fe6:	b8 05 00 00 00       	mov    $0x5,%eax
  801feb:	e8 90 fe ff ff       	call   801e80 <nsipc>
}
  801ff0:	83 c4 14             	add    $0x14,%esp
  801ff3:	5b                   	pop    %ebx
  801ff4:	5d                   	pop    %ebp
  801ff5:	c3                   	ret    

00801ff6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801ff6:	55                   	push   %ebp
  801ff7:	89 e5                	mov    %esp,%ebp
  801ff9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ffc:	8b 45 08             	mov    0x8(%ebp),%eax
  801fff:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  802004:	8b 45 0c             	mov    0xc(%ebp),%eax
  802007:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  80200c:	b8 06 00 00 00       	mov    $0x6,%eax
  802011:	e8 6a fe ff ff       	call   801e80 <nsipc>
}
  802016:	c9                   	leave  
  802017:	c3                   	ret    

00802018 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802018:	55                   	push   %ebp
  802019:	89 e5                	mov    %esp,%ebp
  80201b:	56                   	push   %esi
  80201c:	53                   	push   %ebx
  80201d:	83 ec 10             	sub    $0x10,%esp
  802020:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802023:	8b 45 08             	mov    0x8(%ebp),%eax
  802026:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  80202b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  802031:	8b 45 14             	mov    0x14(%ebp),%eax
  802034:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802039:	b8 07 00 00 00       	mov    $0x7,%eax
  80203e:	e8 3d fe ff ff       	call   801e80 <nsipc>
  802043:	89 c3                	mov    %eax,%ebx
  802045:	85 c0                	test   %eax,%eax
  802047:	78 46                	js     80208f <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802049:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80204e:	7f 04                	jg     802054 <nsipc_recv+0x3c>
  802050:	39 c6                	cmp    %eax,%esi
  802052:	7d 24                	jge    802078 <nsipc_recv+0x60>
  802054:	c7 44 24 0c 63 2f 80 	movl   $0x802f63,0xc(%esp)
  80205b:	00 
  80205c:	c7 44 24 08 2b 2f 80 	movl   $0x802f2b,0x8(%esp)
  802063:	00 
  802064:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  80206b:	00 
  80206c:	c7 04 24 78 2f 80 00 	movl   $0x802f78,(%esp)
  802073:	e8 60 e5 ff ff       	call   8005d8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802078:	89 44 24 08          	mov    %eax,0x8(%esp)
  80207c:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802083:	00 
  802084:	8b 45 0c             	mov    0xc(%ebp),%eax
  802087:	89 04 24             	mov    %eax,(%esp)
  80208a:	e8 65 ed ff ff       	call   800df4 <memmove>
	}

	return r;
}
  80208f:	89 d8                	mov    %ebx,%eax
  802091:	83 c4 10             	add    $0x10,%esp
  802094:	5b                   	pop    %ebx
  802095:	5e                   	pop    %esi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    

00802098 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	53                   	push   %ebx
  80209c:	83 ec 14             	sub    $0x14,%esp
  80209f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8020a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a5:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8020aa:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8020b0:	7e 24                	jle    8020d6 <nsipc_send+0x3e>
  8020b2:	c7 44 24 0c 84 2f 80 	movl   $0x802f84,0xc(%esp)
  8020b9:	00 
  8020ba:	c7 44 24 08 2b 2f 80 	movl   $0x802f2b,0x8(%esp)
  8020c1:	00 
  8020c2:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  8020c9:	00 
  8020ca:	c7 04 24 78 2f 80 00 	movl   $0x802f78,(%esp)
  8020d1:	e8 02 e5 ff ff       	call   8005d8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020e1:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8020e8:	e8 07 ed ff ff       	call   800df4 <memmove>
	nsipcbuf.send.req_size = size;
  8020ed:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8020f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8020f6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8020fb:	b8 08 00 00 00       	mov    $0x8,%eax
  802100:	e8 7b fd ff ff       	call   801e80 <nsipc>
}
  802105:	83 c4 14             	add    $0x14,%esp
  802108:	5b                   	pop    %ebx
  802109:	5d                   	pop    %ebp
  80210a:	c3                   	ret    

0080210b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80210b:	55                   	push   %ebp
  80210c:	89 e5                	mov    %esp,%ebp
  80210e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802111:	8b 45 08             	mov    0x8(%ebp),%eax
  802114:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802119:	8b 45 0c             	mov    0xc(%ebp),%eax
  80211c:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802121:	8b 45 10             	mov    0x10(%ebp),%eax
  802124:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802129:	b8 09 00 00 00       	mov    $0x9,%eax
  80212e:	e8 4d fd ff ff       	call   801e80 <nsipc>
}
  802133:	c9                   	leave  
  802134:	c3                   	ret    
  802135:	00 00                	add    %al,(%eax)
	...

00802138 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	56                   	push   %esi
  80213c:	53                   	push   %ebx
  80213d:	83 ec 10             	sub    $0x10,%esp
  802140:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802143:	8b 45 08             	mov    0x8(%ebp),%eax
  802146:	89 04 24             	mov    %eax,(%esp)
  802149:	e8 6e f2 ff ff       	call   8013bc <fd2data>
  80214e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802150:	c7 44 24 04 90 2f 80 	movl   $0x802f90,0x4(%esp)
  802157:	00 
  802158:	89 34 24             	mov    %esi,(%esp)
  80215b:	e8 1b eb ff ff       	call   800c7b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802160:	8b 43 04             	mov    0x4(%ebx),%eax
  802163:	2b 03                	sub    (%ebx),%eax
  802165:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80216b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802172:	00 00 00 
	stat->st_dev = &devpipe;
  802175:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  80217c:	30 80 00 
	return 0;
}
  80217f:	b8 00 00 00 00       	mov    $0x0,%eax
  802184:	83 c4 10             	add    $0x10,%esp
  802187:	5b                   	pop    %ebx
  802188:	5e                   	pop    %esi
  802189:	5d                   	pop    %ebp
  80218a:	c3                   	ret    

0080218b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80218b:	55                   	push   %ebp
  80218c:	89 e5                	mov    %esp,%ebp
  80218e:	53                   	push   %ebx
  80218f:	83 ec 14             	sub    $0x14,%esp
  802192:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802195:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802199:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a0:	e8 6f ef ff ff       	call   801114 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8021a5:	89 1c 24             	mov    %ebx,(%esp)
  8021a8:	e8 0f f2 ff ff       	call   8013bc <fd2data>
  8021ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021b8:	e8 57 ef ff ff       	call   801114 <sys_page_unmap>
}
  8021bd:	83 c4 14             	add    $0x14,%esp
  8021c0:	5b                   	pop    %ebx
  8021c1:	5d                   	pop    %ebp
  8021c2:	c3                   	ret    

008021c3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8021c3:	55                   	push   %ebp
  8021c4:	89 e5                	mov    %esp,%ebp
  8021c6:	57                   	push   %edi
  8021c7:	56                   	push   %esi
  8021c8:	53                   	push   %ebx
  8021c9:	83 ec 2c             	sub    $0x2c,%esp
  8021cc:	89 c7                	mov    %eax,%edi
  8021ce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8021d1:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8021d6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8021d9:	89 3c 24             	mov    %edi,(%esp)
  8021dc:	e8 a7 05 00 00       	call   802788 <pageref>
  8021e1:	89 c6                	mov    %eax,%esi
  8021e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021e6:	89 04 24             	mov    %eax,(%esp)
  8021e9:	e8 9a 05 00 00       	call   802788 <pageref>
  8021ee:	39 c6                	cmp    %eax,%esi
  8021f0:	0f 94 c0             	sete   %al
  8021f3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8021f6:	8b 15 b4 40 80 00    	mov    0x8040b4,%edx
  8021fc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8021ff:	39 cb                	cmp    %ecx,%ebx
  802201:	75 08                	jne    80220b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802203:	83 c4 2c             	add    $0x2c,%esp
  802206:	5b                   	pop    %ebx
  802207:	5e                   	pop    %esi
  802208:	5f                   	pop    %edi
  802209:	5d                   	pop    %ebp
  80220a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80220b:	83 f8 01             	cmp    $0x1,%eax
  80220e:	75 c1                	jne    8021d1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802210:	8b 42 58             	mov    0x58(%edx),%eax
  802213:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80221a:	00 
  80221b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80221f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802223:	c7 04 24 97 2f 80 00 	movl   $0x802f97,(%esp)
  80222a:	e8 a1 e4 ff ff       	call   8006d0 <cprintf>
  80222f:	eb a0                	jmp    8021d1 <_pipeisclosed+0xe>

00802231 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802231:	55                   	push   %ebp
  802232:	89 e5                	mov    %esp,%ebp
  802234:	57                   	push   %edi
  802235:	56                   	push   %esi
  802236:	53                   	push   %ebx
  802237:	83 ec 1c             	sub    $0x1c,%esp
  80223a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80223d:	89 34 24             	mov    %esi,(%esp)
  802240:	e8 77 f1 ff ff       	call   8013bc <fd2data>
  802245:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802247:	bf 00 00 00 00       	mov    $0x0,%edi
  80224c:	eb 3c                	jmp    80228a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80224e:	89 da                	mov    %ebx,%edx
  802250:	89 f0                	mov    %esi,%eax
  802252:	e8 6c ff ff ff       	call   8021c3 <_pipeisclosed>
  802257:	85 c0                	test   %eax,%eax
  802259:	75 38                	jne    802293 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80225b:	e8 ee ed ff ff       	call   80104e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802260:	8b 43 04             	mov    0x4(%ebx),%eax
  802263:	8b 13                	mov    (%ebx),%edx
  802265:	83 c2 20             	add    $0x20,%edx
  802268:	39 d0                	cmp    %edx,%eax
  80226a:	73 e2                	jae    80224e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80226c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80226f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802272:	89 c2                	mov    %eax,%edx
  802274:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80227a:	79 05                	jns    802281 <devpipe_write+0x50>
  80227c:	4a                   	dec    %edx
  80227d:	83 ca e0             	or     $0xffffffe0,%edx
  802280:	42                   	inc    %edx
  802281:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802285:	40                   	inc    %eax
  802286:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802289:	47                   	inc    %edi
  80228a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80228d:	75 d1                	jne    802260 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80228f:	89 f8                	mov    %edi,%eax
  802291:	eb 05                	jmp    802298 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802293:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802298:	83 c4 1c             	add    $0x1c,%esp
  80229b:	5b                   	pop    %ebx
  80229c:	5e                   	pop    %esi
  80229d:	5f                   	pop    %edi
  80229e:	5d                   	pop    %ebp
  80229f:	c3                   	ret    

008022a0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022a0:	55                   	push   %ebp
  8022a1:	89 e5                	mov    %esp,%ebp
  8022a3:	57                   	push   %edi
  8022a4:	56                   	push   %esi
  8022a5:	53                   	push   %ebx
  8022a6:	83 ec 1c             	sub    $0x1c,%esp
  8022a9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8022ac:	89 3c 24             	mov    %edi,(%esp)
  8022af:	e8 08 f1 ff ff       	call   8013bc <fd2data>
  8022b4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022b6:	be 00 00 00 00       	mov    $0x0,%esi
  8022bb:	eb 3a                	jmp    8022f7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8022bd:	85 f6                	test   %esi,%esi
  8022bf:	74 04                	je     8022c5 <devpipe_read+0x25>
				return i;
  8022c1:	89 f0                	mov    %esi,%eax
  8022c3:	eb 40                	jmp    802305 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8022c5:	89 da                	mov    %ebx,%edx
  8022c7:	89 f8                	mov    %edi,%eax
  8022c9:	e8 f5 fe ff ff       	call   8021c3 <_pipeisclosed>
  8022ce:	85 c0                	test   %eax,%eax
  8022d0:	75 2e                	jne    802300 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8022d2:	e8 77 ed ff ff       	call   80104e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8022d7:	8b 03                	mov    (%ebx),%eax
  8022d9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8022dc:	74 df                	je     8022bd <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022de:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8022e3:	79 05                	jns    8022ea <devpipe_read+0x4a>
  8022e5:	48                   	dec    %eax
  8022e6:	83 c8 e0             	or     $0xffffffe0,%eax
  8022e9:	40                   	inc    %eax
  8022ea:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8022ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022f1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8022f4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022f6:	46                   	inc    %esi
  8022f7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022fa:	75 db                	jne    8022d7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022fc:	89 f0                	mov    %esi,%eax
  8022fe:	eb 05                	jmp    802305 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802300:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802305:	83 c4 1c             	add    $0x1c,%esp
  802308:	5b                   	pop    %ebx
  802309:	5e                   	pop    %esi
  80230a:	5f                   	pop    %edi
  80230b:	5d                   	pop    %ebp
  80230c:	c3                   	ret    

0080230d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80230d:	55                   	push   %ebp
  80230e:	89 e5                	mov    %esp,%ebp
  802310:	57                   	push   %edi
  802311:	56                   	push   %esi
  802312:	53                   	push   %ebx
  802313:	83 ec 3c             	sub    $0x3c,%esp
  802316:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802319:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80231c:	89 04 24             	mov    %eax,(%esp)
  80231f:	e8 b3 f0 ff ff       	call   8013d7 <fd_alloc>
  802324:	89 c3                	mov    %eax,%ebx
  802326:	85 c0                	test   %eax,%eax
  802328:	0f 88 45 01 00 00    	js     802473 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80232e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802335:	00 
  802336:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802339:	89 44 24 04          	mov    %eax,0x4(%esp)
  80233d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802344:	e8 24 ed ff ff       	call   80106d <sys_page_alloc>
  802349:	89 c3                	mov    %eax,%ebx
  80234b:	85 c0                	test   %eax,%eax
  80234d:	0f 88 20 01 00 00    	js     802473 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802353:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802356:	89 04 24             	mov    %eax,(%esp)
  802359:	e8 79 f0 ff ff       	call   8013d7 <fd_alloc>
  80235e:	89 c3                	mov    %eax,%ebx
  802360:	85 c0                	test   %eax,%eax
  802362:	0f 88 f8 00 00 00    	js     802460 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802368:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80236f:	00 
  802370:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802373:	89 44 24 04          	mov    %eax,0x4(%esp)
  802377:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80237e:	e8 ea ec ff ff       	call   80106d <sys_page_alloc>
  802383:	89 c3                	mov    %eax,%ebx
  802385:	85 c0                	test   %eax,%eax
  802387:	0f 88 d3 00 00 00    	js     802460 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80238d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802390:	89 04 24             	mov    %eax,(%esp)
  802393:	e8 24 f0 ff ff       	call   8013bc <fd2data>
  802398:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80239a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8023a1:	00 
  8023a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ad:	e8 bb ec ff ff       	call   80106d <sys_page_alloc>
  8023b2:	89 c3                	mov    %eax,%ebx
  8023b4:	85 c0                	test   %eax,%eax
  8023b6:	0f 88 91 00 00 00    	js     80244d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8023bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8023bf:	89 04 24             	mov    %eax,(%esp)
  8023c2:	e8 f5 ef ff ff       	call   8013bc <fd2data>
  8023c7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8023ce:	00 
  8023cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8023da:	00 
  8023db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023e6:	e8 d6 ec ff ff       	call   8010c1 <sys_page_map>
  8023eb:	89 c3                	mov    %eax,%ebx
  8023ed:	85 c0                	test   %eax,%eax
  8023ef:	78 4c                	js     80243d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8023f1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8023f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023fa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8023fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8023ff:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802406:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80240c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80240f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802411:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802414:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80241b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80241e:	89 04 24             	mov    %eax,(%esp)
  802421:	e8 86 ef ff ff       	call   8013ac <fd2num>
  802426:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802428:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80242b:	89 04 24             	mov    %eax,(%esp)
  80242e:	e8 79 ef ff ff       	call   8013ac <fd2num>
  802433:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802436:	bb 00 00 00 00       	mov    $0x0,%ebx
  80243b:	eb 36                	jmp    802473 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80243d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802441:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802448:	e8 c7 ec ff ff       	call   801114 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80244d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802450:	89 44 24 04          	mov    %eax,0x4(%esp)
  802454:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80245b:	e8 b4 ec ff ff       	call   801114 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802460:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802463:	89 44 24 04          	mov    %eax,0x4(%esp)
  802467:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80246e:	e8 a1 ec ff ff       	call   801114 <sys_page_unmap>
    err:
	return r;
}
  802473:	89 d8                	mov    %ebx,%eax
  802475:	83 c4 3c             	add    $0x3c,%esp
  802478:	5b                   	pop    %ebx
  802479:	5e                   	pop    %esi
  80247a:	5f                   	pop    %edi
  80247b:	5d                   	pop    %ebp
  80247c:	c3                   	ret    

0080247d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80247d:	55                   	push   %ebp
  80247e:	89 e5                	mov    %esp,%ebp
  802480:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802483:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802486:	89 44 24 04          	mov    %eax,0x4(%esp)
  80248a:	8b 45 08             	mov    0x8(%ebp),%eax
  80248d:	89 04 24             	mov    %eax,(%esp)
  802490:	e8 95 ef ff ff       	call   80142a <fd_lookup>
  802495:	85 c0                	test   %eax,%eax
  802497:	78 15                	js     8024ae <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802499:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80249c:	89 04 24             	mov    %eax,(%esp)
  80249f:	e8 18 ef ff ff       	call   8013bc <fd2data>
	return _pipeisclosed(fd, p);
  8024a4:	89 c2                	mov    %eax,%edx
  8024a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024a9:	e8 15 fd ff ff       	call   8021c3 <_pipeisclosed>
}
  8024ae:	c9                   	leave  
  8024af:	c3                   	ret    

008024b0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8024b0:	55                   	push   %ebp
  8024b1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8024b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8024b8:	5d                   	pop    %ebp
  8024b9:	c3                   	ret    

008024ba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8024ba:	55                   	push   %ebp
  8024bb:	89 e5                	mov    %esp,%ebp
  8024bd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8024c0:	c7 44 24 04 af 2f 80 	movl   $0x802faf,0x4(%esp)
  8024c7:	00 
  8024c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024cb:	89 04 24             	mov    %eax,(%esp)
  8024ce:	e8 a8 e7 ff ff       	call   800c7b <strcpy>
	return 0;
}
  8024d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8024d8:	c9                   	leave  
  8024d9:	c3                   	ret    

008024da <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024da:	55                   	push   %ebp
  8024db:	89 e5                	mov    %esp,%ebp
  8024dd:	57                   	push   %edi
  8024de:	56                   	push   %esi
  8024df:	53                   	push   %ebx
  8024e0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024e6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024eb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024f1:	eb 30                	jmp    802523 <devcons_write+0x49>
		m = n - tot;
  8024f3:	8b 75 10             	mov    0x10(%ebp),%esi
  8024f6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8024f8:	83 fe 7f             	cmp    $0x7f,%esi
  8024fb:	76 05                	jbe    802502 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8024fd:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802502:	89 74 24 08          	mov    %esi,0x8(%esp)
  802506:	03 45 0c             	add    0xc(%ebp),%eax
  802509:	89 44 24 04          	mov    %eax,0x4(%esp)
  80250d:	89 3c 24             	mov    %edi,(%esp)
  802510:	e8 df e8 ff ff       	call   800df4 <memmove>
		sys_cputs(buf, m);
  802515:	89 74 24 04          	mov    %esi,0x4(%esp)
  802519:	89 3c 24             	mov    %edi,(%esp)
  80251c:	e8 7f ea ff ff       	call   800fa0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802521:	01 f3                	add    %esi,%ebx
  802523:	89 d8                	mov    %ebx,%eax
  802525:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802528:	72 c9                	jb     8024f3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80252a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802530:	5b                   	pop    %ebx
  802531:	5e                   	pop    %esi
  802532:	5f                   	pop    %edi
  802533:	5d                   	pop    %ebp
  802534:	c3                   	ret    

00802535 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802535:	55                   	push   %ebp
  802536:	89 e5                	mov    %esp,%ebp
  802538:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80253b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80253f:	75 07                	jne    802548 <devcons_read+0x13>
  802541:	eb 25                	jmp    802568 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802543:	e8 06 eb ff ff       	call   80104e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802548:	e8 71 ea ff ff       	call   800fbe <sys_cgetc>
  80254d:	85 c0                	test   %eax,%eax
  80254f:	74 f2                	je     802543 <devcons_read+0xe>
  802551:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802553:	85 c0                	test   %eax,%eax
  802555:	78 1d                	js     802574 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802557:	83 f8 04             	cmp    $0x4,%eax
  80255a:	74 13                	je     80256f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80255c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80255f:	88 10                	mov    %dl,(%eax)
	return 1;
  802561:	b8 01 00 00 00       	mov    $0x1,%eax
  802566:	eb 0c                	jmp    802574 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802568:	b8 00 00 00 00       	mov    $0x0,%eax
  80256d:	eb 05                	jmp    802574 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80256f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802574:	c9                   	leave  
  802575:	c3                   	ret    

00802576 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802576:	55                   	push   %ebp
  802577:	89 e5                	mov    %esp,%ebp
  802579:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80257c:	8b 45 08             	mov    0x8(%ebp),%eax
  80257f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802582:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802589:	00 
  80258a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80258d:	89 04 24             	mov    %eax,(%esp)
  802590:	e8 0b ea ff ff       	call   800fa0 <sys_cputs>
}
  802595:	c9                   	leave  
  802596:	c3                   	ret    

00802597 <getchar>:

int
getchar(void)
{
  802597:	55                   	push   %ebp
  802598:	89 e5                	mov    %esp,%ebp
  80259a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80259d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8025a4:	00 
  8025a5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8025a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025b3:	e8 10 f1 ff ff       	call   8016c8 <read>
	if (r < 0)
  8025b8:	85 c0                	test   %eax,%eax
  8025ba:	78 0f                	js     8025cb <getchar+0x34>
		return r;
	if (r < 1)
  8025bc:	85 c0                	test   %eax,%eax
  8025be:	7e 06                	jle    8025c6 <getchar+0x2f>
		return -E_EOF;
	return c;
  8025c0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8025c4:	eb 05                	jmp    8025cb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8025c6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8025cb:	c9                   	leave  
  8025cc:	c3                   	ret    

008025cd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8025cd:	55                   	push   %ebp
  8025ce:	89 e5                	mov    %esp,%ebp
  8025d0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8025d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025da:	8b 45 08             	mov    0x8(%ebp),%eax
  8025dd:	89 04 24             	mov    %eax,(%esp)
  8025e0:	e8 45 ee ff ff       	call   80142a <fd_lookup>
  8025e5:	85 c0                	test   %eax,%eax
  8025e7:	78 11                	js     8025fa <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8025e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025ec:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8025f2:	39 10                	cmp    %edx,(%eax)
  8025f4:	0f 94 c0             	sete   %al
  8025f7:	0f b6 c0             	movzbl %al,%eax
}
  8025fa:	c9                   	leave  
  8025fb:	c3                   	ret    

008025fc <opencons>:

int
opencons(void)
{
  8025fc:	55                   	push   %ebp
  8025fd:	89 e5                	mov    %esp,%ebp
  8025ff:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802602:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802605:	89 04 24             	mov    %eax,(%esp)
  802608:	e8 ca ed ff ff       	call   8013d7 <fd_alloc>
  80260d:	85 c0                	test   %eax,%eax
  80260f:	78 3c                	js     80264d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802611:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802618:	00 
  802619:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80261c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802620:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802627:	e8 41 ea ff ff       	call   80106d <sys_page_alloc>
  80262c:	85 c0                	test   %eax,%eax
  80262e:	78 1d                	js     80264d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802630:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802636:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802639:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80263b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80263e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802645:	89 04 24             	mov    %eax,(%esp)
  802648:	e8 5f ed ff ff       	call   8013ac <fd2num>
}
  80264d:	c9                   	leave  
  80264e:	c3                   	ret    
	...

00802650 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802650:	55                   	push   %ebp
  802651:	89 e5                	mov    %esp,%ebp
  802653:	56                   	push   %esi
  802654:	53                   	push   %ebx
  802655:	83 ec 10             	sub    $0x10,%esp
  802658:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80265b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80265e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  802661:	85 c0                	test   %eax,%eax
  802663:	74 0a                	je     80266f <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802665:	89 04 24             	mov    %eax,(%esp)
  802668:	e8 16 ec ff ff       	call   801283 <sys_ipc_recv>
  80266d:	eb 0c                	jmp    80267b <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80266f:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802676:	e8 08 ec ff ff       	call   801283 <sys_ipc_recv>
	}
	if (r < 0)
  80267b:	85 c0                	test   %eax,%eax
  80267d:	79 16                	jns    802695 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  80267f:	85 db                	test   %ebx,%ebx
  802681:	74 06                	je     802689 <ipc_recv+0x39>
  802683:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802689:	85 f6                	test   %esi,%esi
  80268b:	74 2c                	je     8026b9 <ipc_recv+0x69>
  80268d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802693:	eb 24                	jmp    8026b9 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802695:	85 db                	test   %ebx,%ebx
  802697:	74 0a                	je     8026a3 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802699:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  80269e:	8b 40 74             	mov    0x74(%eax),%eax
  8026a1:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  8026a3:	85 f6                	test   %esi,%esi
  8026a5:	74 0a                	je     8026b1 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  8026a7:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8026ac:	8b 40 78             	mov    0x78(%eax),%eax
  8026af:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8026b1:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8026b6:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8026b9:	83 c4 10             	add    $0x10,%esp
  8026bc:	5b                   	pop    %ebx
  8026bd:	5e                   	pop    %esi
  8026be:	5d                   	pop    %ebp
  8026bf:	c3                   	ret    

008026c0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8026c0:	55                   	push   %ebp
  8026c1:	89 e5                	mov    %esp,%ebp
  8026c3:	57                   	push   %edi
  8026c4:	56                   	push   %esi
  8026c5:	53                   	push   %ebx
  8026c6:	83 ec 1c             	sub    $0x1c,%esp
  8026c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8026cc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8026cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8026d2:	85 db                	test   %ebx,%ebx
  8026d4:	74 19                	je     8026ef <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8026d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8026d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026dd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8026e5:	89 34 24             	mov    %esi,(%esp)
  8026e8:	e8 73 eb ff ff       	call   801260 <sys_ipc_try_send>
  8026ed:	eb 1c                	jmp    80270b <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  8026ef:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8026f6:	00 
  8026f7:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8026fe:	ee 
  8026ff:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802703:	89 34 24             	mov    %esi,(%esp)
  802706:	e8 55 eb ff ff       	call   801260 <sys_ipc_try_send>
		}
		if (r == 0)
  80270b:	85 c0                	test   %eax,%eax
  80270d:	74 2c                	je     80273b <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80270f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802712:	74 20                	je     802734 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802714:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802718:	c7 44 24 08 bb 2f 80 	movl   $0x802fbb,0x8(%esp)
  80271f:	00 
  802720:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802727:	00 
  802728:	c7 04 24 ce 2f 80 00 	movl   $0x802fce,(%esp)
  80272f:	e8 a4 de ff ff       	call   8005d8 <_panic>
		}
		sys_yield();
  802734:	e8 15 e9 ff ff       	call   80104e <sys_yield>
	}
  802739:	eb 97                	jmp    8026d2 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  80273b:	83 c4 1c             	add    $0x1c,%esp
  80273e:	5b                   	pop    %ebx
  80273f:	5e                   	pop    %esi
  802740:	5f                   	pop    %edi
  802741:	5d                   	pop    %ebp
  802742:	c3                   	ret    

00802743 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802743:	55                   	push   %ebp
  802744:	89 e5                	mov    %esp,%ebp
  802746:	53                   	push   %ebx
  802747:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80274a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80274f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802756:	89 c2                	mov    %eax,%edx
  802758:	c1 e2 07             	shl    $0x7,%edx
  80275b:	29 ca                	sub    %ecx,%edx
  80275d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802763:	8b 52 50             	mov    0x50(%edx),%edx
  802766:	39 da                	cmp    %ebx,%edx
  802768:	75 0f                	jne    802779 <ipc_find_env+0x36>
			return envs[i].env_id;
  80276a:	c1 e0 07             	shl    $0x7,%eax
  80276d:	29 c8                	sub    %ecx,%eax
  80276f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802774:	8b 40 40             	mov    0x40(%eax),%eax
  802777:	eb 0c                	jmp    802785 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802779:	40                   	inc    %eax
  80277a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80277f:	75 ce                	jne    80274f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802781:	66 b8 00 00          	mov    $0x0,%ax
}
  802785:	5b                   	pop    %ebx
  802786:	5d                   	pop    %ebp
  802787:	c3                   	ret    

00802788 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802788:	55                   	push   %ebp
  802789:	89 e5                	mov    %esp,%ebp
  80278b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80278e:	89 c2                	mov    %eax,%edx
  802790:	c1 ea 16             	shr    $0x16,%edx
  802793:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80279a:	f6 c2 01             	test   $0x1,%dl
  80279d:	74 1e                	je     8027bd <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80279f:	c1 e8 0c             	shr    $0xc,%eax
  8027a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8027a9:	a8 01                	test   $0x1,%al
  8027ab:	74 17                	je     8027c4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8027ad:	c1 e8 0c             	shr    $0xc,%eax
  8027b0:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8027b7:	ef 
  8027b8:	0f b7 c0             	movzwl %ax,%eax
  8027bb:	eb 0c                	jmp    8027c9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8027bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8027c2:	eb 05                	jmp    8027c9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8027c4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8027c9:	5d                   	pop    %ebp
  8027ca:	c3                   	ret    
	...

008027cc <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  8027cc:	55                   	push   %ebp
  8027cd:	57                   	push   %edi
  8027ce:	56                   	push   %esi
  8027cf:	83 ec 10             	sub    $0x10,%esp
  8027d2:	8b 74 24 20          	mov    0x20(%esp),%esi
  8027d6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8027da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027de:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  8027e2:	89 cd                	mov    %ecx,%ebp
  8027e4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8027e8:	85 c0                	test   %eax,%eax
  8027ea:	75 2c                	jne    802818 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  8027ec:	39 f9                	cmp    %edi,%ecx
  8027ee:	77 68                	ja     802858 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8027f0:	85 c9                	test   %ecx,%ecx
  8027f2:	75 0b                	jne    8027ff <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8027f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8027f9:	31 d2                	xor    %edx,%edx
  8027fb:	f7 f1                	div    %ecx
  8027fd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8027ff:	31 d2                	xor    %edx,%edx
  802801:	89 f8                	mov    %edi,%eax
  802803:	f7 f1                	div    %ecx
  802805:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802807:	89 f0                	mov    %esi,%eax
  802809:	f7 f1                	div    %ecx
  80280b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80280d:	89 f0                	mov    %esi,%eax
  80280f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802811:	83 c4 10             	add    $0x10,%esp
  802814:	5e                   	pop    %esi
  802815:	5f                   	pop    %edi
  802816:	5d                   	pop    %ebp
  802817:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802818:	39 f8                	cmp    %edi,%eax
  80281a:	77 2c                	ja     802848 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80281c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80281f:	83 f6 1f             	xor    $0x1f,%esi
  802822:	75 4c                	jne    802870 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802824:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802826:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80282b:	72 0a                	jb     802837 <__udivdi3+0x6b>
  80282d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802831:	0f 87 ad 00 00 00    	ja     8028e4 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802837:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80283c:	89 f0                	mov    %esi,%eax
  80283e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802840:	83 c4 10             	add    $0x10,%esp
  802843:	5e                   	pop    %esi
  802844:	5f                   	pop    %edi
  802845:	5d                   	pop    %ebp
  802846:	c3                   	ret    
  802847:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802848:	31 ff                	xor    %edi,%edi
  80284a:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80284c:	89 f0                	mov    %esi,%eax
  80284e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802850:	83 c4 10             	add    $0x10,%esp
  802853:	5e                   	pop    %esi
  802854:	5f                   	pop    %edi
  802855:	5d                   	pop    %ebp
  802856:	c3                   	ret    
  802857:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802858:	89 fa                	mov    %edi,%edx
  80285a:	89 f0                	mov    %esi,%eax
  80285c:	f7 f1                	div    %ecx
  80285e:	89 c6                	mov    %eax,%esi
  802860:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802862:	89 f0                	mov    %esi,%eax
  802864:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802866:	83 c4 10             	add    $0x10,%esp
  802869:	5e                   	pop    %esi
  80286a:	5f                   	pop    %edi
  80286b:	5d                   	pop    %ebp
  80286c:	c3                   	ret    
  80286d:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802870:	89 f1                	mov    %esi,%ecx
  802872:	d3 e0                	shl    %cl,%eax
  802874:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802878:	b8 20 00 00 00       	mov    $0x20,%eax
  80287d:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  80287f:	89 ea                	mov    %ebp,%edx
  802881:	88 c1                	mov    %al,%cl
  802883:	d3 ea                	shr    %cl,%edx
  802885:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802889:	09 ca                	or     %ecx,%edx
  80288b:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  80288f:	89 f1                	mov    %esi,%ecx
  802891:	d3 e5                	shl    %cl,%ebp
  802893:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802897:	89 fd                	mov    %edi,%ebp
  802899:	88 c1                	mov    %al,%cl
  80289b:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  80289d:	89 fa                	mov    %edi,%edx
  80289f:	89 f1                	mov    %esi,%ecx
  8028a1:	d3 e2                	shl    %cl,%edx
  8028a3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8028a7:	88 c1                	mov    %al,%cl
  8028a9:	d3 ef                	shr    %cl,%edi
  8028ab:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8028ad:	89 f8                	mov    %edi,%eax
  8028af:	89 ea                	mov    %ebp,%edx
  8028b1:	f7 74 24 08          	divl   0x8(%esp)
  8028b5:	89 d1                	mov    %edx,%ecx
  8028b7:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8028b9:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028bd:	39 d1                	cmp    %edx,%ecx
  8028bf:	72 17                	jb     8028d8 <__udivdi3+0x10c>
  8028c1:	74 09                	je     8028cc <__udivdi3+0x100>
  8028c3:	89 fe                	mov    %edi,%esi
  8028c5:	31 ff                	xor    %edi,%edi
  8028c7:	e9 41 ff ff ff       	jmp    80280d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8028cc:	8b 54 24 04          	mov    0x4(%esp),%edx
  8028d0:	89 f1                	mov    %esi,%ecx
  8028d2:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028d4:	39 c2                	cmp    %eax,%edx
  8028d6:	73 eb                	jae    8028c3 <__udivdi3+0xf7>
		{
		  q0--;
  8028d8:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8028db:	31 ff                	xor    %edi,%edi
  8028dd:	e9 2b ff ff ff       	jmp    80280d <__udivdi3+0x41>
  8028e2:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8028e4:	31 f6                	xor    %esi,%esi
  8028e6:	e9 22 ff ff ff       	jmp    80280d <__udivdi3+0x41>
	...

008028ec <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8028ec:	55                   	push   %ebp
  8028ed:	57                   	push   %edi
  8028ee:	56                   	push   %esi
  8028ef:	83 ec 20             	sub    $0x20,%esp
  8028f2:	8b 44 24 30          	mov    0x30(%esp),%eax
  8028f6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8028fa:	89 44 24 14          	mov    %eax,0x14(%esp)
  8028fe:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802902:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802906:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80290a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80290c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80290e:	85 ed                	test   %ebp,%ebp
  802910:	75 16                	jne    802928 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802912:	39 f1                	cmp    %esi,%ecx
  802914:	0f 86 a6 00 00 00    	jbe    8029c0 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80291a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80291c:	89 d0                	mov    %edx,%eax
  80291e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802920:	83 c4 20             	add    $0x20,%esp
  802923:	5e                   	pop    %esi
  802924:	5f                   	pop    %edi
  802925:	5d                   	pop    %ebp
  802926:	c3                   	ret    
  802927:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802928:	39 f5                	cmp    %esi,%ebp
  80292a:	0f 87 ac 00 00 00    	ja     8029dc <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802930:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802933:	83 f0 1f             	xor    $0x1f,%eax
  802936:	89 44 24 10          	mov    %eax,0x10(%esp)
  80293a:	0f 84 a8 00 00 00    	je     8029e8 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802940:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802944:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802946:	bf 20 00 00 00       	mov    $0x20,%edi
  80294b:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80294f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802953:	89 f9                	mov    %edi,%ecx
  802955:	d3 e8                	shr    %cl,%eax
  802957:	09 e8                	or     %ebp,%eax
  802959:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  80295d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802961:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802965:	d3 e0                	shl    %cl,%eax
  802967:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80296b:	89 f2                	mov    %esi,%edx
  80296d:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  80296f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802973:	d3 e0                	shl    %cl,%eax
  802975:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802979:	8b 44 24 14          	mov    0x14(%esp),%eax
  80297d:	89 f9                	mov    %edi,%ecx
  80297f:	d3 e8                	shr    %cl,%eax
  802981:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802983:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802985:	89 f2                	mov    %esi,%edx
  802987:	f7 74 24 18          	divl   0x18(%esp)
  80298b:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  80298d:	f7 64 24 0c          	mull   0xc(%esp)
  802991:	89 c5                	mov    %eax,%ebp
  802993:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802995:	39 d6                	cmp    %edx,%esi
  802997:	72 67                	jb     802a00 <__umoddi3+0x114>
  802999:	74 75                	je     802a10 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80299b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80299f:	29 e8                	sub    %ebp,%eax
  8029a1:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8029a3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8029a7:	d3 e8                	shr    %cl,%eax
  8029a9:	89 f2                	mov    %esi,%edx
  8029ab:	89 f9                	mov    %edi,%ecx
  8029ad:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8029af:	09 d0                	or     %edx,%eax
  8029b1:	89 f2                	mov    %esi,%edx
  8029b3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8029b7:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8029b9:	83 c4 20             	add    $0x20,%esp
  8029bc:	5e                   	pop    %esi
  8029bd:	5f                   	pop    %edi
  8029be:	5d                   	pop    %ebp
  8029bf:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8029c0:	85 c9                	test   %ecx,%ecx
  8029c2:	75 0b                	jne    8029cf <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  8029c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8029c9:	31 d2                	xor    %edx,%edx
  8029cb:	f7 f1                	div    %ecx
  8029cd:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8029cf:	89 f0                	mov    %esi,%eax
  8029d1:	31 d2                	xor    %edx,%edx
  8029d3:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8029d5:	89 f8                	mov    %edi,%eax
  8029d7:	e9 3e ff ff ff       	jmp    80291a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8029dc:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8029de:	83 c4 20             	add    $0x20,%esp
  8029e1:	5e                   	pop    %esi
  8029e2:	5f                   	pop    %edi
  8029e3:	5d                   	pop    %ebp
  8029e4:	c3                   	ret    
  8029e5:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8029e8:	39 f5                	cmp    %esi,%ebp
  8029ea:	72 04                	jb     8029f0 <__umoddi3+0x104>
  8029ec:	39 f9                	cmp    %edi,%ecx
  8029ee:	77 06                	ja     8029f6 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8029f0:	89 f2                	mov    %esi,%edx
  8029f2:	29 cf                	sub    %ecx,%edi
  8029f4:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8029f6:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8029f8:	83 c4 20             	add    $0x20,%esp
  8029fb:	5e                   	pop    %esi
  8029fc:	5f                   	pop    %edi
  8029fd:	5d                   	pop    %ebp
  8029fe:	c3                   	ret    
  8029ff:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802a00:	89 d1                	mov    %edx,%ecx
  802a02:	89 c5                	mov    %eax,%ebp
  802a04:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802a08:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802a0c:	eb 8d                	jmp    80299b <__umoddi3+0xaf>
  802a0e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a10:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802a14:	72 ea                	jb     802a00 <__umoddi3+0x114>
  802a16:	89 f1                	mov    %esi,%ecx
  802a18:	eb 81                	jmp    80299b <__umoddi3+0xaf>
