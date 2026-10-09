#include "wdt.h"

#include <stdint.h>

#define DR_REG_TIMERGROUP0_BASE 0x6001F000
#define TIMG0_WDTFEED_REG (DR_REG_TIMERGROUP0_BASE + 0x60)

#define DR_REG_RTCCNTL_BASE 0x60008000
#define RTC_CNTL_WDTFEED_REG          (DR_REG_RTCCNTL_BASE + 0xAC)
#define RTC_CNTL_WDTFEED_MASK (1 << 31)

#define RTC_CNTL_SWD_WKEY_VALUE 0x8F1D312A
#define RTC_CNTL_SWD_CONF_REG          (DR_REG_RTCCNTL_BASE + 0xB4)
#define RTC_CNTL_SWD_FEED_MASK (1 << 29)
#define RTC_CNTL_SWD_WPROTECT_REG          (DR_REG_RTCCNTL_BASE + 0xB8)

void wdt_init() {
    *(volatile uint32_t*) RTC_CNTL_SWD_WPROTECT_REG = RTC_CNTL_SWD_WKEY_VALUE;
}

void wdt_feed() {
    *(volatile uint32_t*) TIMG0_WDTFEED_REG = 1;
    *(volatile uint32_t*) RTC_CNTL_WDTFEED_REG |= RTC_CNTL_WDTFEED_MASK;
    *(volatile uint32_t*) RTC_CNTL_SWD_CONF_REG |= RTC_CNTL_SWD_FEED_MASK;
}
