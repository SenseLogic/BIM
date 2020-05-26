#!/bin/sh
set -x
dmd -m64 bim.d
rm *.o
