
obj/net/testinput:     file format elf32-i386


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
  80002c:	e8 43 09 00 00       	call   800974 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	envid_t ns_envid = sys_getenvid();
  800040:	e8 f6 13 00 00       	call   80143b <sys_getenvid>
  800045:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800047:	c7 05 00 40 80 00 00 	movl   $0x803200,0x804000
  80004e:	32 80 00 

	output_envid = fork();
  800051:	e8 c5 17 00 00       	call   80181b <fork>
  800056:	a3 00 50 80 00       	mov    %eax,0x805000
	if (output_envid < 0)
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 1c                	jns    80007b <umain+0x47>
		panic("error forking");
  80005f:	c7 44 24 08 0a 32 80 	movl   $0x80320a,0x8(%esp)
  800066:	00 
  800067:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80006e:	00 
  80006f:	c7 04 24 18 32 80 00 	movl   $0x803218,(%esp)
  800076:	e8 69 09 00 00       	call   8009e4 <_panic>
	else if (output_envid == 0) {
  80007b:	85 c0                	test   %eax,%eax
  80007d:	75 0d                	jne    80008c <umain+0x58>
		output(ns_envid);
  80007f:	89 1c 24             	mov    %ebx,(%esp)
  800082:	e8 41 05 00 00       	call   8005c8 <output>
		return;
  800087:	e9 af 03 00 00       	jmp    80043b <umain+0x407>
	}

	input_envid = fork();
  80008c:	e8 8a 17 00 00       	call   80181b <fork>
  800091:	a3 04 50 80 00       	mov    %eax,0x805004
	if (input_envid < 0)
  800096:	85 c0                	test   %eax,%eax
  800098:	79 1c                	jns    8000b6 <umain+0x82>
		panic("error forking");
  80009a:	c7 44 24 08 0a 32 80 	movl   $0x80320a,0x8(%esp)
  8000a1:	00 
  8000a2:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8000a9:	00 
  8000aa:	c7 04 24 18 32 80 00 	movl   $0x803218,(%esp)
  8000b1:	e8 2e 09 00 00       	call   8009e4 <_panic>
	else if (input_envid == 0) {
  8000b6:	85 c0                	test   %eax,%eax
  8000b8:	75 0d                	jne    8000c7 <umain+0x93>
		input(ns_envid);
  8000ba:	89 1c 24             	mov    %ebx,(%esp)
  8000bd:	e8 42 04 00 00       	call   800504 <input>
		return;
  8000c2:	e9 74 03 00 00       	jmp    80043b <umain+0x407>
	}

	cprintf("Sending ARP announcement...\n");
  8000c7:	c7 04 24 28 32 80 00 	movl   $0x803228,(%esp)
  8000ce:	e8 09 0a 00 00       	call   800adc <cprintf>
	// with ARP requests.  Ideally, we would use gratuitous ARP
	// for this, but QEMU's ARP implementation is dumb and only
	// listens for very specific ARP requests, such as requests
	// for the gateway IP.

	uint8_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
  8000d3:	c6 45 90 52          	movb   $0x52,-0x70(%ebp)
  8000d7:	c6 45 91 54          	movb   $0x54,-0x6f(%ebp)
  8000db:	c6 45 92 00          	movb   $0x0,-0x6e(%ebp)
  8000df:	c6 45 93 12          	movb   $0x12,-0x6d(%ebp)
  8000e3:	c6 45 94 34          	movb   $0x34,-0x6c(%ebp)
  8000e7:	c6 45 95 56          	movb   $0x56,-0x6b(%ebp)
	uint32_t myip = inet_addr(IP);
  8000eb:	c7 04 24 45 32 80 00 	movl   $0x803245,(%esp)
  8000f2:	e8 40 08 00 00       	call   800937 <inet_addr>
  8000f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  8000fa:	c7 04 24 4f 32 80 00 	movl   $0x80324f,(%esp)
  800101:	e8 31 08 00 00       	call   800937 <inet_addr>
  800106:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;

	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800109:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800110:	00 
  800111:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  800118:	0f 
  800119:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800120:	e8 54 13 00 00       	call   801479 <sys_page_alloc>
  800125:	85 c0                	test   %eax,%eax
  800127:	79 20                	jns    800149 <umain+0x115>
		panic("sys_page_map: %e", r);
  800129:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012d:	c7 44 24 08 58 32 80 	movl   $0x803258,0x8(%esp)
  800134:	00 
  800135:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80013c:	00 
  80013d:	c7 04 24 18 32 80 00 	movl   $0x803218,(%esp)
  800144:	e8 9b 08 00 00       	call   8009e4 <_panic>

	struct etharp_hdr *arp = (struct etharp_hdr*)pkt->jp_data;
	pkt->jp_len = sizeof(*arp);
  800149:	c7 05 00 b0 fe 0f 2a 	movl   $0x2a,0xffeb000
  800150:	00 00 00 

	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  800153:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  80015a:	00 
  80015b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800162:	00 
  800163:	c7 04 24 04 b0 fe 0f 	movl   $0xffeb004,(%esp)
  80016a:	e8 47 10 00 00       	call   8011b6 <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  80016f:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800176:	00 
  800177:	8d 5d 90             	lea    -0x70(%ebp),%ebx
  80017a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80017e:	c7 04 24 0a b0 fe 0f 	movl   $0xffeb00a,(%esp)
  800185:	e8 e0 10 00 00       	call   80126a <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  80018a:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  800191:	e8 53 05 00 00       	call   8006e9 <htons>
  800196:	66 a3 10 b0 fe 0f    	mov    %ax,0xffeb010
	arp->hwtype = htons(1); // Ethernet
  80019c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001a3:	e8 41 05 00 00       	call   8006e9 <htons>
  8001a8:	66 a3 12 b0 fe 0f    	mov    %ax,0xffeb012
	arp->proto = htons(ETHTYPE_IP);
  8001ae:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  8001b5:	e8 2f 05 00 00       	call   8006e9 <htons>
  8001ba:	66 a3 14 b0 fe 0f    	mov    %ax,0xffeb014
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  8001c0:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  8001c7:	e8 1d 05 00 00       	call   8006e9 <htons>
  8001cc:	66 a3 16 b0 fe 0f    	mov    %ax,0xffeb016
	arp->opcode = htons(ARP_REQUEST);
  8001d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001d9:	e8 0b 05 00 00       	call   8006e9 <htons>
  8001de:	66 a3 18 b0 fe 0f    	mov    %ax,0xffeb018
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  8001e4:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  8001eb:	00 
  8001ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001f0:	c7 04 24 1a b0 fe 0f 	movl   $0xffeb01a,(%esp)
  8001f7:	e8 6e 10 00 00       	call   80126a <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  8001fc:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800203:	00 
  800204:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800207:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020b:	c7 04 24 20 b0 fe 0f 	movl   $0xffeb020,(%esp)
  800212:	e8 53 10 00 00       	call   80126a <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  800217:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  80021e:	00 
  80021f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800226:	00 
  800227:	c7 04 24 24 b0 fe 0f 	movl   $0xffeb024,(%esp)
  80022e:	e8 83 0f 00 00       	call   8011b6 <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  800233:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80023a:	00 
  80023b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80023e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800242:	c7 04 24 2a b0 fe 0f 	movl   $0xffeb02a,(%esp)
  800249:	e8 1c 10 00 00       	call   80126a <memcpy>

	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  80024e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800255:	00 
  800256:	c7 44 24 08 00 b0 fe 	movl   $0xffeb000,0x8(%esp)
  80025d:	0f 
  80025e:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800265:	00 
  800266:	a1 00 50 80 00       	mov    0x805000,%eax
  80026b:	89 04 24             	mov    %eax,(%esp)
  80026e:	e8 fd 18 00 00       	call   801b70 <ipc_send>
	sys_page_unmap(0, pkt);
  800273:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  80027a:	0f 
  80027b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800282:	e8 99 12 00 00       	call   801520 <sys_page_unmap>

void
umain(int argc, char **argv)
{
	envid_t ns_envid = sys_getenvid();
	int i, r, first = 1;
  800287:	c7 85 78 ff ff ff 01 	movl   $0x1,-0x88(%ebp)
  80028e:	00 00 00 
	announce();

	while (1) {
		envid_t whom;
		int perm;
		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  800291:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800294:	89 45 80             	mov    %eax,-0x80(%ebp)
  800297:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80029a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80029e:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  8002a5:	0f 
  8002a6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8002a9:	89 04 24             	mov    %eax,(%esp)
  8002ac:	e8 4f 18 00 00       	call   801b00 <ipc_recv>
		if (req < 0)
  8002b1:	85 c0                	test   %eax,%eax
  8002b3:	79 20                	jns    8002d5 <umain+0x2a1>
			panic("ipc_recv: %e", req);
  8002b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b9:	c7 44 24 08 69 32 80 	movl   $0x803269,0x8(%esp)
  8002c0:	00 
  8002c1:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
  8002c8:	00 
  8002c9:	c7 04 24 18 32 80 00 	movl   $0x803218,(%esp)
  8002d0:	e8 0f 07 00 00       	call   8009e4 <_panic>
		if (whom != input_envid)
  8002d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002d8:	3b 15 04 50 80 00    	cmp    0x805004,%edx
  8002de:	74 20                	je     800300 <umain+0x2cc>
			panic("IPC from unexpected environment %08x", whom);
  8002e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002e4:	c7 44 24 08 c0 32 80 	movl   $0x8032c0,0x8(%esp)
  8002eb:	00 
  8002ec:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
  8002f3:	00 
  8002f4:	c7 04 24 18 32 80 00 	movl   $0x803218,(%esp)
  8002fb:	e8 e4 06 00 00       	call   8009e4 <_panic>
		if (req != NSREQ_INPUT)
  800300:	83 f8 0a             	cmp    $0xa,%eax
  800303:	74 20                	je     800325 <umain+0x2f1>
			panic("Unexpected IPC %d", req);
  800305:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800309:	c7 44 24 08 76 32 80 	movl   $0x803276,0x8(%esp)
  800310:	00 
  800311:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  800318:	00 
  800319:	c7 04 24 18 32 80 00 	movl   $0x803218,(%esp)
  800320:	e8 bf 06 00 00       	call   8009e4 <_panic>
		// cprintf("hello world\n");
		hexdump("input: ", pkt->jp_data, pkt->jp_len);
  800325:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  80032a:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
hexdump(const char *prefix, const void *data, int len)
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
  800330:	be 00 00 00 00       	mov    $0x0,%esi
	for (i = 0; i < len; i++) {
  800335:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i % 16 == 0)
			out = buf + snprintf(buf, end - buf,
  80033a:	8d 45 90             	lea    -0x70(%ebp),%eax
  80033d:	89 45 84             	mov    %eax,-0x7c(%ebp)
  800340:	e9 b6 00 00 00       	jmp    8003fb <umain+0x3c7>
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
		if (i % 16 == 0)
  800345:	89 df                	mov    %ebx,%edi
  800347:	f6 c3 0f             	test   $0xf,%bl
  80034a:	75 2c                	jne    800378 <umain+0x344>
			out = buf + snprintf(buf, end - buf,
  80034c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800350:	c7 44 24 0c 88 32 80 	movl   $0x803288,0xc(%esp)
  800357:	00 
  800358:	c7 44 24 08 90 32 80 	movl   $0x803290,0x8(%esp)
  80035f:	00 
  800360:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  800367:	00 
  800368:	8d 45 90             	lea    -0x70(%ebp),%eax
  80036b:	89 04 24             	mov    %eax,(%esp)
  80036e:	e8 b6 0c 00 00       	call   801029 <snprintf>
  800373:	8d 75 90             	lea    -0x70(%ebp),%esi
  800376:	01 c6                	add    %eax,%esi
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  800378:	0f b6 87 04 b0 fe 0f 	movzbl 0xffeb004(%edi),%eax
  80037f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800383:	c7 44 24 08 9a 32 80 	movl   $0x80329a,0x8(%esp)
  80038a:	00 
  80038b:	8b 45 80             	mov    -0x80(%ebp),%eax
  80038e:	29 f0                	sub    %esi,%eax
  800390:	89 44 24 04          	mov    %eax,0x4(%esp)
  800394:	89 34 24             	mov    %esi,(%esp)
  800397:	e8 8d 0c 00 00       	call   801029 <snprintf>
  80039c:	01 c6                	add    %eax,%esi
		if (i % 16 == 15 || i == len - 1)
  80039e:	89 d8                	mov    %ebx,%eax
  8003a0:	25 0f 00 00 80       	and    $0x8000000f,%eax
  8003a5:	79 05                	jns    8003ac <umain+0x378>
  8003a7:	48                   	dec    %eax
  8003a8:	83 c8 f0             	or     $0xfffffff0,%eax
  8003ab:	40                   	inc    %eax
  8003ac:	89 c7                	mov    %eax,%edi
  8003ae:	83 f8 0f             	cmp    $0xf,%eax
  8003b1:	74 0b                	je     8003be <umain+0x38a>
  8003b3:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  8003b9:	48                   	dec    %eax
  8003ba:	39 c3                	cmp    %eax,%ebx
  8003bc:	75 1c                	jne    8003da <umain+0x3a6>
			cprintf("%.*s\n", out - buf, buf);
  8003be:	8d 45 90             	lea    -0x70(%ebp),%eax
  8003c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c5:	89 f0                	mov    %esi,%eax
  8003c7:	2b 45 84             	sub    -0x7c(%ebp),%eax
  8003ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ce:	c7 04 24 9f 32 80 00 	movl   $0x80329f,(%esp)
  8003d5:	e8 02 07 00 00       	call   800adc <cprintf>
		if (i % 2 == 1)
  8003da:	89 d8                	mov    %ebx,%eax
  8003dc:	25 01 00 00 80       	and    $0x80000001,%eax
  8003e1:	79 05                	jns    8003e8 <umain+0x3b4>
  8003e3:	48                   	dec    %eax
  8003e4:	83 c8 fe             	or     $0xfffffffe,%eax
  8003e7:	40                   	inc    %eax
  8003e8:	83 f8 01             	cmp    $0x1,%eax
  8003eb:	75 04                	jne    8003f1 <umain+0x3bd>
			*(out++) = ' ';
  8003ed:	c6 06 20             	movb   $0x20,(%esi)
  8003f0:	46                   	inc    %esi
		if (i % 16 == 7)
  8003f1:	83 ff 07             	cmp    $0x7,%edi
  8003f4:	75 04                	jne    8003fa <umain+0x3c6>
			*(out++) = ' ';
  8003f6:	c6 06 20             	movb   $0x20,(%esi)
  8003f9:	46                   	inc    %esi
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  8003fa:	43                   	inc    %ebx
  8003fb:	39 9d 7c ff ff ff    	cmp    %ebx,-0x84(%ebp)
  800401:	0f 8f 3e ff ff ff    	jg     800345 <umain+0x311>
			panic("IPC from unexpected environment %08x", whom);
		if (req != NSREQ_INPUT)
			panic("Unexpected IPC %d", req);
		// cprintf("hello world\n");
		hexdump("input: ", pkt->jp_data, pkt->jp_len);
		cprintf("\n");
  800407:	c7 04 24 bb 32 80 00 	movl   $0x8032bb,(%esp)
  80040e:	e8 c9 06 00 00       	call   800adc <cprintf>

		// Only indicate that we're waiting for packets once
		// we've received the ARP reply
		if (first)
  800413:	83 bd 78 ff ff ff 00 	cmpl   $0x0,-0x88(%ebp)
  80041a:	0f 84 77 fe ff ff    	je     800297 <umain+0x263>
			cprintf("Waiting for packets...\n");
  800420:	c7 04 24 a5 32 80 00 	movl   $0x8032a5,(%esp)
  800427:	e8 b0 06 00 00       	call   800adc <cprintf>
		first = 0;
  80042c:	c7 85 78 ff ff ff 00 	movl   $0x0,-0x88(%ebp)
  800433:	00 00 00 
  800436:	e9 5c fe ff ff       	jmp    800297 <umain+0x263>
	}
}
  80043b:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  800441:	5b                   	pop    %ebx
  800442:	5e                   	pop    %esi
  800443:	5f                   	pop    %edi
  800444:	5d                   	pop    %ebp
  800445:	c3                   	ret    
	...

00800448 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800448:	55                   	push   %ebp
  800449:	89 e5                	mov    %esp,%ebp
  80044b:	57                   	push   %edi
  80044c:	56                   	push   %esi
  80044d:	53                   	push   %ebx
  80044e:	83 ec 2c             	sub    $0x2c,%esp
  800451:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  800454:	e8 88 12 00 00       	call   8016e1 <sys_time_msec>
  800459:	89 c3                	mov    %eax,%ebx
  80045b:	03 5d 0c             	add    0xc(%ebp),%ebx

	binaryname = "ns_timer";
  80045e:	c7 05 00 40 80 00 e5 	movl   $0x8032e5,0x804000
  800465:	32 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800468:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80046b:	eb 05                	jmp    800472 <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  80046d:	e8 e8 0f 00 00       	call   80145a <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  800472:	e8 6a 12 00 00       	call   8016e1 <sys_time_msec>
  800477:	39 c3                	cmp    %eax,%ebx
  800479:	76 06                	jbe    800481 <timer+0x39>
  80047b:	85 c0                	test   %eax,%eax
  80047d:	79 ee                	jns    80046d <timer+0x25>
  80047f:	eb 04                	jmp    800485 <timer+0x3d>
			sys_yield();
		}
		if (r < 0)
  800481:	85 c0                	test   %eax,%eax
  800483:	79 20                	jns    8004a5 <timer+0x5d>
			panic("sys_time_msec: %e", r);
  800485:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800489:	c7 44 24 08 ee 32 80 	movl   $0x8032ee,0x8(%esp)
  800490:	00 
  800491:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800498:	00 
  800499:	c7 04 24 00 33 80 00 	movl   $0x803300,(%esp)
  8004a0:	e8 3f 05 00 00       	call   8009e4 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8004a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ac:	00 
  8004ad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004b4:	00 
  8004b5:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  8004bc:	00 
  8004bd:	89 3c 24             	mov    %edi,(%esp)
  8004c0:	e8 ab 16 00 00       	call   801b70 <ipc_send>

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8004c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004cc:	00 
  8004cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004d4:	00 
  8004d5:	89 34 24             	mov    %esi,(%esp)
  8004d8:	e8 23 16 00 00       	call   801b00 <ipc_recv>
  8004dd:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  8004df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004e2:	39 c7                	cmp    %eax,%edi
  8004e4:	74 12                	je     8004f8 <timer+0xb0>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  8004e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ea:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  8004f1:	e8 e6 05 00 00       	call   800adc <cprintf>
				continue;
			}

			stop = sys_time_msec() + to;
			break;
		}
  8004f6:	eb cd                	jmp    8004c5 <timer+0x7d>
			if (whom != ns_envid) {
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
				continue;
			}

			stop = sys_time_msec() + to;
  8004f8:	e8 e4 11 00 00       	call   8016e1 <sys_time_msec>
  8004fd:	01 c3                	add    %eax,%ebx
			break;
		}
	}
  8004ff:	e9 6e ff ff ff       	jmp    800472 <timer+0x2a>

00800504 <input>:

#define INPUT_COUNT 10

void
input(envid_t ns_envid)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	56                   	push   %esi
  800508:	53                   	push   %ebx
  800509:	83 ec 10             	sub    $0x10,%esp
  80050c:	8b 75 08             	mov    0x8(%ebp),%esi
	binaryname = "ns_input";
  80050f:	c7 05 00 40 80 00 47 	movl   $0x803347,0x804000
  800516:	33 80 00 
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
	struct jif_pkt *pkt = (struct jif_pkt *)REQVA;
	int r;
	if ((r = sys_page_alloc(0, pkt, PTE_P | PTE_U | PTE_W)) < 0)
  800519:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800520:	00 
  800521:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  800528:	0f 
  800529:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800530:	e8 44 0f 00 00       	call   801479 <sys_page_alloc>
  800535:	85 c0                	test   %eax,%eax
  800537:	79 20                	jns    800559 <input+0x55>
			panic("sys_page_alloc: %e", r);
  800539:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053d:	c7 44 24 08 50 33 80 	movl   $0x803350,0x8(%esp)
  800544:	00 
  800545:	c7 44 24 04 15 00 00 	movl   $0x15,0x4(%esp)
  80054c:	00 
  80054d:	c7 04 24 63 33 80 00 	movl   $0x803363,(%esp)
  800554:	e8 8b 04 00 00       	call   8009e4 <_panic>
	uint32_t len;
		
	while (1)
	{
		// cprintf("input hello world\n");
		if ((r = sys_e1000_receive(pkt->jp_data, (uint32_t *)&pkt->jp_len)) < 0)
  800559:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  800560:	0f 
  800561:	c7 04 24 04 b0 fe 0f 	movl   $0xffeb004,(%esp)
  800568:	e8 b4 11 00 00       	call   801721 <sys_e1000_receive>
  80056d:	85 c0                	test   %eax,%eax
  80056f:	78 e8                	js     800559 <input+0x55>
		{
			continue;
		}
		memcpy(nsipcbuf.pkt.jp_data,pkt->jp_data,pkt->jp_len);
  800571:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  800576:	89 44 24 08          	mov    %eax,0x8(%esp)
  80057a:	c7 44 24 04 04 b0 fe 	movl   $0xffeb004,0x4(%esp)
  800581:	0f 
  800582:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  800589:	e8 dc 0c 00 00       	call   80126a <memcpy>
		nsipcbuf.pkt.jp_len = pkt->jp_len;
  80058e:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  800593:	a3 00 70 80 00       	mov    %eax,0x807000
		ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_P | PTE_W | PTE_U);
  800598:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80059f:	00 
  8005a0:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8005a7:	00 
  8005a8:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  8005af:	00 
  8005b0:	89 34 24             	mov    %esi,(%esp)
  8005b3:	e8 b8 15 00 00       	call   801b70 <ipc_send>
  8005b8:	bb 14 00 00 00       	mov    $0x14,%ebx
		
		for (int i = 0; i < INPUT_COUNT*2; i++)
			sys_yield();
  8005bd:	e8 98 0e 00 00       	call   80145a <sys_yield>
		}
		memcpy(nsipcbuf.pkt.jp_data,pkt->jp_data,pkt->jp_len);
		nsipcbuf.pkt.jp_len = pkt->jp_len;
		ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_P | PTE_W | PTE_U);
		
		for (int i = 0; i < INPUT_COUNT*2; i++)
  8005c2:	4b                   	dec    %ebx
  8005c3:	75 f8                	jne    8005bd <input+0xb9>
  8005c5:	eb 92                	jmp    800559 <input+0x55>
	...

