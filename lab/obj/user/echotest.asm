
obj/user/echotest.debug:     file format elf32-i386


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
  80002c:	e8 e7 04 00 00       	call   800518 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <die>:

const char *msg = "Hello world!\n";

static void
die(char *m)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("%s\n", m);
  80003a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003e:	c7 04 24 60 29 80 00 	movl   $0x802960,(%esp)
  800045:	e8 de 05 00 00       	call   800628 <cprintf>
	exit();
  80004a:	e8 1d 05 00 00       	call   80056c <exit>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <umain>:

void umain(int argc, char **argv)
{
  800051:	55                   	push   %ebp
  800052:	89 e5                	mov    %esp,%ebp
  800054:	57                   	push   %edi
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	83 ec 5c             	sub    $0x5c,%esp
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	cprintf("Connecting to:\n");
  80005a:	c7 04 24 64 29 80 00 	movl   $0x802964,(%esp)
  800061:	e8 c2 05 00 00       	call   800628 <cprintf>
	cprintf("\tip address %s = %x\n", IPADDR, inet_addr(IPADDR));
  800066:	c7 04 24 74 29 80 00 	movl   $0x802974,(%esp)
  80006d:	e8 69 04 00 00       	call   8004db <inet_addr>
  800072:	89 44 24 08          	mov    %eax,0x8(%esp)
  800076:	c7 44 24 04 74 29 80 	movl   $0x802974,0x4(%esp)
  80007d:	00 
  80007e:	c7 04 24 7e 29 80 00 	movl   $0x80297e,(%esp)
  800085:	e8 9e 05 00 00       	call   800628 <cprintf>

	// Create the TCP socket
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  80008a:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800099:	00 
  80009a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8000a1:	e8 91 1c 00 00       	call   801d37 <socket>
  8000a6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  8000a9:	85 c0                	test   %eax,%eax
  8000ab:	79 0a                	jns    8000b7 <umain+0x66>
		die("Failed to create socket");
  8000ad:	b8 93 29 80 00       	mov    $0x802993,%eax
  8000b2:	e8 7d ff ff ff       	call   800034 <die>

	cprintf("opened socket\n");
  8000b7:	c7 04 24 ab 29 80 00 	movl   $0x8029ab,(%esp)
  8000be:	e8 65 05 00 00       	call   800628 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  8000c3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  8000ca:	00 
  8000cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000d2:	00 
  8000d3:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8000d6:	89 1c 24             	mov    %ebx,(%esp)
  8000d9:	e8 24 0c 00 00       	call   800d02 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  8000de:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = inet_addr(IPADDR);   // IP address
  8000e2:	c7 04 24 74 29 80 00 	movl   $0x802974,(%esp)
  8000e9:	e8 ed 03 00 00       	call   8004db <inet_addr>
  8000ee:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  8000f1:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  8000f8:	e8 90 01 00 00       	call   80028d <htons>
  8000fd:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to connect to server\n");
  800101:	c7 04 24 ba 29 80 00 	movl   $0x8029ba,(%esp)
  800108:	e8 1b 05 00 00       	call   800628 <cprintf>

	// Establish connection
	if (connect(sock, (struct sockaddr *) &echoserver, sizeof(echoserver)) < 0)
  80010d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800114:	00 
  800115:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800119:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 c6 1b 00 00       	call   801cea <connect>
  800124:	85 c0                	test   %eax,%eax
  800126:	79 0a                	jns    800132 <umain+0xe1>
		die("Failed to connect with server");
  800128:	b8 d7 29 80 00       	mov    $0x8029d7,%eax
  80012d:	e8 02 ff ff ff       	call   800034 <die>

	cprintf("connected to server\n");
  800132:	c7 04 24 f5 29 80 00 	movl   $0x8029f5,(%esp)
  800139:	e8 ea 04 00 00       	call   800628 <cprintf>

	// Send the word to the server
	echolen = strlen(msg);
  80013e:	a1 00 30 80 00       	mov    0x803000,%eax
  800143:	89 04 24             	mov    %eax,(%esp)
  800146:	e8 55 0a 00 00       	call   800ba0 <strlen>
  80014b:	89 45 b0             	mov    %eax,-0x50(%ebp)
	if (write(sock, msg, echolen) != echolen)
  80014e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800152:	a1 00 30 80 00       	mov    0x803000,%eax
  800157:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  80015e:	89 04 24             	mov    %eax,(%esp)
  800161:	e8 21 15 00 00       	call   801687 <write>
  800166:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  800169:	74 0a                	je     800175 <umain+0x124>
		die("Mismatch in number of sent bytes");
  80016b:	b8 24 2a 80 00       	mov    $0x802a24,%eax
  800170:	e8 bf fe ff ff       	call   800034 <die>

	// Receive the word back from the server
	cprintf("Received: \n");
  800175:	c7 04 24 0a 2a 80 00 	movl   $0x802a0a,(%esp)
  80017c:	e8 a7 04 00 00       	call   800628 <cprintf>
{
	int sock;
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;
  800181:	bf 00 00 00 00       	mov    $0x0,%edi

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  800186:	8d 75 b8             	lea    -0x48(%ebp),%esi
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  800189:	eb 36                	jmp    8001c1 <umain+0x170>
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80018b:	c7 44 24 08 1f 00 00 	movl   $0x1f,0x8(%esp)
  800192:	00 
  800193:	89 74 24 04          	mov    %esi,0x4(%esp)
  800197:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  80019a:	89 04 24             	mov    %eax,(%esp)
  80019d:	e8 0a 14 00 00       	call   8015ac <read>
  8001a2:	89 c3                	mov    %eax,%ebx
  8001a4:	85 c0                	test   %eax,%eax
  8001a6:	7f 0a                	jg     8001b2 <umain+0x161>
			die("Failed to receive bytes from server");
  8001a8:	b8 48 2a 80 00       	mov    $0x802a48,%eax
  8001ad:	e8 82 fe ff ff       	call   800034 <die>
		}
		received += bytes;
  8001b2:	01 df                	add    %ebx,%edi
		buffer[bytes] = '\0';        // Assure null terminated string
  8001b4:	c6 44 1d b8 00       	movb   $0x0,-0x48(%ebp,%ebx,1)
		cprintf(buffer);
  8001b9:	89 34 24             	mov    %esi,(%esp)
  8001bc:	e8 67 04 00 00       	call   800628 <cprintf>
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  8001c1:	39 7d b0             	cmp    %edi,-0x50(%ebp)
  8001c4:	77 c5                	ja     80018b <umain+0x13a>
		}
		received += bytes;
		buffer[bytes] = '\0';        // Assure null terminated string
		cprintf(buffer);
	}
	cprintf("\n");
  8001c6:	c7 04 24 14 2a 80 00 	movl   $0x802a14,(%esp)
  8001cd:	e8 56 04 00 00       	call   800628 <cprintf>

	close(sock);
  8001d2:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	e8 69 12 00 00       	call   801446 <close>
}
  8001dd:	83 c4 5c             	add    $0x5c,%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5f                   	pop    %edi
  8001e3:	5d                   	pop    %ebp
  8001e4:	c3                   	ret    
  8001e5:	00 00                	add    %al,(%eax)
	...

008001e8 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 1c             	sub    $0x1c,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8001f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8001f7:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8001fb:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  8001fe:	c7 45 dc 00 40 80 00 	movl   $0x804000,-0x24(%ebp)
 */
char *
inet_ntoa(struct in_addr addr)
{
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800205:	b2 00                	mov    $0x0,%dl
  800207:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  80020a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80020d:	8a 00                	mov    (%eax),%al
  80020f:	88 45 e2             	mov    %al,-0x1e(%ebp)
      *ap /= (u8_t)10;
  800212:	0f b6 c0             	movzbl %al,%eax
  800215:	8d 34 80             	lea    (%eax,%eax,4),%esi
  800218:	8d 04 f0             	lea    (%eax,%esi,8),%eax
  80021b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80021e:	66 c1 e8 0b          	shr    $0xb,%ax
  800222:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800225:	88 01                	mov    %al,(%ecx)
      inv[i++] = '0' + rem;
  800227:	0f b6 f2             	movzbl %dl,%esi
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  80022a:	8d 3c 80             	lea    (%eax,%eax,4),%edi
  80022d:	d1 e7                	shl    %edi
  80022f:	8a 5d e2             	mov    -0x1e(%ebp),%bl
  800232:	89 f9                	mov    %edi,%ecx
  800234:	28 cb                	sub    %cl,%bl
  800236:	89 df                	mov    %ebx,%edi
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
  800238:	8d 4f 30             	lea    0x30(%edi),%ecx
  80023b:	88 4c 35 ed          	mov    %cl,-0x13(%ebp,%esi,1)
  80023f:	42                   	inc    %edx
    } while(*ap);
  800240:	84 c0                	test   %al,%al
  800242:	75 c6                	jne    80020a <inet_ntoa+0x22>
  800244:	88 d0                	mov    %dl,%al
  800246:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800249:	8b 7d d8             	mov    -0x28(%ebp),%edi
  80024c:	eb 0b                	jmp    800259 <inet_ntoa+0x71>
    while(i--)
  80024e:	48                   	dec    %eax
      *rp++ = inv[i];
  80024f:	0f b6 f0             	movzbl %al,%esi
  800252:	8a 5c 35 ed          	mov    -0x13(%ebp,%esi,1),%bl
  800256:	88 19                	mov    %bl,(%ecx)
  800258:	41                   	inc    %ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800259:	84 c0                	test   %al,%al
  80025b:	75 f1                	jne    80024e <inet_ntoa+0x66>
  80025d:	89 7d d8             	mov    %edi,-0x28(%ebp)
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  800260:	0f b6 d2             	movzbl %dl,%edx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800263:	03 55 dc             	add    -0x24(%ebp),%edx
      *rp++ = inv[i];
    *rp++ = '.';
  800266:	c6 02 2e             	movb   $0x2e,(%edx)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800269:	fe 45 e3             	incb   -0x1d(%ebp)
  80026c:	80 7d e3 03          	cmpb   $0x3,-0x1d(%ebp)
  800270:	77 0b                	ja     80027d <inet_ntoa+0x95>
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
  800272:	42                   	inc    %edx
  800273:	89 55 dc             	mov    %edx,-0x24(%ebp)
    ap++;
  800276:	ff 45 d8             	incl   -0x28(%ebp)
  800279:	88 c2                	mov    %al,%dl
  80027b:	eb 8d                	jmp    80020a <inet_ntoa+0x22>
  }
  *--rp = 0;
  80027d:	c6 02 00             	movb   $0x0,(%edx)
  return str;
}
  800280:	b8 00 40 80 00       	mov    $0x804000,%eax
  800285:	83 c4 1c             	add    $0x1c,%esp
  800288:	5b                   	pop    %ebx
  800289:	5e                   	pop    %esi
  80028a:	5f                   	pop    %edi
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    

0080028d <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  800290:	8b 45 08             	mov    0x8(%ebp),%eax
  800293:	66 c1 c0 08          	rol    $0x8,%ax
}
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    

00800299 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  80029f:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8002a3:	89 04 24             	mov    %eax,(%esp)
  8002a6:	e8 e2 ff ff ff       	call   80028d <htons>
}
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    

008002ad <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  8002b3:	89 d1                	mov    %edx,%ecx
  8002b5:	c1 e9 18             	shr    $0x18,%ecx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  8002b8:	89 d0                	mov    %edx,%eax
  8002ba:	c1 e0 18             	shl    $0x18,%eax
  8002bd:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  8002bf:	89 d1                	mov    %edx,%ecx
  8002c1:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  8002c7:	c1 e1 08             	shl    $0x8,%ecx
  8002ca:	09 c8                	or     %ecx,%eax
    ((n & 0xff0000UL) >> 8) |
  8002cc:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8002d2:	c1 ea 08             	shr    $0x8,%edx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  8002d5:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    

008002d9 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	57                   	push   %edi
  8002dd:	56                   	push   %esi
  8002de:	53                   	push   %ebx
  8002df:	83 ec 24             	sub    $0x24,%esp
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8002e5:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  8002e8:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  8002eb:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8002ee:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  8002f1:	89 5d e0             	mov    %ebx,-0x20(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8002f4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002f7:	80 f9 09             	cmp    $0x9,%cl
  8002fa:	0f 87 8f 01 00 00    	ja     80048f <inet_aton+0x1b6>
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  800300:	83 fa 30             	cmp    $0x30,%edx
  800303:	75 28                	jne    80032d <inet_aton+0x54>
      c = *++cp;
  800305:	0f be 50 01          	movsbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  800309:	83 fa 78             	cmp    $0x78,%edx
  80030c:	74 0f                	je     80031d <inet_aton+0x44>
  80030e:	83 fa 58             	cmp    $0x58,%edx
  800311:	74 0a                	je     80031d <inet_aton+0x44>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  800313:	40                   	inc    %eax
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  800314:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  80031b:	eb 17                	jmp    800334 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  80031d:	0f be 50 02          	movsbl 0x2(%eax),%edx
  800321:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  800324:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
        c = *++cp;
  80032b:	eb 07                	jmp    800334 <inet_aton+0x5b>
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
  80032d:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
  800334:	40                   	inc    %eax
  800335:	be 00 00 00 00       	mov    $0x0,%esi
  80033a:	eb 01                	jmp    80033d <inet_aton+0x64>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  80033c:	40                   	inc    %eax
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
  80033d:	8d 78 ff             	lea    -0x1(%eax),%edi
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800340:	88 d1                	mov    %dl,%cl
  800342:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800345:	80 fb 09             	cmp    $0x9,%bl
  800348:	77 0d                	ja     800357 <inet_aton+0x7e>
        val = (val * base) + (int)(c - '0');
  80034a:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  80034e:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  800352:	0f be 10             	movsbl (%eax),%edx
  800355:	eb e5                	jmp    80033c <inet_aton+0x63>
      } else if (base == 16 && isxdigit(c)) {
  800357:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  80035b:	75 30                	jne    80038d <inet_aton+0xb4>
  80035d:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800360:	88 5d da             	mov    %bl,-0x26(%ebp)
  800363:	80 fb 05             	cmp    $0x5,%bl
  800366:	76 08                	jbe    800370 <inet_aton+0x97>
  800368:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80036b:	80 fb 05             	cmp    $0x5,%bl
  80036e:	77 23                	ja     800393 <inet_aton+0xba>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800370:	89 f1                	mov    %esi,%ecx
  800372:	c1 e1 04             	shl    $0x4,%ecx
  800375:	8d 72 0a             	lea    0xa(%edx),%esi
  800378:	80 7d da 1a          	cmpb   $0x1a,-0x26(%ebp)
  80037c:	19 d2                	sbb    %edx,%edx
  80037e:	83 e2 20             	and    $0x20,%edx
  800381:	83 c2 41             	add    $0x41,%edx
  800384:	29 d6                	sub    %edx,%esi
  800386:	09 ce                	or     %ecx,%esi
        c = *++cp;
  800388:	0f be 10             	movsbl (%eax),%edx
  80038b:	eb af                	jmp    80033c <inet_aton+0x63>
    }
    for (;;) {
      if (isdigit(c)) {
        val = (val * base) + (int)(c - '0');
        c = *++cp;
      } else if (base == 16 && isxdigit(c)) {
  80038d:	89 d0                	mov    %edx,%eax
  80038f:	89 f3                	mov    %esi,%ebx
  800391:	eb 04                	jmp    800397 <inet_aton+0xbe>
  800393:	89 d0                	mov    %edx,%eax
  800395:	89 f3                	mov    %esi,%ebx
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
        c = *++cp;
      } else
        break;
    }
    if (c == '.') {
  800397:	83 f8 2e             	cmp    $0x2e,%eax
  80039a:	75 23                	jne    8003bf <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  80039c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80039f:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
  8003a2:	0f 83 ee 00 00 00    	jae    800496 <inet_aton+0x1bd>
        return (0);
      *pp++ = val;
  8003a8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003ab:	89 1a                	mov    %ebx,(%edx)
  8003ad:	83 c2 04             	add    $0x4,%edx
  8003b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
      c = *++cp;
  8003b3:	8d 47 01             	lea    0x1(%edi),%eax
  8003b6:	0f be 57 01          	movsbl 0x1(%edi),%edx
    } else
      break;
  }
  8003ba:	e9 35 ff ff ff       	jmp    8002f4 <inet_aton+0x1b>
  8003bf:	89 f3                	mov    %esi,%ebx
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
        c = *++cp;
      } else
        break;
    }
    if (c == '.') {
  8003c1:	89 f0                	mov    %esi,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003c3:	85 d2                	test   %edx,%edx
  8003c5:	74 33                	je     8003fa <inet_aton+0x121>
  8003c7:	80 f9 1f             	cmp    $0x1f,%cl
  8003ca:	0f 86 cd 00 00 00    	jbe    80049d <inet_aton+0x1c4>
  8003d0:	84 d2                	test   %dl,%dl
  8003d2:	0f 88 cc 00 00 00    	js     8004a4 <inet_aton+0x1cb>
  8003d8:	83 fa 20             	cmp    $0x20,%edx
  8003db:	74 1d                	je     8003fa <inet_aton+0x121>
  8003dd:	83 fa 0c             	cmp    $0xc,%edx
  8003e0:	74 18                	je     8003fa <inet_aton+0x121>
  8003e2:	83 fa 0a             	cmp    $0xa,%edx
  8003e5:	74 13                	je     8003fa <inet_aton+0x121>
  8003e7:	83 fa 0d             	cmp    $0xd,%edx
  8003ea:	74 0e                	je     8003fa <inet_aton+0x121>
  8003ec:	83 fa 09             	cmp    $0x9,%edx
  8003ef:	74 09                	je     8003fa <inet_aton+0x121>
  8003f1:	83 fa 0b             	cmp    $0xb,%edx
  8003f4:	0f 85 b1 00 00 00    	jne    8004ab <inet_aton+0x1d2>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  8003fa:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8003fd:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800400:	29 d1                	sub    %edx,%ecx
  800402:	89 ca                	mov    %ecx,%edx
  800404:	c1 fa 02             	sar    $0x2,%edx
  800407:	42                   	inc    %edx
  switch (n) {
  800408:	83 fa 02             	cmp    $0x2,%edx
  80040b:	74 1b                	je     800428 <inet_aton+0x14f>
  80040d:	83 fa 02             	cmp    $0x2,%edx
  800410:	7f 0a                	jg     80041c <inet_aton+0x143>
  800412:	85 d2                	test   %edx,%edx
  800414:	0f 84 98 00 00 00    	je     8004b2 <inet_aton+0x1d9>
  80041a:	eb 59                	jmp    800475 <inet_aton+0x19c>
  80041c:	83 fa 03             	cmp    $0x3,%edx
  80041f:	74 1c                	je     80043d <inet_aton+0x164>
  800421:	83 fa 04             	cmp    $0x4,%edx
  800424:	75 4f                	jne    800475 <inet_aton+0x19c>
  800426:	eb 2e                	jmp    800456 <inet_aton+0x17d>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  800428:	3d ff ff ff 00       	cmp    $0xffffff,%eax
  80042d:	0f 87 86 00 00 00    	ja     8004b9 <inet_aton+0x1e0>
      return (0);
    val |= parts[0] << 24;
  800433:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800436:	c1 e3 18             	shl    $0x18,%ebx
  800439:	09 c3                	or     %eax,%ebx
    break;
  80043b:	eb 38                	jmp    800475 <inet_aton+0x19c>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  80043d:	3d ff ff 00 00       	cmp    $0xffff,%eax
  800442:	77 7c                	ja     8004c0 <inet_aton+0x1e7>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  800444:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800447:	c1 e3 10             	shl    $0x10,%ebx
  80044a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80044d:	c1 e2 18             	shl    $0x18,%edx
  800450:	09 d3                	or     %edx,%ebx
  800452:	09 c3                	or     %eax,%ebx
    break;
  800454:	eb 1f                	jmp    800475 <inet_aton+0x19c>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  800456:	3d ff 00 00 00       	cmp    $0xff,%eax
  80045b:	77 6a                	ja     8004c7 <inet_aton+0x1ee>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  80045d:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800460:	c1 e3 10             	shl    $0x10,%ebx
  800463:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800466:	c1 e2 18             	shl    $0x18,%edx
  800469:	09 d3                	or     %edx,%ebx
  80046b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80046e:	c1 e2 08             	shl    $0x8,%edx
  800471:	09 d3                	or     %edx,%ebx
  800473:	09 c3                	or     %eax,%ebx
    break;
  }
  if (addr)
  800475:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800479:	74 53                	je     8004ce <inet_aton+0x1f5>
    addr->s_addr = htonl(val);
  80047b:	89 1c 24             	mov    %ebx,(%esp)
  80047e:	e8 2a fe ff ff       	call   8002ad <htonl>
  800483:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800486:	89 03                	mov    %eax,(%ebx)
  return (1);
  800488:	b8 01 00 00 00       	mov    $0x1,%eax
  80048d:	eb 44                	jmp    8004d3 <inet_aton+0x1fa>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  80048f:	b8 00 00 00 00       	mov    $0x0,%eax
  800494:	eb 3d                	jmp    8004d3 <inet_aton+0x1fa>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  800496:	b8 00 00 00 00       	mov    $0x0,%eax
  80049b:	eb 36                	jmp    8004d3 <inet_aton+0x1fa>
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
    return (0);
  80049d:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a2:	eb 2f                	jmp    8004d3 <inet_aton+0x1fa>
  8004a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a9:	eb 28                	jmp    8004d3 <inet_aton+0x1fa>
  8004ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b0:	eb 21                	jmp    8004d3 <inet_aton+0x1fa>
   */
  n = pp - parts + 1;
  switch (n) {

  case 0:
    return (0);       /* initial nondigit */
  8004b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b7:	eb 1a                	jmp    8004d3 <inet_aton+0x1fa>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8004b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004be:	eb 13                	jmp    8004d3 <inet_aton+0x1fa>
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  8004c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c5:	eb 0c                	jmp    8004d3 <inet_aton+0x1fa>
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  8004c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cc:	eb 05                	jmp    8004d3 <inet_aton+0x1fa>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  8004ce:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8004d3:	83 c4 24             	add    $0x24,%esp
  8004d6:	5b                   	pop    %ebx
  8004d7:	5e                   	pop    %esi
  8004d8:	5f                   	pop    %edi
  8004d9:	5d                   	pop    %ebp
  8004da:	c3                   	ret    

008004db <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8004db:	55                   	push   %ebp
  8004dc:	89 e5                	mov    %esp,%ebp
  8004de:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  8004e1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8004e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004eb:	89 04 24             	mov    %eax,(%esp)
  8004ee:	e8 e6 fd ff ff       	call   8002d9 <inet_aton>
  8004f3:	85 c0                	test   %eax,%eax
  8004f5:	74 05                	je     8004fc <inet_addr+0x21>
    return (val.s_addr);
  8004f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8004fa:	eb 05                	jmp    800501 <inet_addr+0x26>
  }
  return (INADDR_NONE);
  8004fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  800501:	c9                   	leave  
  800502:	c3                   	ret    

00800503 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  800503:	55                   	push   %ebp
  800504:	89 e5                	mov    %esp,%ebp
  800506:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  800509:	8b 45 08             	mov    0x8(%ebp),%eax
  80050c:	89 04 24             	mov    %eax,(%esp)
  80050f:	e8 99 fd ff ff       	call   8002ad <htonl>
}
  800514:	c9                   	leave  
  800515:	c3                   	ret    
	...

