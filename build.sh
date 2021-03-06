#!/bin/sh

wd=$(pwd)

export KERNEL=kernel
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
export INSTALL_MOD_PATH=${wd}/output

kopt="--directory=src/linux --jobs=9"

mkdir -p src
rm -rf output

# Download repositories
if [ ! -d src/linux ]; then
	echo "Downloading Raspberry Pi linux"
	#git clone git@github.com:Naegolus/linux.git src/linux
	git clone https://github.com/raspberrypi/linux.git
fi

if [ ! -d src/tools ]; then
	echo "Downloading Raspberry Pi tools"
	git clone git@github.com:Naegolus/tools src/tools
fi

# Configure kernel
if [ ! -e src/linux/.config ]; then
	make ${kopt} bcmrpi_defconfig

	# Apply patches
	patches=$(ls -1 patches/*.patch)
	for p in ${patches}
	do
		patch -r - --forward --strip=1 --directory=src/linux < ${p}
	done

	# Create default values for new defines in configuration file
	make ${kopt} olddefconfig
fi

# Apply patches
patches=$(ls -1 patches/*.patch)
for p in ${patches}
do
	patch -r - --forward --strip=1 --directory=src/linux < ${p}
done

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

# Install device tree files
cp src/linux/arch/arm/boot/dts/bcm2708-rpi-b.dtb output/boot/.
cp src/linux/arch/arm/boot/dts/overlays/*.dtbo output/boot/overlays/.

# Install boot files
bootfiles=$(ls -1 boot_files | grep --invert-match config.txt.in | sed "s:^:boot_files/:")
cp ${bootfiles} output/boot/.
cat boot_files/config.txt.in | sed "s:@KERNEL_IMAGE@:linux-${kvers}.img:" > output/boot/config.txt

# Install licence and readme files
cp  src/linux/COPYING output/boot/COPYING.linux
cp  src/linux/arch/arm/boot/dts/overlays/README output/boot/overlays/.
