TARGET := baremetal

ESP_BIN := ~/.espressif/tools/xtensa-esp-elf/esp-15.2.0_20251204/xtensa-esp-elf/bin/
CC := $(ESP_BIN)xtensa-esp32s3-elf-gcc
OBJCOPY := $(ESP_BIN)xtensa-esp32s3-elf-objcopy
OBJDUMP := $(ESP_BIN)xtensa-esp32s3-elf-objdump

ESPTOOL := ~/.espressif/tools/python/v6.1/venv/bin/esptool

CFLAGS := \
	-mlongcalls \
	-mabi=call0 \
	-ffreestanding \
	-fno-builtin \
	-nostdlib \
	-nodefaultlibs \
	-nostartfiles \
	-O1 \
	-g

ASFLAGS := \
	-mlongcalls \
	-mabi=call0 \
	-g

LDFLAGS := \
	-nostdlib \
	-nodefaultlibs \
	-nostartfiles \
	-Wl,--gc-sections \
	-Wl,-Map=$(TARGET).map \
	-T linker.ld \
	--verbose

OBJS := init.o main.o uart.o wdt.o console.o

.PHONY: all clean disasm flash

all: $(TARGET).elf $(TARGET).bin

$(TARGET).elf: $(OBJS) linker.ld
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

init.o: init.S
	$(CC) $(ASFLAGS) -c $< -o $@

main.o: main.c
	$(CC) $(CFLAGS) -c $< -o $@

uart.o: uart.c
	$(CC) $(CFLAGS) -c $< -o $@

wdt.o: wdt.c
	$(CC) $(CFLAGS) -c $< -o $@

console.o: console.c
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET).bin: $(TARGET).elf
	$(ESPTOOL) --chip esp32s3 elf2image --flash-mode dio --flash-freq 40m --flash-size 16MB $<

disasm: $(TARGET).elf
	$(OBJDUMP) -d -S $<

flash: $(TARGET).bin
	~/.espressif/tools/openocd-esp32/v0.12.0-esp32-20260703/openocd-esp32/bin/openocd -s ~/.espressif/tools/openocd-esp32/v0.12.0-esp32-20260703/openocd-esp32/share/openocd/scripts/ -f board/esp32s3-builtin.cfg -c init -c halt -c "program $< 0x0 reset exit"

clean:
	rm -f $(OBJS) $(TARGET).elf $(TARGET).bin $(TARGET).map
