
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 0b 1d 00 00       	call   801d3c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	88 c1                	mov    %al,%cl

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80003a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003f:	ec                   	in     (%dx),%al
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800040:	0f b6 c0             	movzbl %al,%eax
  800043:	89 c3                	mov    %eax,%ebx
  800045:	81 e3 c0 00 00 00    	and    $0xc0,%ebx
  80004b:	83 fb 40             	cmp    $0x40,%ebx
  80004e:	75 ef                	jne    80003f <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  800050:	84 c9                	test   %cl,%cl
  800052:	74 0c                	je     800060 <ide_wait_ready+0x2c>
  800054:	83 e0 21             	and    $0x21,%eax
		return -1;
	return 0;
  800057:	83 f8 01             	cmp    $0x1,%eax
  80005a:	19 c0                	sbb    %eax,%eax
  80005c:	f7 d0                	not    %eax
  80005e:	eb 05                	jmp    800065 <ide_wait_ready+0x31>
  800060:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800065:	5b                   	pop    %ebx
  800066:	5d                   	pop    %ebp
  800067:	c3                   	ret    

00800068 <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	53                   	push   %ebx
  80006c:	83 ec 14             	sub    $0x14,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  80006f:	b8 00 00 00 00       	mov    $0x0,%eax
  800074:	e8 bb ff ff ff       	call   800034 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800079:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80007e:	b0 f0                	mov    $0xf0,%al
  800080:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800081:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800086:	b2 f7                	mov    $0xf7,%dl
  800088:	eb 09                	jmp    800093 <ide_probe_disk1+0x2b>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  80008a:	43                   	inc    %ebx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008b:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
  800091:	74 05                	je     800098 <ide_probe_disk1+0x30>
  800093:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800094:	a8 a1                	test   $0xa1,%al
  800096:	75 f2                	jne    80008a <ide_probe_disk1+0x22>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800098:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009d:	b0 e0                	mov    $0xe0,%al
  80009f:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a0:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  8000a6:	0f 9e c0             	setle  %al
  8000a9:	0f b6 c0             	movzbl %al,%eax
  8000ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b0:	c7 04 24 00 42 80 00 	movl   $0x804200,(%esp)
  8000b7:	e8 e8 1d 00 00       	call   801ea4 <cprintf>
	return (x < 1000);
  8000bc:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  8000c2:	0f 9e c0             	setle  %al
}
  8000c5:	83 c4 14             	add    $0x14,%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5d                   	pop    %ebp
  8000ca:	c3                   	ret    

008000cb <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	83 ec 18             	sub    $0x18,%esp
  8000d1:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000d4:	83 f8 01             	cmp    $0x1,%eax
  8000d7:	76 1c                	jbe    8000f5 <ide_set_disk+0x2a>
		panic("bad disk number");
  8000d9:	c7 44 24 08 17 42 80 	movl   $0x804217,0x8(%esp)
  8000e0:	00 
  8000e1:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8000e8:	00 
  8000e9:	c7 04 24 27 42 80 00 	movl   $0x804227,(%esp)
  8000f0:	e8 b7 1c 00 00       	call   801dac <_panic>
	diskno = d;
  8000f5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	57                   	push   %edi
  800100:	56                   	push   %esi
  800101:	53                   	push   %ebx
  800102:	83 ec 1c             	sub    $0x1c,%esp
  800105:	8b 7d 08             	mov    0x8(%ebp),%edi
  800108:	8b 75 0c             	mov    0xc(%ebp),%esi
  80010b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  80010e:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
  800114:	76 24                	jbe    80013a <ide_read+0x3e>
  800116:	c7 44 24 0c 30 42 80 	movl   $0x804230,0xc(%esp)
  80011d:	00 
  80011e:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  800125:	00 
  800126:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
  80012d:	00 
  80012e:	c7 04 24 27 42 80 00 	movl   $0x804227,(%esp)
  800135:	e8 72 1c 00 00       	call   801dac <_panic>

	ide_wait_ready(0);
  80013a:	b8 00 00 00 00       	mov    $0x0,%eax
  80013f:	e8 f0 fe ff ff       	call   800034 <ide_wait_ready>
  800144:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800149:	88 d8                	mov    %bl,%al
  80014b:	ee                   	out    %al,(%dx)
  80014c:	b2 f3                	mov    $0xf3,%dl
  80014e:	89 f8                	mov    %edi,%eax
  800150:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  800151:	89 f8                	mov    %edi,%eax
  800153:	c1 e8 08             	shr    $0x8,%eax
  800156:	b2 f4                	mov    $0xf4,%dl
  800158:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800159:	89 f8                	mov    %edi,%eax
  80015b:	c1 e8 10             	shr    $0x10,%eax
  80015e:	b2 f5                	mov    $0xf5,%dl
  800160:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800161:	a1 00 50 80 00       	mov    0x805000,%eax
  800166:	83 e0 01             	and    $0x1,%eax
  800169:	c1 e0 04             	shl    $0x4,%eax
  80016c:	83 c8 e0             	or     $0xffffffe0,%eax
  80016f:	c1 ef 18             	shr    $0x18,%edi
  800172:	83 e7 0f             	and    $0xf,%edi
  800175:	09 f8                	or     %edi,%eax
  800177:	b2 f6                	mov    $0xf6,%dl
  800179:	ee                   	out    %al,(%dx)
  80017a:	b2 f7                	mov    $0xf7,%dl
  80017c:	b0 20                	mov    $0x20,%al
  80017e:	ee                   	out    %al,(%dx)
  80017f:	eb 24                	jmp    8001a5 <ide_read+0xa9>
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800181:	b8 01 00 00 00       	mov    $0x1,%eax
  800186:	e8 a9 fe ff ff       	call   800034 <ide_wait_ready>
  80018b:	85 c0                	test   %eax,%eax
  80018d:	78 1f                	js     8001ae <ide_read+0xb2>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  80018f:	89 f7                	mov    %esi,%edi
  800191:	b9 80 00 00 00       	mov    $0x80,%ecx
  800196:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80019b:	fc                   	cld    
  80019c:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  80019e:	4b                   	dec    %ebx
  80019f:	81 c6 00 02 00 00    	add    $0x200,%esi
  8001a5:	85 db                	test   %ebx,%ebx
  8001a7:	75 d8                	jne    800181 <ide_read+0x85>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001ae:	83 c4 1c             	add    $0x1c,%esp
  8001b1:	5b                   	pop    %ebx
  8001b2:	5e                   	pop    %esi
  8001b3:	5f                   	pop    %edi
  8001b4:	5d                   	pop    %ebp
  8001b5:	c3                   	ret    

008001b6 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	57                   	push   %edi
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 1c             	sub    $0x1c,%esp
  8001bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8001c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  8001c8:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
  8001ce:	76 24                	jbe    8001f4 <ide_write+0x3e>
  8001d0:	c7 44 24 0c 30 42 80 	movl   $0x804230,0xc(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  8001df:	00 
  8001e0:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8001e7:	00 
  8001e8:	c7 04 24 27 42 80 00 	movl   $0x804227,(%esp)
  8001ef:	e8 b8 1b 00 00       	call   801dac <_panic>

	ide_wait_ready(0);
  8001f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001f9:	e8 36 fe ff ff       	call   800034 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001fe:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800203:	88 d8                	mov    %bl,%al
  800205:	ee                   	out    %al,(%dx)
  800206:	b2 f3                	mov    $0xf3,%dl
  800208:	89 f0                	mov    %esi,%eax
  80020a:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  80020b:	89 f0                	mov    %esi,%eax
  80020d:	c1 e8 08             	shr    $0x8,%eax
  800210:	b2 f4                	mov    $0xf4,%dl
  800212:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800213:	89 f0                	mov    %esi,%eax
  800215:	c1 e8 10             	shr    $0x10,%eax
  800218:	b2 f5                	mov    $0xf5,%dl
  80021a:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80021b:	a1 00 50 80 00       	mov    0x805000,%eax
  800220:	83 e0 01             	and    $0x1,%eax
  800223:	c1 e0 04             	shl    $0x4,%eax
  800226:	83 c8 e0             	or     $0xffffffe0,%eax
  800229:	c1 ee 18             	shr    $0x18,%esi
  80022c:	83 e6 0f             	and    $0xf,%esi
  80022f:	09 f0                	or     %esi,%eax
  800231:	b2 f6                	mov    $0xf6,%dl
  800233:	ee                   	out    %al,(%dx)
  800234:	b2 f7                	mov    $0xf7,%dl
  800236:	b0 30                	mov    $0x30,%al
  800238:	ee                   	out    %al,(%dx)
  800239:	eb 24                	jmp    80025f <ide_write+0xa9>
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80023b:	b8 01 00 00 00       	mov    $0x1,%eax
  800240:	e8 ef fd ff ff       	call   800034 <ide_wait_ready>
  800245:	85 c0                	test   %eax,%eax
  800247:	78 1f                	js     800268 <ide_write+0xb2>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  800249:	89 fe                	mov    %edi,%esi
  80024b:	b9 80 00 00 00       	mov    $0x80,%ecx
  800250:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800255:	fc                   	cld    
  800256:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800258:	4b                   	dec    %ebx
  800259:	81 c7 00 02 00 00    	add    $0x200,%edi
  80025f:	85 db                	test   %ebx,%ebx
  800261:	75 d8                	jne    80023b <ide_write+0x85>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800263:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800268:	83 c4 1c             	add    $0x1c,%esp
  80026b:	5b                   	pop    %ebx
  80026c:	5e                   	pop    %esi
  80026d:	5f                   	pop    %edi
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 20             	sub    $0x20,%esp
  800278:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80027b:	8b 18                	mov    (%eax),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80027d:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
  800283:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  800289:	76 2e                	jbe    8002b9 <bc_pgfault+0x49>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  80028b:	8b 50 04             	mov    0x4(%eax),%edx
  80028e:	89 54 24 14          	mov    %edx,0x14(%esp)
  800292:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800296:	8b 40 28             	mov    0x28(%eax),%eax
  800299:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029d:	c7 44 24 08 54 42 80 	movl   $0x804254,0x8(%esp)
  8002a4:	00 
  8002a5:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8002ac:	00 
  8002ad:	c7 04 24 58 43 80 00 	movl   $0x804358,(%esp)
  8002b4:	e8 f3 1a 00 00       	call   801dac <_panic>
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8002b9:	8d b3 00 00 00 f0    	lea    -0x10000000(%ebx),%esi
  8002bf:	c1 ee 0c             	shr    $0xc,%esi
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002c2:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8002c7:	85 c0                	test   %eax,%eax
  8002c9:	74 25                	je     8002f0 <bc_pgfault+0x80>
  8002cb:	3b 70 04             	cmp    0x4(%eax),%esi
  8002ce:	72 20                	jb     8002f0 <bc_pgfault+0x80>
		panic("reading non-existent block %08x\n", blockno);
  8002d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d4:	c7 44 24 08 84 42 80 	movl   $0x804284,0x8(%esp)
  8002db:	00 
  8002dc:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8002e3:	00 
  8002e4:	c7 04 24 58 43 80 00 	movl   $0x804358,(%esp)
  8002eb:	e8 bc 1a 00 00       	call   801dac <_panic>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	addr = ROUNDDOWN(addr, BLKSIZE);
  8002f0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, addr, PTE_SYSCALL)) < 0)
  8002f6:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  8002fd:	00 
  8002fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800302:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800309:	e8 33 25 00 00       	call   802841 <sys_page_alloc>
  80030e:	85 c0                	test   %eax,%eax
  800310:	79 20                	jns    800332 <bc_pgfault+0xc2>
		panic("in bc_pgfault, sys_page_alloc: %e", r);
  800312:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800316:	c7 44 24 08 a8 42 80 	movl   $0x8042a8,0x8(%esp)
  80031d:	00 
  80031e:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  800325:	00 
  800326:	c7 04 24 58 43 80 00 	movl   $0x804358,(%esp)
  80032d:	e8 7a 1a 00 00       	call   801dac <_panic>
	ide_read(blockno * BLKSECTS, addr, BLKSECTS);
  800332:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  800339:	00 
  80033a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80033e:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	e8 af fd ff ff       	call   8000fc <ide_read>

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  80034d:	89 d8                	mov    %ebx,%eax
  80034f:	c1 e8 0c             	shr    $0xc,%eax
  800352:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800359:	25 07 0e 00 00       	and    $0xe07,%eax
  80035e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800362:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800366:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80036d:	00 
  80036e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800372:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800379:	e8 17 25 00 00       	call   802895 <sys_page_map>
  80037e:	85 c0                	test   %eax,%eax
  800380:	79 20                	jns    8003a2 <bc_pgfault+0x132>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800382:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800386:	c7 44 24 08 cc 42 80 	movl   $0x8042cc,0x8(%esp)
  80038d:	00 
  80038e:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  800395:	00 
  800396:	c7 04 24 58 43 80 00 	movl   $0x804358,(%esp)
  80039d:	e8 0a 1a 00 00       	call   801dac <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  8003a2:	83 3d 08 a0 80 00 00 	cmpl   $0x0,0x80a008
  8003a9:	74 2c                	je     8003d7 <bc_pgfault+0x167>
  8003ab:	89 34 24             	mov    %esi,(%esp)
  8003ae:	e8 58 05 00 00       	call   80090b <block_is_free>
  8003b3:	84 c0                	test   %al,%al
  8003b5:	74 20                	je     8003d7 <bc_pgfault+0x167>
		panic("reading free block %08x\n", blockno);
  8003b7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003bb:	c7 44 24 08 60 43 80 	movl   $0x804360,0x8(%esp)
  8003c2:	00 
  8003c3:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8003ca:	00 
  8003cb:	c7 04 24 58 43 80 00 	movl   $0x804358,(%esp)
  8003d2:	e8 d5 19 00 00       	call   801dac <_panic>
}
  8003d7:	83 c4 20             	add    $0x20,%esp
  8003da:	5b                   	pop    %ebx
  8003db:	5e                   	pop    %esi
  8003dc:	5d                   	pop    %ebp
  8003dd:	c3                   	ret    

008003de <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	83 ec 18             	sub    $0x18,%esp
  8003e4:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  8003e7:	85 c0                	test   %eax,%eax
  8003e9:	74 0f                	je     8003fa <diskaddr+0x1c>
  8003eb:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8003f1:	85 d2                	test   %edx,%edx
  8003f3:	74 25                	je     80041a <diskaddr+0x3c>
  8003f5:	3b 42 04             	cmp    0x4(%edx),%eax
  8003f8:	72 20                	jb     80041a <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  8003fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003fe:	c7 44 24 08 ec 42 80 	movl   $0x8042ec,0x8(%esp)
  800405:	00 
  800406:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80040d:	00 
  80040e:	c7 04 24 58 43 80 00 	movl   $0x804358,(%esp)
  800415:	e8 92 19 00 00       	call   801dac <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  80041a:	05 00 00 01 00       	add    $0x10000,%eax
  80041f:	c1 e0 0c             	shl    $0xc,%eax
}
  800422:	c9                   	leave  
  800423:	c3                   	ret    

00800424 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	8b 45 08             	mov    0x8(%ebp),%eax
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  80042a:	89 c2                	mov    %eax,%edx
  80042c:	c1 ea 16             	shr    $0x16,%edx
  80042f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800436:	f6 c2 01             	test   $0x1,%dl
  800439:	74 0f                	je     80044a <va_is_mapped+0x26>
  80043b:	c1 e8 0c             	shr    $0xc,%eax
  80043e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800445:	83 e0 01             	and    $0x1,%eax
  800448:	eb 05                	jmp    80044f <va_is_mapped+0x2b>
  80044a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80044f:	5d                   	pop    %ebp
  800450:	c3                   	ret    

00800451 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  800454:	8b 45 08             	mov    0x8(%ebp),%eax
  800457:	c1 e8 0c             	shr    $0xc,%eax
  80045a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800461:	a8 40                	test   $0x40,%al
  800463:	0f 95 c0             	setne  %al
}
  800466:	5d                   	pop    %ebp
  800467:	c3                   	ret    

00800468 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	56                   	push   %esi
  80046c:	53                   	push   %ebx
  80046d:	83 ec 20             	sub    $0x20,%esp
  800470:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800473:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800479:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80047e:	76 20                	jbe    8004a0 <flush_block+0x38>
		panic("flush_block of bad va %08x", addr);
  800480:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800484:	c7 44 24 08 79 43 80 	movl   $0x804379,0x8(%esp)
  80048b:	00 
  80048c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800493:	00 
  800494:	c7 04 24 58 43 80 00 	movl   $0x804358,(%esp)
  80049b:	e8 0c 19 00 00       	call   801dac <_panic>

	// LAB 5: Your code here.
	if (va_is_mapped(addr) && va_is_dirty(addr))
  8004a0:	89 1c 24             	mov    %ebx,(%esp)
  8004a3:	e8 7c ff ff ff       	call   800424 <va_is_mapped>
  8004a8:	84 c0                	test   %al,%al
  8004aa:	0f 84 89 00 00 00    	je     800539 <flush_block+0xd1>
  8004b0:	89 1c 24             	mov    %ebx,(%esp)
  8004b3:	e8 99 ff ff ff       	call   800451 <va_is_dirty>
  8004b8:	84 c0                	test   %al,%al
  8004ba:	74 7d                	je     800539 <flush_block+0xd1>
	{
		addr = ROUNDDOWN(addr, BLKSIZE);
  8004bc:	89 de                	mov    %ebx,%esi
  8004be:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
		ide_write(blockno * BLKSECTS, addr, BLKSECTS);
  8004c4:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  8004cb:	00 
  8004cc:	89 74 24 04          	mov    %esi,0x4(%esp)
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8004d0:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  8004d6:	c1 eb 0c             	shr    $0xc,%ebx

	// LAB 5: Your code here.
	if (va_is_mapped(addr) && va_is_dirty(addr))
	{
		addr = ROUNDDOWN(addr, BLKSIZE);
		ide_write(blockno * BLKSECTS, addr, BLKSECTS);
  8004d9:	c1 e3 03             	shl    $0x3,%ebx
  8004dc:	89 1c 24             	mov    %ebx,(%esp)
  8004df:	e8 d2 fc ff ff       	call   8001b6 <ide_write>
		int r;
		if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  8004e4:	89 f0                	mov    %esi,%eax
  8004e6:	c1 e8 0c             	shr    $0xc,%eax
  8004e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8004f0:	25 07 0e 00 00       	and    $0xe07,%eax
  8004f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004f9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004fd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800504:	00 
  800505:	89 74 24 04          	mov    %esi,0x4(%esp)
  800509:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800510:	e8 80 23 00 00       	call   802895 <sys_page_map>
  800515:	85 c0                	test   %eax,%eax
  800517:	79 20                	jns    800539 <flush_block+0xd1>
			panic("int flush_block, sys_page_map: %e", r);
  800519:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80051d:	c7 44 24 08 10 43 80 	movl   $0x804310,0x8(%esp)
  800524:	00 
  800525:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  80052c:	00 
  80052d:	c7 04 24 58 43 80 00 	movl   $0x804358,(%esp)
  800534:	e8 73 18 00 00       	call   801dac <_panic>
	}
	//panic("flush_block not implemented");
}
  800539:	83 c4 20             	add    $0x20,%esp
  80053c:	5b                   	pop    %ebx
  80053d:	5e                   	pop    %esi
  80053e:	5d                   	pop    %ebp
  80053f:	c3                   	ret    

00800540 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  800540:	55                   	push   %ebp
  800541:	89 e5                	mov    %esp,%ebp
  800543:	53                   	push   %ebx
  800544:	81 ec 24 02 00 00    	sub    $0x224,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  80054a:	c7 04 24 70 02 80 00 	movl   $0x800270,(%esp)
  800551:	e8 b6 25 00 00       	call   802b0c <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800556:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80055d:	e8 7c fe ff ff       	call   8003de <diskaddr>
  800562:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800569:	00 
  80056a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80056e:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  800574:	89 04 24             	mov    %eax,(%esp)
  800577:	e8 4c 20 00 00       	call   8025c8 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  80057c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800583:	e8 56 fe ff ff       	call   8003de <diskaddr>
  800588:	c7 44 24 04 94 43 80 	movl   $0x804394,0x4(%esp)
  80058f:	00 
  800590:	89 04 24             	mov    %eax,(%esp)
  800593:	e8 b7 1e 00 00       	call   80244f <strcpy>
	flush_block(diskaddr(1));
  800598:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80059f:	e8 3a fe ff ff       	call   8003de <diskaddr>
  8005a4:	89 04 24             	mov    %eax,(%esp)
  8005a7:	e8 bc fe ff ff       	call   800468 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  8005ac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005b3:	e8 26 fe ff ff       	call   8003de <diskaddr>
  8005b8:	89 04 24             	mov    %eax,(%esp)
  8005bb:	e8 64 fe ff ff       	call   800424 <va_is_mapped>
  8005c0:	84 c0                	test   %al,%al
  8005c2:	75 24                	jne    8005e8 <bc_init+0xa8>
  8005c4:	c7 44 24 0c b6 43 80 	movl   $0x8043b6,0xc(%esp)
  8005cb:	00 
  8005cc:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  8005d3:	00 
  8005d4:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8005db:	00 
  8005dc:	c7 04 24 58 43 80 00 	movl   $0x804358,(%esp)
  8005e3:	e8 c4 17 00 00       	call   801dac <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  8005e8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005ef:	e8 ea fd ff ff       	call   8003de <diskaddr>
  8005f4:	89 04 24             	mov    %eax,(%esp)
  8005f7:	e8 55 fe ff ff       	call   800451 <va_is_dirty>
  8005fc:	84 c0                	test   %al,%al
  8005fe:	74 24                	je     800624 <bc_init+0xe4>
  800600:	c7 44 24 0c 9b 43 80 	movl   $0x80439b,0xc(%esp)
  800607:	00 
  800608:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  80060f:	00 
  800610:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  800617:	00 
  800618:	c7 04 24 58 43 80 00 	movl   $0x804358,(%esp)
  80061f:	e8 88 17 00 00       	call   801dac <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800624:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80062b:	e8 ae fd ff ff       	call   8003de <diskaddr>
  800630:	89 44 24 04          	mov    %eax,0x4(%esp)
  800634:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80063b:	e8 a8 22 00 00       	call   8028e8 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800640:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800647:	e8 92 fd ff ff       	call   8003de <diskaddr>
  80064c:	89 04 24             	mov    %eax,(%esp)
  80064f:	e8 d0 fd ff ff       	call   800424 <va_is_mapped>
  800654:	84 c0                	test   %al,%al
  800656:	74 24                	je     80067c <bc_init+0x13c>
  800658:	c7 44 24 0c b5 43 80 	movl   $0x8043b5,0xc(%esp)
  80065f:	00 
  800660:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  800667:	00 
  800668:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  80066f:	00 
  800670:	c7 04 24 58 43 80 00 	movl   $0x804358,(%esp)
  800677:	e8 30 17 00 00       	call   801dac <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  80067c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800683:	e8 56 fd ff ff       	call   8003de <diskaddr>
  800688:	c7 44 24 04 94 43 80 	movl   $0x804394,0x4(%esp)
  80068f:	00 
  800690:	89 04 24             	mov    %eax,(%esp)
  800693:	e8 5e 1e 00 00       	call   8024f6 <strcmp>
  800698:	85 c0                	test   %eax,%eax
  80069a:	74 24                	je     8006c0 <bc_init+0x180>
  80069c:	c7 44 24 0c 34 43 80 	movl   $0x804334,0xc(%esp)
  8006a3:	00 
  8006a4:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  8006ab:	00 
  8006ac:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8006b3:	00 
  8006b4:	c7 04 24 58 43 80 00 	movl   $0x804358,(%esp)
  8006bb:	e8 ec 16 00 00       	call   801dac <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  8006c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006c7:	e8 12 fd ff ff       	call   8003de <diskaddr>
  8006cc:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  8006d3:	00 
  8006d4:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  8006da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006de:	89 04 24             	mov    %eax,(%esp)
  8006e1:	e8 e2 1e 00 00       	call   8025c8 <memmove>
	flush_block(diskaddr(1));
  8006e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006ed:	e8 ec fc ff ff       	call   8003de <diskaddr>
  8006f2:	89 04 24             	mov    %eax,(%esp)
  8006f5:	e8 6e fd ff ff       	call   800468 <flush_block>

	// Now repeat the same experiment, but pass an unaligned address to
	// flush_block.

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8006fa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800701:	e8 d8 fc ff ff       	call   8003de <diskaddr>
  800706:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  80070d:	00 
  80070e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800712:	89 1c 24             	mov    %ebx,(%esp)
  800715:	e8 ae 1e 00 00       	call   8025c8 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  80071a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800721:	e8 b8 fc ff ff       	call   8003de <diskaddr>
  800726:	c7 44 24 04 94 43 80 	movl   $0x804394,0x4(%esp)
  80072d:	00 
  80072e:	89 04 24             	mov    %eax,(%esp)
  800731:	e8 19 1d 00 00       	call   80244f <strcpy>

	// Pass an unaligned address to flush_block.
	flush_block(diskaddr(1) + 20);
  800736:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80073d:	e8 9c fc ff ff       	call   8003de <diskaddr>
  800742:	83 c0 14             	add    $0x14,%eax
  800745:	89 04 24             	mov    %eax,(%esp)
  800748:	e8 1b fd ff ff       	call   800468 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  80074d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800754:	e8 85 fc ff ff       	call   8003de <diskaddr>
  800759:	89 04 24             	mov    %eax,(%esp)
  80075c:	e8 c3 fc ff ff       	call   800424 <va_is_mapped>
  800761:	84 c0                	test   %al,%al
  800763:	75 24                	jne    800789 <bc_init+0x249>
  800765:	c7 44 24 0c b6 43 80 	movl   $0x8043b6,0xc(%esp)
  80076c:	00 
  80076d:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  800774:	00 
  800775:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  80077c:	00 
  80077d:	c7 04 24 58 43 80 00 	movl   $0x804358,(%esp)
  800784:	e8 23 16 00 00       	call   801dac <_panic>
	// Skip the !va_is_dirty() check because it makes the bug somewhat
	// obscure and hence harder to debug.
	//assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800789:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800790:	e8 49 fc ff ff       	call   8003de <diskaddr>
  800795:	89 44 24 04          	mov    %eax,0x4(%esp)
  800799:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007a0:	e8 43 21 00 00       	call   8028e8 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8007a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8007ac:	e8 2d fc ff ff       	call   8003de <diskaddr>
  8007b1:	89 04 24             	mov    %eax,(%esp)
  8007b4:	e8 6b fc ff ff       	call   800424 <va_is_mapped>
  8007b9:	84 c0                	test   %al,%al
  8007bb:	74 24                	je     8007e1 <bc_init+0x2a1>
  8007bd:	c7 44 24 0c b5 43 80 	movl   $0x8043b5,0xc(%esp)
  8007c4:	00 
  8007c5:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  8007cc:	00 
  8007cd:	c7 44 24 04 8d 00 00 	movl   $0x8d,0x4(%esp)
  8007d4:	00 
  8007d5:	c7 04 24 58 43 80 00 	movl   $0x804358,(%esp)
  8007dc:	e8 cb 15 00 00       	call   801dac <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8007e1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8007e8:	e8 f1 fb ff ff       	call   8003de <diskaddr>
  8007ed:	c7 44 24 04 94 43 80 	movl   $0x804394,0x4(%esp)
  8007f4:	00 
  8007f5:	89 04 24             	mov    %eax,(%esp)
  8007f8:	e8 f9 1c 00 00       	call   8024f6 <strcmp>
  8007fd:	85 c0                	test   %eax,%eax
  8007ff:	74 24                	je     800825 <bc_init+0x2e5>
  800801:	c7 44 24 0c 34 43 80 	movl   $0x804334,0xc(%esp)
  800808:	00 
  800809:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  800810:	00 
  800811:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800818:	00 
  800819:	c7 04 24 58 43 80 00 	movl   $0x804358,(%esp)
  800820:	e8 87 15 00 00       	call   801dac <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800825:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80082c:	e8 ad fb ff ff       	call   8003de <diskaddr>
  800831:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800838:	00 
  800839:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  80083f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800843:	89 04 24             	mov    %eax,(%esp)
  800846:	e8 7d 1d 00 00       	call   8025c8 <memmove>
	flush_block(diskaddr(1));
  80084b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800852:	e8 87 fb ff ff       	call   8003de <diskaddr>
  800857:	89 04 24             	mov    %eax,(%esp)
  80085a:	e8 09 fc ff ff       	call   800468 <flush_block>

	cprintf("block cache is good\n");
  80085f:	c7 04 24 d0 43 80 00 	movl   $0x8043d0,(%esp)
  800866:	e8 39 16 00 00       	call   801ea4 <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  80086b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800872:	e8 67 fb ff ff       	call   8003de <diskaddr>
  800877:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  80087e:	00 
  80087f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800883:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800889:	89 04 24             	mov    %eax,(%esp)
  80088c:	e8 37 1d 00 00       	call   8025c8 <memmove>
}
  800891:	81 c4 24 02 00 00    	add    $0x224,%esp
  800897:	5b                   	pop    %ebx
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    
	...

0080089c <skip_slash>:
}

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
	while (*p == '/')
  80089f:	eb 01                	jmp    8008a2 <skip_slash+0x6>
		p++;
  8008a1:	40                   	inc    %eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8008a2:	80 38 2f             	cmpb   $0x2f,(%eax)
  8008a5:	74 fa                	je     8008a1 <skip_slash+0x5>
		p++;
	return p;
}
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	83 ec 18             	sub    $0x18,%esp
	if (super->s_magic != FS_MAGIC)
  8008af:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8008b4:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8008ba:	74 1c                	je     8008d8 <check_super+0x2f>
		panic("bad file system magic number");
  8008bc:	c7 44 24 08 e5 43 80 	movl   $0x8043e5,0x8(%esp)
  8008c3:	00 
  8008c4:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8008cb:	00 
  8008cc:	c7 04 24 02 44 80 00 	movl   $0x804402,(%esp)
  8008d3:	e8 d4 14 00 00       	call   801dac <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8008d8:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8008df:	76 1c                	jbe    8008fd <check_super+0x54>
		panic("file system is too large");
  8008e1:	c7 44 24 08 0a 44 80 	movl   $0x80440a,0x8(%esp)
  8008e8:	00 
  8008e9:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8008f0:	00 
  8008f1:	c7 04 24 02 44 80 00 	movl   $0x804402,(%esp)
  8008f8:	e8 af 14 00 00       	call   801dac <_panic>

	cprintf("superblock is good\n");
  8008fd:	c7 04 24 23 44 80 00 	movl   $0x804423,(%esp)
  800904:	e8 9b 15 00 00       	call   801ea4 <cprintf>
}
  800909:	c9                   	leave  
  80090a:	c3                   	ret    

0080090b <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  800911:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800916:	85 c0                	test   %eax,%eax
  800918:	74 1d                	je     800937 <block_is_free+0x2c>
  80091a:	39 48 04             	cmp    %ecx,0x4(%eax)
  80091d:	76 1c                	jbe    80093b <block_is_free+0x30>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  80091f:	b8 01 00 00 00       	mov    $0x1,%eax
  800924:	d3 e0                	shl    %cl,%eax
  800926:	c1 e9 05             	shr    $0x5,%ecx
// --------------------------------------------------------------

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
  800929:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80092f:	85 04 8a             	test   %eax,(%edx,%ecx,4)
  800932:	0f 95 c0             	setne  %al
  800935:	eb 06                	jmp    80093d <block_is_free+0x32>
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800937:	b0 00                	mov    $0x0,%al
  800939:	eb 02                	jmp    80093d <block_is_free+0x32>
  80093b:	b0 00                	mov    $0x0,%al
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	83 ec 18             	sub    $0x18,%esp
  800945:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800948:	85 c9                	test   %ecx,%ecx
  80094a:	75 1c                	jne    800968 <free_block+0x29>
		panic("attempt to free zero block");
  80094c:	c7 44 24 08 37 44 80 	movl   $0x804437,0x8(%esp)
  800953:	00 
  800954:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  80095b:	00 
  80095c:	c7 04 24 02 44 80 00 	movl   $0x804402,(%esp)
  800963:	e8 44 14 00 00       	call   801dac <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800968:	89 c8                	mov    %ecx,%eax
  80096a:	c1 e8 05             	shr    $0x5,%eax
  80096d:	c1 e0 02             	shl    $0x2,%eax
  800970:	03 05 08 a0 80 00    	add    0x80a008,%eax
  800976:	ba 01 00 00 00       	mov    $0x1,%edx
  80097b:	d3 e2                	shl    %cl,%edx
  80097d:	09 10                	or     %edx,(%eax)
}
  80097f:	c9                   	leave  
  800980:	c3                   	ret    

