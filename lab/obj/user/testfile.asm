
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 3f 07 00 00       	call   800770 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800041:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  800048:	e8 36 0e 00 00       	call   800e83 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80004d:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  800053:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80005a:	e8 d4 15 00 00       	call   801633 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800066:	00 
  800067:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800076:	00 
  800077:	89 04 24             	mov    %eax,(%esp)
  80007a:	e8 31 15 00 00       	call   8015b0 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  80007f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  80008e:	cc 
  80008f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800096:	e8 a5 14 00 00       	call   801540 <ipc_recv>
}
  80009b:	83 c4 14             	add    $0x14,%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <umain>:

void
umain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	81 ec cc 02 00 00    	sub    $0x2cc,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8000ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b2:	b8 c0 2b 80 00       	mov    $0x802bc0,%eax
  8000b7:	e8 78 ff ff ff       	call   800034 <xopen>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	79 25                	jns    8000e5 <umain+0x44>
  8000c0:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000c3:	74 3c                	je     800101 <umain+0x60>
		panic("serve_open /not-found: %e", r);
  8000c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c9:	c7 44 24 08 cb 2b 80 	movl   $0x802bcb,0x8(%esp)
  8000d0:	00 
  8000d1:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8000d8:	00 
  8000d9:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  8000e0:	e8 fb 06 00 00       	call   8007e0 <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000e5:	c7 44 24 08 80 2d 80 	movl   $0x802d80,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  8000fc:	e8 df 06 00 00       	call   8007e0 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  800101:	ba 00 00 00 00       	mov    $0x0,%edx
  800106:	b8 f5 2b 80 00       	mov    $0x802bf5,%eax
  80010b:	e8 24 ff ff ff       	call   800034 <xopen>
  800110:	85 c0                	test   %eax,%eax
  800112:	79 20                	jns    800134 <umain+0x93>
		panic("serve_open /newmotd: %e", r);
  800114:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800118:	c7 44 24 08 fe 2b 80 	movl   $0x802bfe,0x8(%esp)
  80011f:	00 
  800120:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800127:	00 
  800128:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  80012f:	e8 ac 06 00 00       	call   8007e0 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  800134:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  80013b:	75 12                	jne    80014f <umain+0xae>
  80013d:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800144:	75 09                	jne    80014f <umain+0xae>
  800146:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80014d:	74 1c                	je     80016b <umain+0xca>
		panic("serve_open did not fill struct Fd correctly\n");
  80014f:	c7 44 24 08 a4 2d 80 	movl   $0x802da4,0x8(%esp)
  800156:	00 
  800157:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80015e:	00 
  80015f:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  800166:	e8 75 06 00 00       	call   8007e0 <_panic>
	cprintf("serve_open is good\n");
  80016b:	c7 04 24 16 2c 80 00 	movl   $0x802c16,(%esp)
  800172:	e8 61 07 00 00       	call   8008d8 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800177:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800188:	ff 15 1c 40 80 00    	call   *0x80401c
  80018e:	85 c0                	test   %eax,%eax
  800190:	79 20                	jns    8001b2 <umain+0x111>
		panic("file_stat: %e", r);
  800192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800196:	c7 44 24 08 2a 2c 80 	movl   $0x802c2a,0x8(%esp)
  80019d:	00 
  80019e:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001a5:	00 
  8001a6:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  8001ad:	e8 2e 06 00 00       	call   8007e0 <_panic>
	if (strlen(msg) != st.st_size)
  8001b2:	a1 00 40 80 00       	mov    0x804000,%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 91 0c 00 00       	call   800e50 <strlen>
  8001bf:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  8001c2:	74 34                	je     8001f8 <umain+0x157>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001c4:	a1 00 40 80 00       	mov    0x804000,%eax
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 7f 0c 00 00       	call   800e50 <strlen>
  8001d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001dc:	c7 44 24 08 d4 2d 80 	movl   $0x802dd4,0x8(%esp)
  8001e3:	00 
  8001e4:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8001eb:	00 
  8001ec:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  8001f3:	e8 e8 05 00 00       	call   8007e0 <_panic>
	cprintf("file_stat is good\n");
  8001f8:	c7 04 24 38 2c 80 00 	movl   $0x802c38,(%esp)
  8001ff:	e8 d4 06 00 00       	call   8008d8 <cprintf>

	memset(buf, 0, sizeof buf);
  800204:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800213:	00 
  800214:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80021a:	89 1c 24             	mov    %ebx,(%esp)
  80021d:	e8 90 0d 00 00       	call   800fb2 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800222:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800229:	00 
  80022a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80022e:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800235:	ff 15 10 40 80 00    	call   *0x804010
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 20                	jns    80025f <umain+0x1be>
		panic("file_read: %e", r);
  80023f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800243:	c7 44 24 08 4b 2c 80 	movl   $0x802c4b,0x8(%esp)
  80024a:	00 
  80024b:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  800252:	00 
  800253:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  80025a:	e8 81 05 00 00       	call   8007e0 <_panic>
	if (strcmp(buf, msg) != 0)
  80025f:	a1 00 40 80 00       	mov    0x804000,%eax
  800264:	89 44 24 04          	mov    %eax,0x4(%esp)
  800268:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	e8 b4 0c 00 00       	call   800f2a <strcmp>
  800276:	85 c0                	test   %eax,%eax
  800278:	74 1c                	je     800296 <umain+0x1f5>
		panic("file_read returned wrong data");
  80027a:	c7 44 24 08 59 2c 80 	movl   $0x802c59,0x8(%esp)
  800281:	00 
  800282:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800289:	00 
  80028a:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  800291:	e8 4a 05 00 00       	call   8007e0 <_panic>
	cprintf("file_read is good\n");
  800296:	c7 04 24 77 2c 80 00 	movl   $0x802c77,(%esp)
  80029d:	e8 36 06 00 00       	call   8008d8 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8002a2:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002a9:	ff 15 18 40 80 00    	call   *0x804018
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	79 20                	jns    8002d3 <umain+0x232>
		panic("file_close: %e", r);
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	c7 44 24 08 8a 2c 80 	movl   $0x802c8a,0x8(%esp)
  8002be:	00 
  8002bf:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  8002c6:	00 
  8002c7:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  8002ce:	e8 0d 05 00 00       	call   8007e0 <_panic>
	cprintf("file_close is good\n");
  8002d3:	c7 04 24 99 2c 80 00 	movl   $0x802c99,(%esp)
  8002da:	e8 f9 05 00 00       	call   8008d8 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8002df:	be 00 c0 cc cc       	mov    $0xccccc000,%esi
  8002e4:	8d 7d d8             	lea    -0x28(%ebp),%edi
  8002e7:	b9 04 00 00 00       	mov    $0x4,%ecx
  8002ec:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	sys_page_unmap(0, FVA);
  8002ee:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  8002f5:	cc 
  8002f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002fd:	e8 1a 10 00 00       	call   80131c <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  800302:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800309:	00 
  80030a:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800317:	89 04 24             	mov    %eax,(%esp)
  80031a:	ff 15 10 40 80 00    	call   *0x804010
  800320:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800323:	74 20                	je     800345 <umain+0x2a4>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800325:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800329:	c7 44 24 08 fc 2d 80 	movl   $0x802dfc,0x8(%esp)
  800330:	00 
  800331:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800338:	00 
  800339:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  800340:	e8 9b 04 00 00       	call   8007e0 <_panic>
	cprintf("stale fileid is good\n");
  800345:	c7 04 24 ad 2c 80 00 	movl   $0x802cad,(%esp)
  80034c:	e8 87 05 00 00       	call   8008d8 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  800351:	ba 02 01 00 00       	mov    $0x102,%edx
  800356:	b8 c3 2c 80 00       	mov    $0x802cc3,%eax
  80035b:	e8 d4 fc ff ff       	call   800034 <xopen>
  800360:	85 c0                	test   %eax,%eax
  800362:	79 20                	jns    800384 <umain+0x2e3>
		panic("serve_open /new-file: %e", r);
  800364:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800368:	c7 44 24 08 cd 2c 80 	movl   $0x802ccd,0x8(%esp)
  80036f:	00 
  800370:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
  800377:	00 
  800378:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  80037f:	e8 5c 04 00 00       	call   8007e0 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800384:	8b 1d 14 40 80 00    	mov    0x804014,%ebx
  80038a:	a1 00 40 80 00       	mov    0x804000,%eax
  80038f:	89 04 24             	mov    %eax,(%esp)
  800392:	e8 b9 0a 00 00       	call   800e50 <strlen>
  800397:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039b:	a1 00 40 80 00       	mov    0x804000,%eax
  8003a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a4:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003ab:	ff d3                	call   *%ebx
  8003ad:	89 c3                	mov    %eax,%ebx
  8003af:	a1 00 40 80 00       	mov    0x804000,%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	e8 94 0a 00 00       	call   800e50 <strlen>
  8003bc:	39 c3                	cmp    %eax,%ebx
  8003be:	74 20                	je     8003e0 <umain+0x33f>
		panic("file_write: %e", r);
  8003c0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003c4:	c7 44 24 08 e6 2c 80 	movl   $0x802ce6,0x8(%esp)
  8003cb:	00 
  8003cc:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8003d3:	00 
  8003d4:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  8003db:	e8 00 04 00 00       	call   8007e0 <_panic>
	cprintf("file_write is good\n");
  8003e0:	c7 04 24 f5 2c 80 00 	movl   $0x802cf5,(%esp)
  8003e7:	e8 ec 04 00 00       	call   8008d8 <cprintf>

	FVA->fd_offset = 0;
  8003ec:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  8003f3:	00 00 00 
	memset(buf, 0, sizeof buf);
  8003f6:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8003fd:	00 
  8003fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800405:	00 
  800406:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80040c:	89 1c 24             	mov    %ebx,(%esp)
  80040f:	e8 9e 0b 00 00       	call   800fb2 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800414:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80041b:	00 
  80041c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800420:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800427:	ff 15 10 40 80 00    	call   *0x804010
  80042d:	89 c3                	mov    %eax,%ebx
  80042f:	85 c0                	test   %eax,%eax
  800431:	79 20                	jns    800453 <umain+0x3b2>
		panic("file_read after file_write: %e", r);
  800433:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800437:	c7 44 24 08 34 2e 80 	movl   $0x802e34,0x8(%esp)
  80043e:	00 
  80043f:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800446:	00 
  800447:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  80044e:	e8 8d 03 00 00       	call   8007e0 <_panic>
	if (r != strlen(msg))
  800453:	a1 00 40 80 00       	mov    0x804000,%eax
  800458:	89 04 24             	mov    %eax,(%esp)
  80045b:	e8 f0 09 00 00       	call   800e50 <strlen>
  800460:	39 d8                	cmp    %ebx,%eax
  800462:	74 20                	je     800484 <umain+0x3e3>
		panic("file_read after file_write returned wrong length: %d", r);
  800464:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800468:	c7 44 24 08 54 2e 80 	movl   $0x802e54,0x8(%esp)
  80046f:	00 
  800470:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800477:	00 
  800478:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  80047f:	e8 5c 03 00 00       	call   8007e0 <_panic>
	if (strcmp(buf, msg) != 0)
  800484:	a1 00 40 80 00       	mov    0x804000,%eax
  800489:	89 44 24 04          	mov    %eax,0x4(%esp)
  80048d:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	e8 8f 0a 00 00       	call   800f2a <strcmp>
  80049b:	85 c0                	test   %eax,%eax
  80049d:	74 1c                	je     8004bb <umain+0x41a>
		panic("file_read after file_write returned wrong data");
  80049f:	c7 44 24 08 8c 2e 80 	movl   $0x802e8c,0x8(%esp)
  8004a6:	00 
  8004a7:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8004ae:	00 
  8004af:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  8004b6:	e8 25 03 00 00       	call   8007e0 <_panic>
	cprintf("file_read after file_write is good\n");
  8004bb:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  8004c2:	e8 11 04 00 00       	call   8008d8 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8004c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004ce:	00 
  8004cf:	c7 04 24 c0 2b 80 00 	movl   $0x802bc0,(%esp)
  8004d6:	e8 8c 19 00 00       	call   801e67 <open>
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	79 25                	jns    800504 <umain+0x463>
  8004df:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8004e2:	74 3c                	je     800520 <umain+0x47f>
		panic("open /not-found: %e", r);
  8004e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e8:	c7 44 24 08 d1 2b 80 	movl   $0x802bd1,0x8(%esp)
  8004ef:	00 
  8004f0:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  8004f7:	00 
  8004f8:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  8004ff:	e8 dc 02 00 00       	call   8007e0 <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800504:	c7 44 24 08 09 2d 80 	movl   $0x802d09,0x8(%esp)
  80050b:	00 
  80050c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800513:	00 
  800514:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  80051b:	e8 c0 02 00 00       	call   8007e0 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800520:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800527:	00 
  800528:	c7 04 24 f5 2b 80 00 	movl   $0x802bf5,(%esp)
  80052f:	e8 33 19 00 00       	call   801e67 <open>
  800534:	85 c0                	test   %eax,%eax
  800536:	79 20                	jns    800558 <umain+0x4b7>
		panic("open /newmotd: %e", r);
  800538:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053c:	c7 44 24 08 04 2c 80 	movl   $0x802c04,0x8(%esp)
  800543:	00 
  800544:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  80054b:	00 
  80054c:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  800553:	e8 88 02 00 00       	call   8007e0 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800558:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  80055b:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  800562:	75 12                	jne    800576 <umain+0x4d5>
  800564:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  80056b:	75 09                	jne    800576 <umain+0x4d5>
  80056d:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  800574:	74 1c                	je     800592 <umain+0x4f1>
		panic("open did not fill struct Fd correctly\n");
  800576:	c7 44 24 08 e0 2e 80 	movl   $0x802ee0,0x8(%esp)
  80057d:	00 
  80057e:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  800585:	00 
  800586:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  80058d:	e8 4e 02 00 00       	call   8007e0 <_panic>
	cprintf("open is good\n");
  800592:	c7 04 24 1c 2c 80 00 	movl   $0x802c1c,(%esp)
  800599:	e8 3a 03 00 00       	call   8008d8 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  80059e:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  8005a5:	00 
  8005a6:	c7 04 24 24 2d 80 00 	movl   $0x802d24,(%esp)
  8005ad:	e8 b5 18 00 00       	call   801e67 <open>
  8005b2:	89 c7                	mov    %eax,%edi
  8005b4:	85 c0                	test   %eax,%eax
  8005b6:	79 20                	jns    8005d8 <umain+0x537>
		panic("creat /big: %e", f);
  8005b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005bc:	c7 44 24 08 29 2d 80 	movl   $0x802d29,0x8(%esp)
  8005c3:	00 
  8005c4:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
  8005cb:	00 
  8005cc:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  8005d3:	e8 08 02 00 00       	call   8007e0 <_panic>
	memset(buf, 0, sizeof(buf));
  8005d8:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8005df:	00 
  8005e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8005e7:	00 
  8005e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8005ee:	89 04 24             	mov    %eax,(%esp)
  8005f1:	e8 bc 09 00 00       	call   800fb2 <memset>
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005f6:	be 00 00 00 00       	mov    $0x0,%esi
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8005fb:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800601:	89 b5 4c fd ff ff    	mov    %esi,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800607:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80060e:	00 
  80060f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800613:	89 3c 24             	mov    %edi,(%esp)
  800616:	e8 54 14 00 00       	call   801a6f <write>
  80061b:	85 c0                	test   %eax,%eax
  80061d:	79 24                	jns    800643 <umain+0x5a2>
			panic("write /big@%d: %e", i, r);
  80061f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800623:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800627:	c7 44 24 08 38 2d 80 	movl   $0x802d38,0x8(%esp)
  80062e:	00 
  80062f:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  800636:	00 
  800637:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  80063e:	e8 9d 01 00 00       	call   8007e0 <_panic>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
	return ipc_recv(NULL, FVA, NULL);
}

void
umain(int argc, char **argv)
  800643:	8d 86 00 02 00 00    	lea    0x200(%esi),%eax
  800649:	89 c6                	mov    %eax,%esi

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80064b:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800650:	75 af                	jne    800601 <umain+0x560>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800652:	89 3c 24             	mov    %edi,(%esp)
  800655:	e8 d4 11 00 00       	call   80182e <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80065a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800661:	00 
  800662:	c7 04 24 24 2d 80 00 	movl   $0x802d24,(%esp)
  800669:	e8 f9 17 00 00       	call   801e67 <open>
  80066e:	89 c3                	mov    %eax,%ebx
  800670:	85 c0                	test   %eax,%eax
  800672:	79 20                	jns    800694 <umain+0x5f3>
		panic("open /big: %e", f);
  800674:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800678:	c7 44 24 08 4a 2d 80 	movl   $0x802d4a,0x8(%esp)
  80067f:	00 
  800680:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  800687:	00 
  800688:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  80068f:	e8 4c 01 00 00       	call   8007e0 <_panic>
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
  800694:	be 00 00 00 00       	mov    $0x0,%esi
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800699:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  80069f:	89 b5 4c fd ff ff    	mov    %esi,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  8006a5:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8006ac:	00 
  8006ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006b1:	89 1c 24             	mov    %ebx,(%esp)
  8006b4:	e8 6b 13 00 00       	call   801a24 <readn>
  8006b9:	85 c0                	test   %eax,%eax
  8006bb:	79 24                	jns    8006e1 <umain+0x640>
			panic("read /big@%d: %e", i, r);
  8006bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006c1:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006c5:	c7 44 24 08 58 2d 80 	movl   $0x802d58,0x8(%esp)
  8006cc:	00 
  8006cd:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  8006d4:	00 
  8006d5:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  8006dc:	e8 ff 00 00 00       	call   8007e0 <_panic>
		if (r != sizeof(buf))
  8006e1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8006e6:	74 2c                	je     800714 <umain+0x673>
			panic("read /big from %d returned %d < %d bytes",
  8006e8:	c7 44 24 14 00 02 00 	movl   $0x200,0x14(%esp)
  8006ef:	00 
  8006f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006f4:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8006f8:	c7 44 24 08 08 2f 80 	movl   $0x802f08,0x8(%esp)
  8006ff:	00 
  800700:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  800707:	00 
  800708:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  80070f:	e8 cc 00 00 00       	call   8007e0 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  800714:	8b 07                	mov    (%edi),%eax
  800716:	39 f0                	cmp    %esi,%eax
  800718:	74 24                	je     80073e <umain+0x69d>
			panic("read /big from %d returned bad data %d",
  80071a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80071e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800722:	c7 44 24 08 34 2f 80 	movl   $0x802f34,0x8(%esp)
  800729:	00 
  80072a:	c7 44 24 04 7b 00 00 	movl   $0x7b,0x4(%esp)
  800731:	00 
  800732:	c7 04 24 e5 2b 80 00 	movl   $0x802be5,(%esp)
  800739:	e8 a2 00 00 00       	call   8007e0 <_panic>
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80073e:	8d b0 00 02 00 00    	lea    0x200(%eax),%esi
  800744:	81 fe ff df 01 00    	cmp    $0x1dfff,%esi
  80074a:	0f 8e 4f ff ff ff    	jle    80069f <umain+0x5fe>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800750:	89 1c 24             	mov    %ebx,(%esp)
  800753:	e8 d6 10 00 00       	call   80182e <close>
	cprintf("large file is good\n");
  800758:	c7 04 24 69 2d 80 00 	movl   $0x802d69,(%esp)
  80075f:	e8 74 01 00 00       	call   8008d8 <cprintf>
}
  800764:	81 c4 cc 02 00 00    	add    $0x2cc,%esp
  80076a:	5b                   	pop    %ebx
  80076b:	5e                   	pop    %esi
  80076c:	5f                   	pop    %edi
  80076d:	5d                   	pop    %ebp
  80076e:	c3                   	ret    
	...

00800770 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	56                   	push   %esi
  800774:	53                   	push   %ebx
  800775:	83 ec 10             	sub    $0x10,%esp
  800778:	8b 75 08             	mov    0x8(%ebp),%esi
  80077b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80077e:	e8 b4 0a 00 00       	call   801237 <sys_getenvid>
  800783:	25 ff 03 00 00       	and    $0x3ff,%eax
  800788:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80078f:	c1 e0 07             	shl    $0x7,%eax
  800792:	29 d0                	sub    %edx,%eax
  800794:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800799:	a3 08 50 80 00       	mov    %eax,0x805008


	// save the name of the program so that panic() can use it
	if (argc > 0)
  80079e:	85 f6                	test   %esi,%esi
  8007a0:	7e 07                	jle    8007a9 <libmain+0x39>
		binaryname = argv[0];
  8007a2:	8b 03                	mov    (%ebx),%eax
  8007a4:	a3 04 40 80 00       	mov    %eax,0x804004

	// call user main routine
	umain(argc, argv);
  8007a9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007ad:	89 34 24             	mov    %esi,(%esp)
  8007b0:	e8 ec f8 ff ff       	call   8000a1 <umain>

	// exit gracefully
	exit();
  8007b5:	e8 0a 00 00 00       	call   8007c4 <exit>
}
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	5b                   	pop    %ebx
  8007be:	5e                   	pop    %esi
  8007bf:	5d                   	pop    %ebp
  8007c0:	c3                   	ret    
  8007c1:	00 00                	add    %al,(%eax)
	...

