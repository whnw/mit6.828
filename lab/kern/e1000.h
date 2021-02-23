#ifndef JOS_KERN_E1000_H
#define JOS_KERN_E1000_H

#include <inc/types.h>
#include <kern/pci.h>
#include <inc/error.h>

#define E1000_VENDER_ID 0x8086
#define E1000_DEVICE_ID 0x100e

struct tx_desc
{
    uint64_t addr; 
    uint16_t length; 
    uint8_t cso; 
    uint8_t cmd;
    uint8_t status; 
    uint8_t css; 
    uint16_t special; 
}__attribute__((packed));

struct rx_desc
{
    uint64_t addr; 
    uint16_t length; 
    uint16_t checksum;
    uint8_t status; 
    uint8_t errors; 
    uint16_t special; 
}__attribute__((packed));

int e1000_attach(struct pci_func *pcif);
void e1000_transmit_init();
void e1000_receive_init();
int transmit(char *packet,uint32_t len);
int receive(char *packet, uint32_t *len);

#endif  // SOL >= 6
