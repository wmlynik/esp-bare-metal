#include <stdint.h>

#include "uart.h"
#include "wdt.h"
#include "console.h"

volatile uint32_t counter = 0;

void main(void)
{
    wdt_init();
    console();
}