008007c4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8007ca:	e8 90 10 00 00       	call   80185f <close_all>
	sys_env_destroy(0);
  8007cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007d6:	e8 0a 0a 00 00       	call   8011e5 <sys_env_destroy>
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    
  8007dd:	00 00                	add    %al,(%eax)
	...

008007e0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	56                   	push   %esi
  8007e4:	53                   	push   %ebx
  8007e5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8007e8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8007eb:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  8007f1:	e8 41 0a 00 00       	call   801237 <sys_getenvid>
  8007f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800800:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800804:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800808:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080c:	c7 04 24 8c 2f 80 00 	movl   $0x802f8c,(%esp)
  800813:	e8 c0 00 00 00       	call   8008d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800818:	89 74 24 04          	mov    %esi,0x4(%esp)
  80081c:	8b 45 10             	mov    0x10(%ebp),%eax
  80081f:	89 04 24             	mov    %eax,(%esp)
  800822:	e8 50 00 00 00       	call   800877 <vcprintf>
	cprintf("\n");
  800827:	c7 04 24 24 34 80 00 	movl   $0x803424,(%esp)
  80082e:	e8 a5 00 00 00       	call   8008d8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800833:	cc                   	int3   
  800834:	eb fd                	jmp    800833 <_panic+0x53>
	...

00800838 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	53                   	push   %ebx
  80083c:	83 ec 14             	sub    $0x14,%esp
  80083f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800842:	8b 03                	mov    (%ebx),%eax
  800844:	8b 55 08             	mov    0x8(%ebp),%edx
  800847:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80084b:	40                   	inc    %eax
  80084c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80084e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800853:	75 19                	jne    80086e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800855:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80085c:	00 
  80085d:	8d 43 08             	lea    0x8(%ebx),%eax
  800860:	89 04 24             	mov    %eax,(%esp)
  800863:	e8 40 09 00 00       	call   8011a8 <sys_cputs>
		b->idx = 0;
  800868:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80086e:	ff 43 04             	incl   0x4(%ebx)
}
  800871:	83 c4 14             	add    $0x14,%esp
  800874:	5b                   	pop    %ebx
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800880:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800887:	00 00 00 
	b.cnt = 0;
  80088a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800891:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800894:	8b 45 0c             	mov    0xc(%ebp),%eax
  800897:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8008a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ac:	c7 04 24 38 08 80 00 	movl   $0x800838,(%esp)
  8008b3:	e8 82 01 00 00       	call   800a3a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8008b8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8008be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8008c8:	89 04 24             	mov    %eax,(%esp)
  8008cb:	e8 d8 08 00 00       	call   8011a8 <sys_cputs>

	return b.cnt;
}
  8008d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8008de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8008e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	89 04 24             	mov    %eax,(%esp)
  8008eb:	e8 87 ff ff ff       	call   800877 <vcprintf>
	va_end(ap);

	return cnt;
}
  8008f0:	c9                   	leave  
  8008f1:	c3                   	ret    
	...

008008f4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	57                   	push   %edi
  8008f8:	56                   	push   %esi
  8008f9:	53                   	push   %ebx
  8008fa:	83 ec 3c             	sub    $0x3c,%esp
  8008fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800900:	89 d7                	mov    %edx,%edi
  800902:	8b 45 08             	mov    0x8(%ebp),%eax
  800905:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800908:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80090e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800911:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800914:	85 c0                	test   %eax,%eax
  800916:	75 08                	jne    800920 <printnum+0x2c>
  800918:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80091b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80091e:	77 57                	ja     800977 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800920:	89 74 24 10          	mov    %esi,0x10(%esp)
  800924:	4b                   	dec    %ebx
  800925:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800929:	8b 45 10             	mov    0x10(%ebp),%eax
  80092c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800930:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800934:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800938:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80093f:	00 
  800940:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800943:	89 04 24             	mov    %eax,(%esp)
  800946:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800949:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094d:	e8 0e 20 00 00       	call   802960 <__udivdi3>
  800952:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800956:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80095a:	89 04 24             	mov    %eax,(%esp)
  80095d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800961:	89 fa                	mov    %edi,%edx
  800963:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800966:	e8 89 ff ff ff       	call   8008f4 <printnum>
  80096b:	eb 0f                	jmp    80097c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80096d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800971:	89 34 24             	mov    %esi,(%esp)
  800974:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800977:	4b                   	dec    %ebx
  800978:	85 db                	test   %ebx,%ebx
  80097a:	7f f1                	jg     80096d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80097c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800980:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800984:	8b 45 10             	mov    0x10(%ebp),%eax
  800987:	89 44 24 08          	mov    %eax,0x8(%esp)
  80098b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800992:	00 
  800993:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800996:	89 04 24             	mov    %eax,(%esp)
  800999:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80099c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a0:	e8 db 20 00 00       	call   802a80 <__umoddi3>
  8009a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8009a9:	0f be 80 af 2f 80 00 	movsbl 0x802faf(%eax),%eax
  8009b0:	89 04 24             	mov    %eax,(%esp)
  8009b3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8009b6:	83 c4 3c             	add    $0x3c,%esp
  8009b9:	5b                   	pop    %ebx
  8009ba:	5e                   	pop    %esi
  8009bb:	5f                   	pop    %edi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8009c1:	83 fa 01             	cmp    $0x1,%edx
  8009c4:	7e 0e                	jle    8009d4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8009c6:	8b 10                	mov    (%eax),%edx
  8009c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8009cb:	89 08                	mov    %ecx,(%eax)
  8009cd:	8b 02                	mov    (%edx),%eax
  8009cf:	8b 52 04             	mov    0x4(%edx),%edx
  8009d2:	eb 22                	jmp    8009f6 <getuint+0x38>
	else if (lflag)
  8009d4:	85 d2                	test   %edx,%edx
  8009d6:	74 10                	je     8009e8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8009d8:	8b 10                	mov    (%eax),%edx
  8009da:	8d 4a 04             	lea    0x4(%edx),%ecx
  8009dd:	89 08                	mov    %ecx,(%eax)
  8009df:	8b 02                	mov    (%edx),%eax
  8009e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e6:	eb 0e                	jmp    8009f6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8009e8:	8b 10                	mov    (%eax),%edx
  8009ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8009ed:	89 08                	mov    %ecx,(%eax)
  8009ef:	8b 02                	mov    (%edx),%eax
  8009f1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8009f6:	5d                   	pop    %ebp
  8009f7:	c3                   	ret    

008009f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8009fe:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800a01:	8b 10                	mov    (%eax),%edx
  800a03:	3b 50 04             	cmp    0x4(%eax),%edx
  800a06:	73 08                	jae    800a10 <sprintputch+0x18>
		*b->buf++ = ch;
  800a08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0b:	88 0a                	mov    %cl,(%edx)
  800a0d:	42                   	inc    %edx
  800a0e:	89 10                	mov    %edx,(%eax)
}
  800a10:	5d                   	pop    %ebp
  800a11:	c3                   	ret    

00800a12 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
  800a15:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800a18:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800a1b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a1f:	8b 45 10             	mov    0x10(%ebp),%eax
  800a22:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a29:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	89 04 24             	mov    %eax,(%esp)
  800a33:	e8 02 00 00 00       	call   800a3a <vprintfmt>
	va_end(ap);
}
  800a38:	c9                   	leave  
  800a39:	c3                   	ret    

00800a3a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	83 ec 4c             	sub    $0x4c,%esp
  800a43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a46:	8b 75 10             	mov    0x10(%ebp),%esi
  800a49:	eb 12                	jmp    800a5d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a4b:	85 c0                	test   %eax,%eax
  800a4d:	0f 84 6b 03 00 00    	je     800dbe <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  800a53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a57:	89 04 24             	mov    %eax,(%esp)
  800a5a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a5d:	0f b6 06             	movzbl (%esi),%eax
  800a60:	46                   	inc    %esi
  800a61:	83 f8 25             	cmp    $0x25,%eax
  800a64:	75 e5                	jne    800a4b <vprintfmt+0x11>
  800a66:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800a6a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800a71:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800a76:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800a7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a82:	eb 26                	jmp    800aaa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a84:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800a87:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800a8b:	eb 1d                	jmp    800aaa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a8d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800a90:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800a94:	eb 14                	jmp    800aaa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a96:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800a99:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800aa0:	eb 08                	jmp    800aaa <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800aa2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800aa5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aaa:	0f b6 06             	movzbl (%esi),%eax
  800aad:	8d 56 01             	lea    0x1(%esi),%edx
  800ab0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800ab3:	8a 16                	mov    (%esi),%dl
  800ab5:	83 ea 23             	sub    $0x23,%edx
  800ab8:	80 fa 55             	cmp    $0x55,%dl
  800abb:	0f 87 e1 02 00 00    	ja     800da2 <vprintfmt+0x368>
  800ac1:	0f b6 d2             	movzbl %dl,%edx
  800ac4:	ff 24 95 00 31 80 00 	jmp    *0x803100(,%edx,4)
  800acb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ace:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800ad3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800ad6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800ada:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800add:	8d 50 d0             	lea    -0x30(%eax),%edx
  800ae0:	83 fa 09             	cmp    $0x9,%edx
  800ae3:	77 2a                	ja     800b0f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800ae5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800ae6:	eb eb                	jmp    800ad3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800ae8:	8b 45 14             	mov    0x14(%ebp),%eax
  800aeb:	8d 50 04             	lea    0x4(%eax),%edx
  800aee:	89 55 14             	mov    %edx,0x14(%ebp)
  800af1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800af3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800af6:	eb 17                	jmp    800b0f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800af8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800afc:	78 98                	js     800a96 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800afe:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b01:	eb a7                	jmp    800aaa <vprintfmt+0x70>
  800b03:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800b06:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800b0d:	eb 9b                	jmp    800aaa <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800b0f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b13:	79 95                	jns    800aaa <vprintfmt+0x70>
  800b15:	eb 8b                	jmp    800aa2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800b17:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b18:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800b1b:	eb 8d                	jmp    800aaa <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800b1d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b20:	8d 50 04             	lea    0x4(%eax),%edx
  800b23:	89 55 14             	mov    %edx,0x14(%ebp)
  800b26:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b2a:	8b 00                	mov    (%eax),%eax
  800b2c:	89 04 24             	mov    %eax,(%esp)
  800b2f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b32:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800b35:	e9 23 ff ff ff       	jmp    800a5d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b3a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3d:	8d 50 04             	lea    0x4(%eax),%edx
  800b40:	89 55 14             	mov    %edx,0x14(%ebp)
  800b43:	8b 00                	mov    (%eax),%eax
  800b45:	85 c0                	test   %eax,%eax
  800b47:	79 02                	jns    800b4b <vprintfmt+0x111>
  800b49:	f7 d8                	neg    %eax
  800b4b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800b4d:	83 f8 10             	cmp    $0x10,%eax
  800b50:	7f 0b                	jg     800b5d <vprintfmt+0x123>
  800b52:	8b 04 85 60 32 80 00 	mov    0x803260(,%eax,4),%eax
  800b59:	85 c0                	test   %eax,%eax
  800b5b:	75 23                	jne    800b80 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800b5d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800b61:	c7 44 24 08 c7 2f 80 	movl   $0x802fc7,0x8(%esp)
  800b68:	00 
  800b69:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b70:	89 04 24             	mov    %eax,(%esp)
  800b73:	e8 9a fe ff ff       	call   800a12 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b78:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800b7b:	e9 dd fe ff ff       	jmp    800a5d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800b80:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b84:	c7 44 24 08 b9 33 80 	movl   $0x8033b9,0x8(%esp)
  800b8b:	00 
  800b8c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	89 14 24             	mov    %edx,(%esp)
  800b96:	e8 77 fe ff ff       	call   800a12 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b9b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b9e:	e9 ba fe ff ff       	jmp    800a5d <vprintfmt+0x23>
  800ba3:	89 f9                	mov    %edi,%ecx
  800ba5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ba8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800bab:	8b 45 14             	mov    0x14(%ebp),%eax
  800bae:	8d 50 04             	lea    0x4(%eax),%edx
  800bb1:	89 55 14             	mov    %edx,0x14(%ebp)
  800bb4:	8b 30                	mov    (%eax),%esi
  800bb6:	85 f6                	test   %esi,%esi
  800bb8:	75 05                	jne    800bbf <vprintfmt+0x185>
				p = "(null)";
  800bba:	be c0 2f 80 00       	mov    $0x802fc0,%esi
			if (width > 0 && padc != '-')
  800bbf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800bc3:	0f 8e 84 00 00 00    	jle    800c4d <vprintfmt+0x213>
  800bc9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800bcd:	74 7e                	je     800c4d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800bcf:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800bd3:	89 34 24             	mov    %esi,(%esp)
  800bd6:	e8 8b 02 00 00       	call   800e66 <strnlen>
  800bdb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800bde:	29 c2                	sub    %eax,%edx
  800be0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800be3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800be7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800bea:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800bed:	89 de                	mov    %ebx,%esi
  800bef:	89 d3                	mov    %edx,%ebx
  800bf1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800bf3:	eb 0b                	jmp    800c00 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800bf5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf9:	89 3c 24             	mov    %edi,(%esp)
  800bfc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800bff:	4b                   	dec    %ebx
  800c00:	85 db                	test   %ebx,%ebx
  800c02:	7f f1                	jg     800bf5 <vprintfmt+0x1bb>
  800c04:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800c07:	89 f3                	mov    %esi,%ebx
  800c09:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800c0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	79 05                	jns    800c18 <vprintfmt+0x1de>
  800c13:	b8 00 00 00 00       	mov    $0x0,%eax
  800c18:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c1b:	29 c2                	sub    %eax,%edx
  800c1d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c20:	eb 2b                	jmp    800c4d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c22:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800c26:	74 18                	je     800c40 <vprintfmt+0x206>
  800c28:	8d 50 e0             	lea    -0x20(%eax),%edx
  800c2b:	83 fa 5e             	cmp    $0x5e,%edx
  800c2e:	76 10                	jbe    800c40 <vprintfmt+0x206>
					putch('?', putdat);
  800c30:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c34:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800c3b:	ff 55 08             	call   *0x8(%ebp)
  800c3e:	eb 0a                	jmp    800c4a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800c40:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c44:	89 04 24             	mov    %eax,(%esp)
  800c47:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c4a:	ff 4d e4             	decl   -0x1c(%ebp)
  800c4d:	0f be 06             	movsbl (%esi),%eax
  800c50:	46                   	inc    %esi
  800c51:	85 c0                	test   %eax,%eax
  800c53:	74 21                	je     800c76 <vprintfmt+0x23c>
  800c55:	85 ff                	test   %edi,%edi
  800c57:	78 c9                	js     800c22 <vprintfmt+0x1e8>
  800c59:	4f                   	dec    %edi
  800c5a:	79 c6                	jns    800c22 <vprintfmt+0x1e8>
  800c5c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c5f:	89 de                	mov    %ebx,%esi
  800c61:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c64:	eb 18                	jmp    800c7e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800c66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c6a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800c71:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800c73:	4b                   	dec    %ebx
  800c74:	eb 08                	jmp    800c7e <vprintfmt+0x244>
  800c76:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c79:	89 de                	mov    %ebx,%esi
  800c7b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800c7e:	85 db                	test   %ebx,%ebx
  800c80:	7f e4                	jg     800c66 <vprintfmt+0x22c>
  800c82:	89 7d 08             	mov    %edi,0x8(%ebp)
  800c85:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c87:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800c8a:	e9 ce fd ff ff       	jmp    800a5d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c8f:	83 f9 01             	cmp    $0x1,%ecx
  800c92:	7e 10                	jle    800ca4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800c94:	8b 45 14             	mov    0x14(%ebp),%eax
  800c97:	8d 50 08             	lea    0x8(%eax),%edx
  800c9a:	89 55 14             	mov    %edx,0x14(%ebp)
  800c9d:	8b 30                	mov    (%eax),%esi
  800c9f:	8b 78 04             	mov    0x4(%eax),%edi
  800ca2:	eb 26                	jmp    800cca <vprintfmt+0x290>
	else if (lflag)
  800ca4:	85 c9                	test   %ecx,%ecx
  800ca6:	74 12                	je     800cba <vprintfmt+0x280>
		return va_arg(*ap, long);
  800ca8:	8b 45 14             	mov    0x14(%ebp),%eax
  800cab:	8d 50 04             	lea    0x4(%eax),%edx
  800cae:	89 55 14             	mov    %edx,0x14(%ebp)
  800cb1:	8b 30                	mov    (%eax),%esi
  800cb3:	89 f7                	mov    %esi,%edi
  800cb5:	c1 ff 1f             	sar    $0x1f,%edi
  800cb8:	eb 10                	jmp    800cca <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800cba:	8b 45 14             	mov    0x14(%ebp),%eax
  800cbd:	8d 50 04             	lea    0x4(%eax),%edx
  800cc0:	89 55 14             	mov    %edx,0x14(%ebp)
  800cc3:	8b 30                	mov    (%eax),%esi
  800cc5:	89 f7                	mov    %esi,%edi
  800cc7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800cca:	85 ff                	test   %edi,%edi
  800ccc:	78 0a                	js     800cd8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800cce:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd3:	e9 8c 00 00 00       	jmp    800d64 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800cd8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cdc:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800ce3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800ce6:	f7 de                	neg    %esi
  800ce8:	83 d7 00             	adc    $0x0,%edi
  800ceb:	f7 df                	neg    %edi
			}
			base = 10;
  800ced:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf2:	eb 70                	jmp    800d64 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800cf4:	89 ca                	mov    %ecx,%edx
  800cf6:	8d 45 14             	lea    0x14(%ebp),%eax
  800cf9:	e8 c0 fc ff ff       	call   8009be <getuint>
  800cfe:	89 c6                	mov    %eax,%esi
  800d00:	89 d7                	mov    %edx,%edi
			base = 10;
  800d02:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800d07:	eb 5b                	jmp    800d64 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			// putch('0', putdat);
			num = getuint(&ap,lflag);
  800d09:	89 ca                	mov    %ecx,%edx
  800d0b:	8d 45 14             	lea    0x14(%ebp),%eax
  800d0e:	e8 ab fc ff ff       	call   8009be <getuint>
  800d13:	89 c6                	mov    %eax,%esi
  800d15:	89 d7                	mov    %edx,%edi
			base = 8;
  800d17:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800d1c:	eb 46                	jmp    800d64 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800d1e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d22:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800d29:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800d2c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d30:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800d37:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800d3a:	8b 45 14             	mov    0x14(%ebp),%eax
  800d3d:	8d 50 04             	lea    0x4(%eax),%edx
  800d40:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800d43:	8b 30                	mov    (%eax),%esi
  800d45:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800d4a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800d4f:	eb 13                	jmp    800d64 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800d51:	89 ca                	mov    %ecx,%edx
  800d53:	8d 45 14             	lea    0x14(%ebp),%eax
  800d56:	e8 63 fc ff ff       	call   8009be <getuint>
  800d5b:	89 c6                	mov    %eax,%esi
  800d5d:	89 d7                	mov    %edx,%edi
			base = 16;
  800d5f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800d64:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800d68:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d6c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800d6f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d73:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d77:	89 34 24             	mov    %esi,(%esp)
  800d7a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800d7e:	89 da                	mov    %ebx,%edx
  800d80:	8b 45 08             	mov    0x8(%ebp),%eax
  800d83:	e8 6c fb ff ff       	call   8008f4 <printnum>
			break;
  800d88:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d8b:	e9 cd fc ff ff       	jmp    800a5d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800d90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d94:	89 04 24             	mov    %eax,(%esp)
  800d97:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d9a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800d9d:	e9 bb fc ff ff       	jmp    800a5d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800da2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800da6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800dad:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800db0:	eb 01                	jmp    800db3 <vprintfmt+0x379>
  800db2:	4e                   	dec    %esi
  800db3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800db7:	75 f9                	jne    800db2 <vprintfmt+0x378>
  800db9:	e9 9f fc ff ff       	jmp    800a5d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800dbe:	83 c4 4c             	add    $0x4c,%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	83 ec 28             	sub    $0x28,%esp
  800dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800dd2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800dd5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800dd9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ddc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800de3:	85 c0                	test   %eax,%eax
  800de5:	74 30                	je     800e17 <vsnprintf+0x51>
  800de7:	85 d2                	test   %edx,%edx
  800de9:	7e 33                	jle    800e1e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800deb:	8b 45 14             	mov    0x14(%ebp),%eax
  800dee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800df2:	8b 45 10             	mov    0x10(%ebp),%eax
  800df5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800df9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800dfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e00:	c7 04 24 f8 09 80 00 	movl   $0x8009f8,(%esp)
  800e07:	e8 2e fc ff ff       	call   800a3a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800e0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800e0f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e15:	eb 0c                	jmp    800e23 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800e17:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e1c:	eb 05                	jmp    800e23 <vsnprintf+0x5d>
  800e1e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800e23:	c9                   	leave  
  800e24:	c3                   	ret    

