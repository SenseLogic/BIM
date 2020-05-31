/*
    This file is part of the Bim distribution.

    https://github.com/senselogic/BIM

    Copyright (C) 2020 Eric Pelzer (ecstatic.coder@gmail.com)

    Bim is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3.

    Bim is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Bim.  If not, see <http://www.gnu.org/licenses/>.
*/

// -- IMPORTS

import core.stdc.stdlib : exit;
import std.base64;
import std.conv : to;
import std.file : read, readText, write, FileException;
import std.stdio : writeln;
import std.string : endsWith, join, split, startsWith;

// -- VARIABLES

string
    InputMediaFolderPath,
    OutputMediaFolderPath;

// -- FUNCTIONS

void PrintError(
    string message
    )
{
    writeln( "*** ERROR : ", message );
}

// ~~

void Abort(
    string message
    )
{
    PrintError( message );

    exit( -1 );
}

// ~~

void Abort(
    string message,
    FileException file_exception
    )
{
    PrintError( message );
    PrintError( file_exception.msg );

    exit( -1 );
}

// ~~

ubyte[] ReadByteArray(
    string file_path
    )
{
    ubyte[]
        file_byte_array;

    writeln( "Reading file : ", file_path );

    try
    {
        file_byte_array = cast( ubyte[] )file_path.read();
    }
    catch ( FileException file_exception )
    {
        Abort( "Can't read file : " ~ file_path, file_exception );
    }

    return file_byte_array;
}

// ~~

void WriteByteArray(
    string file_path,
    ubyte[] file_byte_array
    )
{
    writeln( "Writing file : ", file_path );

    try
    {
        file_path.write( file_byte_array );
    }
    catch ( FileException file_exception )
    {
        Abort( "Can't write file : " ~ file_path, file_exception );
    }
}

// ~~

string ReadText(
    string file_path
    )
{
    string
        file_text;

    writeln( "Reading file : ", file_path );

    try
    {
        file_text = file_path.readText();
    }
    catch ( FileException file_exception )
    {
        Abort( "Can't read file : " ~ file_path, file_exception );
    }

    return file_text;
}

// ~~

void WriteText(
    string file_path,
    string file_text
    )
{
    writeln( "Writing file : ", file_path );

    try
    {
        file_path.write( file_text );
    }
    catch ( FileException file_exception )
    {
        Abort( "Can't write file : " ~ file_path, file_exception );
    }
}

// ~~

string GetEncodedFileText(
    string file_path
    )
{
    return Base64.encode( ReadByteArray( file_path ) );
}

// ~~

ubyte[] GetDecodedFileByteArray(
    string file_path
    )
{
    string
        file_text;

    file_text = ReadText( file_path );

    if ( file_text.startsWith( "data:image/jpeg;base64," ) )
    {
        file_text = file_text[ 23 .. $ ];
    }
    else if ( file_text.startsWith( "data:image/png;base64," ) )
    {
        file_text = file_text[ 22 .. $ ];
    }

    return Base64.decode( file_text );
}

// ~~

string GetEncodedImageFileText(
    string image_file_path
    )
{
    if ( image_file_path.endsWith( ".jpg" )
         || image_file_path.endsWith( ".jpeg" ) )
    {
        return "data:image/jpeg;base64," ~ GetEncodedFileText( image_file_path );
    }
    else if ( image_file_path.endsWith( ".png" ) )
    {
        return "data:image/png;base64," ~ GetEncodedFileText( image_file_path );
    }
    else
    {
        return image_file_path;
    }
}

// ~~

string GetEncodedDocumentFileText(
    string document_file_path
    )
{
    long
        section_index;
    string
        document_file_text;
    string[]
        part_array,
        section_array;

    document_file_text = ReadText( document_file_path );

    section_array = document_file_text.split( "src=\"" );

    for ( section_index = 1;
          section_index < section_array.length;
          ++section_index )
    {
        part_array = section_array[ section_index ].split( '"' );

        if ( part_array.length > 0 )
        {
            part_array[ 0 ] = GetEncodedImageFileText( InputMediaFolderPath ~ part_array[ 0 ] );
            section_array[ section_index ] = part_array.join( '"' );
        }
    }

    return section_array.join( "src=\"" );
}