00800518 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800518:	55                   	push   %ebp
  800519:	89 e5                	mov    %esp,%ebp
  80051b:	56                   	push   %esi
  80051c:	53                   	push   %ebx
  80051d:	83 ec 10             	sub    $0x10,%esp
  800520:	8b 75 08             	mov    0x8(%ebp),%esi
  800523:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800526:	e8 5c 0a 00 00       	call   800f87 <sys_getenvid>
  80052b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800530:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800537:	c1 e0 07             	shl    $0x7,%eax
  80053a:	29 d0                	sub    %edx,%eax
  80053c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800541:	a3 18 40 80 00       	mov    %eax,0x804018


	// save the name of the program so that panic() can use it
	if (argc > 0)
  800546:	85 f6                	test   %esi,%esi
  800548:	7e 07                	jle    800551 <libmain+0x39>
		binaryname = argv[0];
  80054a:	8b 03                	mov    (%ebx),%eax
  80054c:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800551:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800555:	89 34 24             	mov    %esi,(%esp)
  800558:	e8 f4 fa ff ff       	call   800051 <umain>

	// exit gracefully
	exit();
  80055d:	e8 0a 00 00 00       	call   80056c <exit>
}
  800562:	83 c4 10             	add    $0x10,%esp
  800565:	5b                   	pop    %ebx
  800566:	5e                   	pop    %esi
  800567:	5d                   	pop    %ebp
  800568:	c3                   	ret    
  800569:	00 00                	add    %al,(%eax)
	...

0080056c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80056c:	55                   	push   %ebp
  80056d:	89 e5                	mov    %esp,%ebp
  80056f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800572:	e8 00 0f 00 00       	call   801477 <close_all>
	sys_env_destroy(0);
  800577:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80057e:	e8 b2 09 00 00       	call   800f35 <sys_env_destroy>
}
  800583:	c9                   	leave  
  800584:	c3                   	ret    
  800585:	00 00                	add    %al,(%eax)
	...

00800588 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800588:	55                   	push   %ebp
  800589:	89 e5                	mov    %esp,%ebp
  80058b:	53                   	push   %ebx
  80058c:	83 ec 14             	sub    $0x14,%esp
  80058f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800592:	8b 03                	mov    (%ebx),%eax
  800594:	8b 55 08             	mov    0x8(%ebp),%edx
  800597:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80059b:	40                   	inc    %eax
  80059c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80059e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8005a3:	75 19                	jne    8005be <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8005a5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8005ac:	00 
  8005ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	e8 40 09 00 00       	call   800ef8 <sys_cputs>
		b->idx = 0;
  8005b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8005be:	ff 43 04             	incl   0x4(%ebx)
}
  8005c1:	83 c4 14             	add    $0x14,%esp
  8005c4:	5b                   	pop    %ebx
  8005c5:	5d                   	pop    %ebp
  8005c6:	c3                   	ret    

008005c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8005c7:	55                   	push   %ebp
  8005c8:	89 e5                	mov    %esp,%ebp
  8005ca:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8005d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005d7:	00 00 00 
	b.cnt = 0;
  8005da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005f2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fc:	c7 04 24 88 05 80 00 	movl   $0x800588,(%esp)
  800603:	e8 82 01 00 00       	call   80078a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800608:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80060e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800612:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800618:	89 04 24             	mov    %eax,(%esp)
  80061b:	e8 d8 08 00 00       	call   800ef8 <sys_cputs>

	return b.cnt;
}
  800620:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800626:	c9                   	leave  
  800627:	c3                   	ret    

00800628 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80062e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800631:	89 44 24 04          	mov    %eax,0x4(%esp)
  800635:	8b 45 08             	mov    0x8(%ebp),%eax
  800638:	89 04 24             	mov    %eax,(%esp)
  80063b:	e8 87 ff ff ff       	call   8005c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800640:	c9                   	leave  
  800641:	c3                   	ret    
	...

00800644 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800644:	55                   	push   %ebp
  800645:	89 e5                	mov    %esp,%ebp
  800647:	57                   	push   %edi
  800648:	56                   	push   %esi
  800649:	53                   	push   %ebx
  80064a:	83 ec 3c             	sub    $0x3c,%esp
  80064d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800650:	89 d7                	mov    %edx,%edi
  800652:	8b 45 08             	mov    0x8(%ebp),%eax
  800655:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800658:	8b 45 0c             	mov    0xc(%ebp),%eax
  80065b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80065e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800661:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800664:	85 c0                	test   %eax,%eax
  800666:	75 08                	jne    800670 <printnum+0x2c>
  800668:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80066b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80066e:	77 57                	ja     8006c7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800670:	89 74 24 10          	mov    %esi,0x10(%esp)
  800674:	4b                   	dec    %ebx
  800675:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800679:	8b 45 10             	mov    0x10(%ebp),%eax
  80067c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800680:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800684:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800688:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80068f:	00 
  800690:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800693:	89 04 24             	mov    %eax,(%esp)
  800696:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069d:	e8 66 20 00 00       	call   802708 <__udivdi3>
  8006a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006a6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006aa:	89 04 24             	mov    %eax,(%esp)
  8006ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b1:	89 fa                	mov    %edi,%edx
  8006b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006b6:	e8 89 ff ff ff       	call   800644 <printnum>
  8006bb:	eb 0f                	jmp    8006cc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006c1:	89 34 24             	mov    %esi,(%esp)
  8006c4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006c7:	4b                   	dec    %ebx
  8006c8:	85 db                	test   %ebx,%ebx
  8006ca:	7f f1                	jg     8006bd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8006d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8006d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8006e2:	00 
  8006e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006e6:	89 04 24             	mov    %eax,(%esp)
  8006e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f0:	e8 33 21 00 00       	call   802828 <__umoddi3>
  8006f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f9:	0f be 80 76 2a 80 00 	movsbl 0x802a76(%eax),%eax
  800700:	89 04 24             	mov    %eax,(%esp)
  800703:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800706:	83 c4 3c             	add    $0x3c,%esp
  800709:	5b                   	pop    %ebx
  80070a:	5e                   	pop    %esi
  80070b:	5f                   	pop    %edi
  80070c:	5d                   	pop    %ebp
  80070d:	c3                   	ret    

0080070e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800711:	83 fa 01             	cmp    $0x1,%edx
  800714:	7e 0e                	jle    800724 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800716:	8b 10                	mov    (%eax),%edx
  800718:	8d 4a 08             	lea    0x8(%edx),%ecx
  80071b:	89 08                	mov    %ecx,(%eax)
  80071d:	8b 02                	mov    (%edx),%eax
  80071f:	8b 52 04             	mov    0x4(%edx),%edx
  800722:	eb 22                	jmp    800746 <getuint+0x38>
	else if (lflag)
  800724:	85 d2                	test   %edx,%edx
  800726:	74 10                	je     800738 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800728:	8b 10                	mov    (%eax),%edx
  80072a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80072d:	89 08                	mov    %ecx,(%eax)
  80072f:	8b 02                	mov    (%edx),%eax
  800731:	ba 00 00 00 00       	mov    $0x0,%edx
  800736:	eb 0e                	jmp    800746 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800738:	8b 10                	mov    (%eax),%edx
  80073a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80073d:	89 08                	mov    %ecx,(%eax)
  80073f:	8b 02                	mov    (%edx),%eax
  800741:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800746:	5d                   	pop    %ebp
  800747:	c3                   	ret    

00800748 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800748:	55                   	push   %ebp
  800749:	89 e5                	mov    %esp,%ebp
  80074b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80074e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800751:	8b 10                	mov    (%eax),%edx
  800753:	3b 50 04             	cmp    0x4(%eax),%edx
  800756:	73 08                	jae    800760 <sprintputch+0x18>
		*b->buf++ = ch;
  800758:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075b:	88 0a                	mov    %cl,(%edx)
  80075d:	42                   	inc    %edx
  80075e:	89 10                	mov    %edx,(%eax)
}
  800760:	5d                   	pop    %ebp
  800761:	c3                   	ret    

00800762 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800768:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80076b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80076f:	8b 45 10             	mov    0x10(%ebp),%eax
  800772:	89 44 24 08          	mov    %eax,0x8(%esp)
  800776:	8b 45 0c             	mov    0xc(%ebp),%eax
  800779:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077d:	8b 45 08             	mov    0x8(%ebp),%eax
  800780:	89 04 24             	mov    %eax,(%esp)
  800783:	e8 02 00 00 00       	call   80078a <vprintfmt>
	va_end(ap);
}
  800788:	c9                   	leave  
  800789:	c3                   	ret    

0080078a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	57                   	push   %edi
  80078e:	56                   	push   %esi
  80078f:	53                   	push   %ebx
  800790:	83 ec 4c             	sub    $0x4c,%esp
  800793:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800796:	8b 75 10             	mov    0x10(%ebp),%esi
  800799:	eb 12                	jmp    8007ad <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80079b:	85 c0                	test   %eax,%eax
  80079d:	0f 84 6b 03 00 00    	je     800b0e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8007a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a7:	89 04 24             	mov    %eax,(%esp)
  8007aa:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007ad:	0f b6 06             	movzbl (%esi),%eax
  8007b0:	46                   	inc    %esi
  8007b1:	83 f8 25             	cmp    $0x25,%eax
  8007b4:	75 e5                	jne    80079b <vprintfmt+0x11>
  8007b6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8007ba:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8007c1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8007c6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8007cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d2:	eb 26                	jmp    8007fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8007d7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8007db:	eb 1d                	jmp    8007fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8007e0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8007e4:	eb 14                	jmp    8007fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8007e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8007f0:	eb 08                	jmp    8007fa <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8007f2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8007f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007fa:	0f b6 06             	movzbl (%esi),%eax
  8007fd:	8d 56 01             	lea    0x1(%esi),%edx
  800800:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800803:	8a 16                	mov    (%esi),%dl
  800805:	83 ea 23             	sub    $0x23,%edx
  800808:	80 fa 55             	cmp    $0x55,%dl
  80080b:	0f 87 e1 02 00 00    	ja     800af2 <vprintfmt+0x368>
  800811:	0f b6 d2             	movzbl %dl,%edx
  800814:	ff 24 95 c0 2b 80 00 	jmp    *0x802bc0(,%edx,4)
  80081b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80081e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800823:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800826:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80082a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80082d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800830:	83 fa 09             	cmp    $0x9,%edx
  800833:	77 2a                	ja     80085f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800835:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800836:	eb eb                	jmp    800823 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800838:	8b 45 14             	mov    0x14(%ebp),%eax
  80083b:	8d 50 04             	lea    0x4(%eax),%edx
  80083e:	89 55 14             	mov    %edx,0x14(%ebp)
  800841:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800843:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800846:	eb 17                	jmp    80085f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800848:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80084c:	78 98                	js     8007e6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800851:	eb a7                	jmp    8007fa <vprintfmt+0x70>
  800853:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800856:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80085d:	eb 9b                	jmp    8007fa <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80085f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800863:	79 95                	jns    8007fa <vprintfmt+0x70>
  800865:	eb 8b                	jmp    8007f2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800867:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800868:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80086b:	eb 8d                	jmp    8007fa <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80086d:	8b 45 14             	mov    0x14(%ebp),%eax
  800870:	8d 50 04             	lea    0x4(%eax),%edx
  800873:	89 55 14             	mov    %edx,0x14(%ebp)
  800876:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80087a:	8b 00                	mov    (%eax),%eax
  80087c:	89 04 24             	mov    %eax,(%esp)
  80087f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800882:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800885:	e9 23 ff ff ff       	jmp    8007ad <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80088a:	8b 45 14             	mov    0x14(%ebp),%eax
  80088d:	8d 50 04             	lea    0x4(%eax),%edx
  800890:	89 55 14             	mov    %edx,0x14(%ebp)
  800893:	8b 00                	mov    (%eax),%eax
  800895:	85 c0                	test   %eax,%eax
  800897:	79 02                	jns    80089b <vprintfmt+0x111>
  800899:	f7 d8                	neg    %eax
  80089b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80089d:	83 f8 10             	cmp    $0x10,%eax
  8008a0:	7f 0b                	jg     8008ad <vprintfmt+0x123>
  8008a2:	8b 04 85 20 2d 80 00 	mov    0x802d20(,%eax,4),%eax
  8008a9:	85 c0                	test   %eax,%eax
  8008ab:	75 23                	jne    8008d0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8008ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008b1:	c7 44 24 08 8e 2a 80 	movl   $0x802a8e,0x8(%esp)
  8008b8:	00 
  8008b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	89 04 24             	mov    %eax,(%esp)
  8008c3:	e8 9a fe ff ff       	call   800762 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8008cb:	e9 dd fe ff ff       	jmp    8007ad <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8008d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008d4:	c7 44 24 08 59 2e 80 	movl   $0x802e59,0x8(%esp)
  8008db:	00 
  8008dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8008e3:	89 14 24             	mov    %edx,(%esp)
  8008e6:	e8 77 fe ff ff       	call   800762 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008ee:	e9 ba fe ff ff       	jmp    8007ad <vprintfmt+0x23>
  8008f3:	89 f9                	mov    %edi,%ecx
  8008f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8008f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fe:	8d 50 04             	lea    0x4(%eax),%edx
  800901:	89 55 14             	mov    %edx,0x14(%ebp)
  800904:	8b 30                	mov    (%eax),%esi
  800906:	85 f6                	test   %esi,%esi
  800908:	75 05                	jne    80090f <vprintfmt+0x185>
				p = "(null)";
  80090a:	be 87 2a 80 00       	mov    $0x802a87,%esi
			if (width > 0 && padc != '-')
  80090f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800913:	0f 8e 84 00 00 00    	jle    80099d <vprintfmt+0x213>
  800919:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80091d:	74 7e                	je     80099d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80091f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800923:	89 34 24             	mov    %esi,(%esp)
  800926:	e8 8b 02 00 00       	call   800bb6 <strnlen>
  80092b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80092e:	29 c2                	sub    %eax,%edx
  800930:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800933:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800937:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80093a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80093d:	89 de                	mov    %ebx,%esi
  80093f:	89 d3                	mov    %edx,%ebx
  800941:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800943:	eb 0b                	jmp    800950 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800945:	89 74 24 04          	mov    %esi,0x4(%esp)
  800949:	89 3c 24             	mov    %edi,(%esp)
  80094c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80094f:	4b                   	dec    %ebx
  800950:	85 db                	test   %ebx,%ebx
  800952:	7f f1                	jg     800945 <vprintfmt+0x1bb>
  800954:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800957:	89 f3                	mov    %esi,%ebx
  800959:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80095c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80095f:	85 c0                	test   %eax,%eax
  800961:	79 05                	jns    800968 <vprintfmt+0x1de>
  800963:	b8 00 00 00 00       	mov    $0x0,%eax
  800968:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80096b:	29 c2                	sub    %eax,%edx
  80096d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800970:	eb 2b                	jmp    80099d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800972:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800976:	74 18                	je     800990 <vprintfmt+0x206>
  800978:	8d 50 e0             	lea    -0x20(%eax),%edx
  80097b:	83 fa 5e             	cmp    $0x5e,%edx
  80097e:	76 10                	jbe    800990 <vprintfmt+0x206>
					putch('?', putdat);
  800980:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800984:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80098b:	ff 55 08             	call   *0x8(%ebp)
  80098e:	eb 0a                	jmp    80099a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800990:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800994:	89 04 24             	mov    %eax,(%esp)
  800997:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80099a:	ff 4d e4             	decl   -0x1c(%ebp)
  80099d:	0f be 06             	movsbl (%esi),%eax
  8009a0:	46                   	inc    %esi
  8009a1:	85 c0                	test   %eax,%eax
  8009a3:	74 21                	je     8009c6 <vprintfmt+0x23c>
  8009a5:	85 ff                	test   %edi,%edi
  8009a7:	78 c9                	js     800972 <vprintfmt+0x1e8>
  8009a9:	4f                   	dec    %edi
  8009aa:	79 c6                	jns    800972 <vprintfmt+0x1e8>
  8009ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009af:	89 de                	mov    %ebx,%esi
  8009b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8009b4:	eb 18                	jmp    8009ce <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8009b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009ba:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009c1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009c3:	4b                   	dec    %ebx
  8009c4:	eb 08                	jmp    8009ce <vprintfmt+0x244>
  8009c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009c9:	89 de                	mov    %ebx,%esi
  8009cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8009ce:	85 db                	test   %ebx,%ebx
  8009d0:	7f e4                	jg     8009b6 <vprintfmt+0x22c>
  8009d2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8009d5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009da:	e9 ce fd ff ff       	jmp    8007ad <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8009df:	83 f9 01             	cmp    $0x1,%ecx
  8009e2:	7e 10                	jle    8009f4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8009e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e7:	8d 50 08             	lea    0x8(%eax),%edx
  8009ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ed:	8b 30                	mov    (%eax),%esi
  8009ef:	8b 78 04             	mov    0x4(%eax),%edi
  8009f2:	eb 26                	jmp    800a1a <vprintfmt+0x290>
	else if (lflag)
  8009f4:	85 c9                	test   %ecx,%ecx
  8009f6:	74 12                	je     800a0a <vprintfmt+0x280>
		return va_arg(*ap, long);
  8009f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8009fb:	8d 50 04             	lea    0x4(%eax),%edx
  8009fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800a01:	8b 30                	mov    (%eax),%esi
  800a03:	89 f7                	mov    %esi,%edi
  800a05:	c1 ff 1f             	sar    $0x1f,%edi
  800a08:	eb 10                	jmp    800a1a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800a0a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0d:	8d 50 04             	lea    0x4(%eax),%edx
  800a10:	89 55 14             	mov    %edx,0x14(%ebp)
  800a13:	8b 30                	mov    (%eax),%esi
  800a15:	89 f7                	mov    %esi,%edi
  800a17:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a1a:	85 ff                	test   %edi,%edi
  800a1c:	78 0a                	js     800a28 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a1e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a23:	e9 8c 00 00 00       	jmp    800ab4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800a28:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a2c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a33:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a36:	f7 de                	neg    %esi
  800a38:	83 d7 00             	adc    $0x0,%edi
  800a3b:	f7 df                	neg    %edi
			}
			base = 10;
  800a3d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a42:	eb 70                	jmp    800ab4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a44:	89 ca                	mov    %ecx,%edx
  800a46:	8d 45 14             	lea    0x14(%ebp),%eax
  800a49:	e8 c0 fc ff ff       	call   80070e <getuint>
  800a4e:	89 c6                	mov    %eax,%esi
  800a50:	89 d7                	mov    %edx,%edi
			base = 10;
  800a52:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800a57:	eb 5b                	jmp    800ab4 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800a59:	89 ca                	mov    %ecx,%edx
  800a5b:	8d 45 14             	lea    0x14(%ebp),%eax
  800a5e:	e8 ab fc ff ff       	call   80070e <getuint>
  800a63:	89 c6                	mov    %eax,%esi
  800a65:	89 d7                	mov    %edx,%edi
			base = 8;
  800a67:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800a6c:	eb 46                	jmp    800ab4 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800a6e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a72:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a79:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800a7c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a80:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a87:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a8a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8d:	8d 50 04             	lea    0x4(%eax),%edx
  800a90:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a93:	8b 30                	mov    (%eax),%esi
  800a95:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a9a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a9f:	eb 13                	jmp    800ab4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800aa1:	89 ca                	mov    %ecx,%edx
  800aa3:	8d 45 14             	lea    0x14(%ebp),%eax
  800aa6:	e8 63 fc ff ff       	call   80070e <getuint>
  800aab:	89 c6                	mov    %eax,%esi
  800aad:	89 d7                	mov    %edx,%edi
			base = 16;
  800aaf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ab4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800ab8:	89 54 24 10          	mov    %edx,0x10(%esp)
  800abc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800abf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ac3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ac7:	89 34 24             	mov    %esi,(%esp)
  800aca:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ace:	89 da                	mov    %ebx,%edx
  800ad0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad3:	e8 6c fb ff ff       	call   800644 <printnum>
			break;
  800ad8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800adb:	e9 cd fc ff ff       	jmp    8007ad <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ae0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae4:	89 04 24             	mov    %eax,(%esp)
  800ae7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800aed:	e9 bb fc ff ff       	jmp    8007ad <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800af2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800af6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800afd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b00:	eb 01                	jmp    800b03 <vprintfmt+0x379>
  800b02:	4e                   	dec    %esi
  800b03:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b07:	75 f9                	jne    800b02 <vprintfmt+0x378>
  800b09:	e9 9f fc ff ff       	jmp    8007ad <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800b0e:	83 c4 4c             	add    $0x4c,%esp
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	83 ec 28             	sub    $0x28,%esp
  800b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b22:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b25:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b29:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b33:	85 c0                	test   %eax,%eax
  800b35:	74 30                	je     800b67 <vsnprintf+0x51>
  800b37:	85 d2                	test   %edx,%edx
  800b39:	7e 33                	jle    800b6e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b3b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b42:	8b 45 10             	mov    0x10(%ebp),%eax
  800b45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b49:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b50:	c7 04 24 48 07 80 00 	movl   $0x800748,(%esp)
  800b57:	e8 2e fc ff ff       	call   80078a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b5f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b65:	eb 0c                	jmp    800b73 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b6c:	eb 05                	jmp    800b73 <vsnprintf+0x5d>
  800b6e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b73:	c9                   	leave  
  800b74:	c3                   	ret    

