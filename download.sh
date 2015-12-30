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
files=""

echo "Downloading:"
for s in ${sect}
do
	if [ "$s" == "boot" ]; then
		echo "- boot files"
		bootfiles=$(ls -1 output/boot/ | grep --invert-match --extended-regexp "overlays|bcm2708|config|linux.*img" | sed "s:^:boot/:")
		files="${files} ${bootfiles}"
	fi

	if [ "$s" == "dts" ]; then
		echo "- device tree"
		maindtb=$(ls -1 output/boot/*.dtb | sed "s:output/::")
		overlays=$(ls -1 output/boot/overlays/*.dtb | sed "s:output/::")
		files="${files} ${maindtb} ${overlays}"
	fi

	if [ "$s" == "kernel" ]; then
		echo "- config file"
		echo "- kernel image"
		files="${files} boot/config.txt boot/linux-${kvers}.img"
	fi

	if [ "$s" == "modules" ]; then
		echo "- modules"
		files="${files} modules-${kvers}.tar.gz"
	fi
done

echo "Files: ${files}"

exit 1

if [ ! "${files}" == "" ]; then
	scp ${files} root@$1:/boot/.
fi
