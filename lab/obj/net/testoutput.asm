
obj/net/testoutput:     file format elf32-i386


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
  80002c:	e8 1f 03 00 00       	call   800350 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	envid_t ns_envid = sys_getenvid();
  80003b:	e8 d7 0d 00 00       	call   800e17 <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx
	int i, r;

	binaryname = "testoutput";
  800042:	c7 05 00 40 80 00 c0 	movl   $0x802bc0,0x804000
  800049:	2b 80 00 

	output_envid = fork();
  80004c:	e8 a6 11 00 00       	call   8011f7 <fork>
  800051:	a3 00 50 80 00       	mov    %eax,0x805000
	if (output_envid < 0)
  800056:	85 c0                	test   %eax,%eax
  800058:	79 1c                	jns    800076 <umain+0x42>
		panic("error forking");
  80005a:	c7 44 24 08 cb 2b 80 	movl   $0x802bcb,0x8(%esp)
  800061:	00 
  800062:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  800069:	00 
  80006a:	c7 04 24 d9 2b 80 00 	movl   $0x802bd9,(%esp)
  800071:	e8 4a 03 00 00       	call   8003c0 <_panic>
	else if (output_envid == 0) {
  800076:	85 c0                	test   %eax,%eax
  800078:	75 0d                	jne    800087 <umain+0x53>
		output(ns_envid);
  80007a:	89 1c 24             	mov    %ebx,(%esp)
  80007d:	e8 52 02 00 00       	call   8002d4 <output>
		return;
  800082:	e9 c7 00 00 00       	jmp    80014e <umain+0x11a>
	binaryname = "testoutput";

	output_envid = fork();
	if (output_envid < 0)
		panic("error forking");
	else if (output_envid == 0) {
  800087:	bb 00 00 00 00       	mov    $0x0,%ebx
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  80008c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  80009b:	0f 
  80009c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a3:	e8 ad 0d 00 00       	call   800e55 <sys_page_alloc>
  8000a8:	85 c0                	test   %eax,%eax
  8000aa:	79 20                	jns    8000cc <umain+0x98>
			panic("sys_page_alloc: %e", r);
  8000ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000b0:	c7 44 24 08 ea 2b 80 	movl   $0x802bea,0x8(%esp)
  8000b7:	00 
  8000b8:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8000bf:	00 
  8000c0:	c7 04 24 d9 2b 80 00 	movl   $0x802bd9,(%esp)
  8000c7:	e8 f4 02 00 00       	call   8003c0 <_panic>
		pkt->jp_len = snprintf(pkt->jp_data,
  8000cc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000d0:	c7 44 24 08 fd 2b 80 	movl   $0x802bfd,0x8(%esp)
  8000d7:	00 
  8000d8:	c7 44 24 04 fc 0f 00 	movl   $0xffc,0x4(%esp)
  8000df:	00 
  8000e0:	c7 04 24 04 b0 fe 0f 	movl   $0xffeb004,(%esp)
  8000e7:	e8 19 09 00 00       	call   800a05 <snprintf>
  8000ec:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000f5:	c7 04 24 09 2c 80 00 	movl   $0x802c09,(%esp)
  8000fc:	e8 b7 03 00 00       	call   8004b8 <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  800101:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800108:	00 
  800109:	c7 44 24 08 00 b0 fe 	movl   $0xffeb000,0x8(%esp)
  800110:	0f 
  800111:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800118:	00 
  800119:	a1 00 50 80 00       	mov    0x805000,%eax
  80011e:	89 04 24             	mov    %eax,(%esp)
  800121:	e8 26 14 00 00       	call   80154c <ipc_send>
		sys_page_unmap(0, pkt);
  800126:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  80012d:	0f 
  80012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800135:	e8 c2 0d 00 00       	call   800efc <sys_page_unmap>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  80013a:	43                   	inc    %ebx
  80013b:	83 fb 0a             	cmp    $0xa,%ebx
  80013e:	0f 85 48 ff ff ff    	jne    80008c <umain+0x58>
  800144:	b3 14                	mov    $0x14,%bl
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  800146:	e8 eb 0c 00 00       	call   800e36 <sys_yield>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  80014b:	4b                   	dec    %ebx
  80014c:	75 f8                	jne    800146 <umain+0x112>
		sys_yield();
}
  80014e:	83 c4 14             	add    $0x14,%esp
  800151:	5b                   	pop    %ebx
  800152:	5d                   	pop    %ebp
  800153:	c3                   	ret    

00800154 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	57                   	push   %edi
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
  80015a:	83 ec 2c             	sub    $0x2c,%esp
  80015d:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  800160:	e8 58 0f 00 00       	call   8010bd <sys_time_msec>
  800165:	89 c3                	mov    %eax,%ebx
  800167:	03 5d 0c             	add    0xc(%ebp),%ebx

	binaryname = "ns_timer";
  80016a:	c7 05 00 40 80 00 21 	movl   $0x802c21,0x804000
  800171:	2c 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800174:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800177:	eb 05                	jmp    80017e <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  800179:	e8 b8 0c 00 00       	call   800e36 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  80017e:	e8 3a 0f 00 00       	call   8010bd <sys_time_msec>
  800183:	39 c3                	cmp    %eax,%ebx
  800185:	76 06                	jbe    80018d <timer+0x39>
  800187:	85 c0                	test   %eax,%eax
  800189:	79 ee                	jns    800179 <timer+0x25>
  80018b:	eb 04                	jmp    800191 <timer+0x3d>
			sys_yield();
		}
		if (r < 0)
  80018d:	85 c0                	test   %eax,%eax
  80018f:	79 20                	jns    8001b1 <timer+0x5d>
			panic("sys_time_msec: %e", r);
  800191:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800195:	c7 44 24 08 2a 2c 80 	movl   $0x802c2a,0x8(%esp)
  80019c:	00 
  80019d:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8001a4:	00 
  8001a5:	c7 04 24 3c 2c 80 00 	movl   $0x802c3c,(%esp)
  8001ac:	e8 0f 02 00 00       	call   8003c0 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8001b1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001b8:	00 
  8001b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001c0:	00 
  8001c1:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  8001c8:	00 
  8001c9:	89 3c 24             	mov    %edi,(%esp)
  8001cc:	e8 7b 13 00 00       	call   80154c <ipc_send>

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8001d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001d8:	00 
  8001d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001e0:	00 
  8001e1:	89 34 24             	mov    %esi,(%esp)
  8001e4:	e8 f3 12 00 00       	call   8014dc <ipc_recv>
  8001e9:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  8001eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001ee:	39 c7                	cmp    %eax,%edi
  8001f0:	74 12                	je     800204 <timer+0xb0>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  8001f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f6:	c7 04 24 48 2c 80 00 	movl   $0x802c48,(%esp)
  8001fd:	e8 b6 02 00 00       	call   8004b8 <cprintf>
				continue;
			}

			stop = sys_time_msec() + to;
			break;
		}
  800202:	eb cd                	jmp    8001d1 <timer+0x7d>
			if (whom != ns_envid) {
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
				continue;
			}

			stop = sys_time_msec() + to;
  800204:	e8 b4 0e 00 00       	call   8010bd <sys_time_msec>
  800209:	01 c3                	add    %eax,%ebx
			break;
		}
	}
  80020b:	e9 6e ff ff ff       	jmp    80017e <timer+0x2a>

00800210 <input>:

#define INPUT_COUNT 10

void
input(envid_t ns_envid)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	83 ec 10             	sub    $0x10,%esp
  800218:	8b 75 08             	mov    0x8(%ebp),%esi
	binaryname = "ns_input";
  80021b:	c7 05 00 40 80 00 83 	movl   $0x802c83,0x804000
  800222:	2c 80 00 
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
	struct jif_pkt *pkt = (struct jif_pkt *)REQVA;
	int r;
	if ((r = sys_page_alloc(0, pkt, PTE_P | PTE_U | PTE_W)) < 0)
  800225:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80022c:	00 
  80022d:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  800234:	0f 
  800235:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80023c:	e8 14 0c 00 00       	call   800e55 <sys_page_alloc>
  800241:	85 c0                	test   %eax,%eax
  800243:	79 20                	jns    800265 <input+0x55>
			panic("sys_page_alloc: %e", r);
  800245:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800249:	c7 44 24 08 ea 2b 80 	movl   $0x802bea,0x8(%esp)
  800250:	00 
  800251:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  800258:	00 
  800259:	c7 04 24 8c 2c 80 00 	movl   $0x802c8c,(%esp)
  800260:	e8 5b 01 00 00       	call   8003c0 <_panic>
	uint32_t len;
		
	while (1)
	{
		// cprintf("input hello world\n");
		if ((r = sys_e1000_receive(pkt->jp_data, (uint32_t *)&pkt->jp_len)) < 0)
  800265:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  80026c:	0f 
  80026d:	c7 04 24 04 b0 fe 0f 	movl   $0xffeb004,(%esp)
  800274:	e8 84 0e 00 00       	call   8010fd <sys_e1000_receive>
  800279:	85 c0                	test   %eax,%eax
  80027b:	78 e8                	js     800265 <input+0x55>
		{
			continue;
		}
		memcpy(nsipcbuf.pkt.jp_data,pkt->jp_data,pkt->jp_len);
  80027d:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  800282:	89 44 24 08          	mov    %eax,0x8(%esp)
  800286:	c7 44 24 04 04 b0 fe 	movl   $0xffeb004,0x4(%esp)
  80028d:	0f 
  80028e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  800295:	e8 ac 09 00 00       	call   800c46 <memcpy>
		nsipcbuf.pkt.jp_len = pkt->jp_len;
  80029a:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  80029f:	a3 00 70 80 00       	mov    %eax,0x807000
		ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_P | PTE_W | PTE_U);
  8002a4:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8002ab:	00 
  8002ac:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8002b3:	00 
  8002b4:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  8002bb:	00 
  8002bc:	89 34 24             	mov    %esi,(%esp)
  8002bf:	e8 88 12 00 00       	call   80154c <ipc_send>
  8002c4:	bb 14 00 00 00       	mov    $0x14,%ebx
		
		for (int i = 0; i < INPUT_COUNT*2; i++)
			sys_yield();
  8002c9:	e8 68 0b 00 00       	call   800e36 <sys_yield>
		}
		memcpy(nsipcbuf.pkt.jp_data,pkt->jp_data,pkt->jp_len);
		nsipcbuf.pkt.jp_len = pkt->jp_len;
		ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_P | PTE_W | PTE_U);
		
		for (int i = 0; i < INPUT_COUNT*2; i++)
  8002ce:	4b                   	dec    %ebx
  8002cf:	75 f8                	jne    8002c9 <input+0xb9>
  8002d1:	eb 92                	jmp    800265 <input+0x55>
	...

008002d4 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	83 ec 18             	sub    $0x18,%esp
	binaryname = "ns_output";
  8002da:	c7 05 00 40 80 00 98 	movl   $0x802c98,0x804000
  8002e1:	2c 80 00 
	struct jif_pkt *pkt = &(nsipcbuf.pkt); //= (struct jif_pkt *)(REQVA + PGSIZE);
	int r;

	while (1)
	{
		if ((r = ipc_recv(&ns_envid, pkt, 0)) < 0)
  8002e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8002eb:	00 
  8002ec:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8002f3:	00 
  8002f4:	8d 45 08             	lea    0x8(%ebp),%eax
  8002f7:	89 04 24             	mov    %eax,(%esp)
  8002fa:	e8 dd 11 00 00       	call   8014dc <ipc_recv>
  8002ff:	85 c0                	test   %eax,%eax
  800301:	79 0e                	jns    800311 <output+0x3d>
		{
			cprintf("output ipc_recv error\n");
  800303:	c7 04 24 a2 2c 80 00 	movl   $0x802ca2,(%esp)
  80030a:	e8 a9 01 00 00       	call   8004b8 <cprintf>
			continue;
  80030f:	eb d3                	jmp    8002e4 <output+0x10>
		}
		while(1){		
			if ((r = sys_e1000_transmit(pkt->jp_data, pkt->jp_len)) < 0)
  800311:	a1 00 70 80 00       	mov    0x807000,%eax
  800316:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031a:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  800321:	e8 b6 0d 00 00       	call   8010dc <sys_e1000_transmit>
  800326:	85 c0                	test   %eax,%eax
  800328:	79 ba                	jns    8002e4 <output+0x10>
			{
				if (r != -E_NET_NO_DES)
  80032a:	83 f8 f0             	cmp    $0xfffffff0,%eax
  80032d:	74 0e                	je     80033d <output+0x69>
				{
					cprintf("output sys_e1000_transmit error\n");
  80032f:	c7 04 24 d8 2c 80 00 	movl   $0x802cd8,(%esp)
  800336:	e8 7d 01 00 00       	call   8004b8 <cprintf>
  80033b:	eb d4                	jmp    800311 <output+0x3d>
				}
				else
				{
					cprintf("output packet overflow yield\n");
  80033d:	c7 04 24 b9 2c 80 00 	movl   $0x802cb9,(%esp)
  800344:	e8 6f 01 00 00       	call   8004b8 <cprintf>
					sys_yield();
  800349:	e8 e8 0a 00 00       	call   800e36 <sys_yield>
  80034e:	eb c1                	jmp    800311 <output+0x3d>

00800350 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	56                   	push   %esi
  800354:	53                   	push   %ebx
  800355:	83 ec 10             	sub    $0x10,%esp
  800358:	8b 75 08             	mov    0x8(%ebp),%esi
  80035b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80035e:	e8 b4 0a 00 00       	call   800e17 <sys_getenvid>
  800363:	25 ff 03 00 00       	and    $0x3ff,%eax
  800368:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80036f:	c1 e0 07             	shl    $0x7,%eax
  800372:	29 d0                	sub    %edx,%eax
  800374:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800379:	a3 0c 50 80 00       	mov    %eax,0x80500c


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80037e:	85 f6                	test   %esi,%esi
  800380:	7e 07                	jle    800389 <libmain+0x39>
		binaryname = argv[0];
  800382:	8b 03                	mov    (%ebx),%eax
  800384:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800389:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80038d:	89 34 24             	mov    %esi,(%esp)
  800390:	e8 9f fc ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800395:	e8 0a 00 00 00       	call   8003a4 <exit>
}
  80039a:	83 c4 10             	add    $0x10,%esp
  80039d:	5b                   	pop    %ebx
  80039e:	5e                   	pop    %esi
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    
  8003a1:	00 00                	add    %al,(%eax)
	...

008003a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8003aa:	e8 4c 14 00 00       	call   8017fb <close_all>
	sys_env_destroy(0);
  8003af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003b6:	e8 0a 0a 00 00       	call   800dc5 <sys_env_destroy>
}
  8003bb:	c9                   	leave  
  8003bc:	c3                   	ret    
  8003bd:	00 00                	add    %al,(%eax)
	...

008003c0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003c0:	55                   	push   %ebp
  8003c1:	89 e5                	mov    %esp,%ebp
  8003c3:	56                   	push   %esi
  8003c4:	53                   	push   %ebx
  8003c5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8003c8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003cb:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8003d1:	e8 41 0a 00 00       	call   800e17 <sys_getenvid>
  8003d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ec:	c7 04 24 04 2d 80 00 	movl   $0x802d04,(%esp)
  8003f3:	e8 c0 00 00 00       	call   8004b8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ff:	89 04 24             	mov    %eax,(%esp)
  800402:	e8 50 00 00 00       	call   800457 <vcprintf>
	cprintf("\n");
  800407:	c7 04 24 1f 2c 80 00 	movl   $0x802c1f,(%esp)
  80040e:	e8 a5 00 00 00       	call   8004b8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800413:	cc                   	int3   
  800414:	eb fd                	jmp    800413 <_panic+0x53>
	...

00800418 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	53                   	push   %ebx
  80041c:	83 ec 14             	sub    $0x14,%esp
  80041f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800422:	8b 03                	mov    (%ebx),%eax
  800424:	8b 55 08             	mov    0x8(%ebp),%edx
  800427:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80042b:	40                   	inc    %eax
  80042c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80042e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800433:	75 19                	jne    80044e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800435:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80043c:	00 
  80043d:	8d 43 08             	lea    0x8(%ebx),%eax
  800440:	89 04 24             	mov    %eax,(%esp)
  800443:	e8 40 09 00 00       	call   800d88 <sys_cputs>
		b->idx = 0;
  800448:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80044e:	ff 43 04             	incl   0x4(%ebx)
}
  800451:	83 c4 14             	add    $0x14,%esp
  800454:	5b                   	pop    %ebx
  800455:	5d                   	pop    %ebp
  800456:	c3                   	ret    

00800457 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800457:	55                   	push   %ebp
  800458:	89 e5                	mov    %esp,%ebp
  80045a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800460:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800467:	00 00 00 
	b.cnt = 0;
  80046a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800471:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800474:	8b 45 0c             	mov    0xc(%ebp),%eax
  800477:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80047b:	8b 45 08             	mov    0x8(%ebp),%eax
  80047e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800482:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800488:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048c:	c7 04 24 18 04 80 00 	movl   $0x800418,(%esp)
  800493:	e8 82 01 00 00       	call   80061a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800498:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80049e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004a8:	89 04 24             	mov    %eax,(%esp)
  8004ab:	e8 d8 08 00 00       	call   800d88 <sys_cputs>

	return b.cnt;
}
  8004b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004b6:	c9                   	leave  
  8004b7:	c3                   	ret    

008004b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c8:	89 04 24             	mov    %eax,(%esp)
  8004cb:	e8 87 ff ff ff       	call   800457 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004d0:	c9                   	leave  
  8004d1:	c3                   	ret    
	...

008004d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	57                   	push   %edi
  8004d8:	56                   	push   %esi
  8004d9:	53                   	push   %ebx
  8004da:	83 ec 3c             	sub    $0x3c,%esp
  8004dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004e0:	89 d7                	mov    %edx,%edi
  8004e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8004e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004eb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ee:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004f1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004f4:	85 c0                	test   %eax,%eax
  8004f6:	75 08                	jne    800500 <printnum+0x2c>
  8004f8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004fb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8004fe:	77 57                	ja     800557 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800500:	89 74 24 10          	mov    %esi,0x10(%esp)
  800504:	4b                   	dec    %ebx
  800505:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800509:	8b 45 10             	mov    0x10(%ebp),%eax
  80050c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800510:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800514:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800518:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80051f:	00 
  800520:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800523:	89 04 24             	mov    %eax,(%esp)
  800526:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800529:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052d:	e8 3e 24 00 00       	call   802970 <__udivdi3>
  800532:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800536:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80053a:	89 04 24             	mov    %eax,(%esp)
  80053d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800541:	89 fa                	mov    %edi,%edx
  800543:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800546:	e8 89 ff ff ff       	call   8004d4 <printnum>
  80054b:	eb 0f                	jmp    80055c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80054d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800551:	89 34 24             	mov    %esi,(%esp)
  800554:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800557:	4b                   	dec    %ebx
  800558:	85 db                	test   %ebx,%ebx
  80055a:	7f f1                	jg     80054d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80055c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800560:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800564:	8b 45 10             	mov    0x10(%ebp),%eax
  800567:	89 44 24 08          	mov    %eax,0x8(%esp)
  80056b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800572:	00 
  800573:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800576:	89 04 24             	mov    %eax,(%esp)
  800579:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80057c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800580:	e8 0b 25 00 00       	call   802a90 <__umoddi3>
  800585:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800589:	0f be 80 27 2d 80 00 	movsbl 0x802d27(%eax),%eax
  800590:	89 04 24             	mov    %eax,(%esp)
  800593:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800596:	83 c4 3c             	add    $0x3c,%esp
  800599:	5b                   	pop    %ebx
  80059a:	5e                   	pop    %esi
  80059b:	5f                   	pop    %edi
  80059c:	5d                   	pop    %ebp
  80059d:	c3                   	ret    