008005c8 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  8005c8:	55                   	push   %ebp
  8005c9:	89 e5                	mov    %esp,%ebp
  8005cb:	83 ec 18             	sub    $0x18,%esp
	binaryname = "ns_output";
  8005ce:	c7 05 00 40 80 00 6f 	movl   $0x80336f,0x804000
  8005d5:	33 80 00 
	struct jif_pkt *pkt = &(nsipcbuf.pkt); //= (struct jif_pkt *)(REQVA + PGSIZE);
	int r;

	while (1)
	{
		if ((r = ipc_recv(&ns_envid, pkt, 0)) < 0)
  8005d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8005df:	00 
  8005e0:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8005e7:	00 
  8005e8:	8d 45 08             	lea    0x8(%ebp),%eax
  8005eb:	89 04 24             	mov    %eax,(%esp)
  8005ee:	e8 0d 15 00 00       	call   801b00 <ipc_recv>
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	79 0e                	jns    800605 <output+0x3d>
		{
			cprintf("output ipc_recv error\n");
  8005f7:	c7 04 24 79 33 80 00 	movl   $0x803379,(%esp)
  8005fe:	e8 d9 04 00 00       	call   800adc <cprintf>
			continue;
  800603:	eb d3                	jmp    8005d8 <output+0x10>
		}
		while(1){		
			if ((r = sys_e1000_transmit(pkt->jp_data, pkt->jp_len)) < 0)
  800605:	a1 00 70 80 00       	mov    0x807000,%eax
  80060a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80060e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  800615:	e8 e6 10 00 00       	call   801700 <sys_e1000_transmit>
  80061a:	85 c0                	test   %eax,%eax
  80061c:	79 ba                	jns    8005d8 <output+0x10>
			{
				if (r != -E_NET_NO_DES)
  80061e:	83 f8 f0             	cmp    $0xfffffff0,%eax
  800621:	74 0e                	je     800631 <output+0x69>
				{
					cprintf("output sys_e1000_transmit error\n");
  800623:	c7 04 24 b0 33 80 00 	movl   $0x8033b0,(%esp)
  80062a:	e8 ad 04 00 00       	call   800adc <cprintf>
  80062f:	eb d4                	jmp    800605 <output+0x3d>
				}
				else
				{
					cprintf("output packet overflow yield\n");
  800631:	c7 04 24 90 33 80 00 	movl   $0x803390,(%esp)
  800638:	e8 9f 04 00 00       	call   800adc <cprintf>
					sys_yield();
  80063d:	e8 18 0e 00 00       	call   80145a <sys_yield>
  800642:	eb c1                	jmp    800605 <output+0x3d>

00800644 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  800644:	55                   	push   %ebp
  800645:	89 e5                	mov    %esp,%ebp
  800647:	57                   	push   %edi
  800648:	56                   	push   %esi
  800649:	53                   	push   %ebx
  80064a:	83 ec 1c             	sub    $0x1c,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  80064d:	8b 45 08             	mov    0x8(%ebp),%eax
  800650:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800653:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  800657:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  80065a:	c7 45 dc 08 50 80 00 	movl   $0x805008,-0x24(%ebp)
 */
char *
inet_ntoa(struct in_addr addr)
{
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800661:	b2 00                	mov    $0x0,%dl
  800663:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  800666:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800669:	8a 00                	mov    (%eax),%al
  80066b:	88 45 e2             	mov    %al,-0x1e(%ebp)
      *ap /= (u8_t)10;
  80066e:	0f b6 c0             	movzbl %al,%eax
  800671:	8d 34 80             	lea    (%eax,%eax,4),%esi
  800674:	8d 04 f0             	lea    (%eax,%esi,8),%eax
  800677:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80067a:	66 c1 e8 0b          	shr    $0xb,%ax
  80067e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800681:	88 01                	mov    %al,(%ecx)
      inv[i++] = '0' + rem;
  800683:	0f b6 f2             	movzbl %dl,%esi
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  800686:	8d 3c 80             	lea    (%eax,%eax,4),%edi
  800689:	d1 e7                	shl    %edi
  80068b:	8a 5d e2             	mov    -0x1e(%ebp),%bl
  80068e:	89 f9                	mov    %edi,%ecx
  800690:	28 cb                	sub    %cl,%bl
  800692:	89 df                	mov    %ebx,%edi
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
  800694:	8d 4f 30             	lea    0x30(%edi),%ecx
  800697:	88 4c 35 ed          	mov    %cl,-0x13(%ebp,%esi,1)
  80069b:	42                   	inc    %edx
    } while(*ap);
  80069c:	84 c0                	test   %al,%al
  80069e:	75 c6                	jne    800666 <inet_ntoa+0x22>
  8006a0:	88 d0                	mov    %dl,%al
  8006a2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006a5:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8006a8:	eb 0b                	jmp    8006b5 <inet_ntoa+0x71>
    while(i--)
  8006aa:	48                   	dec    %eax
      *rp++ = inv[i];
  8006ab:	0f b6 f0             	movzbl %al,%esi
  8006ae:	8a 5c 35 ed          	mov    -0x13(%ebp,%esi,1),%bl
  8006b2:	88 19                	mov    %bl,(%ecx)
  8006b4:	41                   	inc    %ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8006b5:	84 c0                	test   %al,%al
  8006b7:	75 f1                	jne    8006aa <inet_ntoa+0x66>
  8006b9:	89 7d d8             	mov    %edi,-0x28(%ebp)
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  8006bc:	0f b6 d2             	movzbl %dl,%edx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8006bf:	03 55 dc             	add    -0x24(%ebp),%edx
      *rp++ = inv[i];
    *rp++ = '.';
  8006c2:	c6 02 2e             	movb   $0x2e,(%edx)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8006c5:	fe 45 e3             	incb   -0x1d(%ebp)
  8006c8:	80 7d e3 03          	cmpb   $0x3,-0x1d(%ebp)
  8006cc:	77 0b                	ja     8006d9 <inet_ntoa+0x95>
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
  8006ce:	42                   	inc    %edx
  8006cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
    ap++;
  8006d2:	ff 45 d8             	incl   -0x28(%ebp)
  8006d5:	88 c2                	mov    %al,%dl
  8006d7:	eb 8d                	jmp    800666 <inet_ntoa+0x22>
  }
  *--rp = 0;
  8006d9:	c6 02 00             	movb   $0x0,(%edx)
  return str;
}
  8006dc:	b8 08 50 80 00       	mov    $0x805008,%eax
  8006e1:	83 c4 1c             	add    $0x1c,%esp
  8006e4:	5b                   	pop    %ebx
  8006e5:	5e                   	pop    %esi
  8006e6:	5f                   	pop    %edi
  8006e7:	5d                   	pop    %ebp
  8006e8:	c3                   	ret    

008006e9 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8006ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ef:	66 c1 c0 08          	rol    $0x8,%ax
}
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  8006fb:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8006ff:	89 04 24             	mov    %eax,(%esp)
  800702:	e8 e2 ff ff ff       	call   8006e9 <htons>
}
  800707:	c9                   	leave  
  800708:	c3                   	ret    

00800709 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  80070f:	89 d1                	mov    %edx,%ecx
  800711:	c1 e9 18             	shr    $0x18,%ecx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  800714:	89 d0                	mov    %edx,%eax
  800716:	c1 e0 18             	shl    $0x18,%eax
  800719:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  80071b:	89 d1                	mov    %edx,%ecx
  80071d:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800723:	c1 e1 08             	shl    $0x8,%ecx
  800726:	09 c8                	or     %ecx,%eax
    ((n & 0xff0000UL) >> 8) |
  800728:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  80072e:	c1 ea 08             	shr    $0x8,%edx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  800731:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	57                   	push   %edi
  800739:	56                   	push   %esi
  80073a:	53                   	push   %ebx
  80073b:	83 ec 24             	sub    $0x24,%esp
  80073e:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800741:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  800744:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800747:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  80074a:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  80074d:	89 5d e0             	mov    %ebx,-0x20(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  800750:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800753:	80 f9 09             	cmp    $0x9,%cl
  800756:	0f 87 8f 01 00 00    	ja     8008eb <inet_aton+0x1b6>
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  80075c:	83 fa 30             	cmp    $0x30,%edx
  80075f:	75 28                	jne    800789 <inet_aton+0x54>
      c = *++cp;
  800761:	0f be 50 01          	movsbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  800765:	83 fa 78             	cmp    $0x78,%edx
  800768:	74 0f                	je     800779 <inet_aton+0x44>
  80076a:	83 fa 58             	cmp    $0x58,%edx
  80076d:	74 0a                	je     800779 <inet_aton+0x44>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  80076f:	40                   	inc    %eax
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  800770:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  800777:	eb 17                	jmp    800790 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  800779:	0f be 50 02          	movsbl 0x2(%eax),%edx
  80077d:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  800780:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
        c = *++cp;
  800787:	eb 07                	jmp    800790 <inet_aton+0x5b>
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
  800789:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
  800790:	40                   	inc    %eax
  800791:	be 00 00 00 00       	mov    $0x0,%esi
  800796:	eb 01                	jmp    800799 <inet_aton+0x64>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  800798:	40                   	inc    %eax
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
  800799:	8d 78 ff             	lea    -0x1(%eax),%edi
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  80079c:	88 d1                	mov    %dl,%cl
  80079e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8007a1:	80 fb 09             	cmp    $0x9,%bl
  8007a4:	77 0d                	ja     8007b3 <inet_aton+0x7e>
        val = (val * base) + (int)(c - '0');
  8007a6:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  8007aa:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  8007ae:	0f be 10             	movsbl (%eax),%edx
  8007b1:	eb e5                	jmp    800798 <inet_aton+0x63>
      } else if (base == 16 && isxdigit(c)) {
  8007b3:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  8007b7:	75 30                	jne    8007e9 <inet_aton+0xb4>
  8007b9:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8007bc:	88 5d da             	mov    %bl,-0x26(%ebp)
  8007bf:	80 fb 05             	cmp    $0x5,%bl
  8007c2:	76 08                	jbe    8007cc <inet_aton+0x97>
  8007c4:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8007c7:	80 fb 05             	cmp    $0x5,%bl
  8007ca:	77 23                	ja     8007ef <inet_aton+0xba>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  8007cc:	89 f1                	mov    %esi,%ecx
  8007ce:	c1 e1 04             	shl    $0x4,%ecx
  8007d1:	8d 72 0a             	lea    0xa(%edx),%esi
  8007d4:	80 7d da 1a          	cmpb   $0x1a,-0x26(%ebp)
  8007d8:	19 d2                	sbb    %edx,%edx
  8007da:	83 e2 20             	and    $0x20,%edx
  8007dd:	83 c2 41             	add    $0x41,%edx
  8007e0:	29 d6                	sub    %edx,%esi
  8007e2:	09 ce                	or     %ecx,%esi
        c = *++cp;
  8007e4:	0f be 10             	movsbl (%eax),%edx
  8007e7:	eb af                	jmp    800798 <inet_aton+0x63>
    }
    for (;;) {
      if (isdigit(c)) {
        val = (val * base) + (int)(c - '0');
        c = *++cp;
      } else if (base == 16 && isxdigit(c)) {
  8007e9:	89 d0                	mov    %edx,%eax
  8007eb:	89 f3                	mov    %esi,%ebx
  8007ed:	eb 04                	jmp    8007f3 <inet_aton+0xbe>
  8007ef:	89 d0                	mov    %edx,%eax
  8007f1:	89 f3                	mov    %esi,%ebx
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
        c = *++cp;
      } else
        break;
    }
    if (c == '.') {
  8007f3:	83 f8 2e             	cmp    $0x2e,%eax
  8007f6:	75 23                	jne    80081b <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8007f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007fb:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
  8007fe:	0f 83 ee 00 00 00    	jae    8008f2 <inet_aton+0x1bd>
        return (0);
      *pp++ = val;
  800804:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800807:	89 1a                	mov    %ebx,(%edx)
  800809:	83 c2 04             	add    $0x4,%edx
  80080c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
      c = *++cp;
  80080f:	8d 47 01             	lea    0x1(%edi),%eax
  800812:	0f be 57 01          	movsbl 0x1(%edi),%edx
    } else
      break;
  }
  800816:	e9 35 ff ff ff       	jmp    800750 <inet_aton+0x1b>
  80081b:	89 f3                	mov    %esi,%ebx
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
        c = *++cp;
      } else
        break;
    }
    if (c == '.') {
  80081d:	89 f0                	mov    %esi,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  80081f:	85 d2                	test   %edx,%edx
  800821:	74 33                	je     800856 <inet_aton+0x121>
  800823:	80 f9 1f             	cmp    $0x1f,%cl
  800826:	0f 86 cd 00 00 00    	jbe    8008f9 <inet_aton+0x1c4>
  80082c:	84 d2                	test   %dl,%dl
  80082e:	0f 88 cc 00 00 00    	js     800900 <inet_aton+0x1cb>
  800834:	83 fa 20             	cmp    $0x20,%edx
  800837:	74 1d                	je     800856 <inet_aton+0x121>
  800839:	83 fa 0c             	cmp    $0xc,%edx
  80083c:	74 18                	je     800856 <inet_aton+0x121>
  80083e:	83 fa 0a             	cmp    $0xa,%edx
  800841:	74 13                	je     800856 <inet_aton+0x121>
  800843:	83 fa 0d             	cmp    $0xd,%edx
  800846:	74 0e                	je     800856 <inet_aton+0x121>
  800848:	83 fa 09             	cmp    $0x9,%edx
  80084b:	74 09                	je     800856 <inet_aton+0x121>
  80084d:	83 fa 0b             	cmp    $0xb,%edx
  800850:	0f 85 b1 00 00 00    	jne    800907 <inet_aton+0x1d2>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  800856:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800859:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80085c:	29 d1                	sub    %edx,%ecx
  80085e:	89 ca                	mov    %ecx,%edx
  800860:	c1 fa 02             	sar    $0x2,%edx
  800863:	42                   	inc    %edx
  switch (n) {
  800864:	83 fa 02             	cmp    $0x2,%edx
  800867:	74 1b                	je     800884 <inet_aton+0x14f>
  800869:	83 fa 02             	cmp    $0x2,%edx
  80086c:	7f 0a                	jg     800878 <inet_aton+0x143>
  80086e:	85 d2                	test   %edx,%edx
  800870:	0f 84 98 00 00 00    	je     80090e <inet_aton+0x1d9>
  800876:	eb 59                	jmp    8008d1 <inet_aton+0x19c>
  800878:	83 fa 03             	cmp    $0x3,%edx
  80087b:	74 1c                	je     800899 <inet_aton+0x164>
  80087d:	83 fa 04             	cmp    $0x4,%edx
  800880:	75 4f                	jne    8008d1 <inet_aton+0x19c>
  800882:	eb 2e                	jmp    8008b2 <inet_aton+0x17d>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  800884:	3d ff ff ff 00       	cmp    $0xffffff,%eax
  800889:	0f 87 86 00 00 00    	ja     800915 <inet_aton+0x1e0>
      return (0);
    val |= parts[0] << 24;
  80088f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800892:	c1 e3 18             	shl    $0x18,%ebx
  800895:	09 c3                	or     %eax,%ebx
    break;
  800897:	eb 38                	jmp    8008d1 <inet_aton+0x19c>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800899:	3d ff ff 00 00       	cmp    $0xffff,%eax
  80089e:	77 7c                	ja     80091c <inet_aton+0x1e7>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  8008a0:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  8008a3:	c1 e3 10             	shl    $0x10,%ebx
  8008a6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008a9:	c1 e2 18             	shl    $0x18,%edx
  8008ac:	09 d3                	or     %edx,%ebx
  8008ae:	09 c3                	or     %eax,%ebx
    break;
  8008b0:	eb 1f                	jmp    8008d1 <inet_aton+0x19c>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  8008b2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8008b7:	77 6a                	ja     800923 <inet_aton+0x1ee>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  8008b9:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  8008bc:	c1 e3 10             	shl    $0x10,%ebx
  8008bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008c2:	c1 e2 18             	shl    $0x18,%edx
  8008c5:	09 d3                	or     %edx,%ebx
  8008c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8008ca:	c1 e2 08             	shl    $0x8,%edx
  8008cd:	09 d3                	or     %edx,%ebx
  8008cf:	09 c3                	or     %eax,%ebx
    break;
  }
  if (addr)
  8008d1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008d5:	74 53                	je     80092a <inet_aton+0x1f5>
    addr->s_addr = htonl(val);
  8008d7:	89 1c 24             	mov    %ebx,(%esp)
  8008da:	e8 2a fe ff ff       	call   800709 <htonl>
  8008df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008e2:	89 03                	mov    %eax,(%ebx)
  return (1);
  8008e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8008e9:	eb 44                	jmp    80092f <inet_aton+0x1fa>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  8008eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f0:	eb 3d                	jmp    80092f <inet_aton+0x1fa>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f7:	eb 36                	jmp    80092f <inet_aton+0x1fa>
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
    return (0);
  8008f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fe:	eb 2f                	jmp    80092f <inet_aton+0x1fa>
  800900:	b8 00 00 00 00       	mov    $0x0,%eax
  800905:	eb 28                	jmp    80092f <inet_aton+0x1fa>
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
  80090c:	eb 21                	jmp    80092f <inet_aton+0x1fa>
   */
  n = pp - parts + 1;
  switch (n) {

  case 0:
    return (0);       /* initial nondigit */
  80090e:	b8 00 00 00 00       	mov    $0x0,%eax
  800913:	eb 1a                	jmp    80092f <inet_aton+0x1fa>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  800915:	b8 00 00 00 00       	mov    $0x0,%eax
  80091a:	eb 13                	jmp    80092f <inet_aton+0x1fa>
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  80091c:	b8 00 00 00 00       	mov    $0x0,%eax
  800921:	eb 0c                	jmp    80092f <inet_aton+0x1fa>
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  800923:	b8 00 00 00 00       	mov    $0x0,%eax
  800928:	eb 05                	jmp    80092f <inet_aton+0x1fa>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  80092a:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80092f:	83 c4 24             	add    $0x24,%esp
  800932:	5b                   	pop    %ebx
  800933:	5e                   	pop    %esi
  800934:	5f                   	pop    %edi
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  80093d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800940:	89 44 24 04          	mov    %eax,0x4(%esp)
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	89 04 24             	mov    %eax,(%esp)
  80094a:	e8 e6 fd ff ff       	call   800735 <inet_aton>
  80094f:	85 c0                	test   %eax,%eax
  800951:	74 05                	je     800958 <inet_addr+0x21>
    return (val.s_addr);
  800953:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800956:	eb 05                	jmp    80095d <inet_addr+0x26>
  }
  return (INADDR_NONE);
  800958:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  80095d:	c9                   	leave  
  80095e:	c3                   	ret    

0080095f <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	89 04 24             	mov    %eax,(%esp)
  80096b:	e8 99 fd ff ff       	call   800709 <htonl>
}
  800970:	c9                   	leave  
  800971:	c3                   	ret    
	...

00800974 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	56                   	push   %esi
  800978:	53                   	push   %ebx
  800979:	83 ec 10             	sub    $0x10,%esp
  80097c:	8b 75 08             	mov    0x8(%ebp),%esi
  80097f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800982:	e8 b4 0a 00 00       	call   80143b <sys_getenvid>
  800987:	25 ff 03 00 00       	and    $0x3ff,%eax
  80098c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800993:	c1 e0 07             	shl    $0x7,%eax
  800996:	29 d0                	sub    %edx,%eax
  800998:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80099d:	a3 20 50 80 00       	mov    %eax,0x805020


	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009a2:	85 f6                	test   %esi,%esi
  8009a4:	7e 07                	jle    8009ad <libmain+0x39>
		binaryname = argv[0];
  8009a6:	8b 03                	mov    (%ebx),%eax
  8009a8:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8009ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b1:	89 34 24             	mov    %esi,(%esp)
  8009b4:	e8 7b f6 ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8009b9:	e8 0a 00 00 00       	call   8009c8 <exit>
}
  8009be:	83 c4 10             	add    $0x10,%esp
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    
  8009c5:	00 00                	add    %al,(%eax)
	...

008009c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8009ce:	e8 4c 14 00 00       	call   801e1f <close_all>
	sys_env_destroy(0);
  8009d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009da:	e8 0a 0a 00 00       	call   8013e9 <sys_env_destroy>
}
  8009df:	c9                   	leave  
  8009e0:	c3                   	ret    
  8009e1:	00 00                	add    %al,(%eax)
	...

008009e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8009ec:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8009ef:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8009f5:	e8 41 0a 00 00       	call   80143b <sys_getenvid>
  8009fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fd:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a01:	8b 55 08             	mov    0x8(%ebp),%edx
  800a04:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a08:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a10:	c7 04 24 dc 33 80 00 	movl   $0x8033dc,(%esp)
  800a17:	e8 c0 00 00 00       	call   800adc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a1c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a20:	8b 45 10             	mov    0x10(%ebp),%eax
  800a23:	89 04 24             	mov    %eax,(%esp)
  800a26:	e8 50 00 00 00       	call   800a7b <vcprintf>
	cprintf("\n");
  800a2b:	c7 04 24 bb 32 80 00 	movl   $0x8032bb,(%esp)
  800a32:	e8 a5 00 00 00       	call   800adc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a37:	cc                   	int3   
  800a38:	eb fd                	jmp    800a37 <_panic+0x53>
	...

00800a3c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	53                   	push   %ebx
  800a40:	83 ec 14             	sub    $0x14,%esp
  800a43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a46:	8b 03                	mov    (%ebx),%eax
  800a48:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800a4f:	40                   	inc    %eax
  800a50:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800a52:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a57:	75 19                	jne    800a72 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800a59:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800a60:	00 
  800a61:	8d 43 08             	lea    0x8(%ebx),%eax
  800a64:	89 04 24             	mov    %eax,(%esp)
  800a67:	e8 40 09 00 00       	call   8013ac <sys_cputs>
		b->idx = 0;
  800a6c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800a72:	ff 43 04             	incl   0x4(%ebx)
}
  800a75:	83 c4 14             	add    $0x14,%esp
  800a78:	5b                   	pop    %ebx
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800a84:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800a8b:	00 00 00 
	b.cnt = 0;
  800a8e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800a95:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800a98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab0:	c7 04 24 3c 0a 80 00 	movl   $0x800a3c,(%esp)
  800ab7:	e8 82 01 00 00       	call   800c3e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800abc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800acc:	89 04 24             	mov    %eax,(%esp)
  800acf:	e8 d8 08 00 00       	call   8013ac <sys_cputs>

	return b.cnt;
}
  800ad4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800ada:	c9                   	leave  
  800adb:	c3                   	ret    

00800adc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800ae2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800ae5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	89 04 24             	mov    %eax,(%esp)
  800aef:	e8 87 ff ff ff       	call   800a7b <vcprintf>
	va_end(ap);

	return cnt;
}
  800af4:	c9                   	leave  
  800af5:	c3                   	ret    
	...

00800af8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	57                   	push   %edi
  800afc:	56                   	push   %esi
  800afd:	53                   	push   %ebx
  800afe:	83 ec 3c             	sub    $0x3c,%esp
  800b01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800b04:	89 d7                	mov    %edx,%edi
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800b0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b12:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800b15:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b18:	85 c0                	test   %eax,%eax
  800b1a:	75 08                	jne    800b24 <printnum+0x2c>
  800b1c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b1f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800b22:	77 57                	ja     800b7b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b24:	89 74 24 10          	mov    %esi,0x10(%esp)
  800b28:	4b                   	dec    %ebx
  800b29:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800b2d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b30:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b34:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800b38:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800b3c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b43:	00 
  800b44:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b47:	89 04 24             	mov    %eax,(%esp)
  800b4a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800b4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b51:	e8 3e 24 00 00       	call   802f94 <__udivdi3>
  800b56:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800b5a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b5e:	89 04 24             	mov    %eax,(%esp)
  800b61:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b65:	89 fa                	mov    %edi,%edx
  800b67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b6a:	e8 89 ff ff ff       	call   800af8 <printnum>
  800b6f:	eb 0f                	jmp    800b80 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b71:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b75:	89 34 24             	mov    %esi,(%esp)
  800b78:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b7b:	4b                   	dec    %ebx
  800b7c:	85 db                	test   %ebx,%ebx
  800b7e:	7f f1                	jg     800b71 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b80:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b84:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b88:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b8f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800b96:	00 
  800b97:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800b9a:	89 04 24             	mov    %eax,(%esp)
  800b9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba4:	e8 0b 25 00 00       	call   8030b4 <__umoddi3>
  800ba9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bad:	0f be 80 ff 33 80 00 	movsbl 0x8033ff(%eax),%eax
  800bb4:	89 04 24             	mov    %eax,(%esp)
  800bb7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800bba:	83 c4 3c             	add    $0x3c,%esp
  800bbd:	5b                   	pop    %ebx
  800bbe:	5e                   	pop    %esi
  800bbf:	5f                   	pop    %edi
  800bc0:	5d                   	pop    %ebp
  800bc1:	c3                   	ret    

00800bc2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bc5:	83 fa 01             	cmp    $0x1,%edx
  800bc8:	7e 0e                	jle    800bd8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bca:	8b 10                	mov    (%eax),%edx
  800bcc:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bcf:	89 08                	mov    %ecx,(%eax)
  800bd1:	8b 02                	mov    (%edx),%eax
  800bd3:	8b 52 04             	mov    0x4(%edx),%edx
  800bd6:	eb 22                	jmp    800bfa <getuint+0x38>
	else if (lflag)
  800bd8:	85 d2                	test   %edx,%edx
  800bda:	74 10                	je     800bec <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bdc:	8b 10                	mov    (%eax),%edx
  800bde:	8d 4a 04             	lea    0x4(%edx),%ecx
  800be1:	89 08                	mov    %ecx,(%eax)
  800be3:	8b 02                	mov    (%edx),%eax
  800be5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bea:	eb 0e                	jmp    800bfa <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800bec:	8b 10                	mov    (%eax),%edx
  800bee:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bf1:	89 08                	mov    %ecx,(%eax)
  800bf3:	8b 02                	mov    (%edx),%eax
  800bf5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c02:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800c05:	8b 10                	mov    (%eax),%edx
  800c07:	3b 50 04             	cmp    0x4(%eax),%edx
  800c0a:	73 08                	jae    800c14 <sprintputch+0x18>
		*b->buf++ = ch;
  800c0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0f:	88 0a                	mov    %cl,(%edx)
  800c11:	42                   	inc    %edx
  800c12:	89 10                	mov    %edx,(%eax)
}
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800c1c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c23:	8b 45 10             	mov    0x10(%ebp),%eax
  800c26:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c31:	8b 45 08             	mov    0x8(%ebp),%eax
  800c34:	89 04 24             	mov    %eax,(%esp)
  800c37:	e8 02 00 00 00       	call   800c3e <vprintfmt>
	va_end(ap);
}
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    

