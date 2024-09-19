#!/bin/bash
set -e  # 在命令失败时自动退出脚本

# Clean Environment
if [ -z "$ENVIRONMENT_CLEAN" ]; then
    env -i ENVIRONMENT_CLEAN=1 bash "$0" "$@"
    exit $?
fi
unset CLEANED

# Set variables
echo -e "\033[32mSetting variables...\033[0m"
export KBUILD_BUILD_USER=$USER
export KBUILD_BUILD_HOST=$HOST
patchName=cake.patch
branch=lineage-21
workPath=~/playground/kernel_compile.sh
sourcePath=$workPath/android_kernel_oneplus_sm8250
patchPath=$workPath/$patchName
kernelPath=$sourcePath/out/arch/arm64/boot/Image
export PATH=$workPath/toolchain/clang-r487747/bin:$PATH #################
bootURL=https://mirrors.ustc.edu.cn/lineageos/full/lemonades/20240913/boot.img

# Clean change and output
echo -e "\033[32mCleaning source and output directories...\033[0m"
cd $sourcePath || { echo -e "\033[31mFailed to change directory to $sourcePath\033[0m"; exit 1; }
make clean
rm -fr out/.config out/arch/arm64/boot
rm -fr KernelSU
echo -e "\033[32mFetching latest code from $branch...\033[0m"
git fetch --all --depth=1 || { echo -e "\033[31mFailed to fetch repo!\033[0m"; exit 1; }
git reset --hard origin/$branch
git pull
echo -e "\033[32mCleaning kernel build environment...\033[0m"
make mrproper

# Apply patch
echo -e "\033[32mApplying patch...\033[0m"
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -s v0.9.5 || { echo -e "\033[31mFailed to setup KernelSU\033[0m"; exit 1; }
cp $patchPath $sourcePath || { echo -e "\033[31mFailed to copy patch\033[0m"; exit 1; }
patch -p1 < $patchName || { echo -e "\033[31mFailed to apply patch\033[0m"; exit 1; }

# Compile
echo -e "\033[32mCompiling kernel...\033[0m"
make -j$(nproc --all) O=out ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android- HOSTCC="clang -Ofast" CC="clang -Ofast" LLVM=1 LLVM_IAS=1 vendor/kona-perf_defconfig || { echo -e "\033[31mFailed to configure kernel build\033[0m"; exit 1; }
make -j$(nproc --all) O=out ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android- HOSTCC="clang -Ofast" CC="clang -Ofast" LLVM=1 LLVM_IAS=1 || { echo -e "\033[31mFailed to build kernel\033[0m"; exit 1; }

# Repack boot.img
echo -e "\033[32mRepacking boot.img...\033[0m"
cd $workPath || { echo -e "\033[31mFailed to change directory to $workPath\033[0m"; exit 1; }
rm -fr boot_img
rm boot.img
rm new.img
wget $bootURL || { echo -e "\033[31mFailed to download boot.img\033[0m"; exit 1; }
sleep 5
unpack_bootimg --boot_img boot.img --out boot_img || { echo -e "\033[31mFailed to unpack boot.img\033[0m"; exit 1; }
unpack_bootimg --boot_img boot.img --out boot_img --format mkbootimg | sed "s#--kernel [^ ]*#--kernel $kernelPath#" | xargs mkbootimg -o new.img || { echo -e "\033[31mFailed to repack boot.img\033[0m"; exit 1; }

echo -e "\033[32mScript completed successfully!\033[0m"