00800b75 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b7b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b82:	8b 45 10             	mov    0x10(%ebp),%eax
  800b85:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b90:	8b 45 08             	mov    0x8(%ebp),%eax
  800b93:	89 04 24             	mov    %eax,(%esp)
  800b96:	e8 7b ff ff ff       	call   800b16 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    
  800b9d:	00 00                	add    %al,(%eax)
	...

00800ba0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ba6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bab:	eb 01                	jmp    800bae <strlen+0xe>
		n++;
  800bad:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bb2:	75 f9                	jne    800bad <strlen+0xd>
		n++;
	return n;
}
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800bbc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc4:	eb 01                	jmp    800bc7 <strnlen+0x11>
		n++;
  800bc6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bc7:	39 d0                	cmp    %edx,%eax
  800bc9:	74 06                	je     800bd1 <strnlen+0x1b>
  800bcb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800bcf:	75 f5                	jne    800bc6 <strnlen+0x10>
		n++;
	return n;
}
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    

00800bd3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	53                   	push   %ebx
  800bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bda:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800be2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800be5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800be8:	42                   	inc    %edx
  800be9:	84 c9                	test   %cl,%cl
  800beb:	75 f5                	jne    800be2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bed:	5b                   	pop    %ebx
  800bee:	5d                   	pop    %ebp
  800bef:	c3                   	ret    

00800bf0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 08             	sub    $0x8,%esp
  800bf7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800bfa:	89 1c 24             	mov    %ebx,(%esp)
  800bfd:	e8 9e ff ff ff       	call   800ba0 <strlen>
	strcpy(dst + len, src);
  800c02:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c05:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c09:	01 d8                	add    %ebx,%eax
  800c0b:	89 04 24             	mov    %eax,(%esp)
  800c0e:	e8 c0 ff ff ff       	call   800bd3 <strcpy>
	return dst;
}
  800c13:	89 d8                	mov    %ebx,%eax
  800c15:	83 c4 08             	add    $0x8,%esp
  800c18:	5b                   	pop    %ebx
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	8b 45 08             	mov    0x8(%ebp),%eax
  800c23:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c26:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2e:	eb 0c                	jmp    800c3c <strncpy+0x21>
		*dst++ = *src;
  800c30:	8a 1a                	mov    (%edx),%bl
  800c32:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c35:	80 3a 01             	cmpb   $0x1,(%edx)
  800c38:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c3b:	41                   	inc    %ecx
  800c3c:	39 f1                	cmp    %esi,%ecx
  800c3e:	75 f0                	jne    800c30 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	8b 75 08             	mov    0x8(%ebp),%esi
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c52:	85 d2                	test   %edx,%edx
  800c54:	75 0a                	jne    800c60 <strlcpy+0x1c>
  800c56:	89 f0                	mov    %esi,%eax
  800c58:	eb 1a                	jmp    800c74 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c5a:	88 18                	mov    %bl,(%eax)
  800c5c:	40                   	inc    %eax
  800c5d:	41                   	inc    %ecx
  800c5e:	eb 02                	jmp    800c62 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c60:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800c62:	4a                   	dec    %edx
  800c63:	74 0a                	je     800c6f <strlcpy+0x2b>
  800c65:	8a 19                	mov    (%ecx),%bl
  800c67:	84 db                	test   %bl,%bl
  800c69:	75 ef                	jne    800c5a <strlcpy+0x16>
  800c6b:	89 c2                	mov    %eax,%edx
  800c6d:	eb 02                	jmp    800c71 <strlcpy+0x2d>
  800c6f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800c71:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800c74:	29 f0                	sub    %esi,%eax
}
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c80:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c83:	eb 02                	jmp    800c87 <strcmp+0xd>
		p++, q++;
  800c85:	41                   	inc    %ecx
  800c86:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c87:	8a 01                	mov    (%ecx),%al
  800c89:	84 c0                	test   %al,%al
  800c8b:	74 04                	je     800c91 <strcmp+0x17>
  800c8d:	3a 02                	cmp    (%edx),%al
  800c8f:	74 f4                	je     800c85 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c91:	0f b6 c0             	movzbl %al,%eax
  800c94:	0f b6 12             	movzbl (%edx),%edx
  800c97:	29 d0                	sub    %edx,%eax
}
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	53                   	push   %ebx
  800c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800ca8:	eb 03                	jmp    800cad <strncmp+0x12>
		n--, p++, q++;
  800caa:	4a                   	dec    %edx
  800cab:	40                   	inc    %eax
  800cac:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cad:	85 d2                	test   %edx,%edx
  800caf:	74 14                	je     800cc5 <strncmp+0x2a>
  800cb1:	8a 18                	mov    (%eax),%bl
  800cb3:	84 db                	test   %bl,%bl
  800cb5:	74 04                	je     800cbb <strncmp+0x20>
  800cb7:	3a 19                	cmp    (%ecx),%bl
  800cb9:	74 ef                	je     800caa <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cbb:	0f b6 00             	movzbl (%eax),%eax
  800cbe:	0f b6 11             	movzbl (%ecx),%edx
  800cc1:	29 d0                	sub    %edx,%eax
  800cc3:	eb 05                	jmp    800cca <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800cc5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cca:	5b                   	pop    %ebx
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800cd6:	eb 05                	jmp    800cdd <strchr+0x10>
		if (*s == c)
  800cd8:	38 ca                	cmp    %cl,%dl
  800cda:	74 0c                	je     800ce8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800cdc:	40                   	inc    %eax
  800cdd:	8a 10                	mov    (%eax),%dl
  800cdf:	84 d2                	test   %dl,%dl
  800ce1:	75 f5                	jne    800cd8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800ce3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ce8:	5d                   	pop    %ebp
  800ce9:	c3                   	ret    

00800cea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800cf3:	eb 05                	jmp    800cfa <strfind+0x10>
		if (*s == c)
  800cf5:	38 ca                	cmp    %cl,%dl
  800cf7:	74 07                	je     800d00 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800cf9:	40                   	inc    %eax
  800cfa:	8a 10                	mov    (%eax),%dl
  800cfc:	84 d2                	test   %dl,%dl
  800cfe:	75 f5                	jne    800cf5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d11:	85 c9                	test   %ecx,%ecx
  800d13:	74 30                	je     800d45 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d1b:	75 25                	jne    800d42 <memset+0x40>
  800d1d:	f6 c1 03             	test   $0x3,%cl
  800d20:	75 20                	jne    800d42 <memset+0x40>
		c &= 0xFF;
  800d22:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d25:	89 d3                	mov    %edx,%ebx
  800d27:	c1 e3 08             	shl    $0x8,%ebx
  800d2a:	89 d6                	mov    %edx,%esi
  800d2c:	c1 e6 18             	shl    $0x18,%esi
  800d2f:	89 d0                	mov    %edx,%eax
  800d31:	c1 e0 10             	shl    $0x10,%eax
  800d34:	09 f0                	or     %esi,%eax
  800d36:	09 d0                	or     %edx,%eax
  800d38:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d3a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d3d:	fc                   	cld    
  800d3e:	f3 ab                	rep stos %eax,%es:(%edi)
  800d40:	eb 03                	jmp    800d45 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d42:	fc                   	cld    
  800d43:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d45:	89 f8                	mov    %edi,%eax
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	8b 45 08             	mov    0x8(%ebp),%eax
  800d54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d57:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d5a:	39 c6                	cmp    %eax,%esi
  800d5c:	73 34                	jae    800d92 <memmove+0x46>
  800d5e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d61:	39 d0                	cmp    %edx,%eax
  800d63:	73 2d                	jae    800d92 <memmove+0x46>
		s += n;
		d += n;
  800d65:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d68:	f6 c2 03             	test   $0x3,%dl
  800d6b:	75 1b                	jne    800d88 <memmove+0x3c>
  800d6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d73:	75 13                	jne    800d88 <memmove+0x3c>
  800d75:	f6 c1 03             	test   $0x3,%cl
  800d78:	75 0e                	jne    800d88 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d7a:	83 ef 04             	sub    $0x4,%edi
  800d7d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d80:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800d83:	fd                   	std    
  800d84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d86:	eb 07                	jmp    800d8f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d88:	4f                   	dec    %edi
  800d89:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d8c:	fd                   	std    
  800d8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d8f:	fc                   	cld    
  800d90:	eb 20                	jmp    800db2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d92:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d98:	75 13                	jne    800dad <memmove+0x61>
  800d9a:	a8 03                	test   $0x3,%al
  800d9c:	75 0f                	jne    800dad <memmove+0x61>
  800d9e:	f6 c1 03             	test   $0x3,%cl
  800da1:	75 0a                	jne    800dad <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800da3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800da6:	89 c7                	mov    %eax,%edi
  800da8:	fc                   	cld    
  800da9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dab:	eb 05                	jmp    800db2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dad:	89 c7                	mov    %eax,%edi
  800daf:	fc                   	cld    
  800db0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    

00800db6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800dbc:	8b 45 10             	mov    0x10(%ebp),%eax
  800dbf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dca:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcd:	89 04 24             	mov    %eax,(%esp)
  800dd0:	e8 77 ff ff ff       	call   800d4c <memmove>
}
  800dd5:	c9                   	leave  
  800dd6:	c3                   	ret    

00800dd7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	57                   	push   %edi
  800ddb:	56                   	push   %esi
  800ddc:	53                   	push   %ebx
  800ddd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800de0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800de6:	ba 00 00 00 00       	mov    $0x0,%edx
  800deb:	eb 16                	jmp    800e03 <memcmp+0x2c>
		if (*s1 != *s2)
  800ded:	8a 04 17             	mov    (%edi,%edx,1),%al
  800df0:	42                   	inc    %edx
  800df1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800df5:	38 c8                	cmp    %cl,%al
  800df7:	74 0a                	je     800e03 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800df9:	0f b6 c0             	movzbl %al,%eax
  800dfc:	0f b6 c9             	movzbl %cl,%ecx
  800dff:	29 c8                	sub    %ecx,%eax
  800e01:	eb 09                	jmp    800e0c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e03:	39 da                	cmp    %ebx,%edx
  800e05:	75 e6                	jne    800ded <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e0c:	5b                   	pop    %ebx
  800e0d:	5e                   	pop    %esi
  800e0e:	5f                   	pop    %edi
  800e0f:	5d                   	pop    %ebp
  800e10:	c3                   	ret    

00800e11 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	8b 45 08             	mov    0x8(%ebp),%eax
  800e17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e1a:	89 c2                	mov    %eax,%edx
  800e1c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e1f:	eb 05                	jmp    800e26 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e21:	38 08                	cmp    %cl,(%eax)
  800e23:	74 05                	je     800e2a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e25:	40                   	inc    %eax
  800e26:	39 d0                	cmp    %edx,%eax
  800e28:	72 f7                	jb     800e21 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	57                   	push   %edi
  800e30:	56                   	push   %esi
  800e31:	53                   	push   %ebx
  800e32:	8b 55 08             	mov    0x8(%ebp),%edx
  800e35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e38:	eb 01                	jmp    800e3b <strtol+0xf>
		s++;
  800e3a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e3b:	8a 02                	mov    (%edx),%al
  800e3d:	3c 20                	cmp    $0x20,%al
  800e3f:	74 f9                	je     800e3a <strtol+0xe>
  800e41:	3c 09                	cmp    $0x9,%al
  800e43:	74 f5                	je     800e3a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e45:	3c 2b                	cmp    $0x2b,%al
  800e47:	75 08                	jne    800e51 <strtol+0x25>
		s++;
  800e49:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800e4f:	eb 13                	jmp    800e64 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e51:	3c 2d                	cmp    $0x2d,%al
  800e53:	75 0a                	jne    800e5f <strtol+0x33>
		s++, neg = 1;
  800e55:	8d 52 01             	lea    0x1(%edx),%edx
  800e58:	bf 01 00 00 00       	mov    $0x1,%edi
  800e5d:	eb 05                	jmp    800e64 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e5f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e64:	85 db                	test   %ebx,%ebx
  800e66:	74 05                	je     800e6d <strtol+0x41>
  800e68:	83 fb 10             	cmp    $0x10,%ebx
  800e6b:	75 28                	jne    800e95 <strtol+0x69>
  800e6d:	8a 02                	mov    (%edx),%al
  800e6f:	3c 30                	cmp    $0x30,%al
  800e71:	75 10                	jne    800e83 <strtol+0x57>
  800e73:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e77:	75 0a                	jne    800e83 <strtol+0x57>
		s += 2, base = 16;
  800e79:	83 c2 02             	add    $0x2,%edx
  800e7c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e81:	eb 12                	jmp    800e95 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800e83:	85 db                	test   %ebx,%ebx
  800e85:	75 0e                	jne    800e95 <strtol+0x69>
  800e87:	3c 30                	cmp    $0x30,%al
  800e89:	75 05                	jne    800e90 <strtol+0x64>
		s++, base = 8;
  800e8b:	42                   	inc    %edx
  800e8c:	b3 08                	mov    $0x8,%bl
  800e8e:	eb 05                	jmp    800e95 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800e90:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e95:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e9c:	8a 0a                	mov    (%edx),%cl
  800e9e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ea1:	80 fb 09             	cmp    $0x9,%bl
  800ea4:	77 08                	ja     800eae <strtol+0x82>
			dig = *s - '0';
  800ea6:	0f be c9             	movsbl %cl,%ecx
  800ea9:	83 e9 30             	sub    $0x30,%ecx
  800eac:	eb 1e                	jmp    800ecc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800eae:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800eb1:	80 fb 19             	cmp    $0x19,%bl
  800eb4:	77 08                	ja     800ebe <strtol+0x92>
			dig = *s - 'a' + 10;
  800eb6:	0f be c9             	movsbl %cl,%ecx
  800eb9:	83 e9 57             	sub    $0x57,%ecx
  800ebc:	eb 0e                	jmp    800ecc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ebe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ec1:	80 fb 19             	cmp    $0x19,%bl
  800ec4:	77 12                	ja     800ed8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ec6:	0f be c9             	movsbl %cl,%ecx
  800ec9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ecc:	39 f1                	cmp    %esi,%ecx
  800ece:	7d 0c                	jge    800edc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ed0:	42                   	inc    %edx
  800ed1:	0f af c6             	imul   %esi,%eax
  800ed4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ed6:	eb c4                	jmp    800e9c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ed8:	89 c1                	mov    %eax,%ecx
  800eda:	eb 02                	jmp    800ede <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800edc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ede:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ee2:	74 05                	je     800ee9 <strtol+0xbd>
		*endptr = (char *) s;
  800ee4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ee7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ee9:	85 ff                	test   %edi,%edi
  800eeb:	74 04                	je     800ef1 <strtol+0xc5>
  800eed:	89 c8                	mov    %ecx,%eax
  800eef:	f7 d8                	neg    %eax
}
  800ef1:	5b                   	pop    %ebx
  800ef2:	5e                   	pop    %esi
  800ef3:	5f                   	pop    %edi
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    
	...

