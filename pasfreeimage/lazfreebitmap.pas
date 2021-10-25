unit LazFreeBitmap;

{ This unit is based on the original FreeBitmap.pas
from FreeImage Delphi Wrapper
http://www.tech-mash.narod.ru/
}

// Use at your own risk!

{
Added By Me:
TFreeBitmap.ConvertToRawBits, RescaleRect, Rescale,SwapChannels,SwapRedBlue,
CreateBitmaps, LoadFromFile, FromMultiImage
modified TFreeMultiBitmap.Create,Destroy,LoadFromStream,Rotate,SaveToStream,
GetLockedPageNumbers,IsPageLocked,GetLockedCount
look for more...}

{
 TO DO:
 TFreeBitmap.Load,TFreeBitmap.LoadU,TFreeMultiBitmap.Open
 have analys. Need to implement common method
 Need implement TFreeBitmap.FFromTFreeMultiBitmap when unlock, lock page
}

interface


uses
  DynFreeImage,SysUtils{fmOpenRead or fmShareDenyWrite},
  {$IFDEF LCL}
  Lcltype,LCLIntf,GraphType,
  {$ELSE}

  {$ENDIF}
  Classes;
{$ASSERTIONS ON}


type
  { TFreeObject }

  TFreeObject = class(TObject)
  public
    constructor Create;
    function IsValid: Boolean; virtual;
  end;

  { TFreeTag }

  TFreeTag = class(TFreeObject)
  private
    // fields
    FTag: PFITAG;

    // getters & setters
    function GetCount: Cardinal;
    function GetDescription: AnsiString;
    function GetID: Word;
    function GetKey: AnsiString;
    function GetLength: Cardinal;
    function GetTagType: FREE_IMAGE_MDTYPE;
    function GetValue: Pointer;
    procedure SetCount(const Value: Cardinal);
    procedure SetDescription(const Value: AnsiString);
    procedure SetID(const Value: Word);
    procedure SetKey(const Value: AnsiString);
    procedure SetLength(const Value: Cardinal);
    procedure SetTagType(const Value: FREE_IMAGE_MDTYPE);
    procedure SetValue(const Value: Pointer);
  public
    // construction & destruction
    constructor Create(ATag: PFITAG = nil); virtual;
    destructor Destroy; override;

    // methods
    function Clone: TFreeTag;
    function IsValid: Boolean; override;
    function ToString(Model: FREE_IMAGE_MDMODEL; Make: PAnsiChar = nil): AnsiString; reintroduce;

    // properties
    property Key: AnsiString read GetKey write SetKey;
    property Description: AnsiString read GetDescription write SetDescription;
    property ID: Word read GetID write SetID;
    property TagType: FREE_IMAGE_MDTYPE read GetTagType write SetTagType;
    property Count: Cardinal read GetCount write SetCount;
    property Length: Cardinal read GetLength write SetLength;
    property Value: Pointer read GetValue write SetValue;
    property Tag: PFITAG read FTag;
  end;

  { forward declarations }

  TFreeBitmap = class;
  TFreeMemoryIO = class;
  TFreeMultiBitmap = class;

  { TFreeBitmap }

  TFreeBitmapChangingEvent = procedure(Sender: TFreeBitmap; var OldDib, NewDib: PFIBITMAP; var Handled: Boolean) of object;

  TFreeBitmap = class(TFreeObject)
  private
    // fields
    FDib: PFIBITMAP;
    FOnChange: TNotifyEvent;
    FOnChanging: TFreeBitmapChangingEvent;
    //FLockedNumber:integer;//replace to FFromMultipage
    FFromMultipage:TFreeMultiBitmap;//by me unlocked pages should to be different
    procedure SetDib(Value: PFIBITMAP);
  protected
    function DoChanging(var OldDib, NewDib: PFIBITMAP): Boolean; dynamic;
    function Replace(NewDib: PFIBITMAP): Boolean; dynamic;
  public
    constructor Create(ImageType: FREE_IMAGE_TYPE = FIT_BITMAP; Width: Integer = 0; Height: Integer = 0; Bpp: Integer = 0);
    destructor Destroy; override;
    function SetSize(ImageType: FREE_IMAGE_TYPE; Width, Height, Bpp: Integer; RedMask: Cardinal = 0; GreenMask: Cardinal = 0; BlueMask: Cardinal = 0): Boolean;
    procedure Change; dynamic;
    procedure Assign(Source: TFreeBitmap);
    function CopySubImage(Left, Top, Right, Bottom: Integer; Dest: TFreeBitmap): Boolean;
    function PasteSubImage(Src: TFreeBitmap; Left, Top: Integer; Alpha: Integer = 256): Boolean;
    procedure Clear; virtual;
    function LoadFromFile(const FileName:string; Flag: Integer = 0): Boolean;
    function Load(const FileName: FreeImageAnsiString; Flag: Integer = 0): Boolean;
    function LoadU(const FileName: {$IFDEF DELPHI2010}string{$ELSE}WideString{$ENDIF}; Flag: Integer = 0): Boolean;
    function LoadFromHandle(IO: PFreeImageIO; Handle: fi_handle; Flag: Integer = 0): Boolean;
    function LoadFromMemory(MemIO: TFreeMemoryIO; Flag: Integer = 0): Boolean;
    function LoadFromStream(Stream: TStream; Flag: Integer = 0): Boolean;
    // save functions
    function CanSave(fif: FREE_IMAGE_FORMAT): Boolean;
    function Save(const FileName: FreeImageAnsiString; Flag: Integer = 0): Boolean;
    function SaveU(const FileName: {$IFDEF DELPHI2010}string{$ELSE}WideString{$ENDIF}; Flag: Integer = 0): Boolean;
    function SaveToHandle(fif: FREE_IMAGE_FORMAT; IO: PFreeImageIO; Handle: fi_handle; Flag: Integer = 0): Boolean;
    function SaveToMemory(fif: FREE_IMAGE_FORMAT; MemIO: TFreeMemoryIO; Flag: Integer = 0): Boolean;
    function SaveToStream(fif: FREE_IMAGE_FORMAT; Stream: TStream; Flag: Integer = 0): Boolean;
    // image information
    function GetImageType: FREE_IMAGE_TYPE;
    function GetWidth: Integer;
    function GetHeight: Integer;
    function GetScanWidth: Integer;
    function IsValid: Boolean; override;
    function GetInfo: PBitmapInfo;
    function GetInfoHeader: PBitmapInfoHeader;
    function GetImageSize: Cardinal;
    function GetBitsPerPixel: Integer;
    function GetLine: Integer;
    function GetHorizontalResolution: Double;
    function GetVerticalResolution: Double;
    procedure SetHorizontalResolution(Value: Double);
    procedure SetVerticalResolution(Value: Double);
    // palette operations
    function GetPalette: PRGBQUAD;
    function GetPaletteSize: Integer;
    function GetColorsUsed: Integer;
    function GetColorType: FREE_IMAGE_COLOR_TYPE;
    function IsGrayScale: Boolean;
    // pixels access
    function AccessPixels: PByte;
    function GetScanLine(ScanLine: Integer): PByte;
    function GetPixelIndex(X, Y: Cardinal; var Value: Byte): Boolean;
    function GetPixelColor(X, Y: Cardinal; var Value: RGBQUAD): Boolean;
    function SetPixelIndex(X, Y: Cardinal; var Value: Byte): Boolean;
    function SetPixelColor(X, Y: Cardinal; var Value: RGBQUAD): Boolean;
    // convertion
    function ConvertToStandardType(ScaleLinear: Boolean= True;Dest:TFreeBitmap=nil): Boolean;
    function ConvertToType(ImageType: FREE_IMAGE_TYPE; ScaleLinear: Boolean;Dest:TFreeBitmap=nil): Boolean;
    function Threshold(T: Byte;Dest:TFreeBitmap=nil): Boolean;
    function ConvertTo4Bits(Dest:TFreeBitmap=nil): Boolean;
    function ConvertTo8Bits(Dest:TFreeBitmap=nil): Boolean;
    function ConvertTo16Bits555(Dest:TFreeBitmap=nil): Boolean;
    function ConvertTo16Bits565(Dest:TFreeBitmap=nil): Boolean;
    function ConvertTo24Bits(Dest:TFreeBitmap=nil): Boolean;
    function ConvertTo32Bits(Dest:TFreeBitmap=nil): Boolean;
    function ConvertToGrayscale(Dest:TFreeBitmap=nil): Boolean;
    procedure ConvertToRawBits(bits: PByte; pitch: Integer;
              bpp, red_mask, green_mask, blue_mask: Cardinal; topdown: LongBool = False);
    function ColorQuantize(Algorithm: FREE_IMAGE_QUANTIZE;Dest:TFreeBitmap=nil): Boolean;
    function Dither(Algorithm: FREE_IMAGE_DITHER;Dest:TFreeBitmap=nil): Boolean;
    function ConvertToRGBF(Dest:TFreeBitmap=nil): Boolean;
    function ToneMapping(TMO: FREE_IMAGE_TMO; FirstParam, SecondParam: Double;Dest:TFreeBitmap=nil): Boolean;
    // transparency
    function IsTransparent: Boolean;
    function GetTransparencyCount: Cardinal;
    function GetTransparencyTable: PByte;
    procedure SetTransparencyTable(Table: PByte; Count: Integer);
    function HasFileBkColor: Boolean;
    function GetFileBkColor(var BkColor: RGBQUAD): Boolean;
    function SetFileBkColor(BkColor: PRGBQuad): Boolean;
    // channel processing routines
    function GetChannel(Bitmap: TFreeBitmap; Channel: FREE_IMAGE_COLOR_CHANNEL): Boolean;
    function SetChannel(Bitmap: TFreeBitmap; Channel: FREE_IMAGE_COLOR_CHANNEL): Boolean;
    function SwapChannels(FirstChannel,SecondChannel:FREE_IMAGE_COLOR_CHANNEL):boolean;
    function SwapRedBlue: Boolean;
    function SplitChannels(RedChannel, GreenChannel, BlueChannel: TFreeBitmap): Boolean;
    function CombineChannels(Red, Green, Blue: TFreeBitmap): Boolean;
    // rotation and flipping
    function RotateEx(Angle, XShift, YShift, XOrigin, YOrigin: Double; UseMask: Boolean;
              Dest:TFreeBitmap=nil): Boolean;
    function Rotate(Angle90or180or270: Double;Dest:TFreeBitmap=nil): Boolean;
    function FlipHorizontal: Boolean;
    function FlipVertical: Boolean;
    // color manipulation routines
    function Invert: Boolean;
    function AdjustCurve(Lut: PByte; Channel: FREE_IMAGE_COLOR_CHANNEL): Boolean;
    function AdjustGamma(Gamma: Double): Boolean;
    function AdjustBrightness(Percentage: Double): Boolean;
    function AdjustContrast(Percentage: Double): Boolean;
    function GetHistogram(Histo: PDWORD; Channel: FREE_IMAGE_COLOR_CHANNEL = FICC_BLACK): Boolean;
    // upsampling / downsampling
    procedure MakeThumbnail(DestBitmap: TFreeBitmap;max_pixel_size:Integer;convert:Boolean=True);overload;
    procedure MakeThumbnail(const Width, Height: Integer; DestBitmap: TFreeBitmap);overload;
    function Rescale(NewWidth, NewHeight: Integer; Filter: FREE_IMAGE_FILTER = FILTER_CATMULLROM;
              Dest: TFreeBitmap = nil): Boolean;
    function RescaleRect(DestWidth,Destheight,Srcleft,Srctop,SrcRight,SrcBottom: Integer;
  filter: FREE_IMAGE_FILTER = FILTER_BOX;flags: Cardinal = 0;Dest:TFreeBitmap=nil): Boolean;
    // metadata routines
    function FindFirstMetadata(Model: FREE_IMAGE_MDMODEL; var Tag: TFreeTag): PFIMETADATA;
    function FindNextMetadata(MDHandle: PFIMETADATA; var Tag: TFreeTag): Boolean;
    procedure FindCloseMetadata(MDHandle: PFIMETADATA);
    function SetMetadata(Model: FREE_IMAGE_MDMODEL; const Key: AnsiString; Tag: TFreeTag): Boolean;
    function GetMetadata(Model: FREE_IMAGE_MDMODEL; const Key: AnsiString; var Tag: TFreeTag): Boolean;
    function GetMetadataCount(Model: FREE_IMAGE_MDMODEL): Cardinal;

    //Advanced for Lazarus
    {$IFDEF LCL}
    function CreateBitmaps(out ABitmap, AMask: HBitmap; ASkipMask: Boolean = False): Boolean;
    {$ENDIF}

    function FromMultiImage:boolean;
    // properties
    //property LockedNumber:integer read FLockedNumber;
    property Dib: PFIBITMAP read FDib write SetDib;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TFreeBitmapChangingEvent read FOnChanging write FOnChanging;
  end;


  { TFreeMemoryIO }

  TFreeMemoryIO = class(TFreeObject)
  private
    FHMem: PFIMEMORY;
  public
    // construction and destruction
    constructor Create(Data: PByte = nil; SizeInBytes: DWORD = 0);
    destructor Destroy; override;

    function GetFileType: FREE_IMAGE_FORMAT;
    function Read(fif: FREE_IMAGE_FORMAT; Flag: Integer = 0): PFIBITMAP;
    function ReadMultiBitmap(fif: FREE_IMAGE_FORMAT; Flag: Integer = 0): PFIMULTIBITMAP;
    function WriteMultiBitmap(fif: FREE_IMAGE_FORMAT; Mdib: PFIMULTIBITMAP;Flags: Integer = 0): Boolean;
    function Write(fif: FREE_IMAGE_FORMAT; dib: PFIBITMAP; Flag: Integer = 0): Boolean;
    function Tell: Longint;
    function Seek(Offset: Longint; Origin: Word): Boolean;
    function Acquire(var Data: PByte; var SizeInBytes: DWORD): Boolean;
    // overriden methods
    function IsValid: Boolean; override;
  end;

  { TFreeMultiBitmap }

  TFreeMultiBitmap = class(TFreeObject)
  private
    FOpenedFormat:FREE_IMAGE_FORMAT;//Added by me
    FMemIO: TFreeMemoryIO;
    MemStream: TMemoryStream;
    FMPage: PFIMULTIBITMAP;
    FMemoryCache,FReadOnly: Boolean;
    //LockedPages:TFPList;

  public
    // constructor and destructor
    constructor Create(KeepCacheInMemory: Boolean = true);
    constructor CreatEmpty(fif: FREE_IMAGE_FORMAT=FIF_TIFF;Flags: Integer=0);
    destructor Destroy; override;

    // methods
    function Open(const FileName: FreeImageAnsiString; CreateNew, ReadOnly: Boolean;
                 Flags: Integer = 0): Boolean;virtual;

    function LoadFromStream(Stream: TStream; Flags: Integer = 0): Boolean;
    function LoadFromMemory(MemIO: TFreeMemoryIO; Flag: Integer = 0): Boolean;virtual;
    function LoadFromHandle(IO: PFreeImageIO; Handle: fi_handle; Flags: Integer = 0): Boolean;virtual;
    function SaveToMemory(fif: FREE_IMAGE_FORMAT;MemIO:TFreeMemoryIO; flags: Integer=0): Boolean;virtual;
    function SaveToStream(fif: FREE_IMAGE_FORMAT;Stream: TStream; Flags: Integer = 0): Boolean;
    function Close(Flags: Integer = 0): Boolean;virtual;
    function GetPageCount: Integer;virtual;
    procedure AppendPage(Bitmap: TFreeBitmap);virtual;
    //procedure InsertPage(Page: Integer; Bitmap: TFreeBitmap);
    function InsertPage(Page: Integer; Bitmap: TFreeBitmap): Boolean;virtual;
    function DeletePage(Page: Integer): Boolean;virtual;
    function MovePage(Target, Source: Integer): Boolean;virtual;
