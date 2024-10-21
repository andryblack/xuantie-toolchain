UNAME_S := $(shell uname -s)

INSTALL_PREFIX ?= $(HOME)/sdk/xuantie-gnu-toolchain

PARALLEL_BUILD ?= "-j8"

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))

SELF_ROOT=$(mkfile_dir)
BUILD_ROOT=$(SELF_ROOT)/build


CONFIGURE_PARAMS ?= --with-cmodel=medany --enable-multilib --enable-gdb

BREW_PREFIX := $(shell brew --prefix)

PATH_PREPEND := $(BREW_PREFIX)/opt/coreutils/libexec/gnubin:$(BREW_PREFIX)/opt/gcc/bin
GCC_OVERRIDE := CC=gcc-14 CPP=cpp-14 CXX=c++-14

.PHONY: all install

all: build/toolchain.stamp

build:
	mkdir -p build

build/patch.stamp: build Makefile patches/riscv-newlib.patch patches/apple_silicon.patch
	cd xuantie-gnu-toolchain/riscv-newlib && git reset --hard
	cd xuantie-gnu-toolchain/riscv-newlib && git apply ../../patches/riscv-newlib.patch
	cd xuantie-gnu-toolchain/riscv-gcc && git reset --hard
	cd xuantie-gnu-toolchain/riscv-gcc && git apply --verbose ../../patches/apple_silicon.patch
	@echo timestamp > $@

build/configure.stamp: build/patch.stamp
	PATH=$(PATH_PREPEND):$(PATH) $(GCC_OVERRIDE) cd build && ../xuantie-gnu-toolchain/configure --prefix=$(INSTALL_PREFIX) $(CONFIGURE_PARAMS)
	@echo timestamp > $@

build/toolchain.stamp: build/configure.stamp
	PATH=$(PATH_PREPEND):$(PATH) $(GCC_OVERRIDE) $(MAKE) -C build $(PARALLEL_BUILD) newlib
	@echo timestamp > $@