00800ef8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	57                   	push   %edi
  800efc:	56                   	push   %esi
  800efd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800efe:	b8 00 00 00 00       	mov    $0x0,%eax
  800f03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f06:	8b 55 08             	mov    0x8(%ebp),%edx
  800f09:	89 c3                	mov    %eax,%ebx
  800f0b:	89 c7                	mov    %eax,%edi
  800f0d:	89 c6                	mov    %eax,%esi
  800f0f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f11:	5b                   	pop    %ebx
  800f12:	5e                   	pop    %esi
  800f13:	5f                   	pop    %edi
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    

00800f16 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	57                   	push   %edi
  800f1a:	56                   	push   %esi
  800f1b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f21:	b8 01 00 00 00       	mov    $0x1,%eax
  800f26:	89 d1                	mov    %edx,%ecx
  800f28:	89 d3                	mov    %edx,%ebx
  800f2a:	89 d7                	mov    %edx,%edi
  800f2c:	89 d6                	mov    %edx,%esi
  800f2e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	57                   	push   %edi
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
  800f3b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f43:	b8 03 00 00 00       	mov    $0x3,%eax
  800f48:	8b 55 08             	mov    0x8(%ebp),%edx
  800f4b:	89 cb                	mov    %ecx,%ebx
  800f4d:	89 cf                	mov    %ecx,%edi
  800f4f:	89 ce                	mov    %ecx,%esi
  800f51:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f53:	85 c0                	test   %eax,%eax
  800f55:	7e 28                	jle    800f7f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f57:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f5b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f62:	00 
  800f63:	c7 44 24 08 83 2d 80 	movl   $0x802d83,0x8(%esp)
  800f6a:	00 
  800f6b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f72:	00 
  800f73:	c7 04 24 a0 2d 80 00 	movl   $0x802da0,(%esp)
  800f7a:	e8 b5 15 00 00       	call   802534 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f7f:	83 c4 2c             	add    $0x2c,%esp
  800f82:	5b                   	pop    %ebx
  800f83:	5e                   	pop    %esi
  800f84:	5f                   	pop    %edi
  800f85:	5d                   	pop    %ebp
  800f86:	c3                   	ret    

00800f87 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	57                   	push   %edi
  800f8b:	56                   	push   %esi
  800f8c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f92:	b8 02 00 00 00       	mov    $0x2,%eax
  800f97:	89 d1                	mov    %edx,%ecx
  800f99:	89 d3                	mov    %edx,%ebx
  800f9b:	89 d7                	mov    %edx,%edi
  800f9d:	89 d6                	mov    %edx,%esi
  800f9f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800fa1:	5b                   	pop    %ebx
  800fa2:	5e                   	pop    %esi
  800fa3:	5f                   	pop    %edi
  800fa4:	5d                   	pop    %ebp
  800fa5:	c3                   	ret    

00800fa6 <sys_yield>:

void
sys_yield(void)
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	57                   	push   %edi
  800faa:	56                   	push   %esi
  800fab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fac:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fb6:	89 d1                	mov    %edx,%ecx
  800fb8:	89 d3                	mov    %edx,%ebx
  800fba:	89 d7                	mov    %edx,%edi
  800fbc:	89 d6                	mov    %edx,%esi
  800fbe:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fc0:	5b                   	pop    %ebx
  800fc1:	5e                   	pop    %esi
  800fc2:	5f                   	pop    %edi
  800fc3:	5d                   	pop    %ebp
  800fc4:	c3                   	ret    

00800fc5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	57                   	push   %edi
  800fc9:	56                   	push   %esi
  800fca:	53                   	push   %ebx
  800fcb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fce:	be 00 00 00 00       	mov    $0x0,%esi
  800fd3:	b8 04 00 00 00       	mov    $0x4,%eax
  800fd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fde:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe1:	89 f7                	mov    %esi,%edi
  800fe3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	7e 28                	jle    801011 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fed:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ff4:	00 
  800ff5:	c7 44 24 08 83 2d 80 	movl   $0x802d83,0x8(%esp)
  800ffc:	00 
  800ffd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801004:	00 
  801005:	c7 04 24 a0 2d 80 00 	movl   $0x802da0,(%esp)
  80100c:	e8 23 15 00 00       	call   802534 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801011:	83 c4 2c             	add    $0x2c,%esp
  801014:	5b                   	pop    %ebx
  801015:	5e                   	pop    %esi
  801016:	5f                   	pop    %edi
  801017:	5d                   	pop    %ebp
  801018:	c3                   	ret    

00801019 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	57                   	push   %edi
  80101d:	56                   	push   %esi
  80101e:	53                   	push   %ebx
  80101f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801022:	b8 05 00 00 00       	mov    $0x5,%eax
  801027:	8b 75 18             	mov    0x18(%ebp),%esi
  80102a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80102d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801030:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801033:	8b 55 08             	mov    0x8(%ebp),%edx
  801036:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801038:	85 c0                	test   %eax,%eax
  80103a:	7e 28                	jle    801064 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103c:	89 44 24 10          	mov    %eax,0x10(%esp)
  801040:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801047:	00 
  801048:	c7 44 24 08 83 2d 80 	movl   $0x802d83,0x8(%esp)
  80104f:	00 
  801050:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801057:	00 
  801058:	c7 04 24 a0 2d 80 00 	movl   $0x802da0,(%esp)
  80105f:	e8 d0 14 00 00       	call   802534 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801064:	83 c4 2c             	add    $0x2c,%esp
  801067:	5b                   	pop    %ebx
  801068:	5e                   	pop    %esi
  801069:	5f                   	pop    %edi
  80106a:	5d                   	pop    %ebp
  80106b:	c3                   	ret    

0080106c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	57                   	push   %edi
  801070:	56                   	push   %esi
  801071:	53                   	push   %ebx
  801072:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801075:	bb 00 00 00 00       	mov    $0x0,%ebx
  80107a:	b8 06 00 00 00       	mov    $0x6,%eax
  80107f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801082:	8b 55 08             	mov    0x8(%ebp),%edx
  801085:	89 df                	mov    %ebx,%edi
  801087:	89 de                	mov    %ebx,%esi
  801089:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80108b:	85 c0                	test   %eax,%eax
  80108d:	7e 28                	jle    8010b7 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801093:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80109a:	00 
  80109b:	c7 44 24 08 83 2d 80 	movl   $0x802d83,0x8(%esp)
  8010a2:	00 
  8010a3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010aa:	00 
  8010ab:	c7 04 24 a0 2d 80 00 	movl   $0x802da0,(%esp)
  8010b2:	e8 7d 14 00 00       	call   802534 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010b7:	83 c4 2c             	add    $0x2c,%esp
  8010ba:	5b                   	pop    %ebx
  8010bb:	5e                   	pop    %esi
  8010bc:	5f                   	pop    %edi
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	57                   	push   %edi
  8010c3:	56                   	push   %esi
  8010c4:	53                   	push   %ebx
  8010c5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010cd:	b8 08 00 00 00       	mov    $0x8,%eax
  8010d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8010d8:	89 df                	mov    %ebx,%edi
  8010da:	89 de                	mov    %ebx,%esi
  8010dc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	7e 28                	jle    80110a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010e6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8010ed:	00 
  8010ee:	c7 44 24 08 83 2d 80 	movl   $0x802d83,0x8(%esp)
  8010f5:	00 
  8010f6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010fd:	00 
  8010fe:	c7 04 24 a0 2d 80 00 	movl   $0x802da0,(%esp)
  801105:	e8 2a 14 00 00       	call   802534 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80110a:	83 c4 2c             	add    $0x2c,%esp
  80110d:	5b                   	pop    %ebx
  80110e:	5e                   	pop    %esi
  80110f:	5f                   	pop    %edi
  801110:	5d                   	pop    %ebp
  801111:	c3                   	ret    

00801112 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
  801115:	57                   	push   %edi
  801116:	56                   	push   %esi
  801117:	53                   	push   %ebx
  801118:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80111b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801120:	b8 09 00 00 00       	mov    $0x9,%eax
  801125:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801128:	8b 55 08             	mov    0x8(%ebp),%edx
  80112b:	89 df                	mov    %ebx,%edi
  80112d:	89 de                	mov    %ebx,%esi
  80112f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801131:	85 c0                	test   %eax,%eax
  801133:	7e 28                	jle    80115d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801135:	89 44 24 10          	mov    %eax,0x10(%esp)
  801139:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801140:	00 
  801141:	c7 44 24 08 83 2d 80 	movl   $0x802d83,0x8(%esp)
  801148:	00 
  801149:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801150:	00 
  801151:	c7 04 24 a0 2d 80 00 	movl   $0x802da0,(%esp)
  801158:	e8 d7 13 00 00       	call   802534 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80115d:	83 c4 2c             	add    $0x2c,%esp
  801160:	5b                   	pop    %ebx
  801161:	5e                   	pop    %esi
  801162:	5f                   	pop    %edi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    

00801165 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801165:	55                   	push   %ebp
  801166:	89 e5                	mov    %esp,%ebp
  801168:	57                   	push   %edi
  801169:	56                   	push   %esi
  80116a:	53                   	push   %ebx
  80116b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80116e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801173:	b8 0a 00 00 00       	mov    $0xa,%eax
  801178:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117b:	8b 55 08             	mov    0x8(%ebp),%edx
  80117e:	89 df                	mov    %ebx,%edi
  801180:	89 de                	mov    %ebx,%esi
  801182:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801184:	85 c0                	test   %eax,%eax
  801186:	7e 28                	jle    8011b0 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801188:	89 44 24 10          	mov    %eax,0x10(%esp)
  80118c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801193:	00 
  801194:	c7 44 24 08 83 2d 80 	movl   $0x802d83,0x8(%esp)
  80119b:	00 
  80119c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011a3:	00 
  8011a4:	c7 04 24 a0 2d 80 00 	movl   $0x802da0,(%esp)
  8011ab:	e8 84 13 00 00       	call   802534 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011b0:	83 c4 2c             	add    $0x2c,%esp
  8011b3:	5b                   	pop    %ebx
  8011b4:	5e                   	pop    %esi
  8011b5:	5f                   	pop    %edi
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    

008011b8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	57                   	push   %edi
  8011bc:	56                   	push   %esi
  8011bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011be:	be 00 00 00 00       	mov    $0x0,%esi
  8011c3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011c8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8011d4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011d6:	5b                   	pop    %ebx
  8011d7:	5e                   	pop    %esi
  8011d8:	5f                   	pop    %edi
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    

008011db <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	57                   	push   %edi
  8011df:	56                   	push   %esi
  8011e0:	53                   	push   %ebx
  8011e1:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011e9:	b8 0d 00 00 00       	mov    $0xd,%eax
  8011ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f1:	89 cb                	mov    %ecx,%ebx
  8011f3:	89 cf                	mov    %ecx,%edi
  8011f5:	89 ce                	mov    %ecx,%esi
  8011f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	7e 28                	jle    801225 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011fd:	89 44 24 10          	mov    %eax,0x10(%esp)
  801201:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  801208:	00 
  801209:	c7 44 24 08 83 2d 80 	movl   $0x802d83,0x8(%esp)
  801210:	00 
  801211:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801218:	00 
  801219:	c7 04 24 a0 2d 80 00 	movl   $0x802da0,(%esp)
  801220:	e8 0f 13 00 00       	call   802534 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801225:	83 c4 2c             	add    $0x2c,%esp
  801228:	5b                   	pop    %ebx
  801229:	5e                   	pop    %esi
  80122a:	5f                   	pop    %edi
  80122b:	5d                   	pop    %ebp
  80122c:	c3                   	ret    

0080122d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	57                   	push   %edi
  801231:	56                   	push   %esi
  801232:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801233:	ba 00 00 00 00       	mov    $0x0,%edx
  801238:	b8 0e 00 00 00       	mov    $0xe,%eax
  80123d:	89 d1                	mov    %edx,%ecx
  80123f:	89 d3                	mov    %edx,%ebx
  801241:	89 d7                	mov    %edx,%edi
  801243:	89 d6                	mov    %edx,%esi
  801245:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801247:	5b                   	pop    %ebx
  801248:	5e                   	pop    %esi
  801249:	5f                   	pop    %edi
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    

0080124c <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	57                   	push   %edi
  801250:	56                   	push   %esi
  801251:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801252:	bb 00 00 00 00       	mov    $0x0,%ebx
  801257:	b8 0f 00 00 00       	mov    $0xf,%eax
  80125c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80125f:	8b 55 08             	mov    0x8(%ebp),%edx
  801262:	89 df                	mov    %ebx,%edi
  801264:	89 de                	mov    %ebx,%esi
  801266:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  801268:	5b                   	pop    %ebx
  801269:	5e                   	pop    %esi
  80126a:	5f                   	pop    %edi
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	57                   	push   %edi
  801271:	56                   	push   %esi
  801272:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801273:	bb 00 00 00 00       	mov    $0x0,%ebx
  801278:	b8 10 00 00 00       	mov    $0x10,%eax
  80127d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801280:	8b 55 08             	mov    0x8(%ebp),%edx
  801283:	89 df                	mov    %ebx,%edi
  801285:	89 de                	mov    %ebx,%esi
  801287:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  801289:	5b                   	pop    %ebx
  80128a:	5e                   	pop    %esi
  80128b:	5f                   	pop    %edi
  80128c:	5d                   	pop    %ebp
  80128d:	c3                   	ret    
	...

00801290 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801293:	8b 45 08             	mov    0x8(%ebp),%eax
  801296:	05 00 00 00 30       	add    $0x30000000,%eax
  80129b:	c1 e8 0c             	shr    $0xc,%eax
}
  80129e:	5d                   	pop    %ebp
  80129f:	c3                   	ret    

008012a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8012a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a9:	89 04 24             	mov    %eax,(%esp)
  8012ac:	e8 df ff ff ff       	call   801290 <fd2num>
  8012b1:	c1 e0 0c             	shl    $0xc,%eax
  8012b4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012b9:	c9                   	leave  
  8012ba:	c3                   	ret    

008012bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	53                   	push   %ebx
  8012bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012c2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012c7:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012c9:	89 c2                	mov    %eax,%edx
  8012cb:	c1 ea 16             	shr    $0x16,%edx
  8012ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d5:	f6 c2 01             	test   $0x1,%dl
  8012d8:	74 11                	je     8012eb <fd_alloc+0x30>
  8012da:	89 c2                	mov    %eax,%edx
  8012dc:	c1 ea 0c             	shr    $0xc,%edx
  8012df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e6:	f6 c2 01             	test   $0x1,%dl
  8012e9:	75 09                	jne    8012f4 <fd_alloc+0x39>
			*fd_store = fd;
  8012eb:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8012ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f2:	eb 17                	jmp    80130b <fd_alloc+0x50>
  8012f4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012f9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012fe:	75 c7                	jne    8012c7 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801300:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  801306:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80130b:	5b                   	pop    %ebx
  80130c:	5d                   	pop    %ebp
  80130d:	c3                   	ret    

0080130e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801314:	83 f8 1f             	cmp    $0x1f,%eax
  801317:	77 36                	ja     80134f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801319:	c1 e0 0c             	shl    $0xc,%eax
  80131c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801321:	89 c2                	mov    %eax,%edx
  801323:	c1 ea 16             	shr    $0x16,%edx
  801326:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80132d:	f6 c2 01             	test   $0x1,%dl
  801330:	74 24                	je     801356 <fd_lookup+0x48>
  801332:	89 c2                	mov    %eax,%edx
  801334:	c1 ea 0c             	shr    $0xc,%edx
  801337:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80133e:	f6 c2 01             	test   $0x1,%dl
  801341:	74 1a                	je     80135d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801343:	8b 55 0c             	mov    0xc(%ebp),%edx
  801346:	89 02                	mov    %eax,(%edx)
	return 0;
  801348:	b8 00 00 00 00       	mov    $0x0,%eax
  80134d:	eb 13                	jmp    801362 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80134f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801354:	eb 0c                	jmp    801362 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801356:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135b:	eb 05                	jmp    801362 <fd_lookup+0x54>
  80135d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801362:	5d                   	pop    %ebp
  801363:	c3                   	ret    

00801364 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	53                   	push   %ebx
  801368:	83 ec 14             	sub    $0x14,%esp
  80136b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80136e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801371:	ba 00 00 00 00       	mov    $0x0,%edx
  801376:	eb 0e                	jmp    801386 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801378:	39 08                	cmp    %ecx,(%eax)
  80137a:	75 09                	jne    801385 <dev_lookup+0x21>
			*dev = devtab[i];
  80137c:	89 03                	mov    %eax,(%ebx)
			return 0;
  80137e:	b8 00 00 00 00       	mov    $0x0,%eax
  801383:	eb 33                	jmp    8013b8 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801385:	42                   	inc    %edx
  801386:	8b 04 95 2c 2e 80 00 	mov    0x802e2c(,%edx,4),%eax
  80138d:	85 c0                	test   %eax,%eax
  80138f:	75 e7                	jne    801378 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801391:	a1 18 40 80 00       	mov    0x804018,%eax
  801396:	8b 40 48             	mov    0x48(%eax),%eax
  801399:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80139d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a1:	c7 04 24 b0 2d 80 00 	movl   $0x802db0,(%esp)
  8013a8:	e8 7b f2 ff ff       	call   800628 <cprintf>
	*dev = 0;
  8013ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013b8:	83 c4 14             	add    $0x14,%esp
  8013bb:	5b                   	pop    %ebx
  8013bc:	5d                   	pop    %ebp
  8013bd:	c3                   	ret    