0080059e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80059e:	55                   	push   %ebp
  80059f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005a1:	83 fa 01             	cmp    $0x1,%edx
  8005a4:	7e 0e                	jle    8005b4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005a6:	8b 10                	mov    (%eax),%edx
  8005a8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005ab:	89 08                	mov    %ecx,(%eax)
  8005ad:	8b 02                	mov    (%edx),%eax
  8005af:	8b 52 04             	mov    0x4(%edx),%edx
  8005b2:	eb 22                	jmp    8005d6 <getuint+0x38>
	else if (lflag)
  8005b4:	85 d2                	test   %edx,%edx
  8005b6:	74 10                	je     8005c8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005b8:	8b 10                	mov    (%eax),%edx
  8005ba:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005bd:	89 08                	mov    %ecx,(%eax)
  8005bf:	8b 02                	mov    (%edx),%eax
  8005c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005c6:	eb 0e                	jmp    8005d6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005c8:	8b 10                	mov    (%eax),%edx
  8005ca:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005cd:	89 08                	mov    %ecx,(%eax)
  8005cf:	8b 02                	mov    (%edx),%eax
  8005d1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005d6:	5d                   	pop    %ebp
  8005d7:	c3                   	ret    

008005d8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d8:	55                   	push   %ebp
  8005d9:	89 e5                	mov    %esp,%ebp
  8005db:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005de:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8005e1:	8b 10                	mov    (%eax),%edx
  8005e3:	3b 50 04             	cmp    0x4(%eax),%edx
  8005e6:	73 08                	jae    8005f0 <sprintputch+0x18>
		*b->buf++ = ch;
  8005e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005eb:	88 0a                	mov    %cl,(%edx)
  8005ed:	42                   	inc    %edx
  8005ee:	89 10                	mov    %edx,(%eax)
}
  8005f0:	5d                   	pop    %ebp
  8005f1:	c3                   	ret    

008005f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005f2:	55                   	push   %ebp
  8005f3:	89 e5                	mov    %esp,%ebp
  8005f5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800602:	89 44 24 08          	mov    %eax,0x8(%esp)
  800606:	8b 45 0c             	mov    0xc(%ebp),%eax
  800609:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060d:	8b 45 08             	mov    0x8(%ebp),%eax
  800610:	89 04 24             	mov    %eax,(%esp)
  800613:	e8 02 00 00 00       	call   80061a <vprintfmt>
	va_end(ap);
}
  800618:	c9                   	leave  
  800619:	c3                   	ret    

0080061a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80061a:	55                   	push   %ebp
  80061b:	89 e5                	mov    %esp,%ebp
  80061d:	57                   	push   %edi
  80061e:	56                   	push   %esi
  80061f:	53                   	push   %ebx
  800620:	83 ec 4c             	sub    $0x4c,%esp
  800623:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800626:	8b 75 10             	mov    0x10(%ebp),%esi
  800629:	eb 12                	jmp    80063d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80062b:	85 c0                	test   %eax,%eax
  80062d:	0f 84 6b 03 00 00    	je     80099e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800633:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800637:	89 04 24             	mov    %eax,(%esp)
  80063a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80063d:	0f b6 06             	movzbl (%esi),%eax
  800640:	46                   	inc    %esi
  800641:	83 f8 25             	cmp    $0x25,%eax
  800644:	75 e5                	jne    80062b <vprintfmt+0x11>
  800646:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80064a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800651:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800656:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80065d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800662:	eb 26                	jmp    80068a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800667:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80066b:	eb 1d                	jmp    80068a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80066d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800670:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800674:	eb 14                	jmp    80068a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800676:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800679:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800680:	eb 08                	jmp    80068a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800682:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800685:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068a:	0f b6 06             	movzbl (%esi),%eax
  80068d:	8d 56 01             	lea    0x1(%esi),%edx
  800690:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800693:	8a 16                	mov    (%esi),%dl
  800695:	83 ea 23             	sub    $0x23,%edx
  800698:	80 fa 55             	cmp    $0x55,%dl
  80069b:	0f 87 e1 02 00 00    	ja     800982 <vprintfmt+0x368>
  8006a1:	0f b6 d2             	movzbl %dl,%edx
  8006a4:	ff 24 95 60 2e 80 00 	jmp    *0x802e60(,%edx,4)
  8006ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ae:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006b3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8006b6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8006ba:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8006bd:	8d 50 d0             	lea    -0x30(%eax),%edx
  8006c0:	83 fa 09             	cmp    $0x9,%edx
  8006c3:	77 2a                	ja     8006ef <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006c5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006c6:	eb eb                	jmp    8006b3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8d 50 04             	lea    0x4(%eax),%edx
  8006ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006d6:	eb 17                	jmp    8006ef <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8006d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006dc:	78 98                	js     800676 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006de:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006e1:	eb a7                	jmp    80068a <vprintfmt+0x70>
  8006e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006e6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8006ed:	eb 9b                	jmp    80068a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8006ef:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8006f3:	79 95                	jns    80068a <vprintfmt+0x70>
  8006f5:	eb 8b                	jmp    800682 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006f7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006fb:	eb 8d                	jmp    80068a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8d 50 04             	lea    0x4(%eax),%edx
  800703:	89 55 14             	mov    %edx,0x14(%ebp)
  800706:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	89 04 24             	mov    %eax,(%esp)
  80070f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800712:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800715:	e9 23 ff ff ff       	jmp    80063d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 50 04             	lea    0x4(%eax),%edx
  800720:	89 55 14             	mov    %edx,0x14(%ebp)
  800723:	8b 00                	mov    (%eax),%eax
  800725:	85 c0                	test   %eax,%eax
  800727:	79 02                	jns    80072b <vprintfmt+0x111>
  800729:	f7 d8                	neg    %eax
  80072b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80072d:	83 f8 10             	cmp    $0x10,%eax
  800730:	7f 0b                	jg     80073d <vprintfmt+0x123>
  800732:	8b 04 85 c0 2f 80 00 	mov    0x802fc0(,%eax,4),%eax
  800739:	85 c0                	test   %eax,%eax
  80073b:	75 23                	jne    800760 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80073d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800741:	c7 44 24 08 3f 2d 80 	movl   $0x802d3f,0x8(%esp)
  800748:	00 
  800749:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80074d:	8b 45 08             	mov    0x8(%ebp),%eax
  800750:	89 04 24             	mov    %eax,(%esp)
  800753:	e8 9a fe ff ff       	call   8005f2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800758:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80075b:	e9 dd fe ff ff       	jmp    80063d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800760:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800764:	c7 44 24 08 b9 31 80 	movl   $0x8031b9,0x8(%esp)
  80076b:	00 
  80076c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800770:	8b 55 08             	mov    0x8(%ebp),%edx
  800773:	89 14 24             	mov    %edx,(%esp)
  800776:	e8 77 fe ff ff       	call   8005f2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80077b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80077e:	e9 ba fe ff ff       	jmp    80063d <vprintfmt+0x23>
  800783:	89 f9                	mov    %edi,%ecx
  800785:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800788:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80078b:	8b 45 14             	mov    0x14(%ebp),%eax
  80078e:	8d 50 04             	lea    0x4(%eax),%edx
  800791:	89 55 14             	mov    %edx,0x14(%ebp)
  800794:	8b 30                	mov    (%eax),%esi
  800796:	85 f6                	test   %esi,%esi
  800798:	75 05                	jne    80079f <vprintfmt+0x185>
				p = "(null)";
  80079a:	be 38 2d 80 00       	mov    $0x802d38,%esi
			if (width > 0 && padc != '-')
  80079f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a3:	0f 8e 84 00 00 00    	jle    80082d <vprintfmt+0x213>
  8007a9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8007ad:	74 7e                	je     80082d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007af:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007b3:	89 34 24             	mov    %esi,(%esp)
  8007b6:	e8 8b 02 00 00       	call   800a46 <strnlen>
  8007bb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8007be:	29 c2                	sub    %eax,%edx
  8007c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8007c3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8007c7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8007ca:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8007cd:	89 de                	mov    %ebx,%esi
  8007cf:	89 d3                	mov    %edx,%ebx
  8007d1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d3:	eb 0b                	jmp    8007e0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8007d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d9:	89 3c 24             	mov    %edi,(%esp)
  8007dc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007df:	4b                   	dec    %ebx
  8007e0:	85 db                	test   %ebx,%ebx
  8007e2:	7f f1                	jg     8007d5 <vprintfmt+0x1bb>
  8007e4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8007e7:	89 f3                	mov    %esi,%ebx
  8007e9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8007ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007ef:	85 c0                	test   %eax,%eax
  8007f1:	79 05                	jns    8007f8 <vprintfmt+0x1de>
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007fb:	29 c2                	sub    %eax,%edx
  8007fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800800:	eb 2b                	jmp    80082d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800802:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800806:	74 18                	je     800820 <vprintfmt+0x206>
  800808:	8d 50 e0             	lea    -0x20(%eax),%edx
  80080b:	83 fa 5e             	cmp    $0x5e,%edx
  80080e:	76 10                	jbe    800820 <vprintfmt+0x206>
					putch('?', putdat);
  800810:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800814:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80081b:	ff 55 08             	call   *0x8(%ebp)
  80081e:	eb 0a                	jmp    80082a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800820:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800824:	89 04 24             	mov    %eax,(%esp)
  800827:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80082a:	ff 4d e4             	decl   -0x1c(%ebp)
  80082d:	0f be 06             	movsbl (%esi),%eax
  800830:	46                   	inc    %esi
  800831:	85 c0                	test   %eax,%eax
  800833:	74 21                	je     800856 <vprintfmt+0x23c>
  800835:	85 ff                	test   %edi,%edi
  800837:	78 c9                	js     800802 <vprintfmt+0x1e8>
  800839:	4f                   	dec    %edi
  80083a:	79 c6                	jns    800802 <vprintfmt+0x1e8>
  80083c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80083f:	89 de                	mov    %ebx,%esi
  800841:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800844:	eb 18                	jmp    80085e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800846:	89 74 24 04          	mov    %esi,0x4(%esp)
  80084a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800851:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800853:	4b                   	dec    %ebx
  800854:	eb 08                	jmp    80085e <vprintfmt+0x244>
  800856:	8b 7d 08             	mov    0x8(%ebp),%edi
  800859:	89 de                	mov    %ebx,%esi
  80085b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80085e:	85 db                	test   %ebx,%ebx
  800860:	7f e4                	jg     800846 <vprintfmt+0x22c>
  800862:	89 7d 08             	mov    %edi,0x8(%ebp)
  800865:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800867:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80086a:	e9 ce fd ff ff       	jmp    80063d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80086f:	83 f9 01             	cmp    $0x1,%ecx
  800872:	7e 10                	jle    800884 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800874:	8b 45 14             	mov    0x14(%ebp),%eax
  800877:	8d 50 08             	lea    0x8(%eax),%edx
  80087a:	89 55 14             	mov    %edx,0x14(%ebp)
  80087d:	8b 30                	mov    (%eax),%esi
  80087f:	8b 78 04             	mov    0x4(%eax),%edi
  800882:	eb 26                	jmp    8008aa <vprintfmt+0x290>
	else if (lflag)
  800884:	85 c9                	test   %ecx,%ecx
  800886:	74 12                	je     80089a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800888:	8b 45 14             	mov    0x14(%ebp),%eax
  80088b:	8d 50 04             	lea    0x4(%eax),%edx
  80088e:	89 55 14             	mov    %edx,0x14(%ebp)
  800891:	8b 30                	mov    (%eax),%esi
  800893:	89 f7                	mov    %esi,%edi
  800895:	c1 ff 1f             	sar    $0x1f,%edi
  800898:	eb 10                	jmp    8008aa <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80089a:	8b 45 14             	mov    0x14(%ebp),%eax
  80089d:	8d 50 04             	lea    0x4(%eax),%edx
  8008a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a3:	8b 30                	mov    (%eax),%esi
  8008a5:	89 f7                	mov    %esi,%edi
  8008a7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008aa:	85 ff                	test   %edi,%edi
  8008ac:	78 0a                	js     8008b8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008b3:	e9 8c 00 00 00       	jmp    800944 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8008b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008bc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008c3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8008c6:	f7 de                	neg    %esi
  8008c8:	83 d7 00             	adc    $0x0,%edi
  8008cb:	f7 df                	neg    %edi
			}
			base = 10;
  8008cd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008d2:	eb 70                	jmp    800944 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008d4:	89 ca                	mov    %ecx,%edx
  8008d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d9:	e8 c0 fc ff ff       	call   80059e <getuint>
  8008de:	89 c6                	mov    %eax,%esi
  8008e0:	89 d7                	mov    %edx,%edi
			base = 10;
  8008e2:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8008e7:	eb 5b                	jmp    800944 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  8008e9:	89 ca                	mov    %ecx,%edx
  8008eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ee:	e8 ab fc ff ff       	call   80059e <getuint>
  8008f3:	89 c6                	mov    %eax,%esi
  8008f5:	89 d7                	mov    %edx,%edi
			base = 8;
  8008f7:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8008fc:	eb 46                	jmp    800944 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8008fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800902:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800909:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80090c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800910:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800917:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80091a:	8b 45 14             	mov    0x14(%ebp),%eax
  80091d:	8d 50 04             	lea    0x4(%eax),%edx
  800920:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800923:	8b 30                	mov    (%eax),%esi
  800925:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80092a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80092f:	eb 13                	jmp    800944 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800931:	89 ca                	mov    %ecx,%edx
  800933:	8d 45 14             	lea    0x14(%ebp),%eax
  800936:	e8 63 fc ff ff       	call   80059e <getuint>
  80093b:	89 c6                	mov    %eax,%esi
  80093d:	89 d7                	mov    %edx,%edi
			base = 16;
  80093f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800944:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800948:	89 54 24 10          	mov    %edx,0x10(%esp)
  80094c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80094f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800953:	89 44 24 08          	mov    %eax,0x8(%esp)
  800957:	89 34 24             	mov    %esi,(%esp)
  80095a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80095e:	89 da                	mov    %ebx,%edx
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	e8 6c fb ff ff       	call   8004d4 <printnum>
			break;
  800968:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80096b:	e9 cd fc ff ff       	jmp    80063d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800970:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800974:	89 04 24             	mov    %eax,(%esp)
  800977:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80097d:	e9 bb fc ff ff       	jmp    80063d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800982:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800986:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80098d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800990:	eb 01                	jmp    800993 <vprintfmt+0x379>
  800992:	4e                   	dec    %esi
  800993:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800997:	75 f9                	jne    800992 <vprintfmt+0x378>
  800999:	e9 9f fc ff ff       	jmp    80063d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80099e:	83 c4 4c             	add    $0x4c,%esp
  8009a1:	5b                   	pop    %ebx
  8009a2:	5e                   	pop    %esi
  8009a3:	5f                   	pop    %edi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	83 ec 28             	sub    $0x28,%esp
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009b5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009b9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009c3:	85 c0                	test   %eax,%eax
  8009c5:	74 30                	je     8009f7 <vsnprintf+0x51>
  8009c7:	85 d2                	test   %edx,%edx
  8009c9:	7e 33                	jle    8009fe <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8009ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e0:	c7 04 24 d8 05 80 00 	movl   $0x8005d8,(%esp)
  8009e7:	e8 2e fc ff ff       	call   80061a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f5:	eb 0c                	jmp    800a03 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009fc:	eb 05                	jmp    800a03 <vsnprintf+0x5d>
  8009fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a03:	c9                   	leave  
  800a04:	c3                   	ret    

00800a05 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a0b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a12:	8b 45 10             	mov    0x10(%ebp),%eax
  800a15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	89 04 24             	mov    %eax,(%esp)
  800a26:	e8 7b ff ff ff       	call   8009a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    
  800a2d:	00 00                	add    %al,(%eax)
	...

