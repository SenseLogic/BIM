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

bool
    DecodeCharactersOptionIsEnabled,
    EncodeCharactersOptionIsEnabled;
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

string EncodeCharacters(
    string text
    )
{
    dstring
        unicode_text;

    foreach ( unicode_character; text.to!dstring() )
    {
        if ( unicode_character < 128 )
        {
            unicode_text ~= unicode_character;
        }
        else
        {
            unicode_text ~= ( "&#" ~ unicode_character.to!ulong().to!string() ~ ";" ).to!dstring();
        }
    }

    return unicode_text.to!string();
}

// ~~

string DecodeCharacters(
    string text
    )
{
    dchar[ 1 ]
        unicode_character_array;
    long
        digit_character_index,
        part_index;
    string
        part;
    string[]
        part_array;

    part_array = text.split( "&#" );

    for ( part_index = 1;
          part_index < part_array.length;
          ++part_index )
    {
        part = part_array[ part_index ];
        unicode_character_array[ 0 ] = 0;

        for ( digit_character_index = 0;
              digit_character_index < part.length
              && ( part[ digit_character_index ] >= '0'
                   && part[ digit_character_index ] <= '9' );
              ++digit_character_index )
        {
            unicode_character_array[ 0 ]
                = unicode_character_array[ 0 ] * 10 + ( part[ digit_character_index ] - '0' );
        }

        if ( digit_character_index > 0
             && digit_character_index < part.length
             && part[ digit_character_index ] == ';' )
        {
            part_array[ part_index ]
                = unicode_character_array.to!dstring().to!string()
                  ~ part_array[ part_index ][ digit_character_index + 1 .. $ ];
        }
        else
        {
            part_array[ part_index ] = "&#" ~ part_array[ part_index ];
        }
    }

    return part_array.join( "" );
}

// ~~

