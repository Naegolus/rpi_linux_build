#!/bin/sh

allsec="firmware,config,dts,kernel,modules"
defsec="${allsec}"

if [ "$1" = "" ]; then
	echo "Usage: $0 <ip> [section]"
	echo ""
	echo "sections"
	echo "  available: ${allsec}"
	echo "  default:   ${defsec}"
	exit 1
fi

if [ "$2" = "" ]; then
	sections="${defsec}"
else
	sections="$2"
fi

sect=$(echo ${sections} | sed "s:,: :g")
kvers=$(cat src/linux/include/generated/utsrelease.h | cut --delimiter="\"" --fields=2)

for s in ${sect}
do
	if [ "$s" = "firmware" ]; then
		echo "### Downloading firmware files"
		bootfiles=$(ls -1 output/boot/ | grep --invert-match --extended-regexp "overlays|bcm2708|config|linux.*img" | sed "s:^:output/boot/:")
		scp ${bootfiles} root@$1:/boot/.
	fi

	if [ "$s" = "config" ]; then
		echo "### Downloading kernel image and config file"
		scp output/boot/config.txt root@$1:/boot/.
	fi

	if [ "$s" = "dts" ]; then
		echo "### Downloading device tree"
		ssh root@$1 'mkdir -p /boot/overlays'
		scp output/boot/bcm2708-rpi-b.dtb root@$1:/boot/.
		overlays=$(ls -1 output/boot/overlays/*.dtb)
		scp ${overlays} root@$1:/boot/overlays/.
	fi

	if [ "$s" = "kernel" ]; then
		echo "### Downloading kernel image and config file"
		scp output/boot/linux-${kvers}.img root@$1:/boot/.
	fi

	if [ "$s" = "modules" ]; then
		echo "### Downloading modules"
		scp output/modules-${kvers}.tar.gz root@$1:/tmp/.
	fi
done