00800981 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800981:	55                   	push   %ebp
  800982:	89 e5                	mov    %esp,%ebp
  800984:	57                   	push   %edi
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	83 ec 2c             	sub    $0x2c,%esp
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	for (uint32_t i = 0; i < super->s_nblocks; ++i)
  80098a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80098f:	8b 40 04             	mov    0x4(%eax),%eax
  800992:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	{
		if (bitmap[i / 32] & (1 << (i % 32)))
  800995:	8b 35 08 a0 80 00    	mov    0x80a008,%esi
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	for (uint32_t i = 0; i < super->s_nblocks; ++i)
  80099b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009a0:	eb 2d                	jmp    8009cf <alloc_block+0x4e>
	{
		if (bitmap[i / 32] & (1 << (i % 32)))
  8009a2:	89 c8                	mov    %ecx,%eax
  8009a4:	c1 e8 05             	shr    $0x5,%eax
  8009a7:	8d 04 86             	lea    (%esi,%eax,4),%eax
  8009aa:	8b 10                	mov    (%eax),%edx
  8009ac:	89 cb                	mov    %ecx,%ebx
  8009ae:	bf 01 00 00 00       	mov    $0x1,%edi
  8009b3:	d3 e7                	shl    %cl,%edi
  8009b5:	85 d7                	test   %edx,%edi
  8009b7:	74 15                	je     8009ce <alloc_block+0x4d>
		{
			bitmap[i / 32] &= ~(1 << (i % 32));
  8009b9:	f7 d7                	not    %edi
  8009bb:	21 fa                	and    %edi,%edx
  8009bd:	89 10                	mov    %edx,(%eax)
			flush_block(bitmap);
  8009bf:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8009c4:	89 04 24             	mov    %eax,(%esp)
  8009c7:	e8 9c fa ff ff       	call   800468 <flush_block>
			return i;
  8009cc:	eb 0b                	jmp    8009d9 <alloc_block+0x58>
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	for (uint32_t i = 0; i < super->s_nblocks; ++i)
  8009ce:	41                   	inc    %ecx
  8009cf:	3b 4d e4             	cmp    -0x1c(%ebp),%ecx
  8009d2:	75 ce                	jne    8009a2 <alloc_block+0x21>
			flush_block(bitmap);
			return i;
		}
	}
	//panic("alloc_block not implemented");
	return -E_NO_DISK;
  8009d4:	bb f7 ff ff ff       	mov    $0xfffffff7,%ebx
}
  8009d9:	89 d8                	mov    %ebx,%eax
  8009db:	83 c4 2c             	add    $0x2c,%esp
  8009de:	5b                   	pop    %ebx
  8009df:	5e                   	pop    %esi
  8009e0:	5f                   	pop    %edi
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	57                   	push   %edi
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	83 ec 2c             	sub    $0x2c,%esp
  8009ec:	89 c3                	mov    %eax,%ebx
  8009ee:	89 d6                	mov    %edx,%esi
  8009f0:	89 cf                	mov    %ecx,%edi
  8009f2:	8a 45 08             	mov    0x8(%ebp),%al
       // LAB 5: Your code here.
       uint32_t blocknum;
	if (filebno < NDIRECT)
  8009f5:	83 fa 09             	cmp    $0x9,%edx
  8009f8:	77 13                	ja     800a0d <file_block_walk+0x2a>
	{
		*ppdiskbno = &(f->f_direct[filebno]);
  8009fa:	8d 84 93 88 00 00 00 	lea    0x88(%ebx,%edx,4),%eax
  800a01:	89 01                	mov    %eax,(%ecx)
			}
		}
		uint32_t *indirect = (uint32_t *)diskaddr(f->f_indirect);
		*ppdiskbno = &(indirect[filebno - NDIRECT]);
	}
	return 0;
  800a03:	b8 00 00 00 00       	mov    $0x0,%eax
  800a08:	e9 80 00 00 00       	jmp    800a8d <file_block_walk+0xaa>
	{
		*ppdiskbno = &(f->f_direct[filebno]);
	}
	else
	{
		if (filebno >= NDIRECT + NINDIRECT)
  800a0d:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  800a13:	77 6c                	ja     800a81 <file_block_walk+0x9e>
		{
			return -E_INVAL;
		}
		if (!f->f_indirect)
  800a15:	83 bb b0 00 00 00 00 	cmpl   $0x0,0xb0(%ebx)
  800a1c:	75 48                	jne    800a66 <file_block_walk+0x83>
		{
			if (alloc)
  800a1e:	84 c0                	test   %al,%al
  800a20:	74 66                	je     800a88 <file_block_walk+0xa5>
			{
				if ((blocknum = alloc_block()) < 0)
  800a22:	e8 5a ff ff ff       	call   800981 <alloc_block>
  800a27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				{
					return -E_NO_DISK;
				}
				cprintf("blocknum:%d\n",blocknum);
  800a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2e:	c7 04 24 52 44 80 00 	movl   $0x804452,(%esp)
  800a35:	e8 6a 14 00 00       	call   801ea4 <cprintf>
				memset(diskaddr(blocknum),0,BLKSIZE);
  800a3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a3d:	89 04 24             	mov    %eax,(%esp)
  800a40:	e8 99 f9 ff ff       	call   8003de <diskaddr>
  800a45:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800a4c:	00 
  800a4d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a54:	00 
  800a55:	89 04 24             	mov    %eax,(%esp)
  800a58:	e8 21 1b 00 00       	call   80257e <memset>
				f->f_indirect = blocknum;
  800a5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a60:	89 83 b0 00 00 00    	mov    %eax,0xb0(%ebx)
			else
			{
				return -E_NOT_FOUND;
			}
		}
		uint32_t *indirect = (uint32_t *)diskaddr(f->f_indirect);
  800a66:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800a6c:	89 04 24             	mov    %eax,(%esp)
  800a6f:	e8 6a f9 ff ff       	call   8003de <diskaddr>
		*ppdiskbno = &(indirect[filebno - NDIRECT]);
  800a74:	8d 44 b0 d8          	lea    -0x28(%eax,%esi,4),%eax
  800a78:	89 07                	mov    %eax,(%edi)
	}
	return 0;
  800a7a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a7f:	eb 0c                	jmp    800a8d <file_block_walk+0xaa>
	}
	else
	{
		if (filebno >= NDIRECT + NINDIRECT)
		{
			return -E_INVAL;
  800a81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a86:	eb 05                	jmp    800a8d <file_block_walk+0xaa>
				memset(diskaddr(blocknum),0,BLKSIZE);
				f->f_indirect = blocknum;
			}
			else
			{
				return -E_NOT_FOUND;
  800a88:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
		uint32_t *indirect = (uint32_t *)diskaddr(f->f_indirect);
		*ppdiskbno = &(indirect[filebno - NDIRECT]);
	}
	return 0;
       //panic("file_block_walk not implemented");
}
  800a8d:	83 c4 2c             	add    $0x2c,%esp
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5f                   	pop    %edi
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	53                   	push   %ebx
  800a99:	83 ec 14             	sub    $0x14,%esp
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800a9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800aa1:	eb 34                	jmp    800ad7 <check_bitmap+0x42>
		assert(!block_is_free(2+i));
  800aa3:	8d 43 02             	lea    0x2(%ebx),%eax
  800aa6:	89 04 24             	mov    %eax,(%esp)
  800aa9:	e8 5d fe ff ff       	call   80090b <block_is_free>
  800aae:	84 c0                	test   %al,%al
  800ab0:	74 24                	je     800ad6 <check_bitmap+0x41>
  800ab2:	c7 44 24 0c 5f 44 80 	movl   $0x80445f,0xc(%esp)
  800ab9:	00 
  800aba:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  800ac1:	00 
  800ac2:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  800ac9:	00 
  800aca:	c7 04 24 02 44 80 00 	movl   $0x804402,(%esp)
  800ad1:	e8 d6 12 00 00       	call   801dac <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800ad6:	43                   	inc    %ebx
  800ad7:	89 da                	mov    %ebx,%edx
  800ad9:	c1 e2 0f             	shl    $0xf,%edx
  800adc:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800ae1:	3b 50 04             	cmp    0x4(%eax),%edx
  800ae4:	72 bd                	jb     800aa3 <check_bitmap+0xe>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  800ae6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800aed:	e8 19 fe ff ff       	call   80090b <block_is_free>
  800af2:	84 c0                	test   %al,%al
  800af4:	74 24                	je     800b1a <check_bitmap+0x85>
  800af6:	c7 44 24 0c 73 44 80 	movl   $0x804473,0xc(%esp)
  800afd:	00 
  800afe:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  800b05:	00 
  800b06:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800b0d:	00 
  800b0e:	c7 04 24 02 44 80 00 	movl   $0x804402,(%esp)
  800b15:	e8 92 12 00 00       	call   801dac <_panic>
	assert(!block_is_free(1));
  800b1a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b21:	e8 e5 fd ff ff       	call   80090b <block_is_free>
  800b26:	84 c0                	test   %al,%al
  800b28:	74 24                	je     800b4e <check_bitmap+0xb9>
  800b2a:	c7 44 24 0c 85 44 80 	movl   $0x804485,0xc(%esp)
  800b31:	00 
  800b32:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  800b39:	00 
  800b3a:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  800b41:	00 
  800b42:	c7 04 24 02 44 80 00 	movl   $0x804402,(%esp)
  800b49:	e8 5e 12 00 00       	call   801dac <_panic>

	cprintf("bitmap is good\n");
  800b4e:	c7 04 24 97 44 80 00 	movl   $0x804497,(%esp)
  800b55:	e8 4a 13 00 00       	call   801ea4 <cprintf>
}
  800b5a:	83 c4 14             	add    $0x14,%esp
  800b5d:	5b                   	pop    %ebx
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800b66:	e8 fd f4 ff ff       	call   800068 <ide_probe_disk1>
  800b6b:	84 c0                	test   %al,%al
  800b6d:	74 0e                	je     800b7d <fs_init+0x1d>
		ide_set_disk(1);
  800b6f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b76:	e8 50 f5 ff ff       	call   8000cb <ide_set_disk>
  800b7b:	eb 0c                	jmp    800b89 <fs_init+0x29>
	else
		ide_set_disk(0);
  800b7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b84:	e8 42 f5 ff ff       	call   8000cb <ide_set_disk>
	bc_init();
  800b89:	e8 b2 f9 ff ff       	call   800540 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800b8e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b95:	e8 44 f8 ff ff       	call   8003de <diskaddr>
  800b9a:	a3 0c a0 80 00       	mov    %eax,0x80a00c
	check_super();
  800b9f:	e8 05 fd ff ff       	call   8008a9 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800ba4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800bab:	e8 2e f8 ff ff       	call   8003de <diskaddr>
  800bb0:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_bitmap();
  800bb5:	e8 db fe ff ff       	call   800a95 <check_bitmap>
	
}
  800bba:	c9                   	leave  
  800bbb:	c3                   	ret    

00800bbc <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	53                   	push   %ebx
  800bc0:	83 ec 24             	sub    $0x24,%esp
  800bc3:	8b 55 0c             	mov    0xc(%ebp),%edx
       // LAB 5: Your code here.
       uint32_t *pdiskbno;
	if (filebno >= NDIRECT + NINDIRECT)
  800bc6:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  800bcc:	77 78                	ja     800c46 <file_get_block+0x8a>
	{
		return -E_INVAL;
	}
	if (file_block_walk(f, filebno, &pdiskbno, true) < 0)
  800bce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800bd5:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800bd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdb:	e8 03 fe ff ff       	call   8009e3 <file_block_walk>
  800be0:	85 c0                	test   %eax,%eax
  800be2:	78 69                	js     800c4d <file_get_block+0x91>
	{
		return -E_NO_DISK;
	}
	if (*pdiskbno == 0)
  800be4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800be7:	83 3b 00             	cmpl   $0x0,(%ebx)
  800bea:	75 41                	jne    800c2d <file_get_block+0x71>
	{
		if ((*pdiskbno = alloc_block()) < 0)
  800bec:	e8 90 fd ff ff       	call   800981 <alloc_block>
  800bf1:	89 03                	mov    %eax,(%ebx)
		{
			return -E_NO_DISK;
		}
		cprintf("pdiskbno:%d\n",*pdiskbno);
  800bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bf6:	8b 00                	mov    (%eax),%eax
  800bf8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bfc:	c7 04 24 a7 44 80 00 	movl   $0x8044a7,(%esp)
  800c03:	e8 9c 12 00 00       	call   801ea4 <cprintf>
		memset(diskaddr(*pdiskbno),0,BLKSIZE);
  800c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c0b:	8b 00                	mov    (%eax),%eax
  800c0d:	89 04 24             	mov    %eax,(%esp)
  800c10:	e8 c9 f7 ff ff       	call   8003de <diskaddr>
  800c15:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800c1c:	00 
  800c1d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c24:	00 
  800c25:	89 04 24             	mov    %eax,(%esp)
  800c28:	e8 51 19 00 00       	call   80257e <memset>
	}
	*blk = (char *)diskaddr(*pdiskbno);
  800c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c30:	8b 00                	mov    (%eax),%eax
  800c32:	89 04 24             	mov    %eax,(%esp)
  800c35:	e8 a4 f7 ff ff       	call   8003de <diskaddr>
  800c3a:	8b 55 10             	mov    0x10(%ebp),%edx
  800c3d:	89 02                	mov    %eax,(%edx)
	return 0;
  800c3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c44:	eb 0c                	jmp    800c52 <file_get_block+0x96>
{
       // LAB 5: Your code here.
       uint32_t *pdiskbno;
	if (filebno >= NDIRECT + NINDIRECT)
	{
		return -E_INVAL;
  800c46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c4b:	eb 05                	jmp    800c52 <file_get_block+0x96>
	}
	if (file_block_walk(f, filebno, &pdiskbno, true) < 0)
	{
		return -E_NO_DISK;
  800c4d:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
		memset(diskaddr(*pdiskbno),0,BLKSIZE);
	}
	*blk = (char *)diskaddr(*pdiskbno);
	return 0;
       // panic("file_get_block not implemented");
}
  800c52:	83 c4 24             	add    $0x24,%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	81 ec cc 00 00 00    	sub    $0xcc,%esp
  800c64:	89 95 44 ff ff ff    	mov    %edx,-0xbc(%ebp)
  800c6a:	89 8d 40 ff ff ff    	mov    %ecx,-0xc0(%ebp)
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
  800c70:	e8 27 fc ff ff       	call   80089c <skip_slash>
  800c75:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
	f = &super->s_root;
  800c7b:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800c80:	83 c0 08             	add    $0x8,%eax
  800c83:	89 85 50 ff ff ff    	mov    %eax,-0xb0(%ebp)
	dir = 0;
	name[0] = 0;
  800c89:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800c90:	83 bd 44 ff ff ff 00 	cmpl   $0x0,-0xbc(%ebp)
  800c97:	74 0c                	je     800ca5 <walk_path+0x4d>
		*pdir = 0;
  800c99:	8b 95 44 ff ff ff    	mov    -0xbc(%ebp),%edx
  800c9f:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	*pf = 0;
  800ca5:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800cab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800cb6:	e9 95 01 00 00       	jmp    800e50 <walk_path+0x1f8>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800cbb:	46                   	inc    %esi
  800cbc:	eb 06                	jmp    800cc4 <walk_path+0x6c>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800cbe:	8b b5 4c ff ff ff    	mov    -0xb4(%ebp),%esi
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800cc4:	8a 06                	mov    (%esi),%al
  800cc6:	3c 2f                	cmp    $0x2f,%al
  800cc8:	74 04                	je     800cce <walk_path+0x76>
  800cca:	84 c0                	test   %al,%al
  800ccc:	75 ed                	jne    800cbb <walk_path+0x63>
			path++;
		if (path - p >= MAXNAMELEN)
  800cce:	89 f3                	mov    %esi,%ebx
  800cd0:	2b 9d 4c ff ff ff    	sub    -0xb4(%ebp),%ebx
  800cd6:	83 fb 7f             	cmp    $0x7f,%ebx
  800cd9:	0f 8f a6 01 00 00    	jg     800e85 <walk_path+0x22d>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800cdf:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ce3:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ced:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  800cf3:	89 14 24             	mov    %edx,(%esp)
  800cf6:	e8 cd 18 00 00       	call   8025c8 <memmove>
		name[path - p] = '\0';
  800cfb:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800d02:	00 
		path = skip_slash(path);
  800d03:	89 f0                	mov    %esi,%eax
  800d05:	e8 92 fb ff ff       	call   80089c <skip_slash>
  800d0a:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)

		if (dir->f_type != FTYPE_DIR)
  800d10:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800d16:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800d1d:	0f 85 69 01 00 00    	jne    800e8c <walk_path+0x234>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800d23:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800d29:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800d2e:	74 24                	je     800d54 <walk_path+0xfc>
  800d30:	c7 44 24 0c b4 44 80 	movl   $0x8044b4,0xc(%esp)
  800d37:	00 
  800d38:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  800d3f:	00 
  800d40:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  800d47:	00 
  800d48:	c7 04 24 02 44 80 00 	movl   $0x804402,(%esp)
  800d4f:	e8 58 10 00 00       	call   801dac <_panic>
	nblock = dir->f_size / BLKSIZE;
  800d54:	89 c2                	mov    %eax,%edx
  800d56:	85 c0                	test   %eax,%eax
  800d58:	79 06                	jns    800d60 <walk_path+0x108>
  800d5a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800d60:	c1 fa 0c             	sar    $0xc,%edx
  800d63:	89 95 48 ff ff ff    	mov    %edx,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800d69:	c7 85 54 ff ff ff 00 	movl   $0x0,-0xac(%ebp)
  800d70:	00 00 00 
  800d73:	eb 62                	jmp    800dd7 <walk_path+0x17f>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800d75:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800d7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d7f:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  800d85:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d89:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800d8f:	89 04 24             	mov    %eax,(%esp)
  800d92:	e8 25 fe ff ff       	call   800bbc <file_get_block>
  800d97:	85 c0                	test   %eax,%eax
  800d99:	78 4c                	js     800de7 <walk_path+0x18f>
			return r;
		f = (struct File*) blk;
  800d9b:	8b bd 64 ff ff ff    	mov    -0x9c(%ebp),%edi
  800da1:	bb 00 00 00 00       	mov    $0x0,%ebx
// and set *pdir to the directory the file is in.
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
  800da6:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
  800da9:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  800daf:	89 54 24 04          	mov    %edx,0x4(%esp)
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800db3:	89 34 24             	mov    %esi,(%esp)
  800db6:	e8 3b 17 00 00       	call   8024f6 <strcmp>
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	0f 84 81 00 00 00    	je     800e44 <walk_path+0x1ec>
  800dc3:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800dc9:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  800dcf:	75 d5                	jne    800da6 <walk_path+0x14e>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800dd1:	ff 85 54 ff ff ff    	incl   -0xac(%ebp)
  800dd7:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800ddd:	39 85 48 ff ff ff    	cmp    %eax,-0xb8(%ebp)
  800de3:	75 90                	jne    800d75 <walk_path+0x11d>
  800de5:	eb 09                	jmp    800df0 <walk_path+0x198>

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800de7:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800dea:	0f 85 a8 00 00 00    	jne    800e98 <walk_path+0x240>
  800df0:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800df6:	80 38 00             	cmpb   $0x0,(%eax)
  800df9:	0f 85 94 00 00 00    	jne    800e93 <walk_path+0x23b>
				if (pdir)
  800dff:	83 bd 44 ff ff ff 00 	cmpl   $0x0,-0xbc(%ebp)
  800e06:	74 0e                	je     800e16 <walk_path+0x1be>
					*pdir = dir;
  800e08:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800e0e:	8b 95 44 ff ff ff    	mov    -0xbc(%ebp),%edx
  800e14:	89 02                	mov    %eax,(%edx)
				if (lastelem)
  800e16:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800e1a:	74 15                	je     800e31 <walk_path+0x1d9>
					strcpy(lastelem, name);
  800e1c:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800e22:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e26:	8b 55 08             	mov    0x8(%ebp),%edx
  800e29:	89 14 24             	mov    %edx,(%esp)
  800e2c:	e8 1e 16 00 00       	call   80244f <strcpy>
				*pf = 0;
  800e31:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800e37:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800e3d:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800e42:	eb 54                	jmp    800e98 <walk_path+0x240>
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800e44:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800e4a:	89 b5 50 ff ff ff    	mov    %esi,-0xb0(%ebp)
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800e50:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  800e56:	80 3a 00             	cmpb   $0x0,(%edx)
  800e59:	0f 85 5f fe ff ff    	jne    800cbe <walk_path+0x66>
			}
			return r;
		}
	}

	if (pdir)
  800e5f:	83 bd 44 ff ff ff 00 	cmpl   $0x0,-0xbc(%ebp)
  800e66:	74 08                	je     800e70 <walk_path+0x218>
		*pdir = dir;
  800e68:	8b 95 44 ff ff ff    	mov    -0xbc(%ebp),%edx
  800e6e:	89 02                	mov    %eax,(%edx)
	*pf = f;
  800e70:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  800e76:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800e7c:	89 10                	mov    %edx,(%eax)
	return 0;
  800e7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e83:	eb 13                	jmp    800e98 <walk_path+0x240>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800e85:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800e8a:	eb 0c                	jmp    800e98 <walk_path+0x240>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800e8c:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800e91:	eb 05                	jmp    800e98 <walk_path+0x240>
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800e93:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800e98:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	83 ec 18             	sub    $0x18,%esp
	return walk_path(path, 0, pf, 0);
  800ea9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebb:	e8 98 fd ff ff       	call   800c58 <walk_path>
}
  800ec0:	c9                   	leave  
  800ec1:	c3                   	ret    

00800ec2 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
  800ec5:	57                   	push   %edi
  800ec6:	56                   	push   %esi
  800ec7:	53                   	push   %ebx
  800ec8:	83 ec 3c             	sub    $0x3c,%esp
  800ecb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ece:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ed1:	8b 45 14             	mov    0x14(%ebp),%eax
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800ed4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ed7:	8b 93 80 00 00 00    	mov    0x80(%ebx),%edx
  800edd:	39 c2                	cmp    %eax,%edx
  800edf:	0f 8e 8a 00 00 00    	jle    800f6f <file_read+0xad>
		return 0;

	count = MIN(count, f->f_size - offset);
  800ee5:	29 c2                	sub    %eax,%edx
  800ee7:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800eea:	39 ca                	cmp    %ecx,%edx
  800eec:	76 03                	jbe    800ef1 <file_read+0x2f>
  800eee:	89 4d d0             	mov    %ecx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800ef1:	89 c3                	mov    %eax,%ebx
  800ef3:	03 45 d0             	add    -0x30(%ebp),%eax
  800ef6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800ef9:	eb 68                	jmp    800f63 <file_read+0xa1>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800efb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800efe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f02:	89 d8                	mov    %ebx,%eax
  800f04:	85 db                	test   %ebx,%ebx
  800f06:	79 06                	jns    800f0e <file_read+0x4c>
  800f08:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800f0e:	c1 f8 0c             	sar    $0xc,%eax
  800f11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f15:	8b 45 08             	mov    0x8(%ebp),%eax
  800f18:	89 04 24             	mov    %eax,(%esp)
  800f1b:	e8 9c fc ff ff       	call   800bbc <file_get_block>
  800f20:	85 c0                	test   %eax,%eax
  800f22:	78 50                	js     800f74 <file_read+0xb2>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800f24:	89 d8                	mov    %ebx,%eax
  800f26:	25 ff 0f 00 80       	and    $0x80000fff,%eax
  800f2b:	79 07                	jns    800f34 <file_read+0x72>
  800f2d:	48                   	dec    %eax
  800f2e:	0d 00 f0 ff ff       	or     $0xfffff000,%eax
  800f33:	40                   	inc    %eax
  800f34:	89 c2                	mov    %eax,%edx
  800f36:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800f3b:	29 c1                	sub    %eax,%ecx
  800f3d:	89 c8                	mov    %ecx,%eax
  800f3f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800f42:	29 f1                	sub    %esi,%ecx
  800f44:	89 c6                	mov    %eax,%esi
  800f46:	39 c8                	cmp    %ecx,%eax
  800f48:	76 02                	jbe    800f4c <file_read+0x8a>
  800f4a:	89 ce                	mov    %ecx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  800f4c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800f50:	03 55 e4             	add    -0x1c(%ebp),%edx
  800f53:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f57:	89 3c 24             	mov    %edi,(%esp)
  800f5a:	e8 69 16 00 00       	call   8025c8 <memmove>
		pos += bn;
  800f5f:	01 f3                	add    %esi,%ebx
		buf += bn;
  800f61:	01 f7                	add    %esi,%edi
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800f63:	89 de                	mov    %ebx,%esi
  800f65:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
  800f68:	72 91                	jb     800efb <file_read+0x39>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800f6a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800f6d:	eb 05                	jmp    800f74 <file_read+0xb2>
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
		return 0;
  800f6f:	b8 00 00 00 00       	mov    $0x0,%eax
		pos += bn;
		buf += bn;
	}

	return count;
}
  800f74:	83 c4 3c             	add    $0x3c,%esp
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	57                   	push   %edi
  800f80:	56                   	push   %esi
  800f81:	53                   	push   %ebx
  800f82:	83 ec 3c             	sub    $0x3c,%esp
  800f85:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800f88:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800f8e:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800f91:	0f 8e 9c 00 00 00    	jle    801033 <file_set_size+0xb7>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800f97:	05 ff 0f 00 00       	add    $0xfff,%eax
  800f9c:	89 c7                	mov    %eax,%edi
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	79 06                	jns    800fa8 <file_set_size+0x2c>
  800fa2:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
  800fa8:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800fab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fae:	05 ff 0f 00 00       	add    $0xfff,%eax
  800fb3:	89 c2                	mov    %eax,%edx
  800fb5:	85 c0                	test   %eax,%eax
  800fb7:	79 06                	jns    800fbf <file_set_size+0x43>
  800fb9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800fbf:	c1 fa 0c             	sar    $0xc,%edx
  800fc2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800fc5:	89 d3                	mov    %edx,%ebx
  800fc7:	eb 44                	jmp    80100d <file_set_size+0x91>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800fc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fd0:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800fd3:	89 da                	mov    %ebx,%edx
  800fd5:	89 f0                	mov    %esi,%eax
  800fd7:	e8 07 fa ff ff       	call   8009e3 <file_block_walk>
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	78 1c                	js     800ffc <file_set_size+0x80>
		return r;
	if (*ptr) {
  800fe0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fe3:	8b 00                	mov    (%eax),%eax
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	74 23                	je     80100c <file_set_size+0x90>
		free_block(*ptr);
  800fe9:	89 04 24             	mov    %eax,(%esp)
  800fec:	e8 4e f9 ff ff       	call   80093f <free_block>
		*ptr = 0;
  800ff1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ff4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800ffa:	eb 10                	jmp    80100c <file_set_size+0x90>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800ffc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801000:	c7 04 24 d1 44 80 00 	movl   $0x8044d1,(%esp)
  801007:	e8 98 0e 00 00       	call   801ea4 <cprintf>
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  80100c:	43                   	inc    %ebx
  80100d:	39 df                	cmp    %ebx,%edi
  80100f:	77 b8                	ja     800fc9 <file_set_size+0x4d>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  801011:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  801015:	77 1c                	ja     801033 <file_set_size+0xb7>
  801017:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  80101d:	85 c0                	test   %eax,%eax
  80101f:	74 12                	je     801033 <file_set_size+0xb7>
		free_block(f->f_indirect);
  801021:	89 04 24             	mov    %eax,(%esp)
  801024:	e8 16 f9 ff ff       	call   80093f <free_block>
		f->f_indirect = 0;
  801029:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  801030:	00 00 00 
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  801033:	8b 45 0c             	mov    0xc(%ebp),%eax
  801036:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  80103c:	89 34 24             	mov    %esi,(%esp)
  80103f:	e8 24 f4 ff ff       	call   800468 <flush_block>
	return 0;
}
  801044:	b8 00 00 00 00       	mov    $0x0,%eax
  801049:	83 c4 3c             	add    $0x3c,%esp
  80104c:	5b                   	pop    %ebx
  80104d:	5e                   	pop    %esi
  80104e:	5f                   	pop    %edi
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    

