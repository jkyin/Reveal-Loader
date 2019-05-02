#!/bin/bash
set -e

./release.sh

cp -i -R $(< .theos/last_package) ../cydia/debs/
cp -i -R ./releases/Packages.* ../cydia/
cp -i -R ./releases/Release ../cydia/
cp -i -R ./releases/Packages ../cydia/