//    procedure LockPage(Page: Integer; DestBitmap: TFreeBitmap);
    function LockPage(Page: Integer; DestBitmap: TFreeBitmap):boolean;virtual;
    //procedure UnlockPage(Bitmap: TFreeBitmap; Changed: Boolean);original
    function UnlockPage(Bitmap: TFreeBitmap;Changed: Boolean): Boolean;virtual;
//    function GetLostDib(Number:word):PFIBITMAP;
    function IsPageLocked(Number:Integer): Boolean;
    function GetLockedCount:integer;
    function GetLockedPageNumbers(var Pages: Integer; var Count: Integer): Boolean;overload;
    function GetLockedPageNumbers(pages,count: pinteger): Boolean;overload;
    // overriden methods
    function IsValid: Boolean; override;

    // properties
    // change of this property influences only on the next opening of a file
    property SourceReadOnly: Boolean read FReadOnly;
    property MemoryCache: Boolean read FMemoryCache write FMemoryCache;
    property OpenedFormat:FREE_IMAGE_FORMAT read FOpenedFormat;
  end;

TFreeCacheElement= class(Tobject)
  OriginalPageIndex:integer;
  ModifiedImage,OriginalImage:PFIBITMAP;
  ModifiedIsLocked:boolean;
public
  procedure clear;
  constructor Create(OriginalPage:integer);
  destructor Destroy; override;
  function IsEmpty:boolean;
end;

{TFreeMultiBitmapCache = class(Tobject)
  CachedItems:TFPList;
  public
  FMultiBitmap:TFreeMultiBitmap;
  //constructor Create(AMultiBitmap:TFreeMultiBitmap);
  //constructor Create(PagesCount:Word);
  destructor Destroy; override;
  //procedure Clear;
  //function GetCount:word;
  function GetCacheElement(index:word):TFreeCacheElement;
  procedure LockPage(Page: Integer; DestBitmap: TFreeBitmap);
  function UnlockPage(Bitmap: TFreeBitmap;DiscardAllchanges:boolean=false): Boolean;
end;}

TCachedFreeMultiBitmap = class(TFreeMultiBitmap)
  private
    CacheList:TFPList;
    procedure InitCache(PagesCount:Word);
    function CacheIsclean:boolean;
    procedure ClearCache;
    function CacheElement(index:word):TFreeCacheElement;
    //hiden
    function LoadFromHandle(IO: PFreeImageIO; Handle: fi_handle; Flags: Integer = 0): Boolean;reintroduce;

  public
   constructor Create;
   constructor CreatEmpty(fif: FREE_IMAGE_FORMAT=FIF_TIFF;Flags: Integer=0);
   destructor Destroy; override;
   function Open(const FileName: FreeImageAnsiString; CreateNew, ReadOnly: Boolean;
                 Flags: Integer = 0): Boolean;override;
   function LoadFromMemory(MemIO: TFreeMemoryIO; Flag: Integer = 0): Boolean;override;
   function GetPageCount: Integer;override;
   function SaveToMemory(fif: FREE_IMAGE_FORMAT;MemIO:TFreeMemoryIO; flags: Integer=0): Boolean;override;
   function Close(Flags: Integer = 0): Boolean;override;
   function UnlockPage(Bitmap: TFreeBitmap;Changed:boolean=false): Boolean;override;
   function LockPage(Page: Integer; DestBitmap: TFreeBitmap):boolean;override;
   function Replace(Page: Integer; Bitmap: TFreeBitmap): Boolean;
   function DeletePage(Page: Integer): Boolean;override;
   function InsertPage(Page: Integer; Bitmap: TFreeBitmap): Boolean;override;
   procedure AppendPage(Bitmap: TFreeBitmap);override;
   function MovePage(Target, Source: Integer): Boolean;override;
end;

var SizeOfPFIBITMAP:byte;

implementation

const
  ThumbSize = 150;
  NoPageNumber=-1;

// marker used for clipboard copy / paste

procedure SetFreeImageMarker(bmih: PBitmapInfoHeader; dib: PFIBITMAP);
begin
  // Windows constants goes from 0L to 5L
	// Add $FF to avoid conflicts
	bmih^.biCompression := $FF + FreeImage_GetImageType(dib);
end;

function GetFreeImageMarker(bmih: PBitmapInfoHeader): FREE_IMAGE_TYPE;
begin
  Result := FREE_IMAGE_TYPE(bmih^.biCompression - $FF);
end;

{ TFreePersistent }
constructor TFreeObject.Create;
begin
if not FreeimageHandleIsValid then
DynFreeImage.load;
//FreeimageHandle:=FindAndLoadLibrary(FIDLL);
//assert(FreeimageHandleIsValid,'freeimage library not loaded');
inherited;
end;

function TFreeObject.IsValid: Boolean;
begin
  Result := False
end;

{ TFreeBitmap }

function TFreeBitmap.AccessPixels: PByte;
begin
  Result := FreeImage_GetBits(FDib)
end;

function TFreeBitmap.AdjustBrightness(Percentage: Double): Boolean;
begin
  if FDib <> nil then
  begin
    Result := FreeImage_AdjustBrightness(FDib, Percentage);
    Change;
  end
  else
    Result := False
end;

function TFreeBitmap.AdjustContrast(Percentage: Double): Boolean;
begin
  if FDib <> nil then
  begin
    Result := FreeImage_AdjustContrast(FDib, Percentage);
    Change;
  end
  else
    Result := False
end;

function TFreeBitmap.AdjustCurve(Lut: PByte;
  Channel: FREE_IMAGE_COLOR_CHANNEL): Boolean;
begin
  if FDib <> nil then
  begin
    Result := FreeImage_AdjustCurve(FDib, Lut, Channel);
    Change;
  end
  else
    Result := False
end;

function TFreeBitmap.AdjustGamma(Gamma: Double): Boolean;
begin
  if FDib <> nil then
  begin
    Result := FreeImage_AdjustGamma(FDib, Gamma);
    Change;
  end
  else
    Result := False
end;

procedure TFreeBitmap.Assign(Source: TFreeBitmap);
var
  SourceBmp: TFreeBitmap;
  Clone: PFIBITMAP;
begin
  if Source = nil then
  begin
    Clear;
    Exit;
  end;
  
  if Source is TFreeBitmap then
  begin
    SourceBmp := TFreeBitmap(Source);
    if SourceBmp <> Self then
    begin
      if SourceBmp.IsValid then
      begin
        Clone := FreeImage_Clone(SourceBmp.FDib);
        Replace(Clone);
      end
      else
        Clear;
    end;
  end;
end;

function TFreeBitmap.CanSave(fif: FREE_IMAGE_FORMAT): Boolean;
var
  ImageType: FREE_IMAGE_TYPE;
  Bpp: Word;
begin
  Result := False;
  if not IsValid then Exit;

  if fif <> FIF_UNKNOWN then
  begin
    // check that the dib can be saved in this format
    ImageType := FreeImage_GetImageType(FDib);
    if ImageType = FIT_BITMAP then
    begin
      // standard bitmap type
      Bpp := FreeImage_GetBPP(FDib);
      Result := FreeImage_FIFSupportsWriting(fif)
                and FreeImage_FIFSupportsExportBPP(fif, Bpp);
    end
    else // special bitmap type
      Result := FreeImage_FIFSupportsExportType(fif, ImageType);
  end;
end;

procedure TFreeBitmap.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self)
end;

procedure TFreeBitmap.Clear;
begin
  if FDib <> nil then
  begin
    FreeImage_Unload(FDib);
    FDib := nil;
    Change;
  end;
