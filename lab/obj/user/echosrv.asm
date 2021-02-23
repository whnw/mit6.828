
obj/user/echosrv.debug:     file format elf32-i386


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
  80002c:	e8 0b 05 00 00       	call   80053c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <die>:
#define BUFFSIZE 32
#define MAXPENDING 5    // Max connection requests

static void
die(char *m)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("%s\n", m);
  80003a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003e:	c7 04 24 d0 29 80 00 	movl   $0x8029d0,(%esp)
  800045:	e8 02 06 00 00       	call   80064c <cprintf>
	exit();
  80004a:	e8 41 05 00 00       	call   800590 <exit>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <handle_client>:

void
handle_client(int sock)
{
  800051:	55                   	push   %ebp
  800052:	89 e5                	mov    %esp,%ebp
  800054:	57                   	push   %edi
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	83 ec 3c             	sub    $0x3c,%esp
  80005a:	8b 75 08             	mov    0x8(%ebp),%esi
	char buffer[BUFFSIZE];
	int received = -1;
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80005d:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
  800064:	00 
  800065:	8d 45 c8             	lea    -0x38(%ebp),%eax
  800068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006c:	89 34 24             	mov    %esi,(%esp)
  80006f:	e8 5c 15 00 00       	call   8015d0 <read>
  800074:	89 c3                	mov    %eax,%ebx
  800076:	85 c0                	test   %eax,%eax
  800078:	79 50                	jns    8000ca <handle_client+0x79>
		die("Failed to receive initial bytes from client");
  80007a:	b8 d4 29 80 00       	mov    $0x8029d4,%eax
  80007f:	e8 b0 ff ff ff       	call   800034 <die>
  800084:	eb 44                	jmp    8000ca <handle_client+0x79>

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
		// Send back received data
		if (write(sock, buffer, received) != received)
  800086:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80008a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80008e:	89 34 24             	mov    %esi,(%esp)
  800091:	e8 15 16 00 00       	call   8016ab <write>
  800096:	39 d8                	cmp    %ebx,%eax
  800098:	74 0a                	je     8000a4 <handle_client+0x53>
			die("Failed to send bytes to client");
  80009a:	b8 00 2a 80 00       	mov    $0x802a00,%eax
  80009f:	e8 90 ff ff ff       	call   800034 <die>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  8000a4:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
  8000ab:	00 
  8000ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8000b0:	89 34 24             	mov    %esi,(%esp)
  8000b3:	e8 18 15 00 00       	call   8015d0 <read>
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	85 c0                	test   %eax,%eax
  8000bc:	79 0f                	jns    8000cd <handle_client+0x7c>
			die("Failed to receive additional bytes from client");
  8000be:	b8 20 2a 80 00       	mov    $0x802a20,%eax
  8000c3:	e8 6c ff ff ff       	call   800034 <die>
  8000c8:	eb 03                	jmp    8000cd <handle_client+0x7c>
		die("Failed to receive initial bytes from client");

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
		// Send back received data
		if (write(sock, buffer, received) != received)
  8000ca:	8d 7d c8             	lea    -0x38(%ebp),%edi
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
		die("Failed to receive initial bytes from client");

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
  8000cd:	85 db                	test   %ebx,%ebx
  8000cf:	7f b5                	jg     800086 <handle_client+0x35>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
			die("Failed to receive additional bytes from client");
	}
	close(sock);
  8000d1:	89 34 24             	mov    %esi,(%esp)
  8000d4:	e8 91 13 00 00       	call   80146a <close>
}
  8000d9:	83 c4 3c             	add    $0x3c,%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <umain>:

void
umain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 4c             	sub    $0x4c,%esp
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8000ea:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  8000f1:	00 
  8000f2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8000f9:	00 
  8000fa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800101:	e8 55 1c 00 00       	call   801d5b <socket>
  800106:	89 c6                	mov    %eax,%esi
  800108:	85 c0                	test   %eax,%eax
  80010a:	79 0a                	jns    800116 <umain+0x35>
		die("Failed to create socket");
  80010c:	b8 80 29 80 00       	mov    $0x802980,%eax
  800111:	e8 1e ff ff ff       	call   800034 <die>

	cprintf("opened socket\n");
  800116:	c7 04 24 98 29 80 00 	movl   $0x802998,(%esp)
  80011d:	e8 2a 05 00 00       	call   80064c <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  800122:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800129:	00 
  80012a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800131:	00 
  800132:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800135:	89 1c 24             	mov    %ebx,(%esp)
  800138:	e8 e9 0b 00 00       	call   800d26 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  80013d:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = htonl(INADDR_ANY);   // IP address
  800141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800148:	e8 84 01 00 00       	call   8002d1 <htonl>
  80014d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  800150:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800157:	e8 55 01 00 00       	call   8002b1 <htons>
  80015c:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to bind\n");
  800160:	c7 04 24 a7 29 80 00 	movl   $0x8029a7,(%esp)
  800167:	e8 e0 04 00 00       	call   80064c <cprintf>

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &echoserver,
  80016c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800173:	00 
  800174:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800178:	89 34 24             	mov    %esi,(%esp)
  80017b:	e8 41 1b 00 00       	call   801cc1 <bind>
  800180:	85 c0                	test   %eax,%eax
  800182:	79 0a                	jns    80018e <umain+0xad>
		 sizeof(echoserver)) < 0) {
		die("Failed to bind the server socket");
  800184:	b8 50 2a 80 00       	mov    $0x802a50,%eax
  800189:	e8 a6 fe ff ff       	call   800034 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  80018e:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  800195:	00 
  800196:	89 34 24             	mov    %esi,(%esp)
  800199:	e8 9a 1b 00 00       	call   801d38 <listen>
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 0a                	jns    8001ac <umain+0xcb>
		die("Failed to listen on server socket");
  8001a2:	b8 74 2a 80 00       	mov    $0x802a74,%eax
  8001a7:	e8 88 fe ff ff       	call   800034 <die>

	cprintf("bound\n");
  8001ac:	c7 04 24 b7 29 80 00 	movl   $0x8029b7,(%esp)
  8001b3:	e8 94 04 00 00       	call   80064c <cprintf>
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
		     accept(serversock, (struct sockaddr *) &echoclient,
			    &clientlen)) < 0) {
  8001b8:	8d 7d c4             	lea    -0x3c(%ebp),%edi

	cprintf("bound\n");

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
  8001bb:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock =
		     accept(serversock, (struct sockaddr *) &echoclient,
			    &clientlen)) < 0) {
  8001c2:	89 7c 24 08          	mov    %edi,0x8(%esp)
	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
		     accept(serversock, (struct sockaddr *) &echoclient,
  8001c6:	8d 45 c8             	lea    -0x38(%ebp),%eax
  8001c9:	89 44 24 04          	mov    %eax,0x4(%esp)

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
  8001cd:	89 34 24             	mov    %esi,(%esp)
  8001d0:	e8 b9 1a 00 00       	call   801c8e <accept>
  8001d5:	89 c3                	mov    %eax,%ebx
  8001d7:	85 c0                	test   %eax,%eax
  8001d9:	79 0a                	jns    8001e5 <umain+0x104>
		     accept(serversock, (struct sockaddr *) &echoclient,
			    &clientlen)) < 0) {
			die("Failed to accept client connection");
  8001db:	b8 98 2a 80 00       	mov    $0x802a98,%eax
  8001e0:	e8 4f fe ff ff       	call   800034 <die>
		}
		cprintf("Client connected: %s\n", inet_ntoa(echoclient.sin_addr));
  8001e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 1c 00 00 00       	call   80020c <inet_ntoa>
  8001f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f4:	c7 04 24 be 29 80 00 	movl   $0x8029be,(%esp)
  8001fb:	e8 4c 04 00 00       	call   80064c <cprintf>
		handle_client(clientsock);
  800200:	89 1c 24             	mov    %ebx,(%esp)
  800203:	e8 49 fe ff ff       	call   800051 <handle_client>
	}
  800208:	eb b1                	jmp    8001bb <umain+0xda>
	...

0080020c <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 1c             	sub    $0x1c,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800215:	8b 45 08             	mov    0x8(%ebp),%eax
  800218:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  80021b:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  80021f:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  800222:	c7 45 dc 00 40 80 00 	movl   $0x804000,-0x24(%ebp)
 */
char *
inet_ntoa(struct in_addr addr)
{
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800229:	b2 00                	mov    $0x0,%dl
  80022b:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  80022e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800231:	8a 00                	mov    (%eax),%al
  800233:	88 45 e2             	mov    %al,-0x1e(%ebp)
      *ap /= (u8_t)10;
  800236:	0f b6 c0             	movzbl %al,%eax
  800239:	8d 34 80             	lea    (%eax,%eax,4),%esi
  80023c:	8d 04 f0             	lea    (%eax,%esi,8),%eax
  80023f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800242:	66 c1 e8 0b          	shr    $0xb,%ax
  800246:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800249:	88 01                	mov    %al,(%ecx)
      inv[i++] = '0' + rem;
  80024b:	0f b6 f2             	movzbl %dl,%esi
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  80024e:	8d 3c 80             	lea    (%eax,%eax,4),%edi
  800251:	d1 e7                	shl    %edi
  800253:	8a 5d e2             	mov    -0x1e(%ebp),%bl
  800256:	89 f9                	mov    %edi,%ecx
  800258:	28 cb                	sub    %cl,%bl
  80025a:	89 df                	mov    %ebx,%edi
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
  80025c:	8d 4f 30             	lea    0x30(%edi),%ecx
  80025f:	88 4c 35 ed          	mov    %cl,-0x13(%ebp,%esi,1)
  800263:	42                   	inc    %edx
    } while(*ap);
  800264:	84 c0                	test   %al,%al
  800266:	75 c6                	jne    80022e <inet_ntoa+0x22>
  800268:	88 d0                	mov    %dl,%al
  80026a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80026d:	8b 7d d8             	mov    -0x28(%ebp),%edi
  800270:	eb 0b                	jmp    80027d <inet_ntoa+0x71>
    while(i--)
  800272:	48                   	dec    %eax
      *rp++ = inv[i];
  800273:	0f b6 f0             	movzbl %al,%esi
  800276:	8a 5c 35 ed          	mov    -0x13(%ebp,%esi,1),%bl
  80027a:	88 19                	mov    %bl,(%ecx)
  80027c:	41                   	inc    %ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  80027d:	84 c0                	test   %al,%al
  80027f:	75 f1                	jne    800272 <inet_ntoa+0x66>
  800281:	89 7d d8             	mov    %edi,-0x28(%ebp)
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  800284:	0f b6 d2             	movzbl %dl,%edx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  800287:	03 55 dc             	add    -0x24(%ebp),%edx
      *rp++ = inv[i];
    *rp++ = '.';
  80028a:	c6 02 2e             	movb   $0x2e,(%edx)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  80028d:	fe 45 e3             	incb   -0x1d(%ebp)
  800290:	80 7d e3 03          	cmpb   $0x3,-0x1d(%ebp)
  800294:	77 0b                	ja     8002a1 <inet_ntoa+0x95>
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
  800296:	42                   	inc    %edx
  800297:	89 55 dc             	mov    %edx,-0x24(%ebp)
    ap++;
  80029a:	ff 45 d8             	incl   -0x28(%ebp)
  80029d:	88 c2                	mov    %al,%dl
  80029f:	eb 8d                	jmp    80022e <inet_ntoa+0x22>
  }
  *--rp = 0;
  8002a1:	c6 02 00             	movb   $0x0,(%edx)
  return str;
}
  8002a4:	b8 00 40 80 00       	mov    $0x804000,%eax
  8002a9:	83 c4 1c             	add    $0x1c,%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8002b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b7:	66 c1 c0 08          	rol    $0x8,%ax
}
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  8002c3:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8002c7:	89 04 24             	mov    %eax,(%esp)
  8002ca:	e8 e2 ff ff ff       	call   8002b1 <htons>
}
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  8002d7:	89 d1                	mov    %edx,%ecx
  8002d9:	c1 e9 18             	shr    $0x18,%ecx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  8002dc:	89 d0                	mov    %edx,%eax
  8002de:	c1 e0 18             	shl    $0x18,%eax
  8002e1:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  8002e3:	89 d1                	mov    %edx,%ecx
  8002e5:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  8002eb:	c1 e1 08             	shl    $0x8,%ecx
  8002ee:	09 c8                	or     %ecx,%eax
    ((n & 0xff0000UL) >> 8) |
  8002f0:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8002f6:	c1 ea 08             	shr    $0x8,%edx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  8002f9:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
  800303:	83 ec 24             	sub    $0x24,%esp
  800306:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800309:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  80030c:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80030f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  800312:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  800315:	89 5d e0             	mov    %ebx,-0x20(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  800318:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80031b:	80 f9 09             	cmp    $0x9,%cl
  80031e:	0f 87 8f 01 00 00    	ja     8004b3 <inet_aton+0x1b6>
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  800324:	83 fa 30             	cmp    $0x30,%edx
  800327:	75 28                	jne    800351 <inet_aton+0x54>
      c = *++cp;
  800329:	0f be 50 01          	movsbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  80032d:	83 fa 78             	cmp    $0x78,%edx
  800330:	74 0f                	je     800341 <inet_aton+0x44>
  800332:	83 fa 58             	cmp    $0x58,%edx
  800335:	74 0a                	je     800341 <inet_aton+0x44>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  800337:	40                   	inc    %eax
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  800338:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  80033f:	eb 17                	jmp    800358 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  800341:	0f be 50 02          	movsbl 0x2(%eax),%edx
  800345:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  800348:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
        c = *++cp;
  80034f:	eb 07                	jmp    800358 <inet_aton+0x5b>
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
  800351:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
  800358:	40                   	inc    %eax
  800359:	be 00 00 00 00       	mov    $0x0,%esi
  80035e:	eb 01                	jmp    800361 <inet_aton+0x64>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  800360:	40                   	inc    %eax
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
  800361:	8d 78 ff             	lea    -0x1(%eax),%edi
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  800364:	88 d1                	mov    %dl,%cl
  800366:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800369:	80 fb 09             	cmp    $0x9,%bl
  80036c:	77 0d                	ja     80037b <inet_aton+0x7e>
        val = (val * base) + (int)(c - '0');
  80036e:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  800372:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  800376:	0f be 10             	movsbl (%eax),%edx
  800379:	eb e5                	jmp    800360 <inet_aton+0x63>
      } else if (base == 16 && isxdigit(c)) {
  80037b:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  80037f:	75 30                	jne    8003b1 <inet_aton+0xb4>
  800381:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800384:	88 5d da             	mov    %bl,-0x26(%ebp)
  800387:	80 fb 05             	cmp    $0x5,%bl
  80038a:	76 08                	jbe    800394 <inet_aton+0x97>
  80038c:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  80038f:	80 fb 05             	cmp    $0x5,%bl
  800392:	77 23                	ja     8003b7 <inet_aton+0xba>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  800394:	89 f1                	mov    %esi,%ecx
  800396:	c1 e1 04             	shl    $0x4,%ecx
  800399:	8d 72 0a             	lea    0xa(%edx),%esi
  80039c:	80 7d da 1a          	cmpb   $0x1a,-0x26(%ebp)
  8003a0:	19 d2                	sbb    %edx,%edx
  8003a2:	83 e2 20             	and    $0x20,%edx
  8003a5:	83 c2 41             	add    $0x41,%edx
  8003a8:	29 d6                	sub    %edx,%esi
  8003aa:	09 ce                	or     %ecx,%esi
        c = *++cp;
  8003ac:	0f be 10             	movsbl (%eax),%edx
  8003af:	eb af                	jmp    800360 <inet_aton+0x63>
    }
    for (;;) {
      if (isdigit(c)) {
        val = (val * base) + (int)(c - '0');
        c = *++cp;
      } else if (base == 16 && isxdigit(c)) {
  8003b1:	89 d0                	mov    %edx,%eax
  8003b3:	89 f3                	mov    %esi,%ebx
  8003b5:	eb 04                	jmp    8003bb <inet_aton+0xbe>
  8003b7:	89 d0                	mov    %edx,%eax
  8003b9:	89 f3                	mov    %esi,%ebx
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
        c = *++cp;
      } else
        break;
    }
    if (c == '.') {
  8003bb:	83 f8 2e             	cmp    $0x2e,%eax
  8003be:	75 23                	jne    8003e3 <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8003c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c3:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
  8003c6:	0f 83 ee 00 00 00    	jae    8004ba <inet_aton+0x1bd>
        return (0);
      *pp++ = val;
  8003cc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8003cf:	89 1a                	mov    %ebx,(%edx)
  8003d1:	83 c2 04             	add    $0x4,%edx
  8003d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
      c = *++cp;
  8003d7:	8d 47 01             	lea    0x1(%edi),%eax
  8003da:	0f be 57 01          	movsbl 0x1(%edi),%edx
    } else
      break;
  }
  8003de:	e9 35 ff ff ff       	jmp    800318 <inet_aton+0x1b>
  8003e3:	89 f3                	mov    %esi,%ebx
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
        c = *++cp;
      } else
        break;
    }
    if (c == '.') {
  8003e5:	89 f0                	mov    %esi,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8003e7:	85 d2                	test   %edx,%edx
  8003e9:	74 33                	je     80041e <inet_aton+0x121>
  8003eb:	80 f9 1f             	cmp    $0x1f,%cl
  8003ee:	0f 86 cd 00 00 00    	jbe    8004c1 <inet_aton+0x1c4>
  8003f4:	84 d2                	test   %dl,%dl
  8003f6:	0f 88 cc 00 00 00    	js     8004c8 <inet_aton+0x1cb>
  8003fc:	83 fa 20             	cmp    $0x20,%edx
  8003ff:	74 1d                	je     80041e <inet_aton+0x121>
  800401:	83 fa 0c             	cmp    $0xc,%edx
  800404:	74 18                	je     80041e <inet_aton+0x121>
  800406:	83 fa 0a             	cmp    $0xa,%edx
  800409:	74 13                	je     80041e <inet_aton+0x121>
  80040b:	83 fa 0d             	cmp    $0xd,%edx
  80040e:	74 0e                	je     80041e <inet_aton+0x121>
  800410:	83 fa 09             	cmp    $0x9,%edx
  800413:	74 09                	je     80041e <inet_aton+0x121>
  800415:	83 fa 0b             	cmp    $0xb,%edx
  800418:	0f 85 b1 00 00 00    	jne    8004cf <inet_aton+0x1d2>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  80041e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800421:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800424:	29 d1                	sub    %edx,%ecx
  800426:	89 ca                	mov    %ecx,%edx
  800428:	c1 fa 02             	sar    $0x2,%edx
  80042b:	42                   	inc    %edx
  switch (n) {
  80042c:	83 fa 02             	cmp    $0x2,%edx
  80042f:	74 1b                	je     80044c <inet_aton+0x14f>
  800431:	83 fa 02             	cmp    $0x2,%edx
  800434:	7f 0a                	jg     800440 <inet_aton+0x143>
  800436:	85 d2                	test   %edx,%edx
  800438:	0f 84 98 00 00 00    	je     8004d6 <inet_aton+0x1d9>
  80043e:	eb 59                	jmp    800499 <inet_aton+0x19c>
  800440:	83 fa 03             	cmp    $0x3,%edx
  800443:	74 1c                	je     800461 <inet_aton+0x164>
  800445:	83 fa 04             	cmp    $0x4,%edx
  800448:	75 4f                	jne    800499 <inet_aton+0x19c>
  80044a:	eb 2e                	jmp    80047a <inet_aton+0x17d>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  80044c:	3d ff ff ff 00       	cmp    $0xffffff,%eax
  800451:	0f 87 86 00 00 00    	ja     8004dd <inet_aton+0x1e0>
      return (0);
    val |= parts[0] << 24;
  800457:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80045a:	c1 e3 18             	shl    $0x18,%ebx
  80045d:	09 c3                	or     %eax,%ebx
    break;
  80045f:	eb 38                	jmp    800499 <inet_aton+0x19c>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  800461:	3d ff ff 00 00       	cmp    $0xffff,%eax
  800466:	77 7c                	ja     8004e4 <inet_aton+0x1e7>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  800468:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  80046b:	c1 e3 10             	shl    $0x10,%ebx
  80046e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800471:	c1 e2 18             	shl    $0x18,%edx
  800474:	09 d3                	or     %edx,%ebx
  800476:	09 c3                	or     %eax,%ebx
    break;
  800478:	eb 1f                	jmp    800499 <inet_aton+0x19c>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  80047a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80047f:	77 6a                	ja     8004eb <inet_aton+0x1ee>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  800481:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  800484:	c1 e3 10             	shl    $0x10,%ebx
  800487:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80048a:	c1 e2 18             	shl    $0x18,%edx
  80048d:	09 d3                	or     %edx,%ebx
  80048f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800492:	c1 e2 08             	shl    $0x8,%edx
  800495:	09 d3                	or     %edx,%ebx
  800497:	09 c3                	or     %eax,%ebx
    break;
  }
  if (addr)
  800499:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80049d:	74 53                	je     8004f2 <inet_aton+0x1f5>
    addr->s_addr = htonl(val);
  80049f:	89 1c 24             	mov    %ebx,(%esp)
  8004a2:	e8 2a fe ff ff       	call   8002d1 <htonl>
  8004a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004aa:	89 03                	mov    %eax,(%ebx)
  return (1);
  8004ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8004b1:	eb 44                	jmp    8004f7 <inet_aton+0x1fa>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  8004b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b8:	eb 3d                	jmp    8004f7 <inet_aton+0x1fa>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  8004ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bf:	eb 36                	jmp    8004f7 <inet_aton+0x1fa>
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
    return (0);
  8004c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c6:	eb 2f                	jmp    8004f7 <inet_aton+0x1fa>
  8004c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004cd:	eb 28                	jmp    8004f7 <inet_aton+0x1fa>
  8004cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d4:	eb 21                	jmp    8004f7 <inet_aton+0x1fa>
   */
  n = pp - parts + 1;
  switch (n) {

  case 0:
    return (0);       /* initial nondigit */
  8004d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004db:	eb 1a                	jmp    8004f7 <inet_aton+0x1fa>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  8004dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e2:	eb 13                	jmp    8004f7 <inet_aton+0x1fa>
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  8004e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e9:	eb 0c                	jmp    8004f7 <inet_aton+0x1fa>
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  8004eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f0:	eb 05                	jmp    8004f7 <inet_aton+0x1fa>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  8004f2:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8004f7:	83 c4 24             	add    $0x24,%esp
  8004fa:	5b                   	pop    %ebx
  8004fb:	5e                   	pop    %esi
  8004fc:	5f                   	pop    %edi
  8004fd:	5d                   	pop    %ebp
  8004fe:	c3                   	ret    

008004ff <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800505:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800508:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050c:	8b 45 08             	mov    0x8(%ebp),%eax
  80050f:	89 04 24             	mov    %eax,(%esp)
  800512:	e8 e6 fd ff ff       	call   8002fd <inet_aton>
  800517:	85 c0                	test   %eax,%eax
  800519:	74 05                	je     800520 <inet_addr+0x21>
    return (val.s_addr);
  80051b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80051e:	eb 05                	jmp    800525 <inet_addr+0x26>
  }
  return (INADDR_NONE);
  800520:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  800525:	c9                   	leave  
  800526:	c3                   	ret    

00800527 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  80052d:	8b 45 08             	mov    0x8(%ebp),%eax
  800530:	89 04 24             	mov    %eax,(%esp)
  800533:	e8 99 fd ff ff       	call   8002d1 <htonl>
}
  800538:	c9                   	leave  
  800539:	c3                   	ret    
	...

