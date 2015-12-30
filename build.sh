#!/bin/sh

wd=$(pwd)

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
	KERNEL=kernel ARCH=arm CROSS_COMPILE=arm-linux-gnu- make --directory=src/linux bcmrpi_defconfig
fi

# Build kernel, modules and dtb files
KERNEL=kernel ARCH=arm CROSS_COMPILE=arm-linux-gnu- make --directory=src/linux --jobs=9 zImage modules dtbs

# Create output directory
mkdir -p output

# Install modules
KERNEL=kernel ARCH=arm CROSS_COMPILE=arm-linux-gnu- INSTALL_MOD_PATH=${wd}/output make --directory=src/linux modules_install
tar --create --gzip --file=output/modules.tar.gz --directory=output lib
rm -rf output/lib

# Create boot directory
mkdir -p output/boot/overlays
