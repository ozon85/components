unit PortableDynLib;

interface

uses SysUtils,dynlibs;

const //https://wiki.freepascal.org/Lazarus/FPC_Libraries
  prefix={$IFDEF MSWINDOWS}'';{$ENDIF}{$IFNDEF MSWINDOWS}'lib';{$ENDIF}

{ there is no prefix 'lib' or suffix '.so' needed, only libcaption }
function FindAndLoadLibrary(libname:string):TLibHandle;

implementation

function FoundLib(var LibFolder:string;const libname:string):boolean;
begin
LibFolder:='.'+DirectorySeparator; //in current dir
if FileExists(LibFolder+libname)then exit(true);

LibFolder:=ExtractFilePath(paramStr(0)); //there is DirectorySeparator in windows and linux
if FileExists(LibFolder+libname) then exit(true); // in binary folder
exit(false);
end;


function FindAndLoadLibrary(libname:string):TLibHandle;
var TmpLibFolder:string='.'+DirectorySeparator;
begin
libname:=prefix+Libname+'.'+sharedsuffix;
  result:=SafeLoadLibrary(libname);
if (result=NilHandle) and FoundLib(TmpLibFolder,libname)then
    result:=SafeLoadLibrary(TmpLibFolder+libname);
end;


end.