string ProcessCharacters(
    string text
    )
{

    if ( EncodeCharactersOptionIsEnabled )
    {
        return EncodeCharacters( text );
    }
    else if ( DecodeCharactersOptionIsEnabled )
    {
        return DecodeCharacters( text );
    }
    else
    {
        return text;
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
    else if ( file_text.startsWith( "data:image/gif;base64," ) )
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
    else if ( image_file_path.endsWith( ".gif" ) )
    {
        return "data:image/gif;base64," ~ GetEncodedFileText( image_file_path );
    }
    else
    {
        return image_file_path;
    }
}

// ~~

string GetEncodedDocumentFileText(
    string document_file_text,
    string image_file_path_prefix,
    string image_file_path_suffix
    )
{
    long
        section_index;
    string[]
        part_array,
        section_array;

    section_array = document_file_text.split( image_file_path_prefix );

    for ( section_index = 1;
          section_index < section_array.length;
          ++section_index )
    {
        part_array = section_array[ section_index ].split( image_file_path_suffix );

        if ( part_array.length > 0 )
        {
            part_array[ 0 ] = GetEncodedImageFileText( InputMediaFolderPath ~ part_array[ 0 ] );
            section_array[ section_index ] = part_array.join( image_file_path_suffix );
        }
    }

    return section_array.join( image_file_path_prefix );
}

// ~~

string GetEncodedDocumentFileText(
    string document_file_path
    )
{
    return
        ReadText( document_file_path )
            .GetEncodedDocumentFileText( "src=\"", "\"" )
            .GetEncodedDocumentFileText( "url('", "')" )
            .GetEncodedDocumentFileText( "url(\"", "\")" )
            .GetEncodedDocumentFileText( "url( '", "' )" )
            .GetEncodedDocumentFileText( "url( \"", "\" )" )
            .ProcessCharacters();
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

    image_prefix_array = [ "data:image/jpeg;base64,", "data:image/png;base64,", "data:image/gif;base64," ];
    image_extension_array = [ ".jpg", ".png", ".gif" ];
    image_index = 0;

    foreach ( image_format_index; 0 .. 3 )
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

    return document_file_text.ProcessCharacters();
}

// ~~

void EncodeDocumentCharacters(
    string input_file_path,
    string output_file_path
    )
{
    WriteText( output_file_path, EncodeCharacters( input_file_path.ReadText() ) );
}

// ~~

void DecodeDocumentCharacters(
    string input_file_path,
    string output_file_path
    )
{
    WriteText( output_file_path, DecodeCharacters( input_file_path.ReadText() ) );
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
    long
        argument_count;
    string
        option;

    InputMediaFolderPath = "";
    OutputMediaFolderPath = "";
    OutputMediaPrefix = "";
    EncodeCharactersOptionIsEnabled = false;
    DecodeCharactersOptionIsEnabled = false;

    argument_array = argument_array[ 1 .. $ ];

    while ( argument_array.length >= 1
            && argument_array[ 0 ].startsWith( "--" ) )
    {
        option = argument_array[ 0 ];

        argument_array = argument_array[ 1 .. $ ];
        argument_count = 0;

        while ( argument_count < argument_array.length
                && !argument_array[ argument_count ].startsWith( "--" ) )
        {
            ++argument_count;
        }

        if ( option == "--input-media-folder"
             && argument_count == 1
             && argument_array[ 0 ].endsWith( '/' ) )
        {
            InputMediaFolderPath = argument_array[ 0 ];
        }
        else if ( option == "--output-media-folder"
                  && argument_count == 1
                  && argument_array[ 0 ].endsWith( '/' ) )
        {
            OutputMediaFolderPath = argument_array[ 0 ];
        }
        else if ( option == "--media-prefix"
                  && argument_count == 1 )
        {
            OutputMediaPrefix = argument_array[ 0 ];
        }
        else if ( option == "--media-folder"
                  && argument_count == 1
                  && argument_array[ 0 ].endsWith( '/' ) )
        {
            InputMediaFolderPath = argument_array[ 0 ];
            OutputMediaFolderPath = argument_array[ 0 ];
        }
        else if ( option == "--encode-characters"
                  && argument_count == 0 )
        {
            EncodeCharactersOptionIsEnabled = true;
        }
        else if ( option == "--decode-characters"
                  && argument_count == 0 )
        {
            DecodeCharactersOptionIsEnabled = true;
        }
        else if ( option == "--encode-document-characters"
                  && argument_count == 2 )
        {
            EncodeDocumentCharacters(
                InputMediaFolderPath ~ argument_array[ 0 ],
                OutputMediaFolderPath ~ argument_array[ 1 ]
                );
        }
        else if ( option == "--decode-document-characters"
                  && argument_count == 2 )
        {
            DecodeDocumentCharacters(
                InputMediaFolderPath ~ argument_array[ 0 ],
                OutputMediaFolderPath ~ argument_array[ 1 ]
                );
        }
        else if ( option == "--encode-file"
                  && argument_count == 2 )
        {
            EncodeFile(
                InputMediaFolderPath ~ argument_array[ 0 ],
                OutputMediaFolderPath ~ argument_array[ 1 ]
                );
        }
        else if ( ( option == "--decode-file"
                       || option == "--decode-image" )
                  && argument_count == 2 )
        {
            DecodeFile(
                InputMediaFolderPath ~ argument_array[ 0 ],
                OutputMediaFolderPath ~ argument_array[ 1 ]
                );
        }
        else if ( option == "--encode-image"
                  && argument_count == 2 )
        {
            EncodeImage(
                InputMediaFolderPath ~ argument_array[ 0 ],
                OutputMediaFolderPath ~ argument_array[ 1 ]
                );
        }
        else if ( option == "--encode-document"
                  && argument_count == 2 )
        {
            EncodeDocument(
                argument_array[ 0 ],
                argument_array[ 1 ]
                );
        }
        else if ( option == "--decode-document"
                  && argument_count == 2 )
        {
            DecodeDocument(
                argument_array[ 0 ],
                argument_array[ 1 ]
                );
        }
        else
        {
            break;
        }

        argument_array = argument_array[ argument_count .. $ ];
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
        writeln( "    bim --media-folder MEDIA_FOLDER/ --encode-characters --encode-document mail.html inline_mail.html" );
        writeln( "    bim --media-folder MEDIA_FOLDER/ --decode-characters --decode-document inline_mail.html mail.html" );

        Abort( "Invalid arguments : " ~ argument_array.to!string() );
    }
}
