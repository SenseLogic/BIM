#!/bin/sh
set -x
../bim --encode-file road.jpg OUT/road.jpg.b64
../bim --decode-file OUT/road.jpg.b64 OUT/road.jpg
../bim --encode-file river.png OUT/river.png.b64
../bim --decode-file OUT/river.png.b64 OUT/river.png
../bim --encode-image sea.jpg OUT/sea.jpg.b64
../bim --decode-image OUT/sea.jpg.b64 OUT/sea.jpg
../bim --encode-image street.png OUT/street.png.b64
../bim --decode-image OUT/street.png.b64 OUT/street.png
../bim --encode-document document.html OUT/mail.html
