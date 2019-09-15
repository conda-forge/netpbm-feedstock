#!/bin/bash

if [ ${SHLIB_EXT} == '.so' ]
    then
        cp ${RECIPE_DIR}/config.mk.linux config.mk
fi

if [ ${SHLIB_EXT} == '.dylib' ]
    then
        # cp ${RECIPE_DIR}/config.mk.osx config.mk
        echo 'Mac not supported yet.'
        exit 1
fi

make
TMPDIR=`mktemp -d -u`
make package pkgdir=${TMPDIR}
make check
sed -i 's#/usr/bin/perl#/usr/bin/env perl#g' ${TMPDIR}/bin/*
cp -R ${TMPDIR}/bin ${TMPDIR}/lib ${TMPDIR}/include ${PREFIX}
