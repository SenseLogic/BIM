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
import std.file : read, readText, write;
import std.stdio : writeln;
import std.string : endsWith, indexOf, join, replace, split, startsWith;

// -- VARIABLES

string
    InputMediaFolderPath,
    OutputMediaFolderPath,
    OutputMediaPrefix;

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
    Exception exception
    )
{
    PrintError( message );
    PrintError( exception.msg );

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
    catch ( Exception exception )
    {
        Abort( "Can't read file : " ~ file_path, exception );
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
    catch ( Exception exception )
    {
        Abort( "Can't write file : " ~ file_path, exception );
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
    catch ( Exception exception )
    {
        Abort( "Can't read file : " ~ file_path, exception );
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
    catch ( Exception exception )
    {
        Abort( "Can't write file : " ~ file_path, exception );
    }
}

// ~~

string GetFileLabel(
    string file_path
    )
{
    string
        file_name;

    file_name = file_path.replace( '\\', '/' ).split( '/' )[ $ - 1 ];

    if ( file_name.indexOf( '.' ) >= 0 )
    {
        return file_name.split( '.' )[ $ - 2 ];
    }
    else
    {
        return file_name;
    }
}

// ~~

ubyte[] GetDecodedByteArray(
    string text
    )
{
    return Base64.decode( text );
}

// ~~

string GetEncodedText(
    ubyte[] byte_array
    )
{
    return Base64.encode( byte_array );
}

// ~~

string GetEncodedFileText(
    string file_path
    )
{
    return GetEncodedText( ReadByteArray( file_path ) );
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

    return GetDecodedByteArray( file_text );
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

string GetDecodedDocumentFileText(
    string document_file_path
    )
{
    long
        image_index,
        section_index;
    string
        document_file_text,
        image_extension,
        image_prefix;
    string[]
        image_extension_array,
        image_prefix_array,
        part_array,
        section_array;
    ubyte[]
        image_file_byte_array;

    if ( OutputMediaPrefix == "" )
    {
        OutputMediaPrefix = GetFileLabel( document_file_path ) ~ '_';
    }

    document_file_text = ReadText( document_file_path );

    image_prefix_array = [ "data:image/jpeg;base64,", "data:image/png;base64," ];
    image_extension_array = [ ".jpg", ".png" ];
    image_index = 0;

    foreach ( image_format_index; 0 .. 2 )
    {
        image_prefix = image_prefix_array[ image_format_index ];
        image_extension = image_extension_array[ image_format_index ];

        section_array = document_file_text.split( image_prefix );

        for ( section_index = 1;
              section_index < section_array.length;
              ++section_index )
        {
            part_array = section_array[ section_index ].split( '"' );

            if ( part_array.length > 0 )
            {
                ++image_index;
                image_file_byte_array = GetDecodedByteArray( part_array[ 0 ] );
                part_array[ 0 ] = OutputMediaPrefix ~ image_index.to!string() ~ image_extension;
                section_array[ section_index ] = part_array.join( '"' );
                WriteByteArray( OutputMediaFolderPath ~ part_array[ 0 ], image_file_byte_array );
            }
        }

        document_file_text = section_array.join( "" );
    }

    return document_file_text;
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

void DecodeDocument(
    string input_file_path,
    string output_file_path
    )
{
    WriteText( output_file_path, GetDecodedDocumentFileText( input_file_path ) );
}

// ~~

void main(
    string[] argument_array
    )
{
    string
        option;

    argument_array = argument_array[ 1 .. $ ];

    InputMediaFolderPath = "";
    OutputMediaFolderPath = "";
    OutputMediaPrefix = "";

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];
        argument_array = argument_array[ 1 .. $ ];

        if ( option == "--media-folder"
             && argument_array.length >= 1
             && argument_array[ 0 ].endsWith( '/' ) )
        {
            InputMediaFolderPath = argument_array[ 0 ];
            OutputMediaFolderPath = argument_array[ 0 ];

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--input-media-folder"
                  && argument_array.length >= 1
                  && argument_array[ 0 ].endsWith( '/' ) )
        {
            InputMediaFolderPath = argument_array[ 0 ];

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--output-media-folder"
                  && argument_array.length >= 1
                  && argument_array[ 0 ].endsWith( '/' ) )
        {
            OutputMediaFolderPath = argument_array[ 0 ];

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--media-prefix"
                  && argument_array.length >= 1 )
        {
            OutputMediaPrefix = argument_array[ 0 ];

            argument_array = argument_array[ 1 .. $ ];
        }
        else if ( option == "--encode-file"
                  && argument_array.length >= 2 )
        {
            EncodeFile(
                InputMediaFolderPath ~ argument_array[ 0 ],
                OutputMediaFolderPath ~ argument_array[ 1 ]
                );

            argument_array = argument_array[ 2 .. $ ];
        }
        else if ( ( option == "--decode-file"
                       || option == "--decode-image" )
                  && argument_array.length >= 2 )
        {
            DecodeFile(
                InputMediaFolderPath ~ argument_array[ 0 ],
                OutputMediaFolderPath ~ argument_array[ 1 ]
                );

            argument_array = argument_array[ 2 .. $ ];
        }
        else if ( option == "--encode-image"
                  && argument_array.length >= 2 )
        {
            EncodeImage(
                InputMediaFolderPath ~ argument_array[ 0 ],
                OutputMediaFolderPath ~ argument_array[ 1 ]
                );

            argument_array = argument_array[ 2 .. $ ];
        }
        else if ( option == "--encode-document"
                  && argument_array.length >= 2 )
        {
            EncodeDocument(
                argument_array[ 0 ],
                argument_array[ 1 ]
                );

            argument_array = argument_array[ 2 .. $ ];
        }
        else if ( option == "--decode-document"
                  && argument_array.length >= 2 )
        {
            DecodeDocument(
                argument_array[ 0 ],
                argument_array[ 1 ]
                );

            argument_array = argument_array[ 2 .. $ ];
        }
        else
        {
            break;
        }
    }

    if ( argument_array.length > 0 )
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
        writeln( "    bim --encode-document mail.html inline_mail.html" );
        writeln( "    bim --media-folder MEDIA_FOLDER/ --encode-document mail.html inline_mail.html" );
        writeln( "    bim --media-folder MEDIA_FOLDER/ --decode-document inline_mail.html mail.html" );

        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