00800a30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a36:	b8 00 00 00 00       	mov    $0x0,%eax
  800a3b:	eb 01                	jmp    800a3e <strlen+0xe>
		n++;
  800a3d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a3e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a42:	75 f9                	jne    800a3d <strlen+0xd>
		n++;
	return n;
}
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a54:	eb 01                	jmp    800a57 <strnlen+0x11>
		n++;
  800a56:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a57:	39 d0                	cmp    %edx,%eax
  800a59:	74 06                	je     800a61 <strnlen+0x1b>
  800a5b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a5f:	75 f5                	jne    800a56 <strnlen+0x10>
		n++;
	return n;
}
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	53                   	push   %ebx
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a72:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800a75:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a78:	42                   	inc    %edx
  800a79:	84 c9                	test   %cl,%cl
  800a7b:	75 f5                	jne    800a72 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	53                   	push   %ebx
  800a84:	83 ec 08             	sub    $0x8,%esp
  800a87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a8a:	89 1c 24             	mov    %ebx,(%esp)
  800a8d:	e8 9e ff ff ff       	call   800a30 <strlen>
	strcpy(dst + len, src);
  800a92:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a95:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a99:	01 d8                	add    %ebx,%eax
  800a9b:	89 04 24             	mov    %eax,(%esp)
  800a9e:	e8 c0 ff ff ff       	call   800a63 <strcpy>
	return dst;
}
  800aa3:	89 d8                	mov    %ebx,%eax
  800aa5:	83 c4 08             	add    $0x8,%esp
  800aa8:	5b                   	pop    %ebx
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
  800ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800abe:	eb 0c                	jmp    800acc <strncpy+0x21>
		*dst++ = *src;
  800ac0:	8a 1a                	mov    (%edx),%bl
  800ac2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ac5:	80 3a 01             	cmpb   $0x1,(%edx)
  800ac8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800acb:	41                   	inc    %ecx
  800acc:	39 f1                	cmp    %esi,%ecx
  800ace:	75 f0                	jne    800ac0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 75 08             	mov    0x8(%ebp),%esi
  800adc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800adf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae2:	85 d2                	test   %edx,%edx
  800ae4:	75 0a                	jne    800af0 <strlcpy+0x1c>
  800ae6:	89 f0                	mov    %esi,%eax
  800ae8:	eb 1a                	jmp    800b04 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800aea:	88 18                	mov    %bl,(%eax)
  800aec:	40                   	inc    %eax
  800aed:	41                   	inc    %ecx
  800aee:	eb 02                	jmp    800af2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800af0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800af2:	4a                   	dec    %edx
  800af3:	74 0a                	je     800aff <strlcpy+0x2b>
  800af5:	8a 19                	mov    (%ecx),%bl
  800af7:	84 db                	test   %bl,%bl
  800af9:	75 ef                	jne    800aea <strlcpy+0x16>
  800afb:	89 c2                	mov    %eax,%edx
  800afd:	eb 02                	jmp    800b01 <strlcpy+0x2d>
  800aff:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800b01:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800b04:	29 f0                	sub    %esi,%eax
}
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b10:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b13:	eb 02                	jmp    800b17 <strcmp+0xd>
		p++, q++;
  800b15:	41                   	inc    %ecx
  800b16:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b17:	8a 01                	mov    (%ecx),%al
  800b19:	84 c0                	test   %al,%al
  800b1b:	74 04                	je     800b21 <strcmp+0x17>
  800b1d:	3a 02                	cmp    (%edx),%al
  800b1f:	74 f4                	je     800b15 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b21:	0f b6 c0             	movzbl %al,%eax
  800b24:	0f b6 12             	movzbl (%edx),%edx
  800b27:	29 d0                	sub    %edx,%eax
}
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	53                   	push   %ebx
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b35:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800b38:	eb 03                	jmp    800b3d <strncmp+0x12>
		n--, p++, q++;
  800b3a:	4a                   	dec    %edx
  800b3b:	40                   	inc    %eax
  800b3c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b3d:	85 d2                	test   %edx,%edx
  800b3f:	74 14                	je     800b55 <strncmp+0x2a>
  800b41:	8a 18                	mov    (%eax),%bl
  800b43:	84 db                	test   %bl,%bl
  800b45:	74 04                	je     800b4b <strncmp+0x20>
  800b47:	3a 19                	cmp    (%ecx),%bl
  800b49:	74 ef                	je     800b3a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b4b:	0f b6 00             	movzbl (%eax),%eax
  800b4e:	0f b6 11             	movzbl (%ecx),%edx
  800b51:	29 d0                	sub    %edx,%eax
  800b53:	eb 05                	jmp    800b5a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b55:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	8b 45 08             	mov    0x8(%ebp),%eax
  800b63:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b66:	eb 05                	jmp    800b6d <strchr+0x10>
		if (*s == c)
  800b68:	38 ca                	cmp    %cl,%dl
  800b6a:	74 0c                	je     800b78 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b6c:	40                   	inc    %eax
  800b6d:	8a 10                	mov    (%eax),%dl
  800b6f:	84 d2                	test   %dl,%dl
  800b71:	75 f5                	jne    800b68 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800b73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b80:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800b83:	eb 05                	jmp    800b8a <strfind+0x10>
		if (*s == c)
  800b85:	38 ca                	cmp    %cl,%dl
  800b87:	74 07                	je     800b90 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b89:	40                   	inc    %eax
  800b8a:	8a 10                	mov    (%eax),%dl
  800b8c:	84 d2                	test   %dl,%dl
  800b8e:	75 f5                	jne    800b85 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
  800b98:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ba1:	85 c9                	test   %ecx,%ecx
  800ba3:	74 30                	je     800bd5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ba5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bab:	75 25                	jne    800bd2 <memset+0x40>
  800bad:	f6 c1 03             	test   $0x3,%cl
  800bb0:	75 20                	jne    800bd2 <memset+0x40>
		c &= 0xFF;
  800bb2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bb5:	89 d3                	mov    %edx,%ebx
  800bb7:	c1 e3 08             	shl    $0x8,%ebx
  800bba:	89 d6                	mov    %edx,%esi
  800bbc:	c1 e6 18             	shl    $0x18,%esi
  800bbf:	89 d0                	mov    %edx,%eax
  800bc1:	c1 e0 10             	shl    $0x10,%eax
  800bc4:	09 f0                	or     %esi,%eax
  800bc6:	09 d0                	or     %edx,%eax
  800bc8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bca:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bcd:	fc                   	cld    
  800bce:	f3 ab                	rep stos %eax,%es:(%edi)
  800bd0:	eb 03                	jmp    800bd5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bd2:	fc                   	cld    
  800bd3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bd5:	89 f8                	mov    %edi,%eax
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	8b 45 08             	mov    0x8(%ebp),%eax
  800be4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bea:	39 c6                	cmp    %eax,%esi
  800bec:	73 34                	jae    800c22 <memmove+0x46>
  800bee:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bf1:	39 d0                	cmp    %edx,%eax
  800bf3:	73 2d                	jae    800c22 <memmove+0x46>
		s += n;
		d += n;
  800bf5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf8:	f6 c2 03             	test   $0x3,%dl
  800bfb:	75 1b                	jne    800c18 <memmove+0x3c>
  800bfd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c03:	75 13                	jne    800c18 <memmove+0x3c>
  800c05:	f6 c1 03             	test   $0x3,%cl
  800c08:	75 0e                	jne    800c18 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c0a:	83 ef 04             	sub    $0x4,%edi
  800c0d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c10:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c13:	fd                   	std    
  800c14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c16:	eb 07                	jmp    800c1f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c18:	4f                   	dec    %edi
  800c19:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c1c:	fd                   	std    
  800c1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c1f:	fc                   	cld    
  800c20:	eb 20                	jmp    800c42 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c22:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c28:	75 13                	jne    800c3d <memmove+0x61>
  800c2a:	a8 03                	test   $0x3,%al
  800c2c:	75 0f                	jne    800c3d <memmove+0x61>
  800c2e:	f6 c1 03             	test   $0x3,%cl
  800c31:	75 0a                	jne    800c3d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c33:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c36:	89 c7                	mov    %eax,%edi
  800c38:	fc                   	cld    
  800c39:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c3b:	eb 05                	jmp    800c42 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c3d:	89 c7                	mov    %eax,%edi
  800c3f:	fc                   	cld    
  800c40:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800c4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5d:	89 04 24             	mov    %eax,(%esp)
  800c60:	e8 77 ff ff ff       	call   800bdc <memmove>
}
  800c65:	c9                   	leave  
  800c66:	c3                   	ret    

00800c67 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c70:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c76:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7b:	eb 16                	jmp    800c93 <memcmp+0x2c>
		if (*s1 != *s2)
  800c7d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800c80:	42                   	inc    %edx
  800c81:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800c85:	38 c8                	cmp    %cl,%al
  800c87:	74 0a                	je     800c93 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800c89:	0f b6 c0             	movzbl %al,%eax
  800c8c:	0f b6 c9             	movzbl %cl,%ecx
  800c8f:	29 c8                	sub    %ecx,%eax
  800c91:	eb 09                	jmp    800c9c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c93:	39 da                	cmp    %ebx,%edx
  800c95:	75 e6                	jne    800c7d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800caa:	89 c2                	mov    %eax,%edx
  800cac:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800caf:	eb 05                	jmp    800cb6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb1:	38 08                	cmp    %cl,(%eax)
  800cb3:	74 05                	je     800cba <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cb5:	40                   	inc    %eax
  800cb6:	39 d0                	cmp    %edx,%eax
  800cb8:	72 f7                	jb     800cb1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cc8:	eb 01                	jmp    800ccb <strtol+0xf>
		s++;
  800cca:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ccb:	8a 02                	mov    (%edx),%al
  800ccd:	3c 20                	cmp    $0x20,%al
  800ccf:	74 f9                	je     800cca <strtol+0xe>
  800cd1:	3c 09                	cmp    $0x9,%al
  800cd3:	74 f5                	je     800cca <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cd5:	3c 2b                	cmp    $0x2b,%al
  800cd7:	75 08                	jne    800ce1 <strtol+0x25>
		s++;
  800cd9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cda:	bf 00 00 00 00       	mov    $0x0,%edi
  800cdf:	eb 13                	jmp    800cf4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ce1:	3c 2d                	cmp    $0x2d,%al
  800ce3:	75 0a                	jne    800cef <strtol+0x33>
		s++, neg = 1;
  800ce5:	8d 52 01             	lea    0x1(%edx),%edx
  800ce8:	bf 01 00 00 00       	mov    $0x1,%edi
  800ced:	eb 05                	jmp    800cf4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800cef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf4:	85 db                	test   %ebx,%ebx
  800cf6:	74 05                	je     800cfd <strtol+0x41>
  800cf8:	83 fb 10             	cmp    $0x10,%ebx
  800cfb:	75 28                	jne    800d25 <strtol+0x69>
  800cfd:	8a 02                	mov    (%edx),%al
  800cff:	3c 30                	cmp    $0x30,%al
  800d01:	75 10                	jne    800d13 <strtol+0x57>
  800d03:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d07:	75 0a                	jne    800d13 <strtol+0x57>
		s += 2, base = 16;
  800d09:	83 c2 02             	add    $0x2,%edx
  800d0c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d11:	eb 12                	jmp    800d25 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800d13:	85 db                	test   %ebx,%ebx
  800d15:	75 0e                	jne    800d25 <strtol+0x69>
  800d17:	3c 30                	cmp    $0x30,%al
  800d19:	75 05                	jne    800d20 <strtol+0x64>
		s++, base = 8;
  800d1b:	42                   	inc    %edx
  800d1c:	b3 08                	mov    $0x8,%bl
  800d1e:	eb 05                	jmp    800d25 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800d20:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d25:	b8 00 00 00 00       	mov    $0x0,%eax
  800d2a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d2c:	8a 0a                	mov    (%edx),%cl
  800d2e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d31:	80 fb 09             	cmp    $0x9,%bl
  800d34:	77 08                	ja     800d3e <strtol+0x82>
			dig = *s - '0';
  800d36:	0f be c9             	movsbl %cl,%ecx
  800d39:	83 e9 30             	sub    $0x30,%ecx
  800d3c:	eb 1e                	jmp    800d5c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800d3e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800d41:	80 fb 19             	cmp    $0x19,%bl
  800d44:	77 08                	ja     800d4e <strtol+0x92>
			dig = *s - 'a' + 10;
  800d46:	0f be c9             	movsbl %cl,%ecx
  800d49:	83 e9 57             	sub    $0x57,%ecx
  800d4c:	eb 0e                	jmp    800d5c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800d4e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800d51:	80 fb 19             	cmp    $0x19,%bl
  800d54:	77 12                	ja     800d68 <strtol+0xac>
			dig = *s - 'A' + 10;
  800d56:	0f be c9             	movsbl %cl,%ecx
  800d59:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d5c:	39 f1                	cmp    %esi,%ecx
  800d5e:	7d 0c                	jge    800d6c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800d60:	42                   	inc    %edx
  800d61:	0f af c6             	imul   %esi,%eax
  800d64:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800d66:	eb c4                	jmp    800d2c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800d68:	89 c1                	mov    %eax,%ecx
  800d6a:	eb 02                	jmp    800d6e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d6c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800d6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d72:	74 05                	je     800d79 <strtol+0xbd>
		*endptr = (char *) s;
  800d74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d77:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d79:	85 ff                	test   %edi,%edi
  800d7b:	74 04                	je     800d81 <strtol+0xc5>
  800d7d:	89 c8                	mov    %ecx,%eax
  800d7f:	f7 d8                	neg    %eax
}
  800d81:	5b                   	pop    %ebx
  800d82:	5e                   	pop    %esi
  800d83:	5f                   	pop    %edi
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    
	...

00800d88 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d96:	8b 55 08             	mov    0x8(%ebp),%edx
  800d99:	89 c3                	mov    %eax,%ebx
  800d9b:	89 c7                	mov    %eax,%edi
  800d9d:	89 c6                	mov    %eax,%esi
  800d9f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800da1:	5b                   	pop    %ebx
  800da2:	5e                   	pop    %esi
  800da3:	5f                   	pop    %edi
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	57                   	push   %edi
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dac:	ba 00 00 00 00       	mov    $0x0,%edx
  800db1:	b8 01 00 00 00       	mov    $0x1,%eax
  800db6:	89 d1                	mov    %edx,%ecx
  800db8:	89 d3                	mov    %edx,%ebx
  800dba:	89 d7                	mov    %edx,%edi
  800dbc:	89 d6                	mov    %edx,%esi
  800dbe:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
  800dcb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd3:	b8 03 00 00 00       	mov    $0x3,%eax
  800dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddb:	89 cb                	mov    %ecx,%ebx
  800ddd:	89 cf                	mov    %ecx,%edi
  800ddf:	89 ce                	mov    %ecx,%esi
  800de1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	7e 28                	jle    800e0f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de7:	89 44 24 10          	mov    %eax,0x10(%esp)
  800deb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800df2:	00 
  800df3:	c7 44 24 08 23 30 80 	movl   $0x803023,0x8(%esp)
  800dfa:	00 
  800dfb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e02:	00 
  800e03:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  800e0a:	e8 b1 f5 ff ff       	call   8003c0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e0f:	83 c4 2c             	add    $0x2c,%esp
  800e12:	5b                   	pop    %ebx
  800e13:	5e                   	pop    %esi
  800e14:	5f                   	pop    %edi
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	57                   	push   %edi
  800e1b:	56                   	push   %esi
  800e1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e22:	b8 02 00 00 00       	mov    $0x2,%eax
  800e27:	89 d1                	mov    %edx,%ecx
  800e29:	89 d3                	mov    %edx,%ebx
  800e2b:	89 d7                	mov    %edx,%edi
  800e2d:	89 d6                	mov    %edx,%esi
  800e2f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e31:	5b                   	pop    %ebx
  800e32:	5e                   	pop    %esi
  800e33:	5f                   	pop    %edi
  800e34:	5d                   	pop    %ebp
  800e35:	c3                   	ret    

00800e36 <sys_yield>:

void
sys_yield(void)
{
  800e36:	55                   	push   %ebp
  800e37:	89 e5                	mov    %esp,%ebp
  800e39:	57                   	push   %edi
  800e3a:	56                   	push   %esi
  800e3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e41:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e46:	89 d1                	mov    %edx,%ecx
  800e48:	89 d3                	mov    %edx,%ebx
  800e4a:	89 d7                	mov    %edx,%edi
  800e4c:	89 d6                	mov    %edx,%esi
  800e4e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
  800e5b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5e:	be 00 00 00 00       	mov    $0x0,%esi
  800e63:	b8 04 00 00 00       	mov    $0x4,%eax
  800e68:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e71:	89 f7                	mov    %esi,%edi
  800e73:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e75:	85 c0                	test   %eax,%eax
  800e77:	7e 28                	jle    800ea1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800e84:	00 
  800e85:	c7 44 24 08 23 30 80 	movl   $0x803023,0x8(%esp)
  800e8c:	00 
  800e8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e94:	00 
  800e95:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  800e9c:	e8 1f f5 ff ff       	call   8003c0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ea1:	83 c4 2c             	add    $0x2c,%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb2:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb7:	8b 75 18             	mov    0x18(%ebp),%esi
  800eba:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ebd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec8:	85 c0                	test   %eax,%eax
  800eca:	7e 28                	jle    800ef4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecc:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ed7:	00 
  800ed8:	c7 44 24 08 23 30 80 	movl   $0x803023,0x8(%esp)
  800edf:	00 
  800ee0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee7:	00 
  800ee8:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  800eef:	e8 cc f4 ff ff       	call   8003c0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ef4:	83 c4 2c             	add    $0x2c,%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5f                   	pop    %edi
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	57                   	push   %edi
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
  800f02:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f0a:	b8 06 00 00 00       	mov    $0x6,%eax
  800f0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f12:	8b 55 08             	mov    0x8(%ebp),%edx
  800f15:	89 df                	mov    %ebx,%edi
  800f17:	89 de                	mov    %ebx,%esi
  800f19:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	7e 28                	jle    800f47 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f23:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f2a:	00 
  800f2b:	c7 44 24 08 23 30 80 	movl   $0x803023,0x8(%esp)
  800f32:	00 
  800f33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f3a:	00 
  800f3b:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  800f42:	e8 79 f4 ff ff       	call   8003c0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f47:	83 c4 2c             	add    $0x2c,%esp
  800f4a:	5b                   	pop    %ebx
  800f4b:	5e                   	pop    %esi
  800f4c:	5f                   	pop    %edi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    

00800f4f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	57                   	push   %edi
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
  800f55:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f58:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5d:	b8 08 00 00 00       	mov    $0x8,%eax
  800f62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f65:	8b 55 08             	mov    0x8(%ebp),%edx
  800f68:	89 df                	mov    %ebx,%edi
  800f6a:	89 de                	mov    %ebx,%esi
  800f6c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	7e 28                	jle    800f9a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f76:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800f7d:	00 
  800f7e:	c7 44 24 08 23 30 80 	movl   $0x803023,0x8(%esp)
  800f85:	00 
  800f86:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f8d:	00 
  800f8e:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  800f95:	e8 26 f4 ff ff       	call   8003c0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f9a:	83 c4 2c             	add    $0x2c,%esp
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	57                   	push   %edi
  800fa6:	56                   	push   %esi
  800fa7:	53                   	push   %ebx
  800fa8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb0:	b8 09 00 00 00       	mov    $0x9,%eax
  800fb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fbb:	89 df                	mov    %ebx,%edi
  800fbd:	89 de                	mov    %ebx,%esi
  800fbf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	7e 28                	jle    800fed <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fc9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800fd0:	00 
  800fd1:	c7 44 24 08 23 30 80 	movl   $0x803023,0x8(%esp)
  800fd8:	00 
  800fd9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe0:	00 
  800fe1:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  800fe8:	e8 d3 f3 ff ff       	call   8003c0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800fed:	83 c4 2c             	add    $0x2c,%esp
  800ff0:	5b                   	pop    %ebx
  800ff1:	5e                   	pop    %esi
  800ff2:	5f                   	pop    %edi
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	57                   	push   %edi
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
  800ffb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801003:	b8 0a 00 00 00       	mov    $0xa,%eax
  801008:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80100b:	8b 55 08             	mov    0x8(%ebp),%edx
  80100e:	89 df                	mov    %ebx,%edi
  801010:	89 de                	mov    %ebx,%esi
  801012:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801014:	85 c0                	test   %eax,%eax
  801016:	7e 28                	jle    801040 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801018:	89 44 24 10          	mov    %eax,0x10(%esp)
  80101c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801023:	00 
  801024:	c7 44 24 08 23 30 80 	movl   $0x803023,0x8(%esp)
  80102b:	00 
  80102c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801033:	00 
  801034:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  80103b:	e8 80 f3 ff ff       	call   8003c0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801040:	83 c4 2c             	add    $0x2c,%esp
  801043:	5b                   	pop    %ebx
  801044:	5e                   	pop    %esi
  801045:	5f                   	pop    %edi
  801046:	5d                   	pop    %ebp
  801047:	c3                   	ret    

00801048 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801048:	55                   	push   %ebp
  801049:	89 e5                	mov    %esp,%ebp
  80104b:	57                   	push   %edi
  80104c:	56                   	push   %esi
  80104d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80104e:	be 00 00 00 00       	mov    $0x0,%esi
  801053:	b8 0c 00 00 00       	mov    $0xc,%eax
  801058:	8b 7d 14             	mov    0x14(%ebp),%edi
  80105b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80105e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801061:	8b 55 08             	mov    0x8(%ebp),%edx
  801064:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801066:	5b                   	pop    %ebx
  801067:	5e                   	pop    %esi
  801068:	5f                   	pop    %edi
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    

0080106b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	57                   	push   %edi
  80106f:	56                   	push   %esi
  801070:	53                   	push   %ebx
  801071:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801074:	b9 00 00 00 00       	mov    $0x0,%ecx
  801079:	b8 0d 00 00 00       	mov    $0xd,%eax
  80107e:	8b 55 08             	mov    0x8(%ebp),%edx
  801081:	89 cb                	mov    %ecx,%ebx
  801083:	89 cf                	mov    %ecx,%edi
  801085:	89 ce                	mov    %ecx,%esi
  801087:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801089:	85 c0                	test   %eax,%eax
  80108b:	7e 28                	jle    8010b5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801091:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801098:	00 
  801099:	c7 44 24 08 23 30 80 	movl   $0x803023,0x8(%esp)
  8010a0:	00 
  8010a1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010a8:	00 
  8010a9:	c7 04 24 40 30 80 00 	movl   $0x803040,(%esp)
  8010b0:	e8 0b f3 ff ff       	call   8003c0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8010b5:	83 c4 2c             	add    $0x2c,%esp
  8010b8:	5b                   	pop    %ebx
  8010b9:	5e                   	pop    %esi
  8010ba:	5f                   	pop    %edi
  8010bb:	5d                   	pop    %ebp
  8010bc:	c3                   	ret    

008010bd <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	57                   	push   %edi
  8010c1:	56                   	push   %esi
  8010c2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c8:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010cd:	89 d1                	mov    %edx,%ecx
  8010cf:	89 d3                	mov    %edx,%ebx
  8010d1:	89 d7                	mov    %edx,%edi
  8010d3:	89 d6                	mov    %edx,%esi
  8010d5:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010e7:	b8 0f 00 00 00       	mov    $0xf,%eax
  8010ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f2:	89 df                	mov    %ebx,%edi
  8010f4:	89 de                	mov    %ebx,%esi
  8010f6:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  8010f8:	5b                   	pop    %ebx
  8010f9:	5e                   	pop    %esi
  8010fa:	5f                   	pop    %edi
  8010fb:	5d                   	pop    %ebp
  8010fc:	c3                   	ret    

008010fd <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
  801100:	57                   	push   %edi
  801101:	56                   	push   %esi
  801102:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801103:	bb 00 00 00 00       	mov    $0x0,%ebx
  801108:	b8 10 00 00 00       	mov    $0x10,%eax
  80110d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801110:	8b 55 08             	mov    0x8(%ebp),%edx
  801113:	89 df                	mov    %ebx,%edi
  801115:	89 de                	mov    %ebx,%esi
  801117:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  801119:	5b                   	pop    %ebx
  80111a:	5e                   	pop    %esi
  80111b:	5f                   	pop    %edi
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    
	...

00801120 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	53                   	push   %ebx
  801124:	83 ec 24             	sub    $0x24,%esp
  801127:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80112a:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  80112c:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801130:	74 2d                	je     80115f <pgfault+0x3f>
  801132:	89 d8                	mov    %ebx,%eax
  801134:	c1 e8 16             	shr    $0x16,%eax
  801137:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80113e:	a8 01                	test   $0x1,%al
  801140:	74 1d                	je     80115f <pgfault+0x3f>
  801142:	89 d8                	mov    %ebx,%eax
  801144:	c1 e8 0c             	shr    $0xc,%eax
  801147:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80114e:	f6 c2 01             	test   $0x1,%dl
  801151:	74 0c                	je     80115f <pgfault+0x3f>
  801153:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80115a:	f6 c4 08             	test   $0x8,%ah
  80115d:	75 1c                	jne    80117b <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  80115f:	c7 44 24 08 50 30 80 	movl   $0x803050,0x8(%esp)
  801166:	00 
  801167:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  80116e:	00 
  80116f:	c7 04 24 93 30 80 00 	movl   $0x803093,(%esp)
  801176:	e8 45 f2 ff ff       	call   8003c0 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  80117b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  801181:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801188:	00 
  801189:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801190:	00 
  801191:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801198:	e8 b8 fc ff ff       	call   800e55 <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  80119d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8011a4:	00 
  8011a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011a9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8011b0:	e8 91 fa ff ff       	call   800c46 <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  8011b5:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8011bc:	00 
  8011bd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011c1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011c8:	00 
  8011c9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011d0:	00 
  8011d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d8:	e8 cc fc ff ff       	call   800ea9 <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  8011dd:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8011e4:	00 
  8011e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ec:	e8 0b fd ff ff       	call   800efc <sys_page_unmap>

	// panic("pgfault not implemented");
}
  8011f1:	83 c4 24             	add    $0x24,%esp
  8011f4:	5b                   	pop    %ebx
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	57                   	push   %edi
  8011fb:	56                   	push   %esi
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801200:	c7 04 24 20 11 80 00 	movl   $0x801120,(%esp)
  801207:	e8 ac 16 00 00       	call   8028b8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80120c:	ba 07 00 00 00       	mov    $0x7,%edx
  801211:	89 d0                	mov    %edx,%eax
  801213:	cd 30                	int    $0x30
  801215:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801218:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80121a:	85 c0                	test   %eax,%eax
  80121c:	79 20                	jns    80123e <fork+0x47>
		panic("sys_exofork: %e", envid);
  80121e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801222:	c7 44 24 08 9e 30 80 	movl   $0x80309e,0x8(%esp)
  801229:	00 
  80122a:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  801231:	00 
  801232:	c7 04 24 93 30 80 00 	movl   $0x803093,(%esp)
  801239:	e8 82 f1 ff ff       	call   8003c0 <_panic>
	if (envid == 0)
  80123e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801242:	75 25                	jne    801269 <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  801244:	e8 ce fb ff ff       	call   800e17 <sys_getenvid>
  801249:	25 ff 03 00 00       	and    $0x3ff,%eax
  80124e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801255:	c1 e0 07             	shl    $0x7,%eax
  801258:	29 d0                	sub    %edx,%eax
  80125a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80125f:	a3 0c 50 80 00       	mov    %eax,0x80500c
		return 0;
  801264:	e9 43 02 00 00       	jmp    8014ac <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  801269:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  80126e:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801274:	0f 84 85 01 00 00    	je     8013ff <fork+0x208>
  80127a:	89 d8                	mov    %ebx,%eax
  80127c:	c1 e8 16             	shr    $0x16,%eax
  80127f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801286:	a8 01                	test   $0x1,%al
  801288:	0f 84 5f 01 00 00    	je     8013ed <fork+0x1f6>
  80128e:	89 d8                	mov    %ebx,%eax
  801290:	c1 e8 0c             	shr    $0xc,%eax
  801293:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80129a:	f6 c2 01             	test   $0x1,%dl
  80129d:	0f 84 4a 01 00 00    	je     8013ed <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  8012a3:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  8012a5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012ac:	f6 c6 04             	test   $0x4,%dh
  8012af:	74 50                	je     801301 <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  8012b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8012bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8012c5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d4:	e8 d0 fb ff ff       	call   800ea9 <sys_page_map>
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	0f 89 0c 01 00 00    	jns    8013ed <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  8012e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e5:	c7 44 24 08 ae 30 80 	movl   $0x8030ae,0x8(%esp)
  8012ec:	00 
  8012ed:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  8012f4:	00 
  8012f5:	c7 04 24 93 30 80 00 	movl   $0x803093,(%esp)
  8012fc:	e8 bf f0 ff ff       	call   8003c0 <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  801301:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801308:	f6 c2 02             	test   $0x2,%dl
  80130b:	75 10                	jne    80131d <fork+0x126>
  80130d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801314:	f6 c4 08             	test   $0x8,%ah
  801317:	0f 84 8c 00 00 00    	je     8013a9 <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  80131d:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801324:	00 
  801325:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801329:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80132d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801331:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801338:	e8 6c fb ff ff       	call   800ea9 <sys_page_map>
  80133d:	85 c0                	test   %eax,%eax
  80133f:	79 20                	jns    801361 <fork+0x16a>
		{
			panic("duppage error: %e",e);
  801341:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801345:	c7 44 24 08 ae 30 80 	movl   $0x8030ae,0x8(%esp)
  80134c:	00 
  80134d:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801354:	00 
  801355:	c7 04 24 93 30 80 00 	movl   $0x803093,(%esp)
  80135c:	e8 5f f0 ff ff       	call   8003c0 <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  801361:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801368:	00 
  801369:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80136d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801374:	00 
  801375:	89 74 24 04          	mov    %esi,0x4(%esp)
  801379:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801380:	e8 24 fb ff ff       	call   800ea9 <sys_page_map>
  801385:	85 c0                	test   %eax,%eax
  801387:	79 64                	jns    8013ed <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  801389:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80138d:	c7 44 24 08 ae 30 80 	movl   $0x8030ae,0x8(%esp)
  801394:	00 
  801395:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  80139c:	00 
  80139d:	c7 04 24 93 30 80 00 	movl   $0x803093,(%esp)
  8013a4:	e8 17 f0 ff ff       	call   8003c0 <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  8013a9:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8013b0:	00 
  8013b1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013b5:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8013b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013c4:	e8 e0 fa ff ff       	call   800ea9 <sys_page_map>
  8013c9:	85 c0                	test   %eax,%eax
  8013cb:	79 20                	jns    8013ed <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  8013cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d1:	c7 44 24 08 ae 30 80 	movl   $0x8030ae,0x8(%esp)
  8013d8:	00 
  8013d9:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8013e0:	00 
  8013e1:	c7 04 24 93 30 80 00 	movl   $0x803093,(%esp)
  8013e8:	e8 d3 ef ff ff       	call   8003c0 <_panic>
  8013ed:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  8013f3:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8013f9:	0f 85 6f fe ff ff    	jne    80126e <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  8013ff:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801406:	00 
  801407:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80140e:	ee 
  80140f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801412:	89 04 24             	mov    %eax,(%esp)
  801415:	e8 3b fa ff ff       	call   800e55 <sys_page_alloc>
  80141a:	85 c0                	test   %eax,%eax
  80141c:	79 20                	jns    80143e <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  80141e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801422:	c7 44 24 08 ea 2b 80 	movl   $0x802bea,0x8(%esp)
  801429:	00 
  80142a:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  801431:	00 
  801432:	c7 04 24 93 30 80 00 	movl   $0x803093,(%esp)
  801439:	e8 82 ef ff ff       	call   8003c0 <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  80143e:	c7 44 24 04 04 29 80 	movl   $0x802904,0x4(%esp)
  801445:	00 
  801446:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801449:	89 04 24             	mov    %eax,(%esp)
  80144c:	e8 a4 fb ff ff       	call   800ff5 <sys_env_set_pgfault_upcall>
  801451:	85 c0                	test   %eax,%eax
  801453:	79 20                	jns    801475 <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  801455:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801459:	c7 44 24 08 74 30 80 	movl   $0x803074,0x8(%esp)
  801460:	00 
  801461:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  801468:	00 
  801469:	c7 04 24 93 30 80 00 	movl   $0x803093,(%esp)
  801470:	e8 4b ef ff ff       	call   8003c0 <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801475:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80147c:	00 
  80147d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801480:	89 04 24             	mov    %eax,(%esp)
  801483:	e8 c7 fa ff ff       	call   800f4f <sys_env_set_status>
  801488:	85 c0                	test   %eax,%eax
  80148a:	79 20                	jns    8014ac <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  80148c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801490:	c7 44 24 08 c0 30 80 	movl   $0x8030c0,0x8(%esp)
  801497:	00 
  801498:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  80149f:	00 
  8014a0:	c7 04 24 93 30 80 00 	movl   $0x803093,(%esp)
  8014a7:	e8 14 ef ff ff       	call   8003c0 <_panic>

	return envid;
	// panic("fork not implemented");
}
  8014ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014af:	83 c4 3c             	add    $0x3c,%esp
  8014b2:	5b                   	pop    %ebx
  8014b3:	5e                   	pop    %esi
  8014b4:	5f                   	pop    %edi
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    

008014b7 <sfork>:

// Challenge!
int
sfork(void)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8014bd:	c7 44 24 08 d7 30 80 	movl   $0x8030d7,0x8(%esp)
  8014c4:	00 
  8014c5:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  8014cc:	00 
  8014cd:	c7 04 24 93 30 80 00 	movl   $0x803093,(%esp)
  8014d4:	e8 e7 ee ff ff       	call   8003c0 <_panic>
  8014d9:	00 00                	add    %al,(%eax)
	...

008014dc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	56                   	push   %esi
  8014e0:	53                   	push   %ebx
  8014e1:	83 ec 10             	sub    $0x10,%esp
  8014e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8014e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ea:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8014ed:	85 c0                	test   %eax,%eax
  8014ef:	74 0a                	je     8014fb <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8014f1:	89 04 24             	mov    %eax,(%esp)
  8014f4:	e8 72 fb ff ff       	call   80106b <sys_ipc_recv>
  8014f9:	eb 0c                	jmp    801507 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8014fb:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801502:	e8 64 fb ff ff       	call   80106b <sys_ipc_recv>
	}
	if (r < 0)
  801507:	85 c0                	test   %eax,%eax
  801509:	79 16                	jns    801521 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  80150b:	85 db                	test   %ebx,%ebx
  80150d:	74 06                	je     801515 <ipc_recv+0x39>
  80150f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  801515:	85 f6                	test   %esi,%esi
  801517:	74 2c                	je     801545 <ipc_recv+0x69>
  801519:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80151f:	eb 24                	jmp    801545 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  801521:	85 db                	test   %ebx,%ebx
  801523:	74 0a                	je     80152f <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  801525:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80152a:	8b 40 74             	mov    0x74(%eax),%eax
  80152d:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  80152f:	85 f6                	test   %esi,%esi
  801531:	74 0a                	je     80153d <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  801533:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801538:	8b 40 78             	mov    0x78(%eax),%eax
  80153b:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  80153d:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801542:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	5b                   	pop    %ebx
  801549:	5e                   	pop    %esi
  80154a:	5d                   	pop    %ebp
  80154b:	c3                   	ret    

0080154c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	57                   	push   %edi
  801550:	56                   	push   %esi
  801551:	53                   	push   %ebx
  801552:	83 ec 1c             	sub    $0x1c,%esp
  801555:	8b 75 08             	mov    0x8(%ebp),%esi
  801558:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80155b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  80155e:	85 db                	test   %ebx,%ebx
  801560:	74 19                	je     80157b <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  801562:	8b 45 14             	mov    0x14(%ebp),%eax
  801565:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801569:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80156d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801571:	89 34 24             	mov    %esi,(%esp)
  801574:	e8 cf fa ff ff       	call   801048 <sys_ipc_try_send>
  801579:	eb 1c                	jmp    801597 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80157b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801582:	00 
  801583:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80158a:	ee 
  80158b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80158f:	89 34 24             	mov    %esi,(%esp)
  801592:	e8 b1 fa ff ff       	call   801048 <sys_ipc_try_send>
		}
		if (r == 0)
  801597:	85 c0                	test   %eax,%eax
  801599:	74 2c                	je     8015c7 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80159b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80159e:	74 20                	je     8015c0 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  8015a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015a4:	c7 44 24 08 ed 30 80 	movl   $0x8030ed,0x8(%esp)
  8015ab:	00 
  8015ac:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8015b3:	00 
  8015b4:	c7 04 24 00 31 80 00 	movl   $0x803100,(%esp)
  8015bb:	e8 00 ee ff ff       	call   8003c0 <_panic>
		}
		sys_yield();
  8015c0:	e8 71 f8 ff ff       	call   800e36 <sys_yield>
	}
  8015c5:	eb 97                	jmp    80155e <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  8015c7:	83 c4 1c             	add    $0x1c,%esp
  8015ca:	5b                   	pop    %ebx
  8015cb:	5e                   	pop    %esi
  8015cc:	5f                   	pop    %edi
  8015cd:	5d                   	pop    %ebp
  8015ce:	c3                   	ret    

008015cf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8015cf:	55                   	push   %ebp
  8015d0:	89 e5                	mov    %esp,%ebp
  8015d2:	53                   	push   %ebx
  8015d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8015d6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8015db:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8015e2:	89 c2                	mov    %eax,%edx
  8015e4:	c1 e2 07             	shl    $0x7,%edx
  8015e7:	29 ca                	sub    %ecx,%edx
  8015e9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8015ef:	8b 52 50             	mov    0x50(%edx),%edx
  8015f2:	39 da                	cmp    %ebx,%edx
  8015f4:	75 0f                	jne    801605 <ipc_find_env+0x36>
			return envs[i].env_id;
  8015f6:	c1 e0 07             	shl    $0x7,%eax
  8015f9:	29 c8                	sub    %ecx,%eax
  8015fb:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801600:	8b 40 40             	mov    0x40(%eax),%eax
  801603:	eb 0c                	jmp    801611 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801605:	40                   	inc    %eax
  801606:	3d 00 04 00 00       	cmp    $0x400,%eax
  80160b:	75 ce                	jne    8015db <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80160d:	66 b8 00 00          	mov    $0x0,%ax
}
  801611:	5b                   	pop    %ebx
  801612:	5d                   	pop    %ebp
  801613:	c3                   	ret    

00801614 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801617:	8b 45 08             	mov    0x8(%ebp),%eax
  80161a:	05 00 00 00 30       	add    $0x30000000,%eax
  80161f:	c1 e8 0c             	shr    $0xc,%eax
}
  801622:	5d                   	pop    %ebp
  801623:	c3                   	ret    

00801624 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80162a:	8b 45 08             	mov    0x8(%ebp),%eax
  80162d:	89 04 24             	mov    %eax,(%esp)
  801630:	e8 df ff ff ff       	call   801614 <fd2num>
  801635:	c1 e0 0c             	shl    $0xc,%eax
  801638:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	53                   	push   %ebx
  801643:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801646:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80164b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80164d:	89 c2                	mov    %eax,%edx
  80164f:	c1 ea 16             	shr    $0x16,%edx
  801652:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801659:	f6 c2 01             	test   $0x1,%dl
  80165c:	74 11                	je     80166f <fd_alloc+0x30>
  80165e:	89 c2                	mov    %eax,%edx
  801660:	c1 ea 0c             	shr    $0xc,%edx
  801663:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80166a:	f6 c2 01             	test   $0x1,%dl
  80166d:	75 09                	jne    801678 <fd_alloc+0x39>
			*fd_store = fd;
  80166f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801671:	b8 00 00 00 00       	mov    $0x0,%eax
  801676:	eb 17                	jmp    80168f <fd_alloc+0x50>
  801678:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80167d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801682:	75 c7                	jne    80164b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801684:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80168a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80168f:	5b                   	pop    %ebx
  801690:	5d                   	pop    %ebp
  801691:	c3                   	ret    

00801692 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801698:	83 f8 1f             	cmp    $0x1f,%eax
  80169b:	77 36                	ja     8016d3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80169d:	c1 e0 0c             	shl    $0xc,%eax
  8016a0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8016a5:	89 c2                	mov    %eax,%edx
  8016a7:	c1 ea 16             	shr    $0x16,%edx
  8016aa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016b1:	f6 c2 01             	test   $0x1,%dl
  8016b4:	74 24                	je     8016da <fd_lookup+0x48>
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	c1 ea 0c             	shr    $0xc,%edx
  8016bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016c2:	f6 c2 01             	test   $0x1,%dl
  8016c5:	74 1a                	je     8016e1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ca:	89 02                	mov    %eax,(%edx)
	return 0;
  8016cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d1:	eb 13                	jmp    8016e6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016d8:	eb 0c                	jmp    8016e6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8016da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016df:	eb 05                	jmp    8016e6 <fd_lookup+0x54>
  8016e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8016e6:	5d                   	pop    %ebp
  8016e7:	c3                   	ret    