00800c3e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 4c             	sub    $0x4c,%esp
  800c47:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c4a:	8b 75 10             	mov    0x10(%ebp),%esi
  800c4d:	eb 12                	jmp    800c61 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	0f 84 6b 03 00 00    	je     800fc2 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800c57:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c5b:	89 04 24             	mov    %eax,(%esp)
  800c5e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c61:	0f b6 06             	movzbl (%esi),%eax
  800c64:	46                   	inc    %esi
  800c65:	83 f8 25             	cmp    $0x25,%eax
  800c68:	75 e5                	jne    800c4f <vprintfmt+0x11>
  800c6a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800c6e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800c75:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800c7a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800c81:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c86:	eb 26                	jmp    800cae <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c88:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c8b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800c8f:	eb 1d                	jmp    800cae <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c91:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800c94:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800c98:	eb 14                	jmp    800cae <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c9a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800c9d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800ca4:	eb 08                	jmp    800cae <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800ca6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800ca9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cae:	0f b6 06             	movzbl (%esi),%eax
  800cb1:	8d 56 01             	lea    0x1(%esi),%edx
  800cb4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800cb7:	8a 16                	mov    (%esi),%dl
  800cb9:	83 ea 23             	sub    $0x23,%edx
  800cbc:	80 fa 55             	cmp    $0x55,%dl
  800cbf:	0f 87 e1 02 00 00    	ja     800fa6 <vprintfmt+0x368>
  800cc5:	0f b6 d2             	movzbl %dl,%edx
  800cc8:	ff 24 95 40 35 80 00 	jmp    *0x803540(,%edx,4)
  800ccf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800cd2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cd7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800cda:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800cde:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800ce1:	8d 50 d0             	lea    -0x30(%eax),%edx
  800ce4:	83 fa 09             	cmp    $0x9,%edx
  800ce7:	77 2a                	ja     800d13 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800ce9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800cea:	eb eb                	jmp    800cd7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800cec:	8b 45 14             	mov    0x14(%ebp),%eax
  800cef:	8d 50 04             	lea    0x4(%eax),%edx
  800cf2:	89 55 14             	mov    %edx,0x14(%ebp)
  800cf5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cf7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800cfa:	eb 17                	jmp    800d13 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800cfc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d00:	78 98                	js     800c9a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d02:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d05:	eb a7                	jmp    800cae <vprintfmt+0x70>
  800d07:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800d0a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800d11:	eb 9b                	jmp    800cae <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800d13:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d17:	79 95                	jns    800cae <vprintfmt+0x70>
  800d19:	eb 8b                	jmp    800ca6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d1b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d1c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d1f:	eb 8d                	jmp    800cae <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d21:	8b 45 14             	mov    0x14(%ebp),%eax
  800d24:	8d 50 04             	lea    0x4(%eax),%edx
  800d27:	89 55 14             	mov    %edx,0x14(%ebp)
  800d2a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d2e:	8b 00                	mov    (%eax),%eax
  800d30:	89 04 24             	mov    %eax,(%esp)
  800d33:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d36:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d39:	e9 23 ff ff ff       	jmp    800c61 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800d3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800d41:	8d 50 04             	lea    0x4(%eax),%edx
  800d44:	89 55 14             	mov    %edx,0x14(%ebp)
  800d47:	8b 00                	mov    (%eax),%eax
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	79 02                	jns    800d4f <vprintfmt+0x111>
  800d4d:	f7 d8                	neg    %eax
  800d4f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d51:	83 f8 10             	cmp    $0x10,%eax
  800d54:	7f 0b                	jg     800d61 <vprintfmt+0x123>
  800d56:	8b 04 85 a0 36 80 00 	mov    0x8036a0(,%eax,4),%eax
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	75 23                	jne    800d84 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800d61:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d65:	c7 44 24 08 17 34 80 	movl   $0x803417,0x8(%esp)
  800d6c:	00 
  800d6d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d71:	8b 45 08             	mov    0x8(%ebp),%eax
  800d74:	89 04 24             	mov    %eax,(%esp)
  800d77:	e8 9a fe ff ff       	call   800c16 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d7c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d7f:	e9 dd fe ff ff       	jmp    800c61 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800d84:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d88:	c7 44 24 08 99 38 80 	movl   $0x803899,0x8(%esp)
  800d8f:	00 
  800d90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	89 14 24             	mov    %edx,(%esp)
  800d9a:	e8 77 fe ff ff       	call   800c16 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d9f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800da2:	e9 ba fe ff ff       	jmp    800c61 <vprintfmt+0x23>
  800da7:	89 f9                	mov    %edi,%ecx
  800da9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800dac:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800daf:	8b 45 14             	mov    0x14(%ebp),%eax
  800db2:	8d 50 04             	lea    0x4(%eax),%edx
  800db5:	89 55 14             	mov    %edx,0x14(%ebp)
  800db8:	8b 30                	mov    (%eax),%esi
  800dba:	85 f6                	test   %esi,%esi
  800dbc:	75 05                	jne    800dc3 <vprintfmt+0x185>
				p = "(null)";
  800dbe:	be 10 34 80 00       	mov    $0x803410,%esi
			if (width > 0 && padc != '-')
  800dc3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800dc7:	0f 8e 84 00 00 00    	jle    800e51 <vprintfmt+0x213>
  800dcd:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800dd1:	74 7e                	je     800e51 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800dd3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800dd7:	89 34 24             	mov    %esi,(%esp)
  800dda:	e8 8b 02 00 00       	call   80106a <strnlen>
  800ddf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800de2:	29 c2                	sub    %eax,%edx
  800de4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800de7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800deb:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800dee:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800df1:	89 de                	mov    %ebx,%esi
  800df3:	89 d3                	mov    %edx,%ebx
  800df5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800df7:	eb 0b                	jmp    800e04 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800df9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dfd:	89 3c 24             	mov    %edi,(%esp)
  800e00:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800e03:	4b                   	dec    %ebx
  800e04:	85 db                	test   %ebx,%ebx
  800e06:	7f f1                	jg     800df9 <vprintfmt+0x1bb>
  800e08:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800e0b:	89 f3                	mov    %esi,%ebx
  800e0d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800e10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800e13:	85 c0                	test   %eax,%eax
  800e15:	79 05                	jns    800e1c <vprintfmt+0x1de>
  800e17:	b8 00 00 00 00       	mov    $0x0,%eax
  800e1c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e1f:	29 c2                	sub    %eax,%edx
  800e21:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e24:	eb 2b                	jmp    800e51 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e26:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800e2a:	74 18                	je     800e44 <vprintfmt+0x206>
  800e2c:	8d 50 e0             	lea    -0x20(%eax),%edx
  800e2f:	83 fa 5e             	cmp    $0x5e,%edx
  800e32:	76 10                	jbe    800e44 <vprintfmt+0x206>
					putch('?', putdat);
  800e34:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e38:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800e3f:	ff 55 08             	call   *0x8(%ebp)
  800e42:	eb 0a                	jmp    800e4e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800e44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e48:	89 04 24             	mov    %eax,(%esp)
  800e4b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e4e:	ff 4d e4             	decl   -0x1c(%ebp)
  800e51:	0f be 06             	movsbl (%esi),%eax
  800e54:	46                   	inc    %esi
  800e55:	85 c0                	test   %eax,%eax
  800e57:	74 21                	je     800e7a <vprintfmt+0x23c>
  800e59:	85 ff                	test   %edi,%edi
  800e5b:	78 c9                	js     800e26 <vprintfmt+0x1e8>
  800e5d:	4f                   	dec    %edi
  800e5e:	79 c6                	jns    800e26 <vprintfmt+0x1e8>
  800e60:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e63:	89 de                	mov    %ebx,%esi
  800e65:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800e68:	eb 18                	jmp    800e82 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e6a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e6e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800e75:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e77:	4b                   	dec    %ebx
  800e78:	eb 08                	jmp    800e82 <vprintfmt+0x244>
  800e7a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e7d:	89 de                	mov    %ebx,%esi
  800e7f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800e82:	85 db                	test   %ebx,%ebx
  800e84:	7f e4                	jg     800e6a <vprintfmt+0x22c>
  800e86:	89 7d 08             	mov    %edi,0x8(%ebp)
  800e89:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800e8b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800e8e:	e9 ce fd ff ff       	jmp    800c61 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800e93:	83 f9 01             	cmp    $0x1,%ecx
  800e96:	7e 10                	jle    800ea8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800e98:	8b 45 14             	mov    0x14(%ebp),%eax
  800e9b:	8d 50 08             	lea    0x8(%eax),%edx
  800e9e:	89 55 14             	mov    %edx,0x14(%ebp)
  800ea1:	8b 30                	mov    (%eax),%esi
  800ea3:	8b 78 04             	mov    0x4(%eax),%edi
  800ea6:	eb 26                	jmp    800ece <vprintfmt+0x290>
	else if (lflag)
  800ea8:	85 c9                	test   %ecx,%ecx
  800eaa:	74 12                	je     800ebe <vprintfmt+0x280>
		return va_arg(*ap, long);
  800eac:	8b 45 14             	mov    0x14(%ebp),%eax
  800eaf:	8d 50 04             	lea    0x4(%eax),%edx
  800eb2:	89 55 14             	mov    %edx,0x14(%ebp)
  800eb5:	8b 30                	mov    (%eax),%esi
  800eb7:	89 f7                	mov    %esi,%edi
  800eb9:	c1 ff 1f             	sar    $0x1f,%edi
  800ebc:	eb 10                	jmp    800ece <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800ebe:	8b 45 14             	mov    0x14(%ebp),%eax
  800ec1:	8d 50 04             	lea    0x4(%eax),%edx
  800ec4:	89 55 14             	mov    %edx,0x14(%ebp)
  800ec7:	8b 30                	mov    (%eax),%esi
  800ec9:	89 f7                	mov    %esi,%edi
  800ecb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ece:	85 ff                	test   %edi,%edi
  800ed0:	78 0a                	js     800edc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ed2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed7:	e9 8c 00 00 00       	jmp    800f68 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800edc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ee0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800ee7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800eea:	f7 de                	neg    %esi
  800eec:	83 d7 00             	adc    $0x0,%edi
  800eef:	f7 df                	neg    %edi
			}
			base = 10;
  800ef1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef6:	eb 70                	jmp    800f68 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800ef8:	89 ca                	mov    %ecx,%edx
  800efa:	8d 45 14             	lea    0x14(%ebp),%eax
  800efd:	e8 c0 fc ff ff       	call   800bc2 <getuint>
  800f02:	89 c6                	mov    %eax,%esi
  800f04:	89 d7                	mov    %edx,%edi
			base = 10;
  800f06:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800f0b:	eb 5b                	jmp    800f68 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800f0d:	89 ca                	mov    %ecx,%edx
  800f0f:	8d 45 14             	lea    0x14(%ebp),%eax
  800f12:	e8 ab fc ff ff       	call   800bc2 <getuint>
  800f17:	89 c6                	mov    %eax,%esi
  800f19:	89 d7                	mov    %edx,%edi
			base = 8;
  800f1b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800f20:	eb 46                	jmp    800f68 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800f22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f26:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800f2d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800f30:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f34:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800f3b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f41:	8d 50 04             	lea    0x4(%eax),%edx
  800f44:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f47:	8b 30                	mov    (%eax),%esi
  800f49:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f4e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800f53:	eb 13                	jmp    800f68 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f55:	89 ca                	mov    %ecx,%edx
  800f57:	8d 45 14             	lea    0x14(%ebp),%eax
  800f5a:	e8 63 fc ff ff       	call   800bc2 <getuint>
  800f5f:	89 c6                	mov    %eax,%esi
  800f61:	89 d7                	mov    %edx,%edi
			base = 16;
  800f63:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f68:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800f6c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800f70:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f73:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f77:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f7b:	89 34 24             	mov    %esi,(%esp)
  800f7e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800f82:	89 da                	mov    %ebx,%edx
  800f84:	8b 45 08             	mov    0x8(%ebp),%eax
  800f87:	e8 6c fb ff ff       	call   800af8 <printnum>
			break;
  800f8c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f8f:	e9 cd fc ff ff       	jmp    800c61 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800f94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f98:	89 04 24             	mov    %eax,(%esp)
  800f9b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800f9e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fa1:	e9 bb fc ff ff       	jmp    800c61 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fa6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800faa:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800fb1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fb4:	eb 01                	jmp    800fb7 <vprintfmt+0x379>
  800fb6:	4e                   	dec    %esi
  800fb7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800fbb:	75 f9                	jne    800fb6 <vprintfmt+0x378>
  800fbd:	e9 9f fc ff ff       	jmp    800c61 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800fc2:	83 c4 4c             	add    $0x4c,%esp
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	83 ec 28             	sub    $0x28,%esp
  800fd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800fd6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fd9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800fdd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800fe0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	74 30                	je     80101b <vsnprintf+0x51>
  800feb:	85 d2                	test   %edx,%edx
  800fed:	7e 33                	jle    801022 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800fef:	8b 45 14             	mov    0x14(%ebp),%eax
  800ff2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ff6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ffd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801000:	89 44 24 04          	mov    %eax,0x4(%esp)
  801004:	c7 04 24 fc 0b 80 00 	movl   $0x800bfc,(%esp)
  80100b:	e8 2e fc ff ff       	call   800c3e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801010:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801013:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801016:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801019:	eb 0c                	jmp    801027 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80101b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801020:	eb 05                	jmp    801027 <vsnprintf+0x5d>
  801022:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801027:	c9                   	leave  
  801028:	c3                   	ret    

00801029 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80102f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801032:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801036:	8b 45 10             	mov    0x10(%ebp),%eax
  801039:	89 44 24 08          	mov    %eax,0x8(%esp)
  80103d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801040:	89 44 24 04          	mov    %eax,0x4(%esp)
  801044:	8b 45 08             	mov    0x8(%ebp),%eax
  801047:	89 04 24             	mov    %eax,(%esp)
  80104a:	e8 7b ff ff ff       	call   800fca <vsnprintf>
	va_end(ap);

	return rc;
}
  80104f:	c9                   	leave  
  801050:	c3                   	ret    
  801051:	00 00                	add    %al,(%eax)
	...

00801054 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80105a:	b8 00 00 00 00       	mov    $0x0,%eax
  80105f:	eb 01                	jmp    801062 <strlen+0xe>
		n++;
  801061:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801062:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801066:	75 f9                	jne    801061 <strlen+0xd>
		n++;
	return n;
}
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    

0080106a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801070:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801073:	b8 00 00 00 00       	mov    $0x0,%eax
  801078:	eb 01                	jmp    80107b <strnlen+0x11>
		n++;
  80107a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80107b:	39 d0                	cmp    %edx,%eax
  80107d:	74 06                	je     801085 <strnlen+0x1b>
  80107f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801083:	75 f5                	jne    80107a <strnlen+0x10>
		n++;
	return n;
}
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	53                   	push   %ebx
  80108b:	8b 45 08             	mov    0x8(%ebp),%eax
  80108e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801091:	ba 00 00 00 00       	mov    $0x0,%edx
  801096:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801099:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80109c:	42                   	inc    %edx
  80109d:	84 c9                	test   %cl,%cl
  80109f:	75 f5                	jne    801096 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8010a1:	5b                   	pop    %ebx
  8010a2:	5d                   	pop    %ebp
  8010a3:	c3                   	ret    

008010a4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	53                   	push   %ebx
  8010a8:	83 ec 08             	sub    $0x8,%esp
  8010ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8010ae:	89 1c 24             	mov    %ebx,(%esp)
  8010b1:	e8 9e ff ff ff       	call   801054 <strlen>
	strcpy(dst + len, src);
  8010b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010bd:	01 d8                	add    %ebx,%eax
  8010bf:	89 04 24             	mov    %eax,(%esp)
  8010c2:	e8 c0 ff ff ff       	call   801087 <strcpy>
	return dst;
}
  8010c7:	89 d8                	mov    %ebx,%eax
  8010c9:	83 c4 08             	add    $0x8,%esp
  8010cc:	5b                   	pop    %ebx
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	56                   	push   %esi
  8010d3:	53                   	push   %ebx
  8010d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010da:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8010dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010e2:	eb 0c                	jmp    8010f0 <strncpy+0x21>
		*dst++ = *src;
  8010e4:	8a 1a                	mov    (%edx),%bl
  8010e6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8010e9:	80 3a 01             	cmpb   $0x1,(%edx)
  8010ec:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8010ef:	41                   	inc    %ecx
  8010f0:	39 f1                	cmp    %esi,%ecx
  8010f2:	75 f0                	jne    8010e4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8010f4:	5b                   	pop    %ebx
  8010f5:	5e                   	pop    %esi
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	56                   	push   %esi
  8010fc:	53                   	push   %ebx
  8010fd:	8b 75 08             	mov    0x8(%ebp),%esi
  801100:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801103:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801106:	85 d2                	test   %edx,%edx
  801108:	75 0a                	jne    801114 <strlcpy+0x1c>
  80110a:	89 f0                	mov    %esi,%eax
  80110c:	eb 1a                	jmp    801128 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80110e:	88 18                	mov    %bl,(%eax)
  801110:	40                   	inc    %eax
  801111:	41                   	inc    %ecx
  801112:	eb 02                	jmp    801116 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801114:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801116:	4a                   	dec    %edx
  801117:	74 0a                	je     801123 <strlcpy+0x2b>
  801119:	8a 19                	mov    (%ecx),%bl
  80111b:	84 db                	test   %bl,%bl
  80111d:	75 ef                	jne    80110e <strlcpy+0x16>
  80111f:	89 c2                	mov    %eax,%edx
  801121:	eb 02                	jmp    801125 <strlcpy+0x2d>
  801123:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801125:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801128:	29 f0                	sub    %esi,%eax
}
  80112a:	5b                   	pop    %ebx
  80112b:	5e                   	pop    %esi
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801134:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801137:	eb 02                	jmp    80113b <strcmp+0xd>
		p++, q++;
  801139:	41                   	inc    %ecx
  80113a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80113b:	8a 01                	mov    (%ecx),%al
  80113d:	84 c0                	test   %al,%al
  80113f:	74 04                	je     801145 <strcmp+0x17>
  801141:	3a 02                	cmp    (%edx),%al
  801143:	74 f4                	je     801139 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801145:	0f b6 c0             	movzbl %al,%eax
  801148:	0f b6 12             	movzbl (%edx),%edx
  80114b:	29 d0                	sub    %edx,%eax
}
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    

0080114f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	53                   	push   %ebx
  801153:	8b 45 08             	mov    0x8(%ebp),%eax
  801156:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801159:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80115c:	eb 03                	jmp    801161 <strncmp+0x12>
		n--, p++, q++;
  80115e:	4a                   	dec    %edx
  80115f:	40                   	inc    %eax
  801160:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801161:	85 d2                	test   %edx,%edx
  801163:	74 14                	je     801179 <strncmp+0x2a>
  801165:	8a 18                	mov    (%eax),%bl
  801167:	84 db                	test   %bl,%bl
  801169:	74 04                	je     80116f <strncmp+0x20>
  80116b:	3a 19                	cmp    (%ecx),%bl
  80116d:	74 ef                	je     80115e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80116f:	0f b6 00             	movzbl (%eax),%eax
  801172:	0f b6 11             	movzbl (%ecx),%edx
  801175:	29 d0                	sub    %edx,%eax
  801177:	eb 05                	jmp    80117e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801179:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80117e:	5b                   	pop    %ebx
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    

00801181 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	8b 45 08             	mov    0x8(%ebp),%eax
  801187:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80118a:	eb 05                	jmp    801191 <strchr+0x10>
		if (*s == c)
  80118c:	38 ca                	cmp    %cl,%dl
  80118e:	74 0c                	je     80119c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801190:	40                   	inc    %eax
  801191:	8a 10                	mov    (%eax),%dl
  801193:	84 d2                	test   %dl,%dl
  801195:	75 f5                	jne    80118c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801197:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8011a7:	eb 05                	jmp    8011ae <strfind+0x10>
		if (*s == c)
  8011a9:	38 ca                	cmp    %cl,%dl
  8011ab:	74 07                	je     8011b4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8011ad:	40                   	inc    %eax
  8011ae:	8a 10                	mov    (%eax),%dl
  8011b0:	84 d2                	test   %dl,%dl
  8011b2:	75 f5                	jne    8011a9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8011b4:	5d                   	pop    %ebp
  8011b5:	c3                   	ret    

008011b6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	57                   	push   %edi
  8011ba:	56                   	push   %esi
  8011bb:	53                   	push   %ebx
  8011bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8011c5:	85 c9                	test   %ecx,%ecx
  8011c7:	74 30                	je     8011f9 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8011c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8011cf:	75 25                	jne    8011f6 <memset+0x40>
  8011d1:	f6 c1 03             	test   $0x3,%cl
  8011d4:	75 20                	jne    8011f6 <memset+0x40>
		c &= 0xFF;
  8011d6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8011d9:	89 d3                	mov    %edx,%ebx
  8011db:	c1 e3 08             	shl    $0x8,%ebx
  8011de:	89 d6                	mov    %edx,%esi
  8011e0:	c1 e6 18             	shl    $0x18,%esi
  8011e3:	89 d0                	mov    %edx,%eax
  8011e5:	c1 e0 10             	shl    $0x10,%eax
  8011e8:	09 f0                	or     %esi,%eax
  8011ea:	09 d0                	or     %edx,%eax
  8011ec:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8011ee:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8011f1:	fc                   	cld    
  8011f2:	f3 ab                	rep stos %eax,%es:(%edi)
  8011f4:	eb 03                	jmp    8011f9 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8011f6:	fc                   	cld    
  8011f7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8011f9:	89 f8                	mov    %edi,%eax
  8011fb:	5b                   	pop    %ebx
  8011fc:	5e                   	pop    %esi
  8011fd:	5f                   	pop    %edi
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	57                   	push   %edi
  801204:	56                   	push   %esi
  801205:	8b 45 08             	mov    0x8(%ebp),%eax
  801208:	8b 75 0c             	mov    0xc(%ebp),%esi
  80120b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80120e:	39 c6                	cmp    %eax,%esi
  801210:	73 34                	jae    801246 <memmove+0x46>
  801212:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801215:	39 d0                	cmp    %edx,%eax
  801217:	73 2d                	jae    801246 <memmove+0x46>
		s += n;
		d += n;
  801219:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80121c:	f6 c2 03             	test   $0x3,%dl
  80121f:	75 1b                	jne    80123c <memmove+0x3c>
  801221:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801227:	75 13                	jne    80123c <memmove+0x3c>
  801229:	f6 c1 03             	test   $0x3,%cl
  80122c:	75 0e                	jne    80123c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80122e:	83 ef 04             	sub    $0x4,%edi
  801231:	8d 72 fc             	lea    -0x4(%edx),%esi
  801234:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801237:	fd                   	std    
  801238:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80123a:	eb 07                	jmp    801243 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80123c:	4f                   	dec    %edi
  80123d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801240:	fd                   	std    
  801241:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801243:	fc                   	cld    
  801244:	eb 20                	jmp    801266 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801246:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80124c:	75 13                	jne    801261 <memmove+0x61>
  80124e:	a8 03                	test   $0x3,%al
  801250:	75 0f                	jne    801261 <memmove+0x61>
  801252:	f6 c1 03             	test   $0x3,%cl
  801255:	75 0a                	jne    801261 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801257:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80125a:	89 c7                	mov    %eax,%edi
  80125c:	fc                   	cld    
  80125d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80125f:	eb 05                	jmp    801266 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801261:	89 c7                	mov    %eax,%edi
  801263:	fc                   	cld    
  801264:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801266:	5e                   	pop    %esi
  801267:	5f                   	pop    %edi
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801270:	8b 45 10             	mov    0x10(%ebp),%eax
  801273:	89 44 24 08          	mov    %eax,0x8(%esp)
  801277:	8b 45 0c             	mov    0xc(%ebp),%eax
  80127a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127e:	8b 45 08             	mov    0x8(%ebp),%eax
  801281:	89 04 24             	mov    %eax,(%esp)
  801284:	e8 77 ff ff ff       	call   801200 <memmove>
}
  801289:	c9                   	leave  
  80128a:	c3                   	ret    

