#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

pkgdir=`mktemp -d -u`

if [ $(uname) = Linux ]
    then
        cp ${RECIPE_DIR}/config.mk.linux config.mk
fi

if [ $(uname) = Darwin ]
    then
        cp ${RECIPE_DIR}/config.mk.macos config.mk
fi

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"

sed -i 's|misc|share/netpbm|' common.mk
sed -i 's|/link|/lib|' lib/Makefile
sed -i "s|/tmp/netpbm|${pkgdir}|" config.mk
sed -i 's|install.manwebmain install.manweb install.man|install.man|' GNUmakefile

if [[ ${build_platform} != ${target_platform} ]]; then
    CROSS_LDFLAGS=${LDFLAGS}
    CROSS_CC="${CC}"
    CROSS_LD="${LD}"

    LDFLAGS=${LDFLAGS//${PREFIX}/${BUILD_PREFIX}}
    CC=${CC//${CONDA_TOOLCHAIN_HOST}/${CONDA_TOOLCHAIN_BUILD}}
    LD="${LD//${CONDA_TOOLCHAIN_HOST}/${CONDA_TOOLCHAIN_BUILD}}"

    make -C $SRC_DIR/buildtools -f $SRC_DIR/buildtools/Makefile SRCDIR=$SRC_DIR BUILDDIR=$SRC_DIR/bootstrap typegen
    make -C $SRC_DIR/buildtools -f $SRC_DIR/buildtools/Makefile SRCDIR=$SRC_DIR BUILDDIR=$SRC_DIR/bootstrap endiangen

    LDFLAGS="${CROSS_LDFLAGS}"
    CC=${CROSS_CC}
    LD=${CROSS_LD}

    sed -i "s|\$(TYPEGEN) >\$@|${SRC_DIR}/bootstrap/buildtools/typegen >\$@|" GNUmakefile
    sed -i "s|\$(ENDIANGEN) >>\$@|${SRC_DIR}/bootstrap/buildtools/endiangen >>\$@|" GNUmakefile
fi

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