008016e8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	53                   	push   %ebx
  8016ec:	83 ec 14             	sub    $0x14,%esp
  8016ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8016f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fa:	eb 0e                	jmp    80170a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8016fc:	39 08                	cmp    %ecx,(%eax)
  8016fe:	75 09                	jne    801709 <dev_lookup+0x21>
			*dev = devtab[i];
  801700:	89 03                	mov    %eax,(%ebx)
			return 0;
  801702:	b8 00 00 00 00       	mov    $0x0,%eax
  801707:	eb 33                	jmp    80173c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801709:	42                   	inc    %edx
  80170a:	8b 04 95 8c 31 80 00 	mov    0x80318c(,%edx,4),%eax
  801711:	85 c0                	test   %eax,%eax
  801713:	75 e7                	jne    8016fc <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801715:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80171a:	8b 40 48             	mov    0x48(%eax),%eax
  80171d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801721:	89 44 24 04          	mov    %eax,0x4(%esp)
  801725:	c7 04 24 0c 31 80 00 	movl   $0x80310c,(%esp)
  80172c:	e8 87 ed ff ff       	call   8004b8 <cprintf>
	*dev = 0;
  801731:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801737:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80173c:	83 c4 14             	add    $0x14,%esp
  80173f:	5b                   	pop    %ebx
  801740:	5d                   	pop    %ebp
  801741:	c3                   	ret    

00801742 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	56                   	push   %esi
  801746:	53                   	push   %ebx
  801747:	83 ec 30             	sub    $0x30,%esp
  80174a:	8b 75 08             	mov    0x8(%ebp),%esi
  80174d:	8a 45 0c             	mov    0xc(%ebp),%al
  801750:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801753:	89 34 24             	mov    %esi,(%esp)
  801756:	e8 b9 fe ff ff       	call   801614 <fd2num>
  80175b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80175e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801762:	89 04 24             	mov    %eax,(%esp)
  801765:	e8 28 ff ff ff       	call   801692 <fd_lookup>
  80176a:	89 c3                	mov    %eax,%ebx
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 05                	js     801775 <fd_close+0x33>
	    || fd != fd2)
  801770:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801773:	74 0d                	je     801782 <fd_close+0x40>
		return (must_exist ? r : 0);
  801775:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801779:	75 46                	jne    8017c1 <fd_close+0x7f>
  80177b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801780:	eb 3f                	jmp    8017c1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801782:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801785:	89 44 24 04          	mov    %eax,0x4(%esp)
  801789:	8b 06                	mov    (%esi),%eax
  80178b:	89 04 24             	mov    %eax,(%esp)
  80178e:	e8 55 ff ff ff       	call   8016e8 <dev_lookup>
  801793:	89 c3                	mov    %eax,%ebx
  801795:	85 c0                	test   %eax,%eax
  801797:	78 18                	js     8017b1 <fd_close+0x6f>
		if (dev->dev_close)
  801799:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179c:	8b 40 10             	mov    0x10(%eax),%eax
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	74 09                	je     8017ac <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8017a3:	89 34 24             	mov    %esi,(%esp)
  8017a6:	ff d0                	call   *%eax
  8017a8:	89 c3                	mov    %eax,%ebx
  8017aa:	eb 05                	jmp    8017b1 <fd_close+0x6f>
		else
			r = 0;
  8017ac:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8017b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017bc:	e8 3b f7 ff ff       	call   800efc <sys_page_unmap>
	return r;
}
  8017c1:	89 d8                	mov    %ebx,%eax
  8017c3:	83 c4 30             	add    $0x30,%esp
  8017c6:	5b                   	pop    %ebx
  8017c7:	5e                   	pop    %esi
  8017c8:	5d                   	pop    %ebp
  8017c9:	c3                   	ret    

008017ca <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017da:	89 04 24             	mov    %eax,(%esp)
  8017dd:	e8 b0 fe ff ff       	call   801692 <fd_lookup>
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 13                	js     8017f9 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8017e6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8017ed:	00 
  8017ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f1:	89 04 24             	mov    %eax,(%esp)
  8017f4:	e8 49 ff ff ff       	call   801742 <fd_close>
}
  8017f9:	c9                   	leave  
  8017fa:	c3                   	ret    

008017fb <close_all>:

void
close_all(void)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	53                   	push   %ebx
  8017ff:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801802:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801807:	89 1c 24             	mov    %ebx,(%esp)
  80180a:	e8 bb ff ff ff       	call   8017ca <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80180f:	43                   	inc    %ebx
  801810:	83 fb 20             	cmp    $0x20,%ebx
  801813:	75 f2                	jne    801807 <close_all+0xc>
		close(i);
}
  801815:	83 c4 14             	add    $0x14,%esp
  801818:	5b                   	pop    %ebx
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    

0080181b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	57                   	push   %edi
  80181f:	56                   	push   %esi
  801820:	53                   	push   %ebx
  801821:	83 ec 4c             	sub    $0x4c,%esp
  801824:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801827:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80182a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182e:	8b 45 08             	mov    0x8(%ebp),%eax
  801831:	89 04 24             	mov    %eax,(%esp)
  801834:	e8 59 fe ff ff       	call   801692 <fd_lookup>
  801839:	89 c3                	mov    %eax,%ebx
  80183b:	85 c0                	test   %eax,%eax
  80183d:	0f 88 e3 00 00 00    	js     801926 <dup+0x10b>
		return r;
	close(newfdnum);
  801843:	89 3c 24             	mov    %edi,(%esp)
  801846:	e8 7f ff ff ff       	call   8017ca <close>

	newfd = INDEX2FD(newfdnum);
  80184b:	89 fe                	mov    %edi,%esi
  80184d:	c1 e6 0c             	shl    $0xc,%esi
  801850:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801856:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801859:	89 04 24             	mov    %eax,(%esp)
  80185c:	e8 c3 fd ff ff       	call   801624 <fd2data>
  801861:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801863:	89 34 24             	mov    %esi,(%esp)
  801866:	e8 b9 fd ff ff       	call   801624 <fd2data>
  80186b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80186e:	89 d8                	mov    %ebx,%eax
  801870:	c1 e8 16             	shr    $0x16,%eax
  801873:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80187a:	a8 01                	test   $0x1,%al
  80187c:	74 46                	je     8018c4 <dup+0xa9>
  80187e:	89 d8                	mov    %ebx,%eax
  801880:	c1 e8 0c             	shr    $0xc,%eax
  801883:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80188a:	f6 c2 01             	test   $0x1,%dl
  80188d:	74 35                	je     8018c4 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80188f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801896:	25 07 0e 00 00       	and    $0xe07,%eax
  80189b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80189f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8018a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018ad:	00 
  8018ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b9:	e8 eb f5 ff ff       	call   800ea9 <sys_page_map>
  8018be:	89 c3                	mov    %eax,%ebx
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	78 3b                	js     8018ff <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018c7:	89 c2                	mov    %eax,%edx
  8018c9:	c1 ea 0c             	shr    $0xc,%edx
  8018cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8018d3:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8018d9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018dd:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8018e1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018e8:	00 
  8018e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018f4:	e8 b0 f5 ff ff       	call   800ea9 <sys_page_map>
  8018f9:	89 c3                	mov    %eax,%ebx
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	79 25                	jns    801924 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8018ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  801903:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80190a:	e8 ed f5 ff ff       	call   800efc <sys_page_unmap>
	sys_page_unmap(0, nva);
  80190f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801912:	89 44 24 04          	mov    %eax,0x4(%esp)
  801916:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80191d:	e8 da f5 ff ff       	call   800efc <sys_page_unmap>
	return r;
  801922:	eb 02                	jmp    801926 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801924:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801926:	89 d8                	mov    %ebx,%eax
  801928:	83 c4 4c             	add    $0x4c,%esp
  80192b:	5b                   	pop    %ebx
  80192c:	5e                   	pop    %esi
  80192d:	5f                   	pop    %edi
  80192e:	5d                   	pop    %ebp
  80192f:	c3                   	ret    

00801930 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	53                   	push   %ebx
  801934:	83 ec 24             	sub    $0x24,%esp
  801937:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80193a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80193d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801941:	89 1c 24             	mov    %ebx,(%esp)
  801944:	e8 49 fd ff ff       	call   801692 <fd_lookup>
  801949:	85 c0                	test   %eax,%eax
  80194b:	78 6d                	js     8019ba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80194d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801950:	89 44 24 04          	mov    %eax,0x4(%esp)
  801954:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801957:	8b 00                	mov    (%eax),%eax
  801959:	89 04 24             	mov    %eax,(%esp)
  80195c:	e8 87 fd ff ff       	call   8016e8 <dev_lookup>
  801961:	85 c0                	test   %eax,%eax
  801963:	78 55                	js     8019ba <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801965:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801968:	8b 50 08             	mov    0x8(%eax),%edx
  80196b:	83 e2 03             	and    $0x3,%edx
  80196e:	83 fa 01             	cmp    $0x1,%edx
  801971:	75 23                	jne    801996 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801973:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801978:	8b 40 48             	mov    0x48(%eax),%eax
  80197b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80197f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801983:	c7 04 24 50 31 80 00 	movl   $0x803150,(%esp)
  80198a:	e8 29 eb ff ff       	call   8004b8 <cprintf>
		return -E_INVAL;
  80198f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801994:	eb 24                	jmp    8019ba <read+0x8a>
	}
	if (!dev->dev_read)
  801996:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801999:	8b 52 08             	mov    0x8(%edx),%edx
  80199c:	85 d2                	test   %edx,%edx
  80199e:	74 15                	je     8019b5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8019a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8019a3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019aa:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019ae:	89 04 24             	mov    %eax,(%esp)
  8019b1:	ff d2                	call   *%edx
  8019b3:	eb 05                	jmp    8019ba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8019b5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8019ba:	83 c4 24             	add    $0x24,%esp
  8019bd:	5b                   	pop    %ebx
  8019be:	5d                   	pop    %ebp
  8019bf:	c3                   	ret    

008019c0 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	57                   	push   %edi
  8019c4:	56                   	push   %esi
  8019c5:	53                   	push   %ebx
  8019c6:	83 ec 1c             	sub    $0x1c,%esp
  8019c9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019cc:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019d4:	eb 23                	jmp    8019f9 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8019d6:	89 f0                	mov    %esi,%eax
  8019d8:	29 d8                	sub    %ebx,%eax
  8019da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e1:	01 d8                	add    %ebx,%eax
  8019e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e7:	89 3c 24             	mov    %edi,(%esp)
  8019ea:	e8 41 ff ff ff       	call   801930 <read>
		if (m < 0)
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	78 10                	js     801a03 <readn+0x43>
			return m;
		if (m == 0)
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	74 0a                	je     801a01 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019f7:	01 c3                	add    %eax,%ebx
  8019f9:	39 f3                	cmp    %esi,%ebx
  8019fb:	72 d9                	jb     8019d6 <readn+0x16>
  8019fd:	89 d8                	mov    %ebx,%eax
  8019ff:	eb 02                	jmp    801a03 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801a01:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801a03:	83 c4 1c             	add    $0x1c,%esp
  801a06:	5b                   	pop    %ebx
  801a07:	5e                   	pop    %esi
  801a08:	5f                   	pop    %edi
  801a09:	5d                   	pop    %ebp
  801a0a:	c3                   	ret    

00801a0b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
  801a0e:	53                   	push   %ebx
  801a0f:	83 ec 24             	sub    $0x24,%esp
  801a12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a15:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1c:	89 1c 24             	mov    %ebx,(%esp)
  801a1f:	e8 6e fc ff ff       	call   801692 <fd_lookup>
  801a24:	85 c0                	test   %eax,%eax
  801a26:	78 68                	js     801a90 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a32:	8b 00                	mov    (%eax),%eax
  801a34:	89 04 24             	mov    %eax,(%esp)
  801a37:	e8 ac fc ff ff       	call   8016e8 <dev_lookup>
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	78 50                	js     801a90 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a43:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a47:	75 23                	jne    801a6c <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a49:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801a4e:	8b 40 48             	mov    0x48(%eax),%eax
  801a51:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a59:	c7 04 24 6c 31 80 00 	movl   $0x80316c,(%esp)
  801a60:	e8 53 ea ff ff       	call   8004b8 <cprintf>
		return -E_INVAL;
  801a65:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a6a:	eb 24                	jmp    801a90 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a6c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a6f:	8b 52 0c             	mov    0xc(%edx),%edx
  801a72:	85 d2                	test   %edx,%edx
  801a74:	74 15                	je     801a8b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a76:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a79:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a80:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a84:	89 04 24             	mov    %eax,(%esp)
  801a87:	ff d2                	call   *%edx
  801a89:	eb 05                	jmp    801a90 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801a8b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801a90:	83 c4 24             	add    $0x24,%esp
  801a93:	5b                   	pop    %ebx
  801a94:	5d                   	pop    %ebp
  801a95:	c3                   	ret    

00801a96 <seek>:

int
seek(int fdnum, off_t offset)
{
  801a96:	55                   	push   %ebp
  801a97:	89 e5                	mov    %esp,%ebp
  801a99:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a9c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa6:	89 04 24             	mov    %eax,(%esp)
  801aa9:	e8 e4 fb ff ff       	call   801692 <fd_lookup>
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	78 0e                	js     801ac0 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801ab2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801ab5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ab8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801abb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    

00801ac2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	53                   	push   %ebx
  801ac6:	83 ec 24             	sub    $0x24,%esp
  801ac9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801acc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801acf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad3:	89 1c 24             	mov    %ebx,(%esp)
  801ad6:	e8 b7 fb ff ff       	call   801692 <fd_lookup>
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 61                	js     801b40 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801adf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae9:	8b 00                	mov    (%eax),%eax
  801aeb:	89 04 24             	mov    %eax,(%esp)
  801aee:	e8 f5 fb ff ff       	call   8016e8 <dev_lookup>
  801af3:	85 c0                	test   %eax,%eax
  801af5:	78 49                	js     801b40 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801af7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801afa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801afe:	75 23                	jne    801b23 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b00:	a1 0c 50 80 00       	mov    0x80500c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b05:	8b 40 48             	mov    0x48(%eax),%eax
  801b08:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b10:	c7 04 24 2c 31 80 00 	movl   $0x80312c,(%esp)
  801b17:	e8 9c e9 ff ff       	call   8004b8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b1c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b21:	eb 1d                	jmp    801b40 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801b23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b26:	8b 52 18             	mov    0x18(%edx),%edx
  801b29:	85 d2                	test   %edx,%edx
  801b2b:	74 0e                	je     801b3b <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b30:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b34:	89 04 24             	mov    %eax,(%esp)
  801b37:	ff d2                	call   *%edx
  801b39:	eb 05                	jmp    801b40 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b3b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801b40:	83 c4 24             	add    $0x24,%esp
  801b43:	5b                   	pop    %ebx
  801b44:	5d                   	pop    %ebp
  801b45:	c3                   	ret    

00801b46 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	53                   	push   %ebx
  801b4a:	83 ec 24             	sub    $0x24,%esp
  801b4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b50:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b57:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5a:	89 04 24             	mov    %eax,(%esp)
  801b5d:	e8 30 fb ff ff       	call   801692 <fd_lookup>
  801b62:	85 c0                	test   %eax,%eax
  801b64:	78 52                	js     801bb8 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b70:	8b 00                	mov    (%eax),%eax
  801b72:	89 04 24             	mov    %eax,(%esp)
  801b75:	e8 6e fb ff ff       	call   8016e8 <dev_lookup>
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	78 3a                	js     801bb8 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b81:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801b85:	74 2c                	je     801bb3 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801b87:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801b8a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801b91:	00 00 00 
	stat->st_isdir = 0;
  801b94:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b9b:	00 00 00 
	stat->st_dev = dev;
  801b9e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801ba4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ba8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bab:	89 14 24             	mov    %edx,(%esp)
  801bae:	ff 50 14             	call   *0x14(%eax)
  801bb1:	eb 05                	jmp    801bb8 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801bb3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801bb8:	83 c4 24             	add    $0x24,%esp
  801bbb:	5b                   	pop    %ebx
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    

00801bbe <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	56                   	push   %esi
  801bc2:	53                   	push   %ebx
  801bc3:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801bc6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bcd:	00 
  801bce:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd1:	89 04 24             	mov    %eax,(%esp)
  801bd4:	e8 2a 02 00 00       	call   801e03 <open>
  801bd9:	89 c3                	mov    %eax,%ebx
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	78 1b                	js     801bfa <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be6:	89 1c 24             	mov    %ebx,(%esp)
  801be9:	e8 58 ff ff ff       	call   801b46 <fstat>
  801bee:	89 c6                	mov    %eax,%esi
	close(fd);
  801bf0:	89 1c 24             	mov    %ebx,(%esp)
  801bf3:	e8 d2 fb ff ff       	call   8017ca <close>
	return r;
  801bf8:	89 f3                	mov    %esi,%ebx
}
  801bfa:	89 d8                	mov    %ebx,%eax
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	5b                   	pop    %ebx
  801c00:	5e                   	pop    %esi
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    
	...

00801c04 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c04:	55                   	push   %ebp
  801c05:	89 e5                	mov    %esp,%ebp
  801c07:	56                   	push   %esi
  801c08:	53                   	push   %ebx
  801c09:	83 ec 10             	sub    $0x10,%esp
  801c0c:	89 c3                	mov    %eax,%ebx
  801c0e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c10:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801c17:	75 11                	jne    801c2a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c20:	e8 aa f9 ff ff       	call   8015cf <ipc_find_env>
  801c25:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c2a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c31:	00 
  801c32:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801c39:	00 
  801c3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c3e:	a1 04 50 80 00       	mov    0x805004,%eax
  801c43:	89 04 24             	mov    %eax,(%esp)
  801c46:	e8 01 f9 ff ff       	call   80154c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c52:	00 
  801c53:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c5e:	e8 79 f8 ff ff       	call   8014dc <ipc_recv>
}
  801c63:	83 c4 10             	add    $0x10,%esp
  801c66:	5b                   	pop    %ebx
  801c67:	5e                   	pop    %esi
  801c68:	5d                   	pop    %ebp
  801c69:	c3                   	ret    

00801c6a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c70:	8b 45 08             	mov    0x8(%ebp),%eax
  801c73:	8b 40 0c             	mov    0xc(%eax),%eax
  801c76:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7e:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c83:	ba 00 00 00 00       	mov    $0x0,%edx
  801c88:	b8 02 00 00 00       	mov    $0x2,%eax
  801c8d:	e8 72 ff ff ff       	call   801c04 <fsipc>
}
  801c92:	c9                   	leave  
  801c93:	c3                   	ret    

