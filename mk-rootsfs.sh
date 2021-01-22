#!/bin/bash
#make squash from root
#recommend to make directly on boot partition

dest=newroot.sfs

mksquashfs / $dest -noappend  \
-wildcards -e mnt/* dev/* proc/* sys/* tmp/* media/* home/user/*

#home must be included, or you cannot login as user on tmpfs
