#!/bin/bash
set -e

if which dpkg >/dev/null; then
    make clean
    make
    make package

    cd releases

    dpkg-scanpackages debs | bzip2 -c > Packages.bz2
    dpkg-scanpackages debs | gzip -c > Packages.gz
    
    cd ../../cydia

    dpkg-scanpackages -m debs >Packages
    bzip2 -zkf Packages

else
    echo "error: dpkg not installed, please \"brew install dpkg\""
    exit -1
fi
