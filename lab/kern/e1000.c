#include <kern/e1000.h>
#include <kern/pmap.h>
#include <inc/string.h>

// LAB 6: Your driver code here

#define E1000_STATUS (0x00008 / 4)
#define E1000_TDBAL (0x03800 / 4) /* TX Descriptor Base Address Low - RW */
#define E1000_TDBAH (0x03804 / 4) /* TX Descriptor Base Address High - RW */
#define E1000_TDLEN (0x03808 / 4) /* TX Descriptor Length - RW */
#define E1000_TDH (0x03810 / 4)   /* TX Descriptor Head - RW */
#define E1000_TDT (0x03818 / 4)   /* TX Descripotr Tail - RW */
#define E1000_TCTL (0x00400 / 4)  /* TX Control - RW */
#define E1000_TIPG (0x00410 / 4)  /* TX Inter-packet gap -RW */

// Transmit IPG Register
// Field   Bit(s)     Description
// IGPT    9:0        default(10)
// IPGR1  19:10       default(8)
// IPGR2  29:20       default(6)

/* Transmit Control */
#define E1000_TCTL_RST 0x00000001    /* software reset */
#define E1000_TCTL_EN 0x00000002     /* enable tx */
#define E1000_TCTL_BCE 0x00000004    /* busy check enable */
#define E1000_TCTL_PSP 0x00000008    /* pad short packets */
#define E1000_TCTL_CT 0x00000ff0     /* collision threshold */
#define E1000_TCTL_COLD 0x003ff000   /* collision distance */
#define E1000_TCTL_SWXOFF 0x00400000 /* SW Xoff transmission */
#define E1000_TCTL_PBE 0x00800000    /* Packet Burst Enable */
#define E1000_TCTL_RTLC 0x01000000   /* Re-transmit on late collision */
#define E1000_TCTL_NRTU 0x02000000   /* No Re-transmit on underrun */
#define E1000_TCTL_MULR 0x10000000   /* Multiple request support */

#define E1000_TX_DESC_STATUS_DD 0x1
#define E1000_TX_DESC_CMD_EOP   0x1
#define E1000_TX_DESC_CMD_RS    0x8

#define RING_SIZE 64



#define RECEIVE_RING_SIZE 128
#define E1000_RAL (0x05400 / 4)
#define E1000_RAH (0x05404 / 4)
#define E1000_MTA (0x05200 / 4)
#define E1000_IMS (0x000d0 / 4)
#define E1000_RDTR (0x02820 / 4)
#define E1000_RDBAL (0x02800 / 4)
#define E1000_RDBAH (0x02804 / 4)
#define E1000_RDLEN (0x02808 / 4)
#define E1000_RDH (0x02810 / 4)
#define E1000_RDT (0x02818 / 4)
#define E1000_RCTL (0x00100 / 4)

