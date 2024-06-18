#!/bin/bash
[ ! -d "toolchain" ] && echo  "installing toolchain..." && bash init_clang.sh
export KBUILD_BUILD_USER=ghazzor

PATH=$PWD/toolchain/bin:$PATH
export LLVM_DIR=$PWD/toolchain/bin
export LLVM=1
export ARCH=arm64

if [ -z "$DEVICE" ]; then
export DEVICE=g84
fi

if [[ -z "$1" || "$1" = "-c" ]]; then
echo "Clean Build"
rm -rf out
make distclean
elif [ "$1" = "-d" ]; then
echo "Dirty Build"
else
echo "Error: Set $1 to -c or -d"
exit 1
fi

export TIME="$(date "+%Y%m%d")"

ARGS='
LLVM=1
'

make O=out ${ARGS} vendor/${DEVICE}_defconfig vendor/moto.config
make O=out ${ARGS} -j$(nproc)
make O=out ${ARGS} -j$(nproc) INSTALL_MOD_PATH=modules INSTALL_MOD_STRIP=1 modules_install