00801051 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	57                   	push   %edi
  801055:	56                   	push   %esi
  801056:	53                   	push   %ebx
  801057:	83 ec 3c             	sub    $0x3c,%esp
  80105a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80105d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  801060:	8b 45 10             	mov    0x10(%ebp),%eax
  801063:	01 d8                	add    %ebx,%eax
  801065:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801068:	8b 55 08             	mov    0x8(%ebp),%edx
  80106b:	3b 82 80 00 00 00    	cmp    0x80(%edx),%eax
  801071:	76 7a                	jbe    8010ed <file_write+0x9c>
		if ((r = file_set_size(f, offset + count)) < 0)
  801073:	89 44 24 04          	mov    %eax,0x4(%esp)
  801077:	89 14 24             	mov    %edx,(%esp)
  80107a:	e8 fd fe ff ff       	call   800f7c <file_set_size>
  80107f:	85 c0                	test   %eax,%eax
  801081:	79 6a                	jns    8010ed <file_write+0x9c>
  801083:	eb 72                	jmp    8010f7 <file_write+0xa6>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  801085:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801088:	89 54 24 08          	mov    %edx,0x8(%esp)
  80108c:	89 d8                	mov    %ebx,%eax
  80108e:	85 db                	test   %ebx,%ebx
  801090:	79 06                	jns    801098 <file_write+0x47>
  801092:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  801098:	c1 f8 0c             	sar    $0xc,%eax
  80109b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a2:	89 0c 24             	mov    %ecx,(%esp)
  8010a5:	e8 12 fb ff ff       	call   800bbc <file_get_block>
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	78 49                	js     8010f7 <file_write+0xa6>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  8010ae:	89 d8                	mov    %ebx,%eax
  8010b0:	25 ff 0f 00 80       	and    $0x80000fff,%eax
  8010b5:	79 07                	jns    8010be <file_write+0x6d>
  8010b7:	48                   	dec    %eax
  8010b8:	0d 00 f0 ff ff       	or     $0xfffff000,%eax
  8010bd:	40                   	inc    %eax
  8010be:	89 c2                	mov    %eax,%edx
  8010c0:	b9 00 10 00 00       	mov    $0x1000,%ecx
  8010c5:	29 c1                	sub    %eax,%ecx
  8010c7:	89 c8                	mov    %ecx,%eax
  8010c9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8010cc:	29 f1                	sub    %esi,%ecx
  8010ce:	89 c6                	mov    %eax,%esi
  8010d0:	39 c8                	cmp    %ecx,%eax
  8010d2:	76 02                	jbe    8010d6 <file_write+0x85>
  8010d4:	89 ce                	mov    %ecx,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  8010d6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010de:	03 55 e4             	add    -0x1c(%ebp),%edx
  8010e1:	89 14 24             	mov    %edx,(%esp)
  8010e4:	e8 df 14 00 00       	call   8025c8 <memmove>
		pos += bn;
  8010e9:	01 f3                	add    %esi,%ebx
		buf += bn;
  8010eb:	01 f7                	add    %esi,%edi
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  8010ed:	89 de                	mov    %ebx,%esi
  8010ef:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  8010f2:	77 91                	ja     801085 <file_write+0x34>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  8010f4:	8b 45 10             	mov    0x10(%ebp),%eax
}
  8010f7:	83 c4 3c             	add    $0x3c,%esp
  8010fa:	5b                   	pop    %ebx
  8010fb:	5e                   	pop    %esi
  8010fc:	5f                   	pop    %edi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	56                   	push   %esi
  801103:	53                   	push   %ebx
  801104:	83 ec 20             	sub    $0x20,%esp
  801107:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  80110a:	be 00 00 00 00       	mov    $0x0,%esi
  80110f:	eb 35                	jmp    801146 <file_flush+0x47>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  801111:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801118:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  80111b:	89 f2                	mov    %esi,%edx
  80111d:	89 d8                	mov    %ebx,%eax
  80111f:	e8 bf f8 ff ff       	call   8009e3 <file_block_walk>
  801124:	85 c0                	test   %eax,%eax
  801126:	78 1d                	js     801145 <file_flush+0x46>
		    pdiskbno == NULL || *pdiskbno == 0)
  801128:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  80112b:	85 c0                	test   %eax,%eax
  80112d:	74 16                	je     801145 <file_flush+0x46>
		    pdiskbno == NULL || *pdiskbno == 0)
  80112f:	8b 00                	mov    (%eax),%eax
  801131:	85 c0                	test   %eax,%eax
  801133:	74 10                	je     801145 <file_flush+0x46>
			continue;
		flush_block(diskaddr(*pdiskbno));
  801135:	89 04 24             	mov    %eax,(%esp)
  801138:	e8 a1 f2 ff ff       	call   8003de <diskaddr>
  80113d:	89 04 24             	mov    %eax,(%esp)
  801140:	e8 23 f3 ff ff       	call   800468 <flush_block>
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  801145:	46                   	inc    %esi
  801146:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  80114c:	05 ff 0f 00 00       	add    $0xfff,%eax
  801151:	89 c2                	mov    %eax,%edx
  801153:	85 c0                	test   %eax,%eax
  801155:	79 06                	jns    80115d <file_flush+0x5e>
  801157:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  80115d:	c1 fa 0c             	sar    $0xc,%edx
  801160:	39 d6                	cmp    %edx,%esi
  801162:	7c ad                	jl     801111 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  801164:	89 1c 24             	mov    %ebx,(%esp)
  801167:	e8 fc f2 ff ff       	call   800468 <flush_block>
	if (f->f_indirect)
  80116c:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  801172:	85 c0                	test   %eax,%eax
  801174:	74 10                	je     801186 <file_flush+0x87>
		flush_block(diskaddr(f->f_indirect));
  801176:	89 04 24             	mov    %eax,(%esp)
  801179:	e8 60 f2 ff ff       	call   8003de <diskaddr>
  80117e:	89 04 24             	mov    %eax,(%esp)
  801181:	e8 e2 f2 ff ff       	call   800468 <flush_block>
}
  801186:	83 c4 20             	add    $0x20,%esp
  801189:	5b                   	pop    %ebx
  80118a:	5e                   	pop    %esi
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	57                   	push   %edi
  801191:	56                   	push   %esi
  801192:	53                   	push   %ebx
  801193:	81 ec bc 00 00 00    	sub    $0xbc,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  801199:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80119f:	89 04 24             	mov    %eax,(%esp)
  8011a2:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  8011a8:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  8011ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b1:	e8 a2 fa ff ff       	call   800c58 <walk_path>
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	0f 84 dc 00 00 00    	je     80129a <file_create+0x10d>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  8011be:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8011c1:	0f 85 d8 00 00 00    	jne    80129f <file_create+0x112>
  8011c7:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  8011cd:	85 db                	test   %ebx,%ebx
  8011cf:	0f 84 ca 00 00 00    	je     80129f <file_create+0x112>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  8011d5:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  8011db:	a9 ff 0f 00 00       	test   $0xfff,%eax
  8011e0:	74 24                	je     801206 <file_create+0x79>
  8011e2:	c7 44 24 0c b4 44 80 	movl   $0x8044b4,0xc(%esp)
  8011e9:	00 
  8011ea:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  8011f1:	00 
  8011f2:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  8011f9:	00 
  8011fa:	c7 04 24 02 44 80 00 	movl   $0x804402,(%esp)
  801201:	e8 a6 0b 00 00       	call   801dac <_panic>
	nblock = dir->f_size / BLKSIZE;
  801206:	89 c2                	mov    %eax,%edx
  801208:	85 c0                	test   %eax,%eax
  80120a:	79 06                	jns    801212 <file_create+0x85>
  80120c:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  801212:	c1 fa 0c             	sar    $0xc,%edx
  801215:	89 95 54 ff ff ff    	mov    %edx,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  80121b:	be 00 00 00 00       	mov    $0x0,%esi
		if ((r = file_get_block(dir, i, &blk)) < 0)
  801220:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  801226:	eb 38                	jmp    801260 <file_create+0xd3>
  801228:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80122c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801230:	89 1c 24             	mov    %ebx,(%esp)
  801233:	e8 84 f9 ff ff       	call   800bbc <file_get_block>
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 63                	js     80129f <file_create+0x112>
  80123c:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  801242:	ba 00 00 00 00       	mov    $0x0,%edx
			if (f[j].f_name[0] == '\0') {
  801247:	80 38 00             	cmpb   $0x0,(%eax)
  80124a:	75 08                	jne    801254 <file_create+0xc7>
				*file = &f[j];
  80124c:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801252:	eb 56                	jmp    8012aa <file_create+0x11d>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  801254:	42                   	inc    %edx
  801255:	05 00 01 00 00       	add    $0x100,%eax
  80125a:	83 fa 10             	cmp    $0x10,%edx
  80125d:	75 e8                	jne    801247 <file_create+0xba>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  80125f:	46                   	inc    %esi
  801260:	39 b5 54 ff ff ff    	cmp    %esi,-0xac(%ebp)
  801266:	75 c0                	jne    801228 <file_create+0x9b>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  801268:	81 83 80 00 00 00 00 	addl   $0x1000,0x80(%ebx)
  80126f:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  801272:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  801278:	89 44 24 08          	mov    %eax,0x8(%esp)
  80127c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801280:	89 1c 24             	mov    %ebx,(%esp)
  801283:	e8 34 f9 ff ff       	call   800bbc <file_get_block>
  801288:	85 c0                	test   %eax,%eax
  80128a:	78 13                	js     80129f <file_create+0x112>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  80128c:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801292:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801298:	eb 10                	jmp    8012aa <file_create+0x11d>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  80129a:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax

	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  80129f:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  8012a5:	5b                   	pop    %ebx
  8012a6:	5e                   	pop    %esi
  8012a7:	5f                   	pop    %edi
  8012a8:	5d                   	pop    %ebp
  8012a9:	c3                   	ret    
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  8012aa:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8012b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b4:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  8012ba:	89 04 24             	mov    %eax,(%esp)
  8012bd:	e8 8d 11 00 00       	call   80244f <strcpy>
	*pf = f;
  8012c2:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  8012c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cb:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  8012cd:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  8012d3:	89 04 24             	mov    %eax,(%esp)
  8012d6:	e8 24 fe ff ff       	call   8010ff <file_flush>
	return 0;
  8012db:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e0:	eb bd                	jmp    80129f <file_create+0x112>

008012e2 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	53                   	push   %ebx
  8012e6:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  8012e9:	bb 01 00 00 00       	mov    $0x1,%ebx
  8012ee:	eb 11                	jmp    801301 <fs_sync+0x1f>
		flush_block(diskaddr(i));
  8012f0:	89 1c 24             	mov    %ebx,(%esp)
  8012f3:	e8 e6 f0 ff ff       	call   8003de <diskaddr>
  8012f8:	89 04 24             	mov    %eax,(%esp)
  8012fb:	e8 68 f1 ff ff       	call   800468 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801300:	43                   	inc    %ebx
  801301:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  801306:	3b 58 04             	cmp    0x4(%eax),%ebx
  801309:	72 e5                	jb     8012f0 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  80130b:	83 c4 14             	add    $0x14,%esp
  80130e:	5b                   	pop    %ebx
  80130f:	5d                   	pop    %ebp
  801310:	c3                   	ret    
  801311:	00 00                	add    %al,(%eax)
	...

00801314 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  80131a:	e8 c3 ff ff ff       	call   8012e2 <fs_sync>
	return 0;
}
  80131f:	b8 00 00 00 00       	mov    $0x0,%eax
  801324:	c9                   	leave  
  801325:	c3                   	ret    

00801326 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  801329:	ba 60 50 80 00       	mov    $0x805060,%edx

void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
  80132e:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801333:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  801338:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  80133a:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  80133d:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  801343:	40                   	inc    %eax
  801344:	83 c2 10             	add    $0x10,%edx
  801347:	3d 00 04 00 00       	cmp    $0x400,%eax
  80134c:	75 ea                	jne    801338 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  80134e:	5d                   	pop    %ebp
  80134f:	c3                   	ret    

00801350 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	56                   	push   %esi
  801354:	53                   	push   %ebx
  801355:	83 ec 10             	sub    $0x10,%esp
  801358:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80135b:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
}

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
  801360:	89 d8                	mov    %ebx,%eax
  801362:	c1 e0 04             	shl    $0x4,%eax
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
  801365:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  80136b:	89 04 24             	mov    %eax,(%esp)
  80136e:	e8 d5 21 00 00       	call   803548 <pageref>
  801373:	85 c0                	test   %eax,%eax
  801375:	74 07                	je     80137e <openfile_alloc+0x2e>
  801377:	83 f8 01             	cmp    $0x1,%eax
  80137a:	75 62                	jne    8013de <openfile_alloc+0x8e>
  80137c:	eb 27                	jmp    8013a5 <openfile_alloc+0x55>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  80137e:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801385:	00 
  801386:	89 d8                	mov    %ebx,%eax
  801388:	c1 e0 04             	shl    $0x4,%eax
  80138b:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  801391:	89 44 24 04          	mov    %eax,0x4(%esp)
  801395:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80139c:	e8 a0 14 00 00       	call   802841 <sys_page_alloc>
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	78 4b                	js     8013f0 <openfile_alloc+0xa0>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8013a5:	c1 e3 04             	shl    $0x4,%ebx
  8013a8:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  8013ae:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  8013b5:	04 00 00 
			*o = &opentab[i];
  8013b8:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8013ba:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8013c1:	00 
  8013c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013c9:	00 
  8013ca:	8b 83 6c 50 80 00    	mov    0x80506c(%ebx),%eax
  8013d0:	89 04 24             	mov    %eax,(%esp)
  8013d3:	e8 a6 11 00 00       	call   80257e <memset>
			return (*o)->o_fileid;
  8013d8:	8b 06                	mov    (%esi),%eax
  8013da:	8b 00                	mov    (%eax),%eax
  8013dc:	eb 12                	jmp    8013f0 <openfile_alloc+0xa0>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8013de:	43                   	inc    %ebx
  8013df:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8013e5:	0f 85 75 ff ff ff    	jne    801360 <openfile_alloc+0x10>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  8013eb:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	5b                   	pop    %ebx
  8013f4:	5e                   	pop    %esi
  8013f5:	5d                   	pop    %ebp
  8013f6:	c3                   	ret    

008013f7 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	57                   	push   %edi
  8013fb:	56                   	push   %esi
  8013fc:	53                   	push   %ebx
  8013fd:	83 ec 1c             	sub    $0x1c,%esp
  801400:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801403:	89 fe                	mov    %edi,%esi
  801405:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80140b:	c1 e6 04             	shl    $0x4,%esi
  80140e:	8d 9e 60 50 80 00    	lea    0x805060(%esi),%ebx
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801414:	8b 86 6c 50 80 00    	mov    0x80506c(%esi),%eax
  80141a:	89 04 24             	mov    %eax,(%esp)
  80141d:	e8 26 21 00 00       	call   803548 <pageref>
  801422:	83 f8 01             	cmp    $0x1,%eax
  801425:	7e 14                	jle    80143b <openfile_lookup+0x44>
  801427:	39 be 60 50 80 00    	cmp    %edi,0x805060(%esi)
  80142d:	75 13                	jne    801442 <openfile_lookup+0x4b>
		return -E_INVAL;
	*po = o;
  80142f:	8b 45 10             	mov    0x10(%ebp),%eax
  801432:	89 18                	mov    %ebx,(%eax)
	return 0;
  801434:	b8 00 00 00 00       	mov    $0x0,%eax
  801439:	eb 0c                	jmp    801447 <openfile_lookup+0x50>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  80143b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801440:	eb 05                	jmp    801447 <openfile_lookup+0x50>
  801442:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  801447:	83 c4 1c             	add    $0x1c,%esp
  80144a:	5b                   	pop    %ebx
  80144b:	5e                   	pop    %esi
  80144c:	5f                   	pop    %edi
  80144d:	5d                   	pop    %ebp
  80144e:	c3                   	ret    

0080144f <serve_flush>:
}

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801455:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801458:	89 44 24 08          	mov    %eax,0x8(%esp)
  80145c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145f:	8b 00                	mov    (%eax),%eax
  801461:	89 44 24 04          	mov    %eax,0x4(%esp)
  801465:	8b 45 08             	mov    0x8(%ebp),%eax
  801468:	89 04 24             	mov    %eax,(%esp)
  80146b:	e8 87 ff ff ff       	call   8013f7 <openfile_lookup>
  801470:	85 c0                	test   %eax,%eax
  801472:	78 13                	js     801487 <serve_flush+0x38>
		return r;
	file_flush(o->o_file);
  801474:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801477:	8b 40 04             	mov    0x4(%eax),%eax
  80147a:	89 04 24             	mov    %eax,(%esp)
  80147d:	e8 7d fc ff ff       	call   8010ff <file_flush>
	return 0;
  801482:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801487:	c9                   	leave  
  801488:	c3                   	ret    

00801489 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  801489:	55                   	push   %ebp
  80148a:	89 e5                	mov    %esp,%ebp
  80148c:	53                   	push   %ebx
  80148d:	83 ec 24             	sub    $0x24,%esp
  801490:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801493:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801496:	89 44 24 08          	mov    %eax,0x8(%esp)
  80149a:	8b 03                	mov    (%ebx),%eax
  80149c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a3:	89 04 24             	mov    %eax,(%esp)
  8014a6:	e8 4c ff ff ff       	call   8013f7 <openfile_lookup>
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 3f                	js     8014ee <serve_stat+0x65>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8014af:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b2:	8b 40 04             	mov    0x4(%eax),%eax
  8014b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b9:	89 1c 24             	mov    %ebx,(%esp)
  8014bc:	e8 8e 0f 00 00       	call   80244f <strcpy>
	ret->ret_size = o->o_file->f_size;
  8014c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c4:	8b 50 04             	mov    0x4(%eax),%edx
  8014c7:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8014cd:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8014d3:	8b 40 04             	mov    0x4(%eax),%eax
  8014d6:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8014dd:	0f 94 c0             	sete   %al
  8014e0:	0f b6 c0             	movzbl %al,%eax
  8014e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014ee:	83 c4 24             	add    $0x24,%esp
  8014f1:	5b                   	pop    %ebx
  8014f2:	5d                   	pop    %ebp
  8014f3:	c3                   	ret    

008014f4 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	53                   	push   %ebx
  8014f8:	83 ec 24             	sub    $0x24,%esp
  8014fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8014fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801501:	89 44 24 08          	mov    %eax,0x8(%esp)
  801505:	8b 03                	mov    (%ebx),%eax
  801507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150b:	8b 45 08             	mov    0x8(%ebp),%eax
  80150e:	89 04 24             	mov    %eax,(%esp)
  801511:	e8 e1 fe ff ff       	call   8013f7 <openfile_lookup>
  801516:	85 c0                	test   %eax,%eax
  801518:	78 33                	js     80154d <serve_write+0x59>
	{
		return r;
	}
	if ((r = file_write(o->o_file, req->req_buf, req->req_n, o->o_fd->fd_offset)) < 0)
  80151a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151d:	8b 50 0c             	mov    0xc(%eax),%edx
  801520:	8b 52 04             	mov    0x4(%edx),%edx
  801523:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801527:	8b 53 04             	mov    0x4(%ebx),%edx
  80152a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80152e:	83 c3 08             	add    $0x8,%ebx
  801531:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801535:	8b 40 04             	mov    0x4(%eax),%eax
  801538:	89 04 24             	mov    %eax,(%esp)
  80153b:	e8 11 fb ff ff       	call   801051 <file_write>
  801540:	85 c0                	test   %eax,%eax
  801542:	78 09                	js     80154d <serve_write+0x59>
	{
		return r;
	}
	o->o_fd->fd_offset += r;
  801544:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801547:	8b 52 0c             	mov    0xc(%edx),%edx
  80154a:	01 42 04             	add    %eax,0x4(%edx)
	return r;
	// panic("serve_write not implemented");
}
  80154d:	83 c4 24             	add    $0x24,%esp
  801550:	5b                   	pop    %ebx
  801551:	5d                   	pop    %ebp
  801552:	c3                   	ret    

00801553 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	53                   	push   %ebx
  801557:	83 ec 24             	sub    $0x24,%esp
  80155a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	struct OpenFile *o;
	int r;
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80155d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801560:	89 44 24 08          	mov    %eax,0x8(%esp)
  801564:	8b 03                	mov    (%ebx),%eax
  801566:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156a:	8b 45 08             	mov    0x8(%ebp),%eax
  80156d:	89 04 24             	mov    %eax,(%esp)
  801570:	e8 82 fe ff ff       	call   8013f7 <openfile_lookup>
  801575:	85 c0                	test   %eax,%eax
  801577:	78 30                	js     8015a9 <serve_read+0x56>
	{
		return r;
	}
	if ((r = file_read(o->o_file, ret->ret_buf, req->req_n, o->o_fd->fd_offset)) < 0)
  801579:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157c:	8b 50 0c             	mov    0xc(%eax),%edx
  80157f:	8b 52 04             	mov    0x4(%edx),%edx
  801582:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801586:	8b 53 04             	mov    0x4(%ebx),%edx
  801589:	89 54 24 08          	mov    %edx,0x8(%esp)
  80158d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801591:	8b 40 04             	mov    0x4(%eax),%eax
  801594:	89 04 24             	mov    %eax,(%esp)
  801597:	e8 26 f9 ff ff       	call   800ec2 <file_read>
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 09                	js     8015a9 <serve_read+0x56>
	{
		return r;
	}
	o->o_fd->fd_offset += r;
  8015a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a3:	8b 52 0c             	mov    0xc(%edx),%edx
  8015a6:	01 42 04             	add    %eax,0x4(%edx)
	return r;
	//return 0;
}
  8015a9:	83 c4 24             	add    $0x24,%esp
  8015ac:	5b                   	pop    %ebx
  8015ad:	5d                   	pop    %ebp
  8015ae:	c3                   	ret    

008015af <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	53                   	push   %ebx
  8015b3:	83 ec 24             	sub    $0x24,%esp
  8015b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8015b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015c0:	8b 03                	mov    (%ebx),%eax
  8015c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c9:	89 04 24             	mov    %eax,(%esp)
  8015cc:	e8 26 fe ff ff       	call   8013f7 <openfile_lookup>
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	78 15                	js     8015ea <serve_set_size+0x3b>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  8015d5:	8b 43 04             	mov    0x4(%ebx),%eax
  8015d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015df:	8b 40 04             	mov    0x4(%eax),%eax
  8015e2:	89 04 24             	mov    %eax,(%esp)
  8015e5:	e8 92 f9 ff ff       	call   800f7c <file_set_size>
}
  8015ea:	83 c4 24             	add    $0x24,%esp
  8015ed:	5b                   	pop    %ebx
  8015ee:	5d                   	pop    %ebp
  8015ef:	c3                   	ret    

008015f0 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	53                   	push   %ebx
  8015f4:	81 ec 24 04 00 00    	sub    $0x424,%esp
  8015fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  8015fd:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  801604:	00 
  801605:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801609:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80160f:	89 04 24             	mov    %eax,(%esp)
  801612:	e8 b1 0f 00 00       	call   8025c8 <memmove>
	path[MAXPATHLEN-1] = 0;
  801617:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  80161b:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801621:	89 04 24             	mov    %eax,(%esp)
  801624:	e8 27 fd ff ff       	call   801350 <openfile_alloc>
  801629:	85 c0                	test   %eax,%eax
  80162b:	0f 88 f0 00 00 00    	js     801721 <serve_open+0x131>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801631:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801638:	74 32                	je     80166c <serve_open+0x7c>
		if ((r = file_create(path, &f)) < 0) {
  80163a:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801640:	89 44 24 04          	mov    %eax,0x4(%esp)
  801644:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80164a:	89 04 24             	mov    %eax,(%esp)
  80164d:	e8 3b fb ff ff       	call   80118d <file_create>
  801652:	85 c0                	test   %eax,%eax
  801654:	79 36                	jns    80168c <serve_open+0x9c>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801656:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  80165d:	0f 85 be 00 00 00    	jne    801721 <serve_open+0x131>
  801663:	83 f8 f3             	cmp    $0xfffffff3,%eax
  801666:	0f 85 b5 00 00 00    	jne    801721 <serve_open+0x131>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  80166c:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801672:	89 44 24 04          	mov    %eax,0x4(%esp)
  801676:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80167c:	89 04 24             	mov    %eax,(%esp)
  80167f:	e8 1f f8 ff ff       	call   800ea3 <file_open>
  801684:	85 c0                	test   %eax,%eax
  801686:	0f 88 95 00 00 00    	js     801721 <serve_open+0x131>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  80168c:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  801693:	74 1a                	je     8016af <serve_open+0xbf>
		if ((r = file_set_size(f, 0)) < 0) {
  801695:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80169c:	00 
  80169d:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  8016a3:	89 04 24             	mov    %eax,(%esp)
  8016a6:	e8 d1 f8 ff ff       	call   800f7c <file_set_size>
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	78 72                	js     801721 <serve_open+0x131>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8016af:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8016b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b9:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8016bf:	89 04 24             	mov    %eax,(%esp)
  8016c2:	e8 dc f7 ff ff       	call   800ea3 <file_open>
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	78 56                	js     801721 <serve_open+0x131>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  8016cb:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8016d1:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8016d7:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8016da:	8b 50 0c             	mov    0xc(%eax),%edx
  8016dd:	8b 08                	mov    (%eax),%ecx
  8016df:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8016e2:	8b 50 0c             	mov    0xc(%eax),%edx
  8016e5:	8b 8b 00 04 00 00    	mov    0x400(%ebx),%ecx
  8016eb:	83 e1 03             	and    $0x3,%ecx
  8016ee:	89 4a 08             	mov    %ecx,0x8(%edx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  8016f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f4:	8b 15 64 90 80 00    	mov    0x809064,%edx
  8016fa:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  8016fc:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801702:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801708:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  80170b:	8b 50 0c             	mov    0xc(%eax),%edx
  80170e:	8b 45 10             	mov    0x10(%ebp),%eax
  801711:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801713:	8b 45 14             	mov    0x14(%ebp),%eax
  801716:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  80171c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801721:	81 c4 24 04 00 00    	add    $0x424,%esp
  801727:	5b                   	pop    %ebx
  801728:	5d                   	pop    %ebp
  801729:	c3                   	ret    

0080172a <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  80172a:	55                   	push   %ebp
  80172b:	89 e5                	mov    %esp,%ebp
  80172d:	56                   	push   %esi
  80172e:	53                   	push   %ebx
  80172f:	83 ec 20             	sub    $0x20,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801732:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801735:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801738:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80173f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801743:	a1 44 50 80 00       	mov    0x805044,%eax
  801748:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174c:	89 34 24             	mov    %esi,(%esp)
  80174f:	e8 2c 14 00 00       	call   802b80 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801754:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801758:	75 15                	jne    80176f <serve+0x45>
			cprintf("Invalid request from %08x: no argument page\n",
  80175a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801761:	c7 04 24 f0 44 80 00 	movl   $0x8044f0,(%esp)
  801768:	e8 37 07 00 00       	call   801ea4 <cprintf>
				whom);
			continue; // just leave it hanging...
  80176d:	eb c9                	jmp    801738 <serve+0xe>
		}

		pg = NULL;
  80176f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  801776:	83 f8 01             	cmp    $0x1,%eax
  801779:	75 21                	jne    80179c <serve+0x72>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  80177b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80177f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801782:	89 44 24 08          	mov    %eax,0x8(%esp)
  801786:	a1 44 50 80 00       	mov    0x805044,%eax
  80178b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801792:	89 04 24             	mov    %eax,(%esp)
  801795:	e8 56 fe ff ff       	call   8015f0 <serve_open>
  80179a:	eb 3f                	jmp    8017db <serve+0xb1>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  80179c:	83 f8 08             	cmp    $0x8,%eax
  80179f:	77 1e                	ja     8017bf <serve+0x95>
  8017a1:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8017a8:	85 d2                	test   %edx,%edx
  8017aa:	74 13                	je     8017bf <serve+0x95>
			r = handlers[req](whom, fsreq);
  8017ac:	a1 44 50 80 00       	mov    0x805044,%eax
  8017b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b8:	89 04 24             	mov    %eax,(%esp)
  8017bb:	ff d2                	call   *%edx
  8017bd:	eb 1c                	jmp    8017db <serve+0xb1>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8017bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c2:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ca:	c7 04 24 20 45 80 00 	movl   $0x804520,(%esp)
  8017d1:	e8 ce 06 00 00       	call   801ea4 <cprintf>
			r = -E_INVAL;
  8017d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8017db:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017de:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017e2:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8017e5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f0:	89 04 24             	mov    %eax,(%esp)
  8017f3:	e8 f8 13 00 00       	call   802bf0 <ipc_send>
		sys_page_unmap(0, fsreq);
  8017f8:	a1 44 50 80 00       	mov    0x805044,%eax
  8017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801801:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801808:	e8 db 10 00 00       	call   8028e8 <sys_page_unmap>
  80180d:	e9 26 ff ff ff       	jmp    801738 <serve+0xe>

00801812 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801818:	c7 05 60 90 80 00 43 	movl   $0x804543,0x809060
  80181f:	45 80 00 
	cprintf("FS is running\n");
  801822:	c7 04 24 46 45 80 00 	movl   $0x804546,(%esp)
  801829:	e8 76 06 00 00       	call   801ea4 <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80182e:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801833:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801838:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  80183a:	c7 04 24 55 45 80 00 	movl   $0x804555,(%esp)
  801841:	e8 5e 06 00 00       	call   801ea4 <cprintf>

	serve_init();
  801846:	e8 db fa ff ff       	call   801326 <serve_init>
	fs_init();
  80184b:	e8 10 f3 ff ff       	call   800b60 <fs_init>
	serve();
  801850:	e8 d5 fe ff ff       	call   80172a <serve>
  801855:	00 00                	add    %al,(%eax)
	...

00801858 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	53                   	push   %ebx
  80185c:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80185f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801866:	00 
  801867:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  80186e:	00 
  80186f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801876:	e8 c6 0f 00 00       	call   802841 <sys_page_alloc>
  80187b:	85 c0                	test   %eax,%eax
  80187d:	79 20                	jns    80189f <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  80187f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801883:	c7 44 24 08 64 45 80 	movl   $0x804564,0x8(%esp)
  80188a:	00 
  80188b:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  801892:	00 
  801893:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  80189a:	e8 0d 05 00 00       	call   801dac <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  80189f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8018a6:	00 
  8018a7:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8018ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b0:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  8018b7:	e8 0c 0d 00 00       	call   8025c8 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8018bc:	e8 c0 f0 ff ff       	call   800981 <alloc_block>
  8018c1:	85 c0                	test   %eax,%eax
  8018c3:	79 20                	jns    8018e5 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  8018c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018c9:	c7 44 24 08 81 45 80 	movl   $0x804581,0x8(%esp)
  8018d0:	00 
  8018d1:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8018d8:	00 
  8018d9:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  8018e0:	e8 c7 04 00 00       	call   801dac <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8018e5:	89 c2                	mov    %eax,%edx
  8018e7:	85 c0                	test   %eax,%eax
  8018e9:	79 03                	jns    8018ee <fs_test+0x96>
  8018eb:	8d 50 1f             	lea    0x1f(%eax),%edx
  8018ee:	c1 fa 05             	sar    $0x5,%edx
  8018f1:	c1 e2 02             	shl    $0x2,%edx
  8018f4:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8018f9:	79 05                	jns    801900 <fs_test+0xa8>
  8018fb:	48                   	dec    %eax
  8018fc:	83 c8 e0             	or     $0xffffffe0,%eax
  8018ff:	40                   	inc    %eax
  801900:	bb 01 00 00 00       	mov    $0x1,%ebx
  801905:	88 c1                	mov    %al,%cl
  801907:	d3 e3                	shl    %cl,%ebx
  801909:	85 9a 00 10 00 00    	test   %ebx,0x1000(%edx)
  80190f:	75 24                	jne    801935 <fs_test+0xdd>
  801911:	c7 44 24 0c 91 45 80 	movl   $0x804591,0xc(%esp)
  801918:	00 
  801919:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801920:	00 
  801921:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  801928:	00 
  801929:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  801930:	e8 77 04 00 00       	call   801dac <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801935:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  80193b:	85 1c 11             	test   %ebx,(%ecx,%edx,1)
  80193e:	74 24                	je     801964 <fs_test+0x10c>
  801940:	c7 44 24 0c 0c 47 80 	movl   $0x80470c,0xc(%esp)
  801947:	00 
  801948:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  80194f:	00 
  801950:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  801957:	00 
  801958:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  80195f:	e8 48 04 00 00       	call   801dac <_panic>
	cprintf("alloc_block is good\n");
  801964:	c7 04 24 ac 45 80 00 	movl   $0x8045ac,(%esp)
  80196b:	e8 34 05 00 00       	call   801ea4 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801970:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801973:	89 44 24 04          	mov    %eax,0x4(%esp)
  801977:	c7 04 24 c1 45 80 00 	movl   $0x8045c1,(%esp)
  80197e:	e8 20 f5 ff ff       	call   800ea3 <file_open>
  801983:	85 c0                	test   %eax,%eax
  801985:	79 25                	jns    8019ac <fs_test+0x154>
  801987:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80198a:	74 40                	je     8019cc <fs_test+0x174>
		panic("file_open /not-found: %e", r);
  80198c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801990:	c7 44 24 08 cc 45 80 	movl   $0x8045cc,0x8(%esp)
  801997:	00 
  801998:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  80199f:	00 
  8019a0:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  8019a7:	e8 00 04 00 00       	call   801dac <_panic>
	else if (r == 0)
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	75 1c                	jne    8019cc <fs_test+0x174>
		panic("file_open /not-found succeeded!");
  8019b0:	c7 44 24 08 2c 47 80 	movl   $0x80472c,0x8(%esp)
  8019b7:	00 
  8019b8:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8019bf:	00 
  8019c0:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  8019c7:	e8 e0 03 00 00       	call   801dac <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  8019cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d3:	c7 04 24 e5 45 80 00 	movl   $0x8045e5,(%esp)
  8019da:	e8 c4 f4 ff ff       	call   800ea3 <file_open>
  8019df:	85 c0                	test   %eax,%eax
  8019e1:	79 20                	jns    801a03 <fs_test+0x1ab>
		panic("file_open /newmotd: %e", r);
  8019e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019e7:	c7 44 24 08 ee 45 80 	movl   $0x8045ee,0x8(%esp)
  8019ee:	00 
  8019ef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8019f6:	00 
  8019f7:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  8019fe:	e8 a9 03 00 00       	call   801dac <_panic>
	cprintf("file_open is good\n");
  801a03:	c7 04 24 05 46 80 00 	movl   $0x804605,(%esp)
  801a0a:	e8 95 04 00 00       	call   801ea4 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801a0f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a12:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a16:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a1d:	00 
  801a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a21:	89 04 24             	mov    %eax,(%esp)
  801a24:	e8 93 f1 ff ff       	call   800bbc <file_get_block>
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	79 20                	jns    801a4d <fs_test+0x1f5>
		panic("file_get_block: %e", r);
  801a2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a31:	c7 44 24 08 18 46 80 	movl   $0x804618,0x8(%esp)
  801a38:	00 
  801a39:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801a40:	00 
  801a41:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  801a48:	e8 5f 03 00 00       	call   801dac <_panic>
	if (strcmp(blk, msg) != 0)
  801a4d:	c7 44 24 04 4c 47 80 	movl   $0x80474c,0x4(%esp)
  801a54:	00 
  801a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a58:	89 04 24             	mov    %eax,(%esp)
  801a5b:	e8 96 0a 00 00       	call   8024f6 <strcmp>
  801a60:	85 c0                	test   %eax,%eax
  801a62:	74 1c                	je     801a80 <fs_test+0x228>
		panic("file_get_block returned wrong data");
  801a64:	c7 44 24 08 74 47 80 	movl   $0x804774,0x8(%esp)
  801a6b:	00 
  801a6c:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801a73:	00 
  801a74:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  801a7b:	e8 2c 03 00 00       	call   801dac <_panic>
	cprintf("file_get_block is good\n");
  801a80:	c7 04 24 2b 46 80 00 	movl   $0x80462b,(%esp)
  801a87:	e8 18 04 00 00       	call   801ea4 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a8f:	8a 10                	mov    (%eax),%dl
  801a91:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a96:	c1 e8 0c             	shr    $0xc,%eax
  801a99:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801aa0:	a8 40                	test   $0x40,%al
  801aa2:	75 24                	jne    801ac8 <fs_test+0x270>
  801aa4:	c7 44 24 0c 44 46 80 	movl   $0x804644,0xc(%esp)
  801aab:	00 
  801aac:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801ab3:	00 
  801ab4:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  801abb:	00 
  801abc:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  801ac3:	e8 e4 02 00 00       	call   801dac <_panic>
	file_flush(f);
  801ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acb:	89 04 24             	mov    %eax,(%esp)
  801ace:	e8 2c f6 ff ff       	call   8010ff <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ad6:	c1 e8 0c             	shr    $0xc,%eax
  801ad9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ae0:	a8 40                	test   $0x40,%al
  801ae2:	74 24                	je     801b08 <fs_test+0x2b0>
  801ae4:	c7 44 24 0c 43 46 80 	movl   $0x804643,0xc(%esp)
  801aeb:	00 
  801aec:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801af3:	00 
  801af4:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801afb:	00 
  801afc:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  801b03:	e8 a4 02 00 00       	call   801dac <_panic>
	cprintf("file_flush is good\n");
  801b08:	c7 04 24 5f 46 80 00 	movl   $0x80465f,(%esp)
  801b0f:	e8 90 03 00 00       	call   801ea4 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801b14:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b1b:	00 
  801b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1f:	89 04 24             	mov    %eax,(%esp)
  801b22:	e8 55 f4 ff ff       	call   800f7c <file_set_size>
  801b27:	85 c0                	test   %eax,%eax
  801b29:	79 20                	jns    801b4b <fs_test+0x2f3>
		panic("file_set_size: %e", r);
  801b2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b2f:	c7 44 24 08 73 46 80 	movl   $0x804673,0x8(%esp)
  801b36:	00 
  801b37:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  801b3e:	00 
  801b3f:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  801b46:	e8 61 02 00 00       	call   801dac <_panic>
	assert(f->f_direct[0] == 0);
  801b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4e:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801b55:	74 24                	je     801b7b <fs_test+0x323>
  801b57:	c7 44 24 0c 85 46 80 	movl   $0x804685,0xc(%esp)
  801b5e:	00 
  801b5f:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801b66:	00 
  801b67:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801b6e:	00 
  801b6f:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  801b76:	e8 31 02 00 00       	call   801dac <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801b7b:	c1 e8 0c             	shr    $0xc,%eax
  801b7e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b85:	a8 40                	test   $0x40,%al
  801b87:	74 24                	je     801bad <fs_test+0x355>
  801b89:	c7 44 24 0c 99 46 80 	movl   $0x804699,0xc(%esp)
  801b90:	00 
  801b91:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801b98:	00 
  801b99:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801ba0:	00 
  801ba1:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  801ba8:	e8 ff 01 00 00       	call   801dac <_panic>
	cprintf("file_truncate is good\n");
  801bad:	c7 04 24 b3 46 80 00 	movl   $0x8046b3,(%esp)
  801bb4:	e8 eb 02 00 00       	call   801ea4 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801bb9:	c7 04 24 4c 47 80 00 	movl   $0x80474c,(%esp)
  801bc0:	e8 57 08 00 00       	call   80241c <strlen>
  801bc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcc:	89 04 24             	mov    %eax,(%esp)
  801bcf:	e8 a8 f3 ff ff       	call   800f7c <file_set_size>
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	79 20                	jns    801bf8 <fs_test+0x3a0>
		panic("file_set_size 2: %e", r);
  801bd8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bdc:	c7 44 24 08 ca 46 80 	movl   $0x8046ca,0x8(%esp)
  801be3:	00 
  801be4:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801beb:	00 
  801bec:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  801bf3:	e8 b4 01 00 00       	call   801dac <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfb:	89 c2                	mov    %eax,%edx
  801bfd:	c1 ea 0c             	shr    $0xc,%edx
  801c00:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c07:	f6 c2 40             	test   $0x40,%dl
  801c0a:	74 24                	je     801c30 <fs_test+0x3d8>
  801c0c:	c7 44 24 0c 99 46 80 	movl   $0x804699,0xc(%esp)
  801c13:	00 
  801c14:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801c1b:	00 
  801c1c:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801c23:	00 
  801c24:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  801c2b:	e8 7c 01 00 00       	call   801dac <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801c30:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801c33:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c37:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c3e:	00 
  801c3f:	89 04 24             	mov    %eax,(%esp)
  801c42:	e8 75 ef ff ff       	call   800bbc <file_get_block>
  801c47:	85 c0                	test   %eax,%eax
  801c49:	79 20                	jns    801c6b <fs_test+0x413>
		panic("file_get_block 2: %e", r);
  801c4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c4f:	c7 44 24 08 de 46 80 	movl   $0x8046de,0x8(%esp)
  801c56:	00 
  801c57:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  801c5e:	00 
  801c5f:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  801c66:	e8 41 01 00 00       	call   801dac <_panic>
	strcpy(blk, msg);
  801c6b:	c7 44 24 04 4c 47 80 	movl   $0x80474c,0x4(%esp)
  801c72:	00 
  801c73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c76:	89 04 24             	mov    %eax,(%esp)
  801c79:	e8 d1 07 00 00       	call   80244f <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801c7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c81:	c1 e8 0c             	shr    $0xc,%eax
  801c84:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801c8b:	a8 40                	test   $0x40,%al
  801c8d:	75 24                	jne    801cb3 <fs_test+0x45b>
  801c8f:	c7 44 24 0c 44 46 80 	movl   $0x804644,0xc(%esp)
  801c96:	00 
  801c97:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801c9e:	00 
  801c9f:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801ca6:	00 
  801ca7:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  801cae:	e8 f9 00 00 00       	call   801dac <_panic>
	file_flush(f);
  801cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb6:	89 04 24             	mov    %eax,(%esp)
  801cb9:	e8 41 f4 ff ff       	call   8010ff <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801cbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc1:	c1 e8 0c             	shr    $0xc,%eax
  801cc4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ccb:	a8 40                	test   $0x40,%al
  801ccd:	74 24                	je     801cf3 <fs_test+0x49b>
  801ccf:	c7 44 24 0c 43 46 80 	movl   $0x804643,0xc(%esp)
  801cd6:	00 
  801cd7:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801cde:	00 
  801cdf:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801ce6:	00 
  801ce7:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  801cee:	e8 b9 00 00 00       	call   801dac <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf6:	c1 e8 0c             	shr    $0xc,%eax
  801cf9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d00:	a8 40                	test   $0x40,%al
  801d02:	74 24                	je     801d28 <fs_test+0x4d0>
  801d04:	c7 44 24 0c 99 46 80 	movl   $0x804699,0xc(%esp)
  801d0b:	00 
  801d0c:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  801d13:	00 
  801d14:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801d1b:	00 
  801d1c:	c7 04 24 77 45 80 00 	movl   $0x804577,(%esp)
  801d23:	e8 84 00 00 00       	call   801dac <_panic>
	cprintf("file rewrite is good\n");
  801d28:	c7 04 24 f3 46 80 00 	movl   $0x8046f3,(%esp)
  801d2f:	e8 70 01 00 00       	call   801ea4 <cprintf>
}
  801d34:	83 c4 24             	add    $0x24,%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    
	...

00801d3c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	56                   	push   %esi
  801d40:	53                   	push   %ebx
  801d41:	83 ec 10             	sub    $0x10,%esp
  801d44:	8b 75 08             	mov    0x8(%ebp),%esi
  801d47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  801d4a:	e8 b4 0a 00 00       	call   802803 <sys_getenvid>
  801d4f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801d54:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801d5b:	c1 e0 07             	shl    $0x7,%eax
  801d5e:	29 d0                	sub    %edx,%eax
  801d60:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d65:	a3 10 a0 80 00       	mov    %eax,0x80a010


	// save the name of the program so that panic() can use it
	if (argc > 0)
  801d6a:	85 f6                	test   %esi,%esi
  801d6c:	7e 07                	jle    801d75 <libmain+0x39>
		binaryname = argv[0];
  801d6e:	8b 03                	mov    (%ebx),%eax
  801d70:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801d75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d79:	89 34 24             	mov    %esi,(%esp)
  801d7c:	e8 91 fa ff ff       	call   801812 <umain>

	// exit gracefully
	exit();
  801d81:	e8 0a 00 00 00       	call   801d90 <exit>
}
  801d86:	83 c4 10             	add    $0x10,%esp
  801d89:	5b                   	pop    %ebx
  801d8a:	5e                   	pop    %esi
  801d8b:	5d                   	pop    %ebp
  801d8c:	c3                   	ret    
  801d8d:	00 00                	add    %al,(%eax)
	...