00800e25 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800e2b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800e2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e32:	8b 45 10             	mov    0x10(%ebp),%eax
  800e35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e40:	8b 45 08             	mov    0x8(%ebp),%eax
  800e43:	89 04 24             	mov    %eax,(%esp)
  800e46:	e8 7b ff ff ff       	call   800dc6 <vsnprintf>
	va_end(ap);

	return rc;
}
  800e4b:	c9                   	leave  
  800e4c:	c3                   	ret    
  800e4d:	00 00                	add    %al,(%eax)
	...

00800e50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800e56:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5b:	eb 01                	jmp    800e5e <strlen+0xe>
		n++;
  800e5d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800e5e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800e62:	75 f9                	jne    800e5d <strlen+0xd>
		n++;
	return n;
}
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800e6c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e74:	eb 01                	jmp    800e77 <strnlen+0x11>
		n++;
  800e76:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800e77:	39 d0                	cmp    %edx,%eax
  800e79:	74 06                	je     800e81 <strnlen+0x1b>
  800e7b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800e7f:	75 f5                	jne    800e76 <strnlen+0x10>
		n++;
	return n;
}
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	53                   	push   %ebx
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800e8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e92:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800e95:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800e98:	42                   	inc    %edx
  800e99:	84 c9                	test   %cl,%cl
  800e9b:	75 f5                	jne    800e92 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800e9d:	5b                   	pop    %ebx
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 08             	sub    $0x8,%esp
  800ea7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800eaa:	89 1c 24             	mov    %ebx,(%esp)
  800ead:	e8 9e ff ff ff       	call   800e50 <strlen>
	strcpy(dst + len, src);
  800eb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800eb9:	01 d8                	add    %ebx,%eax
  800ebb:	89 04 24             	mov    %eax,(%esp)
  800ebe:	e8 c0 ff ff ff       	call   800e83 <strcpy>
	return dst;
}
  800ec3:	89 d8                	mov    %ebx,%eax
  800ec5:	83 c4 08             	add    $0x8,%esp
  800ec8:	5b                   	pop    %ebx
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	56                   	push   %esi
  800ecf:	53                   	push   %ebx
  800ed0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ed9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ede:	eb 0c                	jmp    800eec <strncpy+0x21>
		*dst++ = *src;
  800ee0:	8a 1a                	mov    (%edx),%bl
  800ee2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ee5:	80 3a 01             	cmpb   $0x1,(%edx)
  800ee8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800eeb:	41                   	inc    %ecx
  800eec:	39 f1                	cmp    %esi,%ecx
  800eee:	75 f0                	jne    800ee0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	8b 75 08             	mov    0x8(%ebp),%esi
  800efc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eff:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f02:	85 d2                	test   %edx,%edx
  800f04:	75 0a                	jne    800f10 <strlcpy+0x1c>
  800f06:	89 f0                	mov    %esi,%eax
  800f08:	eb 1a                	jmp    800f24 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800f0a:	88 18                	mov    %bl,(%eax)
  800f0c:	40                   	inc    %eax
  800f0d:	41                   	inc    %ecx
  800f0e:	eb 02                	jmp    800f12 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800f10:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800f12:	4a                   	dec    %edx
  800f13:	74 0a                	je     800f1f <strlcpy+0x2b>
  800f15:	8a 19                	mov    (%ecx),%bl
  800f17:	84 db                	test   %bl,%bl
  800f19:	75 ef                	jne    800f0a <strlcpy+0x16>
  800f1b:	89 c2                	mov    %eax,%edx
  800f1d:	eb 02                	jmp    800f21 <strlcpy+0x2d>
  800f1f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800f21:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800f24:	29 f0                	sub    %esi,%eax
}
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    

00800f2a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f30:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800f33:	eb 02                	jmp    800f37 <strcmp+0xd>
		p++, q++;
  800f35:	41                   	inc    %ecx
  800f36:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800f37:	8a 01                	mov    (%ecx),%al
  800f39:	84 c0                	test   %al,%al
  800f3b:	74 04                	je     800f41 <strcmp+0x17>
  800f3d:	3a 02                	cmp    (%edx),%al
  800f3f:	74 f4                	je     800f35 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800f41:	0f b6 c0             	movzbl %al,%eax
  800f44:	0f b6 12             	movzbl (%edx),%edx
  800f47:	29 d0                	sub    %edx,%eax
}
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	53                   	push   %ebx
  800f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f55:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800f58:	eb 03                	jmp    800f5d <strncmp+0x12>
		n--, p++, q++;
  800f5a:	4a                   	dec    %edx
  800f5b:	40                   	inc    %eax
  800f5c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800f5d:	85 d2                	test   %edx,%edx
  800f5f:	74 14                	je     800f75 <strncmp+0x2a>
  800f61:	8a 18                	mov    (%eax),%bl
  800f63:	84 db                	test   %bl,%bl
  800f65:	74 04                	je     800f6b <strncmp+0x20>
  800f67:	3a 19                	cmp    (%ecx),%bl
  800f69:	74 ef                	je     800f5a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800f6b:	0f b6 00             	movzbl (%eax),%eax
  800f6e:	0f b6 11             	movzbl (%ecx),%edx
  800f71:	29 d0                	sub    %edx,%eax
  800f73:	eb 05                	jmp    800f7a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800f75:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800f7a:	5b                   	pop    %ebx
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    

00800f7d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	8b 45 08             	mov    0x8(%ebp),%eax
  800f83:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800f86:	eb 05                	jmp    800f8d <strchr+0x10>
		if (*s == c)
  800f88:	38 ca                	cmp    %cl,%dl
  800f8a:	74 0c                	je     800f98 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f8c:	40                   	inc    %eax
  800f8d:	8a 10                	mov    (%eax),%dl
  800f8f:	84 d2                	test   %dl,%dl
  800f91:	75 f5                	jne    800f88 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800f93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800fa3:	eb 05                	jmp    800faa <strfind+0x10>
		if (*s == c)
  800fa5:	38 ca                	cmp    %cl,%dl
  800fa7:	74 07                	je     800fb0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800fa9:	40                   	inc    %eax
  800faa:	8a 10                	mov    (%eax),%dl
  800fac:	84 d2                	test   %dl,%dl
  800fae:	75 f5                	jne    800fa5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	57                   	push   %edi
  800fb6:	56                   	push   %esi
  800fb7:	53                   	push   %ebx
  800fb8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800fbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800fc1:	85 c9                	test   %ecx,%ecx
  800fc3:	74 30                	je     800ff5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800fc5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fcb:	75 25                	jne    800ff2 <memset+0x40>
  800fcd:	f6 c1 03             	test   $0x3,%cl
  800fd0:	75 20                	jne    800ff2 <memset+0x40>
		c &= 0xFF;
  800fd2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800fd5:	89 d3                	mov    %edx,%ebx
  800fd7:	c1 e3 08             	shl    $0x8,%ebx
  800fda:	89 d6                	mov    %edx,%esi
  800fdc:	c1 e6 18             	shl    $0x18,%esi
  800fdf:	89 d0                	mov    %edx,%eax
  800fe1:	c1 e0 10             	shl    $0x10,%eax
  800fe4:	09 f0                	or     %esi,%eax
  800fe6:	09 d0                	or     %edx,%eax
  800fe8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800fea:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800fed:	fc                   	cld    
  800fee:	f3 ab                	rep stos %eax,%es:(%edi)
  800ff0:	eb 03                	jmp    800ff5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ff2:	fc                   	cld    
  800ff3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ff5:	89 f8                	mov    %edi,%eax
  800ff7:	5b                   	pop    %ebx
  800ff8:	5e                   	pop    %esi
  800ff9:	5f                   	pop    %edi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    

00800ffc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	57                   	push   %edi
  801000:	56                   	push   %esi
  801001:	8b 45 08             	mov    0x8(%ebp),%eax
  801004:	8b 75 0c             	mov    0xc(%ebp),%esi
  801007:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80100a:	39 c6                	cmp    %eax,%esi
  80100c:	73 34                	jae    801042 <memmove+0x46>
  80100e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801011:	39 d0                	cmp    %edx,%eax
  801013:	73 2d                	jae    801042 <memmove+0x46>
		s += n;
		d += n;
  801015:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801018:	f6 c2 03             	test   $0x3,%dl
  80101b:	75 1b                	jne    801038 <memmove+0x3c>
  80101d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801023:	75 13                	jne    801038 <memmove+0x3c>
  801025:	f6 c1 03             	test   $0x3,%cl
  801028:	75 0e                	jne    801038 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80102a:	83 ef 04             	sub    $0x4,%edi
  80102d:	8d 72 fc             	lea    -0x4(%edx),%esi
  801030:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801033:	fd                   	std    
  801034:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801036:	eb 07                	jmp    80103f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801038:	4f                   	dec    %edi
  801039:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80103c:	fd                   	std    
  80103d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80103f:	fc                   	cld    
  801040:	eb 20                	jmp    801062 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801042:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801048:	75 13                	jne    80105d <memmove+0x61>
  80104a:	a8 03                	test   $0x3,%al
  80104c:	75 0f                	jne    80105d <memmove+0x61>
  80104e:	f6 c1 03             	test   $0x3,%cl
  801051:	75 0a                	jne    80105d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801053:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801056:	89 c7                	mov    %eax,%edi
  801058:	fc                   	cld    
  801059:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80105b:	eb 05                	jmp    801062 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80105d:	89 c7                	mov    %eax,%edi
  80105f:	fc                   	cld    
  801060:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801062:	5e                   	pop    %esi
  801063:	5f                   	pop    %edi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80106c:	8b 45 10             	mov    0x10(%ebp),%eax
  80106f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801073:	8b 45 0c             	mov    0xc(%ebp),%eax
  801076:	89 44 24 04          	mov    %eax,0x4(%esp)
  80107a:	8b 45 08             	mov    0x8(%ebp),%eax
  80107d:	89 04 24             	mov    %eax,(%esp)
  801080:	e8 77 ff ff ff       	call   800ffc <memmove>
}
  801085:	c9                   	leave  
  801086:	c3                   	ret    

00801087 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	57                   	push   %edi
  80108b:	56                   	push   %esi
  80108c:	53                   	push   %ebx
  80108d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801090:	8b 75 0c             	mov    0xc(%ebp),%esi
  801093:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801096:	ba 00 00 00 00       	mov    $0x0,%edx
  80109b:	eb 16                	jmp    8010b3 <memcmp+0x2c>
		if (*s1 != *s2)
  80109d:	8a 04 17             	mov    (%edi,%edx,1),%al
  8010a0:	42                   	inc    %edx
  8010a1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8010a5:	38 c8                	cmp    %cl,%al
  8010a7:	74 0a                	je     8010b3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8010a9:	0f b6 c0             	movzbl %al,%eax
  8010ac:	0f b6 c9             	movzbl %cl,%ecx
  8010af:	29 c8                	sub    %ecx,%eax
  8010b1:	eb 09                	jmp    8010bc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010b3:	39 da                	cmp    %ebx,%edx
  8010b5:	75 e6                	jne    80109d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8010b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010bc:	5b                   	pop    %ebx
  8010bd:	5e                   	pop    %esi
  8010be:	5f                   	pop    %edi
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    

008010c1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8010ca:	89 c2                	mov    %eax,%edx
  8010cc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8010cf:	eb 05                	jmp    8010d6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010d1:	38 08                	cmp    %cl,(%eax)
  8010d3:	74 05                	je     8010da <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010d5:	40                   	inc    %eax
  8010d6:	39 d0                	cmp    %edx,%eax
  8010d8:	72 f7                	jb     8010d1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
  8010e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010e8:	eb 01                	jmp    8010eb <strtol+0xf>
		s++;
  8010ea:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010eb:	8a 02                	mov    (%edx),%al
  8010ed:	3c 20                	cmp    $0x20,%al
  8010ef:	74 f9                	je     8010ea <strtol+0xe>
  8010f1:	3c 09                	cmp    $0x9,%al
  8010f3:	74 f5                	je     8010ea <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010f5:	3c 2b                	cmp    $0x2b,%al
  8010f7:	75 08                	jne    801101 <strtol+0x25>
		s++;
  8010f9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8010fa:	bf 00 00 00 00       	mov    $0x0,%edi
  8010ff:	eb 13                	jmp    801114 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801101:	3c 2d                	cmp    $0x2d,%al
  801103:	75 0a                	jne    80110f <strtol+0x33>
		s++, neg = 1;
  801105:	8d 52 01             	lea    0x1(%edx),%edx
  801108:	bf 01 00 00 00       	mov    $0x1,%edi
  80110d:	eb 05                	jmp    801114 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80110f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801114:	85 db                	test   %ebx,%ebx
  801116:	74 05                	je     80111d <strtol+0x41>
  801118:	83 fb 10             	cmp    $0x10,%ebx
  80111b:	75 28                	jne    801145 <strtol+0x69>
  80111d:	8a 02                	mov    (%edx),%al
  80111f:	3c 30                	cmp    $0x30,%al
  801121:	75 10                	jne    801133 <strtol+0x57>
  801123:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801127:	75 0a                	jne    801133 <strtol+0x57>
		s += 2, base = 16;
  801129:	83 c2 02             	add    $0x2,%edx
  80112c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801131:	eb 12                	jmp    801145 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801133:	85 db                	test   %ebx,%ebx
  801135:	75 0e                	jne    801145 <strtol+0x69>
  801137:	3c 30                	cmp    $0x30,%al
  801139:	75 05                	jne    801140 <strtol+0x64>
		s++, base = 8;
  80113b:	42                   	inc    %edx
  80113c:	b3 08                	mov    $0x8,%bl
  80113e:	eb 05                	jmp    801145 <strtol+0x69>
	else if (base == 0)
		base = 10;
  801140:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801145:	b8 00 00 00 00       	mov    $0x0,%eax
  80114a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80114c:	8a 0a                	mov    (%edx),%cl
  80114e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801151:	80 fb 09             	cmp    $0x9,%bl
  801154:	77 08                	ja     80115e <strtol+0x82>
			dig = *s - '0';
  801156:	0f be c9             	movsbl %cl,%ecx
  801159:	83 e9 30             	sub    $0x30,%ecx
  80115c:	eb 1e                	jmp    80117c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80115e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801161:	80 fb 19             	cmp    $0x19,%bl
  801164:	77 08                	ja     80116e <strtol+0x92>
			dig = *s - 'a' + 10;
  801166:	0f be c9             	movsbl %cl,%ecx
  801169:	83 e9 57             	sub    $0x57,%ecx
  80116c:	eb 0e                	jmp    80117c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80116e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801171:	80 fb 19             	cmp    $0x19,%bl
  801174:	77 12                	ja     801188 <strtol+0xac>
			dig = *s - 'A' + 10;
  801176:	0f be c9             	movsbl %cl,%ecx
  801179:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80117c:	39 f1                	cmp    %esi,%ecx
  80117e:	7d 0c                	jge    80118c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801180:	42                   	inc    %edx
  801181:	0f af c6             	imul   %esi,%eax
  801184:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801186:	eb c4                	jmp    80114c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801188:	89 c1                	mov    %eax,%ecx
  80118a:	eb 02                	jmp    80118e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80118c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  80118e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801192:	74 05                	je     801199 <strtol+0xbd>
		*endptr = (char *) s;
  801194:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801197:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801199:	85 ff                	test   %edi,%edi
  80119b:	74 04                	je     8011a1 <strtol+0xc5>
  80119d:	89 c8                	mov    %ecx,%eax
  80119f:	f7 d8                	neg    %eax
}
  8011a1:	5b                   	pop    %ebx
  8011a2:	5e                   	pop    %esi
  8011a3:	5f                   	pop    %edi
  8011a4:	5d                   	pop    %ebp
  8011a5:	c3                   	ret    
	...

008011a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	57                   	push   %edi
  8011ac:	56                   	push   %esi
  8011ad:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b9:	89 c3                	mov    %eax,%ebx
  8011bb:	89 c7                	mov    %eax,%edi
  8011bd:	89 c6                	mov    %eax,%esi
  8011bf:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5f                   	pop    %edi
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    

008011c6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8011c6:	55                   	push   %ebp
  8011c7:	89 e5                	mov    %esp,%ebp
  8011c9:	57                   	push   %edi
  8011ca:	56                   	push   %esi
  8011cb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d6:	89 d1                	mov    %edx,%ecx
  8011d8:	89 d3                	mov    %edx,%ebx
  8011da:	89 d7                	mov    %edx,%edi
  8011dc:	89 d6                	mov    %edx,%esi
  8011de:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	57                   	push   %edi
  8011e9:	56                   	push   %esi
  8011ea:	53                   	push   %ebx
  8011eb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011f3:	b8 03 00 00 00       	mov    $0x3,%eax
  8011f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fb:	89 cb                	mov    %ecx,%ebx
  8011fd:	89 cf                	mov    %ecx,%edi
  8011ff:	89 ce                	mov    %ecx,%esi
  801201:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801203:	85 c0                	test   %eax,%eax
  801205:	7e 28                	jle    80122f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801207:	89 44 24 10          	mov    %eax,0x10(%esp)
  80120b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801212:	00 
  801213:	c7 44 24 08 c3 32 80 	movl   $0x8032c3,0x8(%esp)
  80121a:	00 
  80121b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801222:	00 
  801223:	c7 04 24 e0 32 80 00 	movl   $0x8032e0,(%esp)
  80122a:	e8 b1 f5 ff ff       	call   8007e0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80122f:	83 c4 2c             	add    $0x2c,%esp
  801232:	5b                   	pop    %ebx
  801233:	5e                   	pop    %esi
  801234:	5f                   	pop    %edi
  801235:	5d                   	pop    %ebp
  801236:	c3                   	ret    

00801237 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801237:	55                   	push   %ebp
  801238:	89 e5                	mov    %esp,%ebp
  80123a:	57                   	push   %edi
  80123b:	56                   	push   %esi
  80123c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80123d:	ba 00 00 00 00       	mov    $0x0,%edx
  801242:	b8 02 00 00 00       	mov    $0x2,%eax
  801247:	89 d1                	mov    %edx,%ecx
  801249:	89 d3                	mov    %edx,%ebx
  80124b:	89 d7                	mov    %edx,%edi
  80124d:	89 d6                	mov    %edx,%esi
  80124f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801251:	5b                   	pop    %ebx
  801252:	5e                   	pop    %esi
  801253:	5f                   	pop    %edi
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    

00801256 <sys_yield>:

