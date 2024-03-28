export KBUILD_BUILD_USER=hydroakri
export KBUILD_BUILD_HOST=archlinux
export PATH=/home/hydroakri/sm8250kernel/toolchain/clang-aosp/bin:$PATH
export PATH=/home/hydroakri/sm8250kernel/toolchain/gcc-aosp/bin:$PATH
# export https_proxy=127.0.0.1:7890

cd ~/sm8250kernel/kernel_oneplus_sm8250/  ###########
rm -fr out
git fetch --all --depth=1
git reset --hard origin/13.1 #########
git pull
rm -fr KernelSU

#git submodule update --init --recursive
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
echo "CONFIG_QCOM_ADRENO_DEFAULT_GOVERNOR=\"simple_ondemand\"" >> arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_NET_SCH_DEFAULT=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_DEFAULT_CAKE=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_DEFAULT_NET_SCH=\"cake\"" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_NET_SCH_CAKE=y" >> arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_PM_WAKELOCKS_GC=y" >> arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_HZ=100" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_NO_HZ_IDLE=y" >> arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_SPARSEMEM_VMEMMAP=y" >> arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_SCHED_AUTOGROUP=y" >> arch/arm64/configs/vendor/kona-perf_defconfig

# echo "CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
# sed -i 's/CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL=y/CONFIG_CPU_DEFAULT_FREQ_GOV_SCHEDUTIL=n/' arch/arm64/configs/vendor/kona-perf_defconfig
# sed -i 's/CONFIG_CPU_FREQ_GOV_SCHEDUTIL=y/CONFIG_CPU_FREQ_GOV_SCHEDUTIL=n/' arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_ARM_QCOM_CPUFREQ_KRYO=y" >> arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_LTO=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_LTO_CLANG=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_THINLTO=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
echo "CONFIG_LTO_NONE=n" >> arch/arm64/configs/vendor/kona-perf_defconfig

#echo "CONFIG_MODULES=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
#echo "CONFIG_KPROBES=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
#echo "CONFIG_HAVE_KPROBES=y" >> arch/arm64/configs/vendor/kona-perf_defconfig
#echo "CONFIG_KPROBE_EVENTS=y" >> arch/arm64/configs/vendor/kona-perf_defconfig

echo "CONFIG_KERNELSU=y" >> arch/arm64/configs/vendor/kona-perf_defconfig

make -j$(nproc --all) O=out ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android- CC=clang LLVM=1 LLVM_IAS=1 vendor/kona-perf_defconfig
make -j$(nproc --all) O=out ARCH=arm64 CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android- CC=clang LLVM=1 LLVM_IAS=1