// ~~

void EncodeFile(
    string input_file_path,
    string output_file_path
    )
{
    WriteText( output_file_path, GetEncodedFileText( input_file_path ) );
}

// ~~

void DecodeFile(
    string input_file_path,
    string output_file_path
    )
{
    WriteByteArray( output_file_path, GetDecodedFileByteArray( input_file_path ) );
}

// ~~

void EncodeImage(
    string input_file_path,
    string output_file_path
    )
{
    WriteText( output_file_path, GetEncodedImageFileText( input_file_path ) );
}

// ~~

void EncodeDocument(
    string input_file_path,
    string output_file_path
    )
{
    WriteText( output_file_path, GetEncodedDocumentFileText( input_file_path ) );
}

// ~~

void main(
    string[] argument_array
    )
{
    argument_array = argument_array[ 1 .. $ ];

    InputMediaFolderPath = "";
    OutputMediaFolderPath = "";

    if ( argument_array.length >= 2
         && argument_array[ 0 ] == "--media-folder"
         && argument_array[ 1 ].endsWith( '/' ) )
    {
        InputMediaFolderPath = argument_array[ 1 ];
        OutputMediaFolderPath = argument_array[ 1 ];

        argument_array = argument_array[ 2 .. $ ];
    }
    else if ( argument_array.length >= 2
         && argument_array[ 0 ] == "--input-media-folder"
         && argument_array[ 1 ].endsWith( '/' ) )
    {
        InputMediaFolderPath = argument_array[ 1 ];

        argument_array = argument_array[ 2 .. $ ];
    }
    else if ( argument_array.length >= 2
         && argument_array[ 0 ] == "--output-media-folder"
         && argument_array[ 1 ].endsWith( '/' ) )
    {
        OutputMediaFolderPath = argument_array[ 1 ];

        argument_array = argument_array[ 2 .. $ ];
    }
    else if ( argument_array.length >= 3
         && argument_array[ 0 ] == "--encode-file" )
    {
        EncodeFile(
            InputMediaFolderPath ~ argument_array[ 1 ],
            OutputMediaFolderPath ~ argument_array[ 2 ]
            );

        argument_array = argument_array[ 3 .. $ ];
    }
    else if ( argument_array.length >= 3
              && ( argument_array[ 0 ] == "--decode-file"
                   || argument_array[ 0 ] == "--decode-image" ) )
    {
        DecodeFile(
            InputMediaFolderPath ~ argument_array[ 1 ],
            OutputMediaFolderPath ~ argument_array[ 2 ]
            );

        argument_array = argument_array[ 3 .. $ ];
    }
    else if ( argument_array.length >= 3
              && argument_array[ 0 ] == "--encode-image" )
    {
        EncodeImage(
            InputMediaFolderPath ~ argument_array[ 1 ],
            OutputMediaFolderPath ~ argument_array[ 2 ]
            );

        argument_array = argument_array[ 3 .. $ ];
    }
    else if ( argument_array.length >= 3
              && argument_array[ 0 ] == "--encode-document" )
    {
        EncodeDocument(
            argument_array[ 1 ],
            argument_array[ 2 ]
            );

        argument_array = argument_array[ 3 .. $ ];
    }
    else
    {
        writeln( "Usage :" );
        writeln( "    bim <options>" );
        writeln( "Examples :" );
        writeln( "    bim --encode-file file.bin file.bin.b64" );
        writeln( "    bim --decode-file file.bin.b64 file.bin" );
        writeln( "    bim --encode-image image.jpg image.jpg.b64" );
        writeln( "    bim --decode-image image.jpg.b64 image.jpg" );
        writeln( "    bim --encode-image image.png image.png.b64" );
        writeln( "    bim --decode-image image.png.b64 image.png" );
        writeln( "    bim --encode-document document.html mail.html" );
        writeln( "    bim --media-folder MEDIA_FOLDER/ --encode-document document.html mail.html" );

        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