00801c94 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9d:	8b 40 0c             	mov    0xc(%eax),%eax
  801ca0:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ca5:	ba 00 00 00 00       	mov    $0x0,%edx
  801caa:	b8 06 00 00 00       	mov    $0x6,%eax
  801caf:	e8 50 ff ff ff       	call   801c04 <fsipc>
}
  801cb4:	c9                   	leave  
  801cb5:	c3                   	ret    

00801cb6 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	53                   	push   %ebx
  801cba:	83 ec 14             	sub    $0x14,%esp
  801cbd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801cc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc3:	8b 40 0c             	mov    0xc(%eax),%eax
  801cc6:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ccb:	ba 00 00 00 00       	mov    $0x0,%edx
  801cd0:	b8 05 00 00 00       	mov    $0x5,%eax
  801cd5:	e8 2a ff ff ff       	call   801c04 <fsipc>
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	78 2b                	js     801d09 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801cde:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801ce5:	00 
  801ce6:	89 1c 24             	mov    %ebx,(%esp)
  801ce9:	e8 75 ed ff ff       	call   800a63 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801cee:	a1 80 60 80 00       	mov    0x806080,%eax
  801cf3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801cf9:	a1 84 60 80 00       	mov    0x806084,%eax
  801cfe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d09:	83 c4 14             	add    $0x14,%esp
  801d0c:	5b                   	pop    %ebx
  801d0d:	5d                   	pop    %ebp
  801d0e:	c3                   	ret    

00801d0f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	83 ec 18             	sub    $0x18,%esp
  801d15:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d18:	8b 55 08             	mov    0x8(%ebp),%edx
  801d1b:	8b 52 0c             	mov    0xc(%edx),%edx
  801d1e:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801d24:	a3 04 60 80 00       	mov    %eax,0x806004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801d29:	89 c2                	mov    %eax,%edx
  801d2b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801d30:	76 05                	jbe    801d37 <devfile_write+0x28>
  801d32:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801d37:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d42:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801d49:	e8 f8 ee ff ff       	call   800c46 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801d4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d53:	b8 04 00 00 00       	mov    $0x4,%eax
  801d58:	e8 a7 fe ff ff       	call   801c04 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801d5d:	c9                   	leave  
  801d5e:	c3                   	ret    

00801d5f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	56                   	push   %esi
  801d63:	53                   	push   %ebx
  801d64:	83 ec 10             	sub    $0x10,%esp
  801d67:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d6a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6d:	8b 40 0c             	mov    0xc(%eax),%eax
  801d70:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801d75:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d7b:	ba 00 00 00 00       	mov    $0x0,%edx
  801d80:	b8 03 00 00 00       	mov    $0x3,%eax
  801d85:	e8 7a fe ff ff       	call   801c04 <fsipc>
  801d8a:	89 c3                	mov    %eax,%ebx
  801d8c:	85 c0                	test   %eax,%eax
  801d8e:	78 6a                	js     801dfa <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801d90:	39 c6                	cmp    %eax,%esi
  801d92:	73 24                	jae    801db8 <devfile_read+0x59>
  801d94:	c7 44 24 0c a0 31 80 	movl   $0x8031a0,0xc(%esp)
  801d9b:	00 
  801d9c:	c7 44 24 08 a7 31 80 	movl   $0x8031a7,0x8(%esp)
  801da3:	00 
  801da4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801dab:	00 
  801dac:	c7 04 24 bc 31 80 00 	movl   $0x8031bc,(%esp)
  801db3:	e8 08 e6 ff ff       	call   8003c0 <_panic>
	assert(r <= PGSIZE);
  801db8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801dbd:	7e 24                	jle    801de3 <devfile_read+0x84>
  801dbf:	c7 44 24 0c c7 31 80 	movl   $0x8031c7,0xc(%esp)
  801dc6:	00 
  801dc7:	c7 44 24 08 a7 31 80 	movl   $0x8031a7,0x8(%esp)
  801dce:	00 
  801dcf:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801dd6:	00 
  801dd7:	c7 04 24 bc 31 80 00 	movl   $0x8031bc,(%esp)
  801dde:	e8 dd e5 ff ff       	call   8003c0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801de3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801de7:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801dee:	00 
  801def:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df2:	89 04 24             	mov    %eax,(%esp)
  801df5:	e8 e2 ed ff ff       	call   800bdc <memmove>
	return r;
}
  801dfa:	89 d8                	mov    %ebx,%eax
  801dfc:	83 c4 10             	add    $0x10,%esp
  801dff:	5b                   	pop    %ebx
  801e00:	5e                   	pop    %esi
  801e01:	5d                   	pop    %ebp
  801e02:	c3                   	ret    

00801e03 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	56                   	push   %esi
  801e07:	53                   	push   %ebx
  801e08:	83 ec 20             	sub    $0x20,%esp
  801e0b:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e0e:	89 34 24             	mov    %esi,(%esp)
  801e11:	e8 1a ec ff ff       	call   800a30 <strlen>
  801e16:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e1b:	7f 60                	jg     801e7d <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e20:	89 04 24             	mov    %eax,(%esp)
  801e23:	e8 17 f8 ff ff       	call   80163f <fd_alloc>
  801e28:	89 c3                	mov    %eax,%ebx
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	78 54                	js     801e82 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e2e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e32:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801e39:	e8 25 ec ff ff       	call   800a63 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e41:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e49:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4e:	e8 b1 fd ff ff       	call   801c04 <fsipc>
  801e53:	89 c3                	mov    %eax,%ebx
  801e55:	85 c0                	test   %eax,%eax
  801e57:	79 15                	jns    801e6e <open+0x6b>
		fd_close(fd, 0);
  801e59:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e60:	00 
  801e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e64:	89 04 24             	mov    %eax,(%esp)
  801e67:	e8 d6 f8 ff ff       	call   801742 <fd_close>
		return r;
  801e6c:	eb 14                	jmp    801e82 <open+0x7f>
	}

	return fd2num(fd);
  801e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e71:	89 04 24             	mov    %eax,(%esp)
  801e74:	e8 9b f7 ff ff       	call   801614 <fd2num>
  801e79:	89 c3                	mov    %eax,%ebx
  801e7b:	eb 05                	jmp    801e82 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801e7d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801e82:	89 d8                	mov    %ebx,%eax
  801e84:	83 c4 20             	add    $0x20,%esp
  801e87:	5b                   	pop    %ebx
  801e88:	5e                   	pop    %esi
  801e89:	5d                   	pop    %ebp
  801e8a:	c3                   	ret    

00801e8b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801e8b:	55                   	push   %ebp
  801e8c:	89 e5                	mov    %esp,%ebp
  801e8e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e91:	ba 00 00 00 00       	mov    $0x0,%edx
  801e96:	b8 08 00 00 00       	mov    $0x8,%eax
  801e9b:	e8 64 fd ff ff       	call   801c04 <fsipc>
}
  801ea0:	c9                   	leave  
  801ea1:	c3                   	ret    
	...

00801ea4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ea4:	55                   	push   %ebp
  801ea5:	89 e5                	mov    %esp,%ebp
  801ea7:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801eaa:	c7 44 24 04 d3 31 80 	movl   $0x8031d3,0x4(%esp)
  801eb1:	00 
  801eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb5:	89 04 24             	mov    %eax,(%esp)
  801eb8:	e8 a6 eb ff ff       	call   800a63 <strcpy>
	return 0;
}
  801ebd:	b8 00 00 00 00       	mov    $0x0,%eax
  801ec2:	c9                   	leave  
  801ec3:	c3                   	ret    

00801ec4 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	53                   	push   %ebx
  801ec8:	83 ec 14             	sub    $0x14,%esp
  801ecb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ece:	89 1c 24             	mov    %ebx,(%esp)
  801ed1:	e8 56 0a 00 00       	call   80292c <pageref>
  801ed6:	83 f8 01             	cmp    $0x1,%eax
  801ed9:	75 0d                	jne    801ee8 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801edb:	8b 43 0c             	mov    0xc(%ebx),%eax
  801ede:	89 04 24             	mov    %eax,(%esp)
  801ee1:	e8 1f 03 00 00       	call   802205 <nsipc_close>
  801ee6:	eb 05                	jmp    801eed <devsock_close+0x29>
	else
		return 0;
  801ee8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eed:	83 c4 14             	add    $0x14,%esp
  801ef0:	5b                   	pop    %ebx
  801ef1:	5d                   	pop    %ebp
  801ef2:	c3                   	ret    

00801ef3 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ef3:	55                   	push   %ebp
  801ef4:	89 e5                	mov    %esp,%ebp
  801ef6:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ef9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f00:	00 
  801f01:	8b 45 10             	mov    0x10(%ebp),%eax
  801f04:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f12:	8b 40 0c             	mov    0xc(%eax),%eax
  801f15:	89 04 24             	mov    %eax,(%esp)
  801f18:	e8 e3 03 00 00       	call   802300 <nsipc_send>
}
  801f1d:	c9                   	leave  
  801f1e:	c3                   	ret    

00801f1f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f1f:	55                   	push   %ebp
  801f20:	89 e5                	mov    %esp,%ebp
  801f22:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f25:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f2c:	00 
  801f2d:	8b 45 10             	mov    0x10(%ebp),%eax
  801f30:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3e:	8b 40 0c             	mov    0xc(%eax),%eax
  801f41:	89 04 24             	mov    %eax,(%esp)
  801f44:	e8 37 03 00 00       	call   802280 <nsipc_recv>
}
  801f49:	c9                   	leave  
  801f4a:	c3                   	ret    

00801f4b <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	56                   	push   %esi
  801f4f:	53                   	push   %ebx
  801f50:	83 ec 20             	sub    $0x20,%esp
  801f53:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f58:	89 04 24             	mov    %eax,(%esp)
  801f5b:	e8 df f6 ff ff       	call   80163f <fd_alloc>
  801f60:	89 c3                	mov    %eax,%ebx
  801f62:	85 c0                	test   %eax,%eax
  801f64:	78 21                	js     801f87 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f66:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f6d:	00 
  801f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f71:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f7c:	e8 d4 ee ff ff       	call   800e55 <sys_page_alloc>
  801f81:	89 c3                	mov    %eax,%ebx
  801f83:	85 c0                	test   %eax,%eax
  801f85:	79 0a                	jns    801f91 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801f87:	89 34 24             	mov    %esi,(%esp)
  801f8a:	e8 76 02 00 00       	call   802205 <nsipc_close>
		return r;
  801f8f:	eb 22                	jmp    801fb3 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801f91:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801f9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801fa6:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801fa9:	89 04 24             	mov    %eax,(%esp)
  801fac:	e8 63 f6 ff ff       	call   801614 <fd2num>
  801fb1:	89 c3                	mov    %eax,%ebx
}
  801fb3:	89 d8                	mov    %ebx,%eax
  801fb5:	83 c4 20             	add    $0x20,%esp
  801fb8:	5b                   	pop    %ebx
  801fb9:	5e                   	pop    %esi
  801fba:	5d                   	pop    %ebp
  801fbb:	c3                   	ret    

00801fbc <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801fc2:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801fc5:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fc9:	89 04 24             	mov    %eax,(%esp)
  801fcc:	e8 c1 f6 ff ff       	call   801692 <fd_lookup>
  801fd1:	85 c0                	test   %eax,%eax
  801fd3:	78 17                	js     801fec <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd8:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801fde:	39 10                	cmp    %edx,(%eax)
  801fe0:	75 05                	jne    801fe7 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801fe2:	8b 40 0c             	mov    0xc(%eax),%eax
  801fe5:	eb 05                	jmp    801fec <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801fe7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801fec:	c9                   	leave  
  801fed:	c3                   	ret    

00801fee <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
  801ff1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ff4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff7:	e8 c0 ff ff ff       	call   801fbc <fd2sockid>
  801ffc:	85 c0                	test   %eax,%eax
  801ffe:	78 1f                	js     80201f <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802000:	8b 55 10             	mov    0x10(%ebp),%edx
  802003:	89 54 24 08          	mov    %edx,0x8(%esp)
  802007:	8b 55 0c             	mov    0xc(%ebp),%edx
  80200a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80200e:	89 04 24             	mov    %eax,(%esp)
  802011:	e8 38 01 00 00       	call   80214e <nsipc_accept>
  802016:	85 c0                	test   %eax,%eax
  802018:	78 05                	js     80201f <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80201a:	e8 2c ff ff ff       	call   801f4b <alloc_sockfd>
}
  80201f:	c9                   	leave  
  802020:	c3                   	ret    

00802021 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802021:	55                   	push   %ebp
  802022:	89 e5                	mov    %esp,%ebp
  802024:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802027:	8b 45 08             	mov    0x8(%ebp),%eax
  80202a:	e8 8d ff ff ff       	call   801fbc <fd2sockid>
  80202f:	85 c0                	test   %eax,%eax
  802031:	78 16                	js     802049 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  802033:	8b 55 10             	mov    0x10(%ebp),%edx
  802036:	89 54 24 08          	mov    %edx,0x8(%esp)
  80203a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80203d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802041:	89 04 24             	mov    %eax,(%esp)
  802044:	e8 5b 01 00 00       	call   8021a4 <nsipc_bind>
}
  802049:	c9                   	leave  
  80204a:	c3                   	ret    

0080204b <shutdown>:

int
shutdown(int s, int how)
{
  80204b:	55                   	push   %ebp
  80204c:	89 e5                	mov    %esp,%ebp
  80204e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802051:	8b 45 08             	mov    0x8(%ebp),%eax
  802054:	e8 63 ff ff ff       	call   801fbc <fd2sockid>
  802059:	85 c0                	test   %eax,%eax
  80205b:	78 0f                	js     80206c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80205d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802060:	89 54 24 04          	mov    %edx,0x4(%esp)
  802064:	89 04 24             	mov    %eax,(%esp)
  802067:	e8 77 01 00 00       	call   8021e3 <nsipc_shutdown>
}
  80206c:	c9                   	leave  
  80206d:	c3                   	ret    

0080206e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80206e:	55                   	push   %ebp
  80206f:	89 e5                	mov    %esp,%ebp
  802071:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802074:	8b 45 08             	mov    0x8(%ebp),%eax
  802077:	e8 40 ff ff ff       	call   801fbc <fd2sockid>
  80207c:	85 c0                	test   %eax,%eax
  80207e:	78 16                	js     802096 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  802080:	8b 55 10             	mov    0x10(%ebp),%edx
  802083:	89 54 24 08          	mov    %edx,0x8(%esp)
  802087:	8b 55 0c             	mov    0xc(%ebp),%edx
  80208a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80208e:	89 04 24             	mov    %eax,(%esp)
  802091:	e8 89 01 00 00       	call   80221f <nsipc_connect>
}
  802096:	c9                   	leave  
  802097:	c3                   	ret    

00802098 <listen>:

int
listen(int s, int backlog)
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80209e:	8b 45 08             	mov    0x8(%ebp),%eax
  8020a1:	e8 16 ff ff ff       	call   801fbc <fd2sockid>
  8020a6:	85 c0                	test   %eax,%eax
  8020a8:	78 0f                	js     8020b9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8020aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020b1:	89 04 24             	mov    %eax,(%esp)
  8020b4:	e8 a5 01 00 00       	call   80225e <nsipc_listen>
}
  8020b9:	c9                   	leave  
  8020ba:	c3                   	ret    

008020bb <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8020bb:	55                   	push   %ebp
  8020bc:	89 e5                	mov    %esp,%ebp
  8020be:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8020c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d2:	89 04 24             	mov    %eax,(%esp)
  8020d5:	e8 99 02 00 00       	call   802373 <nsipc_socket>
  8020da:	85 c0                	test   %eax,%eax
  8020dc:	78 05                	js     8020e3 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8020de:	e8 68 fe ff ff       	call   801f4b <alloc_sockfd>
}
  8020e3:	c9                   	leave  
  8020e4:	c3                   	ret    
  8020e5:	00 00                	add    %al,(%eax)
	...

008020e8 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8020e8:	55                   	push   %ebp
  8020e9:	89 e5                	mov    %esp,%ebp
  8020eb:	53                   	push   %ebx
  8020ec:	83 ec 14             	sub    $0x14,%esp
  8020ef:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8020f1:	83 3d 08 50 80 00 00 	cmpl   $0x0,0x805008
  8020f8:	75 11                	jne    80210b <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8020fa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  802101:	e8 c9 f4 ff ff       	call   8015cf <ipc_find_env>
  802106:	a3 08 50 80 00       	mov    %eax,0x805008
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80210b:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802112:	00 
  802113:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  80211a:	00 
  80211b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80211f:	a1 08 50 80 00       	mov    0x805008,%eax
  802124:	89 04 24             	mov    %eax,(%esp)
  802127:	e8 20 f4 ff ff       	call   80154c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80212c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802133:	00 
  802134:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80213b:	00 
  80213c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802143:	e8 94 f3 ff ff       	call   8014dc <ipc_recv>
}
  802148:	83 c4 14             	add    $0x14,%esp
  80214b:	5b                   	pop    %ebx
  80214c:	5d                   	pop    %ebp
  80214d:	c3                   	ret    

0080214e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80214e:	55                   	push   %ebp
  80214f:	89 e5                	mov    %esp,%ebp
  802151:	56                   	push   %esi
  802152:	53                   	push   %ebx
  802153:	83 ec 10             	sub    $0x10,%esp
  802156:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  802159:	8b 45 08             	mov    0x8(%ebp),%eax
  80215c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802161:	8b 06                	mov    (%esi),%eax
  802163:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802168:	b8 01 00 00 00       	mov    $0x1,%eax
  80216d:	e8 76 ff ff ff       	call   8020e8 <nsipc>
  802172:	89 c3                	mov    %eax,%ebx
  802174:	85 c0                	test   %eax,%eax
  802176:	78 23                	js     80219b <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802178:	a1 10 70 80 00       	mov    0x807010,%eax
  80217d:	89 44 24 08          	mov    %eax,0x8(%esp)
  802181:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802188:	00 
  802189:	8b 45 0c             	mov    0xc(%ebp),%eax
  80218c:	89 04 24             	mov    %eax,(%esp)
  80218f:	e8 48 ea ff ff       	call   800bdc <memmove>
		*addrlen = ret->ret_addrlen;
  802194:	a1 10 70 80 00       	mov    0x807010,%eax
  802199:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  80219b:	89 d8                	mov    %ebx,%eax
  80219d:	83 c4 10             	add    $0x10,%esp
  8021a0:	5b                   	pop    %ebx
  8021a1:	5e                   	pop    %esi
  8021a2:	5d                   	pop    %ebp
  8021a3:	c3                   	ret    

008021a4 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8021a4:	55                   	push   %ebp
  8021a5:	89 e5                	mov    %esp,%ebp
  8021a7:	53                   	push   %ebx
  8021a8:	83 ec 14             	sub    $0x14,%esp
  8021ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8021ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b1:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8021b6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021c1:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8021c8:	e8 0f ea ff ff       	call   800bdc <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8021cd:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8021d3:	b8 02 00 00 00       	mov    $0x2,%eax
  8021d8:	e8 0b ff ff ff       	call   8020e8 <nsipc>
}
  8021dd:	83 c4 14             	add    $0x14,%esp
  8021e0:	5b                   	pop    %ebx
  8021e1:	5d                   	pop    %ebp
  8021e2:	c3                   	ret    