0080053c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	56                   	push   %esi
  800540:	53                   	push   %ebx
  800541:	83 ec 10             	sub    $0x10,%esp
  800544:	8b 75 08             	mov    0x8(%ebp),%esi
  800547:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80054a:	e8 5c 0a 00 00       	call   800fab <sys_getenvid>
  80054f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800554:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80055b:	c1 e0 07             	shl    $0x7,%eax
  80055e:	29 d0                	sub    %edx,%eax
  800560:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800565:	a3 18 40 80 00       	mov    %eax,0x804018


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80056a:	85 f6                	test   %esi,%esi
  80056c:	7e 07                	jle    800575 <libmain+0x39>
		binaryname = argv[0];
  80056e:	8b 03                	mov    (%ebx),%eax
  800570:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800575:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800579:	89 34 24             	mov    %esi,(%esp)
  80057c:	e8 60 fb ff ff       	call   8000e1 <umain>

	// exit gracefully
	exit();
  800581:	e8 0a 00 00 00       	call   800590 <exit>
}
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	5b                   	pop    %ebx
  80058a:	5e                   	pop    %esi
  80058b:	5d                   	pop    %ebp
  80058c:	c3                   	ret    
  80058d:	00 00                	add    %al,(%eax)
	...

00800590 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800590:	55                   	push   %ebp
  800591:	89 e5                	mov    %esp,%ebp
  800593:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800596:	e8 00 0f 00 00       	call   80149b <close_all>
	sys_env_destroy(0);
  80059b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005a2:	e8 b2 09 00 00       	call   800f59 <sys_env_destroy>
}
  8005a7:	c9                   	leave  
  8005a8:	c3                   	ret    
  8005a9:	00 00                	add    %al,(%eax)
	...

008005ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8005ac:	55                   	push   %ebp
  8005ad:	89 e5                	mov    %esp,%ebp
  8005af:	53                   	push   %ebx
  8005b0:	83 ec 14             	sub    $0x14,%esp
  8005b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8005b6:	8b 03                	mov    (%ebx),%eax
  8005b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8005bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8005bf:	40                   	inc    %eax
  8005c0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8005c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8005c7:	75 19                	jne    8005e2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8005c9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8005d0:	00 
  8005d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8005d4:	89 04 24             	mov    %eax,(%esp)
  8005d7:	e8 40 09 00 00       	call   800f1c <sys_cputs>
		b->idx = 0;
  8005dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8005e2:	ff 43 04             	incl   0x4(%ebx)
}
  8005e5:	83 c4 14             	add    $0x14,%esp
  8005e8:	5b                   	pop    %ebx
  8005e9:	5d                   	pop    %ebp
  8005ea:	c3                   	ret    

008005eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8005eb:	55                   	push   %ebp
  8005ec:	89 e5                	mov    %esp,%ebp
  8005ee:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8005f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005fb:	00 00 00 
	b.cnt = 0;
  8005fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800605:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800608:	8b 45 0c             	mov    0xc(%ebp),%eax
  80060b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80060f:	8b 45 08             	mov    0x8(%ebp),%eax
  800612:	89 44 24 08          	mov    %eax,0x8(%esp)
  800616:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80061c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800620:	c7 04 24 ac 05 80 00 	movl   $0x8005ac,(%esp)
  800627:	e8 82 01 00 00       	call   8007ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80062c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800632:	89 44 24 04          	mov    %eax,0x4(%esp)
  800636:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80063c:	89 04 24             	mov    %eax,(%esp)
  80063f:	e8 d8 08 00 00       	call   800f1c <sys_cputs>

	return b.cnt;
}
  800644:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80064a:	c9                   	leave  
  80064b:	c3                   	ret    

0080064c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80064c:	55                   	push   %ebp
  80064d:	89 e5                	mov    %esp,%ebp
  80064f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800652:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800655:	89 44 24 04          	mov    %eax,0x4(%esp)
  800659:	8b 45 08             	mov    0x8(%ebp),%eax
  80065c:	89 04 24             	mov    %eax,(%esp)
  80065f:	e8 87 ff ff ff       	call   8005eb <vcprintf>
	va_end(ap);

	return cnt;
}
  800664:	c9                   	leave  
  800665:	c3                   	ret    
	...

00800668 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800668:	55                   	push   %ebp
  800669:	89 e5                	mov    %esp,%ebp
  80066b:	57                   	push   %edi
  80066c:	56                   	push   %esi
  80066d:	53                   	push   %ebx
  80066e:	83 ec 3c             	sub    $0x3c,%esp
  800671:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800674:	89 d7                	mov    %edx,%edi
  800676:	8b 45 08             	mov    0x8(%ebp),%eax
  800679:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80067c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80067f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800682:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800685:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800688:	85 c0                	test   %eax,%eax
  80068a:	75 08                	jne    800694 <printnum+0x2c>
  80068c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80068f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800692:	77 57                	ja     8006eb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800694:	89 74 24 10          	mov    %esi,0x10(%esp)
  800698:	4b                   	dec    %ebx
  800699:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80069d:	8b 45 10             	mov    0x10(%ebp),%eax
  8006a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006a4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8006a8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8006ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8006b3:	00 
  8006b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8006b7:	89 04 24             	mov    %eax,(%esp)
  8006ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c1:	e8 66 20 00 00       	call   80272c <__udivdi3>
  8006c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006ce:	89 04 24             	mov    %eax,(%esp)
  8006d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006d5:	89 fa                	mov    %edi,%edx
  8006d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006da:	e8 89 ff ff ff       	call   800668 <printnum>
  8006df:	eb 0f                	jmp    8006f0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8006e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006e5:	89 34 24             	mov    %esi,(%esp)
  8006e8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8006eb:	4b                   	dec    %ebx
  8006ec:	85 db                	test   %ebx,%ebx
  8006ee:	7f f1                	jg     8006e1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8006f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8006f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8006fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800706:	00 
  800707:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80070a:	89 04 24             	mov    %eax,(%esp)
  80070d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800710:	89 44 24 04          	mov    %eax,0x4(%esp)
  800714:	e8 33 21 00 00       	call   80284c <__umoddi3>
  800719:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80071d:	0f be 80 c5 2a 80 00 	movsbl 0x802ac5(%eax),%eax
  800724:	89 04 24             	mov    %eax,(%esp)
  800727:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80072a:	83 c4 3c             	add    $0x3c,%esp
  80072d:	5b                   	pop    %ebx
  80072e:	5e                   	pop    %esi
  80072f:	5f                   	pop    %edi
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800735:	83 fa 01             	cmp    $0x1,%edx
  800738:	7e 0e                	jle    800748 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80073a:	8b 10                	mov    (%eax),%edx
  80073c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80073f:	89 08                	mov    %ecx,(%eax)
  800741:	8b 02                	mov    (%edx),%eax
  800743:	8b 52 04             	mov    0x4(%edx),%edx
  800746:	eb 22                	jmp    80076a <getuint+0x38>
	else if (lflag)
  800748:	85 d2                	test   %edx,%edx
  80074a:	74 10                	je     80075c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80074c:	8b 10                	mov    (%eax),%edx
  80074e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800751:	89 08                	mov    %ecx,(%eax)
  800753:	8b 02                	mov    (%edx),%eax
  800755:	ba 00 00 00 00       	mov    $0x0,%edx
  80075a:	eb 0e                	jmp    80076a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80075c:	8b 10                	mov    (%eax),%edx
  80075e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800761:	89 08                	mov    %ecx,(%eax)
  800763:	8b 02                	mov    (%edx),%eax
  800765:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80076a:	5d                   	pop    %ebp
  80076b:	c3                   	ret    

0080076c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800772:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800775:	8b 10                	mov    (%eax),%edx
  800777:	3b 50 04             	cmp    0x4(%eax),%edx
  80077a:	73 08                	jae    800784 <sprintputch+0x18>
		*b->buf++ = ch;
  80077c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077f:	88 0a                	mov    %cl,(%edx)
  800781:	42                   	inc    %edx
  800782:	89 10                	mov    %edx,(%eax)
}
  800784:	5d                   	pop    %ebp
  800785:	c3                   	ret    

00800786 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80078c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80078f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800793:	8b 45 10             	mov    0x10(%ebp),%eax
  800796:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a4:	89 04 24             	mov    %eax,(%esp)
  8007a7:	e8 02 00 00 00       	call   8007ae <vprintfmt>
	va_end(ap);
}
  8007ac:	c9                   	leave  
  8007ad:	c3                   	ret    

