Toolset for hacking debian-based live-iso

So you don't need to use install procedure
- extract filesystem.squashfs, vmlinuz and initrd from iso, 
- put them to usb or harddisk
- unpack initrd using binwalk and lz4
- modify init script on initrd
- pack initrd 
- edit grub menu 

after modifying live system you can assemle a new rootfs
or drop changes

kernel parameters:
rootdev - device where squashfs located
rootro - file pathname on rootdev
rwdev - device for rw store (if omitted, =rootdev)
rootrw - file.ext4, device, tmpfs, or directory (will be created if not exist)
breakmount=1 - break to shell after mount overlay

look at scripts, i try to keep it simple as possible
sae762@gmail.com