00801d90 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	83 ec 18             	sub    $0x18,%esp
	close_all();
  801d96:	e8 04 11 00 00       	call   802e9f <close_all>
	sys_env_destroy(0);
  801d9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801da2:	e8 0a 0a 00 00       	call   8027b1 <sys_env_destroy>
}
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    
  801da9:	00 00                	add    %al,(%eax)
	...

00801dac <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801dac:	55                   	push   %ebp
  801dad:	89 e5                	mov    %esp,%ebp
  801daf:	56                   	push   %esi
  801db0:	53                   	push   %ebx
  801db1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801db4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801db7:	8b 1d 60 90 80 00    	mov    0x809060,%ebx
  801dbd:	e8 41 0a 00 00       	call   802803 <sys_getenvid>
  801dc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc5:	89 54 24 10          	mov    %edx,0x10(%esp)
  801dc9:	8b 55 08             	mov    0x8(%ebp),%edx
  801dcc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801dd0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd8:	c7 04 24 a4 47 80 00 	movl   $0x8047a4,(%esp)
  801ddf:	e8 c0 00 00 00       	call   801ea4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801de4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801de8:	8b 45 10             	mov    0x10(%ebp),%eax
  801deb:	89 04 24             	mov    %eax,(%esp)
  801dee:	e8 50 00 00 00       	call   801e43 <vcprintf>
	cprintf("\n");
  801df3:	c7 04 24 99 43 80 00 	movl   $0x804399,(%esp)
  801dfa:	e8 a5 00 00 00       	call   801ea4 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dff:	cc                   	int3   
  801e00:	eb fd                	jmp    801dff <_panic+0x53>
	...

00801e04 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	53                   	push   %ebx
  801e08:	83 ec 14             	sub    $0x14,%esp
  801e0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801e0e:	8b 03                	mov    (%ebx),%eax
  801e10:	8b 55 08             	mov    0x8(%ebp),%edx
  801e13:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801e17:	40                   	inc    %eax
  801e18:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801e1a:	3d ff 00 00 00       	cmp    $0xff,%eax
  801e1f:	75 19                	jne    801e3a <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801e21:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801e28:	00 
  801e29:	8d 43 08             	lea    0x8(%ebx),%eax
  801e2c:	89 04 24             	mov    %eax,(%esp)
  801e2f:	e8 40 09 00 00       	call   802774 <sys_cputs>
		b->idx = 0;
  801e34:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801e3a:	ff 43 04             	incl   0x4(%ebx)
}
  801e3d:	83 c4 14             	add    $0x14,%esp
  801e40:	5b                   	pop    %ebx
  801e41:	5d                   	pop    %ebp
  801e42:	c3                   	ret    

00801e43 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801e43:	55                   	push   %ebp
  801e44:	89 e5                	mov    %esp,%ebp
  801e46:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801e4c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801e53:	00 00 00 
	b.cnt = 0;
  801e56:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801e5d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801e60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e63:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e67:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e6e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801e74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e78:	c7 04 24 04 1e 80 00 	movl   $0x801e04,(%esp)
  801e7f:	e8 82 01 00 00       	call   802006 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801e84:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801e8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801e94:	89 04 24             	mov    %eax,(%esp)
  801e97:	e8 d8 08 00 00       	call   802774 <sys_cputs>

	return b.cnt;
}
  801e9c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801ea2:	c9                   	leave  
  801ea3:	c3                   	ret    

00801ea4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801eaa:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801ead:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb4:	89 04 24             	mov    %eax,(%esp)
  801eb7:	e8 87 ff ff ff       	call   801e43 <vcprintf>
	va_end(ap);

	return cnt;
}
  801ebc:	c9                   	leave  
  801ebd:	c3                   	ret    
	...

00801ec0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	57                   	push   %edi
  801ec4:	56                   	push   %esi
  801ec5:	53                   	push   %ebx
  801ec6:	83 ec 3c             	sub    $0x3c,%esp
  801ec9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ecc:	89 d7                	mov    %edx,%edi
  801ece:	8b 45 08             	mov    0x8(%ebp),%eax
  801ed1:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801ed4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ed7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801eda:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801edd:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	75 08                	jne    801eec <printnum+0x2c>
  801ee4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801ee7:	39 45 10             	cmp    %eax,0x10(%ebp)
  801eea:	77 57                	ja     801f43 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801eec:	89 74 24 10          	mov    %esi,0x10(%esp)
  801ef0:	4b                   	dec    %ebx
  801ef1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801ef5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ef8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801efc:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801f00:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801f04:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f0b:	00 
  801f0c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801f0f:	89 04 24             	mov    %eax,(%esp)
  801f12:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f19:	e8 82 20 00 00       	call   803fa0 <__udivdi3>
  801f1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f22:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801f26:	89 04 24             	mov    %eax,(%esp)
  801f29:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f2d:	89 fa                	mov    %edi,%edx
  801f2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f32:	e8 89 ff ff ff       	call   801ec0 <printnum>
  801f37:	eb 0f                	jmp    801f48 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801f39:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f3d:	89 34 24             	mov    %esi,(%esp)
  801f40:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801f43:	4b                   	dec    %ebx
  801f44:	85 db                	test   %ebx,%ebx
  801f46:	7f f1                	jg     801f39 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801f48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f4c:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f50:	8b 45 10             	mov    0x10(%ebp),%eax
  801f53:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f57:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f5e:	00 
  801f5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801f62:	89 04 24             	mov    %eax,(%esp)
  801f65:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f68:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6c:	e8 4f 21 00 00       	call   8040c0 <__umoddi3>
  801f71:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f75:	0f be 80 c7 47 80 00 	movsbl 0x8047c7(%eax),%eax
  801f7c:	89 04 24             	mov    %eax,(%esp)
  801f7f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801f82:	83 c4 3c             	add    $0x3c,%esp
  801f85:	5b                   	pop    %ebx
  801f86:	5e                   	pop    %esi
  801f87:	5f                   	pop    %edi
  801f88:	5d                   	pop    %ebp
  801f89:	c3                   	ret    

00801f8a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801f8d:	83 fa 01             	cmp    $0x1,%edx
  801f90:	7e 0e                	jle    801fa0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801f92:	8b 10                	mov    (%eax),%edx
  801f94:	8d 4a 08             	lea    0x8(%edx),%ecx
  801f97:	89 08                	mov    %ecx,(%eax)
  801f99:	8b 02                	mov    (%edx),%eax
  801f9b:	8b 52 04             	mov    0x4(%edx),%edx
  801f9e:	eb 22                	jmp    801fc2 <getuint+0x38>
	else if (lflag)
  801fa0:	85 d2                	test   %edx,%edx
  801fa2:	74 10                	je     801fb4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801fa4:	8b 10                	mov    (%eax),%edx
  801fa6:	8d 4a 04             	lea    0x4(%edx),%ecx
  801fa9:	89 08                	mov    %ecx,(%eax)
  801fab:	8b 02                	mov    (%edx),%eax
  801fad:	ba 00 00 00 00       	mov    $0x0,%edx
  801fb2:	eb 0e                	jmp    801fc2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801fb4:	8b 10                	mov    (%eax),%edx
  801fb6:	8d 4a 04             	lea    0x4(%edx),%ecx
  801fb9:	89 08                	mov    %ecx,(%eax)
  801fbb:	8b 02                	mov    (%edx),%eax
  801fbd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801fc2:	5d                   	pop    %ebp
  801fc3:	c3                   	ret    

00801fc4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801fca:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801fcd:	8b 10                	mov    (%eax),%edx
  801fcf:	3b 50 04             	cmp    0x4(%eax),%edx
  801fd2:	73 08                	jae    801fdc <sprintputch+0x18>
		*b->buf++ = ch;
  801fd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fd7:	88 0a                	mov    %cl,(%edx)
  801fd9:	42                   	inc    %edx
  801fda:	89 10                	mov    %edx,(%eax)
}
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    

00801fde <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801fe4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801fe7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801feb:	8b 45 10             	mov    0x10(%ebp),%eax
  801fee:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffc:	89 04 24             	mov    %eax,(%esp)
  801fff:	e8 02 00 00 00       	call   802006 <vprintfmt>
	va_end(ap);
}
  802004:	c9                   	leave  
  802005:	c3                   	ret    

00802006 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	57                   	push   %edi
  80200a:	56                   	push   %esi
  80200b:	53                   	push   %ebx
  80200c:	83 ec 4c             	sub    $0x4c,%esp
  80200f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802012:	8b 75 10             	mov    0x10(%ebp),%esi
  802015:	eb 12                	jmp    802029 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  802017:	85 c0                	test   %eax,%eax
  802019:	0f 84 6b 03 00 00    	je     80238a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  80201f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802023:	89 04 24             	mov    %eax,(%esp)
  802026:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  802029:	0f b6 06             	movzbl (%esi),%eax
  80202c:	46                   	inc    %esi
  80202d:	83 f8 25             	cmp    $0x25,%eax
  802030:	75 e5                	jne    802017 <vprintfmt+0x11>
  802032:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  802036:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  80203d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  802042:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  802049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80204e:	eb 26                	jmp    802076 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802050:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  802053:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  802057:	eb 1d                	jmp    802076 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802059:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80205c:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  802060:	eb 14                	jmp    802076 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802062:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  802065:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80206c:	eb 08                	jmp    802076 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80206e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  802071:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802076:	0f b6 06             	movzbl (%esi),%eax
  802079:	8d 56 01             	lea    0x1(%esi),%edx
  80207c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80207f:	8a 16                	mov    (%esi),%dl
  802081:	83 ea 23             	sub    $0x23,%edx
  802084:	80 fa 55             	cmp    $0x55,%dl
  802087:	0f 87 e1 02 00 00    	ja     80236e <vprintfmt+0x368>
  80208d:	0f b6 d2             	movzbl %dl,%edx
  802090:	ff 24 95 00 49 80 00 	jmp    *0x804900(,%edx,4)
  802097:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80209a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80209f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8020a2:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8020a6:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8020a9:	8d 50 d0             	lea    -0x30(%eax),%edx
  8020ac:	83 fa 09             	cmp    $0x9,%edx
  8020af:	77 2a                	ja     8020db <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8020b1:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8020b2:	eb eb                	jmp    80209f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8020b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8020b7:	8d 50 04             	lea    0x4(%eax),%edx
  8020ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8020bd:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8020c2:	eb 17                	jmp    8020db <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8020c4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8020c8:	78 98                	js     802062 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8020cd:	eb a7                	jmp    802076 <vprintfmt+0x70>
  8020cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8020d2:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8020d9:	eb 9b                	jmp    802076 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8020db:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8020df:	79 95                	jns    802076 <vprintfmt+0x70>
  8020e1:	eb 8b                	jmp    80206e <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8020e3:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8020e7:	eb 8d                	jmp    802076 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8020e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8020ec:	8d 50 04             	lea    0x4(%eax),%edx
  8020ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8020f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020f6:	8b 00                	mov    (%eax),%eax
  8020f8:	89 04 24             	mov    %eax,(%esp)
  8020fb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8020fe:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  802101:	e9 23 ff ff ff       	jmp    802029 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  802106:	8b 45 14             	mov    0x14(%ebp),%eax
  802109:	8d 50 04             	lea    0x4(%eax),%edx
  80210c:	89 55 14             	mov    %edx,0x14(%ebp)
  80210f:	8b 00                	mov    (%eax),%eax
  802111:	85 c0                	test   %eax,%eax
  802113:	79 02                	jns    802117 <vprintfmt+0x111>
  802115:	f7 d8                	neg    %eax
  802117:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  802119:	83 f8 10             	cmp    $0x10,%eax
  80211c:	7f 0b                	jg     802129 <vprintfmt+0x123>
  80211e:	8b 04 85 60 4a 80 00 	mov    0x804a60(,%eax,4),%eax
  802125:	85 c0                	test   %eax,%eax
  802127:	75 23                	jne    80214c <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  802129:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80212d:	c7 44 24 08 df 47 80 	movl   $0x8047df,0x8(%esp)
  802134:	00 
  802135:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802139:	8b 45 08             	mov    0x8(%ebp),%eax
  80213c:	89 04 24             	mov    %eax,(%esp)
  80213f:	e8 9a fe ff ff       	call   801fde <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802144:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  802147:	e9 dd fe ff ff       	jmp    802029 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  80214c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802150:	c7 44 24 08 4f 42 80 	movl   $0x80424f,0x8(%esp)
  802157:	00 
  802158:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80215c:	8b 55 08             	mov    0x8(%ebp),%edx
  80215f:	89 14 24             	mov    %edx,(%esp)
  802162:	e8 77 fe ff ff       	call   801fde <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802167:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80216a:	e9 ba fe ff ff       	jmp    802029 <vprintfmt+0x23>
  80216f:	89 f9                	mov    %edi,%ecx
  802171:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802174:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  802177:	8b 45 14             	mov    0x14(%ebp),%eax
  80217a:	8d 50 04             	lea    0x4(%eax),%edx
  80217d:	89 55 14             	mov    %edx,0x14(%ebp)
  802180:	8b 30                	mov    (%eax),%esi
  802182:	85 f6                	test   %esi,%esi
  802184:	75 05                	jne    80218b <vprintfmt+0x185>
				p = "(null)";
  802186:	be d8 47 80 00       	mov    $0x8047d8,%esi
			if (width > 0 && padc != '-')
  80218b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80218f:	0f 8e 84 00 00 00    	jle    802219 <vprintfmt+0x213>
  802195:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  802199:	74 7e                	je     802219 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80219b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80219f:	89 34 24             	mov    %esi,(%esp)
  8021a2:	e8 8b 02 00 00       	call   802432 <strnlen>
  8021a7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8021aa:	29 c2                	sub    %eax,%edx
  8021ac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8021af:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8021b3:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8021b6:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8021b9:	89 de                	mov    %ebx,%esi
  8021bb:	89 d3                	mov    %edx,%ebx
  8021bd:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8021bf:	eb 0b                	jmp    8021cc <vprintfmt+0x1c6>
					putch(padc, putdat);
  8021c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021c5:	89 3c 24             	mov    %edi,(%esp)
  8021c8:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8021cb:	4b                   	dec    %ebx
  8021cc:	85 db                	test   %ebx,%ebx
  8021ce:	7f f1                	jg     8021c1 <vprintfmt+0x1bb>
  8021d0:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8021d3:	89 f3                	mov    %esi,%ebx
  8021d5:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8021d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021db:	85 c0                	test   %eax,%eax
  8021dd:	79 05                	jns    8021e4 <vprintfmt+0x1de>
  8021df:	b8 00 00 00 00       	mov    $0x0,%eax
  8021e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8021e7:	29 c2                	sub    %eax,%edx
  8021e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8021ec:	eb 2b                	jmp    802219 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8021ee:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8021f2:	74 18                	je     80220c <vprintfmt+0x206>
  8021f4:	8d 50 e0             	lea    -0x20(%eax),%edx
  8021f7:	83 fa 5e             	cmp    $0x5e,%edx
  8021fa:	76 10                	jbe    80220c <vprintfmt+0x206>
					putch('?', putdat);
  8021fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802200:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  802207:	ff 55 08             	call   *0x8(%ebp)
  80220a:	eb 0a                	jmp    802216 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80220c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802210:	89 04 24             	mov    %eax,(%esp)
  802213:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  802216:	ff 4d e4             	decl   -0x1c(%ebp)
  802219:	0f be 06             	movsbl (%esi),%eax
  80221c:	46                   	inc    %esi
  80221d:	85 c0                	test   %eax,%eax
  80221f:	74 21                	je     802242 <vprintfmt+0x23c>
  802221:	85 ff                	test   %edi,%edi
  802223:	78 c9                	js     8021ee <vprintfmt+0x1e8>
  802225:	4f                   	dec    %edi
  802226:	79 c6                	jns    8021ee <vprintfmt+0x1e8>
  802228:	8b 7d 08             	mov    0x8(%ebp),%edi
  80222b:	89 de                	mov    %ebx,%esi
  80222d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  802230:	eb 18                	jmp    80224a <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  802232:	89 74 24 04          	mov    %esi,0x4(%esp)
  802236:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80223d:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80223f:	4b                   	dec    %ebx
  802240:	eb 08                	jmp    80224a <vprintfmt+0x244>
  802242:	8b 7d 08             	mov    0x8(%ebp),%edi
  802245:	89 de                	mov    %ebx,%esi
  802247:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80224a:	85 db                	test   %ebx,%ebx
  80224c:	7f e4                	jg     802232 <vprintfmt+0x22c>
  80224e:	89 7d 08             	mov    %edi,0x8(%ebp)
  802251:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802253:	8b 75 e0             	mov    -0x20(%ebp),%esi
  802256:	e9 ce fd ff ff       	jmp    802029 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80225b:	83 f9 01             	cmp    $0x1,%ecx
  80225e:	7e 10                	jle    802270 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  802260:	8b 45 14             	mov    0x14(%ebp),%eax
  802263:	8d 50 08             	lea    0x8(%eax),%edx
  802266:	89 55 14             	mov    %edx,0x14(%ebp)
  802269:	8b 30                	mov    (%eax),%esi
  80226b:	8b 78 04             	mov    0x4(%eax),%edi
  80226e:	eb 26                	jmp    802296 <vprintfmt+0x290>
	else if (lflag)
  802270:	85 c9                	test   %ecx,%ecx
  802272:	74 12                	je     802286 <vprintfmt+0x280>
		return va_arg(*ap, long);
  802274:	8b 45 14             	mov    0x14(%ebp),%eax
  802277:	8d 50 04             	lea    0x4(%eax),%edx
  80227a:	89 55 14             	mov    %edx,0x14(%ebp)
  80227d:	8b 30                	mov    (%eax),%esi
  80227f:	89 f7                	mov    %esi,%edi
  802281:	c1 ff 1f             	sar    $0x1f,%edi
  802284:	eb 10                	jmp    802296 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  802286:	8b 45 14             	mov    0x14(%ebp),%eax
  802289:	8d 50 04             	lea    0x4(%eax),%edx
  80228c:	89 55 14             	mov    %edx,0x14(%ebp)
  80228f:	8b 30                	mov    (%eax),%esi
  802291:	89 f7                	mov    %esi,%edi
  802293:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  802296:	85 ff                	test   %edi,%edi
  802298:	78 0a                	js     8022a4 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80229a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80229f:	e9 8c 00 00 00       	jmp    802330 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8022a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022a8:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8022af:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8022b2:	f7 de                	neg    %esi
  8022b4:	83 d7 00             	adc    $0x0,%edi
  8022b7:	f7 df                	neg    %edi
			}
			base = 10;
  8022b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8022be:	eb 70                	jmp    802330 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8022c0:	89 ca                	mov    %ecx,%edx
  8022c2:	8d 45 14             	lea    0x14(%ebp),%eax
  8022c5:	e8 c0 fc ff ff       	call   801f8a <getuint>
  8022ca:	89 c6                	mov    %eax,%esi
  8022cc:	89 d7                	mov    %edx,%edi
			base = 10;
  8022ce:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8022d3:	eb 5b                	jmp    802330 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  8022d5:	89 ca                	mov    %ecx,%edx
  8022d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8022da:	e8 ab fc ff ff       	call   801f8a <getuint>
  8022df:	89 c6                	mov    %eax,%esi
  8022e1:	89 d7                	mov    %edx,%edi
			base = 8;
  8022e3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8022e8:	eb 46                	jmp    802330 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8022ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022ee:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8022f5:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8022f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022fc:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  802303:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  802306:	8b 45 14             	mov    0x14(%ebp),%eax
  802309:	8d 50 04             	lea    0x4(%eax),%edx
  80230c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80230f:	8b 30                	mov    (%eax),%esi
  802311:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  802316:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80231b:	eb 13                	jmp    802330 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80231d:	89 ca                	mov    %ecx,%edx
  80231f:	8d 45 14             	lea    0x14(%ebp),%eax
  802322:	e8 63 fc ff ff       	call   801f8a <getuint>
  802327:	89 c6                	mov    %eax,%esi
  802329:	89 d7                	mov    %edx,%edi
			base = 16;
  80232b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  802330:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  802334:	89 54 24 10          	mov    %edx,0x10(%esp)
  802338:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80233b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80233f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802343:	89 34 24             	mov    %esi,(%esp)
  802346:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80234a:	89 da                	mov    %ebx,%edx
  80234c:	8b 45 08             	mov    0x8(%ebp),%eax
  80234f:	e8 6c fb ff ff       	call   801ec0 <printnum>
			break;
  802354:	8b 75 e0             	mov    -0x20(%ebp),%esi
  802357:	e9 cd fc ff ff       	jmp    802029 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80235c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802360:	89 04 24             	mov    %eax,(%esp)
  802363:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802366:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  802369:	e9 bb fc ff ff       	jmp    802029 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80236e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802372:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  802379:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80237c:	eb 01                	jmp    80237f <vprintfmt+0x379>
  80237e:	4e                   	dec    %esi
  80237f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  802383:	75 f9                	jne    80237e <vprintfmt+0x378>
  802385:	e9 9f fc ff ff       	jmp    802029 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80238a:	83 c4 4c             	add    $0x4c,%esp
  80238d:	5b                   	pop    %ebx
  80238e:	5e                   	pop    %esi
  80238f:	5f                   	pop    %edi
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    

00802392 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802392:	55                   	push   %ebp
  802393:	89 e5                	mov    %esp,%ebp
  802395:	83 ec 28             	sub    $0x28,%esp
  802398:	8b 45 08             	mov    0x8(%ebp),%eax
  80239b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80239e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8023a1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8023a5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8023a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8023af:	85 c0                	test   %eax,%eax
  8023b1:	74 30                	je     8023e3 <vsnprintf+0x51>
  8023b3:	85 d2                	test   %edx,%edx
  8023b5:	7e 33                	jle    8023ea <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8023b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8023ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023be:	8b 45 10             	mov    0x10(%ebp),%eax
  8023c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023c5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8023c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023cc:	c7 04 24 c4 1f 80 00 	movl   $0x801fc4,(%esp)
  8023d3:	e8 2e fc ff ff       	call   802006 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8023d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8023db:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8023de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023e1:	eb 0c                	jmp    8023ef <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8023e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8023e8:	eb 05                	jmp    8023ef <vsnprintf+0x5d>
  8023ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8023ef:	c9                   	leave  
  8023f0:	c3                   	ret    

008023f1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8023f1:	55                   	push   %ebp
  8023f2:	89 e5                	mov    %esp,%ebp
  8023f4:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8023f7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8023fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023fe:	8b 45 10             	mov    0x10(%ebp),%eax
  802401:	89 44 24 08          	mov    %eax,0x8(%esp)
  802405:	8b 45 0c             	mov    0xc(%ebp),%eax
  802408:	89 44 24 04          	mov    %eax,0x4(%esp)
  80240c:	8b 45 08             	mov    0x8(%ebp),%eax
  80240f:	89 04 24             	mov    %eax,(%esp)
  802412:	e8 7b ff ff ff       	call   802392 <vsnprintf>
	va_end(ap);

	return rc;
}
  802417:	c9                   	leave  
  802418:	c3                   	ret    
  802419:	00 00                	add    %al,(%eax)
	...

0080241c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80241c:	55                   	push   %ebp
  80241d:	89 e5                	mov    %esp,%ebp
  80241f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802422:	b8 00 00 00 00       	mov    $0x0,%eax
  802427:	eb 01                	jmp    80242a <strlen+0xe>
		n++;
  802429:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80242a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80242e:	75 f9                	jne    802429 <strlen+0xd>
		n++;
	return n;
}
  802430:	5d                   	pop    %ebp
  802431:	c3                   	ret    

00802432 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802432:	55                   	push   %ebp
  802433:	89 e5                	mov    %esp,%ebp
  802435:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  802438:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80243b:	b8 00 00 00 00       	mov    $0x0,%eax
  802440:	eb 01                	jmp    802443 <strnlen+0x11>
		n++;
  802442:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802443:	39 d0                	cmp    %edx,%eax
  802445:	74 06                	je     80244d <strnlen+0x1b>
  802447:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80244b:	75 f5                	jne    802442 <strnlen+0x10>
		n++;
	return n;
}
  80244d:	5d                   	pop    %ebp
  80244e:	c3                   	ret    