void
sys_yield(void)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	57                   	push   %edi
  80125a:	56                   	push   %esi
  80125b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80125c:	ba 00 00 00 00       	mov    $0x0,%edx
  801261:	b8 0b 00 00 00       	mov    $0xb,%eax
  801266:	89 d1                	mov    %edx,%ecx
  801268:	89 d3                	mov    %edx,%ebx
  80126a:	89 d7                	mov    %edx,%edi
  80126c:	89 d6                	mov    %edx,%esi
  80126e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801270:	5b                   	pop    %ebx
  801271:	5e                   	pop    %esi
  801272:	5f                   	pop    %edi
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	57                   	push   %edi
  801279:	56                   	push   %esi
  80127a:	53                   	push   %ebx
  80127b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127e:	be 00 00 00 00       	mov    $0x0,%esi
  801283:	b8 04 00 00 00       	mov    $0x4,%eax
  801288:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80128b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128e:	8b 55 08             	mov    0x8(%ebp),%edx
  801291:	89 f7                	mov    %esi,%edi
  801293:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801295:	85 c0                	test   %eax,%eax
  801297:	7e 28                	jle    8012c1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  801299:	89 44 24 10          	mov    %eax,0x10(%esp)
  80129d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8012a4:	00 
  8012a5:	c7 44 24 08 c3 32 80 	movl   $0x8032c3,0x8(%esp)
  8012ac:	00 
  8012ad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012b4:	00 
  8012b5:	c7 04 24 e0 32 80 00 	movl   $0x8032e0,(%esp)
  8012bc:	e8 1f f5 ff ff       	call   8007e0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8012c1:	83 c4 2c             	add    $0x2c,%esp
  8012c4:	5b                   	pop    %ebx
  8012c5:	5e                   	pop    %esi
  8012c6:	5f                   	pop    %edi
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	57                   	push   %edi
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
  8012cf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8012d7:	8b 75 18             	mov    0x18(%ebp),%esi
  8012da:	8b 7d 14             	mov    0x14(%ebp),%edi
  8012dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	7e 28                	jle    801314 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8012f7:	00 
  8012f8:	c7 44 24 08 c3 32 80 	movl   $0x8032c3,0x8(%esp)
  8012ff:	00 
  801300:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801307:	00 
  801308:	c7 04 24 e0 32 80 00 	movl   $0x8032e0,(%esp)
  80130f:	e8 cc f4 ff ff       	call   8007e0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801314:	83 c4 2c             	add    $0x2c,%esp
  801317:	5b                   	pop    %ebx
  801318:	5e                   	pop    %esi
  801319:	5f                   	pop    %edi
  80131a:	5d                   	pop    %ebp
  80131b:	c3                   	ret    

0080131c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	57                   	push   %edi
  801320:	56                   	push   %esi
  801321:	53                   	push   %ebx
  801322:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801325:	bb 00 00 00 00       	mov    $0x0,%ebx
  80132a:	b8 06 00 00 00       	mov    $0x6,%eax
  80132f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801332:	8b 55 08             	mov    0x8(%ebp),%edx
  801335:	89 df                	mov    %ebx,%edi
  801337:	89 de                	mov    %ebx,%esi
  801339:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80133b:	85 c0                	test   %eax,%eax
  80133d:	7e 28                	jle    801367 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80133f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801343:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80134a:	00 
  80134b:	c7 44 24 08 c3 32 80 	movl   $0x8032c3,0x8(%esp)
  801352:	00 
  801353:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80135a:	00 
  80135b:	c7 04 24 e0 32 80 00 	movl   $0x8032e0,(%esp)
  801362:	e8 79 f4 ff ff       	call   8007e0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801367:	83 c4 2c             	add    $0x2c,%esp
  80136a:	5b                   	pop    %ebx
  80136b:	5e                   	pop    %esi
  80136c:	5f                   	pop    %edi
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    

0080136f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	57                   	push   %edi
  801373:	56                   	push   %esi
  801374:	53                   	push   %ebx
  801375:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801378:	bb 00 00 00 00       	mov    $0x0,%ebx
  80137d:	b8 08 00 00 00       	mov    $0x8,%eax
  801382:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801385:	8b 55 08             	mov    0x8(%ebp),%edx
  801388:	89 df                	mov    %ebx,%edi
  80138a:	89 de                	mov    %ebx,%esi
  80138c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80138e:	85 c0                	test   %eax,%eax
  801390:	7e 28                	jle    8013ba <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801392:	89 44 24 10          	mov    %eax,0x10(%esp)
  801396:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80139d:	00 
  80139e:	c7 44 24 08 c3 32 80 	movl   $0x8032c3,0x8(%esp)
  8013a5:	00 
  8013a6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013ad:	00 
  8013ae:	c7 04 24 e0 32 80 00 	movl   $0x8032e0,(%esp)
  8013b5:	e8 26 f4 ff ff       	call   8007e0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8013ba:	83 c4 2c             	add    $0x2c,%esp
  8013bd:	5b                   	pop    %ebx
  8013be:	5e                   	pop    %esi
  8013bf:	5f                   	pop    %edi
  8013c0:	5d                   	pop    %ebp
  8013c1:	c3                   	ret    

008013c2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	57                   	push   %edi
  8013c6:	56                   	push   %esi
  8013c7:	53                   	push   %ebx
  8013c8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013d0:	b8 09 00 00 00       	mov    $0x9,%eax
  8013d5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8013db:	89 df                	mov    %ebx,%edi
  8013dd:	89 de                	mov    %ebx,%esi
  8013df:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	7e 28                	jle    80140d <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013e5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013e9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8013f0:	00 
  8013f1:	c7 44 24 08 c3 32 80 	movl   $0x8032c3,0x8(%esp)
  8013f8:	00 
  8013f9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801400:	00 
  801401:	c7 04 24 e0 32 80 00 	movl   $0x8032e0,(%esp)
  801408:	e8 d3 f3 ff ff       	call   8007e0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80140d:	83 c4 2c             	add    $0x2c,%esp
  801410:	5b                   	pop    %ebx
  801411:	5e                   	pop    %esi
  801412:	5f                   	pop    %edi
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	57                   	push   %edi
  801419:	56                   	push   %esi
  80141a:	53                   	push   %ebx
  80141b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80141e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801423:	b8 0a 00 00 00       	mov    $0xa,%eax
  801428:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80142b:	8b 55 08             	mov    0x8(%ebp),%edx
  80142e:	89 df                	mov    %ebx,%edi
  801430:	89 de                	mov    %ebx,%esi
  801432:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801434:	85 c0                	test   %eax,%eax
  801436:	7e 28                	jle    801460 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801438:	89 44 24 10          	mov    %eax,0x10(%esp)
  80143c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  801443:	00 
  801444:	c7 44 24 08 c3 32 80 	movl   $0x8032c3,0x8(%esp)
  80144b:	00 
  80144c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801453:	00 
  801454:	c7 04 24 e0 32 80 00 	movl   $0x8032e0,(%esp)
  80145b:	e8 80 f3 ff ff       	call   8007e0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801460:	83 c4 2c             	add    $0x2c,%esp
  801463:	5b                   	pop    %ebx
  801464:	5e                   	pop    %esi
  801465:	5f                   	pop    %edi
  801466:	5d                   	pop    %ebp
  801467:	c3                   	ret    

00801468 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801468:	55                   	push   %ebp
  801469:	89 e5                	mov    %esp,%ebp
  80146b:	57                   	push   %edi
  80146c:	56                   	push   %esi
  80146d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80146e:	be 00 00 00 00       	mov    $0x0,%esi
  801473:	b8 0c 00 00 00       	mov    $0xc,%eax
  801478:	8b 7d 14             	mov    0x14(%ebp),%edi
  80147b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80147e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801481:	8b 55 08             	mov    0x8(%ebp),%edx
  801484:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801486:	5b                   	pop    %ebx
  801487:	5e                   	pop    %esi
  801488:	5f                   	pop    %edi
  801489:	5d                   	pop    %ebp
  80148a:	c3                   	ret    

0080148b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	57                   	push   %edi
  80148f:	56                   	push   %esi
  801490:	53                   	push   %ebx
  801491:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801494:	b9 00 00 00 00       	mov    $0x0,%ecx
  801499:	b8 0d 00 00 00       	mov    $0xd,%eax
  80149e:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a1:	89 cb                	mov    %ecx,%ebx
  8014a3:	89 cf                	mov    %ecx,%edi
  8014a5:	89 ce                	mov    %ecx,%esi
  8014a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	7e 28                	jle    8014d5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8014ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8014b1:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8014b8:	00 
  8014b9:	c7 44 24 08 c3 32 80 	movl   $0x8032c3,0x8(%esp)
  8014c0:	00 
  8014c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8014c8:	00 
  8014c9:	c7 04 24 e0 32 80 00 	movl   $0x8032e0,(%esp)
  8014d0:	e8 0b f3 ff ff       	call   8007e0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8014d5:	83 c4 2c             	add    $0x2c,%esp
  8014d8:	5b                   	pop    %ebx
  8014d9:	5e                   	pop    %esi
  8014da:	5f                   	pop    %edi
  8014db:	5d                   	pop    %ebp
  8014dc:	c3                   	ret    

008014dd <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	57                   	push   %edi
  8014e1:	56                   	push   %esi
  8014e2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e8:	b8 0e 00 00 00       	mov    $0xe,%eax
  8014ed:	89 d1                	mov    %edx,%ecx
  8014ef:	89 d3                	mov    %edx,%ebx
  8014f1:	89 d7                	mov    %edx,%edi
  8014f3:	89 d6                	mov    %edx,%esi
  8014f5:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8014f7:	5b                   	pop    %ebx
  8014f8:	5e                   	pop    %esi
  8014f9:	5f                   	pop    %edi
  8014fa:	5d                   	pop    %ebp
  8014fb:	c3                   	ret    

008014fc <sys_e1000_transmit>:

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	57                   	push   %edi
  801500:	56                   	push   %esi
  801501:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801502:	bb 00 00 00 00       	mov    $0x0,%ebx
  801507:	b8 0f 00 00 00       	mov    $0xf,%eax
  80150c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80150f:	8b 55 08             	mov    0x8(%ebp),%edx
  801512:	89 df                	mov    %ebx,%edi
  801514:	89 de                	mov    %ebx,%esi
  801516:	cd 30                	int    $0x30

int 
sys_e1000_transmit(char *packet, uint32_t len)
{
	return syscall(SYS_e1000_transmit, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  801518:	5b                   	pop    %ebx
  801519:	5e                   	pop    %esi
  80151a:	5f                   	pop    %edi
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    

0080151d <sys_e1000_receive>:

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	57                   	push   %edi
  801521:	56                   	push   %esi
  801522:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801523:	bb 00 00 00 00       	mov    $0x0,%ebx
  801528:	b8 10 00 00 00       	mov    $0x10,%eax
  80152d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801530:	8b 55 08             	mov    0x8(%ebp),%edx
  801533:	89 df                	mov    %ebx,%edi
  801535:	89 de                	mov    %ebx,%esi
  801537:	cd 30                	int    $0x30

int 
sys_e1000_receive(char *packet, uint32_t *len)
{
	return syscall(SYS_e1000_receive, 0, (uint32_t)packet, (uint32_t)len, 0, 0, 0);
}
  801539:	5b                   	pop    %ebx
  80153a:	5e                   	pop    %esi
  80153b:	5f                   	pop    %edi
  80153c:	5d                   	pop    %ebp
  80153d:	c3                   	ret    
	...

00801540 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	56                   	push   %esi
  801544:	53                   	push   %ebx
  801545:	83 ec 10             	sub    $0x10,%esp
  801548:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80154b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80154e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 4: Your code here.
	int r;
	if (pg)
  801551:	85 c0                	test   %eax,%eax
  801553:	74 0a                	je     80155f <ipc_recv+0x1f>
	{
		r = sys_ipc_recv(pg);
  801555:	89 04 24             	mov    %eax,(%esp)
  801558:	e8 2e ff ff ff       	call   80148b <sys_ipc_recv>
  80155d:	eb 0c                	jmp    80156b <ipc_recv+0x2b>
	}
	else
	{
		r = sys_ipc_recv((void *)UTOP);
  80155f:	c7 04 24 00 00 c0 ee 	movl   $0xeec00000,(%esp)
  801566:	e8 20 ff ff ff       	call   80148b <sys_ipc_recv>
	}
	if (r < 0)
  80156b:	85 c0                	test   %eax,%eax
  80156d:	79 16                	jns    801585 <ipc_recv+0x45>
	{
		if(from_env_store) *from_env_store = 0;
  80156f:	85 db                	test   %ebx,%ebx
  801571:	74 06                	je     801579 <ipc_recv+0x39>
  801573:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(perm_store) *perm_store = 0;
  801579:	85 f6                	test   %esi,%esi
  80157b:	74 2c                	je     8015a9 <ipc_recv+0x69>
  80157d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  801583:	eb 24                	jmp    8015a9 <ipc_recv+0x69>
		return r;
	}
	if (from_env_store)
  801585:	85 db                	test   %ebx,%ebx
  801587:	74 0a                	je     801593 <ipc_recv+0x53>
	{
		*from_env_store = thisenv->env_ipc_from;
  801589:	a1 08 50 80 00       	mov    0x805008,%eax
  80158e:	8b 40 74             	mov    0x74(%eax),%eax
  801591:	89 03                	mov    %eax,(%ebx)
	}
	if (perm_store)
  801593:	85 f6                	test   %esi,%esi
  801595:	74 0a                	je     8015a1 <ipc_recv+0x61>
	{
		*perm_store = thisenv->env_ipc_perm;
  801597:	a1 08 50 80 00       	mov    0x805008,%eax
  80159c:	8b 40 78             	mov    0x78(%eax),%eax
  80159f:	89 06                	mov    %eax,(%esi)
	}
	return thisenv->env_ipc_value;
  8015a1:	a1 08 50 80 00       	mov    0x805008,%eax
  8015a6:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	//return 0;
}
  8015a9:	83 c4 10             	add    $0x10,%esp
  8015ac:	5b                   	pop    %ebx
  8015ad:	5e                   	pop    %esi
  8015ae:	5d                   	pop    %ebp
  8015af:	c3                   	ret    

008015b0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	57                   	push   %edi
  8015b4:	56                   	push   %esi
  8015b5:	53                   	push   %ebx
  8015b6:	83 ec 1c             	sub    $0x1c,%esp
  8015b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8015bc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	while (1)
	{
		if (pg)
  8015c2:	85 db                	test   %ebx,%ebx
  8015c4:	74 19                	je     8015df <ipc_send+0x2f>
		{
			r = sys_ipc_try_send(to_env, val, pg, perm);
  8015c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015cd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015d5:	89 34 24             	mov    %esi,(%esp)
  8015d8:	e8 8b fe ff ff       	call   801468 <sys_ipc_try_send>
  8015dd:	eb 1c                	jmp    8015fb <ipc_send+0x4b>
		}
		else
		{
			r = sys_ipc_try_send(to_env, val, (void *)UTOP, 0);
  8015df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8015e6:	00 
  8015e7:	c7 44 24 08 00 00 c0 	movl   $0xeec00000,0x8(%esp)
  8015ee:	ee 
  8015ef:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015f3:	89 34 24             	mov    %esi,(%esp)
  8015f6:	e8 6d fe ff ff       	call   801468 <sys_ipc_try_send>
		}
		if (r == 0)
  8015fb:	85 c0                	test   %eax,%eax
  8015fd:	74 2c                	je     80162b <ipc_send+0x7b>
		{
			break;
		}
		if (r != -E_IPC_NOT_RECV)
  8015ff:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801602:	74 20                	je     801624 <ipc_send+0x74>
		{
			panic("ipc send error: %e", r);
  801604:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801608:	c7 44 24 08 ee 32 80 	movl   $0x8032ee,0x8(%esp)
  80160f:	00 
  801610:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  801617:	00 
  801618:	c7 04 24 01 33 80 00 	movl   $0x803301,(%esp)
  80161f:	e8 bc f1 ff ff       	call   8007e0 <_panic>
		}
		sys_yield();
  801624:	e8 2d fc ff ff       	call   801256 <sys_yield>
	}
  801629:	eb 97                	jmp    8015c2 <ipc_send+0x12>
	//panic("ipc_send not implemented");
}
  80162b:	83 c4 1c             	add    $0x1c,%esp
  80162e:	5b                   	pop    %ebx
  80162f:	5e                   	pop    %esi
  801630:	5f                   	pop    %edi
  801631:	5d                   	pop    %ebp
  801632:	c3                   	ret    

00801633 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801633:	55                   	push   %ebp
  801634:	89 e5                	mov    %esp,%ebp
  801636:	53                   	push   %ebx
  801637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80163a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80163f:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801646:	89 c2                	mov    %eax,%edx
  801648:	c1 e2 07             	shl    $0x7,%edx
  80164b:	29 ca                	sub    %ecx,%edx
  80164d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801653:	8b 52 50             	mov    0x50(%edx),%edx
  801656:	39 da                	cmp    %ebx,%edx
  801658:	75 0f                	jne    801669 <ipc_find_env+0x36>
			return envs[i].env_id;
  80165a:	c1 e0 07             	shl    $0x7,%eax
  80165d:	29 c8                	sub    %ecx,%eax
  80165f:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801664:	8b 40 40             	mov    0x40(%eax),%eax
  801667:	eb 0c                	jmp    801675 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801669:	40                   	inc    %eax
  80166a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80166f:	75 ce                	jne    80163f <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801671:	66 b8 00 00          	mov    $0x0,%ax
}
  801675:	5b                   	pop    %ebx
  801676:	5d                   	pop    %ebp
  801677:	c3                   	ret    

00801678 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80167b:	8b 45 08             	mov    0x8(%ebp),%eax
  80167e:	05 00 00 00 30       	add    $0x30000000,%eax
  801683:	c1 e8 0c             	shr    $0xc,%eax
}
  801686:	5d                   	pop    %ebp
  801687:	c3                   	ret    

00801688 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80168e:	8b 45 08             	mov    0x8(%ebp),%eax
  801691:	89 04 24             	mov    %eax,(%esp)
  801694:	e8 df ff ff ff       	call   801678 <fd2num>
  801699:	c1 e0 0c             	shl    $0xc,%eax
  80169c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    

008016a3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	53                   	push   %ebx
  8016a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8016aa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8016af:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8016b1:	89 c2                	mov    %eax,%edx
  8016b3:	c1 ea 16             	shr    $0x16,%edx
  8016b6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016bd:	f6 c2 01             	test   $0x1,%dl
  8016c0:	74 11                	je     8016d3 <fd_alloc+0x30>
  8016c2:	89 c2                	mov    %eax,%edx
  8016c4:	c1 ea 0c             	shr    $0xc,%edx
  8016c7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016ce:	f6 c2 01             	test   $0x1,%dl
  8016d1:	75 09                	jne    8016dc <fd_alloc+0x39>
			*fd_store = fd;
  8016d3:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  8016d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8016da:	eb 17                	jmp    8016f3 <fd_alloc+0x50>
  8016dc:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016e1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016e6:	75 c7                	jne    8016af <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016e8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8016ee:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8016f3:	5b                   	pop    %ebx
  8016f4:	5d                   	pop    %ebp
  8016f5:	c3                   	ret    

008016f6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8016fc:	83 f8 1f             	cmp    $0x1f,%eax
  8016ff:	77 36                	ja     801737 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801701:	c1 e0 0c             	shl    $0xc,%eax
  801704:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801709:	89 c2                	mov    %eax,%edx
  80170b:	c1 ea 16             	shr    $0x16,%edx
  80170e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801715:	f6 c2 01             	test   $0x1,%dl
  801718:	74 24                	je     80173e <fd_lookup+0x48>
  80171a:	89 c2                	mov    %eax,%edx
  80171c:	c1 ea 0c             	shr    $0xc,%edx
  80171f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801726:	f6 c2 01             	test   $0x1,%dl
  801729:	74 1a                	je     801745 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80172b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80172e:	89 02                	mov    %eax,(%edx)
	return 0;
  801730:	b8 00 00 00 00       	mov    $0x0,%eax
  801735:	eb 13                	jmp    80174a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801737:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80173c:	eb 0c                	jmp    80174a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80173e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801743:	eb 05                	jmp    80174a <fd_lookup+0x54>
  801745:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80174a:	5d                   	pop    %ebp
  80174b:	c3                   	ret    

