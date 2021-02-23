
obj/user/httpd.debug:     file format elf32-i386


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
  80002c:	e8 47 08 00 00       	call   800878 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <die>:
	{404, "Not Found"},
};

static void
die(char *m)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("%s\n", m);
  80003a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003e:	c7 04 24 40 2f 80 00 	movl   $0x802f40,(%esp)
  800045:	e8 96 09 00 00       	call   8009e0 <cprintf>
	exit();
  80004a:	e8 7d 08 00 00       	call   8008cc <exit>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <send_error>:
	return 0;
}

static int
send_error(struct http_request *req, int code)
{
  800051:	55                   	push   %ebp
  800052:	89 e5                	mov    %esp,%ebp
  800054:	57                   	push   %edi
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	81 ec 2c 02 00 00    	sub    $0x22c,%esp
  80005d:	89 c3                	mov    %eax,%ebx
	char buf[512];
	int r;

	struct error_messages *e = errors;
  80005f:	b8 00 40 80 00       	mov    $0x804000,%eax
	while (e->code != 0 && e->msg != 0) {
  800064:	eb 07                	jmp    80006d <send_error+0x1c>
		if (e->code == code)
  800066:	39 d1                	cmp    %edx,%ecx
  800068:	74 11                	je     80007b <send_error+0x2a>
			break;
		e++;
  80006a:	83 c0 08             	add    $0x8,%eax
{
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
  80006d:	8b 08                	mov    (%eax),%ecx
  80006f:	85 c9                	test   %ecx,%ecx
  800071:	74 5c                	je     8000cf <send_error+0x7e>
  800073:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  800077:	75 ed                	jne    800066 <send_error+0x15>
  800079:	eb 04                	jmp    80007f <send_error+0x2e>
		if (e->code == code)
			break;
		e++;
	}

	if (e->code == 0)
  80007b:	85 c9                	test   %ecx,%ecx
  80007d:	74 57                	je     8000d6 <send_error+0x85>
		return -1;

	r = snprintf(buf, 512, "HTTP/" HTTP_VERSION" %d %s\r\n"
  80007f:	8b 40 04             	mov    0x4(%eax),%eax
  800082:	89 44 24 18          	mov    %eax,0x18(%esp)
  800086:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80008a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80008e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800092:	c7 44 24 08 e0 2f 80 	movl   $0x802fe0,0x8(%esp)
  800099:	00 
  80009a:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  8000a1:	00 
  8000a2:	8d b5 e8 fd ff ff    	lea    -0x218(%ebp),%esi
  8000a8:	89 34 24             	mov    %esi,(%esp)
  8000ab:	e8 7d 0e 00 00       	call   800f2d <snprintf>
  8000b0:	89 c7                	mov    %eax,%edi
			       "Content-type: text/html\r\n"
			       "\r\n"
			       "<html><body><p>%d - %s</p></body></html>\r\n",
			       e->code, e->msg, e->code, e->msg);

	if (write(req->sock, buf, r) != r)
  8000b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ba:	8b 03                	mov    (%ebx),%eax
  8000bc:	89 04 24             	mov    %eax,(%esp)
  8000bf:	e8 7b 19 00 00       	call   801a3f <write>
		return -1;
  8000c4:	39 f8                	cmp    %edi,%eax
  8000c6:	0f 94 c0             	sete   %al
  8000c9:	0f b6 c0             	movzbl %al,%eax
  8000cc:	48                   	dec    %eax
  8000cd:	eb 0c                	jmp    8000db <send_error+0x8a>
			break;
		e++;
	}

	if (e->code == 0)
		return -1;
  8000cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8000d4:	eb 05                	jmp    8000db <send_error+0x8a>
  8000d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	if (write(req->sock, buf, r) != r)
		return -1;

	return 0;
}
  8000db:	81 c4 2c 02 00 00    	add    $0x22c,%esp
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5f                   	pop    %edi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <handle_client>:
	return r;
}

static void
handle_client(int sock)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	57                   	push   %edi
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
  8000ec:	81 ec cc 04 00 00    	sub    $0x4cc,%esp
  8000f2:	89 85 44 fb ff ff    	mov    %eax,-0x4bc(%ebp)
	struct http_request *req = &con_d;

	while (1)
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  8000f8:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8000ff:	00 
  800100:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  800106:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010a:	8b 85 44 fb ff ff    	mov    -0x4bc(%ebp),%eax
  800110:	89 04 24             	mov    %eax,(%esp)
  800113:	e8 4c 18 00 00       	call   801964 <read>
  800118:	85 c0                	test   %eax,%eax
  80011a:	79 1c                	jns    800138 <handle_client+0x52>
			panic("failed to read");
  80011c:	c7 44 24 08 44 2f 80 	movl   $0x802f44,0x8(%esp)
  800123:	00 
  800124:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
  80012b:	00 
  80012c:	c7 04 24 53 2f 80 00 	movl   $0x802f53,(%esp)
  800133:	e8 b0 07 00 00       	call   8008e8 <_panic>

		memset(req, 0, sizeof(*req));
  800138:	c7 44 24 08 0c 00 00 	movl   $0xc,0x8(%esp)
  80013f:	00 
  800140:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800147:	00 
{
	struct http_request con_d;
	int r;
	char buffer[BUFFSIZE];
	int received = -1;
	struct http_request *req = &con_d;
  800148:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80014b:	89 04 24             	mov    %eax,(%esp)
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
			panic("failed to read");

		memset(req, 0, sizeof(*req));
  80014e:	e8 67 0f 00 00       	call   8010ba <memset>

		req->sock = sock;
  800153:	8b 85 44 fb ff ff    	mov    -0x4bc(%ebp),%eax
  800159:	89 45 dc             	mov    %eax,-0x24(%ebp)
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  80015c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800163:	00 
  800164:	c7 44 24 04 60 2f 80 	movl   $0x802f60,0x4(%esp)
  80016b:	00 

		memset(req, 0, sizeof(*req));

		req->sock = sock;

		r = http_request_parse(req, buffer);
  80016c:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  800172:	89 04 24             	mov    %eax,(%esp)
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  800175:	e8 d9 0e 00 00       	call   801053 <strncmp>
  80017a:	85 c0                	test   %eax,%eax
  80017c:	0f 85 4d 02 00 00    	jne    8003cf <handle_client+0x2e9>
		return -E_BAD_REQ;

	// skip GET
	request += 4;
  800182:	8d 9d e0 fd ff ff    	lea    -0x220(%ebp),%ebx
  800188:	eb 01                	jmp    80018b <handle_client+0xa5>

	// get the url
	url = request;
	while (*request && *request != ' ')
		request++;
  80018a:	43                   	inc    %ebx
	// skip GET
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
  80018b:	8a 03                	mov    (%ebx),%al
  80018d:	84 c0                	test   %al,%al
  80018f:	74 04                	je     800195 <handle_client+0xaf>
  800191:	3c 20                	cmp    $0x20,%al
  800193:	75 f5                	jne    80018a <handle_client+0xa4>

	if (strncmp(request, "GET ", 4) != 0)
		return -E_BAD_REQ;

	// skip GET
	request += 4;
  800195:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi

	// get the url
	url = request;
	while (*request && *request != ' ')
		request++;
	url_len = request - url;
  80019b:	89 de                	mov    %ebx,%esi
  80019d:	29 fe                	sub    %edi,%esi

	req->url = malloc(url_len + 1);
  80019f:	8d 46 01             	lea    0x1(%esi),%eax
  8001a2:	89 04 24             	mov    %eax,(%esp)
  8001a5:	e8 fa 22 00 00       	call   8024a4 <malloc>
  8001aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
	memmove(req->url, url, url_len);
  8001ad:	89 74 24 08          	mov    %esi,0x8(%esp)

	if (strncmp(request, "GET ", 4) != 0)
		return -E_BAD_REQ;

	// skip GET
	request += 4;
  8001b1:	89 7c 24 04          	mov    %edi,0x4(%esp)
	while (*request && *request != ' ')
		request++;
	url_len = request - url;

	req->url = malloc(url_len + 1);
	memmove(req->url, url, url_len);
  8001b5:	89 04 24             	mov    %eax,(%esp)
  8001b8:	e8 47 0f 00 00       	call   801104 <memmove>
	req->url[url_len] = '\0';
  8001bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8001c0:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)

	// skip space
	request++;
  8001c4:	8d 73 01             	lea    0x1(%ebx),%esi
  8001c7:	89 f3                	mov    %esi,%ebx
  8001c9:	eb 01                	jmp    8001cc <handle_client+0xe6>

	version = request;
	while (*request && *request != '\n')
		request++;
  8001cb:	43                   	inc    %ebx

	// skip space
	request++;

	version = request;
	while (*request && *request != '\n')
  8001cc:	8a 03                	mov    (%ebx),%al
  8001ce:	84 c0                	test   %al,%al
  8001d0:	74 04                	je     8001d6 <handle_client+0xf0>
  8001d2:	3c 0a                	cmp    $0xa,%al
  8001d4:	75 f5                	jne    8001cb <handle_client+0xe5>
		request++;
	version_len = request - version;
  8001d6:	29 f3                	sub    %esi,%ebx

	req->version = malloc(version_len + 1);
  8001d8:	8d 43 01             	lea    0x1(%ebx),%eax
  8001db:	89 04 24             	mov    %eax,(%esp)
  8001de:	e8 c1 22 00 00       	call   8024a4 <malloc>
  8001e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	memmove(req->version, version, version_len);
  8001e6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001ee:	89 04 24             	mov    %eax,(%esp)
  8001f1:	e8 0e 0f 00 00       	call   801104 <memmove>
	req->version[version_len] = '\0';
  8001f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001f9:	c6 04 18 00          	movb   $0x0,(%eax,%ebx,1)
	// set file_size to the size of the file

	// LAB 6: Your code here.
	// panic("send_file not implemented");
	char *path = req->url;
	if ((fd = open(path, O_RDONLY)) < 0)
  8001fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800204:	00 
  800205:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800208:	89 04 24             	mov    %eax,(%esp)
  80020b:	e8 27 1c 00 00       	call   801e37 <open>
  800210:	89 c6                	mov    %eax,%esi
  800212:	85 c0                	test   %eax,%eax
  800214:	79 0d                	jns    800223 <handle_client+0x13d>
	{
		send_error(req, 404);
  800216:	ba 94 01 00 00       	mov    $0x194,%edx
  80021b:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80021e:	e8 2e fe ff ff       	call   800051 <send_error>
	}
	struct Stat st;
	stat(req->url, &st);
  800223:	8d 85 50 fd ff ff    	lea    -0x2b0(%ebp),%eax
  800229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800230:	89 04 24             	mov    %eax,(%esp)
  800233:	e8 ba 19 00 00       	call   801bf2 <stat>
	if (st.st_isdir)
  800238:	83 bd d4 fd ff ff 00 	cmpl   $0x0,-0x22c(%ebp)
  80023f:	74 0d                	je     80024e <handle_client+0x168>
	{
		send_error(req, 404);
  800241:	ba 94 01 00 00       	mov    $0x194,%edx
  800246:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800249:	e8 03 fe ff ff       	call   800051 <send_error>
	}
	file_size = st.st_size;
  80024e:	8b bd d0 fd ff ff    	mov    -0x230(%ebp),%edi
}

