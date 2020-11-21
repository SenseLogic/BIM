#!/bin/sh
set -x
../bim --encode-file IN/road.jpg OUT/road.jpg.b64
../bim --decode-file OUT/road.jpg.b64 OUT/road.jpg
../bim --encode-file IN/river.png OUT/river.png.b64
../bim --decode-file OUT/river.png.b64 OUT/river.png
../bim --encode-image IN/sea.jpg OUT/sea.jpg.b64
../bim --decode-image OUT/sea.jpg.b64 OUT/sea.jpg
../bim --encode-image IN/street.png OUT/street.png.b64
../bim --decode-image OUT/street.png.b64 OUT/street.png
../bim --media-folder IN/ --encode-document IN/mail.html OUT/inline_mail.html
../bim --media-folder OUT/ --decode-document IN/inline_mail.html OUT/mail.html