008007ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	57                   	push   %edi
  8007b2:	56                   	push   %esi
  8007b3:	53                   	push   %ebx
  8007b4:	83 ec 4c             	sub    $0x4c,%esp
  8007b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007ba:	8b 75 10             	mov    0x10(%ebp),%esi
  8007bd:	eb 12                	jmp    8007d1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	0f 84 6b 03 00 00    	je     800b32 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8007c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007cb:	89 04 24             	mov    %eax,(%esp)
  8007ce:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007d1:	0f b6 06             	movzbl (%esi),%eax
  8007d4:	46                   	inc    %esi
  8007d5:	83 f8 25             	cmp    $0x25,%eax
  8007d8:	75 e5                	jne    8007bf <vprintfmt+0x11>
  8007da:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8007de:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8007e5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8007ea:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8007f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f6:	eb 26                	jmp    80081e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007f8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8007fb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8007ff:	eb 1d                	jmp    80081e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800801:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800804:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800808:	eb 14                	jmp    80081e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80080d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800814:	eb 08                	jmp    80081e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800816:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800819:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081e:	0f b6 06             	movzbl (%esi),%eax
  800821:	8d 56 01             	lea    0x1(%esi),%edx
  800824:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800827:	8a 16                	mov    (%esi),%dl
  800829:	83 ea 23             	sub    $0x23,%edx
  80082c:	80 fa 55             	cmp    $0x55,%dl
  80082f:	0f 87 e1 02 00 00    	ja     800b16 <vprintfmt+0x368>
  800835:	0f b6 d2             	movzbl %dl,%edx
  800838:	ff 24 95 00 2c 80 00 	jmp    *0x802c00(,%edx,4)
  80083f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800842:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800847:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80084a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80084e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800851:	8d 50 d0             	lea    -0x30(%eax),%edx
  800854:	83 fa 09             	cmp    $0x9,%edx
  800857:	77 2a                	ja     800883 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800859:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80085a:	eb eb                	jmp    800847 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80085c:	8b 45 14             	mov    0x14(%ebp),%eax
  80085f:	8d 50 04             	lea    0x4(%eax),%edx
  800862:	89 55 14             	mov    %edx,0x14(%ebp)
  800865:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800867:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80086a:	eb 17                	jmp    800883 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80086c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800870:	78 98                	js     80080a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800872:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800875:	eb a7                	jmp    80081e <vprintfmt+0x70>
  800877:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80087a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800881:	eb 9b                	jmp    80081e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800883:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800887:	79 95                	jns    80081e <vprintfmt+0x70>
  800889:	eb 8b                	jmp    800816 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80088b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80088f:	eb 8d                	jmp    80081e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800891:	8b 45 14             	mov    0x14(%ebp),%eax
  800894:	8d 50 04             	lea    0x4(%eax),%edx
  800897:	89 55 14             	mov    %edx,0x14(%ebp)
  80089a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80089e:	8b 00                	mov    (%eax),%eax
  8008a0:	89 04 24             	mov    %eax,(%esp)
  8008a3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008a9:	e9 23 ff ff ff       	jmp    8007d1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b1:	8d 50 04             	lea    0x4(%eax),%edx
  8008b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b7:	8b 00                	mov    (%eax),%eax
  8008b9:	85 c0                	test   %eax,%eax
  8008bb:	79 02                	jns    8008bf <vprintfmt+0x111>
  8008bd:	f7 d8                	neg    %eax
  8008bf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8008c1:	83 f8 10             	cmp    $0x10,%eax
  8008c4:	7f 0b                	jg     8008d1 <vprintfmt+0x123>
  8008c6:	8b 04 85 60 2d 80 00 	mov    0x802d60(,%eax,4),%eax
  8008cd:	85 c0                	test   %eax,%eax
  8008cf:	75 23                	jne    8008f4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8008d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8008d5:	c7 44 24 08 dd 2a 80 	movl   $0x802add,0x8(%esp)
  8008dc:	00 
  8008dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	89 04 24             	mov    %eax,(%esp)
  8008e7:	e8 9a fe ff ff       	call   800786 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8008ef:	e9 dd fe ff ff       	jmp    8007d1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8008f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008f8:	c7 44 24 08 99 2e 80 	movl   $0x802e99,0x8(%esp)
  8008ff:	00 
  800900:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800904:	8b 55 08             	mov    0x8(%ebp),%edx
  800907:	89 14 24             	mov    %edx,(%esp)
  80090a:	e8 77 fe ff ff       	call   800786 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80090f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800912:	e9 ba fe ff ff       	jmp    8007d1 <vprintfmt+0x23>
  800917:	89 f9                	mov    %edi,%ecx
  800919:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80091c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80091f:	8b 45 14             	mov    0x14(%ebp),%eax
  800922:	8d 50 04             	lea    0x4(%eax),%edx
  800925:	89 55 14             	mov    %edx,0x14(%ebp)
  800928:	8b 30                	mov    (%eax),%esi
  80092a:	85 f6                	test   %esi,%esi
  80092c:	75 05                	jne    800933 <vprintfmt+0x185>
				p = "(null)";
  80092e:	be d6 2a 80 00       	mov    $0x802ad6,%esi
			if (width > 0 && padc != '-')
  800933:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800937:	0f 8e 84 00 00 00    	jle    8009c1 <vprintfmt+0x213>
  80093d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800941:	74 7e                	je     8009c1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800943:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800947:	89 34 24             	mov    %esi,(%esp)
  80094a:	e8 8b 02 00 00       	call   800bda <strnlen>
  80094f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800952:	29 c2                	sub    %eax,%edx
  800954:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800957:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80095b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80095e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800961:	89 de                	mov    %ebx,%esi
  800963:	89 d3                	mov    %edx,%ebx
  800965:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800967:	eb 0b                	jmp    800974 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800969:	89 74 24 04          	mov    %esi,0x4(%esp)
  80096d:	89 3c 24             	mov    %edi,(%esp)
  800970:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800973:	4b                   	dec    %ebx
  800974:	85 db                	test   %ebx,%ebx
  800976:	7f f1                	jg     800969 <vprintfmt+0x1bb>
  800978:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80097b:	89 f3                	mov    %esi,%ebx
  80097d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800980:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800983:	85 c0                	test   %eax,%eax
  800985:	79 05                	jns    80098c <vprintfmt+0x1de>
  800987:	b8 00 00 00 00       	mov    $0x0,%eax
  80098c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80098f:	29 c2                	sub    %eax,%edx
  800991:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800994:	eb 2b                	jmp    8009c1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800996:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80099a:	74 18                	je     8009b4 <vprintfmt+0x206>
  80099c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80099f:	83 fa 5e             	cmp    $0x5e,%edx
  8009a2:	76 10                	jbe    8009b4 <vprintfmt+0x206>
					putch('?', putdat);
  8009a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009a8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8009af:	ff 55 08             	call   *0x8(%ebp)
  8009b2:	eb 0a                	jmp    8009be <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8009b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b8:	89 04 24             	mov    %eax,(%esp)
  8009bb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009be:	ff 4d e4             	decl   -0x1c(%ebp)
  8009c1:	0f be 06             	movsbl (%esi),%eax
  8009c4:	46                   	inc    %esi
  8009c5:	85 c0                	test   %eax,%eax
  8009c7:	74 21                	je     8009ea <vprintfmt+0x23c>
  8009c9:	85 ff                	test   %edi,%edi
  8009cb:	78 c9                	js     800996 <vprintfmt+0x1e8>
  8009cd:	4f                   	dec    %edi
  8009ce:	79 c6                	jns    800996 <vprintfmt+0x1e8>
  8009d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009d3:	89 de                	mov    %ebx,%esi
  8009d5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8009d8:	eb 18                	jmp    8009f2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8009da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009de:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8009e5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8009e7:	4b                   	dec    %ebx
  8009e8:	eb 08                	jmp    8009f2 <vprintfmt+0x244>
  8009ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ed:	89 de                	mov    %ebx,%esi
  8009ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8009f2:	85 db                	test   %ebx,%ebx
  8009f4:	7f e4                	jg     8009da <vprintfmt+0x22c>
  8009f6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8009f9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8009fe:	e9 ce fd ff ff       	jmp    8007d1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a03:	83 f9 01             	cmp    $0x1,%ecx
  800a06:	7e 10                	jle    800a18 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800a08:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0b:	8d 50 08             	lea    0x8(%eax),%edx
  800a0e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a11:	8b 30                	mov    (%eax),%esi
  800a13:	8b 78 04             	mov    0x4(%eax),%edi
  800a16:	eb 26                	jmp    800a3e <vprintfmt+0x290>
	else if (lflag)
  800a18:	85 c9                	test   %ecx,%ecx
  800a1a:	74 12                	je     800a2e <vprintfmt+0x280>
		return va_arg(*ap, long);
  800a1c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a1f:	8d 50 04             	lea    0x4(%eax),%edx
  800a22:	89 55 14             	mov    %edx,0x14(%ebp)
  800a25:	8b 30                	mov    (%eax),%esi
  800a27:	89 f7                	mov    %esi,%edi
  800a29:	c1 ff 1f             	sar    $0x1f,%edi
  800a2c:	eb 10                	jmp    800a3e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800a2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a31:	8d 50 04             	lea    0x4(%eax),%edx
  800a34:	89 55 14             	mov    %edx,0x14(%ebp)
  800a37:	8b 30                	mov    (%eax),%esi
  800a39:	89 f7                	mov    %esi,%edi
  800a3b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800a3e:	85 ff                	test   %edi,%edi
  800a40:	78 0a                	js     800a4c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800a42:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a47:	e9 8c 00 00 00       	jmp    800ad8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800a4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a50:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a57:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800a5a:	f7 de                	neg    %esi
  800a5c:	83 d7 00             	adc    $0x0,%edi
  800a5f:	f7 df                	neg    %edi
			}
			base = 10;
  800a61:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a66:	eb 70                	jmp    800ad8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a68:	89 ca                	mov    %ecx,%edx
  800a6a:	8d 45 14             	lea    0x14(%ebp),%eax
  800a6d:	e8 c0 fc ff ff       	call   800732 <getuint>
  800a72:	89 c6                	mov    %eax,%esi
  800a74:	89 d7                	mov    %edx,%edi
			base = 10;
  800a76:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800a7b:	eb 5b                	jmp    800ad8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800a7d:	89 ca                	mov    %ecx,%edx
  800a7f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a82:	e8 ab fc ff ff       	call   800732 <getuint>
  800a87:	89 c6                	mov    %eax,%esi
  800a89:	89 d7                	mov    %edx,%edi
			base = 8;
  800a8b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800a90:	eb 46                	jmp    800ad8 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800a92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a96:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a9d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800aa0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aa4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800aab:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800aae:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab1:	8d 50 04             	lea    0x4(%eax),%edx
  800ab4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800ab7:	8b 30                	mov    (%eax),%esi
  800ab9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800abe:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800ac3:	eb 13                	jmp    800ad8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800ac5:	89 ca                	mov    %ecx,%edx
  800ac7:	8d 45 14             	lea    0x14(%ebp),%eax
  800aca:	e8 63 fc ff ff       	call   800732 <getuint>
  800acf:	89 c6                	mov    %eax,%esi
  800ad1:	89 d7                	mov    %edx,%edi
			base = 16;
  800ad3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ad8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800adc:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ae0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ae3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ae7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aeb:	89 34 24             	mov    %esi,(%esp)
  800aee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800af2:	89 da                	mov    %ebx,%edx
  800af4:	8b 45 08             	mov    0x8(%ebp),%eax
  800af7:	e8 6c fb ff ff       	call   800668 <printnum>
			break;
  800afc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800aff:	e9 cd fc ff ff       	jmp    8007d1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b04:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b08:	89 04 24             	mov    %eax,(%esp)
  800b0b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b0e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b11:	e9 bb fc ff ff       	jmp    8007d1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b1a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b21:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b24:	eb 01                	jmp    800b27 <vprintfmt+0x379>
  800b26:	4e                   	dec    %esi
  800b27:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800b2b:	75 f9                	jne    800b26 <vprintfmt+0x378>
  800b2d:	e9 9f fc ff ff       	jmp    8007d1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800b32:	83 c4 4c             	add    $0x4c,%esp
  800b35:	5b                   	pop    %ebx
  800b36:	5e                   	pop    %esi
  800b37:	5f                   	pop    %edi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	83 ec 28             	sub    $0x28,%esp
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
  800b43:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b46:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b49:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800b4d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800b50:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b57:	85 c0                	test   %eax,%eax
  800b59:	74 30                	je     800b8b <vsnprintf+0x51>
  800b5b:	85 d2                	test   %edx,%edx
  800b5d:	7e 33                	jle    800b92 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b5f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b62:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b66:	8b 45 10             	mov    0x10(%ebp),%eax
  800b69:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b6d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b70:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b74:	c7 04 24 6c 07 80 00 	movl   $0x80076c,(%esp)
  800b7b:	e8 2e fc ff ff       	call   8007ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b80:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b83:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b89:	eb 0c                	jmp    800b97 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800b8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b90:	eb 05                	jmp    800b97 <vsnprintf+0x5d>
  800b92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b9f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ba2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ba6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb7:	89 04 24             	mov    %eax,(%esp)
  800bba:	e8 7b ff ff ff       	call   800b3a <vsnprintf>
	va_end(ap);

	return rc;
}
  800bbf:	c9                   	leave  
  800bc0:	c3                   	ret    
  800bc1:	00 00                	add    %al,(%eax)
	...

00800bc4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bca:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcf:	eb 01                	jmp    800bd2 <strlen+0xe>
		n++;
  800bd1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bd2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bd6:	75 f9                	jne    800bd1 <strlen+0xd>
		n++;
	return n;
}
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800be0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800be3:	b8 00 00 00 00       	mov    $0x0,%eax
  800be8:	eb 01                	jmp    800beb <strnlen+0x11>
		n++;
  800bea:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800beb:	39 d0                	cmp    %edx,%eax
  800bed:	74 06                	je     800bf5 <strnlen+0x1b>
  800bef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800bf3:	75 f5                	jne    800bea <strnlen+0x10>
		n++;
	return n;
}
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	53                   	push   %ebx
  800bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c01:	ba 00 00 00 00       	mov    $0x0,%edx
  800c06:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800c09:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c0c:	42                   	inc    %edx
  800c0d:	84 c9                	test   %cl,%cl
  800c0f:	75 f5                	jne    800c06 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c11:	5b                   	pop    %ebx
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	53                   	push   %ebx
  800c18:	83 ec 08             	sub    $0x8,%esp
  800c1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c1e:	89 1c 24             	mov    %ebx,(%esp)
  800c21:	e8 9e ff ff ff       	call   800bc4 <strlen>
	strcpy(dst + len, src);
  800c26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c29:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c2d:	01 d8                	add    %ebx,%eax
  800c2f:	89 04 24             	mov    %eax,(%esp)
  800c32:	e8 c0 ff ff ff       	call   800bf7 <strcpy>
	return dst;
}
  800c37:	89 d8                	mov    %ebx,%eax
  800c39:	83 c4 08             	add    $0x8,%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    

00800c3f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	8b 45 08             	mov    0x8(%ebp),%eax
  800c47:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c4a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c4d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c52:	eb 0c                	jmp    800c60 <strncpy+0x21>
		*dst++ = *src;
  800c54:	8a 1a                	mov    (%edx),%bl
  800c56:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c59:	80 3a 01             	cmpb   $0x1,(%edx)
  800c5c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c5f:	41                   	inc    %ecx
  800c60:	39 f1                	cmp    %esi,%ecx
  800c62:	75 f0                	jne    800c54 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c64:	5b                   	pop    %ebx
  800c65:	5e                   	pop    %esi
  800c66:	5d                   	pop    %ebp
  800c67:	c3                   	ret    

00800c68 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c68:	55                   	push   %ebp
  800c69:	89 e5                	mov    %esp,%ebp
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
  800c6d:	8b 75 08             	mov    0x8(%ebp),%esi
  800c70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c73:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c76:	85 d2                	test   %edx,%edx
  800c78:	75 0a                	jne    800c84 <strlcpy+0x1c>
  800c7a:	89 f0                	mov    %esi,%eax
  800c7c:	eb 1a                	jmp    800c98 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800c7e:	88 18                	mov    %bl,(%eax)
  800c80:	40                   	inc    %eax
  800c81:	41                   	inc    %ecx
  800c82:	eb 02                	jmp    800c86 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c84:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800c86:	4a                   	dec    %edx
  800c87:	74 0a                	je     800c93 <strlcpy+0x2b>
  800c89:	8a 19                	mov    (%ecx),%bl
  800c8b:	84 db                	test   %bl,%bl
  800c8d:	75 ef                	jne    800c7e <strlcpy+0x16>
  800c8f:	89 c2                	mov    %eax,%edx
  800c91:	eb 02                	jmp    800c95 <strlcpy+0x2d>
  800c93:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800c95:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800c98:	29 f0                	sub    %esi,%eax
}
  800c9a:	5b                   	pop    %ebx
  800c9b:	5e                   	pop    %esi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ca7:	eb 02                	jmp    800cab <strcmp+0xd>
		p++, q++;
  800ca9:	41                   	inc    %ecx
  800caa:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cab:	8a 01                	mov    (%ecx),%al
  800cad:	84 c0                	test   %al,%al
  800caf:	74 04                	je     800cb5 <strcmp+0x17>
  800cb1:	3a 02                	cmp    (%edx),%al
  800cb3:	74 f4                	je     800ca9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800cb5:	0f b6 c0             	movzbl %al,%eax
  800cb8:	0f b6 12             	movzbl (%edx),%edx
  800cbb:	29 d0                	sub    %edx,%eax
}
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	53                   	push   %ebx
  800cc3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800ccc:	eb 03                	jmp    800cd1 <strncmp+0x12>
		n--, p++, q++;
  800cce:	4a                   	dec    %edx
  800ccf:	40                   	inc    %eax
  800cd0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cd1:	85 d2                	test   %edx,%edx
  800cd3:	74 14                	je     800ce9 <strncmp+0x2a>
  800cd5:	8a 18                	mov    (%eax),%bl
  800cd7:	84 db                	test   %bl,%bl
  800cd9:	74 04                	je     800cdf <strncmp+0x20>
  800cdb:	3a 19                	cmp    (%ecx),%bl
  800cdd:	74 ef                	je     800cce <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800cdf:	0f b6 00             	movzbl (%eax),%eax
  800ce2:	0f b6 11             	movzbl (%ecx),%edx
  800ce5:	29 d0                	sub    %edx,%eax
  800ce7:	eb 05                	jmp    800cee <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ce9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cee:	5b                   	pop    %ebx
  800cef:	5d                   	pop    %ebp
  800cf0:	c3                   	ret    

00800cf1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800cf1:	55                   	push   %ebp
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800cfa:	eb 05                	jmp    800d01 <strchr+0x10>
		if (*s == c)
  800cfc:	38 ca                	cmp    %cl,%dl
  800cfe:	74 0c                	je     800d0c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d00:	40                   	inc    %eax
  800d01:	8a 10                	mov    (%eax),%dl
  800d03:	84 d2                	test   %dl,%dl
  800d05:	75 f5                	jne    800cfc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800d07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	8b 45 08             	mov    0x8(%ebp),%eax
  800d14:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800d17:	eb 05                	jmp    800d1e <strfind+0x10>
		if (*s == c)
  800d19:	38 ca                	cmp    %cl,%dl
  800d1b:	74 07                	je     800d24 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d1d:	40                   	inc    %eax
  800d1e:	8a 10                	mov    (%eax),%dl
  800d20:	84 d2                	test   %dl,%dl
  800d22:	75 f5                	jne    800d19 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d32:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d35:	85 c9                	test   %ecx,%ecx
  800d37:	74 30                	je     800d69 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d39:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d3f:	75 25                	jne    800d66 <memset+0x40>
  800d41:	f6 c1 03             	test   $0x3,%cl
  800d44:	75 20                	jne    800d66 <memset+0x40>
		c &= 0xFF;
  800d46:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d49:	89 d3                	mov    %edx,%ebx
  800d4b:	c1 e3 08             	shl    $0x8,%ebx
  800d4e:	89 d6                	mov    %edx,%esi
  800d50:	c1 e6 18             	shl    $0x18,%esi
  800d53:	89 d0                	mov    %edx,%eax
  800d55:	c1 e0 10             	shl    $0x10,%eax
  800d58:	09 f0                	or     %esi,%eax
  800d5a:	09 d0                	or     %edx,%eax
  800d5c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800d5e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800d61:	fc                   	cld    
  800d62:	f3 ab                	rep stos %eax,%es:(%edi)
  800d64:	eb 03                	jmp    800d69 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d66:	fc                   	cld    
  800d67:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d69:	89 f8                	mov    %edi,%eax
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	57                   	push   %edi
  800d74:	56                   	push   %esi
  800d75:	8b 45 08             	mov    0x8(%ebp),%eax
  800d78:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d7e:	39 c6                	cmp    %eax,%esi
  800d80:	73 34                	jae    800db6 <memmove+0x46>
  800d82:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d85:	39 d0                	cmp    %edx,%eax
  800d87:	73 2d                	jae    800db6 <memmove+0x46>
		s += n;
		d += n;
  800d89:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d8c:	f6 c2 03             	test   $0x3,%dl
  800d8f:	75 1b                	jne    800dac <memmove+0x3c>
  800d91:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d97:	75 13                	jne    800dac <memmove+0x3c>
  800d99:	f6 c1 03             	test   $0x3,%cl
  800d9c:	75 0e                	jne    800dac <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d9e:	83 ef 04             	sub    $0x4,%edi
  800da1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800da4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800da7:	fd                   	std    
  800da8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800daa:	eb 07                	jmp    800db3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800dac:	4f                   	dec    %edi
  800dad:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800db0:	fd                   	std    
  800db1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800db3:	fc                   	cld    
  800db4:	eb 20                	jmp    800dd6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800db6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800dbc:	75 13                	jne    800dd1 <memmove+0x61>
  800dbe:	a8 03                	test   $0x3,%al
  800dc0:	75 0f                	jne    800dd1 <memmove+0x61>
  800dc2:	f6 c1 03             	test   $0x3,%cl
  800dc5:	75 0a                	jne    800dd1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800dc7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800dca:	89 c7                	mov    %eax,%edi
  800dcc:	fc                   	cld    
  800dcd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800dcf:	eb 05                	jmp    800dd6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800dd1:	89 c7                	mov    %eax,%edi
  800dd3:	fc                   	cld    
  800dd4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800dd6:	5e                   	pop    %esi
  800dd7:	5f                   	pop    %edi
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800de0:	8b 45 10             	mov    0x10(%ebp),%eax
  800de3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800de7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dea:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	89 04 24             	mov    %eax,(%esp)
  800df4:	e8 77 ff ff ff       	call   800d70 <memmove>
}
  800df9:	c9                   	leave  
  800dfa:	c3                   	ret    

00800dfb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0f:	eb 16                	jmp    800e27 <memcmp+0x2c>
		if (*s1 != *s2)
  800e11:	8a 04 17             	mov    (%edi,%edx,1),%al
  800e14:	42                   	inc    %edx
  800e15:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800e19:	38 c8                	cmp    %cl,%al
  800e1b:	74 0a                	je     800e27 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800e1d:	0f b6 c0             	movzbl %al,%eax
  800e20:	0f b6 c9             	movzbl %cl,%ecx
  800e23:	29 c8                	sub    %ecx,%eax
  800e25:	eb 09                	jmp    800e30 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e27:	39 da                	cmp    %ebx,%edx
  800e29:	75 e6                	jne    800e11 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e3e:	89 c2                	mov    %eax,%edx
  800e40:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800e43:	eb 05                	jmp    800e4a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800e45:	38 08                	cmp    %cl,(%eax)
  800e47:	74 05                	je     800e4e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800e49:	40                   	inc    %eax
  800e4a:	39 d0                	cmp    %edx,%eax
  800e4c:	72 f7                	jb     800e45 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	57                   	push   %edi
  800e54:	56                   	push   %esi
  800e55:	53                   	push   %ebx
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e5c:	eb 01                	jmp    800e5f <strtol+0xf>
		s++;
  800e5e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e5f:	8a 02                	mov    (%edx),%al
  800e61:	3c 20                	cmp    $0x20,%al
  800e63:	74 f9                	je     800e5e <strtol+0xe>
  800e65:	3c 09                	cmp    $0x9,%al
  800e67:	74 f5                	je     800e5e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e69:	3c 2b                	cmp    $0x2b,%al
  800e6b:	75 08                	jne    800e75 <strtol+0x25>
		s++;
  800e6d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800e73:	eb 13                	jmp    800e88 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800e75:	3c 2d                	cmp    $0x2d,%al
  800e77:	75 0a                	jne    800e83 <strtol+0x33>
		s++, neg = 1;
  800e79:	8d 52 01             	lea    0x1(%edx),%edx
  800e7c:	bf 01 00 00 00       	mov    $0x1,%edi
  800e81:	eb 05                	jmp    800e88 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800e83:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e88:	85 db                	test   %ebx,%ebx
  800e8a:	74 05                	je     800e91 <strtol+0x41>
  800e8c:	83 fb 10             	cmp    $0x10,%ebx
  800e8f:	75 28                	jne    800eb9 <strtol+0x69>
  800e91:	8a 02                	mov    (%edx),%al
  800e93:	3c 30                	cmp    $0x30,%al
  800e95:	75 10                	jne    800ea7 <strtol+0x57>
  800e97:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e9b:	75 0a                	jne    800ea7 <strtol+0x57>
		s += 2, base = 16;
  800e9d:	83 c2 02             	add    $0x2,%edx
  800ea0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ea5:	eb 12                	jmp    800eb9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ea7:	85 db                	test   %ebx,%ebx
  800ea9:	75 0e                	jne    800eb9 <strtol+0x69>
  800eab:	3c 30                	cmp    $0x30,%al
  800ead:	75 05                	jne    800eb4 <strtol+0x64>
		s++, base = 8;
  800eaf:	42                   	inc    %edx
  800eb0:	b3 08                	mov    $0x8,%bl
  800eb2:	eb 05                	jmp    800eb9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800eb4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800eb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebe:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ec0:	8a 0a                	mov    (%edx),%cl
  800ec2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ec5:	80 fb 09             	cmp    $0x9,%bl
  800ec8:	77 08                	ja     800ed2 <strtol+0x82>
			dig = *s - '0';
  800eca:	0f be c9             	movsbl %cl,%ecx
  800ecd:	83 e9 30             	sub    $0x30,%ecx
  800ed0:	eb 1e                	jmp    800ef0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ed2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ed5:	80 fb 19             	cmp    $0x19,%bl
  800ed8:	77 08                	ja     800ee2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800eda:	0f be c9             	movsbl %cl,%ecx
  800edd:	83 e9 57             	sub    $0x57,%ecx
  800ee0:	eb 0e                	jmp    800ef0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ee2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ee5:	80 fb 19             	cmp    $0x19,%bl
  800ee8:	77 12                	ja     800efc <strtol+0xac>
			dig = *s - 'A' + 10;
  800eea:	0f be c9             	movsbl %cl,%ecx
  800eed:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ef0:	39 f1                	cmp    %esi,%ecx
  800ef2:	7d 0c                	jge    800f00 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ef4:	42                   	inc    %edx
  800ef5:	0f af c6             	imul   %esi,%eax
  800ef8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800efa:	eb c4                	jmp    800ec0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800efc:	89 c1                	mov    %eax,%ecx
  800efe:	eb 02                	jmp    800f02 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800f00:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800f02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f06:	74 05                	je     800f0d <strtol+0xbd>
		*endptr = (char *) s;
  800f08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f0b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f0d:	85 ff                	test   %edi,%edi
  800f0f:	74 04                	je     800f15 <strtol+0xc5>
  800f11:	89 c8                	mov    %ecx,%eax
  800f13:	f7 d8                	neg    %eax
}
  800f15:	5b                   	pop    %ebx
  800f16:	5e                   	pop    %esi
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    
	...

