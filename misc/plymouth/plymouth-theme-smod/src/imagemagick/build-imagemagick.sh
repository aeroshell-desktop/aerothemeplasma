#!/bin/bash

# Based on the Arch Linux PKGBUILD from June 4th 2024
# https://gitlab.archlinux.org/archlinux/packaging/packages/imagemagick/-/raw/9ef4423e069818c51a4bcc0be0f1d9937e8991f1/PKGBUILD

IM="$(cat imagemagick-version.txt)"

function funcFetch()
{
    wget -c "https://imagemagick.org/archive/$IM.zip"
    unzip "$IM.zip"
}

function funcPatch()
{
    patch -p1 < ../imagemagick-bmp-fix.patch
}

function funcConfigure()
{
    ./configure \
        --prefix=/usr/local \
        --sysconfdir=/usr/local/etc \
        --enable-shared \
        --disable-static \
        --with-dejavu-font-dir=/usr/share/fonts/TTF \
        --with-gs-font-dir=/usr/share/fonts/gsfonts \
        PSDelegate=/usr/bin/gs \
        XPSDelegate=/usr/bin/gxps \
        PCLDelegate=/usr/bin/gpcl6 \
        --enable-hdri \
        --enable-opencl \
        --without-gslib \
        --with-djvu \
        --with-fftw \
        --with-jxl \
        --with-lqr \
        --with-modules \
        --with-openexr \
        --with-openjp2 \
        --with-perl \
        --with-perl-options='INSTALLDIRS=vendor INSTALL_BASE=' \
        --with-rsvg \
        --with-webp \
        --with-wmf \
        --with-xml \
        --without-autotrace \
        --without-dps \
        --without-fpx \
        --without-gcc-arch \
        --without-gvc
}

funcFetch

cd "$IM"

funcPatch
funcConfigure

make
