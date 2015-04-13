library libarchive;

{$mode objfpc}{$H+}

uses
  Classes, ArchiveFunc
  { you can add units after this };

exports
  { Mandatory }
  OpenArchive,
  ReadHeader,
  ReadHeaderEx,
  ProcessFile,
  CloseArchive,
  SetChangeVolProc,
  SetProcessDataProc;

begin
end.

