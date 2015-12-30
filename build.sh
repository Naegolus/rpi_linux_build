#!/bin/sh

wd=$(pwd)

mkdir -p src output

# Download repositories
if [ ! -d src/linux ]; then
	echo "Downloading Raspberry Pi linux"
	git clone git@github.com:Naegolus/linux.git src/linux
fi

if [ ! -d src/tools ]; then
	echo "Downloading Raspberry Pi tools"
	git clone git@github.com:Naegolus/tools src/tools
fi
