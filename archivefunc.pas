unit ArchiveFunc;

{$mode objfpc}{$H+}
{$I calling.inc}

interface

uses
  Classes, SysUtils, WcxPlugin;

function OpenArchive(var ArchiveData : tOpenArchiveData) : TArcHandle; dcpcall;
function ReadHeader(hArcData : TArcHandle; var HeaderData: THeaderData) : Integer; dcpcall;
function ReadHeaderEx(hArcData : TArcHandle; var HeaderData: THeaderDataEx) : Integer; dcpcall;
function ProcessFile(hArcData : TArcHandle; Operation : Integer; DestPath, DestName : PChar) : Integer; dcpcall;
function CloseArchive(hArcData : TArcHandle) : Integer; dcpcall;

procedure SetChangeVolProc(hArcData : TArcHandle; pChangeVolProc : PChangeVolProc); dcpcall;
procedure SetProcessDataProc(hArcData : TArcHandle; pProcessDataProc : TProcessDataProc); dcpcall;

implementation

uses
  CTypes, uArchive, DCFileAttributes, DCDateTimeUtils, DCOSUtils, Windows;

threadvar
  ProcessDataProcT: TProcessDataProc;

type
  TArchiveHandle = class
    Archive: PArchive;
    ArchiveEntry: PArchiveEntry;
    ProcessDataProc: TProcessDataProc;
  end;

procedure GetFileName(FileName: PAnsiChar; var HeaderData: THeaderDataEx);
var
  Index: Integer = 0;
begin
  while (FileName[Index] <> #0) do
  begin
    if FileName[Index] = '/' then
      HeaderData.FileName[Index]:= PathDelim
    else begin
      HeaderData.FileName[Index]:= FileName[Index];
    end;
    Inc(Index);
  end;
  HeaderData.FileName[Index]:= #0;
end;

function GetFileTime(FileTime: PtrInt): PtrInt;
begin
  Result:= FileTime;;
  {$IFDEF MSWINDOWS}
   Result   := DateTimeToDosFileTime(UnixFileTimeToDateTime(Result));
  {$ENDIF}
end;

function OpenArchive(var ArchiveData: tOpenArchiveData): TArcHandle; dcpcall;
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
  ): Integer; dcpcall;
begin

end;

function ReadHeaderEx(hArcData: TArcHandle; var HeaderData: THeaderDataEx
  ): Integer; dcpcall;
var
  FileSize: Int64;
  FileName: PAnsiChar;
  Handle: TArchiveHandle absolute hArcData;
begin
  Result:= archive_read_next_header(Handle.Archive, Handle.ArchiveEntry);
  if Result = ARCHIVE_EOF then Exit(E_NO_FILES);
  FileSize:= archive_entry_size(Handle.ArchiveEntry);
  HeaderData.UnpSize:= Int64Rec(FileSize).Lo;
  HeaderData.UnpSizeHigh:= Int64Rec(FileSize).Hi;
  HeaderData.FileAttr:= UnixToWinFileAttr(archive_entry_mode(Handle.ArchiveEntry));
  HeaderData.FileTime:= GetFileTime(archive_entry_mtime(Handle.ArchiveEntry));
  FileName:= archive_entry_pathname(Handle.ArchiveEntry);
  GetFileName(FileName, HeaderData);
  Result:= E_SUCCESS;
end;

function ProcessFile(hArcData: TArcHandle; Operation: Integer; DestPath,
  DestName: PChar): Integer; dcpcall;
var
  Size: csize_t;
  Offset: cint64;
  FileHandle: PArchive;
  Buffer: PByte;
  FileName: PAnsiChar;
  Handle: TArchiveHandle absolute hArcData;
begin
  Result:= E_SUCCESS;
  case Operation of
    PK_SKIP: archive_read_data_skip(Handle.Archive);
    PK_EXTRACT:
      begin
        FileHandle:= archive_write_disk_new();
        if FileHandle = nil then Exit(E_NO_MEMORY);
        WriteLn('1');
        //archive_write_open_filename(FileHandle, PAnsiChar(String(DestPath) + String(DestName)));
                WriteLn('2');
        try
          FileName:= PAnsiChar(String(DestPath) + String(DestName));
          archive_entry_set_pathname(Handle.ArchiveEntry, FileName);
          archive_write_header(FileHandle, Handle.ArchiveEntry);
                  WriteLn('3');
          repeat
            WriteLn('3/1');
            Result:= archive_read_data_block(Handle.Archive, @Buffer, @size, @Offset);
            WriteLn('4');
            if (Result = ARCHIVE_EOF) then
            begin
              WriteLn('4/1');
              if archive_write_finish_entry(FileHandle) = ARCHIVE_OK then
                Exit(E_SUCCESS)
              else begin
                Exit(E_EWRITE);
              end;

            end;
            if (Result <> ARCHIVE_OK) then Exit(E_EREAD);
            Result:= archive_write_data_block(FileHandle, buffer, Size, Offset);
                        WriteLn('5');
            if (Result <> ARCHIVE_OK) then Exit(E_EWRITE);
            Handle.ProcessDataProc(FileName, Size);
          until False;
        finally
          //WriteLn('5.1 ', archive_error_string(FileHandle));
          //Offset:= achive_write_free(FileHandle);
          WriteLn('6');
        end;
        Offset:= achive_write_free(FileHandle);
        WriteLn('7');
        if Offset <> ARCHIVE_OK then Result:= E_ECLOSE;
      end;
  end;
end;

function CloseArchive(hArcData: TArcHandle): Integer; dcpcall;
var
  Handle: TArchiveHandle absolute hArcData;
begin
  archive_read_close(Handle.Archive);
  archive_read_free(Handle.Archive);
end;

procedure SetChangeVolProc(hArcData: TArcHandle; pChangeVolProc: PChangeVolProc
  ); dcpcall;
begin

end;

procedure SetProcessDataProc(hArcData: TArcHandle; pProcessDataProc: TProcessDataProc); dcpcall;
var
  Handle: TArchiveHandle absolute hArcData;
begin
  if hArcData <> wcxInvalidHandle then
     Handle.ProcessDataProc := pProcessDataProc
  else begin
    ProcessDataProcT := pProcessDataProc;
  end;
end;

end.