00800f1c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	57                   	push   %edi
  800f20:	56                   	push   %esi
  800f21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f22:	b8 00 00 00 00       	mov    $0x0,%eax
  800f27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2d:	89 c3                	mov    %eax,%ebx
  800f2f:	89 c7                	mov    %eax,%edi
  800f31:	89 c6                	mov    %eax,%esi
  800f33:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800f35:	5b                   	pop    %ebx
  800f36:	5e                   	pop    %esi
  800f37:	5f                   	pop    %edi
  800f38:	5d                   	pop    %ebp
  800f39:	c3                   	ret    

00800f3a <sys_cgetc>:

int
sys_cgetc(void)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	57                   	push   %edi
  800f3e:	56                   	push   %esi
  800f3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f40:	ba 00 00 00 00       	mov    $0x0,%edx
  800f45:	b8 01 00 00 00       	mov    $0x1,%eax
  800f4a:	89 d1                	mov    %edx,%ecx
  800f4c:	89 d3                	mov    %edx,%ebx
  800f4e:	89 d7                	mov    %edx,%edi
  800f50:	89 d6                	mov    %edx,%esi
  800f52:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    

00800f59 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f59:	55                   	push   %ebp
  800f5a:	89 e5                	mov    %esp,%ebp
  800f5c:	57                   	push   %edi
  800f5d:	56                   	push   %esi
  800f5e:	53                   	push   %ebx
  800f5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f62:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f67:	b8 03 00 00 00       	mov    $0x3,%eax
  800f6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f6f:	89 cb                	mov    %ecx,%ebx
  800f71:	89 cf                	mov    %ecx,%edi
  800f73:	89 ce                	mov    %ecx,%esi
  800f75:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f77:	85 c0                	test   %eax,%eax
  800f79:	7e 28                	jle    800fa3 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f86:	00 
  800f87:	c7 44 24 08 c3 2d 80 	movl   $0x802dc3,0x8(%esp)
  800f8e:	00 
  800f8f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f96:	00 
  800f97:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  800f9e:	e8 b5 15 00 00       	call   802558 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800fa3:	83 c4 2c             	add    $0x2c,%esp
  800fa6:	5b                   	pop    %ebx
  800fa7:	5e                   	pop    %esi
  800fa8:	5f                   	pop    %edi
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    

00800fab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	57                   	push   %edi
  800faf:	56                   	push   %esi
  800fb0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb6:	b8 02 00 00 00       	mov    $0x2,%eax
  800fbb:	89 d1                	mov    %edx,%ecx
  800fbd:	89 d3                	mov    %edx,%ebx
  800fbf:	89 d7                	mov    %edx,%edi
  800fc1:	89 d6                	mov    %edx,%esi
  800fc3:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800fc5:	5b                   	pop    %ebx
  800fc6:	5e                   	pop    %esi
  800fc7:	5f                   	pop    %edi
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <sys_yield>:

void
sys_yield(void)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	57                   	push   %edi
  800fce:	56                   	push   %esi
  800fcf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd5:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fda:	89 d1                	mov    %edx,%ecx
  800fdc:	89 d3                	mov    %edx,%ebx
  800fde:	89 d7                	mov    %edx,%edi
  800fe0:	89 d6                	mov    %edx,%esi
  800fe2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fe4:	5b                   	pop    %ebx
  800fe5:	5e                   	pop    %esi
  800fe6:	5f                   	pop    %edi
  800fe7:	5d                   	pop    %ebp
  800fe8:	c3                   	ret    

00800fe9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	57                   	push   %edi
  800fed:	56                   	push   %esi
  800fee:	53                   	push   %ebx
  800fef:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff2:	be 00 00 00 00       	mov    $0x0,%esi
  800ff7:	b8 04 00 00 00       	mov    $0x4,%eax
  800ffc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801002:	8b 55 08             	mov    0x8(%ebp),%edx
  801005:	89 f7                	mov    %esi,%edi
  801007:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801009:	85 c0                	test   %eax,%eax
  80100b:	7e 28                	jle    801035 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801011:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801018:	00 
  801019:	c7 44 24 08 c3 2d 80 	movl   $0x802dc3,0x8(%esp)
  801020:	00 
  801021:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801028:	00 
  801029:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  801030:	e8 23 15 00 00       	call   802558 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801035:	83 c4 2c             	add    $0x2c,%esp
  801038:	5b                   	pop    %ebx
  801039:	5e                   	pop    %esi
  80103a:	5f                   	pop    %edi
  80103b:	5d                   	pop    %ebp
  80103c:	c3                   	ret    

0080103d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	57                   	push   %edi
  801041:	56                   	push   %esi
  801042:	53                   	push   %ebx
  801043:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801046:	b8 05 00 00 00       	mov    $0x5,%eax
  80104b:	8b 75 18             	mov    0x18(%ebp),%esi
  80104e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801051:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801054:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801057:	8b 55 08             	mov    0x8(%ebp),%edx
  80105a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80105c:	85 c0                	test   %eax,%eax
  80105e:	7e 28                	jle    801088 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801060:	89 44 24 10          	mov    %eax,0x10(%esp)
  801064:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80106b:	00 
  80106c:	c7 44 24 08 c3 2d 80 	movl   $0x802dc3,0x8(%esp)
  801073:	00 
  801074:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80107b:	00 
  80107c:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  801083:	e8 d0 14 00 00       	call   802558 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801088:	83 c4 2c             	add    $0x2c,%esp
  80108b:	5b                   	pop    %ebx
  80108c:	5e                   	pop    %esi
  80108d:	5f                   	pop    %edi
  80108e:	5d                   	pop    %ebp
  80108f:	c3                   	ret    

00801090 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	57                   	push   %edi
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801099:	bb 00 00 00 00       	mov    $0x0,%ebx
  80109e:	b8 06 00 00 00       	mov    $0x6,%eax
  8010a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a9:	89 df                	mov    %ebx,%edi
  8010ab:	89 de                	mov    %ebx,%esi
  8010ad:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	7e 28                	jle    8010db <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010b3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8010be:	00 
  8010bf:	c7 44 24 08 c3 2d 80 	movl   $0x802dc3,0x8(%esp)
  8010c6:	00 
  8010c7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010ce:	00 
  8010cf:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  8010d6:	e8 7d 14 00 00       	call   802558 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8010db:	83 c4 2c             	add    $0x2c,%esp
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5f                   	pop    %edi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	57                   	push   %edi
  8010e7:	56                   	push   %esi
  8010e8:	53                   	push   %ebx
  8010e9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f1:	b8 08 00 00 00       	mov    $0x8,%eax
  8010f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010fc:	89 df                	mov    %ebx,%edi
  8010fe:	89 de                	mov    %ebx,%esi
  801100:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801102:	85 c0                	test   %eax,%eax
  801104:	7e 28                	jle    80112e <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801106:	89 44 24 10          	mov    %eax,0x10(%esp)
  80110a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801111:	00 
  801112:	c7 44 24 08 c3 2d 80 	movl   $0x802dc3,0x8(%esp)
  801119:	00 
  80111a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801121:	00 
  801122:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  801129:	e8 2a 14 00 00       	call   802558 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80112e:	83 c4 2c             	add    $0x2c,%esp
  801131:	5b                   	pop    %ebx
  801132:	5e                   	pop    %esi
  801133:	5f                   	pop    %edi
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	57                   	push   %edi
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
  80113c:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801144:	b8 09 00 00 00       	mov    $0x9,%eax
  801149:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114c:	8b 55 08             	mov    0x8(%ebp),%edx
  80114f:	89 df                	mov    %ebx,%edi
  801151:	89 de                	mov    %ebx,%esi
  801153:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801155:	85 c0                	test   %eax,%eax
  801157:	7e 28                	jle    801181 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801159:	89 44 24 10          	mov    %eax,0x10(%esp)
  80115d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  801164:	00 
  801165:	c7 44 24 08 c3 2d 80 	movl   $0x802dc3,0x8(%esp)
  80116c:	00 
  80116d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801174:	00 
  801175:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  80117c:	e8 d7 13 00 00       	call   802558 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801181:	83 c4 2c             	add    $0x2c,%esp
  801184:	5b                   	pop    %ebx
  801185:	5e                   	pop    %esi
  801186:	5f                   	pop    %edi
  801187:	5d                   	pop    %ebp
  801188:	c3                   	ret    

00801189 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	57                   	push   %edi
  80118d:	56                   	push   %esi
  80118e:	53                   	push   %ebx
  80118f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801192:	bb 00 00 00 00       	mov    $0x0,%ebx
  801197:	b8 0a 00 00 00       	mov    $0xa,%eax
  80119c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80119f:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a2:	89 df                	mov    %ebx,%edi
  8011a4:	89 de                	mov    %ebx,%esi
  8011a6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011a8:	85 c0                	test   %eax,%eax
  8011aa:	7e 28                	jle    8011d4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ac:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b0:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  8011b7:	00 
  8011b8:	c7 44 24 08 c3 2d 80 	movl   $0x802dc3,0x8(%esp)
  8011bf:	00 
  8011c0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c7:	00 
  8011c8:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  8011cf:	e8 84 13 00 00       	call   802558 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011d4:	83 c4 2c             	add    $0x2c,%esp
  8011d7:	5b                   	pop    %ebx
  8011d8:	5e                   	pop    %esi
  8011d9:	5f                   	pop    %edi
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
  8011df:	57                   	push   %edi
  8011e0:	56                   	push   %esi
  8011e1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e2:	be 00 00 00 00       	mov    $0x0,%esi
  8011e7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011ec:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8011fa:	5b                   	pop    %ebx
  8011fb:	5e                   	pop    %esi
  8011fc:	5f                   	pop    %edi
  8011fd:	5d                   	pop    %ebp
  8011fe:	c3                   	ret    

008011ff <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8011ff:	55                   	push   %ebp
  801200:	89 e5                	mov    %esp,%ebp
  801202:	57                   	push   %edi
  801203:	56                   	push   %esi
  801204:	53                   	push   %ebx
  801205:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801208:	b9 00 00 00 00       	mov    $0x0,%ecx
  80120d:	b8 0d 00 00 00       	mov    $0xd,%eax
  801212:	8b 55 08             	mov    0x8(%ebp),%edx
  801215:	89 cb                	mov    %ecx,%ebx
  801217:	89 cf                	mov    %ecx,%edi
  801219:	89 ce                	mov    %ecx,%esi
  80121b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80121d:	85 c0                	test   %eax,%eax
  80121f:	7e 28                	jle    801249 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801221:	89 44 24 10          	mov    %eax,0x10(%esp)
  801225:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  80122c:	00 
  80122d:	c7 44 24 08 c3 2d 80 	movl   $0x802dc3,0x8(%esp)
  801234:	00 
  801235:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80123c:	00 
  80123d:	c7 04 24 e0 2d 80 00 	movl   $0x802de0,(%esp)
  801244:	e8 0f 13 00 00       	call   802558 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801249:	83 c4 2c             	add    $0x2c,%esp
  80124c:	5b                   	pop    %ebx
  80124d:	5e                   	pop    %esi
  80124e:	5f                   	pop    %edi
  80124f:	5d                   	pop    %ebp
  801250:	c3                   	ret    

00801251 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	57                   	push   %edi
  801255:	56                   	push   %esi
  801256:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801257:	ba 00 00 00 00       	mov    $0x0,%edx
  80125c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801261:	89 d1                	mov    %edx,%ecx
  801263:	89 d3                	mov    %edx,%ebx
  801265:	89 d7                	mov    %edx,%edi
  801267:	89 d6                	mov    %edx,%esi
  801269:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80126b:	5b                   	pop    %ebx
  80126c:	5e                   	pop    %esi
  80126d:	5f                   	pop    %edi
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    

00801270 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	57                   	push   %edi
  801274:	56                   	push   %esi
  801275:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801276:	bb 00 00 00 00       	mov    $0x0,%ebx
  80127b:	b8 0f 00 00 00       	mov    $0xf,%eax
  801280:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801283:	8b 55 08             	mov    0x8(%ebp),%edx
  801286:	89 df                	mov    %ebx,%edi
  801288:	89 de                	mov    %ebx,%esi
  80128a:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  80128c:	5b                   	pop    %ebx
  80128d:	5e                   	pop    %esi
  80128e:	5f                   	pop    %edi
  80128f:	5d                   	pop    %ebp
  801290:	c3                   	ret    

00801291 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	57                   	push   %edi
  801295:	56                   	push   %esi
  801296:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801297:	bb 00 00 00 00       	mov    $0x0,%ebx
  80129c:	b8 10 00 00 00       	mov    $0x10,%eax
  8012a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a7:	89 df                	mov    %ebx,%edi
  8012a9:	89 de                	mov    %ebx,%esi
  8012ab:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  8012ad:	5b                   	pop    %ebx
  8012ae:	5e                   	pop    %esi
  8012af:	5f                   	pop    %edi
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    
	...

008012b4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ba:	05 00 00 00 30       	add    $0x30000000,%eax
  8012bf:	c1 e8 0c             	shr    $0xc,%eax
}
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    

008012c4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8012ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cd:	89 04 24             	mov    %eax,(%esp)
  8012d0:	e8 df ff ff ff       	call   8012b4 <fd2num>
  8012d5:	c1 e0 0c             	shl    $0xc,%eax
  8012d8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012dd:	c9                   	leave  
  8012de:	c3                   	ret    

008012df <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	53                   	push   %ebx
  8012e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012e6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8012eb:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012ed:	89 c2                	mov    %eax,%edx
  8012ef:	c1 ea 16             	shr    $0x16,%edx
  8012f2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f9:	f6 c2 01             	test   $0x1,%dl
  8012fc:	74 11                	je     80130f <fd_alloc+0x30>
  8012fe:	89 c2                	mov    %eax,%edx
  801300:	c1 ea 0c             	shr    $0xc,%edx
  801303:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80130a:	f6 c2 01             	test   $0x1,%dl
  80130d:	75 09                	jne    801318 <fd_alloc+0x39>
			*fd_store = fd;
  80130f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801311:	b8 00 00 00 00       	mov    $0x0,%eax
  801316:	eb 17                	jmp    80132f <fd_alloc+0x50>
  801318:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80131d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801322:	75 c7                	jne    8012eb <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801324:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80132a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80132f:	5b                   	pop    %ebx
  801330:	5d                   	pop    %ebp
  801331:	c3                   	ret    

00801332 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801338:	83 f8 1f             	cmp    $0x1f,%eax
  80133b:	77 36                	ja     801373 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80133d:	c1 e0 0c             	shl    $0xc,%eax
  801340:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801345:	89 c2                	mov    %eax,%edx
  801347:	c1 ea 16             	shr    $0x16,%edx
  80134a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801351:	f6 c2 01             	test   $0x1,%dl
  801354:	74 24                	je     80137a <fd_lookup+0x48>
  801356:	89 c2                	mov    %eax,%edx
  801358:	c1 ea 0c             	shr    $0xc,%edx
  80135b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801362:	f6 c2 01             	test   $0x1,%dl
  801365:	74 1a                	je     801381 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801367:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136a:	89 02                	mov    %eax,(%edx)
	return 0;
  80136c:	b8 00 00 00 00       	mov    $0x0,%eax
  801371:	eb 13                	jmp    801386 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801373:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801378:	eb 0c                	jmp    801386 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80137a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80137f:	eb 05                	jmp    801386 <fd_lookup+0x54>
  801381:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    

00801388 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	53                   	push   %ebx
  80138c:	83 ec 14             	sub    $0x14,%esp
  80138f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801392:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801395:	ba 00 00 00 00       	mov    $0x0,%edx
  80139a:	eb 0e                	jmp    8013aa <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80139c:	39 08                	cmp    %ecx,(%eax)
  80139e:	75 09                	jne    8013a9 <dev_lookup+0x21>
			*dev = devtab[i];
  8013a0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8013a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a7:	eb 33                	jmp    8013dc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013a9:	42                   	inc    %edx
  8013aa:	8b 04 95 6c 2e 80 00 	mov    0x802e6c(,%edx,4),%eax
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	75 e7                	jne    80139c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013b5:	a1 18 40 80 00       	mov    0x804018,%eax
  8013ba:	8b 40 48             	mov    0x48(%eax),%eax
  8013bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c5:	c7 04 24 f0 2d 80 00 	movl   $0x802df0,(%esp)
  8013cc:	e8 7b f2 ff ff       	call   80064c <cprintf>
	*dev = 0;
  8013d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8013d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013dc:	83 c4 14             	add    $0x14,%esp
  8013df:	5b                   	pop    %ebx
  8013e0:	5d                   	pop    %ebp
  8013e1:	c3                   	ret    

