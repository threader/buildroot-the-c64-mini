##!/bin/bash
#
# scripts/build_sun7i.sh
# (c) Copyright 2013
# Allwinner Technology Co., Ltd. <www.allwinnertech.com>
# James Deng <csjamesdeng@allwinnertech.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

set -e
LICHEE_BR_DIR=`echo $PWD`
LICHEE_BR_OUT=$LICHEE_BR_DIR/output
build_buildroot()
{
    if [ ! -f ${LICHEE_BR_DIR}/.config ] ; then
        printf "\nUsing default config ...\n\n"
        make V=1 O=${LICHEE_BR_OUT} -C ${LICHEE_BR_DIR} ${LICHEE_BR_DEFCONF}
    fi

    make O=${LICHEE_BR_OUT} -C ${LICHEE_BR_DIR} LICHEE_GEN_ROOTFS=n
}

EXTERNAL_DIR=${LICHEE_BR_DIR}/external-packages
DESTDIR=${LICHEE_BR_DIR}/images
STAGING_DIR=${LICHEE_BR_OUT}/staging
INCDIR=${STAGING_DIR}/usr/include
TARGET_DIR=${LICHEE_BR_OUT}/target
TARGET_SYSROOT_OPT="--sysroot=${STAGING_DIR}"

CROSS_COMPILE=/home/thread/dev/sdk/gcc-linaro-4.9-2016.02-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-
#/home/thread/dev/sdk/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-
#arm-linux-gnueabi-

TARGET_AR=${CROSS_COMPILE}ar
TARGET_AS=${CROSS_COMPILE}as
TARGET_CC="${CROSS_COMPILE}gcc ${TARGET_SYSROOT_OPT}"
TARGET_CPP="${CROSS_COMPILE}cpp ${TARGET_SYSROOT_OPT}"
TARGET_CXX="${CROSS_COMPILE}g++ ${TARGET_SYSROOT_OPT}"
TARGET_FC="${CROSS_COMPILE}gfortran ${TARGET_SYSROOT_OPT}"
TARGET_LD="${CROSS_COMPILE}ld ${TARGET_SYSROOT_OPT}"
TARGET_NM="${CROSS_COMPILE}nm"
TARGET_RANLIB="${CROSS_COMPILE}ranlib"
TARGET_OBJCOPY="${CROSS_COMPILE}objcopy"
TARGET_OBJDUMP="${CROSS_COMPILE}objdump"
TARGET_CFLAGS="-pipe -O2 -mcpu=cortex-a7 -mtune=cortex-a7 -mfpu=vfpv4-d16 -mfpu=neon-vfpv4 -funsafe-math-optimizations -mabi=aapcs-linux -mfloat-api=softfp -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -I${INCDIR}"
# TODO: Test -mfpu=vfpv4-d16 vs -mfpu=neon-vfpv4, only the last flag will be honored 
BUILD_OPTIONS="DESTDIR=${DESTDIR} CROSS_COMPILE=${CROSS_COMPILE} \
    STAGING_DIR=${STAGING_DIR} TARGET_DIR=${TARGET_DIR} CC=\"${TARGET_CC}\" \
    AR=${TARGET_AR} AS=${TARGET_AS} CPP=\"${TARGET_CPP}\" CXX=\"${TARGET_CXX}\" \
    FC=\"${TARGET_FC}\" LD=\"${TARGET_LD}\" NM=${TARGET_NM} RANLIB=${TARGET_RANLIB} \
    OBJCOPY=${TARGET_OBJCOPY} OBJDUMP=${TARGET_OBJDUMP} CFLAGS=\"${TARGET_CFLAGS}\""

build_external()
{
    for dir in ${EXTERNAL_DIR}/* ; do
        if [ -f ${dir}/Makefile ]; then
            BUILD_COMMAND="make -C ${dir} ${BUILD_OPTIONS} all"
            eval $BUILD_COMMAND
            BUILD_COMMAND="make -C ${dir} ${BUILD_OPTIONS} install"
            eval $BUILD_COMMAND
        fi
    done
}

case "$1" in
    clean)
        rm -rf ${LICHEE_BR_OUT}
        ;;
    *)
        build_buildroot
        export PATH=${LICHEE_BR_OUT}/external-toolchain/bin:$PATH
        build_external
        ;;
esac
