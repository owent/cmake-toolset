#!/bin/bash

if [[ "x$BACKUP_ASM" != "x" ]]; then
    export ASM="$BACKUP_ASM"
fi
if [[ "x$BACKUP_CC" != "x" ]]; then
    export CC="$BACKUP_CC"
fi
if [[ "x$BACKUP_CXX" != "x" ]]; then
    export CXX="$BACKUP_CXX"
fi
if [[ "x$BACKUP_SDKROOT" != "x" ]]; then
    export SDKROOT="$BACKUP_SDKROOT"
fi
if [[ "x$BACKUP_DEVROOT" != "x" ]]; then
    export DEVROOT="$BACKUP_DEVROOT"
fi
if [[ "x$BACKUP_CROSS_TOP" != "x" ]]; then
    export CROSS_TOP="$BACKUP_CROSS_TOP"
fi
if [[ "x$BACKUP_CROSS_SDK" != "x" ]]; then
    export CROSS_SDK="$BACKUP_CROSS_SDK"
fi
if [[ "x$BACKUP_CMAKE_OSX_SYSROOT" != "x" ]]; then
    export CMAKE_OSX_SYSROOT="$BACKUP_CMAKE_OSX_SYSROOT"
fi
if [[ "x$BACKUP_CMAKE_OSX_ARCHITECTURES" != "x" ]]; then
    export CMAKE_OSX_ARCHITECTURES="$BACKUP_CMAKE_OSX_ARCHITECTURES"
fi
if [[ "x$BACKUP_SYSROOT_DIR" != "x" ]]; then
    export SYSROOT_DIR="$BACKUP_SYSROOT_DIR"
fi
if [[ "x$BACKUP_LOCALBASE" != "x" ]]; then
    export LOCALBASE="$BACKUP_LOCALBASE"
fi
