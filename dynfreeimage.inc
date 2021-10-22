//types, defined in LCLtype for non lazarus compilation
//this types from original freeimage.pas - Delphi wrapper for freeimage library
type

LONG = LongInt;
DWORD = Cardinal;
PDWORD = ^DWORD;

RGBQUAD = packed record
   rgbBlue : BYTE;
   rgbGreen : BYTE;
   rgbRed : BYTE;
   rgbReserved : BYTE;
 end;
 tagRGBQUAD = RGBQUAD;
 TRGBQUAD = RGBQUAD;
 PRGBQUAD = ^RGBQUAD;

BITMAPINFOHEADER = packed record
    biSize : DWORD;
    biWidth : LONG;
    biHeight : LONG;
    biPlanes : WORD;
    biBitCount : WORD;
    biCompression : DWORD;
    biSizeImage : DWORD;
    biXPelsPerMeter : LONG;
    biYPelsPerMeter : LONG;
    biClrUsed : DWORD;
    biClrImportant : DWORD;
end;
  LPBITMAPINFOHEADER = ^BITMAPINFOHEADER;
  TBITMAPINFOHEADER = BITMAPINFOHEADER;
  PBITMAPINFOHEADER = ^BITMAPINFOHEADER;

BITMAPINFO = packed record
    bmiHeader : BITMAPINFOHEADER;
    bmiColors : array[0..0] of RGBQUAD;
  end;
LPBITMAPINFO = ^BITMAPINFO;
PBITMAPINFO = ^BITMAPINFO;
TBITMAPINFO = BITMAPINFO;

HBITMAP = type LongWord;
HWND = type LongWord;
HDC = type LongWord;
