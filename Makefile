BUILD_DIR      ?= /tmp/qemu-uboot-kernel-playground
DOWNLOAD_DIR   ?= $(CURDIR)/.dl
SOURCE_DIR     ?= $(CURDIR)/.src
U_BOOT_VERSION ?= v2022.07

.PHONY: default
default: u-boot

.PHONY: u-boot
u-boot:
ifeq ($(wildcard $(DOWNLOAD_DIR)/$(U_BOOT_VERSION).tar.gz),)
	@wget -P $(DOWNLOAD_DIR) https://github.com/u-boot/u-boot/archive/refs/tags/$(U_BOOT_VERSION).tar.gz
endif
ifeq ($(wildcard $(SOURCE_DIR)/u-boot/Makefile),)
	@mkdir -p $(SOURCE_DIR)/u-boot
	@tar -xvf $(DOWNLOAD_DIR)/$(U_BOOT_VERSION).tar.gz -C $(SOURCE_DIR)/u-boot --strip-components=1
endif
ifeq ($(wildcard $(BUILD_DIR)/u-boot/.config),)
	@$(MAKE) \
		-C $(SOURCE_DIR)/u-boot \
		-j $(shell nproc) \
		O=$(BUILD_DIR)/u-boot \
		qemu-x86_64_defconfig
	@sed -i -E 's@^CONFIG_DEFAULT_DEVICE_TREE=.*@CONFIG_DEFAULT_DEVICE_TREE="qemu-x86_q35"@' $(BUILD_DIR)/u-boot/.config
endif
ifeq ($(wildcard $(BUILD_DIR)/u-boot/u-boot.rom),)
	@$(MAKE) \
		-C $(SOURCE_DIR)/u-boot \
		-j $(shell nproc) \
		O=$(BUILD_DIR)/u-boot
endif

.PHONY: u-boot-menuconfig
u-boot-menuconfig:
	@$(MAKE) \
		-C $(SOURCE_DIR)/u-boot \
		-j $(shell nproc) \
		O=$(BUILD_DIR)/u-boot \
		menuconfig

.PHONY: run
run:
	@qemu-system-x86_64 -M q35 -nographic -bios $(BUILD_DIR)/u-boot/u-boot.rom

.PHONY: clean
clean:
	@rm -fr $(BUILD_DIR)

.PHONY: distclean
distclean: clean
	@git clean -xdf $(SOURCE_DIR)
