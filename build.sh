#!/bin/bash
# Clean Environment
if [ -z "$ENVIRONMENT_CLEAN" ]; then
    env -i ENVIRONMENT_CLEAN=1 bash "$0" "$@"
    exit $?
fi
unset CLEANED

# Set variables
export KBUILD_BUILD_USER=hydroakri
export KBUILD_BUILD_HOST=Debian
export PATH=/home/hydroakri/git-app/toolchain/clang-r487747/bin:$PATH
patchName=cake.patch
branch=lineage-21
workPath=~/playground/kernel_compile.sh
sourcePath=$workPath/android_kernel_oneplus_sm8250
patchPath=$workPath/$patchName
kernelPath=$sourcePath/out/arch/arm64/boot/Image
bootURL=https://mirrors.ustc.edu.cn/lineageos/full/lemonades/20240913/boot.img

# Clean change and output
cd $sourcePath
make clean
rm -fr out/.config out/arch/arm64/boot
rm -fr KernelSU
git fetch --all --depth=1
git reset --hard origin/$branch
git pull
make mrproper

# Apply patch
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -s v0.9.5
cp $patchPath $sourcePath
patch -p1 < $patchName

# Compile
make -j$(nproc --all) O=out ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android- HOSTCC="clang -Ofast" CC="clang -Ofast" LLVM=1 LLVM_IAS=1 vendor/kona-perf_defconfig
make -j$(nproc --all) O=out ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android- HOSTCC="clang -Ofast" CC="clang -Ofast" LLVM=1 LLVM_IAS=1

# Repack boot.img
cd $workPath
rm -fr boot_img
rm boot.img
rm new.img
wget $bootURL
sleep 5
unpack_bootimg --boot_img boot.img --out boot_img
unpack_bootimg --boot_img boot.img --out boot_img --format mkbootimg | sed "s#--kernel [^ ]*#--kernel $kernelPath#" | xargs mkbootimg -o new.img