008021e3 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8021e3:	55                   	push   %ebp
  8021e4:	89 e5                	mov    %esp,%ebp
  8021e6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8021e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ec:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8021f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021f4:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8021f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8021fe:	e8 e5 fe ff ff       	call   8020e8 <nsipc>
}
  802203:	c9                   	leave  
  802204:	c3                   	ret    

00802205 <nsipc_close>:

int
nsipc_close(int s)
{
  802205:	55                   	push   %ebp
  802206:	89 e5                	mov    %esp,%ebp
  802208:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80220b:	8b 45 08             	mov    0x8(%ebp),%eax
  80220e:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802213:	b8 04 00 00 00       	mov    $0x4,%eax
  802218:	e8 cb fe ff ff       	call   8020e8 <nsipc>
}
  80221d:	c9                   	leave  
  80221e:	c3                   	ret    

0080221f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80221f:	55                   	push   %ebp
  802220:	89 e5                	mov    %esp,%ebp
  802222:	53                   	push   %ebx
  802223:	83 ec 14             	sub    $0x14,%esp
  802226:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  802229:	8b 45 08             	mov    0x8(%ebp),%eax
  80222c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802231:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802235:	8b 45 0c             	mov    0xc(%ebp),%eax
  802238:	89 44 24 04          	mov    %eax,0x4(%esp)
  80223c:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802243:	e8 94 e9 ff ff       	call   800bdc <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  802248:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  80224e:	b8 05 00 00 00       	mov    $0x5,%eax
  802253:	e8 90 fe ff ff       	call   8020e8 <nsipc>
}
  802258:	83 c4 14             	add    $0x14,%esp
  80225b:	5b                   	pop    %ebx
  80225c:	5d                   	pop    %ebp
  80225d:	c3                   	ret    

0080225e <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80225e:	55                   	push   %ebp
  80225f:	89 e5                	mov    %esp,%ebp
  802261:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802264:	8b 45 08             	mov    0x8(%ebp),%eax
  802267:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80226c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80226f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802274:	b8 06 00 00 00       	mov    $0x6,%eax
  802279:	e8 6a fe ff ff       	call   8020e8 <nsipc>
}
  80227e:	c9                   	leave  
  80227f:	c3                   	ret    

00802280 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802280:	55                   	push   %ebp
  802281:	89 e5                	mov    %esp,%ebp
  802283:	56                   	push   %esi
  802284:	53                   	push   %ebx
  802285:	83 ec 10             	sub    $0x10,%esp
  802288:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80228b:	8b 45 08             	mov    0x8(%ebp),%eax
  80228e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802293:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802299:	8b 45 14             	mov    0x14(%ebp),%eax
  80229c:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8022a1:	b8 07 00 00 00       	mov    $0x7,%eax
  8022a6:	e8 3d fe ff ff       	call   8020e8 <nsipc>
  8022ab:	89 c3                	mov    %eax,%ebx
  8022ad:	85 c0                	test   %eax,%eax
  8022af:	78 46                	js     8022f7 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8022b1:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8022b6:	7f 04                	jg     8022bc <nsipc_recv+0x3c>
  8022b8:	39 c6                	cmp    %eax,%esi
  8022ba:	7d 24                	jge    8022e0 <nsipc_recv+0x60>
  8022bc:	c7 44 24 0c df 31 80 	movl   $0x8031df,0xc(%esp)
  8022c3:	00 
  8022c4:	c7 44 24 08 a7 31 80 	movl   $0x8031a7,0x8(%esp)
  8022cb:	00 
  8022cc:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8022d3:	00 
  8022d4:	c7 04 24 f4 31 80 00 	movl   $0x8031f4,(%esp)
  8022db:	e8 e0 e0 ff ff       	call   8003c0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8022e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022e4:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8022eb:	00 
  8022ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ef:	89 04 24             	mov    %eax,(%esp)
  8022f2:	e8 e5 e8 ff ff       	call   800bdc <memmove>
	}

	return r;
}
  8022f7:	89 d8                	mov    %ebx,%eax
  8022f9:	83 c4 10             	add    $0x10,%esp
  8022fc:	5b                   	pop    %ebx
  8022fd:	5e                   	pop    %esi
  8022fe:	5d                   	pop    %ebp
  8022ff:	c3                   	ret    

00802300 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802300:	55                   	push   %ebp
  802301:	89 e5                	mov    %esp,%ebp
  802303:	53                   	push   %ebx
  802304:	83 ec 14             	sub    $0x14,%esp
  802307:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80230a:	8b 45 08             	mov    0x8(%ebp),%eax
  80230d:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802312:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802318:	7e 24                	jle    80233e <nsipc_send+0x3e>
  80231a:	c7 44 24 0c 00 32 80 	movl   $0x803200,0xc(%esp)
  802321:	00 
  802322:	c7 44 24 08 a7 31 80 	movl   $0x8031a7,0x8(%esp)
  802329:	00 
  80232a:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802331:	00 
  802332:	c7 04 24 f4 31 80 00 	movl   $0x8031f4,(%esp)
  802339:	e8 82 e0 ff ff       	call   8003c0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80233e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802342:	8b 45 0c             	mov    0xc(%ebp),%eax
  802345:	89 44 24 04          	mov    %eax,0x4(%esp)
  802349:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802350:	e8 87 e8 ff ff       	call   800bdc <memmove>
	nsipcbuf.send.req_size = size;
  802355:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80235b:	8b 45 14             	mov    0x14(%ebp),%eax
  80235e:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802363:	b8 08 00 00 00       	mov    $0x8,%eax
  802368:	e8 7b fd ff ff       	call   8020e8 <nsipc>
}
  80236d:	83 c4 14             	add    $0x14,%esp
  802370:	5b                   	pop    %ebx
  802371:	5d                   	pop    %ebp
  802372:	c3                   	ret    

00802373 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802373:	55                   	push   %ebp
  802374:	89 e5                	mov    %esp,%ebp
  802376:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802379:	8b 45 08             	mov    0x8(%ebp),%eax
  80237c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802381:	8b 45 0c             	mov    0xc(%ebp),%eax
  802384:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  802389:	8b 45 10             	mov    0x10(%ebp),%eax
  80238c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802391:	b8 09 00 00 00       	mov    $0x9,%eax
  802396:	e8 4d fd ff ff       	call   8020e8 <nsipc>
}
  80239b:	c9                   	leave  
  80239c:	c3                   	ret    
  80239d:	00 00                	add    %al,(%eax)
	...

008023a0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8023a0:	55                   	push   %ebp
  8023a1:	89 e5                	mov    %esp,%ebp
  8023a3:	56                   	push   %esi
  8023a4:	53                   	push   %ebx
  8023a5:	83 ec 10             	sub    $0x10,%esp
  8023a8:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8023ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ae:	89 04 24             	mov    %eax,(%esp)
  8023b1:	e8 6e f2 ff ff       	call   801624 <fd2data>
  8023b6:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8023b8:	c7 44 24 04 0c 32 80 	movl   $0x80320c,0x4(%esp)
  8023bf:	00 
  8023c0:	89 34 24             	mov    %esi,(%esp)
  8023c3:	e8 9b e6 ff ff       	call   800a63 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8023c8:	8b 43 04             	mov    0x4(%ebx),%eax
  8023cb:	2b 03                	sub    (%ebx),%eax
  8023cd:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8023d3:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8023da:	00 00 00 
	stat->st_dev = &devpipe;
  8023dd:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  8023e4:	40 80 00 
	return 0;
}
  8023e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ec:	83 c4 10             	add    $0x10,%esp
  8023ef:	5b                   	pop    %ebx
  8023f0:	5e                   	pop    %esi
  8023f1:	5d                   	pop    %ebp
  8023f2:	c3                   	ret    

008023f3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8023f3:	55                   	push   %ebp
  8023f4:	89 e5                	mov    %esp,%ebp
  8023f6:	53                   	push   %ebx
  8023f7:	83 ec 14             	sub    $0x14,%esp
  8023fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8023fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802401:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802408:	e8 ef ea ff ff       	call   800efc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80240d:	89 1c 24             	mov    %ebx,(%esp)
  802410:	e8 0f f2 ff ff       	call   801624 <fd2data>
  802415:	89 44 24 04          	mov    %eax,0x4(%esp)
  802419:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802420:	e8 d7 ea ff ff       	call   800efc <sys_page_unmap>
}
  802425:	83 c4 14             	add    $0x14,%esp
  802428:	5b                   	pop    %ebx
  802429:	5d                   	pop    %ebp
  80242a:	c3                   	ret    

0080242b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80242b:	55                   	push   %ebp
  80242c:	89 e5                	mov    %esp,%ebp
  80242e:	57                   	push   %edi
  80242f:	56                   	push   %esi
  802430:	53                   	push   %ebx
  802431:	83 ec 2c             	sub    $0x2c,%esp
  802434:	89 c7                	mov    %eax,%edi
  802436:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802439:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80243e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802441:	89 3c 24             	mov    %edi,(%esp)
  802444:	e8 e3 04 00 00       	call   80292c <pageref>
  802449:	89 c6                	mov    %eax,%esi
  80244b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80244e:	89 04 24             	mov    %eax,(%esp)
  802451:	e8 d6 04 00 00       	call   80292c <pageref>
  802456:	39 c6                	cmp    %eax,%esi
  802458:	0f 94 c0             	sete   %al
  80245b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80245e:	8b 15 0c 50 80 00    	mov    0x80500c,%edx
  802464:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802467:	39 cb                	cmp    %ecx,%ebx
  802469:	75 08                	jne    802473 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80246b:	83 c4 2c             	add    $0x2c,%esp
  80246e:	5b                   	pop    %ebx
  80246f:	5e                   	pop    %esi
  802470:	5f                   	pop    %edi
  802471:	5d                   	pop    %ebp
  802472:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802473:	83 f8 01             	cmp    $0x1,%eax
  802476:	75 c1                	jne    802439 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802478:	8b 42 58             	mov    0x58(%edx),%eax
  80247b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802482:	00 
  802483:	89 44 24 08          	mov    %eax,0x8(%esp)
  802487:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80248b:	c7 04 24 13 32 80 00 	movl   $0x803213,(%esp)
  802492:	e8 21 e0 ff ff       	call   8004b8 <cprintf>
  802497:	eb a0                	jmp    802439 <_pipeisclosed+0xe>

00802499 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802499:	55                   	push   %ebp
  80249a:	89 e5                	mov    %esp,%ebp
  80249c:	57                   	push   %edi
  80249d:	56                   	push   %esi
  80249e:	53                   	push   %ebx
  80249f:	83 ec 1c             	sub    $0x1c,%esp
  8024a2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8024a5:	89 34 24             	mov    %esi,(%esp)
  8024a8:	e8 77 f1 ff ff       	call   801624 <fd2data>
  8024ad:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024af:	bf 00 00 00 00       	mov    $0x0,%edi
  8024b4:	eb 3c                	jmp    8024f2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8024b6:	89 da                	mov    %ebx,%edx
  8024b8:	89 f0                	mov    %esi,%eax
  8024ba:	e8 6c ff ff ff       	call   80242b <_pipeisclosed>
  8024bf:	85 c0                	test   %eax,%eax
  8024c1:	75 38                	jne    8024fb <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8024c3:	e8 6e e9 ff ff       	call   800e36 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8024c8:	8b 43 04             	mov    0x4(%ebx),%eax
  8024cb:	8b 13                	mov    (%ebx),%edx
  8024cd:	83 c2 20             	add    $0x20,%edx
  8024d0:	39 d0                	cmp    %edx,%eax
  8024d2:	73 e2                	jae    8024b6 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8024d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024d7:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  8024da:	89 c2                	mov    %eax,%edx
  8024dc:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  8024e2:	79 05                	jns    8024e9 <devpipe_write+0x50>
  8024e4:	4a                   	dec    %edx
  8024e5:	83 ca e0             	or     $0xffffffe0,%edx
  8024e8:	42                   	inc    %edx
  8024e9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8024ed:	40                   	inc    %eax
  8024ee:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8024f1:	47                   	inc    %edi
  8024f2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8024f5:	75 d1                	jne    8024c8 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8024f7:	89 f8                	mov    %edi,%eax
  8024f9:	eb 05                	jmp    802500 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8024fb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802500:	83 c4 1c             	add    $0x1c,%esp
  802503:	5b                   	pop    %ebx
  802504:	5e                   	pop    %esi
  802505:	5f                   	pop    %edi
  802506:	5d                   	pop    %ebp
  802507:	c3                   	ret    

00802508 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802508:	55                   	push   %ebp
  802509:	89 e5                	mov    %esp,%ebp
  80250b:	57                   	push   %edi
  80250c:	56                   	push   %esi
  80250d:	53                   	push   %ebx
  80250e:	83 ec 1c             	sub    $0x1c,%esp
  802511:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802514:	89 3c 24             	mov    %edi,(%esp)
  802517:	e8 08 f1 ff ff       	call   801624 <fd2data>
  80251c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80251e:	be 00 00 00 00       	mov    $0x0,%esi
  802523:	eb 3a                	jmp    80255f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802525:	85 f6                	test   %esi,%esi
  802527:	74 04                	je     80252d <devpipe_read+0x25>
				return i;
  802529:	89 f0                	mov    %esi,%eax
  80252b:	eb 40                	jmp    80256d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80252d:	89 da                	mov    %ebx,%edx
  80252f:	89 f8                	mov    %edi,%eax
  802531:	e8 f5 fe ff ff       	call   80242b <_pipeisclosed>
  802536:	85 c0                	test   %eax,%eax
  802538:	75 2e                	jne    802568 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80253a:	e8 f7 e8 ff ff       	call   800e36 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80253f:	8b 03                	mov    (%ebx),%eax
  802541:	3b 43 04             	cmp    0x4(%ebx),%eax
  802544:	74 df                	je     802525 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802546:	25 1f 00 00 80       	and    $0x8000001f,%eax
  80254b:	79 05                	jns    802552 <devpipe_read+0x4a>
  80254d:	48                   	dec    %eax
  80254e:	83 c8 e0             	or     $0xffffffe0,%eax
  802551:	40                   	inc    %eax
  802552:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802556:	8b 55 0c             	mov    0xc(%ebp),%edx
  802559:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80255c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80255e:	46                   	inc    %esi
  80255f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802562:	75 db                	jne    80253f <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802564:	89 f0                	mov    %esi,%eax
  802566:	eb 05                	jmp    80256d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802568:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80256d:	83 c4 1c             	add    $0x1c,%esp
  802570:	5b                   	pop    %ebx
  802571:	5e                   	pop    %esi
  802572:	5f                   	pop    %edi
  802573:	5d                   	pop    %ebp
  802574:	c3                   	ret    

00802575 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802575:	55                   	push   %ebp
  802576:	89 e5                	mov    %esp,%ebp
  802578:	57                   	push   %edi
  802579:	56                   	push   %esi
  80257a:	53                   	push   %ebx
  80257b:	83 ec 3c             	sub    $0x3c,%esp
  80257e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802581:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802584:	89 04 24             	mov    %eax,(%esp)
  802587:	e8 b3 f0 ff ff       	call   80163f <fd_alloc>
  80258c:	89 c3                	mov    %eax,%ebx
  80258e:	85 c0                	test   %eax,%eax
  802590:	0f 88 45 01 00 00    	js     8026db <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802596:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80259d:	00 
  80259e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025ac:	e8 a4 e8 ff ff       	call   800e55 <sys_page_alloc>
  8025b1:	89 c3                	mov    %eax,%ebx
  8025b3:	85 c0                	test   %eax,%eax
  8025b5:	0f 88 20 01 00 00    	js     8026db <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8025bb:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8025be:	89 04 24             	mov    %eax,(%esp)
  8025c1:	e8 79 f0 ff ff       	call   80163f <fd_alloc>
  8025c6:	89 c3                	mov    %eax,%ebx
  8025c8:	85 c0                	test   %eax,%eax
  8025ca:	0f 88 f8 00 00 00    	js     8026c8 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025d0:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8025d7:	00 
  8025d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8025db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025e6:	e8 6a e8 ff ff       	call   800e55 <sys_page_alloc>
  8025eb:	89 c3                	mov    %eax,%ebx
  8025ed:	85 c0                	test   %eax,%eax
  8025ef:	0f 88 d3 00 00 00    	js     8026c8 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8025f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8025f8:	89 04 24             	mov    %eax,(%esp)
  8025fb:	e8 24 f0 ff ff       	call   801624 <fd2data>
  802600:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802602:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802609:	00 
  80260a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80260e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802615:	e8 3b e8 ff ff       	call   800e55 <sys_page_alloc>
  80261a:	89 c3                	mov    %eax,%ebx
  80261c:	85 c0                	test   %eax,%eax
  80261e:	0f 88 91 00 00 00    	js     8026b5 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802624:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802627:	89 04 24             	mov    %eax,(%esp)
  80262a:	e8 f5 ef ff ff       	call   801624 <fd2data>
  80262f:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802636:	00 
  802637:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80263b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802642:	00 
  802643:	89 74 24 04          	mov    %esi,0x4(%esp)
  802647:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80264e:	e8 56 e8 ff ff       	call   800ea9 <sys_page_map>
  802653:	89 c3                	mov    %eax,%ebx
  802655:	85 c0                	test   %eax,%eax
  802657:	78 4c                	js     8026a5 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802659:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  80265f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802662:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802664:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802667:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80266e:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802674:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802677:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802679:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80267c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802683:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802686:	89 04 24             	mov    %eax,(%esp)
  802689:	e8 86 ef ff ff       	call   801614 <fd2num>
  80268e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802690:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802693:	89 04 24             	mov    %eax,(%esp)
  802696:	e8 79 ef ff ff       	call   801614 <fd2num>
  80269b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80269e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8026a3:	eb 36                	jmp    8026db <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  8026a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026b0:	e8 47 e8 ff ff       	call   800efc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  8026b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8026b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026c3:	e8 34 e8 ff ff       	call   800efc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  8026c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026d6:	e8 21 e8 ff ff       	call   800efc <sys_page_unmap>
    err:
	return r;
}
  8026db:	89 d8                	mov    %ebx,%eax
  8026dd:	83 c4 3c             	add    $0x3c,%esp
  8026e0:	5b                   	pop    %ebx
  8026e1:	5e                   	pop    %esi
  8026e2:	5f                   	pop    %edi
  8026e3:	5d                   	pop    %ebp
  8026e4:	c3                   	ret    

008026e5 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8026e5:	55                   	push   %ebp
  8026e6:	89 e5                	mov    %esp,%ebp
  8026e8:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8026eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8026f5:	89 04 24             	mov    %eax,(%esp)
  8026f8:	e8 95 ef ff ff       	call   801692 <fd_lookup>
  8026fd:	85 c0                	test   %eax,%eax
  8026ff:	78 15                	js     802716 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802701:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802704:	89 04 24             	mov    %eax,(%esp)
  802707:	e8 18 ef ff ff       	call   801624 <fd2data>
	return _pipeisclosed(fd, p);
  80270c:	89 c2                	mov    %eax,%edx
  80270e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802711:	e8 15 fd ff ff       	call   80242b <_pipeisclosed>
}
  802716:	c9                   	leave  
  802717:	c3                   	ret    