008013e2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	56                   	push   %esi
  8013e6:	53                   	push   %ebx
  8013e7:	83 ec 30             	sub    $0x30,%esp
  8013ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8013ed:	8a 45 0c             	mov    0xc(%ebp),%al
  8013f0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013f3:	89 34 24             	mov    %esi,(%esp)
  8013f6:	e8 b9 fe ff ff       	call   8012b4 <fd2num>
  8013fb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801402:	89 04 24             	mov    %eax,(%esp)
  801405:	e8 28 ff ff ff       	call   801332 <fd_lookup>
  80140a:	89 c3                	mov    %eax,%ebx
  80140c:	85 c0                	test   %eax,%eax
  80140e:	78 05                	js     801415 <fd_close+0x33>
	    || fd != fd2)
  801410:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801413:	74 0d                	je     801422 <fd_close+0x40>
		return (must_exist ? r : 0);
  801415:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  801419:	75 46                	jne    801461 <fd_close+0x7f>
  80141b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801420:	eb 3f                	jmp    801461 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801422:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801425:	89 44 24 04          	mov    %eax,0x4(%esp)
  801429:	8b 06                	mov    (%esi),%eax
  80142b:	89 04 24             	mov    %eax,(%esp)
  80142e:	e8 55 ff ff ff       	call   801388 <dev_lookup>
  801433:	89 c3                	mov    %eax,%ebx
  801435:	85 c0                	test   %eax,%eax
  801437:	78 18                	js     801451 <fd_close+0x6f>
		if (dev->dev_close)
  801439:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143c:	8b 40 10             	mov    0x10(%eax),%eax
  80143f:	85 c0                	test   %eax,%eax
  801441:	74 09                	je     80144c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801443:	89 34 24             	mov    %esi,(%esp)
  801446:	ff d0                	call   *%eax
  801448:	89 c3                	mov    %eax,%ebx
  80144a:	eb 05                	jmp    801451 <fd_close+0x6f>
		else
			r = 0;
  80144c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801451:	89 74 24 04          	mov    %esi,0x4(%esp)
  801455:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80145c:	e8 2f fc ff ff       	call   801090 <sys_page_unmap>
	return r;
}
  801461:	89 d8                	mov    %ebx,%eax
  801463:	83 c4 30             	add    $0x30,%esp
  801466:	5b                   	pop    %ebx
  801467:	5e                   	pop    %esi
  801468:	5d                   	pop    %ebp
  801469:	c3                   	ret    

0080146a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801470:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801473:	89 44 24 04          	mov    %eax,0x4(%esp)
  801477:	8b 45 08             	mov    0x8(%ebp),%eax
  80147a:	89 04 24             	mov    %eax,(%esp)
  80147d:	e8 b0 fe ff ff       	call   801332 <fd_lookup>
  801482:	85 c0                	test   %eax,%eax
  801484:	78 13                	js     801499 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801486:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80148d:	00 
  80148e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801491:	89 04 24             	mov    %eax,(%esp)
  801494:	e8 49 ff ff ff       	call   8013e2 <fd_close>
}
  801499:	c9                   	leave  
  80149a:	c3                   	ret    

0080149b <close_all>:

void
close_all(void)
{
  80149b:	55                   	push   %ebp
  80149c:	89 e5                	mov    %esp,%ebp
  80149e:	53                   	push   %ebx
  80149f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014a7:	89 1c 24             	mov    %ebx,(%esp)
  8014aa:	e8 bb ff ff ff       	call   80146a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014af:	43                   	inc    %ebx
  8014b0:	83 fb 20             	cmp    $0x20,%ebx
  8014b3:	75 f2                	jne    8014a7 <close_all+0xc>
		close(i);
}
  8014b5:	83 c4 14             	add    $0x14,%esp
  8014b8:	5b                   	pop    %ebx
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    

008014bb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	57                   	push   %edi
  8014bf:	56                   	push   %esi
  8014c0:	53                   	push   %ebx
  8014c1:	83 ec 4c             	sub    $0x4c,%esp
  8014c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d1:	89 04 24             	mov    %eax,(%esp)
  8014d4:	e8 59 fe ff ff       	call   801332 <fd_lookup>
  8014d9:	89 c3                	mov    %eax,%ebx
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	0f 88 e3 00 00 00    	js     8015c6 <dup+0x10b>
		return r;
	close(newfdnum);
  8014e3:	89 3c 24             	mov    %edi,(%esp)
  8014e6:	e8 7f ff ff ff       	call   80146a <close>

	newfd = INDEX2FD(newfdnum);
  8014eb:	89 fe                	mov    %edi,%esi
  8014ed:	c1 e6 0c             	shl    $0xc,%esi
  8014f0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8014f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014f9:	89 04 24             	mov    %eax,(%esp)
  8014fc:	e8 c3 fd ff ff       	call   8012c4 <fd2data>
  801501:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801503:	89 34 24             	mov    %esi,(%esp)
  801506:	e8 b9 fd ff ff       	call   8012c4 <fd2data>
  80150b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80150e:	89 d8                	mov    %ebx,%eax
  801510:	c1 e8 16             	shr    $0x16,%eax
  801513:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80151a:	a8 01                	test   $0x1,%al
  80151c:	74 46                	je     801564 <dup+0xa9>
  80151e:	89 d8                	mov    %ebx,%eax
  801520:	c1 e8 0c             	shr    $0xc,%eax
  801523:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80152a:	f6 c2 01             	test   $0x1,%dl
  80152d:	74 35                	je     801564 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80152f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801536:	25 07 0e 00 00       	and    $0xe07,%eax
  80153b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80153f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801542:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801546:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80154d:	00 
  80154e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801552:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801559:	e8 df fa ff ff       	call   80103d <sys_page_map>
  80155e:	89 c3                	mov    %eax,%ebx
  801560:	85 c0                	test   %eax,%eax
  801562:	78 3b                	js     80159f <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801564:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801567:	89 c2                	mov    %eax,%edx
  801569:	c1 ea 0c             	shr    $0xc,%edx
  80156c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801573:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801579:	89 54 24 10          	mov    %edx,0x10(%esp)
  80157d:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801581:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801588:	00 
  801589:	89 44 24 04          	mov    %eax,0x4(%esp)
  80158d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801594:	e8 a4 fa ff ff       	call   80103d <sys_page_map>
  801599:	89 c3                	mov    %eax,%ebx
  80159b:	85 c0                	test   %eax,%eax
  80159d:	79 25                	jns    8015c4 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80159f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015aa:	e8 e1 fa ff ff       	call   801090 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015bd:	e8 ce fa ff ff       	call   801090 <sys_page_unmap>
	return r;
  8015c2:	eb 02                	jmp    8015c6 <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8015c4:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8015c6:	89 d8                	mov    %ebx,%eax
  8015c8:	83 c4 4c             	add    $0x4c,%esp
  8015cb:	5b                   	pop    %ebx
  8015cc:	5e                   	pop    %esi
  8015cd:	5f                   	pop    %edi
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    

008015d0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 24             	sub    $0x24,%esp
  8015d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e1:	89 1c 24             	mov    %ebx,(%esp)
  8015e4:	e8 49 fd ff ff       	call   801332 <fd_lookup>
  8015e9:	85 c0                	test   %eax,%eax
  8015eb:	78 6d                	js     80165a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f7:	8b 00                	mov    (%eax),%eax
  8015f9:	89 04 24             	mov    %eax,(%esp)
  8015fc:	e8 87 fd ff ff       	call   801388 <dev_lookup>
  801601:	85 c0                	test   %eax,%eax
  801603:	78 55                	js     80165a <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801605:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801608:	8b 50 08             	mov    0x8(%eax),%edx
  80160b:	83 e2 03             	and    $0x3,%edx
  80160e:	83 fa 01             	cmp    $0x1,%edx
  801611:	75 23                	jne    801636 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801613:	a1 18 40 80 00       	mov    0x804018,%eax
  801618:	8b 40 48             	mov    0x48(%eax),%eax
  80161b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80161f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801623:	c7 04 24 31 2e 80 00 	movl   $0x802e31,(%esp)
  80162a:	e8 1d f0 ff ff       	call   80064c <cprintf>
		return -E_INVAL;
  80162f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801634:	eb 24                	jmp    80165a <read+0x8a>
	}
	if (!dev->dev_read)
  801636:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801639:	8b 52 08             	mov    0x8(%edx),%edx
  80163c:	85 d2                	test   %edx,%edx
  80163e:	74 15                	je     801655 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801640:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801643:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801647:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80164a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80164e:	89 04 24             	mov    %eax,(%esp)
  801651:	ff d2                	call   *%edx
  801653:	eb 05                	jmp    80165a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801655:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80165a:	83 c4 24             	add    $0x24,%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5d                   	pop    %ebp
  80165f:	c3                   	ret    

00801660 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	57                   	push   %edi
  801664:	56                   	push   %esi
  801665:	53                   	push   %ebx
  801666:	83 ec 1c             	sub    $0x1c,%esp
  801669:	8b 7d 08             	mov    0x8(%ebp),%edi
  80166c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80166f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801674:	eb 23                	jmp    801699 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801676:	89 f0                	mov    %esi,%eax
  801678:	29 d8                	sub    %ebx,%eax
  80167a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80167e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801681:	01 d8                	add    %ebx,%eax
  801683:	89 44 24 04          	mov    %eax,0x4(%esp)
  801687:	89 3c 24             	mov    %edi,(%esp)
  80168a:	e8 41 ff ff ff       	call   8015d0 <read>
		if (m < 0)
  80168f:	85 c0                	test   %eax,%eax
  801691:	78 10                	js     8016a3 <readn+0x43>
			return m;
		if (m == 0)
  801693:	85 c0                	test   %eax,%eax
  801695:	74 0a                	je     8016a1 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801697:	01 c3                	add    %eax,%ebx
  801699:	39 f3                	cmp    %esi,%ebx
  80169b:	72 d9                	jb     801676 <readn+0x16>
  80169d:	89 d8                	mov    %ebx,%eax
  80169f:	eb 02                	jmp    8016a3 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8016a1:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8016a3:	83 c4 1c             	add    $0x1c,%esp
  8016a6:	5b                   	pop    %ebx
  8016a7:	5e                   	pop    %esi
  8016a8:	5f                   	pop    %edi
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	53                   	push   %ebx
  8016af:	83 ec 24             	sub    $0x24,%esp
  8016b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bc:	89 1c 24             	mov    %ebx,(%esp)
  8016bf:	e8 6e fc ff ff       	call   801332 <fd_lookup>
  8016c4:	85 c0                	test   %eax,%eax
  8016c6:	78 68                	js     801730 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d2:	8b 00                	mov    (%eax),%eax
  8016d4:	89 04 24             	mov    %eax,(%esp)
  8016d7:	e8 ac fc ff ff       	call   801388 <dev_lookup>
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	78 50                	js     801730 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e7:	75 23                	jne    80170c <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016e9:	a1 18 40 80 00       	mov    0x804018,%eax
  8016ee:	8b 40 48             	mov    0x48(%eax),%eax
  8016f1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8016f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f9:	c7 04 24 4d 2e 80 00 	movl   $0x802e4d,(%esp)
  801700:	e8 47 ef ff ff       	call   80064c <cprintf>
		return -E_INVAL;
  801705:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80170a:	eb 24                	jmp    801730 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80170c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170f:	8b 52 0c             	mov    0xc(%edx),%edx
  801712:	85 d2                	test   %edx,%edx
  801714:	74 15                	je     80172b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801716:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801719:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80171d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801720:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801724:	89 04 24             	mov    %eax,(%esp)
  801727:	ff d2                	call   *%edx
  801729:	eb 05                	jmp    801730 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80172b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801730:	83 c4 24             	add    $0x24,%esp
  801733:	5b                   	pop    %ebx
  801734:	5d                   	pop    %ebp
  801735:	c3                   	ret    

00801736 <seek>:

int
seek(int fdnum, off_t offset)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80173c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80173f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801743:	8b 45 08             	mov    0x8(%ebp),%eax
  801746:	89 04 24             	mov    %eax,(%esp)
  801749:	e8 e4 fb ff ff       	call   801332 <fd_lookup>
  80174e:	85 c0                	test   %eax,%eax
  801750:	78 0e                	js     801760 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801752:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801755:	8b 55 0c             	mov    0xc(%ebp),%edx
  801758:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80175b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801760:	c9                   	leave  
  801761:	c3                   	ret    

00801762 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	53                   	push   %ebx
  801766:	83 ec 24             	sub    $0x24,%esp
  801769:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80176c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801773:	89 1c 24             	mov    %ebx,(%esp)
  801776:	e8 b7 fb ff ff       	call   801332 <fd_lookup>
  80177b:	85 c0                	test   %eax,%eax
  80177d:	78 61                	js     8017e0 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801782:	89 44 24 04          	mov    %eax,0x4(%esp)
  801786:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801789:	8b 00                	mov    (%eax),%eax
  80178b:	89 04 24             	mov    %eax,(%esp)
  80178e:	e8 f5 fb ff ff       	call   801388 <dev_lookup>
  801793:	85 c0                	test   %eax,%eax
  801795:	78 49                	js     8017e0 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801797:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80179e:	75 23                	jne    8017c3 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017a0:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017a5:	8b 40 48             	mov    0x48(%eax),%eax
  8017a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b0:	c7 04 24 10 2e 80 00 	movl   $0x802e10,(%esp)
  8017b7:	e8 90 ee ff ff       	call   80064c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017c1:	eb 1d                	jmp    8017e0 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8017c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c6:	8b 52 18             	mov    0x18(%edx),%edx
  8017c9:	85 d2                	test   %edx,%edx
  8017cb:	74 0e                	je     8017db <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d0:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017d4:	89 04 24             	mov    %eax,(%esp)
  8017d7:	ff d2                	call   *%edx
  8017d9:	eb 05                	jmp    8017e0 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017db:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8017e0:	83 c4 24             	add    $0x24,%esp
  8017e3:	5b                   	pop    %ebx
  8017e4:	5d                   	pop    %ebp
  8017e5:	c3                   	ret    

008017e6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	53                   	push   %ebx
  8017ea:	83 ec 24             	sub    $0x24,%esp
  8017ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fa:	89 04 24             	mov    %eax,(%esp)
  8017fd:	e8 30 fb ff ff       	call   801332 <fd_lookup>
  801802:	85 c0                	test   %eax,%eax
  801804:	78 52                	js     801858 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801806:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801809:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801810:	8b 00                	mov    (%eax),%eax
  801812:	89 04 24             	mov    %eax,(%esp)
  801815:	e8 6e fb ff ff       	call   801388 <dev_lookup>
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 3a                	js     801858 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80181e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801821:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801825:	74 2c                	je     801853 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801827:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80182a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801831:	00 00 00 
	stat->st_isdir = 0;
  801834:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80183b:	00 00 00 
	stat->st_dev = dev;
  80183e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801844:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801848:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80184b:	89 14 24             	mov    %edx,(%esp)
  80184e:	ff 50 14             	call   *0x14(%eax)
  801851:	eb 05                	jmp    801858 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801853:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801858:	83 c4 24             	add    $0x24,%esp
  80185b:	5b                   	pop    %ebx
  80185c:	5d                   	pop    %ebp
  80185d:	c3                   	ret    

0080185e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	56                   	push   %esi
  801862:	53                   	push   %ebx
  801863:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801866:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80186d:	00 
  80186e:	8b 45 08             	mov    0x8(%ebp),%eax
  801871:	89 04 24             	mov    %eax,(%esp)
  801874:	e8 2a 02 00 00       	call   801aa3 <open>
  801879:	89 c3                	mov    %eax,%ebx
  80187b:	85 c0                	test   %eax,%eax
  80187d:	78 1b                	js     80189a <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  80187f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801882:	89 44 24 04          	mov    %eax,0x4(%esp)
  801886:	89 1c 24             	mov    %ebx,(%esp)
  801889:	e8 58 ff ff ff       	call   8017e6 <fstat>
  80188e:	89 c6                	mov    %eax,%esi
	close(fd);
  801890:	89 1c 24             	mov    %ebx,(%esp)
  801893:	e8 d2 fb ff ff       	call   80146a <close>
	return r;
  801898:	89 f3                	mov    %esi,%ebx
}
  80189a:	89 d8                	mov    %ebx,%eax
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	5b                   	pop    %ebx
  8018a0:	5e                   	pop    %esi
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    
	...

008018a4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	56                   	push   %esi
  8018a8:	53                   	push   %ebx
  8018a9:	83 ec 10             	sub    $0x10,%esp
  8018ac:	89 c3                	mov    %eax,%ebx
  8018ae:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8018b0:	83 3d 10 40 80 00 00 	cmpl   $0x0,0x804010
  8018b7:	75 11                	jne    8018ca <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8018c0:	e8 de 0d 00 00       	call   8026a3 <ipc_find_env>
  8018c5:	a3 10 40 80 00       	mov    %eax,0x804010
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018ca:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018d1:	00 
  8018d2:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8018d9:	00 
  8018da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018de:	a1 10 40 80 00       	mov    0x804010,%eax
  8018e3:	89 04 24             	mov    %eax,(%esp)
  8018e6:	e8 35 0d 00 00       	call   802620 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018f2:	00 
  8018f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018fe:	e8 ad 0c 00 00       	call   8025b0 <ipc_recv>
}
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801910:	8b 45 08             	mov    0x8(%ebp),%eax
  801913:	8b 40 0c             	mov    0xc(%eax),%eax
  801916:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80191b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80191e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801923:	ba 00 00 00 00       	mov    $0x0,%edx
  801928:	b8 02 00 00 00       	mov    $0x2,%eax
  80192d:	e8 72 ff ff ff       	call   8018a4 <fsipc>
}
  801932:	c9                   	leave  
  801933:	c3                   	ret    

00801934 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80193a:	8b 45 08             	mov    0x8(%ebp),%eax
  80193d:	8b 40 0c             	mov    0xc(%eax),%eax
  801940:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801945:	ba 00 00 00 00       	mov    $0x0,%edx
  80194a:	b8 06 00 00 00       	mov    $0x6,%eax
  80194f:	e8 50 ff ff ff       	call   8018a4 <fsipc>
}
  801954:	c9                   	leave  
  801955:	c3                   	ret    

00801956 <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801956:	55                   	push   %ebp
  801957:	89 e5                	mov    %esp,%ebp
  801959:	53                   	push   %ebx
  80195a:	83 ec 14             	sub    $0x14,%esp
  80195d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801960:	8b 45 08             	mov    0x8(%ebp),%eax
  801963:	8b 40 0c             	mov    0xc(%eax),%eax
  801966:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80196b:	ba 00 00 00 00       	mov    $0x0,%edx
  801970:	b8 05 00 00 00       	mov    $0x5,%eax
  801975:	e8 2a ff ff ff       	call   8018a4 <fsipc>
  80197a:	85 c0                	test   %eax,%eax
  80197c:	78 2b                	js     8019a9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80197e:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801985:	00 
  801986:	89 1c 24             	mov    %ebx,(%esp)
  801989:	e8 69 f2 ff ff       	call   800bf7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80198e:	a1 80 50 80 00       	mov    0x805080,%eax
  801993:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801999:	a1 84 50 80 00       	mov    0x805084,%eax
  80199e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8019a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8019a9:	83 c4 14             	add    $0x14,%esp
  8019ac:	5b                   	pop    %ebx
  8019ad:	5d                   	pop    %ebp
  8019ae:	c3                   	ret    

