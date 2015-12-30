#!/bin/sh

wd=$(pwd)

export KERNEL=kernel
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnu-
export INSTALL_MOD_PATH=${wd}/output

kopt="--directory=src/linux --jobs=9"

mkdir -p src
rm -rf output

# Download repositories
if [ ! -d src/linux ]; then
	echo "Downloading Raspberry Pi linux"
	git clone git@github.com:Naegolus/linux.git src/linux
fi

if [ ! -d src/tools ]; then
	echo "Downloading Raspberry Pi tools"
	git clone git@github.com:Naegolus/tools src/tools
fi

# Apply patches
patches=$(ls -1 patches/*.patch)
patch -r - --forward --strip=1 --directory=src/linux < ${patches}

# Configure kernel
if [ ! -e src/linux/.config ]; then
	make ${kopt} bcmrpi_defconfig
fi

# Build kernel, modules and dtb files
make ${kopt} zImage modules dtbs

# Create output directory
mkdir -p output

# Install modules
kvers=$(cat src/linux/include/generated/utsrelease.h | cut --delimiter="\"" --fields=2)
make ${kopt} modules_install

tar --create --gzip --file=output/modules-${kvers}.tar.gz --directory=output lib
rm -rf output/lib

# Create boot directory
mkdir -p output/boot/overlays

# Install kernel
src/tools/mkimage/mkknlimg --dtok src/linux/arch/arm/boot/zImage output/boot/linux-${kvers}.img