0080244f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80244f:	55                   	push   %ebp
  802450:	89 e5                	mov    %esp,%ebp
  802452:	53                   	push   %ebx
  802453:	8b 45 08             	mov    0x8(%ebp),%eax
  802456:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802459:	ba 00 00 00 00       	mov    $0x0,%edx
  80245e:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  802461:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  802464:	42                   	inc    %edx
  802465:	84 c9                	test   %cl,%cl
  802467:	75 f5                	jne    80245e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  802469:	5b                   	pop    %ebx
  80246a:	5d                   	pop    %ebp
  80246b:	c3                   	ret    

0080246c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80246c:	55                   	push   %ebp
  80246d:	89 e5                	mov    %esp,%ebp
  80246f:	53                   	push   %ebx
  802470:	83 ec 08             	sub    $0x8,%esp
  802473:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802476:	89 1c 24             	mov    %ebx,(%esp)
  802479:	e8 9e ff ff ff       	call   80241c <strlen>
	strcpy(dst + len, src);
  80247e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802481:	89 54 24 04          	mov    %edx,0x4(%esp)
  802485:	01 d8                	add    %ebx,%eax
  802487:	89 04 24             	mov    %eax,(%esp)
  80248a:	e8 c0 ff ff ff       	call   80244f <strcpy>
	return dst;
}
  80248f:	89 d8                	mov    %ebx,%eax
  802491:	83 c4 08             	add    $0x8,%esp
  802494:	5b                   	pop    %ebx
  802495:	5d                   	pop    %ebp
  802496:	c3                   	ret    

00802497 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802497:	55                   	push   %ebp
  802498:	89 e5                	mov    %esp,%ebp
  80249a:	56                   	push   %esi
  80249b:	53                   	push   %ebx
  80249c:	8b 45 08             	mov    0x8(%ebp),%eax
  80249f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024a2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8024a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8024aa:	eb 0c                	jmp    8024b8 <strncpy+0x21>
		*dst++ = *src;
  8024ac:	8a 1a                	mov    (%edx),%bl
  8024ae:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8024b1:	80 3a 01             	cmpb   $0x1,(%edx)
  8024b4:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8024b7:	41                   	inc    %ecx
  8024b8:	39 f1                	cmp    %esi,%ecx
  8024ba:	75 f0                	jne    8024ac <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8024bc:	5b                   	pop    %ebx
  8024bd:	5e                   	pop    %esi
  8024be:	5d                   	pop    %ebp
  8024bf:	c3                   	ret    

008024c0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8024c0:	55                   	push   %ebp
  8024c1:	89 e5                	mov    %esp,%ebp
  8024c3:	56                   	push   %esi
  8024c4:	53                   	push   %ebx
  8024c5:	8b 75 08             	mov    0x8(%ebp),%esi
  8024c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024cb:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8024ce:	85 d2                	test   %edx,%edx
  8024d0:	75 0a                	jne    8024dc <strlcpy+0x1c>
  8024d2:	89 f0                	mov    %esi,%eax
  8024d4:	eb 1a                	jmp    8024f0 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8024d6:	88 18                	mov    %bl,(%eax)
  8024d8:	40                   	inc    %eax
  8024d9:	41                   	inc    %ecx
  8024da:	eb 02                	jmp    8024de <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8024dc:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8024de:	4a                   	dec    %edx
  8024df:	74 0a                	je     8024eb <strlcpy+0x2b>
  8024e1:	8a 19                	mov    (%ecx),%bl
  8024e3:	84 db                	test   %bl,%bl
  8024e5:	75 ef                	jne    8024d6 <strlcpy+0x16>
  8024e7:	89 c2                	mov    %eax,%edx
  8024e9:	eb 02                	jmp    8024ed <strlcpy+0x2d>
  8024eb:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8024ed:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8024f0:	29 f0                	sub    %esi,%eax
}
  8024f2:	5b                   	pop    %ebx
  8024f3:	5e                   	pop    %esi
  8024f4:	5d                   	pop    %ebp
  8024f5:	c3                   	ret    

008024f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8024f6:	55                   	push   %ebp
  8024f7:	89 e5                	mov    %esp,%ebp
  8024f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8024fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8024ff:	eb 02                	jmp    802503 <strcmp+0xd>
		p++, q++;
  802501:	41                   	inc    %ecx
  802502:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  802503:	8a 01                	mov    (%ecx),%al
  802505:	84 c0                	test   %al,%al
  802507:	74 04                	je     80250d <strcmp+0x17>
  802509:	3a 02                	cmp    (%edx),%al
  80250b:	74 f4                	je     802501 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80250d:	0f b6 c0             	movzbl %al,%eax
  802510:	0f b6 12             	movzbl (%edx),%edx
  802513:	29 d0                	sub    %edx,%eax
}
  802515:	5d                   	pop    %ebp
  802516:	c3                   	ret    

00802517 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802517:	55                   	push   %ebp
  802518:	89 e5                	mov    %esp,%ebp
  80251a:	53                   	push   %ebx
  80251b:	8b 45 08             	mov    0x8(%ebp),%eax
  80251e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802521:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  802524:	eb 03                	jmp    802529 <strncmp+0x12>
		n--, p++, q++;
  802526:	4a                   	dec    %edx
  802527:	40                   	inc    %eax
  802528:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  802529:	85 d2                	test   %edx,%edx
  80252b:	74 14                	je     802541 <strncmp+0x2a>
  80252d:	8a 18                	mov    (%eax),%bl
  80252f:	84 db                	test   %bl,%bl
  802531:	74 04                	je     802537 <strncmp+0x20>
  802533:	3a 19                	cmp    (%ecx),%bl
  802535:	74 ef                	je     802526 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802537:	0f b6 00             	movzbl (%eax),%eax
  80253a:	0f b6 11             	movzbl (%ecx),%edx
  80253d:	29 d0                	sub    %edx,%eax
  80253f:	eb 05                	jmp    802546 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802541:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802546:	5b                   	pop    %ebx
  802547:	5d                   	pop    %ebp
  802548:	c3                   	ret    

00802549 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802549:	55                   	push   %ebp
  80254a:	89 e5                	mov    %esp,%ebp
  80254c:	8b 45 08             	mov    0x8(%ebp),%eax
  80254f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  802552:	eb 05                	jmp    802559 <strchr+0x10>
		if (*s == c)
  802554:	38 ca                	cmp    %cl,%dl
  802556:	74 0c                	je     802564 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802558:	40                   	inc    %eax
  802559:	8a 10                	mov    (%eax),%dl
  80255b:	84 d2                	test   %dl,%dl
  80255d:	75 f5                	jne    802554 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80255f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802564:	5d                   	pop    %ebp
  802565:	c3                   	ret    

00802566 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802566:	55                   	push   %ebp
  802567:	89 e5                	mov    %esp,%ebp
  802569:	8b 45 08             	mov    0x8(%ebp),%eax
  80256c:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80256f:	eb 05                	jmp    802576 <strfind+0x10>
		if (*s == c)
  802571:	38 ca                	cmp    %cl,%dl
  802573:	74 07                	je     80257c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  802575:	40                   	inc    %eax
  802576:	8a 10                	mov    (%eax),%dl
  802578:	84 d2                	test   %dl,%dl
  80257a:	75 f5                	jne    802571 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80257c:	5d                   	pop    %ebp
  80257d:	c3                   	ret    

0080257e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80257e:	55                   	push   %ebp
  80257f:	89 e5                	mov    %esp,%ebp
  802581:	57                   	push   %edi
  802582:	56                   	push   %esi
  802583:	53                   	push   %ebx
  802584:	8b 7d 08             	mov    0x8(%ebp),%edi
  802587:	8b 45 0c             	mov    0xc(%ebp),%eax
  80258a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80258d:	85 c9                	test   %ecx,%ecx
  80258f:	74 30                	je     8025c1 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802591:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802597:	75 25                	jne    8025be <memset+0x40>
  802599:	f6 c1 03             	test   $0x3,%cl
  80259c:	75 20                	jne    8025be <memset+0x40>
		c &= 0xFF;
  80259e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8025a1:	89 d3                	mov    %edx,%ebx
  8025a3:	c1 e3 08             	shl    $0x8,%ebx
  8025a6:	89 d6                	mov    %edx,%esi
  8025a8:	c1 e6 18             	shl    $0x18,%esi
  8025ab:	89 d0                	mov    %edx,%eax
  8025ad:	c1 e0 10             	shl    $0x10,%eax
  8025b0:	09 f0                	or     %esi,%eax
  8025b2:	09 d0                	or     %edx,%eax
  8025b4:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8025b6:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8025b9:	fc                   	cld    
  8025ba:	f3 ab                	rep stos %eax,%es:(%edi)
  8025bc:	eb 03                	jmp    8025c1 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8025be:	fc                   	cld    
  8025bf:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8025c1:	89 f8                	mov    %edi,%eax
  8025c3:	5b                   	pop    %ebx
  8025c4:	5e                   	pop    %esi
  8025c5:	5f                   	pop    %edi
  8025c6:	5d                   	pop    %ebp
  8025c7:	c3                   	ret    

008025c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8025c8:	55                   	push   %ebp
  8025c9:	89 e5                	mov    %esp,%ebp
  8025cb:	57                   	push   %edi
  8025cc:	56                   	push   %esi
  8025cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8025d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8025d6:	39 c6                	cmp    %eax,%esi
  8025d8:	73 34                	jae    80260e <memmove+0x46>
  8025da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8025dd:	39 d0                	cmp    %edx,%eax
  8025df:	73 2d                	jae    80260e <memmove+0x46>
		s += n;
		d += n;
  8025e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8025e4:	f6 c2 03             	test   $0x3,%dl
  8025e7:	75 1b                	jne    802604 <memmove+0x3c>
  8025e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8025ef:	75 13                	jne    802604 <memmove+0x3c>
  8025f1:	f6 c1 03             	test   $0x3,%cl
  8025f4:	75 0e                	jne    802604 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8025f6:	83 ef 04             	sub    $0x4,%edi
  8025f9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8025fc:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8025ff:	fd                   	std    
  802600:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802602:	eb 07                	jmp    80260b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  802604:	4f                   	dec    %edi
  802605:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802608:	fd                   	std    
  802609:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80260b:	fc                   	cld    
  80260c:	eb 20                	jmp    80262e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80260e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802614:	75 13                	jne    802629 <memmove+0x61>
  802616:	a8 03                	test   $0x3,%al
  802618:	75 0f                	jne    802629 <memmove+0x61>
  80261a:	f6 c1 03             	test   $0x3,%cl
  80261d:	75 0a                	jne    802629 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80261f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  802622:	89 c7                	mov    %eax,%edi
  802624:	fc                   	cld    
  802625:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802627:	eb 05                	jmp    80262e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  802629:	89 c7                	mov    %eax,%edi
  80262b:	fc                   	cld    
  80262c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80262e:	5e                   	pop    %esi
  80262f:	5f                   	pop    %edi
  802630:	5d                   	pop    %ebp
  802631:	c3                   	ret    

00802632 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  802632:	55                   	push   %ebp
  802633:	89 e5                	mov    %esp,%ebp
  802635:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  802638:	8b 45 10             	mov    0x10(%ebp),%eax
  80263b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80263f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802642:	89 44 24 04          	mov    %eax,0x4(%esp)
  802646:	8b 45 08             	mov    0x8(%ebp),%eax
  802649:	89 04 24             	mov    %eax,(%esp)
  80264c:	e8 77 ff ff ff       	call   8025c8 <memmove>
}
  802651:	c9                   	leave  
  802652:	c3                   	ret    

00802653 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802653:	55                   	push   %ebp
  802654:	89 e5                	mov    %esp,%ebp
  802656:	57                   	push   %edi
  802657:	56                   	push   %esi
  802658:	53                   	push   %ebx
  802659:	8b 7d 08             	mov    0x8(%ebp),%edi
  80265c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80265f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802662:	ba 00 00 00 00       	mov    $0x0,%edx
  802667:	eb 16                	jmp    80267f <memcmp+0x2c>
		if (*s1 != *s2)
  802669:	8a 04 17             	mov    (%edi,%edx,1),%al
  80266c:	42                   	inc    %edx
  80266d:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  802671:	38 c8                	cmp    %cl,%al
  802673:	74 0a                	je     80267f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  802675:	0f b6 c0             	movzbl %al,%eax
  802678:	0f b6 c9             	movzbl %cl,%ecx
  80267b:	29 c8                	sub    %ecx,%eax
  80267d:	eb 09                	jmp    802688 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80267f:	39 da                	cmp    %ebx,%edx
  802681:	75 e6                	jne    802669 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802683:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802688:	5b                   	pop    %ebx
  802689:	5e                   	pop    %esi
  80268a:	5f                   	pop    %edi
  80268b:	5d                   	pop    %ebp
  80268c:	c3                   	ret    

0080268d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80268d:	55                   	push   %ebp
  80268e:	89 e5                	mov    %esp,%ebp
  802690:	8b 45 08             	mov    0x8(%ebp),%eax
  802693:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  802696:	89 c2                	mov    %eax,%edx
  802698:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80269b:	eb 05                	jmp    8026a2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  80269d:	38 08                	cmp    %cl,(%eax)
  80269f:	74 05                	je     8026a6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8026a1:	40                   	inc    %eax
  8026a2:	39 d0                	cmp    %edx,%eax
  8026a4:	72 f7                	jb     80269d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8026a6:	5d                   	pop    %ebp
  8026a7:	c3                   	ret    

008026a8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8026a8:	55                   	push   %ebp
  8026a9:	89 e5                	mov    %esp,%ebp
  8026ab:	57                   	push   %edi
  8026ac:	56                   	push   %esi
  8026ad:	53                   	push   %ebx
  8026ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8026b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8026b4:	eb 01                	jmp    8026b7 <strtol+0xf>
		s++;
  8026b6:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8026b7:	8a 02                	mov    (%edx),%al
  8026b9:	3c 20                	cmp    $0x20,%al
  8026bb:	74 f9                	je     8026b6 <strtol+0xe>
  8026bd:	3c 09                	cmp    $0x9,%al
  8026bf:	74 f5                	je     8026b6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8026c1:	3c 2b                	cmp    $0x2b,%al
  8026c3:	75 08                	jne    8026cd <strtol+0x25>
		s++;
  8026c5:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8026c6:	bf 00 00 00 00       	mov    $0x0,%edi
  8026cb:	eb 13                	jmp    8026e0 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8026cd:	3c 2d                	cmp    $0x2d,%al
  8026cf:	75 0a                	jne    8026db <strtol+0x33>
		s++, neg = 1;
  8026d1:	8d 52 01             	lea    0x1(%edx),%edx
  8026d4:	bf 01 00 00 00       	mov    $0x1,%edi
  8026d9:	eb 05                	jmp    8026e0 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8026db:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8026e0:	85 db                	test   %ebx,%ebx
  8026e2:	74 05                	je     8026e9 <strtol+0x41>
  8026e4:	83 fb 10             	cmp    $0x10,%ebx
  8026e7:	75 28                	jne    802711 <strtol+0x69>
  8026e9:	8a 02                	mov    (%edx),%al
  8026eb:	3c 30                	cmp    $0x30,%al
  8026ed:	75 10                	jne    8026ff <strtol+0x57>
  8026ef:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8026f3:	75 0a                	jne    8026ff <strtol+0x57>
		s += 2, base = 16;
  8026f5:	83 c2 02             	add    $0x2,%edx
  8026f8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8026fd:	eb 12                	jmp    802711 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  8026ff:	85 db                	test   %ebx,%ebx
  802701:	75 0e                	jne    802711 <strtol+0x69>
  802703:	3c 30                	cmp    $0x30,%al
  802705:	75 05                	jne    80270c <strtol+0x64>
		s++, base = 8;
  802707:	42                   	inc    %edx
  802708:	b3 08                	mov    $0x8,%bl
  80270a:	eb 05                	jmp    802711 <strtol+0x69>
	else if (base == 0)
		base = 10;
  80270c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  802711:	b8 00 00 00 00       	mov    $0x0,%eax
  802716:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802718:	8a 0a                	mov    (%edx),%cl
  80271a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80271d:	80 fb 09             	cmp    $0x9,%bl
  802720:	77 08                	ja     80272a <strtol+0x82>
			dig = *s - '0';
  802722:	0f be c9             	movsbl %cl,%ecx
  802725:	83 e9 30             	sub    $0x30,%ecx
  802728:	eb 1e                	jmp    802748 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80272a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  80272d:	80 fb 19             	cmp    $0x19,%bl
  802730:	77 08                	ja     80273a <strtol+0x92>
			dig = *s - 'a' + 10;
  802732:	0f be c9             	movsbl %cl,%ecx
  802735:	83 e9 57             	sub    $0x57,%ecx
  802738:	eb 0e                	jmp    802748 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80273a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80273d:	80 fb 19             	cmp    $0x19,%bl
  802740:	77 12                	ja     802754 <strtol+0xac>
			dig = *s - 'A' + 10;
  802742:	0f be c9             	movsbl %cl,%ecx
  802745:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  802748:	39 f1                	cmp    %esi,%ecx
  80274a:	7d 0c                	jge    802758 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  80274c:	42                   	inc    %edx
  80274d:	0f af c6             	imul   %esi,%eax
  802750:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  802752:	eb c4                	jmp    802718 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  802754:	89 c1                	mov    %eax,%ecx
  802756:	eb 02                	jmp    80275a <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  802758:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  80275a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80275e:	74 05                	je     802765 <strtol+0xbd>
		*endptr = (char *) s;
  802760:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802763:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  802765:	85 ff                	test   %edi,%edi
  802767:	74 04                	je     80276d <strtol+0xc5>
  802769:	89 c8                	mov    %ecx,%eax
  80276b:	f7 d8                	neg    %eax
}
  80276d:	5b                   	pop    %ebx
  80276e:	5e                   	pop    %esi
  80276f:	5f                   	pop    %edi
  802770:	5d                   	pop    %ebp
  802771:	c3                   	ret    
	...

00802774 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802774:	55                   	push   %ebp
  802775:	89 e5                	mov    %esp,%ebp
  802777:	57                   	push   %edi
  802778:	56                   	push   %esi
  802779:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80277a:	b8 00 00 00 00       	mov    $0x0,%eax
  80277f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802782:	8b 55 08             	mov    0x8(%ebp),%edx
  802785:	89 c3                	mov    %eax,%ebx
  802787:	89 c7                	mov    %eax,%edi
  802789:	89 c6                	mov    %eax,%esi
  80278b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80278d:	5b                   	pop    %ebx
  80278e:	5e                   	pop    %esi
  80278f:	5f                   	pop    %edi
  802790:	5d                   	pop    %ebp
  802791:	c3                   	ret    

00802792 <sys_cgetc>:

int
sys_cgetc(void)
{
  802792:	55                   	push   %ebp
  802793:	89 e5                	mov    %esp,%ebp
  802795:	57                   	push   %edi
  802796:	56                   	push   %esi
  802797:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802798:	ba 00 00 00 00       	mov    $0x0,%edx
  80279d:	b8 01 00 00 00       	mov    $0x1,%eax
  8027a2:	89 d1                	mov    %edx,%ecx
  8027a4:	89 d3                	mov    %edx,%ebx
  8027a6:	89 d7                	mov    %edx,%edi
  8027a8:	89 d6                	mov    %edx,%esi
  8027aa:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8027ac:	5b                   	pop    %ebx
  8027ad:	5e                   	pop    %esi
  8027ae:	5f                   	pop    %edi
  8027af:	5d                   	pop    %ebp
  8027b0:	c3                   	ret    

008027b1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8027b1:	55                   	push   %ebp
  8027b2:	89 e5                	mov    %esp,%ebp
  8027b4:	57                   	push   %edi
  8027b5:	56                   	push   %esi
  8027b6:	53                   	push   %ebx
  8027b7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8027ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8027bf:	b8 03 00 00 00       	mov    $0x3,%eax
  8027c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8027c7:	89 cb                	mov    %ecx,%ebx
  8027c9:	89 cf                	mov    %ecx,%edi
  8027cb:	89 ce                	mov    %ecx,%esi
  8027cd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8027cf:	85 c0                	test   %eax,%eax
  8027d1:	7e 28                	jle    8027fb <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8027d3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8027d7:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8027de:	00 
  8027df:	c7 44 24 08 c3 4a 80 	movl   $0x804ac3,0x8(%esp)
  8027e6:	00 
  8027e7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8027ee:	00 
  8027ef:	c7 04 24 e0 4a 80 00 	movl   $0x804ae0,(%esp)
  8027f6:	e8 b1 f5 ff ff       	call   801dac <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8027fb:	83 c4 2c             	add    $0x2c,%esp
  8027fe:	5b                   	pop    %ebx
  8027ff:	5e                   	pop    %esi
  802800:	5f                   	pop    %edi
  802801:	5d                   	pop    %ebp
  802802:	c3                   	ret    

00802803 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802803:	55                   	push   %ebp
  802804:	89 e5                	mov    %esp,%ebp
  802806:	57                   	push   %edi
  802807:	56                   	push   %esi
  802808:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802809:	ba 00 00 00 00       	mov    $0x0,%edx
  80280e:	b8 02 00 00 00       	mov    $0x2,%eax
  802813:	89 d1                	mov    %edx,%ecx
  802815:	89 d3                	mov    %edx,%ebx
  802817:	89 d7                	mov    %edx,%edi
  802819:	89 d6                	mov    %edx,%esi
  80281b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80281d:	5b                   	pop    %ebx
  80281e:	5e                   	pop    %esi
  80281f:	5f                   	pop    %edi
  802820:	5d                   	pop    %ebp
  802821:	c3                   	ret    

00802822 <sys_yield>:

void
sys_yield(void)
{
  802822:	55                   	push   %ebp
  802823:	89 e5                	mov    %esp,%ebp
  802825:	57                   	push   %edi
  802826:	56                   	push   %esi
  802827:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802828:	ba 00 00 00 00       	mov    $0x0,%edx
  80282d:	b8 0b 00 00 00       	mov    $0xb,%eax
  802832:	89 d1                	mov    %edx,%ecx
  802834:	89 d3                	mov    %edx,%ebx
  802836:	89 d7                	mov    %edx,%edi
  802838:	89 d6                	mov    %edx,%esi
  80283a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80283c:	5b                   	pop    %ebx
  80283d:	5e                   	pop    %esi
  80283e:	5f                   	pop    %edi
  80283f:	5d                   	pop    %ebp
  802840:	c3                   	ret    

00802841 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802841:	55                   	push   %ebp
  802842:	89 e5                	mov    %esp,%ebp
  802844:	57                   	push   %edi
  802845:	56                   	push   %esi
  802846:	53                   	push   %ebx
  802847:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80284a:	be 00 00 00 00       	mov    $0x0,%esi
  80284f:	b8 04 00 00 00       	mov    $0x4,%eax
  802854:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802857:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80285a:	8b 55 08             	mov    0x8(%ebp),%edx
  80285d:	89 f7                	mov    %esi,%edi
  80285f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802861:	85 c0                	test   %eax,%eax
  802863:	7e 28                	jle    80288d <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  802865:	89 44 24 10          	mov    %eax,0x10(%esp)
  802869:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  802870:	00 
  802871:	c7 44 24 08 c3 4a 80 	movl   $0x804ac3,0x8(%esp)
  802878:	00 
  802879:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802880:	00 
  802881:	c7 04 24 e0 4a 80 00 	movl   $0x804ae0,(%esp)
  802888:	e8 1f f5 ff ff       	call   801dac <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80288d:	83 c4 2c             	add    $0x2c,%esp
  802890:	5b                   	pop    %ebx
  802891:	5e                   	pop    %esi
  802892:	5f                   	pop    %edi
  802893:	5d                   	pop    %ebp
  802894:	c3                   	ret    

00802895 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802895:	55                   	push   %ebp
  802896:	89 e5                	mov    %esp,%ebp
  802898:	57                   	push   %edi
  802899:	56                   	push   %esi
  80289a:	53                   	push   %ebx
  80289b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80289e:	b8 05 00 00 00       	mov    $0x5,%eax
  8028a3:	8b 75 18             	mov    0x18(%ebp),%esi
  8028a6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8028a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8028ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028af:	8b 55 08             	mov    0x8(%ebp),%edx
  8028b2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8028b4:	85 c0                	test   %eax,%eax
  8028b6:	7e 28                	jle    8028e0 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8028b8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8028bc:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8028c3:	00 
  8028c4:	c7 44 24 08 c3 4a 80 	movl   $0x804ac3,0x8(%esp)
  8028cb:	00 
  8028cc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8028d3:	00 
  8028d4:	c7 04 24 e0 4a 80 00 	movl   $0x804ae0,(%esp)
  8028db:	e8 cc f4 ff ff       	call   801dac <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8028e0:	83 c4 2c             	add    $0x2c,%esp
  8028e3:	5b                   	pop    %ebx
  8028e4:	5e                   	pop    %esi
  8028e5:	5f                   	pop    %edi
  8028e6:	5d                   	pop    %ebp
  8028e7:	c3                   	ret    

008028e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8028e8:	55                   	push   %ebp
  8028e9:	89 e5                	mov    %esp,%ebp
  8028eb:	57                   	push   %edi
  8028ec:	56                   	push   %esi
  8028ed:	53                   	push   %ebx
  8028ee:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8028f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8028fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028fe:	8b 55 08             	mov    0x8(%ebp),%edx
  802901:	89 df                	mov    %ebx,%edi
  802903:	89 de                	mov    %ebx,%esi
  802905:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802907:	85 c0                	test   %eax,%eax
  802909:	7e 28                	jle    802933 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80290b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80290f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  802916:	00 
  802917:	c7 44 24 08 c3 4a 80 	movl   $0x804ac3,0x8(%esp)
  80291e:	00 
  80291f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802926:	00 
  802927:	c7 04 24 e0 4a 80 00 	movl   $0x804ae0,(%esp)
  80292e:	e8 79 f4 ff ff       	call   801dac <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802933:	83 c4 2c             	add    $0x2c,%esp
  802936:	5b                   	pop    %ebx
  802937:	5e                   	pop    %esi
  802938:	5f                   	pop    %edi
  802939:	5d                   	pop    %ebp
  80293a:	c3                   	ret    

0080293b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80293b:	55                   	push   %ebp
  80293c:	89 e5                	mov    %esp,%ebp
  80293e:	57                   	push   %edi
  80293f:	56                   	push   %esi
  802940:	53                   	push   %ebx
  802941:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802944:	bb 00 00 00 00       	mov    $0x0,%ebx
  802949:	b8 08 00 00 00       	mov    $0x8,%eax
  80294e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802951:	8b 55 08             	mov    0x8(%ebp),%edx
  802954:	89 df                	mov    %ebx,%edi
  802956:	89 de                	mov    %ebx,%esi
  802958:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80295a:	85 c0                	test   %eax,%eax
  80295c:	7e 28                	jle    802986 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80295e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802962:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  802969:	00 
  80296a:	c7 44 24 08 c3 4a 80 	movl   $0x804ac3,0x8(%esp)
  802971:	00 
  802972:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802979:	00 
  80297a:	c7 04 24 e0 4a 80 00 	movl   $0x804ae0,(%esp)
  802981:	e8 26 f4 ff ff       	call   801dac <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  802986:	83 c4 2c             	add    $0x2c,%esp
  802989:	5b                   	pop    %ebx
  80298a:	5e                   	pop    %esi
  80298b:	5f                   	pop    %edi
  80298c:	5d                   	pop    %ebp
  80298d:	c3                   	ret    

0080298e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80298e:	55                   	push   %ebp
  80298f:	89 e5                	mov    %esp,%ebp
  802991:	57                   	push   %edi
  802992:	56                   	push   %esi
  802993:	53                   	push   %ebx
  802994:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802997:	bb 00 00 00 00       	mov    $0x0,%ebx
  80299c:	b8 09 00 00 00       	mov    $0x9,%eax
  8029a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8029a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8029a7:	89 df                	mov    %ebx,%edi
  8029a9:	89 de                	mov    %ebx,%esi
  8029ab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8029ad:	85 c0                	test   %eax,%eax
  8029af:	7e 28                	jle    8029d9 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8029b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8029b5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8029bc:	00 
  8029bd:	c7 44 24 08 c3 4a 80 	movl   $0x804ac3,0x8(%esp)
  8029c4:	00 
  8029c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8029cc:	00 
  8029cd:	c7 04 24 e0 4a 80 00 	movl   $0x804ae0,(%esp)
  8029d4:	e8 d3 f3 ff ff       	call   801dac <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8029d9:	83 c4 2c             	add    $0x2c,%esp
  8029dc:	5b                   	pop    %ebx
  8029dd:	5e                   	pop    %esi
  8029de:	5f                   	pop    %edi
  8029df:	5d                   	pop    %ebp
  8029e0:	c3                   	ret    

008029e1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8029e1:	55                   	push   %ebp
  8029e2:	89 e5                	mov    %esp,%ebp
  8029e4:	57                   	push   %edi
  8029e5:	56                   	push   %esi
  8029e6:	53                   	push   %ebx
  8029e7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8029ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8029ef:	b8 0a 00 00 00       	mov    $0xa,%eax
  8029f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8029f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8029fa:	89 df                	mov    %ebx,%edi
  8029fc:	89 de                	mov    %ebx,%esi
  8029fe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802a00:	85 c0                	test   %eax,%eax
  802a02:	7e 28                	jle    802a2c <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802a04:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a08:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  802a0f:	00 
  802a10:	c7 44 24 08 c3 4a 80 	movl   $0x804ac3,0x8(%esp)
  802a17:	00 
  802a18:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802a1f:	00 
  802a20:	c7 04 24 e0 4a 80 00 	movl   $0x804ae0,(%esp)
  802a27:	e8 80 f3 ff ff       	call   801dac <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802a2c:	83 c4 2c             	add    $0x2c,%esp
  802a2f:	5b                   	pop    %ebx
  802a30:	5e                   	pop    %esi
  802a31:	5f                   	pop    %edi
  802a32:	5d                   	pop    %ebp
  802a33:	c3                   	ret    

00802a34 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802a34:	55                   	push   %ebp
  802a35:	89 e5                	mov    %esp,%ebp
  802a37:	57                   	push   %edi
  802a38:	56                   	push   %esi
  802a39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802a3a:	be 00 00 00 00       	mov    $0x0,%esi
  802a3f:	b8 0c 00 00 00       	mov    $0xc,%eax
  802a44:	8b 7d 14             	mov    0x14(%ebp),%edi
  802a47:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802a4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a4d:	8b 55 08             	mov    0x8(%ebp),%edx
  802a50:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802a52:	5b                   	pop    %ebx
  802a53:	5e                   	pop    %esi
  802a54:	5f                   	pop    %edi
  802a55:	5d                   	pop    %ebp
  802a56:	c3                   	ret    

00802a57 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802a57:	55                   	push   %ebp
  802a58:	89 e5                	mov    %esp,%ebp
  802a5a:	57                   	push   %edi
  802a5b:	56                   	push   %esi
  802a5c:	53                   	push   %ebx
  802a5d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802a60:	b9 00 00 00 00       	mov    $0x0,%ecx
  802a65:	b8 0d 00 00 00       	mov    $0xd,%eax
  802a6a:	8b 55 08             	mov    0x8(%ebp),%edx
  802a6d:	89 cb                	mov    %ecx,%ebx
  802a6f:	89 cf                	mov    %ecx,%edi
  802a71:	89 ce                	mov    %ecx,%esi
  802a73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802a75:	85 c0                	test   %eax,%eax
  802a77:	7e 28                	jle    802aa1 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802a79:	89 44 24 10          	mov    %eax,0x10(%esp)
  802a7d:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  802a84:	00 
  802a85:	c7 44 24 08 c3 4a 80 	movl   $0x804ac3,0x8(%esp)
  802a8c:	00 
  802a8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802a94:	00 
  802a95:	c7 04 24 e0 4a 80 00 	movl   $0x804ae0,(%esp)
  802a9c:	e8 0b f3 ff ff       	call   801dac <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802aa1:	83 c4 2c             	add    $0x2c,%esp
  802aa4:	5b                   	pop    %ebx
  802aa5:	5e                   	pop    %esi
  802aa6:	5f                   	pop    %edi
  802aa7:	5d                   	pop    %ebp
  802aa8:	c3                   	ret    

00802aa9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  802aa9:	55                   	push   %ebp
  802aaa:	89 e5                	mov    %esp,%ebp
  802aac:	57                   	push   %edi
  802aad:	56                   	push   %esi
  802aae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802aaf:	ba 00 00 00 00       	mov    $0x0,%edx
  802ab4:	b8 0e 00 00 00       	mov    $0xe,%eax
  802ab9:	89 d1                	mov    %edx,%ecx
  802abb:	89 d3                	mov    %edx,%ebx
  802abd:	89 d7                	mov    %edx,%edi
  802abf:	89 d6                	mov    %edx,%esi
  802ac1:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  802ac3:	5b                   	pop    %ebx
  802ac4:	5e                   	pop    %esi
  802ac5:	5f                   	pop    %edi
  802ac6:	5d                   	pop    %ebp
  802ac7:	c3                   	ret    

00802ac8 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  802ac8:	55                   	push   %ebp
  802ac9:	89 e5                	mov    %esp,%ebp
  802acb:	57                   	push   %edi
  802acc:	56                   	push   %esi
  802acd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802ace:	bb 00 00 00 00       	mov    $0x0,%ebx
  802ad3:	b8 0f 00 00 00       	mov    $0xf,%eax
  802ad8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802adb:	8b 55 08             	mov    0x8(%ebp),%edx
  802ade:	89 df                	mov    %ebx,%edi
  802ae0:	89 de                	mov    %ebx,%esi
  802ae2:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  802ae4:	5b                   	pop    %ebx
  802ae5:	5e                   	pop    %esi
  802ae6:	5f                   	pop    %edi
  802ae7:	5d                   	pop    %ebp
  802ae8:	c3                   	ret    

00802ae9 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  802ae9:	55                   	push   %ebp
  802aea:	89 e5                	mov    %esp,%ebp
  802aec:	57                   	push   %edi
  802aed:	56                   	push   %esi
  802aee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802aef:	bb 00 00 00 00       	mov    $0x0,%ebx
  802af4:	b8 10 00 00 00       	mov    $0x10,%eax
  802af9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802afc:	8b 55 08             	mov    0x8(%ebp),%edx
  802aff:	89 df                	mov    %ebx,%edi
  802b01:	89 de                	mov    %ebx,%esi
  802b03:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  802b05:	5b                   	pop    %ebx
  802b06:	5e                   	pop    %esi
  802b07:	5f                   	pop    %edi
  802b08:	5d                   	pop    %ebp
  802b09:	c3                   	ret    
	...

00802b0c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802b0c:	55                   	push   %ebp
  802b0d:	89 e5                	mov    %esp,%ebp
  802b0f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802b12:	83 3d 14 a0 80 00 00 	cmpl   $0x0,0x80a014
  802b19:	75 30                	jne    802b4b <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  802b1b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802b22:	00 
  802b23:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802b2a:	ee 
  802b2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b32:	e8 0a fd ff ff       	call   802841 <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  802b37:	c7 44 24 04 58 2b 80 	movl   $0x802b58,0x4(%esp)
  802b3e:	00 
  802b3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b46:	e8 96 fe ff ff       	call   8029e1 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  802b4e:	a3 14 a0 80 00       	mov    %eax,0x80a014
}
  802b53:	c9                   	leave  
  802b54:	c3                   	ret    
  802b55:	00 00                	add    %al,(%eax)
	...

00802b58 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802b58:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802b59:	a1 14 a0 80 00       	mov    0x80a014,%eax
	call *%eax
  802b5e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802b60:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  802b63:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  802b67:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  802b6b:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  802b6e:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  802b70:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  802b74:	83 c4 08             	add    $0x8,%esp
	popal
  802b77:	61                   	popa   

	addl $4,%esp 
  802b78:	83 c4 04             	add    $0x4,%esp
	popfl
  802b7b:	9d                   	popf   

	popl %esp
  802b7c:	5c                   	pop    %esp

	ret
  802b7d:	c3                   	ret    
	...

00802b80 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802b80:	55                   	push   %ebp
  802b81:	89 e5                	mov    %esp,%ebp
  802b83:	56                   	push   %esi
  802b84:	53                   	push   %ebx
  802b85:	83 ec 10             	sub    $0x10,%esp
  802b88:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b8e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  802b91:	85 c0                	test   %eax,%eax
  802b93:	74 0a                	je     802b9f <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802b95:	89 04 24             	mov    %eax,(%esp)
  802b98:	e8 ba fe ff ff       	call   802a57 <sys_ipc_recv>
  802b9d:	eb 0c                	jmp    802bab <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  802b9f:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802ba6:	e8 ac fe ff ff       	call   802a57 <sys_ipc_recv>
	}
	if (r < 0)
  802bab:	85 c0                	test   %eax,%eax
  802bad:	79 16                	jns    802bc5 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  802baf:	85 db                	test   %ebx,%ebx
  802bb1:	74 06                	je     802bb9 <ipc_recv+0x39>
  802bb3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802bb9:	85 f6                	test   %esi,%esi
  802bbb:	74 2c                	je     802be9 <ipc_recv+0x69>
  802bbd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802bc3:	eb 24                	jmp    802be9 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802bc5:	85 db                	test   %ebx,%ebx
  802bc7:	74 0a                	je     802bd3 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802bc9:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802bce:	8b 40 74             	mov    0x74(%eax),%eax
  802bd1:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  802bd3:	85 f6                	test   %esi,%esi
  802bd5:	74 0a                	je     802be1 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  802bd7:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802bdc:	8b 40 78             	mov    0x78(%eax),%eax
  802bdf:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802be1:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802be6:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802be9:	83 c4 10             	add    $0x10,%esp
  802bec:	5b                   	pop    %ebx
  802bed:	5e                   	pop    %esi
  802bee:	5d                   	pop    %ebp
  802bef:	c3                   	ret    

