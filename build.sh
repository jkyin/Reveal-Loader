#!/bin/bash

make clean
make
make package
make install THEOS_DEVICE_IP=192.168.0.99