008019af <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	83 ec 18             	sub    $0x18,%esp
  8019b5:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8019bb:	8b 52 0c             	mov    0xc(%edx),%edx
  8019be:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8019c4:	a3 04 50 80 00       	mov    %eax,0x805004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  8019c9:	89 c2                	mov    %eax,%edx
  8019cb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019d0:	76 05                	jbe    8019d7 <devfile_write+0x28>
  8019d2:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  8019d7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8019db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e2:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8019e9:	e8 ec f3 ff ff       	call   800dda <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8019ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f3:	b8 04 00 00 00       	mov    $0x4,%eax
  8019f8:	e8 a7 fe ff ff       	call   8018a4 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  8019fd:	c9                   	leave  
  8019fe:	c3                   	ret    

008019ff <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	56                   	push   %esi
  801a03:	53                   	push   %ebx
  801a04:	83 ec 10             	sub    $0x10,%esp
  801a07:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0d:	8b 40 0c             	mov    0xc(%eax),%eax
  801a10:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a15:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a20:	b8 03 00 00 00       	mov    $0x3,%eax
  801a25:	e8 7a fe ff ff       	call   8018a4 <fsipc>
  801a2a:	89 c3                	mov    %eax,%ebx
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	78 6a                	js     801a9a <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801a30:	39 c6                	cmp    %eax,%esi
  801a32:	73 24                	jae    801a58 <devfile_read+0x59>
  801a34:	c7 44 24 0c 80 2e 80 	movl   $0x802e80,0xc(%esp)
  801a3b:	00 
  801a3c:	c7 44 24 08 87 2e 80 	movl   $0x802e87,0x8(%esp)
  801a43:	00 
  801a44:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801a4b:	00 
  801a4c:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  801a53:	e8 00 0b 00 00       	call   802558 <_panic>
	assert(r <= PGSIZE);
  801a58:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a5d:	7e 24                	jle    801a83 <devfile_read+0x84>
  801a5f:	c7 44 24 0c a7 2e 80 	movl   $0x802ea7,0xc(%esp)
  801a66:	00 
  801a67:	c7 44 24 08 87 2e 80 	movl   $0x802e87,0x8(%esp)
  801a6e:	00 
  801a6f:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801a76:	00 
  801a77:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
  801a7e:	e8 d5 0a 00 00       	call   802558 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a83:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a87:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a8e:	00 
  801a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a92:	89 04 24             	mov    %eax,(%esp)
  801a95:	e8 d6 f2 ff ff       	call   800d70 <memmove>
	return r;
}
  801a9a:	89 d8                	mov    %ebx,%eax
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	5b                   	pop    %ebx
  801aa0:	5e                   	pop    %esi
  801aa1:	5d                   	pop    %ebp
  801aa2:	c3                   	ret    

00801aa3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	56                   	push   %esi
  801aa7:	53                   	push   %ebx
  801aa8:	83 ec 20             	sub    $0x20,%esp
  801aab:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801aae:	89 34 24             	mov    %esi,(%esp)
  801ab1:	e8 0e f1 ff ff       	call   800bc4 <strlen>
  801ab6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801abb:	7f 60                	jg     801b1d <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801abd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac0:	89 04 24             	mov    %eax,(%esp)
  801ac3:	e8 17 f8 ff ff       	call   8012df <fd_alloc>
  801ac8:	89 c3                	mov    %eax,%ebx
  801aca:	85 c0                	test   %eax,%eax
  801acc:	78 54                	js     801b22 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801ace:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ad2:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ad9:	e8 19 f1 ff ff       	call   800bf7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801ae6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ae9:	b8 01 00 00 00       	mov    $0x1,%eax
  801aee:	e8 b1 fd ff ff       	call   8018a4 <fsipc>
  801af3:	89 c3                	mov    %eax,%ebx
  801af5:	85 c0                	test   %eax,%eax
  801af7:	79 15                	jns    801b0e <open+0x6b>
		fd_close(fd, 0);
  801af9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b00:	00 
  801b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b04:	89 04 24             	mov    %eax,(%esp)
  801b07:	e8 d6 f8 ff ff       	call   8013e2 <fd_close>
		return r;
  801b0c:	eb 14                	jmp    801b22 <open+0x7f>
	}

	return fd2num(fd);
  801b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b11:	89 04 24             	mov    %eax,(%esp)
  801b14:	e8 9b f7 ff ff       	call   8012b4 <fd2num>
  801b19:	89 c3                	mov    %eax,%ebx
  801b1b:	eb 05                	jmp    801b22 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b1d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b22:	89 d8                	mov    %ebx,%eax
  801b24:	83 c4 20             	add    $0x20,%esp
  801b27:	5b                   	pop    %ebx
  801b28:	5e                   	pop    %esi
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b31:	ba 00 00 00 00       	mov    $0x0,%edx
  801b36:	b8 08 00 00 00       	mov    $0x8,%eax
  801b3b:	e8 64 fd ff ff       	call   8018a4 <fsipc>
}
  801b40:	c9                   	leave  
  801b41:	c3                   	ret    
	...

00801b44 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801b4a:	c7 44 24 04 b3 2e 80 	movl   $0x802eb3,0x4(%esp)
  801b51:	00 
  801b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b55:	89 04 24             	mov    %eax,(%esp)
  801b58:	e8 9a f0 ff ff       	call   800bf7 <strcpy>
	return 0;
}
  801b5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b62:	c9                   	leave  
  801b63:	c3                   	ret    

00801b64 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	53                   	push   %ebx
  801b68:	83 ec 14             	sub    $0x14,%esp
  801b6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b6e:	89 1c 24             	mov    %ebx,(%esp)
  801b71:	e8 72 0b 00 00       	call   8026e8 <pageref>
  801b76:	83 f8 01             	cmp    $0x1,%eax
  801b79:	75 0d                	jne    801b88 <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801b7b:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b7e:	89 04 24             	mov    %eax,(%esp)
  801b81:	e8 1f 03 00 00       	call   801ea5 <nsipc_close>
  801b86:	eb 05                	jmp    801b8d <devsock_close+0x29>
	else
		return 0;
  801b88:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b8d:	83 c4 14             	add    $0x14,%esp
  801b90:	5b                   	pop    %ebx
  801b91:	5d                   	pop    %ebp
  801b92:	c3                   	ret    

00801b93 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b99:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ba0:	00 
  801ba1:	8b 45 10             	mov    0x10(%ebp),%eax
  801ba4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bab:	89 44 24 04          	mov    %eax,0x4(%esp)
  801baf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb2:	8b 40 0c             	mov    0xc(%eax),%eax
  801bb5:	89 04 24             	mov    %eax,(%esp)
  801bb8:	e8 e3 03 00 00       	call   801fa0 <nsipc_send>
}
  801bbd:	c9                   	leave  
  801bbe:	c3                   	ret    

00801bbf <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801bbf:	55                   	push   %ebp
  801bc0:	89 e5                	mov    %esp,%ebp
  801bc2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801bc5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801bcc:	00 
  801bcd:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bde:	8b 40 0c             	mov    0xc(%eax),%eax
  801be1:	89 04 24             	mov    %eax,(%esp)
  801be4:	e8 37 03 00 00       	call   801f20 <nsipc_recv>
}
  801be9:	c9                   	leave  
  801bea:	c3                   	ret    

00801beb <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	56                   	push   %esi
  801bef:	53                   	push   %ebx
  801bf0:	83 ec 20             	sub    $0x20,%esp
  801bf3:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bf5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf8:	89 04 24             	mov    %eax,(%esp)
  801bfb:	e8 df f6 ff ff       	call   8012df <fd_alloc>
  801c00:	89 c3                	mov    %eax,%ebx
  801c02:	85 c0                	test   %eax,%eax
  801c04:	78 21                	js     801c27 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c06:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c0d:	00 
  801c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c11:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c1c:	e8 c8 f3 ff ff       	call   800fe9 <sys_page_alloc>
  801c21:	89 c3                	mov    %eax,%ebx
  801c23:	85 c0                	test   %eax,%eax
  801c25:	79 0a                	jns    801c31 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801c27:	89 34 24             	mov    %esi,(%esp)
  801c2a:	e8 76 02 00 00       	call   801ea5 <nsipc_close>
		return r;
  801c2f:	eb 22                	jmp    801c53 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c31:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c3f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c46:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c49:	89 04 24             	mov    %eax,(%esp)
  801c4c:	e8 63 f6 ff ff       	call   8012b4 <fd2num>
  801c51:	89 c3                	mov    %eax,%ebx
}
  801c53:	89 d8                	mov    %ebx,%eax
  801c55:	83 c4 20             	add    $0x20,%esp
  801c58:	5b                   	pop    %ebx
  801c59:	5e                   	pop    %esi
  801c5a:	5d                   	pop    %ebp
  801c5b:	c3                   	ret    

00801c5c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c62:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c65:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c69:	89 04 24             	mov    %eax,(%esp)
  801c6c:	e8 c1 f6 ff ff       	call   801332 <fd_lookup>
  801c71:	85 c0                	test   %eax,%eax
  801c73:	78 17                	js     801c8c <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c78:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c7e:	39 10                	cmp    %edx,(%eax)
  801c80:	75 05                	jne    801c87 <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c82:	8b 40 0c             	mov    0xc(%eax),%eax
  801c85:	eb 05                	jmp    801c8c <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c87:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    

00801c8e <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c94:	8b 45 08             	mov    0x8(%ebp),%eax
  801c97:	e8 c0 ff ff ff       	call   801c5c <fd2sockid>
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	78 1f                	js     801cbf <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ca0:	8b 55 10             	mov    0x10(%ebp),%edx
  801ca3:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ca7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801caa:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cae:	89 04 24             	mov    %eax,(%esp)
  801cb1:	e8 38 01 00 00       	call   801dee <nsipc_accept>
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	78 05                	js     801cbf <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801cba:	e8 2c ff ff ff       	call   801beb <alloc_sockfd>
}
  801cbf:	c9                   	leave  
  801cc0:	c3                   	ret    

00801cc1 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cca:	e8 8d ff ff ff       	call   801c5c <fd2sockid>
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	78 16                	js     801ce9 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801cd3:	8b 55 10             	mov    0x10(%ebp),%edx
  801cd6:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cda:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cdd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ce1:	89 04 24             	mov    %eax,(%esp)
  801ce4:	e8 5b 01 00 00       	call   801e44 <nsipc_bind>
}
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    

00801ceb <shutdown>:

int
shutdown(int s, int how)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf4:	e8 63 ff ff ff       	call   801c5c <fd2sockid>
  801cf9:	85 c0                	test   %eax,%eax
  801cfb:	78 0f                	js     801d0c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801cfd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d00:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d04:	89 04 24             	mov    %eax,(%esp)
  801d07:	e8 77 01 00 00       	call   801e83 <nsipc_shutdown>
}
  801d0c:	c9                   	leave  
  801d0d:	c3                   	ret    

00801d0e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d14:	8b 45 08             	mov    0x8(%ebp),%eax
  801d17:	e8 40 ff ff ff       	call   801c5c <fd2sockid>
  801d1c:	85 c0                	test   %eax,%eax
  801d1e:	78 16                	js     801d36 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801d20:	8b 55 10             	mov    0x10(%ebp),%edx
  801d23:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d27:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d2a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d2e:	89 04 24             	mov    %eax,(%esp)
  801d31:	e8 89 01 00 00       	call   801ebf <nsipc_connect>
}
  801d36:	c9                   	leave  
  801d37:	c3                   	ret    

00801d38 <listen>:

int
listen(int s, int backlog)
{
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d41:	e8 16 ff ff ff       	call   801c5c <fd2sockid>
  801d46:	85 c0                	test   %eax,%eax
  801d48:	78 0f                	js     801d59 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d4d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d51:	89 04 24             	mov    %eax,(%esp)
  801d54:	e8 a5 01 00 00       	call   801efe <nsipc_listen>
}
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d61:	8b 45 10             	mov    0x10(%ebp),%eax
  801d64:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d72:	89 04 24             	mov    %eax,(%esp)
  801d75:	e8 99 02 00 00       	call   802013 <nsipc_socket>
  801d7a:	85 c0                	test   %eax,%eax
  801d7c:	78 05                	js     801d83 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801d7e:	e8 68 fe ff ff       	call   801beb <alloc_sockfd>
}
  801d83:	c9                   	leave  
  801d84:	c3                   	ret    
  801d85:	00 00                	add    %al,(%eax)
	...

00801d88 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	53                   	push   %ebx
  801d8c:	83 ec 14             	sub    $0x14,%esp
  801d8f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d91:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  801d98:	75 11                	jne    801dab <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d9a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801da1:	e8 fd 08 00 00       	call   8026a3 <ipc_find_env>
  801da6:	a3 14 40 80 00       	mov    %eax,0x804014
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801dab:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801db2:	00 
  801db3:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801dba:	00 
  801dbb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801dbf:	a1 14 40 80 00       	mov    0x804014,%eax
  801dc4:	89 04 24             	mov    %eax,(%esp)
  801dc7:	e8 54 08 00 00       	call   802620 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801dcc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dd3:	00 
  801dd4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ddb:	00 
  801ddc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801de3:	e8 c8 07 00 00       	call   8025b0 <ipc_recv>
}
  801de8:	83 c4 14             	add    $0x14,%esp
  801deb:	5b                   	pop    %ebx
  801dec:	5d                   	pop    %ebp
  801ded:	c3                   	ret    

00801dee <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	56                   	push   %esi
  801df2:	53                   	push   %ebx
  801df3:	83 ec 10             	sub    $0x10,%esp
  801df6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801df9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e01:	8b 06                	mov    (%esi),%eax
  801e03:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e08:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0d:	e8 76 ff ff ff       	call   801d88 <nsipc>
  801e12:	89 c3                	mov    %eax,%ebx
  801e14:	85 c0                	test   %eax,%eax
  801e16:	78 23                	js     801e3b <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e18:	a1 10 60 80 00       	mov    0x806010,%eax
  801e1d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e21:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e28:	00 
  801e29:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2c:	89 04 24             	mov    %eax,(%esp)
  801e2f:	e8 3c ef ff ff       	call   800d70 <memmove>
		*addrlen = ret->ret_addrlen;
  801e34:	a1 10 60 80 00       	mov    0x806010,%eax
  801e39:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  801e3b:	89 d8                	mov    %ebx,%eax
  801e3d:	83 c4 10             	add    $0x10,%esp
  801e40:	5b                   	pop    %ebx
  801e41:	5e                   	pop    %esi
  801e42:	5d                   	pop    %ebp
  801e43:	c3                   	ret    

00801e44 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	53                   	push   %ebx
  801e48:	83 ec 14             	sub    $0x14,%esp
  801e4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e51:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e56:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e61:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801e68:	e8 03 ef ff ff       	call   800d70 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e6d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e73:	b8 02 00 00 00       	mov    $0x2,%eax
  801e78:	e8 0b ff ff ff       	call   801d88 <nsipc>
}
  801e7d:	83 c4 14             	add    $0x14,%esp
  801e80:	5b                   	pop    %ebx
  801e81:	5d                   	pop    %ebp
  801e82:	c3                   	ret    

00801e83 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e83:	55                   	push   %ebp
  801e84:	89 e5                	mov    %esp,%ebp
  801e86:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e89:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e91:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e94:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e99:	b8 03 00 00 00       	mov    $0x3,%eax
  801e9e:	e8 e5 fe ff ff       	call   801d88 <nsipc>
}
  801ea3:	c9                   	leave  
  801ea4:	c3                   	ret    

00801ea5 <nsipc_close>:

int
nsipc_close(int s)
{
  801ea5:	55                   	push   %ebp
  801ea6:	89 e5                	mov    %esp,%ebp
  801ea8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801eab:	8b 45 08             	mov    0x8(%ebp),%eax
  801eae:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801eb3:	b8 04 00 00 00       	mov    $0x4,%eax
  801eb8:	e8 cb fe ff ff       	call   801d88 <nsipc>
}
  801ebd:	c9                   	leave  
  801ebe:	c3                   	ret    

00801ebf <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	53                   	push   %ebx
  801ec3:	83 ec 14             	sub    $0x14,%esp
  801ec6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ec9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ed1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ed8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801edc:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801ee3:	e8 88 ee ff ff       	call   800d70 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ee8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801eee:	b8 05 00 00 00       	mov    $0x5,%eax
  801ef3:	e8 90 fe ff ff       	call   801d88 <nsipc>
}
  801ef8:	83 c4 14             	add    $0x14,%esp
  801efb:	5b                   	pop    %ebx
  801efc:	5d                   	pop    %ebp
  801efd:	c3                   	ret    

00801efe <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801efe:	55                   	push   %ebp
  801eff:	89 e5                	mov    %esp,%ebp
  801f01:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f04:	8b 45 08             	mov    0x8(%ebp),%eax
  801f07:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f14:	b8 06 00 00 00       	mov    $0x6,%eax
  801f19:	e8 6a fe ff ff       	call   801d88 <nsipc>
}
  801f1e:	c9                   	leave  
  801f1f:	c3                   	ret    

00801f20 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	56                   	push   %esi
  801f24:	53                   	push   %ebx
  801f25:	83 ec 10             	sub    $0x10,%esp
  801f28:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f33:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f39:	8b 45 14             	mov    0x14(%ebp),%eax
  801f3c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f41:	b8 07 00 00 00       	mov    $0x7,%eax
  801f46:	e8 3d fe ff ff       	call   801d88 <nsipc>
  801f4b:	89 c3                	mov    %eax,%ebx
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	78 46                	js     801f97 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801f51:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f56:	7f 04                	jg     801f5c <nsipc_recv+0x3c>
  801f58:	39 c6                	cmp    %eax,%esi
  801f5a:	7d 24                	jge    801f80 <nsipc_recv+0x60>
  801f5c:	c7 44 24 0c bf 2e 80 	movl   $0x802ebf,0xc(%esp)
  801f63:	00 
  801f64:	c7 44 24 08 87 2e 80 	movl   $0x802e87,0x8(%esp)
  801f6b:	00 
  801f6c:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  801f73:	00 
  801f74:	c7 04 24 d4 2e 80 00 	movl   $0x802ed4,(%esp)
  801f7b:	e8 d8 05 00 00       	call   802558 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f80:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f84:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f8b:	00 
  801f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8f:	89 04 24             	mov    %eax,(%esp)
  801f92:	e8 d9 ed ff ff       	call   800d70 <memmove>
	}

	return r;
}
  801f97:	89 d8                	mov    %ebx,%eax
  801f99:	83 c4 10             	add    $0x10,%esp
  801f9c:	5b                   	pop    %ebx
  801f9d:	5e                   	pop    %esi
  801f9e:	5d                   	pop    %ebp
  801f9f:	c3                   	ret    

