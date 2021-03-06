#!/bin/sh
#set -e
set -x
BUILD=/mnt/build
BRANCH=angstrom-v2012.12-yocto1.3
DATE=`date +%F-%T`
#TAG=f6fe4ce6f4f82be5b2185b12ccadb163a61e512e
date
if [ -e $BUILD/oe ]
then
 cd $BUILD/oe
# time MACHINE=beaglebone ./oebb.sh update commit $TAG
 time MACHINE=beaglebone ./oebb.sh update
else
# time git clone git://github.com/jadonk/setup-scripts.git /mnt/build/oe
 time git clone git://github.com/Angstrom-distribution/setup-scripts.git /mnt/build/oe
 cd $BUILD/oe
 time git checkout -b $BRANCH origin/$BRANCH
 time MACHINE=beaglebone ./oebb.sh config beaglebone
 sed -i 's/^PARALLEL_MAKE.*$/PARALLEL_MAKE = "-j4"/' $BUILD/oe/conf/local.conf
 sed -i 's/^BB_NUMBER_THREADS.*$/BB_NUMBER_THREADS = "3"/' $BUILD/oe/conf/local.conf
# time MACHINE=beaglebone ./oebb.sh update commit $TAG
fi
source ~/.oe/environment-angstromv2012.12
#time bitbake -k console-image
time bitbake -k cloud9-gnome-image
cd $BUILD/oe/build
date
echo !!!! COMPLETED build-angstrom.sh !!!!

cd $BUILD
rm -rf sources.tgz sources
tar czf $BUILD/sources.tgz oe/oebb.sh oe/README oe/conf oe/sources oe/scripts oe/.git $HOME/.oe/*
mkdir -p sources
cd sources
split -b 20M ../sources.tgz sources.tgz.

cd $BUILD/oe/build/tmp-angstrom_v2012_12-eglibc/deploy/images/beaglebone
rm -rf rootfs
mkdir -p rootfs
cd rootfs
split -b 20M ../Angstrom-Cloud9-IDE-GNOME-eglibc-ipk-v2012.12-beaglebone.rootfs.tar.gz rootfs.tgz.

cd $BUILD/oe/build/tmp-angstrom_v2012_12-eglibc/deploy/images/beaglebone
cat >index.html <<EOF
<html>
<head>
<title>Angstrom $DATE</title>
</head>
<body>
<h1>Angstrom $DATE</h1>
<ul>
<li><a href="build.log">build.log</a></li>
<li><a href="Angstrom-Cloud9-IDE-GNOME-eglibc-ipk-v2012.12-beaglebone.rootfs.tar.gz">
Angstrom-Cloud9-IDE-GNOME-eglibc-ipk-v2012.12-beaglebone.rootfs.tar.gz
</a></li>
<li><a href="sources.tgz">sources.tgz</a></li>
</a></li>
EOF
ls $BUILD/oe/build/tmp-angstrom_v2012_12-eglibc/deploy/images/beaglebone/MLO* | perl -pe 's/^(.*)$/<li><a href="$1">$1<\/a><\/li>/' >>index.html
ls $BUILD/oe/build/tmp-angstrom_v2012_12-eglibc/deploy/images/beaglebone/u-boot.img* | perl -pe 's/^(.*)$/<li><a href="$1">$1<\/a><\/li>/' >>index.html
ls $BUILD/oe/build/tmp-angstrom_v2012_12-eglibc/deploy/images/beaglebone/modules* | perl -pe 's/^(.*)$/<li><a href="$1">$1<\/a><\/li>/' >>index.html
ls $BUILD/oe/build/tmp-angstrom_v2012_12-eglibc/deploy/images/beaglebone/uImage* | perl -pe 's/^(.*)$/<li><a href="$1">$1<\/a><\/li>/' >>index.html
ls $BUILD/oe/build/tmp-angstrom_v2012_12-eglibc/deploy/images/beaglebone/rootfs | perl -pe 's/^(.*)$/<li><a href="rootfs\/$1">rootfs\/$1<\/a><\/li>/' >>index.html
ls $BUILD/sources | perl -pe 's/^(.*)$/<li><a href="sources\/$1">sources\/$1<\/a><\/li>/' >>index.html
echo "</ul></body></html>" >>index.html

cd $BUILD/ec2-build
./s3cp $BUILD/oe/build/tmp-angstrom_v2012_12-eglibc/deploy/images/beaglebone/index.html angstrom-$DATE
./s3cp $BUILD/build.log angstrom-$DATE
./s3cp $BUILD/oe/build/tmp-angstrom_v2012_12-eglibc/deploy/images/beaglebone/MLO* angstrom-$DATE
./s3cp $BUILD/oe/build/tmp-angstrom_v2012_12-eglibc/deploy/images/beaglebone/u-boot.img* angstrom-$DATE
./s3cp $BUILD/oe/build/tmp-angstrom_v2012_12-eglibc/deploy/images/beaglebone/uImage* angstrom-$DATE
./s3cp $BUILD/oe/build/tmp-angstrom_v2012_12-eglibc/deploy/images/beaglebone/modules* angstrom-$DATE
./s3cp $BUILD/oe/build/tmp-angstrom_v2012_12-eglibc/deploy/images/beaglebone/rootfs angstrom-$DATE
./s3cp $BUILD/sources angstrom-$DATE
./s3cp $BUILD/oe/build/tmp-angstrom_v2012_12-eglibc/deploy/images/beaglebone/Angstrom-Cloud9-IDE-GNOME-eglibc-ipk-v2012.12-beaglebone.rootfs.tar.gz angstrom-$DATE
./s3cp $BUILD/sources.tgz angstrom-$DATE