0080174c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	53                   	push   %ebx
  801750:	83 ec 14             	sub    $0x14,%esp
  801753:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801756:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801759:	ba 00 00 00 00       	mov    $0x0,%edx
  80175e:	eb 0e                	jmp    80176e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801760:	39 08                	cmp    %ecx,(%eax)
  801762:	75 09                	jne    80176d <dev_lookup+0x21>
			*dev = devtab[i];
  801764:	89 03                	mov    %eax,(%ebx)
			return 0;
  801766:	b8 00 00 00 00       	mov    $0x0,%eax
  80176b:	eb 33                	jmp    8017a0 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80176d:	42                   	inc    %edx
  80176e:	8b 04 95 8c 33 80 00 	mov    0x80338c(,%edx,4),%eax
  801775:	85 c0                	test   %eax,%eax
  801777:	75 e7                	jne    801760 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801779:	a1 08 50 80 00       	mov    0x805008,%eax
  80177e:	8b 40 48             	mov    0x48(%eax),%eax
  801781:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801785:	89 44 24 04          	mov    %eax,0x4(%esp)
  801789:	c7 04 24 0c 33 80 00 	movl   $0x80330c,(%esp)
  801790:	e8 43 f1 ff ff       	call   8008d8 <cprintf>
	*dev = 0;
  801795:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80179b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017a0:	83 c4 14             	add    $0x14,%esp
  8017a3:	5b                   	pop    %ebx
  8017a4:	5d                   	pop    %ebp
  8017a5:	c3                   	ret    

008017a6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	56                   	push   %esi
  8017aa:	53                   	push   %ebx
  8017ab:	83 ec 30             	sub    $0x30,%esp
  8017ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8017b1:	8a 45 0c             	mov    0xc(%ebp),%al
  8017b4:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8017b7:	89 34 24             	mov    %esi,(%esp)
  8017ba:	e8 b9 fe ff ff       	call   801678 <fd2num>
  8017bf:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8017c2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017c6:	89 04 24             	mov    %eax,(%esp)
  8017c9:	e8 28 ff ff ff       	call   8016f6 <fd_lookup>
  8017ce:	89 c3                	mov    %eax,%ebx
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	78 05                	js     8017d9 <fd_close+0x33>
	    || fd != fd2)
  8017d4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8017d7:	74 0d                	je     8017e6 <fd_close+0x40>
		return (must_exist ? r : 0);
  8017d9:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  8017dd:	75 46                	jne    801825 <fd_close+0x7f>
  8017df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017e4:	eb 3f                	jmp    801825 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8017e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ed:	8b 06                	mov    (%esi),%eax
  8017ef:	89 04 24             	mov    %eax,(%esp)
  8017f2:	e8 55 ff ff ff       	call   80174c <dev_lookup>
  8017f7:	89 c3                	mov    %eax,%ebx
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 18                	js     801815 <fd_close+0x6f>
		if (dev->dev_close)
  8017fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801800:	8b 40 10             	mov    0x10(%eax),%eax
  801803:	85 c0                	test   %eax,%eax
  801805:	74 09                	je     801810 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801807:	89 34 24             	mov    %esi,(%esp)
  80180a:	ff d0                	call   *%eax
  80180c:	89 c3                	mov    %eax,%ebx
  80180e:	eb 05                	jmp    801815 <fd_close+0x6f>
		else
			r = 0;
  801810:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801815:	89 74 24 04          	mov    %esi,0x4(%esp)
  801819:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801820:	e8 f7 fa ff ff       	call   80131c <sys_page_unmap>
	return r;
}
  801825:	89 d8                	mov    %ebx,%eax
  801827:	83 c4 30             	add    $0x30,%esp
  80182a:	5b                   	pop    %ebx
  80182b:	5e                   	pop    %esi
  80182c:	5d                   	pop    %ebp
  80182d:	c3                   	ret    

0080182e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801834:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183b:	8b 45 08             	mov    0x8(%ebp),%eax
  80183e:	89 04 24             	mov    %eax,(%esp)
  801841:	e8 b0 fe ff ff       	call   8016f6 <fd_lookup>
  801846:	85 c0                	test   %eax,%eax
  801848:	78 13                	js     80185d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80184a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801851:	00 
  801852:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801855:	89 04 24             	mov    %eax,(%esp)
  801858:	e8 49 ff ff ff       	call   8017a6 <fd_close>
}
  80185d:	c9                   	leave  
  80185e:	c3                   	ret    

0080185f <close_all>:

void
close_all(void)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	53                   	push   %ebx
  801863:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801866:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80186b:	89 1c 24             	mov    %ebx,(%esp)
  80186e:	e8 bb ff ff ff       	call   80182e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801873:	43                   	inc    %ebx
  801874:	83 fb 20             	cmp    $0x20,%ebx
  801877:	75 f2                	jne    80186b <close_all+0xc>
		close(i);
}
  801879:	83 c4 14             	add    $0x14,%esp
  80187c:	5b                   	pop    %ebx
  80187d:	5d                   	pop    %ebp
  80187e:	c3                   	ret    

0080187f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	57                   	push   %edi
  801883:	56                   	push   %esi
  801884:	53                   	push   %ebx
  801885:	83 ec 4c             	sub    $0x4c,%esp
  801888:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80188b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80188e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801892:	8b 45 08             	mov    0x8(%ebp),%eax
  801895:	89 04 24             	mov    %eax,(%esp)
  801898:	e8 59 fe ff ff       	call   8016f6 <fd_lookup>
  80189d:	89 c3                	mov    %eax,%ebx
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	0f 88 e3 00 00 00    	js     80198a <dup+0x10b>
		return r;
	close(newfdnum);
  8018a7:	89 3c 24             	mov    %edi,(%esp)
  8018aa:	e8 7f ff ff ff       	call   80182e <close>

	newfd = INDEX2FD(newfdnum);
  8018af:	89 fe                	mov    %edi,%esi
  8018b1:	c1 e6 0c             	shl    $0xc,%esi
  8018b4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8018ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018bd:	89 04 24             	mov    %eax,(%esp)
  8018c0:	e8 c3 fd ff ff       	call   801688 <fd2data>
  8018c5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8018c7:	89 34 24             	mov    %esi,(%esp)
  8018ca:	e8 b9 fd ff ff       	call   801688 <fd2data>
  8018cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8018d2:	89 d8                	mov    %ebx,%eax
  8018d4:	c1 e8 16             	shr    $0x16,%eax
  8018d7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018de:	a8 01                	test   $0x1,%al
  8018e0:	74 46                	je     801928 <dup+0xa9>
  8018e2:	89 d8                	mov    %ebx,%eax
  8018e4:	c1 e8 0c             	shr    $0xc,%eax
  8018e7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8018ee:	f6 c2 01             	test   $0x1,%dl
  8018f1:	74 35                	je     801928 <dup+0xa9>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8018f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018fa:	25 07 0e 00 00       	and    $0xe07,%eax
  8018ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  801903:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801906:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80190a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801911:	00 
  801912:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801916:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80191d:	e8 a7 f9 ff ff       	call   8012c9 <sys_page_map>
  801922:	89 c3                	mov    %eax,%ebx
  801924:	85 c0                	test   %eax,%eax
  801926:	78 3b                	js     801963 <dup+0xe4>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801928:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80192b:	89 c2                	mov    %eax,%edx
  80192d:	c1 ea 0c             	shr    $0xc,%edx
  801930:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801937:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80193d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801941:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801945:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80194c:	00 
  80194d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801951:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801958:	e8 6c f9 ff ff       	call   8012c9 <sys_page_map>
  80195d:	89 c3                	mov    %eax,%ebx
  80195f:	85 c0                	test   %eax,%eax
  801961:	79 25                	jns    801988 <dup+0x109>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801963:	89 74 24 04          	mov    %esi,0x4(%esp)
  801967:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80196e:	e8 a9 f9 ff ff       	call   80131c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801973:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801976:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801981:	e8 96 f9 ff ff       	call   80131c <sys_page_unmap>
	return r;
  801986:	eb 02                	jmp    80198a <dup+0x10b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801988:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80198a:	89 d8                	mov    %ebx,%eax
  80198c:	83 c4 4c             	add    $0x4c,%esp
  80198f:	5b                   	pop    %ebx
  801990:	5e                   	pop    %esi
  801991:	5f                   	pop    %edi
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    

00801994 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	53                   	push   %ebx
  801998:	83 ec 24             	sub    $0x24,%esp
  80199b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80199e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a5:	89 1c 24             	mov    %ebx,(%esp)
  8019a8:	e8 49 fd ff ff       	call   8016f6 <fd_lookup>
  8019ad:	85 c0                	test   %eax,%eax
  8019af:	78 6d                	js     801a1e <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019bb:	8b 00                	mov    (%eax),%eax
  8019bd:	89 04 24             	mov    %eax,(%esp)
  8019c0:	e8 87 fd ff ff       	call   80174c <dev_lookup>
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	78 55                	js     801a1e <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019cc:	8b 50 08             	mov    0x8(%eax),%edx
  8019cf:	83 e2 03             	and    $0x3,%edx
  8019d2:	83 fa 01             	cmp    $0x1,%edx
  8019d5:	75 23                	jne    8019fa <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019d7:	a1 08 50 80 00       	mov    0x805008,%eax
  8019dc:	8b 40 48             	mov    0x48(%eax),%eax
  8019df:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e7:	c7 04 24 50 33 80 00 	movl   $0x803350,(%esp)
  8019ee:	e8 e5 ee ff ff       	call   8008d8 <cprintf>
		return -E_INVAL;
  8019f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019f8:	eb 24                	jmp    801a1e <read+0x8a>
	}
	if (!dev->dev_read)
  8019fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019fd:	8b 52 08             	mov    0x8(%edx),%edx
  801a00:	85 d2                	test   %edx,%edx
  801a02:	74 15                	je     801a19 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a04:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a07:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a0e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801a12:	89 04 24             	mov    %eax,(%esp)
  801a15:	ff d2                	call   *%edx
  801a17:	eb 05                	jmp    801a1e <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801a19:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  801a1e:	83 c4 24             	add    $0x24,%esp
  801a21:	5b                   	pop    %ebx
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	57                   	push   %edi
  801a28:	56                   	push   %esi
  801a29:	53                   	push   %ebx
  801a2a:	83 ec 1c             	sub    $0x1c,%esp
  801a2d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a30:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a33:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a38:	eb 23                	jmp    801a5d <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a3a:	89 f0                	mov    %esi,%eax
  801a3c:	29 d8                	sub    %ebx,%eax
  801a3e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a45:	01 d8                	add    %ebx,%eax
  801a47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4b:	89 3c 24             	mov    %edi,(%esp)
  801a4e:	e8 41 ff ff ff       	call   801994 <read>
		if (m < 0)
  801a53:	85 c0                	test   %eax,%eax
  801a55:	78 10                	js     801a67 <readn+0x43>
			return m;
		if (m == 0)
  801a57:	85 c0                	test   %eax,%eax
  801a59:	74 0a                	je     801a65 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a5b:	01 c3                	add    %eax,%ebx
  801a5d:	39 f3                	cmp    %esi,%ebx
  801a5f:	72 d9                	jb     801a3a <readn+0x16>
  801a61:	89 d8                	mov    %ebx,%eax
  801a63:	eb 02                	jmp    801a67 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801a65:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801a67:	83 c4 1c             	add    $0x1c,%esp
  801a6a:	5b                   	pop    %ebx
  801a6b:	5e                   	pop    %esi
  801a6c:	5f                   	pop    %edi
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	53                   	push   %ebx
  801a73:	83 ec 24             	sub    $0x24,%esp
  801a76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a79:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a80:	89 1c 24             	mov    %ebx,(%esp)
  801a83:	e8 6e fc ff ff       	call   8016f6 <fd_lookup>
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	78 68                	js     801af4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a8c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a96:	8b 00                	mov    (%eax),%eax
  801a98:	89 04 24             	mov    %eax,(%esp)
  801a9b:	e8 ac fc ff ff       	call   80174c <dev_lookup>
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	78 50                	js     801af4 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aa7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801aab:	75 23                	jne    801ad0 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801aad:	a1 08 50 80 00       	mov    0x805008,%eax
  801ab2:	8b 40 48             	mov    0x48(%eax),%eax
  801ab5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abd:	c7 04 24 6c 33 80 00 	movl   $0x80336c,(%esp)
  801ac4:	e8 0f ee ff ff       	call   8008d8 <cprintf>
		return -E_INVAL;
  801ac9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ace:	eb 24                	jmp    801af4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801ad0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ad3:	8b 52 0c             	mov    0xc(%edx),%edx
  801ad6:	85 d2                	test   %edx,%edx
  801ad8:	74 15                	je     801aef <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801ada:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801add:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ae1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ae8:	89 04 24             	mov    %eax,(%esp)
  801aeb:	ff d2                	call   *%edx
  801aed:	eb 05                	jmp    801af4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801aef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801af4:	83 c4 24             	add    $0x24,%esp
  801af7:	5b                   	pop    %ebx
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    

00801afa <seek>:

int
seek(int fdnum, off_t offset)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b00:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801b03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b07:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0a:	89 04 24             	mov    %eax,(%esp)
  801b0d:	e8 e4 fb ff ff       	call   8016f6 <fd_lookup>
  801b12:	85 c0                	test   %eax,%eax
  801b14:	78 0e                	js     801b24 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801b16:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801b19:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b1c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801b1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b24:	c9                   	leave  
  801b25:	c3                   	ret    

00801b26 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	53                   	push   %ebx
  801b2a:	83 ec 24             	sub    $0x24,%esp
  801b2d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b30:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b37:	89 1c 24             	mov    %ebx,(%esp)
  801b3a:	e8 b7 fb ff ff       	call   8016f6 <fd_lookup>
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	78 61                	js     801ba4 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b46:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b4d:	8b 00                	mov    (%eax),%eax
  801b4f:	89 04 24             	mov    %eax,(%esp)
  801b52:	e8 f5 fb ff ff       	call   80174c <dev_lookup>
  801b57:	85 c0                	test   %eax,%eax
  801b59:	78 49                	js     801ba4 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b5e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b62:	75 23                	jne    801b87 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b64:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b69:	8b 40 48             	mov    0x48(%eax),%eax
  801b6c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b74:	c7 04 24 2c 33 80 00 	movl   $0x80332c,(%esp)
  801b7b:	e8 58 ed ff ff       	call   8008d8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b80:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b85:	eb 1d                	jmp    801ba4 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801b87:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b8a:	8b 52 18             	mov    0x18(%edx),%edx
  801b8d:	85 d2                	test   %edx,%edx
  801b8f:	74 0e                	je     801b9f <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b94:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801b98:	89 04 24             	mov    %eax,(%esp)
  801b9b:	ff d2                	call   *%edx
  801b9d:	eb 05                	jmp    801ba4 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801b9f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801ba4:	83 c4 24             	add    $0x24,%esp
  801ba7:	5b                   	pop    %ebx
  801ba8:	5d                   	pop    %ebp
  801ba9:	c3                   	ret    

00801baa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801baa:	55                   	push   %ebp
  801bab:	89 e5                	mov    %esp,%ebp
  801bad:	53                   	push   %ebx
  801bae:	83 ec 24             	sub    $0x24,%esp
  801bb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bb4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bb7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbe:	89 04 24             	mov    %eax,(%esp)
  801bc1:	e8 30 fb ff ff       	call   8016f6 <fd_lookup>
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	78 52                	js     801c1c <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bd4:	8b 00                	mov    (%eax),%eax
  801bd6:	89 04 24             	mov    %eax,(%esp)
  801bd9:	e8 6e fb ff ff       	call   80174c <dev_lookup>
  801bde:	85 c0                	test   %eax,%eax
  801be0:	78 3a                	js     801c1c <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801be9:	74 2c                	je     801c17 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801beb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801bee:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801bf5:	00 00 00 
	stat->st_isdir = 0;
  801bf8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bff:	00 00 00 
	stat->st_dev = dev;
  801c02:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801c08:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c0c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c0f:	89 14 24             	mov    %edx,(%esp)
  801c12:	ff 50 14             	call   *0x14(%eax)
  801c15:	eb 05                	jmp    801c1c <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801c17:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801c1c:	83 c4 24             	add    $0x24,%esp
  801c1f:	5b                   	pop    %ebx
  801c20:	5d                   	pop    %ebp
  801c21:	c3                   	ret    

00801c22 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	56                   	push   %esi
  801c26:	53                   	push   %ebx
  801c27:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c2a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c31:	00 
  801c32:	8b 45 08             	mov    0x8(%ebp),%eax
  801c35:	89 04 24             	mov    %eax,(%esp)
  801c38:	e8 2a 02 00 00       	call   801e67 <open>
  801c3d:	89 c3                	mov    %eax,%ebx
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	78 1b                	js     801c5e <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801c43:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c46:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c4a:	89 1c 24             	mov    %ebx,(%esp)
  801c4d:	e8 58 ff ff ff       	call   801baa <fstat>
  801c52:	89 c6                	mov    %eax,%esi
	close(fd);
  801c54:	89 1c 24             	mov    %ebx,(%esp)
  801c57:	e8 d2 fb ff ff       	call   80182e <close>
	return r;
  801c5c:	89 f3                	mov    %esi,%ebx
}
  801c5e:	89 d8                	mov    %ebx,%eax
  801c60:	83 c4 10             	add    $0x10,%esp
  801c63:	5b                   	pop    %ebx
  801c64:	5e                   	pop    %esi
  801c65:	5d                   	pop    %ebp
  801c66:	c3                   	ret    
	...

00801c68 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	56                   	push   %esi
  801c6c:	53                   	push   %ebx
  801c6d:	83 ec 10             	sub    $0x10,%esp
  801c70:	89 c3                	mov    %eax,%ebx
  801c72:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c74:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801c7b:	75 11                	jne    801c8e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c7d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801c84:	e8 aa f9 ff ff       	call   801633 <ipc_find_env>
  801c89:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c8e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c95:	00 
  801c96:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801c9d:	00 
  801c9e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ca2:	a1 00 50 80 00       	mov    0x805000,%eax
  801ca7:	89 04 24             	mov    %eax,(%esp)
  801caa:	e8 01 f9 ff ff       	call   8015b0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801caf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cb6:	00 
  801cb7:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cbb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc2:	e8 79 f8 ff ff       	call   801540 <ipc_recv>
}
  801cc7:	83 c4 10             	add    $0x10,%esp
  801cca:	5b                   	pop    %ebx
  801ccb:	5e                   	pop    %esi
  801ccc:	5d                   	pop    %ebp
  801ccd:	c3                   	ret    

00801cce <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801cd4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd7:	8b 40 0c             	mov    0xc(%eax),%eax
  801cda:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801cdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce2:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ce7:	ba 00 00 00 00       	mov    $0x0,%edx
  801cec:	b8 02 00 00 00       	mov    $0x2,%eax
  801cf1:	e8 72 ff ff ff       	call   801c68 <fsipc>
}
  801cf6:	c9                   	leave  
  801cf7:	c3                   	ret    

00801cf8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  801d01:	8b 40 0c             	mov    0xc(%eax),%eax
  801d04:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801d09:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0e:	b8 06 00 00 00       	mov    $0x6,%eax
  801d13:	e8 50 ff ff ff       	call   801c68 <fsipc>
}
  801d18:	c9                   	leave  
  801d19:	c3                   	ret    

00801d1a <devfile_stat>:
	// panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	53                   	push   %ebx
  801d1e:	83 ec 14             	sub    $0x14,%esp
  801d21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d24:	8b 45 08             	mov    0x8(%ebp),%eax
  801d27:	8b 40 0c             	mov    0xc(%eax),%eax
  801d2a:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d34:	b8 05 00 00 00       	mov    $0x5,%eax
  801d39:	e8 2a ff ff ff       	call   801c68 <fsipc>
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	78 2b                	js     801d6d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d42:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d49:	00 
  801d4a:	89 1c 24             	mov    %ebx,(%esp)
  801d4d:	e8 31 f1 ff ff       	call   800e83 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d52:	a1 80 60 80 00       	mov    0x806080,%eax
  801d57:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d5d:	a1 84 60 80 00       	mov    0x806084,%eax
  801d62:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d6d:	83 c4 14             	add    $0x14,%esp
  801d70:	5b                   	pop    %ebx
  801d71:	5d                   	pop    %ebp
  801d72:	c3                   	ret    