00801fa0 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 14             	sub    $0x14,%esp
  801fa7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801faa:	8b 45 08             	mov    0x8(%ebp),%eax
  801fad:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801fb2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801fb8:	7e 24                	jle    801fde <nsipc_send+0x3e>
  801fba:	c7 44 24 0c e0 2e 80 	movl   $0x802ee0,0xc(%esp)
  801fc1:	00 
  801fc2:	c7 44 24 08 87 2e 80 	movl   $0x802e87,0x8(%esp)
  801fc9:	00 
  801fca:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  801fd1:	00 
  801fd2:	c7 04 24 d4 2e 80 00 	movl   $0x802ed4,(%esp)
  801fd9:	e8 7a 05 00 00       	call   802558 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fe2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fe9:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801ff0:	e8 7b ed ff ff       	call   800d70 <memmove>
	nsipcbuf.send.req_size = size;
  801ff5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ffb:	8b 45 14             	mov    0x14(%ebp),%eax
  801ffe:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802003:	b8 08 00 00 00       	mov    $0x8,%eax
  802008:	e8 7b fd ff ff       	call   801d88 <nsipc>
}
  80200d:	83 c4 14             	add    $0x14,%esp
  802010:	5b                   	pop    %ebx
  802011:	5d                   	pop    %ebp
  802012:	c3                   	ret    

00802013 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  802013:	55                   	push   %ebp
  802014:	89 e5                	mov    %esp,%ebp
  802016:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802019:	8b 45 08             	mov    0x8(%ebp),%eax
  80201c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802021:	8b 45 0c             	mov    0xc(%ebp),%eax
  802024:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802029:	8b 45 10             	mov    0x10(%ebp),%eax
  80202c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802031:	b8 09 00 00 00       	mov    $0x9,%eax
  802036:	e8 4d fd ff ff       	call   801d88 <nsipc>
}
  80203b:	c9                   	leave  
  80203c:	c3                   	ret    
  80203d:	00 00                	add    %al,(%eax)
	...

00802040 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	56                   	push   %esi
  802044:	53                   	push   %ebx
  802045:	83 ec 10             	sub    $0x10,%esp
  802048:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80204b:	8b 45 08             	mov    0x8(%ebp),%eax
  80204e:	89 04 24             	mov    %eax,(%esp)
  802051:	e8 6e f2 ff ff       	call   8012c4 <fd2data>
  802056:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802058:	c7 44 24 04 ec 2e 80 	movl   $0x802eec,0x4(%esp)
  80205f:	00 
  802060:	89 34 24             	mov    %esi,(%esp)
  802063:	e8 8f eb ff ff       	call   800bf7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802068:	8b 43 04             	mov    0x4(%ebx),%eax
  80206b:	2b 03                	sub    (%ebx),%eax
  80206d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802073:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80207a:	00 00 00 
	stat->st_dev = &devpipe;
  80207d:	c7 86 88 00 00 00 3c 	movl   $0x80303c,0x88(%esi)
  802084:	30 80 00 
	return 0;
}
  802087:	b8 00 00 00 00       	mov    $0x0,%eax
  80208c:	83 c4 10             	add    $0x10,%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5d                   	pop    %ebp
  802092:	c3                   	ret    

00802093 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802093:	55                   	push   %ebp
  802094:	89 e5                	mov    %esp,%ebp
  802096:	53                   	push   %ebx
  802097:	83 ec 14             	sub    $0x14,%esp
  80209a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80209d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a8:	e8 e3 ef ff ff       	call   801090 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8020ad:	89 1c 24             	mov    %ebx,(%esp)
  8020b0:	e8 0f f2 ff ff       	call   8012c4 <fd2data>
  8020b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020c0:	e8 cb ef ff ff       	call   801090 <sys_page_unmap>
}
  8020c5:	83 c4 14             	add    $0x14,%esp
  8020c8:	5b                   	pop    %ebx
  8020c9:	5d                   	pop    %ebp
  8020ca:	c3                   	ret    

008020cb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020cb:	55                   	push   %ebp
  8020cc:	89 e5                	mov    %esp,%ebp
  8020ce:	57                   	push   %edi
  8020cf:	56                   	push   %esi
  8020d0:	53                   	push   %ebx
  8020d1:	83 ec 2c             	sub    $0x2c,%esp
  8020d4:	89 c7                	mov    %eax,%edi
  8020d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020d9:	a1 18 40 80 00       	mov    0x804018,%eax
  8020de:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8020e1:	89 3c 24             	mov    %edi,(%esp)
  8020e4:	e8 ff 05 00 00       	call   8026e8 <pageref>
  8020e9:	89 c6                	mov    %eax,%esi
  8020eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020ee:	89 04 24             	mov    %eax,(%esp)
  8020f1:	e8 f2 05 00 00       	call   8026e8 <pageref>
  8020f6:	39 c6                	cmp    %eax,%esi
  8020f8:	0f 94 c0             	sete   %al
  8020fb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8020fe:	8b 15 18 40 80 00    	mov    0x804018,%edx
  802104:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802107:	39 cb                	cmp    %ecx,%ebx
  802109:	75 08                	jne    802113 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80210b:	83 c4 2c             	add    $0x2c,%esp
  80210e:	5b                   	pop    %ebx
  80210f:	5e                   	pop    %esi
  802110:	5f                   	pop    %edi
  802111:	5d                   	pop    %ebp
  802112:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802113:	83 f8 01             	cmp    $0x1,%eax
  802116:	75 c1                	jne    8020d9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802118:	8b 42 58             	mov    0x58(%edx),%eax
  80211b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802122:	00 
  802123:	89 44 24 08          	mov    %eax,0x8(%esp)
  802127:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80212b:	c7 04 24 f3 2e 80 00 	movl   $0x802ef3,(%esp)
  802132:	e8 15 e5 ff ff       	call   80064c <cprintf>
  802137:	eb a0                	jmp    8020d9 <_pipeisclosed+0xe>

00802139 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802139:	55                   	push   %ebp
  80213a:	89 e5                	mov    %esp,%ebp
  80213c:	57                   	push   %edi
  80213d:	56                   	push   %esi
  80213e:	53                   	push   %ebx
  80213f:	83 ec 1c             	sub    $0x1c,%esp
  802142:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802145:	89 34 24             	mov    %esi,(%esp)
  802148:	e8 77 f1 ff ff       	call   8012c4 <fd2data>
  80214d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80214f:	bf 00 00 00 00       	mov    $0x0,%edi
  802154:	eb 3c                	jmp    802192 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802156:	89 da                	mov    %ebx,%edx
  802158:	89 f0                	mov    %esi,%eax
  80215a:	e8 6c ff ff ff       	call   8020cb <_pipeisclosed>
  80215f:	85 c0                	test   %eax,%eax
  802161:	75 38                	jne    80219b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802163:	e8 62 ee ff ff       	call   800fca <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802168:	8b 43 04             	mov    0x4(%ebx),%eax
  80216b:	8b 13                	mov    (%ebx),%edx
  80216d:	83 c2 20             	add    $0x20,%edx
  802170:	39 d0                	cmp    %edx,%eax
  802172:	73 e2                	jae    802156 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802174:	8b 55 0c             	mov    0xc(%ebp),%edx
  802177:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80217a:	89 c2                	mov    %eax,%edx
  80217c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802182:	79 05                	jns    802189 <devpipe_write+0x50>
  802184:	4a                   	dec    %edx
  802185:	83 ca e0             	or     $0xffffffe0,%edx
  802188:	42                   	inc    %edx
  802189:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80218d:	40                   	inc    %eax
  80218e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802191:	47                   	inc    %edi
  802192:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802195:	75 d1                	jne    802168 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802197:	89 f8                	mov    %edi,%eax
  802199:	eb 05                	jmp    8021a0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80219b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8021a0:	83 c4 1c             	add    $0x1c,%esp
  8021a3:	5b                   	pop    %ebx
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    

008021a8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021a8:	55                   	push   %ebp
  8021a9:	89 e5                	mov    %esp,%ebp
  8021ab:	57                   	push   %edi
  8021ac:	56                   	push   %esi
  8021ad:	53                   	push   %ebx
  8021ae:	83 ec 1c             	sub    $0x1c,%esp
  8021b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021b4:	89 3c 24             	mov    %edi,(%esp)
  8021b7:	e8 08 f1 ff ff       	call   8012c4 <fd2data>
  8021bc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021be:	be 00 00 00 00       	mov    $0x0,%esi
  8021c3:	eb 3a                	jmp    8021ff <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021c5:	85 f6                	test   %esi,%esi
  8021c7:	74 04                	je     8021cd <devpipe_read+0x25>
				return i;
  8021c9:	89 f0                	mov    %esi,%eax
  8021cb:	eb 40                	jmp    80220d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021cd:	89 da                	mov    %ebx,%edx
  8021cf:	89 f8                	mov    %edi,%eax
  8021d1:	e8 f5 fe ff ff       	call   8020cb <_pipeisclosed>
  8021d6:	85 c0                	test   %eax,%eax
  8021d8:	75 2e                	jne    802208 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021da:	e8 eb ed ff ff       	call   800fca <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021df:	8b 03                	mov    (%ebx),%eax
  8021e1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8021e4:	74 df                	je     8021c5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021e6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8021eb:	79 05                	jns    8021f2 <devpipe_read+0x4a>
  8021ed:	48                   	dec    %eax
  8021ee:	83 c8 e0             	or     $0xffffffe0,%eax
  8021f1:	40                   	inc    %eax
  8021f2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8021f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8021fc:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021fe:	46                   	inc    %esi
  8021ff:	3b 75 10             	cmp    0x10(%ebp),%esi
  802202:	75 db                	jne    8021df <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802204:	89 f0                	mov    %esi,%eax
  802206:	eb 05                	jmp    80220d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802208:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80220d:	83 c4 1c             	add    $0x1c,%esp
  802210:	5b                   	pop    %ebx
  802211:	5e                   	pop    %esi
  802212:	5f                   	pop    %edi
  802213:	5d                   	pop    %ebp
  802214:	c3                   	ret    

00802215 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	57                   	push   %edi
  802219:	56                   	push   %esi
  80221a:	53                   	push   %ebx
  80221b:	83 ec 3c             	sub    $0x3c,%esp
  80221e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802221:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802224:	89 04 24             	mov    %eax,(%esp)
  802227:	e8 b3 f0 ff ff       	call   8012df <fd_alloc>
  80222c:	89 c3                	mov    %eax,%ebx
  80222e:	85 c0                	test   %eax,%eax
  802230:	0f 88 45 01 00 00    	js     80237b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802236:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80223d:	00 
  80223e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802241:	89 44 24 04          	mov    %eax,0x4(%esp)
  802245:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80224c:	e8 98 ed ff ff       	call   800fe9 <sys_page_alloc>
  802251:	89 c3                	mov    %eax,%ebx
  802253:	85 c0                	test   %eax,%eax
  802255:	0f 88 20 01 00 00    	js     80237b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80225b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80225e:	89 04 24             	mov    %eax,(%esp)
  802261:	e8 79 f0 ff ff       	call   8012df <fd_alloc>
  802266:	89 c3                	mov    %eax,%ebx
  802268:	85 c0                	test   %eax,%eax
  80226a:	0f 88 f8 00 00 00    	js     802368 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802270:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802277:	00 
  802278:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80227b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80227f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802286:	e8 5e ed ff ff       	call   800fe9 <sys_page_alloc>
  80228b:	89 c3                	mov    %eax,%ebx
  80228d:	85 c0                	test   %eax,%eax
  80228f:	0f 88 d3 00 00 00    	js     802368 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802295:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802298:	89 04 24             	mov    %eax,(%esp)
  80229b:	e8 24 f0 ff ff       	call   8012c4 <fd2data>
  8022a0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022a2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022a9:	00 
  8022aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022b5:	e8 2f ed ff ff       	call   800fe9 <sys_page_alloc>
  8022ba:	89 c3                	mov    %eax,%ebx
  8022bc:	85 c0                	test   %eax,%eax
  8022be:	0f 88 91 00 00 00    	js     802355 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8022c7:	89 04 24             	mov    %eax,(%esp)
  8022ca:	e8 f5 ef ff ff       	call   8012c4 <fd2data>
  8022cf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8022d6:	00 
  8022d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022e2:	00 
  8022e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022ee:	e8 4a ed ff ff       	call   80103d <sys_page_map>
  8022f3:	89 c3                	mov    %eax,%ebx
  8022f5:	85 c0                	test   %eax,%eax
  8022f7:	78 4c                	js     802345 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8022f9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802302:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802304:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802307:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80230e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802314:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802317:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802319:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80231c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802323:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802326:	89 04 24             	mov    %eax,(%esp)
  802329:	e8 86 ef ff ff       	call   8012b4 <fd2num>
  80232e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802330:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802333:	89 04 24             	mov    %eax,(%esp)
  802336:	e8 79 ef ff ff       	call   8012b4 <fd2num>
  80233b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80233e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802343:	eb 36                	jmp    80237b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802345:	89 74 24 04          	mov    %esi,0x4(%esp)
  802349:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802350:	e8 3b ed ff ff       	call   801090 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802355:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802358:	89 44 24 04          	mov    %eax,0x4(%esp)
  80235c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802363:	e8 28 ed ff ff       	call   801090 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802368:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80236b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80236f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802376:	e8 15 ed ff ff       	call   801090 <sys_page_unmap>
    err:
	return r;
}
  80237b:	89 d8                	mov    %ebx,%eax
  80237d:	83 c4 3c             	add    $0x3c,%esp
  802380:	5b                   	pop    %ebx
  802381:	5e                   	pop    %esi
  802382:	5f                   	pop    %edi
  802383:	5d                   	pop    %ebp
  802384:	c3                   	ret    

00802385 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802385:	55                   	push   %ebp
  802386:	89 e5                	mov    %esp,%ebp
  802388:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80238b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80238e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802392:	8b 45 08             	mov    0x8(%ebp),%eax
  802395:	89 04 24             	mov    %eax,(%esp)
  802398:	e8 95 ef ff ff       	call   801332 <fd_lookup>
  80239d:	85 c0                	test   %eax,%eax
  80239f:	78 15                	js     8023b6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8023a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023a4:	89 04 24             	mov    %eax,(%esp)
  8023a7:	e8 18 ef ff ff       	call   8012c4 <fd2data>
	return _pipeisclosed(fd, p);
  8023ac:	89 c2                	mov    %eax,%edx
  8023ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b1:	e8 15 fd ff ff       	call   8020cb <_pipeisclosed>
}
  8023b6:	c9                   	leave  
  8023b7:	c3                   	ret    

008023b8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8023b8:	55                   	push   %ebp
  8023b9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8023bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8023c0:	5d                   	pop    %ebp
  8023c1:	c3                   	ret    

008023c2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8023c2:	55                   	push   %ebp
  8023c3:	89 e5                	mov    %esp,%ebp
  8023c5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8023c8:	c7 44 24 04 0b 2f 80 	movl   $0x802f0b,0x4(%esp)
  8023cf:	00 
  8023d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023d3:	89 04 24             	mov    %eax,(%esp)
  8023d6:	e8 1c e8 ff ff       	call   800bf7 <strcpy>
	return 0;
}
  8023db:	b8 00 00 00 00       	mov    $0x0,%eax
  8023e0:	c9                   	leave  
  8023e1:	c3                   	ret    

008023e2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023e2:	55                   	push   %ebp
  8023e3:	89 e5                	mov    %esp,%ebp
  8023e5:	57                   	push   %edi
  8023e6:	56                   	push   %esi
  8023e7:	53                   	push   %ebx
  8023e8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023ee:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023f3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023f9:	eb 30                	jmp    80242b <devcons_write+0x49>
		m = n - tot;
  8023fb:	8b 75 10             	mov    0x10(%ebp),%esi
  8023fe:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802400:	83 fe 7f             	cmp    $0x7f,%esi
  802403:	76 05                	jbe    80240a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802405:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80240a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80240e:	03 45 0c             	add    0xc(%ebp),%eax
  802411:	89 44 24 04          	mov    %eax,0x4(%esp)
  802415:	89 3c 24             	mov    %edi,(%esp)
  802418:	e8 53 e9 ff ff       	call   800d70 <memmove>
		sys_cputs(buf, m);
  80241d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802421:	89 3c 24             	mov    %edi,(%esp)
  802424:	e8 f3 ea ff ff       	call   800f1c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802429:	01 f3                	add    %esi,%ebx
  80242b:	89 d8                	mov    %ebx,%eax
  80242d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802430:	72 c9                	jb     8023fb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802432:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802438:	5b                   	pop    %ebx
  802439:	5e                   	pop    %esi
  80243a:	5f                   	pop    %edi
  80243b:	5d                   	pop    %ebp
  80243c:	c3                   	ret    

0080243d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80243d:	55                   	push   %ebp
  80243e:	89 e5                	mov    %esp,%ebp
  802440:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802443:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802447:	75 07                	jne    802450 <devcons_read+0x13>
  802449:	eb 25                	jmp    802470 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80244b:	e8 7a eb ff ff       	call   800fca <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802450:	e8 e5 ea ff ff       	call   800f3a <sys_cgetc>
  802455:	85 c0                	test   %eax,%eax
  802457:	74 f2                	je     80244b <devcons_read+0xe>
  802459:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80245b:	85 c0                	test   %eax,%eax
  80245d:	78 1d                	js     80247c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80245f:	83 f8 04             	cmp    $0x4,%eax
  802462:	74 13                	je     802477 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802464:	8b 45 0c             	mov    0xc(%ebp),%eax
  802467:	88 10                	mov    %dl,(%eax)
	return 1;
  802469:	b8 01 00 00 00       	mov    $0x1,%eax
  80246e:	eb 0c                	jmp    80247c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802470:	b8 00 00 00 00       	mov    $0x0,%eax
  802475:	eb 05                	jmp    80247c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802477:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80247c:	c9                   	leave  
  80247d:	c3                   	ret    

0080247e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80247e:	55                   	push   %ebp
  80247f:	89 e5                	mov    %esp,%ebp
  802481:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802484:	8b 45 08             	mov    0x8(%ebp),%eax
  802487:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80248a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802491:	00 
  802492:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802495:	89 04 24             	mov    %eax,(%esp)
  802498:	e8 7f ea ff ff       	call   800f1c <sys_cputs>
}
  80249d:	c9                   	leave  
  80249e:	c3                   	ret    

0080249f <getchar>:

int
getchar(void)
{
  80249f:	55                   	push   %ebp
  8024a0:	89 e5                	mov    %esp,%ebp
  8024a2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8024a5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8024ac:	00 
  8024ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8024b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024bb:	e8 10 f1 ff ff       	call   8015d0 <read>
	if (r < 0)
  8024c0:	85 c0                	test   %eax,%eax
  8024c2:	78 0f                	js     8024d3 <getchar+0x34>
		return r;
	if (r < 1)
  8024c4:	85 c0                	test   %eax,%eax
  8024c6:	7e 06                	jle    8024ce <getchar+0x2f>
		return -E_EOF;
	return c;
  8024c8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8024cc:	eb 05                	jmp    8024d3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8024ce:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8024d3:	c9                   	leave  
  8024d4:	c3                   	ret    

008024d5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8024d5:	55                   	push   %ebp
  8024d6:	89 e5                	mov    %esp,%ebp
  8024d8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8024db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e5:	89 04 24             	mov    %eax,(%esp)
  8024e8:	e8 45 ee ff ff       	call   801332 <fd_lookup>
  8024ed:	85 c0                	test   %eax,%eax
  8024ef:	78 11                	js     802502 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8024f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024f4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024fa:	39 10                	cmp    %edx,(%eax)
  8024fc:	0f 94 c0             	sete   %al
  8024ff:	0f b6 c0             	movzbl %al,%eax
}
  802502:	c9                   	leave  
  802503:	c3                   	ret    