static int
send_header(struct http_request *req, int code)
{
	struct responce_header *h = headers;
  800254:	bb 10 40 80 00       	mov    $0x804010,%ebx
  800259:	eb 0a                	jmp    800265 <handle_client+0x17f>
	while (h->code != 0 && h->header!= 0) {
		if (h->code == code)
  80025b:	3d c8 00 00 00       	cmp    $0xc8,%eax
  800260:	74 13                	je     800275 <handle_client+0x18f>
			break;
		h++;
  800262:	83 c3 08             	add    $0x8,%ebx

static int
send_header(struct http_request *req, int code)
{
	struct responce_header *h = headers;
	while (h->code != 0 && h->header!= 0) {
  800265:	8b 03                	mov    (%ebx),%eax
  800267:	85 c0                	test   %eax,%eax
  800269:	0f 84 29 01 00 00    	je     800398 <handle_client+0x2b2>
  80026f:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  800273:	75 e6                	jne    80025b <handle_client+0x175>
	}

	if (h->code == 0)
		return -1;

	int len = strlen(h->header);
  800275:	8b 43 04             	mov    0x4(%ebx),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	e8 d8 0c 00 00       	call   800f58 <strlen>
  800280:	89 85 40 fb ff ff    	mov    %eax,-0x4c0(%ebp)
	if (write(req->sock, h->header, len) != len) {
  800286:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028a:	8b 43 04             	mov    0x4(%ebx),%eax
  80028d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800291:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800294:	89 04 24             	mov    %eax,(%esp)
  800297:	e8 a3 17 00 00       	call   801a3f <write>
  80029c:	39 85 40 fb ff ff    	cmp    %eax,-0x4c0(%ebp)
  8002a2:	0f 84 36 01 00 00    	je     8003de <handle_client+0x2f8>
		die("Failed to send bytes to client");
  8002a8:	b8 5c 30 80 00       	mov    $0x80305c,%eax
  8002ad:	e8 82 fd ff ff       	call   800034 <die>
  8002b2:	e9 27 01 00 00       	jmp    8003de <handle_client+0x2f8>
	char buf[64];
	int r;

	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
	if (r > 63)
		panic("buffer too small!");
  8002b7:	c7 44 24 08 65 2f 80 	movl   $0x802f65,0x8(%esp)
  8002be:	00 
  8002bf:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
  8002c6:	00 
  8002c7:	c7 04 24 53 2f 80 00 	movl   $0x802f53,(%esp)
  8002ce:	e8 15 06 00 00       	call   8008e8 <_panic>

	if (write(req->sock, buf, r) != r)
  8002d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d7:	8d 85 50 fb ff ff    	lea    -0x4b0(%ebp),%eax
  8002dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002e4:	89 04 24             	mov    %eax,(%esp)
  8002e7:	e8 53 17 00 00       	call   801a3f <write>
  8002ec:	39 c3                	cmp    %eax,%ebx
  8002ee:	0f 84 1c 01 00 00    	je     800410 <handle_client+0x32a>
  8002f4:	e9 9f 00 00 00       	jmp    800398 <handle_client+0x2b2>
	if (!type)
		return -1;

	r = snprintf(buf, 128, "Content-Type: %s\r\n", type);
	if (r > 127)
		panic("buffer too small!");
  8002f9:	c7 44 24 08 65 2f 80 	movl   $0x802f65,0x8(%esp)
  800300:	00 
  800301:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  800308:	00 
  800309:	c7 04 24 53 2f 80 00 	movl   $0x802f53,(%esp)
  800310:	e8 d3 05 00 00       	call   8008e8 <_panic>

	if (write(req->sock, buf, r) != r)
  800315:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800319:	8d 85 50 fb ff ff    	lea    -0x4b0(%ebp),%eax
  80031f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800323:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800326:	89 04 24             	mov    %eax,(%esp)
  800329:	e8 11 17 00 00       	call   801a3f <write>
  80032e:	39 c3                	cmp    %eax,%ebx
  800330:	75 66                	jne    800398 <handle_client+0x2b2>

static int
send_header_fin(struct http_request *req)
{
	const char *fin = "\r\n";
	int fin_len = strlen(fin);
  800332:	c7 04 24 8a 2f 80 00 	movl   $0x802f8a,(%esp)
  800339:	e8 1a 0c 00 00       	call   800f58 <strlen>
  80033e:	89 c3                	mov    %eax,%ebx

	if (write(req->sock, fin, fin_len) != fin_len)
  800340:	89 44 24 08          	mov    %eax,0x8(%esp)
  800344:	c7 44 24 04 8a 2f 80 	movl   $0x802f8a,0x4(%esp)
  80034b:	00 
  80034c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80034f:	89 04 24             	mov    %eax,(%esp)
  800352:	e8 e8 16 00 00       	call   801a3f <write>
  800357:	39 c3                	cmp    %eax,%ebx
  800359:	74 1f                	je     80037a <handle_client+0x294>
  80035b:	eb 3b                	jmp    800398 <handle_client+0x2b2>
	// panic("send_data not implemented");
	char buf[BUFFSIZE];
	int readcnt = 0;
	while ((readcnt = read(fd, buf, BUFFSIZE)))
	{
		if ( readcnt < 0)
  80035d:	85 c0                	test   %eax,%eax
  80035f:	78 37                	js     800398 <handle_client+0x2b2>
		{
			return -1;
		}
		if (write(req->sock, buf, readcnt) < 0){
  800361:	89 44 24 08          	mov    %eax,0x8(%esp)
  800365:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800369:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036c:	89 04 24             	mov    %eax,(%esp)
  80036f:	e8 cb 16 00 00       	call   801a3f <write>
  800374:	85 c0                	test   %eax,%eax
  800376:	79 08                	jns    800380 <handle_client+0x29a>
  800378:	eb 1e                	jmp    800398 <handle_client+0x2b2>
{
	// LAB 6: Your code here.
	// panic("send_data not implemented");
	char buf[BUFFSIZE];
	int readcnt = 0;
	while ((readcnt = read(fd, buf, BUFFSIZE)))
  80037a:	8d 9d 50 fb ff ff    	lea    -0x4b0(%ebp),%ebx
  800380:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800387:	00 
  800388:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80038c:	89 34 24             	mov    %esi,(%esp)
  80038f:	e8 d0 15 00 00       	call   801964 <read>
  800394:	85 c0                	test   %eax,%eax
  800396:	75 c5                	jne    80035d <handle_client+0x277>
		goto end;

	r = send_data(req, fd);

end:
	close(fd);
  800398:	89 34 24             	mov    %esi,(%esp)
  80039b:	e8 5e 14 00 00       	call   8017fe <close>
}

static void
req_free(struct http_request *req)
{
	free(req->url);
  8003a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a3:	89 04 24             	mov    %eax,(%esp)
  8003a6:	e8 29 20 00 00       	call   8023d4 <free>
	free(req->version);
  8003ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003ae:	89 04 24             	mov    %eax,(%esp)
  8003b1:	e8 1e 20 00 00       	call   8023d4 <free>

		// no keep alive
		break;
	}

	close(sock);
  8003b6:	8b 85 44 fb ff ff    	mov    -0x4bc(%ebp),%eax
  8003bc:	89 04 24             	mov    %eax,(%esp)
  8003bf:	e8 3a 14 00 00       	call   8017fe <close>
}
  8003c4:	81 c4 cc 04 00 00    	add    $0x4cc,%esp
  8003ca:	5b                   	pop    %ebx
  8003cb:	5e                   	pop    %esi
  8003cc:	5f                   	pop    %edi
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

		req->sock = sock;

		r = http_request_parse(req, buffer);
		if (r == -E_BAD_REQ)
			send_error(req, 400);
  8003cf:	ba 90 01 00 00       	mov    $0x190,%edx
  8003d4:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8003d7:	e8 75 fc ff ff       	call   800051 <send_error>
  8003dc:	eb c2                	jmp    8003a0 <handle_client+0x2ba>
send_size(struct http_request *req, off_t size)
{
	char buf[64];
	int r;

	r = snprintf(buf, 64, "Content-Length: %ld\r\n", (long)size);
  8003de:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8003e2:	c7 44 24 08 77 2f 80 	movl   $0x802f77,0x8(%esp)
  8003e9:	00 
  8003ea:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  8003f1:	00 
  8003f2:	8d 85 50 fb ff ff    	lea    -0x4b0(%ebp),%eax
  8003f8:	89 04 24             	mov    %eax,(%esp)
  8003fb:	e8 2d 0b 00 00       	call   800f2d <snprintf>
  800400:	89 c3                	mov    %eax,%ebx
	if (r > 63)
  800402:	83 f8 3f             	cmp    $0x3f,%eax
  800405:	0f 8e c8 fe ff ff    	jle    8002d3 <handle_client+0x1ed>
  80040b:	e9 a7 fe ff ff       	jmp    8002b7 <handle_client+0x1d1>

	type = mime_type(req->url);
	if (!type)
		return -1;

	r = snprintf(buf, 128, "Content-Type: %s\r\n", type);
  800410:	c7 44 24 0c 8d 2f 80 	movl   $0x802f8d,0xc(%esp)
  800417:	00 
  800418:	c7 44 24 08 97 2f 80 	movl   $0x802f97,0x8(%esp)
  80041f:	00 
  800420:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  800427:	00 
  800428:	8d 85 50 fb ff ff    	lea    -0x4b0(%ebp),%eax
  80042e:	89 04 24             	mov    %eax,(%esp)
  800431:	e8 f7 0a 00 00       	call   800f2d <snprintf>
  800436:	89 c3                	mov    %eax,%ebx
	if (r > 127)
  800438:	83 f8 7f             	cmp    $0x7f,%eax
  80043b:	0f 8e d4 fe ff ff    	jle    800315 <handle_client+0x22f>
  800441:	e9 b3 fe ff ff       	jmp    8002f9 <handle_client+0x213>

00800446 <umain>:
	close(sock);
}

void
umain(int argc, char **argv)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	83 ec 4c             	sub    $0x4c,%esp
	int serversock, clientsock;
	struct sockaddr_in server, client;

	binaryname = "jhttpd";
  80044f:	c7 05 20 40 80 00 aa 	movl   $0x802faa,0x804020
  800456:	2f 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800459:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800460:	00 
  800461:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800468:	00 
  800469:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800470:	e8 7a 1c 00 00       	call   8020ef <socket>
  800475:	89 c6                	mov    %eax,%esi
  800477:	85 c0                	test   %eax,%eax
  800479:	79 0a                	jns    800485 <umain+0x3f>
		die("Failed to create socket");
  80047b:	b8 b1 2f 80 00       	mov    $0x802fb1,%eax
  800480:	e8 af fb ff ff       	call   800034 <die>

	// Construct the server sockaddr_in structure
	memset(&server, 0, sizeof(server));		// Clear struct
  800485:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  80048c:	00 
  80048d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800494:	00 
  800495:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800498:	89 1c 24             	mov    %ebx,(%esp)
  80049b:	e8 1a 0c 00 00       	call   8010ba <memset>
	server.sin_family = AF_INET;			// Internet/IP
  8004a0:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	server.sin_addr.s_addr = htonl(INADDR_ANY);	// IP address
  8004a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8004ab:	e8 5d 01 00 00       	call   80060d <htonl>
  8004b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
	server.sin_port = htons(PORT);			// server port
  8004b3:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
  8004ba:	e8 2e 01 00 00       	call   8005ed <htons>
  8004bf:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &server,
  8004c3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  8004ca:	00 
  8004cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004cf:	89 34 24             	mov    %esi,(%esp)
  8004d2:	e8 7e 1b 00 00       	call   802055 <bind>
  8004d7:	85 c0                	test   %eax,%eax
  8004d9:	79 0a                	jns    8004e5 <umain+0x9f>
		 sizeof(server)) < 0)
	{
		die("Failed to bind the server socket");
  8004db:	b8 7c 30 80 00       	mov    $0x80307c,%eax
  8004e0:	e8 4f fb ff ff       	call   800034 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  8004e5:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  8004ec:	00 
  8004ed:	89 34 24             	mov    %esi,(%esp)
  8004f0:	e8 d7 1b 00 00       	call   8020cc <listen>
  8004f5:	85 c0                	test   %eax,%eax
  8004f7:	79 0a                	jns    800503 <umain+0xbd>
		die("Failed to listen on server socket");
  8004f9:	b8 a0 30 80 00       	mov    $0x8030a0,%eax
  8004fe:	e8 31 fb ff ff       	call   800034 <die>

	cprintf("Waiting for http connections...\n");
  800503:	c7 04 24 c4 30 80 00 	movl   $0x8030c4,(%esp)
  80050a:	e8 d1 04 00 00       	call   8009e0 <cprintf>
	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
  80050f:	8d 7d c4             	lea    -0x3c(%ebp),%edi
		die("Failed to listen on server socket");

	cprintf("Waiting for http connections...\n");

	while (1) {
		unsigned int clientlen = sizeof(client);
  800512:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock = accept(serversock,
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
  800519:	89 7c 24 08          	mov    %edi,0x8(%esp)

	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
					 (struct sockaddr *) &client,
  80051d:	8d 45 c8             	lea    -0x38(%ebp),%eax
  800520:	89 44 24 04          	mov    %eax,0x4(%esp)
	cprintf("Waiting for http connections...\n");

	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
  800524:	89 34 24             	mov    %esi,(%esp)
  800527:	e8 f6 1a 00 00       	call   802022 <accept>
  80052c:	89 c3                	mov    %eax,%ebx
  80052e:	85 c0                	test   %eax,%eax
  800530:	79 0a                	jns    80053c <umain+0xf6>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
		{
			die("Failed to accept client connection");
  800532:	b8 e8 30 80 00       	mov    $0x8030e8,%eax
  800537:	e8 f8 fa ff ff       	call   800034 <die>
		}
		handle_client(clientsock);
  80053c:	89 d8                	mov    %ebx,%eax
  80053e:	e8 a3 fb ff ff       	call   8000e6 <handle_client>
	}
  800543:	eb cd                	jmp    800512 <umain+0xcc>
  800545:	00 00                	add    %al,(%eax)
	...

00800548 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	57                   	push   %edi
  80054c:	56                   	push   %esi
  80054d:	53                   	push   %ebx
  80054e:	83 ec 1c             	sub    $0x1c,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800551:	8b 45 08             	mov    0x8(%ebp),%eax
  800554:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  800557:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  80055b:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  u8_t *ap;
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  80055e:	c7 45 dc 00 50 80 00 	movl   $0x805000,-0x24(%ebp)
 */
char *
inet_ntoa(struct in_addr addr)
{
  static char str[16];
  u32_t s_addr = addr.s_addr;
  800565:	b2 00                	mov    $0x0,%dl
  800567:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  80056a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80056d:	8a 00                	mov    (%eax),%al
  80056f:	88 45 e2             	mov    %al,-0x1e(%ebp)
      *ap /= (u8_t)10;
  800572:	0f b6 c0             	movzbl %al,%eax
  800575:	8d 34 80             	lea    (%eax,%eax,4),%esi
  800578:	8d 04 f0             	lea    (%eax,%esi,8),%eax
  80057b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80057e:	66 c1 e8 0b          	shr    $0xb,%ax
  800582:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800585:	88 01                	mov    %al,(%ecx)
      inv[i++] = '0' + rem;
  800587:	0f b6 f2             	movzbl %dl,%esi
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  80058a:	8d 3c 80             	lea    (%eax,%eax,4),%edi
  80058d:	d1 e7                	shl    %edi
  80058f:	8a 5d e2             	mov    -0x1e(%ebp),%bl
  800592:	89 f9                	mov    %edi,%ecx
  800594:	28 cb                	sub    %cl,%bl
  800596:	89 df                	mov    %ebx,%edi
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
  800598:	8d 4f 30             	lea    0x30(%edi),%ecx
  80059b:	88 4c 35 ed          	mov    %cl,-0x13(%ebp,%esi,1)
  80059f:	42                   	inc    %edx
    } while(*ap);
  8005a0:	84 c0                	test   %al,%al
  8005a2:	75 c6                	jne    80056a <inet_ntoa+0x22>
  8005a4:	88 d0                	mov    %dl,%al
  8005a6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a9:	8b 7d d8             	mov    -0x28(%ebp),%edi
  8005ac:	eb 0b                	jmp    8005b9 <inet_ntoa+0x71>
    while(i--)
  8005ae:	48                   	dec    %eax
      *rp++ = inv[i];
  8005af:	0f b6 f0             	movzbl %al,%esi
  8005b2:	8a 5c 35 ed          	mov    -0x13(%ebp,%esi,1),%bl
  8005b6:	88 19                	mov    %bl,(%ecx)
  8005b8:	41                   	inc    %ecx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8005b9:	84 c0                	test   %al,%al
  8005bb:	75 f1                	jne    8005ae <inet_ntoa+0x66>
  8005bd:	89 7d d8             	mov    %edi,-0x28(%ebp)
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  8005c0:	0f b6 d2             	movzbl %dl,%edx
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  8005c3:	03 55 dc             	add    -0x24(%ebp),%edx
      *rp++ = inv[i];
    *rp++ = '.';
  8005c6:	c6 02 2e             	movb   $0x2e,(%edx)
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  8005c9:	fe 45 e3             	incb   -0x1d(%ebp)
  8005cc:	80 7d e3 03          	cmpb   $0x3,-0x1d(%ebp)
  8005d0:	77 0b                	ja     8005dd <inet_ntoa+0x95>
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
  8005d2:	42                   	inc    %edx
  8005d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
    ap++;
  8005d6:	ff 45 d8             	incl   -0x28(%ebp)
  8005d9:	88 c2                	mov    %al,%dl
  8005db:	eb 8d                	jmp    80056a <inet_ntoa+0x22>
  }
  *--rp = 0;
  8005dd:	c6 02 00             	movb   $0x0,(%edx)
  return str;
}
  8005e0:	b8 00 50 80 00       	mov    $0x805000,%eax
  8005e5:	83 c4 1c             	add    $0x1c,%esp
  8005e8:	5b                   	pop    %ebx
  8005e9:	5e                   	pop    %esi
  8005ea:	5f                   	pop    %edi
  8005eb:	5d                   	pop    %ebp
  8005ec:	c3                   	ret    

008005ed <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8005ed:	55                   	push   %ebp
  8005ee:	89 e5                	mov    %esp,%ebp
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
  8005f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f3:	66 c1 c0 08          	rol    $0x8,%ax
}
  8005f7:	5d                   	pop    %ebp
  8005f8:	c3                   	ret    

008005f9 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8005f9:	55                   	push   %ebp
  8005fa:	89 e5                	mov    %esp,%ebp
  8005fc:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  8005ff:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  800603:	89 04 24             	mov    %eax,(%esp)
  800606:	e8 e2 ff ff ff       	call   8005ed <htons>
}
  80060b:	c9                   	leave  
  80060c:	c3                   	ret    

0080060d <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  80060d:	55                   	push   %ebp
  80060e:	89 e5                	mov    %esp,%ebp
  800610:	8b 55 08             	mov    0x8(%ebp),%edx
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
  800613:	89 d1                	mov    %edx,%ecx
  800615:	c1 e9 18             	shr    $0x18,%ecx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  800618:	89 d0                	mov    %edx,%eax
  80061a:	c1 e0 18             	shl    $0x18,%eax
  80061d:	09 c8                	or     %ecx,%eax
    ((n & 0xff00) << 8) |
  80061f:	89 d1                	mov    %edx,%ecx
  800621:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  800627:	c1 e1 08             	shl    $0x8,%ecx
  80062a:	09 c8                	or     %ecx,%eax
    ((n & 0xff0000UL) >> 8) |
  80062c:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  800632:	c1 ea 08             	shr    $0x8,%edx
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  return ((n & 0xff) << 24) |
  800635:	09 d0                	or     %edx,%eax
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  800637:	5d                   	pop    %ebp
  800638:	c3                   	ret    

00800639 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  800639:	55                   	push   %ebp
  80063a:	89 e5                	mov    %esp,%ebp
  80063c:	57                   	push   %edi
  80063d:	56                   	push   %esi
  80063e:	53                   	push   %ebx
  80063f:	83 ec 24             	sub    $0x24,%esp
  800642:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  800645:	0f be 10             	movsbl (%eax),%edx
inet_aton(const char *cp, struct in_addr *addr)
{
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;
  800648:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80064b:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  80064e:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  800651:	89 5d e0             	mov    %ebx,-0x20(%ebp)
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  800654:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800657:	80 f9 09             	cmp    $0x9,%cl
  80065a:	0f 87 8f 01 00 00    	ja     8007ef <inet_aton+0x1b6>
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  800660:	83 fa 30             	cmp    $0x30,%edx
  800663:	75 28                	jne    80068d <inet_aton+0x54>
      c = *++cp;
  800665:	0f be 50 01          	movsbl 0x1(%eax),%edx
      if (c == 'x' || c == 'X') {
  800669:	83 fa 78             	cmp    $0x78,%edx
  80066c:	74 0f                	je     80067d <inet_aton+0x44>
  80066e:	83 fa 58             	cmp    $0x58,%edx
  800671:	74 0a                	je     80067d <inet_aton+0x44>
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
  800673:	40                   	inc    %eax
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
      } else
        base = 8;
  800674:	c7 45 dc 08 00 00 00 	movl   $0x8,-0x24(%ebp)
  80067b:	eb 17                	jmp    800694 <inet_aton+0x5b>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  80067d:	0f be 50 02          	movsbl 0x2(%eax),%edx
  800681:	8d 40 02             	lea    0x2(%eax),%eax
    val = 0;
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
  800684:	c7 45 dc 10 00 00 00 	movl   $0x10,-0x24(%ebp)
        c = *++cp;
  80068b:	eb 07                	jmp    800694 <inet_aton+0x5b>
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
  80068d:	c7 45 dc 0a 00 00 00 	movl   $0xa,-0x24(%ebp)
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
  800694:	40                   	inc    %eax
  800695:	be 00 00 00 00       	mov    $0x0,%esi
  80069a:	eb 01                	jmp    80069d <inet_aton+0x64>
    base = 10;
    if (c == '0') {
      c = *++cp;
      if (c == 'x' || c == 'X') {
        base = 16;
        c = *++cp;
  80069c:	40                   	inc    %eax
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
  80069d:	8d 78 ff             	lea    -0x1(%eax),%edi
        c = *++cp;
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  8006a0:	88 d1                	mov    %dl,%cl
  8006a2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8006a5:	80 fb 09             	cmp    $0x9,%bl
  8006a8:	77 0d                	ja     8006b7 <inet_aton+0x7e>
        val = (val * base) + (int)(c - '0');
  8006aa:	0f af 75 dc          	imul   -0x24(%ebp),%esi
  8006ae:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  8006b2:	0f be 10             	movsbl (%eax),%edx
  8006b5:	eb e5                	jmp    80069c <inet_aton+0x63>
      } else if (base == 16 && isxdigit(c)) {
  8006b7:	83 7d dc 10          	cmpl   $0x10,-0x24(%ebp)
  8006bb:	75 30                	jne    8006ed <inet_aton+0xb4>
  8006bd:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  8006c0:	88 5d da             	mov    %bl,-0x26(%ebp)
  8006c3:	80 fb 05             	cmp    $0x5,%bl
  8006c6:	76 08                	jbe    8006d0 <inet_aton+0x97>
  8006c8:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  8006cb:	80 fb 05             	cmp    $0x5,%bl
  8006ce:	77 23                	ja     8006f3 <inet_aton+0xba>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  8006d0:	89 f1                	mov    %esi,%ecx
  8006d2:	c1 e1 04             	shl    $0x4,%ecx
  8006d5:	8d 72 0a             	lea    0xa(%edx),%esi
  8006d8:	80 7d da 1a          	cmpb   $0x1a,-0x26(%ebp)
  8006dc:	19 d2                	sbb    %edx,%edx
  8006de:	83 e2 20             	and    $0x20,%edx
  8006e1:	83 c2 41             	add    $0x41,%edx
  8006e4:	29 d6                	sub    %edx,%esi
  8006e6:	09 ce                	or     %ecx,%esi
        c = *++cp;
  8006e8:	0f be 10             	movsbl (%eax),%edx
  8006eb:	eb af                	jmp    80069c <inet_aton+0x63>
    }
    for (;;) {
      if (isdigit(c)) {
        val = (val * base) + (int)(c - '0');
        c = *++cp;
      } else if (base == 16 && isxdigit(c)) {
  8006ed:	89 d0                	mov    %edx,%eax
  8006ef:	89 f3                	mov    %esi,%ebx
  8006f1:	eb 04                	jmp    8006f7 <inet_aton+0xbe>
  8006f3:	89 d0                	mov    %edx,%eax
  8006f5:	89 f3                	mov    %esi,%ebx
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
        c = *++cp;
      } else
        break;
    }
    if (c == '.') {
  8006f7:	83 f8 2e             	cmp    $0x2e,%eax
  8006fa:	75 23                	jne    80071f <inet_aton+0xe6>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8006fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006ff:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
  800702:	0f 83 ee 00 00 00    	jae    8007f6 <inet_aton+0x1bd>
        return (0);
      *pp++ = val;
  800708:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80070b:	89 1a                	mov    %ebx,(%edx)
  80070d:	83 c2 04             	add    $0x4,%edx
  800710:	89 55 d4             	mov    %edx,-0x2c(%ebp)
      c = *++cp;
  800713:	8d 47 01             	lea    0x1(%edi),%eax
  800716:	0f be 57 01          	movsbl 0x1(%edi),%edx
    } else
      break;
  }
  80071a:	e9 35 ff ff ff       	jmp    800654 <inet_aton+0x1b>
  80071f:	89 f3                	mov    %esi,%ebx
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
        c = *++cp;
      } else
        break;
    }
    if (c == '.') {
  800721:	89 f0                	mov    %esi,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  800723:	85 d2                	test   %edx,%edx
  800725:	74 33                	je     80075a <inet_aton+0x121>
  800727:	80 f9 1f             	cmp    $0x1f,%cl
  80072a:	0f 86 cd 00 00 00    	jbe    8007fd <inet_aton+0x1c4>
  800730:	84 d2                	test   %dl,%dl
  800732:	0f 88 cc 00 00 00    	js     800804 <inet_aton+0x1cb>
  800738:	83 fa 20             	cmp    $0x20,%edx
  80073b:	74 1d                	je     80075a <inet_aton+0x121>
  80073d:	83 fa 0c             	cmp    $0xc,%edx
  800740:	74 18                	je     80075a <inet_aton+0x121>
  800742:	83 fa 0a             	cmp    $0xa,%edx
  800745:	74 13                	je     80075a <inet_aton+0x121>
  800747:	83 fa 0d             	cmp    $0xd,%edx
  80074a:	74 0e                	je     80075a <inet_aton+0x121>
  80074c:	83 fa 09             	cmp    $0x9,%edx
  80074f:	74 09                	je     80075a <inet_aton+0x121>
  800751:	83 fa 0b             	cmp    $0xb,%edx
  800754:	0f 85 b1 00 00 00    	jne    80080b <inet_aton+0x1d2>
    return (0);
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  80075a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80075d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800760:	29 d1                	sub    %edx,%ecx
  800762:	89 ca                	mov    %ecx,%edx
  800764:	c1 fa 02             	sar    $0x2,%edx
  800767:	42                   	inc    %edx
  switch (n) {
  800768:	83 fa 02             	cmp    $0x2,%edx
  80076b:	74 1b                	je     800788 <inet_aton+0x14f>
  80076d:	83 fa 02             	cmp    $0x2,%edx
  800770:	7f 0a                	jg     80077c <inet_aton+0x143>
  800772:	85 d2                	test   %edx,%edx
  800774:	0f 84 98 00 00 00    	je     800812 <inet_aton+0x1d9>
  80077a:	eb 59                	jmp    8007d5 <inet_aton+0x19c>
  80077c:	83 fa 03             	cmp    $0x3,%edx
  80077f:	74 1c                	je     80079d <inet_aton+0x164>
  800781:	83 fa 04             	cmp    $0x4,%edx
  800784:	75 4f                	jne    8007d5 <inet_aton+0x19c>
  800786:	eb 2e                	jmp    8007b6 <inet_aton+0x17d>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  800788:	3d ff ff ff 00       	cmp    $0xffffff,%eax
  80078d:	0f 87 86 00 00 00    	ja     800819 <inet_aton+0x1e0>
      return (0);
    val |= parts[0] << 24;
  800793:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800796:	c1 e3 18             	shl    $0x18,%ebx
  800799:	09 c3                	or     %eax,%ebx
    break;
  80079b:	eb 38                	jmp    8007d5 <inet_aton+0x19c>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  80079d:	3d ff ff 00 00       	cmp    $0xffff,%eax
  8007a2:	77 7c                	ja     800820 <inet_aton+0x1e7>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  8007a4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  8007a7:	c1 e3 10             	shl    $0x10,%ebx
  8007aa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007ad:	c1 e2 18             	shl    $0x18,%edx
  8007b0:	09 d3                	or     %edx,%ebx
  8007b2:	09 c3                	or     %eax,%ebx
    break;
  8007b4:	eb 1f                	jmp    8007d5 <inet_aton+0x19c>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  8007b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8007bb:	77 6a                	ja     800827 <inet_aton+0x1ee>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  8007bd:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  8007c0:	c1 e3 10             	shl    $0x10,%ebx
  8007c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007c6:	c1 e2 18             	shl    $0x18,%edx
  8007c9:	09 d3                	or     %edx,%ebx
  8007cb:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8007ce:	c1 e2 08             	shl    $0x8,%edx
  8007d1:	09 d3                	or     %edx,%ebx
  8007d3:	09 c3                	or     %eax,%ebx
    break;
  }
  if (addr)
  8007d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007d9:	74 53                	je     80082e <inet_aton+0x1f5>
    addr->s_addr = htonl(val);
  8007db:	89 1c 24             	mov    %ebx,(%esp)
  8007de:	e8 2a fe ff ff       	call   80060d <htonl>
  8007e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007e6:	89 03                	mov    %eax,(%ebx)
  return (1);
  8007e8:	b8 01 00 00 00       	mov    $0x1,%eax
  8007ed:	eb 44                	jmp    800833 <inet_aton+0x1fa>
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
      return (0);
  8007ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f4:	eb 3d                	jmp    800833 <inet_aton+0x1fa>
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fb:	eb 36                	jmp    800833 <inet_aton+0x1fa>
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
    return (0);
  8007fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800802:	eb 2f                	jmp    800833 <inet_aton+0x1fa>
  800804:	b8 00 00 00 00       	mov    $0x0,%eax
  800809:	eb 28                	jmp    800833 <inet_aton+0x1fa>
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
  800810:	eb 21                	jmp    800833 <inet_aton+0x1fa>
   */
  n = pp - parts + 1;
  switch (n) {

  case 0:
    return (0);       /* initial nondigit */
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
  800817:	eb 1a                	jmp    800833 <inet_aton+0x1fa>
  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
      return (0);
  800819:	b8 00 00 00 00       	mov    $0x0,%eax
  80081e:	eb 13                	jmp    800833 <inet_aton+0x1fa>
    val |= parts[0] << 24;
    break;

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
      return (0);
  800820:	b8 00 00 00 00       	mov    $0x0,%eax
  800825:	eb 0c                	jmp    800833 <inet_aton+0x1fa>
    val |= (parts[0] << 24) | (parts[1] << 16);
    break;

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
      return (0);
  800827:	b8 00 00 00 00       	mov    $0x0,%eax
  80082c:	eb 05                	jmp    800833 <inet_aton+0x1fa>
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
    break;
  }
  if (addr)
    addr->s_addr = htonl(val);
  return (1);
  80082e:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800833:	83 c4 24             	add    $0x24,%esp
  800836:	5b                   	pop    %ebx
  800837:	5e                   	pop    %esi
  800838:	5f                   	pop    %edi
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  800841:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800844:	89 44 24 04          	mov    %eax,0x4(%esp)
  800848:	8b 45 08             	mov    0x8(%ebp),%eax
  80084b:	89 04 24             	mov    %eax,(%esp)
  80084e:	e8 e6 fd ff ff       	call   800639 <inet_aton>
  800853:	85 c0                	test   %eax,%eax
  800855:	74 05                	je     80085c <inet_addr+0x21>
    return (val.s_addr);
  800857:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80085a:	eb 05                	jmp    800861 <inet_addr+0x26>
  }
  return (INADDR_NONE);
  80085c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
  800861:	c9                   	leave  
  800862:	c3                   	ret    

00800863 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  800869:	8b 45 08             	mov    0x8(%ebp),%eax
  80086c:	89 04 24             	mov    %eax,(%esp)
  80086f:	e8 99 fd ff ff       	call   80060d <htonl>
}
  800874:	c9                   	leave  
  800875:	c3                   	ret    
	...

00800878 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
  80087d:	83 ec 10             	sub    $0x10,%esp
  800880:	8b 75 08             	mov    0x8(%ebp),%esi
  800883:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800886:	e8 b4 0a 00 00       	call   80133f <sys_getenvid>
  80088b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800890:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800897:	c1 e0 07             	shl    $0x7,%eax
  80089a:	29 d0                	sub    %edx,%eax
  80089c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8008a1:	a3 1c 50 80 00       	mov    %eax,0x80501c


	// save the name of the program so that panic() can use it
	if (argc > 0)
  8008a6:	85 f6                	test   %esi,%esi
  8008a8:	7e 07                	jle    8008b1 <libmain+0x39>
		binaryname = argv[0];
  8008aa:	8b 03                	mov    (%ebx),%eax
  8008ac:	a3 20 40 80 00       	mov    %eax,0x804020

	// call user main routine
	umain(argc, argv);
  8008b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8008b5:	89 34 24             	mov    %esi,(%esp)
  8008b8:	e8 89 fb ff ff       	call   800446 <umain>

	// exit gracefully
	exit();
  8008bd:	e8 0a 00 00 00       	call   8008cc <exit>
}
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    
  8008c9:	00 00                	add    %al,(%eax)
	...

008008cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8008cc:	55                   	push   %ebp
  8008cd:	89 e5                	mov    %esp,%ebp
  8008cf:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8008d2:	e8 58 0f 00 00       	call   80182f <close_all>
	sys_env_destroy(0);
  8008d7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8008de:	e8 0a 0a 00 00       	call   8012ed <sys_env_destroy>
}
  8008e3:	c9                   	leave  
  8008e4:	c3                   	ret    
  8008e5:	00 00                	add    %al,(%eax)
	...

008008e8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
  8008ed:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8008f0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8008f3:	8b 1d 20 40 80 00    	mov    0x804020,%ebx
  8008f9:	e8 41 0a 00 00       	call   80133f <sys_getenvid>
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800901:	89 54 24 10          	mov    %edx,0x10(%esp)
  800905:	8b 55 08             	mov    0x8(%ebp),%edx
  800908:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80090c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800910:	89 44 24 04          	mov    %eax,0x4(%esp)
  800914:	c7 04 24 3c 31 80 00 	movl   $0x80313c,(%esp)
  80091b:	e8 c0 00 00 00       	call   8009e0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800920:	89 74 24 04          	mov    %esi,0x4(%esp)
  800924:	8b 45 10             	mov    0x10(%ebp),%eax
  800927:	89 04 24             	mov    %eax,(%esp)
  80092a:	e8 50 00 00 00       	call   80097f <vcprintf>
	cprintf("\n");
  80092f:	c7 04 24 8b 2f 80 00 	movl   $0x802f8b,(%esp)
  800936:	e8 a5 00 00 00       	call   8009e0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80093b:	cc                   	int3   
  80093c:	eb fd                	jmp    80093b <_panic+0x53>
	...

00800940 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	53                   	push   %ebx
  800944:	83 ec 14             	sub    $0x14,%esp
  800947:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80094a:	8b 03                	mov    (%ebx),%eax
  80094c:	8b 55 08             	mov    0x8(%ebp),%edx
  80094f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800953:	40                   	inc    %eax
  800954:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800956:	3d ff 00 00 00       	cmp    $0xff,%eax
  80095b:	75 19                	jne    800976 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80095d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800964:	00 
  800965:	8d 43 08             	lea    0x8(%ebx),%eax
  800968:	89 04 24             	mov    %eax,(%esp)
  80096b:	e8 40 09 00 00       	call   8012b0 <sys_cputs>
		b->idx = 0;
  800970:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800976:	ff 43 04             	incl   0x4(%ebx)
}
  800979:	83 c4 14             	add    $0x14,%esp
  80097c:	5b                   	pop    %ebx
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800988:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80098f:	00 00 00 
	b.cnt = 0;
  800992:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800999:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80099c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8009b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b4:	c7 04 24 40 09 80 00 	movl   $0x800940,(%esp)
  8009bb:	e8 82 01 00 00       	call   800b42 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8009c0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8009c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ca:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8009d0:	89 04 24             	mov    %eax,(%esp)
  8009d3:	e8 d8 08 00 00       	call   8012b0 <sys_cputs>

	return b.cnt;
}
  8009d8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8009e6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8009e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	89 04 24             	mov    %eax,(%esp)
  8009f3:	e8 87 ff ff ff       	call   80097f <vcprintf>
	va_end(ap);

	return cnt;
}
  8009f8:	c9                   	leave  
  8009f9:	c3                   	ret    
	...

