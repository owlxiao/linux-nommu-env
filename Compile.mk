CROSS_COMPILE = riscv64-linux-gnu-
CC        = $(CROSS_COMPILE)gcc
AS        = $(CROSS_COMPILE)gcc
OBJCOPY   = $(CROSS_COMPILE)objcopy
OBJDUMP   = $(CROSS_COMPILE)objdump
AR        = $(CROSS_COMPILE)ar
SZ        = $(CROSS_COMPILE)size
LD        = $(CROSS_COMPILE)ld
HEX       = $(OBJCOPY) -O ihex
BIN       = $(OBJCOPY) -O binary -S


# libraries
LIBS = 
LIBDIR =
LDFLAGS = -melf32lriscv -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Map=$(BUILD_DIR)/$(TARGET).map --gc-sections -e _start
CFLAGS = -march=rv32im_zicsr -mabi=ilp32 -fno-pic -mcmodel=medany -mstrict-align -static -O0 -g
ASFLAGS = $(CFLAGS)

#######################################
# build the application
#######################################
# list of objects
OBJECTS = $(addprefix $(OBJ_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
# list of ASM program objects
OBJECTS += $(addprefix $(OBJ_DIR)/,$(notdir $(ASM_SOURCES:.S=.o)))
vpath %.S $(sort $(dir $(ASM_SOURCES)))

$(OBJ_DIR)/%.o: %.c Makefile | $(OBJ_DIR)
	@echo CC $(notdir $@)
	@$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(OBJ_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(OBJ_DIR)/%.o: %.S Makefile | $(OBJ_DIR)
	@echo AS $(notdir $@)
	@$(AS) -c $(ASFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) $(LDSCRIPT) Makefile 
	@echo LD "->" $(notdir $@)
	@$(LD) $(OBJECTS) $(LDFLAGS) -o $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	@echo OBJCOPY $(notdir $@)
	@$(HEX) $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	@echo OBJCOPY $(notdir $@)
	@$(BIN) $< $@

$(BUILD_DIR)/%.lst: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	@echo OBJDUMP $(notdir $@)
	@$(OBJDUMP) --source --demangle --disassemble --reloc --wide $< > $@
	@$(SZ) --format=berkeley $<

$(BUILD_DIR):
	mkdir $@

ifeq ($(OBJ_DIR), $(wildcard $(OBJ_DIR)))
else
$(OBJ_DIR):$(BUILD_DIR)
	mkdir $@
endif