end;

function TFreeBitmap.ColorQuantize(
  Algorithm: FREE_IMAGE_QUANTIZE;Dest:TFreeBitmap=nil): Boolean;
var
  dib8: PFIBITMAP;
begin
{  if FDib <> nil then
  begin
    dib8 := FreeImage_ColorQuantize(FDib, Algorithm);
    Result := Replace(dib8);
  end
  else
    Result := False;}
Result := False;
if not IsValid then exit;
dib8 := FreeImage_ColorQuantize(FDib, Algorithm);
if Dest = nil then Result := Replace(dib8)
else Result := Dest.Replace(dib8);
if not result then FreeImage_Unload(dib8);
end;

function TFreeBitmap.CombineChannels(Red, Green,
  Blue: TFreeBitmap): Boolean;
var
  Width, Height: Integer;
begin
  if FDib = nil then
  begin
    Width := Red.GetWidth;
    Height := Red.GetHeight;
    FDib := FreeImage_Allocate(Width, Height, 24, FI_RGBA_RED_MASK,
            FI_RGBA_GREEN_MASK, FI_RGBA_BLUE_MASK);
  end;

  if FDib <> nil then
  begin
    Result := FreeImage_SetChannel(FDib, Red.FDib, FICC_RED) and
              FreeImage_SetChannel(FDib, Green.FDib, FICC_GREEN) and
              FreeImage_SetChannel(FDib, Blue.FDib, FICC_BLUE);

    Change
  end
  else
    Result := False;
end;

function TFreeBitmap.ConvertTo16Bits555(Dest:TFreeBitmap=nil): Boolean;
var
  dib16_555: PFIBITMAP;
begin
{  if FDib <> nil then
  begin
    dib16_555 := FreeImage_ConvertTo16Bits555(FDib);
    Result := Replace(dib16_555);
  end
  else
    Result := False}

  //Added By Me
  Result := False;
  if not IsValid then exit;
  dib16_555 := FreeImage_ConvertTo16Bits555(FDib);
  if Dest = nil then Result := Replace(dib16_555)
  else Result := Dest.Replace(dib16_555);
  if not result then FreeImage_Unload(dib16_555);

end;

function TFreeBitmap.ConvertTo16Bits565(Dest:TFreeBitmap=nil): Boolean;
var
  dib16_565: PFIBITMAP;
begin
{  if FDib <> nil then
  begin
    dib16_565 := FreeImage_ConvertTo16Bits565(FDib);
    Result := Replace(dib16_565);
  end
  else
    Result := False}
  //Added By Me
  Result := False;
  if not IsValid then exit;
  dib16_565 := FreeImage_ConvertTo16Bits565(FDib);
  if Dest = nil then Result := Replace(dib16_565)
  else Result := Dest.Replace(dib16_565);
  if not result then FreeImage_Unload(dib16_565);
end;

function TFreeBitmap.ConvertTo24Bits(Dest:TFreeBitmap=nil): Boolean;
var
  dibRGB: PFIBITMAP;
begin
{  if FDib <> nil then
  begin
    dibRGB := FreeImage_ConvertTo24Bits(FDib);
    Result := Replace(dibRGB);
  end
  else
    Result := False }
  //Added By Me
  Result := False;
if not IsValid then exit;
dibRGB := FreeImage_ConvertTo24Bits(FDib);
if Dest = nil then Result := Replace(dibRGB)
else Result := Dest.Replace(dibRGB);
if not result then FreeImage_Unload(dibRGB);
end;

function TFreeBitmap.ConvertTo32Bits(Dest:TFreeBitmap=nil): Boolean;
var
  dib32: PFIBITMAP;
begin
{  if FDib <> nil then
  begin
    dib32 := FreeImage_ConvertTo32Bits(FDib);
    Result := Replace(dib32);
  end
  else
    Result := False}
//Added By Me
  Result := False;
if not IsValid then exit;
dib32 := FreeImage_ConvertTo32Bits(FDib);
if Dest = nil then
Result := Replace(dib32)
else
Result := Dest.Replace(dib32);
if not result then FreeImage_Unload(dib32);
end;

function TFreeBitmap.ConvertTo4Bits(Dest:TFreeBitmap=nil): Boolean;
var
  dib4: PFIBITMAP;
begin
  Result := False;
{  if IsValid then
  begin
    dib4 := FreeImage_ConvertTo4Bits(FDib);
    Result := Replace(dib4);
  end;}
  //Added By Me
  if not IsValid then exit;
  dib4 := FreeImage_ConvertTo4Bits(FDib);
  if Dest = nil then Result := Replace(dib4)
  else Result := Dest.Replace(dib4);
  if not result then FreeImage_Unload(dib4);
end;

function TFreeBitmap.ConvertTo8Bits(Dest:TFreeBitmap=nil): Boolean;
var
  dib8: PFIBITMAP;
begin
{  if FDib <> nil then
  begin
    dib8 := FreeImage_ConvertTo8Bits(FDib);
    Result := Replace(dib8);
  end
  else
    Result := False}
  //Added By Me
  Result := False;
if not IsValid then exit;
dib8 := FreeImage_ConvertTo8Bits(FDib);
if Dest = nil then Result := Replace(dib8)
else Result := Dest.Replace(dib8);
if not result then FreeImage_Unload(dib8);
end;

function TFreeBitmap.ConvertToGrayscale(Dest:TFreeBitmap=nil): Boolean;
var
  dib8: PFIBITMAP;
begin
  Result := False;

{  if IsValid then
  begin
    dib8 := FreeImage_ConvertToGreyscale(FDib);
    Result := Replace(dib8);
  end }

//Added By Me
if not IsValid then exit;
dib8 := FreeImage_ConvertToGreyscale(FDib);
if Dest = nil then Result := Replace(dib8)
else Result := Dest.Replace(dib8);
if not result then FreeImage_Unload(dib8);
end;

//Added By Me
procedure TFreeBitmap.ConvertToRawBits(bits: PByte; pitch: Integer;
              bpp, red_mask, green_mask, blue_mask: Cardinal; topdown: LongBool = False);
begin
FreeImage_ConvertToRawBits(bits,FDib,pitch,bpp, red_mask, green_mask, blue_mask,topdown);
end;
//

function TFreeBitmap.ConvertToRGBF(Dest:TFreeBitmap=nil): Boolean;
var
//  ImageType: FREE_IMAGE_TYPE;
  RGBFDib: PFIBITMAP;
begin
{  Result := False;
  if not IsValid then Exit;

  ImageType := GetImageType;

  if (ImageType = FIT_BITMAP) then
  begin
    if GetBitsPerPixel < 24 then
      if not ConvertTo24Bits then
        Exit
  end;
  NewDib := FreeImage_ConvertToRGBF(FDib);
  Result := Replace(NewDib);}

Result := False;
if not IsValid then exit;
{ImageType := GetImageType; Checking into library?
if not(ImageType in[FIT_BITMAP,FIT_UINT16,FIT_FLOAT,FIT_RGB16,FIT_RGBA16,FIT_RGBAF])then exit;
}

RGBFDib:= FreeImage_ConvertToRGBF(FDib);
if Dest = nil then Result := Replace(RGBFDib)
else Result := Dest.Replace(RGBFDib);
if not result then FreeImage_Unload(RGBFDib);
end;

function TFreeBitmap.ConvertToStandardType(ScaleLinear: Boolean= True;Dest:TFreeBitmap=nil): Boolean;
var
  dibStandard: PFIBITMAP;
begin
{  if IsValid then
  begin
    dibStandard := FreeImage_ConvertToStandardType(FDib, ScaleLinear);
    Result := Replace(dibStandard);
  end
  else
    Result := False;}
 Result := False;
 if not IsValid then exit;
  dibStandard := FreeImage_ConvertToStandardType(FDib,ScaleLinear);
  if Dest = nil then Result := Replace(dibStandard)
  else Result := Dest.Replace(dibStandard);
  if not result then FreeImage_Unload(dibStandard);
end;

function TFreeBitmap.ConvertToType(ImageType: FREE_IMAGE_TYPE;
  ScaleLinear: Boolean;Dest:TFreeBitmap=nil): Boolean;
var
  Sdib: PFIBITMAP;
begin
{  if FDib <> nil then
  begin
    Sdib := FreeImage_ConvertToType(FDib, ImageType, ScaleLinear);
    Result := Replace(Sdib)
  end
  else
    Result := False}
Result := False;
if not IsValid then exit;
Sdib := FreeImage_ConvertToType(FDib, ImageType, ScaleLinear);
if Dest = nil then Result := Replace(Sdib)
else Result := Dest.Replace(Sdib);
if not result then FreeImage_Unload(Sdib);

end;

function TFreeBitmap.CopySubImage(Left, Top, Right, Bottom: Integer;
  Dest: TFreeBitmap): Boolean;
begin
  if FDib <> nil then
  begin
    Dest.FDib := FreeImage_Copy(FDib, Left, Top, Right, Bottom);
    Result := Dest.IsValid;
  end else
    Result := False;
end;

constructor TFreeBitmap.Create(ImageType: FREE_IMAGE_TYPE; Width, Height,
  Bpp: Integer);
begin
  inherited Create;
  //FLockedNumber:=NoPageNumber;
  FFromMultipage:=nil;
  FDib := nil;
  if (Width > 0) and (Height > 0) and (Bpp > 0) then
    SetSize(ImageType, Width, Height, Bpp);
end;

destructor TFreeBitmap.Destroy;
begin
  if FDib <> nil then
    FreeImage_Unload(FDib);
  inherited;
end;

function TFreeBitmap.Dither(Algorithm: FREE_IMAGE_DITHER;Dest:TFreeBitmap=nil): Boolean;
var
  Sdib: PFIBITMAP;
begin
 { if FDib <> nil then
  begin
    Sdib := FreeImage_Dither(FDib, Algorithm);
    Result := Replace(Sdib);
  end
  else
    Result := False;}
Result := False;
if not IsValid then exit;
Sdib :=FreeImage_Dither(FDib, Algorithm);
if Dest = nil then Result := Replace(Sdib)
else Result := Dest.Replace(Sdib);
if not result then FreeImage_Unload(Sdib);
end;

function TFreeBitmap.DoChanging(var OldDib, NewDib: PFIBITMAP): Boolean;
begin
  Result := False;
  if (OldDib <> NewDib) and Assigned(FOnChanging) then
    FOnChanging(Self, OldDib, NewDib, Result);
end;

procedure TFreeBitmap.FindCloseMetadata(MDHandle: PFIMETADATA);
begin
  FreeImage_FindCloseMetadata(MDHandle);
end;

function TFreeBitmap.FindFirstMetadata(Model: FREE_IMAGE_MDMODEL;
  var Tag: TFreeTag): PFIMETADATA;
begin
  Result := FreeImage_FindFirstMetadata(Model, FDib, Tag.FTag);
end;

function TFreeBitmap.FindNextMetadata(MDHandle: PFIMETADATA;
  var Tag: TFreeTag): Boolean;
begin
  Result := FreeImage_FindNextMetadata(MDHandle, Tag.FTag);
end;

function TFreeBitmap.FlipHorizontal: Boolean;
begin
  if FDib <> nil then
  begin
    Result := FreeImage_FlipHorizontal(FDib);
    Change;
  end
  else
    Result := False
end;

function TFreeBitmap.FlipVertical: Boolean;
begin
  if FDib <> nil then
  begin
    Result := FreeImage_FlipVertical(FDib);
    Change;
  end
  else
    Result := False
end;

function TFreeBitmap.GetBitsPerPixel: Integer;
begin
  Result := FreeImage_GetBPP(FDib)
end;

function TFreeBitmap.GetChannel(Bitmap: TFreeBitmap;
  Channel: FREE_IMAGE_COLOR_CHANNEL): Boolean;
