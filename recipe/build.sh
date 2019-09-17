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

if [ $(uname) = Linux ]
    then
        cp -rf $pkgdir/bin $PREFIX
        cp -rf $pkgdir/lib $PREFIX
        cp -rf $pkgdir/share $PREFIX
        cp -rf $pkgdir/include $PREFIX
fi

if [ $(uname) = Darwin ]
    then
        cp -rf $pkgdir/bin $PREFIX
        cp -rf $pkgdir/lib $PREFIX
        cp -rf $pkgdir/share $PREFIX
        cp -rf $pkgdir/include $PREFIX
        for b in $PREFIX/bin/*
        do
            install_name_tool -change /libnetpbm.11.dylib $PREFIX/lib/libnetpbm.11.dylib $b
        done
fi
