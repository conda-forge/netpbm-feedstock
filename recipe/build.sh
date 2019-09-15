#!/bin/bash

if [ $(uname) = Linux ]
    then
        cp ${RECIPE_DIR}/config.mk.linux config.mk
fi

if [ $(uname) = Darwin ]
    then
        cp ${RECIPE_DIR}/config.mk.macos config.mk
fi

make
TMPDIR=`mktemp -d -u`
make package pkgdir=${TMPDIR}
make check
sed -i 's#/usr/bin/perl#/usr/bin/env perl#g' ${TMPDIR}/bin/*
cp -R ${TMPDIR}/bin ${TMPDIR}/lib ${TMPDIR}/include ${PREFIX}