008009fc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	57                   	push   %edi
  800a00:	56                   	push   %esi
  800a01:	53                   	push   %ebx
  800a02:	83 ec 3c             	sub    $0x3c,%esp
  800a05:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a08:	89 d7                	mov    %edx,%edi
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800a10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a13:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a16:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800a19:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800a1c:	85 c0                	test   %eax,%eax
  800a1e:	75 08                	jne    800a28 <printnum+0x2c>
  800a20:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a23:	39 45 10             	cmp    %eax,0x10(%ebp)
  800a26:	77 57                	ja     800a7f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800a28:	89 74 24 10          	mov    %esi,0x10(%esp)
  800a2c:	4b                   	dec    %ebx
  800a2d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800a31:	8b 45 10             	mov    0x10(%ebp),%eax
  800a34:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a38:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800a3c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800a40:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a47:	00 
  800a48:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a4b:	89 04 24             	mov    %eax,(%esp)
  800a4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a55:	e8 8a 22 00 00       	call   802ce4 <__udivdi3>
  800a5a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800a5e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a62:	89 04 24             	mov    %eax,(%esp)
  800a65:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a69:	89 fa                	mov    %edi,%edx
  800a6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a6e:	e8 89 ff ff ff       	call   8009fc <printnum>
  800a73:	eb 0f                	jmp    800a84 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800a75:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a79:	89 34 24             	mov    %esi,(%esp)
  800a7c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800a7f:	4b                   	dec    %ebx
  800a80:	85 db                	test   %ebx,%ebx
  800a82:	7f f1                	jg     800a75 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800a84:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a88:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a93:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800a9a:	00 
  800a9b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a9e:	89 04 24             	mov    %eax,(%esp)
  800aa1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa8:	e8 57 23 00 00       	call   802e04 <__umoddi3>
  800aad:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ab1:	0f be 80 5f 31 80 00 	movsbl 0x80315f(%eax),%eax
  800ab8:	89 04 24             	mov    %eax,(%esp)
  800abb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800abe:	83 c4 3c             	add    $0x3c,%esp
  800ac1:	5b                   	pop    %ebx
  800ac2:	5e                   	pop    %esi
  800ac3:	5f                   	pop    %edi
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800ac9:	83 fa 01             	cmp    $0x1,%edx
  800acc:	7e 0e                	jle    800adc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800ace:	8b 10                	mov    (%eax),%edx
  800ad0:	8d 4a 08             	lea    0x8(%edx),%ecx
  800ad3:	89 08                	mov    %ecx,(%eax)
  800ad5:	8b 02                	mov    (%edx),%eax
  800ad7:	8b 52 04             	mov    0x4(%edx),%edx
  800ada:	eb 22                	jmp    800afe <getuint+0x38>
	else if (lflag)
  800adc:	85 d2                	test   %edx,%edx
  800ade:	74 10                	je     800af0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800ae0:	8b 10                	mov    (%eax),%edx
  800ae2:	8d 4a 04             	lea    0x4(%edx),%ecx
  800ae5:	89 08                	mov    %ecx,(%eax)
  800ae7:	8b 02                	mov    (%edx),%eax
  800ae9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aee:	eb 0e                	jmp    800afe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800af0:	8b 10                	mov    (%eax),%edx
  800af2:	8d 4a 04             	lea    0x4(%edx),%ecx
  800af5:	89 08                	mov    %ecx,(%eax)
  800af7:	8b 02                	mov    (%edx),%eax
  800af9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b00:	55                   	push   %ebp
  800b01:	89 e5                	mov    %esp,%ebp
  800b03:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800b06:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800b09:	8b 10                	mov    (%eax),%edx
  800b0b:	3b 50 04             	cmp    0x4(%eax),%edx
  800b0e:	73 08                	jae    800b18 <sprintputch+0x18>
		*b->buf++ = ch;
  800b10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b13:	88 0a                	mov    %cl,(%edx)
  800b15:	42                   	inc    %edx
  800b16:	89 10                	mov    %edx,(%eax)
}
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800b20:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800b23:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b27:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b35:	8b 45 08             	mov    0x8(%ebp),%eax
  800b38:	89 04 24             	mov    %eax,(%esp)
  800b3b:	e8 02 00 00 00       	call   800b42 <vprintfmt>
	va_end(ap);
}
  800b40:	c9                   	leave  
  800b41:	c3                   	ret    

00800b42 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
  800b48:	83 ec 4c             	sub    $0x4c,%esp
  800b4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b4e:	8b 75 10             	mov    0x10(%ebp),%esi
  800b51:	eb 12                	jmp    800b65 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800b53:	85 c0                	test   %eax,%eax
  800b55:	0f 84 6b 03 00 00    	je     800ec6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800b5b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b5f:	89 04 24             	mov    %eax,(%esp)
  800b62:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b65:	0f b6 06             	movzbl (%esi),%eax
  800b68:	46                   	inc    %esi
  800b69:	83 f8 25             	cmp    $0x25,%eax
  800b6c:	75 e5                	jne    800b53 <vprintfmt+0x11>
  800b6e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800b72:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800b79:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800b7e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800b85:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8a:	eb 26                	jmp    800bb2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b8c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800b8f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800b93:	eb 1d                	jmp    800bb2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b95:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800b98:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800b9c:	eb 14                	jmp    800bb2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b9e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800ba1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800ba8:	eb 08                	jmp    800bb2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800baa:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800bad:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bb2:	0f b6 06             	movzbl (%esi),%eax
  800bb5:	8d 56 01             	lea    0x1(%esi),%edx
  800bb8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800bbb:	8a 16                	mov    (%esi),%dl
  800bbd:	83 ea 23             	sub    $0x23,%edx
  800bc0:	80 fa 55             	cmp    $0x55,%dl
  800bc3:	0f 87 e1 02 00 00    	ja     800eaa <vprintfmt+0x368>
  800bc9:	0f b6 d2             	movzbl %dl,%edx
  800bcc:	ff 24 95 a0 32 80 00 	jmp    *0x8032a0(,%edx,4)
  800bd3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800bd6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800bdb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800bde:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800be2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800be5:	8d 50 d0             	lea    -0x30(%eax),%edx
  800be8:	83 fa 09             	cmp    $0x9,%edx
  800beb:	77 2a                	ja     800c17 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800bed:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800bee:	eb eb                	jmp    800bdb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800bf0:	8b 45 14             	mov    0x14(%ebp),%eax
  800bf3:	8d 50 04             	lea    0x4(%eax),%edx
  800bf6:	89 55 14             	mov    %edx,0x14(%ebp)
  800bf9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bfb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800bfe:	eb 17                	jmp    800c17 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800c00:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c04:	78 98                	js     800b9e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c06:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c09:	eb a7                	jmp    800bb2 <vprintfmt+0x70>
  800c0b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800c0e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800c15:	eb 9b                	jmp    800bb2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800c17:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c1b:	79 95                	jns    800bb2 <vprintfmt+0x70>
  800c1d:	eb 8b                	jmp    800baa <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800c1f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c20:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800c23:	eb 8d                	jmp    800bb2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800c25:	8b 45 14             	mov    0x14(%ebp),%eax
  800c28:	8d 50 04             	lea    0x4(%eax),%edx
  800c2b:	89 55 14             	mov    %edx,0x14(%ebp)
  800c2e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c32:	8b 00                	mov    (%eax),%eax
  800c34:	89 04 24             	mov    %eax,(%esp)
  800c37:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c3a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800c3d:	e9 23 ff ff ff       	jmp    800b65 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800c42:	8b 45 14             	mov    0x14(%ebp),%eax
  800c45:	8d 50 04             	lea    0x4(%eax),%edx
  800c48:	89 55 14             	mov    %edx,0x14(%ebp)
  800c4b:	8b 00                	mov    (%eax),%eax
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	79 02                	jns    800c53 <vprintfmt+0x111>
  800c51:	f7 d8                	neg    %eax
  800c53:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800c55:	83 f8 10             	cmp    $0x10,%eax
  800c58:	7f 0b                	jg     800c65 <vprintfmt+0x123>
  800c5a:	8b 04 85 00 34 80 00 	mov    0x803400(,%eax,4),%eax
  800c61:	85 c0                	test   %eax,%eax
  800c63:	75 23                	jne    800c88 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800c65:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c69:	c7 44 24 08 77 31 80 	movl   $0x803177,0x8(%esp)
  800c70:	00 
  800c71:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c75:	8b 45 08             	mov    0x8(%ebp),%eax
  800c78:	89 04 24             	mov    %eax,(%esp)
  800c7b:	e8 9a fe ff ff       	call   800b1a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c80:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800c83:	e9 dd fe ff ff       	jmp    800b65 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800c88:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c8c:	c7 44 24 08 39 35 80 	movl   $0x803539,0x8(%esp)
  800c93:	00 
  800c94:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	89 14 24             	mov    %edx,(%esp)
  800c9e:	e8 77 fe ff ff       	call   800b1a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ca6:	e9 ba fe ff ff       	jmp    800b65 <vprintfmt+0x23>
  800cab:	89 f9                	mov    %edi,%ecx
  800cad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cb0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800cb3:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb6:	8d 50 04             	lea    0x4(%eax),%edx
  800cb9:	89 55 14             	mov    %edx,0x14(%ebp)
  800cbc:	8b 30                	mov    (%eax),%esi
  800cbe:	85 f6                	test   %esi,%esi
  800cc0:	75 05                	jne    800cc7 <vprintfmt+0x185>
				p = "(null)";
  800cc2:	be 70 31 80 00       	mov    $0x803170,%esi
			if (width > 0 && padc != '-')
  800cc7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800ccb:	0f 8e 84 00 00 00    	jle    800d55 <vprintfmt+0x213>
  800cd1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800cd5:	74 7e                	je     800d55 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800cd7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800cdb:	89 34 24             	mov    %esi,(%esp)
  800cde:	e8 8b 02 00 00       	call   800f6e <strnlen>
  800ce3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800ce6:	29 c2                	sub    %eax,%edx
  800ce8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800ceb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800cef:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800cf2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800cf5:	89 de                	mov    %ebx,%esi
  800cf7:	89 d3                	mov    %edx,%ebx
  800cf9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800cfb:	eb 0b                	jmp    800d08 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800cfd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d01:	89 3c 24             	mov    %edi,(%esp)
  800d04:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800d07:	4b                   	dec    %ebx
  800d08:	85 db                	test   %ebx,%ebx
  800d0a:	7f f1                	jg     800cfd <vprintfmt+0x1bb>
  800d0c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800d0f:	89 f3                	mov    %esi,%ebx
  800d11:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800d14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d17:	85 c0                	test   %eax,%eax
  800d19:	79 05                	jns    800d20 <vprintfmt+0x1de>
  800d1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d20:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d23:	29 c2                	sub    %eax,%edx
  800d25:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d28:	eb 2b                	jmp    800d55 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800d2a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d2e:	74 18                	je     800d48 <vprintfmt+0x206>
  800d30:	8d 50 e0             	lea    -0x20(%eax),%edx
  800d33:	83 fa 5e             	cmp    $0x5e,%edx
  800d36:	76 10                	jbe    800d48 <vprintfmt+0x206>
					putch('?', putdat);
  800d38:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d3c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800d43:	ff 55 08             	call   *0x8(%ebp)
  800d46:	eb 0a                	jmp    800d52 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800d48:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d4c:	89 04 24             	mov    %eax,(%esp)
  800d4f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800d52:	ff 4d e4             	decl   -0x1c(%ebp)
  800d55:	0f be 06             	movsbl (%esi),%eax
  800d58:	46                   	inc    %esi
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	74 21                	je     800d7e <vprintfmt+0x23c>
  800d5d:	85 ff                	test   %edi,%edi
  800d5f:	78 c9                	js     800d2a <vprintfmt+0x1e8>
  800d61:	4f                   	dec    %edi
  800d62:	79 c6                	jns    800d2a <vprintfmt+0x1e8>
  800d64:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d67:	89 de                	mov    %ebx,%esi
  800d69:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800d6c:	eb 18                	jmp    800d86 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800d6e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d72:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800d79:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800d7b:	4b                   	dec    %ebx
  800d7c:	eb 08                	jmp    800d86 <vprintfmt+0x244>
  800d7e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d81:	89 de                	mov    %ebx,%esi
  800d83:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800d86:	85 db                	test   %ebx,%ebx
  800d88:	7f e4                	jg     800d6e <vprintfmt+0x22c>
  800d8a:	89 7d 08             	mov    %edi,0x8(%ebp)
  800d8d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d8f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d92:	e9 ce fd ff ff       	jmp    800b65 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800d97:	83 f9 01             	cmp    $0x1,%ecx
  800d9a:	7e 10                	jle    800dac <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800d9c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d9f:	8d 50 08             	lea    0x8(%eax),%edx
  800da2:	89 55 14             	mov    %edx,0x14(%ebp)
  800da5:	8b 30                	mov    (%eax),%esi
  800da7:	8b 78 04             	mov    0x4(%eax),%edi
  800daa:	eb 26                	jmp    800dd2 <vprintfmt+0x290>
	else if (lflag)
  800dac:	85 c9                	test   %ecx,%ecx
  800dae:	74 12                	je     800dc2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800db0:	8b 45 14             	mov    0x14(%ebp),%eax
  800db3:	8d 50 04             	lea    0x4(%eax),%edx
  800db6:	89 55 14             	mov    %edx,0x14(%ebp)
  800db9:	8b 30                	mov    (%eax),%esi
  800dbb:	89 f7                	mov    %esi,%edi
  800dbd:	c1 ff 1f             	sar    $0x1f,%edi
  800dc0:	eb 10                	jmp    800dd2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800dc2:	8b 45 14             	mov    0x14(%ebp),%eax
  800dc5:	8d 50 04             	lea    0x4(%eax),%edx
  800dc8:	89 55 14             	mov    %edx,0x14(%ebp)
  800dcb:	8b 30                	mov    (%eax),%esi
  800dcd:	89 f7                	mov    %esi,%edi
  800dcf:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800dd2:	85 ff                	test   %edi,%edi
  800dd4:	78 0a                	js     800de0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800dd6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ddb:	e9 8c 00 00 00       	jmp    800e6c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800de0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800de4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800deb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800dee:	f7 de                	neg    %esi
  800df0:	83 d7 00             	adc    $0x0,%edi
  800df3:	f7 df                	neg    %edi
			}
			base = 10;
  800df5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dfa:	eb 70                	jmp    800e6c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800dfc:	89 ca                	mov    %ecx,%edx
  800dfe:	8d 45 14             	lea    0x14(%ebp),%eax
  800e01:	e8 c0 fc ff ff       	call   800ac6 <getuint>
  800e06:	89 c6                	mov    %eax,%esi
  800e08:	89 d7                	mov    %edx,%edi
			base = 10;
  800e0a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800e0f:	eb 5b                	jmp    800e6c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800e11:	89 ca                	mov    %ecx,%edx
  800e13:	8d 45 14             	lea    0x14(%ebp),%eax
  800e16:	e8 ab fc ff ff       	call   800ac6 <getuint>
  800e1b:	89 c6                	mov    %eax,%esi
  800e1d:	89 d7                	mov    %edx,%edi
			base = 8;
  800e1f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800e24:	eb 46                	jmp    800e6c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800e26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e2a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800e31:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800e34:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e38:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800e3f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800e42:	8b 45 14             	mov    0x14(%ebp),%eax
  800e45:	8d 50 04             	lea    0x4(%eax),%edx
  800e48:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800e4b:	8b 30                	mov    (%eax),%esi
  800e4d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800e52:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800e57:	eb 13                	jmp    800e6c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800e59:	89 ca                	mov    %ecx,%edx
  800e5b:	8d 45 14             	lea    0x14(%ebp),%eax
  800e5e:	e8 63 fc ff ff       	call   800ac6 <getuint>
  800e63:	89 c6                	mov    %eax,%esi
  800e65:	89 d7                	mov    %edx,%edi
			base = 16;
  800e67:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800e6c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800e70:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e74:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800e77:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e7f:	89 34 24             	mov    %esi,(%esp)
  800e82:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e86:	89 da                	mov    %ebx,%edx
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8b:	e8 6c fb ff ff       	call   8009fc <printnum>
			break;
  800e90:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800e93:	e9 cd fc ff ff       	jmp    800b65 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800e98:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e9c:	89 04 24             	mov    %eax,(%esp)
  800e9f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ea2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800ea5:	e9 bb fc ff ff       	jmp    800b65 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800eaa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800eae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800eb5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800eb8:	eb 01                	jmp    800ebb <vprintfmt+0x379>
  800eba:	4e                   	dec    %esi
  800ebb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800ebf:	75 f9                	jne    800eba <vprintfmt+0x378>
  800ec1:	e9 9f fc ff ff       	jmp    800b65 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800ec6:	83 c4 4c             	add    $0x4c,%esp
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5f                   	pop    %edi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	83 ec 28             	sub    $0x28,%esp
  800ed4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800eda:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800edd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ee1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ee4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	74 30                	je     800f1f <vsnprintf+0x51>
  800eef:	85 d2                	test   %edx,%edx
  800ef1:	7e 33                	jle    800f26 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ef3:	8b 45 14             	mov    0x14(%ebp),%eax
  800ef6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800efa:	8b 45 10             	mov    0x10(%ebp),%eax
  800efd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f01:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f04:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f08:	c7 04 24 00 0b 80 00 	movl   $0x800b00,(%esp)
  800f0f:	e8 2e fc ff ff       	call   800b42 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f14:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f17:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f1d:	eb 0c                	jmp    800f2b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800f1f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f24:	eb 05                	jmp    800f2b <vsnprintf+0x5d>
  800f26:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800f2b:	c9                   	leave  
  800f2c:	c3                   	ret    

00800f2d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800f33:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800f36:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f3a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f41:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f44:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f48:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4b:	89 04 24             	mov    %eax,(%esp)
  800f4e:	e8 7b ff ff ff       	call   800ece <vsnprintf>
	va_end(ap);

	return rc;
}
  800f53:	c9                   	leave  
  800f54:	c3                   	ret    
  800f55:	00 00                	add    %al,(%eax)
	...

00800f58 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800f5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f63:	eb 01                	jmp    800f66 <strlen+0xe>
		n++;
  800f65:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800f66:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800f6a:	75 f9                	jne    800f65 <strlen+0xd>
		n++;
	return n;
}
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    

00800f6e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800f74:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f77:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7c:	eb 01                	jmp    800f7f <strnlen+0x11>
		n++;
  800f7e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800f7f:	39 d0                	cmp    %edx,%eax
  800f81:	74 06                	je     800f89 <strnlen+0x1b>
  800f83:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800f87:	75 f5                	jne    800f7e <strnlen+0x10>
		n++;
	return n;
}
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    

00800f8b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	53                   	push   %ebx
  800f8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800f95:	ba 00 00 00 00       	mov    $0x0,%edx
  800f9a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800f9d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800fa0:	42                   	inc    %edx
  800fa1:	84 c9                	test   %cl,%cl
  800fa3:	75 f5                	jne    800f9a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800fa5:	5b                   	pop    %ebx
  800fa6:	5d                   	pop    %ebp
  800fa7:	c3                   	ret    

00800fa8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	53                   	push   %ebx
  800fac:	83 ec 08             	sub    $0x8,%esp
  800faf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800fb2:	89 1c 24             	mov    %ebx,(%esp)
  800fb5:	e8 9e ff ff ff       	call   800f58 <strlen>
	strcpy(dst + len, src);
  800fba:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fbd:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc1:	01 d8                	add    %ebx,%eax
  800fc3:	89 04 24             	mov    %eax,(%esp)
  800fc6:	e8 c0 ff ff ff       	call   800f8b <strcpy>
	return dst;
}
  800fcb:	89 d8                	mov    %ebx,%eax
  800fcd:	83 c4 08             	add    $0x8,%esp
  800fd0:	5b                   	pop    %ebx
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	56                   	push   %esi
  800fd7:	53                   	push   %ebx
  800fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fde:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800fe1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe6:	eb 0c                	jmp    800ff4 <strncpy+0x21>
		*dst++ = *src;
  800fe8:	8a 1a                	mov    (%edx),%bl
  800fea:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800fed:	80 3a 01             	cmpb   $0x1,(%edx)
  800ff0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ff3:	41                   	inc    %ecx
  800ff4:	39 f1                	cmp    %esi,%ecx
  800ff6:	75 f0                	jne    800fe8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	56                   	push   %esi
  801000:	53                   	push   %ebx
  801001:	8b 75 08             	mov    0x8(%ebp),%esi
  801004:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801007:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80100a:	85 d2                	test   %edx,%edx
  80100c:	75 0a                	jne    801018 <strlcpy+0x1c>
  80100e:	89 f0                	mov    %esi,%eax
  801010:	eb 1a                	jmp    80102c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801012:	88 18                	mov    %bl,(%eax)
  801014:	40                   	inc    %eax
  801015:	41                   	inc    %ecx
  801016:	eb 02                	jmp    80101a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801018:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80101a:	4a                   	dec    %edx
  80101b:	74 0a                	je     801027 <strlcpy+0x2b>
  80101d:	8a 19                	mov    (%ecx),%bl
  80101f:	84 db                	test   %bl,%bl
  801021:	75 ef                	jne    801012 <strlcpy+0x16>
  801023:	89 c2                	mov    %eax,%edx
  801025:	eb 02                	jmp    801029 <strlcpy+0x2d>
  801027:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801029:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80102c:	29 f0                	sub    %esi,%eax
}
  80102e:	5b                   	pop    %ebx
  80102f:	5e                   	pop    %esi
  801030:	5d                   	pop    %ebp
  801031:	c3                   	ret    

00801032 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801038:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80103b:	eb 02                	jmp    80103f <strcmp+0xd>
		p++, q++;
  80103d:	41                   	inc    %ecx
  80103e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80103f:	8a 01                	mov    (%ecx),%al
  801041:	84 c0                	test   %al,%al
  801043:	74 04                	je     801049 <strcmp+0x17>
  801045:	3a 02                	cmp    (%edx),%al
  801047:	74 f4                	je     80103d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801049:	0f b6 c0             	movzbl %al,%eax
  80104c:	0f b6 12             	movzbl (%edx),%edx
  80104f:	29 d0                	sub    %edx,%eax
}
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	53                   	push   %ebx
  801057:	8b 45 08             	mov    0x8(%ebp),%eax
  80105a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80105d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801060:	eb 03                	jmp    801065 <strncmp+0x12>
		n--, p++, q++;
  801062:	4a                   	dec    %edx
  801063:	40                   	inc    %eax
  801064:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801065:	85 d2                	test   %edx,%edx
  801067:	74 14                	je     80107d <strncmp+0x2a>
  801069:	8a 18                	mov    (%eax),%bl
  80106b:	84 db                	test   %bl,%bl
  80106d:	74 04                	je     801073 <strncmp+0x20>
  80106f:	3a 19                	cmp    (%ecx),%bl
  801071:	74 ef                	je     801062 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801073:	0f b6 00             	movzbl (%eax),%eax
  801076:	0f b6 11             	movzbl (%ecx),%edx
  801079:	29 d0                	sub    %edx,%eax
  80107b:	eb 05                	jmp    801082 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80107d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801082:	5b                   	pop    %ebx
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    