0080128b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	57                   	push   %edi
  80128f:	56                   	push   %esi
  801290:	53                   	push   %ebx
  801291:	8b 7d 08             	mov    0x8(%ebp),%edi
  801294:	8b 75 0c             	mov    0xc(%ebp),%esi
  801297:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80129a:	ba 00 00 00 00       	mov    $0x0,%edx
  80129f:	eb 16                	jmp    8012b7 <memcmp+0x2c>
		if (*s1 != *s2)
  8012a1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8012a4:	42                   	inc    %edx
  8012a5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8012a9:	38 c8                	cmp    %cl,%al
  8012ab:	74 0a                	je     8012b7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8012ad:	0f b6 c0             	movzbl %al,%eax
  8012b0:	0f b6 c9             	movzbl %cl,%ecx
  8012b3:	29 c8                	sub    %ecx,%eax
  8012b5:	eb 09                	jmp    8012c0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8012b7:	39 da                	cmp    %ebx,%edx
  8012b9:	75 e6                	jne    8012a1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8012bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5f                   	pop    %edi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8012ce:	89 c2                	mov    %eax,%edx
  8012d0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8012d3:	eb 05                	jmp    8012da <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8012d5:	38 08                	cmp    %cl,(%eax)
  8012d7:	74 05                	je     8012de <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8012d9:	40                   	inc    %eax
  8012da:	39 d0                	cmp    %edx,%eax
  8012dc:	72 f7                	jb     8012d5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8012de:	5d                   	pop    %ebp
  8012df:	c3                   	ret    

008012e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	57                   	push   %edi
  8012e4:	56                   	push   %esi
  8012e5:	53                   	push   %ebx
  8012e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012ec:	eb 01                	jmp    8012ef <strtol+0xf>
		s++;
  8012ee:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012ef:	8a 02                	mov    (%edx),%al
  8012f1:	3c 20                	cmp    $0x20,%al
  8012f3:	74 f9                	je     8012ee <strtol+0xe>
  8012f5:	3c 09                	cmp    $0x9,%al
  8012f7:	74 f5                	je     8012ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8012f9:	3c 2b                	cmp    $0x2b,%al
  8012fb:	75 08                	jne    801305 <strtol+0x25>
		s++;
  8012fd:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8012fe:	bf 00 00 00 00       	mov    $0x0,%edi
  801303:	eb 13                	jmp    801318 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801305:	3c 2d                	cmp    $0x2d,%al
  801307:	75 0a                	jne    801313 <strtol+0x33>
		s++, neg = 1;
  801309:	8d 52 01             	lea    0x1(%edx),%edx
  80130c:	bf 01 00 00 00       	mov    $0x1,%edi
  801311:	eb 05                	jmp    801318 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801313:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801318:	85 db                	test   %ebx,%ebx
  80131a:	74 05                	je     801321 <strtol+0x41>
  80131c:	83 fb 10             	cmp    $0x10,%ebx
  80131f:	75 28                	jne    801349 <strtol+0x69>
  801321:	8a 02                	mov    (%edx),%al
  801323:	3c 30                	cmp    $0x30,%al
  801325:	75 10                	jne    801337 <strtol+0x57>
  801327:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80132b:	75 0a                	jne    801337 <strtol+0x57>
		s += 2, base = 16;
  80132d:	83 c2 02             	add    $0x2,%edx
  801330:	bb 10 00 00 00       	mov    $0x10,%ebx
  801335:	eb 12                	jmp    801349 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801337:	85 db                	test   %ebx,%ebx
  801339:	75 0e                	jne    801349 <strtol+0x69>
  80133b:	3c 30                	cmp    $0x30,%al
  80133d:	75 05                	jne    801344 <strtol+0x64>
		s++, base = 8;
  80133f:	42                   	inc    %edx
  801340:	b3 08                	mov    $0x8,%bl
  801342:	eb 05                	jmp    801349 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801344:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801349:	b8 00 00 00 00       	mov    $0x0,%eax
  80134e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801350:	8a 0a                	mov    (%edx),%cl
  801352:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801355:	80 fb 09             	cmp    $0x9,%bl
  801358:	77 08                	ja     801362 <strtol+0x82>
			dig = *s - '0';
  80135a:	0f be c9             	movsbl %cl,%ecx
  80135d:	83 e9 30             	sub    $0x30,%ecx
  801360:	eb 1e                	jmp    801380 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801362:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801365:	80 fb 19             	cmp    $0x19,%bl
  801368:	77 08                	ja     801372 <strtol+0x92>
			dig = *s - 'a' + 10;
  80136a:	0f be c9             	movsbl %cl,%ecx
  80136d:	83 e9 57             	sub    $0x57,%ecx
  801370:	eb 0e                	jmp    801380 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801372:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801375:	80 fb 19             	cmp    $0x19,%bl
  801378:	77 12                	ja     80138c <strtol+0xac>
			dig = *s - 'A' + 10;
  80137a:	0f be c9             	movsbl %cl,%ecx
  80137d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801380:	39 f1                	cmp    %esi,%ecx
  801382:	7d 0c                	jge    801390 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801384:	42                   	inc    %edx
  801385:	0f af c6             	imul   %esi,%eax
  801388:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80138a:	eb c4                	jmp    801350 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  80138c:	89 c1                	mov    %eax,%ecx
  80138e:	eb 02                	jmp    801392 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801390:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801392:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801396:	74 05                	je     80139d <strtol+0xbd>
		*endptr = (char *) s;
  801398:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80139b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  80139d:	85 ff                	test   %edi,%edi
  80139f:	74 04                	je     8013a5 <strtol+0xc5>
  8013a1:	89 c8                	mov    %ecx,%eax
  8013a3:	f7 d8                	neg    %eax
}
  8013a5:	5b                   	pop    %ebx
  8013a6:	5e                   	pop    %esi
  8013a7:	5f                   	pop    %edi
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    
	...

008013ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	57                   	push   %edi
  8013b0:	56                   	push   %esi
  8013b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8013bd:	89 c3                	mov    %eax,%ebx
  8013bf:	89 c7                	mov    %eax,%edi
  8013c1:	89 c6                	mov    %eax,%esi
  8013c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8013c5:	5b                   	pop    %ebx
  8013c6:	5e                   	pop    %esi
  8013c7:	5f                   	pop    %edi
  8013c8:	5d                   	pop    %ebp
  8013c9:	c3                   	ret    

008013ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	57                   	push   %edi
  8013ce:	56                   	push   %esi
  8013cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8013da:	89 d1                	mov    %edx,%ecx
  8013dc:	89 d3                	mov    %edx,%ebx
  8013de:	89 d7                	mov    %edx,%edi
  8013e0:	89 d6                	mov    %edx,%esi
  8013e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8013e4:	5b                   	pop    %ebx
  8013e5:	5e                   	pop    %esi
  8013e6:	5f                   	pop    %edi
  8013e7:	5d                   	pop    %ebp
  8013e8:	c3                   	ret    

008013e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8013e9:	55                   	push   %ebp
  8013ea:	89 e5                	mov    %esp,%ebp
  8013ec:	57                   	push   %edi
  8013ed:	56                   	push   %esi
  8013ee:	53                   	push   %ebx
  8013ef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8013fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ff:	89 cb                	mov    %ecx,%ebx
  801401:	89 cf                	mov    %ecx,%edi
  801403:	89 ce                	mov    %ecx,%esi
  801405:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801407:	85 c0                	test   %eax,%eax
  801409:	7e 28                	jle    801433 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80140b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80140f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801416:	00 
  801417:	c7 44 24 08 03 37 80 	movl   $0x803703,0x8(%esp)
  80141e:	00 
  80141f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801426:	00 
  801427:	c7 04 24 20 37 80 00 	movl   $0x803720,(%esp)
  80142e:	e8 b1 f5 ff ff       	call   8009e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801433:	83 c4 2c             	add    $0x2c,%esp
  801436:	5b                   	pop    %ebx
  801437:	5e                   	pop    %esi
  801438:	5f                   	pop    %edi
  801439:	5d                   	pop    %ebp
  80143a:	c3                   	ret    

0080143b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	57                   	push   %edi
  80143f:	56                   	push   %esi
  801440:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801441:	ba 00 00 00 00       	mov    $0x0,%edx
  801446:	b8 02 00 00 00       	mov    $0x2,%eax
  80144b:	89 d1                	mov    %edx,%ecx
  80144d:	89 d3                	mov    %edx,%ebx
  80144f:	89 d7                	mov    %edx,%edi
  801451:	89 d6                	mov    %edx,%esi
  801453:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801455:	5b                   	pop    %ebx
  801456:	5e                   	pop    %esi
  801457:	5f                   	pop    %edi
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <sys_yield>:

void
sys_yield(void)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	57                   	push   %edi
  80145e:	56                   	push   %esi
  80145f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801460:	ba 00 00 00 00       	mov    $0x0,%edx
  801465:	b8 0b 00 00 00       	mov    $0xb,%eax
  80146a:	89 d1                	mov    %edx,%ecx
  80146c:	89 d3                	mov    %edx,%ebx
  80146e:	89 d7                	mov    %edx,%edi
  801470:	89 d6                	mov    %edx,%esi
  801472:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801474:	5b                   	pop    %ebx
  801475:	5e                   	pop    %esi
  801476:	5f                   	pop    %edi
  801477:	5d                   	pop    %ebp
  801478:	c3                   	ret    

00801479 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801479:	55                   	push   %ebp
  80147a:	89 e5                	mov    %esp,%ebp
  80147c:	57                   	push   %edi
  80147d:	56                   	push   %esi
  80147e:	53                   	push   %ebx
  80147f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801482:	be 00 00 00 00       	mov    $0x0,%esi
  801487:	b8 04 00 00 00       	mov    $0x4,%eax
  80148c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80148f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801492:	8b 55 08             	mov    0x8(%ebp),%edx
  801495:	89 f7                	mov    %esi,%edi
  801497:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801499:	85 c0                	test   %eax,%eax
  80149b:	7e 28                	jle    8014c5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80149d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014a1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8014a8:	00 
  8014a9:	c7 44 24 08 03 37 80 	movl   $0x803703,0x8(%esp)
  8014b0:	00 
  8014b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014b8:	00 
  8014b9:	c7 04 24 20 37 80 00 	movl   $0x803720,(%esp)
  8014c0:	e8 1f f5 ff ff       	call   8009e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8014c5:	83 c4 2c             	add    $0x2c,%esp
  8014c8:	5b                   	pop    %ebx
  8014c9:	5e                   	pop    %esi
  8014ca:	5f                   	pop    %edi
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    

008014cd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	57                   	push   %edi
  8014d1:	56                   	push   %esi
  8014d2:	53                   	push   %ebx
  8014d3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8014db:	8b 75 18             	mov    0x18(%ebp),%esi
  8014de:	8b 7d 14             	mov    0x14(%ebp),%edi
  8014e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8014e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8014ea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8014ec:	85 c0                	test   %eax,%eax
  8014ee:	7e 28                	jle    801518 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014f4:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8014fb:	00 
  8014fc:	c7 44 24 08 03 37 80 	movl   $0x803703,0x8(%esp)
  801503:	00 
  801504:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80150b:	00 
  80150c:	c7 04 24 20 37 80 00 	movl   $0x803720,(%esp)
  801513:	e8 cc f4 ff ff       	call   8009e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801518:	83 c4 2c             	add    $0x2c,%esp
  80151b:	5b                   	pop    %ebx
  80151c:	5e                   	pop    %esi
  80151d:	5f                   	pop    %edi
  80151e:	5d                   	pop    %ebp
  80151f:	c3                   	ret    

00801520 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	57                   	push   %edi
  801524:	56                   	push   %esi
  801525:	53                   	push   %ebx
  801526:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801529:	bb 00 00 00 00       	mov    $0x0,%ebx
  80152e:	b8 06 00 00 00       	mov    $0x6,%eax
  801533:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801536:	8b 55 08             	mov    0x8(%ebp),%edx
  801539:	89 df                	mov    %ebx,%edi
  80153b:	89 de                	mov    %ebx,%esi
  80153d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80153f:	85 c0                	test   %eax,%eax
  801541:	7e 28                	jle    80156b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801543:	89 44 24 10          	mov    %eax,0x10(%esp)
  801547:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80154e:	00 
  80154f:	c7 44 24 08 03 37 80 	movl   $0x803703,0x8(%esp)
  801556:	00 
  801557:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80155e:	00 
  80155f:	c7 04 24 20 37 80 00 	movl   $0x803720,(%esp)
  801566:	e8 79 f4 ff ff       	call   8009e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80156b:	83 c4 2c             	add    $0x2c,%esp
  80156e:	5b                   	pop    %ebx
  80156f:	5e                   	pop    %esi
  801570:	5f                   	pop    %edi
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    

00801573 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	57                   	push   %edi
  801577:	56                   	push   %esi
  801578:	53                   	push   %ebx
  801579:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80157c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801581:	b8 08 00 00 00       	mov    $0x8,%eax
  801586:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801589:	8b 55 08             	mov    0x8(%ebp),%edx
  80158c:	89 df                	mov    %ebx,%edi
  80158e:	89 de                	mov    %ebx,%esi
  801590:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801592:	85 c0                	test   %eax,%eax
  801594:	7e 28                	jle    8015be <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801596:	89 44 24 10          	mov    %eax,0x10(%esp)
  80159a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8015a1:	00 
  8015a2:	c7 44 24 08 03 37 80 	movl   $0x803703,0x8(%esp)
  8015a9:	00 
  8015aa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015b1:	00 
  8015b2:	c7 04 24 20 37 80 00 	movl   $0x803720,(%esp)
  8015b9:	e8 26 f4 ff ff       	call   8009e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8015be:	83 c4 2c             	add    $0x2c,%esp
  8015c1:	5b                   	pop    %ebx
  8015c2:	5e                   	pop    %esi
  8015c3:	5f                   	pop    %edi
  8015c4:	5d                   	pop    %ebp
  8015c5:	c3                   	ret    

008015c6 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	57                   	push   %edi
  8015ca:	56                   	push   %esi
  8015cb:	53                   	push   %ebx
  8015cc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d4:	b8 09 00 00 00       	mov    $0x9,%eax
  8015d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8015df:	89 df                	mov    %ebx,%edi
  8015e1:	89 de                	mov    %ebx,%esi
  8015e3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015e5:	85 c0                	test   %eax,%eax
  8015e7:	7e 28                	jle    801611 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015ed:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8015f4:	00 
  8015f5:	c7 44 24 08 03 37 80 	movl   $0x803703,0x8(%esp)
  8015fc:	00 
  8015fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801604:	00 
  801605:	c7 04 24 20 37 80 00 	movl   $0x803720,(%esp)
  80160c:	e8 d3 f3 ff ff       	call   8009e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801611:	83 c4 2c             	add    $0x2c,%esp
  801614:	5b                   	pop    %ebx
  801615:	5e                   	pop    %esi
  801616:	5f                   	pop    %edi
  801617:	5d                   	pop    %ebp
  801618:	c3                   	ret    

00801619 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	57                   	push   %edi
  80161d:	56                   	push   %esi
  80161e:	53                   	push   %ebx
  80161f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801622:	bb 00 00 00 00       	mov    $0x0,%ebx
  801627:	b8 0a 00 00 00       	mov    $0xa,%eax
  80162c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80162f:	8b 55 08             	mov    0x8(%ebp),%edx
  801632:	89 df                	mov    %ebx,%edi
  801634:	89 de                	mov    %ebx,%esi
  801636:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801638:	85 c0                	test   %eax,%eax
  80163a:	7e 28                	jle    801664 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80163c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801640:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801647:	00 
  801648:	c7 44 24 08 03 37 80 	movl   $0x803703,0x8(%esp)
  80164f:	00 
  801650:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801657:	00 
  801658:	c7 04 24 20 37 80 00 	movl   $0x803720,(%esp)
  80165f:	e8 80 f3 ff ff       	call   8009e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801664:	83 c4 2c             	add    $0x2c,%esp
  801667:	5b                   	pop    %ebx
  801668:	5e                   	pop    %esi
  801669:	5f                   	pop    %edi
  80166a:	5d                   	pop    %ebp
  80166b:	c3                   	ret    

0080166c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	57                   	push   %edi
  801670:	56                   	push   %esi
  801671:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801672:	be 00 00 00 00       	mov    $0x0,%esi
  801677:	b8 0c 00 00 00       	mov    $0xc,%eax
  80167c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80167f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801682:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801685:	8b 55 08             	mov    0x8(%ebp),%edx
  801688:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80168a:	5b                   	pop    %ebx
  80168b:	5e                   	pop    %esi
  80168c:	5f                   	pop    %edi
  80168d:	5d                   	pop    %ebp
  80168e:	c3                   	ret    

0080168f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	57                   	push   %edi
  801693:	56                   	push   %esi
  801694:	53                   	push   %ebx
  801695:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801698:	b9 00 00 00 00       	mov    $0x0,%ecx
  80169d:	b8 0d 00 00 00       	mov    $0xd,%eax
  8016a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8016a5:	89 cb                	mov    %ecx,%ebx
  8016a7:	89 cf                	mov    %ecx,%edi
  8016a9:	89 ce                	mov    %ecx,%esi
  8016ab:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	7e 28                	jle    8016d9 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016b1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016b5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8016bc:	00 
  8016bd:	c7 44 24 08 03 37 80 	movl   $0x803703,0x8(%esp)
  8016c4:	00 
  8016c5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8016cc:	00 
  8016cd:	c7 04 24 20 37 80 00 	movl   $0x803720,(%esp)
  8016d4:	e8 0b f3 ff ff       	call   8009e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8016d9:	83 c4 2c             	add    $0x2c,%esp
  8016dc:	5b                   	pop    %ebx
  8016dd:	5e                   	pop    %esi
  8016de:	5f                   	pop    %edi
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	57                   	push   %edi
  8016e5:	56                   	push   %esi
  8016e6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ec:	b8 0e 00 00 00       	mov    $0xe,%eax
  8016f1:	89 d1                	mov    %edx,%ecx
  8016f3:	89 d3                	mov    %edx,%ebx
  8016f5:	89 d7                	mov    %edx,%edi
  8016f7:	89 d6                	mov    %edx,%esi
  8016f9:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8016fb:	5b                   	pop    %ebx
  8016fc:	5e                   	pop    %esi
  8016fd:	5f                   	pop    %edi
  8016fe:	5d                   	pop    %ebp
  8016ff:	c3                   	ret    

00801700 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	57                   	push   %edi
  801704:	56                   	push   %esi
  801705:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801706:	bb 00 00 00 00       	mov    $0x0,%ebx
  80170b:	b8 0f 00 00 00       	mov    $0xf,%eax
  801710:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801713:	8b 55 08             	mov    0x8(%ebp),%edx
  801716:	89 df                	mov    %ebx,%edi
  801718:	89 de                	mov    %ebx,%esi
  80171a:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  80171c:	5b                   	pop    %ebx
  80171d:	5e                   	pop    %esi
  80171e:	5f                   	pop    %edi
  80171f:	5d                   	pop    %ebp
  801720:	c3                   	ret    

00801721 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	57                   	push   %edi
  801725:	56                   	push   %esi
  801726:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801727:	bb 00 00 00 00       	mov    $0x0,%ebx
  80172c:	b8 10 00 00 00       	mov    $0x10,%eax
  801731:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801734:	8b 55 08             	mov    0x8(%ebp),%edx
  801737:	89 df                	mov    %ebx,%edi
  801739:	89 de                	mov    %ebx,%esi
  80173b:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  80173d:	5b                   	pop    %ebx
  80173e:	5e                   	pop    %esi
  80173f:	5f                   	pop    %edi
  801740:	5d                   	pop    %ebp
  801741:	c3                   	ret    
	...

00801744 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	53                   	push   %ebx
  801748:	83 ec 24             	sub    $0x24,%esp
  80174b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80174e:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(err & FEC_WR) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_COW))
  801750:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801754:	74 2d                	je     801783 <pgfault+0x3f>
  801756:	89 d8                	mov    %ebx,%eax
  801758:	c1 e8 16             	shr    $0x16,%eax
  80175b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801762:	a8 01                	test   $0x1,%al
  801764:	74 1d                	je     801783 <pgfault+0x3f>
  801766:	89 d8                	mov    %ebx,%eax
  801768:	c1 e8 0c             	shr    $0xc,%eax
  80176b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801772:	f6 c2 01             	test   $0x1,%dl
  801775:	74 0c                	je     801783 <pgfault+0x3f>
  801777:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80177e:	f6 c4 08             	test   $0x8,%ah
  801781:	75 1c                	jne    80179f <pgfault+0x5b>
	{
		panic("pgfault error, not copy on write\n");
  801783:	c7 44 24 08 30 37 80 	movl   $0x803730,0x8(%esp)
  80178a:	00 
  80178b:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801792:	00 
  801793:	c7 04 24 73 37 80 00 	movl   $0x803773,(%esp)
  80179a:	e8 45 f2 ff ff       	call   8009e4 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	void *va = (void *)ROUNDDOWN(addr, PGSIZE);
  80179f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	sys_page_alloc(0, (void *)PFTEMP, PTE_W | PTE_U | PTE_P);
  8017a5:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8017ac:	00 
  8017ad:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8017b4:	00 
  8017b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017bc:	e8 b8 fc ff ff       	call   801479 <sys_page_alloc>
	memcpy((void *)PFTEMP, va, PGSIZE);
  8017c1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8017c8:	00 
  8017c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017cd:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8017d4:	e8 91 fa ff ff       	call   80126a <memcpy>
	sys_page_map(0, (void *)PFTEMP, 0, va, PTE_W | PTE_P | PTE_U);
  8017d9:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8017e0:	00 
  8017e1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8017e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017ec:	00 
  8017ed:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8017f4:	00 
  8017f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017fc:	e8 cc fc ff ff       	call   8014cd <sys_page_map>
	sys_page_unmap(0, (void *)PFTEMP);
  801801:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801808:	00 
  801809:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801810:	e8 0b fd ff ff       	call   801520 <sys_page_unmap>

	// panic("pgfault not implemented");
}
  801815:	83 c4 24             	add    $0x24,%esp
  801818:	5b                   	pop    %ebx
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    

