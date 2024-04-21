PROJECTBASE = $(PWD)
override PROJECTBASE    := $(abspath $(PROJECTBASE))
TOP_DIR = $(PROJECTBASE)

# Build Path 
BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/obj

# Linux image
BUILDROOT_DIR ?= 
LINUX_IMAGE =  $(BUILDROOT_DIR)/output/images/Image

# ASM sources
ASM_SOURCES =  \
		${wildcard $(TOP_DIR)/bootloader/*.S}

# link script
LD_FILE = bootloader/boot.lds
LDSCRIPT = $(PROJECTBASE)/$(LD_FILE)

# default action: build all
all: $(BUILD_DIR)/fw.bin

TARGET = fsbl
include Compile.mk

$(BUILD_DIR)/YsyxSoc.dtb: ./dts/YsyxSoc.dts 
	dtc -I dts -O dtb -o $@ $<

$(BUILD_DIR)/Image.bin: $(LINUX_IMAGE)
	cp $< $@

$(BUILD_DIR)/payload.bin: $(BUILD_DIR)/YsyxSoc.dtb $(BUILD_DIR)/Image.bin
	dd of=$@ bs=1k count=64K if=/dev/zero
	dd of=$@ bs=1k conv=notrunc seek=0 if=$(BUILD_DIR)/Image.bin
	dd of=$@ bs=1k conv=notrunc seek=32K if=$(BUILD_DIR)/YsyxSoc.dtb

$(BUILD_DIR)/fw.bin: $(BUILD_DIR)/fsbl.bin $(BUILD_DIR)/payload.bin
	dd of=$@ bs=1k count=64K if=/dev/zero
	dd of=$@ bs=1k conv=notrunc seek=0 if=$< 
	dd of=$@ bs=1k conv=notrunc seek=1K if=$(BUILD_DIR)/payload.bin

IMAGE_REL = $(BUILD_DIR)/fw.bin
IMAGE     = $(abspath $(IMAGE_REL))


image: $(BUILD_DIR)/fw.bin
	@$(OBJDUMP) -d -S $(BUILD_DIR)/$(TARGET).elf > $(BUILD_DIR)/$(TARGET).txt

NEMUFLAGS = -b -f $(IMAGE) -l $(shell dirname $(IMAGE).elf)/nemu-log.txt

run: image
	make -C $(NEMU_HOME) ISA=rv32-nemu run ARGS="$(NEMUFLAGS)" IMG=$(shell dirname $(IMAGE).elf)/payload.bin