00802504 <opencons>:

int
opencons(void)
{
  802504:	55                   	push   %ebp
  802505:	89 e5                	mov    %esp,%ebp
  802507:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80250a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80250d:	89 04 24             	mov    %eax,(%esp)
  802510:	e8 ca ed ff ff       	call   8012df <fd_alloc>
  802515:	85 c0                	test   %eax,%eax
  802517:	78 3c                	js     802555 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802519:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802520:	00 
  802521:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802524:	89 44 24 04          	mov    %eax,0x4(%esp)
  802528:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80252f:	e8 b5 ea ff ff       	call   800fe9 <sys_page_alloc>
  802534:	85 c0                	test   %eax,%eax
  802536:	78 1d                	js     802555 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802538:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80253e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802541:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802543:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802546:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80254d:	89 04 24             	mov    %eax,(%esp)
  802550:	e8 5f ed ff ff       	call   8012b4 <fd2num>
}
  802555:	c9                   	leave  
  802556:	c3                   	ret    
	...

00802558 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802558:	55                   	push   %ebp
  802559:	89 e5                	mov    %esp,%ebp
  80255b:	56                   	push   %esi
  80255c:	53                   	push   %ebx
  80255d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  802560:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802563:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802569:	e8 3d ea ff ff       	call   800fab <sys_getenvid>
  80256e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802571:	89 54 24 10          	mov    %edx,0x10(%esp)
  802575:	8b 55 08             	mov    0x8(%ebp),%edx
  802578:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80257c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802580:	89 44 24 04          	mov    %eax,0x4(%esp)
  802584:	c7 04 24 18 2f 80 00 	movl   $0x802f18,(%esp)
  80258b:	e8 bc e0 ff ff       	call   80064c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802590:	89 74 24 04          	mov    %esi,0x4(%esp)
  802594:	8b 45 10             	mov    0x10(%ebp),%eax
  802597:	89 04 24             	mov    %eax,(%esp)
  80259a:	e8 4c e0 ff ff       	call   8005eb <vcprintf>
	cprintf("\n");
  80259f:	c7 04 24 04 2f 80 00 	movl   $0x802f04,(%esp)
  8025a6:	e8 a1 e0 ff ff       	call   80064c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8025ab:	cc                   	int3   
  8025ac:	eb fd                	jmp    8025ab <_panic+0x53>
	...

008025b0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8025b0:	55                   	push   %ebp
  8025b1:	89 e5                	mov    %esp,%ebp
  8025b3:	56                   	push   %esi
  8025b4:	53                   	push   %ebx
  8025b5:	83 ec 10             	sub    $0x10,%esp
  8025b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8025bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025be:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  8025c1:	85 c0                	test   %eax,%eax
  8025c3:	74 0a                	je     8025cf <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  8025c5:	89 04 24             	mov    %eax,(%esp)
  8025c8:	e8 32 ec ff ff       	call   8011ff <sys_ipc_recv>
  8025cd:	eb 0c                	jmp    8025db <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  8025cf:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  8025d6:	e8 24 ec ff ff       	call   8011ff <sys_ipc_recv>
	}
	if (r < 0)
  8025db:	85 c0                	test   %eax,%eax
  8025dd:	79 16                	jns    8025f5 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  8025df:	85 db                	test   %ebx,%ebx
  8025e1:	74 06                	je     8025e9 <ipc_recv+0x39>
  8025e3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  8025e9:	85 f6                	test   %esi,%esi
  8025eb:	74 2c                	je     802619 <ipc_recv+0x69>
  8025ed:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8025f3:	eb 24                	jmp    802619 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  8025f5:	85 db                	test   %ebx,%ebx
  8025f7:	74 0a                	je     802603 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  8025f9:	a1 18 40 80 00       	mov    0x804018,%eax
  8025fe:	8b 40 74             	mov    0x74(%eax),%eax
  802601:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  802603:	85 f6                	test   %esi,%esi
  802605:	74 0a                	je     802611 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  802607:	a1 18 40 80 00       	mov    0x804018,%eax
  80260c:	8b 40 78             	mov    0x78(%eax),%eax
  80260f:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802611:	a1 18 40 80 00       	mov    0x804018,%eax
  802616:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802619:	83 c4 10             	add    $0x10,%esp
  80261c:	5b                   	pop    %ebx
  80261d:	5e                   	pop    %esi
  80261e:	5d                   	pop    %ebp
  80261f:	c3                   	ret    

00802620 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802620:	55                   	push   %ebp
  802621:	89 e5                	mov    %esp,%ebp
  802623:	57                   	push   %edi
  802624:	56                   	push   %esi
  802625:	53                   	push   %ebx
  802626:	83 ec 1c             	sub    $0x1c,%esp
  802629:	8b 75 08             	mov    0x8(%ebp),%esi
  80262c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80262f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  802632:	85 db                	test   %ebx,%ebx
  802634:	74 19                	je     80264f <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802636:	8b 45 14             	mov    0x14(%ebp),%eax
  802639:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80263d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802641:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802645:	89 34 24             	mov    %esi,(%esp)
  802648:	e8 8f eb ff ff       	call   8011dc <sys_ipc_try_send>
  80264d:	eb 1c                	jmp    80266b <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  80264f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802656:	00 
  802657:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  80265e:	ee 
  80265f:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802663:	89 34 24             	mov    %esi,(%esp)
  802666:	e8 71 eb ff ff       	call   8011dc <sys_ipc_try_send>
		}
		if (r == 0)
  80266b:	85 c0                	test   %eax,%eax
  80266d:	74 2c                	je     80269b <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  80266f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802672:	74 20                	je     802694 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802674:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802678:	c7 44 24 08 3c 2f 80 	movl   $0x802f3c,0x8(%esp)
  80267f:	00 
  802680:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802687:	00 
  802688:	c7 04 24 4f 2f 80 00 	movl   $0x802f4f,(%esp)
  80268f:	e8 c4 fe ff ff       	call   802558 <_panic>
		}
		sys_yield();
  802694:	e8 31 e9 ff ff       	call   800fca <sys_yield>
	}
  802699:	eb 97                	jmp    802632 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  80269b:	83 c4 1c             	add    $0x1c,%esp
  80269e:	5b                   	pop    %ebx
  80269f:	5e                   	pop    %esi
  8026a0:	5f                   	pop    %edi
  8026a1:	5d                   	pop    %ebp
  8026a2:	c3                   	ret    

008026a3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8026a3:	55                   	push   %ebp
  8026a4:	89 e5                	mov    %esp,%ebp
  8026a6:	53                   	push   %ebx
  8026a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8026aa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8026af:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8026b6:	89 c2                	mov    %eax,%edx
  8026b8:	c1 e2 07             	shl    $0x7,%edx
  8026bb:	29 ca                	sub    %ecx,%edx
  8026bd:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8026c3:	8b 52 50             	mov    0x50(%edx),%edx
  8026c6:	39 da                	cmp    %ebx,%edx
  8026c8:	75 0f                	jne    8026d9 <ipc_find_env+0x36>
			return envs[i].env_id;
  8026ca:	c1 e0 07             	shl    $0x7,%eax
  8026cd:	29 c8                	sub    %ecx,%eax
  8026cf:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8026d4:	8b 40 40             	mov    0x40(%eax),%eax
  8026d7:	eb 0c                	jmp    8026e5 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8026d9:	40                   	inc    %eax
  8026da:	3d 00 04 00 00       	cmp    $0x400,%eax
  8026df:	75 ce                	jne    8026af <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8026e1:	66 b8 00 00          	mov    $0x0,%ax
}
  8026e5:	5b                   	pop    %ebx
  8026e6:	5d                   	pop    %ebp
  8026e7:	c3                   	ret    

008026e8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026e8:	55                   	push   %ebp
  8026e9:	89 e5                	mov    %esp,%ebp
  8026eb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8026ee:	89 c2                	mov    %eax,%edx
  8026f0:	c1 ea 16             	shr    $0x16,%edx
  8026f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8026fa:	f6 c2 01             	test   $0x1,%dl
  8026fd:	74 1e                	je     80271d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8026ff:	c1 e8 0c             	shr    $0xc,%eax
  802702:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802709:	a8 01                	test   $0x1,%al
  80270b:	74 17                	je     802724 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80270d:	c1 e8 0c             	shr    $0xc,%eax
  802710:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802717:	ef 
  802718:	0f b7 c0             	movzwl %ax,%eax
  80271b:	eb 0c                	jmp    802729 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  80271d:	b8 00 00 00 00       	mov    $0x0,%eax
  802722:	eb 05                	jmp    802729 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802724:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802729:	5d                   	pop    %ebp
  80272a:	c3                   	ret    
	...

0080272c <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  80272c:	55                   	push   %ebp
  80272d:	57                   	push   %edi
  80272e:	56                   	push   %esi
  80272f:	83 ec 10             	sub    $0x10,%esp
  802732:	8b 74 24 20          	mov    0x20(%esp),%esi
  802736:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80273a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80273e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802742:	89 cd                	mov    %ecx,%ebp
  802744:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802748:	85 c0                	test   %eax,%eax
  80274a:	75 2c                	jne    802778 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  80274c:	39 f9                	cmp    %edi,%ecx
  80274e:	77 68                	ja     8027b8 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802750:	85 c9                	test   %ecx,%ecx
  802752:	75 0b                	jne    80275f <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802754:	b8 01 00 00 00       	mov    $0x1,%eax
  802759:	31 d2                	xor    %edx,%edx
  80275b:	f7 f1                	div    %ecx
  80275d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80275f:	31 d2                	xor    %edx,%edx
  802761:	89 f8                	mov    %edi,%eax
  802763:	f7 f1                	div    %ecx
  802765:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802767:	89 f0                	mov    %esi,%eax
  802769:	f7 f1                	div    %ecx
  80276b:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80276d:	89 f0                	mov    %esi,%eax
  80276f:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802771:	83 c4 10             	add    $0x10,%esp
  802774:	5e                   	pop    %esi
  802775:	5f                   	pop    %edi
  802776:	5d                   	pop    %ebp
  802777:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802778:	39 f8                	cmp    %edi,%eax
  80277a:	77 2c                	ja     8027a8 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  80277c:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  80277f:	83 f6 1f             	xor    $0x1f,%esi
  802782:	75 4c                	jne    8027d0 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802784:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802786:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  80278b:	72 0a                	jb     802797 <__udivdi3+0x6b>
  80278d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802791:	0f 87 ad 00 00 00    	ja     802844 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802797:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  80279c:	89 f0                	mov    %esi,%eax
  80279e:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027a0:	83 c4 10             	add    $0x10,%esp
  8027a3:	5e                   	pop    %esi
  8027a4:	5f                   	pop    %edi
  8027a5:	5d                   	pop    %ebp
  8027a6:	c3                   	ret    
  8027a7:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8027a8:	31 ff                	xor    %edi,%edi
  8027aa:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027ac:	89 f0                	mov    %esi,%eax
  8027ae:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027b0:	83 c4 10             	add    $0x10,%esp
  8027b3:	5e                   	pop    %esi
  8027b4:	5f                   	pop    %edi
  8027b5:	5d                   	pop    %ebp
  8027b6:	c3                   	ret    
  8027b7:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8027b8:	89 fa                	mov    %edi,%edx
  8027ba:	89 f0                	mov    %esi,%eax
  8027bc:	f7 f1                	div    %ecx
  8027be:	89 c6                	mov    %eax,%esi
  8027c0:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8027c2:	89 f0                	mov    %esi,%eax
  8027c4:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8027c6:	83 c4 10             	add    $0x10,%esp
  8027c9:	5e                   	pop    %esi
  8027ca:	5f                   	pop    %edi
  8027cb:	5d                   	pop    %ebp
  8027cc:	c3                   	ret    
  8027cd:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8027d0:	89 f1                	mov    %esi,%ecx
  8027d2:	d3 e0                	shl    %cl,%eax
  8027d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8027d8:	b8 20 00 00 00       	mov    $0x20,%eax
  8027dd:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  8027df:	89 ea                	mov    %ebp,%edx
  8027e1:	88 c1                	mov    %al,%cl
  8027e3:	d3 ea                	shr    %cl,%edx
  8027e5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8027e9:	09 ca                	or     %ecx,%edx
  8027eb:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  8027ef:	89 f1                	mov    %esi,%ecx
  8027f1:	d3 e5                	shl    %cl,%ebp
  8027f3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  8027f7:	89 fd                	mov    %edi,%ebp
  8027f9:	88 c1                	mov    %al,%cl
  8027fb:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  8027fd:	89 fa                	mov    %edi,%edx
  8027ff:	89 f1                	mov    %esi,%ecx
  802801:	d3 e2                	shl    %cl,%edx
  802803:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802807:	88 c1                	mov    %al,%cl
  802809:	d3 ef                	shr    %cl,%edi
  80280b:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  80280d:	89 f8                	mov    %edi,%eax
  80280f:	89 ea                	mov    %ebp,%edx
  802811:	f7 74 24 08          	divl   0x8(%esp)
  802815:	89 d1                	mov    %edx,%ecx
  802817:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802819:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  80281d:	39 d1                	cmp    %edx,%ecx
  80281f:	72 17                	jb     802838 <__udivdi3+0x10c>
  802821:	74 09                	je     80282c <__udivdi3+0x100>
  802823:	89 fe                	mov    %edi,%esi
  802825:	31 ff                	xor    %edi,%edi
  802827:	e9 41 ff ff ff       	jmp    80276d <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  80282c:	8b 54 24 04          	mov    0x4(%esp),%edx
  802830:	89 f1                	mov    %esi,%ecx
  802832:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802834:	39 c2                	cmp    %eax,%edx
  802836:	73 eb                	jae    802823 <__udivdi3+0xf7>
		{
		  q0--;
  802838:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  80283b:	31 ff                	xor    %edi,%edi
  80283d:	e9 2b ff ff ff       	jmp    80276d <__udivdi3+0x41>
  802842:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802844:	31 f6                	xor    %esi,%esi
  802846:	e9 22 ff ff ff       	jmp    80276d <__udivdi3+0x41>
	...

0080284c <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  80284c:	55                   	push   %ebp
  80284d:	57                   	push   %edi
  80284e:	56                   	push   %esi
  80284f:	83 ec 20             	sub    $0x20,%esp
  802852:	8b 44 24 30          	mov    0x30(%esp),%eax
  802856:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80285a:	89 44 24 14          	mov    %eax,0x14(%esp)
  80285e:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802862:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802866:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  80286a:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  80286c:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80286e:	85 ed                	test   %ebp,%ebp
  802870:	75 16                	jne    802888 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802872:	39 f1                	cmp    %esi,%ecx
  802874:	0f 86 a6 00 00 00    	jbe    802920 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80287a:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  80287c:	89 d0                	mov    %edx,%eax
  80287e:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802880:	83 c4 20             	add    $0x20,%esp
  802883:	5e                   	pop    %esi
  802884:	5f                   	pop    %edi
  802885:	5d                   	pop    %ebp
  802886:	c3                   	ret    
  802887:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802888:	39 f5                	cmp    %esi,%ebp
  80288a:	0f 87 ac 00 00 00    	ja     80293c <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802890:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802893:	83 f0 1f             	xor    $0x1f,%eax
  802896:	89 44 24 10          	mov    %eax,0x10(%esp)
  80289a:	0f 84 a8 00 00 00    	je     802948 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  8028a0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028a4:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  8028a6:	bf 20 00 00 00       	mov    $0x20,%edi
  8028ab:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  8028af:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8028b3:	89 f9                	mov    %edi,%ecx
  8028b5:	d3 e8                	shr    %cl,%eax
  8028b7:	09 e8                	or     %ebp,%eax
  8028b9:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  8028bd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8028c1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8028c5:	d3 e0                	shl    %cl,%eax
  8028c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8028cb:	89 f2                	mov    %esi,%edx
  8028cd:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  8028cf:	8b 44 24 14          	mov    0x14(%esp),%eax
  8028d3:	d3 e0                	shl    %cl,%eax
  8028d5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  8028d9:	8b 44 24 14          	mov    0x14(%esp),%eax
  8028dd:	89 f9                	mov    %edi,%ecx
  8028df:	d3 e8                	shr    %cl,%eax
  8028e1:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  8028e3:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  8028e5:	89 f2                	mov    %esi,%edx
  8028e7:	f7 74 24 18          	divl   0x18(%esp)
  8028eb:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  8028ed:	f7 64 24 0c          	mull   0xc(%esp)
  8028f1:	89 c5                	mov    %eax,%ebp
  8028f3:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  8028f5:	39 d6                	cmp    %edx,%esi
  8028f7:	72 67                	jb     802960 <__umoddi3+0x114>
  8028f9:	74 75                	je     802970 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  8028fb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8028ff:	29 e8                	sub    %ebp,%eax
  802901:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802903:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802907:	d3 e8                	shr    %cl,%eax
  802909:	89 f2                	mov    %esi,%edx
  80290b:	89 f9                	mov    %edi,%ecx
  80290d:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  80290f:	09 d0                	or     %edx,%eax
  802911:	89 f2                	mov    %esi,%edx
  802913:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802917:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802919:	83 c4 20             	add    $0x20,%esp
  80291c:	5e                   	pop    %esi
  80291d:	5f                   	pop    %edi
  80291e:	5d                   	pop    %ebp
  80291f:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802920:	85 c9                	test   %ecx,%ecx
  802922:	75 0b                	jne    80292f <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802924:	b8 01 00 00 00       	mov    $0x1,%eax
  802929:	31 d2                	xor    %edx,%edx
  80292b:	f7 f1                	div    %ecx
  80292d:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  80292f:	89 f0                	mov    %esi,%eax
  802931:	31 d2                	xor    %edx,%edx
  802933:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802935:	89 f8                	mov    %edi,%eax
  802937:	e9 3e ff ff ff       	jmp    80287a <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  80293c:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  80293e:	83 c4 20             	add    $0x20,%esp
  802941:	5e                   	pop    %esi
  802942:	5f                   	pop    %edi
  802943:	5d                   	pop    %ebp
  802944:	c3                   	ret    
  802945:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802948:	39 f5                	cmp    %esi,%ebp
  80294a:	72 04                	jb     802950 <__umoddi3+0x104>
  80294c:	39 f9                	cmp    %edi,%ecx
  80294e:	77 06                	ja     802956 <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802950:	89 f2                	mov    %esi,%edx
  802952:	29 cf                	sub    %ecx,%edi
  802954:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802956:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802958:	83 c4 20             	add    $0x20,%esp
  80295b:	5e                   	pop    %esi
  80295c:	5f                   	pop    %edi
  80295d:	5d                   	pop    %ebp
  80295e:	c3                   	ret    
  80295f:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802960:	89 d1                	mov    %edx,%ecx
  802962:	89 c5                	mov    %eax,%ebp
  802964:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802968:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  80296c:	eb 8d                	jmp    8028fb <__umoddi3+0xaf>
  80296e:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802970:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802974:	72 ea                	jb     802960 <__umoddi3+0x114>
  802976:	89 f1                	mov    %esi,%ecx
  802978:	eb 81                	jmp    8028fb <__umoddi3+0xaf>