0080181b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	57                   	push   %edi
  80181f:	56                   	push   %esi
  801820:	53                   	push   %ebx
  801821:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  801824:	c7 04 24 44 17 80 00 	movl   $0x801744,(%esp)
  80182b:	e8 ac 16 00 00       	call   802edc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801830:	ba 07 00 00 00       	mov    $0x7,%edx
  801835:	89 d0                	mov    %edx,%eax
  801837:	cd 30                	int    $0x30
  801839:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80183c:	89 c7                	mov    %eax,%edi
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80183e:	85 c0                	test   %eax,%eax
  801840:	79 20                	jns    801862 <fork+0x47>
		panic("sys_exofork: %e", envid);
  801842:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801846:	c7 44 24 08 7e 37 80 	movl   $0x80377e,0x8(%esp)
  80184d:	00 
  80184e:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  801855:	00 
  801856:	c7 04 24 73 37 80 00 	movl   $0x803773,(%esp)
  80185d:	e8 82 f1 ff ff       	call   8009e4 <_panic>
	if (envid == 0)
  801862:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801866:	75 25                	jne    80188d <fork+0x72>
	{
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  801868:	e8 ce fb ff ff       	call   80143b <sys_getenvid>
  80186d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801872:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801879:	c1 e0 07             	shl    $0x7,%eax
  80187c:	29 d0                	sub    %edx,%eax
  80187e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801883:	a3 20 50 80 00       	mov    %eax,0x805020
		return 0;
  801888:	e9 43 02 00 00       	jmp    801ad0 <fork+0x2b5>
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
		panic("sys_exofork: %e", envid);
	if (envid == 0)
  80188d:	bb 00 00 00 00       	mov    $0x0,%ebx
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
		if (((uintptr_t)addr == UXSTACKTOP - PGSIZE) || !(uvpd[PDX(addr)] & PTE_P) || !(uvpt[PGNUM(addr)] & PTE_P))
  801892:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801898:	0f 84 85 01 00 00    	je     801a23 <fork+0x208>
  80189e:	89 d8                	mov    %ebx,%eax
  8018a0:	c1 e8 16             	shr    $0x16,%eax
  8018a3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018aa:	a8 01                	test   $0x1,%al
  8018ac:	0f 84 5f 01 00 00    	je     801a11 <fork+0x1f6>
  8018b2:	89 d8                	mov    %ebx,%eax
  8018b4:	c1 e8 0c             	shr    $0xc,%eax
  8018b7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018be:	f6 c2 01             	test   $0x1,%dl
  8018c1:	0f 84 4a 01 00 00    	je     801a11 <fork+0x1f6>
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
	{
		addr = (uint8_t *)(pn * PGSIZE);
  8018c7:	89 de                	mov    %ebx,%esi

	// LAB 4: Your code here.
	r = pn * PGSIZE;
	// int perm = uvpt[PGNUM(r)] & PTE_SYSCALL & ~PTE_W;
	int perm = PTE_U | PTE_P;
	if ((uvpt[PGNUM(r)] & PTE_SHARE))
  8018c9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018d0:	f6 c6 04             	test   $0x4,%dh
  8018d3:	74 50                	je     801925 <fork+0x10a>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, uvpt[PGNUM(r)] & PTE_SYSCALL)) < 0)
  8018d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8018e1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8018e9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8018ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018f8:	e8 d0 fb ff ff       	call   8014cd <sys_page_map>
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	0f 89 0c 01 00 00    	jns    801a11 <fork+0x1f6>
		{
			panic("duppage error: %e", e);
  801905:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801909:	c7 44 24 08 8e 37 80 	movl   $0x80378e,0x8(%esp)
  801910:	00 
  801911:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  801918:	00 
  801919:	c7 04 24 73 37 80 00 	movl   $0x803773,(%esp)
  801920:	e8 bf f0 ff ff       	call   8009e4 <_panic>
		}
		return 0;
	}
	if ((uvpt[PGNUM(r)] & PTE_W) || (uvpt[PGNUM(r)] & PTE_COW))
  801925:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80192c:	f6 c2 02             	test   $0x2,%dl
  80192f:	75 10                	jne    801941 <fork+0x126>
  801931:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801938:	f6 c4 08             	test   $0x8,%ah
  80193b:	0f 84 8c 00 00 00    	je     8019cd <fork+0x1b2>
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm | PTE_COW)) < 0)
  801941:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  801948:	00 
  801949:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80194d:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801951:	89 74 24 04          	mov    %esi,0x4(%esp)
  801955:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80195c:	e8 6c fb ff ff       	call   8014cd <sys_page_map>
  801961:	85 c0                	test   %eax,%eax
  801963:	79 20                	jns    801985 <fork+0x16a>
		{
			panic("duppage error: %e",e);
  801965:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801969:	c7 44 24 08 8e 37 80 	movl   $0x80378e,0x8(%esp)
  801970:	00 
  801971:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801978:	00 
  801979:	c7 04 24 73 37 80 00 	movl   $0x803773,(%esp)
  801980:	e8 5f f0 ff ff       	call   8009e4 <_panic>
		}
		if ((e = sys_page_map(0, (void *)r, 0, (void *)r, perm | PTE_COW)) < 0)
  801985:	c7 44 24 10 05 08 00 	movl   $0x805,0x10(%esp)
  80198c:	00 
  80198d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801991:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801998:	00 
  801999:	89 74 24 04          	mov    %esi,0x4(%esp)
  80199d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019a4:	e8 24 fb ff ff       	call   8014cd <sys_page_map>
  8019a9:	85 c0                	test   %eax,%eax
  8019ab:	79 64                	jns    801a11 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  8019ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019b1:	c7 44 24 08 8e 37 80 	movl   $0x80378e,0x8(%esp)
  8019b8:	00 
  8019b9:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  8019c0:	00 
  8019c1:	c7 04 24 73 37 80 00 	movl   $0x803773,(%esp)
  8019c8:	e8 17 f0 ff ff       	call   8009e4 <_panic>
		}
	}
	else
	{
		if ((e = sys_page_map(0, (void *)r, envid, (void *)r, perm)) < 0)
  8019cd:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8019d4:	00 
  8019d5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8019d9:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8019dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019e8:	e8 e0 fa ff ff       	call   8014cd <sys_page_map>
  8019ed:	85 c0                	test   %eax,%eax
  8019ef:	79 20                	jns    801a11 <fork+0x1f6>
		{
			panic("duppage error: %e",e);
  8019f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019f5:	c7 44 24 08 8e 37 80 	movl   $0x80378e,0x8(%esp)
  8019fc:	00 
  8019fd:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801a04:	00 
  801a05:	c7 04 24 73 37 80 00 	movl   $0x803773,(%esp)
  801a0c:	e8 d3 ef ff ff       	call   8009e4 <_panic>
  801a11:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (uint32_t pn = 0; pn < UTOP / PGSIZE; ++pn)
  801a17:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801a1d:	0f 85 6f fe ff ff    	jne    801892 <fork+0x77>
			continue;
		}
		duppage(envid, pn);
	}

	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P)) < 0)
  801a23:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801a2a:	00 
  801a2b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801a32:	ee 
  801a33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a36:	89 04 24             	mov    %eax,(%esp)
  801a39:	e8 3b fa ff ff       	call   801479 <sys_page_alloc>
  801a3e:	85 c0                	test   %eax,%eax
  801a40:	79 20                	jns    801a62 <fork+0x247>
	{
		panic("sys_page_alloc: %e", r);
  801a42:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a46:	c7 44 24 08 50 33 80 	movl   $0x803350,0x8(%esp)
  801a4d:	00 
  801a4e:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
  801a55:	00 
  801a56:	c7 04 24 73 37 80 00 	movl   $0x803773,(%esp)
  801a5d:	e8 82 ef ff ff       	call   8009e4 <_panic>
	}
	extern void _pgfault_upcall(void);
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801a62:	c7 44 24 04 28 2f 80 	movl   $0x802f28,0x4(%esp)
  801a69:	00 
  801a6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a6d:	89 04 24             	mov    %eax,(%esp)
  801a70:	e8 a4 fb ff ff       	call   801619 <sys_env_set_pgfault_upcall>
  801a75:	85 c0                	test   %eax,%eax
  801a77:	79 20                	jns    801a99 <fork+0x27e>
	{
		panic("sys_env_set_pgfault_upcall: %e", r);
  801a79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a7d:	c7 44 24 08 54 37 80 	movl   $0x803754,0x8(%esp)
  801a84:	00 
  801a85:	c7 44 24 04 a3 00 00 	movl   $0xa3,0x4(%esp)
  801a8c:	00 
  801a8d:	c7 04 24 73 37 80 00 	movl   $0x803773,(%esp)
  801a94:	e8 4b ef ff ff       	call   8009e4 <_panic>
	}
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801a99:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801aa0:	00 
  801aa1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aa4:	89 04 24             	mov    %eax,(%esp)
  801aa7:	e8 c7 fa ff ff       	call   801573 <sys_env_set_status>
  801aac:	85 c0                	test   %eax,%eax
  801aae:	79 20                	jns    801ad0 <fork+0x2b5>
		panic("sys_env_set_status: %e", r);
  801ab0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ab4:	c7 44 24 08 a0 37 80 	movl   $0x8037a0,0x8(%esp)
  801abb:	00 
  801abc:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801ac3:	00 
  801ac4:	c7 04 24 73 37 80 00 	movl   $0x803773,(%esp)
  801acb:	e8 14 ef ff ff       	call   8009e4 <_panic>

	return envid;
	// panic("fork not implemented");
}
  801ad0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ad3:	83 c4 3c             	add    $0x3c,%esp
  801ad6:	5b                   	pop    %ebx
  801ad7:	5e                   	pop    %esi
  801ad8:	5f                   	pop    %edi
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <sfork>:

// Challenge!
int
sfork(void)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801ae1:	c7 44 24 08 b7 37 80 	movl   $0x8037b7,0x8(%esp)
  801ae8:	00 
  801ae9:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801af0:	00 
  801af1:	c7 04 24 73 37 80 00 	movl   $0x803773,(%esp)
  801af8:	e8 e7 ee ff ff       	call   8009e4 <_panic>
  801afd:	00 00                	add    %al,(%eax)
	...

00801b00 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	56                   	push   %esi
  801b04:	53                   	push   %ebx
  801b05:	83 ec 10             	sub    $0x10,%esp
  801b08:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b0e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  801b11:	85 c0                	test   %eax,%eax
  801b13:	74 0a                	je     801b1f <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  801b15:	89 04 24             	mov    %eax,(%esp)
  801b18:	e8 72 fb ff ff       	call   80168f <sys_ipc_recv>
  801b1d:	eb 0c                	jmp    801b2b <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  801b1f:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801b26:	e8 64 fb ff ff       	call   80168f <sys_ipc_recv>
	}
	if (r < 0)
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	79 16                	jns    801b45 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  801b2f:	85 db                	test   %ebx,%ebx
  801b31:	74 06                	je     801b39 <ipc_recv+0x39>
  801b33:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  801b39:	85 f6                	test   %esi,%esi
  801b3b:	74 2c                	je     801b69 <ipc_recv+0x69>
  801b3d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801b43:	eb 24                	jmp    801b69 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  801b45:	85 db                	test   %ebx,%ebx
  801b47:	74 0a                	je     801b53 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  801b49:	a1 20 50 80 00       	mov    0x805020,%eax
  801b4e:	8b 40 74             	mov    0x74(%eax),%eax
  801b51:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  801b53:	85 f6                	test   %esi,%esi
  801b55:	74 0a                	je     801b61 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  801b57:	a1 20 50 80 00       	mov    0x805020,%eax
  801b5c:	8b 40 78             	mov    0x78(%eax),%eax
  801b5f:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  801b61:	a1 20 50 80 00       	mov    0x805020,%eax
  801b66:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  801b69:	83 c4 10             	add    $0x10,%esp
  801b6c:	5b                   	pop    %ebx
  801b6d:	5e                   	pop    %esi
  801b6e:	5d                   	pop    %ebp
  801b6f:	c3                   	ret    

00801b70 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	57                   	push   %edi
  801b74:	56                   	push   %esi
  801b75:	53                   	push   %ebx
  801b76:	83 ec 1c             	sub    $0x1c,%esp
  801b79:	8b 75 08             	mov    0x8(%ebp),%esi
  801b7c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  801b82:	85 db                	test   %ebx,%ebx
  801b84:	74 19                	je     801b9f <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  801b86:	8b 45 14             	mov    0x14(%ebp),%eax
  801b89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b8d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b91:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b95:	89 34 24             	mov    %esi,(%esp)
  801b98:	e8 cf fa ff ff       	call   80166c <sys_ipc_try_send>
  801b9d:	eb 1c                	jmp    801bbb <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  801b9f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ba6:	00 
  801ba7:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  801bae:	ee 
  801baf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bb3:	89 34 24             	mov    %esi,(%esp)
  801bb6:	e8 b1 fa ff ff       	call   80166c <sys_ipc_try_send>
		}
		if (r == 0)
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	74 2c                	je     801beb <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  801bbf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bc2:	74 20                	je     801be4 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  801bc4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bc8:	c7 44 24 08 cd 37 80 	movl   $0x8037cd,0x8(%esp)
  801bcf:	00 
  801bd0:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801bd7:	00 
  801bd8:	c7 04 24 e0 37 80 00 	movl   $0x8037e0,(%esp)
  801bdf:	e8 00 ee ff ff       	call   8009e4 <_panic>
		}
		sys_yield();
  801be4:	e8 71 f8 ff ff       	call   80145a <sys_yield>
	}
  801be9:	eb 97                	jmp    801b82 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  801beb:	83 c4 1c             	add    $0x1c,%esp
  801bee:	5b                   	pop    %ebx
  801bef:	5e                   	pop    %esi
  801bf0:	5f                   	pop    %edi
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    

00801bf3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	53                   	push   %ebx
  801bf7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801bfa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bff:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801c06:	89 c2                	mov    %eax,%edx
  801c08:	c1 e2 07             	shl    $0x7,%edx
  801c0b:	29 ca                	sub    %ecx,%edx
  801c0d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c13:	8b 52 50             	mov    0x50(%edx),%edx
  801c16:	39 da                	cmp    %ebx,%edx
  801c18:	75 0f                	jne    801c29 <ipc_find_env+0x36>
			return envs[i].env_id;
  801c1a:	c1 e0 07             	shl    $0x7,%eax
  801c1d:	29 c8                	sub    %ecx,%eax
  801c1f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801c24:	8b 40 40             	mov    0x40(%eax),%eax
  801c27:	eb 0c                	jmp    801c35 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c29:	40                   	inc    %eax
  801c2a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c2f:	75 ce                	jne    801bff <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c31:	66 b8 00 00          	mov    $0x0,%ax
}
  801c35:	5b                   	pop    %ebx
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    

00801c38 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3e:	05 00 00 00 30       	add    $0x30000000,%eax
  801c43:	c1 e8 0c             	shr    $0xc,%eax
}
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    

00801c48 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c51:	89 04 24             	mov    %eax,(%esp)
  801c54:	e8 df ff ff ff       	call   801c38 <fd2num>
  801c59:	c1 e0 0c             	shl    $0xc,%eax
  801c5c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801c61:	c9                   	leave  
  801c62:	c3                   	ret    

00801c63 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	53                   	push   %ebx
  801c67:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801c6a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  801c6f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801c71:	89 c2                	mov    %eax,%edx
  801c73:	c1 ea 16             	shr    $0x16,%edx
  801c76:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c7d:	f6 c2 01             	test   $0x1,%dl
  801c80:	74 11                	je     801c93 <fd_alloc+0x30>
  801c82:	89 c2                	mov    %eax,%edx
  801c84:	c1 ea 0c             	shr    $0xc,%edx
  801c87:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c8e:	f6 c2 01             	test   $0x1,%dl
  801c91:	75 09                	jne    801c9c <fd_alloc+0x39>
			*fd_store = fd;
  801c93:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801c95:	b8 00 00 00 00       	mov    $0x0,%eax
  801c9a:	eb 17                	jmp    801cb3 <fd_alloc+0x50>
  801c9c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801ca1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801ca6:	75 c7                	jne    801c6f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801ca8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801cae:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801cb3:	5b                   	pop    %ebx
  801cb4:	5d                   	pop    %ebp
  801cb5:	c3                   	ret    

00801cb6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801cbc:	83 f8 1f             	cmp    $0x1f,%eax
  801cbf:	77 36                	ja     801cf7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801cc1:	c1 e0 0c             	shl    $0xc,%eax
  801cc4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801cc9:	89 c2                	mov    %eax,%edx
  801ccb:	c1 ea 16             	shr    $0x16,%edx
  801cce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801cd5:	f6 c2 01             	test   $0x1,%dl
  801cd8:	74 24                	je     801cfe <fd_lookup+0x48>
  801cda:	89 c2                	mov    %eax,%edx
  801cdc:	c1 ea 0c             	shr    $0xc,%edx
  801cdf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ce6:	f6 c2 01             	test   $0x1,%dl
  801ce9:	74 1a                	je     801d05 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801ceb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cee:	89 02                	mov    %eax,(%edx)
	return 0;
  801cf0:	b8 00 00 00 00       	mov    $0x0,%eax
  801cf5:	eb 13                	jmp    801d0a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cf7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801cfc:	eb 0c                	jmp    801d0a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801cfe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801d03:	eb 05                	jmp    801d0a <fd_lookup+0x54>
  801d05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801d0a:	5d                   	pop    %ebp
  801d0b:	c3                   	ret    

00801d0c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	53                   	push   %ebx
  801d10:	83 ec 14             	sub    $0x14,%esp
  801d13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801d19:	ba 00 00 00 00       	mov    $0x0,%edx
  801d1e:	eb 0e                	jmp    801d2e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801d20:	39 08                	cmp    %ecx,(%eax)
  801d22:	75 09                	jne    801d2d <dev_lookup+0x21>
			*dev = devtab[i];
  801d24:	89 03                	mov    %eax,(%ebx)
			return 0;
  801d26:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2b:	eb 33                	jmp    801d60 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801d2d:	42                   	inc    %edx
  801d2e:	8b 04 95 6c 38 80 00 	mov    0x80386c(,%edx,4),%eax
  801d35:	85 c0                	test   %eax,%eax
  801d37:	75 e7                	jne    801d20 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801d39:	a1 20 50 80 00       	mov    0x805020,%eax
  801d3e:	8b 40 48             	mov    0x48(%eax),%eax
  801d41:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d49:	c7 04 24 ec 37 80 00 	movl   $0x8037ec,(%esp)
  801d50:	e8 87 ed ff ff       	call   800adc <cprintf>
	*dev = 0;
  801d55:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  801d5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801d60:	83 c4 14             	add    $0x14,%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5d                   	pop    %ebp
  801d65:	c3                   	ret    

00801d66 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	56                   	push   %esi
  801d6a:	53                   	push   %ebx
  801d6b:	83 ec 30             	sub    $0x30,%esp
  801d6e:	8b 75 08             	mov    0x8(%ebp),%esi
  801d71:	8a 45 0c             	mov    0xc(%ebp),%al
  801d74:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d77:	89 34 24             	mov    %esi,(%esp)
  801d7a:	e8 b9 fe ff ff       	call   801c38 <fd2num>
  801d7f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d82:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d86:	89 04 24             	mov    %eax,(%esp)
  801d89:	e8 28 ff ff ff       	call   801cb6 <fd_lookup>
  801d8e:	89 c3                	mov    %eax,%ebx
  801d90:	85 c0                	test   %eax,%eax
  801d92:	78 05                	js     801d99 <fd_close+0x33>
	    || fd != fd2)
  801d94:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d97:	74 0d                	je     801da6 <fd_close+0x40>
		return (must_exist ? r : 0);
  801d99:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801d9d:	75 46                	jne    801de5 <fd_close+0x7f>
  801d9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801da4:	eb 3f                	jmp    801de5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801da6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801da9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dad:	8b 06                	mov    (%esi),%eax
  801daf:	89 04 24             	mov    %eax,(%esp)
  801db2:	e8 55 ff ff ff       	call   801d0c <dev_lookup>
  801db7:	89 c3                	mov    %eax,%ebx
  801db9:	85 c0                	test   %eax,%eax
  801dbb:	78 18                	js     801dd5 <fd_close+0x6f>
		if (dev->dev_close)
  801dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc0:	8b 40 10             	mov    0x10(%eax),%eax
  801dc3:	85 c0                	test   %eax,%eax
  801dc5:	74 09                	je     801dd0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801dc7:	89 34 24             	mov    %esi,(%esp)
  801dca:	ff d0                	call   *%eax
  801dcc:	89 c3                	mov    %eax,%ebx
  801dce:	eb 05                	jmp    801dd5 <fd_close+0x6f>
		else
			r = 0;
  801dd0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801dd5:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dd9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801de0:	e8 3b f7 ff ff       	call   801520 <sys_page_unmap>
	return r;
}
  801de5:	89 d8                	mov    %ebx,%eax
  801de7:	83 c4 30             	add    $0x30,%esp
  801dea:	5b                   	pop    %ebx
  801deb:	5e                   	pop    %esi
  801dec:	5d                   	pop    %ebp
  801ded:	c3                   	ret    

00801dee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801df4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfe:	89 04 24             	mov    %eax,(%esp)
  801e01:	e8 b0 fe ff ff       	call   801cb6 <fd_lookup>
  801e06:	85 c0                	test   %eax,%eax
  801e08:	78 13                	js     801e1d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801e0a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801e11:	00 
  801e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e15:	89 04 24             	mov    %eax,(%esp)
  801e18:	e8 49 ff ff ff       	call   801d66 <fd_close>
}
  801e1d:	c9                   	leave  
  801e1e:	c3                   	ret    

00801e1f <close_all>:

void
close_all(void)
{
  801e1f:	55                   	push   %ebp
  801e20:	89 e5                	mov    %esp,%ebp
  801e22:	53                   	push   %ebx
  801e23:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801e26:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801e2b:	89 1c 24             	mov    %ebx,(%esp)
  801e2e:	e8 bb ff ff ff       	call   801dee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801e33:	43                   	inc    %ebx
  801e34:	83 fb 20             	cmp    $0x20,%ebx
  801e37:	75 f2                	jne    801e2b <close_all+0xc>
		close(i);
}
  801e39:	83 c4 14             	add    $0x14,%esp
  801e3c:	5b                   	pop    %ebx
  801e3d:	5d                   	pop    %ebp
  801e3e:	c3                   	ret    

00801e3f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	57                   	push   %edi
  801e43:	56                   	push   %esi
  801e44:	53                   	push   %ebx
  801e45:	83 ec 4c             	sub    $0x4c,%esp
  801e48:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e4b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e52:	8b 45 08             	mov    0x8(%ebp),%eax
  801e55:	89 04 24             	mov    %eax,(%esp)
  801e58:	e8 59 fe ff ff       	call   801cb6 <fd_lookup>
  801e5d:	89 c3                	mov    %eax,%ebx
  801e5f:	85 c0                	test   %eax,%eax
  801e61:	0f 88 e3 00 00 00    	js     801f4a <dup+0x10b>
		return r;
	close(newfdnum);
  801e67:	89 3c 24             	mov    %edi,(%esp)
  801e6a:	e8 7f ff ff ff       	call   801dee <close>

	newfd = INDEX2FD(newfdnum);
  801e6f:	89 fe                	mov    %edi,%esi
  801e71:	c1 e6 0c             	shl    $0xc,%esi
  801e74:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801e7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e7d:	89 04 24             	mov    %eax,(%esp)
  801e80:	e8 c3 fd ff ff       	call   801c48 <fd2data>
  801e85:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801e87:	89 34 24             	mov    %esi,(%esp)
  801e8a:	e8 b9 fd ff ff       	call   801c48 <fd2data>
  801e8f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801e92:	89 d8                	mov    %ebx,%eax
  801e94:	c1 e8 16             	shr    $0x16,%eax
  801e97:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e9e:	a8 01                	test   $0x1,%al
  801ea0:	74 46                	je     801ee8 <dup+0xa9>
  801ea2:	89 d8                	mov    %ebx,%eax
  801ea4:	c1 e8 0c             	shr    $0xc,%eax
  801ea7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801eae:	f6 c2 01             	test   $0x1,%dl
  801eb1:	74 35                	je     801ee8 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801eb3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801eba:	25 07 0e 00 00       	and    $0xe07,%eax
  801ebf:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ec3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ec6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ed1:	00 
  801ed2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ed6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801edd:	e8 eb f5 ff ff       	call   8014cd <sys_page_map>
  801ee2:	89 c3                	mov    %eax,%ebx
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	78 3b                	js     801f23 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ee8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eeb:	89 c2                	mov    %eax,%edx
  801eed:	c1 ea 0c             	shr    $0xc,%edx
  801ef0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ef7:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801efd:	89 54 24 10          	mov    %edx,0x10(%esp)
  801f01:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801f05:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f0c:	00 
  801f0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f18:	e8 b0 f5 ff ff       	call   8014cd <sys_page_map>
  801f1d:	89 c3                	mov    %eax,%ebx
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	79 25                	jns    801f48 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801f23:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f2e:	e8 ed f5 ff ff       	call   801520 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801f33:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801f36:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f41:	e8 da f5 ff ff       	call   801520 <sys_page_unmap>
	return r;
  801f46:	eb 02                	jmp    801f4a <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801f48:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801f4a:	89 d8                	mov    %ebx,%eax
  801f4c:	83 c4 4c             	add    $0x4c,%esp
  801f4f:	5b                   	pop    %ebx
  801f50:	5e                   	pop    %esi
  801f51:	5f                   	pop    %edi
  801f52:	5d                   	pop    %ebp
  801f53:	c3                   	ret    