00801085 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	8b 45 08             	mov    0x8(%ebp),%eax
  80108b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80108e:	eb 05                	jmp    801095 <strchr+0x10>
		if (*s == c)
  801090:	38 ca                	cmp    %cl,%dl
  801092:	74 0c                	je     8010a0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801094:	40                   	inc    %eax
  801095:	8a 10                	mov    (%eax),%dl
  801097:	84 d2                	test   %dl,%dl
  801099:	75 f5                	jne    801090 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  80109b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010a0:	5d                   	pop    %ebp
  8010a1:	c3                   	ret    

008010a2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8010ab:	eb 05                	jmp    8010b2 <strfind+0x10>
		if (*s == c)
  8010ad:	38 ca                	cmp    %cl,%dl
  8010af:	74 07                	je     8010b8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8010b1:	40                   	inc    %eax
  8010b2:	8a 10                	mov    (%eax),%dl
  8010b4:	84 d2                	test   %dl,%dl
  8010b6:	75 f5                	jne    8010ad <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    

008010ba <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	57                   	push   %edi
  8010be:	56                   	push   %esi
  8010bf:	53                   	push   %ebx
  8010c0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8010c9:	85 c9                	test   %ecx,%ecx
  8010cb:	74 30                	je     8010fd <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8010cd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8010d3:	75 25                	jne    8010fa <memset+0x40>
  8010d5:	f6 c1 03             	test   $0x3,%cl
  8010d8:	75 20                	jne    8010fa <memset+0x40>
		c &= 0xFF;
  8010da:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8010dd:	89 d3                	mov    %edx,%ebx
  8010df:	c1 e3 08             	shl    $0x8,%ebx
  8010e2:	89 d6                	mov    %edx,%esi
  8010e4:	c1 e6 18             	shl    $0x18,%esi
  8010e7:	89 d0                	mov    %edx,%eax
  8010e9:	c1 e0 10             	shl    $0x10,%eax
  8010ec:	09 f0                	or     %esi,%eax
  8010ee:	09 d0                	or     %edx,%eax
  8010f0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8010f2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8010f5:	fc                   	cld    
  8010f6:	f3 ab                	rep stos %eax,%es:(%edi)
  8010f8:	eb 03                	jmp    8010fd <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8010fa:	fc                   	cld    
  8010fb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8010fd:	89 f8                	mov    %edi,%eax
  8010ff:	5b                   	pop    %ebx
  801100:	5e                   	pop    %esi
  801101:	5f                   	pop    %edi
  801102:	5d                   	pop    %ebp
  801103:	c3                   	ret    

00801104 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	57                   	push   %edi
  801108:	56                   	push   %esi
  801109:	8b 45 08             	mov    0x8(%ebp),%eax
  80110c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80110f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801112:	39 c6                	cmp    %eax,%esi
  801114:	73 34                	jae    80114a <memmove+0x46>
  801116:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801119:	39 d0                	cmp    %edx,%eax
  80111b:	73 2d                	jae    80114a <memmove+0x46>
		s += n;
		d += n;
  80111d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801120:	f6 c2 03             	test   $0x3,%dl
  801123:	75 1b                	jne    801140 <memmove+0x3c>
  801125:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80112b:	75 13                	jne    801140 <memmove+0x3c>
  80112d:	f6 c1 03             	test   $0x3,%cl
  801130:	75 0e                	jne    801140 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801132:	83 ef 04             	sub    $0x4,%edi
  801135:	8d 72 fc             	lea    -0x4(%edx),%esi
  801138:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80113b:	fd                   	std    
  80113c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80113e:	eb 07                	jmp    801147 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801140:	4f                   	dec    %edi
  801141:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801144:	fd                   	std    
  801145:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801147:	fc                   	cld    
  801148:	eb 20                	jmp    80116a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80114a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801150:	75 13                	jne    801165 <memmove+0x61>
  801152:	a8 03                	test   $0x3,%al
  801154:	75 0f                	jne    801165 <memmove+0x61>
  801156:	f6 c1 03             	test   $0x3,%cl
  801159:	75 0a                	jne    801165 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80115b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80115e:	89 c7                	mov    %eax,%edi
  801160:	fc                   	cld    
  801161:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801163:	eb 05                	jmp    80116a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801165:	89 c7                	mov    %eax,%edi
  801167:	fc                   	cld    
  801168:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80116a:	5e                   	pop    %esi
  80116b:	5f                   	pop    %edi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    

0080116e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801174:	8b 45 10             	mov    0x10(%ebp),%eax
  801177:	89 44 24 08          	mov    %eax,0x8(%esp)
  80117b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801182:	8b 45 08             	mov    0x8(%ebp),%eax
  801185:	89 04 24             	mov    %eax,(%esp)
  801188:	e8 77 ff ff ff       	call   801104 <memmove>
}
  80118d:	c9                   	leave  
  80118e:	c3                   	ret    

0080118f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80118f:	55                   	push   %ebp
  801190:	89 e5                	mov    %esp,%ebp
  801192:	57                   	push   %edi
  801193:	56                   	push   %esi
  801194:	53                   	push   %ebx
  801195:	8b 7d 08             	mov    0x8(%ebp),%edi
  801198:	8b 75 0c             	mov    0xc(%ebp),%esi
  80119b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80119e:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a3:	eb 16                	jmp    8011bb <memcmp+0x2c>
		if (*s1 != *s2)
  8011a5:	8a 04 17             	mov    (%edi,%edx,1),%al
  8011a8:	42                   	inc    %edx
  8011a9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8011ad:	38 c8                	cmp    %cl,%al
  8011af:	74 0a                	je     8011bb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8011b1:	0f b6 c0             	movzbl %al,%eax
  8011b4:	0f b6 c9             	movzbl %cl,%ecx
  8011b7:	29 c8                	sub    %ecx,%eax
  8011b9:	eb 09                	jmp    8011c4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8011bb:	39 da                	cmp    %ebx,%edx
  8011bd:	75 e6                	jne    8011a5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8011bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011c4:	5b                   	pop    %ebx
  8011c5:	5e                   	pop    %esi
  8011c6:	5f                   	pop    %edi
  8011c7:	5d                   	pop    %ebp
  8011c8:	c3                   	ret    

008011c9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8011c9:	55                   	push   %ebp
  8011ca:	89 e5                	mov    %esp,%ebp
  8011cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8011d7:	eb 05                	jmp    8011de <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8011d9:	38 08                	cmp    %cl,(%eax)
  8011db:	74 05                	je     8011e2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8011dd:	40                   	inc    %eax
  8011de:	39 d0                	cmp    %edx,%eax
  8011e0:	72 f7                	jb     8011d9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	57                   	push   %edi
  8011e8:	56                   	push   %esi
  8011e9:	53                   	push   %ebx
  8011ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8011f0:	eb 01                	jmp    8011f3 <strtol+0xf>
		s++;
  8011f2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8011f3:	8a 02                	mov    (%edx),%al
  8011f5:	3c 20                	cmp    $0x20,%al
  8011f7:	74 f9                	je     8011f2 <strtol+0xe>
  8011f9:	3c 09                	cmp    $0x9,%al
  8011fb:	74 f5                	je     8011f2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8011fd:	3c 2b                	cmp    $0x2b,%al
  8011ff:	75 08                	jne    801209 <strtol+0x25>
		s++;
  801201:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801202:	bf 00 00 00 00       	mov    $0x0,%edi
  801207:	eb 13                	jmp    80121c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801209:	3c 2d                	cmp    $0x2d,%al
  80120b:	75 0a                	jne    801217 <strtol+0x33>
		s++, neg = 1;
  80120d:	8d 52 01             	lea    0x1(%edx),%edx
  801210:	bf 01 00 00 00       	mov    $0x1,%edi
  801215:	eb 05                	jmp    80121c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801217:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80121c:	85 db                	test   %ebx,%ebx
  80121e:	74 05                	je     801225 <strtol+0x41>
  801220:	83 fb 10             	cmp    $0x10,%ebx
  801223:	75 28                	jne    80124d <strtol+0x69>
  801225:	8a 02                	mov    (%edx),%al
  801227:	3c 30                	cmp    $0x30,%al
  801229:	75 10                	jne    80123b <strtol+0x57>
  80122b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80122f:	75 0a                	jne    80123b <strtol+0x57>
		s += 2, base = 16;
  801231:	83 c2 02             	add    $0x2,%edx
  801234:	bb 10 00 00 00       	mov    $0x10,%ebx
  801239:	eb 12                	jmp    80124d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  80123b:	85 db                	test   %ebx,%ebx
  80123d:	75 0e                	jne    80124d <strtol+0x69>
  80123f:	3c 30                	cmp    $0x30,%al
  801241:	75 05                	jne    801248 <strtol+0x64>
		s++, base = 8;
  801243:	42                   	inc    %edx
  801244:	b3 08                	mov    $0x8,%bl
  801246:	eb 05                	jmp    80124d <strtol+0x69>
	else if (base == 0)
		base = 10;
  801248:	bb 0a 00 00 00       	mov    $0xa,%ebx
  80124d:	b8 00 00 00 00       	mov    $0x0,%eax
  801252:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801254:	8a 0a                	mov    (%edx),%cl
  801256:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801259:	80 fb 09             	cmp    $0x9,%bl
  80125c:	77 08                	ja     801266 <strtol+0x82>
			dig = *s - '0';
  80125e:	0f be c9             	movsbl %cl,%ecx
  801261:	83 e9 30             	sub    $0x30,%ecx
  801264:	eb 1e                	jmp    801284 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801266:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801269:	80 fb 19             	cmp    $0x19,%bl
  80126c:	77 08                	ja     801276 <strtol+0x92>
			dig = *s - 'a' + 10;
  80126e:	0f be c9             	movsbl %cl,%ecx
  801271:	83 e9 57             	sub    $0x57,%ecx
  801274:	eb 0e                	jmp    801284 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801276:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801279:	80 fb 19             	cmp    $0x19,%bl
  80127c:	77 12                	ja     801290 <strtol+0xac>
			dig = *s - 'A' + 10;
  80127e:	0f be c9             	movsbl %cl,%ecx
  801281:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801284:	39 f1                	cmp    %esi,%ecx
  801286:	7d 0c                	jge    801294 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801288:	42                   	inc    %edx
  801289:	0f af c6             	imul   %esi,%eax
  80128c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  80128e:	eb c4                	jmp    801254 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801290:	89 c1                	mov    %eax,%ecx
  801292:	eb 02                	jmp    801296 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801294:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801296:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80129a:	74 05                	je     8012a1 <strtol+0xbd>
		*endptr = (char *) s;
  80129c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80129f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8012a1:	85 ff                	test   %edi,%edi
  8012a3:	74 04                	je     8012a9 <strtol+0xc5>
  8012a5:	89 c8                	mov    %ecx,%eax
  8012a7:	f7 d8                	neg    %eax
}
  8012a9:	5b                   	pop    %ebx
  8012aa:	5e                   	pop    %esi
  8012ab:	5f                   	pop    %edi
  8012ac:	5d                   	pop    %ebp
  8012ad:	c3                   	ret    
	...

008012b0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	57                   	push   %edi
  8012b4:	56                   	push   %esi
  8012b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012be:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c1:	89 c3                	mov    %eax,%ebx
  8012c3:	89 c7                	mov    %eax,%edi
  8012c5:	89 c6                	mov    %eax,%esi
  8012c7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8012c9:	5b                   	pop    %ebx
  8012ca:	5e                   	pop    %esi
  8012cb:	5f                   	pop    %edi
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    

008012ce <sys_cgetc>:

int
sys_cgetc(void)
{
  8012ce:	55                   	push   %ebp
  8012cf:	89 e5                	mov    %esp,%ebp
  8012d1:	57                   	push   %edi
  8012d2:	56                   	push   %esi
  8012d3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8012de:	89 d1                	mov    %edx,%ecx
  8012e0:	89 d3                	mov    %edx,%ebx
  8012e2:	89 d7                	mov    %edx,%edi
  8012e4:	89 d6                	mov    %edx,%esi
  8012e6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8012e8:	5b                   	pop    %ebx
  8012e9:	5e                   	pop    %esi
  8012ea:	5f                   	pop    %edi
  8012eb:	5d                   	pop    %ebp
  8012ec:	c3                   	ret    

008012ed <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8012ed:	55                   	push   %ebp
  8012ee:	89 e5                	mov    %esp,%ebp
  8012f0:	57                   	push   %edi
  8012f1:	56                   	push   %esi
  8012f2:	53                   	push   %ebx
  8012f3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012fb:	b8 03 00 00 00       	mov    $0x3,%eax
  801300:	8b 55 08             	mov    0x8(%ebp),%edx
  801303:	89 cb                	mov    %ecx,%ebx
  801305:	89 cf                	mov    %ecx,%edi
  801307:	89 ce                	mov    %ecx,%esi
  801309:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80130b:	85 c0                	test   %eax,%eax
  80130d:	7e 28                	jle    801337 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80130f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801313:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80131a:	00 
  80131b:	c7 44 24 08 63 34 80 	movl   $0x803463,0x8(%esp)
  801322:	00 
  801323:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80132a:	00 
  80132b:	c7 04 24 80 34 80 00 	movl   $0x803480,(%esp)
  801332:	e8 b1 f5 ff ff       	call   8008e8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801337:	83 c4 2c             	add    $0x2c,%esp
  80133a:	5b                   	pop    %ebx
  80133b:	5e                   	pop    %esi
  80133c:	5f                   	pop    %edi
  80133d:	5d                   	pop    %ebp
  80133e:	c3                   	ret    

0080133f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80133f:	55                   	push   %ebp
  801340:	89 e5                	mov    %esp,%ebp
  801342:	57                   	push   %edi
  801343:	56                   	push   %esi
  801344:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801345:	ba 00 00 00 00       	mov    $0x0,%edx
  80134a:	b8 02 00 00 00       	mov    $0x2,%eax
  80134f:	89 d1                	mov    %edx,%ecx
  801351:	89 d3                	mov    %edx,%ebx
  801353:	89 d7                	mov    %edx,%edi
  801355:	89 d6                	mov    %edx,%esi
  801357:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801359:	5b                   	pop    %ebx
  80135a:	5e                   	pop    %esi
  80135b:	5f                   	pop    %edi
  80135c:	5d                   	pop    %ebp
  80135d:	c3                   	ret    

0080135e <sys_yield>:

void
sys_yield(void)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	57                   	push   %edi
  801362:	56                   	push   %esi
  801363:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801364:	ba 00 00 00 00       	mov    $0x0,%edx
  801369:	b8 0b 00 00 00       	mov    $0xb,%eax
  80136e:	89 d1                	mov    %edx,%ecx
  801370:	89 d3                	mov    %edx,%ebx
  801372:	89 d7                	mov    %edx,%edi
  801374:	89 d6                	mov    %edx,%esi
  801376:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801378:	5b                   	pop    %ebx
  801379:	5e                   	pop    %esi
  80137a:	5f                   	pop    %edi
  80137b:	5d                   	pop    %ebp
  80137c:	c3                   	ret    

0080137d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	57                   	push   %edi
  801381:	56                   	push   %esi
  801382:	53                   	push   %ebx
  801383:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801386:	be 00 00 00 00       	mov    $0x0,%esi
  80138b:	b8 04 00 00 00       	mov    $0x4,%eax
  801390:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801393:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801396:	8b 55 08             	mov    0x8(%ebp),%edx
  801399:	89 f7                	mov    %esi,%edi
  80139b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80139d:	85 c0                	test   %eax,%eax
  80139f:	7e 28                	jle    8013c9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013a1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013a5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8013ac:	00 
  8013ad:	c7 44 24 08 63 34 80 	movl   $0x803463,0x8(%esp)
  8013b4:	00 
  8013b5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013bc:	00 
  8013bd:	c7 04 24 80 34 80 00 	movl   $0x803480,(%esp)
  8013c4:	e8 1f f5 ff ff       	call   8008e8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8013c9:	83 c4 2c             	add    $0x2c,%esp
  8013cc:	5b                   	pop    %ebx
  8013cd:	5e                   	pop    %esi
  8013ce:	5f                   	pop    %edi
  8013cf:	5d                   	pop    %ebp
  8013d0:	c3                   	ret    

008013d1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	57                   	push   %edi
  8013d5:	56                   	push   %esi
  8013d6:	53                   	push   %ebx
  8013d7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013da:	b8 05 00 00 00       	mov    $0x5,%eax
  8013df:	8b 75 18             	mov    0x18(%ebp),%esi
  8013e2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8013e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8013ee:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	7e 28                	jle    80141c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013f4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013f8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8013ff:	00 
  801400:	c7 44 24 08 63 34 80 	movl   $0x803463,0x8(%esp)
  801407:	00 
  801408:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80140f:	00 
  801410:	c7 04 24 80 34 80 00 	movl   $0x803480,(%esp)
  801417:	e8 cc f4 ff ff       	call   8008e8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80141c:	83 c4 2c             	add    $0x2c,%esp
  80141f:	5b                   	pop    %ebx
  801420:	5e                   	pop    %esi
  801421:	5f                   	pop    %edi
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    

00801424 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	57                   	push   %edi
  801428:	56                   	push   %esi
  801429:	53                   	push   %ebx
  80142a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80142d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801432:	b8 06 00 00 00       	mov    $0x6,%eax
  801437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80143a:	8b 55 08             	mov    0x8(%ebp),%edx
  80143d:	89 df                	mov    %ebx,%edi
  80143f:	89 de                	mov    %ebx,%esi
  801441:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801443:	85 c0                	test   %eax,%eax
  801445:	7e 28                	jle    80146f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801447:	89 44 24 10          	mov    %eax,0x10(%esp)
  80144b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801452:	00 
  801453:	c7 44 24 08 63 34 80 	movl   $0x803463,0x8(%esp)
  80145a:	00 
  80145b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801462:	00 
  801463:	c7 04 24 80 34 80 00 	movl   $0x803480,(%esp)
  80146a:	e8 79 f4 ff ff       	call   8008e8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80146f:	83 c4 2c             	add    $0x2c,%esp
  801472:	5b                   	pop    %ebx
  801473:	5e                   	pop    %esi
  801474:	5f                   	pop    %edi
  801475:	5d                   	pop    %ebp
  801476:	c3                   	ret    

00801477 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	57                   	push   %edi
  80147b:	56                   	push   %esi
  80147c:	53                   	push   %ebx
  80147d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801480:	bb 00 00 00 00       	mov    $0x0,%ebx
  801485:	b8 08 00 00 00       	mov    $0x8,%eax
  80148a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80148d:	8b 55 08             	mov    0x8(%ebp),%edx
  801490:	89 df                	mov    %ebx,%edi
  801492:	89 de                	mov    %ebx,%esi
  801494:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801496:	85 c0                	test   %eax,%eax
  801498:	7e 28                	jle    8014c2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80149a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80149e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  8014a5:	00 
  8014a6:	c7 44 24 08 63 34 80 	movl   $0x803463,0x8(%esp)
  8014ad:	00 
  8014ae:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014b5:	00 
  8014b6:	c7 04 24 80 34 80 00 	movl   $0x803480,(%esp)
  8014bd:	e8 26 f4 ff ff       	call   8008e8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8014c2:	83 c4 2c             	add    $0x2c,%esp
  8014c5:	5b                   	pop    %ebx
  8014c6:	5e                   	pop    %esi
  8014c7:	5f                   	pop    %edi
  8014c8:	5d                   	pop    %ebp
  8014c9:	c3                   	ret    

008014ca <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	57                   	push   %edi
  8014ce:	56                   	push   %esi
  8014cf:	53                   	push   %ebx
  8014d0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014d8:	b8 09 00 00 00       	mov    $0x9,%eax
  8014dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e3:	89 df                	mov    %ebx,%edi
  8014e5:	89 de                	mov    %ebx,%esi
  8014e7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	7e 28                	jle    801515 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014ed:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014f1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8014f8:	00 
  8014f9:	c7 44 24 08 63 34 80 	movl   $0x803463,0x8(%esp)
  801500:	00 
  801501:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801508:	00 
  801509:	c7 04 24 80 34 80 00 	movl   $0x803480,(%esp)
  801510:	e8 d3 f3 ff ff       	call   8008e8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801515:	83 c4 2c             	add    $0x2c,%esp
  801518:	5b                   	pop    %ebx
  801519:	5e                   	pop    %esi
  80151a:	5f                   	pop    %edi
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    

0080151d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	57                   	push   %edi
  801521:	56                   	push   %esi
  801522:	53                   	push   %ebx
  801523:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801526:	bb 00 00 00 00       	mov    $0x0,%ebx
  80152b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801530:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801533:	8b 55 08             	mov    0x8(%ebp),%edx
  801536:	89 df                	mov    %ebx,%edi
  801538:	89 de                	mov    %ebx,%esi
  80153a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80153c:	85 c0                	test   %eax,%eax
  80153e:	7e 28                	jle    801568 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801540:	89 44 24 10          	mov    %eax,0x10(%esp)
  801544:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80154b:	00 
  80154c:	c7 44 24 08 63 34 80 	movl   $0x803463,0x8(%esp)
  801553:	00 
  801554:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80155b:	00 
  80155c:	c7 04 24 80 34 80 00 	movl   $0x803480,(%esp)
  801563:	e8 80 f3 ff ff       	call   8008e8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801568:	83 c4 2c             	add    $0x2c,%esp
  80156b:	5b                   	pop    %ebx
  80156c:	5e                   	pop    %esi
  80156d:	5f                   	pop    %edi
  80156e:	5d                   	pop    %ebp
  80156f:	c3                   	ret    

00801570 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	57                   	push   %edi
  801574:	56                   	push   %esi
  801575:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801576:	be 00 00 00 00       	mov    $0x0,%esi
  80157b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801580:	8b 7d 14             	mov    0x14(%ebp),%edi
  801583:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801586:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801589:	8b 55 08             	mov    0x8(%ebp),%edx
  80158c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80158e:	5b                   	pop    %ebx
  80158f:	5e                   	pop    %esi
  801590:	5f                   	pop    %edi
  801591:	5d                   	pop    %ebp
  801592:	c3                   	ret    

00801593 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	57                   	push   %edi
  801597:	56                   	push   %esi
  801598:	53                   	push   %ebx
  801599:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80159c:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015a1:	b8 0d 00 00 00       	mov    $0xd,%eax
  8015a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8015a9:	89 cb                	mov    %ecx,%ebx
  8015ab:	89 cf                	mov    %ecx,%edi
  8015ad:	89 ce                	mov    %ecx,%esi
  8015af:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	7e 28                	jle    8015dd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015b5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015b9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8015c0:	00 
  8015c1:	c7 44 24 08 63 34 80 	movl   $0x803463,0x8(%esp)
  8015c8:	00 
  8015c9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8015d0:	00 
  8015d1:	c7 04 24 80 34 80 00 	movl   $0x803480,(%esp)
  8015d8:	e8 0b f3 ff ff       	call   8008e8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8015dd:	83 c4 2c             	add    $0x2c,%esp
  8015e0:	5b                   	pop    %ebx
  8015e1:	5e                   	pop    %esi
  8015e2:	5f                   	pop    %edi
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	57                   	push   %edi
  8015e9:	56                   	push   %esi
  8015ea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f0:	b8 0e 00 00 00       	mov    $0xe,%eax
  8015f5:	89 d1                	mov    %edx,%ecx
  8015f7:	89 d3                	mov    %edx,%ebx
  8015f9:	89 d7                	mov    %edx,%edi
  8015fb:	89 d6                	mov    %edx,%esi
  8015fd:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8015ff:	5b                   	pop    %ebx
  801600:	5e                   	pop    %esi
  801601:	5f                   	pop    %edi
  801602:	5d                   	pop    %ebp
  801603:	c3                   	ret    

00801604 <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	57                   	push   %edi
  801608:	56                   	push   %esi
  801609:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80160a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80160f:	b8 0f 00 00 00       	mov    $0xf,%eax
  801614:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801617:	8b 55 08             	mov    0x8(%ebp),%edx
  80161a:	89 df                	mov    %ebx,%edi
  80161c:	89 de                	mov    %ebx,%esi
  80161e:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  801620:	5b                   	pop    %ebx
  801621:	5e                   	pop    %esi
  801622:	5f                   	pop    %edi
  801623:	5d                   	pop    %ebp
  801624:	c3                   	ret    

00801625 <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	57                   	push   %edi
  801629:	56                   	push   %esi
  80162a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80162b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801630:	b8 10 00 00 00       	mov    $0x10,%eax
  801635:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801638:	8b 55 08             	mov    0x8(%ebp),%edx
  80163b:	89 df                	mov    %ebx,%edi
  80163d:	89 de                	mov    %ebx,%esi
  80163f:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  801641:	5b                   	pop    %ebx
  801642:	5e                   	pop    %esi
  801643:	5f                   	pop    %edi
  801644:	5d                   	pop    %ebp
  801645:	c3                   	ret    
	...

00801648 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80164b:	8b 45 08             	mov    0x8(%ebp),%eax
  80164e:	05 00 00 00 30       	add    $0x30000000,%eax
  801653:	c1 e8 0c             	shr    $0xc,%eax
}
  801656:	5d                   	pop    %ebp
  801657:	c3                   	ret    

