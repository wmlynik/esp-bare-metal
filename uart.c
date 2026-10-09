#include "uart.h"

#include "wdt.h"
#include <stdint.h>

#define USB_SERIAL_JTAG_BASE    0x60038000

#define USB_SERIAL_RDWR_REG     (USB_SERIAL_JTAG_BASE + 0x0)
#define USB_SERIAL_RDWR_MASK    0x000000FF

#define USB_SERIAL_CTRL_REG     (USB_SERIAL_JTAG_BASE + 0x4)
#define USB_SERIAL_CTRL_TX_FREE_MASK    (1 << 1)
#define USB_SERIAL_CTRL_TX_DONE_MASK    (1 << 0)
#define USB_SERIAL_CTRL_RX_READY_MASK   (1 << 2)

void uart_putc(char c) {
    while(!(*(volatile uint32_t *)USB_SERIAL_CTRL_REG & USB_SERIAL_CTRL_TX_FREE_MASK)) {
        wdt_feed();
    }
    *(volatile uint32_t *)USB_SERIAL_RDWR_REG = c & 0x000000FF;
    *(volatile uint32_t *)USB_SERIAL_CTRL_REG |= USB_SERIAL_CTRL_TX_DONE_MASK;
}

void uart_puts(char *s) {
    while(*s) {
        while(!(*(volatile uint32_t *)USB_SERIAL_CTRL_REG & USB_SERIAL_CTRL_TX_FREE_MASK)) wdt_feed();
        *(volatile uint32_t *)USB_SERIAL_RDWR_REG = *(s++) & 0x000000FF;
    }
    *(volatile uint32_t *)USB_SERIAL_CTRL_REG |= USB_SERIAL_CTRL_TX_DONE_MASK;
}

char uart_getc() {
    while(!(*(volatile uint32_t*)USB_SERIAL_CTRL_REG & USB_SERIAL_CTRL_RX_READY_MASK)) wdt_feed();
    return (char)(*(volatile uint32_t*) USB_SERIAL_RDWR_REG & USB_SERIAL_RDWR_MASK);
}