008013be <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	56                   	push   %esi
  8013c2:	53                   	push   %ebx
  8013c3:	83 ec 30             	sub    $0x30,%esp
  8013c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8013c9:	8a 45 0c             	mov    0xc(%ebp),%al
  8013cc:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013cf:	89 34 24             	mov    %esi,(%esp)
  8013d2:	e8 b9 fe ff ff       	call   801290 <fd2num>
  8013d7:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013da:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013de:	89 04 24             	mov    %eax,(%esp)
  8013e1:	e8 28 ff ff ff       	call   80130e <fd_lookup>
  8013e6:	89 c3                	mov    %eax,%ebx
  8013e8:	85 c0                	test   %eax,%eax
  8013ea:	78 05                	js     8013f1 <fd_close+0x33>
	    || fd != fd2)
  8013ec:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013ef:	74 0d                	je     8013fe <fd_close+0x40>
		return (must_exist ? r : 0);
  8013f1:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8013f5:	75 46                	jne    80143d <fd_close+0x7f>
  8013f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013fc:	eb 3f                	jmp    80143d <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801401:	89 44 24 04          	mov    %eax,0x4(%esp)
  801405:	8b 06                	mov    (%esi),%eax
  801407:	89 04 24             	mov    %eax,(%esp)
  80140a:	e8 55 ff ff ff       	call   801364 <dev_lookup>
  80140f:	89 c3                	mov    %eax,%ebx
  801411:	85 c0                	test   %eax,%eax
  801413:	78 18                	js     80142d <fd_close+0x6f>
		if (dev->dev_close)
  801415:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801418:	8b 40 10             	mov    0x10(%eax),%eax
  80141b:	85 c0                	test   %eax,%eax
  80141d:	74 09                	je     801428 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80141f:	89 34 24             	mov    %esi,(%esp)
  801422:	ff d0                	call   *%eax
  801424:	89 c3                	mov    %eax,%ebx
  801426:	eb 05                	jmp    80142d <fd_close+0x6f>
		else
			r = 0;
  801428:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80142d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801431:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801438:	e8 2f fc ff ff       	call   80106c <sys_page_unmap>
	return r;
}
  80143d:	89 d8                	mov    %ebx,%eax
  80143f:	83 c4 30             	add    $0x30,%esp
  801442:	5b                   	pop    %ebx
  801443:	5e                   	pop    %esi
  801444:	5d                   	pop    %ebp
  801445:	c3                   	ret    

00801446 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80144c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801453:	8b 45 08             	mov    0x8(%ebp),%eax
  801456:	89 04 24             	mov    %eax,(%esp)
  801459:	e8 b0 fe ff ff       	call   80130e <fd_lookup>
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 13                	js     801475 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801462:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801469:	00 
  80146a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146d:	89 04 24             	mov    %eax,(%esp)
  801470:	e8 49 ff ff ff       	call   8013be <fd_close>
}
  801475:	c9                   	leave  
  801476:	c3                   	ret    

00801477 <close_all>:

void
close_all(void)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	53                   	push   %ebx
  80147b:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80147e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801483:	89 1c 24             	mov    %ebx,(%esp)
  801486:	e8 bb ff ff ff       	call   801446 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80148b:	43                   	inc    %ebx
  80148c:	83 fb 20             	cmp    $0x20,%ebx
  80148f:	75 f2                	jne    801483 <close_all+0xc>
		close(i);
}
  801491:	83 c4 14             	add    $0x14,%esp
  801494:	5b                   	pop    %ebx
  801495:	5d                   	pop    %ebp
  801496:	c3                   	ret    

00801497 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	57                   	push   %edi
  80149b:	56                   	push   %esi
  80149c:	53                   	push   %ebx
  80149d:	83 ec 4c             	sub    $0x4c,%esp
  8014a0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ad:	89 04 24             	mov    %eax,(%esp)
  8014b0:	e8 59 fe ff ff       	call   80130e <fd_lookup>
  8014b5:	89 c3                	mov    %eax,%ebx
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	0f 88 e3 00 00 00    	js     8015a2 <dup+0x10b>
		return r;
	close(newfdnum);
  8014bf:	89 3c 24             	mov    %edi,(%esp)
  8014c2:	e8 7f ff ff ff       	call   801446 <close>

	newfd = INDEX2FD(newfdnum);
  8014c7:	89 fe                	mov    %edi,%esi
  8014c9:	c1 e6 0c             	shl    $0xc,%esi
  8014cc:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8014d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014d5:	89 04 24             	mov    %eax,(%esp)
  8014d8:	e8 c3 fd ff ff       	call   8012a0 <fd2data>
  8014dd:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014df:	89 34 24             	mov    %esi,(%esp)
  8014e2:	e8 b9 fd ff ff       	call   8012a0 <fd2data>
  8014e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014ea:	89 d8                	mov    %ebx,%eax
  8014ec:	c1 e8 16             	shr    $0x16,%eax
  8014ef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014f6:	a8 01                	test   $0x1,%al
  8014f8:	74 46                	je     801540 <dup+0xa9>
  8014fa:	89 d8                	mov    %ebx,%eax
  8014fc:	c1 e8 0c             	shr    $0xc,%eax
  8014ff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801506:	f6 c2 01             	test   $0x1,%dl
  801509:	74 35                	je     801540 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80150b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801512:	25 07 0e 00 00       	and    $0xe07,%eax
  801517:	89 44 24 10          	mov    %eax,0x10(%esp)
  80151b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80151e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801522:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801529:	00 
  80152a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80152e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801535:	e8 df fa ff ff       	call   801019 <sys_page_map>
  80153a:	89 c3                	mov    %eax,%ebx
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 3b                	js     80157b <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801540:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801543:	89 c2                	mov    %eax,%edx
  801545:	c1 ea 0c             	shr    $0xc,%edx
  801548:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80154f:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801555:	89 54 24 10          	mov    %edx,0x10(%esp)
  801559:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80155d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801564:	00 
  801565:	89 44 24 04          	mov    %eax,0x4(%esp)
  801569:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801570:	e8 a4 fa ff ff       	call   801019 <sys_page_map>
  801575:	89 c3                	mov    %eax,%ebx
  801577:	85 c0                	test   %eax,%eax
  801579:	79 25                	jns    8015a0 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80157b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80157f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801586:	e8 e1 fa ff ff       	call   80106c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80158b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80158e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801592:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801599:	e8 ce fa ff ff       	call   80106c <sys_page_unmap>
	return r;
  80159e:	eb 02                	jmp    8015a2 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8015a0:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015a2:	89 d8                	mov    %ebx,%eax
  8015a4:	83 c4 4c             	add    $0x4c,%esp
  8015a7:	5b                   	pop    %ebx
  8015a8:	5e                   	pop    %esi
  8015a9:	5f                   	pop    %edi
  8015aa:	5d                   	pop    %ebp
  8015ab:	c3                   	ret    

008015ac <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	53                   	push   %ebx
  8015b0:	83 ec 24             	sub    $0x24,%esp
  8015b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015bd:	89 1c 24             	mov    %ebx,(%esp)
  8015c0:	e8 49 fd ff ff       	call   80130e <fd_lookup>
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 6d                	js     801636 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d3:	8b 00                	mov    (%eax),%eax
  8015d5:	89 04 24             	mov    %eax,(%esp)
  8015d8:	e8 87 fd ff ff       	call   801364 <dev_lookup>
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	78 55                	js     801636 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e4:	8b 50 08             	mov    0x8(%eax),%edx
  8015e7:	83 e2 03             	and    $0x3,%edx
  8015ea:	83 fa 01             	cmp    $0x1,%edx
  8015ed:	75 23                	jne    801612 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015ef:	a1 18 40 80 00       	mov    0x804018,%eax
  8015f4:	8b 40 48             	mov    0x48(%eax),%eax
  8015f7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ff:	c7 04 24 f1 2d 80 00 	movl   $0x802df1,(%esp)
  801606:	e8 1d f0 ff ff       	call   800628 <cprintf>
		return -E_INVAL;
  80160b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801610:	eb 24                	jmp    801636 <read+0x8a>
	}
	if (!dev->dev_read)
  801612:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801615:	8b 52 08             	mov    0x8(%edx),%edx
  801618:	85 d2                	test   %edx,%edx
  80161a:	74 15                	je     801631 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80161c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80161f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801623:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801626:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80162a:	89 04 24             	mov    %eax,(%esp)
  80162d:	ff d2                	call   *%edx
  80162f:	eb 05                	jmp    801636 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801631:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801636:	83 c4 24             	add    $0x24,%esp
  801639:	5b                   	pop    %ebx
  80163a:	5d                   	pop    %ebp
  80163b:	c3                   	ret    

0080163c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	57                   	push   %edi
  801640:	56                   	push   %esi
  801641:	53                   	push   %ebx
  801642:	83 ec 1c             	sub    $0x1c,%esp
  801645:	8b 7d 08             	mov    0x8(%ebp),%edi
  801648:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80164b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801650:	eb 23                	jmp    801675 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801652:	89 f0                	mov    %esi,%eax
  801654:	29 d8                	sub    %ebx,%eax
  801656:	89 44 24 08          	mov    %eax,0x8(%esp)
  80165a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80165d:	01 d8                	add    %ebx,%eax
  80165f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801663:	89 3c 24             	mov    %edi,(%esp)
  801666:	e8 41 ff ff ff       	call   8015ac <read>
		if (m < 0)
  80166b:	85 c0                	test   %eax,%eax
  80166d:	78 10                	js     80167f <readn+0x43>
			return m;
		if (m == 0)
  80166f:	85 c0                	test   %eax,%eax
  801671:	74 0a                	je     80167d <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801673:	01 c3                	add    %eax,%ebx
  801675:	39 f3                	cmp    %esi,%ebx
  801677:	72 d9                	jb     801652 <readn+0x16>
  801679:	89 d8                	mov    %ebx,%eax
  80167b:	eb 02                	jmp    80167f <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80167d:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  80167f:	83 c4 1c             	add    $0x1c,%esp
  801682:	5b                   	pop    %ebx
  801683:	5e                   	pop    %esi
  801684:	5f                   	pop    %edi
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	53                   	push   %ebx
  80168b:	83 ec 24             	sub    $0x24,%esp
  80168e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801691:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801694:	89 44 24 04          	mov    %eax,0x4(%esp)
  801698:	89 1c 24             	mov    %ebx,(%esp)
  80169b:	e8 6e fc ff ff       	call   80130e <fd_lookup>
  8016a0:	85 c0                	test   %eax,%eax
  8016a2:	78 68                	js     80170c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ae:	8b 00                	mov    (%eax),%eax
  8016b0:	89 04 24             	mov    %eax,(%esp)
  8016b3:	e8 ac fc ff ff       	call   801364 <dev_lookup>
  8016b8:	85 c0                	test   %eax,%eax
  8016ba:	78 50                	js     80170c <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016bf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016c3:	75 23                	jne    8016e8 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c5:	a1 18 40 80 00       	mov    0x804018,%eax
  8016ca:	8b 40 48             	mov    0x48(%eax),%eax
  8016cd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d5:	c7 04 24 0d 2e 80 00 	movl   $0x802e0d,(%esp)
  8016dc:	e8 47 ef ff ff       	call   800628 <cprintf>
		return -E_INVAL;
  8016e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016e6:	eb 24                	jmp    80170c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016eb:	8b 52 0c             	mov    0xc(%edx),%edx
  8016ee:	85 d2                	test   %edx,%edx
  8016f0:	74 15                	je     801707 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8016f5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016fc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801700:	89 04 24             	mov    %eax,(%esp)
  801703:	ff d2                	call   *%edx
  801705:	eb 05                	jmp    80170c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801707:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80170c:	83 c4 24             	add    $0x24,%esp
  80170f:	5b                   	pop    %ebx
  801710:	5d                   	pop    %ebp
  801711:	c3                   	ret    

00801712 <seek>:

int
seek(int fdnum, off_t offset)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801718:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80171b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171f:	8b 45 08             	mov    0x8(%ebp),%eax
  801722:	89 04 24             	mov    %eax,(%esp)
  801725:	e8 e4 fb ff ff       	call   80130e <fd_lookup>
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 0e                	js     80173c <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  80172e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801731:	8b 55 0c             	mov    0xc(%ebp),%edx
  801734:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801737:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	53                   	push   %ebx
  801742:	83 ec 24             	sub    $0x24,%esp
  801745:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801748:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80174b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174f:	89 1c 24             	mov    %ebx,(%esp)
  801752:	e8 b7 fb ff ff       	call   80130e <fd_lookup>
  801757:	85 c0                	test   %eax,%eax
  801759:	78 61                	js     8017bc <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801762:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801765:	8b 00                	mov    (%eax),%eax
  801767:	89 04 24             	mov    %eax,(%esp)
  80176a:	e8 f5 fb ff ff       	call   801364 <dev_lookup>
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 49                	js     8017bc <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801773:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801776:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80177a:	75 23                	jne    80179f <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80177c:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801781:	8b 40 48             	mov    0x48(%eax),%eax
  801784:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178c:	c7 04 24 d0 2d 80 00 	movl   $0x802dd0,(%esp)
  801793:	e8 90 ee ff ff       	call   800628 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801798:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80179d:	eb 1d                	jmp    8017bc <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  80179f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a2:	8b 52 18             	mov    0x18(%edx),%edx
  8017a5:	85 d2                	test   %edx,%edx
  8017a7:	74 0e                	je     8017b7 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017ac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017b0:	89 04 24             	mov    %eax,(%esp)
  8017b3:	ff d2                	call   *%edx
  8017b5:	eb 05                	jmp    8017bc <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017bc:	83 c4 24             	add    $0x24,%esp
  8017bf:	5b                   	pop    %ebx
  8017c0:	5d                   	pop    %ebp
  8017c1:	c3                   	ret    

008017c2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	53                   	push   %ebx
  8017c6:	83 ec 24             	sub    $0x24,%esp
  8017c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d6:	89 04 24             	mov    %eax,(%esp)
  8017d9:	e8 30 fb ff ff       	call   80130e <fd_lookup>
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 52                	js     801834 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ec:	8b 00                	mov    (%eax),%eax
  8017ee:	89 04 24             	mov    %eax,(%esp)
  8017f1:	e8 6e fb ff ff       	call   801364 <dev_lookup>
  8017f6:	85 c0                	test   %eax,%eax
  8017f8:	78 3a                	js     801834 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8017fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801801:	74 2c                	je     80182f <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801803:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801806:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80180d:	00 00 00 
	stat->st_isdir = 0;
  801810:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801817:	00 00 00 
	stat->st_dev = dev;
  80181a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801820:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801824:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801827:	89 14 24             	mov    %edx,(%esp)
  80182a:	ff 50 14             	call   *0x14(%eax)
  80182d:	eb 05                	jmp    801834 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80182f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801834:	83 c4 24             	add    $0x24,%esp
  801837:	5b                   	pop    %ebx
  801838:	5d                   	pop    %ebp
  801839:	c3                   	ret    

0080183a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80183a:	55                   	push   %ebp
  80183b:	89 e5                	mov    %esp,%ebp
  80183d:	56                   	push   %esi
  80183e:	53                   	push   %ebx
  80183f:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801842:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801849:	00 
  80184a:	8b 45 08             	mov    0x8(%ebp),%eax
  80184d:	89 04 24             	mov    %eax,(%esp)
  801850:	e8 2a 02 00 00       	call   801a7f <open>
  801855:	89 c3                	mov    %eax,%ebx
  801857:	85 c0                	test   %eax,%eax
  801859:	78 1b                	js     801876 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80185b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801862:	89 1c 24             	mov    %ebx,(%esp)
  801865:	e8 58 ff ff ff       	call   8017c2 <fstat>
  80186a:	89 c6                	mov    %eax,%esi
	close(fd);
  80186c:	89 1c 24             	mov    %ebx,(%esp)
  80186f:	e8 d2 fb ff ff       	call   801446 <close>
	return r;
  801874:	89 f3                	mov    %esi,%ebx
}
  801876:	89 d8                	mov    %ebx,%eax
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	5b                   	pop    %ebx
  80187c:	5e                   	pop    %esi
  80187d:	5d                   	pop    %ebp
  80187e:	c3                   	ret    
	...

00801880 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	56                   	push   %esi
  801884:	53                   	push   %ebx
  801885:	83 ec 10             	sub    $0x10,%esp
  801888:	89 c3                	mov    %eax,%ebx
  80188a:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  80188c:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  801893:	75 11                	jne    8018a6 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801895:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80189c:	e8 de 0d 00 00       	call   80267f <ipc_find_env>
  8018a1:	a3 10 40 80 00       	mov    %eax,0x804010
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018a6:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018ad:	00 
  8018ae:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8018b5:	00 
  8018b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018ba:	a1 10 40 80 00       	mov    0x804010,%eax
  8018bf:	89 04 24             	mov    %eax,(%esp)
  8018c2:	e8 35 0d 00 00       	call   8025fc <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018c7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018ce:	00 
  8018cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018da:	e8 ad 0c 00 00       	call   80258c <ipc_recv>
}
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	5b                   	pop    %ebx
  8018e3:	5e                   	pop    %esi
  8018e4:	5d                   	pop    %ebp
  8018e5:	c3                   	ret    

008018e6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018fa:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801904:	b8 02 00 00 00       	mov    $0x2,%eax
  801909:	e8 72 ff ff ff       	call   801880 <fsipc>
}
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    

00801910 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801916:	8b 45 08             	mov    0x8(%ebp),%eax
  801919:	8b 40 0c             	mov    0xc(%eax),%eax
  80191c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801921:	ba 00 00 00 00       	mov    $0x0,%edx
  801926:	b8 06 00 00 00       	mov    $0x6,%eax
  80192b:	e8 50 ff ff ff       	call   801880 <fsipc>
}
  801930:	c9                   	leave  
  801931:	c3                   	ret    

00801932 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801932:	55                   	push   %ebp
  801933:	89 e5                	mov    %esp,%ebp
  801935:	53                   	push   %ebx
  801936:	83 ec 14             	sub    $0x14,%esp
  801939:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80193c:	8b 45 08             	mov    0x8(%ebp),%eax
  80193f:	8b 40 0c             	mov    0xc(%eax),%eax
  801942:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801947:	ba 00 00 00 00       	mov    $0x0,%edx
  80194c:	b8 05 00 00 00       	mov    $0x5,%eax
  801951:	e8 2a ff ff ff       	call   801880 <fsipc>
  801956:	85 c0                	test   %eax,%eax
  801958:	78 2b                	js     801985 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80195a:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801961:	00 
  801962:	89 1c 24             	mov    %ebx,(%esp)
  801965:	e8 69 f2 ff ff       	call   800bd3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80196a:	a1 80 50 80 00       	mov    0x805080,%eax
  80196f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801975:	a1 84 50 80 00       	mov    0x805084,%eax
  80197a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801980:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801985:	83 c4 14             	add    $0x14,%esp
  801988:	5b                   	pop    %ebx
  801989:	5d                   	pop    %ebp
  80198a:	c3                   	ret    

