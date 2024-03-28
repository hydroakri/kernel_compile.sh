rm -fr out
rm boot.img
rm new.img
aria2c https://mirrors.ustc.edu.cn/lineageos/full/lemonades/20240315/boot.img
# aria2c https://mirrorbits.lineageos.org/full/lemonades/20240301/boot.img
sleep 5
unpack_bootimg --boot_img boot.img
unpack_bootimg --boot_img boot.img --format mkbootimg | nvim
#mkbootimg [.....] -o new.img