00801d73 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	83 ec 18             	sub    $0x18,%esp
  801d79:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  801d7f:	8b 52 0c             	mov    0xc(%edx),%edx
  801d82:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801d88:	a3 04 60 80 00       	mov    %eax,0x806004
	size_t maxw = PGSIZE - (sizeof(int) + sizeof(size_t));
	n = n <= maxw ? n : maxw ;
  801d8d:	89 c2                	mov    %eax,%edx
  801d8f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801d94:	76 05                	jbe    801d9b <devfile_write+0x28>
  801d96:	ba f8 0f 00 00       	mov    $0xff8,%edx
	memcpy(fsipcbuf.write.req_buf, buf, n);
  801d9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da6:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801dad:	e8 b4 f2 ff ff       	call   801066 <memcpy>
	if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801db2:	ba 00 00 00 00       	mov    $0x0,%edx
  801db7:	b8 04 00 00 00       	mov    $0x4,%eax
  801dbc:	e8 a7 fe ff ff       	call   801c68 <fsipc>
	{
		return r;
	}
	return r;
	// panic("devfile_write not implemented");
}
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	56                   	push   %esi
  801dc7:	53                   	push   %ebx
  801dc8:	83 ec 10             	sub    $0x10,%esp
  801dcb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801dce:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd1:	8b 40 0c             	mov    0xc(%eax),%eax
  801dd4:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801dd9:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801ddf:	ba 00 00 00 00       	mov    $0x0,%edx
  801de4:	b8 03 00 00 00       	mov    $0x3,%eax
  801de9:	e8 7a fe ff ff       	call   801c68 <fsipc>
  801dee:	89 c3                	mov    %eax,%ebx
  801df0:	85 c0                	test   %eax,%eax
  801df2:	78 6a                	js     801e5e <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801df4:	39 c6                	cmp    %eax,%esi
  801df6:	73 24                	jae    801e1c <devfile_read+0x59>
  801df8:	c7 44 24 0c a0 33 80 	movl   $0x8033a0,0xc(%esp)
  801dff:	00 
  801e00:	c7 44 24 08 a7 33 80 	movl   $0x8033a7,0x8(%esp)
  801e07:	00 
  801e08:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801e0f:	00 
  801e10:	c7 04 24 bc 33 80 00 	movl   $0x8033bc,(%esp)
  801e17:	e8 c4 e9 ff ff       	call   8007e0 <_panic>
	assert(r <= PGSIZE);
  801e1c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e21:	7e 24                	jle    801e47 <devfile_read+0x84>
  801e23:	c7 44 24 0c c7 33 80 	movl   $0x8033c7,0xc(%esp)
  801e2a:	00 
  801e2b:	c7 44 24 08 a7 33 80 	movl   $0x8033a7,0x8(%esp)
  801e32:	00 
  801e33:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801e3a:	00 
  801e3b:	c7 04 24 bc 33 80 00 	movl   $0x8033bc,(%esp)
  801e42:	e8 99 e9 ff ff       	call   8007e0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e47:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e4b:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e52:	00 
  801e53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e56:	89 04 24             	mov    %eax,(%esp)
  801e59:	e8 9e f1 ff ff       	call   800ffc <memmove>
	return r;
}
  801e5e:	89 d8                	mov    %ebx,%eax
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	5b                   	pop    %ebx
  801e64:	5e                   	pop    %esi
  801e65:	5d                   	pop    %ebp
  801e66:	c3                   	ret    

00801e67 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	56                   	push   %esi
  801e6b:	53                   	push   %ebx
  801e6c:	83 ec 20             	sub    $0x20,%esp
  801e6f:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801e72:	89 34 24             	mov    %esi,(%esp)
  801e75:	e8 d6 ef ff ff       	call   800e50 <strlen>
  801e7a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e7f:	7f 60                	jg     801ee1 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801e81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e84:	89 04 24             	mov    %eax,(%esp)
  801e87:	e8 17 f8 ff ff       	call   8016a3 <fd_alloc>
  801e8c:	89 c3                	mov    %eax,%ebx
  801e8e:	85 c0                	test   %eax,%eax
  801e90:	78 54                	js     801ee6 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801e92:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e96:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801e9d:	e8 e1 ef ff ff       	call   800e83 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea5:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801eaa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ead:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb2:	e8 b1 fd ff ff       	call   801c68 <fsipc>
  801eb7:	89 c3                	mov    %eax,%ebx
  801eb9:	85 c0                	test   %eax,%eax
  801ebb:	79 15                	jns    801ed2 <open+0x6b>
		fd_close(fd, 0);
  801ebd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ec4:	00 
  801ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec8:	89 04 24             	mov    %eax,(%esp)
  801ecb:	e8 d6 f8 ff ff       	call   8017a6 <fd_close>
		return r;
  801ed0:	eb 14                	jmp    801ee6 <open+0x7f>
	}

	return fd2num(fd);
  801ed2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed5:	89 04 24             	mov    %eax,(%esp)
  801ed8:	e8 9b f7 ff ff       	call   801678 <fd2num>
  801edd:	89 c3                	mov    %eax,%ebx
  801edf:	eb 05                	jmp    801ee6 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801ee1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801ee6:	89 d8                	mov    %ebx,%eax
  801ee8:	83 c4 20             	add    $0x20,%esp
  801eeb:	5b                   	pop    %ebx
  801eec:	5e                   	pop    %esi
  801eed:	5d                   	pop    %ebp
  801eee:	c3                   	ret    

00801eef <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
  801ef2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ef5:	ba 00 00 00 00       	mov    $0x0,%edx
  801efa:	b8 08 00 00 00       	mov    $0x8,%eax
  801eff:	e8 64 fd ff ff       	call   801c68 <fsipc>
}
  801f04:	c9                   	leave  
  801f05:	c3                   	ret    
	...

00801f08 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801f0e:	c7 44 24 04 d3 33 80 	movl   $0x8033d3,0x4(%esp)
  801f15:	00 
  801f16:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f19:	89 04 24             	mov    %eax,(%esp)
  801f1c:	e8 62 ef ff ff       	call   800e83 <strcpy>
	return 0;
}
  801f21:	b8 00 00 00 00       	mov    $0x0,%eax
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	53                   	push   %ebx
  801f2c:	83 ec 14             	sub    $0x14,%esp
  801f2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801f32:	89 1c 24             	mov    %ebx,(%esp)
  801f35:	e8 e2 09 00 00       	call   80291c <pageref>
  801f3a:	83 f8 01             	cmp    $0x1,%eax
  801f3d:	75 0d                	jne    801f4c <devsock_close+0x24>
		return nsipc_close(fd->fd_sock.sockid);
  801f3f:	8b 43 0c             	mov    0xc(%ebx),%eax
  801f42:	89 04 24             	mov    %eax,(%esp)
  801f45:	e8 1f 03 00 00       	call   802269 <nsipc_close>
  801f4a:	eb 05                	jmp    801f51 <devsock_close+0x29>
	else
		return 0;
  801f4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f51:	83 c4 14             	add    $0x14,%esp
  801f54:	5b                   	pop    %ebx
  801f55:	5d                   	pop    %ebp
  801f56:	c3                   	ret    

00801f57 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f5d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f64:	00 
  801f65:	8b 45 10             	mov    0x10(%ebp),%eax
  801f68:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f73:	8b 45 08             	mov    0x8(%ebp),%eax
  801f76:	8b 40 0c             	mov    0xc(%eax),%eax
  801f79:	89 04 24             	mov    %eax,(%esp)
  801f7c:	e8 e3 03 00 00       	call   802364 <nsipc_send>
}
  801f81:	c9                   	leave  
  801f82:	c3                   	ret    

00801f83 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f83:	55                   	push   %ebp
  801f84:	89 e5                	mov    %esp,%ebp
  801f86:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f89:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f90:	00 
  801f91:	8b 45 10             	mov    0x10(%ebp),%eax
  801f94:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f98:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa2:	8b 40 0c             	mov    0xc(%eax),%eax
  801fa5:	89 04 24             	mov    %eax,(%esp)
  801fa8:	e8 37 03 00 00       	call   8022e4 <nsipc_recv>
}
  801fad:	c9                   	leave  
  801fae:	c3                   	ret    

00801faf <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 20             	sub    $0x20,%esp
  801fb7:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801fb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fbc:	89 04 24             	mov    %eax,(%esp)
  801fbf:	e8 df f6 ff ff       	call   8016a3 <fd_alloc>
  801fc4:	89 c3                	mov    %eax,%ebx
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	78 21                	js     801feb <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801fca:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801fd1:	00 
  801fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fd9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fe0:	e8 90 f2 ff ff       	call   801275 <sys_page_alloc>
  801fe5:	89 c3                	mov    %eax,%ebx
  801fe7:	85 c0                	test   %eax,%eax
  801fe9:	79 0a                	jns    801ff5 <alloc_sockfd+0x46>
		nsipc_close(sockid);
  801feb:	89 34 24             	mov    %esi,(%esp)
  801fee:	e8 76 02 00 00       	call   802269 <nsipc_close>
		return r;
  801ff3:	eb 22                	jmp    802017 <alloc_sockfd+0x68>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ff5:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ffe:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802000:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802003:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80200a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80200d:	89 04 24             	mov    %eax,(%esp)
  802010:	e8 63 f6 ff ff       	call   801678 <fd2num>
  802015:	89 c3                	mov    %eax,%ebx
}
  802017:	89 d8                	mov    %ebx,%eax
  802019:	83 c4 20             	add    $0x20,%esp
  80201c:	5b                   	pop    %ebx
  80201d:	5e                   	pop    %esi
  80201e:	5d                   	pop    %ebp
  80201f:	c3                   	ret    

00802020 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  802026:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802029:	89 54 24 04          	mov    %edx,0x4(%esp)
  80202d:	89 04 24             	mov    %eax,(%esp)
  802030:	e8 c1 f6 ff ff       	call   8016f6 <fd_lookup>
  802035:	85 c0                	test   %eax,%eax
  802037:	78 17                	js     802050 <fd2sockid+0x30>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802039:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80203c:	8b 15 24 40 80 00    	mov    0x804024,%edx
  802042:	39 10                	cmp    %edx,(%eax)
  802044:	75 05                	jne    80204b <fd2sockid+0x2b>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802046:	8b 40 0c             	mov    0xc(%eax),%eax
  802049:	eb 05                	jmp    802050 <fd2sockid+0x30>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80204b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  802050:	c9                   	leave  
  802051:	c3                   	ret    

00802052 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802052:	55                   	push   %ebp
  802053:	89 e5                	mov    %esp,%ebp
  802055:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802058:	8b 45 08             	mov    0x8(%ebp),%eax
  80205b:	e8 c0 ff ff ff       	call   802020 <fd2sockid>
  802060:	85 c0                	test   %eax,%eax
  802062:	78 1f                	js     802083 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802064:	8b 55 10             	mov    0x10(%ebp),%edx
  802067:	89 54 24 08          	mov    %edx,0x8(%esp)
  80206b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80206e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802072:	89 04 24             	mov    %eax,(%esp)
  802075:	e8 38 01 00 00       	call   8021b2 <nsipc_accept>
  80207a:	85 c0                	test   %eax,%eax
  80207c:	78 05                	js     802083 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80207e:	e8 2c ff ff ff       	call   801faf <alloc_sockfd>
}
  802083:	c9                   	leave  
  802084:	c3                   	ret    

00802085 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802085:	55                   	push   %ebp
  802086:	89 e5                	mov    %esp,%ebp
  802088:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80208b:	8b 45 08             	mov    0x8(%ebp),%eax
  80208e:	e8 8d ff ff ff       	call   802020 <fd2sockid>
  802093:	85 c0                	test   %eax,%eax
  802095:	78 16                	js     8020ad <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  802097:	8b 55 10             	mov    0x10(%ebp),%edx
  80209a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80209e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020a1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020a5:	89 04 24             	mov    %eax,(%esp)
  8020a8:	e8 5b 01 00 00       	call   802208 <nsipc_bind>
}
  8020ad:	c9                   	leave  
  8020ae:	c3                   	ret    

008020af <shutdown>:

int
shutdown(int s, int how)
{
  8020af:	55                   	push   %ebp
  8020b0:	89 e5                	mov    %esp,%ebp
  8020b2:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b8:	e8 63 ff ff ff       	call   802020 <fd2sockid>
  8020bd:	85 c0                	test   %eax,%eax
  8020bf:	78 0f                	js     8020d0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8020c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020c4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020c8:	89 04 24             	mov    %eax,(%esp)
  8020cb:	e8 77 01 00 00       	call   802247 <nsipc_shutdown>
}
  8020d0:	c9                   	leave  
  8020d1:	c3                   	ret    

008020d2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020d2:	55                   	push   %ebp
  8020d3:	89 e5                	mov    %esp,%ebp
  8020d5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020db:	e8 40 ff ff ff       	call   802020 <fd2sockid>
  8020e0:	85 c0                	test   %eax,%eax
  8020e2:	78 16                	js     8020fa <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8020e4:	8b 55 10             	mov    0x10(%ebp),%edx
  8020e7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020f2:	89 04 24             	mov    %eax,(%esp)
  8020f5:	e8 89 01 00 00       	call   802283 <nsipc_connect>
}
  8020fa:	c9                   	leave  
  8020fb:	c3                   	ret    

008020fc <listen>:

int
listen(int s, int backlog)
{
  8020fc:	55                   	push   %ebp
  8020fd:	89 e5                	mov    %esp,%ebp
  8020ff:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802102:	8b 45 08             	mov    0x8(%ebp),%eax
  802105:	e8 16 ff ff ff       	call   802020 <fd2sockid>
  80210a:	85 c0                	test   %eax,%eax
  80210c:	78 0f                	js     80211d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80210e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802111:	89 54 24 04          	mov    %edx,0x4(%esp)
  802115:	89 04 24             	mov    %eax,(%esp)
  802118:	e8 a5 01 00 00       	call   8022c2 <nsipc_listen>
}
  80211d:	c9                   	leave  
  80211e:	c3                   	ret    

0080211f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80211f:	55                   	push   %ebp
  802120:	89 e5                	mov    %esp,%ebp
  802122:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802125:	8b 45 10             	mov    0x10(%ebp),%eax
  802128:	89 44 24 08          	mov    %eax,0x8(%esp)
  80212c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80212f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802133:	8b 45 08             	mov    0x8(%ebp),%eax
  802136:	89 04 24             	mov    %eax,(%esp)
  802139:	e8 99 02 00 00       	call   8023d7 <nsipc_socket>
  80213e:	85 c0                	test   %eax,%eax
  802140:	78 05                	js     802147 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802142:	e8 68 fe ff ff       	call   801faf <alloc_sockfd>
}
  802147:	c9                   	leave  
  802148:	c3                   	ret    
  802149:	00 00                	add    %al,(%eax)
	...

0080214c <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80214c:	55                   	push   %ebp
  80214d:	89 e5                	mov    %esp,%ebp
  80214f:	53                   	push   %ebx
  802150:	83 ec 14             	sub    $0x14,%esp
  802153:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802155:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  80215c:	75 11                	jne    80216f <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80215e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  802165:	e8 c9 f4 ff ff       	call   801633 <ipc_find_env>
  80216a:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  80216f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802176:	00 
  802177:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  80217e:	00 
  80217f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802183:	a1 04 50 80 00       	mov    0x805004,%eax
  802188:	89 04 24             	mov    %eax,(%esp)
  80218b:	e8 20 f4 ff ff       	call   8015b0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802190:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802197:	00 
  802198:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80219f:	00 
  8021a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a7:	e8 94 f3 ff ff       	call   801540 <ipc_recv>
}
  8021ac:	83 c4 14             	add    $0x14,%esp
  8021af:	5b                   	pop    %ebx
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    

008021b2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8021b2:	55                   	push   %ebp
  8021b3:	89 e5                	mov    %esp,%ebp
  8021b5:	56                   	push   %esi
  8021b6:	53                   	push   %ebx
  8021b7:	83 ec 10             	sub    $0x10,%esp
  8021ba:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8021bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8021c5:	8b 06                	mov    (%esi),%eax
  8021c7:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8021cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d1:	e8 76 ff ff ff       	call   80214c <nsipc>
  8021d6:	89 c3                	mov    %eax,%ebx
  8021d8:	85 c0                	test   %eax,%eax
  8021da:	78 23                	js     8021ff <nsipc_accept+0x4d>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8021dc:	a1 10 70 80 00       	mov    0x807010,%eax
  8021e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021e5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8021ec:	00 
  8021ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021f0:	89 04 24             	mov    %eax,(%esp)
  8021f3:	e8 04 ee ff ff       	call   800ffc <memmove>
		*addrlen = ret->ret_addrlen;
  8021f8:	a1 10 70 80 00       	mov    0x807010,%eax
  8021fd:	89 06                	mov    %eax,(%esi)
	}
	return r;
}
  8021ff:	89 d8                	mov    %ebx,%eax
  802201:	83 c4 10             	add    $0x10,%esp
  802204:	5b                   	pop    %ebx
  802205:	5e                   	pop    %esi
  802206:	5d                   	pop    %ebp
  802207:	c3                   	ret    

00802208 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802208:	55                   	push   %ebp
  802209:	89 e5                	mov    %esp,%ebp
  80220b:	53                   	push   %ebx
  80220c:	83 ec 14             	sub    $0x14,%esp
  80220f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  802212:	8b 45 08             	mov    0x8(%ebp),%eax
  802215:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80221a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80221e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802221:	89 44 24 04          	mov    %eax,0x4(%esp)
  802225:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80222c:	e8 cb ed ff ff       	call   800ffc <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802231:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  802237:	b8 02 00 00 00       	mov    $0x2,%eax
  80223c:	e8 0b ff ff ff       	call   80214c <nsipc>
}
  802241:	83 c4 14             	add    $0x14,%esp
  802244:	5b                   	pop    %ebx
  802245:	5d                   	pop    %ebp
  802246:	c3                   	ret    

00802247 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  802247:	55                   	push   %ebp
  802248:	89 e5                	mov    %esp,%ebp
  80224a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80224d:	8b 45 08             	mov    0x8(%ebp),%eax
  802250:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  802255:	8b 45 0c             	mov    0xc(%ebp),%eax
  802258:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  80225d:	b8 03 00 00 00       	mov    $0x3,%eax
  802262:	e8 e5 fe ff ff       	call   80214c <nsipc>
}
  802267:	c9                   	leave  
  802268:	c3                   	ret    

00802269 <nsipc_close>:

int
nsipc_close(int s)
{
  802269:	55                   	push   %ebp
  80226a:	89 e5                	mov    %esp,%ebp
  80226c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80226f:	8b 45 08             	mov    0x8(%ebp),%eax
  802272:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802277:	b8 04 00 00 00       	mov    $0x4,%eax
  80227c:	e8 cb fe ff ff       	call   80214c <nsipc>
}
  802281:	c9                   	leave  
  802282:	c3                   	ret    

00802283 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802283:	55                   	push   %ebp
  802284:	89 e5                	mov    %esp,%ebp
  802286:	53                   	push   %ebx
  802287:	83 ec 14             	sub    $0x14,%esp
  80228a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80228d:	8b 45 08             	mov    0x8(%ebp),%eax
  802290:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802295:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802299:	8b 45 0c             	mov    0xc(%ebp),%eax
  80229c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a0:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8022a7:	e8 50 ed ff ff       	call   800ffc <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8022ac:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8022b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8022b7:	e8 90 fe ff ff       	call   80214c <nsipc>
}
  8022bc:	83 c4 14             	add    $0x14,%esp
  8022bf:	5b                   	pop    %ebx
  8022c0:	5d                   	pop    %ebp
  8022c1:	c3                   	ret    

008022c2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8022c2:	55                   	push   %ebp
  8022c3:	89 e5                	mov    %esp,%ebp
  8022c5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8022c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022cb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8022d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022d3:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8022d8:	b8 06 00 00 00       	mov    $0x6,%eax
  8022dd:	e8 6a fe ff ff       	call   80214c <nsipc>
}
  8022e2:	c9                   	leave  
  8022e3:	c3                   	ret    

008022e4 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8022e4:	55                   	push   %ebp
  8022e5:	89 e5                	mov    %esp,%ebp
  8022e7:	56                   	push   %esi
  8022e8:	53                   	push   %ebx
  8022e9:	83 ec 10             	sub    $0x10,%esp
  8022ec:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8022ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8022f7:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8022fd:	8b 45 14             	mov    0x14(%ebp),%eax
  802300:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802305:	b8 07 00 00 00       	mov    $0x7,%eax
  80230a:	e8 3d fe ff ff       	call   80214c <nsipc>
  80230f:	89 c3                	mov    %eax,%ebx
  802311:	85 c0                	test   %eax,%eax
  802313:	78 46                	js     80235b <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802315:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80231a:	7f 04                	jg     802320 <nsipc_recv+0x3c>
  80231c:	39 c6                	cmp    %eax,%esi
  80231e:	7d 24                	jge    802344 <nsipc_recv+0x60>
  802320:	c7 44 24 0c df 33 80 	movl   $0x8033df,0xc(%esp)
  802327:	00 
  802328:	c7 44 24 08 a7 33 80 	movl   $0x8033a7,0x8(%esp)
  80232f:	00 
  802330:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
  802337:	00 
  802338:	c7 04 24 f4 33 80 00 	movl   $0x8033f4,(%esp)
  80233f:	e8 9c e4 ff ff       	call   8007e0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802344:	89 44 24 08          	mov    %eax,0x8(%esp)
  802348:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80234f:	00 
  802350:	8b 45 0c             	mov    0xc(%ebp),%eax
  802353:	89 04 24             	mov    %eax,(%esp)
  802356:	e8 a1 ec ff ff       	call   800ffc <memmove>
	}

	return r;
}
  80235b:	89 d8                	mov    %ebx,%eax
  80235d:	83 c4 10             	add    $0x10,%esp
  802360:	5b                   	pop    %ebx
  802361:	5e                   	pop    %esi
  802362:	5d                   	pop    %ebp
  802363:	c3                   	ret    

