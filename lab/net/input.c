#include "ns.h"

extern union Nsipc nsipcbuf;

#define INPUT_COUNT 10

void
input(envid_t ns_envid)
{
	binaryname = "ns_input";

	// LAB 6: Your code here:
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
	struct jif_pkt *pkt = (struct jif_pkt *)REQVA;
	int r;
	if ((r = sys_page_alloc(0, pkt, PTE_P | PTE_U | PTE_W)) < 0)
			panic("sys_page_alloc: %e", r);
	uint32_t len;
		
	while (1)
	{
		// cprintf("input hello world\n");
		if ((r = sys_e1000_receive(pkt->jp_data, (uint32_t *)&pkt->jp_len)) < 0)
		{
			continue;
		}
		memcpy(nsipcbuf.pkt.jp_data,pkt->jp_data,pkt->jp_len);
		nsipcbuf.pkt.jp_len = pkt->jp_len;
		ipc_send(ns_envid, NSREQ_INPUT, &nsipcbuf, PTE_P | PTE_W | PTE_U);
		
		for (int i = 0; i < INPUT_COUNT*2; i++)
			sys_yield();
	}
}
