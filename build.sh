#!/bin/bash
if [ -z "$ENVIRONMENT_CLEAN" ]; then
    # Not in a clean environment, execute self in clean environment
    env -i ENVIRONMENT_CLEAN=1 bash "$0" "$@"
    exit $?
fi
unset CLEANED
export KBUILD_BUILD_USER=hydroakri
export KBUILD_BUILD_HOST=archlinux
export PATH=/home/hydroakri/sm8250kernel/toolchain/clang-r487747c/bin:$PATH
export PATH=/home/hydroakri/sm8250kernel/toolchain/aarch64-linux-android-4.9-961622e926a1b21382dba4dd9fe0e5fb3ee5ab7c/bin:$PATH
# export https_proxy=127.0.0.1:7890

cd ~/sm8250kernel/android_kernel_oneplus_sm8250/  ###########
make clean
rm -fr out/.config out/arch/arm64/boot
rm -fr KernelSU
git fetch --all --depth=1

# if git status | grep -q "Your branch is up to date with"; then
#     echo "ALREADY UP TO DATE"
#     exit 0
# else
#     echo "UPDATING KERNEL CODE"

git reset --hard origin/lineage-21 #########
git pull

make mrproper
# curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
cp ../cake.patch ./
patch -p1 < cake.patch

echo "CONFIG_QCOM_ADRENO_DEFAULT_GOVERNOR=\"simple_ondemand\"" >> arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y" >> arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_NET_SCH_DEFAULT=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_DEFAULT_CAKE=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_DEFAULT_NET_SCH=\"cake\"" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_NET_SCH_CAKE=y" >> arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_TCP_CONG_ADVANCED=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_DEFAULT_BBR=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_DEFAULT_TCP_CONG=\"bbr\"" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_TCP_CONG_BBR=y" >> arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_PM_WAKELOCKS_GC=y" >> arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_HZ_100=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_HZ=100" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_NO_HZ_IDLE=y" >> arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_SPARSEMEM_VMEMMAP=y" >> arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
sed -i 's/CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y/CONFIG_CPU_FREQ_GOV_SCHEDUTIL=n/' arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_ARM_QCOM_CPUFREQ_KRYO=y" >> arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_LTO=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_LTO_CLANG=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_THINLTO=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_LTO_NONE=n" >> arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_HAVE_KPROBES=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_KPROBE_EVENTS=y" >> arch/arm64/configs/vendor/kona-perf_defconfig

# make -j$(nproc --all) O=out ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android- CC=clang LLVM=1 LLVM_IAS=1 vendor/kona-perf_defconfig
# make -j$(nproc --all) O=out ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android- CC=clang LLVM=1 LLVM_IAS=1

make -j$(nproc --all) O=out ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android- HOSTCC="clang -Ofast" CC="clang -Ofast" LLVM=1 LLVM_IAS=1 vendor/kona-perf_defconfig
make -j$(nproc --all) O=out ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android- HOSTCC="clang -Ofast" CC="clang -Ofast" LLVM=1 LLVM_IAS=1

# fi
