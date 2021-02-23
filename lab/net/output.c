#include "ns.h"

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
	binaryname = "ns_output";

	// LAB 6: Your code here:
	// 	- read a packet from the network server
	//	- send the packet to the device driver
	struct jif_pkt *pkt = &(nsipcbuf.pkt); //= (struct jif_pkt *)(REQVA + PGSIZE);
	int r;

	while (1)
	{
		if ((r = ipc_recv(&ns_envid, pkt, 0)) < 0)
		{
			cprintf("output ipc_recv error\n");
			continue;
		}
		while(1){		
			if ((r = sys_e1000_transmit(pkt->jp_data, pkt->jp_len)) < 0)
			{
				if (r != -E_NET_NO_DES)
				{
					cprintf("output sys_e1000_transmit error\n");
				}
				else
				{
					cprintf("output packet overflow yield\n");
					sys_yield();
				}
			}else break;
		}
	}
}
