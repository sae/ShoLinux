#!/bin/sh
#script for mounting squashed rootfs image and overlay 
#specify squash as boot parameter "rootdev" and "rootro"
#specify overlay as "rwdev" and "rootrw"
#rootrw can be file, directory, device or tmpfs by default
#
#place ". /initrd-hook.sh" to initrd/init instead mountroot in debian disros
#like this:
#  #mountroot
#  log_end_msg
#  . /initrd-hook.sh

tmproot="tmproot"
mkdir /$tmproot
mkdir /$tmproot/rootmnt
mkdir /$tmproot/rootdev
mkdir /$tmproot/rootrwdev
mkdir /$tmproot/rootro
mkdir /$tmproot/rootrw
mkdir /$tmproot/work

#we have rootdev,rootro,rootrw,rwdev ---
mount $rootdev /$tmproot/rootdev
mount /$tmproot/rootdev/$rootro  /$tmproot/rootro

#if rwdev is device, else same device
if [ -b $rwdev ]; then
    mount $rwdev /$tmproot/rootrwdev
else
    mount -o bind /$tmproot/rootdev /$tmproot/rootrwdev
fi

#rootrw can be: device, directory, file or tmpfs
if [ -z $rootrw ]; then
    newsystem=1
    mount -t tmpfs tmpfs /$tmproot/rootrw
elif [ $rootrw == "tmpfs" ]; then
    newsystem=1
    mount -t tmpfs tmpfs /$tmproot/rootrw
elif [ -b $rootrw ]; then
    mount $rootrw  /$tmproot/rootrw
elif [ -f /$tmproot/rootrwdev/$rootrw ]; then
    mount /$tmproot/rootrwdev/$rootrw  /$tmproot/rootrw
else
    #if directory not exist, it will be created
    if [ ! -d /$tmproot/rootrwdev/$rootrw  ]; then
        newsystem=1
	mkdir -p /$tmproot/rootrwdev/$rootrw  
    fi
    mount -o bind /$tmproot/rootrwdev/$rootrw  /$tmproot/rootrw
fi

#building overlay:
mkdir /$tmproot/rootrw/work
mkdir /$tmproot/rootrw/upper
#/$tmproot/rootmnt \
mkdir -p /root
mount -t overlay \
-o lowerdir=/$tmproot/rootro,upperdir=/$tmproot/rootrw/upper \
-o workdir=/$tmproot/rootrw/work \
overlay /root

#set variable for init
rootmnt="/root" 
#"/$tmproot/rootmnt"
export rootmnt

#insert hook to system init if we need to add new user and reset root password
if [ "$newsystem" == "1" ]; then
    echo "#!/bin/sh" >$rootmnt/init-hook.sh
    echo "echo \"root:1234\" | chpasswd" >>$rootmnt/init-hook.sh
    echo "adduser --gecos "user" user" >>$rootmnt/init-hook.sh
    echo "exec $init \$@" >>$rootmnt/init-hook.sh
    chmod 755 $rootmnt/init-hook.sh
    init=/init-hook.sh
fi

#shell for debugging
if [ "$break" == "overlay" ]; then
    exec /bin/sh
fi

#force switch root 
mount -n -o move /run ${rootmnt}/run
#echo "run"
mount -n -o move /sys ${rootmnt}/sys
#echo "sys"
mount -n -o move /proc ${rootmnt}/proc
#echo "proc mounted, switching"
exec switch_root $rootmnt $init

#if init terminated
echo "init ended, press exit to panic"
exec /bin/sh

#no more scripts here

