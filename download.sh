#!/bin/sh

if [ "$1" == "" ]; then
	echo "Usage: $0 <ip> [section]"
	echo ""
	echo "sections: boot,dts,kernel,modules"
	exit 1
fi

if [ "$2" == "boot" ]; then
	echo "Downloading boot files"
fi

if [ "$2" == "dts" ]; then
	echo "Downloading dts"
fi

if [ "$2" == "kernel" ]; then
	echo "Downloading kernel"
fi

if [ "$2" == "modules" ]; then
	echo "Downloading modules"
fi

if [ "$2" == "" ]; then
	echo "Downloading all"
fi