0080198b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	83 ec 18             	sub    $0x18,%esp
  801991:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801994:	8b 55 08             	mov    0x8(%ebp),%edx
  801997:	8b 52 0c             	mov    0xc(%edx),%edx
  80199a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8019a0:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  8019a5:	89 c2                	mov    %eax,%edx
  8019a7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019ac:	76 05                	jbe    8019b3 <devfile_write+0x28>
  8019ae:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  8019b3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8019b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019be:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8019c5:	e8 ec f3 ff ff       	call   800db6 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8019ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cf:	b8 04 00 00 00       	mov    $0x4,%eax
  8019d4:	e8 a7 fe ff ff       	call   801880 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	56                   	push   %esi
  8019df:	53                   	push   %ebx
  8019e0:	83 ec 10             	sub    $0x10,%esp
  8019e3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ec:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019f1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fc:	b8 03 00 00 00       	mov    $0x3,%eax
  801a01:	e8 7a fe ff ff       	call   801880 <fsipc>
  801a06:	89 c3                	mov    %eax,%ebx
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	78 6a                	js     801a76 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a0c:	39 c6                	cmp    %eax,%esi
  801a0e:	73 24                	jae    801a34 <devfile_read+0x59>
  801a10:	c7 44 24 0c 40 2e 80 	movl   $0x802e40,0xc(%esp)
  801a17:	00 
  801a18:	c7 44 24 08 47 2e 80 	movl   $0x802e47,0x8(%esp)
  801a1f:	00 
  801a20:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a27:	00 
  801a28:	c7 04 24 5c 2e 80 00 	movl   $0x802e5c,(%esp)
  801a2f:	e8 00 0b 00 00       	call   802534 <_panic>
	assert(r <= PGSIZE);
  801a34:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a39:	7e 24                	jle    801a5f <devfile_read+0x84>
  801a3b:	c7 44 24 0c 67 2e 80 	movl   $0x802e67,0xc(%esp)
  801a42:	00 
  801a43:	c7 44 24 08 47 2e 80 	movl   $0x802e47,0x8(%esp)
  801a4a:	00 
  801a4b:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801a52:	00 
  801a53:	c7 04 24 5c 2e 80 00 	movl   $0x802e5c,(%esp)
  801a5a:	e8 d5 0a 00 00       	call   802534 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a63:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a6a:	00 
  801a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6e:	89 04 24             	mov    %eax,(%esp)
  801a71:	e8 d6 f2 ff ff       	call   800d4c <memmove>
	return r;
}
  801a76:	89 d8                	mov    %ebx,%eax
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	5b                   	pop    %ebx
  801a7c:	5e                   	pop    %esi
  801a7d:	5d                   	pop    %ebp
  801a7e:	c3                   	ret    

00801a7f <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	56                   	push   %esi
  801a83:	53                   	push   %ebx
  801a84:	83 ec 20             	sub    $0x20,%esp
  801a87:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a8a:	89 34 24             	mov    %esi,(%esp)
  801a8d:	e8 0e f1 ff ff       	call   800ba0 <strlen>
  801a92:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a97:	7f 60                	jg     801af9 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a99:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a9c:	89 04 24             	mov    %eax,(%esp)
  801a9f:	e8 17 f8 ff ff       	call   8012bb <fd_alloc>
  801aa4:	89 c3                	mov    %eax,%ebx
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	78 54                	js     801afe <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801aaa:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aae:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ab5:	e8 19 f1 ff ff       	call   800bd3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801aba:	8b 45 0c             	mov    0xc(%ebp),%eax
  801abd:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ac2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ac5:	b8 01 00 00 00       	mov    $0x1,%eax
  801aca:	e8 b1 fd ff ff       	call   801880 <fsipc>
  801acf:	89 c3                	mov    %eax,%ebx
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	79 15                	jns    801aea <open+0x6b>
		fd_close(fd, 0);
  801ad5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801adc:	00 
  801add:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae0:	89 04 24             	mov    %eax,(%esp)
  801ae3:	e8 d6 f8 ff ff       	call   8013be <fd_close>
		return r;
  801ae8:	eb 14                	jmp    801afe <open+0x7f>
	}

	return fd2num(fd);
  801aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aed:	89 04 24             	mov    %eax,(%esp)
  801af0:	e8 9b f7 ff ff       	call   801290 <fd2num>
  801af5:	89 c3                	mov    %eax,%ebx
  801af7:	eb 05                	jmp    801afe <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801af9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801afe:	89 d8                	mov    %ebx,%eax
  801b00:	83 c4 20             	add    $0x20,%esp
  801b03:	5b                   	pop    %ebx
  801b04:	5e                   	pop    %esi
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    

00801b07 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801b12:	b8 08 00 00 00       	mov    $0x8,%eax
  801b17:	e8 64 fd ff ff       	call   801880 <fsipc>
}
  801b1c:	c9                   	leave  
  801b1d:	c3                   	ret    
	...

00801b20 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801b26:	c7 44 24 04 73 2e 80 	movl   $0x802e73,0x4(%esp)
  801b2d:	00 
  801b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b31:	89 04 24             	mov    %eax,(%esp)
  801b34:	e8 9a f0 ff ff       	call   800bd3 <strcpy>
	return 0;
}
  801b39:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3e:	c9                   	leave  
  801b3f:	c3                   	ret    

00801b40 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	53                   	push   %ebx
  801b44:	83 ec 14             	sub    $0x14,%esp
  801b47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b4a:	89 1c 24             	mov    %ebx,(%esp)
  801b4d:	e8 72 0b 00 00       	call   8026c4 <pageref>
  801b52:	83 f8 01             	cmp    $0x1,%eax
  801b55:	75 0d                	jne    801b64 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801b57:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b5a:	89 04 24             	mov    %eax,(%esp)
  801b5d:	e8 1f 03 00 00       	call   801e81 <nsipc_close>
  801b62:	eb 05                	jmp    801b69 <devsock_close+0x29>
	else
		return 0;
  801b64:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b69:	83 c4 14             	add    $0x14,%esp
  801b6c:	5b                   	pop    %ebx
  801b6d:	5d                   	pop    %ebp
  801b6e:	c3                   	ret    

00801b6f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b6f:	55                   	push   %ebp
  801b70:	89 e5                	mov    %esp,%ebp
  801b72:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b75:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b7c:	00 
  801b7d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b80:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b84:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8e:	8b 40 0c             	mov    0xc(%eax),%eax
  801b91:	89 04 24             	mov    %eax,(%esp)
  801b94:	e8 e3 03 00 00       	call   801f7c <nsipc_send>
}
  801b99:	c9                   	leave  
  801b9a:	c3                   	ret    

00801b9b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ba1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ba8:	00 
  801ba9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bac:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bba:	8b 40 0c             	mov    0xc(%eax),%eax
  801bbd:	89 04 24             	mov    %eax,(%esp)
  801bc0:	e8 37 03 00 00       	call   801efc <nsipc_recv>
}
  801bc5:	c9                   	leave  
  801bc6:	c3                   	ret    

00801bc7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	56                   	push   %esi
  801bcb:	53                   	push   %ebx
  801bcc:	83 ec 20             	sub    $0x20,%esp
  801bcf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd4:	89 04 24             	mov    %eax,(%esp)
  801bd7:	e8 df f6 ff ff       	call   8012bb <fd_alloc>
  801bdc:	89 c3                	mov    %eax,%ebx
  801bde:	85 c0                	test   %eax,%eax
  801be0:	78 21                	js     801c03 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801be2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801be9:	00 
  801bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf8:	e8 c8 f3 ff ff       	call   800fc5 <sys_page_alloc>
  801bfd:	89 c3                	mov    %eax,%ebx
  801bff:	85 c0                	test   %eax,%eax
  801c01:	79 0a                	jns    801c0d <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801c03:	89 34 24             	mov    %esi,(%esp)
  801c06:	e8 76 02 00 00       	call   801e81 <nsipc_close>
		return r;
  801c0b:	eb 22                	jmp    801c2f <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c0d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c16:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c22:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c25:	89 04 24             	mov    %eax,(%esp)
  801c28:	e8 63 f6 ff ff       	call   801290 <fd2num>
  801c2d:	89 c3                	mov    %eax,%ebx
}
  801c2f:	89 d8                	mov    %ebx,%eax
  801c31:	83 c4 20             	add    $0x20,%esp
  801c34:	5b                   	pop    %ebx
  801c35:	5e                   	pop    %esi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    

00801c38 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c3e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c41:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c45:	89 04 24             	mov    %eax,(%esp)
  801c48:	e8 c1 f6 ff ff       	call   80130e <fd_lookup>
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	78 17                	js     801c68 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c54:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801c5a:	39 10                	cmp    %edx,(%eax)
  801c5c:	75 05                	jne    801c63 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c5e:	8b 40 0c             	mov    0xc(%eax),%eax
  801c61:	eb 05                	jmp    801c68 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c63:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c68:	c9                   	leave  
  801c69:	c3                   	ret    

00801c6a <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c6a:	55                   	push   %ebp
  801c6b:	89 e5                	mov    %esp,%ebp
  801c6d:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c70:	8b 45 08             	mov    0x8(%ebp),%eax
  801c73:	e8 c0 ff ff ff       	call   801c38 <fd2sockid>
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	78 1f                	js     801c9b <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c7c:	8b 55 10             	mov    0x10(%ebp),%edx
  801c7f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c83:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c86:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c8a:	89 04 24             	mov    %eax,(%esp)
  801c8d:	e8 38 01 00 00       	call   801dca <nsipc_accept>
  801c92:	85 c0                	test   %eax,%eax
  801c94:	78 05                	js     801c9b <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801c96:	e8 2c ff ff ff       	call   801bc7 <alloc_sockfd>
}
  801c9b:	c9                   	leave  
  801c9c:	c3                   	ret    

00801c9d <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca6:	e8 8d ff ff ff       	call   801c38 <fd2sockid>
  801cab:	85 c0                	test   %eax,%eax
  801cad:	78 16                	js     801cc5 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801caf:	8b 55 10             	mov    0x10(%ebp),%edx
  801cb2:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cb6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cbd:	89 04 24             	mov    %eax,(%esp)
  801cc0:	e8 5b 01 00 00       	call   801e20 <nsipc_bind>
}
  801cc5:	c9                   	leave  
  801cc6:	c3                   	ret    

00801cc7 <shutdown>:

int
shutdown(int s, int how)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
  801cca:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd0:	e8 63 ff ff ff       	call   801c38 <fd2sockid>
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	78 0f                	js     801ce8 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801cd9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cdc:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ce0:	89 04 24             	mov    %eax,(%esp)
  801ce3:	e8 77 01 00 00       	call   801e5f <nsipc_shutdown>
}
  801ce8:	c9                   	leave  
  801ce9:	c3                   	ret    

00801cea <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf3:	e8 40 ff ff ff       	call   801c38 <fd2sockid>
  801cf8:	85 c0                	test   %eax,%eax
  801cfa:	78 16                	js     801d12 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801cfc:	8b 55 10             	mov    0x10(%ebp),%edx
  801cff:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d03:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d06:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d0a:	89 04 24             	mov    %eax,(%esp)
  801d0d:	e8 89 01 00 00       	call   801e9b <nsipc_connect>
}
  801d12:	c9                   	leave  
  801d13:	c3                   	ret    

00801d14 <listen>:

int
listen(int s, int backlog)
{
  801d14:	55                   	push   %ebp
  801d15:	89 e5                	mov    %esp,%ebp
  801d17:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1d:	e8 16 ff ff ff       	call   801c38 <fd2sockid>
  801d22:	85 c0                	test   %eax,%eax
  801d24:	78 0f                	js     801d35 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d26:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d29:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d2d:	89 04 24             	mov    %eax,(%esp)
  801d30:	e8 a5 01 00 00       	call   801eda <nsipc_listen>
}
  801d35:	c9                   	leave  
  801d36:	c3                   	ret    

00801d37 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d3d:	8b 45 10             	mov    0x10(%ebp),%eax
  801d40:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4e:	89 04 24             	mov    %eax,(%esp)
  801d51:	e8 99 02 00 00       	call   801fef <nsipc_socket>
  801d56:	85 c0                	test   %eax,%eax
  801d58:	78 05                	js     801d5f <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801d5a:	e8 68 fe ff ff       	call   801bc7 <alloc_sockfd>
}
  801d5f:	c9                   	leave  
  801d60:	c3                   	ret    
  801d61:	00 00                	add    %al,(%eax)
	...

00801d64 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d64:	55                   	push   %ebp
  801d65:	89 e5                	mov    %esp,%ebp
  801d67:	53                   	push   %ebx
  801d68:	83 ec 14             	sub    $0x14,%esp
  801d6b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d6d:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801d74:	75 11                	jne    801d87 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d76:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801d7d:	e8 fd 08 00 00       	call   80267f <ipc_find_env>
  801d82:	a3 14 40 80 00       	mov    %eax,0x804014
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d87:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d8e:	00 
  801d8f:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d96:	00 
  801d97:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d9b:	a1 14 40 80 00       	mov    0x804014,%eax
  801da0:	89 04 24             	mov    %eax,(%esp)
  801da3:	e8 54 08 00 00       	call   8025fc <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801da8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801daf:	00 
  801db0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801db7:	00 
  801db8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dbf:	e8 c8 07 00 00       	call   80258c <ipc_recv>
}
  801dc4:	83 c4 14             	add    $0x14,%esp
  801dc7:	5b                   	pop    %ebx
  801dc8:	5d                   	pop    %ebp
  801dc9:	c3                   	ret    

00801dca <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	56                   	push   %esi
  801dce:	53                   	push   %ebx
  801dcf:	83 ec 10             	sub    $0x10,%esp
  801dd2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801dd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ddd:	8b 06                	mov    (%esi),%eax
  801ddf:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801de4:	b8 01 00 00 00       	mov    $0x1,%eax
  801de9:	e8 76 ff ff ff       	call   801d64 <nsipc>
  801dee:	89 c3                	mov    %eax,%ebx
  801df0:	85 c0                	test   %eax,%eax
  801df2:	78 23                	js     801e17 <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801df4:	a1 10 60 80 00       	mov    0x806010,%eax
  801df9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dfd:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e04:	00 
  801e05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e08:	89 04 24             	mov    %eax,(%esp)
  801e0b:	e8 3c ef ff ff       	call   800d4c <memmove>
		*addrlen = ret->ret_addrlen;
  801e10:	a1 10 60 80 00       	mov    0x806010,%eax
  801e15:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801e17:	89 d8                	mov    %ebx,%eax
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	5b                   	pop    %ebx
  801e1d:	5e                   	pop    %esi
  801e1e:	5d                   	pop    %ebp
  801e1f:	c3                   	ret    

00801e20 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	53                   	push   %ebx
  801e24:	83 ec 14             	sub    $0x14,%esp
  801e27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e2a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e32:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e39:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801e44:	e8 03 ef ff ff       	call   800d4c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e49:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e4f:	b8 02 00 00 00       	mov    $0x2,%eax
  801e54:	e8 0b ff ff ff       	call   801d64 <nsipc>
}
  801e59:	83 c4 14             	add    $0x14,%esp
  801e5c:	5b                   	pop    %ebx
  801e5d:	5d                   	pop    %ebp
  801e5e:	c3                   	ret    

00801e5f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e5f:	55                   	push   %ebp
  801e60:	89 e5                	mov    %esp,%ebp
  801e62:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e65:	8b 45 08             	mov    0x8(%ebp),%eax
  801e68:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e70:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e75:	b8 03 00 00 00       	mov    $0x3,%eax
  801e7a:	e8 e5 fe ff ff       	call   801d64 <nsipc>
}
  801e7f:	c9                   	leave  
  801e80:	c3                   	ret    

00801e81 <nsipc_close>:

int
nsipc_close(int s)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e87:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8a:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e8f:	b8 04 00 00 00       	mov    $0x4,%eax
  801e94:	e8 cb fe ff ff       	call   801d64 <nsipc>
}
  801e99:	c9                   	leave  
  801e9a:	c3                   	ret    

00801e9b <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	53                   	push   %ebx
  801e9f:	83 ec 14             	sub    $0x14,%esp
  801ea2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ead:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801eb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb8:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801ebf:	e8 88 ee ff ff       	call   800d4c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ec4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801eca:	b8 05 00 00 00       	mov    $0x5,%eax
  801ecf:	e8 90 fe ff ff       	call   801d64 <nsipc>
}
  801ed4:	83 c4 14             	add    $0x14,%esp
  801ed7:	5b                   	pop    %ebx
  801ed8:	5d                   	pop    %ebp
  801ed9:	c3                   	ret    

00801eda <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eeb:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801ef0:	b8 06 00 00 00       	mov    $0x6,%eax
  801ef5:	e8 6a fe ff ff       	call   801d64 <nsipc>
}
  801efa:	c9                   	leave  
  801efb:	c3                   	ret    

00801efc <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	56                   	push   %esi
  801f00:	53                   	push   %ebx
  801f01:	83 ec 10             	sub    $0x10,%esp
  801f04:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f07:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f0f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f15:	8b 45 14             	mov    0x14(%ebp),%eax
  801f18:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f1d:	b8 07 00 00 00       	mov    $0x7,%eax
  801f22:	e8 3d fe ff ff       	call   801d64 <nsipc>
  801f27:	89 c3                	mov    %eax,%ebx
  801f29:	85 c0                	test   %eax,%eax
  801f2b:	78 46                	js     801f73 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801f2d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f32:	7f 04                	jg     801f38 <nsipc_recv+0x3c>
  801f34:	39 c6                	cmp    %eax,%esi
  801f36:	7d 24                	jge    801f5c <nsipc_recv+0x60>
  801f38:	c7 44 24 0c 7f 2e 80 	movl   $0x802e7f,0xc(%esp)
  801f3f:	00 
  801f40:	c7 44 24 08 47 2e 80 	movl   $0x802e47,0x8(%esp)
  801f47:	00 
  801f48:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801f4f:	00 
  801f50:	c7 04 24 94 2e 80 00 	movl   $0x802e94,(%esp)
  801f57:	e8 d8 05 00 00       	call   802534 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f60:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f67:	00 
  801f68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6b:	89 04 24             	mov    %eax,(%esp)
  801f6e:	e8 d9 ed ff ff       	call   800d4c <memmove>
	}

	return r;
}
  801f73:	89 d8                	mov    %ebx,%eax
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	5b                   	pop    %ebx
  801f79:	5e                   	pop    %esi
  801f7a:	5d                   	pop    %ebp
  801f7b:	c3                   	ret    