00801658 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80165e:	8b 45 08             	mov    0x8(%ebp),%eax
  801661:	89 04 24             	mov    %eax,(%esp)
  801664:	e8 df ff ff ff       	call   801648 <fd2num>
  801669:	c1 e0 0c             	shl    $0xc,%eax
  80166c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	53                   	push   %ebx
  801677:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80167a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80167f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801681:	89 c2                	mov    %eax,%edx
  801683:	c1 ea 16             	shr    $0x16,%edx
  801686:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80168d:	f6 c2 01             	test   $0x1,%dl
  801690:	74 11                	je     8016a3 <fd_alloc+0x30>
  801692:	89 c2                	mov    %eax,%edx
  801694:	c1 ea 0c             	shr    $0xc,%edx
  801697:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80169e:	f6 c2 01             	test   $0x1,%dl
  8016a1:	75 09                	jne    8016ac <fd_alloc+0x39>
			*fd_store = fd;
  8016a3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8016a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8016aa:	eb 17                	jmp    8016c3 <fd_alloc+0x50>
  8016ac:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016b1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016b6:	75 c7                	jne    80167f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8016be:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8016c3:	5b                   	pop    %ebx
  8016c4:	5d                   	pop    %ebp
  8016c5:	c3                   	ret    

008016c6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8016cc:	83 f8 1f             	cmp    $0x1f,%eax
  8016cf:	77 36                	ja     801707 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8016d1:	c1 e0 0c             	shl    $0xc,%eax
  8016d4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8016d9:	89 c2                	mov    %eax,%edx
  8016db:	c1 ea 16             	shr    $0x16,%edx
  8016de:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016e5:	f6 c2 01             	test   $0x1,%dl
  8016e8:	74 24                	je     80170e <fd_lookup+0x48>
  8016ea:	89 c2                	mov    %eax,%edx
  8016ec:	c1 ea 0c             	shr    $0xc,%edx
  8016ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016f6:	f6 c2 01             	test   $0x1,%dl
  8016f9:	74 1a                	je     801715 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016fe:	89 02                	mov    %eax,(%edx)
	return 0;
  801700:	b8 00 00 00 00       	mov    $0x0,%eax
  801705:	eb 13                	jmp    80171a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801707:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80170c:	eb 0c                	jmp    80171a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80170e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801713:	eb 05                	jmp    80171a <fd_lookup+0x54>
  801715:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80171a:	5d                   	pop    %ebp
  80171b:	c3                   	ret    

0080171c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	53                   	push   %ebx
  801720:	83 ec 14             	sub    $0x14,%esp
  801723:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801726:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801729:	ba 00 00 00 00       	mov    $0x0,%edx
  80172e:	eb 0e                	jmp    80173e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801730:	39 08                	cmp    %ecx,(%eax)
  801732:	75 09                	jne    80173d <dev_lookup+0x21>
			*dev = devtab[i];
  801734:	89 03                	mov    %eax,(%ebx)
			return 0;
  801736:	b8 00 00 00 00       	mov    $0x0,%eax
  80173b:	eb 33                	jmp    801770 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80173d:	42                   	inc    %edx
  80173e:	8b 04 95 0c 35 80 00 	mov    0x80350c(,%edx,4),%eax
  801745:	85 c0                	test   %eax,%eax
  801747:	75 e7                	jne    801730 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801749:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80174e:	8b 40 48             	mov    0x48(%eax),%eax
  801751:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801755:	89 44 24 04          	mov    %eax,0x4(%esp)
  801759:	c7 04 24 90 34 80 00 	movl   $0x803490,(%esp)
  801760:	e8 7b f2 ff ff       	call   8009e0 <cprintf>
	*dev = 0;
  801765:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80176b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801770:	83 c4 14             	add    $0x14,%esp
  801773:	5b                   	pop    %ebx
  801774:	5d                   	pop    %ebp
  801775:	c3                   	ret    

00801776 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	56                   	push   %esi
  80177a:	53                   	push   %ebx
  80177b:	83 ec 30             	sub    $0x30,%esp
  80177e:	8b 75 08             	mov    0x8(%ebp),%esi
  801781:	8a 45 0c             	mov    0xc(%ebp),%al
  801784:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801787:	89 34 24             	mov    %esi,(%esp)
  80178a:	e8 b9 fe ff ff       	call   801648 <fd2num>
  80178f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801792:	89 54 24 04          	mov    %edx,0x4(%esp)
  801796:	89 04 24             	mov    %eax,(%esp)
  801799:	e8 28 ff ff ff       	call   8016c6 <fd_lookup>
  80179e:	89 c3                	mov    %eax,%ebx
  8017a0:	85 c0                	test   %eax,%eax
  8017a2:	78 05                	js     8017a9 <fd_close+0x33>
	    || fd != fd2)
  8017a4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8017a7:	74 0d                	je     8017b6 <fd_close+0x40>
		return (must_exist ? r : 0);
  8017a9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8017ad:	75 46                	jne    8017f5 <fd_close+0x7f>
  8017af:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017b4:	eb 3f                	jmp    8017f5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8017b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bd:	8b 06                	mov    (%esi),%eax
  8017bf:	89 04 24             	mov    %eax,(%esp)
  8017c2:	e8 55 ff ff ff       	call   80171c <dev_lookup>
  8017c7:	89 c3                	mov    %eax,%ebx
  8017c9:	85 c0                	test   %eax,%eax
  8017cb:	78 18                	js     8017e5 <fd_close+0x6f>
		if (dev->dev_close)
  8017cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d0:	8b 40 10             	mov    0x10(%eax),%eax
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	74 09                	je     8017e0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8017d7:	89 34 24             	mov    %esi,(%esp)
  8017da:	ff d0                	call   *%eax
  8017dc:	89 c3                	mov    %eax,%ebx
  8017de:	eb 05                	jmp    8017e5 <fd_close+0x6f>
		else
			r = 0;
  8017e0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8017e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f0:	e8 2f fc ff ff       	call   801424 <sys_page_unmap>
	return r;
}
  8017f5:	89 d8                	mov    %ebx,%eax
  8017f7:	83 c4 30             	add    $0x30,%esp
  8017fa:	5b                   	pop    %ebx
  8017fb:	5e                   	pop    %esi
  8017fc:	5d                   	pop    %ebp
  8017fd:	c3                   	ret    

008017fe <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801804:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	89 04 24             	mov    %eax,(%esp)
  801811:	e8 b0 fe ff ff       	call   8016c6 <fd_lookup>
  801816:	85 c0                	test   %eax,%eax
  801818:	78 13                	js     80182d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80181a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801821:	00 
  801822:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801825:	89 04 24             	mov    %eax,(%esp)
  801828:	e8 49 ff ff ff       	call   801776 <fd_close>
}
  80182d:	c9                   	leave  
  80182e:	c3                   	ret    

0080182f <close_all>:

void
close_all(void)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	53                   	push   %ebx
  801833:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801836:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80183b:	89 1c 24             	mov    %ebx,(%esp)
  80183e:	e8 bb ff ff ff       	call   8017fe <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801843:	43                   	inc    %ebx
  801844:	83 fb 20             	cmp    $0x20,%ebx
  801847:	75 f2                	jne    80183b <close_all+0xc>
		close(i);
}
  801849:	83 c4 14             	add    $0x14,%esp
  80184c:	5b                   	pop    %ebx
  80184d:	5d                   	pop    %ebp
  80184e:	c3                   	ret    

0080184f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	57                   	push   %edi
  801853:	56                   	push   %esi
  801854:	53                   	push   %ebx
  801855:	83 ec 4c             	sub    $0x4c,%esp
  801858:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80185b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80185e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801862:	8b 45 08             	mov    0x8(%ebp),%eax
  801865:	89 04 24             	mov    %eax,(%esp)
  801868:	e8 59 fe ff ff       	call   8016c6 <fd_lookup>
  80186d:	89 c3                	mov    %eax,%ebx
  80186f:	85 c0                	test   %eax,%eax
  801871:	0f 88 e3 00 00 00    	js     80195a <dup+0x10b>
		return r;
	close(newfdnum);
  801877:	89 3c 24             	mov    %edi,(%esp)
  80187a:	e8 7f ff ff ff       	call   8017fe <close>

	newfd = INDEX2FD(newfdnum);
  80187f:	89 fe                	mov    %edi,%esi
  801881:	c1 e6 0c             	shl    $0xc,%esi
  801884:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80188a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80188d:	89 04 24             	mov    %eax,(%esp)
  801890:	e8 c3 fd ff ff       	call   801658 <fd2data>
  801895:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801897:	89 34 24             	mov    %esi,(%esp)
  80189a:	e8 b9 fd ff ff       	call   801658 <fd2data>
  80189f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8018a2:	89 d8                	mov    %ebx,%eax
  8018a4:	c1 e8 16             	shr    $0x16,%eax
  8018a7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018ae:	a8 01                	test   $0x1,%al
  8018b0:	74 46                	je     8018f8 <dup+0xa9>
  8018b2:	89 d8                	mov    %ebx,%eax
  8018b4:	c1 e8 0c             	shr    $0xc,%eax
  8018b7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018be:	f6 c2 01             	test   $0x1,%dl
  8018c1:	74 35                	je     8018f8 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8018c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018ca:	25 07 0e 00 00       	and    $0xe07,%eax
  8018cf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8018d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8018d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018e1:	00 
  8018e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018ed:	e8 df fa ff ff       	call   8013d1 <sys_page_map>
  8018f2:	89 c3                	mov    %eax,%ebx
  8018f4:	85 c0                	test   %eax,%eax
  8018f6:	78 3b                	js     801933 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8018f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018fb:	89 c2                	mov    %eax,%edx
  8018fd:	c1 ea 0c             	shr    $0xc,%edx
  801900:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801907:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80190d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801911:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801915:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80191c:	00 
  80191d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801921:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801928:	e8 a4 fa ff ff       	call   8013d1 <sys_page_map>
  80192d:	89 c3                	mov    %eax,%ebx
  80192f:	85 c0                	test   %eax,%eax
  801931:	79 25                	jns    801958 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801933:	89 74 24 04          	mov    %esi,0x4(%esp)
  801937:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80193e:	e8 e1 fa ff ff       	call   801424 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801943:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801946:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801951:	e8 ce fa ff ff       	call   801424 <sys_page_unmap>
	return r;
  801956:	eb 02                	jmp    80195a <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801958:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80195a:	89 d8                	mov    %ebx,%eax
  80195c:	83 c4 4c             	add    $0x4c,%esp
  80195f:	5b                   	pop    %ebx
  801960:	5e                   	pop    %esi
  801961:	5f                   	pop    %edi
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    

00801964 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	53                   	push   %ebx
  801968:	83 ec 24             	sub    $0x24,%esp
  80196b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80196e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801971:	89 44 24 04          	mov    %eax,0x4(%esp)
  801975:	89 1c 24             	mov    %ebx,(%esp)
  801978:	e8 49 fd ff ff       	call   8016c6 <fd_lookup>
  80197d:	85 c0                	test   %eax,%eax
  80197f:	78 6d                	js     8019ee <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801981:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801984:	89 44 24 04          	mov    %eax,0x4(%esp)
  801988:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198b:	8b 00                	mov    (%eax),%eax
  80198d:	89 04 24             	mov    %eax,(%esp)
  801990:	e8 87 fd ff ff       	call   80171c <dev_lookup>
  801995:	85 c0                	test   %eax,%eax
  801997:	78 55                	js     8019ee <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801999:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80199c:	8b 50 08             	mov    0x8(%eax),%edx
  80199f:	83 e2 03             	and    $0x3,%edx
  8019a2:	83 fa 01             	cmp    $0x1,%edx
  8019a5:	75 23                	jne    8019ca <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019a7:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8019ac:	8b 40 48             	mov    0x48(%eax),%eax
  8019af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b7:	c7 04 24 d1 34 80 00 	movl   $0x8034d1,(%esp)
  8019be:	e8 1d f0 ff ff       	call   8009e0 <cprintf>
		return -E_INVAL;
  8019c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019c8:	eb 24                	jmp    8019ee <read+0x8a>
	}
	if (!dev->dev_read)
  8019ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019cd:	8b 52 08             	mov    0x8(%edx),%edx
  8019d0:	85 d2                	test   %edx,%edx
  8019d2:	74 15                	je     8019e9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8019d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8019d7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019e2:	89 04 24             	mov    %eax,(%esp)
  8019e5:	ff d2                	call   *%edx
  8019e7:	eb 05                	jmp    8019ee <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8019e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8019ee:	83 c4 24             	add    $0x24,%esp
  8019f1:	5b                   	pop    %ebx
  8019f2:	5d                   	pop    %ebp
  8019f3:	c3                   	ret    

008019f4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	57                   	push   %edi
  8019f8:	56                   	push   %esi
  8019f9:	53                   	push   %ebx
  8019fa:	83 ec 1c             	sub    $0x1c,%esp
  8019fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a00:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a03:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a08:	eb 23                	jmp    801a2d <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a0a:	89 f0                	mov    %esi,%eax
  801a0c:	29 d8                	sub    %ebx,%eax
  801a0e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a15:	01 d8                	add    %ebx,%eax
  801a17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1b:	89 3c 24             	mov    %edi,(%esp)
  801a1e:	e8 41 ff ff ff       	call   801964 <read>
		if (m < 0)
  801a23:	85 c0                	test   %eax,%eax
  801a25:	78 10                	js     801a37 <readn+0x43>
			return m;
		if (m == 0)
  801a27:	85 c0                	test   %eax,%eax
  801a29:	74 0a                	je     801a35 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a2b:	01 c3                	add    %eax,%ebx
  801a2d:	39 f3                	cmp    %esi,%ebx
  801a2f:	72 d9                	jb     801a0a <readn+0x16>
  801a31:	89 d8                	mov    %ebx,%eax
  801a33:	eb 02                	jmp    801a37 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801a35:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801a37:	83 c4 1c             	add    $0x1c,%esp
  801a3a:	5b                   	pop    %ebx
  801a3b:	5e                   	pop    %esi
  801a3c:	5f                   	pop    %edi
  801a3d:	5d                   	pop    %ebp
  801a3e:	c3                   	ret    

00801a3f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	53                   	push   %ebx
  801a43:	83 ec 24             	sub    $0x24,%esp
  801a46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a49:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a50:	89 1c 24             	mov    %ebx,(%esp)
  801a53:	e8 6e fc ff ff       	call   8016c6 <fd_lookup>
  801a58:	85 c0                	test   %eax,%eax
  801a5a:	78 68                	js     801ac4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a66:	8b 00                	mov    (%eax),%eax
  801a68:	89 04 24             	mov    %eax,(%esp)
  801a6b:	e8 ac fc ff ff       	call   80171c <dev_lookup>
  801a70:	85 c0                	test   %eax,%eax
  801a72:	78 50                	js     801ac4 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a77:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a7b:	75 23                	jne    801aa0 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a7d:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801a82:	8b 40 48             	mov    0x48(%eax),%eax
  801a85:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8d:	c7 04 24 ed 34 80 00 	movl   $0x8034ed,(%esp)
  801a94:	e8 47 ef ff ff       	call   8009e0 <cprintf>
		return -E_INVAL;
  801a99:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a9e:	eb 24                	jmp    801ac4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801aa0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aa3:	8b 52 0c             	mov    0xc(%edx),%edx
  801aa6:	85 d2                	test   %edx,%edx
  801aa8:	74 15                	je     801abf <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801aaa:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801aad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ab1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ab4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ab8:	89 04 24             	mov    %eax,(%esp)
  801abb:	ff d2                	call   *%edx
  801abd:	eb 05                	jmp    801ac4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801abf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801ac4:	83 c4 24             	add    $0x24,%esp
  801ac7:	5b                   	pop    %ebx
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    

00801aca <seek>:

int
seek(int fdnum, off_t offset)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ad0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801ad3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  801ada:	89 04 24             	mov    %eax,(%esp)
  801add:	e8 e4 fb ff ff       	call   8016c6 <fd_lookup>
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	78 0e                	js     801af4 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801ae6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801ae9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aec:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801aef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	53                   	push   %ebx
  801afa:	83 ec 24             	sub    $0x24,%esp
  801afd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b00:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b07:	89 1c 24             	mov    %ebx,(%esp)
  801b0a:	e8 b7 fb ff ff       	call   8016c6 <fd_lookup>
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	78 61                	js     801b74 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b16:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b1d:	8b 00                	mov    (%eax),%eax
  801b1f:	89 04 24             	mov    %eax,(%esp)
  801b22:	e8 f5 fb ff ff       	call   80171c <dev_lookup>
  801b27:	85 c0                	test   %eax,%eax
  801b29:	78 49                	js     801b74 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b2e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b32:	75 23                	jne    801b57 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b34:	a1 1c 50 80 00       	mov    0x80501c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b39:	8b 40 48             	mov    0x48(%eax),%eax
  801b3c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b44:	c7 04 24 b0 34 80 00 	movl   $0x8034b0,(%esp)
  801b4b:	e8 90 ee ff ff       	call   8009e0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b50:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b55:	eb 1d                	jmp    801b74 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801b57:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b5a:	8b 52 18             	mov    0x18(%edx),%edx
  801b5d:	85 d2                	test   %edx,%edx
  801b5f:	74 0e                	je     801b6f <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b64:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b68:	89 04 24             	mov    %eax,(%esp)
  801b6b:	ff d2                	call   *%edx
  801b6d:	eb 05                	jmp    801b74 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b6f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801b74:	83 c4 24             	add    $0x24,%esp
  801b77:	5b                   	pop    %ebx
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    

00801b7a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	53                   	push   %ebx
  801b7e:	83 ec 24             	sub    $0x24,%esp
  801b81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b84:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8e:	89 04 24             	mov    %eax,(%esp)
  801b91:	e8 30 fb ff ff       	call   8016c6 <fd_lookup>
  801b96:	85 c0                	test   %eax,%eax
  801b98:	78 52                	js     801bec <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ba4:	8b 00                	mov    (%eax),%eax
  801ba6:	89 04 24             	mov    %eax,(%esp)
  801ba9:	e8 6e fb ff ff       	call   80171c <dev_lookup>
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	78 3a                	js     801bec <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801bb9:	74 2c                	je     801be7 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801bbb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801bbe:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801bc5:	00 00 00 
	stat->st_isdir = 0;
  801bc8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bcf:	00 00 00 
	stat->st_dev = dev;
  801bd2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801bd8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bdc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bdf:	89 14 24             	mov    %edx,(%esp)
  801be2:	ff 50 14             	call   *0x14(%eax)
  801be5:	eb 05                	jmp    801bec <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801be7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801bec:	83 c4 24             	add    $0x24,%esp
  801bef:	5b                   	pop    %ebx
  801bf0:	5d                   	pop    %ebp
  801bf1:	c3                   	ret    

00801bf2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	56                   	push   %esi
  801bf6:	53                   	push   %ebx
  801bf7:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801bfa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c01:	00 
  801c02:	8b 45 08             	mov    0x8(%ebp),%eax
  801c05:	89 04 24             	mov    %eax,(%esp)
  801c08:	e8 2a 02 00 00       	call   801e37 <open>
  801c0d:	89 c3                	mov    %eax,%ebx
  801c0f:	85 c0                	test   %eax,%eax
  801c11:	78 1b                	js     801c2e <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801c13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c16:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c1a:	89 1c 24             	mov    %ebx,(%esp)
  801c1d:	e8 58 ff ff ff       	call   801b7a <fstat>
  801c22:	89 c6                	mov    %eax,%esi
	close(fd);
  801c24:	89 1c 24             	mov    %ebx,(%esp)
  801c27:	e8 d2 fb ff ff       	call   8017fe <close>
	return r;
  801c2c:	89 f3                	mov    %esi,%ebx
}
  801c2e:	89 d8                	mov    %ebx,%eax
  801c30:	83 c4 10             	add    $0x10,%esp
  801c33:	5b                   	pop    %ebx
  801c34:	5e                   	pop    %esi
  801c35:	5d                   	pop    %ebp
  801c36:	c3                   	ret    
	...

00801c38 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	56                   	push   %esi
  801c3c:	53                   	push   %ebx
  801c3d:	83 ec 10             	sub    $0x10,%esp
  801c40:	89 c3                	mov    %eax,%ebx
  801c42:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c44:	83 3d 10 50 80 00 00 	cmpl   $0x0,0x805010
  801c4b:	75 11                	jne    801c5e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c4d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c54:	e8 02 10 00 00       	call   802c5b <ipc_find_env>
  801c59:	a3 10 50 80 00       	mov    %eax,0x805010
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c5e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c65:	00 
  801c66:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801c6d:	00 
  801c6e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c72:	a1 10 50 80 00       	mov    0x805010,%eax
  801c77:	89 04 24             	mov    %eax,(%esp)
  801c7a:	e8 59 0f 00 00       	call   802bd8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c7f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c86:	00 
  801c87:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c92:	e8 d1 0e 00 00       	call   802b68 <ipc_recv>
}
  801c97:	83 c4 10             	add    $0x10,%esp
  801c9a:	5b                   	pop    %ebx
  801c9b:	5e                   	pop    %esi
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    

00801c9e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca7:	8b 40 0c             	mov    0xc(%eax),%eax
  801caa:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801caf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb2:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801cb7:	ba 00 00 00 00       	mov    $0x0,%edx
  801cbc:	b8 02 00 00 00       	mov    $0x2,%eax
  801cc1:	e8 72 ff ff ff       	call   801c38 <fsipc>
}
  801cc6:	c9                   	leave  
  801cc7:	c3                   	ret    

00801cc8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801cce:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd1:	8b 40 0c             	mov    0xc(%eax),%eax
  801cd4:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801cd9:	ba 00 00 00 00       	mov    $0x0,%edx
  801cde:	b8 06 00 00 00       	mov    $0x6,%eax
  801ce3:	e8 50 ff ff ff       	call   801c38 <fsipc>
}
  801ce8:	c9                   	leave  
  801ce9:	c3                   	ret    

00801cea <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	53                   	push   %ebx
  801cee:	83 ec 14             	sub    $0x14,%esp
  801cf1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf7:	8b 40 0c             	mov    0xc(%eax),%eax
  801cfa:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801cff:	ba 00 00 00 00       	mov    $0x0,%edx
  801d04:	b8 05 00 00 00       	mov    $0x5,%eax
  801d09:	e8 2a ff ff ff       	call   801c38 <fsipc>
  801d0e:	85 c0                	test   %eax,%eax
  801d10:	78 2b                	js     801d3d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d12:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d19:	00 
  801d1a:	89 1c 24             	mov    %ebx,(%esp)
  801d1d:	e8 69 f2 ff ff       	call   800f8b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d22:	a1 80 60 80 00       	mov    0x806080,%eax
  801d27:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d2d:	a1 84 60 80 00       	mov    0x806084,%eax
  801d32:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d38:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d3d:	83 c4 14             	add    $0x14,%esp
  801d40:	5b                   	pop    %ebx
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    