00801f54 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	53                   	push   %ebx
  801f58:	83 ec 24             	sub    $0x24,%esp
  801f5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f5e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f61:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f65:	89 1c 24             	mov    %ebx,(%esp)
  801f68:	e8 49 fd ff ff       	call   801cb6 <fd_lookup>
  801f6d:	85 c0                	test   %eax,%eax
  801f6f:	78 6d                	js     801fde <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f7b:	8b 00                	mov    (%eax),%eax
  801f7d:	89 04 24             	mov    %eax,(%esp)
  801f80:	e8 87 fd ff ff       	call   801d0c <dev_lookup>
  801f85:	85 c0                	test   %eax,%eax
  801f87:	78 55                	js     801fde <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801f89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f8c:	8b 50 08             	mov    0x8(%eax),%edx
  801f8f:	83 e2 03             	and    $0x3,%edx
  801f92:	83 fa 01             	cmp    $0x1,%edx
  801f95:	75 23                	jne    801fba <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801f97:	a1 20 50 80 00       	mov    0x805020,%eax
  801f9c:	8b 40 48             	mov    0x48(%eax),%eax
  801f9f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fa3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa7:	c7 04 24 30 38 80 00 	movl   $0x803830,(%esp)
  801fae:	e8 29 eb ff ff       	call   800adc <cprintf>
		return -E_INVAL;
  801fb3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801fb8:	eb 24                	jmp    801fde <read+0x8a>
	}
	if (!dev->dev_read)
  801fba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fbd:	8b 52 08             	mov    0x8(%edx),%edx
  801fc0:	85 d2                	test   %edx,%edx
  801fc2:	74 15                	je     801fd9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801fc4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801fc7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801fd2:	89 04 24             	mov    %eax,(%esp)
  801fd5:	ff d2                	call   *%edx
  801fd7:	eb 05                	jmp    801fde <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801fd9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801fde:	83 c4 24             	add    $0x24,%esp
  801fe1:	5b                   	pop    %ebx
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    

00801fe4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	57                   	push   %edi
  801fe8:	56                   	push   %esi
  801fe9:	53                   	push   %ebx
  801fea:	83 ec 1c             	sub    $0x1c,%esp
  801fed:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ff0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ff3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ff8:	eb 23                	jmp    80201d <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801ffa:	89 f0                	mov    %esi,%eax
  801ffc:	29 d8                	sub    %ebx,%eax
  801ffe:	89 44 24 08          	mov    %eax,0x8(%esp)
  802002:	8b 45 0c             	mov    0xc(%ebp),%eax
  802005:	01 d8                	add    %ebx,%eax
  802007:	89 44 24 04          	mov    %eax,0x4(%esp)
  80200b:	89 3c 24             	mov    %edi,(%esp)
  80200e:	e8 41 ff ff ff       	call   801f54 <read>
		if (m < 0)
  802013:	85 c0                	test   %eax,%eax
  802015:	78 10                	js     802027 <readn+0x43>
			return m;
		if (m == 0)
  802017:	85 c0                	test   %eax,%eax
  802019:	74 0a                	je     802025 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80201b:	01 c3                	add    %eax,%ebx
  80201d:	39 f3                	cmp    %esi,%ebx
  80201f:	72 d9                	jb     801ffa <readn+0x16>
  802021:	89 d8                	mov    %ebx,%eax
  802023:	eb 02                	jmp    802027 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  802025:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  802027:	83 c4 1c             	add    $0x1c,%esp
  80202a:	5b                   	pop    %ebx
  80202b:	5e                   	pop    %esi
  80202c:	5f                   	pop    %edi
  80202d:	5d                   	pop    %ebp
  80202e:	c3                   	ret    

0080202f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80202f:	55                   	push   %ebp
  802030:	89 e5                	mov    %esp,%ebp
  802032:	53                   	push   %ebx
  802033:	83 ec 24             	sub    $0x24,%esp
  802036:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802039:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80203c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802040:	89 1c 24             	mov    %ebx,(%esp)
  802043:	e8 6e fc ff ff       	call   801cb6 <fd_lookup>
  802048:	85 c0                	test   %eax,%eax
  80204a:	78 68                	js     8020b4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80204c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802053:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802056:	8b 00                	mov    (%eax),%eax
  802058:	89 04 24             	mov    %eax,(%esp)
  80205b:	e8 ac fc ff ff       	call   801d0c <dev_lookup>
  802060:	85 c0                	test   %eax,%eax
  802062:	78 50                	js     8020b4 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802064:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802067:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80206b:	75 23                	jne    802090 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80206d:	a1 20 50 80 00       	mov    0x805020,%eax
  802072:	8b 40 48             	mov    0x48(%eax),%eax
  802075:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802079:	89 44 24 04          	mov    %eax,0x4(%esp)
  80207d:	c7 04 24 4c 38 80 00 	movl   $0x80384c,(%esp)
  802084:	e8 53 ea ff ff       	call   800adc <cprintf>
		return -E_INVAL;
  802089:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80208e:	eb 24                	jmp    8020b4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802090:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802093:	8b 52 0c             	mov    0xc(%edx),%edx
  802096:	85 d2                	test   %edx,%edx
  802098:	74 15                	je     8020af <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80209a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80209d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8020a8:	89 04 24             	mov    %eax,(%esp)
  8020ab:	ff d2                	call   *%edx
  8020ad:	eb 05                	jmp    8020b4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8020af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8020b4:	83 c4 24             	add    $0x24,%esp
  8020b7:	5b                   	pop    %ebx
  8020b8:	5d                   	pop    %ebp
  8020b9:	c3                   	ret    

008020ba <seek>:

int
seek(int fdnum, off_t offset)
{
  8020ba:	55                   	push   %ebp
  8020bb:	89 e5                	mov    %esp,%ebp
  8020bd:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020c0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8020c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ca:	89 04 24             	mov    %eax,(%esp)
  8020cd:	e8 e4 fb ff ff       	call   801cb6 <fd_lookup>
  8020d2:	85 c0                	test   %eax,%eax
  8020d4:	78 0e                	js     8020e4 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8020d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8020d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020dc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8020df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020e4:	c9                   	leave  
  8020e5:	c3                   	ret    

008020e6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8020e6:	55                   	push   %ebp
  8020e7:	89 e5                	mov    %esp,%ebp
  8020e9:	53                   	push   %ebx
  8020ea:	83 ec 24             	sub    $0x24,%esp
  8020ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f7:	89 1c 24             	mov    %ebx,(%esp)
  8020fa:	e8 b7 fb ff ff       	call   801cb6 <fd_lookup>
  8020ff:	85 c0                	test   %eax,%eax
  802101:	78 61                	js     802164 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802103:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802106:	89 44 24 04          	mov    %eax,0x4(%esp)
  80210a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80210d:	8b 00                	mov    (%eax),%eax
  80210f:	89 04 24             	mov    %eax,(%esp)
  802112:	e8 f5 fb ff ff       	call   801d0c <dev_lookup>
  802117:	85 c0                	test   %eax,%eax
  802119:	78 49                	js     802164 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80211b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80211e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802122:	75 23                	jne    802147 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802124:	a1 20 50 80 00       	mov    0x805020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802129:	8b 40 48             	mov    0x48(%eax),%eax
  80212c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802130:	89 44 24 04          	mov    %eax,0x4(%esp)
  802134:	c7 04 24 0c 38 80 00 	movl   $0x80380c,(%esp)
  80213b:	e8 9c e9 ff ff       	call   800adc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802140:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802145:	eb 1d                	jmp    802164 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  802147:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80214a:	8b 52 18             	mov    0x18(%edx),%edx
  80214d:	85 d2                	test   %edx,%edx
  80214f:	74 0e                	je     80215f <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802151:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802154:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802158:	89 04 24             	mov    %eax,(%esp)
  80215b:	ff d2                	call   *%edx
  80215d:	eb 05                	jmp    802164 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80215f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  802164:	83 c4 24             	add    $0x24,%esp
  802167:	5b                   	pop    %ebx
  802168:	5d                   	pop    %ebp
  802169:	c3                   	ret    

0080216a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80216a:	55                   	push   %ebp
  80216b:	89 e5                	mov    %esp,%ebp
  80216d:	53                   	push   %ebx
  80216e:	83 ec 24             	sub    $0x24,%esp
  802171:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802174:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802177:	89 44 24 04          	mov    %eax,0x4(%esp)
  80217b:	8b 45 08             	mov    0x8(%ebp),%eax
  80217e:	89 04 24             	mov    %eax,(%esp)
  802181:	e8 30 fb ff ff       	call   801cb6 <fd_lookup>
  802186:	85 c0                	test   %eax,%eax
  802188:	78 52                	js     8021dc <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80218a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80218d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802191:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802194:	8b 00                	mov    (%eax),%eax
  802196:	89 04 24             	mov    %eax,(%esp)
  802199:	e8 6e fb ff ff       	call   801d0c <dev_lookup>
  80219e:	85 c0                	test   %eax,%eax
  8021a0:	78 3a                	js     8021dc <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8021a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8021a9:	74 2c                	je     8021d7 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8021ab:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8021ae:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8021b5:	00 00 00 
	stat->st_isdir = 0;
  8021b8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8021bf:	00 00 00 
	stat->st_dev = dev;
  8021c2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8021c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021cf:	89 14 24             	mov    %edx,(%esp)
  8021d2:	ff 50 14             	call   *0x14(%eax)
  8021d5:	eb 05                	jmp    8021dc <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8021d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8021dc:	83 c4 24             	add    $0x24,%esp
  8021df:	5b                   	pop    %ebx
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    

008021e2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8021e2:	55                   	push   %ebp
  8021e3:	89 e5                	mov    %esp,%ebp
  8021e5:	56                   	push   %esi
  8021e6:	53                   	push   %ebx
  8021e7:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8021ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8021f1:	00 
  8021f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f5:	89 04 24             	mov    %eax,(%esp)
  8021f8:	e8 2a 02 00 00       	call   802427 <open>
  8021fd:	89 c3                	mov    %eax,%ebx
  8021ff:	85 c0                	test   %eax,%eax
  802201:	78 1b                	js     80221e <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  802203:	8b 45 0c             	mov    0xc(%ebp),%eax
  802206:	89 44 24 04          	mov    %eax,0x4(%esp)
  80220a:	89 1c 24             	mov    %ebx,(%esp)
  80220d:	e8 58 ff ff ff       	call   80216a <fstat>
  802212:	89 c6                	mov    %eax,%esi
	close(fd);
  802214:	89 1c 24             	mov    %ebx,(%esp)
  802217:	e8 d2 fb ff ff       	call   801dee <close>
	return r;
  80221c:	89 f3                	mov    %esi,%ebx
}
  80221e:	89 d8                	mov    %ebx,%eax
  802220:	83 c4 10             	add    $0x10,%esp
  802223:	5b                   	pop    %ebx
  802224:	5e                   	pop    %esi
  802225:	5d                   	pop    %ebp
  802226:	c3                   	ret    
	...

00802228 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802228:	55                   	push   %ebp
  802229:	89 e5                	mov    %esp,%ebp
  80222b:	56                   	push   %esi
  80222c:	53                   	push   %ebx
  80222d:	83 ec 10             	sub    $0x10,%esp
  802230:	89 c3                	mov    %eax,%ebx
  802232:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  802234:	83 3d 18 50 80 00 00 	cmpl   $0x0,0x805018
  80223b:	75 11                	jne    80224e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80223d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  802244:	e8 aa f9 ff ff       	call   801bf3 <ipc_find_env>
  802249:	a3 18 50 80 00       	mov    %eax,0x805018
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80224e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802255:	00 
  802256:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80225d:	00 
  80225e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802262:	a1 18 50 80 00       	mov    0x805018,%eax
  802267:	89 04 24             	mov    %eax,(%esp)
  80226a:	e8 01 f9 ff ff       	call   801b70 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80226f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802276:	00 
  802277:	89 74 24 04          	mov    %esi,0x4(%esp)
  80227b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802282:	e8 79 f8 ff ff       	call   801b00 <ipc_recv>
}
  802287:	83 c4 10             	add    $0x10,%esp
  80228a:	5b                   	pop    %ebx
  80228b:	5e                   	pop    %esi
  80228c:	5d                   	pop    %ebp
  80228d:	c3                   	ret    

0080228e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80228e:	55                   	push   %ebp
  80228f:	89 e5                	mov    %esp,%ebp
  802291:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802294:	8b 45 08             	mov    0x8(%ebp),%eax
  802297:	8b 40 0c             	mov    0xc(%eax),%eax
  80229a:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  80229f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022a2:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8022a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8022ac:	b8 02 00 00 00       	mov    $0x2,%eax
  8022b1:	e8 72 ff ff ff       	call   802228 <fsipc>
}
  8022b6:	c9                   	leave  
  8022b7:	c3                   	ret    

008022b8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8022b8:	55                   	push   %ebp
  8022b9:	89 e5                	mov    %esp,%ebp
  8022bb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8022be:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8022c4:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8022c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8022ce:	b8 06 00 00 00       	mov    $0x6,%eax
  8022d3:	e8 50 ff ff ff       	call   802228 <fsipc>
}
  8022d8:	c9                   	leave  
  8022d9:	c3                   	ret    

008022da <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8022da:	55                   	push   %ebp
  8022db:	89 e5                	mov    %esp,%ebp
  8022dd:	53                   	push   %ebx
  8022de:	83 ec 14             	sub    $0x14,%esp
  8022e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8022e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8022e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8022ea:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8022ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8022f4:	b8 05 00 00 00       	mov    $0x5,%eax
  8022f9:	e8 2a ff ff ff       	call   802228 <fsipc>
  8022fe:	85 c0                	test   %eax,%eax
  802300:	78 2b                	js     80232d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802302:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802309:	00 
  80230a:	89 1c 24             	mov    %ebx,(%esp)
  80230d:	e8 75 ed ff ff       	call   801087 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802312:	a1 80 60 80 00       	mov    0x806080,%eax
  802317:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80231d:	a1 84 60 80 00       	mov    0x806084,%eax
  802322:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802328:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80232d:	83 c4 14             	add    $0x14,%esp
  802330:	5b                   	pop    %ebx
  802331:	5d                   	pop    %ebp
  802332:	c3                   	ret    

00802333 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802333:	55                   	push   %ebp
  802334:	89 e5                	mov    %esp,%ebp
  802336:	83 ec 18             	sub    $0x18,%esp
  802339:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80233c:	8b 55 08             	mov    0x8(%ebp),%edx
  80233f:	8b 52 0c             	mov    0xc(%edx),%edx
  802342:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  802348:	a3 04 60 80 00       	mov    %eax,0x806004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  80234d:	89 c2                	mov    %eax,%edx
  80234f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802354:	76 05                	jbe    80235b <devfile_write+0x28>
  802356:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  80235b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80235f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802362:	89 44 24 04          	mov    %eax,0x4(%esp)
  802366:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  80236d:	e8 f8 ee ff ff       	call   80126a <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  802372:	ba 00 00 00 00       	mov    $0x0,%edx
  802377:	b8 04 00 00 00       	mov    $0x4,%eax
  80237c:	e8 a7 fe ff ff       	call   802228 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  802381:	c9                   	leave  
  802382:	c3                   	ret    

00802383 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802383:	55                   	push   %ebp
  802384:	89 e5                	mov    %esp,%ebp
  802386:	56                   	push   %esi
  802387:	53                   	push   %ebx
  802388:	83 ec 10             	sub    $0x10,%esp
  80238b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80238e:	8b 45 08             	mov    0x8(%ebp),%eax
  802391:	8b 40 0c             	mov    0xc(%eax),%eax
  802394:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802399:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80239f:	ba 00 00 00 00       	mov    $0x0,%edx
  8023a4:	b8 03 00 00 00       	mov    $0x3,%eax
  8023a9:	e8 7a fe ff ff       	call   802228 <fsipc>
  8023ae:	89 c3                	mov    %eax,%ebx
  8023b0:	85 c0                	test   %eax,%eax
  8023b2:	78 6a                	js     80241e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8023b4:	39 c6                	cmp    %eax,%esi
  8023b6:	73 24                	jae    8023dc <devfile_read+0x59>
  8023b8:	c7 44 24 0c 80 38 80 	movl   $0x803880,0xc(%esp)
  8023bf:	00 
  8023c0:	c7 44 24 08 87 38 80 	movl   $0x803887,0x8(%esp)
  8023c7:	00 
  8023c8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  8023cf:	00 
  8023d0:	c7 04 24 9c 38 80 00 	movl   $0x80389c,(%esp)
  8023d7:	e8 08 e6 ff ff       	call   8009e4 <_panic>
	assert(r <= PGSIZE);
  8023dc:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8023e1:	7e 24                	jle    802407 <devfile_read+0x84>
  8023e3:	c7 44 24 0c a7 38 80 	movl   $0x8038a7,0xc(%esp)
  8023ea:	00 
  8023eb:	c7 44 24 08 87 38 80 	movl   $0x803887,0x8(%esp)
  8023f2:	00 
  8023f3:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8023fa:	00 
  8023fb:	c7 04 24 9c 38 80 00 	movl   $0x80389c,(%esp)
  802402:	e8 dd e5 ff ff       	call   8009e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802407:	89 44 24 08          	mov    %eax,0x8(%esp)
  80240b:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802412:	00 
  802413:	8b 45 0c             	mov    0xc(%ebp),%eax
  802416:	89 04 24             	mov    %eax,(%esp)
  802419:	e8 e2 ed ff ff       	call   801200 <memmove>
	return r;
}
  80241e:	89 d8                	mov    %ebx,%eax
  802420:	83 c4 10             	add    $0x10,%esp
  802423:	5b                   	pop    %ebx
  802424:	5e                   	pop    %esi
  802425:	5d                   	pop    %ebp
  802426:	c3                   	ret    

00802427 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802427:	55                   	push   %ebp
  802428:	89 e5                	mov    %esp,%ebp
  80242a:	56                   	push   %esi
  80242b:	53                   	push   %ebx
  80242c:	83 ec 20             	sub    $0x20,%esp
  80242f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802432:	89 34 24             	mov    %esi,(%esp)
  802435:	e8 1a ec ff ff       	call   801054 <strlen>
  80243a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80243f:	7f 60                	jg     8024a1 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802441:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802444:	89 04 24             	mov    %eax,(%esp)
  802447:	e8 17 f8 ff ff       	call   801c63 <fd_alloc>
  80244c:	89 c3                	mov    %eax,%ebx
  80244e:	85 c0                	test   %eax,%eax
  802450:	78 54                	js     8024a6 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802452:	89 74 24 04          	mov    %esi,0x4(%esp)
  802456:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80245d:	e8 25 ec ff ff       	call   801087 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802462:	8b 45 0c             	mov    0xc(%ebp),%eax
  802465:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80246a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80246d:	b8 01 00 00 00       	mov    $0x1,%eax
  802472:	e8 b1 fd ff ff       	call   802228 <fsipc>
  802477:	89 c3                	mov    %eax,%ebx
  802479:	85 c0                	test   %eax,%eax
  80247b:	79 15                	jns    802492 <open+0x6b>
		fd_close(fd, 0);
  80247d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802484:	00 
  802485:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802488:	89 04 24             	mov    %eax,(%esp)
  80248b:	e8 d6 f8 ff ff       	call   801d66 <fd_close>
		return r;
  802490:	eb 14                	jmp    8024a6 <open+0x7f>
	}

	return fd2num(fd);
  802492:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802495:	89 04 24             	mov    %eax,(%esp)
  802498:	e8 9b f7 ff ff       	call   801c38 <fd2num>
  80249d:	89 c3                	mov    %eax,%ebx
  80249f:	eb 05                	jmp    8024a6 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8024a1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8024a6:	89 d8                	mov    %ebx,%eax
  8024a8:	83 c4 20             	add    $0x20,%esp
  8024ab:	5b                   	pop    %ebx
  8024ac:	5e                   	pop    %esi
  8024ad:	5d                   	pop    %ebp
  8024ae:	c3                   	ret    

008024af <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8024af:	55                   	push   %ebp
  8024b0:	89 e5                	mov    %esp,%ebp
  8024b2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8024b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8024ba:	b8 08 00 00 00       	mov    $0x8,%eax
  8024bf:	e8 64 fd ff ff       	call   802228 <fsipc>
}
  8024c4:	c9                   	leave  
  8024c5:	c3                   	ret    
	...

008024c8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8024c8:	55                   	push   %ebp
  8024c9:	89 e5                	mov    %esp,%ebp
  8024cb:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8024ce:	c7 44 24 04 b3 38 80 	movl   $0x8038b3,0x4(%esp)
  8024d5:	00 
  8024d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024d9:	89 04 24             	mov    %eax,(%esp)
  8024dc:	e8 a6 eb ff ff       	call   801087 <strcpy>
	return 0;
}
  8024e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8024e6:	c9                   	leave  
  8024e7:	c3                   	ret    

008024e8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8024e8:	55                   	push   %ebp
  8024e9:	89 e5                	mov    %esp,%ebp
  8024eb:	53                   	push   %ebx
  8024ec:	83 ec 14             	sub    $0x14,%esp
  8024ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8024f2:	89 1c 24             	mov    %ebx,(%esp)
  8024f5:	e8 56 0a 00 00       	call   802f50 <pageref>
  8024fa:	83 f8 01             	cmp    $0x1,%eax
  8024fd:	75 0d                	jne    80250c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  8024ff:	8b 43 0c             	mov    0xc(%ebx),%eax
  802502:	89 04 24             	mov    %eax,(%esp)
  802505:	e8 1f 03 00 00       	call   802829 <nsipc_close>
  80250a:	eb 05                	jmp    802511 <devsock_close+0x29>
	else
		return 0;
  80250c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802511:	83 c4 14             	add    $0x14,%esp
  802514:	5b                   	pop    %ebx
  802515:	5d                   	pop    %ebp
  802516:	c3                   	ret    

00802517 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  802517:	55                   	push   %ebp
  802518:	89 e5                	mov    %esp,%ebp
  80251a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80251d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802524:	00 
  802525:	8b 45 10             	mov    0x10(%ebp),%eax
  802528:	89 44 24 08          	mov    %eax,0x8(%esp)
  80252c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80252f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802533:	8b 45 08             	mov    0x8(%ebp),%eax
  802536:	8b 40 0c             	mov    0xc(%eax),%eax
  802539:	89 04 24             	mov    %eax,(%esp)
  80253c:	e8 e3 03 00 00       	call   802924 <nsipc_send>
}
  802541:	c9                   	leave  
  802542:	c3                   	ret    

00802543 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  802543:	55                   	push   %ebp
  802544:	89 e5                	mov    %esp,%ebp
  802546:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802549:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802550:	00 
  802551:	8b 45 10             	mov    0x10(%ebp),%eax
  802554:	89 44 24 08          	mov    %eax,0x8(%esp)
  802558:	8b 45 0c             	mov    0xc(%ebp),%eax
  80255b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80255f:	8b 45 08             	mov    0x8(%ebp),%eax
  802562:	8b 40 0c             	mov    0xc(%eax),%eax
  802565:	89 04 24             	mov    %eax,(%esp)
  802568:	e8 37 03 00 00       	call   8028a4 <nsipc_recv>
}
  80256d:	c9                   	leave  
  80256e:	c3                   	ret    

0080256f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  80256f:	55                   	push   %ebp
  802570:	89 e5                	mov    %esp,%ebp
  802572:	56                   	push   %esi
  802573:	53                   	push   %ebx
  802574:	83 ec 20             	sub    $0x20,%esp
  802577:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802579:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80257c:	89 04 24             	mov    %eax,(%esp)
  80257f:	e8 df f6 ff ff       	call   801c63 <fd_alloc>
  802584:	89 c3                	mov    %eax,%ebx
  802586:	85 c0                	test   %eax,%eax
  802588:	78 21                	js     8025ab <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80258a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802591:	00 
  802592:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802595:	89 44 24 04          	mov    %eax,0x4(%esp)
  802599:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025a0:	e8 d4 ee ff ff       	call   801479 <sys_page_alloc>
  8025a5:	89 c3                	mov    %eax,%ebx
  8025a7:	85 c0                	test   %eax,%eax
  8025a9:	79 0a                	jns    8025b5 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  8025ab:	89 34 24             	mov    %esi,(%esp)
  8025ae:	e8 76 02 00 00       	call   802829 <nsipc_close>
		return r;
  8025b3:	eb 22                	jmp    8025d7 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8025b5:	8b 15 20 40 80 00    	mov    0x804020,%edx
  8025bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025be:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8025c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025c3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8025ca:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8025cd:	89 04 24             	mov    %eax,(%esp)
  8025d0:	e8 63 f6 ff ff       	call   801c38 <fd2num>
  8025d5:	89 c3                	mov    %eax,%ebx
}
  8025d7:	89 d8                	mov    %ebx,%eax
  8025d9:	83 c4 20             	add    $0x20,%esp
  8025dc:	5b                   	pop    %ebx
  8025dd:	5e                   	pop    %esi
  8025de:	5d                   	pop    %ebp
  8025df:	c3                   	ret    