00802bf0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802bf0:	55                   	push   %ebp
  802bf1:	89 e5                	mov    %esp,%ebp
  802bf3:	57                   	push   %edi
  802bf4:	56                   	push   %esi
  802bf5:	53                   	push   %ebx
  802bf6:	83 ec 1c             	sub    $0x1c,%esp
  802bf9:	8b 75 08             	mov    0x8(%ebp),%esi
  802bfc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802bff:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  802c02:	85 db                	test   %ebx,%ebx
  802c04:	74 19                	je     802c1f <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802c06:	8b 45 14             	mov    0x14(%ebp),%eax
  802c09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c0d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802c11:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802c15:	89 34 24             	mov    %esi,(%esp)
  802c18:	e8 17 fe ff ff       	call   802a34 <sys_ipc_try_send>
  802c1d:	eb 1c                	jmp    802c3b <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  802c1f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802c26:	00 
  802c27:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802c2e:	ee 
  802c2f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802c33:	89 34 24             	mov    %esi,(%esp)
  802c36:	e8 f9 fd ff ff       	call   802a34 <sys_ipc_try_send>
		}
		if (r == 0)
  802c3b:	85 c0                	test   %eax,%eax
  802c3d:	74 2c                	je     802c6b <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802c3f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802c42:	74 20                	je     802c64 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802c44:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c48:	c7 44 24 08 ee 4a 80 	movl   $0x804aee,0x8(%esp)
  802c4f:	00 
  802c50:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802c57:	00 
  802c58:	c7 04 24 01 4b 80 00 	movl   $0x804b01,(%esp)
  802c5f:	e8 48 f1 ff ff       	call   801dac <_panic>
		}
		sys_yield();
  802c64:	e8 b9 fb ff ff       	call   802822 <sys_yield>
	}
  802c69:	eb 97                	jmp    802c02 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802c6b:	83 c4 1c             	add    $0x1c,%esp
  802c6e:	5b                   	pop    %ebx
  802c6f:	5e                   	pop    %esi
  802c70:	5f                   	pop    %edi
  802c71:	5d                   	pop    %ebp
  802c72:	c3                   	ret    

00802c73 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802c73:	55                   	push   %ebp
  802c74:	89 e5                	mov    %esp,%ebp
  802c76:	53                   	push   %ebx
  802c77:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802c7a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802c7f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802c86:	89 c2                	mov    %eax,%edx
  802c88:	c1 e2 07             	shl    $0x7,%edx
  802c8b:	29 ca                	sub    %ecx,%edx
  802c8d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802c93:	8b 52 50             	mov    0x50(%edx),%edx
  802c96:	39 da                	cmp    %ebx,%edx
  802c98:	75 0f                	jne    802ca9 <ipc_find_env+0x36>
			return envs[i].env_id;
  802c9a:	c1 e0 07             	shl    $0x7,%eax
  802c9d:	29 c8                	sub    %ecx,%eax
  802c9f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802ca4:	8b 40 40             	mov    0x40(%eax),%eax
  802ca7:	eb 0c                	jmp    802cb5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802ca9:	40                   	inc    %eax
  802caa:	3d 00 04 00 00       	cmp    $0x400,%eax
  802caf:	75 ce                	jne    802c7f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802cb1:	66 b8 00 00          	mov    $0x0,%ax
}
  802cb5:	5b                   	pop    %ebx
  802cb6:	5d                   	pop    %ebp
  802cb7:	c3                   	ret    

00802cb8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802cb8:	55                   	push   %ebp
  802cb9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  802cbe:	05 00 00 00 30       	add    $0x30000000,%eax
  802cc3:	c1 e8 0c             	shr    $0xc,%eax
}
  802cc6:	5d                   	pop    %ebp
  802cc7:	c3                   	ret    

00802cc8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802cc8:	55                   	push   %ebp
  802cc9:	89 e5                	mov    %esp,%ebp
  802ccb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  802cce:	8b 45 08             	mov    0x8(%ebp),%eax
  802cd1:	89 04 24             	mov    %eax,(%esp)
  802cd4:	e8 df ff ff ff       	call   802cb8 <fd2num>
  802cd9:	c1 e0 0c             	shl    $0xc,%eax
  802cdc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  802ce1:	c9                   	leave  
  802ce2:	c3                   	ret    

00802ce3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802ce3:	55                   	push   %ebp
  802ce4:	89 e5                	mov    %esp,%ebp
  802ce6:	53                   	push   %ebx
  802ce7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802cea:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  802cef:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802cf1:	89 c2                	mov    %eax,%edx
  802cf3:	c1 ea 16             	shr    $0x16,%edx
  802cf6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802cfd:	f6 c2 01             	test   $0x1,%dl
  802d00:	74 11                	je     802d13 <fd_alloc+0x30>
  802d02:	89 c2                	mov    %eax,%edx
  802d04:	c1 ea 0c             	shr    $0xc,%edx
  802d07:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802d0e:	f6 c2 01             	test   $0x1,%dl
  802d11:	75 09                	jne    802d1c <fd_alloc+0x39>
			*fd_store = fd;
  802d13:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  802d15:	b8 00 00 00 00       	mov    $0x0,%eax
  802d1a:	eb 17                	jmp    802d33 <fd_alloc+0x50>
  802d1c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802d21:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802d26:	75 c7                	jne    802cef <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802d28:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  802d2e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802d33:	5b                   	pop    %ebx
  802d34:	5d                   	pop    %ebp
  802d35:	c3                   	ret    

00802d36 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802d36:	55                   	push   %ebp
  802d37:	89 e5                	mov    %esp,%ebp
  802d39:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802d3c:	83 f8 1f             	cmp    $0x1f,%eax
  802d3f:	77 36                	ja     802d77 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802d41:	c1 e0 0c             	shl    $0xc,%eax
  802d44:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802d49:	89 c2                	mov    %eax,%edx
  802d4b:	c1 ea 16             	shr    $0x16,%edx
  802d4e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802d55:	f6 c2 01             	test   $0x1,%dl
  802d58:	74 24                	je     802d7e <fd_lookup+0x48>
  802d5a:	89 c2                	mov    %eax,%edx
  802d5c:	c1 ea 0c             	shr    $0xc,%edx
  802d5f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802d66:	f6 c2 01             	test   $0x1,%dl
  802d69:	74 1a                	je     802d85 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802d6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  802d6e:	89 02                	mov    %eax,(%edx)
	return 0;
  802d70:	b8 00 00 00 00       	mov    $0x0,%eax
  802d75:	eb 13                	jmp    802d8a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802d77:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802d7c:	eb 0c                	jmp    802d8a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802d7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802d83:	eb 05                	jmp    802d8a <fd_lookup+0x54>
  802d85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802d8a:	5d                   	pop    %ebp
  802d8b:	c3                   	ret    

00802d8c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802d8c:	55                   	push   %ebp
  802d8d:	89 e5                	mov    %esp,%ebp
  802d8f:	53                   	push   %ebx
  802d90:	83 ec 14             	sub    $0x14,%esp
  802d93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  802d99:	ba 00 00 00 00       	mov    $0x0,%edx
  802d9e:	eb 0e                	jmp    802dae <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  802da0:	39 08                	cmp    %ecx,(%eax)
  802da2:	75 09                	jne    802dad <dev_lookup+0x21>
			*dev = devtab[i];
  802da4:	89 03                	mov    %eax,(%ebx)
			return 0;
  802da6:	b8 00 00 00 00       	mov    $0x0,%eax
  802dab:	eb 33                	jmp    802de0 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802dad:	42                   	inc    %edx
  802dae:	8b 04 95 8c 4b 80 00 	mov    0x804b8c(,%edx,4),%eax
  802db5:	85 c0                	test   %eax,%eax
  802db7:	75 e7                	jne    802da0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802db9:	a1 10 a0 80 00       	mov    0x80a010,%eax
  802dbe:	8b 40 48             	mov    0x48(%eax),%eax
  802dc1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  802dc9:	c7 04 24 0c 4b 80 00 	movl   $0x804b0c,(%esp)
  802dd0:	e8 cf f0 ff ff       	call   801ea4 <cprintf>
	*dev = 0;
  802dd5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  802ddb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802de0:	83 c4 14             	add    $0x14,%esp
  802de3:	5b                   	pop    %ebx
  802de4:	5d                   	pop    %ebp
  802de5:	c3                   	ret    

00802de6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802de6:	55                   	push   %ebp
  802de7:	89 e5                	mov    %esp,%ebp
  802de9:	56                   	push   %esi
  802dea:	53                   	push   %ebx
  802deb:	83 ec 30             	sub    $0x30,%esp
  802dee:	8b 75 08             	mov    0x8(%ebp),%esi
  802df1:	8a 45 0c             	mov    0xc(%ebp),%al
  802df4:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802df7:	89 34 24             	mov    %esi,(%esp)
  802dfa:	e8 b9 fe ff ff       	call   802cb8 <fd2num>
  802dff:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802e02:	89 54 24 04          	mov    %edx,0x4(%esp)
  802e06:	89 04 24             	mov    %eax,(%esp)
  802e09:	e8 28 ff ff ff       	call   802d36 <fd_lookup>
  802e0e:	89 c3                	mov    %eax,%ebx
  802e10:	85 c0                	test   %eax,%eax
  802e12:	78 05                	js     802e19 <fd_close+0x33>
	    || fd != fd2)
  802e14:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802e17:	74 0d                	je     802e26 <fd_close+0x40>
		return (must_exist ? r : 0);
  802e19:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  802e1d:	75 46                	jne    802e65 <fd_close+0x7f>
  802e1f:	bb 00 00 00 00       	mov    $0x0,%ebx
  802e24:	eb 3f                	jmp    802e65 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802e26:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802e29:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e2d:	8b 06                	mov    (%esi),%eax
  802e2f:	89 04 24             	mov    %eax,(%esp)
  802e32:	e8 55 ff ff ff       	call   802d8c <dev_lookup>
  802e37:	89 c3                	mov    %eax,%ebx
  802e39:	85 c0                	test   %eax,%eax
  802e3b:	78 18                	js     802e55 <fd_close+0x6f>
		if (dev->dev_close)
  802e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802e40:	8b 40 10             	mov    0x10(%eax),%eax
  802e43:	85 c0                	test   %eax,%eax
  802e45:	74 09                	je     802e50 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802e47:	89 34 24             	mov    %esi,(%esp)
  802e4a:	ff d0                	call   *%eax
  802e4c:	89 c3                	mov    %eax,%ebx
  802e4e:	eb 05                	jmp    802e55 <fd_close+0x6f>
		else
			r = 0;
  802e50:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802e55:	89 74 24 04          	mov    %esi,0x4(%esp)
  802e59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e60:	e8 83 fa ff ff       	call   8028e8 <sys_page_unmap>
	return r;
}
  802e65:	89 d8                	mov    %ebx,%eax
  802e67:	83 c4 30             	add    $0x30,%esp
  802e6a:	5b                   	pop    %ebx
  802e6b:	5e                   	pop    %esi
  802e6c:	5d                   	pop    %ebp
  802e6d:	c3                   	ret    

00802e6e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802e6e:	55                   	push   %ebp
  802e6f:	89 e5                	mov    %esp,%ebp
  802e71:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e77:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  802e7e:	89 04 24             	mov    %eax,(%esp)
  802e81:	e8 b0 fe ff ff       	call   802d36 <fd_lookup>
  802e86:	85 c0                	test   %eax,%eax
  802e88:	78 13                	js     802e9d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  802e8a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802e91:	00 
  802e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e95:	89 04 24             	mov    %eax,(%esp)
  802e98:	e8 49 ff ff ff       	call   802de6 <fd_close>
}
  802e9d:	c9                   	leave  
  802e9e:	c3                   	ret    

00802e9f <close_all>:

void
close_all(void)
{
  802e9f:	55                   	push   %ebp
  802ea0:	89 e5                	mov    %esp,%ebp
  802ea2:	53                   	push   %ebx
  802ea3:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802ea6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802eab:	89 1c 24             	mov    %ebx,(%esp)
  802eae:	e8 bb ff ff ff       	call   802e6e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802eb3:	43                   	inc    %ebx
  802eb4:	83 fb 20             	cmp    $0x20,%ebx
  802eb7:	75 f2                	jne    802eab <close_all+0xc>
		close(i);
}
  802eb9:	83 c4 14             	add    $0x14,%esp
  802ebc:	5b                   	pop    %ebx
  802ebd:	5d                   	pop    %ebp
  802ebe:	c3                   	ret    

00802ebf <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802ebf:	55                   	push   %ebp
  802ec0:	89 e5                	mov    %esp,%ebp
  802ec2:	57                   	push   %edi
  802ec3:	56                   	push   %esi
  802ec4:	53                   	push   %ebx
  802ec5:	83 ec 4c             	sub    $0x4c,%esp
  802ec8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802ecb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802ece:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  802ed5:	89 04 24             	mov    %eax,(%esp)
  802ed8:	e8 59 fe ff ff       	call   802d36 <fd_lookup>
  802edd:	89 c3                	mov    %eax,%ebx
  802edf:	85 c0                	test   %eax,%eax
  802ee1:	0f 88 e3 00 00 00    	js     802fca <dup+0x10b>
		return r;
	close(newfdnum);
  802ee7:	89 3c 24             	mov    %edi,(%esp)
  802eea:	e8 7f ff ff ff       	call   802e6e <close>

	newfd = INDEX2FD(newfdnum);
  802eef:	89 fe                	mov    %edi,%esi
  802ef1:	c1 e6 0c             	shl    $0xc,%esi
  802ef4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  802efa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802efd:	89 04 24             	mov    %eax,(%esp)
  802f00:	e8 c3 fd ff ff       	call   802cc8 <fd2data>
  802f05:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802f07:	89 34 24             	mov    %esi,(%esp)
  802f0a:	e8 b9 fd ff ff       	call   802cc8 <fd2data>
  802f0f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802f12:	89 d8                	mov    %ebx,%eax
  802f14:	c1 e8 16             	shr    $0x16,%eax
  802f17:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802f1e:	a8 01                	test   $0x1,%al
  802f20:	74 46                	je     802f68 <dup+0xa9>
  802f22:	89 d8                	mov    %ebx,%eax
  802f24:	c1 e8 0c             	shr    $0xc,%eax
  802f27:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802f2e:	f6 c2 01             	test   $0x1,%dl
  802f31:	74 35                	je     802f68 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802f33:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802f3a:	25 07 0e 00 00       	and    $0xe07,%eax
  802f3f:	89 44 24 10          	mov    %eax,0x10(%esp)
  802f43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802f46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802f4a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802f51:	00 
  802f52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802f56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f5d:	e8 33 f9 ff ff       	call   802895 <sys_page_map>
  802f62:	89 c3                	mov    %eax,%ebx
  802f64:	85 c0                	test   %eax,%eax
  802f66:	78 3b                	js     802fa3 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802f68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802f6b:	89 c2                	mov    %eax,%edx
  802f6d:	c1 ea 0c             	shr    $0xc,%edx
  802f70:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802f77:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  802f7d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802f81:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802f85:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802f8c:	00 
  802f8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f98:	e8 f8 f8 ff ff       	call   802895 <sys_page_map>
  802f9d:	89 c3                	mov    %eax,%ebx
  802f9f:	85 c0                	test   %eax,%eax
  802fa1:	79 25                	jns    802fc8 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802fa3:	89 74 24 04          	mov    %esi,0x4(%esp)
  802fa7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802fae:	e8 35 f9 ff ff       	call   8028e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802fb3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802fb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802fc1:	e8 22 f9 ff ff       	call   8028e8 <sys_page_unmap>
	return r;
  802fc6:	eb 02                	jmp    802fca <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  802fc8:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  802fca:	89 d8                	mov    %ebx,%eax
  802fcc:	83 c4 4c             	add    $0x4c,%esp
  802fcf:	5b                   	pop    %ebx
  802fd0:	5e                   	pop    %esi
  802fd1:	5f                   	pop    %edi
  802fd2:	5d                   	pop    %ebp
  802fd3:	c3                   	ret    

00802fd4 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802fd4:	55                   	push   %ebp
  802fd5:	89 e5                	mov    %esp,%ebp
  802fd7:	53                   	push   %ebx
  802fd8:	83 ec 24             	sub    $0x24,%esp
  802fdb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802fde:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802fe1:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fe5:	89 1c 24             	mov    %ebx,(%esp)
  802fe8:	e8 49 fd ff ff       	call   802d36 <fd_lookup>
  802fed:	85 c0                	test   %eax,%eax
  802fef:	78 6d                	js     80305e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ff1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ff4:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ff8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802ffb:	8b 00                	mov    (%eax),%eax
  802ffd:	89 04 24             	mov    %eax,(%esp)
  803000:	e8 87 fd ff ff       	call   802d8c <dev_lookup>
  803005:	85 c0                	test   %eax,%eax
  803007:	78 55                	js     80305e <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  803009:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80300c:	8b 50 08             	mov    0x8(%eax),%edx
  80300f:	83 e2 03             	and    $0x3,%edx
  803012:	83 fa 01             	cmp    $0x1,%edx
  803015:	75 23                	jne    80303a <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  803017:	a1 10 a0 80 00       	mov    0x80a010,%eax
  80301c:	8b 40 48             	mov    0x48(%eax),%eax
  80301f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803023:	89 44 24 04          	mov    %eax,0x4(%esp)
  803027:	c7 04 24 50 4b 80 00 	movl   $0x804b50,(%esp)
  80302e:	e8 71 ee ff ff       	call   801ea4 <cprintf>
		return -E_INVAL;
  803033:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  803038:	eb 24                	jmp    80305e <read+0x8a>
	}
	if (!dev->dev_read)
  80303a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80303d:	8b 52 08             	mov    0x8(%edx),%edx
  803040:	85 d2                	test   %edx,%edx
  803042:	74 15                	je     803059 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  803044:	8b 4d 10             	mov    0x10(%ebp),%ecx
  803047:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80304b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80304e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803052:	89 04 24             	mov    %eax,(%esp)
  803055:	ff d2                	call   *%edx
  803057:	eb 05                	jmp    80305e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  803059:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80305e:	83 c4 24             	add    $0x24,%esp
  803061:	5b                   	pop    %ebx
  803062:	5d                   	pop    %ebp
  803063:	c3                   	ret    

00803064 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  803064:	55                   	push   %ebp
  803065:	89 e5                	mov    %esp,%ebp
  803067:	57                   	push   %edi
  803068:	56                   	push   %esi
  803069:	53                   	push   %ebx
  80306a:	83 ec 1c             	sub    $0x1c,%esp
  80306d:	8b 7d 08             	mov    0x8(%ebp),%edi
  803070:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  803073:	bb 00 00 00 00       	mov    $0x0,%ebx
  803078:	eb 23                	jmp    80309d <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80307a:	89 f0                	mov    %esi,%eax
  80307c:	29 d8                	sub    %ebx,%eax
  80307e:	89 44 24 08          	mov    %eax,0x8(%esp)
  803082:	8b 45 0c             	mov    0xc(%ebp),%eax
  803085:	01 d8                	add    %ebx,%eax
  803087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80308b:	89 3c 24             	mov    %edi,(%esp)
  80308e:	e8 41 ff ff ff       	call   802fd4 <read>
		if (m < 0)
  803093:	85 c0                	test   %eax,%eax
  803095:	78 10                	js     8030a7 <readn+0x43>
			return m;
		if (m == 0)
  803097:	85 c0                	test   %eax,%eax
  803099:	74 0a                	je     8030a5 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80309b:	01 c3                	add    %eax,%ebx
  80309d:	39 f3                	cmp    %esi,%ebx
  80309f:	72 d9                	jb     80307a <readn+0x16>
  8030a1:	89 d8                	mov    %ebx,%eax
  8030a3:	eb 02                	jmp    8030a7 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8030a5:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8030a7:	83 c4 1c             	add    $0x1c,%esp
  8030aa:	5b                   	pop    %ebx
  8030ab:	5e                   	pop    %esi
  8030ac:	5f                   	pop    %edi
  8030ad:	5d                   	pop    %ebp
  8030ae:	c3                   	ret    

008030af <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8030af:	55                   	push   %ebp
  8030b0:	89 e5                	mov    %esp,%ebp
  8030b2:	53                   	push   %ebx
  8030b3:	83 ec 24             	sub    $0x24,%esp
  8030b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8030b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8030bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030c0:	89 1c 24             	mov    %ebx,(%esp)
  8030c3:	e8 6e fc ff ff       	call   802d36 <fd_lookup>
  8030c8:	85 c0                	test   %eax,%eax
  8030ca:	78 68                	js     803134 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8030cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8030d6:	8b 00                	mov    (%eax),%eax
  8030d8:	89 04 24             	mov    %eax,(%esp)
  8030db:	e8 ac fc ff ff       	call   802d8c <dev_lookup>
  8030e0:	85 c0                	test   %eax,%eax
  8030e2:	78 50                	js     803134 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8030e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8030e7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8030eb:	75 23                	jne    803110 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8030ed:	a1 10 a0 80 00       	mov    0x80a010,%eax
  8030f2:	8b 40 48             	mov    0x48(%eax),%eax
  8030f5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8030f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030fd:	c7 04 24 6c 4b 80 00 	movl   $0x804b6c,(%esp)
  803104:	e8 9b ed ff ff       	call   801ea4 <cprintf>
		return -E_INVAL;
  803109:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80310e:	eb 24                	jmp    803134 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  803110:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803113:	8b 52 0c             	mov    0xc(%edx),%edx
  803116:	85 d2                	test   %edx,%edx
  803118:	74 15                	je     80312f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80311a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80311d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803121:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803124:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  803128:	89 04 24             	mov    %eax,(%esp)
  80312b:	ff d2                	call   *%edx
  80312d:	eb 05                	jmp    803134 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80312f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  803134:	83 c4 24             	add    $0x24,%esp
  803137:	5b                   	pop    %ebx
  803138:	5d                   	pop    %ebp
  803139:	c3                   	ret    

0080313a <seek>:

int
seek(int fdnum, off_t offset)
{
  80313a:	55                   	push   %ebp
  80313b:	89 e5                	mov    %esp,%ebp
  80313d:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803140:	8d 45 fc             	lea    -0x4(%ebp),%eax
  803143:	89 44 24 04          	mov    %eax,0x4(%esp)
  803147:	8b 45 08             	mov    0x8(%ebp),%eax
  80314a:	89 04 24             	mov    %eax,(%esp)
  80314d:	e8 e4 fb ff ff       	call   802d36 <fd_lookup>
  803152:	85 c0                	test   %eax,%eax
  803154:	78 0e                	js     803164 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  803156:	8b 45 fc             	mov    -0x4(%ebp),%eax
  803159:	8b 55 0c             	mov    0xc(%ebp),%edx
  80315c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80315f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803164:	c9                   	leave  
  803165:	c3                   	ret    

00803166 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  803166:	55                   	push   %ebp
  803167:	89 e5                	mov    %esp,%ebp
  803169:	53                   	push   %ebx
  80316a:	83 ec 24             	sub    $0x24,%esp
  80316d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  803170:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803173:	89 44 24 04          	mov    %eax,0x4(%esp)
  803177:	89 1c 24             	mov    %ebx,(%esp)
  80317a:	e8 b7 fb ff ff       	call   802d36 <fd_lookup>
  80317f:	85 c0                	test   %eax,%eax
  803181:	78 61                	js     8031e4 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803183:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803186:	89 44 24 04          	mov    %eax,0x4(%esp)
  80318a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80318d:	8b 00                	mov    (%eax),%eax
  80318f:	89 04 24             	mov    %eax,(%esp)
  803192:	e8 f5 fb ff ff       	call   802d8c <dev_lookup>
  803197:	85 c0                	test   %eax,%eax
  803199:	78 49                	js     8031e4 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80319b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80319e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8031a2:	75 23                	jne    8031c7 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8031a4:	a1 10 a0 80 00       	mov    0x80a010,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8031a9:	8b 40 48             	mov    0x48(%eax),%eax
  8031ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8031b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031b4:	c7 04 24 2c 4b 80 00 	movl   $0x804b2c,(%esp)
  8031bb:	e8 e4 ec ff ff       	call   801ea4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8031c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8031c5:	eb 1d                	jmp    8031e4 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8031c7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8031ca:	8b 52 18             	mov    0x18(%edx),%edx
  8031cd:	85 d2                	test   %edx,%edx
  8031cf:	74 0e                	je     8031df <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8031d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8031d4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8031d8:	89 04 24             	mov    %eax,(%esp)
  8031db:	ff d2                	call   *%edx
  8031dd:	eb 05                	jmp    8031e4 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8031df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8031e4:	83 c4 24             	add    $0x24,%esp
  8031e7:	5b                   	pop    %ebx
  8031e8:	5d                   	pop    %ebp
  8031e9:	c3                   	ret    

008031ea <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8031ea:	55                   	push   %ebp
  8031eb:	89 e5                	mov    %esp,%ebp
  8031ed:	53                   	push   %ebx
  8031ee:	83 ec 24             	sub    $0x24,%esp
  8031f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8031f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8031f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8031fe:	89 04 24             	mov    %eax,(%esp)
  803201:	e8 30 fb ff ff       	call   802d36 <fd_lookup>
  803206:	85 c0                	test   %eax,%eax
  803208:	78 52                	js     80325c <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80320a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80320d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803211:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803214:	8b 00                	mov    (%eax),%eax
  803216:	89 04 24             	mov    %eax,(%esp)
  803219:	e8 6e fb ff ff       	call   802d8c <dev_lookup>
  80321e:	85 c0                	test   %eax,%eax
  803220:	78 3a                	js     80325c <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  803222:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803225:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  803229:	74 2c                	je     803257 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80322b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80322e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  803235:	00 00 00 
	stat->st_isdir = 0;
  803238:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80323f:	00 00 00 
	stat->st_dev = dev;
  803242:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  803248:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80324c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80324f:	89 14 24             	mov    %edx,(%esp)
  803252:	ff 50 14             	call   *0x14(%eax)
  803255:	eb 05                	jmp    80325c <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  803257:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80325c:	83 c4 24             	add    $0x24,%esp
  80325f:	5b                   	pop    %ebx
  803260:	5d                   	pop    %ebp
  803261:	c3                   	ret    

00803262 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  803262:	55                   	push   %ebp
  803263:	89 e5                	mov    %esp,%ebp
  803265:	56                   	push   %esi
  803266:	53                   	push   %ebx
  803267:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80326a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803271:	00 
  803272:	8b 45 08             	mov    0x8(%ebp),%eax
  803275:	89 04 24             	mov    %eax,(%esp)
  803278:	e8 2a 02 00 00       	call   8034a7 <open>
  80327d:	89 c3                	mov    %eax,%ebx
  80327f:	85 c0                	test   %eax,%eax
  803281:	78 1b                	js     80329e <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  803283:	8b 45 0c             	mov    0xc(%ebp),%eax
  803286:	89 44 24 04          	mov    %eax,0x4(%esp)
  80328a:	89 1c 24             	mov    %ebx,(%esp)
  80328d:	e8 58 ff ff ff       	call   8031ea <fstat>
  803292:	89 c6                	mov    %eax,%esi
	close(fd);
  803294:	89 1c 24             	mov    %ebx,(%esp)
  803297:	e8 d2 fb ff ff       	call   802e6e <close>
	return r;
  80329c:	89 f3                	mov    %esi,%ebx
}
  80329e:	89 d8                	mov    %ebx,%eax
  8032a0:	83 c4 10             	add    $0x10,%esp
  8032a3:	5b                   	pop    %ebx
  8032a4:	5e                   	pop    %esi
  8032a5:	5d                   	pop    %ebp
  8032a6:	c3                   	ret    
	...

