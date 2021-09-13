![](https://github.com/senselogic/BIM/blob/master/LOGO/bim.png)

# Bim

Base64 document encoder and decoder.

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (using the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 bim.d
```

## Command line

```bash
bim <options>
```

### Options

```bash
--media-folder : use this folder to read and write media files
--input-media-folder : use this folder to read media files
--output-media-folder : use this folder to write media files
--encode-file : encode a Base64 file
--decode-file : encode a Base64 file
--encode-image : encode a Base64 image
--decode-image : decode a Base64 image
--encode-document : encode a Base64 document
--decode-document : decode a Base64 document
```

### Examples

```bash
bim --encode-file file.bin file.bin.b64
bim --decode-file file.bin.b64 file.bin
bim --encode-image image.jpg image.jpg.b64
bim --decode-image image.jpg.b64 image.jpg
bim --encode-image image.png image.png.b64
bim --decode-image image.png.b64 image.png
bim --encode-image image.gif image.gif.b64
bim --decode-image image.gif.b64 image.gif
bim --encode-document mail.html inline_mail.html
bim --media-folder MEDIA_FOLDER/ --encode-document mail.html inline_mail.html
bim --media-folder MEDIA_FOLDER/ --encode-document inline_mail.html mail.html
```

## Version

1.0

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