00802718 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802718:	55                   	push   %ebp
  802719:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80271b:	b8 00 00 00 00       	mov    $0x0,%eax
  802720:	5d                   	pop    %ebp
  802721:	c3                   	ret    

00802722 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802722:	55                   	push   %ebp
  802723:	89 e5                	mov    %esp,%ebp
  802725:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802728:	c7 44 24 04 2b 32 80 	movl   $0x80322b,0x4(%esp)
  80272f:	00 
  802730:	8b 45 0c             	mov    0xc(%ebp),%eax
  802733:	89 04 24             	mov    %eax,(%esp)
  802736:	e8 28 e3 ff ff       	call   800a63 <strcpy>
	return 0;
}
  80273b:	b8 00 00 00 00       	mov    $0x0,%eax
  802740:	c9                   	leave  
  802741:	c3                   	ret    

00802742 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802742:	55                   	push   %ebp
  802743:	89 e5                	mov    %esp,%ebp
  802745:	57                   	push   %edi
  802746:	56                   	push   %esi
  802747:	53                   	push   %ebx
  802748:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80274e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802753:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802759:	eb 30                	jmp    80278b <devcons_write+0x49>
		m = n - tot;
  80275b:	8b 75 10             	mov    0x10(%ebp),%esi
  80275e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802760:	83 fe 7f             	cmp    $0x7f,%esi
  802763:	76 05                	jbe    80276a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802765:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80276a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80276e:	03 45 0c             	add    0xc(%ebp),%eax
  802771:	89 44 24 04          	mov    %eax,0x4(%esp)
  802775:	89 3c 24             	mov    %edi,(%esp)
  802778:	e8 5f e4 ff ff       	call   800bdc <memmove>
		sys_cputs(buf, m);
  80277d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802781:	89 3c 24             	mov    %edi,(%esp)
  802784:	e8 ff e5 ff ff       	call   800d88 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802789:	01 f3                	add    %esi,%ebx
  80278b:	89 d8                	mov    %ebx,%eax
  80278d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802790:	72 c9                	jb     80275b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802792:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802798:	5b                   	pop    %ebx
  802799:	5e                   	pop    %esi
  80279a:	5f                   	pop    %edi
  80279b:	5d                   	pop    %ebp
  80279c:	c3                   	ret    

0080279d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80279d:	55                   	push   %ebp
  80279e:	89 e5                	mov    %esp,%ebp
  8027a0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  8027a3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8027a7:	75 07                	jne    8027b0 <devcons_read+0x13>
  8027a9:	eb 25                	jmp    8027d0 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8027ab:	e8 86 e6 ff ff       	call   800e36 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8027b0:	e8 f1 e5 ff ff       	call   800da6 <sys_cgetc>
  8027b5:	85 c0                	test   %eax,%eax
  8027b7:	74 f2                	je     8027ab <devcons_read+0xe>
  8027b9:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8027bb:	85 c0                	test   %eax,%eax
  8027bd:	78 1d                	js     8027dc <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8027bf:	83 f8 04             	cmp    $0x4,%eax
  8027c2:	74 13                	je     8027d7 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8027c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027c7:	88 10                	mov    %dl,(%eax)
	return 1;
  8027c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8027ce:	eb 0c                	jmp    8027dc <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8027d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8027d5:	eb 05                	jmp    8027dc <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8027d7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8027dc:	c9                   	leave  
  8027dd:	c3                   	ret    

008027de <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8027de:	55                   	push   %ebp
  8027df:	89 e5                	mov    %esp,%ebp
  8027e1:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8027e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8027e7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8027ea:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8027f1:	00 
  8027f2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8027f5:	89 04 24             	mov    %eax,(%esp)
  8027f8:	e8 8b e5 ff ff       	call   800d88 <sys_cputs>
}
  8027fd:	c9                   	leave  
  8027fe:	c3                   	ret    

008027ff <getchar>:

int
getchar(void)
{
  8027ff:	55                   	push   %ebp
  802800:	89 e5                	mov    %esp,%ebp
  802802:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802805:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  80280c:	00 
  80280d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802810:	89 44 24 04          	mov    %eax,0x4(%esp)
  802814:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80281b:	e8 10 f1 ff ff       	call   801930 <read>
	if (r < 0)
  802820:	85 c0                	test   %eax,%eax
  802822:	78 0f                	js     802833 <getchar+0x34>
		return r;
	if (r < 1)
  802824:	85 c0                	test   %eax,%eax
  802826:	7e 06                	jle    80282e <getchar+0x2f>
		return -E_EOF;
	return c;
  802828:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80282c:	eb 05                	jmp    802833 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80282e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802833:	c9                   	leave  
  802834:	c3                   	ret    

00802835 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802835:	55                   	push   %ebp
  802836:	89 e5                	mov    %esp,%ebp
  802838:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80283b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80283e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802842:	8b 45 08             	mov    0x8(%ebp),%eax
  802845:	89 04 24             	mov    %eax,(%esp)
  802848:	e8 45 ee ff ff       	call   801692 <fd_lookup>
  80284d:	85 c0                	test   %eax,%eax
  80284f:	78 11                	js     802862 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802851:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802854:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80285a:	39 10                	cmp    %edx,(%eax)
  80285c:	0f 94 c0             	sete   %al
  80285f:	0f b6 c0             	movzbl %al,%eax
}
  802862:	c9                   	leave  
  802863:	c3                   	ret    

00802864 <opencons>:

int
opencons(void)
{
  802864:	55                   	push   %ebp
  802865:	89 e5                	mov    %esp,%ebp
  802867:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80286a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80286d:	89 04 24             	mov    %eax,(%esp)
  802870:	e8 ca ed ff ff       	call   80163f <fd_alloc>
  802875:	85 c0                	test   %eax,%eax
  802877:	78 3c                	js     8028b5 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802879:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802880:	00 
  802881:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802884:	89 44 24 04          	mov    %eax,0x4(%esp)
  802888:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80288f:	e8 c1 e5 ff ff       	call   800e55 <sys_page_alloc>
  802894:	85 c0                	test   %eax,%eax
  802896:	78 1d                	js     8028b5 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802898:	8b 15 58 40 80 00    	mov    0x804058,%edx
  80289e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028a1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8028a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028a6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8028ad:	89 04 24             	mov    %eax,(%esp)
  8028b0:	e8 5f ed ff ff       	call   801614 <fd2num>
}
  8028b5:	c9                   	leave  
  8028b6:	c3                   	ret    
	...

008028b8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8028b8:	55                   	push   %ebp
  8028b9:	89 e5                	mov    %esp,%ebp
  8028bb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8028be:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8028c5:	75 30                	jne    8028f7 <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  8028c7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8028ce:	00 
  8028cf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8028d6:	ee 
  8028d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028de:	e8 72 e5 ff ff       	call   800e55 <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  8028e3:	c7 44 24 04 04 29 80 	movl   $0x802904,0x4(%esp)
  8028ea:	00 
  8028eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028f2:	e8 fe e6 ff ff       	call   800ff5 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8028f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8028fa:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8028ff:	c9                   	leave  
  802900:	c3                   	ret    
  802901:	00 00                	add    %al,(%eax)
	...

00802904 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802904:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802905:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  80290a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80290c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  80290f:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  802913:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  802917:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  80291a:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  80291c:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  802920:	83 c4 08             	add    $0x8,%esp
	popal
  802923:	61                   	popa   

	addl $4,%esp 
  802924:	83 c4 04             	add    $0x4,%esp
	popfl
  802927:	9d                   	popf   

	popl %esp
  802928:	5c                   	pop    %esp

	ret
  802929:	c3                   	ret    
	...

0080292c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80292c:	55                   	push   %ebp
  80292d:	89 e5                	mov    %esp,%ebp
  80292f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802932:	89 c2                	mov    %eax,%edx
  802934:	c1 ea 16             	shr    $0x16,%edx
  802937:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80293e:	f6 c2 01             	test   $0x1,%dl
  802941:	74 1e                	je     802961 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802943:	c1 e8 0c             	shr    $0xc,%eax
  802946:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80294d:	a8 01                	test   $0x1,%al
  80294f:	74 17                	je     802968 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802951:	c1 e8 0c             	shr    $0xc,%eax
  802954:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80295b:	ef 
  80295c:	0f b7 c0             	movzwl %ax,%eax
  80295f:	eb 0c                	jmp    80296d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802961:	b8 00 00 00 00       	mov    $0x0,%eax
  802966:	eb 05                	jmp    80296d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802968:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80296d:	5d                   	pop    %ebp
  80296e:	c3                   	ret    
	...

00802970 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802970:	55                   	push   %ebp
  802971:	57                   	push   %edi
  802972:	56                   	push   %esi
  802973:	83 ec 10             	sub    $0x10,%esp
  802976:	8b 74 24 20          	mov    0x20(%esp),%esi
  80297a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80297e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802982:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802986:	89 cd                	mov    %ecx,%ebp
  802988:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80298c:	85 c0                	test   %eax,%eax
  80298e:	75 2c                	jne    8029bc <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802990:	39 f9                	cmp    %edi,%ecx
  802992:	77 68                	ja     8029fc <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802994:	85 c9                	test   %ecx,%ecx
  802996:	75 0b                	jne    8029a3 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802998:	b8 01 00 00 00       	mov    $0x1,%eax
  80299d:	31 d2                	xor    %edx,%edx
  80299f:	f7 f1                	div    %ecx
  8029a1:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  8029a3:	31 d2                	xor    %edx,%edx
  8029a5:	89 f8                	mov    %edi,%eax
  8029a7:	f7 f1                	div    %ecx
  8029a9:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8029ab:	89 f0                	mov    %esi,%eax
  8029ad:	f7 f1                	div    %ecx
  8029af:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029b1:	89 f0                	mov    %esi,%eax
  8029b3:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029b5:	83 c4 10             	add    $0x10,%esp
  8029b8:	5e                   	pop    %esi
  8029b9:	5f                   	pop    %edi
  8029ba:	5d                   	pop    %ebp
  8029bb:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8029bc:	39 f8                	cmp    %edi,%eax
  8029be:	77 2c                	ja     8029ec <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8029c0:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8029c3:	83 f6 1f             	xor    $0x1f,%esi
  8029c6:	75 4c                	jne    802a14 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8029c8:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8029ca:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8029cf:	72 0a                	jb     8029db <__udivdi3+0x6b>
  8029d1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8029d5:	0f 87 ad 00 00 00    	ja     802a88 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8029db:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029e0:	89 f0                	mov    %esi,%eax
  8029e2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029e4:	83 c4 10             	add    $0x10,%esp
  8029e7:	5e                   	pop    %esi
  8029e8:	5f                   	pop    %edi
  8029e9:	5d                   	pop    %ebp
  8029ea:	c3                   	ret    
  8029eb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8029ec:	31 ff                	xor    %edi,%edi
  8029ee:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029f0:	89 f0                	mov    %esi,%eax
  8029f2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029f4:	83 c4 10             	add    $0x10,%esp
  8029f7:	5e                   	pop    %esi
  8029f8:	5f                   	pop    %edi
  8029f9:	5d                   	pop    %ebp
  8029fa:	c3                   	ret    
  8029fb:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8029fc:	89 fa                	mov    %edi,%edx
  8029fe:	89 f0                	mov    %esi,%eax
  802a00:	f7 f1                	div    %ecx
  802a02:	89 c6                	mov    %eax,%esi
  802a04:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802a06:	89 f0                	mov    %esi,%eax
  802a08:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802a0a:	83 c4 10             	add    $0x10,%esp
  802a0d:	5e                   	pop    %esi
  802a0e:	5f                   	pop    %edi
  802a0f:	5d                   	pop    %ebp
  802a10:	c3                   	ret    
  802a11:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802a14:	89 f1                	mov    %esi,%ecx
  802a16:	d3 e0                	shl    %cl,%eax
  802a18:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802a1c:	b8 20 00 00 00       	mov    $0x20,%eax
  802a21:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802a23:	89 ea                	mov    %ebp,%edx
  802a25:	88 c1                	mov    %al,%cl
  802a27:	d3 ea                	shr    %cl,%edx
  802a29:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802a2d:	09 ca                	or     %ecx,%edx
  802a2f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802a33:	89 f1                	mov    %esi,%ecx
  802a35:	d3 e5                	shl    %cl,%ebp
  802a37:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802a3b:	89 fd                	mov    %edi,%ebp
  802a3d:	88 c1                	mov    %al,%cl
  802a3f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802a41:	89 fa                	mov    %edi,%edx
  802a43:	89 f1                	mov    %esi,%ecx
  802a45:	d3 e2                	shl    %cl,%edx
  802a47:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802a4b:	88 c1                	mov    %al,%cl
  802a4d:	d3 ef                	shr    %cl,%edi
  802a4f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802a51:	89 f8                	mov    %edi,%eax
  802a53:	89 ea                	mov    %ebp,%edx
  802a55:	f7 74 24 08          	divl   0x8(%esp)
  802a59:	89 d1                	mov    %edx,%ecx
  802a5b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802a5d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a61:	39 d1                	cmp    %edx,%ecx
  802a63:	72 17                	jb     802a7c <__udivdi3+0x10c>
  802a65:	74 09                	je     802a70 <__udivdi3+0x100>
  802a67:	89 fe                	mov    %edi,%esi
  802a69:	31 ff                	xor    %edi,%edi
  802a6b:	e9 41 ff ff ff       	jmp    8029b1 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802a70:	8b 54 24 04          	mov    0x4(%esp),%edx
  802a74:	89 f1                	mov    %esi,%ecx
  802a76:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a78:	39 c2                	cmp    %eax,%edx
  802a7a:	73 eb                	jae    802a67 <__udivdi3+0xf7>
		{
		  q0--;
  802a7c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802a7f:	31 ff                	xor    %edi,%edi
  802a81:	e9 2b ff ff ff       	jmp    8029b1 <__udivdi3+0x41>
  802a86:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a88:	31 f6                	xor    %esi,%esi
  802a8a:	e9 22 ff ff ff       	jmp    8029b1 <__udivdi3+0x41>
	...

00802a90 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802a90:	55                   	push   %ebp
  802a91:	57                   	push   %edi
  802a92:	56                   	push   %esi
  802a93:	83 ec 20             	sub    $0x20,%esp
  802a96:	8b 44 24 30          	mov    0x30(%esp),%eax
  802a9a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802a9e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802aa2:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802aa6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802aaa:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802aae:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802ab0:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802ab2:	85 ed                	test   %ebp,%ebp
  802ab4:	75 16                	jne    802acc <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802ab6:	39 f1                	cmp    %esi,%ecx
  802ab8:	0f 86 a6 00 00 00    	jbe    802b64 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802abe:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802ac0:	89 d0                	mov    %edx,%eax
  802ac2:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802ac4:	83 c4 20             	add    $0x20,%esp
  802ac7:	5e                   	pop    %esi
  802ac8:	5f                   	pop    %edi
  802ac9:	5d                   	pop    %ebp
  802aca:	c3                   	ret    
  802acb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802acc:	39 f5                	cmp    %esi,%ebp
  802ace:	0f 87 ac 00 00 00    	ja     802b80 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802ad4:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802ad7:	83 f0 1f             	xor    $0x1f,%eax
  802ada:	89 44 24 10          	mov    %eax,0x10(%esp)
  802ade:	0f 84 a8 00 00 00    	je     802b8c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802ae4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ae8:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802aea:	bf 20 00 00 00       	mov    $0x20,%edi
  802aef:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802af3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802af7:	89 f9                	mov    %edi,%ecx
  802af9:	d3 e8                	shr    %cl,%eax
  802afb:	09 e8                	or     %ebp,%eax
  802afd:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802b01:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802b05:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b09:	d3 e0                	shl    %cl,%eax
  802b0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802b0f:	89 f2                	mov    %esi,%edx
  802b11:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802b13:	8b 44 24 14          	mov    0x14(%esp),%eax
  802b17:	d3 e0                	shl    %cl,%eax
  802b19:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802b1d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802b21:	89 f9                	mov    %edi,%ecx
  802b23:	d3 e8                	shr    %cl,%eax
  802b25:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802b27:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802b29:	89 f2                	mov    %esi,%edx
  802b2b:	f7 74 24 18          	divl   0x18(%esp)
  802b2f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802b31:	f7 64 24 0c          	mull   0xc(%esp)
  802b35:	89 c5                	mov    %eax,%ebp
  802b37:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802b39:	39 d6                	cmp    %edx,%esi
  802b3b:	72 67                	jb     802ba4 <__umoddi3+0x114>
  802b3d:	74 75                	je     802bb4 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802b3f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802b43:	29 e8                	sub    %ebp,%eax
  802b45:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802b47:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b4b:	d3 e8                	shr    %cl,%eax
  802b4d:	89 f2                	mov    %esi,%edx
  802b4f:	89 f9                	mov    %edi,%ecx
  802b51:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802b53:	09 d0                	or     %edx,%eax
  802b55:	89 f2                	mov    %esi,%edx
  802b57:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b5b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b5d:	83 c4 20             	add    $0x20,%esp
  802b60:	5e                   	pop    %esi
  802b61:	5f                   	pop    %edi
  802b62:	5d                   	pop    %ebp
  802b63:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802b64:	85 c9                	test   %ecx,%ecx
  802b66:	75 0b                	jne    802b73 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802b68:	b8 01 00 00 00       	mov    $0x1,%eax
  802b6d:	31 d2                	xor    %edx,%edx
  802b6f:	f7 f1                	div    %ecx
  802b71:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802b73:	89 f0                	mov    %esi,%eax
  802b75:	31 d2                	xor    %edx,%edx
  802b77:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802b79:	89 f8                	mov    %edi,%eax
  802b7b:	e9 3e ff ff ff       	jmp    802abe <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802b80:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b82:	83 c4 20             	add    $0x20,%esp
  802b85:	5e                   	pop    %esi
  802b86:	5f                   	pop    %edi
  802b87:	5d                   	pop    %ebp
  802b88:	c3                   	ret    
  802b89:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802b8c:	39 f5                	cmp    %esi,%ebp
  802b8e:	72 04                	jb     802b94 <__umoddi3+0x104>
  802b90:	39 f9                	cmp    %edi,%ecx
  802b92:	77 06                	ja     802b9a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802b94:	89 f2                	mov    %esi,%edx
  802b96:	29 cf                	sub    %ecx,%edi
  802b98:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802b9a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b9c:	83 c4 20             	add    $0x20,%esp
  802b9f:	5e                   	pop    %esi
  802ba0:	5f                   	pop    %edi
  802ba1:	5d                   	pop    %ebp
  802ba2:	c3                   	ret    
  802ba3:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802ba4:	89 d1                	mov    %edx,%ecx
  802ba6:	89 c5                	mov    %eax,%ebp
  802ba8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802bac:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802bb0:	eb 8d                	jmp    802b3f <__umoddi3+0xaf>
  802bb2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802bb4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802bb8:	72 ea                	jb     802ba4 <__umoddi3+0x114>
  802bba:	89 f1                	mov    %esi,%ecx
  802bbc:	eb 81                	jmp    802b3f <__umoddi3+0xaf>