008032a8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8032a8:	55                   	push   %ebp
  8032a9:	89 e5                	mov    %esp,%ebp
  8032ab:	56                   	push   %esi
  8032ac:	53                   	push   %ebx
  8032ad:	83 ec 10             	sub    $0x10,%esp
  8032b0:	89 c3                	mov    %eax,%ebx
  8032b2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8032b4:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  8032bb:	75 11                	jne    8032ce <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8032bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8032c4:	e8 aa f9 ff ff       	call   802c73 <ipc_find_env>
  8032c9:	a3 00 a0 80 00       	mov    %eax,0x80a000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8032ce:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8032d5:	00 
  8032d6:	c7 44 24 08 00 b0 80 	movl   $0x80b000,0x8(%esp)
  8032dd:	00 
  8032de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8032e2:	a1 00 a0 80 00       	mov    0x80a000,%eax
  8032e7:	89 04 24             	mov    %eax,(%esp)
  8032ea:	e8 01 f9 ff ff       	call   802bf0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8032ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8032f6:	00 
  8032f7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8032fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803302:	e8 79 f8 ff ff       	call   802b80 <ipc_recv>
}
  803307:	83 c4 10             	add    $0x10,%esp
  80330a:	5b                   	pop    %ebx
  80330b:	5e                   	pop    %esi
  80330c:	5d                   	pop    %ebp
  80330d:	c3                   	ret    

0080330e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80330e:	55                   	push   %ebp
  80330f:	89 e5                	mov    %esp,%ebp
  803311:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  803314:	8b 45 08             	mov    0x8(%ebp),%eax
  803317:	8b 40 0c             	mov    0xc(%eax),%eax
  80331a:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  80331f:	8b 45 0c             	mov    0xc(%ebp),%eax
  803322:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  803327:	ba 00 00 00 00       	mov    $0x0,%edx
  80332c:	b8 02 00 00 00       	mov    $0x2,%eax
  803331:	e8 72 ff ff ff       	call   8032a8 <fsipc>
}
  803336:	c9                   	leave  
  803337:	c3                   	ret    

00803338 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  803338:	55                   	push   %ebp
  803339:	89 e5                	mov    %esp,%ebp
  80333b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80333e:	8b 45 08             	mov    0x8(%ebp),%eax
  803341:	8b 40 0c             	mov    0xc(%eax),%eax
  803344:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  803349:	ba 00 00 00 00       	mov    $0x0,%edx
  80334e:	b8 06 00 00 00       	mov    $0x6,%eax
  803353:	e8 50 ff ff ff       	call   8032a8 <fsipc>
}
  803358:	c9                   	leave  
  803359:	c3                   	ret    

0080335a <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80335a:	55                   	push   %ebp
  80335b:	89 e5                	mov    %esp,%ebp
  80335d:	53                   	push   %ebx
  80335e:	83 ec 14             	sub    $0x14,%esp
  803361:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  803364:	8b 45 08             	mov    0x8(%ebp),%eax
  803367:	8b 40 0c             	mov    0xc(%eax),%eax
  80336a:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80336f:	ba 00 00 00 00       	mov    $0x0,%edx
  803374:	b8 05 00 00 00       	mov    $0x5,%eax
  803379:	e8 2a ff ff ff       	call   8032a8 <fsipc>
  80337e:	85 c0                	test   %eax,%eax
  803380:	78 2b                	js     8033ad <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  803382:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  803389:	00 
  80338a:	89 1c 24             	mov    %ebx,(%esp)
  80338d:	e8 bd f0 ff ff       	call   80244f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  803392:	a1 80 b0 80 00       	mov    0x80b080,%eax
  803397:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80339d:	a1 84 b0 80 00       	mov    0x80b084,%eax
  8033a2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8033a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8033ad:	83 c4 14             	add    $0x14,%esp
  8033b0:	5b                   	pop    %ebx
  8033b1:	5d                   	pop    %ebp
  8033b2:	c3                   	ret    

008033b3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8033b3:	55                   	push   %ebp
  8033b4:	89 e5                	mov    %esp,%ebp
  8033b6:	83 ec 18             	sub    $0x18,%esp
  8033b9:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8033bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8033bf:	8b 52 0c             	mov    0xc(%edx),%edx
  8033c2:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	fsipcbuf.write.req_n = n;
  8033c8:	a3 04 b0 80 00       	mov    %eax,0x80b004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  8033cd:	89 c2                	mov    %eax,%edx
  8033cf:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8033d4:	76 05                	jbe    8033db <devfile_write+0x28>
  8033d6:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  8033db:	89 54 24 08          	mov    %edx,0x8(%esp)
  8033df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8033e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8033e6:	c7 04 24 08 b0 80 00 	movl   $0x80b008,(%esp)
  8033ed:	e8 40 f2 ff ff       	call   802632 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8033f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8033f7:	b8 04 00 00 00       	mov    $0x4,%eax
  8033fc:	e8 a7 fe ff ff       	call   8032a8 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  803401:	c9                   	leave  
  803402:	c3                   	ret    

00803403 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  803403:	55                   	push   %ebp
  803404:	89 e5                	mov    %esp,%ebp
  803406:	56                   	push   %esi
  803407:	53                   	push   %ebx
  803408:	83 ec 10             	sub    $0x10,%esp
  80340b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80340e:	8b 45 08             	mov    0x8(%ebp),%eax
  803411:	8b 40 0c             	mov    0xc(%eax),%eax
  803414:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  803419:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80341f:	ba 00 00 00 00       	mov    $0x0,%edx
  803424:	b8 03 00 00 00       	mov    $0x3,%eax
  803429:	e8 7a fe ff ff       	call   8032a8 <fsipc>
  80342e:	89 c3                	mov    %eax,%ebx
  803430:	85 c0                	test   %eax,%eax
  803432:	78 6a                	js     80349e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  803434:	39 c6                	cmp    %eax,%esi
  803436:	73 24                	jae    80345c <devfile_read+0x59>
  803438:	c7 44 24 0c a0 4b 80 	movl   $0x804ba0,0xc(%esp)
  80343f:	00 
  803440:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  803447:	00 
  803448:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80344f:	00 
  803450:	c7 04 24 a7 4b 80 00 	movl   $0x804ba7,(%esp)
  803457:	e8 50 e9 ff ff       	call   801dac <_panic>
	assert(r <= PGSIZE);
  80345c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  803461:	7e 24                	jle    803487 <devfile_read+0x84>
  803463:	c7 44 24 0c b2 4b 80 	movl   $0x804bb2,0xc(%esp)
  80346a:	00 
  80346b:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  803472:	00 
  803473:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80347a:	00 
  80347b:	c7 04 24 a7 4b 80 00 	movl   $0x804ba7,(%esp)
  803482:	e8 25 e9 ff ff       	call   801dac <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803487:	89 44 24 08          	mov    %eax,0x8(%esp)
  80348b:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  803492:	00 
  803493:	8b 45 0c             	mov    0xc(%ebp),%eax
  803496:	89 04 24             	mov    %eax,(%esp)
  803499:	e8 2a f1 ff ff       	call   8025c8 <memmove>
	return r;
}
  80349e:	89 d8                	mov    %ebx,%eax
  8034a0:	83 c4 10             	add    $0x10,%esp
  8034a3:	5b                   	pop    %ebx
  8034a4:	5e                   	pop    %esi
  8034a5:	5d                   	pop    %ebp
  8034a6:	c3                   	ret    

008034a7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8034a7:	55                   	push   %ebp
  8034a8:	89 e5                	mov    %esp,%ebp
  8034aa:	56                   	push   %esi
  8034ab:	53                   	push   %ebx
  8034ac:	83 ec 20             	sub    $0x20,%esp
  8034af:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8034b2:	89 34 24             	mov    %esi,(%esp)
  8034b5:	e8 62 ef ff ff       	call   80241c <strlen>
  8034ba:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8034bf:	7f 60                	jg     803521 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8034c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8034c4:	89 04 24             	mov    %eax,(%esp)
  8034c7:	e8 17 f8 ff ff       	call   802ce3 <fd_alloc>
  8034cc:	89 c3                	mov    %eax,%ebx
  8034ce:	85 c0                	test   %eax,%eax
  8034d0:	78 54                	js     803526 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8034d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8034d6:	c7 04 24 00 b0 80 00 	movl   $0x80b000,(%esp)
  8034dd:	e8 6d ef ff ff       	call   80244f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8034e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8034e5:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8034ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8034ed:	b8 01 00 00 00       	mov    $0x1,%eax
  8034f2:	e8 b1 fd ff ff       	call   8032a8 <fsipc>
  8034f7:	89 c3                	mov    %eax,%ebx
  8034f9:	85 c0                	test   %eax,%eax
  8034fb:	79 15                	jns    803512 <open+0x6b>
		fd_close(fd, 0);
  8034fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803504:	00 
  803505:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803508:	89 04 24             	mov    %eax,(%esp)
  80350b:	e8 d6 f8 ff ff       	call   802de6 <fd_close>
		return r;
  803510:	eb 14                	jmp    803526 <open+0x7f>
	}

	return fd2num(fd);
  803512:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803515:	89 04 24             	mov    %eax,(%esp)
  803518:	e8 9b f7 ff ff       	call   802cb8 <fd2num>
  80351d:	89 c3                	mov    %eax,%ebx
  80351f:	eb 05                	jmp    803526 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  803521:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  803526:	89 d8                	mov    %ebx,%eax
  803528:	83 c4 20             	add    $0x20,%esp
  80352b:	5b                   	pop    %ebx
  80352c:	5e                   	pop    %esi
  80352d:	5d                   	pop    %ebp
  80352e:	c3                   	ret    

0080352f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80352f:	55                   	push   %ebp
  803530:	89 e5                	mov    %esp,%ebp
  803532:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803535:	ba 00 00 00 00       	mov    $0x0,%edx
  80353a:	b8 08 00 00 00       	mov    $0x8,%eax
  80353f:	e8 64 fd ff ff       	call   8032a8 <fsipc>
}
  803544:	c9                   	leave  
  803545:	c3                   	ret    
	...

00803548 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803548:	55                   	push   %ebp
  803549:	89 e5                	mov    %esp,%ebp
  80354b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80354e:	89 c2                	mov    %eax,%edx
  803550:	c1 ea 16             	shr    $0x16,%edx
  803553:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80355a:	f6 c2 01             	test   $0x1,%dl
  80355d:	74 1e                	je     80357d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  80355f:	c1 e8 0c             	shr    $0xc,%eax
  803562:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  803569:	a8 01                	test   $0x1,%al
  80356b:	74 17                	je     803584 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80356d:	c1 e8 0c             	shr    $0xc,%eax
  803570:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  803577:	ef 
  803578:	0f b7 c0             	movzwl %ax,%eax
  80357b:	eb 0c                	jmp    803589 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80357d:	b8 00 00 00 00       	mov    $0x0,%eax
  803582:	eb 05                	jmp    803589 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  803584:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  803589:	5d                   	pop    %ebp
  80358a:	c3                   	ret    
	...

0080358c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80358c:	55                   	push   %ebp
  80358d:	89 e5                	mov    %esp,%ebp
  80358f:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  803592:	c7 44 24 04 be 4b 80 	movl   $0x804bbe,0x4(%esp)
  803599:	00 
  80359a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80359d:	89 04 24             	mov    %eax,(%esp)
  8035a0:	e8 aa ee ff ff       	call   80244f <strcpy>
	return 0;
}
  8035a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8035aa:	c9                   	leave  
  8035ab:	c3                   	ret    

008035ac <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8035ac:	55                   	push   %ebp
  8035ad:	89 e5                	mov    %esp,%ebp
  8035af:	53                   	push   %ebx
  8035b0:	83 ec 14             	sub    $0x14,%esp
  8035b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8035b6:	89 1c 24             	mov    %ebx,(%esp)
  8035b9:	e8 8a ff ff ff       	call   803548 <pageref>
  8035be:	83 f8 01             	cmp    $0x1,%eax
  8035c1:	75 0d                	jne    8035d0 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  8035c3:	8b 43 0c             	mov    0xc(%ebx),%eax
  8035c6:	89 04 24             	mov    %eax,(%esp)
  8035c9:	e8 1f 03 00 00       	call   8038ed <nsipc_close>
  8035ce:	eb 05                	jmp    8035d5 <devsock_close+0x29>
	else
		return 0;
  8035d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8035d5:	83 c4 14             	add    $0x14,%esp
  8035d8:	5b                   	pop    %ebx
  8035d9:	5d                   	pop    %ebp
  8035da:	c3                   	ret    

008035db <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8035db:	55                   	push   %ebp
  8035dc:	89 e5                	mov    %esp,%ebp
  8035de:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8035e1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8035e8:	00 
  8035e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8035ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8035f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8035f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8035f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8035fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8035fd:	89 04 24             	mov    %eax,(%esp)
  803600:	e8 e3 03 00 00       	call   8039e8 <nsipc_send>
}
  803605:	c9                   	leave  
  803606:	c3                   	ret    

00803607 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  803607:	55                   	push   %ebp
  803608:	89 e5                	mov    %esp,%ebp
  80360a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80360d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  803614:	00 
  803615:	8b 45 10             	mov    0x10(%ebp),%eax
  803618:	89 44 24 08          	mov    %eax,0x8(%esp)
  80361c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80361f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803623:	8b 45 08             	mov    0x8(%ebp),%eax
  803626:	8b 40 0c             	mov    0xc(%eax),%eax
  803629:	89 04 24             	mov    %eax,(%esp)
  80362c:	e8 37 03 00 00       	call   803968 <nsipc_recv>
}
  803631:	c9                   	leave  
  803632:	c3                   	ret    

00803633 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  803633:	55                   	push   %ebp
  803634:	89 e5                	mov    %esp,%ebp
  803636:	56                   	push   %esi
  803637:	53                   	push   %ebx
  803638:	83 ec 20             	sub    $0x20,%esp
  80363b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80363d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803640:	89 04 24             	mov    %eax,(%esp)
  803643:	e8 9b f6 ff ff       	call   802ce3 <fd_alloc>
  803648:	89 c3                	mov    %eax,%ebx
  80364a:	85 c0                	test   %eax,%eax
  80364c:	78 21                	js     80366f <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80364e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803655:	00 
  803656:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80365d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803664:	e8 d8 f1 ff ff       	call   802841 <sys_page_alloc>
  803669:	89 c3                	mov    %eax,%ebx
  80366b:	85 c0                	test   %eax,%eax
  80366d:	79 0a                	jns    803679 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  80366f:	89 34 24             	mov    %esi,(%esp)
  803672:	e8 76 02 00 00       	call   8038ed <nsipc_close>
		return r;
  803677:	eb 22                	jmp    80369b <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  803679:	8b 15 80 90 80 00    	mov    0x809080,%edx
  80367f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803682:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  803684:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803687:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80368e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  803691:	89 04 24             	mov    %eax,(%esp)
  803694:	e8 1f f6 ff ff       	call   802cb8 <fd2num>
  803699:	89 c3                	mov    %eax,%ebx
}
  80369b:	89 d8                	mov    %ebx,%eax
  80369d:	83 c4 20             	add    $0x20,%esp
  8036a0:	5b                   	pop    %ebx
  8036a1:	5e                   	pop    %esi
  8036a2:	5d                   	pop    %ebp
  8036a3:	c3                   	ret    

008036a4 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8036a4:	55                   	push   %ebp
  8036a5:	89 e5                	mov    %esp,%ebp
  8036a7:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8036aa:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8036ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8036b1:	89 04 24             	mov    %eax,(%esp)
  8036b4:	e8 7d f6 ff ff       	call   802d36 <fd_lookup>
  8036b9:	85 c0                	test   %eax,%eax
  8036bb:	78 17                	js     8036d4 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8036bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036c0:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8036c6:	39 10                	cmp    %edx,(%eax)
  8036c8:	75 05                	jne    8036cf <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8036ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8036cd:	eb 05                	jmp    8036d4 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8036cf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8036d4:	c9                   	leave  
  8036d5:	c3                   	ret    

008036d6 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8036d6:	55                   	push   %ebp
  8036d7:	89 e5                	mov    %esp,%ebp
  8036d9:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8036dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8036df:	e8 c0 ff ff ff       	call   8036a4 <fd2sockid>
  8036e4:	85 c0                	test   %eax,%eax
  8036e6:	78 1f                	js     803707 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8036e8:	8b 55 10             	mov    0x10(%ebp),%edx
  8036eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8036ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8036f2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8036f6:	89 04 24             	mov    %eax,(%esp)
  8036f9:	e8 38 01 00 00       	call   803836 <nsipc_accept>
  8036fe:	85 c0                	test   %eax,%eax
  803700:	78 05                	js     803707 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  803702:	e8 2c ff ff ff       	call   803633 <alloc_sockfd>
}
  803707:	c9                   	leave  
  803708:	c3                   	ret    

00803709 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  803709:	55                   	push   %ebp
  80370a:	89 e5                	mov    %esp,%ebp
  80370c:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80370f:	8b 45 08             	mov    0x8(%ebp),%eax
  803712:	e8 8d ff ff ff       	call   8036a4 <fd2sockid>
  803717:	85 c0                	test   %eax,%eax
  803719:	78 16                	js     803731 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80371b:	8b 55 10             	mov    0x10(%ebp),%edx
  80371e:	89 54 24 08          	mov    %edx,0x8(%esp)
  803722:	8b 55 0c             	mov    0xc(%ebp),%edx
  803725:	89 54 24 04          	mov    %edx,0x4(%esp)
  803729:	89 04 24             	mov    %eax,(%esp)
  80372c:	e8 5b 01 00 00       	call   80388c <nsipc_bind>
}
  803731:	c9                   	leave  
  803732:	c3                   	ret    

00803733 <shutdown>:

int
shutdown(int s, int how)
{
  803733:	55                   	push   %ebp
  803734:	89 e5                	mov    %esp,%ebp
  803736:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803739:	8b 45 08             	mov    0x8(%ebp),%eax
  80373c:	e8 63 ff ff ff       	call   8036a4 <fd2sockid>
  803741:	85 c0                	test   %eax,%eax
  803743:	78 0f                	js     803754 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  803745:	8b 55 0c             	mov    0xc(%ebp),%edx
  803748:	89 54 24 04          	mov    %edx,0x4(%esp)
  80374c:	89 04 24             	mov    %eax,(%esp)
  80374f:	e8 77 01 00 00       	call   8038cb <nsipc_shutdown>
}
  803754:	c9                   	leave  
  803755:	c3                   	ret    

00803756 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803756:	55                   	push   %ebp
  803757:	89 e5                	mov    %esp,%ebp
  803759:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80375c:	8b 45 08             	mov    0x8(%ebp),%eax
  80375f:	e8 40 ff ff ff       	call   8036a4 <fd2sockid>
  803764:	85 c0                	test   %eax,%eax
  803766:	78 16                	js     80377e <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  803768:	8b 55 10             	mov    0x10(%ebp),%edx
  80376b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80376f:	8b 55 0c             	mov    0xc(%ebp),%edx
  803772:	89 54 24 04          	mov    %edx,0x4(%esp)
  803776:	89 04 24             	mov    %eax,(%esp)
  803779:	e8 89 01 00 00       	call   803907 <nsipc_connect>
}
  80377e:	c9                   	leave  
  80377f:	c3                   	ret    

00803780 <listen>:

int
listen(int s, int backlog)
{
  803780:	55                   	push   %ebp
  803781:	89 e5                	mov    %esp,%ebp
  803783:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803786:	8b 45 08             	mov    0x8(%ebp),%eax
  803789:	e8 16 ff ff ff       	call   8036a4 <fd2sockid>
  80378e:	85 c0                	test   %eax,%eax
  803790:	78 0f                	js     8037a1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  803792:	8b 55 0c             	mov    0xc(%ebp),%edx
  803795:	89 54 24 04          	mov    %edx,0x4(%esp)
  803799:	89 04 24             	mov    %eax,(%esp)
  80379c:	e8 a5 01 00 00       	call   803946 <nsipc_listen>
}
  8037a1:	c9                   	leave  
  8037a2:	c3                   	ret    

008037a3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8037a3:	55                   	push   %ebp
  8037a4:	89 e5                	mov    %esp,%ebp
  8037a6:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8037a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8037ac:	89 44 24 08          	mov    %eax,0x8(%esp)
  8037b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8037b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8037b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8037ba:	89 04 24             	mov    %eax,(%esp)
  8037bd:	e8 99 02 00 00       	call   803a5b <nsipc_socket>
  8037c2:	85 c0                	test   %eax,%eax
  8037c4:	78 05                	js     8037cb <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8037c6:	e8 68 fe ff ff       	call   803633 <alloc_sockfd>
}
  8037cb:	c9                   	leave  
  8037cc:	c3                   	ret    
  8037cd:	00 00                	add    %al,(%eax)
	...

008037d0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8037d0:	55                   	push   %ebp
  8037d1:	89 e5                	mov    %esp,%ebp
  8037d3:	53                   	push   %ebx
  8037d4:	83 ec 14             	sub    $0x14,%esp
  8037d7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8037d9:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  8037e0:	75 11                	jne    8037f3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8037e2:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8037e9:	e8 85 f4 ff ff       	call   802c73 <ipc_find_env>
  8037ee:	a3 04 a0 80 00       	mov    %eax,0x80a004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8037f3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8037fa:	00 
  8037fb:	c7 44 24 08 00 c0 80 	movl   $0x80c000,0x8(%esp)
  803802:	00 
  803803:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803807:	a1 04 a0 80 00       	mov    0x80a004,%eax
  80380c:	89 04 24             	mov    %eax,(%esp)
  80380f:	e8 dc f3 ff ff       	call   802bf0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  803814:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80381b:	00 
  80381c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803823:	00 
  803824:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80382b:	e8 50 f3 ff ff       	call   802b80 <ipc_recv>
}
  803830:	83 c4 14             	add    $0x14,%esp
  803833:	5b                   	pop    %ebx
  803834:	5d                   	pop    %ebp
  803835:	c3                   	ret    

00803836 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  803836:	55                   	push   %ebp
  803837:	89 e5                	mov    %esp,%ebp
  803839:	56                   	push   %esi
  80383a:	53                   	push   %ebx
  80383b:	83 ec 10             	sub    $0x10,%esp
  80383e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  803841:	8b 45 08             	mov    0x8(%ebp),%eax
  803844:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.accept.req_addrlen = *addrlen;
  803849:	8b 06                	mov    (%esi),%eax
  80384b:	a3 04 c0 80 00       	mov    %eax,0x80c004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  803850:	b8 01 00 00 00       	mov    $0x1,%eax
  803855:	e8 76 ff ff ff       	call   8037d0 <nsipc>
  80385a:	89 c3                	mov    %eax,%ebx
  80385c:	85 c0                	test   %eax,%eax
  80385e:	78 23                	js     803883 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  803860:	a1 10 c0 80 00       	mov    0x80c010,%eax
  803865:	89 44 24 08          	mov    %eax,0x8(%esp)
  803869:	c7 44 24 04 00 c0 80 	movl   $0x80c000,0x4(%esp)
  803870:	00 
  803871:	8b 45 0c             	mov    0xc(%ebp),%eax
  803874:	89 04 24             	mov    %eax,(%esp)
  803877:	e8 4c ed ff ff       	call   8025c8 <memmove>
		*addrlen = ret->ret_addrlen;
  80387c:	a1 10 c0 80 00       	mov    0x80c010,%eax
  803881:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  803883:	89 d8                	mov    %ebx,%eax
  803885:	83 c4 10             	add    $0x10,%esp
  803888:	5b                   	pop    %ebx
  803889:	5e                   	pop    %esi
  80388a:	5d                   	pop    %ebp
  80388b:	c3                   	ret    

0080388c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80388c:	55                   	push   %ebp
  80388d:	89 e5                	mov    %esp,%ebp
  80388f:	53                   	push   %ebx
  803890:	83 ec 14             	sub    $0x14,%esp
  803893:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  803896:	8b 45 08             	mov    0x8(%ebp),%eax
  803899:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80389e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8038a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8038a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8038a9:	c7 04 24 04 c0 80 00 	movl   $0x80c004,(%esp)
  8038b0:	e8 13 ed ff ff       	call   8025c8 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8038b5:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_BIND);
  8038bb:	b8 02 00 00 00       	mov    $0x2,%eax
  8038c0:	e8 0b ff ff ff       	call   8037d0 <nsipc>
}
  8038c5:	83 c4 14             	add    $0x14,%esp
  8038c8:	5b                   	pop    %ebx
  8038c9:	5d                   	pop    %ebp
  8038ca:	c3                   	ret    

008038cb <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8038cb:	55                   	push   %ebp
  8038cc:	89 e5                	mov    %esp,%ebp
  8038ce:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8038d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8038d4:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.shutdown.req_how = how;
  8038d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8038dc:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_SHUTDOWN);
  8038e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8038e6:	e8 e5 fe ff ff       	call   8037d0 <nsipc>
}
  8038eb:	c9                   	leave  
  8038ec:	c3                   	ret    

008038ed <nsipc_close>:

int
nsipc_close(int s)
{
  8038ed:	55                   	push   %ebp
  8038ee:	89 e5                	mov    %esp,%ebp
  8038f0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8038f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8038f6:	a3 00 c0 80 00       	mov    %eax,0x80c000
	return nsipc(NSREQ_CLOSE);
  8038fb:	b8 04 00 00 00       	mov    $0x4,%eax
  803900:	e8 cb fe ff ff       	call   8037d0 <nsipc>
}
  803905:	c9                   	leave  
  803906:	c3                   	ret    

00803907 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803907:	55                   	push   %ebp
  803908:	89 e5                	mov    %esp,%ebp
  80390a:	53                   	push   %ebx
  80390b:	83 ec 14             	sub    $0x14,%esp
  80390e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  803911:	8b 45 08             	mov    0x8(%ebp),%eax
  803914:	a3 00 c0 80 00       	mov    %eax,0x80c000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  803919:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80391d:	8b 45 0c             	mov    0xc(%ebp),%eax
  803920:	89 44 24 04          	mov    %eax,0x4(%esp)
  803924:	c7 04 24 04 c0 80 00 	movl   $0x80c004,(%esp)
  80392b:	e8 98 ec ff ff       	call   8025c8 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  803930:	89 1d 14 c0 80 00    	mov    %ebx,0x80c014
	return nsipc(NSREQ_CONNECT);
  803936:	b8 05 00 00 00       	mov    $0x5,%eax
  80393b:	e8 90 fe ff ff       	call   8037d0 <nsipc>
}
  803940:	83 c4 14             	add    $0x14,%esp
  803943:	5b                   	pop    %ebx
  803944:	5d                   	pop    %ebp
  803945:	c3                   	ret    

00803946 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  803946:	55                   	push   %ebp
  803947:	89 e5                	mov    %esp,%ebp
  803949:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  80394c:	8b 45 08             	mov    0x8(%ebp),%eax
  80394f:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.listen.req_backlog = backlog;
  803954:	8b 45 0c             	mov    0xc(%ebp),%eax
  803957:	a3 04 c0 80 00       	mov    %eax,0x80c004
	return nsipc(NSREQ_LISTEN);
  80395c:	b8 06 00 00 00       	mov    $0x6,%eax
  803961:	e8 6a fe ff ff       	call   8037d0 <nsipc>
}
  803966:	c9                   	leave  
  803967:	c3                   	ret    

00803968 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  803968:	55                   	push   %ebp
  803969:	89 e5                	mov    %esp,%ebp
  80396b:	56                   	push   %esi
  80396c:	53                   	push   %ebx
  80396d:	83 ec 10             	sub    $0x10,%esp
  803970:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  803973:	8b 45 08             	mov    0x8(%ebp),%eax
  803976:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.recv.req_len = len;
  80397b:	89 35 04 c0 80 00    	mov    %esi,0x80c004
	nsipcbuf.recv.req_flags = flags;
  803981:	8b 45 14             	mov    0x14(%ebp),%eax
  803984:	a3 08 c0 80 00       	mov    %eax,0x80c008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  803989:	b8 07 00 00 00       	mov    $0x7,%eax
  80398e:	e8 3d fe ff ff       	call   8037d0 <nsipc>
  803993:	89 c3                	mov    %eax,%ebx
  803995:	85 c0                	test   %eax,%eax
  803997:	78 46                	js     8039df <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  803999:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80399e:	7f 04                	jg     8039a4 <nsipc_recv+0x3c>
  8039a0:	39 c6                	cmp    %eax,%esi
  8039a2:	7d 24                	jge    8039c8 <nsipc_recv+0x60>
  8039a4:	c7 44 24 0c ca 4b 80 	movl   $0x804bca,0xc(%esp)
  8039ab:	00 
  8039ac:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  8039b3:	00 
  8039b4:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8039bb:	00 
  8039bc:	c7 04 24 df 4b 80 00 	movl   $0x804bdf,(%esp)
  8039c3:	e8 e4 e3 ff ff       	call   801dac <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8039c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8039cc:	c7 44 24 04 00 c0 80 	movl   $0x80c000,0x4(%esp)
  8039d3:	00 
  8039d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8039d7:	89 04 24             	mov    %eax,(%esp)
  8039da:	e8 e9 eb ff ff       	call   8025c8 <memmove>
	}

	return r;
}
  8039df:	89 d8                	mov    %ebx,%eax
  8039e1:	83 c4 10             	add    $0x10,%esp
  8039e4:	5b                   	pop    %ebx
  8039e5:	5e                   	pop    %esi
  8039e6:	5d                   	pop    %ebp
  8039e7:	c3                   	ret    

008039e8 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8039e8:	55                   	push   %ebp
  8039e9:	89 e5                	mov    %esp,%ebp
  8039eb:	53                   	push   %ebx
  8039ec:	83 ec 14             	sub    $0x14,%esp
  8039ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8039f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8039f5:	a3 00 c0 80 00       	mov    %eax,0x80c000
	assert(size < 1600);
  8039fa:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  803a00:	7e 24                	jle    803a26 <nsipc_send+0x3e>
  803a02:	c7 44 24 0c eb 4b 80 	movl   $0x804beb,0xc(%esp)
  803a09:	00 
  803a0a:	c7 44 24 08 3d 42 80 	movl   $0x80423d,0x8(%esp)
  803a11:	00 
  803a12:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  803a19:	00 
  803a1a:	c7 04 24 df 4b 80 00 	movl   $0x804bdf,(%esp)
  803a21:	e8 86 e3 ff ff       	call   801dac <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  803a26:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803a2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  803a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803a31:	c7 04 24 0c c0 80 00 	movl   $0x80c00c,(%esp)
  803a38:	e8 8b eb ff ff       	call   8025c8 <memmove>
	nsipcbuf.send.req_size = size;
  803a3d:	89 1d 04 c0 80 00    	mov    %ebx,0x80c004
	nsipcbuf.send.req_flags = flags;
  803a43:	8b 45 14             	mov    0x14(%ebp),%eax
  803a46:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SEND);
  803a4b:	b8 08 00 00 00       	mov    $0x8,%eax
  803a50:	e8 7b fd ff ff       	call   8037d0 <nsipc>
}
  803a55:	83 c4 14             	add    $0x14,%esp
  803a58:	5b                   	pop    %ebx
  803a59:	5d                   	pop    %ebp
  803a5a:	c3                   	ret    