008025e0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8025e0:	55                   	push   %ebp
  8025e1:	89 e5                	mov    %esp,%ebp
  8025e3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8025e6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8025e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025ed:	89 04 24             	mov    %eax,(%esp)
  8025f0:	e8 c1 f6 ff ff       	call   801cb6 <fd_lookup>
  8025f5:	85 c0                	test   %eax,%eax
  8025f7:	78 17                	js     802610 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8025f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025fc:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802602:	39 10                	cmp    %edx,(%eax)
  802604:	75 05                	jne    80260b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802606:	8b 40 0c             	mov    0xc(%eax),%eax
  802609:	eb 05                	jmp    802610 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80260b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802610:	c9                   	leave  
  802611:	c3                   	ret    

00802612 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802612:	55                   	push   %ebp
  802613:	89 e5                	mov    %esp,%ebp
  802615:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802618:	8b 45 08             	mov    0x8(%ebp),%eax
  80261b:	e8 c0 ff ff ff       	call   8025e0 <fd2sockid>
  802620:	85 c0                	test   %eax,%eax
  802622:	78 1f                	js     802643 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802624:	8b 55 10             	mov    0x10(%ebp),%edx
  802627:	89 54 24 08          	mov    %edx,0x8(%esp)
  80262b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80262e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802632:	89 04 24             	mov    %eax,(%esp)
  802635:	e8 38 01 00 00       	call   802772 <nsipc_accept>
  80263a:	85 c0                	test   %eax,%eax
  80263c:	78 05                	js     802643 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80263e:	e8 2c ff ff ff       	call   80256f <alloc_sockfd>
}
  802643:	c9                   	leave  
  802644:	c3                   	ret    

00802645 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802645:	55                   	push   %ebp
  802646:	89 e5                	mov    %esp,%ebp
  802648:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80264b:	8b 45 08             	mov    0x8(%ebp),%eax
  80264e:	e8 8d ff ff ff       	call   8025e0 <fd2sockid>
  802653:	85 c0                	test   %eax,%eax
  802655:	78 16                	js     80266d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  802657:	8b 55 10             	mov    0x10(%ebp),%edx
  80265a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80265e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802661:	89 54 24 04          	mov    %edx,0x4(%esp)
  802665:	89 04 24             	mov    %eax,(%esp)
  802668:	e8 5b 01 00 00       	call   8027c8 <nsipc_bind>
}
  80266d:	c9                   	leave  
  80266e:	c3                   	ret    

0080266f <shutdown>:

int
shutdown(int s, int how)
{
  80266f:	55                   	push   %ebp
  802670:	89 e5                	mov    %esp,%ebp
  802672:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802675:	8b 45 08             	mov    0x8(%ebp),%eax
  802678:	e8 63 ff ff ff       	call   8025e0 <fd2sockid>
  80267d:	85 c0                	test   %eax,%eax
  80267f:	78 0f                	js     802690 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802681:	8b 55 0c             	mov    0xc(%ebp),%edx
  802684:	89 54 24 04          	mov    %edx,0x4(%esp)
  802688:	89 04 24             	mov    %eax,(%esp)
  80268b:	e8 77 01 00 00       	call   802807 <nsipc_shutdown>
}
  802690:	c9                   	leave  
  802691:	c3                   	ret    

00802692 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802692:	55                   	push   %ebp
  802693:	89 e5                	mov    %esp,%ebp
  802695:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802698:	8b 45 08             	mov    0x8(%ebp),%eax
  80269b:	e8 40 ff ff ff       	call   8025e0 <fd2sockid>
  8026a0:	85 c0                	test   %eax,%eax
  8026a2:	78 16                	js     8026ba <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8026a4:	8b 55 10             	mov    0x10(%ebp),%edx
  8026a7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8026ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8026ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026b2:	89 04 24             	mov    %eax,(%esp)
  8026b5:	e8 89 01 00 00       	call   802843 <nsipc_connect>
}
  8026ba:	c9                   	leave  
  8026bb:	c3                   	ret    

008026bc <listen>:

int
listen(int s, int backlog)
{
  8026bc:	55                   	push   %ebp
  8026bd:	89 e5                	mov    %esp,%ebp
  8026bf:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8026c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8026c5:	e8 16 ff ff ff       	call   8025e0 <fd2sockid>
  8026ca:	85 c0                	test   %eax,%eax
  8026cc:	78 0f                	js     8026dd <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8026ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8026d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026d5:	89 04 24             	mov    %eax,(%esp)
  8026d8:	e8 a5 01 00 00       	call   802882 <nsipc_listen>
}
  8026dd:	c9                   	leave  
  8026de:	c3                   	ret    

008026df <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8026df:	55                   	push   %ebp
  8026e0:	89 e5                	mov    %esp,%ebp
  8026e2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8026e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8026e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8026f6:	89 04 24             	mov    %eax,(%esp)
  8026f9:	e8 99 02 00 00       	call   802997 <nsipc_socket>
  8026fe:	85 c0                	test   %eax,%eax
  802700:	78 05                	js     802707 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802702:	e8 68 fe ff ff       	call   80256f <alloc_sockfd>
}
  802707:	c9                   	leave  
  802708:	c3                   	ret    
  802709:	00 00                	add    %al,(%eax)
	...

0080270c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80270c:	55                   	push   %ebp
  80270d:	89 e5                	mov    %esp,%ebp
  80270f:	53                   	push   %ebx
  802710:	83 ec 14             	sub    $0x14,%esp
  802713:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802715:	83 3d 1c 50 80 00 00 	cmpl   $0x0,0x80501c
  80271c:	75 11                	jne    80272f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80271e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  802725:	e8 c9 f4 ff ff       	call   801bf3 <ipc_find_env>
  80272a:	a3 1c 50 80 00       	mov    %eax,0x80501c
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80272f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802736:	00 
  802737:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  80273e:	00 
  80273f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802743:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802748:	89 04 24             	mov    %eax,(%esp)
  80274b:	e8 20 f4 ff ff       	call   801b70 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802750:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802757:	00 
  802758:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80275f:	00 
  802760:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802767:	e8 94 f3 ff ff       	call   801b00 <ipc_recv>
}
  80276c:	83 c4 14             	add    $0x14,%esp
  80276f:	5b                   	pop    %ebx
  802770:	5d                   	pop    %ebp
  802771:	c3                   	ret    

00802772 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802772:	55                   	push   %ebp
  802773:	89 e5                	mov    %esp,%ebp
  802775:	56                   	push   %esi
  802776:	53                   	push   %ebx
  802777:	83 ec 10             	sub    $0x10,%esp
  80277a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80277d:	8b 45 08             	mov    0x8(%ebp),%eax
  802780:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802785:	8b 06                	mov    (%esi),%eax
  802787:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80278c:	b8 01 00 00 00       	mov    $0x1,%eax
  802791:	e8 76 ff ff ff       	call   80270c <nsipc>
  802796:	89 c3                	mov    %eax,%ebx
  802798:	85 c0                	test   %eax,%eax
  80279a:	78 23                	js     8027bf <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80279c:	a1 10 70 80 00       	mov    0x807010,%eax
  8027a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8027a5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8027ac:	00 
  8027ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027b0:	89 04 24             	mov    %eax,(%esp)
  8027b3:	e8 48 ea ff ff       	call   801200 <memmove>
		*addrlen = ret->ret_addrlen;
  8027b8:	a1 10 70 80 00       	mov    0x807010,%eax
  8027bd:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8027bf:	89 d8                	mov    %ebx,%eax
  8027c1:	83 c4 10             	add    $0x10,%esp
  8027c4:	5b                   	pop    %ebx
  8027c5:	5e                   	pop    %esi
  8027c6:	5d                   	pop    %ebp
  8027c7:	c3                   	ret    

008027c8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8027c8:	55                   	push   %ebp
  8027c9:	89 e5                	mov    %esp,%ebp
  8027cb:	53                   	push   %ebx
  8027cc:	83 ec 14             	sub    $0x14,%esp
  8027cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8027d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8027d5:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8027da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027e5:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8027ec:	e8 0f ea ff ff       	call   801200 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8027f1:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8027f7:	b8 02 00 00 00       	mov    $0x2,%eax
  8027fc:	e8 0b ff ff ff       	call   80270c <nsipc>
}
  802801:	83 c4 14             	add    $0x14,%esp
  802804:	5b                   	pop    %ebx
  802805:	5d                   	pop    %ebp
  802806:	c3                   	ret    

00802807 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802807:	55                   	push   %ebp
  802808:	89 e5                	mov    %esp,%ebp
  80280a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80280d:	8b 45 08             	mov    0x8(%ebp),%eax
  802810:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802815:	8b 45 0c             	mov    0xc(%ebp),%eax
  802818:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80281d:	b8 03 00 00 00       	mov    $0x3,%eax
  802822:	e8 e5 fe ff ff       	call   80270c <nsipc>
}
  802827:	c9                   	leave  
  802828:	c3                   	ret    

00802829 <nsipc_close>:

int
nsipc_close(int s)
{
  802829:	55                   	push   %ebp
  80282a:	89 e5                	mov    %esp,%ebp
  80282c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80282f:	8b 45 08             	mov    0x8(%ebp),%eax
  802832:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802837:	b8 04 00 00 00       	mov    $0x4,%eax
  80283c:	e8 cb fe ff ff       	call   80270c <nsipc>
}
  802841:	c9                   	leave  
  802842:	c3                   	ret    

00802843 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802843:	55                   	push   %ebp
  802844:	89 e5                	mov    %esp,%ebp
  802846:	53                   	push   %ebx
  802847:	83 ec 14             	sub    $0x14,%esp
  80284a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80284d:	8b 45 08             	mov    0x8(%ebp),%eax
  802850:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802855:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802859:	8b 45 0c             	mov    0xc(%ebp),%eax
  80285c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802860:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802867:	e8 94 e9 ff ff       	call   801200 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80286c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802872:	b8 05 00 00 00       	mov    $0x5,%eax
  802877:	e8 90 fe ff ff       	call   80270c <nsipc>
}
  80287c:	83 c4 14             	add    $0x14,%esp
  80287f:	5b                   	pop    %ebx
  802880:	5d                   	pop    %ebp
  802881:	c3                   	ret    

00802882 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802882:	55                   	push   %ebp
  802883:	89 e5                	mov    %esp,%ebp
  802885:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802888:	8b 45 08             	mov    0x8(%ebp),%eax
  80288b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  802890:	8b 45 0c             	mov    0xc(%ebp),%eax
  802893:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802898:	b8 06 00 00 00       	mov    $0x6,%eax
  80289d:	e8 6a fe ff ff       	call   80270c <nsipc>
}
  8028a2:	c9                   	leave  
  8028a3:	c3                   	ret    

008028a4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8028a4:	55                   	push   %ebp
  8028a5:	89 e5                	mov    %esp,%ebp
  8028a7:	56                   	push   %esi
  8028a8:	53                   	push   %ebx
  8028a9:	83 ec 10             	sub    $0x10,%esp
  8028ac:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8028af:	8b 45 08             	mov    0x8(%ebp),%eax
  8028b2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8028b7:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8028bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8028c0:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8028c5:	b8 07 00 00 00       	mov    $0x7,%eax
  8028ca:	e8 3d fe ff ff       	call   80270c <nsipc>
  8028cf:	89 c3                	mov    %eax,%ebx
  8028d1:	85 c0                	test   %eax,%eax
  8028d3:	78 46                	js     80291b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8028d5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8028da:	7f 04                	jg     8028e0 <nsipc_recv+0x3c>
  8028dc:	39 c6                	cmp    %eax,%esi
  8028de:	7d 24                	jge    802904 <nsipc_recv+0x60>
  8028e0:	c7 44 24 0c bf 38 80 	movl   $0x8038bf,0xc(%esp)
  8028e7:	00 
  8028e8:	c7 44 24 08 87 38 80 	movl   $0x803887,0x8(%esp)
  8028ef:	00 
  8028f0:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  8028f7:	00 
  8028f8:	c7 04 24 d4 38 80 00 	movl   $0x8038d4,(%esp)
  8028ff:	e8 e0 e0 ff ff       	call   8009e4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802904:	89 44 24 08          	mov    %eax,0x8(%esp)
  802908:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80290f:	00 
  802910:	8b 45 0c             	mov    0xc(%ebp),%eax
  802913:	89 04 24             	mov    %eax,(%esp)
  802916:	e8 e5 e8 ff ff       	call   801200 <memmove>
	}

	return r;
}
  80291b:	89 d8                	mov    %ebx,%eax
  80291d:	83 c4 10             	add    $0x10,%esp
  802920:	5b                   	pop    %ebx
  802921:	5e                   	pop    %esi
  802922:	5d                   	pop    %ebp
  802923:	c3                   	ret    

00802924 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802924:	55                   	push   %ebp
  802925:	89 e5                	mov    %esp,%ebp
  802927:	53                   	push   %ebx
  802928:	83 ec 14             	sub    $0x14,%esp
  80292b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80292e:	8b 45 08             	mov    0x8(%ebp),%eax
  802931:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802936:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80293c:	7e 24                	jle    802962 <nsipc_send+0x3e>
  80293e:	c7 44 24 0c e0 38 80 	movl   $0x8038e0,0xc(%esp)
  802945:	00 
  802946:	c7 44 24 08 87 38 80 	movl   $0x803887,0x8(%esp)
  80294d:	00 
  80294e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802955:	00 
  802956:	c7 04 24 d4 38 80 00 	movl   $0x8038d4,(%esp)
  80295d:	e8 82 e0 ff ff       	call   8009e4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802962:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802966:	8b 45 0c             	mov    0xc(%ebp),%eax
  802969:	89 44 24 04          	mov    %eax,0x4(%esp)
  80296d:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802974:	e8 87 e8 ff ff       	call   801200 <memmove>
	nsipcbuf.send.req_size = size;
  802979:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80297f:	8b 45 14             	mov    0x14(%ebp),%eax
  802982:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802987:	b8 08 00 00 00       	mov    $0x8,%eax
  80298c:	e8 7b fd ff ff       	call   80270c <nsipc>
}
  802991:	83 c4 14             	add    $0x14,%esp
  802994:	5b                   	pop    %ebx
  802995:	5d                   	pop    %ebp
  802996:	c3                   	ret    

00802997 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802997:	55                   	push   %ebp
  802998:	89 e5                	mov    %esp,%ebp
  80299a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80299d:	8b 45 08             	mov    0x8(%ebp),%eax
  8029a0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8029a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029a8:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8029ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8029b0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8029b5:	b8 09 00 00 00       	mov    $0x9,%eax
  8029ba:	e8 4d fd ff ff       	call   80270c <nsipc>
}
  8029bf:	c9                   	leave  
  8029c0:	c3                   	ret    
  8029c1:	00 00                	add    %al,(%eax)
	...

008029c4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8029c4:	55                   	push   %ebp
  8029c5:	89 e5                	mov    %esp,%ebp
  8029c7:	56                   	push   %esi
  8029c8:	53                   	push   %ebx
  8029c9:	83 ec 10             	sub    $0x10,%esp
  8029cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8029cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8029d2:	89 04 24             	mov    %eax,(%esp)
  8029d5:	e8 6e f2 ff ff       	call   801c48 <fd2data>
  8029da:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  8029dc:	c7 44 24 04 ec 38 80 	movl   $0x8038ec,0x4(%esp)
  8029e3:	00 
  8029e4:	89 34 24             	mov    %esi,(%esp)
  8029e7:	e8 9b e6 ff ff       	call   801087 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8029ec:	8b 43 04             	mov    0x4(%ebx),%eax
  8029ef:	2b 03                	sub    (%ebx),%eax
  8029f1:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  8029f7:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  8029fe:	00 00 00 
	stat->st_dev = &devpipe;
  802a01:	c7 86 88 00 00 00 3c 	movl   $0x80403c,0x88(%esi)
  802a08:	40 80 00 
	return 0;
}
  802a0b:	b8 00 00 00 00       	mov    $0x0,%eax
  802a10:	83 c4 10             	add    $0x10,%esp
  802a13:	5b                   	pop    %ebx
  802a14:	5e                   	pop    %esi
  802a15:	5d                   	pop    %ebp
  802a16:	c3                   	ret    

00802a17 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802a17:	55                   	push   %ebp
  802a18:	89 e5                	mov    %esp,%ebp
  802a1a:	53                   	push   %ebx
  802a1b:	83 ec 14             	sub    $0x14,%esp
  802a1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802a21:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802a25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a2c:	e8 ef ea ff ff       	call   801520 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802a31:	89 1c 24             	mov    %ebx,(%esp)
  802a34:	e8 0f f2 ff ff       	call   801c48 <fd2data>
  802a39:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a44:	e8 d7 ea ff ff       	call   801520 <sys_page_unmap>
}
  802a49:	83 c4 14             	add    $0x14,%esp
  802a4c:	5b                   	pop    %ebx
  802a4d:	5d                   	pop    %ebp
  802a4e:	c3                   	ret    

00802a4f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802a4f:	55                   	push   %ebp
  802a50:	89 e5                	mov    %esp,%ebp
  802a52:	57                   	push   %edi
  802a53:	56                   	push   %esi
  802a54:	53                   	push   %ebx
  802a55:	83 ec 2c             	sub    $0x2c,%esp
  802a58:	89 c7                	mov    %eax,%edi
  802a5a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802a5d:	a1 20 50 80 00       	mov    0x805020,%eax
  802a62:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802a65:	89 3c 24             	mov    %edi,(%esp)
  802a68:	e8 e3 04 00 00       	call   802f50 <pageref>
  802a6d:	89 c6                	mov    %eax,%esi
  802a6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802a72:	89 04 24             	mov    %eax,(%esp)
  802a75:	e8 d6 04 00 00       	call   802f50 <pageref>
  802a7a:	39 c6                	cmp    %eax,%esi
  802a7c:	0f 94 c0             	sete   %al
  802a7f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802a82:	8b 15 20 50 80 00    	mov    0x805020,%edx
  802a88:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802a8b:	39 cb                	cmp    %ecx,%ebx
  802a8d:	75 08                	jne    802a97 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802a8f:	83 c4 2c             	add    $0x2c,%esp
  802a92:	5b                   	pop    %ebx
  802a93:	5e                   	pop    %esi
  802a94:	5f                   	pop    %edi
  802a95:	5d                   	pop    %ebp
  802a96:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802a97:	83 f8 01             	cmp    $0x1,%eax
  802a9a:	75 c1                	jne    802a5d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802a9c:	8b 42 58             	mov    0x58(%edx),%eax
  802a9f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802aa6:	00 
  802aa7:	89 44 24 08          	mov    %eax,0x8(%esp)
  802aab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802aaf:	c7 04 24 f3 38 80 00 	movl   $0x8038f3,(%esp)
  802ab6:	e8 21 e0 ff ff       	call   800adc <cprintf>
  802abb:	eb a0                	jmp    802a5d <_pipeisclosed+0xe>

00802abd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802abd:	55                   	push   %ebp
  802abe:	89 e5                	mov    %esp,%ebp
  802ac0:	57                   	push   %edi
  802ac1:	56                   	push   %esi
  802ac2:	53                   	push   %ebx
  802ac3:	83 ec 1c             	sub    $0x1c,%esp
  802ac6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802ac9:	89 34 24             	mov    %esi,(%esp)
  802acc:	e8 77 f1 ff ff       	call   801c48 <fd2data>
  802ad1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ad3:	bf 00 00 00 00       	mov    $0x0,%edi
  802ad8:	eb 3c                	jmp    802b16 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802ada:	89 da                	mov    %ebx,%edx
  802adc:	89 f0                	mov    %esi,%eax
  802ade:	e8 6c ff ff ff       	call   802a4f <_pipeisclosed>
  802ae3:	85 c0                	test   %eax,%eax
  802ae5:	75 38                	jne    802b1f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802ae7:	e8 6e e9 ff ff       	call   80145a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802aec:	8b 43 04             	mov    0x4(%ebx),%eax
  802aef:	8b 13                	mov    (%ebx),%edx
  802af1:	83 c2 20             	add    $0x20,%edx
  802af4:	39 d0                	cmp    %edx,%eax
  802af6:	73 e2                	jae    802ada <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802af8:	8b 55 0c             	mov    0xc(%ebp),%edx
  802afb:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802afe:	89 c2                	mov    %eax,%edx
  802b00:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802b06:	79 05                	jns    802b0d <devpipe_write+0x50>
  802b08:	4a                   	dec    %edx
  802b09:	83 ca e0             	or     $0xffffffe0,%edx
  802b0c:	42                   	inc    %edx
  802b0d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802b11:	40                   	inc    %eax
  802b12:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b15:	47                   	inc    %edi
  802b16:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802b19:	75 d1                	jne    802aec <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802b1b:	89 f8                	mov    %edi,%eax
  802b1d:	eb 05                	jmp    802b24 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802b1f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802b24:	83 c4 1c             	add    $0x1c,%esp
  802b27:	5b                   	pop    %ebx
  802b28:	5e                   	pop    %esi
  802b29:	5f                   	pop    %edi
  802b2a:	5d                   	pop    %ebp
  802b2b:	c3                   	ret    

00802b2c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802b2c:	55                   	push   %ebp
  802b2d:	89 e5                	mov    %esp,%ebp
  802b2f:	57                   	push   %edi
  802b30:	56                   	push   %esi
  802b31:	53                   	push   %ebx
  802b32:	83 ec 1c             	sub    $0x1c,%esp
  802b35:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802b38:	89 3c 24             	mov    %edi,(%esp)
  802b3b:	e8 08 f1 ff ff       	call   801c48 <fd2data>
  802b40:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b42:	be 00 00 00 00       	mov    $0x0,%esi
  802b47:	eb 3a                	jmp    802b83 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802b49:	85 f6                	test   %esi,%esi
  802b4b:	74 04                	je     802b51 <devpipe_read+0x25>
				return i;
  802b4d:	89 f0                	mov    %esi,%eax
  802b4f:	eb 40                	jmp    802b91 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802b51:	89 da                	mov    %ebx,%edx
  802b53:	89 f8                	mov    %edi,%eax
  802b55:	e8 f5 fe ff ff       	call   802a4f <_pipeisclosed>
  802b5a:	85 c0                	test   %eax,%eax
  802b5c:	75 2e                	jne    802b8c <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802b5e:	e8 f7 e8 ff ff       	call   80145a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802b63:	8b 03                	mov    (%ebx),%eax
  802b65:	3b 43 04             	cmp    0x4(%ebx),%eax
  802b68:	74 df                	je     802b49 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802b6a:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802b6f:	79 05                	jns    802b76 <devpipe_read+0x4a>
  802b71:	48                   	dec    %eax
  802b72:	83 c8 e0             	or     $0xffffffe0,%eax
  802b75:	40                   	inc    %eax
  802b76:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802b7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b7d:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802b80:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b82:	46                   	inc    %esi
  802b83:	3b 75 10             	cmp    0x10(%ebp),%esi
  802b86:	75 db                	jne    802b63 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802b88:	89 f0                	mov    %esi,%eax
  802b8a:	eb 05                	jmp    802b91 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802b8c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802b91:	83 c4 1c             	add    $0x1c,%esp
  802b94:	5b                   	pop    %ebx
  802b95:	5e                   	pop    %esi
  802b96:	5f                   	pop    %edi
  802b97:	5d                   	pop    %ebp
  802b98:	c3                   	ret    