00801f7c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f7c:	55                   	push   %ebp
  801f7d:	89 e5                	mov    %esp,%ebp
  801f7f:	53                   	push   %ebx
  801f80:	83 ec 14             	sub    $0x14,%esp
  801f83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f86:	8b 45 08             	mov    0x8(%ebp),%eax
  801f89:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f8e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f94:	7e 24                	jle    801fba <nsipc_send+0x3e>
  801f96:	c7 44 24 0c a0 2e 80 	movl   $0x802ea0,0xc(%esp)
  801f9d:	00 
  801f9e:	c7 44 24 08 47 2e 80 	movl   $0x802e47,0x8(%esp)
  801fa5:	00 
  801fa6:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801fad:	00 
  801fae:	c7 04 24 94 2e 80 00 	movl   $0x802e94,(%esp)
  801fb5:	e8 7a 05 00 00       	call   802534 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc5:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801fcc:	e8 7b ed ff ff       	call   800d4c <memmove>
	nsipcbuf.send.req_size = size;
  801fd1:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801fd7:	8b 45 14             	mov    0x14(%ebp),%eax
  801fda:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801fdf:	b8 08 00 00 00       	mov    $0x8,%eax
  801fe4:	e8 7b fd ff ff       	call   801d64 <nsipc>
}
  801fe9:	83 c4 14             	add    $0x14,%esp
  801fec:	5b                   	pop    %ebx
  801fed:	5d                   	pop    %ebp
  801fee:	c3                   	ret    

00801fef <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801fef:	55                   	push   %ebp
  801ff0:	89 e5                	mov    %esp,%ebp
  801ff2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ff5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ffd:	8b 45 0c             	mov    0xc(%ebp),%eax
  802000:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802005:	8b 45 10             	mov    0x10(%ebp),%eax
  802008:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80200d:	b8 09 00 00 00       	mov    $0x9,%eax
  802012:	e8 4d fd ff ff       	call   801d64 <nsipc>
}
  802017:	c9                   	leave  
  802018:	c3                   	ret    
  802019:	00 00                	add    %al,(%eax)
	...

0080201c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	56                   	push   %esi
  802020:	53                   	push   %ebx
  802021:	83 ec 10             	sub    $0x10,%esp
  802024:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802027:	8b 45 08             	mov    0x8(%ebp),%eax
  80202a:	89 04 24             	mov    %eax,(%esp)
  80202d:	e8 6e f2 ff ff       	call   8012a0 <fd2data>
  802032:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802034:	c7 44 24 04 ac 2e 80 	movl   $0x802eac,0x4(%esp)
  80203b:	00 
  80203c:	89 34 24             	mov    %esi,(%esp)
  80203f:	e8 8f eb ff ff       	call   800bd3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802044:	8b 43 04             	mov    0x4(%ebx),%eax
  802047:	2b 03                	sub    (%ebx),%eax
  802049:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80204f:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802056:	00 00 00 
	stat->st_dev = &devpipe;
  802059:	c7 86 88 00 00 00 40 	movl   $0x803040,0x88(%esi)
  802060:	30 80 00 
	return 0;
}
  802063:	b8 00 00 00 00       	mov    $0x0,%eax
  802068:	83 c4 10             	add    $0x10,%esp
  80206b:	5b                   	pop    %ebx
  80206c:	5e                   	pop    %esi
  80206d:	5d                   	pop    %ebp
  80206e:	c3                   	ret    

0080206f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80206f:	55                   	push   %ebp
  802070:	89 e5                	mov    %esp,%ebp
  802072:	53                   	push   %ebx
  802073:	83 ec 14             	sub    $0x14,%esp
  802076:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802079:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80207d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802084:	e8 e3 ef ff ff       	call   80106c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802089:	89 1c 24             	mov    %ebx,(%esp)
  80208c:	e8 0f f2 ff ff       	call   8012a0 <fd2data>
  802091:	89 44 24 04          	mov    %eax,0x4(%esp)
  802095:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80209c:	e8 cb ef ff ff       	call   80106c <sys_page_unmap>
}
  8020a1:	83 c4 14             	add    $0x14,%esp
  8020a4:	5b                   	pop    %ebx
  8020a5:	5d                   	pop    %ebp
  8020a6:	c3                   	ret    

008020a7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020a7:	55                   	push   %ebp
  8020a8:	89 e5                	mov    %esp,%ebp
  8020aa:	57                   	push   %edi
  8020ab:	56                   	push   %esi
  8020ac:	53                   	push   %ebx
  8020ad:	83 ec 2c             	sub    $0x2c,%esp
  8020b0:	89 c7                	mov    %eax,%edi
  8020b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020b5:	a1 18 40 80 00       	mov    0x804018,%eax
  8020ba:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020bd:	89 3c 24             	mov    %edi,(%esp)
  8020c0:	e8 ff 05 00 00       	call   8026c4 <pageref>
  8020c5:	89 c6                	mov    %eax,%esi
  8020c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020ca:	89 04 24             	mov    %eax,(%esp)
  8020cd:	e8 f2 05 00 00       	call   8026c4 <pageref>
  8020d2:	39 c6                	cmp    %eax,%esi
  8020d4:	0f 94 c0             	sete   %al
  8020d7:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8020da:	8b 15 18 40 80 00    	mov    0x804018,%edx
  8020e0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8020e3:	39 cb                	cmp    %ecx,%ebx
  8020e5:	75 08                	jne    8020ef <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8020e7:	83 c4 2c             	add    $0x2c,%esp
  8020ea:	5b                   	pop    %ebx
  8020eb:	5e                   	pop    %esi
  8020ec:	5f                   	pop    %edi
  8020ed:	5d                   	pop    %ebp
  8020ee:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8020ef:	83 f8 01             	cmp    $0x1,%eax
  8020f2:	75 c1                	jne    8020b5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020f4:	8b 42 58             	mov    0x58(%edx),%eax
  8020f7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8020fe:	00 
  8020ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  802103:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802107:	c7 04 24 b3 2e 80 00 	movl   $0x802eb3,(%esp)
  80210e:	e8 15 e5 ff ff       	call   800628 <cprintf>
  802113:	eb a0                	jmp    8020b5 <_pipeisclosed+0xe>

00802115 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802115:	55                   	push   %ebp
  802116:	89 e5                	mov    %esp,%ebp
  802118:	57                   	push   %edi
  802119:	56                   	push   %esi
  80211a:	53                   	push   %ebx
  80211b:	83 ec 1c             	sub    $0x1c,%esp
  80211e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802121:	89 34 24             	mov    %esi,(%esp)
  802124:	e8 77 f1 ff ff       	call   8012a0 <fd2data>
  802129:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80212b:	bf 00 00 00 00       	mov    $0x0,%edi
  802130:	eb 3c                	jmp    80216e <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802132:	89 da                	mov    %ebx,%edx
  802134:	89 f0                	mov    %esi,%eax
  802136:	e8 6c ff ff ff       	call   8020a7 <_pipeisclosed>
  80213b:	85 c0                	test   %eax,%eax
  80213d:	75 38                	jne    802177 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80213f:	e8 62 ee ff ff       	call   800fa6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802144:	8b 43 04             	mov    0x4(%ebx),%eax
  802147:	8b 13                	mov    (%ebx),%edx
  802149:	83 c2 20             	add    $0x20,%edx
  80214c:	39 d0                	cmp    %edx,%eax
  80214e:	73 e2                	jae    802132 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802150:	8b 55 0c             	mov    0xc(%ebp),%edx
  802153:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802156:	89 c2                	mov    %eax,%edx
  802158:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80215e:	79 05                	jns    802165 <devpipe_write+0x50>
  802160:	4a                   	dec    %edx
  802161:	83 ca e0             	or     $0xffffffe0,%edx
  802164:	42                   	inc    %edx
  802165:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802169:	40                   	inc    %eax
  80216a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80216d:	47                   	inc    %edi
  80216e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802171:	75 d1                	jne    802144 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802173:	89 f8                	mov    %edi,%eax
  802175:	eb 05                	jmp    80217c <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802177:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80217c:	83 c4 1c             	add    $0x1c,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5e                   	pop    %esi
  802181:	5f                   	pop    %edi
  802182:	5d                   	pop    %ebp
  802183:	c3                   	ret    

00802184 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802184:	55                   	push   %ebp
  802185:	89 e5                	mov    %esp,%ebp
  802187:	57                   	push   %edi
  802188:	56                   	push   %esi
  802189:	53                   	push   %ebx
  80218a:	83 ec 1c             	sub    $0x1c,%esp
  80218d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802190:	89 3c 24             	mov    %edi,(%esp)
  802193:	e8 08 f1 ff ff       	call   8012a0 <fd2data>
  802198:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80219a:	be 00 00 00 00       	mov    $0x0,%esi
  80219f:	eb 3a                	jmp    8021db <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021a1:	85 f6                	test   %esi,%esi
  8021a3:	74 04                	je     8021a9 <devpipe_read+0x25>
				return i;
  8021a5:	89 f0                	mov    %esi,%eax
  8021a7:	eb 40                	jmp    8021e9 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021a9:	89 da                	mov    %ebx,%edx
  8021ab:	89 f8                	mov    %edi,%eax
  8021ad:	e8 f5 fe ff ff       	call   8020a7 <_pipeisclosed>
  8021b2:	85 c0                	test   %eax,%eax
  8021b4:	75 2e                	jne    8021e4 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021b6:	e8 eb ed ff ff       	call   800fa6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021bb:	8b 03                	mov    (%ebx),%eax
  8021bd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8021c0:	74 df                	je     8021a1 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021c2:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8021c7:	79 05                	jns    8021ce <devpipe_read+0x4a>
  8021c9:	48                   	dec    %eax
  8021ca:	83 c8 e0             	or     $0xffffffe0,%eax
  8021cd:	40                   	inc    %eax
  8021ce:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8021d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021d5:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8021d8:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021da:	46                   	inc    %esi
  8021db:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021de:	75 db                	jne    8021bb <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8021e0:	89 f0                	mov    %esi,%eax
  8021e2:	eb 05                	jmp    8021e9 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021e4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8021e9:	83 c4 1c             	add    $0x1c,%esp
  8021ec:	5b                   	pop    %ebx
  8021ed:	5e                   	pop    %esi
  8021ee:	5f                   	pop    %edi
  8021ef:	5d                   	pop    %ebp
  8021f0:	c3                   	ret    

008021f1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8021f1:	55                   	push   %ebp
  8021f2:	89 e5                	mov    %esp,%ebp
  8021f4:	57                   	push   %edi
  8021f5:	56                   	push   %esi
  8021f6:	53                   	push   %ebx
  8021f7:	83 ec 3c             	sub    $0x3c,%esp
  8021fa:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8021fd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802200:	89 04 24             	mov    %eax,(%esp)
  802203:	e8 b3 f0 ff ff       	call   8012bb <fd_alloc>
  802208:	89 c3                	mov    %eax,%ebx
  80220a:	85 c0                	test   %eax,%eax
  80220c:	0f 88 45 01 00 00    	js     802357 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802212:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802219:	00 
  80221a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80221d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802221:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802228:	e8 98 ed ff ff       	call   800fc5 <sys_page_alloc>
  80222d:	89 c3                	mov    %eax,%ebx
  80222f:	85 c0                	test   %eax,%eax
  802231:	0f 88 20 01 00 00    	js     802357 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802237:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80223a:	89 04 24             	mov    %eax,(%esp)
  80223d:	e8 79 f0 ff ff       	call   8012bb <fd_alloc>
  802242:	89 c3                	mov    %eax,%ebx
  802244:	85 c0                	test   %eax,%eax
  802246:	0f 88 f8 00 00 00    	js     802344 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80224c:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802253:	00 
  802254:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802257:	89 44 24 04          	mov    %eax,0x4(%esp)
  80225b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802262:	e8 5e ed ff ff       	call   800fc5 <sys_page_alloc>
  802267:	89 c3                	mov    %eax,%ebx
  802269:	85 c0                	test   %eax,%eax
  80226b:	0f 88 d3 00 00 00    	js     802344 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802271:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802274:	89 04 24             	mov    %eax,(%esp)
  802277:	e8 24 f0 ff ff       	call   8012a0 <fd2data>
  80227c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80227e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802285:	00 
  802286:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802291:	e8 2f ed ff ff       	call   800fc5 <sys_page_alloc>
  802296:	89 c3                	mov    %eax,%ebx
  802298:	85 c0                	test   %eax,%eax
  80229a:	0f 88 91 00 00 00    	js     802331 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022a3:	89 04 24             	mov    %eax,(%esp)
  8022a6:	e8 f5 ef ff ff       	call   8012a0 <fd2data>
  8022ab:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8022b2:	00 
  8022b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022be:	00 
  8022bf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022ca:	e8 4a ed ff ff       	call   801019 <sys_page_map>
  8022cf:	89 c3                	mov    %eax,%ebx
  8022d1:	85 c0                	test   %eax,%eax
  8022d3:	78 4c                	js     802321 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8022d5:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8022db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022de:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8022e3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8022ea:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8022f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022f3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8022f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022f8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8022ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802302:	89 04 24             	mov    %eax,(%esp)
  802305:	e8 86 ef ff ff       	call   801290 <fd2num>
  80230a:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  80230c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80230f:	89 04 24             	mov    %eax,(%esp)
  802312:	e8 79 ef ff ff       	call   801290 <fd2num>
  802317:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80231a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80231f:	eb 36                	jmp    802357 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802321:	89 74 24 04          	mov    %esi,0x4(%esp)
  802325:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80232c:	e8 3b ed ff ff       	call   80106c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802331:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802334:	89 44 24 04          	mov    %eax,0x4(%esp)
  802338:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80233f:	e8 28 ed ff ff       	call   80106c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802344:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802347:	89 44 24 04          	mov    %eax,0x4(%esp)
  80234b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802352:	e8 15 ed ff ff       	call   80106c <sys_page_unmap>
    err:
	return r;
}
  802357:	89 d8                	mov    %ebx,%eax
  802359:	83 c4 3c             	add    $0x3c,%esp
  80235c:	5b                   	pop    %ebx
  80235d:	5e                   	pop    %esi
  80235e:	5f                   	pop    %edi
  80235f:	5d                   	pop    %ebp
  802360:	c3                   	ret    

00802361 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802361:	55                   	push   %ebp
  802362:	89 e5                	mov    %esp,%ebp
  802364:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80236a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80236e:	8b 45 08             	mov    0x8(%ebp),%eax
  802371:	89 04 24             	mov    %eax,(%esp)
  802374:	e8 95 ef ff ff       	call   80130e <fd_lookup>
  802379:	85 c0                	test   %eax,%eax
  80237b:	78 15                	js     802392 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80237d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802380:	89 04 24             	mov    %eax,(%esp)
  802383:	e8 18 ef ff ff       	call   8012a0 <fd2data>
	return _pipeisclosed(fd, p);
  802388:	89 c2                	mov    %eax,%edx
  80238a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80238d:	e8 15 fd ff ff       	call   8020a7 <_pipeisclosed>
}
  802392:	c9                   	leave  
  802393:	c3                   	ret    

00802394 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802394:	55                   	push   %ebp
  802395:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802397:	b8 00 00 00 00       	mov    $0x0,%eax
  80239c:	5d                   	pop    %ebp
  80239d:	c3                   	ret    

0080239e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80239e:	55                   	push   %ebp
  80239f:	89 e5                	mov    %esp,%ebp
  8023a1:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8023a4:	c7 44 24 04 cb 2e 80 	movl   $0x802ecb,0x4(%esp)
  8023ab:	00 
  8023ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023af:	89 04 24             	mov    %eax,(%esp)
  8023b2:	e8 1c e8 ff ff       	call   800bd3 <strcpy>
	return 0;
}
  8023b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8023bc:	c9                   	leave  
  8023bd:	c3                   	ret    

008023be <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023be:	55                   	push   %ebp
  8023bf:	89 e5                	mov    %esp,%ebp
  8023c1:	57                   	push   %edi
  8023c2:	56                   	push   %esi
  8023c3:	53                   	push   %ebx
  8023c4:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023ca:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023cf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023d5:	eb 30                	jmp    802407 <devcons_write+0x49>
		m = n - tot;
  8023d7:	8b 75 10             	mov    0x10(%ebp),%esi
  8023da:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8023dc:	83 fe 7f             	cmp    $0x7f,%esi
  8023df:	76 05                	jbe    8023e6 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8023e1:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8023e6:	89 74 24 08          	mov    %esi,0x8(%esp)
  8023ea:	03 45 0c             	add    0xc(%ebp),%eax
  8023ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023f1:	89 3c 24             	mov    %edi,(%esp)
  8023f4:	e8 53 e9 ff ff       	call   800d4c <memmove>
		sys_cputs(buf, m);
  8023f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023fd:	89 3c 24             	mov    %edi,(%esp)
  802400:	e8 f3 ea ff ff       	call   800ef8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802405:	01 f3                	add    %esi,%ebx
  802407:	89 d8                	mov    %ebx,%eax
  802409:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80240c:	72 c9                	jb     8023d7 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80240e:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802414:	5b                   	pop    %ebx
  802415:	5e                   	pop    %esi
  802416:	5f                   	pop    %edi
  802417:	5d                   	pop    %ebp
  802418:	c3                   	ret    

00802419 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802419:	55                   	push   %ebp
  80241a:	89 e5                	mov    %esp,%ebp
  80241c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80241f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802423:	75 07                	jne    80242c <devcons_read+0x13>
  802425:	eb 25                	jmp    80244c <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802427:	e8 7a eb ff ff       	call   800fa6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80242c:	e8 e5 ea ff ff       	call   800f16 <sys_cgetc>
  802431:	85 c0                	test   %eax,%eax
  802433:	74 f2                	je     802427 <devcons_read+0xe>
  802435:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802437:	85 c0                	test   %eax,%eax
  802439:	78 1d                	js     802458 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80243b:	83 f8 04             	cmp    $0x4,%eax
  80243e:	74 13                	je     802453 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802440:	8b 45 0c             	mov    0xc(%ebp),%eax
  802443:	88 10                	mov    %dl,(%eax)
	return 1;
  802445:	b8 01 00 00 00       	mov    $0x1,%eax
  80244a:	eb 0c                	jmp    802458 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  80244c:	b8 00 00 00 00       	mov    $0x0,%eax
  802451:	eb 05                	jmp    802458 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802453:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802458:	c9                   	leave  
  802459:	c3                   	ret    

0080245a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80245a:	55                   	push   %ebp
  80245b:	89 e5                	mov    %esp,%ebp
  80245d:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802460:	8b 45 08             	mov    0x8(%ebp),%eax
  802463:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802466:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80246d:	00 
  80246e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802471:	89 04 24             	mov    %eax,(%esp)
  802474:	e8 7f ea ff ff       	call   800ef8 <sys_cputs>
}
  802479:	c9                   	leave  
  80247a:	c3                   	ret    

0080247b <getchar>:

int
getchar(void)
{
  80247b:	55                   	push   %ebp
  80247c:	89 e5                	mov    %esp,%ebp
  80247e:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802481:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802488:	00 
  802489:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80248c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802490:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802497:	e8 10 f1 ff ff       	call   8015ac <read>
	if (r < 0)
  80249c:	85 c0                	test   %eax,%eax
  80249e:	78 0f                	js     8024af <getchar+0x34>
		return r;
	if (r < 1)
  8024a0:	85 c0                	test   %eax,%eax
  8024a2:	7e 06                	jle    8024aa <getchar+0x2f>
		return -E_EOF;
	return c;
  8024a4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8024a8:	eb 05                	jmp    8024af <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8024aa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8024af:	c9                   	leave  
  8024b0:	c3                   	ret    

008024b1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8024b1:	55                   	push   %ebp
  8024b2:	89 e5                	mov    %esp,%ebp
  8024b4:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024be:	8b 45 08             	mov    0x8(%ebp),%eax
  8024c1:	89 04 24             	mov    %eax,(%esp)
  8024c4:	e8 45 ee ff ff       	call   80130e <fd_lookup>
  8024c9:	85 c0                	test   %eax,%eax
  8024cb:	78 11                	js     8024de <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8024cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024d0:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8024d6:	39 10                	cmp    %edx,(%eax)
  8024d8:	0f 94 c0             	sete   %al
  8024db:	0f b6 c0             	movzbl %al,%eax
}
  8024de:	c9                   	leave  
  8024df:	c3                   	ret    

