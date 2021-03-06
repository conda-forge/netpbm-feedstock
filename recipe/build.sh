#!/bin/bash

pkgdir=`mktemp -d -u`

if [ $(uname) = Linux ]
    then
        cp ${RECIPE_DIR}/config.mk.linux config.mk
fi

if [ $(uname) = Darwin ]
    then
        cp ${RECIPE_DIR}/config.mk.macos config.mk
fi

sed -i 's|misc|share/netpbm|' common.mk
sed -i 's|/link|/lib|' lib/Makefile
sed -i "s|/tmp/netpbm|${pkgdir}|" config.mk
sed -i 's|install.manwebmain install.manweb install.man|install.man|' GNUmakefile

make
make package pkgdir=${pkgdir} PKGMANDIR="share/man" install-run install-dev
sed -i 's#/usr/bin/perl#/usr/bin/env perl#g' ${pkgdir}/bin/*

# Copy files to prefix
cp -rf $pkgdir/bin $PREFIX
cp -rf $pkgdir/lib $PREFIX
cp -rf $pkgdir/share $PREFIX
cp -rf $pkgdir/include $PREFIX

VERSION=`cat "${pkgdir}/VERSION"`
DATADIR=$PREFIX/share/netpbm
LINKDIR=$PREFIX/lib
INCLUDEDIR=$PREFIX/include
BINDIR=$PREFIX/bin

# Config program
conf_temp="buildtools/config_template"
sed -i "s|@VERSION@|$VERSION|" $conf_temp
sed -i "s|@DATADIR@|$DATADIR|" $conf_temp
sed -i "s|@BINDIR@|$BINDIR|" $conf_temp
sed -i "s|@LINKDIR@|$LINKDIR|" $conf_temp
sed -i "s|@INCLUDEDIR@|$INCLUDEDIR|" $conf_temp
cp -r $conf_temp $PREFIX/bin/netpbm-config

# pkgconfig 
pkgconf="buildtools/pkgconfig_template"
sed -i "s|@VERSION@|$VERSION|" $pkgconf
sed -i "s|@LINKDIR@|$LINKDIR|" $pkgconf
sed -i "s|@INCLUDEDIR@|$INCLUDEDIR|" $pkgconf
cp -f $pkgconf $PKG_CONFIG_PATH/netpbm.pc
