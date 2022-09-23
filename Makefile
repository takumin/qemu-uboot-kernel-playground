unexport CPATH
unexport C_INCLUDE_PATH
unexport CPLUS_INCLUDE_PATH
unexport PKG_CONFIG_PATH
unexport CMAKE_MODULE_PATH
unexport CCACHE_PATH
unexport LD_LIBRARY_PATH
unexport LD_RUN_PATH
unexport UNZIP

export LC_ALL = C
export CCACHE_DIR = $(HOME)/.cache/ccache

BUILD_DIR      ?= /tmp/qemu-uboot-kernel-playground
DOWNLOAD_DIR   ?= $(CURDIR)/.dl
SOURCE_DIR     ?= $(CURDIR)/.src
U_BOOT_VERSION ?= v2022.07
LINUX_VERSION  ?= 5.15.69

.PHONY: default
default: u-boot linux

include Makefile.u-boot
include Makefile.linux

.PHONY: run-u-boot
run-u-boot:
	@qemu-system-x86_64 \
		-M q35 \
		-nographic \
		-bios $(BUILD_DIR)/u-boot/u-boot.rom

.PHONY: run-kernel
run-kernel:
	@qemu-system-x86_64 \
		-M q35 \
		-nographic \
		-kernel $(BUILD_DIR)/linux/arch/x86/boot/bzImage \
		-append "console=ttyS0"

.PHONY: clean
clean:
	@rm -fr $(BUILD_DIR)

.PHONY: distclean
distclean: clean
	@git clean -xdf $(SOURCE_DIR)
