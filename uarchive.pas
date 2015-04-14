unit uArchive;

{$mode delphi}

interface

uses
  Classes, SysUtils, CTypes;

const
  ARCHIVE_EOF    = 1;	  //* Found end of archive. */
  ARCHIVE_OK	 = 0;	  //* Operation was successful. */
  ARCHIVE_RETRY	 = (-10); //* Retry might succeed. */
  ARCHIVE_WARN	 = (-20); //* Partial success. */
  ARCHIVE_FAILED = (-25); //* Current operation cannot complete. */
  ARCHIVE_FATAL	 = (-30); //* No more operations are possible. */

type
  PArchive = ^TArchive;
  TArchive = record end;
  PArchiveEntry = ^TArchiveEntry;
  TArchiveEntry = record end;

var
  archive_read_new: function(): PArchive; cdecl;
  archive_read_support_filter_all: function(archive: PArchive): cint; cdecl;
  archive_read_support_format_all: function(archive: PArchive): cint; cdecl;
  archive_read_open_filename: function(archive: PArchive;
  		     const _filename: PAnsiChar; _block_size: csize_t): cint; cdecl;
  //* Parses and returns next entry header. */
  archive_read_next_header: function(archive: PArchive;
                     		     var archive_entry: PArchiveEntry): cint; cdecl;
  archive_read_data_skip: function(archive: PArchive): cint; cdecl;

  archive_entry_pathname: function(archive_entry: PArchiveEntry): PAnsiChar; cdecl;
  archive_entry_mtime: function(archive_entry: PArchiveEntry): ptrint; cdecl;
  archive_entry_mode: function(archive_entry: PArchiveEntry): longword; cdecl;
  archive_entry_size: function(archive_entry: PArchiveEntry): cint64; cdecl;

  archive_write_disk_new: function(): PArchive; cdecl;
  archive_write_open_filename: function(archive: PArchive;
                                        const file_name: PAnsiChar): cint; cdecl;
  archive_write_header: function(archive: PArchive;
                                 archive_entry: PArchiveEntry): cint; cdecl;
  archive_write_finish_entry: function(archive: PArchive): cint; cdecl;
  archive_read_data_block: function(archive: PArchive; const buff: PPointer;
                                    size: pcsize_t; offset: pcint64): cint; cdecl;
  archive_write_data_block: function(archive: PArchive; const buffer: PByte;
                                    size: csize_t; offset: cint64): cint64; cdecl;
  achive_write_free: function(archive: PArchive): cint; cdecl;
  //* Close the file and release most resources. */
  archive_read_close: function(archive: PArchive): cint; cdecl;
  //* Release all resources and destroy the object. */
  //* Note that archive_read_free will call archive_read_close for you. */
  archive_read_free: function(archive: PArchive): cint; cdecl;

  archive_error_string: function(archive: PArchive): PAnsiChar; cdecl;
  archive_entry_set_pathname: procedure(archive_entry: PArchiveEntry; const file_name: PAnsiChar); cdecl;



implementation

uses
  DynLibs, Windows;

var
  libarchive: TLibHandle = NilHandle;

function Load: Boolean;
begin
  libarchive:= LoadLibrary('libarchive-13.dll');
  Result:= libarchive <> NilHandle;
  if Result then
  begin
    @archive_read_new:= GetProcAddress(libarchive, 'archive_read_new');
    @archive_read_support_filter_all:= GetProcAddress(libarchive, 'archive_read_support_filter_all');
    @archive_read_support_format_all:= GetProcAddress(libarchive, 'archive_read_support_format_all');
    @archive_read_open_filename:= GetProcAddress(libarchive, 'archive_read_open_filename');
    @archive_read_next_header:= GetProcAddress(libarchive, 'archive_read_next_header');
    @archive_read_data_skip:= GetProcAddress(libarchive, 'archive_read_data_skip');
    @archive_entry_pathname:= GetProcAddress(libarchive, 'archive_entry_pathname');
    @archive_entry_mtime:= GetProcAddress(libarchive, 'archive_entry_mtime');
    @archive_entry_mode:= GetProcAddress(libarchive, 'archive_entry_mode');
    @archive_entry_size:= GetProcAddress(libarchive, 'archive_entry_size');
    @archive_read_close:= GetProcAddress(libarchive, 'archive_read_close');
    @archive_read_free:= GetProcAddress(libarchive, 'archive_read_free');
    @archive_read_data_block:= GetProcAddress(libarchive, 'archive_read_data_block');
    @archive_write_data_block:= GetProcAddress(libarchive, 'archive_write_data_block');
    @archive_write_open_filename:= GetProcAddress(libarchive, 'archive_write_open_filename');
    @archive_write_header:= GetProcAddress(libarchive, 'archive_write_header');
    @achive_write_free:= GetProcAddress(libarchive, 'achive_write_free');
    @archive_write_finish_entry:= GetProcAddress(libarchive, 'archive_write_finish_entry');
    @archive_write_disk_new:= GetProcAddress(libarchive, 'archive_write_disk_new');
    @archive_error_string:= GetProcAddress(libarchive, 'archive_error_string');
    @archive_entry_set_pathname:= GetProcAddress(libarchive, 'archive_entry_set_pathname');
  end;
end;

initialization
Load;

end.