00802364 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802364:	55                   	push   %ebp
  802365:	89 e5                	mov    %esp,%ebp
  802367:	53                   	push   %ebx
  802368:	83 ec 14             	sub    $0x14,%esp
  80236b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80236e:	8b 45 08             	mov    0x8(%ebp),%eax
  802371:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802376:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80237c:	7e 24                	jle    8023a2 <nsipc_send+0x3e>
  80237e:	c7 44 24 0c 00 34 80 	movl   $0x803400,0xc(%esp)
  802385:	00 
  802386:	c7 44 24 08 a7 33 80 	movl   $0x8033a7,0x8(%esp)
  80238d:	00 
  80238e:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  802395:	00 
  802396:	c7 04 24 f4 33 80 00 	movl   $0x8033f4,(%esp)
  80239d:	e8 3e e4 ff ff       	call   8007e0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8023a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023ad:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8023b4:	e8 43 ec ff ff       	call   800ffc <memmove>
	nsipcbuf.send.req_size = size;
  8023b9:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8023bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8023c2:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8023c7:	b8 08 00 00 00       	mov    $0x8,%eax
  8023cc:	e8 7b fd ff ff       	call   80214c <nsipc>
}
  8023d1:	83 c4 14             	add    $0x14,%esp
  8023d4:	5b                   	pop    %ebx
  8023d5:	5d                   	pop    %ebp
  8023d6:	c3                   	ret    

008023d7 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8023d7:	55                   	push   %ebp
  8023d8:	89 e5                	mov    %esp,%ebp
  8023da:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8023dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8023e0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8023e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023e8:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8023ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8023f0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8023f5:	b8 09 00 00 00       	mov    $0x9,%eax
  8023fa:	e8 4d fd ff ff       	call   80214c <nsipc>
}
  8023ff:	c9                   	leave  
  802400:	c3                   	ret    
  802401:	00 00                	add    %al,(%eax)
	...

00802404 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802404:	55                   	push   %ebp
  802405:	89 e5                	mov    %esp,%ebp
  802407:	56                   	push   %esi
  802408:	53                   	push   %ebx
  802409:	83 ec 10             	sub    $0x10,%esp
  80240c:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80240f:	8b 45 08             	mov    0x8(%ebp),%eax
  802412:	89 04 24             	mov    %eax,(%esp)
  802415:	e8 6e f2 ff ff       	call   801688 <fd2data>
  80241a:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  80241c:	c7 44 24 04 0c 34 80 	movl   $0x80340c,0x4(%esp)
  802423:	00 
  802424:	89 34 24             	mov    %esi,(%esp)
  802427:	e8 57 ea ff ff       	call   800e83 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80242c:	8b 43 04             	mov    0x4(%ebx),%eax
  80242f:	2b 03                	sub    (%ebx),%eax
  802431:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802437:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80243e:	00 00 00 
	stat->st_dev = &devpipe;
  802441:	c7 86 88 00 00 00 40 	movl   $0x804040,0x88(%esi)
  802448:	40 80 00 
	return 0;
}
  80244b:	b8 00 00 00 00       	mov    $0x0,%eax
  802450:	83 c4 10             	add    $0x10,%esp
  802453:	5b                   	pop    %ebx
  802454:	5e                   	pop    %esi
  802455:	5d                   	pop    %ebp
  802456:	c3                   	ret    

00802457 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802457:	55                   	push   %ebp
  802458:	89 e5                	mov    %esp,%ebp
  80245a:	53                   	push   %ebx
  80245b:	83 ec 14             	sub    $0x14,%esp
  80245e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802461:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802465:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80246c:	e8 ab ee ff ff       	call   80131c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802471:	89 1c 24             	mov    %ebx,(%esp)
  802474:	e8 0f f2 ff ff       	call   801688 <fd2data>
  802479:	89 44 24 04          	mov    %eax,0x4(%esp)
  80247d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802484:	e8 93 ee ff ff       	call   80131c <sys_page_unmap>
}
  802489:	83 c4 14             	add    $0x14,%esp
  80248c:	5b                   	pop    %ebx
  80248d:	5d                   	pop    %ebp
  80248e:	c3                   	ret    

0080248f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80248f:	55                   	push   %ebp
  802490:	89 e5                	mov    %esp,%ebp
  802492:	57                   	push   %edi
  802493:	56                   	push   %esi
  802494:	53                   	push   %ebx
  802495:	83 ec 2c             	sub    $0x2c,%esp
  802498:	89 c7                	mov    %eax,%edi
  80249a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80249d:	a1 08 50 80 00       	mov    0x805008,%eax
  8024a2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8024a5:	89 3c 24             	mov    %edi,(%esp)
  8024a8:	e8 6f 04 00 00       	call   80291c <pageref>
  8024ad:	89 c6                	mov    %eax,%esi
  8024af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024b2:	89 04 24             	mov    %eax,(%esp)
  8024b5:	e8 62 04 00 00       	call   80291c <pageref>
  8024ba:	39 c6                	cmp    %eax,%esi
  8024bc:	0f 94 c0             	sete   %al
  8024bf:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8024c2:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8024c8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8024cb:	39 cb                	cmp    %ecx,%ebx
  8024cd:	75 08                	jne    8024d7 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  8024cf:	83 c4 2c             	add    $0x2c,%esp
  8024d2:	5b                   	pop    %ebx
  8024d3:	5e                   	pop    %esi
  8024d4:	5f                   	pop    %edi
  8024d5:	5d                   	pop    %ebp
  8024d6:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  8024d7:	83 f8 01             	cmp    $0x1,%eax
  8024da:	75 c1                	jne    80249d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8024dc:	8b 42 58             	mov    0x58(%edx),%eax
  8024df:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  8024e6:	00 
  8024e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8024ef:	c7 04 24 13 34 80 00 	movl   $0x803413,(%esp)
  8024f6:	e8 dd e3 ff ff       	call   8008d8 <cprintf>
  8024fb:	eb a0                	jmp    80249d <_pipeisclosed+0xe>

008024fd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8024fd:	55                   	push   %ebp
  8024fe:	89 e5                	mov    %esp,%ebp
  802500:	57                   	push   %edi
  802501:	56                   	push   %esi
  802502:	53                   	push   %ebx
  802503:	83 ec 1c             	sub    $0x1c,%esp
  802506:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802509:	89 34 24             	mov    %esi,(%esp)
  80250c:	e8 77 f1 ff ff       	call   801688 <fd2data>
  802511:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802513:	bf 00 00 00 00       	mov    $0x0,%edi
  802518:	eb 3c                	jmp    802556 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80251a:	89 da                	mov    %ebx,%edx
  80251c:	89 f0                	mov    %esi,%eax
  80251e:	e8 6c ff ff ff       	call   80248f <_pipeisclosed>
  802523:	85 c0                	test   %eax,%eax
  802525:	75 38                	jne    80255f <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802527:	e8 2a ed ff ff       	call   801256 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80252c:	8b 43 04             	mov    0x4(%ebx),%eax
  80252f:	8b 13                	mov    (%ebx),%edx
  802531:	83 c2 20             	add    $0x20,%edx
  802534:	39 d0                	cmp    %edx,%eax
  802536:	73 e2                	jae    80251a <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802538:	8b 55 0c             	mov    0xc(%ebp),%edx
  80253b:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80253e:	89 c2                	mov    %eax,%edx
  802540:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802546:	79 05                	jns    80254d <devpipe_write+0x50>
  802548:	4a                   	dec    %edx
  802549:	83 ca e0             	or     $0xffffffe0,%edx
  80254c:	42                   	inc    %edx
  80254d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802551:	40                   	inc    %eax
  802552:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802555:	47                   	inc    %edi
  802556:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802559:	75 d1                	jne    80252c <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80255b:	89 f8                	mov    %edi,%eax
  80255d:	eb 05                	jmp    802564 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80255f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802564:	83 c4 1c             	add    $0x1c,%esp
  802567:	5b                   	pop    %ebx
  802568:	5e                   	pop    %esi
  802569:	5f                   	pop    %edi
  80256a:	5d                   	pop    %ebp
  80256b:	c3                   	ret    

0080256c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80256c:	55                   	push   %ebp
  80256d:	89 e5                	mov    %esp,%ebp
  80256f:	57                   	push   %edi
  802570:	56                   	push   %esi
  802571:	53                   	push   %ebx
  802572:	83 ec 1c             	sub    $0x1c,%esp
  802575:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802578:	89 3c 24             	mov    %edi,(%esp)
  80257b:	e8 08 f1 ff ff       	call   801688 <fd2data>
  802580:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802582:	be 00 00 00 00       	mov    $0x0,%esi
  802587:	eb 3a                	jmp    8025c3 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802589:	85 f6                	test   %esi,%esi
  80258b:	74 04                	je     802591 <devpipe_read+0x25>
				return i;
  80258d:	89 f0                	mov    %esi,%eax
  80258f:	eb 40                	jmp    8025d1 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802591:	89 da                	mov    %ebx,%edx
  802593:	89 f8                	mov    %edi,%eax
  802595:	e8 f5 fe ff ff       	call   80248f <_pipeisclosed>
  80259a:	85 c0                	test   %eax,%eax
  80259c:	75 2e                	jne    8025cc <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80259e:	e8 b3 ec ff ff       	call   801256 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8025a3:	8b 03                	mov    (%ebx),%eax
  8025a5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8025a8:	74 df                	je     802589 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8025aa:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8025af:	79 05                	jns    8025b6 <devpipe_read+0x4a>
  8025b1:	48                   	dec    %eax
  8025b2:	83 c8 e0             	or     $0xffffffe0,%eax
  8025b5:	40                   	inc    %eax
  8025b6:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8025ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025bd:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8025c0:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8025c2:	46                   	inc    %esi
  8025c3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8025c6:	75 db                	jne    8025a3 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8025c8:	89 f0                	mov    %esi,%eax
  8025ca:	eb 05                	jmp    8025d1 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8025cc:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8025d1:	83 c4 1c             	add    $0x1c,%esp
  8025d4:	5b                   	pop    %ebx
  8025d5:	5e                   	pop    %esi
  8025d6:	5f                   	pop    %edi
  8025d7:	5d                   	pop    %ebp
  8025d8:	c3                   	ret    

008025d9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8025d9:	55                   	push   %ebp
  8025da:	89 e5                	mov    %esp,%ebp
  8025dc:	57                   	push   %edi
  8025dd:	56                   	push   %esi
  8025de:	53                   	push   %ebx
  8025df:	83 ec 3c             	sub    $0x3c,%esp
  8025e2:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8025e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8025e8:	89 04 24             	mov    %eax,(%esp)
  8025eb:	e8 b3 f0 ff ff       	call   8016a3 <fd_alloc>
  8025f0:	89 c3                	mov    %eax,%ebx
  8025f2:	85 c0                	test   %eax,%eax
  8025f4:	0f 88 45 01 00 00    	js     80273f <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8025fa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802601:	00 
  802602:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802605:	89 44 24 04          	mov    %eax,0x4(%esp)
  802609:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802610:	e8 60 ec ff ff       	call   801275 <sys_page_alloc>
  802615:	89 c3                	mov    %eax,%ebx
  802617:	85 c0                	test   %eax,%eax
  802619:	0f 88 20 01 00 00    	js     80273f <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80261f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802622:	89 04 24             	mov    %eax,(%esp)
  802625:	e8 79 f0 ff ff       	call   8016a3 <fd_alloc>
  80262a:	89 c3                	mov    %eax,%ebx
  80262c:	85 c0                	test   %eax,%eax
  80262e:	0f 88 f8 00 00 00    	js     80272c <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802634:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80263b:	00 
  80263c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80263f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802643:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80264a:	e8 26 ec ff ff       	call   801275 <sys_page_alloc>
  80264f:	89 c3                	mov    %eax,%ebx
  802651:	85 c0                	test   %eax,%eax
  802653:	0f 88 d3 00 00 00    	js     80272c <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802659:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80265c:	89 04 24             	mov    %eax,(%esp)
  80265f:	e8 24 f0 ff ff       	call   801688 <fd2data>
  802664:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802666:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80266d:	00 
  80266e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802672:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802679:	e8 f7 eb ff ff       	call   801275 <sys_page_alloc>
  80267e:	89 c3                	mov    %eax,%ebx
  802680:	85 c0                	test   %eax,%eax
  802682:	0f 88 91 00 00 00    	js     802719 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802688:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80268b:	89 04 24             	mov    %eax,(%esp)
  80268e:	e8 f5 ef ff ff       	call   801688 <fd2data>
  802693:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  80269a:	00 
  80269b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80269f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8026a6:	00 
  8026a7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026b2:	e8 12 ec ff ff       	call   8012c9 <sys_page_map>
  8026b7:	89 c3                	mov    %eax,%ebx
  8026b9:	85 c0                	test   %eax,%eax
  8026bb:	78 4c                	js     802709 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8026bd:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8026c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026c6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8026c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026cb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8026d2:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8026d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8026db:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8026dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8026e0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8026e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026ea:	89 04 24             	mov    %eax,(%esp)
  8026ed:	e8 86 ef ff ff       	call   801678 <fd2num>
  8026f2:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  8026f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8026f7:	89 04 24             	mov    %eax,(%esp)
  8026fa:	e8 79 ef ff ff       	call   801678 <fd2num>
  8026ff:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  802702:	bb 00 00 00 00       	mov    $0x0,%ebx
  802707:	eb 36                	jmp    80273f <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  802709:	89 74 24 04          	mov    %esi,0x4(%esp)
  80270d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802714:	e8 03 ec ff ff       	call   80131c <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  802719:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80271c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802720:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802727:	e8 f0 eb ff ff       	call   80131c <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  80272c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80272f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802733:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80273a:	e8 dd eb ff ff       	call   80131c <sys_page_unmap>
    err:
	return r;
}
  80273f:	89 d8                	mov    %ebx,%eax
  802741:	83 c4 3c             	add    $0x3c,%esp
  802744:	5b                   	pop    %ebx
  802745:	5e                   	pop    %esi
  802746:	5f                   	pop    %edi
  802747:	5d                   	pop    %ebp
  802748:	c3                   	ret    

00802749 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802749:	55                   	push   %ebp
  80274a:	89 e5                	mov    %esp,%ebp
  80274c:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80274f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802752:	89 44 24 04          	mov    %eax,0x4(%esp)
  802756:	8b 45 08             	mov    0x8(%ebp),%eax
  802759:	89 04 24             	mov    %eax,(%esp)
  80275c:	e8 95 ef ff ff       	call   8016f6 <fd_lookup>
  802761:	85 c0                	test   %eax,%eax
  802763:	78 15                	js     80277a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802765:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802768:	89 04 24             	mov    %eax,(%esp)
  80276b:	e8 18 ef ff ff       	call   801688 <fd2data>
	return _pipeisclosed(fd, p);
  802770:	89 c2                	mov    %eax,%edx
  802772:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802775:	e8 15 fd ff ff       	call   80248f <_pipeisclosed>
}
  80277a:	c9                   	leave  
  80277b:	c3                   	ret    

0080277c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80277c:	55                   	push   %ebp
  80277d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80277f:	b8 00 00 00 00       	mov    $0x0,%eax
  802784:	5d                   	pop    %ebp
  802785:	c3                   	ret    

00802786 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802786:	55                   	push   %ebp
  802787:	89 e5                	mov    %esp,%ebp
  802789:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  80278c:	c7 44 24 04 2b 34 80 	movl   $0x80342b,0x4(%esp)
  802793:	00 
  802794:	8b 45 0c             	mov    0xc(%ebp),%eax
  802797:	89 04 24             	mov    %eax,(%esp)
  80279a:	e8 e4 e6 ff ff       	call   800e83 <strcpy>
	return 0;
}
  80279f:	b8 00 00 00 00       	mov    $0x0,%eax
  8027a4:	c9                   	leave  
  8027a5:	c3                   	ret    

008027a6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8027a6:	55                   	push   %ebp
  8027a7:	89 e5                	mov    %esp,%ebp
  8027a9:	57                   	push   %edi
  8027aa:	56                   	push   %esi
  8027ab:	53                   	push   %ebx
  8027ac:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027b2:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8027b7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027bd:	eb 30                	jmp    8027ef <devcons_write+0x49>
		m = n - tot;
  8027bf:	8b 75 10             	mov    0x10(%ebp),%esi
  8027c2:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  8027c4:	83 fe 7f             	cmp    $0x7f,%esi
  8027c7:	76 05                	jbe    8027ce <devcons_write+0x28>
			m = sizeof(buf) - 1;
  8027c9:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8027ce:	89 74 24 08          	mov    %esi,0x8(%esp)
  8027d2:	03 45 0c             	add    0xc(%ebp),%eax
  8027d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027d9:	89 3c 24             	mov    %edi,(%esp)
  8027dc:	e8 1b e8 ff ff       	call   800ffc <memmove>
		sys_cputs(buf, m);
  8027e1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027e5:	89 3c 24             	mov    %edi,(%esp)
  8027e8:	e8 bb e9 ff ff       	call   8011a8 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8027ed:	01 f3                	add    %esi,%ebx
  8027ef:	89 d8                	mov    %ebx,%eax
  8027f1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8027f4:	72 c9                	jb     8027bf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8027f6:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  8027fc:	5b                   	pop    %ebx
  8027fd:	5e                   	pop    %esi
  8027fe:	5f                   	pop    %edi
  8027ff:	5d                   	pop    %ebp
  802800:	c3                   	ret    

00802801 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802801:	55                   	push   %ebp
  802802:	89 e5                	mov    %esp,%ebp
  802804:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802807:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80280b:	75 07                	jne    802814 <devcons_read+0x13>
  80280d:	eb 25                	jmp    802834 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80280f:	e8 42 ea ff ff       	call   801256 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802814:	e8 ad e9 ff ff       	call   8011c6 <sys_cgetc>
  802819:	85 c0                	test   %eax,%eax
  80281b:	74 f2                	je     80280f <devcons_read+0xe>
  80281d:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80281f:	85 c0                	test   %eax,%eax
  802821:	78 1d                	js     802840 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802823:	83 f8 04             	cmp    $0x4,%eax
  802826:	74 13                	je     80283b <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802828:	8b 45 0c             	mov    0xc(%ebp),%eax
  80282b:	88 10                	mov    %dl,(%eax)
	return 1;
  80282d:	b8 01 00 00 00       	mov    $0x1,%eax
  802832:	eb 0c                	jmp    802840 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802834:	b8 00 00 00 00       	mov    $0x0,%eax
  802839:	eb 05                	jmp    802840 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80283b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802840:	c9                   	leave  
  802841:	c3                   	ret    

00802842 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802842:	55                   	push   %ebp
  802843:	89 e5                	mov    %esp,%ebp
  802845:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802848:	8b 45 08             	mov    0x8(%ebp),%eax
  80284b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80284e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802855:	00 
  802856:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802859:	89 04 24             	mov    %eax,(%esp)
  80285c:	e8 47 e9 ff ff       	call   8011a8 <sys_cputs>
}
  802861:	c9                   	leave  
  802862:	c3                   	ret    

00802863 <getchar>:

int
getchar(void)
{
  802863:	55                   	push   %ebp
  802864:	89 e5                	mov    %esp,%ebp
  802866:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802869:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802870:	00 
  802871:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802874:	89 44 24 04          	mov    %eax,0x4(%esp)
  802878:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80287f:	e8 10 f1 ff ff       	call   801994 <read>
	if (r < 0)
  802884:	85 c0                	test   %eax,%eax
  802886:	78 0f                	js     802897 <getchar+0x34>
		return r;
	if (r < 1)
  802888:	85 c0                	test   %eax,%eax
  80288a:	7e 06                	jle    802892 <getchar+0x2f>
		return -E_EOF;
	return c;
  80288c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802890:	eb 05                	jmp    802897 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802892:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802897:	c9                   	leave  
  802898:	c3                   	ret    

00802899 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802899:	55                   	push   %ebp
  80289a:	89 e5                	mov    %esp,%ebp
  80289c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80289f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8028a9:	89 04 24             	mov    %eax,(%esp)
  8028ac:	e8 45 ee ff ff       	call   8016f6 <fd_lookup>
  8028b1:	85 c0                	test   %eax,%eax
  8028b3:	78 11                	js     8028c6 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8028b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028b8:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8028be:	39 10                	cmp    %edx,(%eax)
  8028c0:	0f 94 c0             	sete   %al
  8028c3:	0f b6 c0             	movzbl %al,%eax
}
  8028c6:	c9                   	leave  
  8028c7:	c3                   	ret    

008028c8 <opencons>:

int
opencons(void)
{
  8028c8:	55                   	push   %ebp
  8028c9:	89 e5                	mov    %esp,%ebp
  8028cb:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8028ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028d1:	89 04 24             	mov    %eax,(%esp)
  8028d4:	e8 ca ed ff ff       	call   8016a3 <fd_alloc>
  8028d9:	85 c0                	test   %eax,%eax
  8028db:	78 3c                	js     802919 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8028dd:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8028e4:	00 
  8028e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8028f3:	e8 7d e9 ff ff       	call   801275 <sys_page_alloc>
  8028f8:	85 c0                	test   %eax,%eax
  8028fa:	78 1d                	js     802919 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8028fc:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  802902:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802905:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802907:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80290a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802911:	89 04 24             	mov    %eax,(%esp)
  802914:	e8 5f ed ff ff       	call   801678 <fd2num>
}
  802919:	c9                   	leave  
  80291a:	c3                   	ret    
	...

0080291c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80291c:	55                   	push   %ebp
  80291d:	89 e5                	mov    %esp,%ebp
  80291f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802922:	89 c2                	mov    %eax,%edx
  802924:	c1 ea 16             	shr    $0x16,%edx
  802927:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80292e:	f6 c2 01             	test   $0x1,%dl
  802931:	74 1e                	je     802951 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802933:	c1 e8 0c             	shr    $0xc,%eax
  802936:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80293d:	a8 01                	test   $0x1,%al
  80293f:	74 17                	je     802958 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802941:	c1 e8 0c             	shr    $0xc,%eax
  802944:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80294b:	ef 
  80294c:	0f b7 c0             	movzwl %ax,%eax
  80294f:	eb 0c                	jmp    80295d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802951:	b8 00 00 00 00       	mov    $0x0,%eax
  802956:	eb 05                	jmp    80295d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802958:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80295d:	5d                   	pop    %ebp
  80295e:	c3                   	ret    
	...

00802960 <__udivdi3>:
#endif

#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  802960:	55                   	push   %ebp
  802961:	57                   	push   %edi
  802962:	56                   	push   %esi
  802963:	83 ec 10             	sub    $0x10,%esp
  802966:	8b 74 24 20          	mov    0x20(%esp),%esi
  80296a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  80296e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802972:	8b 7c 24 24          	mov    0x24(%esp),%edi
  const DWunion dd = {.ll = d};
  802976:	89 cd                	mov    %ecx,%ebp
  802978:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  d1 = dd.s.high;
  n0 = nn.s.low;
  n1 = nn.s.high;

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  80297c:	85 c0                	test   %eax,%eax
  80297e:	75 2c                	jne    8029ac <__udivdi3+0x4c>
    {
      if (d0 > n1)
  802980:	39 f9                	cmp    %edi,%ecx
  802982:	77 68                	ja     8029ec <__udivdi3+0x8c>
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802984:	85 c9                	test   %ecx,%ecx
  802986:	75 0b                	jne    802993 <__udivdi3+0x33>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802988:	b8 01 00 00 00       	mov    $0x1,%eax
  80298d:	31 d2                	xor    %edx,%edx
  80298f:	f7 f1                	div    %ecx
  802991:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802993:	31 d2                	xor    %edx,%edx
  802995:	89 f8                	mov    %edi,%eax
  802997:	f7 f1                	div    %ecx
  802999:	89 c7                	mov    %eax,%edi
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  80299b:	89 f0                	mov    %esi,%eax
  80299d:	f7 f1                	div    %ecx
  80299f:	89 c6                	mov    %eax,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029a1:	89 f0                	mov    %esi,%eax
  8029a3:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029a5:	83 c4 10             	add    $0x10,%esp
  8029a8:	5e                   	pop    %esi
  8029a9:	5f                   	pop    %edi
  8029aa:	5d                   	pop    %ebp
  8029ab:	c3                   	ret    
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8029ac:	39 f8                	cmp    %edi,%eax
  8029ae:	77 2c                	ja     8029dc <__udivdi3+0x7c>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  8029b0:	0f bd f0             	bsr    %eax,%esi
	  if (bm == 0)
  8029b3:	83 f6 1f             	xor    $0x1f,%esi
  8029b6:	75 4c                	jne    802a04 <__udivdi3+0xa4>

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8029b8:	39 f8                	cmp    %edi,%eax
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8029ba:	bf 00 00 00 00       	mov    $0x0,%edi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  8029bf:	72 0a                	jb     8029cb <__udivdi3+0x6b>
  8029c1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8029c5:	0f 87 ad 00 00 00    	ja     802a78 <__udivdi3+0x118>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  8029cb:	be 01 00 00 00       	mov    $0x1,%esi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029d0:	89 f0                	mov    %esi,%eax
  8029d2:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029d4:	83 c4 10             	add    $0x10,%esp
  8029d7:	5e                   	pop    %esi
  8029d8:	5f                   	pop    %edi
  8029d9:	5d                   	pop    %ebp
  8029da:	c3                   	ret    
  8029db:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  8029dc:	31 ff                	xor    %edi,%edi
  8029de:	31 f6                	xor    %esi,%esi
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
    {
      if (d0 > n1)
	{
	  /* 0q = nn / 0D */

	  udiv_qrnnd (q0, n0, n1, n0, d0);
  8029ec:	89 fa                	mov    %edi,%edx
  8029ee:	89 f0                	mov    %esi,%eax
  8029f0:	f7 f1                	div    %ecx
  8029f2:	89 c6                	mov    %eax,%esi
  8029f4:	31 ff                	xor    %edi,%edi
		}
	    }
	}
    }

  const DWunion ww = {{.low = q0, .high = q1}};
  8029f6:	89 f0                	mov    %esi,%eax
  8029f8:	89 fa                	mov    %edi,%edx
#ifdef L_udivdi3
UDWtype
__udivdi3 (UDWtype n, UDWtype d)
{
  return __udivmoddi4 (n, d, (UDWtype *) 0);
}
  8029fa:	83 c4 10             	add    $0x10,%esp
  8029fd:	5e                   	pop    %esi
  8029fe:	5f                   	pop    %edi
  8029ff:	5d                   	pop    %ebp
  802a00:	c3                   	ret    
  802a01:	8d 76 00             	lea    0x0(%esi),%esi
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802a04:	89 f1                	mov    %esi,%ecx
  802a06:	d3 e0                	shl    %cl,%eax
  802a08:	89 44 24 0c          	mov    %eax,0xc(%esp)
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802a0c:	b8 20 00 00 00       	mov    $0x20,%eax
  802a11:	29 f0                	sub    %esi,%eax

	      d1 = (d1 << bm) | (d0 >> b);
  802a13:	89 ea                	mov    %ebp,%edx
  802a15:	88 c1                	mov    %al,%cl
  802a17:	d3 ea                	shr    %cl,%edx
  802a19:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802a1d:	09 ca                	or     %ecx,%edx
  802a1f:	89 54 24 08          	mov    %edx,0x8(%esp)
	      d0 = d0 << bm;
  802a23:	89 f1                	mov    %esi,%ecx
  802a25:	d3 e5                	shl    %cl,%ebp
  802a27:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
	      n2 = n1 >> b;
  802a2b:	89 fd                	mov    %edi,%ebp
  802a2d:	88 c1                	mov    %al,%cl
  802a2f:	d3 ed                	shr    %cl,%ebp
	      n1 = (n1 << bm) | (n0 >> b);
  802a31:	89 fa                	mov    %edi,%edx
  802a33:	89 f1                	mov    %esi,%ecx
  802a35:	d3 e2                	shl    %cl,%edx
  802a37:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802a3b:	88 c1                	mov    %al,%cl
  802a3d:	d3 ef                	shr    %cl,%edi
  802a3f:	09 d7                	or     %edx,%edi
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802a41:	89 f8                	mov    %edi,%eax
  802a43:	89 ea                	mov    %ebp,%edx
  802a45:	f7 74 24 08          	divl   0x8(%esp)
  802a49:	89 d1                	mov    %edx,%ecx
  802a4b:	89 c7                	mov    %eax,%edi
	      umul_ppmm (m1, m0, q0, d0);
  802a4d:	f7 64 24 0c          	mull   0xc(%esp)

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a51:	39 d1                	cmp    %edx,%ecx
  802a53:	72 17                	jb     802a6c <__udivdi3+0x10c>
  802a55:	74 09                	je     802a60 <__udivdi3+0x100>
  802a57:	89 fe                	mov    %edi,%esi
  802a59:	31 ff                	xor    %edi,%edi
  802a5b:	e9 41 ff ff ff       	jmp    8029a1 <__udivdi3+0x41>

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;
  802a60:	8b 54 24 04          	mov    0x4(%esp),%edx
  802a64:	89 f1                	mov    %esi,%ecx
  802a66:	d3 e2                	shl    %cl,%edx

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802a68:	39 c2                	cmp    %eax,%edx
  802a6a:	73 eb                	jae    802a57 <__udivdi3+0xf7>
		{
		  q0--;
  802a6c:	8d 77 ff             	lea    -0x1(%edi),%esi
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802a6f:	31 ff                	xor    %edi,%edi
  802a71:	e9 2b ff ff ff       	jmp    8029a1 <__udivdi3+0x41>
  802a76:	66 90                	xchg   %ax,%ax

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802a78:	31 f6                	xor    %esi,%esi
  802a7a:	e9 22 ff ff ff       	jmp    8029a1 <__udivdi3+0x41>
	...

00802a80 <__umoddi3>:
#endif

#ifdef L_umoddi3
UDWtype
__umoddi3 (UDWtype u, UDWtype v)
{
  802a80:	55                   	push   %ebp
  802a81:	57                   	push   %edi
  802a82:	56                   	push   %esi
  802a83:	83 ec 20             	sub    $0x20,%esp
  802a86:	8b 44 24 30          	mov    0x30(%esp),%eax
  802a8a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
static inline __attribute__ ((__always_inline__))
#endif
UDWtype
__udivmoddi4 (UDWtype n, UDWtype d, UDWtype *rp)
{
  const DWunion nn = {.ll = n};
  802a8e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802a92:	8b 74 24 34          	mov    0x34(%esp),%esi
  const DWunion dd = {.ll = d};
  802a96:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802a9a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  UWtype q0, q1;
  UWtype b, bm;

  d0 = dd.s.low;
  d1 = dd.s.high;
  n0 = nn.s.low;
  802a9e:	89 c7                	mov    %eax,%edi
  n1 = nn.s.high;
  802aa0:	89 f2                	mov    %esi,%edx

#if !UDIV_NEEDS_NORMALIZATION
  if (d1 == 0)
  802aa2:	85 ed                	test   %ebp,%ebp
  802aa4:	75 16                	jne    802abc <__umoddi3+0x3c>
    {
      if (d0 > n1)
  802aa6:	39 f1                	cmp    %esi,%ecx
  802aa8:	0f 86 a6 00 00 00    	jbe    802b54 <__umoddi3+0xd4>

	  if (d0 == 0)
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */

	  udiv_qrnnd (q1, n1, 0, n1, d0);
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802aae:	f7 f1                	div    %ecx

      if (rp != 0)
	{
	  rr.s.low = n0;
	  rr.s.high = 0;
	  *rp = rr.ll;
  802ab0:	89 d0                	mov    %edx,%eax
  802ab2:	31 d2                	xor    %edx,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802ab4:	83 c4 20             	add    $0x20,%esp
  802ab7:	5e                   	pop    %esi
  802ab8:	5f                   	pop    %edi
  802ab9:	5d                   	pop    %ebp
  802aba:	c3                   	ret    
  802abb:	90                   	nop
    }
#endif /* UDIV_NEEDS_NORMALIZATION */

  else
    {
      if (d1 > n1)
  802abc:	39 f5                	cmp    %esi,%ebp
  802abe:	0f 87 ac 00 00 00    	ja     802b70 <__umoddi3+0xf0>
	}
      else
	{
	  /* 0q = NN / dd */

	  count_leading_zeros (bm, d1);
  802ac4:	0f bd c5             	bsr    %ebp,%eax
	  if (bm == 0)
  802ac7:	83 f0 1f             	xor    $0x1f,%eax
  802aca:	89 44 24 10          	mov    %eax,0x10(%esp)
  802ace:	0f 84 a8 00 00 00    	je     802b7c <__umoddi3+0xfc>
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
  802ad4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802ad8:	d3 e5                	shl    %cl,%ebp
	  else
	    {
	      UWtype m1, m0;
	      /* Normalize.  */

	      b = W_TYPE_SIZE - bm;
  802ada:	bf 20 00 00 00       	mov    $0x20,%edi
  802adf:	2b 7c 24 10          	sub    0x10(%esp),%edi

	      d1 = (d1 << bm) | (d0 >> b);
  802ae3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802ae7:	89 f9                	mov    %edi,%ecx
  802ae9:	d3 e8                	shr    %cl,%eax
  802aeb:	09 e8                	or     %ebp,%eax
  802aed:	89 44 24 18          	mov    %eax,0x18(%esp)
	      d0 = d0 << bm;
  802af1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802af5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802af9:	d3 e0                	shl    %cl,%eax
  802afb:	89 44 24 0c          	mov    %eax,0xc(%esp)
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802aff:	89 f2                	mov    %esi,%edx
  802b01:	d3 e2                	shl    %cl,%edx
	      n0 = n0 << bm;
  802b03:	8b 44 24 14          	mov    0x14(%esp),%eax
  802b07:	d3 e0                	shl    %cl,%eax
  802b09:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
	      n1 = (n1 << bm) | (n0 >> b);
  802b0d:	8b 44 24 14          	mov    0x14(%esp),%eax
  802b11:	89 f9                	mov    %edi,%ecx
  802b13:	d3 e8                	shr    %cl,%eax
  802b15:	09 d0                	or     %edx,%eax

	      b = W_TYPE_SIZE - bm;

	      d1 = (d1 << bm) | (d0 >> b);
	      d0 = d0 << bm;
	      n2 = n1 >> b;
  802b17:	d3 ee                	shr    %cl,%esi
	      n1 = (n1 << bm) | (n0 >> b);
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
  802b19:	89 f2                	mov    %esi,%edx
  802b1b:	f7 74 24 18          	divl   0x18(%esp)
  802b1f:	89 d6                	mov    %edx,%esi
	      umul_ppmm (m1, m0, q0, d0);
  802b21:	f7 64 24 0c          	mull   0xc(%esp)
  802b25:	89 c5                	mov    %eax,%ebp
  802b27:	89 d1                	mov    %edx,%ecx

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802b29:	39 d6                	cmp    %edx,%esi
  802b2b:	72 67                	jb     802b94 <__umoddi3+0x114>
  802b2d:	74 75                	je     802ba4 <__umoddi3+0x124>
	      q1 = 0;

	      /* Remainder in (n1n0 - m1m0) >> bm.  */
	      if (rp != 0)
		{
		  sub_ddmmss (n1, n0, n1, n0, m1, m0);
  802b2f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802b33:	29 e8                	sub    %ebp,%eax
  802b35:	19 ce                	sbb    %ecx,%esi
		  rr.s.low = (n1 << b) | (n0 >> bm);
  802b37:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b3b:	d3 e8                	shr    %cl,%eax
  802b3d:	89 f2                	mov    %esi,%edx
  802b3f:	89 f9                	mov    %edi,%ecx
  802b41:	d3 e2                	shl    %cl,%edx
		  rr.s.high = n1 >> bm;
		  *rp = rr.ll;
  802b43:	09 d0                	or     %edx,%eax
  802b45:	89 f2                	mov    %esi,%edx
  802b47:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802b4b:	d3 ea                	shr    %cl,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b4d:	83 c4 20             	add    $0x20,%esp
  802b50:	5e                   	pop    %esi
  802b51:	5f                   	pop    %edi
  802b52:	5d                   	pop    %ebp
  802b53:	c3                   	ret    
	}
      else
	{
	  /* qq = NN / 0d */

	  if (d0 == 0)
  802b54:	85 c9                	test   %ecx,%ecx
  802b56:	75 0b                	jne    802b63 <__umoddi3+0xe3>
	    d0 = 1 / d0;	/* Divide intentionally by zero.  */
  802b58:	b8 01 00 00 00       	mov    $0x1,%eax
  802b5d:	31 d2                	xor    %edx,%edx
  802b5f:	f7 f1                	div    %ecx
  802b61:	89 c1                	mov    %eax,%ecx

	  udiv_qrnnd (q1, n1, 0, n1, d0);
  802b63:	89 f0                	mov    %esi,%eax
  802b65:	31 d2                	xor    %edx,%edx
  802b67:	f7 f1                	div    %ecx
	  udiv_qrnnd (q0, n0, n1, n0, d0);
  802b69:	89 f8                	mov    %edi,%eax
  802b6b:	e9 3e ff ff ff       	jmp    802aae <__umoddi3+0x2e>
	  /* Remainder in n1n0.  */
	  if (rp != 0)
	    {
	      rr.s.low = n0;
	      rr.s.high = n1;
	      *rp = rr.ll;
  802b70:	89 f2                	mov    %esi,%edx
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b72:	83 c4 20             	add    $0x20,%esp
  802b75:	5e                   	pop    %esi
  802b76:	5f                   	pop    %edi
  802b77:	5d                   	pop    %ebp
  802b78:	c3                   	ret    
  802b79:	8d 76 00             	lea    0x0(%esi),%esi

		 This special case is necessary, not an optimization.  */

	      /* The condition on the next line takes advantage of that
		 n1 >= d1 (true due to program flow).  */
	      if (n1 > d1 || n0 >= d0)
  802b7c:	39 f5                	cmp    %esi,%ebp
  802b7e:	72 04                	jb     802b84 <__umoddi3+0x104>
  802b80:	39 f9                	cmp    %edi,%ecx
  802b82:	77 06                	ja     802b8a <__umoddi3+0x10a>
		{
		  q0 = 1;
		  sub_ddmmss (n1, n0, n1, n0, d1, d0);
  802b84:	89 f2                	mov    %esi,%edx
  802b86:	29 cf                	sub    %ecx,%edi
  802b88:	19 ea                	sbb    %ebp,%edx

	      if (rp != 0)
		{
		  rr.s.low = n0;
		  rr.s.high = n1;
		  *rp = rr.ll;
  802b8a:	89 f8                	mov    %edi,%eax
  UDWtype w;

  (void) __udivmoddi4 (u, v, &w);

  return w;
}
  802b8c:	83 c4 20             	add    $0x20,%esp
  802b8f:	5e                   	pop    %esi
  802b90:	5f                   	pop    %edi
  802b91:	5d                   	pop    %ebp
  802b92:	c3                   	ret    
  802b93:	90                   	nop
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
		{
		  q0--;
		  sub_ddmmss (m1, m0, m1, m0, d1, d0);
  802b94:	89 d1                	mov    %edx,%ecx
  802b96:	89 c5                	mov    %eax,%ebp
  802b98:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802b9c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802ba0:	eb 8d                	jmp    802b2f <__umoddi3+0xaf>
  802ba2:	66 90                	xchg   %ax,%ax
	      n0 = n0 << bm;

	      udiv_qrnnd (q0, n1, n2, n1, d1);
	      umul_ppmm (m1, m0, q0, d0);

	      if (m1 > n1 || (m1 == n1 && m0 > n0))
  802ba4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802ba8:	72 ea                	jb     802b94 <__umoddi3+0x114>
  802baa:	89 f1                	mov    %esi,%ecx
  802bac:	eb 81                	jmp    802b2f <__umoddi3+0xaf>