begin
  if FDib <> nil then
  begin
    Bitmap.Dib := FreeImage_GetChannel(FDib, Channel);
    Result := Bitmap.IsValid;
  end
  else
    Result := False
end;

function TFreeBitmap.GetColorsUsed: Integer;
begin
  Result := FreeImage_GetColorsUsed(FDib)
end;

function TFreeBitmap.GetColorType: FREE_IMAGE_COLOR_TYPE;
begin
  Result := FreeImage_GetColorType(FDib);
end;

function TFreeBitmap.GetFileBkColor(var BkColor: RGBQUAD): Boolean;
begin
  Result := FreeImage_GetBackgroundColor(FDib, BkColor);
end;

function TFreeBitmap.GetHeight: Integer;
begin
  Result := FreeImage_GetHeight(FDib)
end;

function TFreeBitmap.GetHistogram(Histo: PDWORD;
  Channel: FREE_IMAGE_COLOR_CHANNEL): Boolean;
begin
  if FDib <> nil then
    Result := FreeImage_GetHistogram(FDib, Histo, Channel)
  else
    Result := False
end;

function TFreeBitmap.GetHorizontalResolution: Double;
begin
  Result := FreeImage_GetDotsPerMeterX(FDib) / 100
end;

function TFreeBitmap.GetImageSize: Cardinal;
begin
  Result := FreeImage_GetDIBSize(FDib);
end;

function TFreeBitmap.GetImageType: FREE_IMAGE_TYPE;
begin
  Result := FreeImage_GetImageType(FDib);
end;

function TFreeBitmap.GetInfo: PBitmapInfo;
begin
  Result := FreeImage_GetInfo(FDib);
end;

function TFreeBitmap.GetInfoHeader: PBITMAPINFOHEADER;
begin
  Result := FreeImage_GetInfoHeader(FDib)
end;

function TFreeBitmap.GetLine: Integer;
begin
  Result := FreeImage_GetLine(FDib)
end;

function TFreeBitmap.GetMetadata(Model: FREE_IMAGE_MDMODEL;
  const Key: AnsiString; var Tag: TFreeTag): Boolean;
begin
  Result := FreeImage_GetMetadata(Model, FDib, PAnsiChar(Key), Tag.FTag);
end;

function TFreeBitmap.GetMetadataCount(Model: FREE_IMAGE_MDMODEL): Cardinal;
begin
  Result := FreeImage_GetMetadataCount(Model, FDib);
end;

function TFreeBitmap.GetPalette: PRGBQUAD;
begin
  Result := FreeImage_GetPalette(FDib)
end;

function TFreeBitmap.GetPaletteSize: Integer;
begin
  Result := FreeImage_GetColorsUsed(FDib) * SizeOf(RGBQUAD)
end;

function TFreeBitmap.GetPixelColor(X, Y: Cardinal;
  var Value: RGBQUAD): Boolean;
begin
  Result := FreeImage_GetPixelColor(FDib, X, Y, Value);
end;

function TFreeBitmap.GetPixelIndex(X, Y: Cardinal;
  var Value: Byte): Boolean;
begin
  Result := FreeImage_GetPixelIndex(FDib, X, Y, Value);
end;

function TFreeBitmap.GetScanLine(ScanLine: Integer): PByte;
var
  H: Integer;
begin
  H := FreeImage_GetHeight(FDib);
  if ScanLine < H then
    Result := FreeImage_GetScanLine(FDib, ScanLine)
  else
    Result := nil;
end;

function TFreeBitmap.GetScanWidth: Integer;
begin
  Result := FreeImage_GetPitch(FDib)
end;

function TFreeBitmap.GetTransparencyCount: Cardinal;
begin
  Result := FreeImage_GetTransparencyCount(FDib)
end;

function TFreeBitmap.GetTransparencyTable: PByte;
begin
  Result := FreeImage_GetTransparencyTable(FDib)
end;

function TFreeBitmap.GetVerticalResolution: Double;
begin
  Result := FreeImage_GetDotsPerMeterY(Fdib) / 100
end;

function TFreeBitmap.GetWidth: Integer;
begin
  Result := FreeImage_GetWidth(FDib)
end;

function TFreeBitmap.HasFileBkColor: Boolean;
begin
  Result := FreeImage_HasBackgroundColor(FDib)
end;

function TFreeBitmap.Invert: Boolean;
begin
  if FDib <> nil then
  begin
   // Result := FreeImage_Invert(FDib);
    Change;
  end
  else
    Result := False
end;

function TFreeBitmap.IsGrayScale: Boolean;
begin
  Result := (FreeImage_GetBPP(FDib) = 8)
// modif JMB NOVAXEL
// 	FIC_PALETTE isn't enough to tell the bitmap is grayscale
//            and (FreeImage_GetColorType(FDib) = FIC_PALETTE);
            and ((FreeImage_GetColorType(FDib) = FIC_MINISBLACK) or
            		(FreeImage_GetColorType(FDib) = FIC_MINISWHITE));
// end of modif JMB NOVAXEL
end;

function TFreeBitmap.IsTransparent: Boolean;
begin
  Result := FreeImage_IsTransparent(FDib);
end;

function TFreeBitmap.IsValid: Boolean;
begin
  Result := FDib <> nil
end;

function TFreeBitmap.LoadFromFile(const FileName:string; Flag: Integer = 0): Boolean;
var TmpFileStream:Tfilestream;
begin
result:=
{$IFDEF MSWINDOWS}LoadU
{$else}
Load
{$ENDIF}
(FileName,flag);
if result then exit;

TmpFileStream:=Tfilestream.Create(filename,fmOpenRead or fmShareDenyWrite);
if TmpFileStream.Handle<>feInvalidHandle then
  result:=LoadFromStream(TmpFileStream,flag);
TmpFileStream.Free;
end;

function TFreeBitmap.Load(const FileName: FreeImageAnsiString; Flag: Integer): Boolean;
var
  fif: FREE_IMAGE_FORMAT;
begin

  // check the file signature and get its format
  fif := FreeImage_GetFileType(PAnsiChar(FileName), 0);
  if fif = FIF_UNKNOWN then
    // no signature?
    // try to guess the file format from the file extention
    fif := FreeImage_GetFIFFromFilename(PAnsiChar(FileName));

    // check that the plugin has reading capabilities ...
    if (fif <> FIF_UNKNOWN) and FreeImage_FIFSupportsReading(FIF)
    and not(fif in TFreeMultiBitmapFormats)
    then begin
      // free the previous dib
      if FDib <> nil then
        FreeImage_Unload(dib);

      // load the file
      FDib := FreeImage_Load(fif, PAnsiChar(FileName), Flag);

      Change;
      Result := IsValid;
    end else
      Result := False;
end;

function TFreeBitmap.LoadFromHandle(IO: PFreeImageIO; Handle: fi_handle;
  Flag: Integer): Boolean;
var
  fif: FREE_IMAGE_FORMAT;
begin
  // check the file signature and get its format
  fif := FreeImage_GetFileTypeFromHandle(IO, Handle, 16);
  if (fif <> FIF_UNKNOWN) and FreeImage_FIFSupportsReading(fif) then
  begin
    // free the previous dib
    if FDib <> nil then
      FreeImage_Unload(FDib);

    // load the file
    FDib := FreeImage_LoadFromHandle(fif, IO, Handle, Flag);

    Change;
    Result := IsValid;
  end else
    Result := False;
end;

function TFreeBitmap.LoadFromMemory(MemIO: TFreeMemoryIO;
  Flag: Integer): Boolean;
var
  fif: FREE_IMAGE_FORMAT;
begin

  // check the file signature and get its format
  fif := MemIO.GetFileType;
  if (fif <> FIF_UNKNOWN) and FreeImage_FIFSupportsReading(fif)
  and not(fif in TFreeMultiBitmapFormats)
  then begin
    // free the previous dib
    if FDib <> nil then
      FreeImage_Unload(FDib);

    // load the file
    FDib := MemIO.Read(fif, Flag);

    Result := IsValid;
    Change;
  end else
    Result := False;
end;

function TFreeBitmap.LoadFromStream(Stream: TStream;
  Flag: Integer): Boolean;
var
  MemIO: TFreeMemoryIO;
  Data: PByte;
  MemStream: TMemoryStream;
  Size: Cardinal;
begin
  Size := Stream.Size;

  MemStream := TMemoryStream.Create;
  try
    MemStream.CopyFrom(Stream, Size);
    Data := MemStream.Memory;

    MemIO := TFreeMemoryIO.Create(Data, Size);
    try
      Result := LoadFromMemory(MemIO,Flag);
    finally
      MemIO.Free;
    end;
  finally
    MemStream.Free;
  end;
end;

function TFreeBitmap.LoadU(const FileName: {$IFDEF DELPHI2010}string{$ELSE}WideString{$ENDIF};
  Flag: Integer): Boolean;
var
  fif: FREE_IMAGE_FORMAT;
begin

  // check the file signature and get its format
  fif := FreeImage_GetFileTypeU(PWideChar(Filename), 0);
  if fif = FIF_UNKNOWN then
    // no signature?
    // try to guess the file format from the file extention
    fif := FreeImage_GetFIFFromFilenameU(PWideChar(FileName));

    // check that the plugin has reading capabilities ...
    if (fif <> FIF_UNKNOWN) and FreeImage_FIFSupportsReading(FIF)
    and not(fif in TFreeMultiBitmapFormats)
    then begin
      // free the previous dib
      if FDib <> nil then
        FreeImage_Unload(dib);

      // load the file
      FDib := FreeImage_LoadU(fif, PWideChar(FileName), Flag);

      Change;
      Result := IsValid;
    end else
      Result := False;
end;

procedure TFreeBitmap.MakeThumbnail(const Width, Height: Integer;
  DestBitmap: TFreeBitmap);
type
  PRGB24 = ^TRGB24;
  TRGB24 = packed record
    B: Byte;
    G: Byte;
    R: Byte;
  end;
var
  x, y, ix, iy: integer;
  x1, x2, x3: integer;

  xscale, yscale: single;
  iRed, iGrn, iBlu, iRatio: Longword;
  p, c1, c2, c3, c4, c5: TRGB24;
  pt, pt1: PRGB24;
  iSrc, iDst, s1: integer;
  i, j, r, g, b, tmpY: integer;

  RowDest, RowSource, RowSourceStart: integer;
  w, h: Integer;
  dxmin, dymin: integer;
  ny1, ny2, ny3: integer;
  dx, dy: integer;
  lutX, lutY: array of integer;

  SrcBmp, DestBmp: PFIBITMAP;
begin
  if not IsValid then Exit;

  if (GetWidth <= ThumbSize) and (GetHeight <= ThumbSize) then
  begin
    DestBitmap.Assign(Self);
    Exit;
  end;

  w := Width;
  h := Height;

  // prepare bitmaps
  if GetBitsPerPixel <> 24 then
    SrcBmp := FreeImage_ConvertTo24Bits(FDib)
  else
    SrcBmp := FDib;
  DestBmp := FreeImage_Allocate(w, h, 24);
  Assert(DestBmp <> nil, 'TFreeBitmap.MakeThumbnail error');

