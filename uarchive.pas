unit uArchive;

{$mode delphi}

interface

uses
  Classes, SysUtils, CTypes, UnixType;

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
  archive_entry_mtime: function(archive_entry: PArchiveEntry): time_t; cdecl;
  archive_entry_mode: function(archive_entry: PArchiveEntry): mode_t; cdecl;
  archive_entry_size: function(archive_entry: PArchiveEntry): cint64; cdecl;

  archive_write_disk_new: function(): PArchive; cdecl;
  archive_write_header: function(archive: PArchive;
                                 archive_entry: PArchiveEntry): cint; cdecl;
  archive_read_data_block: function(archive: PArchive; const buff: PPointer;
                                    size: pcsize_t; offset: pcint64): cint; cdecl;
  archive_write_data_block: function(archive: PArchive; const buffer: Pointer;
                                    size: csize_t; offset: cint64): cint64; cdecl;
  //* Close the file and release most resources. */
  archive_read_close: function(archive: PArchive): cint; cdecl;
  //* Release all resources and destroy the object. */
  //* Note that archive_read_free will call archive_read_close for you. */
  archive_read_free: function(archive: PArchive): cint; cdecl;



implementation

uses
  DynLibs;

var
  libarchive: TLibHandle = NilHandle;

function Load: Boolean;
begin
  libarchive:= LoadLibrary('libarchive.so.13');
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


  end;
end;

initialization
Load;

end.