00801d43 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	83 ec 18             	sub    $0x18,%esp
  801d49:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d4c:	8b 55 08             	mov    0x8(%ebp),%edx
  801d4f:	8b 52 0c             	mov    0xc(%edx),%edx
  801d52:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801d58:	a3 04 60 80 00       	mov    %eax,0x806004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801d5d:	89 c2                	mov    %eax,%edx
  801d5f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801d64:	76 05                	jbe    801d6b <devfile_write+0x28>
  801d66:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801d6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d72:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d76:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801d7d:	e8 ec f3 ff ff       	call   80116e <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801d82:	ba 00 00 00 00       	mov    $0x0,%edx
  801d87:	b8 04 00 00 00       	mov    $0x4,%eax
  801d8c:	e8 a7 fe ff ff       	call   801c38 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801d91:	c9                   	leave  
  801d92:	c3                   	ret    

00801d93 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d93:	55                   	push   %ebp
  801d94:	89 e5                	mov    %esp,%ebp
  801d96:	56                   	push   %esi
  801d97:	53                   	push   %ebx
  801d98:	83 ec 10             	sub    $0x10,%esp
  801d9b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801da1:	8b 40 0c             	mov    0xc(%eax),%eax
  801da4:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801da9:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801daf:	ba 00 00 00 00       	mov    $0x0,%edx
  801db4:	b8 03 00 00 00       	mov    $0x3,%eax
  801db9:	e8 7a fe ff ff       	call   801c38 <fsipc>
  801dbe:	89 c3                	mov    %eax,%ebx
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	78 6a                	js     801e2e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801dc4:	39 c6                	cmp    %eax,%esi
  801dc6:	73 24                	jae    801dec <devfile_read+0x59>
  801dc8:	c7 44 24 0c 20 35 80 	movl   $0x803520,0xc(%esp)
  801dcf:	00 
  801dd0:	c7 44 24 08 27 35 80 	movl   $0x803527,0x8(%esp)
  801dd7:	00 
  801dd8:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801ddf:	00 
  801de0:	c7 04 24 3c 35 80 00 	movl   $0x80353c,(%esp)
  801de7:	e8 fc ea ff ff       	call   8008e8 <_panic>
	assert(r <= PGSIZE);
  801dec:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801df1:	7e 24                	jle    801e17 <devfile_read+0x84>
  801df3:	c7 44 24 0c 47 35 80 	movl   $0x803547,0xc(%esp)
  801dfa:	00 
  801dfb:	c7 44 24 08 27 35 80 	movl   $0x803527,0x8(%esp)
  801e02:	00 
  801e03:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801e0a:	00 
  801e0b:	c7 04 24 3c 35 80 00 	movl   $0x80353c,(%esp)
  801e12:	e8 d1 ea ff ff       	call   8008e8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e17:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e1b:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e22:	00 
  801e23:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e26:	89 04 24             	mov    %eax,(%esp)
  801e29:	e8 d6 f2 ff ff       	call   801104 <memmove>
	return r;
}
  801e2e:	89 d8                	mov    %ebx,%eax
  801e30:	83 c4 10             	add    $0x10,%esp
  801e33:	5b                   	pop    %ebx
  801e34:	5e                   	pop    %esi
  801e35:	5d                   	pop    %ebp
  801e36:	c3                   	ret    

00801e37 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	56                   	push   %esi
  801e3b:	53                   	push   %ebx
  801e3c:	83 ec 20             	sub    $0x20,%esp
  801e3f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e42:	89 34 24             	mov    %esi,(%esp)
  801e45:	e8 0e f1 ff ff       	call   800f58 <strlen>
  801e4a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e4f:	7f 60                	jg     801eb1 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e54:	89 04 24             	mov    %eax,(%esp)
  801e57:	e8 17 f8 ff ff       	call   801673 <fd_alloc>
  801e5c:	89 c3                	mov    %eax,%ebx
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	78 54                	js     801eb6 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e62:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e66:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801e6d:	e8 19 f1 ff ff       	call   800f8b <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e72:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e75:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e7d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e82:	e8 b1 fd ff ff       	call   801c38 <fsipc>
  801e87:	89 c3                	mov    %eax,%ebx
  801e89:	85 c0                	test   %eax,%eax
  801e8b:	79 15                	jns    801ea2 <open+0x6b>
		fd_close(fd, 0);
  801e8d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e94:	00 
  801e95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e98:	89 04 24             	mov    %eax,(%esp)
  801e9b:	e8 d6 f8 ff ff       	call   801776 <fd_close>
		return r;
  801ea0:	eb 14                	jmp    801eb6 <open+0x7f>
	}

	return fd2num(fd);
  801ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea5:	89 04 24             	mov    %eax,(%esp)
  801ea8:	e8 9b f7 ff ff       	call   801648 <fd2num>
  801ead:	89 c3                	mov    %eax,%ebx
  801eaf:	eb 05                	jmp    801eb6 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801eb1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801eb6:	89 d8                	mov    %ebx,%eax
  801eb8:	83 c4 20             	add    $0x20,%esp
  801ebb:	5b                   	pop    %ebx
  801ebc:	5e                   	pop    %esi
  801ebd:	5d                   	pop    %ebp
  801ebe:	c3                   	ret    

00801ebf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ec5:	ba 00 00 00 00       	mov    $0x0,%edx
  801eca:	b8 08 00 00 00       	mov    $0x8,%eax
  801ecf:	e8 64 fd ff ff       	call   801c38 <fsipc>
}
  801ed4:	c9                   	leave  
  801ed5:	c3                   	ret    
	...

00801ed8 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ed8:	55                   	push   %ebp
  801ed9:	89 e5                	mov    %esp,%ebp
  801edb:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801ede:	c7 44 24 04 53 35 80 	movl   $0x803553,0x4(%esp)
  801ee5:	00 
  801ee6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee9:	89 04 24             	mov    %eax,(%esp)
  801eec:	e8 9a f0 ff ff       	call   800f8b <strcpy>
	return 0;
}
  801ef1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef6:	c9                   	leave  
  801ef7:	c3                   	ret    

00801ef8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ef8:	55                   	push   %ebp
  801ef9:	89 e5                	mov    %esp,%ebp
  801efb:	53                   	push   %ebx
  801efc:	83 ec 14             	sub    $0x14,%esp
  801eff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f02:	89 1c 24             	mov    %ebx,(%esp)
  801f05:	e8 96 0d 00 00       	call   802ca0 <pageref>
  801f0a:	83 f8 01             	cmp    $0x1,%eax
  801f0d:	75 0d                	jne    801f1c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801f0f:	8b 43 0c             	mov    0xc(%ebx),%eax
  801f12:	89 04 24             	mov    %eax,(%esp)
  801f15:	e8 1f 03 00 00       	call   802239 <nsipc_close>
  801f1a:	eb 05                	jmp    801f21 <devsock_close+0x29>
	else
		return 0;
  801f1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f21:	83 c4 14             	add    $0x14,%esp
  801f24:	5b                   	pop    %ebx
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    

00801f27 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f2d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f34:	00 
  801f35:	8b 45 10             	mov    0x10(%ebp),%eax
  801f38:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f43:	8b 45 08             	mov    0x8(%ebp),%eax
  801f46:	8b 40 0c             	mov    0xc(%eax),%eax
  801f49:	89 04 24             	mov    %eax,(%esp)
  801f4c:	e8 e3 03 00 00       	call   802334 <nsipc_send>
}
  801f51:	c9                   	leave  
  801f52:	c3                   	ret    

00801f53 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f59:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f60:	00 
  801f61:	8b 45 10             	mov    0x10(%ebp),%eax
  801f64:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f72:	8b 40 0c             	mov    0xc(%eax),%eax
  801f75:	89 04 24             	mov    %eax,(%esp)
  801f78:	e8 37 03 00 00       	call   8022b4 <nsipc_recv>
}
  801f7d:	c9                   	leave  
  801f7e:	c3                   	ret    

00801f7f <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	56                   	push   %esi
  801f83:	53                   	push   %ebx
  801f84:	83 ec 20             	sub    $0x20,%esp
  801f87:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f8c:	89 04 24             	mov    %eax,(%esp)
  801f8f:	e8 df f6 ff ff       	call   801673 <fd_alloc>
  801f94:	89 c3                	mov    %eax,%ebx
  801f96:	85 c0                	test   %eax,%eax
  801f98:	78 21                	js     801fbb <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f9a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fa1:	00 
  801fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fb0:	e8 c8 f3 ff ff       	call   80137d <sys_page_alloc>
  801fb5:	89 c3                	mov    %eax,%ebx
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	79 0a                	jns    801fc5 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801fbb:	89 34 24             	mov    %esi,(%esp)
  801fbe:	e8 76 02 00 00       	call   802239 <nsipc_close>
		return r;
  801fc3:	eb 22                	jmp    801fe7 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801fc5:	8b 15 40 40 80 00    	mov    0x804040,%edx
  801fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fce:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801fd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801fda:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801fdd:	89 04 24             	mov    %eax,(%esp)
  801fe0:	e8 63 f6 ff ff       	call   801648 <fd2num>
  801fe5:	89 c3                	mov    %eax,%ebx
}
  801fe7:	89 d8                	mov    %ebx,%eax
  801fe9:	83 c4 20             	add    $0x20,%esp
  801fec:	5b                   	pop    %ebx
  801fed:	5e                   	pop    %esi
  801fee:	5d                   	pop    %ebp
  801fef:	c3                   	ret    

00801ff0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801ff6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ff9:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ffd:	89 04 24             	mov    %eax,(%esp)
  802000:	e8 c1 f6 ff ff       	call   8016c6 <fd_lookup>
  802005:	85 c0                	test   %eax,%eax
  802007:	78 17                	js     802020 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802009:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200c:	8b 15 40 40 80 00    	mov    0x804040,%edx
  802012:	39 10                	cmp    %edx,(%eax)
  802014:	75 05                	jne    80201b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802016:	8b 40 0c             	mov    0xc(%eax),%eax
  802019:	eb 05                	jmp    802020 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80201b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802020:	c9                   	leave  
  802021:	c3                   	ret    

00802022 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802028:	8b 45 08             	mov    0x8(%ebp),%eax
  80202b:	e8 c0 ff ff ff       	call   801ff0 <fd2sockid>
  802030:	85 c0                	test   %eax,%eax
  802032:	78 1f                	js     802053 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802034:	8b 55 10             	mov    0x10(%ebp),%edx
  802037:	89 54 24 08          	mov    %edx,0x8(%esp)
  80203b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80203e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802042:	89 04 24             	mov    %eax,(%esp)
  802045:	e8 38 01 00 00       	call   802182 <nsipc_accept>
  80204a:	85 c0                	test   %eax,%eax
  80204c:	78 05                	js     802053 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80204e:	e8 2c ff ff ff       	call   801f7f <alloc_sockfd>
}
  802053:	c9                   	leave  
  802054:	c3                   	ret    

00802055 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802055:	55                   	push   %ebp
  802056:	89 e5                	mov    %esp,%ebp
  802058:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80205b:	8b 45 08             	mov    0x8(%ebp),%eax
  80205e:	e8 8d ff ff ff       	call   801ff0 <fd2sockid>
  802063:	85 c0                	test   %eax,%eax
  802065:	78 16                	js     80207d <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  802067:	8b 55 10             	mov    0x10(%ebp),%edx
  80206a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80206e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802071:	89 54 24 04          	mov    %edx,0x4(%esp)
  802075:	89 04 24             	mov    %eax,(%esp)
  802078:	e8 5b 01 00 00       	call   8021d8 <nsipc_bind>
}
  80207d:	c9                   	leave  
  80207e:	c3                   	ret    

0080207f <shutdown>:

int
shutdown(int s, int how)
{
  80207f:	55                   	push   %ebp
  802080:	89 e5                	mov    %esp,%ebp
  802082:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802085:	8b 45 08             	mov    0x8(%ebp),%eax
  802088:	e8 63 ff ff ff       	call   801ff0 <fd2sockid>
  80208d:	85 c0                	test   %eax,%eax
  80208f:	78 0f                	js     8020a0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802091:	8b 55 0c             	mov    0xc(%ebp),%edx
  802094:	89 54 24 04          	mov    %edx,0x4(%esp)
  802098:	89 04 24             	mov    %eax,(%esp)
  80209b:	e8 77 01 00 00       	call   802217 <nsipc_shutdown>
}
  8020a0:	c9                   	leave  
  8020a1:	c3                   	ret    

008020a2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020a2:	55                   	push   %ebp
  8020a3:	89 e5                	mov    %esp,%ebp
  8020a5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ab:	e8 40 ff ff ff       	call   801ff0 <fd2sockid>
  8020b0:	85 c0                	test   %eax,%eax
  8020b2:	78 16                	js     8020ca <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8020b4:	8b 55 10             	mov    0x10(%ebp),%edx
  8020b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020c2:	89 04 24             	mov    %eax,(%esp)
  8020c5:	e8 89 01 00 00       	call   802253 <nsipc_connect>
}
  8020ca:	c9                   	leave  
  8020cb:	c3                   	ret    

008020cc <listen>:

int
listen(int s, int backlog)
{
  8020cc:	55                   	push   %ebp
  8020cd:	89 e5                	mov    %esp,%ebp
  8020cf:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d5:	e8 16 ff ff ff       	call   801ff0 <fd2sockid>
  8020da:	85 c0                	test   %eax,%eax
  8020dc:	78 0f                	js     8020ed <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8020de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020e5:	89 04 24             	mov    %eax,(%esp)
  8020e8:	e8 a5 01 00 00       	call   802292 <nsipc_listen>
}
  8020ed:	c9                   	leave  
  8020ee:	c3                   	ret    

008020ef <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8020ef:	55                   	push   %ebp
  8020f0:	89 e5                	mov    %esp,%ebp
  8020f2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8020f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  802103:	8b 45 08             	mov    0x8(%ebp),%eax
  802106:	89 04 24             	mov    %eax,(%esp)
  802109:	e8 99 02 00 00       	call   8023a7 <nsipc_socket>
  80210e:	85 c0                	test   %eax,%eax
  802110:	78 05                	js     802117 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802112:	e8 68 fe ff ff       	call   801f7f <alloc_sockfd>
}
  802117:	c9                   	leave  
  802118:	c3                   	ret    
  802119:	00 00                	add    %al,(%eax)
	...

0080211c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	53                   	push   %ebx
  802120:	83 ec 14             	sub    $0x14,%esp
  802123:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802125:	83 3d 14 50 80 00 00 	cmpl   $0x0,0x805014
  80212c:	75 11                	jne    80213f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80212e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  802135:	e8 21 0b 00 00       	call   802c5b <ipc_find_env>
  80213a:	a3 14 50 80 00       	mov    %eax,0x805014
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80213f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802146:	00 
  802147:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  80214e:	00 
  80214f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802153:	a1 14 50 80 00       	mov    0x805014,%eax
  802158:	89 04 24             	mov    %eax,(%esp)
  80215b:	e8 78 0a 00 00       	call   802bd8 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802160:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802167:	00 
  802168:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80216f:	00 
  802170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802177:	e8 ec 09 00 00       	call   802b68 <ipc_recv>
}
  80217c:	83 c4 14             	add    $0x14,%esp
  80217f:	5b                   	pop    %ebx
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    

00802182 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802182:	55                   	push   %ebp
  802183:	89 e5                	mov    %esp,%ebp
  802185:	56                   	push   %esi
  802186:	53                   	push   %ebx
  802187:	83 ec 10             	sub    $0x10,%esp
  80218a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80218d:	8b 45 08             	mov    0x8(%ebp),%eax
  802190:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  802195:	8b 06                	mov    (%esi),%eax
  802197:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80219c:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a1:	e8 76 ff ff ff       	call   80211c <nsipc>
  8021a6:	89 c3                	mov    %eax,%ebx
  8021a8:	85 c0                	test   %eax,%eax
  8021aa:	78 23                	js     8021cf <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8021ac:	a1 10 70 80 00       	mov    0x807010,%eax
  8021b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021b5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8021bc:	00 
  8021bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021c0:	89 04 24             	mov    %eax,(%esp)
  8021c3:	e8 3c ef ff ff       	call   801104 <memmove>
		*addrlen = ret->ret_addrlen;
  8021c8:	a1 10 70 80 00       	mov    0x807010,%eax
  8021cd:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8021cf:	89 d8                	mov    %ebx,%eax
  8021d1:	83 c4 10             	add    $0x10,%esp
  8021d4:	5b                   	pop    %ebx
  8021d5:	5e                   	pop    %esi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    

008021d8 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8021d8:	55                   	push   %ebp
  8021d9:	89 e5                	mov    %esp,%ebp
  8021db:	53                   	push   %ebx
  8021dc:	83 ec 14             	sub    $0x14,%esp
  8021df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8021e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e5:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8021ea:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f5:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8021fc:	e8 03 ef ff ff       	call   801104 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802201:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802207:	b8 02 00 00 00       	mov    $0x2,%eax
  80220c:	e8 0b ff ff ff       	call   80211c <nsipc>
}
  802211:	83 c4 14             	add    $0x14,%esp
  802214:	5b                   	pop    %ebx
  802215:	5d                   	pop    %ebp
  802216:	c3                   	ret    

00802217 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802217:	55                   	push   %ebp
  802218:	89 e5                	mov    %esp,%ebp
  80221a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80221d:	8b 45 08             	mov    0x8(%ebp),%eax
  802220:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802225:	8b 45 0c             	mov    0xc(%ebp),%eax
  802228:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80222d:	b8 03 00 00 00       	mov    $0x3,%eax
  802232:	e8 e5 fe ff ff       	call   80211c <nsipc>
}
  802237:	c9                   	leave  
  802238:	c3                   	ret    

00802239 <nsipc_close>:

int
nsipc_close(int s)
{
  802239:	55                   	push   %ebp
  80223a:	89 e5                	mov    %esp,%ebp
  80223c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80223f:	8b 45 08             	mov    0x8(%ebp),%eax
  802242:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802247:	b8 04 00 00 00       	mov    $0x4,%eax
  80224c:	e8 cb fe ff ff       	call   80211c <nsipc>
}
  802251:	c9                   	leave  
  802252:	c3                   	ret    

00802253 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802253:	55                   	push   %ebp
  802254:	89 e5                	mov    %esp,%ebp
  802256:	53                   	push   %ebx
  802257:	83 ec 14             	sub    $0x14,%esp
  80225a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80225d:	8b 45 08             	mov    0x8(%ebp),%eax
  802260:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802265:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802269:	8b 45 0c             	mov    0xc(%ebp),%eax
  80226c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802270:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802277:	e8 88 ee ff ff       	call   801104 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80227c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802282:	b8 05 00 00 00       	mov    $0x5,%eax
  802287:	e8 90 fe ff ff       	call   80211c <nsipc>
}
  80228c:	83 c4 14             	add    $0x14,%esp
  80228f:	5b                   	pop    %ebx
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    

00802292 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  802292:	55                   	push   %ebp
  802293:	89 e5                	mov    %esp,%ebp
  802295:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802298:	8b 45 08             	mov    0x8(%ebp),%eax
  80229b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8022a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022a3:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8022a8:	b8 06 00 00 00       	mov    $0x6,%eax
  8022ad:	e8 6a fe ff ff       	call   80211c <nsipc>
}
  8022b2:	c9                   	leave  
  8022b3:	c3                   	ret    

008022b4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8022b4:	55                   	push   %ebp
  8022b5:	89 e5                	mov    %esp,%ebp
  8022b7:	56                   	push   %esi
  8022b8:	53                   	push   %ebx
  8022b9:	83 ec 10             	sub    $0x10,%esp
  8022bc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8022bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8022c2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8022c7:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8022cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8022d0:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8022d5:	b8 07 00 00 00       	mov    $0x7,%eax
  8022da:	e8 3d fe ff ff       	call   80211c <nsipc>
  8022df:	89 c3                	mov    %eax,%ebx
  8022e1:	85 c0                	test   %eax,%eax
  8022e3:	78 46                	js     80232b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8022e5:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8022ea:	7f 04                	jg     8022f0 <nsipc_recv+0x3c>
  8022ec:	39 c6                	cmp    %eax,%esi
  8022ee:	7d 24                	jge    802314 <nsipc_recv+0x60>
  8022f0:	c7 44 24 0c 5f 35 80 	movl   $0x80355f,0xc(%esp)
  8022f7:	00 
  8022f8:	c7 44 24 08 27 35 80 	movl   $0x803527,0x8(%esp)
  8022ff:	00 
  802300:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802307:	00 
  802308:	c7 04 24 74 35 80 00 	movl   $0x803574,(%esp)
  80230f:	e8 d4 e5 ff ff       	call   8008e8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802314:	89 44 24 08          	mov    %eax,0x8(%esp)
  802318:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80231f:	00 
  802320:	8b 45 0c             	mov    0xc(%ebp),%eax
  802323:	89 04 24             	mov    %eax,(%esp)
  802326:	e8 d9 ed ff ff       	call   801104 <memmove>
	}

	return r;
}
  80232b:	89 d8                	mov    %ebx,%eax
  80232d:	83 c4 10             	add    $0x10,%esp
  802330:	5b                   	pop    %ebx
  802331:	5e                   	pop    %esi
  802332:	5d                   	pop    %ebp
  802333:	c3                   	ret    

00802334 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802334:	55                   	push   %ebp
  802335:	89 e5                	mov    %esp,%ebp
  802337:	53                   	push   %ebx
  802338:	83 ec 14             	sub    $0x14,%esp
  80233b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80233e:	8b 45 08             	mov    0x8(%ebp),%eax
  802341:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802346:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80234c:	7e 24                	jle    802372 <nsipc_send+0x3e>
  80234e:	c7 44 24 0c 80 35 80 	movl   $0x803580,0xc(%esp)
  802355:	00 
  802356:	c7 44 24 08 27 35 80 	movl   $0x803527,0x8(%esp)
  80235d:	00 
  80235e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802365:	00 
  802366:	c7 04 24 74 35 80 00 	movl   $0x803574,(%esp)
  80236d:	e8 76 e5 ff ff       	call   8008e8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  802372:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802376:	8b 45 0c             	mov    0xc(%ebp),%eax
  802379:	89 44 24 04          	mov    %eax,0x4(%esp)
  80237d:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  802384:	e8 7b ed ff ff       	call   801104 <memmove>
	nsipcbuf.send.req_size = size;
  802389:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  80238f:	8b 45 14             	mov    0x14(%ebp),%eax
  802392:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802397:	b8 08 00 00 00       	mov    $0x8,%eax
  80239c:	e8 7b fd ff ff       	call   80211c <nsipc>
}
  8023a1:	83 c4 14             	add    $0x14,%esp
  8023a4:	5b                   	pop    %ebx
  8023a5:	5d                   	pop    %ebp
  8023a6:	c3                   	ret    

008023a7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8023a7:	55                   	push   %ebp
  8023a8:	89 e5                	mov    %esp,%ebp
  8023aa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8023ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8023b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023b8:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8023bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8023c0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8023c5:	b8 09 00 00 00       	mov    $0x9,%eax
  8023ca:	e8 4d fd ff ff       	call   80211c <nsipc>
}
  8023cf:	c9                   	leave  
  8023d0:	c3                   	ret    
  8023d1:	00 00                	add    %al,(%eax)
	...

008023d4 <free>:
	return v;
}