{  iDst := (w * 24 + 31) and not 31;
  iDst := iDst div 8; //BytesPerScanline
  iSrc := (GetWidth * 24 + 31) and not 31;
  iSrc := iSrc div 8;
}
  // BytesPerScanline
  iDst := FreeImage_GetPitch(DestBmp);
  iSrc := FreeImage_GetPitch(SrcBmp);

  xscale := 1 / (w / FreeImage_GetWidth(SrcBmp));
  yscale := 1 / (h / FreeImage_GetHeight(SrcBmp));

  // X lookup table
  SetLength(lutX, w);
  x1 := 0;
  x2 := trunc(xscale);
  for x := 0 to w - 1 do
  begin
    lutX[x] := x2 - x1;
    x1 := x2;
    x2 := trunc((x + 2) * xscale);
  end;

  // Y lookup table
  SetLength(lutY, h);
  x1 := 0;
  x2 := trunc(yscale);
  for x := 0 to h - 1 do
  begin
    lutY[x] := x2 - x1;
    x1 := x2;
    x2 := trunc((x + 2) * yscale);
  end;

  Dec(w);
  Dec(h);
  RowDest := integer(FreeImage_GetScanLine(DestBmp, 0));
  RowSourceStart := integer(FreeImage_GetScanLine(SrcBmp, 0));
  RowSource := RowSourceStart;

  for y := 0 to h do
  // resampling
  begin
    dy := lutY[y];
    x1 := 0;
    x3 := 0;
    for x := 0 to w do  // loop through row
    begin
      dx:= lutX[x];
      iRed:= 0;
      iGrn:= 0;
      iBlu:= 0;
      RowSource := RowSourceStart;
      for iy := 1 to dy do
      begin
        pt := PRGB24(RowSource + x1);
        for ix := 1 to dx do
        begin
          iRed := iRed + pt^.R;
          iGrn := iGrn + pt^.G;
          iBlu := iBlu + pt^.B;
          inc(pt);
        end;
        RowSource := RowSource + iSrc;
      end;
      iRatio := 65535 div (dx * dy);
      pt1 := PRGB24(RowDest + x3);
      pt1^.R := (iRed * iRatio) shr 16;
      pt1^.G := (iGrn * iRatio) shr 16;
      pt1^.B := (iBlu * iRatio) shr 16;
      x1 := x1 + 3 * dx;
      inc(x3,3);
    end;
    RowDest := RowDest + iDst;
    RowSourceStart := RowSource;
  end; // resampling

  if FreeImage_GetHeight(DestBmp) >= 3 then
  // Sharpening...
  begin
    s1 := integer(FreeImage_GetScanLine(DestBmp, 0));
    iDst := integer(FreeImage_GetScanLine(DestBmp, 1)) - s1;
    ny1 := Integer(s1);
    ny2 := ny1 + iDst;
    ny3 := ny2 + iDst;
    for y := 1 to FreeImage_GetHeight(DestBmp) - 2 do
    begin
      for x := 0 to FreeImage_GetWidth(DestBmp) - 3 do
      begin
        x1 := x * 3;
        x2 := x1 + 3;
        x3 := x1 + 6;

        c1 := pRGB24(ny1 + x1)^;
        c2 := pRGB24(ny1 + x3)^;
        c3 := pRGB24(ny2 + x2)^;
        c4 := pRGB24(ny3 + x1)^;
        c5 := pRGB24(ny3 + x3)^;

        r := (c1.R + c2.R + (c3.R * -12) + c4.R + c5.R) div -8;
        g := (c1.G + c2.G + (c3.G * -12) + c4.G + c5.G) div -8;
        b := (c1.B + c2.B + (c3.B * -12) + c4.B + c5.B) div -8;

        if r < 0 then r := 0 else if r > 255 then r := 255;
        if g < 0 then g := 0 else if g > 255 then g := 255;
        if b < 0 then b := 0 else if b > 255 then b := 255;

        pt1 := pRGB24(ny2 + x2);
        pt1^.R := r;
        pt1^.G := g;
        pt1^.B := b;
      end;
      inc(ny1, iDst);
      inc(ny2, iDst);
      inc(ny3, iDst);
    end;
  end; // sharpening

  if SrcBmp <> FDib then
    FreeImage_Unload(SrcBmp);
  DestBitmap.Replace(DestBmp);
end;

procedure TFreeBitmap.MakeThumbnail(DestBitmap: TFreeBitmap;max_pixel_size:Integer;convert:Boolean=True);
begin
DestBitmap.Replace(FreeImage_MakeThumbnail(Fdib,max_pixel_size,convert));
end;

function TFreeBitmap.PasteSubImage(Src: TFreeBitmap; Left, Top,
  Alpha: Integer): Boolean;
begin
  if FDib <> nil then
  begin
    Result := FreeImage_Paste(FDib, Src.Dib, Left, Top, Alpha);
    Change;
  end else
    Result := False;
end;

function TFreeBitmap.Replace(NewDib: PFIBITMAP): Boolean;
begin
  Result := False;
  if NewDib = nil then Exit;

  if not DoChanging(FDib, NewDib) and IsValid then
    FreeImage_Unload(FDib);

  FDib := NewDib;
  Result := True;
  Change;
end;

function TFreeBitmap.Rescale(NewWidth, NewHeight: Integer;
  Filter: FREE_IMAGE_FILTER = FILTER_CATMULLROM; Dest: TFreeBitmap=nil): Boolean;
var
  Bpp: Integer;
  DstDib: PFIBITMAP;
begin
  {Result := False;

  if FDib <> nil then
  begin
    Bpp := FreeImage_GetBPP(FDib);

    if Bpp < 8 then
      if not ConvertToGrayscale then Exit
    else
    if Bpp = 16 then
    // convert to 24-bit
      if not ConvertTo24Bits then Exit;

    // perform upsampling / downsampling
    DstDib := FreeImage_Rescale(FDib, NewWidth, NewHeight, Filter);
    if Dest = nil then
      Result := Replace(DstDib)
    else
      Result := Dest.Replace(DstDib)
  end }
//Added By Me :
  DstDib := FreeImage_Rescale(FDib, NewWidth, NewHeight, Filter);
  if Dest = nil then Result := Replace(DstDib)
  else Result := Dest.Replace(DstDib);
end;

function TFreeBitmap.RescaleRect(DestWidth,Destheight,Srcleft,Srctop,SrcRight,SrcBottom: Integer;
  filter: FREE_IMAGE_FILTER = FILTER_BOX;flags: Cardinal = 0;Dest:TFreeBitmap=nil): Boolean;
var
Rescaled: PFIBITMAP;
begin
Result := False;
if not IsValid then exit;
Rescaled:=FreeImage_RescaleRect(Fdib,DestWidth,Destheight,Srcleft,Srctop,SrcRight,SrcBottom,filter,flags);
if Dest = nil then
Result := Replace(Rescaled)
else
Result := Dest.Replace(Rescaled);
if not result then FreeImage_Unload(Rescaled);
end;

function TFreeBitmap.Rotate(Angle90or180or270: Double;Dest:TFreeBitmap=nil): Boolean;
var
  Bpp: Integer;
  Rotated: PFIBITMAP;
begin
 { Result := False;
  if IsValid then
  begin
    Bpp := FreeImage_GetBPP(FDib);
    if Bpp in [1, 8, 24, 32] then
    begin
// modif JMB : FreeImage_RotateClassic : deprecated function, call to DeprecationManager in 64 bits crash freeimage.dll
      //Rotated := FreeImage_RotateClassic(FDib, Angle);
      Rotated := FreeImage_Rotate(FDib, Angle, nil);
// end of modif JMB
      //Rotated := FreeImage_Rotate(FDib, Angle);
      Result := Replace(Rotated);
    end
  end;}
Result := False;
if not IsValid then exit;
Rotated := FreeImage_Rotate(FDib,Angle90or180or270);
if Dest = nil then
Result := Replace(Rotated)
else
Result := Dest.Replace(Rotated);
if not result then FreeImage_Unload(Rotated);
end;

function TFreeBitmap.RotateEx(Angle, XShift, YShift, XOrigin,
  YOrigin: Double; UseMask: Boolean;Dest:TFreeBitmap=nil): Boolean;
var
  Rotated: PFIBITMAP;
begin
{  Result := False;
  if FDib <> nil then
  begin
    if FreeImage_GetBPP(FDib) >= 8 then
    begin
      Rotated := FreeImage_RotateEx(FDib, Angle, XShift, YShift, XOrigin, YOrigin, UseMask);
      Result := Replace(Rotated);
    end
  end;}
Result := False;
if not IsValid then exit;
Rotated :=FreeImage_RotateEx(FDib, Angle, XShift, YShift, XOrigin, YOrigin, UseMask);
if Dest = nil then Result := Replace(Rotated)
else Result := Dest.Replace(Rotated);
if not result then FreeImage_Unload(Rotated);
end;

function TFreeBitmap.Save(const FileName: FreeImageAnsiString; Flag: Integer): Boolean;
var
  fif: FREE_IMAGE_FORMAT;
begin
  Result := False;

  // try to guess the file format from the file extension
  fif := FreeImage_GetFIFFromFilename(PAnsiChar(FileName));
  if CanSave(fif) then
    Result := FreeImage_Save(fif, FDib, PAnsiChar(FileName), Flag);
end;

function TFreeBitmap.SaveToHandle(fif: FREE_IMAGE_FORMAT; IO: PFreeImageIO;
  Handle: fi_handle; Flag: Integer): Boolean;
begin
  Result := False;
  if CanSave(fif) then
    Result := FreeImage_SaveToHandle(fif, FDib, IO, Handle, Flag)
end;

function TFreeBitmap.SaveToMemory(fif: FREE_IMAGE_FORMAT;
  MemIO: TFreeMemoryIO; Flag: Integer): Boolean;
begin
  Result := False;

  if CanSave(fif) then
    Result := MemIO.Write(fif, FDib, Flag)
end;

function TFreeBitmap.SaveToStream(fif: FREE_IMAGE_FORMAT; Stream: TStream;
  Flag: Integer): Boolean;
var
  MemIO: TFreeMemoryIO;
  Data: PByte;
  Size: Cardinal;
begin
  MemIO := TFreeMemoryIO.Create;
  try
    Result := SaveToMemory(fif, MemIO, Flag);
    if Result then
    begin
      MemIO.Acquire(Data, Size);
      Stream.WriteBuffer(Data^, Size);
    end;
  finally
    MemIO.Free;
  end;
end;

function TFreeBitmap.SaveU(const FileName: {$IFDEF DELPHI2010}string{$ELSE}WideString{$ENDIF};
  Flag: Integer): Boolean;
var
  fif: FREE_IMAGE_FORMAT;
begin
  Result := False;

  // try to guess the file format from the file extension
  fif := FreeImage_GetFIFFromFilenameU(PWideChar(Filename));
  if CanSave(fif) then
    Result := FreeImage_SaveU(fif, FDib, PWideChar(FileName), Flag);
end;

function TFreeBitmap.SetChannel(Bitmap: TFreeBitmap;
  Channel: FREE_IMAGE_COLOR_CHANNEL): Boolean;
begin
  if FDib <> nil then
  begin
    Result := FreeImage_SetChannel(FDib, Bitmap.FDib, Channel);
    Change;
  end
  else
    Result := False
end;

function TFreeBitmap.SwapChannels(FirstChannel,SecondChannel:FREE_IMAGE_COLOR_CHANNEL):boolean;
var First,Second:TFreeBitmap;
begin
First:=TFreeBitmap.Create();
Second:=TFreeBitmap.Create();

result:=GetChannel(First,FirstChannel)and GetChannel(Second,SecondChannel)and
SetChannel(First,SecondChannel)and SetChannel(Second,FirstChannel);

Second.Free;
First.Free;
Change;
end;

function TFreeBitmap.SwapRedBlue: Boolean;
var x,y:qword;pb:Pbyte;bpp,value:byte;
begin
result:=false;
bpp:=FreeImage_GetBPP(FDib);
  if not(bpp in [32,24]) then exit;
bpp:=bpp shr 3;
for y:=0 to FreeImage_getHeight(FDib)-1 do begin
  pb:=FreeImage_getscanline(FDib,y);
  for x:=0 to FreeImage_getwidth(FDib)-1 do begin
    value:=pb[fi_rgba_red];
    pb[fi_rgba_red]:=pb[fi_rgba_blue];
    pb[fi_rgba_blue]:=value;
    inc(pb,bpp);
   end;
 end;
