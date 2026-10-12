#include "console.h"

#include "uart.h"
#include <stdint.h>

#define CMD_MAX 8192

void console() {
    while(1) {
        uart_puts("> ");
        char c;
        char cmd[CMD_MAX];
        uint32_t i = 0;
        while(i < CMD_MAX) {
            c = uart_getc();
            cmd[i++] = c;
            if(c == '\n' || c == '\r') break;
            uart_putc(c);
        }
        uart_putc('\n');
    }
}
