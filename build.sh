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
elif [ "$1" = "-d" ]; then
echo "Dirty Build"
else
echo "Error: Set $1 to -c or -d"
exit 1
fi

export TIME="$(date "+%Y%m%d")"

ARGS='LLVM=1'

make O=out ${ARGS} vendor/${DEVICE}_defconfig vendor/moto.config
make O=out ${ARGS} -j$(nproc)
make O=out ${ARGS} -j$(nproc) INSTALL_MOD_PATH=modules INSTALL_MOD_STRIP=1 modules_install
rm -rf AnyKernel3
cp -r akv3 AnyKernel3
mkdir -p AnyKernel3/modules/vendor/lib/modules
kver=$(make kernelversion)
kmod=$(echo ${kver} | awk -F'.' '{print $3}')
cp out/arch/arm64/boot/Image AnyKernel3/Image 
cp out/arch/arm64/boot/dtb.img AnyKernel3/dtb.img
cp out/arch/arm64/boot/dtbo.img AnyKernel3/dtbo.img
cp $(find out/modules/lib/modules/5.4* -name '*.ko') AnyKernel3/modules/vendor/lib/modules/
cp out/modules/lib/modules/5.4*/modules.{alias,dep,softdep} AnyKernel3/modules/vendor/lib/modules
cp out/modules/lib/modules/5.4*/modules.order AnyKernel3/modules/vendor/lib/modules/modules.load
sed -i 's/\(kernel\/[^: ]*\/\)\([^: ]*\.ko\)/\/vendor\/lib\/modules\/\2/g' AnyKernel3/modules/vendor/lib/modules/modules.dep
sed -i 's/.*\///g' AnyKernel3/modules/vendor/lib/modules/modules.load
cd AnyKernel3
rm -rf O_KERNEL.*.zip
zip -r9 O_KERNEL.${kmod}_${DEVICE}-${TIME}.zip * -x .git README.md *placeholder