#define E1000_RX_DESC_STATUS_DD  0x1
#define E1000_RX_DESC_STATUS_EOP 0x2 
#define E1000_RAH_AV  0x80000000        /* Receive descriptor valid */
/* Receive Control */
#define E1000_RCTL_RST 0x00000001         /* Software reset */
#define E1000_RCTL_EN 0x00000002          /* enable */
#define E1000_RCTL_SBP 0x00000004         /* store bad packet */
#define E1000_RCTL_UPE 0x00000008         /* unicast promiscuous enable */
#define E1000_RCTL_MPE 0x00000010         /* multicast promiscuous enab */
#define E1000_RCTL_LPE 0x00000020         /* long packet enable */
#define E1000_RCTL_LBM_NO 0x00000000      /* no loopback mode */
#define E1000_RCTL_LBM_MAC 0x00000040     /* MAC loopback mode */
#define E1000_RCTL_LBM_SLP 0x00000080     /* serial link loopback mode */
#define E1000_RCTL_LBM_TCVR 0x000000C0    /* tcvr loopback mode */
#define E1000_RCTL_DTYP_MASK 0x00000C00   /* Descriptor type mask */
#define E1000_RCTL_DTYP_PS 0x00000400     /* Packet Split descriptor */
#define E1000_RCTL_RDMTS_HALF 0x00000000  /* rx desc min threshold size */
#define E1000_RCTL_RDMTS_QUAT 0x00000100  /* rx desc min threshold size */
#define E1000_RCTL_RDMTS_EIGTH 0x00000200 /* rx desc min threshold size */
#define E1000_RCTL_MO_SHIFT 12            /* multicast offset shift */
#define E1000_RCTL_MO_0 0x00000000        /* multicast offset 11:0 */
#define E1000_RCTL_MO_1 0x00001000        /* multicast offset 12:1 */
#define E1000_RCTL_MO_2 0x00002000        /* multicast offset 13:2 */
#define E1000_RCTL_MO_3 0x00003000        /* multicast offset 15:4 */
#define E1000_RCTL_MDR 0x00004000         /* multicast desc ring 0 */
#define E1000_RCTL_BAM 0x00008000         /* broadcast enable */
/* these buffer sizes are valid if E1000_RCTL_BSEX is 0 */
#define E1000_RCTL_SZ_2048 0x00000000 /* rx buffer size 2048 */
#define E1000_RCTL_SZ_1024 0x00010000 /* rx buffer size 1024 */
#define E1000_RCTL_SZ_512 0x00020000  /* rx buffer size 512 */
#define E1000_RCTL_SZ_256 0x00030000  /* rx buffer size 256 */
/* these buffer sizes are valid if E1000_RCTL_BSEX is 1 */
#define E1000_RCTL_SZ_16384 0x00010000    /* rx buffer size 16384 */
#define E1000_RCTL_SZ_8192 0x00020000     /* rx buffer size 8192 */
#define E1000_RCTL_SZ_4096 0x00030000     /* rx buffer size 4096 */
#define E1000_RCTL_VFE 0x00040000         /* vlan filter enable */
#define E1000_RCTL_CFIEN 0x00080000       /* canonical form enable */
#define E1000_RCTL_CFI 0x00100000         /* canonical form indicator */
#define E1000_RCTL_DPF 0x00400000         /* discard pause frames */
#define E1000_RCTL_PMCF 0x00800000        /* pass MAC control frames */
#define E1000_RCTL_BSEX 0x02000000        /* Buffer size extension */
#define E1000_RCTL_SECRC 0x04000000       /* Strip Ethernet CRC */
#define E1000_RCTL_FLXBUF_MASK 0x78000000 /* Flexible buffer size */
#define E1000_RCTL_FLXBUF_SHIFT 27        /* Flexible buffer shift */

volatile uint32_t *e1000;
struct tx_desc *tx_ring;
struct rx_desc *rx_ring;


int e1000_attach(struct pci_func *pcif){
	pci_func_enable(pcif);
	cprintf("reg_base[0]: %08x, reg_size[0]:%d\n",pcif->reg_base[0],pcif->reg_size[0]);
	e1000=mmio_map_region(pcif->reg_base[0],pcif->reg_size[0]);
    	cprintf("status %08x\n",e1000[E1000_STATUS]);
    	
    	e1000_transmit_init();

	e1000_receive_init();
	
	char *packet = "hello world";
	uint32_t len = 11;
	
	// transmit(packet, len);	
	
	return 0;
}

void e1000_transmit_init(){
	struct PageInfo *page;
	page = page_alloc(ALLOC_ZERO);
	if (!page)
	{
		panic("e1000_attach, page_alloc error");
	}
	tx_ring = (struct tx_desc *)page2kva(page);
	for (uint32_t i = 0; i < RING_SIZE; ++i)
	{
		page = page_alloc(ALLOC_ZERO);
		if (!page)
		{
		    	panic("e1000_attach, page_alloc error");
		}
		tx_ring[i].addr = page2pa(page);
		tx_ring[i].status |= E1000_TX_DESC_STATUS_DD; 
		tx_ring[i].cmd = 0;
	}
	
	e1000[E1000_TDBAL] = PADDR((void*)tx_ring); // (uint32_t)tx_ring;
	e1000[E1000_TDBAH] = 0;
	e1000[E1000_TDLEN] = sizeof(struct tx_desc) * RING_SIZE;
	e1000[E1000_TDH] = 0;
	e1000[E1000_TDT] = 0;

	e1000[E1000_TCTL] = 0;
	e1000[E1000_TCTL] |= E1000_TCTL_EN;
	e1000[E1000_TCTL] |= E1000_TCTL_PSP;
	e1000[E1000_TCTL] |= (0x10 << 4);
	e1000[E1000_TCTL] |= (0x40 << 12);

	e1000[E1000_TIPG] = 0;
	e1000[E1000_TIPG] |= 10;
	e1000[E1000_TIPG] |= (4 << 10);
	e1000[E1000_TIPG] |= (6 << 20);
}

