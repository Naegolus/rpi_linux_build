#!/bin/sh

if [ "$1" == "" ]; then
	echo "Usage: $0 <ip> [section]"
	echo ""
	echo "sections: boot,dts,kernel,modules"
	exit 1
fi

if [ "$2" == "" ]; then
	sections="boot,dts,kernel,modules"
else
	sections="$2"
fi

sect=$(echo ${sections} | sed "s:,: :g")
kvers=$(cat src/linux/include/generated/utsrelease.h | cut --delimiter="\"" --fields=2)
files=

echo "Downloading:"
for s in ${sect}
do
	if [ "$s" == "boot" ]; then
		echo "- boot files"
		bootfiles=$(ls -1 output/boot/ | grep --invert-match --extended-regexp "overlays|bcm2708|config|linux.*img" | sed "s:^:boot/:")
		files="${files}"$'\n'"${bootfiles}"
	fi

	if [ "$s" == "dts" ]; then
		echo "- device tree"
		maindtb=$(ls -1 output/boot/*.dtb | sed "s:output/::")
		overlays=$(ls -1 output/boot/overlays/*.dtb | sed "s:output/::")
		files="${files}"$'\n'"${maindtb}"$'\n'"${overlays}"
	fi

	if [ "$s" == "kernel" ]; then
		echo "- config file"
		echo "- kernel image"
		files="${files}"$'\n'"boot/config.txt"$'\n'"boot/linux-${kvers}.img"
	fi

	if [ "$s" == "modules" ]; then
		echo "- modules"
		files="${files}"$'\n'"modules-${kvers}.tar.gz"
	fi
done

if [ ! "${files}" == "" ]; then
	cd output
	ssh root@$1 'mkdir -p /boot/overlays'
	#scp ${files} root@$1:/.
fi