00802b99 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802b99:	55                   	push   %ebp
  802b9a:	89 e5                	mov    %esp,%ebp
  802b9c:	57                   	push   %edi
  802b9d:	56                   	push   %esi
  802b9e:	53                   	push   %ebx
  802b9f:	83 ec 3c             	sub    $0x3c,%esp
  802ba2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802ba5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802ba8:	89 04 24             	mov    %eax,(%esp)
  802bab:	e8 b3 f0 ff ff       	call   801c63 <fd_alloc>
  802bb0:	89 c3                	mov    %eax,%ebx
  802bb2:	85 c0                	test   %eax,%eax
  802bb4:	0f 88 45 01 00 00    	js     802cff <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802bba:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802bc1:	00 
  802bc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802bc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  802bc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802bd0:	e8 a4 e8 ff ff       	call   801479 <sys_page_alloc>
  802bd5:	89 c3                	mov    %eax,%ebx
  802bd7:	85 c0                	test   %eax,%eax
  802bd9:	0f 88 20 01 00 00    	js     802cff <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802bdf:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802be2:	89 04 24             	mov    %eax,(%esp)
  802be5:	e8 79 f0 ff ff       	call   801c63 <fd_alloc>
  802bea:	89 c3                	mov    %eax,%ebx
  802bec:	85 c0                	test   %eax,%eax
  802bee:	0f 88 f8 00 00 00    	js     802cec <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802bf4:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802bfb:	00 
  802bfc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802bff:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c0a:	e8 6a e8 ff ff       	call   801479 <sys_page_alloc>
  802c0f:	89 c3                	mov    %eax,%ebx
  802c11:	85 c0                	test   %eax,%eax
  802c13:	0f 88 d3 00 00 00    	js     802cec <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802c19:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802c1c:	89 04 24             	mov    %eax,(%esp)
  802c1f:	e8 24 f0 ff ff       	call   801c48 <fd2data>
  802c24:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c26:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802c2d:	00 
  802c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802c32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c39:	e8 3b e8 ff ff       	call   801479 <sys_page_alloc>
  802c3e:	89 c3                	mov    %eax,%ebx
  802c40:	85 c0                	test   %eax,%eax
  802c42:	0f 88 91 00 00 00    	js     802cd9 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c48:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802c4b:	89 04 24             	mov    %eax,(%esp)
  802c4e:	e8 f5 ef ff ff       	call   801c48 <fd2data>
  802c53:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802c5a:	00 
  802c5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c5f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802c66:	00 
  802c67:	89 74 24 04          	mov    %esi,0x4(%esp)
  802c6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c72:	e8 56 e8 ff ff       	call   8014cd <sys_page_map>
  802c77:	89 c3                	mov    %eax,%ebx
  802c79:	85 c0                	test   %eax,%eax
  802c7b:	78 4c                	js     802cc9 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802c7d:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802c83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802c86:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802c88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802c8b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802c92:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802c98:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802c9b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802c9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802ca0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802ca7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802caa:	89 04 24             	mov    %eax,(%esp)
  802cad:	e8 86 ef ff ff       	call   801c38 <fd2num>
  802cb2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802cb4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802cb7:	89 04 24             	mov    %eax,(%esp)
  802cba:	e8 79 ef ff ff       	call   801c38 <fd2num>
  802cbf:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802cc2:	bb 00 00 00 00       	mov    $0x0,%ebx
  802cc7:	eb 36                	jmp    802cff <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802cc9:	89 74 24 04          	mov    %esi,0x4(%esp)
  802ccd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802cd4:	e8 47 e8 ff ff       	call   801520 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802cd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ce0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ce7:	e8 34 e8 ff ff       	call   801520 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802cec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802cef:	89 44 24 04          	mov    %eax,0x4(%esp)
  802cf3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802cfa:	e8 21 e8 ff ff       	call   801520 <sys_page_unmap>
    err:
	return r;
}
  802cff:	89 d8                	mov    %ebx,%eax
  802d01:	83 c4 3c             	add    $0x3c,%esp
  802d04:	5b                   	pop    %ebx
  802d05:	5e                   	pop    %esi
  802d06:	5f                   	pop    %edi
  802d07:	5d                   	pop    %ebp
  802d08:	c3                   	ret    

00802d09 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802d09:	55                   	push   %ebp
  802d0a:	89 e5                	mov    %esp,%ebp
  802d0c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d12:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d16:	8b 45 08             	mov    0x8(%ebp),%eax
  802d19:	89 04 24             	mov    %eax,(%esp)
  802d1c:	e8 95 ef ff ff       	call   801cb6 <fd_lookup>
  802d21:	85 c0                	test   %eax,%eax
  802d23:	78 15                	js     802d3a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d28:	89 04 24             	mov    %eax,(%esp)
  802d2b:	e8 18 ef ff ff       	call   801c48 <fd2data>
	return _pipeisclosed(fd, p);
  802d30:	89 c2                	mov    %eax,%edx
  802d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d35:	e8 15 fd ff ff       	call   802a4f <_pipeisclosed>
}
  802d3a:	c9                   	leave  
  802d3b:	c3                   	ret    

00802d3c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802d3c:	55                   	push   %ebp
  802d3d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  802d44:	5d                   	pop    %ebp
  802d45:	c3                   	ret    

00802d46 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802d46:	55                   	push   %ebp
  802d47:	89 e5                	mov    %esp,%ebp
  802d49:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802d4c:	c7 44 24 04 0b 39 80 	movl   $0x80390b,0x4(%esp)
  802d53:	00 
  802d54:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d57:	89 04 24             	mov    %eax,(%esp)
  802d5a:	e8 28 e3 ff ff       	call   801087 <strcpy>
	return 0;
}
  802d5f:	b8 00 00 00 00       	mov    $0x0,%eax
  802d64:	c9                   	leave  
  802d65:	c3                   	ret    

00802d66 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802d66:	55                   	push   %ebp
  802d67:	89 e5                	mov    %esp,%ebp
  802d69:	57                   	push   %edi
  802d6a:	56                   	push   %esi
  802d6b:	53                   	push   %ebx
  802d6c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802d72:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802d77:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802d7d:	eb 30                	jmp    802daf <devcons_write+0x49>
		m = n - tot;
  802d7f:	8b 75 10             	mov    0x10(%ebp),%esi
  802d82:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802d84:	83 fe 7f             	cmp    $0x7f,%esi
  802d87:	76 05                	jbe    802d8e <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802d89:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802d8e:	89 74 24 08          	mov    %esi,0x8(%esp)
  802d92:	03 45 0c             	add    0xc(%ebp),%eax
  802d95:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d99:	89 3c 24             	mov    %edi,(%esp)
  802d9c:	e8 5f e4 ff ff       	call   801200 <memmove>
		sys_cputs(buf, m);
  802da1:	89 74 24 04          	mov    %esi,0x4(%esp)
  802da5:	89 3c 24             	mov    %edi,(%esp)
  802da8:	e8 ff e5 ff ff       	call   8013ac <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802dad:	01 f3                	add    %esi,%ebx
  802daf:	89 d8                	mov    %ebx,%eax
  802db1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802db4:	72 c9                	jb     802d7f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802db6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802dbc:	5b                   	pop    %ebx
  802dbd:	5e                   	pop    %esi
  802dbe:	5f                   	pop    %edi
  802dbf:	5d                   	pop    %ebp
  802dc0:	c3                   	ret    

00802dc1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802dc1:	55                   	push   %ebp
  802dc2:	89 e5                	mov    %esp,%ebp
  802dc4:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802dc7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802dcb:	75 07                	jne    802dd4 <devcons_read+0x13>
  802dcd:	eb 25                	jmp    802df4 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802dcf:	e8 86 e6 ff ff       	call   80145a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802dd4:	e8 f1 e5 ff ff       	call   8013ca <sys_cgetc>
  802dd9:	85 c0                	test   %eax,%eax
  802ddb:	74 f2                	je     802dcf <devcons_read+0xe>
  802ddd:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802ddf:	85 c0                	test   %eax,%eax
  802de1:	78 1d                	js     802e00 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802de3:	83 f8 04             	cmp    $0x4,%eax
  802de6:	74 13                	je     802dfb <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802de8:	8b 45 0c             	mov    0xc(%ebp),%eax
  802deb:	88 10                	mov    %dl,(%eax)
	return 1;
  802ded:	b8 01 00 00 00       	mov    $0x1,%eax
  802df2:	eb 0c                	jmp    802e00 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802df4:	b8 00 00 00 00       	mov    $0x0,%eax
  802df9:	eb 05                	jmp    802e00 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802dfb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802e00:	c9                   	leave  
  802e01:	c3                   	ret    

00802e02 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802e02:	55                   	push   %ebp
  802e03:	89 e5                	mov    %esp,%ebp
  802e05:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802e08:	8b 45 08             	mov    0x8(%ebp),%eax
  802e0b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802e0e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802e15:	00 
  802e16:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802e19:	89 04 24             	mov    %eax,(%esp)
  802e1c:	e8 8b e5 ff ff       	call   8013ac <sys_cputs>
}
  802e21:	c9                   	leave  
  802e22:	c3                   	ret    

00802e23 <getchar>:

int
getchar(void)
{
  802e23:	55                   	push   %ebp
  802e24:	89 e5                	mov    %esp,%ebp
  802e26:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802e29:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802e30:	00 
  802e31:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802e34:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e3f:	e8 10 f1 ff ff       	call   801f54 <read>
	if (r < 0)
  802e44:	85 c0                	test   %eax,%eax
  802e46:	78 0f                	js     802e57 <getchar+0x34>
		return r;
	if (r < 1)
  802e48:	85 c0                	test   %eax,%eax
  802e4a:	7e 06                	jle    802e52 <getchar+0x2f>
		return -E_EOF;
	return c;
  802e4c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802e50:	eb 05                	jmp    802e57 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802e52:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802e57:	c9                   	leave  
  802e58:	c3                   	ret    

00802e59 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802e59:	55                   	push   %ebp
  802e5a:	89 e5                	mov    %esp,%ebp
  802e5c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802e5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e62:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e66:	8b 45 08             	mov    0x8(%ebp),%eax
  802e69:	89 04 24             	mov    %eax,(%esp)
  802e6c:	e8 45 ee ff ff       	call   801cb6 <fd_lookup>
  802e71:	85 c0                	test   %eax,%eax
  802e73:	78 11                	js     802e86 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802e78:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802e7e:	39 10                	cmp    %edx,(%eax)
  802e80:	0f 94 c0             	sete   %al
  802e83:	0f b6 c0             	movzbl %al,%eax
}
  802e86:	c9                   	leave  
  802e87:	c3                   	ret    

00802e88 <opencons>:

int
opencons(void)
{
  802e88:	55                   	push   %ebp
  802e89:	89 e5                	mov    %esp,%ebp
  802e8b:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802e8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802e91:	89 04 24             	mov    %eax,(%esp)
  802e94:	e8 ca ed ff ff       	call   801c63 <fd_alloc>
  802e99:	85 c0                	test   %eax,%eax
  802e9b:	78 3c                	js     802ed9 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802e9d:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802ea4:	00 
  802ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ea8:	89 44 24 04          	mov    %eax,0x4(%esp)
  802eac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802eb3:	e8 c1 e5 ff ff       	call   801479 <sys_page_alloc>
  802eb8:	85 c0                	test   %eax,%eax
  802eba:	78 1d                	js     802ed9 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802ebc:	8b 15 58 40 80 00    	mov    0x804058,%edx
  802ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ec5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802eca:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802ed1:	89 04 24             	mov    %eax,(%esp)
  802ed4:	e8 5f ed ff ff       	call   801c38 <fd2num>
}
  802ed9:	c9                   	leave  
  802eda:	c3                   	ret    
	...

00802edc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802edc:	55                   	push   %ebp
  802edd:	89 e5                	mov    %esp,%ebp
  802edf:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802ee2:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802ee9:	75 30                	jne    802f1b <set_pgfault_handler+0x3f>
		// First time through!
		// LAB 4: Your code here.
		sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W | PTE_U | PTE_P);
  802eeb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802ef2:	00 
  802ef3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802efa:	ee 
  802efb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f02:	e8 72 e5 ff ff       	call   801479 <sys_page_alloc>
		sys_env_set_pgfault_upcall(0,_pgfault_upcall);
  802f07:	c7 44 24 04 28 2f 80 	movl   $0x802f28,0x4(%esp)
  802f0e:	00 
  802f0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f16:	e8 fe e6 ff ff       	call   801619 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  802f1e:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802f23:	c9                   	leave  
  802f24:	c3                   	ret    
  802f25:	00 00                	add    %al,(%eax)
	...

00802f28 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802f28:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802f29:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  802f2e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802f30:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x28(%esp),%eax 
  802f33:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 0x30(%esp),%ebx
  802f37:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4,%ebx
  802f3b:	83 eb 04             	sub    $0x4,%ebx
	movl %eax,(%ebx)
  802f3e:	89 03                	mov    %eax,(%ebx)
	movl %ebx,0x30(%esp)
  802f40:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	addl $8,%esp 
  802f44:	83 c4 08             	add    $0x8,%esp
	popal
  802f47:	61                   	popa   

	addl $4,%esp 
  802f48:	83 c4 04             	add    $0x4,%esp
	popfl
  802f4b:	9d                   	popf   

	popl %esp
  802f4c:	5c                   	pop    %esp

	ret
  802f4d:	c3                   	ret    
	...

00802f50 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802f50:	55                   	push   %ebp
  802f51:	89 e5                	mov    %esp,%ebp
  802f53:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802f56:	89 c2                	mov    %eax,%edx
  802f58:	c1 ea 16             	shr    $0x16,%edx
  802f5b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802f62:	f6 c2 01             	test   $0x1,%dl
  802f65:	74 1e                	je     802f85 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802f67:	c1 e8 0c             	shr    $0xc,%eax
  802f6a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802f71:	a8 01                	test   $0x1,%al
  802f73:	74 17                	je     802f8c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802f75:	c1 e8 0c             	shr    $0xc,%eax
  802f78:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802f7f:	ef 
  802f80:	0f b7 c0             	movzwl %ax,%eax
  802f83:	eb 0c                	jmp    802f91 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802f85:	b8 00 00 00 00       	mov    $0x0,%eax
  802f8a:	eb 05                	jmp    802f91 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802f8c:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802f91:	5d                   	pop    %ebp
  802f92:	c3                   	ret    
	...

00802f94 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802f94:	55                   	push   %ebp
  802f95:	57                   	push   %edi
  802f96:	56                   	push   %esi
  802f97:	83 ec 10             	sub    $0x10,%esp
  802f9a:	8b 74 24 20          	mov    0x20(%esp),%esi
  802f9e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802fa2:	89 74 24 04          	mov    %esi,0x4(%esp)
  802fa6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802faa:	89 cd                	mov    %ecx,%ebp
  802fac:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802fb0:	85 c0                	test   %eax,%eax
  802fb2:	75 2c                	jne    802fe0 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802fb4:	39 f9                	cmp    %edi,%ecx
  802fb6:	77 68                	ja     803020 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802fb8:	85 c9                	test   %ecx,%ecx
  802fba:	75 0b                	jne    802fc7 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802fbc:	b8 01 00 00 00       	mov    $0x1,%eax
  802fc1:	31 d2                	xor    %edx,%edx
  802fc3:	f7 f1                	div    %ecx
  802fc5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802fc7:	31 d2                	xor    %edx,%edx
  802fc9:	89 f8                	mov    %edi,%eax
  802fcb:	f7 f1                	div    %ecx
  802fcd:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802fcf:	89 f0                	mov    %esi,%eax
  802fd1:	f7 f1                	div    %ecx
  802fd3:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802fd5:	89 f0                	mov    %esi,%eax
  802fd7:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802fd9:	83 c4 10             	add    $0x10,%esp
  802fdc:	5e                   	pop    %esi
  802fdd:	5f                   	pop    %edi
  802fde:	5d                   	pop    %ebp
  802fdf:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802fe0:	39 f8                	cmp    %edi,%eax
  802fe2:	77 2c                	ja     803010 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802fe4:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802fe7:	83 f6 1f             	xor    $0x1f,%esi
  802fea:	75 4c                	jne    803038 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802fec:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802fee:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802ff3:	72 0a                	jb     802fff <__udivdi3+0x6b>
  802ff5:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802ff9:	0f 87 ad 00 00 00    	ja     8030ac <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802fff:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803004:	89 f0                	mov    %esi,%eax
  803006:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803008:	83 c4 10             	add    $0x10,%esp
  80300b:	5e                   	pop    %esi
  80300c:	5f                   	pop    %edi
  80300d:	5d                   	pop    %ebp
  80300e:	c3                   	ret    
  80300f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  803010:	31 ff                	xor    %edi,%edi
  803012:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  803014:	89 f0                	mov    %esi,%eax
  803016:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  803018:	83 c4 10             	add    $0x10,%esp
  80301b:	5e                   	pop    %esi
  80301c:	5f                   	pop    %edi
  80301d:	5d                   	pop    %ebp
  80301e:	c3                   	ret    
  80301f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  803020:	89 fa                	mov    %edi,%edx
  803022:	89 f0                	mov    %esi,%eax
  803024:	f7 f1                	div    %ecx
  803026:	89 c6                	mov    %eax,%esi
  803028:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80302a:	89 f0                	mov    %esi,%eax
  80302c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80302e:	83 c4 10             	add    $0x10,%esp
  803031:	5e                   	pop    %esi
  803032:	5f                   	pop    %edi
  803033:	5d                   	pop    %ebp
  803034:	c3                   	ret    
  803035:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803038:	89 f1                	mov    %esi,%ecx
  80303a:	d3 e0                	shl    %cl,%eax
  80303c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  803040:	b8 20 00 00 00       	mov    $0x20,%eax
  803045:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  803047:	89 ea                	mov    %ebp,%edx
  803049:	88 c1                	mov    %al,%cl
  80304b:	d3 ea                	shr    %cl,%edx
  80304d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  803051:	09 ca                	or     %ecx,%edx
  803053:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  803057:	89 f1                	mov    %esi,%ecx
  803059:	d3 e5                	shl    %cl,%ebp
  80305b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  80305f:	89 fd                	mov    %edi,%ebp
  803061:	88 c1                	mov    %al,%cl
  803063:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  803065:	89 fa                	mov    %edi,%edx
  803067:	89 f1                	mov    %esi,%ecx
  803069:	d3 e2                	shl    %cl,%edx
  80306b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80306f:	88 c1                	mov    %al,%cl
  803071:	d3 ef                	shr    %cl,%edi
  803073:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  803075:	89 f8                	mov    %edi,%eax
  803077:	89 ea                	mov    %ebp,%edx
  803079:	f7 74 24 08          	divl   0x8(%esp)
  80307d:	89 d1                	mov    %edx,%ecx
  80307f:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  803081:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  803085:	39 d1                	cmp    %edx,%ecx
  803087:	72 17                	jb     8030a0 <__udivdi3+0x10c>
  803089:	74 09                	je     803094 <__udivdi3+0x100>
  80308b:	89 fe                	mov    %edi,%esi
  80308d:	31 ff                	xor    %edi,%edi
  80308f:	e9 41 ff ff ff       	jmp    802fd5 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  803094:	8b 54 24 04          	mov    0x4(%esp),%edx
  803098:	89 f1                	mov    %esi,%ecx
  80309a:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80309c:	39 c2                	cmp    %eax,%edx
  80309e:	73 eb                	jae    80308b <__udivdi3+0xf7>
		{
		  q0--;
  8030a0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8030a3:	31 ff                	xor    %edi,%edi
  8030a5:	e9 2b ff ff ff       	jmp    802fd5 <__udivdi3+0x41>
  8030aa:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8030ac:	31 f6                	xor    %esi,%esi
  8030ae:	e9 22 ff ff ff       	jmp    802fd5 <__udivdi3+0x41>
	...

008030b4 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  8030b4:	55                   	push   %ebp
  8030b5:	57                   	push   %edi
  8030b6:	56                   	push   %esi
  8030b7:	83 ec 20             	sub    $0x20,%esp
  8030ba:	8b 44 24 30          	mov    0x30(%esp),%eax
  8030be:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  8030c2:	89 44 24 14          	mov    %eax,0x14(%esp)
  8030c6:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  8030ca:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8030ce:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  8030d2:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  8030d4:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  8030d6:	85 ed                	test   %ebp,%ebp
  8030d8:	75 16                	jne    8030f0 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  8030da:	39 f1                	cmp    %esi,%ecx
  8030dc:	0f 86 a6 00 00 00    	jbe    803188 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8030e2:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  8030e4:	89 d0                	mov    %edx,%eax
  8030e6:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8030e8:	83 c4 20             	add    $0x20,%esp
  8030eb:	5e                   	pop    %esi
  8030ec:	5f                   	pop    %edi
  8030ed:	5d                   	pop    %ebp
  8030ee:	c3                   	ret    
  8030ef:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8030f0:	39 f5                	cmp    %esi,%ebp
  8030f2:	0f 87 ac 00 00 00    	ja     8031a4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8030f8:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  8030fb:	83 f0 1f             	xor    $0x1f,%eax
  8030fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  803102:	0f 84 a8 00 00 00    	je     8031b0 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  803108:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80310c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  80310e:	bf 20 00 00 00       	mov    $0x20,%edi
  803113:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  803117:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80311b:	89 f9                	mov    %edi,%ecx
  80311d:	d3 e8                	shr    %cl,%eax
  80311f:	09 e8                	or     %ebp,%eax
  803121:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  803125:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803129:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80312d:	d3 e0                	shl    %cl,%eax
  80312f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803133:	89 f2                	mov    %esi,%edx
  803135:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  803137:	8b 44 24 14          	mov    0x14(%esp),%eax
  80313b:	d3 e0                	shl    %cl,%eax
  80313d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  803141:	8b 44 24 14          	mov    0x14(%esp),%eax
  803145:	89 f9                	mov    %edi,%ecx
  803147:	d3 e8                	shr    %cl,%eax
  803149:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  80314b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80314d:	89 f2                	mov    %esi,%edx
  80314f:	f7 74 24 18          	divl   0x18(%esp)
  803153:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  803155:	f7 64 24 0c          	mull   0xc(%esp)
  803159:	89 c5                	mov    %eax,%ebp
  80315b:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80315d:	39 d6                	cmp    %edx,%esi
  80315f:	72 67                	jb     8031c8 <__umoddi3+0x114>
  803161:	74 75                	je     8031d8 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  803163:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  803167:	29 e8                	sub    %ebp,%eax
  803169:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  80316b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80316f:	d3 e8                	shr    %cl,%eax
  803171:	89 f2                	mov    %esi,%edx
  803173:	89 f9                	mov    %edi,%ecx
  803175:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  803177:	09 d0                	or     %edx,%eax
  803179:	89 f2                	mov    %esi,%edx
  80317b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80317f:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  803181:	83 c4 20             	add    $0x20,%esp
  803184:	5e                   	pop    %esi
  803185:	5f                   	pop    %edi
  803186:	5d                   	pop    %ebp
  803187:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  803188:	85 c9                	test   %ecx,%ecx
  80318a:	75 0b                	jne    803197 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  80318c:	b8 01 00 00 00       	mov    $0x1,%eax
  803191:	31 d2                	xor    %edx,%edx
  803193:	f7 f1                	div    %ecx
  803195:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  803197:	89 f0                	mov    %esi,%eax
  803199:	31 d2                	xor    %edx,%edx
  80319b:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80319d:	89 f8                	mov    %edi,%eax
  80319f:	e9 3e ff ff ff       	jmp    8030e2 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  8031a4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8031a6:	83 c4 20             	add    $0x20,%esp
  8031a9:	5e                   	pop    %esi
  8031aa:	5f                   	pop    %edi
  8031ab:	5d                   	pop    %ebp
  8031ac:	c3                   	ret    
  8031ad:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8031b0:	39 f5                	cmp    %esi,%ebp
  8031b2:	72 04                	jb     8031b8 <__umoddi3+0x104>
  8031b4:	39 f9                	cmp    %edi,%ecx
  8031b6:	77 06                	ja     8031be <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8031b8:	89 f2                	mov    %esi,%edx
  8031ba:	29 cf                	sub    %ecx,%edi
  8031bc:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  8031be:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8031c0:	83 c4 20             	add    $0x20,%esp
  8031c3:	5e                   	pop    %esi
  8031c4:	5f                   	pop    %edi
  8031c5:	5d                   	pop    %ebp
  8031c6:	c3                   	ret    
  8031c7:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  8031c8:	89 d1                	mov    %edx,%ecx
  8031ca:	89 c5                	mov    %eax,%ebp
  8031cc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8031d0:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8031d4:	eb 8d                	jmp    803163 <__umoddi3+0xaf>
  8031d6:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8031d8:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8031dc:	72 ea                	jb     8031c8 <__umoddi3+0x114>
  8031de:	89 f1                	mov    %esi,%ecx
  8031e0:	eb 81                	jmp    803163 <__umoddi3+0xaf>