00803a5b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  803a5b:	55                   	push   %ebp
  803a5c:	89 e5                	mov    %esp,%ebp
  803a5e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  803a61:	8b 45 08             	mov    0x8(%ebp),%eax
  803a64:	a3 00 c0 80 00       	mov    %eax,0x80c000
	nsipcbuf.socket.req_type = type;
  803a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  803a6c:	a3 04 c0 80 00       	mov    %eax,0x80c004
	nsipcbuf.socket.req_protocol = protocol;
  803a71:	8b 45 10             	mov    0x10(%ebp),%eax
  803a74:	a3 08 c0 80 00       	mov    %eax,0x80c008
	return nsipc(NSREQ_SOCKET);
  803a79:	b8 09 00 00 00       	mov    $0x9,%eax
  803a7e:	e8 4d fd ff ff       	call   8037d0 <nsipc>
}
  803a83:	c9                   	leave  
  803a84:	c3                   	ret    
  803a85:	00 00                	add    %al,(%eax)
	...

00803a88 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803a88:	55                   	push   %ebp
  803a89:	89 e5                	mov    %esp,%ebp
  803a8b:	56                   	push   %esi
  803a8c:	53                   	push   %ebx
  803a8d:	83 ec 10             	sub    $0x10,%esp
  803a90:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  803a93:	8b 45 08             	mov    0x8(%ebp),%eax
  803a96:	89 04 24             	mov    %eax,(%esp)
  803a99:	e8 2a f2 ff ff       	call   802cc8 <fd2data>
  803a9e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  803aa0:	c7 44 24 04 f7 4b 80 	movl   $0x804bf7,0x4(%esp)
  803aa7:	00 
  803aa8:	89 34 24             	mov    %esi,(%esp)
  803aab:	e8 9f e9 ff ff       	call   80244f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803ab0:	8b 43 04             	mov    0x4(%ebx),%eax
  803ab3:	2b 03                	sub    (%ebx),%eax
  803ab5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  803abb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  803ac2:	00 00 00 
	stat->st_dev = &devpipe;
  803ac5:	c7 86 88 00 00 00 9c 	movl   $0x80909c,0x88(%esi)
  803acc:	90 80 00 
	return 0;
}
  803acf:	b8 00 00 00 00       	mov    $0x0,%eax
  803ad4:	83 c4 10             	add    $0x10,%esp
  803ad7:	5b                   	pop    %ebx
  803ad8:	5e                   	pop    %esi
  803ad9:	5d                   	pop    %ebp
  803ada:	c3                   	ret    

00803adb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803adb:	55                   	push   %ebp
  803adc:	89 e5                	mov    %esp,%ebp
  803ade:	53                   	push   %ebx
  803adf:	83 ec 14             	sub    $0x14,%esp
  803ae2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803ae5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803ae9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803af0:	e8 f3 ed ff ff       	call   8028e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  803af5:	89 1c 24             	mov    %ebx,(%esp)
  803af8:	e8 cb f1 ff ff       	call   802cc8 <fd2data>
  803afd:	89 44 24 04          	mov    %eax,0x4(%esp)
  803b01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803b08:	e8 db ed ff ff       	call   8028e8 <sys_page_unmap>
}
  803b0d:	83 c4 14             	add    $0x14,%esp
  803b10:	5b                   	pop    %ebx
  803b11:	5d                   	pop    %ebp
  803b12:	c3                   	ret    

00803b13 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803b13:	55                   	push   %ebp
  803b14:	89 e5                	mov    %esp,%ebp
  803b16:	57                   	push   %edi
  803b17:	56                   	push   %esi
  803b18:	53                   	push   %ebx
  803b19:	83 ec 2c             	sub    $0x2c,%esp
  803b1c:	89 c7                	mov    %eax,%edi
  803b1e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803b21:	a1 10 a0 80 00       	mov    0x80a010,%eax
  803b26:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  803b29:	89 3c 24             	mov    %edi,(%esp)
  803b2c:	e8 17 fa ff ff       	call   803548 <pageref>
  803b31:	89 c6                	mov    %eax,%esi
  803b33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803b36:	89 04 24             	mov    %eax,(%esp)
  803b39:	e8 0a fa ff ff       	call   803548 <pageref>
  803b3e:	39 c6                	cmp    %eax,%esi
  803b40:	0f 94 c0             	sete   %al
  803b43:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  803b46:	8b 15 10 a0 80 00    	mov    0x80a010,%edx
  803b4c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803b4f:	39 cb                	cmp    %ecx,%ebx
  803b51:	75 08                	jne    803b5b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  803b53:	83 c4 2c             	add    $0x2c,%esp
  803b56:	5b                   	pop    %ebx
  803b57:	5e                   	pop    %esi
  803b58:	5f                   	pop    %edi
  803b59:	5d                   	pop    %ebp
  803b5a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  803b5b:	83 f8 01             	cmp    $0x1,%eax
  803b5e:	75 c1                	jne    803b21 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803b60:	8b 42 58             	mov    0x58(%edx),%eax
  803b63:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  803b6a:	00 
  803b6b:	89 44 24 08          	mov    %eax,0x8(%esp)
  803b6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803b73:	c7 04 24 fe 4b 80 00 	movl   $0x804bfe,(%esp)
  803b7a:	e8 25 e3 ff ff       	call   801ea4 <cprintf>
  803b7f:	eb a0                	jmp    803b21 <_pipeisclosed+0xe>

00803b81 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803b81:	55                   	push   %ebp
  803b82:	89 e5                	mov    %esp,%ebp
  803b84:	57                   	push   %edi
  803b85:	56                   	push   %esi
  803b86:	53                   	push   %ebx
  803b87:	83 ec 1c             	sub    $0x1c,%esp
  803b8a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803b8d:	89 34 24             	mov    %esi,(%esp)
  803b90:	e8 33 f1 ff ff       	call   802cc8 <fd2data>
  803b95:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803b97:	bf 00 00 00 00       	mov    $0x0,%edi
  803b9c:	eb 3c                	jmp    803bda <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803b9e:	89 da                	mov    %ebx,%edx
  803ba0:	89 f0                	mov    %esi,%eax
  803ba2:	e8 6c ff ff ff       	call   803b13 <_pipeisclosed>
  803ba7:	85 c0                	test   %eax,%eax
  803ba9:	75 38                	jne    803be3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803bab:	e8 72 ec ff ff       	call   802822 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803bb0:	8b 43 04             	mov    0x4(%ebx),%eax
  803bb3:	8b 13                	mov    (%ebx),%edx
  803bb5:	83 c2 20             	add    $0x20,%edx
  803bb8:	39 d0                	cmp    %edx,%eax
  803bba:	73 e2                	jae    803b9e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803bbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  803bbf:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  803bc2:	89 c2                	mov    %eax,%edx
  803bc4:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  803bca:	79 05                	jns    803bd1 <devpipe_write+0x50>
  803bcc:	4a                   	dec    %edx
  803bcd:	83 ca e0             	or     $0xffffffe0,%edx
  803bd0:	42                   	inc    %edx
  803bd1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803bd5:	40                   	inc    %eax
  803bd6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803bd9:	47                   	inc    %edi
  803bda:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803bdd:	75 d1                	jne    803bb0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803bdf:	89 f8                	mov    %edi,%eax
  803be1:	eb 05                	jmp    803be8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803be3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  803be8:	83 c4 1c             	add    $0x1c,%esp
  803beb:	5b                   	pop    %ebx
  803bec:	5e                   	pop    %esi
  803bed:	5f                   	pop    %edi
  803bee:	5d                   	pop    %ebp
  803bef:	c3                   	ret    

00803bf0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803bf0:	55                   	push   %ebp
  803bf1:	89 e5                	mov    %esp,%ebp
  803bf3:	57                   	push   %edi
  803bf4:	56                   	push   %esi
  803bf5:	53                   	push   %ebx
  803bf6:	83 ec 1c             	sub    $0x1c,%esp
  803bf9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803bfc:	89 3c 24             	mov    %edi,(%esp)
  803bff:	e8 c4 f0 ff ff       	call   802cc8 <fd2data>
  803c04:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803c06:	be 00 00 00 00       	mov    $0x0,%esi
  803c0b:	eb 3a                	jmp    803c47 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803c0d:	85 f6                	test   %esi,%esi
  803c0f:	74 04                	je     803c15 <devpipe_read+0x25>
				return i;
  803c11:	89 f0                	mov    %esi,%eax
  803c13:	eb 40                	jmp    803c55 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  803c15:	89 da                	mov    %ebx,%edx
  803c17:	89 f8                	mov    %edi,%eax
  803c19:	e8 f5 fe ff ff       	call   803b13 <_pipeisclosed>
  803c1e:	85 c0                	test   %eax,%eax
  803c20:	75 2e                	jne    803c50 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803c22:	e8 fb eb ff ff       	call   802822 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  803c27:	8b 03                	mov    (%ebx),%eax
  803c29:	3b 43 04             	cmp    0x4(%ebx),%eax
  803c2c:	74 df                	je     803c0d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803c2e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  803c33:	79 05                	jns    803c3a <devpipe_read+0x4a>
  803c35:	48                   	dec    %eax
  803c36:	83 c8 e0             	or     $0xffffffe0,%eax
  803c39:	40                   	inc    %eax
  803c3a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  803c3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  803c41:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  803c44:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803c46:	46                   	inc    %esi
  803c47:	3b 75 10             	cmp    0x10(%ebp),%esi
  803c4a:	75 db                	jne    803c27 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803c4c:	89 f0                	mov    %esi,%eax
  803c4e:	eb 05                	jmp    803c55 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803c50:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803c55:	83 c4 1c             	add    $0x1c,%esp
  803c58:	5b                   	pop    %ebx
  803c59:	5e                   	pop    %esi
  803c5a:	5f                   	pop    %edi
  803c5b:	5d                   	pop    %ebp
  803c5c:	c3                   	ret    

00803c5d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803c5d:	55                   	push   %ebp
  803c5e:	89 e5                	mov    %esp,%ebp
  803c60:	57                   	push   %edi
  803c61:	56                   	push   %esi
  803c62:	53                   	push   %ebx
  803c63:	83 ec 3c             	sub    $0x3c,%esp
  803c66:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803c69:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  803c6c:	89 04 24             	mov    %eax,(%esp)
  803c6f:	e8 6f f0 ff ff       	call   802ce3 <fd_alloc>
  803c74:	89 c3                	mov    %eax,%ebx
  803c76:	85 c0                	test   %eax,%eax
  803c78:	0f 88 45 01 00 00    	js     803dc3 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803c7e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803c85:	00 
  803c86:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803c89:	89 44 24 04          	mov    %eax,0x4(%esp)
  803c8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803c94:	e8 a8 eb ff ff       	call   802841 <sys_page_alloc>
  803c99:	89 c3                	mov    %eax,%ebx
  803c9b:	85 c0                	test   %eax,%eax
  803c9d:	0f 88 20 01 00 00    	js     803dc3 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803ca3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  803ca6:	89 04 24             	mov    %eax,(%esp)
  803ca9:	e8 35 f0 ff ff       	call   802ce3 <fd_alloc>
  803cae:	89 c3                	mov    %eax,%ebx
  803cb0:	85 c0                	test   %eax,%eax
  803cb2:	0f 88 f8 00 00 00    	js     803db0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803cb8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803cbf:	00 
  803cc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803cc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  803cc7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803cce:	e8 6e eb ff ff       	call   802841 <sys_page_alloc>
  803cd3:	89 c3                	mov    %eax,%ebx
  803cd5:	85 c0                	test   %eax,%eax
  803cd7:	0f 88 d3 00 00 00    	js     803db0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803cdd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803ce0:	89 04 24             	mov    %eax,(%esp)
  803ce3:	e8 e0 ef ff ff       	call   802cc8 <fd2data>
  803ce8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803cea:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803cf1:	00 
  803cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  803cf6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803cfd:	e8 3f eb ff ff       	call   802841 <sys_page_alloc>
  803d02:	89 c3                	mov    %eax,%ebx
  803d04:	85 c0                	test   %eax,%eax
  803d06:	0f 88 91 00 00 00    	js     803d9d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803d0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803d0f:	89 04 24             	mov    %eax,(%esp)
  803d12:	e8 b1 ef ff ff       	call   802cc8 <fd2data>
  803d17:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  803d1e:	00 
  803d1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803d23:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803d2a:	00 
  803d2b:	89 74 24 04          	mov    %esi,0x4(%esp)
  803d2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803d36:	e8 5a eb ff ff       	call   802895 <sys_page_map>
  803d3b:	89 c3                	mov    %eax,%ebx
  803d3d:	85 c0                	test   %eax,%eax
  803d3f:	78 4c                	js     803d8d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803d41:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803d47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803d4a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803d4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803d4f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803d56:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803d5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803d5f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803d61:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803d64:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803d6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803d6e:	89 04 24             	mov    %eax,(%esp)
  803d71:	e8 42 ef ff ff       	call   802cb8 <fd2num>
  803d76:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  803d78:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803d7b:	89 04 24             	mov    %eax,(%esp)
  803d7e:	e8 35 ef ff ff       	call   802cb8 <fd2num>
  803d83:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  803d86:	bb 00 00 00 00       	mov    $0x0,%ebx
  803d8b:	eb 36                	jmp    803dc3 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  803d8d:	89 74 24 04          	mov    %esi,0x4(%esp)
  803d91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803d98:	e8 4b eb ff ff       	call   8028e8 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  803d9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803da0:	89 44 24 04          	mov    %eax,0x4(%esp)
  803da4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803dab:	e8 38 eb ff ff       	call   8028e8 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  803db0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803db3:	89 44 24 04          	mov    %eax,0x4(%esp)
  803db7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803dbe:	e8 25 eb ff ff       	call   8028e8 <sys_page_unmap>
    err:
	return r;
}
  803dc3:	89 d8                	mov    %ebx,%eax
  803dc5:	83 c4 3c             	add    $0x3c,%esp
  803dc8:	5b                   	pop    %ebx
  803dc9:	5e                   	pop    %esi
  803dca:	5f                   	pop    %edi
  803dcb:	5d                   	pop    %ebp
  803dcc:	c3                   	ret    

00803dcd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803dcd:	55                   	push   %ebp
  803dce:	89 e5                	mov    %esp,%ebp
  803dd0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803dd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803dd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  803dda:	8b 45 08             	mov    0x8(%ebp),%eax
  803ddd:	89 04 24             	mov    %eax,(%esp)
  803de0:	e8 51 ef ff ff       	call   802d36 <fd_lookup>
  803de5:	85 c0                	test   %eax,%eax
  803de7:	78 15                	js     803dfe <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803dec:	89 04 24             	mov    %eax,(%esp)
  803def:	e8 d4 ee ff ff       	call   802cc8 <fd2data>
	return _pipeisclosed(fd, p);
  803df4:	89 c2                	mov    %eax,%edx
  803df6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803df9:	e8 15 fd ff ff       	call   803b13 <_pipeisclosed>
}
  803dfe:	c9                   	leave  
  803dff:	c3                   	ret    

00803e00 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803e00:	55                   	push   %ebp
  803e01:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803e03:	b8 00 00 00 00       	mov    $0x0,%eax
  803e08:	5d                   	pop    %ebp
  803e09:	c3                   	ret    

00803e0a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  803e0a:	55                   	push   %ebp
  803e0b:	89 e5                	mov    %esp,%ebp
  803e0d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  803e10:	c7 44 24 04 16 4c 80 	movl   $0x804c16,0x4(%esp)
  803e17:	00 
  803e18:	8b 45 0c             	mov    0xc(%ebp),%eax
  803e1b:	89 04 24             	mov    %eax,(%esp)
  803e1e:	e8 2c e6 ff ff       	call   80244f <strcpy>
	return 0;
}
  803e23:	b8 00 00 00 00       	mov    $0x0,%eax
  803e28:	c9                   	leave  
  803e29:	c3                   	ret    

00803e2a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803e2a:	55                   	push   %ebp
  803e2b:	89 e5                	mov    %esp,%ebp
  803e2d:	57                   	push   %edi
  803e2e:	56                   	push   %esi
  803e2f:	53                   	push   %ebx
  803e30:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803e36:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803e3b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803e41:	eb 30                	jmp    803e73 <devcons_write+0x49>
		m = n - tot;
  803e43:	8b 75 10             	mov    0x10(%ebp),%esi
  803e46:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  803e48:	83 fe 7f             	cmp    $0x7f,%esi
  803e4b:	76 05                	jbe    803e52 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  803e4d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  803e52:	89 74 24 08          	mov    %esi,0x8(%esp)
  803e56:	03 45 0c             	add    0xc(%ebp),%eax
  803e59:	89 44 24 04          	mov    %eax,0x4(%esp)
  803e5d:	89 3c 24             	mov    %edi,(%esp)
  803e60:	e8 63 e7 ff ff       	call   8025c8 <memmove>
		sys_cputs(buf, m);
  803e65:	89 74 24 04          	mov    %esi,0x4(%esp)
  803e69:	89 3c 24             	mov    %edi,(%esp)
  803e6c:	e8 03 e9 ff ff       	call   802774 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803e71:	01 f3                	add    %esi,%ebx
  803e73:	89 d8                	mov    %ebx,%eax
  803e75:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803e78:	72 c9                	jb     803e43 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  803e7a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  803e80:	5b                   	pop    %ebx
  803e81:	5e                   	pop    %esi
  803e82:	5f                   	pop    %edi
  803e83:	5d                   	pop    %ebp
  803e84:	c3                   	ret    

00803e85 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803e85:	55                   	push   %ebp
  803e86:	89 e5                	mov    %esp,%ebp
  803e88:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  803e8b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803e8f:	75 07                	jne    803e98 <devcons_read+0x13>
  803e91:	eb 25                	jmp    803eb8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  803e93:	e8 8a e9 ff ff       	call   802822 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  803e98:	e8 f5 e8 ff ff       	call   802792 <sys_cgetc>
  803e9d:	85 c0                	test   %eax,%eax
  803e9f:	74 f2                	je     803e93 <devcons_read+0xe>
  803ea1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  803ea3:	85 c0                	test   %eax,%eax
  803ea5:	78 1d                	js     803ec4 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  803ea7:	83 f8 04             	cmp    $0x4,%eax
  803eaa:	74 13                	je     803ebf <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  803eac:	8b 45 0c             	mov    0xc(%ebp),%eax
  803eaf:	88 10                	mov    %dl,(%eax)
	return 1;
  803eb1:	b8 01 00 00 00       	mov    $0x1,%eax
  803eb6:	eb 0c                	jmp    803ec4 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  803eb8:	b8 00 00 00 00       	mov    $0x0,%eax
  803ebd:	eb 05                	jmp    803ec4 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  803ebf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  803ec4:	c9                   	leave  
  803ec5:	c3                   	ret    

00803ec6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  803ec6:	55                   	push   %ebp
  803ec7:	89 e5                	mov    %esp,%ebp
  803ec9:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  803ecc:	8b 45 08             	mov    0x8(%ebp),%eax
  803ecf:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803ed2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803ed9:	00 
  803eda:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803edd:	89 04 24             	mov    %eax,(%esp)
  803ee0:	e8 8f e8 ff ff       	call   802774 <sys_cputs>
}
  803ee5:	c9                   	leave  
  803ee6:	c3                   	ret    

00803ee7 <getchar>:

int
getchar(void)
{
  803ee7:	55                   	push   %ebp
  803ee8:	89 e5                	mov    %esp,%ebp
  803eea:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803eed:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  803ef4:	00 
  803ef5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803ef8:	89 44 24 04          	mov    %eax,0x4(%esp)
  803efc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803f03:	e8 cc f0 ff ff       	call   802fd4 <read>
	if (r < 0)
  803f08:	85 c0                	test   %eax,%eax
  803f0a:	78 0f                	js     803f1b <getchar+0x34>
		return r;
	if (r < 1)
  803f0c:	85 c0                	test   %eax,%eax
  803f0e:	7e 06                	jle    803f16 <getchar+0x2f>
		return -E_EOF;
	return c;
  803f10:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803f14:	eb 05                	jmp    803f1b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803f16:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803f1b:	c9                   	leave  
  803f1c:	c3                   	ret    

00803f1d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  803f1d:	55                   	push   %ebp
  803f1e:	89 e5                	mov    %esp,%ebp
  803f20:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803f23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803f26:	89 44 24 04          	mov    %eax,0x4(%esp)
  803f2a:	8b 45 08             	mov    0x8(%ebp),%eax
  803f2d:	89 04 24             	mov    %eax,(%esp)
  803f30:	e8 01 ee ff ff       	call   802d36 <fd_lookup>
  803f35:	85 c0                	test   %eax,%eax
  803f37:	78 11                	js     803f4a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803f3c:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803f42:	39 10                	cmp    %edx,(%eax)
  803f44:	0f 94 c0             	sete   %al
  803f47:	0f b6 c0             	movzbl %al,%eax
}
  803f4a:	c9                   	leave  
  803f4b:	c3                   	ret    

00803f4c <opencons>:

int
opencons(void)
{
  803f4c:	55                   	push   %ebp
  803f4d:	89 e5                	mov    %esp,%ebp
  803f4f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803f52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803f55:	89 04 24             	mov    %eax,(%esp)
  803f58:	e8 86 ed ff ff       	call   802ce3 <fd_alloc>
  803f5d:	85 c0                	test   %eax,%eax
  803f5f:	78 3c                	js     803f9d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803f61:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803f68:	00 
  803f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803f6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803f70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803f77:	e8 c5 e8 ff ff       	call   802841 <sys_page_alloc>
  803f7c:	85 c0                	test   %eax,%eax
  803f7e:	78 1d                	js     803f9d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803f80:	8b 15 b8 90 80 00    	mov    0x8090b8,%edx
  803f86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803f89:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803f8e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803f95:	89 04 24             	mov    %eax,(%esp)
  803f98:	e8 1b ed ff ff       	call   802cb8 <fd2num>
}
  803f9d:	c9                   	leave  
  803f9e:	c3                   	ret    
	...

00803fa0 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  803fa0:	55                   	push   %ebp
  803fa1:	57                   	push   %edi
  803fa2:	56                   	push   %esi
  803fa3:	83 ec 10             	sub    $0x10,%esp
  803fa6:	8b 74 24 20          	mov    0x20(%esp),%esi
  803faa:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  803fae:	89 74 24 04          	mov    %esi,0x4(%esp)
  803fb2:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  803fb6:	89 cd                	mov    %ecx,%ebp
  803fb8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  803fbc:	85 c0                	test   %eax,%eax
  803fbe:	75 2c                	jne    803fec <__udivdi3+0x4c>
    {
      if (d0 > n1)
  803fc0:	39 f9                	cmp    %edi,%ecx
  803fc2:	77 68                	ja     80402c <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  803fc4:	85 c9                	test   %ecx,%ecx
  803fc6:	75 0b                	jne    803fd3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  803fc8:	b8 01 00 00 00       	mov    $0x1,%eax
  803fcd:	31 d2                	xor    %edx,%edx
  803fcf:	f7 f1                	div    %ecx
  803fd1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803fd3:	31 d2                	xor    %edx,%edx
  803fd5:	89 f8                	mov    %edi,%eax
  803fd7:	f7 f1                	div    %ecx
  803fd9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803fdb:	89 f0                	mov    %esi,%eax
  803fdd:	f7 f1                	div    %ecx
  803fdf:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803fe1:	89 f0                	mov    %esi,%eax
  803fe3:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803fe5:	83 c4 10             	add    $0x10,%esp
  803fe8:	5e                   	pop    %esi
  803fe9:	5f                   	pop    %edi
  803fea:	5d                   	pop    %ebp
  803feb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803fec:	39 f8                	cmp    %edi,%eax
  803fee:	77 2c                	ja     80401c <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  803ff0:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  803ff3:	83 f6 1f             	xor    $0x1f,%esi
  803ff6:	75 4c                	jne    804044 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803ff8:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  803ffa:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  803fff:	72 0a                	jb     80400b <__udivdi3+0x6b>
  804001:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  804005:	0f 87 ad 00 00 00    	ja     8040b8 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80400b:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  804010:	89 f0                	mov    %esi,%eax
  804012:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  804014:	83 c4 10             	add    $0x10,%esp
  804017:	5e                   	pop    %esi
  804018:	5f                   	pop    %edi
  804019:	5d                   	pop    %ebp
  80401a:	c3                   	ret    
  80401b:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  80401c:	31 ff                	xor    %edi,%edi
  80401e:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  804020:	89 f0                	mov    %esi,%eax
  804022:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  804024:	83 c4 10             	add    $0x10,%esp
  804027:	5e                   	pop    %esi
  804028:	5f                   	pop    %edi
  804029:	5d                   	pop    %ebp
  80402a:	c3                   	ret    
  80402b:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80402c:	89 fa                	mov    %edi,%edx
  80402e:	89 f0                	mov    %esi,%eax
  804030:	f7 f1                	div    %ecx
  804032:	89 c6                	mov    %eax,%esi
  804034:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  804036:	89 f0                	mov    %esi,%eax
  804038:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80403a:	83 c4 10             	add    $0x10,%esp
  80403d:	5e                   	pop    %esi
  80403e:	5f                   	pop    %edi
  80403f:	5d                   	pop    %ebp
  804040:	c3                   	ret    
  804041:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  804044:	89 f1                	mov    %esi,%ecx
  804046:	d3 e0                	shl    %cl,%eax
  804048:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80404c:	b8 20 00 00 00       	mov    $0x20,%eax
  804051:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  804053:	89 ea                	mov    %ebp,%edx
  804055:	88 c1                	mov    %al,%cl
  804057:	d3 ea                	shr    %cl,%edx
  804059:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80405d:	09 ca                	or     %ecx,%edx
  80405f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  804063:	89 f1                	mov    %esi,%ecx
  804065:	d3 e5                	shl    %cl,%ebp
  804067:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80406b:	89 fd                	mov    %edi,%ebp
  80406d:	88 c1                	mov    %al,%cl
  80406f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  804071:	89 fa                	mov    %edi,%edx
  804073:	89 f1                	mov    %esi,%ecx
  804075:	d3 e2                	shl    %cl,%edx
  804077:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80407b:	88 c1                	mov    %al,%cl
  80407d:	d3 ef                	shr    %cl,%edi
  80407f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  804081:	89 f8                	mov    %edi,%eax
  804083:	89 ea                	mov    %ebp,%edx
  804085:	f7 74 24 08          	divl   0x8(%esp)
  804089:	89 d1                	mov    %edx,%ecx
  80408b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  80408d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  804091:	39 d1                	cmp    %edx,%ecx
  804093:	72 17                	jb     8040ac <__udivdi3+0x10c>
  804095:	74 09                	je     8040a0 <__udivdi3+0x100>
  804097:	89 fe                	mov    %edi,%esi
  804099:	31 ff                	xor    %edi,%edi
  80409b:	e9 41 ff ff ff       	jmp    803fe1 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  8040a0:	8b 54 24 04          	mov    0x4(%esp),%edx
  8040a4:	89 f1                	mov    %esi,%ecx
  8040a6:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8040a8:	39 c2                	cmp    %eax,%edx
  8040aa:	73 eb                	jae    804097 <__udivdi3+0xf7>
		{
		  q0--;
  8040ac:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8040af:	31 ff                	xor    %edi,%edi
  8040b1:	e9 2b ff ff ff       	jmp    803fe1 <__udivdi3+0x41>
  8040b6:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8040b8:	31 f6                	xor    %esi,%esi
  8040ba:	e9 22 ff ff ff       	jmp    803fe1 <__udivdi3+0x41>
	...

008040c0 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8040c0:	55                   	push   %ebp
  8040c1:	57                   	push   %edi
  8040c2:	56                   	push   %esi
  8040c3:	83 ec 20             	sub    $0x20,%esp
  8040c6:	8b 44 24 30          	mov    0x30(%esp),%eax
  8040ca:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8040ce:	89 44 24 14          	mov    %eax,0x14(%esp)
  8040d2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8040d6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8040da:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8040de:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8040e0:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8040e2:	85 ed                	test   %ebp,%ebp
  8040e4:	75 16                	jne    8040fc <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8040e6:	39 f1                	cmp    %esi,%ecx
  8040e8:	0f 86 a6 00 00 00    	jbe    804194 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8040ee:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8040f0:	89 d0                	mov    %edx,%eax
  8040f2:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8040f4:	83 c4 20             	add    $0x20,%esp
  8040f7:	5e                   	pop    %esi
  8040f8:	5f                   	pop    %edi
  8040f9:	5d                   	pop    %ebp
  8040fa:	c3                   	ret    
  8040fb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8040fc:	39 f5                	cmp    %esi,%ebp
  8040fe:	0f 87 ac 00 00 00    	ja     8041b0 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  804104:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  804107:	83 f0 1f             	xor    $0x1f,%eax
  80410a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80410e:	0f 84 a8 00 00 00    	je     8041bc <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  804114:	8a 4c 24 10          	mov    0x10(%esp),%cl
  804118:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80411a:	bf 20 00 00 00       	mov    $0x20,%edi
  80411f:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  804123:	8b 44 24 0c          	mov    0xc(%esp),%eax
  804127:	89 f9                	mov    %edi,%ecx
  804129:	d3 e8                	shr    %cl,%eax
  80412b:	09 e8                	or     %ebp,%eax
  80412d:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  804131:	8b 44 24 0c          	mov    0xc(%esp),%eax
  804135:	8a 4c 24 10          	mov    0x10(%esp),%cl
  804139:	d3 e0                	shl    %cl,%eax
  80413b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80413f:	89 f2                	mov    %esi,%edx
  804141:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  804143:	8b 44 24 14          	mov    0x14(%esp),%eax
  804147:	d3 e0                	shl    %cl,%eax
  804149:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  80414d:	8b 44 24 14          	mov    0x14(%esp),%eax
  804151:	89 f9                	mov    %edi,%ecx
  804153:	d3 e8                	shr    %cl,%eax
  804155:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  804157:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  804159:	89 f2                	mov    %esi,%edx
  80415b:	f7 74 24 18          	divl   0x18(%esp)
  80415f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  804161:	f7 64 24 0c          	mull   0xc(%esp)
  804165:	89 c5                	mov    %eax,%ebp
  804167:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  804169:	39 d6                	cmp    %edx,%esi
  80416b:	72 67                	jb     8041d4 <__umoddi3+0x114>
  80416d:	74 75                	je     8041e4 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  80416f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  804173:	29 e8                	sub    %ebp,%eax
  804175:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  804177:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80417b:	d3 e8                	shr    %cl,%eax
  80417d:	89 f2                	mov    %esi,%edx
  80417f:	89 f9                	mov    %edi,%ecx
  804181:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  804183:	09 d0                	or     %edx,%eax
  804185:	89 f2                	mov    %esi,%edx
  804187:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80418b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80418d:	83 c4 20             	add    $0x20,%esp
  804190:	5e                   	pop    %esi
  804191:	5f                   	pop    %edi
  804192:	5d                   	pop    %ebp
  804193:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  804194:	85 c9                	test   %ecx,%ecx
  804196:	75 0b                	jne    8041a3 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  804198:	b8 01 00 00 00       	mov    $0x1,%eax
  80419d:	31 d2                	xor    %edx,%edx
  80419f:	f7 f1                	div    %ecx
  8041a1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8041a3:	89 f0                	mov    %esi,%eax
  8041a5:	31 d2                	xor    %edx,%edx
  8041a7:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8041a9:	89 f8                	mov    %edi,%eax
  8041ab:	e9 3e ff ff ff       	jmp    8040ee <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8041b0:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8041b2:	83 c4 20             	add    $0x20,%esp
  8041b5:	5e                   	pop    %esi
  8041b6:	5f                   	pop    %edi
  8041b7:	5d                   	pop    %ebp
  8041b8:	c3                   	ret    
  8041b9:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8041bc:	39 f5                	cmp    %esi,%ebp
  8041be:	72 04                	jb     8041c4 <__umoddi3+0x104>
  8041c0:	39 f9                	cmp    %edi,%ecx
  8041c2:	77 06                	ja     8041ca <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8041c4:	89 f2                	mov    %esi,%edx
  8041c6:	29 cf                	sub    %ecx,%edi
  8041c8:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8041ca:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8041cc:	83 c4 20             	add    $0x20,%esp
  8041cf:	5e                   	pop    %esi
  8041d0:	5f                   	pop    %edi
  8041d1:	5d                   	pop    %ebp
  8041d2:	c3                   	ret    
  8041d3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8041d4:	89 d1                	mov    %edx,%ecx
  8041d6:	89 c5                	mov    %eax,%ebp
  8041d8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8041dc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8041e0:	eb 8d                	jmp    80416f <__umoddi3+0xaf>
  8041e2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8041e4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8041e8:	72 ea                	jb     8041d4 <__umoddi3+0x114>
  8041ea:	89 f1                	mov    %esi,%ecx
  8041ec:	eb 81                	jmp    80416f <__umoddi3+0xaf>
