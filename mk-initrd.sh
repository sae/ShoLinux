#script to assemble a new initrd
cd initrd-dir
find | cpio -H newc -o | lzma -c > ../initrd