result:=true;
Change;
end;

procedure TFreeBitmap.SetDib(Value: PFIBITMAP);
begin
Replace(Value);
end;

function TFreeBitmap.SetFileBkColor(BkColor: PRGBQuad): Boolean;
begin
  Result := FreeImage_SetBackgroundColor(FDib, BkColor);
  Change;
end;

procedure TFreeBitmap.SetHorizontalResolution(Value: Double);
begin
  if IsValid then
  begin
    FreeImage_SetDotsPerMeterX(FDib, Trunc(Value * 100 + 0.5));
    Change;
  end;
end;

function TFreeBitmap.SetMetadata(Model: FREE_IMAGE_MDMODEL;
  const Key: AnsiString; Tag: TFreeTag): Boolean;
begin
  Result := FreeImage_SetMetadata(Model, FDib, PAnsiChar(Key), Tag.Tag);
end;

function TFreeBitmap.SetPixelColor(X, Y: Cardinal;
  var Value: RGBQUAD): Boolean;
begin
  Result := FreeImage_SetPixelColor(FDib, X, Y, Value);
  Change;
end;

function TFreeBitmap.SetPixelIndex(X, Y: Cardinal; var Value: Byte): Boolean;
begin
  Result := FreeImage_SetPixelIndex(FDib, X, Y, Value);
  Change;
end;

function TFreeBitmap.SetSize(ImageType: FREE_IMAGE_TYPE; Width, Height,
  Bpp: Integer; RedMask, GreenMask, BlueMask: Cardinal): Boolean;
var
  Pal: PRGBQuad;
  I: Cardinal;
begin
  Result := False;

  if FDib <> nil then
    FreeImage_Unload(FDib);

  FDib := FreeImage_Allocate(Width, Height, Bpp, RedMask, GreenMask, BlueMask);
  if FDib = nil then Exit;

  if ImageType = FIT_BITMAP then
  case Bpp of
    1, 4, 8:
    begin
      Pal := FreeImage_GetPalette(FDib);
      for I := 0 to FreeImage_GetColorsUsed(FDib) - 1 do
      begin
        Pal^.rgbBlue := I;
        Pal^.rgbGreen := I;
        Pal^.rgbRed := I;
        Inc(Pal);//, SizeOf(RGBQUAD));
      end;
    end;
  end;

  Result := True;
  Change;
end;

procedure TFreeBitmap.SetTransparencyTable(Table: PByte; Count: Integer);
begin
  FreeImage_SetTransparencyTable(FDib, Table, Count);
  Change;
end;

procedure TFreeBitmap.SetVerticalResolution(Value: Double);
begin
  if IsValid then
  begin
    FreeImage_SetDotsPerMeterY(FDib, Trunc(Value * 100 + 0.5));
    Change;
  end;
end;

function TFreeBitmap.SplitChannels(RedChannel, GreenChannel,
  BlueChannel: TFreeBitmap): Boolean;
begin
  if FDib <> nil then
  begin
    RedChannel.FDib := FreeImage_GetChannel(FDib, FICC_RED);
    GreenChannel.FDib := FreeImage_GetChannel(FDib, FICC_GREEN);
    BlueChannel.FDib := FreeImage_GetChannel(FDib, FICC_BLUE);
    Result := RedChannel.IsValid and GreenChannel.IsValid and BlueChannel.IsValid;
  end
  else
    Result := False  
end;

function TFreeBitmap.Threshold(T: Byte;Dest:TFreeBitmap=nil): Boolean;
var
  dib1: PFIBITMAP;
begin
{  if FDib <> nil then
  begin
    dib1 := FreeImage_Threshold(FDib, T);
    Result := Replace(dib1);
  end
  else
    Result := False}
Result := False;
if not IsValid then exit;
dib1 :=FreeImage_Threshold(FDib, T);
if Dest = nil then
Result := Replace(dib1)
else
Result := Dest.Replace(dib1);
if not result then FreeImage_Unload(dib1);
end;

function TFreeBitmap.ToneMapping(TMO: FREE_IMAGE_TMO; FirstParam,
  SecondParam: Double;Dest:TFreeBitmap=nil): Boolean;
var
  NewDib: PFIBITMAP;
begin
{  Result := False;
  if not IsValid then Exit;

  NewDib := FreeImage_ToneMapping(Fdib, TMO, FirstParam, SecondParam);
  Result := Replace(NewDib);}
Result := False;
if not IsValid then exit;
NewDib :=FreeImage_ToneMapping(Fdib, TMO, FirstParam, SecondParam);
if Dest = nil then
Result := Replace(NewDib)
else
Result := Dest.Replace(NewDib);
if not result then FreeImage_Unload(NewDib);
end;

function TFreeBitmap.FromMultiImage:boolean;
begin result:=FFromMultipage<>nil;end;

{$IFDEF LCL}
function TFreeBitmap.CreateBitmaps(out ABitmap, AMask: HBitmap; ASkipMask: Boolean = False): Boolean;
var tmpraw:TRawImage;
tmpimage:TFreeBitmap;
DibDouble:PFIBITMAP;
ImageType:FREE_IMAGE_TYPE;
begin
result:=false;
tmpraw.Init;
//windows + Linux in Lazarus:
tmpraw.Description.Init_BPP32_B8G8R8A8_BIO_TTB(GetWidth,GetHeight);
tmpimage:=TFreeBitmap.Create();
tmpimage.Assign(self);
ImageType:=tmpimage.GetImageType;
if ImageType<>FIT_BITMAP then begin
  if ImageType <> FIT_COMPLEX then begin
    DibDouble := FreeImage_GetComplexChannel(tmpimage.Dib, FICC_MAG);
    tmpimage.Replace(DibDouble);
  end;
  tmpimage.ConvertToStandardType;
