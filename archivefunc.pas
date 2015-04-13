unit ArchiveFunc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, WcxPlugin;

function OpenArchive(var ArchiveData : tOpenArchiveData) : TArcHandle; cdecl;
function ReadHeader(hArcData : TArcHandle; var HeaderData: THeaderData) : Integer; cdecl;
function ReadHeaderEx(hArcData : TArcHandle; var HeaderData: THeaderDataEx) : Integer; cdecl;
function ProcessFile(hArcData : TArcHandle; Operation : Integer; DestPath, DestName : PChar) : Integer; cdecl;
function CloseArchive(hArcData : TArcHandle) : Integer; cdecl;

procedure SetChangeVolProc(hArcData : TArcHandle; pChangeVolProc : PChangeVolProc); cdecl;
procedure SetProcessDataProc(hArcData : TArcHandle; pProcessDataProc : TProcessDataProc); cdecl;

implementation

uses
  uArchive;

type
  TArchiveHandle = class
    Archive: PArchive;
    ArchiveEntry: PArchiveEntry;
  end;

function OpenArchive(var ArchiveData: tOpenArchiveData): TArcHandle; cdecl;
var
  Handle: TArchiveHandle;
begin
  Handle:= TArchiveHandle.Create;
  Handle.Archive:= archive_read_new();
  archive_read_support_filter_all(Handle.Archive);
  archive_read_support_format_all(Handle.Archive);
  archive_read_open_filename(Handle.Archive, ArchiveData.ArcName, 40960);

  Result:= TArcHandle(Handle);
end;

function ReadHeader(hArcData: TArcHandle; var HeaderData: THeaderData
  ): Integer; cdecl;
begin

end;

function ReadHeaderEx(hArcData: TArcHandle; var HeaderData: THeaderDataEx
  ): Integer; cdecl;
var
  FileSize: Int64;
  ArchiveEntry: PArchiveEntry;
  Handle: TArchiveHandle absolute hArcData;
begin
  Result:= archive_read_next_header(Handle.Archive, ArchiveEntry);
  if Result = ARCHIVE_EOF then Exit(E_NO_FILES);
  FileSize:= archive_entry_size(ArchiveEntry);
  HeaderData.UnpSize:= Int64Rec(FileSize).Lo;
  HeaderData.UnpSizeHigh:= Int64Rec(FileSize).Hi;
  HeaderData.FileAttr:= archive_entry_mode(ArchiveEntry);
  HeaderData.FileTime:= archive_entry_mtime(ArchiveEntry);
  HeaderData.FileName:= archive_entry_pathname(ArchiveEntry);
  Result:= E_SUCCESS;
end;

function ProcessFile(hArcData: TArcHandle; Operation: Integer; DestPath,
  DestName: PChar): Integer; cdecl;
var
  Handle: TArchiveHandle absolute hArcData;
begin
  Result:= E_SUCCESS;
  if Operation = PK_SKIP then
  archive_read_data_skip(Handle.Archive);


end;

function CloseArchive(hArcData: TArcHandle): Integer; cdecl;
var
  Handle: TArchiveHandle absolute hArcData;
begin
  archive_read_close(Handle.Archive);
  archive_read_free(Handle.Archive);
end;

procedure SetChangeVolProc(hArcData: TArcHandle; pChangeVolProc: PChangeVolProc
  ); cdecl;
begin

end;

procedure SetProcessDataProc(hArcData: TArcHandle;
  pProcessDataProc: TProcessDataProc); cdecl;
begin

end;

end.

