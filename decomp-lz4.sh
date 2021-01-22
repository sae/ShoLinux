#modern initrd include some headers
#so we need a binwalk and dd to cut them
#use binwalk, look at LZ4 archive
#then use dd if=initrd of=initrd0 bs=<offset> skip=1
#then unpack a result
lz4 -d ../initrd0 - | cpio -i

#note that you don't need to re-assemle this headers )