008024e0 <opencons>:

int
opencons(void)
{
  8024e0:	55                   	push   %ebp
  8024e1:	89 e5                	mov    %esp,%ebp
  8024e3:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024e9:	89 04 24             	mov    %eax,(%esp)
  8024ec:	e8 ca ed ff ff       	call   8012bb <fd_alloc>
  8024f1:	85 c0                	test   %eax,%eax
  8024f3:	78 3c                	js     802531 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024f5:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8024fc:	00 
  8024fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802500:	89 44 24 04          	mov    %eax,0x4(%esp)
  802504:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80250b:	e8 b5 ea ff ff       	call   800fc5 <sys_page_alloc>
  802510:	85 c0                	test   %eax,%eax
  802512:	78 1d                	js     802531 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802514:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80251a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80251d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80251f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802522:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802529:	89 04 24             	mov    %eax,(%esp)
  80252c:	e8 5f ed ff ff       	call   801290 <fd2num>
}
  802531:	c9                   	leave  
  802532:	c3                   	ret    
	...

00802534 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802534:	55                   	push   %ebp
  802535:	89 e5                	mov    %esp,%ebp
  802537:	56                   	push   %esi
  802538:	53                   	push   %ebx
  802539:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80253c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80253f:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  802545:	e8 3d ea ff ff       	call   800f87 <sys_getenvid>
  80254a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80254d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802551:	8b 55 08             	mov    0x8(%ebp),%edx
  802554:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802558:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80255c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802560:	c7 04 24 d8 2e 80 00 	movl   $0x802ed8,(%esp)
  802567:	e8 bc e0 ff ff       	call   800628 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80256c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802570:	8b 45 10             	mov    0x10(%ebp),%eax
  802573:	89 04 24             	mov    %eax,(%esp)
  802576:	e8 4c e0 ff ff       	call   8005c7 <vcprintf>
	cprintf("\n");
  80257b:	c7 04 24 14 2a 80 00 	movl   $0x802a14,(%esp)
  802582:	e8 a1 e0 ff ff       	call   800628 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802587:	cc                   	int3   
  802588:	eb fd                	jmp    802587 <_panic+0x53>
	...

0080258c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80258c:	55                   	push   %ebp
  80258d:	89 e5                	mov    %esp,%ebp
  80258f:	56                   	push   %esi
  802590:	53                   	push   %ebx
  802591:	83 ec 10             	sub    $0x10,%esp
  802594:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802597:	8b 45 0c             	mov    0xc(%ebp),%eax
  80259a:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  80259d:	85 c0                	test   %eax,%eax
  80259f:	74 0a                	je     8025ab <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8025a1:	89 04 24             	mov    %eax,(%esp)
  8025a4:	e8 32 ec ff ff       	call   8011db <sys_ipc_recv>
  8025a9:	eb 0c                	jmp    8025b7 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8025ab:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8025b2:	e8 24 ec ff ff       	call   8011db <sys_ipc_recv>
	}
	if (r < 0)
  8025b7:	85 c0                	test   %eax,%eax
  8025b9:	79 16                	jns    8025d1 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8025bb:	85 db                	test   %ebx,%ebx
  8025bd:	74 06                	je     8025c5 <ipc_recv+0x39>
  8025bf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8025c5:	85 f6                	test   %esi,%esi
  8025c7:	74 2c                	je     8025f5 <ipc_recv+0x69>
  8025c9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8025cf:	eb 24                	jmp    8025f5 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8025d1:	85 db                	test   %ebx,%ebx
  8025d3:	74 0a                	je     8025df <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  8025d5:	a1 18 40 80 00       	mov    0x804018,%eax
  8025da:	8b 40 74             	mov    0x74(%eax),%eax
  8025dd:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  8025df:	85 f6                	test   %esi,%esi
  8025e1:	74 0a                	je     8025ed <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  8025e3:	a1 18 40 80 00       	mov    0x804018,%eax
  8025e8:	8b 40 78             	mov    0x78(%eax),%eax
  8025eb:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8025ed:	a1 18 40 80 00       	mov    0x804018,%eax
  8025f2:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8025f5:	83 c4 10             	add    $0x10,%esp
  8025f8:	5b                   	pop    %ebx
  8025f9:	5e                   	pop    %esi
  8025fa:	5d                   	pop    %ebp
  8025fb:	c3                   	ret    

008025fc <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025fc:	55                   	push   %ebp
  8025fd:	89 e5                	mov    %esp,%ebp
  8025ff:	57                   	push   %edi
  802600:	56                   	push   %esi
  802601:	53                   	push   %ebx
  802602:	83 ec 1c             	sub    $0x1c,%esp
  802605:	8b 75 08             	mov    0x8(%ebp),%esi
  802608:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80260b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  80260e:	85 db                	test   %ebx,%ebx
  802610:	74 19                	je     80262b <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802612:	8b 45 14             	mov    0x14(%ebp),%eax
  802615:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802619:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80261d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802621:	89 34 24             	mov    %esi,(%esp)
  802624:	e8 8f eb ff ff       	call   8011b8 <sys_ipc_try_send>
  802629:	eb 1c                	jmp    802647 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80262b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802632:	00 
  802633:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80263a:	ee 
  80263b:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80263f:	89 34 24             	mov    %esi,(%esp)
  802642:	e8 71 eb ff ff       	call   8011b8 <sys_ipc_try_send>
		}
		if (r == 0)
  802647:	85 c0                	test   %eax,%eax
  802649:	74 2c                	je     802677 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80264b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80264e:	74 20                	je     802670 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802650:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802654:	c7 44 24 08 fc 2e 80 	movl   $0x802efc,0x8(%esp)
  80265b:	00 
  80265c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802663:	00 
  802664:	c7 04 24 0f 2f 80 00 	movl   $0x802f0f,(%esp)
  80266b:	e8 c4 fe ff ff       	call   802534 <_panic>
		}
		sys_yield();
  802670:	e8 31 e9 ff ff       	call   800fa6 <sys_yield>
	}
  802675:	eb 97                	jmp    80260e <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802677:	83 c4 1c             	add    $0x1c,%esp
  80267a:	5b                   	pop    %ebx
  80267b:	5e                   	pop    %esi
  80267c:	5f                   	pop    %edi
  80267d:	5d                   	pop    %ebp
  80267e:	c3                   	ret    

0080267f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80267f:	55                   	push   %ebp
  802680:	89 e5                	mov    %esp,%ebp
  802682:	53                   	push   %ebx
  802683:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802686:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80268b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802692:	89 c2                	mov    %eax,%edx
  802694:	c1 e2 07             	shl    $0x7,%edx
  802697:	29 ca                	sub    %ecx,%edx
  802699:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80269f:	8b 52 50             	mov    0x50(%edx),%edx
  8026a2:	39 da                	cmp    %ebx,%edx
  8026a4:	75 0f                	jne    8026b5 <ipc_find_env+0x36>
			return envs[i].env_id;
  8026a6:	c1 e0 07             	shl    $0x7,%eax
  8026a9:	29 c8                	sub    %ecx,%eax
  8026ab:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8026b0:	8b 40 40             	mov    0x40(%eax),%eax
  8026b3:	eb 0c                	jmp    8026c1 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026b5:	40                   	inc    %eax
  8026b6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026bb:	75 ce                	jne    80268b <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026bd:	66 b8 00 00          	mov    $0x0,%ax
}
  8026c1:	5b                   	pop    %ebx
  8026c2:	5d                   	pop    %ebp
  8026c3:	c3                   	ret    

008026c4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026c4:	55                   	push   %ebp
  8026c5:	89 e5                	mov    %esp,%ebp
  8026c7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026ca:	89 c2                	mov    %eax,%edx
  8026cc:	c1 ea 16             	shr    $0x16,%edx
  8026cf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8026d6:	f6 c2 01             	test   $0x1,%dl
  8026d9:	74 1e                	je     8026f9 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026db:	c1 e8 0c             	shr    $0xc,%eax
  8026de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8026e5:	a8 01                	test   $0x1,%al
  8026e7:	74 17                	je     802700 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8026e9:	c1 e8 0c             	shr    $0xc,%eax
  8026ec:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8026f3:	ef 
  8026f4:	0f b7 c0             	movzwl %ax,%eax
  8026f7:	eb 0c                	jmp    802705 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8026f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8026fe:	eb 05                	jmp    802705 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802700:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802705:	5d                   	pop    %ebp
  802706:	c3                   	ret    
	...

00802708 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802708:	55                   	push   %ebp
  802709:	57                   	push   %edi
  80270a:	56                   	push   %esi
  80270b:	83 ec 10             	sub    $0x10,%esp
  80270e:	8b 74 24 20          	mov    0x20(%esp),%esi
  802712:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802716:	89 74 24 04          	mov    %esi,0x4(%esp)
  80271a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  80271e:	89 cd                	mov    %ecx,%ebp
  802720:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802724:	85 c0                	test   %eax,%eax
  802726:	75 2c                	jne    802754 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802728:	39 f9                	cmp    %edi,%ecx
  80272a:	77 68                	ja     802794 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  80272c:	85 c9                	test   %ecx,%ecx
  80272e:	75 0b                	jne    80273b <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802730:	b8 01 00 00 00       	mov    $0x1,%eax
  802735:	31 d2                	xor    %edx,%edx
  802737:	f7 f1                	div    %ecx
  802739:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80273b:	31 d2                	xor    %edx,%edx
  80273d:	89 f8                	mov    %edi,%eax
  80273f:	f7 f1                	div    %ecx
  802741:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802743:	89 f0                	mov    %esi,%eax
  802745:	f7 f1                	div    %ecx
  802747:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802749:	89 f0                	mov    %esi,%eax
  80274b:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80274d:	83 c4 10             	add    $0x10,%esp
  802750:	5e                   	pop    %esi
  802751:	5f                   	pop    %edi
  802752:	5d                   	pop    %ebp
  802753:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802754:	39 f8                	cmp    %edi,%eax
  802756:	77 2c                	ja     802784 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802758:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80275b:	83 f6 1f             	xor    $0x1f,%esi
  80275e:	75 4c                	jne    8027ac <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802760:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802762:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802767:	72 0a                	jb     802773 <__udivdi3+0x6b>
  802769:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80276d:	0f 87 ad 00 00 00    	ja     802820 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802773:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802778:	89 f0                	mov    %esi,%eax
  80277a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80277c:	83 c4 10             	add    $0x10,%esp
  80277f:	5e                   	pop    %esi
  802780:	5f                   	pop    %edi
  802781:	5d                   	pop    %ebp
  802782:	c3                   	ret    
  802783:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802784:	31 ff                	xor    %edi,%edi
  802786:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802788:	89 f0                	mov    %esi,%eax
  80278a:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  80278c:	83 c4 10             	add    $0x10,%esp
  80278f:	5e                   	pop    %esi
  802790:	5f                   	pop    %edi
  802791:	5d                   	pop    %ebp
  802792:	c3                   	ret    
  802793:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802794:	89 fa                	mov    %edi,%edx
  802796:	89 f0                	mov    %esi,%eax
  802798:	f7 f1                	div    %ecx
  80279a:	89 c6                	mov    %eax,%esi
  80279c:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80279e:	89 f0                	mov    %esi,%eax
  8027a0:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027a2:	83 c4 10             	add    $0x10,%esp
  8027a5:	5e                   	pop    %esi
  8027a6:	5f                   	pop    %edi
  8027a7:	5d                   	pop    %ebp
  8027a8:	c3                   	ret    
  8027a9:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8027ac:	89 f1                	mov    %esi,%ecx
  8027ae:	d3 e0                	shl    %cl,%eax
  8027b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8027b4:	b8 20 00 00 00       	mov    $0x20,%eax
  8027b9:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8027bb:	89 ea                	mov    %ebp,%edx
  8027bd:	88 c1                	mov    %al,%cl
  8027bf:	d3 ea                	shr    %cl,%edx
  8027c1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8027c5:	09 ca                	or     %ecx,%edx
  8027c7:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8027cb:	89 f1                	mov    %esi,%ecx
  8027cd:	d3 e5                	shl    %cl,%ebp
  8027cf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8027d3:	89 fd                	mov    %edi,%ebp
  8027d5:	88 c1                	mov    %al,%cl
  8027d7:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8027d9:	89 fa                	mov    %edi,%edx
  8027db:	89 f1                	mov    %esi,%ecx
  8027dd:	d3 e2                	shl    %cl,%edx
  8027df:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8027e3:	88 c1                	mov    %al,%cl
  8027e5:	d3 ef                	shr    %cl,%edi
  8027e7:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8027e9:	89 f8                	mov    %edi,%eax
  8027eb:	89 ea                	mov    %ebp,%edx
  8027ed:	f7 74 24 08          	divl   0x8(%esp)
  8027f1:	89 d1                	mov    %edx,%ecx
  8027f3:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  8027f5:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8027f9:	39 d1                	cmp    %edx,%ecx
  8027fb:	72 17                	jb     802814 <__udivdi3+0x10c>
  8027fd:	74 09                	je     802808 <__udivdi3+0x100>
  8027ff:	89 fe                	mov    %edi,%esi
  802801:	31 ff                	xor    %edi,%edi
  802803:	e9 41 ff ff ff       	jmp    802749 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802808:	8b 54 24 04          	mov    0x4(%esp),%edx
  80280c:	89 f1                	mov    %esi,%ecx
  80280e:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802810:	39 c2                	cmp    %eax,%edx
  802812:	73 eb                	jae    8027ff <__udivdi3+0xf7>
		{
		  q0--;
  802814:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802817:	31 ff                	xor    %edi,%edi
  802819:	e9 2b ff ff ff       	jmp    802749 <__udivdi3+0x41>
  80281e:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802820:	31 f6                	xor    %esi,%esi
  802822:	e9 22 ff ff ff       	jmp    802749 <__udivdi3+0x41>
	...

00802828 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802828:	55                   	push   %ebp
  802829:	57                   	push   %edi
  80282a:	56                   	push   %esi
  80282b:	83 ec 20             	sub    $0x20,%esp
  80282e:	8b 44 24 30          	mov    0x30(%esp),%eax
  802832:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802836:	89 44 24 14          	mov    %eax,0x14(%esp)
  80283a:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  80283e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802842:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802846:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802848:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80284a:	85 ed                	test   %ebp,%ebp
  80284c:	75 16                	jne    802864 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  80284e:	39 f1                	cmp    %esi,%ecx
  802850:	0f 86 a6 00 00 00    	jbe    8028fc <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802856:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802858:	89 d0                	mov    %edx,%eax
  80285a:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80285c:	83 c4 20             	add    $0x20,%esp
  80285f:	5e                   	pop    %esi
  802860:	5f                   	pop    %edi
  802861:	5d                   	pop    %ebp
  802862:	c3                   	ret    
  802863:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802864:	39 f5                	cmp    %esi,%ebp
  802866:	0f 87 ac 00 00 00    	ja     802918 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80286c:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  80286f:	83 f0 1f             	xor    $0x1f,%eax
  802872:	89 44 24 10          	mov    %eax,0x10(%esp)
  802876:	0f 84 a8 00 00 00    	je     802924 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  80287c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802880:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802882:	bf 20 00 00 00       	mov    $0x20,%edi
  802887:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  80288b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80288f:	89 f9                	mov    %edi,%ecx
  802891:	d3 e8                	shr    %cl,%eax
  802893:	09 e8                	or     %ebp,%eax
  802895:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802899:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80289d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028a1:	d3 e0                	shl    %cl,%eax
  8028a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8028a7:	89 f2                	mov    %esi,%edx
  8028a9:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8028ab:	8b 44 24 14          	mov    0x14(%esp),%eax
  8028af:	d3 e0                	shl    %cl,%eax
  8028b1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8028b5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8028b9:	89 f9                	mov    %edi,%ecx
  8028bb:	d3 e8                	shr    %cl,%eax
  8028bd:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8028bf:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8028c1:	89 f2                	mov    %esi,%edx
  8028c3:	f7 74 24 18          	divl   0x18(%esp)
  8028c7:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8028c9:	f7 64 24 0c          	mull   0xc(%esp)
  8028cd:	89 c5                	mov    %eax,%ebp
  8028cf:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028d1:	39 d6                	cmp    %edx,%esi
  8028d3:	72 67                	jb     80293c <__umoddi3+0x114>
  8028d5:	74 75                	je     80294c <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8028d7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8028db:	29 e8                	sub    %ebp,%eax
  8028dd:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  8028df:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028e3:	d3 e8                	shr    %cl,%eax
  8028e5:	89 f2                	mov    %esi,%edx
  8028e7:	89 f9                	mov    %edi,%ecx
  8028e9:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  8028eb:	09 d0                	or     %edx,%eax
  8028ed:	89 f2                	mov    %esi,%edx
  8028ef:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028f3:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  8028f5:	83 c4 20             	add    $0x20,%esp
  8028f8:	5e                   	pop    %esi
  8028f9:	5f                   	pop    %edi
  8028fa:	5d                   	pop    %ebp
  8028fb:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  8028fc:	85 c9                	test   %ecx,%ecx
  8028fe:	75 0b                	jne    80290b <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802900:	b8 01 00 00 00       	mov    $0x1,%eax
  802905:	31 d2                	xor    %edx,%edx
  802907:	f7 f1                	div    %ecx
  802909:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80290b:	89 f0                	mov    %esi,%eax
  80290d:	31 d2                	xor    %edx,%edx
  80290f:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802911:	89 f8                	mov    %edi,%eax
  802913:	e9 3e ff ff ff       	jmp    802856 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802918:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80291a:	83 c4 20             	add    $0x20,%esp
  80291d:	5e                   	pop    %esi
  80291e:	5f                   	pop    %edi
  80291f:	5d                   	pop    %ebp
  802920:	c3                   	ret    
  802921:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802924:	39 f5                	cmp    %esi,%ebp
  802926:	72 04                	jb     80292c <__umoddi3+0x104>
  802928:	39 f9                	cmp    %edi,%ecx
  80292a:	77 06                	ja     802932 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  80292c:	89 f2                	mov    %esi,%edx
  80292e:	29 cf                	sub    %ecx,%edi
  802930:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802932:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802934:	83 c4 20             	add    $0x20,%esp
  802937:	5e                   	pop    %esi
  802938:	5f                   	pop    %edi
  802939:	5d                   	pop    %ebp
  80293a:	c3                   	ret    
  80293b:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80293c:	89 d1                	mov    %edx,%ecx
  80293e:	89 c5                	mov    %eax,%ebp
  802940:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802944:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802948:	eb 8d                	jmp    8028d7 <__umoddi3+0xaf>
  80294a:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80294c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802950:	72 ea                	jb     80293c <__umoddi3+0x114>
  802952:	89 f1                	mov    %esi,%ecx
  802954:	eb 81                	jmp    8028d7 <__umoddi3+0xaf>
