#!/bin/bash

TMPDIR=`mktemp -d -u`

if [ $(uname) = Linux ]
    then
        cp ${RECIPE_DIR}/config.mk.linux config.mk
fi

if [ $(uname) = Darwin ]
    then
        cp ${RECIPE_DIR}/config.mk.macos config.mk
fi

make
make package pkgdir=${TMPDIR}
sed -i 's#/usr/bin/perl#/usr/bin/env perl#g' ${TMPDIR}/bin/*
./installnetpbm