void
free(void *v)
{
  8023d4:	55                   	push   %ebp
  8023d5:	89 e5                	mov    %esp,%ebp
  8023d7:	53                   	push   %ebx
  8023d8:	83 ec 14             	sub    $0x14,%esp
  8023db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  8023de:	85 db                	test   %ebx,%ebx
  8023e0:	0f 84 b8 00 00 00    	je     80249e <free+0xca>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  8023e6:	81 fb ff ff ff 07    	cmp    $0x7ffffff,%ebx
  8023ec:	76 08                	jbe    8023f6 <free+0x22>
  8023ee:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
  8023f4:	76 24                	jbe    80241a <free+0x46>
  8023f6:	c7 44 24 0c 8c 35 80 	movl   $0x80358c,0xc(%esp)
  8023fd:	00 
  8023fe:	c7 44 24 08 27 35 80 	movl   $0x803527,0x8(%esp)
  802405:	00 
  802406:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  80240d:	00 
  80240e:	c7 04 24 bc 35 80 00 	movl   $0x8035bc,(%esp)
  802415:	e8 ce e4 ff ff       	call   8008e8 <_panic>

	c = ROUNDDOWN(v, PGSIZE);
  80241a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  802420:	eb 4a                	jmp    80246c <free+0x98>
		sys_page_unmap(0, c);
  802422:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802426:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80242d:	e8 f2 ef ff ff       	call   801424 <sys_page_unmap>
		c += PGSIZE;
  802432:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(mbegin <= c && c < mend);
  802438:	81 fb ff ff ff 07    	cmp    $0x7ffffff,%ebx
  80243e:	76 08                	jbe    802448 <free+0x74>
  802440:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
  802446:	76 24                	jbe    80246c <free+0x98>
  802448:	c7 44 24 0c c9 35 80 	movl   $0x8035c9,0xc(%esp)
  80244f:	00 
  802450:	c7 44 24 08 27 35 80 	movl   $0x803527,0x8(%esp)
  802457:	00 
  802458:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  80245f:	00 
  802460:	c7 04 24 bc 35 80 00 	movl   $0x8035bc,(%esp)
  802467:	e8 7c e4 ff ff       	call   8008e8 <_panic>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);

	c = ROUNDDOWN(v, PGSIZE);

	while (uvpt[PGNUM(c)] & PTE_CONTINUED) {
  80246c:	89 d8                	mov    %ebx,%eax
  80246e:	c1 e8 0c             	shr    $0xc,%eax
  802471:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802478:	f6 c4 02             	test   $0x2,%ah
  80247b:	75 a5                	jne    802422 <free+0x4e>
	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
	if (--(*ref) == 0)
  80247d:	8b 83 fc 0f 00 00    	mov    0xffc(%ebx),%eax
  802483:	48                   	dec    %eax
  802484:	89 83 fc 0f 00 00    	mov    %eax,0xffc(%ebx)
  80248a:	85 c0                	test   %eax,%eax
  80248c:	75 10                	jne    80249e <free+0xca>
		sys_page_unmap(0, c);
  80248e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802492:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802499:	e8 86 ef ff ff       	call   801424 <sys_page_unmap>
}
  80249e:	83 c4 14             	add    $0x14,%esp
  8024a1:	5b                   	pop    %ebx
  8024a2:	5d                   	pop    %ebp
  8024a3:	c3                   	ret    

008024a4 <malloc>:
	return 1;
}

void*
malloc(size_t n)
{
  8024a4:	55                   	push   %ebp
  8024a5:	89 e5                	mov    %esp,%ebp
  8024a7:	57                   	push   %edi
  8024a8:	56                   	push   %esi
  8024a9:	53                   	push   %ebx
  8024aa:	83 ec 2c             	sub    $0x2c,%esp
	int i, cont;
	int nwrap;
	uint32_t *ref;
	void *v;

	if (mptr == 0)
  8024ad:	83 3d 18 50 80 00 00 	cmpl   $0x0,0x805018
  8024b4:	75 0a                	jne    8024c0 <malloc+0x1c>
		mptr = mbegin;
  8024b6:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  8024bd:	00 00 08 

	n = ROUNDUP(n, 4);
  8024c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8024c3:	83 c0 03             	add    $0x3,%eax
  8024c6:	83 e0 fc             	and    $0xfffffffc,%eax
  8024c9:	89 45 e0             	mov    %eax,-0x20(%ebp)

	if (n >= MAXMALLOC)
  8024cc:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  8024d1:	0f 87 6a 01 00 00    	ja     802641 <malloc+0x19d>
		return 0;

	if ((uintptr_t) mptr % PGSIZE){
  8024d7:	a1 18 50 80 00       	mov    0x805018,%eax
  8024dc:	89 c2                	mov    %eax,%edx
  8024de:	a9 ff 0f 00 00       	test   $0xfff,%eax
  8024e3:	74 4d                	je     802532 <malloc+0x8e>
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
  8024e5:	89 c3                	mov    %eax,%ebx
  8024e7:	c1 eb 0c             	shr    $0xc,%ebx
  8024ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8024ed:	8d 4c 30 03          	lea    0x3(%eax,%esi,1),%ecx
  8024f1:	c1 e9 0c             	shr    $0xc,%ecx
  8024f4:	39 cb                	cmp    %ecx,%ebx
  8024f6:	75 1e                	jne    802516 <malloc+0x72>
		/*
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
  8024f8:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  8024fe:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
			(*ref)++;
  802504:	ff 42 fc             	incl   -0x4(%edx)
			v = mptr;
			mptr += n;
  802507:	89 f2                	mov    %esi,%edx
  802509:	01 c2                	add    %eax,%edx
  80250b:	89 15 18 50 80 00    	mov    %edx,0x805018
			return v;
  802511:	e9 30 01 00 00       	jmp    802646 <malloc+0x1a2>
		}
		/*
		 * stop working on this page and move on.
		 */
		free(mptr);	/* drop reference to this page */
  802516:	89 04 24             	mov    %eax,(%esp)
  802519:	e8 b6 fe ff ff       	call   8023d4 <free>
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  80251e:	a1 18 50 80 00       	mov    0x805018,%eax
  802523:	05 00 10 00 00       	add    $0x1000,%eax
  802528:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80252d:	a3 18 50 80 00       	mov    %eax,0x805018
  802532:	8b 1d 18 50 80 00    	mov    0x805018,%ebx
	return 1;
}

void*
malloc(size_t n)
{
  802538:	c7 45 dc 02 00 00 00 	movl   $0x2,-0x24(%ebp)
	 * runs of more than a page can't have ref counts so we
	 * flag the PTE entries instead.
	 */
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
  80253f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  802542:	83 c6 04             	add    $0x4,%esi
  802545:	eb 05                	jmp    80254c <malloc+0xa8>
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
			mptr = mbegin;
  802547:	bb 00 00 00 08       	mov    $0x8000000,%ebx
		}
		/*
		 * stop working on this page and move on.
		 */
		free(mptr);	/* drop reference to this page */
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  80254c:	89 df                	mov    %ebx,%edi
	 * runs of more than a page can't have ref counts so we
	 * flag the PTE entries instead.
	 */
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
  80254e:	89 75 e4             	mov    %esi,-0x1c(%ebp)
static uint8_t *mptr;

static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;
  802551:	89 d8                	mov    %ebx,%eax
			return 0;
	return 1;
}

void*
malloc(size_t n)
  802553:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
  802556:	eb 2e                	jmp    802586 <malloc+0xe2>
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
		if (va >= (uintptr_t) mend
  802558:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
  80255d:	77 30                	ja     80258f <malloc+0xeb>
		    || ((uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P)))
  80255f:	89 c2                	mov    %eax,%edx
  802561:	c1 ea 16             	shr    $0x16,%edx
  802564:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80256b:	f6 c2 01             	test   $0x1,%dl
  80256e:	74 11                	je     802581 <malloc+0xdd>
  802570:	89 c2                	mov    %eax,%edx
  802572:	c1 ea 0c             	shr    $0xc,%edx
  802575:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80257c:	f6 c2 01             	test   $0x1,%dl
  80257f:	75 0e                	jne    80258f <malloc+0xeb>
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  802581:	05 00 10 00 00       	add    $0x1000,%eax
  802586:	39 c1                	cmp    %eax,%ecx
  802588:	77 ce                	ja     802558 <malloc+0xb4>
  80258a:	e9 84 00 00 00       	jmp    802613 <malloc+0x16f>
  80258f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
  802595:	81 fb 00 00 00 10    	cmp    $0x10000000,%ebx
  80259b:	75 af                	jne    80254c <malloc+0xa8>
			mptr = mbegin;
			if (++nwrap == 2)
  80259d:	ff 4d dc             	decl   -0x24(%ebp)
  8025a0:	75 a5                	jne    802547 <malloc+0xa3>
  8025a2:	c7 05 18 50 80 00 00 	movl   $0x8000000,0x805018
  8025a9:	00 00 08 
				return 0;	/* out of address space */
  8025ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8025b1:	e9 90 00 00 00       	jmp    802646 <malloc+0x1a2>

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  8025b6:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
  8025bc:	39 fe                	cmp    %edi,%esi
  8025be:	19 c0                	sbb    %eax,%eax
  8025c0:	25 00 02 00 00       	and    $0x200,%eax
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  8025c5:	83 c8 07             	or     $0x7,%eax
  8025c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025cc:	03 15 18 50 80 00    	add    0x805018,%edx
  8025d2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025dd:	e8 9b ed ff ff       	call   80137d <sys_page_alloc>
  8025e2:	85 c0                	test   %eax,%eax
  8025e4:	78 22                	js     802608 <malloc+0x164>
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  8025e6:	89 f3                	mov    %esi,%ebx
  8025e8:	eb 37                	jmp    802621 <malloc+0x17d>
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
				sys_page_unmap(0, mptr + i);
  8025ea:	89 d8                	mov    %ebx,%eax
  8025ec:	03 05 18 50 80 00    	add    0x805018,%eax
  8025f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025fd:	e8 22 ee ff ff       	call   801424 <sys_page_unmap>
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
  802602:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  802608:	85 db                	test   %ebx,%ebx
  80260a:	79 de                	jns    8025ea <malloc+0x146>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
  80260c:	b8 00 00 00 00       	mov    $0x0,%eax
  802611:	eb 33                	jmp    802646 <malloc+0x1a2>
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
  802613:	89 3d 18 50 80 00    	mov    %edi,0x805018
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  802619:	bb 00 00 00 00       	mov    $0x0,%ebx
  80261e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  802621:	89 da                	mov    %ebx,%edx
  802623:	39 fb                	cmp    %edi,%ebx
  802625:	72 8f                	jb     8025b6 <malloc+0x112>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
		}
	}

	ref = (uint32_t*) (mptr + i - 4);
  802627:	a1 18 50 80 00       	mov    0x805018,%eax
	*ref = 2;	/* reference for mptr, reference for returned block */
  80262c:	c7 44 18 fc 02 00 00 	movl   $0x2,-0x4(%eax,%ebx,1)
  802633:	00 
	v = mptr;
	mptr += n;
  802634:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802637:	01 c2                	add    %eax,%edx
  802639:	89 15 18 50 80 00    	mov    %edx,0x805018
	return v;
  80263f:	eb 05                	jmp    802646 <malloc+0x1a2>
		mptr = mbegin;

	n = ROUNDUP(n, 4);

	if (n >= MAXMALLOC)
		return 0;
  802641:	b8 00 00 00 00       	mov    $0x0,%eax
	ref = (uint32_t*) (mptr + i - 4);
	*ref = 2;	/* reference for mptr, reference for returned block */
	v = mptr;
	mptr += n;
	return v;
}
  802646:	83 c4 2c             	add    $0x2c,%esp
  802649:	5b                   	pop    %ebx
  80264a:	5e                   	pop    %esi
  80264b:	5f                   	pop    %edi
  80264c:	5d                   	pop    %ebp
  80264d:	c3                   	ret    
	...

00802650 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802650:	55                   	push   %ebp
  802651:	89 e5                	mov    %esp,%ebp
  802653:	56                   	push   %esi
  802654:	53                   	push   %ebx
  802655:	83 ec 10             	sub    $0x10,%esp
  802658:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80265b:	8b 45 08             	mov    0x8(%ebp),%eax
  80265e:	89 04 24             	mov    %eax,(%esp)
  802661:	e8 f2 ef ff ff       	call   801658 <fd2data>
  802666:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802668:	c7 44 24 04 e1 35 80 	movl   $0x8035e1,0x4(%esp)
  80266f:	00 
  802670:	89 34 24             	mov    %esi,(%esp)
  802673:	e8 13 e9 ff ff       	call   800f8b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802678:	8b 43 04             	mov    0x4(%ebx),%eax
  80267b:	2b 03                	sub    (%ebx),%eax
  80267d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802683:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80268a:	00 00 00 
	stat->st_dev = &devpipe;
  80268d:	c7 86 88 00 00 00 5c 	movl   $0x80405c,0x88(%esi)
  802694:	40 80 00 
	return 0;
}
  802697:	b8 00 00 00 00       	mov    $0x0,%eax
  80269c:	83 c4 10             	add    $0x10,%esp
  80269f:	5b                   	pop    %ebx
  8026a0:	5e                   	pop    %esi
  8026a1:	5d                   	pop    %ebp
  8026a2:	c3                   	ret    

008026a3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8026a3:	55                   	push   %ebp
  8026a4:	89 e5                	mov    %esp,%ebp
  8026a6:	53                   	push   %ebx
  8026a7:	83 ec 14             	sub    $0x14,%esp
  8026aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8026ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8026b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026b8:	e8 67 ed ff ff       	call   801424 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8026bd:	89 1c 24             	mov    %ebx,(%esp)
  8026c0:	e8 93 ef ff ff       	call   801658 <fd2data>
  8026c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026d0:	e8 4f ed ff ff       	call   801424 <sys_page_unmap>
}
  8026d5:	83 c4 14             	add    $0x14,%esp
  8026d8:	5b                   	pop    %ebx
  8026d9:	5d                   	pop    %ebp
  8026da:	c3                   	ret    

008026db <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8026db:	55                   	push   %ebp
  8026dc:	89 e5                	mov    %esp,%ebp
  8026de:	57                   	push   %edi
  8026df:	56                   	push   %esi
  8026e0:	53                   	push   %ebx
  8026e1:	83 ec 2c             	sub    $0x2c,%esp
  8026e4:	89 c7                	mov    %eax,%edi
  8026e6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8026e9:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8026ee:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8026f1:	89 3c 24             	mov    %edi,(%esp)
  8026f4:	e8 a7 05 00 00       	call   802ca0 <pageref>
  8026f9:	89 c6                	mov    %eax,%esi
  8026fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026fe:	89 04 24             	mov    %eax,(%esp)
  802701:	e8 9a 05 00 00       	call   802ca0 <pageref>
  802706:	39 c6                	cmp    %eax,%esi
  802708:	0f 94 c0             	sete   %al
  80270b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80270e:	8b 15 1c 50 80 00    	mov    0x80501c,%edx
  802714:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802717:	39 cb                	cmp    %ecx,%ebx
  802719:	75 08                	jne    802723 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80271b:	83 c4 2c             	add    $0x2c,%esp
  80271e:	5b                   	pop    %ebx
  80271f:	5e                   	pop    %esi
  802720:	5f                   	pop    %edi
  802721:	5d                   	pop    %ebp
  802722:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802723:	83 f8 01             	cmp    $0x1,%eax
  802726:	75 c1                	jne    8026e9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802728:	8b 42 58             	mov    0x58(%edx),%eax
  80272b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802732:	00 
  802733:	89 44 24 08          	mov    %eax,0x8(%esp)
  802737:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80273b:	c7 04 24 e8 35 80 00 	movl   $0x8035e8,(%esp)
  802742:	e8 99 e2 ff ff       	call   8009e0 <cprintf>
  802747:	eb a0                	jmp    8026e9 <_pipeisclosed+0xe>

00802749 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802749:	55                   	push   %ebp
  80274a:	89 e5                	mov    %esp,%ebp
  80274c:	57                   	push   %edi
  80274d:	56                   	push   %esi
  80274e:	53                   	push   %ebx
  80274f:	83 ec 1c             	sub    $0x1c,%esp
  802752:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802755:	89 34 24             	mov    %esi,(%esp)
  802758:	e8 fb ee ff ff       	call   801658 <fd2data>
  80275d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80275f:	bf 00 00 00 00       	mov    $0x0,%edi
  802764:	eb 3c                	jmp    8027a2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802766:	89 da                	mov    %ebx,%edx
  802768:	89 f0                	mov    %esi,%eax
  80276a:	e8 6c ff ff ff       	call   8026db <_pipeisclosed>
  80276f:	85 c0                	test   %eax,%eax
  802771:	75 38                	jne    8027ab <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802773:	e8 e6 eb ff ff       	call   80135e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802778:	8b 43 04             	mov    0x4(%ebx),%eax
  80277b:	8b 13                	mov    (%ebx),%edx
  80277d:	83 c2 20             	add    $0x20,%edx
  802780:	39 d0                	cmp    %edx,%eax
  802782:	73 e2                	jae    802766 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802784:	8b 55 0c             	mov    0xc(%ebp),%edx
  802787:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80278a:	89 c2                	mov    %eax,%edx
  80278c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802792:	79 05                	jns    802799 <devpipe_write+0x50>
  802794:	4a                   	dec    %edx
  802795:	83 ca e0             	or     $0xffffffe0,%edx
  802798:	42                   	inc    %edx
  802799:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80279d:	40                   	inc    %eax
  80279e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8027a1:	47                   	inc    %edi
  8027a2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8027a5:	75 d1                	jne    802778 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8027a7:	89 f8                	mov    %edi,%eax
  8027a9:	eb 05                	jmp    8027b0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8027ab:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8027b0:	83 c4 1c             	add    $0x1c,%esp
  8027b3:	5b                   	pop    %ebx
  8027b4:	5e                   	pop    %esi
  8027b5:	5f                   	pop    %edi
  8027b6:	5d                   	pop    %ebp
  8027b7:	c3                   	ret    

008027b8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8027b8:	55                   	push   %ebp
  8027b9:	89 e5                	mov    %esp,%ebp
  8027bb:	57                   	push   %edi
  8027bc:	56                   	push   %esi
  8027bd:	53                   	push   %ebx
  8027be:	83 ec 1c             	sub    $0x1c,%esp
  8027c1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8027c4:	89 3c 24             	mov    %edi,(%esp)
  8027c7:	e8 8c ee ff ff       	call   801658 <fd2data>
  8027cc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8027ce:	be 00 00 00 00       	mov    $0x0,%esi
  8027d3:	eb 3a                	jmp    80280f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8027d5:	85 f6                	test   %esi,%esi
  8027d7:	74 04                	je     8027dd <devpipe_read+0x25>
				return i;
  8027d9:	89 f0                	mov    %esi,%eax
  8027db:	eb 40                	jmp    80281d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8027dd:	89 da                	mov    %ebx,%edx
  8027df:	89 f8                	mov    %edi,%eax
  8027e1:	e8 f5 fe ff ff       	call   8026db <_pipeisclosed>
  8027e6:	85 c0                	test   %eax,%eax
  8027e8:	75 2e                	jne    802818 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8027ea:	e8 6f eb ff ff       	call   80135e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8027ef:	8b 03                	mov    (%ebx),%eax
  8027f1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8027f4:	74 df                	je     8027d5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8027f6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8027fb:	79 05                	jns    802802 <devpipe_read+0x4a>
  8027fd:	48                   	dec    %eax
  8027fe:	83 c8 e0             	or     $0xffffffe0,%eax
  802801:	40                   	inc    %eax
  802802:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802806:	8b 55 0c             	mov    0xc(%ebp),%edx
  802809:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  80280c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80280e:	46                   	inc    %esi
  80280f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802812:	75 db                	jne    8027ef <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802814:	89 f0                	mov    %esi,%eax
  802816:	eb 05                	jmp    80281d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802818:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80281d:	83 c4 1c             	add    $0x1c,%esp
  802820:	5b                   	pop    %ebx
  802821:	5e                   	pop    %esi
  802822:	5f                   	pop    %edi
  802823:	5d                   	pop    %ebp
  802824:	c3                   	ret    

00802825 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802825:	55                   	push   %ebp
  802826:	89 e5                	mov    %esp,%ebp
  802828:	57                   	push   %edi
  802829:	56                   	push   %esi
  80282a:	53                   	push   %ebx
  80282b:	83 ec 3c             	sub    $0x3c,%esp
  80282e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802831:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802834:	89 04 24             	mov    %eax,(%esp)
  802837:	e8 37 ee ff ff       	call   801673 <fd_alloc>
  80283c:	89 c3                	mov    %eax,%ebx
  80283e:	85 c0                	test   %eax,%eax
  802840:	0f 88 45 01 00 00    	js     80298b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802846:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80284d:	00 
  80284e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802851:	89 44 24 04          	mov    %eax,0x4(%esp)
  802855:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80285c:	e8 1c eb ff ff       	call   80137d <sys_page_alloc>
  802861:	89 c3                	mov    %eax,%ebx
  802863:	85 c0                	test   %eax,%eax
  802865:	0f 88 20 01 00 00    	js     80298b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80286b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80286e:	89 04 24             	mov    %eax,(%esp)
  802871:	e8 fd ed ff ff       	call   801673 <fd_alloc>
  802876:	89 c3                	mov    %eax,%ebx
  802878:	85 c0                	test   %eax,%eax
  80287a:	0f 88 f8 00 00 00    	js     802978 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802880:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802887:	00 
  802888:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80288b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80288f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802896:	e8 e2 ea ff ff       	call   80137d <sys_page_alloc>
  80289b:	89 c3                	mov    %eax,%ebx
  80289d:	85 c0                	test   %eax,%eax
  80289f:	0f 88 d3 00 00 00    	js     802978 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8028a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8028a8:	89 04 24             	mov    %eax,(%esp)
  8028ab:	e8 a8 ed ff ff       	call   801658 <fd2data>
  8028b0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028b2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8028b9:	00 
  8028ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028c5:	e8 b3 ea ff ff       	call   80137d <sys_page_alloc>
  8028ca:	89 c3                	mov    %eax,%ebx
  8028cc:	85 c0                	test   %eax,%eax
  8028ce:	0f 88 91 00 00 00    	js     802965 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8028d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8028d7:	89 04 24             	mov    %eax,(%esp)
  8028da:	e8 79 ed ff ff       	call   801658 <fd2data>
  8028df:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8028e6:	00 
  8028e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8028eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8028f2:	00 
  8028f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028fe:	e8 ce ea ff ff       	call   8013d1 <sys_page_map>
  802903:	89 c3                	mov    %eax,%ebx
  802905:	85 c0                	test   %eax,%eax
  802907:	78 4c                	js     802955 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802909:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  80290f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802912:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802914:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802917:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80291e:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802924:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802927:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802929:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80292c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802933:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802936:	89 04 24             	mov    %eax,(%esp)
  802939:	e8 0a ed ff ff       	call   801648 <fd2num>
  80293e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  802940:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802943:	89 04 24             	mov    %eax,(%esp)
  802946:	e8 fd ec ff ff       	call   801648 <fd2num>
  80294b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80294e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802953:	eb 36                	jmp    80298b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802955:	89 74 24 04          	mov    %esi,0x4(%esp)
  802959:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802960:	e8 bf ea ff ff       	call   801424 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802965:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802968:	89 44 24 04          	mov    %eax,0x4(%esp)
  80296c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802973:	e8 ac ea ff ff       	call   801424 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  802978:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80297b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80297f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802986:	e8 99 ea ff ff       	call   801424 <sys_page_unmap>
    err:
	return r;
}
  80298b:	89 d8                	mov    %ebx,%eax
  80298d:	83 c4 3c             	add    $0x3c,%esp
  802990:	5b                   	pop    %ebx
  802991:	5e                   	pop    %esi
  802992:	5f                   	pop    %edi
  802993:	5d                   	pop    %ebp
  802994:	c3                   	ret    

00802995 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802995:	55                   	push   %ebp
  802996:	89 e5                	mov    %esp,%ebp
  802998:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80299b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80299e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8029a5:	89 04 24             	mov    %eax,(%esp)
  8029a8:	e8 19 ed ff ff       	call   8016c6 <fd_lookup>
  8029ad:	85 c0                	test   %eax,%eax
  8029af:	78 15                	js     8029c6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8029b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029b4:	89 04 24             	mov    %eax,(%esp)
  8029b7:	e8 9c ec ff ff       	call   801658 <fd2data>
	return _pipeisclosed(fd, p);
  8029bc:	89 c2                	mov    %eax,%edx
  8029be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8029c1:	e8 15 fd ff ff       	call   8026db <_pipeisclosed>
}
  8029c6:	c9                   	leave  
  8029c7:	c3                   	ret    