void e1000_receive_init(){
    e1000[E1000_RAL]=0x12005452;  // 52:54:00:12
    e1000[E1000_RAH]=0x00005634;  // 34:56;
    e1000[E1000_RAH]|=E1000_RAH_AV;
    struct PageInfo *page;
    page = page_alloc(ALLOC_ZERO);
    if (!page)
    {
        panic("e1000_attach, page_alloc error");
    }
    rx_ring = (struct rx_desc *)page2kva(page);
    for (uint32_t i = 0; i < RECEIVE_RING_SIZE; ++i)
    {
        page = page_alloc(ALLOC_ZERO);
        if (!page)
        {
            panic("e1000_receive_init, page_alloc error");
        }
        rx_ring[i].addr = page2pa(page);
        rx_ring[i].status = 0; // |= E1000_TX_DESC_STATUS_DD;
    }
    e1000[E1000_RDBAL] = PADDR((void*)rx_ring);
    e1000[E1000_RDBAH] = 0;
    e1000[E1000_RDLEN] = sizeof(struct rx_desc) * RECEIVE_RING_SIZE;
    e1000[E1000_RDH]=0;
    e1000[E1000_RDT]=RECEIVE_RING_SIZE - 1;

    e1000[E1000_RCTL]=0;
    e1000[E1000_RCTL]|=E1000_RCTL_SZ_2048;
    e1000[E1000_RCTL]|=E1000_RCTL_BAM;
    e1000[E1000_RCTL]|=E1000_RCTL_LBM_NO;
    e1000[E1000_RCTL]|=E1000_RCTL_SECRC;
    e1000[E1000_RCTL]|=E1000_RCTL_EN;
}

int transmit(char *packet, uint32_t len)
{
    uint32_t idx = e1000[E1000_TDT] % RING_SIZE;
    //STATUS, DD bit:0
    //CMD, RS bit:3, EOP bit:0
    // cprintf("$$$$$$$$$$$$ 1 %d\n",idx);
    if (tx_ring[idx].status & E1000_TX_DESC_STATUS_DD)
    {
    	// cprintf("$$$$$$$$$$$$ 2 %d\n",idx);
        tx_ring[idx].status &= ~E1000_TX_DESC_STATUS_DD;
        void *va = KADDR(tx_ring[idx].addr);
        memcpy(va, packet, len);
        tx_ring[idx].length = len;
        tx_ring[idx].cmd |= (E1000_TX_DESC_CMD_EOP | E1000_TX_DESC_CMD_RS);
        e1000[E1000_TDT] = (idx + 1) % RING_SIZE;
        return 0;
    }
    // cprintf("$$$$$$$$$$$$ 3 %d\n",idx);
    return -E_NET_NO_DES;
}

int receive(char *packet, uint32_t *len)
{
    static uint32_t idx = 0; 
    // uint32_t idx = e1000[E1000_RDT];
    if (rx_ring[idx].status & E1000_RX_DESC_STATUS_DD)
    {
        rx_ring[idx].status &= (~E1000_RX_DESC_STATUS_DD & ~E1000_RX_DESC_STATUS_EOP);
        void *va = KADDR(rx_ring[idx].addr);
        memcpy(packet, va, rx_ring[idx].length);
        *len = rx_ring[idx].length;
	cprintf("rdt: %d, rdh: %d, idx %d\n", e1000[E1000_RDT], e1000[E1000_RDH], idx);
        idx = (idx + 1) % RECEIVE_RING_SIZE;
        // e1000[E1000_RDT] = (idx + 1) % RECEIVE_RING_SIZE;
	return 0;
    }
    // cprintf("why why\n");
    return -E_NET_NO_DES;
}