end;
if tmpimage.IsValid then begin
//need flipping?  check on linux
if tmpimage.FlipVertical = false then begin tmpimage.Free; exit(false);end;
if tmpimage.GetBitsPerPixel<>32 then tmpimage.ConvertTo32Bits;
{//windows only, linux not emplemented yet: Fraw.Description.LineOrder:=riloBottomToTop;}
tmpraw.Data:=tmpimage.AccessPixels;tmpraw.DataSize:=tmpimage.GetHeight*tmpimage.GetScanWidth;
try
result:=RawImage_CreateBitmaps(tmpraw,ABitmap,AMask,ASkipMask);
finally
  FreeAndNil(tmpimage);
end;

end;
FreeAndNil(tmpimage);
end;
{$ENDIF}


{ TFreeMultiBitmap }

procedure TFreeMultiBitmap.AppendPage(Bitmap: TFreeBitmap);
begin
if IsValid=false then exit;
FreeImage_AppendPage(FMPage, Bitmap.FDib);
//LockedPages.Add(Bitmap.FDib);
end;

function TFreeMultiBitmap.Close(Flags: Integer): Boolean;
begin
Result := FreeImage_CloseMultiBitmap(FMPage, Flags);
if result then begin //Add by me
  FreeAndNil(FMemIO);
  MemStream.Clear;
  FOpenedFormat:=FIF_UNKNOWN;
  //LockedPages.Clear;
  FMPage := nil;
end;
end;

constructor TFreeMultiBitmap.Create(KeepCacheInMemory: Boolean);
begin
  inherited Create;
  FMemoryCache := KeepCacheInMemory;
  //Add by me:
  MemStream := TMemoryStream.Create;
  //LockedPages:=TFPList.Create;
end;

function TFreeMultiBitmap.DeletePage(Page: Integer): Boolean;
begin
result:=false;
if (IsValid=false)or (GetLockedCount>0) or FReadOnly then exit;
FreeImage_DeletePage(FMPage, Page);
//because FreeImage do not delete locked or when readonly stream
{if LockedPages.Count<>GetPageCount then
  LockedPages.Delete(Page);}
result:=true;
end;

destructor TFreeMultiBitmap.Destroy;
begin
  if FMPage <> nil then Close;
  MemStream.Free;//Add by me
  //LockedPages.Free;
  inherited;
end;

function TFreeMultiBitmap.IsPageLocked(Number:Integer): Boolean;
type Tintarray=array of integer;
var  arr:Tintarray;
  count:PINTEGER;
  n:word;
begin
new(count);
result:=GetLockedPageNumbers(nil,count)and(count^>0);
if result then begin
setlength(arr,count^);arr[0]:=count^;
result:=GetLockedPageNumbers(@(arr[0]),count);
  if result then begin
    result:=false;
    for n:=0 to count^-1 do
       if arr[n]=Number then begin
         result:=true;break;
       end;
  end;
end;
dispose(count);
end;

function TFreeMultiBitmap.GetLockedCount:integer;
begin GetLockedPageNumbers(nil,@result);end;

function TFreeMultiBitmap.GetLockedPageNumbers(var Pages,
  Count: Integer): Boolean;
begin
//if not IsValid then
Exit(False);
//Result := FreeImage_GetLockedPageNumbers(FMPage, Pages, Count)
end;

function TFreeMultiBitmap.GetLockedPageNumbers(pages,count: pinteger): Boolean;
begin
  if not IsValid then Exit(False);
  Result := FreeImage_GetLockedPageNumbers(FMPage, Pages, Count);
end;

function TFreeMultiBitmap.GetPageCount: Integer;
begin
  Result := 0;
  if IsValid then
    Result := FreeImage_GetPageCount(FMPage)
end;

//procedure TFreeMultiBitmap.InsertPage(Page: Integer; Bitmap: TFreeBitmap);
function TFreeMultiBitmap.InsertPage(Page: Integer; Bitmap: TFreeBitmap): Boolean;
var OldCount:integer;
begin
result:=false;
if (IsValid=false)or(Bitmap=nil)or(Bitmap.IsValid=false)  then exit;
{OldCount:=GetPageCount;
if OldCount=page then begin
  AppendPage(Bitmap);
end else begin}
FreeImage_InsertPage(FMPage, Page, Bitmap.FDib);
//end;
//LockedPages.Count:=GetPageCount;
{if OldCount<>LockedPages.Count then begin
LockedPages.Insert(Page,nil);//it insert as unlocked  }
result:=true;
//end;
end;

function TFreeMultiBitmap.IsValid: Boolean;
begin
  Result := FMPage <> nil
end;

//procedure TFreeMultiBitmap.LockPage(Page: Integer; DestBitmap: TFreeBitmap);
function TFreeMultiBitmap.LockPage(Page: Integer; DestBitmap: TFreeBitmap):boolean;
//var LockedPage:PFIBITMAP;
begin
if (not IsValid)or (DestBitmap=nil) then Exit(false);
result:=DestBitmap.Replace(FreeImage_LockPage(FMPage, Page));
{if Assigned(DestBitmap) then begin
  LockedPage:=FreeImage_LockPage(FMPage, Page);
  LockedPages[Page]:=LockedPage; //added by me
  DestBitmap.Replace(LockedPage);
  DestBitmap.FLockedNumber:=Page;
end;}
end;

function TFreeMultiBitmap.MovePage(Target, Source: Integer): Boolean;
begin
  Result := False;
  if not IsValid then Exit;
  Result := FreeImage_MovePage(FMPage, Target, Source);
end;

constructor TFreeMultiBitmap.CreatEmpty(fif: FREE_IMAGE_FORMAT;Flags: Integer);
var MemIO:TFreeMemoryIO;
begin
Create(true);
MemIO:=TFreeMemoryIO.Create();
if MemIO.IsValid then begin
 FMPage := MemIO.ReadMultiBitmap(fif, Flags);
 if IsValid then begin
   FMemIO:=MemIO;
   FReadOnly:=false;
   FOpenedFormat:=fif;
 end;
end else MemIO.Free;

end;

function TFreeMultiBitmap.Open(const FileName: FreeImageAnsiString; CreateNew,
  ReadOnly: Boolean; Flags: Integer): Boolean;
var
  fif: FREE_IMAGE_FORMAT;
begin
  Result := False;

// modif NOVAXEL
// In order to try to get the file format even if the extension is not standard,
// we check first the file signature
  fif := FreeImage_GetFileType(PAnsiChar(FileName), 0);

  if fif = FIF_UNKNOWN then
    // no signature?
// end of modif NOVAXEL
	// try to guess the file format from the filename
  	fif := FreeImage_GetFIFFromFilename(PAnsiChar(FileName));

  // check for supported file types
  if (fif <> FIF_UNKNOWN) and (not fif in TFreeMultiBitmapFormats) then
    Exit;

  // open the stream
  FMPage := FreeImage_OpenMultiBitmap(fif, PAnsiChar(FileName), CreateNew, ReadOnly, FMemoryCache, Flags);
  FOpenedFormat:=fif;//added by me
  //LockedPages.Count:=GetPageCount;
  Result := FMPage <> nil;
  FReadOnly:=ReadOnly;
end;

function TFreeMultiBitmap.LoadFromStream(Stream: TStream;Flags: Integer): Boolean;
var Size: Cardinal;
begin
  Result :=false;
  Stream.Position:=0;
  Size := Stream.Size;
  try
    MemStream.CopyFrom(Stream,Size);
    //MemStream.LoadFromStream(Stream);
    FMemIO := TFreeMemoryIO.Create(MemStream.Memory,MemStream.Size);
    try
      Result := LoadFromMemory(FMemIO,Flags);
    except
      FreeAndNil(FMemIO);
    end;
  except
    freeandnil(FMemIO);
    MemStream.Clear;
  end;
end;

function TFreeMultiBitmap.LoadFromMemory(MemIO: TFreeMemoryIO;Flag: Integer = 0): Boolean;
var
  fif: FREE_IMAGE_FORMAT;
begin
  // check the file signature and get its format
  fif := MemIO.GetFileType;
  if (fif <> FIF_UNKNOWN) and FreeImage_FIFSupportsReading(fif) and
     (fif in TFreeMultiBitmapFormats) then
  begin
    // free the previous dib
    if FMPage <> nil then close;
    //IFormat:=fif;
    // load the file
    FMPage := MemIO.ReadMultiBitmap(fif, Flag);
     //не всё отработано в чтении из памяти для multi
    Result := IsValid;
  end else
    Result := False;

if result then begin //added by me
  FOpenedFormat:=fif;
  //LockedPages.Count:=GetPageCount;
end else begin
  FOpenedFormat:=FIF_UNKNOWN;
  //LockedPages.Clear;
end;
FMemIO:=MemIO;
FReadOnly:=false;
end;

function TFreeMultiBitmap.LoadFromHandle(IO: PFreeImageIO; Handle: fi_handle; Flags: Integer = 0): Boolean;
var fif: FREE_IMAGE_FORMAT;
begin
fif:=FreeImage_GetFileTypeFromHandle(IO,Handle{,16});
if (fif <> FIF_UNKNOWN) and FreeImage_FIFSupportsReading(fif) and
       (fif in TFreeMultiBitmapFormats) then begin
  FMPage :=FreeImage_OpenMultiBitmapFromHandle(fif,IO,Handle,Flags);
  Result := IsValid;
end else result:=false;

if result then begin //added by me
  FOpenedFormat:=fif;
  //LockedPages.Count:=GetPageCount;
end else begin
  FOpenedFormat:=FIF_UNKNOWN;
//  LockedPages.Clear;
end;
end;

function TFreeMultiBitmap.SaveToMemory(fif: FREE_IMAGE_FORMAT;MemIO:TFreeMemoryIO; flags: Integer=0): Boolean;
begin
{//Проверки как на freebitmap}
result:=MemIO.WriteMultiBitmap(fif,FMPage,flags);
end;

function TFreeMultiBitmap.SaveToStream(fif: FREE_IMAGE_FORMAT;Stream: TStream; Flags: Integer = 0): Boolean;
var SaveMemo:TFreeMemoryIO;
Pdata:Pbyte;
count:cardinal;
begin
SaveMemo:=TFreeMemoryIO.Create();
if SaveToMemory(fif,SaveMemo,Flags)then begin
  Pdata:=nil;count:=0;
  try
    result:=SaveMemo.Acquire(Pdata,count)and boolean(Stream.Write(Pdata^,count));
  except
   result:=false;
  end;
end;
SaveMemo.Free;
end;

function TFreeMultiBitmap.UnlockPage(Bitmap: TFreeBitmap;Changed: Boolean): Boolean;
var num:word;
n:integer;
begin
result:=false;
if (Bitmap=nil)or(Bitmap.IsValid=false)or(IsValid=false)then exit;
if Bitmap.FromMultiImage=false then exit;
FreeImage_UnlockPage(FMPage, Bitmap.FDib, Changed);
//LockedPages[Bitmap.LockedNumber]:=nil;
// clear the image so that it becomes invalid.
// don't use Bitmap.Clear method because it calls FreeImage_Unload
// just clear the pointer
Bitmap.FDib := nil;
Bitmap.FFromMultipage:=nil;
//Bitmap.FLockedNumber:=NoPageNumber;
Bitmap.Change;
result:=true;
end;

{function TFreeMultiBitmap.GetLostDib(Number:word):PFIBITMAP;
begin
{if (LockedPages)>Number+1 then} result:=LockedPages[Number];
end;}

{ TFreeMemoryIO }

function TFreeMemoryIO.Acquire(var Data: PByte;
  var SizeInBytes: DWORD): Boolean;
begin
  Result := FreeImage_AcquireMemory(FHMem, Data, SizeInBytes);
end;

constructor TFreeMemoryIO.Create(Data: PByte; SizeInBytes: DWORD);
begin
  inherited Create;
  FHMem := FreeImage_OpenMemory(Data, SizeInBytes);
end;

destructor TFreeMemoryIO.Destroy;
begin
  FreeImage_CloseMemory(FHMem);
  inherited;
end;

function TFreeMemoryIO.GetFileType: FREE_IMAGE_FORMAT;
begin
  Result := FreeImage_GetFileTypeFromMemory(FHMem);
end;

function TFreeMemoryIO.IsValid: Boolean;
begin
  Result := FHMem <> nil
end;

function TFreeMemoryIO.Read(fif: FREE_IMAGE_FORMAT;
  Flag: Integer): PFIBITMAP;
begin
  Result := FreeImage_LoadFromMemory(fif, FHMem, Flag)
end;

function TFreeMemoryIO.ReadMultiBitmap(fif: FREE_IMAGE_FORMAT; Flag: Integer = 0): PFIMULTIBITMAP;
begin
  Result := FreeImage_LoadMultiBitmapFromMemory(fif, FHMem, Flag);
end;

function TFreeMemoryIO.WriteMultiBitmap(fif: FREE_IMAGE_FORMAT; Mdib: PFIMULTIBITMAP;
  Flags: Integer = 0): Boolean;
begin
result:=FreeImage_SaveMultiBitmapToMemory(fif,Mdib,FHMem,Flags);
end;

function TFreeMemoryIO.Seek(Offset: Longint; Origin: Word): Boolean;
begin
  Result := FreeImage_SeekMemory(FHMem, Offset, Origin)
end;

function TFreeMemoryIO.Tell: Longint;
begin
  Result := FreeImage_TellMemory(FHMem)
end;

function TFreeMemoryIO.Write(fif: FREE_IMAGE_FORMAT; dib: PFIBITMAP;
  Flag: Integer): Boolean;
begin
  Result := FreeImage_SaveToMemory(fif, dib, FHMem, Flag)
end;

{ TFreeTag }

function TFreeTag.Clone: TFreeTag;
var
  CloneTag: PFITAG;
begin
  Result := nil;
  if not IsValid then Exit;

  CloneTag := FreeImage_CloneTag(FTag);
  Result := TFreeTag.Create(CloneTag);
end;

constructor TFreeTag.Create(ATag: PFITAG);
begin
  inherited Create;

  if ATag <> nil then
    FTag := ATag
  else
    FTag := FreeImage_CreateTag;
end;

destructor TFreeTag.Destroy;
begin
  if IsValid then
    FreeImage_DeleteTag(FTag);
    
  inherited;
end;

function TFreeTag.GetCount: Cardinal;
begin
  Result := 0;
  if not IsValid then Exit;

  Result := FreeImage_GetTagCount(FTag);
end;

function TFreeTag.GetDescription: AnsiString;
begin
  Result := '';
  if not IsValid then Exit;

  Result := FreeImage_GetTagDescription(FTag);
end;

function TFreeTag.GetID: Word;
begin
  Result := 0;
  if not IsValid then Exit;

  Result := FreeImage_GetTagID(FTag);
end;

function TFreeTag.GetKey: AnsiString;
begin
  Result := '';
  if not IsValid then Exit;

  Result := FreeImage_GetTagKey(FTag);
end;

function TFreeTag.GetLength: Cardinal;
begin
  Result := 0;
  if not IsValid then Exit;

  Result := FreeImage_GetTagLength(FTag);
end;

function TFreeTag.GetTagType: FREE_IMAGE_MDTYPE;
begin
  Result := FIDT_NOTYPE;
  if not IsValid then Exit;

  Result := FreeImage_GetTagType(FTag);
end;

function TFreeTag.GetValue: Pointer;
begin
  Result := nil;
  if not IsValid then Exit;

  Result := FreeImage_GetTagValue(FTag);
end;

function TFreeTag.IsValid: Boolean;
begin
  Result := FTag <> nil;
end;

procedure TFreeTag.SetCount(const Value: Cardinal);
begin
  if IsValid then
    FreeImage_SetTagCount(FTag, Value);
end;

procedure TFreeTag.SetDescription(const Value: AnsiString);
begin
  if IsValid then
    FreeImage_SetTagDescription(FTag, PAnsiChar(Value));
end;

procedure TFreeTag.SetID(const Value: Word);
begin
  if IsValid then
    FreeImage_SetTagID(FTag, Value);
end;

procedure TFreeTag.SetKey(const Value: AnsiString);
begin
  if IsValid then
    FreeImage_SetTagKey(FTag, PAnsiChar(Value));
end;

procedure TFreeTag.SetLength(const Value: Cardinal);
begin
  if IsValid then
    FreeImage_SetTagLength(FTag, Value);
end;

procedure TFreeTag.SetTagType(const Value: FREE_IMAGE_MDTYPE);
begin
  if IsValid then
    FreeImage_SetTagType(FTag, Value);
end;

procedure TFreeTag.SetValue(const Value: Pointer);
begin
  if IsValid then
    FreeImage_SetTagValue(FTag, Value);
end;

function TFreeTag.ToString(Model: FREE_IMAGE_MDMODEL; Make: PAnsiChar): AnsiString;
begin
  Result := FreeImage_TagToString(Model, FTag, Make);
end;

//---------------------------------------- CACHE

procedure TFreeCacheElement.clear;begin
//FreeAndNil(ModifiedImage);
if ModifiedImage <> nil then begin
  FreeImage_Unload(ModifiedImage);ModifiedImage := nil;
end;
end;

destructor TFreeCacheElement.Destroy;begin clear;inherited;end;

constructor TFreeCacheElement.Create(OriginalPage:integer);
begin inherited Create;OriginalPageIndex:=OriginalPage;end;

function TFreeCacheElement.IsEmpty:boolean;
begin result:=ModifiedImage=nil;end;


{constructor TFreeMultiBitmapCache.Create(AMultiBitmap:TFreeMultiBitmap);
var n:word;
begin
  inherited Create;
  CachedItems:=TFPList.Create;
  FMultiBitmap:=AMultiBitmap;
  CachedItems.Count:=FMultiBitmap.GetPageCount;
  //procedure fill original ?
  if CachedItems.Count >0 then
    for n:=0 to CachedItems.Count-1 do begin
       CachedItems[n]:=TFreeCacheElement.Create(n);
    end;
  //
end;}

{constructor TFreeMultiBitmapCache.Create(PagesCount:Word);
begin
  inherited Create;
  CachedItems:=TFPList.Create;
  //FMultiBitmap:=AMultiBitmap;
  CachedItems.Count:=PagesCount;
  //procedure fill original ?
  if CachedItems.Count >0 then
    for n:=0 to CachedItems.Count-1 do begin
       CachedItems[n]:=TFreeCacheElement.Create(n);
    end;
  //
end;}

{destructor TFreeMultiBitmapCache.Destroy;
begin
  Clear;
  CachedItems.Free;
  inherited;
end;}

{procedure TFreeMultiBitmapCache.Clear;
var n:integer;
begin
if CachedItems.Count>0 then begin
  for n:=0 to CachedItems.Count-1 do begin
    if assigned(CachedItems[n]) then begin//FreeAndNil(TFreeCacheElement(CachedItems.Items[n]));
      TFreeCacheElement(CachedItems.Items[n]).clear;{CachedItems[n]:=nil;}
    end;
  end;
end;
{CachedItems.Count:=FMultiBitmap.GetPageCount;
//procedure fill original ?
  if CachedItems.Count >0 then
    for n:=0 to CachedItems.Count-1 do begin
       CachedItems[n]:=TFreeCacheElement.Create(n);
    end;
  //}
end;}

{function TFreeMultiBitmapCache.GetCacheElement(index:word):TFreeCacheElement;
begin result:=TFreeCacheElement(CachedItems[index]);end;

{function TFreeMultiBitmapCache.GetCount:word;
begin result:=CachedItems.Count; end;}

procedure TFreeMultiBitmapCache.LockPage(Page: Integer; DestBitmap: TFreeBitmap);
var cached:TFreeCacheElement;
begin
if (page>=CachedItems.Count)or (DestBitmap=nil) then exit;
cached:=TFreeCacheElement(CachedItems[page]);
if cached.IsEmpty and (FMultiBitmap.IsPageLocked(Page)=false) then begin
  FMultiBitmap.LockPage(cached.OriginalPageIndex,DestBitmap);
end else begin
  DestBitmap.Replace(cached.ModifiedImage);
  DestBitmap.FLockedNumber:=Page;//not used in TFreeMultiBitmapCache
end;
end;

function TFreeMultiBitmapCache.UnlockPage(Bitmap: TFreeBitmap;DiscardAllchanges:boolean=false): Boolean;
var cachedIndex,n:integer;
  cached:TFreeCacheElement;
  forgoten:PFIBITMAP;////memory leak check:
begin
forgoten:=Bitmap.FDib;//for memory leak check
result:=false;
if (Bitmap=nil)or(Bitmap.IsValid=false)or(FMultiBitmap.IsValid=false)or(CachedItems.Count=0)then exit;
if DiscardAllchanges then result:=FMultiBitmap.UnlockPage(Bitmap,false)
else begin Bitmap.FDib:=nil;Bitmap.Change;end;

//memory leak check:
 cachedIndex:=-1;
 for n:=0 to CachedItems.Count-1 do begin
  cached:=GetCacheElement(n);
  if cached.ModifiedImage=forgoten then begin
    cachedIndex:=n;break;
  end;
end;
if cachedIndex>=0 then result:=true;//no memory leak
end;}





//----------------------------------------
constructor TCachedFreeMultiBitmap.Create();
begin
  inherited Create(true);
  CacheList:=TFPList.Create;
end;

destructor TCachedFreeMultiBitmap.Destroy;
begin
close;ClearCache;
CacheList.Free;
  inherited;
end;

function TCachedFreeMultiBitmap.Close(Flags: Integer): Boolean;
//var n:integer;
begin
if IsValid=false then exit(true);
//n:=GetLockedCount;
//if (n>0) then exit(false);
result:=inherited;
if result then ClearCache;
end;

function TCachedFreeMultiBitmap.LockPage(Page: Integer; DestBitmap: TFreeBitmap):boolean;
var cached:TFreeCacheElement;
begin
if (page>=self.CacheList.Count)or (DestBitmap=nil) then exit;
cached:=CacheElement(page);
if cached.IsEmpty then begin
  result:=inherited LockPage(cached.OriginalPageIndex,DestBitmap);
  cached.OriginalImage:=DestBitmap.Dib;
end else begin
  DestBitmap.Replace(cached.ModifiedImage);
  cached.ModifiedIsLocked:=true;
end;
//DestBitmap.FLockedNumber:=Page;
DestBitmap.FFromMultipage:=self;
end;

function TCachedFreeMultiBitmap.Replace(Page: Integer; Bitmap: TFreeBitmap): Boolean;
var cached:TFreeCacheElement;
begin
if (not IsValid)or(Page>=GetPageCount)or(Bitmap=nil)or(not Bitmap.IsValid)then exit(false);
cached:=CacheElement(page);
if (cached.ModifiedIsLocked)or(IsPageLocked(cached.OriginalPageIndex)) then exit(false);

if not cached.IsEmpty then FreeImage_Unload(cached.ModifiedImage);
cached.ModifiedImage:=FreeImage_Clone(Bitmap.FDib);
result:=true;
end;

function TCachedFreeMultiBitmap.DeletePage(Page: Integer): Boolean;
var cached:TFreeCacheElement;
begin
result:=false;
if (IsValid=false)or(Page>=GetPageCount) then exit;
cached:=CacheElement(page);
if (cached.ModifiedIsLocked)or(IsPageLocked(cached.OriginalPageIndex)) then exit(false);
if not cached.IsEmpty then begin
FreeImage_Unload(cached.ModifiedImage);
cached.ModifiedImage:=nil;
end;
cached.Free;
CacheList.Delete(page);
result:=true;
end;

function TCachedFreeMultiBitmap.InsertPage(Page: Integer; Bitmap: TFreeBitmap): Boolean;
var NewCachedElement:TFreeCacheElement;
begin
if(not IsValid)or(Bitmap=nil)or(not Bitmap.IsValid)then exit(false);
NewCachedElement:=TFreeCacheElement.Create(-1);
NewCachedElement.ModifiedImage:=FreeImage_Clone(Bitmap.FDib);
if Page>=GetPageCount then self.CacheList.Add(NewCachedElement)
else CacheList.Insert(page,NewCachedElement);
result:=true;
end;

procedure TCachedFreeMultiBitmap.AppendPage(Bitmap: TFreeBitmap);
begin InsertPage(GetPageCount,Bitmap);end;

function TCachedFreeMultiBitmap.UnlockPage(Bitmap: TFreeBitmap;Changed:boolean): Boolean;
var cachedIndex,n:integer;
cached:TFreeCacheElement;
Clone:PFIBITMAP;
begin
result:=false;
if (Bitmap=nil)or(Bitmap.IsValid=false)or(IsValid=false)then exit;
if Bitmap.FromMultiImage=false then exit;//был не с нашего района
cachedIndex:=-1;
for n:=0 to CacheList.Count-1 do begin
  cached:=CacheElement(n);
  if (cached.ModifiedImage=Bitmap.FDib)or(cached.OriginalImage=Bitmap.FDib) then begin
    cachedIndex:=n;break;
  end;
end;
if cachedIndex<0 then exit;//не с нашего района

if cached.ModifiedImage=Bitmap.FDib then begin
  cached.ModifiedIsLocked:=false;
  Bitmap.FDib:=nil;Bitmap.Change;
  result:=true;
end else begin
  if Changed then cached.ModifiedImage := FreeImage_Clone(Bitmap.FDib);
  result:=inherited UnlockPage(Bitmap,false);
  if result then cached.OriginalImage:=nil;
end;

end;

function TCachedFreeMultiBitmap.Open(const FileName: FreeImageAnsiString; CreateNew, ReadOnly: Boolean;
                 Flags: Integer = 0): Boolean;
begin
result:=inherited Open(FileName,false,true,Flags);
if result then begin
InitCache(GetPageCount);
end;
end;

function TCachedFreeMultiBitmap.LoadFromMemory(MemIO: TFreeMemoryIO;Flag: Integer = 0): Boolean;
begin
result:=inherited;
if result then begin
  InitCache(inherited GetPageCount);
end;
end;

function TCachedFreeMultiBitmap.SaveToMemory(fif: FREE_IMAGE_FORMAT;MemIO:TFreeMemoryIO; flags: Integer=0): Boolean;
var n:integer;
NewMulti:TFreeMultiBitmap;
PageToWrite:PFIBITMAP;
begin
result:=false;
if (GetLockedCount>0)or(CacheList.Count<1)then exit;
NewMulti:=TFreeMultiBitmap.CreatEmpty(fif,flags);
if NewMulti.IsValid=false then exit;
for n:=0 to CacheList.Count-1 do begin //CacheList.Count should be always equal to current GetPageCount
  if CacheElement(n).IsEmpty then begin
    PageToWrite:=FreeImage_LockPage(FMPage,CacheElement(n).OriginalPageIndex);
    FreeImage_AppendPage(NewMulti.FMPage,PageToWrite);
    FreeImage_UnlockPage(FMPage,PageToWrite,false);
  end else begin
    FreeImage_AppendPage(NewMulti.FMPage,CacheElement(n).ModifiedImage);
  end;
end;
result:=NewMulti.SaveToMemory(fif,MemIO,flags);
NewMulti.Destroy;
end;

procedure TCachedFreeMultiBitmap.ClearCache;
var n:integer;
begin
if CacheList.Count>0 then begin
  for n:=0 to CacheList.Count-1 do begin
    if assigned(CacheList[n]) then begin
      TFreeCacheElement(CacheList.Items[n]).clear;
    end;
  end;
end;
end;

function TCachedFreeMultiBitmap.LoadFromHandle(IO: PFreeImageIO; Handle: fi_handle; Flags: Integer = 0): Boolean;
begin result:=false;end;

function TCachedFreeMultiBitmap.CacheIsclean:boolean;
var n:word;
begin
if CacheList.Count<1 then exit(true);
for n:=0 to CacheList.Count-1 do
  if TFreeCacheElement(CacheList[n]).IsEmpty=false then exit(false);
result:=true;
end;

procedure TCachedFreeMultiBitmap.InitCache(PagesCount:Word);
var n:word;
begin
CacheList.Count:=PagesCount;
  if CacheList.Count >0 then
    for n:=0 to CacheList.Count-1 do begin
       CacheList[n]:=TFreeCacheElement.Create(n);
    end;
end;

function TCachedFreeMultiBitmap.GetPageCount: Integer;
begin
  if IsValid then Result :=CacheList.Count else result:=0;
end;

function TCachedFreeMultiBitmap.MovePage(Target, Source: Integer): Boolean;
begin
if (not IsValid)or(Source>=GetPageCount)or(Target>=GetPageCount)then exit(false);
CacheList.Move(Source,Target);
result:=true;
end;

function TCachedFreeMultiBitmap.CacheElement(index:word):TFreeCacheElement;
begin result:=TFreeCacheElement(CacheList[index]);end;

constructor TCachedFreeMultiBitmap.CreatEmpty(fif: FREE_IMAGE_FORMAT;Flags: Integer=0);
begin inherited;CacheList:=TFPList.Create;end;

begin
  SizeOfPFIBITMAP:=sizeof(PFIBITMAP);
end.
{$ASSERTIONS OFF}