008029c8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8029c8:	55                   	push   %ebp
  8029c9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8029cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8029d0:	5d                   	pop    %ebp
  8029d1:	c3                   	ret    

008029d2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8029d2:	55                   	push   %ebp
  8029d3:	89 e5                	mov    %esp,%ebp
  8029d5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8029d8:	c7 44 24 04 00 36 80 	movl   $0x803600,0x4(%esp)
  8029df:	00 
  8029e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8029e3:	89 04 24             	mov    %eax,(%esp)
  8029e6:	e8 a0 e5 ff ff       	call   800f8b <strcpy>
	return 0;
}
  8029eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8029f0:	c9                   	leave  
  8029f1:	c3                   	ret    

008029f2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8029f2:	55                   	push   %ebp
  8029f3:	89 e5                	mov    %esp,%ebp
  8029f5:	57                   	push   %edi
  8029f6:	56                   	push   %esi
  8029f7:	53                   	push   %ebx
  8029f8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8029fe:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802a03:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802a09:	eb 30                	jmp    802a3b <devcons_write+0x49>
		m = n - tot;
  802a0b:	8b 75 10             	mov    0x10(%ebp),%esi
  802a0e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802a10:	83 fe 7f             	cmp    $0x7f,%esi
  802a13:	76 05                	jbe    802a1a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802a15:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802a1a:	89 74 24 08          	mov    %esi,0x8(%esp)
  802a1e:	03 45 0c             	add    0xc(%ebp),%eax
  802a21:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a25:	89 3c 24             	mov    %edi,(%esp)
  802a28:	e8 d7 e6 ff ff       	call   801104 <memmove>
		sys_cputs(buf, m);
  802a2d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a31:	89 3c 24             	mov    %edi,(%esp)
  802a34:	e8 77 e8 ff ff       	call   8012b0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802a39:	01 f3                	add    %esi,%ebx
  802a3b:	89 d8                	mov    %ebx,%eax
  802a3d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802a40:	72 c9                	jb     802a0b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802a42:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802a48:	5b                   	pop    %ebx
  802a49:	5e                   	pop    %esi
  802a4a:	5f                   	pop    %edi
  802a4b:	5d                   	pop    %ebp
  802a4c:	c3                   	ret    

00802a4d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802a4d:	55                   	push   %ebp
  802a4e:	89 e5                	mov    %esp,%ebp
  802a50:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802a53:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802a57:	75 07                	jne    802a60 <devcons_read+0x13>
  802a59:	eb 25                	jmp    802a80 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802a5b:	e8 fe e8 ff ff       	call   80135e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802a60:	e8 69 e8 ff ff       	call   8012ce <sys_cgetc>
  802a65:	85 c0                	test   %eax,%eax
  802a67:	74 f2                	je     802a5b <devcons_read+0xe>
  802a69:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  802a6b:	85 c0                	test   %eax,%eax
  802a6d:	78 1d                	js     802a8c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802a6f:	83 f8 04             	cmp    $0x4,%eax
  802a72:	74 13                	je     802a87 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802a74:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a77:	88 10                	mov    %dl,(%eax)
	return 1;
  802a79:	b8 01 00 00 00       	mov    $0x1,%eax
  802a7e:	eb 0c                	jmp    802a8c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802a80:	b8 00 00 00 00       	mov    $0x0,%eax
  802a85:	eb 05                	jmp    802a8c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802a87:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802a8c:	c9                   	leave  
  802a8d:	c3                   	ret    

00802a8e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802a8e:	55                   	push   %ebp
  802a8f:	89 e5                	mov    %esp,%ebp
  802a91:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802a94:	8b 45 08             	mov    0x8(%ebp),%eax
  802a97:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802a9a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802aa1:	00 
  802aa2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802aa5:	89 04 24             	mov    %eax,(%esp)
  802aa8:	e8 03 e8 ff ff       	call   8012b0 <sys_cputs>
}
  802aad:	c9                   	leave  
  802aae:	c3                   	ret    

00802aaf <getchar>:

int
getchar(void)
{
  802aaf:	55                   	push   %ebp
  802ab0:	89 e5                	mov    %esp,%ebp
  802ab2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802ab5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802abc:	00 
  802abd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ac4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802acb:	e8 94 ee ff ff       	call   801964 <read>
	if (r < 0)
  802ad0:	85 c0                	test   %eax,%eax
  802ad2:	78 0f                	js     802ae3 <getchar+0x34>
		return r;
	if (r < 1)
  802ad4:	85 c0                	test   %eax,%eax
  802ad6:	7e 06                	jle    802ade <getchar+0x2f>
		return -E_EOF;
	return c;
  802ad8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802adc:	eb 05                	jmp    802ae3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802ade:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802ae3:	c9                   	leave  
  802ae4:	c3                   	ret    

00802ae5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802ae5:	55                   	push   %ebp
  802ae6:	89 e5                	mov    %esp,%ebp
  802ae8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802aeb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802aee:	89 44 24 04          	mov    %eax,0x4(%esp)
  802af2:	8b 45 08             	mov    0x8(%ebp),%eax
  802af5:	89 04 24             	mov    %eax,(%esp)
  802af8:	e8 c9 eb ff ff       	call   8016c6 <fd_lookup>
  802afd:	85 c0                	test   %eax,%eax
  802aff:	78 11                	js     802b12 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b04:	8b 15 78 40 80 00    	mov    0x804078,%edx
  802b0a:	39 10                	cmp    %edx,(%eax)
  802b0c:	0f 94 c0             	sete   %al
  802b0f:	0f b6 c0             	movzbl %al,%eax
}
  802b12:	c9                   	leave  
  802b13:	c3                   	ret    

00802b14 <opencons>:

int
opencons(void)
{
  802b14:	55                   	push   %ebp
  802b15:	89 e5                	mov    %esp,%ebp
  802b17:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802b1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b1d:	89 04 24             	mov    %eax,(%esp)
  802b20:	e8 4e eb ff ff       	call   801673 <fd_alloc>
  802b25:	85 c0                	test   %eax,%eax
  802b27:	78 3c                	js     802b65 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802b29:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802b30:	00 
  802b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b34:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802b3f:	e8 39 e8 ff ff       	call   80137d <sys_page_alloc>
  802b44:	85 c0                	test   %eax,%eax
  802b46:	78 1d                	js     802b65 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802b48:	8b 15 78 40 80 00    	mov    0x804078,%edx
  802b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b51:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b56:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802b5d:	89 04 24             	mov    %eax,(%esp)
  802b60:	e8 e3 ea ff ff       	call   801648 <fd2num>
}
  802b65:	c9                   	leave  
  802b66:	c3                   	ret    
	...

00802b68 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802b68:	55                   	push   %ebp
  802b69:	89 e5                	mov    %esp,%ebp
  802b6b:	56                   	push   %esi
  802b6c:	53                   	push   %ebx
  802b6d:	83 ec 10             	sub    $0x10,%esp
  802b70:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802b73:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b76:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  802b79:	85 c0                	test   %eax,%eax
  802b7b:	74 0a                	je     802b87 <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  802b7d:	89 04 24             	mov    %eax,(%esp)
  802b80:	e8 0e ea ff ff       	call   801593 <sys_ipc_recv>
  802b85:	eb 0c                	jmp    802b93 <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  802b87:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  802b8e:	e8 00 ea ff ff       	call   801593 <sys_ipc_recv>
	}
	if (r < 0)
  802b93:	85 c0                	test   %eax,%eax
  802b95:	79 16                	jns    802bad <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  802b97:	85 db                	test   %ebx,%ebx
  802b99:	74 06                	je     802ba1 <ipc_recv+0x39>
  802b9b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  802ba1:	85 f6                	test   %esi,%esi
  802ba3:	74 2c                	je     802bd1 <ipc_recv+0x69>
  802ba5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  802bab:	eb 24                	jmp    802bd1 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  802bad:	85 db                	test   %ebx,%ebx
  802baf:	74 0a                	je     802bbb <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  802bb1:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802bb6:	8b 40 74             	mov    0x74(%eax),%eax
  802bb9:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  802bbb:	85 f6                	test   %esi,%esi
  802bbd:	74 0a                	je     802bc9 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  802bbf:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802bc4:	8b 40 78             	mov    0x78(%eax),%eax
  802bc7:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  802bc9:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802bce:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  802bd1:	83 c4 10             	add    $0x10,%esp
  802bd4:	5b                   	pop    %ebx
  802bd5:	5e                   	pop    %esi
  802bd6:	5d                   	pop    %ebp
  802bd7:	c3                   	ret    

00802bd8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802bd8:	55                   	push   %ebp
  802bd9:	89 e5                	mov    %esp,%ebp
  802bdb:	57                   	push   %edi
  802bdc:	56                   	push   %esi
  802bdd:	53                   	push   %ebx
  802bde:	83 ec 1c             	sub    $0x1c,%esp
  802be1:	8b 75 08             	mov    0x8(%ebp),%esi
  802be4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  802bea:	85 db                	test   %ebx,%ebx
  802bec:	74 19                	je     802c07 <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  802bee:	8b 45 14             	mov    0x14(%ebp),%eax
  802bf1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802bf5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802bf9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802bfd:	89 34 24             	mov    %esi,(%esp)
  802c00:	e8 6b e9 ff ff       	call   801570 <sys_ipc_try_send>
  802c05:	eb 1c                	jmp    802c23 <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  802c07:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802c0e:	00 
  802c0f:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  802c16:	ee 
  802c17:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802c1b:	89 34 24             	mov    %esi,(%esp)
  802c1e:	e8 4d e9 ff ff       	call   801570 <sys_ipc_try_send>
		}
		if (r == 0)
  802c23:	85 c0                	test   %eax,%eax
  802c25:	74 2c                	je     802c53 <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  802c27:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802c2a:	74 20                	je     802c4c <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  802c2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802c30:	c7 44 24 08 0c 36 80 	movl   $0x80360c,0x8(%esp)
  802c37:	00 
  802c38:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  802c3f:	00 
  802c40:	c7 04 24 1f 36 80 00 	movl   $0x80361f,(%esp)
  802c47:	e8 9c dc ff ff       	call   8008e8 <_panic>
		}
		sys_yield();
  802c4c:	e8 0d e7 ff ff       	call   80135e <sys_yield>
	}
  802c51:	eb 97                	jmp    802bea <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  802c53:	83 c4 1c             	add    $0x1c,%esp
  802c56:	5b                   	pop    %ebx
  802c57:	5e                   	pop    %esi
  802c58:	5f                   	pop    %edi
  802c59:	5d                   	pop    %ebp
  802c5a:	c3                   	ret    

00802c5b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802c5b:	55                   	push   %ebp
  802c5c:	89 e5                	mov    %esp,%ebp
  802c5e:	53                   	push   %ebx
  802c5f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802c62:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802c67:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802c6e:	89 c2                	mov    %eax,%edx
  802c70:	c1 e2 07             	shl    $0x7,%edx
  802c73:	29 ca                	sub    %ecx,%edx
  802c75:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802c7b:	8b 52 50             	mov    0x50(%edx),%edx
  802c7e:	39 da                	cmp    %ebx,%edx
  802c80:	75 0f                	jne    802c91 <ipc_find_env+0x36>
			return envs[i].env_id;
  802c82:	c1 e0 07             	shl    $0x7,%eax
  802c85:	29 c8                	sub    %ecx,%eax
  802c87:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802c8c:	8b 40 40             	mov    0x40(%eax),%eax
  802c8f:	eb 0c                	jmp    802c9d <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802c91:	40                   	inc    %eax
  802c92:	3d 00 04 00 00       	cmp    $0x400,%eax
  802c97:	75 ce                	jne    802c67 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802c99:	66 b8 00 00          	mov    $0x0,%ax
}
  802c9d:	5b                   	pop    %ebx
  802c9e:	5d                   	pop    %ebp
  802c9f:	c3                   	ret    

00802ca0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802ca0:	55                   	push   %ebp
  802ca1:	89 e5                	mov    %esp,%ebp
  802ca3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802ca6:	89 c2                	mov    %eax,%edx
  802ca8:	c1 ea 16             	shr    $0x16,%edx
  802cab:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802cb2:	f6 c2 01             	test   $0x1,%dl
  802cb5:	74 1e                	je     802cd5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802cb7:	c1 e8 0c             	shr    $0xc,%eax
  802cba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802cc1:	a8 01                	test   $0x1,%al
  802cc3:	74 17                	je     802cdc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802cc5:	c1 e8 0c             	shr    $0xc,%eax
  802cc8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802ccf:	ef 
  802cd0:	0f b7 c0             	movzwl %ax,%eax
  802cd3:	eb 0c                	jmp    802ce1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802cd5:	b8 00 00 00 00       	mov    $0x0,%eax
  802cda:	eb 05                	jmp    802ce1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802cdc:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802ce1:	5d                   	pop    %ebp
  802ce2:	c3                   	ret    
	...

00802ce4 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802ce4:	55                   	push   %ebp
  802ce5:	57                   	push   %edi
  802ce6:	56                   	push   %esi
  802ce7:	83 ec 10             	sub    $0x10,%esp
  802cea:	8b 74 24 20          	mov    0x20(%esp),%esi
  802cee:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802cf2:	89 74 24 04          	mov    %esi,0x4(%esp)
  802cf6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802cfa:	89 cd                	mov    %ecx,%ebp
  802cfc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802d00:	85 c0                	test   %eax,%eax
  802d02:	75 2c                	jne    802d30 <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802d04:	39 f9                	cmp    %edi,%ecx
  802d06:	77 68                	ja     802d70 <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802d08:	85 c9                	test   %ecx,%ecx
  802d0a:	75 0b                	jne    802d17 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802d0c:	b8 01 00 00 00       	mov    $0x1,%eax
  802d11:	31 d2                	xor    %edx,%edx
  802d13:	f7 f1                	div    %ecx
  802d15:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802d17:	31 d2                	xor    %edx,%edx
  802d19:	89 f8                	mov    %edi,%eax
  802d1b:	f7 f1                	div    %ecx
  802d1d:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802d1f:	89 f0                	mov    %esi,%eax
  802d21:	f7 f1                	div    %ecx
  802d23:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802d25:	89 f0                	mov    %esi,%eax
  802d27:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802d29:	83 c4 10             	add    $0x10,%esp
  802d2c:	5e                   	pop    %esi
  802d2d:	5f                   	pop    %edi
  802d2e:	5d                   	pop    %ebp
  802d2f:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802d30:	39 f8                	cmp    %edi,%eax
  802d32:	77 2c                	ja     802d60 <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802d34:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  802d37:	83 f6 1f             	xor    $0x1f,%esi
  802d3a:	75 4c                	jne    802d88 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802d3c:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802d3e:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802d43:	72 0a                	jb     802d4f <__udivdi3+0x6b>
  802d45:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802d49:	0f 87 ad 00 00 00    	ja     802dfc <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802d4f:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802d54:	89 f0                	mov    %esi,%eax
  802d56:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802d58:	83 c4 10             	add    $0x10,%esp
  802d5b:	5e                   	pop    %esi
  802d5c:	5f                   	pop    %edi
  802d5d:	5d                   	pop    %ebp
  802d5e:	c3                   	ret    
  802d5f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802d60:	31 ff                	xor    %edi,%edi
  802d62:	31 f6                	xor    %esi,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802d64:	89 f0                	mov    %esi,%eax
  802d66:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802d68:	83 c4 10             	add    $0x10,%esp
  802d6b:	5e                   	pop    %esi
  802d6c:	5f                   	pop    %edi
  802d6d:	5d                   	pop    %ebp
  802d6e:	c3                   	ret    
  802d6f:	90                   	nop
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802d70:	89 fa                	mov    %edi,%edx
  802d72:	89 f0                	mov    %esi,%eax
  802d74:	f7 f1                	div    %ecx
  802d76:	89 c6                	mov    %eax,%esi
  802d78:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  802d7a:	89 f0                	mov    %esi,%eax
  802d7c:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  802d7e:	83 c4 10             	add    $0x10,%esp
  802d81:	5e                   	pop    %esi
  802d82:	5f                   	pop    %edi
  802d83:	5d                   	pop    %ebp
  802d84:	c3                   	ret    
  802d85:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802d88:	89 f1                	mov    %esi,%ecx
  802d8a:	d3 e0                	shl    %cl,%eax
  802d8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802d90:	b8 20 00 00 00       	mov    $0x20,%eax
  802d95:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802d97:	89 ea                	mov    %ebp,%edx
  802d99:	88 c1                	mov    %al,%cl
  802d9b:	d3 ea                	shr    %cl,%edx
  802d9d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802da1:	09 ca                	or     %ecx,%edx
  802da3:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802da7:	89 f1                	mov    %esi,%ecx
  802da9:	d3 e5                	shl    %cl,%ebp
  802dab:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802daf:	89 fd                	mov    %edi,%ebp
  802db1:	88 c1                	mov    %al,%cl
  802db3:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802db5:	89 fa                	mov    %edi,%edx
  802db7:	89 f1                	mov    %esi,%ecx
  802db9:	d3 e2                	shl    %cl,%edx
  802dbb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802dbf:	88 c1                	mov    %al,%cl
  802dc1:	d3 ef                	shr    %cl,%edi
  802dc3:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802dc5:	89 f8                	mov    %edi,%eax
  802dc7:	89 ea                	mov    %ebp,%edx
  802dc9:	f7 74 24 08          	divl   0x8(%esp)
  802dcd:	89 d1                	mov    %edx,%ecx
  802dcf:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802dd1:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802dd5:	39 d1                	cmp    %edx,%ecx
  802dd7:	72 17                	jb     802df0 <__udivdi3+0x10c>
  802dd9:	74 09                	je     802de4 <__udivdi3+0x100>
  802ddb:	89 fe                	mov    %edi,%esi
  802ddd:	31 ff                	xor    %edi,%edi
  802ddf:	e9 41 ff ff ff       	jmp    802d25 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802de4:	8b 54 24 04          	mov    0x4(%esp),%edx
  802de8:	89 f1                	mov    %esi,%ecx
  802dea:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802dec:	39 c2                	cmp    %eax,%edx
  802dee:	73 eb                	jae    802ddb <__udivdi3+0xf7>
		{
		  q0--;
  802df0:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802df3:	31 ff                	xor    %edi,%edi
  802df5:	e9 2b ff ff ff       	jmp    802d25 <__udivdi3+0x41>
  802dfa:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802dfc:	31 f6                	xor    %esi,%esi
  802dfe:	e9 22 ff ff ff       	jmp    802d25 <__udivdi3+0x41>
	...

00802e04 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802e04:	55                   	push   %ebp
  802e05:	57                   	push   %edi
  802e06:	56                   	push   %esi
  802e07:	83 ec 20             	sub    $0x20,%esp
  802e0a:	8b 44 24 30          	mov    0x30(%esp),%eax
  802e0e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802e12:	89 44 24 14          	mov    %eax,0x14(%esp)
  802e16:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802e1a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802e1e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802e22:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802e24:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802e26:	85 ed                	test   %ebp,%ebp
  802e28:	75 16                	jne    802e40 <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802e2a:	39 f1                	cmp    %esi,%ecx
  802e2c:	0f 86 a6 00 00 00    	jbe    802ed8 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802e32:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802e34:	89 d0                	mov    %edx,%eax
  802e36:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802e38:	83 c4 20             	add    $0x20,%esp
  802e3b:	5e                   	pop    %esi
  802e3c:	5f                   	pop    %edi
  802e3d:	5d                   	pop    %ebp
  802e3e:	c3                   	ret    
  802e3f:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802e40:	39 f5                	cmp    %esi,%ebp
  802e42:	0f 87 ac 00 00 00    	ja     802ef4 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802e48:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802e4b:	83 f0 1f             	xor    $0x1f,%eax
  802e4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802e52:	0f 84 a8 00 00 00    	je     802f00 <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802e58:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802e5c:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802e5e:	bf 20 00 00 00       	mov    $0x20,%edi
  802e63:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802e67:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802e6b:	89 f9                	mov    %edi,%ecx
  802e6d:	d3 e8                	shr    %cl,%eax
  802e6f:	09 e8                	or     %ebp,%eax
  802e71:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802e75:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802e79:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802e7d:	d3 e0                	shl    %cl,%eax
  802e7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802e83:	89 f2                	mov    %esi,%edx
  802e85:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802e87:	8b 44 24 14          	mov    0x14(%esp),%eax
  802e8b:	d3 e0                	shl    %cl,%eax
  802e8d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802e91:	8b 44 24 14          	mov    0x14(%esp),%eax
  802e95:	89 f9                	mov    %edi,%ecx
  802e97:	d3 e8                	shr    %cl,%eax
  802e99:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802e9b:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802e9d:	89 f2                	mov    %esi,%edx
  802e9f:	f7 74 24 18          	divl   0x18(%esp)
  802ea3:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802ea5:	f7 64 24 0c          	mull   0xc(%esp)
  802ea9:	89 c5                	mov    %eax,%ebp
  802eab:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802ead:	39 d6                	cmp    %edx,%esi
  802eaf:	72 67                	jb     802f18 <__umoddi3+0x114>
  802eb1:	74 75                	je     802f28 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802eb3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802eb7:	29 e8                	sub    %ebp,%eax
  802eb9:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802ebb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ebf:	d3 e8                	shr    %cl,%eax
  802ec1:	89 f2                	mov    %esi,%edx
  802ec3:	89 f9                	mov    %edi,%ecx
  802ec5:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802ec7:	09 d0                	or     %edx,%eax
  802ec9:	89 f2                	mov    %esi,%edx
  802ecb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ecf:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802ed1:	83 c4 20             	add    $0x20,%esp
  802ed4:	5e                   	pop    %esi
  802ed5:	5f                   	pop    %edi
  802ed6:	5d                   	pop    %ebp
  802ed7:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802ed8:	85 c9                	test   %ecx,%ecx
  802eda:	75 0b                	jne    802ee7 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802edc:	b8 01 00 00 00       	mov    $0x1,%eax
  802ee1:	31 d2                	xor    %edx,%edx
  802ee3:	f7 f1                	div    %ecx
  802ee5:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802ee7:	89 f0                	mov    %esi,%eax
  802ee9:	31 d2                	xor    %edx,%edx
  802eeb:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802eed:	89 f8                	mov    %edi,%eax
  802eef:	e9 3e ff ff ff       	jmp    802e32 <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802ef4:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802ef6:	83 c4 20             	add    $0x20,%esp
  802ef9:	5e                   	pop    %esi
  802efa:	5f                   	pop    %edi
  802efb:	5d                   	pop    %ebp
  802efc:	c3                   	ret    
  802efd:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802f00:	39 f5                	cmp    %esi,%ebp
  802f02:	72 04                	jb     802f08 <__umoddi3+0x104>
  802f04:	39 f9                	cmp    %edi,%ecx
  802f06:	77 06                	ja     802f0e <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802f08:	89 f2                	mov    %esi,%edx
  802f0a:	29 cf                	sub    %ecx,%edi
  802f0c:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802f0e:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802f10:	83 c4 20             	add    $0x20,%esp
  802f13:	5e                   	pop    %esi
  802f14:	5f                   	pop    %edi
  802f15:	5d                   	pop    %ebp
  802f16:	c3                   	ret    
  802f17:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802f18:	89 d1                	mov    %edx,%ecx
  802f1a:	89 c5                	mov    %eax,%ebp
  802f1c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802f20:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802f24:	eb 8d                	jmp    802eb3 <__umoddi3+0xaf>
  802f26:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802f28:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802f2c:	72 ea                	jb     802f18 <__umoddi3+0x114>
  802f2e:	89 f1                	mov    %esi,%ecx
  802f30:	eb 81                	jmp    802eb3 <__umoddi3+0xaf>
