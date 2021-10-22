unit DynFreeImage;

// Use at your own risk!

{ This unit is based on the original FreeBitmap.pas
from FreeImage Delphi Wrapper
http://www.tech-mash.narod.ru/
types for non windows moved by Lcltype
Add by me  FreeImage_GetLockedPageNumbers with Pinteger parameter
}

interface

{$MINENUMSIZE 4} // Make sure enums are stored as an integer to be compatible with C/C++
{$ASSERTIONS ON}


uses portabledynlib
{$IFDEF LCL}
 ,Lcltype
 {$ENDIF}
;
{$IFNDEF LCL}
{$I 'DynFreeImage.inc'}
{$ENDIF}

{$IFDEF MSWINDOWS}
type
  FreeImageAnsiString = AnsiString;

{$ELSE}
type
  FreeImageAnsiString = UTF8String;
{$ENDIF}

const //FIDLL = 'FreeImage';
  EXTENSIONS_SEPARATOR=',';
  // Version information
  FREEIMAGE_MAJOR_VERSION  = 3;
  FREEIMAGE_MINOR_VERSION  = 18;
  FREEIMAGE_RELEASE_SERIAL = 0;
  // This really only affects 24 and 32 bit formats, the rest are always RGB order.
  FREEIMAGE_COLORORDER_BGR = 0;
  FREEIMAGE_COLORORDER_RGB = 1;
  FREEIMAGE_COLORORDER = FREEIMAGE_COLORORDER_BGR;

// --------------------------------------------------------------------------
// Bitmap types -------------------------------------------------------------
// --------------------------------------------------------------------------

type
  FIBITMAP = record
    data: Pointer;
  end;
  PFIBITMAP = ^FIBITMAP;

  FIMULTIBITMAP = record
    data: Pointer;
  end;
  PFIMULTIBITMAP = ^FIMULTIBITMAP;

// --------------------------------------------------------------------------
// Types used in the library (specific to FreeImage) ------------------------
// --------------------------------------------------------------------------

type
  {* 48-bit RGB }
  tagFIRGB16 = packed record
    red: WORD;
    green: WORD;
    blue: WORD;
  end;
  FIRGB16 = tagFIRGB16;

  {* 64-bit RGBA }
  tagFIRGBA16 = packed record
    red: WORD;
    green: WORD;
    blue: WORD;
    alpha: WORD;
  end;
  FIRGBA16 = tagFIRGBA16;

  {* 96-bit RGB Float }
  tagFIRGBF = packed record
    red: Single;
    green: Single;
    blue: Single;
  end;
  FIRGBF = tagFIRGBF;

  {* 128-bit RGBA Float }
  tagFIRGBAF = packed record
    red: Single;
    green: Single;
    blue: Single;
    alpha: Single;
  end;
  FIRGBAF = tagFIRGBAF;

  {* Data structure for COMPLEX type (complex number) }
  tagFICOMPLEX = packed record
    /// real part
    r: Double;
    /// imaginary part
    i: Double;
  end;
  FICOMPLEX = tagFICOMPLEX;

// --------------------------------------------------------------------------
// Indexes for byte arrays, masks and shifts for treating pixels as words ---
// These coincide with the order of RGBQUAD and RGBTRIPLE -------------------
// Little Endian (x86 / MS Windows, Linux) : BGR(A) order -------------------
// --------------------------------------------------------------------------

const
  FI_RGBA_RED         = 2;
  FI_RGBA_GREEN       = 1;
  FI_RGBA_BLUE        = 0;
  FI_RGBA_ALPHA       = 3;
  FI_RGBA_RED_MASK    = $00FF0000;
  FI_RGBA_GREEN_MASK  = $0000FF00;
  FI_RGBA_BLUE_MASK   = $000000FF;
  FI_RGBA_ALPHA_MASK  = $FF000000;
  FI_RGBA_RED_SHIFT   = 16;
  FI_RGBA_GREEN_SHIFT = 8;
  FI_RGBA_BLUE_SHIFT  = 0;
  FI_RGBA_ALPHA_SHIFT = 24;

  FI_RGBA_RGB_MASK = FI_RGBA_RED_MASK or FI_RGBA_GREEN_MASK or FI_RGBA_BLUE_MASK;

// --------------------------------------------------------------------------
// The 16bit macros only include masks and shifts, --------------------------
// since each color element is not byte aligned -----------------------------
// --------------------------------------------------------------------------

const
  FI16_555_RED_MASK    = $7C00;
  FI16_555_GREEN_MASK  = $03E0;
  FI16_555_BLUE_MASK   = $001F;
  FI16_555_RED_SHIFT   = 10;
  FI16_555_GREEN_SHIFT = 5;
  FI16_555_BLUE_SHIFT  = 0;
  FI16_565_RED_MASK    = $F800;
  FI16_565_GREEN_MASK  = $07E0;
  FI16_565_BLUE_MASK   = $001F;
  FI16_565_RED_SHIFT   = 11;
  FI16_565_GREEN_SHIFT = 5;
  FI16_565_BLUE_SHIFT  = 0;

// --------------------------------------------------------------------------
// ICC profile support ------------------------------------------------------
// --------------------------------------------------------------------------

const
  FIICC_DEFAULT = $0;
  FIICC_COLOR_IS_CMYK = $1;

type
  FIICCPROFILE = packed record
    flags: WORD;   // info flag
    size: DWORD;   // profile's size measured in bytes
    data: Pointer; // points to a block of contiguous memory containing the profile
  end;
  PFIICCPROFILE = ^FIICCPROFILE;

// --------------------------------------------------------------------------
// Important enums ----------------------------------------------------------
// --------------------------------------------------------------------------

type
  FREE_IMAGE_FORMAT         = type Integer;
  FREE_IMAGE_TYPE           = type Integer;
  FREE_IMAGE_COLOR_TYPE     = type Integer;
  FREE_IMAGE_QUANTIZE       = type Integer;
  FREE_IMAGE_DITHER         = type Integer;
  FREE_IMAGE_FILTER         = type Integer;
  FREE_IMAGE_COLOR_CHANNEL  = type Integer;
  FREE_IMAGE_MDTYPE         = type Integer;
  FREE_IMAGE_MDMODEL        = type Integer;
  FREE_IMAGE_JPEG_OPERATION = type Integer;
  FREE_IMAGE_TMO            = type Integer;

const
  // I/O image format identifiers.
  FIF_UNKNOWN = FREE_IMAGE_FORMAT(-1);
  FIF_BMP     = FREE_IMAGE_FORMAT(0);
  FIF_ICO     = FREE_IMAGE_FORMAT(1);
  FIF_JPEG    = FREE_IMAGE_FORMAT(2);
  FIF_JNG     = FREE_IMAGE_FORMAT(3);
  FIF_KOALA   = FREE_IMAGE_FORMAT(4);
  FIF_LBM     = FREE_IMAGE_FORMAT(5);
  FIF_IFF     = FIF_LBM;
  FIF_MNG     = FREE_IMAGE_FORMAT(6);
  FIF_PBM     = FREE_IMAGE_FORMAT(7);
  FIF_PBMRAW  = FREE_IMAGE_FORMAT(8);
  FIF_PCD     = FREE_IMAGE_FORMAT(9);
  FIF_PCX     = FREE_IMAGE_FORMAT(10);
  FIF_PGM     = FREE_IMAGE_FORMAT(11);
  FIF_PGMRAW  = FREE_IMAGE_FORMAT(12);
  FIF_PNG     = FREE_IMAGE_FORMAT(13);
  FIF_PPM     = FREE_IMAGE_FORMAT(14);
  FIF_PPMRAW  = FREE_IMAGE_FORMAT(15);
  FIF_RAS     = FREE_IMAGE_FORMAT(16);
  FIF_TARGA   = FREE_IMAGE_FORMAT(17);
  FIF_TIFF    = FREE_IMAGE_FORMAT(18);
  FIF_WBMP    = FREE_IMAGE_FORMAT(19);
  FIF_PSD     = FREE_IMAGE_FORMAT(20);
  FIF_CUT     = FREE_IMAGE_FORMAT(21);
  FIF_XBM     = FREE_IMAGE_FORMAT(22);
  FIF_XPM     = FREE_IMAGE_FORMAT(23);
  FIF_DDS     = FREE_IMAGE_FORMAT(24);
  FIF_GIF     = FREE_IMAGE_FORMAT(25);
  FIF_HDR     = FREE_IMAGE_FORMAT(26);
  FIF_FAXG3   = FREE_IMAGE_FORMAT(27);
  FIF_SGI     = FREE_IMAGE_FORMAT(28);
  FIF_EXR     = FREE_IMAGE_FORMAT(29);
  FIF_J2K     = FREE_IMAGE_FORMAT(30);
  FIF_JP2     = FREE_IMAGE_FORMAT(31);
  FIF_PFM     = FREE_IMAGE_FORMAT(32);
  FIF_PICT    = FREE_IMAGE_FORMAT(33);
  FIF_RAW     = FREE_IMAGE_FORMAT(34);
  FIF_WEBP    = FREE_IMAGE_FORMAT(35);
  FIF_JXR     = FREE_IMAGE_FORMAT(36);

  // Image type used in FreeImage.
  FIT_UNKNOWN = FREE_IMAGE_TYPE(0);  // unknown type
  FIT_BITMAP  = FREE_IMAGE_TYPE(1);  // standard image: 1-, 4-, 8-, 16-, 24-, 32-bit
  FIT_UINT16  = FREE_IMAGE_TYPE(2);  // array of unsigned short: unsigned 16-bit
  FIT_INT16   = FREE_IMAGE_TYPE(3);  // array of short: signed 16-bit
  FIT_UINT32  = FREE_IMAGE_TYPE(4);  // array of unsigned long: unsigned 32-bit
  FIT_INT32   = FREE_IMAGE_TYPE(5);  // array of long: signed 32-bit
  FIT_FLOAT   = FREE_IMAGE_TYPE(6);  // array of float: 32-bit IEEE floating point
  FIT_DOUBLE  = FREE_IMAGE_TYPE(7);  // array of double: 64-bit IEEE floating point
  FIT_COMPLEX = FREE_IMAGE_TYPE(8);  // array of FICOMPLEX: 2 x 64-bit IEEE floating point
  FIT_RGB16   = FREE_IMAGE_TYPE(9);  // 48-bit RGB image: 3 x 16-bit
  FIT_RGBA16  = FREE_IMAGE_TYPE(10); // 64-bit RGBA image: 4 x 16-bit
  FIT_RGBF    = FREE_IMAGE_TYPE(11); // 96-bit RGB float image: 3 x 32-bit IEEE floating point
  FIT_RGBAF   = FREE_IMAGE_TYPE(12); // 128-bit RGBA float image: 4 x 32-bit IEEE floating point

  // Image color type used in FreeImage.
  FIC_MINISWHITE = FREE_IMAGE_COLOR_TYPE(0); // min value is white
  FIC_MINISBLACK = FREE_IMAGE_COLOR_TYPE(1); // min value is black
  FIC_RGB        = FREE_IMAGE_COLOR_TYPE(2); // RGB color model
  FIC_PALETTE    = FREE_IMAGE_COLOR_TYPE(3); // color map indexed
  FIC_RGBALPHA   = FREE_IMAGE_COLOR_TYPE(4); // RGB color model with alpha channel
  FIC_CMYK       = FREE_IMAGE_COLOR_TYPE(5); // CMYK color model

  // Color quantization algorithms. Constants used in FreeImage_ColorQuantize.
  FIQ_WUQUANT = FREE_IMAGE_QUANTIZE(0); // Xiaolin Wu color quantization algorithm
  FIQ_NNQUANT = FREE_IMAGE_QUANTIZE(1); // NeuQuant neural-net quantization algorithm by Anthony Dekker
  FIQ_LFPQUANT = FREE_IMAGE_QUANTIZE(2); // Lossless Fast Pseudo-Quantization Algorithm by Carsten Klein

  // Dithering algorithms. Constants used FreeImage_Dither.
  FID_FS            = FREE_IMAGE_DITHER(0); // Floyd & Steinberg error diffusion
  FID_BAYER4x4      = FREE_IMAGE_DITHER(1); // Bayer ordered dispersed dot dithering (order 2 dithering matrix)
  FID_BAYER8x8      = FREE_IMAGE_DITHER(2); // Bayer ordered dispersed dot dithering (order 3 dithering matrix)
  FID_CLUSTER6x6    = FREE_IMAGE_DITHER(3); // Ordered clustered dot dithering (order 3 - 6x6 matrix)
  FID_CLUSTER8x8    = FREE_IMAGE_DITHER(4); // Ordered clustered dot dithering (order 4 - 8x8 matrix)
  FID_CLUSTER16x16  = FREE_IMAGE_DITHER(5); // Ordered clustered dot dithering (order 8 - 16x16 matrix)
  FID_BAYER16x16    = FREE_IMAGE_DITHER(6); // Bayer ordered dispersed dot dithering (order 4 dithering matrix)

  // Lossless JPEG transformations Constants used in FreeImage_JPEGTransform
  FIJPEG_OP_NONE        = FREE_IMAGE_JPEG_OPERATION(0); // no transformation
  FIJPEG_OP_FLIP_H      = FREE_IMAGE_JPEG_OPERATION(1); // horizontal flip
  FIJPEG_OP_FLIP_V      = FREE_IMAGE_JPEG_OPERATION(2); // vertical flip
  FIJPEG_OP_TRANSPOSE   = FREE_IMAGE_JPEG_OPERATION(3); // transpose across UL-to-LR axis
  FIJPEG_OP_TRANSVERSE  = FREE_IMAGE_JPEG_OPERATION(4); // transpose across UR-to-LL axis
  FIJPEG_OP_ROTATE_90   = FREE_IMAGE_JPEG_OPERATION(5); // 90-degree clockwise rotation
  FIJPEG_OP_ROTATE_180  = FREE_IMAGE_JPEG_OPERATION(6); // 180-degree rotation
  FIJPEG_OP_ROTATE_270  = FREE_IMAGE_JPEG_OPERATION(7); // 270-degree clockwise (or 90 ccw)

  // Tone mapping operators. Constants used in FreeImage_ToneMapping.
  FITMO_DRAGO03    = FREE_IMAGE_TMO(0); // Adaptive logarithmic mapping (F. Drago, 2003)
  FITMO_REINHARD05 = FREE_IMAGE_TMO(1); // Dynamic range reduction inspired by photoreceptor physiology (E. Reinhard, 2005)
  FITMO_FATTAL02   = FREE_IMAGE_TMO(2); // Gradient domain high dynamic range compression (R. Fattal, 2002)

  // Upsampling / downsampling filters. Constants used in FreeImage_Rescale.
  FILTER_BOX        = FREE_IMAGE_FILTER(0); // Box, pulse, Fourier window, 1st order (constant) b-spline
  FILTER_BICUBIC    = FREE_IMAGE_FILTER(1); // Mitchell & Netravali's two-param cubic filter
  FILTER_BILINEAR   = FREE_IMAGE_FILTER(2); // Bilinear filter
  FILTER_BSPLINE    = FREE_IMAGE_FILTER(3); // 4th order (cubic) b-spline
  FILTER_CATMULLROM = FREE_IMAGE_FILTER(4); // Catmull-Rom spline, Overhauser spline
  FILTER_LANCZOS3   = FREE_IMAGE_FILTER(5); // Lanczos3 filter

  // Color channels. Constants used in color manipulation routines.
  FICC_RGB   = FREE_IMAGE_COLOR_CHANNEL(0); // Use red, green and blue channels
  FICC_RED   = FREE_IMAGE_COLOR_CHANNEL(1); // Use red channel
  FICC_GREEN = FREE_IMAGE_COLOR_CHANNEL(2); // Use green channel
  FICC_BLUE  = FREE_IMAGE_COLOR_CHANNEL(3); // Use blue channel
  FICC_ALPHA = FREE_IMAGE_COLOR_CHANNEL(4); // Use alpha channel
  FICC_BLACK = FREE_IMAGE_COLOR_CHANNEL(5); // Use black channel
  FICC_REAL  = FREE_IMAGE_COLOR_CHANNEL(6); // Complex images: use real part
  FICC_IMAG  = FREE_IMAGE_COLOR_CHANNEL(7); // Complex images: use imaginary part
  FICC_MAG   = FREE_IMAGE_COLOR_CHANNEL(8); // Complex images: use magnitude
  FICC_PHASE = FREE_IMAGE_COLOR_CHANNEL(9); // Complex images: use phase

  // Tag data type information (based on TIFF specifications)
  FIDT_NOTYPE    = FREE_IMAGE_MDTYPE(0);  // placeholder
  FIDT_BYTE      = FREE_IMAGE_MDTYPE(1);  // 8-bit unsigned integer
  FIDT_ASCII     = FREE_IMAGE_MDTYPE(2);  // 8-bit bytes w/ last byte null
  FIDT_SHORT     = FREE_IMAGE_MDTYPE(3);  // 16-bit unsigned integer
  FIDT_LONG      = FREE_IMAGE_MDTYPE(4);  // 32-bit unsigned integer
  FIDT_RATIONAL  = FREE_IMAGE_MDTYPE(5);  // 64-bit unsigned fraction
  FIDT_SBYTE     = FREE_IMAGE_MDTYPE(6);  // 8-bit signed integer
  FIDT_UNDEFINED = FREE_IMAGE_MDTYPE(7);  // 8-bit untyped data
  FIDT_SSHORT    = FREE_IMAGE_MDTYPE(8);  // 16-bit signed integer
  FIDT_SLONG     = FREE_IMAGE_MDTYPE(9);  // 32-bit signed integer
  FIDT_SRATIONAL = FREE_IMAGE_MDTYPE(10); // 64-bit signed fraction
  FIDT_FLOAT     = FREE_IMAGE_MDTYPE(11); // 32-bit IEEE floating point
  FIDT_DOUBLE    = FREE_IMAGE_MDTYPE(12); // 64-bit IEEE floating point
  FIDT_IFD       = FREE_IMAGE_MDTYPE(13); // 32-bit unsigned integer (offset)
  FIDT_PALETTE   = FREE_IMAGE_MDTYPE(14); // 32-bit RGBQUAD
  FIDT_LONG8     = FREE_IMAGE_MDTYPE(16); // 64-bit unsigned integer
  FIDT_SLONG8    = FREE_IMAGE_MDTYPE(17); // 64-bit signed integer
  FIDT_IFD8      = FREE_IMAGE_MDTYPE(18); // 64-bit unsigned integer (offset)

  // Metadata models supported by FreeImage
  FIMD_NODATA         = FREE_IMAGE_MDMODEL(-1);
  FIMD_COMMENTS       = FREE_IMAGE_MDMODEL(0);  // single comment or keywords
  FIMD_EXIF_MAIN      = FREE_IMAGE_MDMODEL(1);  // Exif-TIFF metadata
  FIMD_EXIF_EXIF      = FREE_IMAGE_MDMODEL(2);  // Exif-specific metadata
  FIMD_EXIF_GPS       = FREE_IMAGE_MDMODEL(3);  // Exif GPS metadata
  FIMD_EXIF_MAKERNOTE = FREE_IMAGE_MDMODEL(4);  // Exif maker note metadata
  FIMD_EXIF_INTEROP   = FREE_IMAGE_MDMODEL(5);  // Exif interoperability metadata
  FIMD_IPTC           = FREE_IMAGE_MDMODEL(6);  // IPTC/NAA metadata
  FIMD_XMP            = FREE_IMAGE_MDMODEL(7);  // Abobe XMP metadata
  FIMD_GEOTIFF        = FREE_IMAGE_MDMODEL(8);  // GeoTIFF metadata (to be implemented)
  FIMD_ANIMATION      = FREE_IMAGE_MDMODEL(9);  // Animation metadata
  FIMD_CUSTOM         = FREE_IMAGE_MDMODEL(10); // Used to attach other metadata types to a dib
  FIMD_EXIF_RAW       = FREE_IMAGE_MDMODEL(11); // Exif metadata as a raw buffer

const TFreeMultiBitmapFormats = [FIF_TIFF, FIF_ICO, FIF_GIF];{//added by me}

type
  // Handle to a metadata model
  FIMETADATA = record
    data: Pointer;
  end;
  PFIMETADATA = ^FIMETADATA;

  // Handle to a metadata tag
  FITAG = record
    data: Pointer;
  end;
  PFITAG = ^FITAG;

// --------------------------------------------------------------------------
// File IO routines ---------------------------------------------------------
// --------------------------------------------------------------------------

type
  fi_handle = Pointer;

  FI_ReadProc = function(buffer: Pointer; size, count: Cardinal;
    handle: fi_handle): Cardinal; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_WriteProc = function(buffer: Pointer; size, count: Cardinal;
    handle: fi_handle): Cardinal; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_SeekProc = function(handle: fi_handle; offset: LongInt;
    origin: Integer): Integer; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_TellProc = function(handle: fi_handle): LongInt; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}

  FreeImageIO = packed record
    read_proc : FI_ReadProc;     // pointer to the function used to read data
    write_proc: FI_WriteProc;    // pointer to the function used to write data
    seek_proc : FI_SeekProc;     // pointer to the function used to seek
    tell_proc : FI_TellProc;     // pointer to the function used to aquire the current position
  end;
  PFreeImageIO = ^FreeImageIO;

  // Handle to a memory I/O stream
  FIMEMORY = record
    data: Pointer;
  end;
  PFIMEMORY = ^FIMEMORY;

const
  // constants used in FreeImage_Seek for Origin parameter
  SEEK_SET = 0;
  SEEK_CUR = 1;
  SEEK_END = 2;

//type
  // define portable types for 32-bit / 64-bit OS
  //FIINT64 = Int64;
  //FIUINT64 = UInt64;

// --------------------------------------------------------------------------
// Plugin routines ----------------------------------------------------------
// --------------------------------------------------------------------------

type
  PPlugin = ^Plugin;

  FI_FormatProc = function: PAnsiChar; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_DescriptionProc = function: PAnsiChar; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_ExtensionListProc = function: PAnsiChar; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_RegExprProc = function: PAnsiChar; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_OpenProc = function(io: PFreeImageIO; handle: fi_handle;
    read: LongBool): Pointer; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_CloseProc = procedure(io: PFreeImageIO; handle: fi_handle;
    data: Pointer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_PageCountProc = function(io: PFreeImageIO; handle: fi_handle;
    data: Pointer): Integer; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_PageCapabilityProc = function(io: PFreeImageIO; handle: fi_handle;
    data: Pointer): Integer; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_LoadProc = function(io: PFreeImageIO; handle: fi_handle; page, flags: Integer;
    data: Pointer): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_SaveProc = function(io: PFreeImageIO; dib: PFIBITMAP; handle: fi_handle;
    page, flags: Integer; data: Pointer): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_ValidateProc = function(io: PFreeImageIO; handle: fi_handle): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_MimeProc = function: PAnsiChar; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_SupportsExportBPPProc = function(bpp: integer): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_SupportsExportTypeProc = function(_type: FREE_IMAGE_TYPE): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_SupportsICCProfilesProc = function: LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  FI_SupportsNoPixelsProc = function: LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}

  Plugin = packed record
    format_proc: FI_FormatProc;
    description_proc: FI_DescriptionProc;
    extension_proc: FI_ExtensionListProc;
    regexpr_proc: FI_RegExprProc;
    open_proc: FI_OpenProc;
    close_proc: FI_CloseProc;
    pagecount_proc: FI_PageCountProc;
    pagecapability_proc: FI_PageCapabilityProc;
    load_proc: FI_LoadProc;
    save_proc: FI_SaveProc;
    validate_proc: FI_ValidateProc;
    mime_proc: FI_MimeProc;
    supports_export_bpp_proc: FI_SupportsExportBPPProc;
    supports_export_type_proc: FI_SupportsExportTypeProc;
    supports_icc_profiles_proc: FI_SupportsICCProfilesProc;
    supports_no_pixels_proc: FI_SupportsNoPixelsProc;
  end;

  FI_InitProc = procedure(aplugin: PPlugin; format_id: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}

// --------------------------------------------------------------------------
// Load/Save flag constants -------------------------------------------------
// --------------------------------------------------------------------------

const
  FIF_LOAD_NOPIXELS   = $8000;  //! loading: load the image header only (not supported by all plugins, default to full loading)
  BMP_DEFAULT         = 0;
  BMP_SAVE_RLE        = 1;
  CUT_DEFAULT         = 0;
  DDS_DEFAULT         = 0;
  EXR_DEFAULT         = 0;      //! save data as half with piz-based wavelet compression
  EXR_FLOAT           = $0001;  //! save data as float instead of as half (not recommended)
  EXR_NONE            = $0002;  //! save with no compression
  EXR_ZIP             = $0004;  //! save with zlib compression, in blocks of 16 scan lines
  EXR_PIZ             = $0008;  //! save with piz-based wavelet compression
  EXR_PXR24           = $0010;  //! save with lossy 24-bit float compression
  EXR_B44             = $0020;  //! save with lossy 44% float compression - goes to 22% when combined with EXR_LC
  EXR_LC              = $0040;  //! save images with one luminance and two chroma channels, rather than as RGB (lossy compression)
  FAXG3_DEFAULT       = 0;
  GIF_DEFAULT         = 0;
  GIF_LOAD256         = 1;     //! Load the image as a 256 color image with ununsed palette entries, if it's 16 or 2 color
  GIF_PLAYBACK        = 2;     //! 'Play' the GIF to generate each frame (as 32bpp) instead of returning raw frame data when loading
  HDR_DEFAULT         = 0;
  ICO_DEFAULT         = 0;
  ICO_MAKEALPHA       = 1;     //! convert to 32bpp and create an alpha channel from the AND-mask when loading
  IFF_DEFAULT         = 0;
  J2K_DEFAULT         = 0;     //! save with a 16:1 rate
  JP2_DEFAULT         = 0;     //! save with a 16:1 rate
  JPEG_DEFAULT        = 0;     //! loading (see JPEG_FAST); saving (see JPEG_QUALITYGOOD|JPEG_SUBSAMPLING_420)
  JPEG_FAST           = 1;     //! load the file as fast as possible, sacrificing some quality
  JPEG_ACCURATE       = 2;     //! load the file with the best quality, sacrificing some speed
  JPEG_CMYK           = $0004; //! load separated CMYK "as is" (use | to combine with other flags)
  JPEG_EXIFROTATE     = $0008; //! load and rotate according to Exif 'Orientation' tag if available
  JPEG_GREYSCALE      = $0010; //! load and convert to a 8-bit greyscale image
  JPEG_QUALITYSUPERB  = $0080; //! save with superb quality (100:1)
  JPEG_QUALITYGOOD    = $0100; //! save with good quality (75:1)
  JPEG_QUALITYNORMAL  = $0200; //! save with normal quality (50:1)
  JPEG_QUALITYAVERAGE = $0400; //! save with average quality (25:1)
  JPEG_QUALITYBAD     = $0800; //! save with bad quality (10:1)
  JPEG_PROGRESSIVE    = $2000; //! save as a progressive-JPEG (use | to combine with other save flags)
  JPEG_SUBSAMPLING_411 = $1000;  //! save with high 4x1 chroma subsampling (4:1:1)
  JPEG_SUBSAMPLING_420 = $4000;  //! save with medium 2x2 medium chroma subsampling (4:2:0) - default value
  JPEG_SUBSAMPLING_422 = $8000;  //! save with low 2x1 chroma subsampling (4:2:2)
  JPEG_SUBSAMPLING_444 = $10000; //! save with no chroma subsampling (4:4:4)
  JPEG_OPTIMIZE       = $20000; //! on saving, compute optimal Huffman coding tables (can reduce a few percent of file size)
  JPEG_BASELINE       = $40000; //! save basic JPEG, without metadata or any markers
  KOALA_DEFAULT       = 0;
  LBM_DEFAULT         = 0;
  MNG_DEFAULT         = 0;
  PCD_DEFAULT         = 0;
  PCD_BASE            = 1;     //! load the bitmap sized 768 x 512
  PCD_BASEDIV4        = 2;     //! load the bitmap sized 384 x 256
  PCD_BASEDIV16       = 3;     //! load the bitmap sized 192 x 128
  PCX_DEFAULT         = 0;
  PFM_DEFAULT         = 0;
  PICT_DEFAULT        = 0;
  PNG_DEFAULT         = 0;
  PNG_IGNOREGAMMA     = 1;     //! loading: avoid gamma correction
  PNG_Z_BEST_SPEED          = $0001; //! save using ZLib level 1 compression flag (default value is 6)
  PNG_Z_DEFAULT_COMPRESSION = $0006; //! save using ZLib level 6 compression flag (default recommended value)
  PNG_Z_BEST_COMPRESSION    = $0009; //! save using ZLib level 9 compression flag (default value is 6)
  PNG_Z_NO_COMPRESSION      = $0100; //! save without ZLib compression
  PNG_INTERLACED            = $0200; //! save using Adam7 interlacing (use | to combine with other save flags)
  PNM_DEFAULT         = 0;
  PNM_SAVE_RAW        = 0;     //! if set the writer saves in RAW format (i.e. P4, P5 or P6)
  PNM_SAVE_ASCII      = 1;     //! if set the writer saves in ASCII format (i.e. P1, P2 or P3)
  PSD_DEFAULT         = 0;
  PSD_CMYK            = 1; //! reads tags for separated CMYK (default is conversion to RGB)
  PSD_LAB             = 2; //! reads tags for CIELab (default is conversion to RGB)
  PSD_NONE            = $0100; //! save without any compression
  PSD_RLE             = $0200; //! save using RLE compression
  PSD_PSB             = $2000; //! save using Adobe Large Document Format (use | to combine with other save flags)
  RAS_DEFAULT         = 0;
  RAW_DEFAULT         = 0; //! load the file as linear RGB 48-bit
  RAW_PREVIEW         = 1; //! try to load the embedded JPEG preview with included Exif Data or default to RGB 24-bit
  RAW_DISPLAY         = 2; //! load the file as RGB 24-bit
  RAW_HALFSIZE        = 4; //! output a half-size color image
  RAW_UNPROCESSED     = 8; //! output a FIT_UINT16 raw Bayer image
  SGI_DEFAULT         = 0;
  TARGA_DEFAULT       = 0;
  TARGA_LOAD_RGB888   = 1;     //! if set the loader converts RGB555 and ARGB8888 -> RGB888.
  TARGA_SAVE_RLE      = 2;     //! if set, the writer saves with RLE compression
  TIFF_DEFAULT        = 0;
  TIFF_CMYK           = $0001;  //! reads/stores tags for separated CMYK (use | to combine with compression flags)
  TIFF_PACKBITS       = $0100;  //! save using PACKBITS compression
  TIFF_DEFLATE        = $0200;  //! save using DEFLATE compression
  TIFF_ADOBE_DEFLATE  = $0400;  //! save using ADOBE DEFLATE compression
  TIFF_NONE           = $0800;  //! save without any compression
  TIFF_CCITTFAX3      = $1000;  //! save using CCITT Group 3 fax encoding
  TIFF_CCITTFAX4      = $2000;  //! save using CCITT Group 4 fax encoding
  TIFF_LZW            = $4000;  //! save using LZW compression
  TIFF_JPEG           = $8000;  //! save using JPEG compression
  TIFF_LOGLUV         = $10000; //! save using LogLuv compression
  WBMP_DEFAULT        = 0;
  XBM_DEFAULT         = 0;
  XPM_DEFAULT         = 0;
  WEBP_DEFAULT        = 0;      //! save with good quality (75:1)
  WEBP_LOSSLESS       = $100;   //! save in lossless mode
  JXR_DEFAULT         = 0;      //! save with quality 80 and no chroma subsampling (4:4:4)
  JXR_LOSSLESS        = $0064;  //! save lossless
  JXR_PROGRESSIVE     = $2000;  //! save as a progressive-JXR (use | to combine with other save flags)

// --------------------------------------------------------------------------
// Background filling options -----------------------------------------------
// Constants used in FreeImage_FillBackground and FreeImage_EnlargeCanvas
// --------------------------------------------------------------------------

const
  FI_COLOR_IS_RGB_COLOR         = $00; // RGBQUAD color is a RGB color (contains no valid alpha channel)
  FI_COLOR_IS_RGBA_COLOR        = $01; // RGBQUAD color is a RGBA color (contains a valid alpha channel)
  FI_COLOR_FIND_EQUAL_COLOR     = $02; // For palettized images: lookup equal RGB color from palette
  FI_COLOR_ALPHA_IS_INDEX       = $04; // The color's rgbReserved member (alpha) contains the palette index to be used
  FI_COLOR_PALETTE_SEARCH_MASK  = FI_COLOR_FIND_EQUAL_COLOR or FI_COLOR_ALPHA_IS_INDEX; // No color lookup is performed

// RescaleEx options ---------------------------------------------------------
// Constants used in FreeImage_RescaleEx

  FI_RESCALE_DEFAULT            = $00;  //! default options; none of the following other options apply
  FI_RESCALE_TRUE_COLOR         = $01;  //! for non-transparent greyscale images, convert to 24-bit if src bitdepth <= 8 (default is a 8-bit greyscale image). 
  FI_RESCALE_OMIT_METADATA      = $02;  //! do not copy metadata to the rescaled image















// --------------------------------------------------------------------------
// Message output functions -------------------------------------------------
// --------------------------------------------------------------------------

type
  FreeImage_OutputMessageFunction = procedure(fif: FREE_IMAGE_FORMAT;
    msg: PAnsiChar); cdecl;
  FreeImage_OutputMessageFunctionStdCall = procedure(fif: FREE_IMAGE_FORMAT;
    msg: PAnsiChar); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
{
procedure FreeImage_SetOutputMessageStdCall(omf: FreeImage_OutputMessageFunctionStdCall); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_SetOutputMessageStdCall@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_SetOutputMessageStdCall'{$ENDIF};
procedure FreeImage_SetOutputMessage(omf: FreeImage_OutputMessageFunction); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_SetOutputMessage@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_SetOutputMessage'{$ENDIF};
}
// --------------------------------------------------------------------------
// Allocate / Clone / Unload routines ---------------------------------------
// --------------------------------------------------------------------------






// --------------------------------------------------------------------------
// Header loading routines
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// Load / Save routines -----------------------------------------------------
// --------------------------------------------------------------------------







// --------------------------------------------------------------------------
// Memory I/O stream routines -----------------------------------------------
// --------------------------------------------------------------------------











// --------------------------------------------------------------------------
// Plugin Interface ---------------------------------------------------------
// --------------------------------------------------------------------------
{
function FreeImage_RegisterLocalPlugin(proc_address: FI_InitProc; format: PAnsiChar = nil;
  description: PAnsiChar = nil; extension: PAnsiChar = nil;
  regexpr: PAnsiChar = nil): FREE_IMAGE_FORMAT; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_RegisterLocalPlugin@20'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_RegisterLocalPlugin'{$ENDIF};
function FreeImage_RegisterExternalPlugin(path: PAnsiChar; format: PAnsiChar = nil;
  description: PAnsiChar = nil; extension: PAnsiChar = nil;
  regexpr: PAnsiChar = nil): FREE_IMAGE_FORMAT; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_RegisterExternalPlugin@20'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_RegisterExternalPlugin'{$ENDIF};
function FreeImage_GetFIFCount: Integer; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_GetFIFCount@0'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_GetFIFCount'{$ENDIF};
procedure FreeImage_SetPluginEnabled(fif: FREE_IMAGE_FORMAT; enable: LongBool); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_SetPluginEnabled@8'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_SetPluginEnabled'{$ENDIF};
function FreeImage_IsPluginEnabled(fif: FREE_IMAGE_FORMAT): Integer; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_IsPluginEnabled@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_IsPluginEnabled'{$ENDIF};
function FreeImage_GetFIFFromFormat(format: PAnsiChar): FREE_IMAGE_FORMAT; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_GetFIFFromFormat@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_GetFIFFromFormat'{$ENDIF};
function FreeImage_GetFIFFromMime(mime: PAnsiChar): FREE_IMAGE_FORMAT; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_GetFIFFromMime@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_GetFIFFromMime'{$ENDIF};
function FreeImage_GetFormatFromFIF(fif: FREE_IMAGE_FORMAT): PAnsiChar; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_GetFormatFromFIF@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_GetFormatFromFIF'{$ENDIF};
function FreeImage_GetFIFExtensionList(fif: FREE_IMAGE_FORMAT): PAnsiChar; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_GetFIFExtensionList@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_GetFIFExtensionList'{$ENDIF};
function FreeImage_GetFIFDescription(fif: FREE_IMAGE_FORMAT): PAnsiChar; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_GetFIFDescription@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_GetFIFDescription'{$ENDIF};
function FreeImage_GetFIFRegExpr(fif: FREE_IMAGE_FORMAT): PAnsiChar; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_GetFIFRegExpr@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_GetFIFRegExpr'{$ENDIF};
function FreeImage_GetFIFMimeType(fif: FREE_IMAGE_FORMAT): PAnsiChar; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_GetFIFMimeType@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_GetFIFMimeType'{$ENDIF};
}

{
function FreeImage_FIFSupportsICCProfiles(fif: FREE_IMAGE_FORMAT): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_FIFSupportsICCProfiles@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_FIFSupportsICCProfiles'{$ENDIF};
function FreeImage_FIFSupportsNoPixels(fif: FREE_IMAGE_FORMAT): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_FIFSupportsNoPixels@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_FIFSupportsNoPixels'{$ENDIF};
 }
// --------------------------------------------------------------------------
// Multipaging interface ----------------------------------------------------
// --------------------------------------------------------------------------











{function FreeImage_GetLockedPageNumbers(bitmap: PFIMULTIBITMAP; var pages: Integer;
  var count: Integer): LongBool;overload; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_GetLockedPageNumbers@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_GetLockedPageNumbers'{$ENDIF};
function FreeImage_GetLockedPageNumbers(bitmap: PFIMULTIBITMAP; pages: PInteger;
      count: PInteger): LongBool;overload; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
      external FIDLL {$IFDEF WIN32}name '_FreeImage_GetLockedPageNumbers@12'{$ENDIF}
      {$IFDEF MACOS}name '_FreeImage_GetLockedPageNumbers'{$ENDIF};}

// --------------------------------------------------------------------------
// Filetype request routines ------------------------------------------------
// --------------------------------------------------------------------------






// --------------------------------------------------------------------------
// FreeImage helper routines ------------------------------------------------
// --------------------------------------------------------------------------
{
function FreeImage_IsLittleEndian: LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_IsLittleEndian@0'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_IsLittleEndian'{$ENDIF};
function FreeImage_LookupX11Color(szColor: PAnsiChar; var nRed, nGreen, nBlue: Byte): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_LookupX11Color@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_LookupX11Color'{$ENDIF};
function FreeImage_LookupSVGColor(szColor: PAnsiChar; var nRed, nGreen, nBlue: Byte): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_LookupSVGColor@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_LookupSVGColor'{$ENDIF};
         }
// --------------------------------------------------------------------------
// Pixels access routines ---------------------------------------------------
// --------------------------------------------------------------------------






// --------------------------------------------------------------------------
// DIB info routines --------------------------------------------------------
// --------------------------------------------------------------------------






{
procedure FreeImage_SetTransparentIndex(dib: PFIBITMAP; index: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_SetTransparentIndex@8'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_SetTransparentIndex'{$ENDIF};
function FreeImage_GetTransparentIndex(dib: PFIBITMAP): Integer; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_GetTransparentIndex@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_GetTransparentIndex'{$ENDIF};

}
{
function FreeImage_SetBackgroundColor(dib: PFIBITMAP; bkcolor: PRGBQuad): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_SetBackgroundColor@8'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_SetBackgroundColor'{$ENDIF};

function FreeImage_GetThumbnail(dib: PFIBITMAP): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_GetThumbnail@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_GetThumbnail'{$ENDIF};
function FreeImage_SetThumbnail(dib, thumbnail: PFIBITMAP): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_SetThumbnail@8'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_SetThumbnail'{$ENDIF};
  }
// --------------------------------------------------------------------------
// ICC profile routines -----------------------------------------------------
// --------------------------------------------------------------------------
{
function FreeImage_GetICCProfile(dib: PFIBITMAP): PFIICCPROFILE; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_GetICCProfile@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_GetICCProfile'{$ENDIF};
function FreeImage_CreateICCProfile(dib: PFIBITMAP; data: Pointer;
  size: LongInt): PFIICCPROFILE; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name 'FreeImage_CreateICCProfile@12'{$ENDIF}
  {$IFDEF MACOS}name 'FreeImage_CreateICCProfile'{$ENDIF};
procedure FreeImage_DestroyICCProfile(dib: PFIBITMAP); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name 'FreeImage_DestroyICCProfile@4'{$ENDIF}
  {$IFDEF MACOS}name 'FreeImage_DestroyICCProfile'{$ENDIF};
}
// --------------------------------------------------------------------------
// Line conversion routines -------------------------------------------------
// --------------------------------------------------------------------------
{
procedure FreeImage_ConvertLine1To4(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine1To4@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine1To4'{$ENDIF};
procedure FreeImage_ConvertLine8To4(target, source: PByte; width_in_pixels: Integer;
  palette: PRGBQuad); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine8To4@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine8To4'{$ENDIF};
procedure FreeImage_ConvertLine16To4_555(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine16To4_555@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine16To4_555'{$ENDIF};
procedure FreeImage_ConvertLine16To4_565(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine16To4_565@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine16To4_565'{$ENDIF};
procedure FreeImage_ConvertLine24To4(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine24To4@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine24To4'{$ENDIF};
procedure FreeImage_ConvertLine32To4(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine32To4@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine32To4'{$ENDIF};

procedure FreeImage_ConvertLine1To8(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine1To8@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine1To8'{$ENDIF};
procedure FreeImage_ConvertLine4To8(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine4To8@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine4To8'{$ENDIF};
procedure FreeImage_ConvertLine16To8_555(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine16To8_555@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine16To8_555'{$ENDIF};
procedure FreeImage_ConvertLine16To8_565(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine16To8_565@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine16To8_565'{$ENDIF};
procedure FreeImage_ConvertLine24To8(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine24To8@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine24To8'{$ENDIF};
procedure FreeImage_ConvertLine32To8(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine32To8@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine32To8'{$ENDIF};

procedure FreeImage_ConvertLine1To16_555(target, source: PByte; width_in_pixels: Integer;
  palette: PRGBQuad); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine1To16_555@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine1To16_555'{$ENDIF};
procedure FreeImage_ConvertLine4To16_555(target, source: PByte; width_in_pixels: Integer;
  palette: PRGBQuad); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine4To16_555@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine4To16_555'{$ENDIF};
procedure FreeImage_ConvertLine8To16_555(target, source: PByte; width_in_pixels: Integer;
  palette: PRGBQuad); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine8To16_555@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine8To16_555'{$ENDIF};
procedure FreeImage_ConvertLine16_565_To16_555(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine16_565_To16_555@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine16_565_To16_555'{$ENDIF};
procedure FreeImage_ConvertLine24To16_555(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine24To16_555@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine24To16_555'{$ENDIF};
procedure FreeImage_ConvertLine32To16_555(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine32To16_555@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine32To16_555'{$ENDIF};

procedure FreeImage_ConvertLine1To16_565(target, source: PByte; width_in_pixels: Integer;
  palette: PRGBQuad); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine1To16_565@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine1To16_565'{$ENDIF};
procedure FreeImage_ConvertLine4To16_565(target, source: PByte; width_in_pixels: Integer;
  palette: PRGBQuad); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine4To16_565@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine4To16_565'{$ENDIF};
procedure FreeImage_ConvertLine8To16_565(target, source: PByte; width_in_pixels: Integer;
  palette: PRGBQuad); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine8To16_565@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine8To16_565'{$ENDIF};
procedure FreeImage_ConvertLine16_555_To16_565(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine16_555_To16_565@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine16_555_To16_565'{$ENDIF};
procedure FreeImage_ConvertLine24To16_565(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine24To16_565@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine24To16_565'{$ENDIF};
procedure FreeImage_ConvertLine32To16_565(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine32To16_565@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine32To16_565'{$ENDIF};

procedure FreeImage_ConvertLine1To24(target, source: PByte; width_in_pixels: Integer;
  palette: PRGBQuad); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine1To24@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine1To24'{$ENDIF};
procedure FreeImage_ConvertLine4To24(target, source: PByte; width_in_pixels: Integer;
  palette: PRGBQuad); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine4To24@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine4To24'{$ENDIF};
procedure FreeImage_ConvertLine8To24(target, source: PByte; width_in_pixels: Integer;
  palette: PRGBQuad); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine8To24@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine8To24'{$ENDIF};
procedure FreeImage_ConvertLine16To24_555(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine16To24_555@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine16To24_555'{$ENDIF};
procedure FreeImage_ConvertLine16To24_565(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine16To24_565@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine16To24_565'{$ENDIF};
procedure FreeImage_ConvertLine32To24(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine32To24@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine32To24'{$ENDIF};

procedure FreeImage_ConvertLine1To32(target, source: PByte; width_in_pixels: Integer;
  palette: PRGBQuad); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine1To32@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine1To32'{$ENDIF};
procedure FreeImage_ConvertLine1To32MapTransparency(target, source: PByte; width_in_pixels: Integer;
  palette: PRGBQuad; table: PByte; transparent_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine1To32MapTransparency@24'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine1To32MapTransparency'{$ENDIF};
procedure FreeImage_ConvertLine4To32(target, source: PByte; width_in_pixels: Integer;
  palette: PRGBQuad); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine4To32@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine4To32'{$ENDIF};
procedure FreeImage_ConvertLine4To32MapTransparency(target, source: PByte; width_in_pixels: Integer;
  palette: PRGBQuad; table: PByte; transparent_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine4To32MapTransparency@24'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine4To32MapTransparency'{$ENDIF};
procedure FreeImage_ConvertLine8To32(target, source: PByte; width_in_pixels: Integer;
  palette: PRGBQuad); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine8To32@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine8To32'{$ENDIF};
procedure FreeImage_ConvertLine8To32MapTransparency(target, source: PByte; width_in_pixels: Integer;
  palette: PRGBQuad; table: PByte; transparent_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine8To32MapTransparency@24'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine8To32MapTransparency'{$ENDIF};
procedure FreeImage_ConvertLine16To32_555(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine16To32_555@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine16To32_555'{$ENDIF};
procedure FreeImage_ConvertLine16To32_565(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine16To32_565@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine16To32_565'{$ENDIF};
procedure FreeImage_ConvertLine24To32(target, source: PByte; width_in_pixels: Integer); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertLine24To32@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertLine24To32'{$ENDIF};
}
// --------------------------------------------------------------------------
// Smart conversion routines ------------------------------------------------
// --------------------------------------------------------------------------


{
function FreeImage_ColorQuantizeEx(dib: PFIBITMAP; quantize: FREE_IMAGE_QUANTIZE = FIQ_WUQUANT;
  PaletteSize: Integer = 256; ReserveSize: Integer = 0;
  ReservePalette: PRGBQuad = nil): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ColorQuantizeEx@20'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ColorQuantizeEx'{$ENDIF};



function FreeImage_ConvertFromRawBitsEx(copySource: LongBool; bits: PByte; _type: FREE_IMAGE_TYPE;
  width, height, pitch: Integer; bpp, red_mask, green_mask, blue_mask: Cardinal;
  topdown: LongBool = False): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertFromRawBitsEx@44'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertFromRawBitsEx'{$ENDIF};
procedure FreeImage_ConvertToRawBits(bits: PByte; dib: PFIBITMAP; pitch: Integer;
  bpp, red_mask, green_mask, blue_mask: Cardinal; topdown: LongBool = False); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertToRawBits@32'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertToRawBits'{$ENDIF};

function FreeImage_ConvertToFloat(dib: PFIBITMAP): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertToFloat@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertToFloat'{$ENDIF};

function FreeImage_ConvertToRGBAF(dib: PFIBITMAP): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertToRGBAF@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertToRGBAF'{$ENDIF};
function FreeImage_ConvertToUINT16(dib: PFIBITMAP): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertToUINT16@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertToUINT16'{$ENDIF};
function FreeImage_ConvertToRGB16(dib: PFIBITMAP): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertToRGB16@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertToRGB16'{$ENDIF};
function FreeImage_ConvertToRGBA16(dib: PFIBITMAP): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertToRGBA16@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertToRGBA16'{$ENDIF};
}
{
function FreeImage_ConvertToType(src: PFIBITMAP; dst_type: FREE_IMAGE_TYPE;
  scale_linear: LongBool = True): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ConvertToType@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ConvertToType'{$ENDIF};
}
{
// Tone mapping operators ---------------------------------------------------
function FreeImage_ToneMapping(dib: PFIBITMAP; tmo: FREE_IMAGE_TMO;
  first_param: Double = 0; second_param: Double = 0): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ToneMapping@24'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ToneMapping'{$ENDIF};
function FreeImage_TmoDrago03(src: PFIBITMAP; gamma: Double = 2.2;
  exposure: Double = 0): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_TmoDrago03@20'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_TmoDrago03'{$ENDIF};
function FreeImage_TmoReinhard05(src: PFIBITMAP; intensity: Double = 0;
  contrast: Double = 0): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_TmoReinhard05@20'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_TmoReinhard05'{$ENDIF};
function FreeImage_TmoReinhard05Ex(src: PFIBITMAP; intensity: Double = 0;
  contrast: Double = 0; adaptation: Double = 1; color_correction: Double = 0): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_TmoReinhard05Ex@36'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_TmoReinhard05Ex'{$ENDIF};

function FreeImage_TmoFattal02(src: PFIBITMAP; color_saturation: Double = 0.5;
  attenuation: Double = 0.85): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_TmoFattal02@20'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_TmoFattal02'{$ENDIF};
}
// --------------------------------------------------------------------------
// ZLib interface -----------------------------------------------------------
// --------------------------------------------------------------------------
{
function FreeImage_ZLibGZip(target: PByte; target_size: DWORD; source: PByte; source_size: DWORD): DWORD; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ZLibGZip@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ZLibGZip'{$ENDIF};
function FreeImage_ZLibGUnzip(target: PByte; target_size: DWORD; source: PByte; source_size: DWORD): DWORD; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ZLibGUnzip@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ZLibGUnzip'{$ENDIF};
function FreeImage_ZLibCRC32(crc: DWORD; source: PByte; source_size: DWORD): DWORD; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ZLibCRC32@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ZLibCRC32'{$ENDIF};
}
// --------------------------------------------------------------------------
// Metadata routines
// --------------------------------------------------------------------------
{
// tag creation / destruction
function FreeImage_CreateTag: PFITAG; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_CreateTag@0'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_CreateTag'{$ENDIF};
procedure FreeImage_DeleteTag(tag: PFITAG); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_DeleteTag@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_DeleteTag'{$ENDIF};
function FreeImage_CloneTag(tag: PFITAG): PFITAG; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_CloneTag@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_CloneTag'{$ENDIF};
}

// tag getters and setters


// iterator

// metadata setter and getter


// helpers

// tag to C string conversion

// --------------------------------------------------------------------------
// JPEG lossless transformation routines
// --------------------------------------------------------------------------
{
function FreeImage_JPEGTransform(src_file, dst_file: PAnsiChar; operation: FREE_IMAGE_JPEG_OPERATION;
  perfect: LongBool = False): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_JPEGTransform@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_JPEGTransform'{$ENDIF};
function FreeImage_JPEGTransformU(src_file, dst_file: PWideChar; operation: FREE_IMAGE_JPEG_OPERATION;
  perfect: LongBool = False): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_JPEGTransformU@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_JPEGTransformU'{$ENDIF};
function FreeImage_JPEGCrop(src_file, dst_file: PAnsiChar;
  left, top, right, bottom: Integer): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_JPEGCrop@24'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_JPEGCrop'{$ENDIF};
function FreeImage_JPEGCropU(src_file, dst_file: PWideChar;
  left, top, right, bottom: Integer): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_JPEGCropU@24'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_JPEGCropU'{$ENDIF};
function FreeImage_JPEGTransformFromHandle(src_io: PFreeImageIO; src_handle: fi_handle; dst_io: PFreeImageIO;
  dst_handle: fi_handle; operation: FREE_IMAGE_JPEG_OPERATION; var left, top, right, bottom: Integer;
  perfect: LongBool = True): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_JPEGTransformFromHandle@40'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_JPEGTransformFromHandle'{$ENDIF};
function FreeImage_JPEGTransformCombined(src_file, dst_file: PAnsiChar; operation: FREE_IMAGE_JPEG_OPERATION;
  var left, top, right, bottom: Integer; perfect: LongBool = True): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_JPEGTransformCombined@32'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_JPEGTransformCombined'{$ENDIF};
function FreeImage_JPEGTransformCombinedU(src_file, dst_file: PWideChar; operation: FREE_IMAGE_JPEG_OPERATION;
  var left, top, right, bottom: Integer; perfect: LongBool = True): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_JPEGTransformCombinedU@32'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_JPEGTransformCombinedU'{$ENDIF};
function FreeImage_JPEGTransformCombinedFromMemory(src_stream, dst_stream: PFIMEMORY; operation: FREE_IMAGE_JPEG_OPERATION;
  var left, top, right, bottom: Integer; perfect: LongBool = True): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_JPEGTransformCombinedFromMemory@32'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_JPEGTransformCombinedFromMemory'{$ENDIF};
}
// --------------------------------------------------------------------------
// Image manipulation toolkit
// --------------------------------------------------------------------------

// rotation and flipping
// modif JMB : FreeImage_RotateClassic : deprecated function, call to DeprecationManager in 64 bits crashes freeimage.dll
//function FreeImage_RotateClassic(dib: PFIBITMAP; angle: Double): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
//  external FIDLL {$IFDEF WIN32}name '_FreeImage_RotateClassic@12'{$ENDIF}
//  {$IFDEF MACOS}name '_FreeImage_RotateClassic'{$ENDIF};

// upsampling / downsampling


{
// color manipulation routines (point operations)
function FreeImage_AdjustCurve(dib: PFIBITMAP; LUT: PByte;
  channel: FREE_IMAGE_COLOR_CHANNEL): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_AdjustCurve@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_AdjustCurve'{$ENDIF};
function FreeImage_AdjustGamma(dib: PFIBITMAP; gamma: Double): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_AdjustGamma@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_AdjustGamma'{$ENDIF};
function FreeImage_AdjustBrightness(dib: PFIBITMAP; percentage: Double): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_AdjustBrightness@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_AdjustBrightness'{$ENDIF};
function FreeImage_AdjustContrast(dib: PFIBITMAP; percentage: Double): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_AdjustContrast@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_AdjustContrast'{$ENDIF};
function FreeImage_Invert(dib: PFIBITMAP): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_Invert@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_Invert'{$ENDIF};
function FreeImage_GetHistogram(dib: PFIBITMAP; histo: PDWORD;
  channel: FREE_IMAGE_COLOR_CHANNEL = FICC_BLACK): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_GetHistogram@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_GetHistogram'{$ENDIF};
function FreeImage_GetAdjustColorsLookupTable(LUT: PByte; brightness, contrast, gamma: Double;
  invert: LongBool): Integer; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_GetAdjustColorsLookupTable@32'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_GetAdjustColorsLookupTable'{$ENDIF};
function FreeImage_AdjustColors(dib: PFIBITMAP; brightness, contrast, gamma: Double;
  invert: LongBool = False): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_AdjustColors@32'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_AdjustColors'{$ENDIF};
function FreeImage_ApplyColorMapping(dib: PFIBITMAP; srccolors, dstcolors: PRGBQuad;
  count: Cardinal; ignore_alpha, swap: LongBool): Cardinal; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ApplyColorMapping@24'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ApplyColorMapping'{$ENDIF};
function FreeImage_SwapColors(dib: PFIBITMAP; color_a, color_b: PRGBQuad;
  ignore_alpha: LongBool): Cardinal; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_SwapColors@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_SwapColors'{$ENDIF};
function FreeImage_ApplyPaletteIndexMapping(dib: PFIBITMAP; srcindices, dstindices: PByte;
  count: Cardinal; swap: LongBool): Cardinal; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_ApplyPaletteIndexMapping@20'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_ApplyPaletteIndexMapping'{$ENDIF};
function FreeImage_SwapPaletteIndices(dib: PFIBITMAP; index_a, index_b: PByte): Cardinal; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_SwapPaletteIndices@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_SwapPaletteIndices'{$ENDIF};
}
{
// channel processing routines
function FreeImage_GetChannel(dib: PFIBITMAP; channel: FREE_IMAGE_COLOR_CHANNEL): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_GetChannel@8'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_GetChannel'{$ENDIF};
function FreeImage_SetChannel(dst, src: PFIBITMAP; channel: FREE_IMAGE_COLOR_CHANNEL): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_SetChannel@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_SetChannel'{$ENDIF};
function FreeImage_GetComplexChannel(src: PFIBITMAP; channel: FREE_IMAGE_COLOR_CHANNEL): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_GetComplexChannel@8'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_GetComplexChannel'{$ENDIF};
function FreeImage_SetComplexChannel(dst, src: PFIBITMAP; channel: FREE_IMAGE_COLOR_CHANNEL): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_SetComplexChannel@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_SetComplexChannel'{$ENDIF};
}
// copy / paste / composite routines



{
function FreeImage_Composite(fg: PFIBITMAP; useFileBkg: LongBool = False;
  appBkColor: PRGBQuad = nil; bg: PFIBITMAP = nil): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_Composite@16'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_Composite'{$ENDIF};
function FreeImage_PreMultiplyWithAlpha(dib: PFIBITMAP): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_PreMultiplyWithAlpha@4'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_PreMultiplyWithAlpha'{$ENDIF};
}
{
// background filling routines
function FreeImage_FillBackground(dib: PFIBITMAP; color: Pointer;
  options: Integer = 0): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_FillBackground@12'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_FillBackground'{$ENDIF};
function FreeImage_EnlargeCanvas(src: PFIBITMAP; left, top, right, bottom: Integer;
  color: Pointer; options: Integer = 0): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_EnlargeCanvas@28'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_EnlargeCanvas'{$ENDIF};
function FreeImage_AllocateEx(width, height, bpp: Integer; color: PRGBQuad;
  options: Integer = 0; palette: PRGBQuad = nil; red_mask: Cardinal = 0;
  green_mask: Cardinal = 0; blue_mask: Cardinal = 0): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_AllocateEx@36'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_AllocateEx'{$ENDIF};
function FreeImage_AllocateExT(_type: FREE_IMAGE_TYPE; width, height, bpp: Integer;
  color: Pointer; options: Integer = 0; palette: PRGBQuad = nil; red_mask: Cardinal = 0;
  green_mask: Cardinal = 0; blue_mask: Cardinal = 0): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_AllocateExT@40'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_AllocateExT'{$ENDIF};
}
{
// miscellaneous algorithms
function FreeImage_MultigridPoissonSolver(Laplacian: PFIBITMAP;
  ncycle: Integer = 3): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
  external FIDLL {$IFDEF WIN32}name '_FreeImage_MultigridPoissonSolver@8'{$ENDIF}
  {$IFDEF MACOS}name '_FreeImage_MultigridPoissonSolver'{$ENDIF};
}
  
  
//-----------------------------------------------------  
var FreeimageHandle:TLibHandle=NilHandle;
FIDLL:string = 'freeimage';


procedure load;

function FreeimageHandleIsValid:boolean;
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// Init/Error routines ------------------------------------------------------

procedure FreeImage_Initialise(load_local_plugins_only: LongBool = False);
procedure FreeImage_DeInitialise;
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// Version routines ---------------------------------------------------------
function FreeImage_GetVersion: PAnsiChar;
function FreeImage_GetCopyrightMessage: PAnsiChar;
//...

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// Allocate / Clone / Unload routines ---------------------------------------
function FreeImage_Allocate(width, height, bpp: Integer; red_mask: Cardinal = 0;
  green_mask: Cardinal = 0; blue_mask: Cardinal = 0): PFIBITMAP;
function FreeImage_AllocateT(_type: FREE_IMAGE_TYPE; width, height: Integer;
  bpp: Integer = 8; red_mask: Cardinal = 0; green_mask: Cardinal = 0;
  blue_mask: Cardinal = 0): PFIBITMAP;
function FreeImage_Clone(dib: PFIBITMAP): PFIBITMAP;
procedure FreeImage_Unload(dib: PFIBITMAP);
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// Header loading routines
function FreeImage_HasPixels(dib: PFIBITMAP): LongBool;
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// Load / Save routines -----------------------------------------------------
function FreeImage_Load(fif: FREE_IMAGE_FORMAT; filename: PAnsiChar;
  flags: Integer = 0): PFIBITMAP;
function FreeImage_LoadU(fif: FREE_IMAGE_FORMAT; filename: PWideChar;
  flags: Integer = 0): PFIBITMAP;
function FreeImage_LoadFromHandle(fif: FREE_IMAGE_FORMAT; io: PFreeImageIO;
  handle: fi_handle; flags: Integer = 0): PFIBITMAP;
function FreeImage_Save(fif: FREE_IMAGE_FORMAT; dib: PFIBITMAP; filename: PAnsiChar;
  flags: Integer = 0): LongBool;
function FreeImage_SaveU(fif: FREE_IMAGE_FORMAT; dib: PFIBITMAP; filename: PWideChar;
  flags: Integer = 0): LongBool;
function FreeImage_SaveToHandle(fif: FREE_IMAGE_FORMAT; dib: PFIBITMAP;
  io: PFreeImageIO; handle: fi_handle; flags: Integer = 0): LongBool;
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// Memory I/O stream routines -----------------------------------------------
function FreeImage_OpenMemory(data: PByte = nil; size_in_bytes: DWORD = 0): PFIMEMORY;
procedure FreeImage_CloseMemory(stream: PFIMEMORY);
function FreeImage_LoadFromMemory(fif: FREE_IMAGE_FORMAT; stream: PFIMEMORY;
  flags: Integer = 0): PFIBITMAP;
function FreeImage_SaveToMemory(fif: FREE_IMAGE_FORMAT; dib: PFIBITMAP;
  stream: PFIMEMORY; flags: Integer = 0): LongBool;
function FreeImage_TellMemory(stream: PFIMEMORY): LongInt;
function FreeImage_SeekMemory(stream: PFIMEMORY; offset: LongInt;
  origin: Integer): LongBool;
function FreeImage_AcquireMemory(stream: PFIMEMORY; var data: PByte;
  var size_in_bytes: DWORD): LongBool;
function FreeImage_WriteMemory(buffer: Pointer; size, count: Cardinal;
  stream: PFIMEMORY): Cardinal;
function FreeImage_LoadMultiBitmapFromMemory(fif: FREE_IMAGE_FORMAT; stream: PFIMEMORY;
  flags: Integer = 0): PFIMULTIBITMAP;
function FreeImage_SaveMultiBitmapToMemory(fif: FREE_IMAGE_FORMAT; bitmap: PFIMULTIBITMAP;
  stream: PFIMEMORY; flags: Integer): LongBool;
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// Plugin Interface ---------------------------------------------------------
function FreeImage_GetFIFFromFilename(filename: PAnsiChar): FREE_IMAGE_FORMAT;
function FreeImage_GetFIFFromFilenameU(filename: PWideChar): FREE_IMAGE_FORMAT;
function FreeImage_FIFSupportsReading(fif: FREE_IMAGE_FORMAT): LongBool;
function FreeImage_FIFSupportsWriting(fif: FREE_IMAGE_FORMAT): LongBool;
function FreeImage_FIFSupportsExportBPP(fif: FREE_IMAGE_FORMAT;
  bpp: Integer): LongBool;
function FreeImage_FIFSupportsExportType(fif: FREE_IMAGE_FORMAT;
  _type: FREE_IMAGE_TYPE): LongBool;
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// Multipaging interface ----------------------------------------------------
function FreeImage_OpenMultiBitmapFromHandle(fif: FREE_IMAGE_FORMAT; io: PFreeImageIO;
  handle: fi_handle; flags: Integer = 0): PFIMULTIBITMAP;
function FreeImage_OpenMultiBitmap(fif: FREE_IMAGE_FORMAT; filename: PAnsiChar;
  create_new, read_only: LongBool; keep_cache_in_memory: LongBool = False;
  flags: Integer = 0): PFIMULTIBITMAP;
function FreeImage_SaveMultiBitmapToHandle(fif: FREE_IMAGE_FORMAT; bitmap: PFIMULTIBITMAP;
  io: PFreeImageIO; handle: fi_handle; flags: Integer = 0): LongBool;
function FreeImage_CloseMultiBitmap(bitmap: PFIMULTIBITMAP;
  flags: Integer = 0): LongBool;
function FreeImage_GetPageCount(bitmap: PFIMULTIBITMAP): Integer;
procedure FreeImage_AppendPage(bitmap: PFIMULTIBITMAP; data: PFIBITMAP);
procedure FreeImage_InsertPage(bitmap: PFIMULTIBITMAP; page: Integer;
  data: PFIBITMAP);
procedure FreeImage_DeletePage(bitmap: PFIMULTIBITMAP; page: Integer);
function FreeImage_LockPage(bitmap: PFIMULTIBITMAP; page: Integer): PFIBITMAP;
procedure FreeImage_UnlockPage(bitmap: PFIMULTIBITMAP; data: PFIBITMAP;
  changed: LongBool);
function FreeImage_MovePage(bitmap: PFIMULTIBITMAP; target, source: Integer): LongBool;
function FreeImage_GetLockedPageNumbers(bitmap: PFIMULTIBITMAP; pages: PInteger;
      count: PInteger): LongBool;
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// Filetype request routines ------------------------------------------------
function FreeImage_GetFileType(filename: PAnsiChar;
  size: Integer = 0): FREE_IMAGE_FORMAT;
function FreeImage_GetFileTypeU(filename: PWideChar;
  size: Integer = 0): FREE_IMAGE_FORMAT;
function FreeImage_GetFileTypeFromHandle(io: PFreeImageIO; handle: FI_Handle;
  size: Integer = 0): FREE_IMAGE_FORMAT;
function FreeImage_GetFileTypeFromMemory(stream: PFIMEMORY;
  size: Integer = 0): FREE_IMAGE_FORMAT;
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// ImageType request routine ------------------------------------------------
function FreeImage_GetImageType(dib: PFIBITMAP): FREE_IMAGE_TYPE;
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// Pixels access routines ---------------------------------------------------
function FreeImage_GetBits(dib: PFIBITMAP): PByte;
function FreeImage_GetScanLine(dib: PFIBITMAP; scanline: Integer): PByte;
function FreeImage_GetPixelIndex(dib: PFIBITMAP; x, y: Cardinal; var value: Byte): LongBool;
function FreeImage_GetPixelColor(dib: PFIBITMAP; x, y: Cardinal; var value: RGBQUAD): LongBool;
function FreeImage_SetPixelIndex(dib: PFIBITMAP; x, y: Cardinal; var value: Byte): LongBool;
function FreeImage_SetPixelColor(dib: PFIBITMAP; x, y: Cardinal; var value: RGBQUAD): LongBool;
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// DIB info routines --------------------------------------------------------
function FreeImage_GetColorsUsed(dib: PFIBITMAP): Cardinal;
function FreeImage_GetBPP(dib: PFIBITMAP): Cardinal;
function FreeImage_GetWidth(dib: PFIBITMAP): Cardinal;
function FreeImage_GetHeight(dib: PFIBITMAP): Cardinal;
function FreeImage_GetLine(dib: PFIBITMAP): Cardinal;
function FreeImage_GetPitch(dib: PFIBITMAP): Cardinal;
function FreeImage_GetDIBSize(dib: PFIBITMAP): Cardinal;
function FreeImage_GetMemorySize(dib: PFIBITMAP): Cardinal;
function FreeImage_GetPalette(dib: PFIBITMAP): PRGBQuad;
function FreeImage_GetDotsPerMeterX(dib: PFIBITMAP): Cardinal;
function FreeImage_GetDotsPerMeterY(dib: PFIBITMAP): Cardinal;
procedure FreeImage_SetDotsPerMeterX(dib: PFIBITMAP; res: Cardinal);
procedure FreeImage_SetDotsPerMeterY(dib: PFIBITMAP; res: Cardinal);
function FreeImage_GetInfoHeader(dib: PFIBITMAP): PBITMAPINFOHEADER;
function FreeImage_GetInfo(dib: PFIBITMAP): PBITMAPINFO;
function FreeImage_GetColorType(dib: PFIBITMAP): FREE_IMAGE_COLOR_TYPE;
function FreeImage_GetRedMask(dib: PFIBITMAP): Cardinal;
function FreeImage_GetGreenMask(dib: PFIBITMAP): Cardinal;
function FreeImage_GetBlueMask(dib: PFIBITMAP): Cardinal;
function FreeImage_GetTransparencyCount(dib: PFIBITMAP): Cardinal;
function FreeImage_GetTransparencyTable(dib: PFIBITMAP): PByte;
procedure FreeImage_SetTransparent(dib: PFIBITMAP; enabled: LongBool);
procedure FreeImage_SetTransparencyTable(dib: PFIBITMAP; table: PByte;
  count: Integer);
function FreeImage_IsTransparent(dib: PFIBITMAP): LongBool;
function FreeImage_HasBackgroundColor(dib: PFIBITMAP): LongBool;
function FreeImage_GetBackgroundColor(dib: PFIBITMAP; var bkcolor: RGBQUAD): LongBool;
function FreeImage_SetBackgroundColor(dib: PFIBITMAP; bkcolor: PRGBQuad): LongBool;

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// Smart conversion routines ------------------------------------------------
function FreeImage_ConvertTo4Bits(dib: PFIBITMAP): PFIBITMAP;
function FreeImage_ConvertTo8Bits(dib: PFIBITMAP): PFIBITMAP;
function FreeImage_ConvertToGreyscale(dib: PFIBITMAP): PFIBITMAP;
function FreeImage_ConvertTo16Bits555(dib: PFIBITMAP): PFIBITMAP;
function FreeImage_ConvertTo16Bits565(dib: PFIBITMAP): PFIBITMAP;
function FreeImage_ConvertTo24Bits(dib: PFIBITMAP): PFIBITMAP;
function FreeImage_ConvertTo32Bits(dib: PFIBITMAP): PFIBITMAP;
function FreeImage_ColorQuantize(dib: PFIBITMAP; quantize: FREE_IMAGE_QUANTIZE): PFIBITMAP;
function FreeImage_Threshold(dib: PFIBITMAP; T: Byte): PFIBITMAP;
function FreeImage_Dither(dib: PFIBITMAP; algorithm: FREE_IMAGE_DITHER): PFIBITMAP;
function FreeImage_ConvertFromRawBits(bits: PByte; width, height, pitch: Integer;
  bpp, red_mask, green_mask, blue_mask: Cardinal; topdown: LongBool = False): PFIBITMAP;
function FreeImage_ConvertToRGBF(dib: PFIBITMAP): PFIBITMAP;
procedure FreeImage_ConvertToRawBits(bits: PByte; dib: PFIBITMAP; pitch: Integer;
  bpp, red_mask, green_mask, blue_mask: Cardinal; topdown: LongBool = False);
function FreeImage_ConvertToStandardType(src: PFIBITMAP;
  scale_linear: LongBool = True): PFIBITMAP;
function FreeImage_ConvertToType(src: PFIBITMAP; dst_type: FREE_IMAGE_TYPE;
  scale_linear: LongBool = True): PFIBITMAP;
function FreeImage_ToneMapping(dib: PFIBITMAP; tmo: FREE_IMAGE_TMO;
  first_param: Double = 0; second_param: Double = 0): PFIBITMAP;
function FreeImage_ZLibCompress(target: PByte; target_size: DWORD; source: PByte;
  source_size: DWORD): DWORD;
function FreeImage_ZLibUncompress(target: PByte; target_size: DWORD; source: PByte;
  source_size: DWORD): DWORD;
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// Metadata routines
function FreeImage_CreateTag: PFITAG;
function FreeImage_CloneTag(tag: PFITAG): PFITAG;
procedure FreeImage_DeleteTag(tag: PFITAG);
function FreeImage_GetTagCount(tag: PFITAG): DWORD;
function FreeImage_SetTagDescription(tag: PFITAG; description: PAnsiChar): LongBool;
function FreeImage_GetTagDescription(tag: PFITAG): PAnsiChar;
function FreeImage_GetTagID(tag: PFITAG): Word;
function FreeImage_GetTagKey(tag: PFITAG): PAnsiChar;
function FreeImage_GetTagType(tag: PFITAG): FREE_IMAGE_MDTYPE;
function FreeImage_GetTagLength(tag: PFITAG): DWORD;
function FreeImage_SetTagLength(tag: PFITAG; length: DWORD): LongBool;
function FreeImage_GetTagValue(tag: PFITAG): Pointer;
function FreeImage_SetTagKey(tag: PFITAG; key: PAnsiChar): LongBool;
function FreeImage_SetTagID(tag: PFITAG; id: Word): LongBool;
function FreeImage_SetTagType(tag: PFITAG; _type: FREE_IMAGE_MDTYPE): LongBool;
function FreeImage_SetTagCount(tag: PFITAG; count: DWORD): LongBool;
function FreeImage_SetTagValue(tag: PFITAG; value: Pointer): LongBool;
function FreeImage_TagToString(model: FREE_IMAGE_MDMODEL; tag: PFITAG;
  Make: PAnsiChar = nil): PAnsiChar;
function FreeImage_FindFirstMetadata(model: FREE_IMAGE_MDMODEL; dib: PFIBITMAP;
  var tag: PFITAG): PFIMETADATA;
function FreeImage_FindNextMetadata(mdhandle: PFIMETADATA; var tag: PFITAG): LongBool;
procedure FreeImage_FindCloseMetadata(mdhandle: PFIMETADATA);
function FreeImage_SetMetadata(model: FREE_IMAGE_MDMODEL; dib: PFIBITMAP;
  key: PAnsiChar; tag: PFITAG): LongBool;
function FreeImage_GetMetadata(model: FREE_IMAGE_MDMODEL; dib: PFIBITMAP;
  key: PAnsiChar; var tag: PFITAG): LongBool;
function FreeImage_SetMetadataKeyValue(model: FREE_IMAGE_MDMODEL; dib: PFIBITMAP;
  key, value: PAnsiChar): LongBool;
function FreeImage_GetMetadataCount(model: FREE_IMAGE_MDMODEL; dib: PFIBITMAP): Cardinal;
function FreeImage_CloneMetadata(dst, src: PFIBITMAP): LongBool;
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// Image manipulation toolkit
function FreeImage_Rotate(dib: PFIBITMAP; angle: Double; bkcolor: Pointer = nil): PFIBITMAP;
function FreeImage_RotateEx(dib: PFIBITMAP; angle, x_shift, y_shift, x_origin, y_origin: Double;
  use_mask: LongBool): PFIBITMAP;
function FreeImage_FlipHorizontal(dib: PFIBITMAP): LongBool;
function FreeImage_FlipVertical(dib: PFIBITMAP): LongBool;
function FreeImage_Rescale(dib: PFIBITMAP; dst_width, dst_height: Integer;
  filter: FREE_IMAGE_FILTER = FILTER_CATMULLROM): PFIBITMAP;
function FreeImage_MakeThumbnail(dib: PFIBITMAP; max_pixel_size: Integer;
         convert: LongBool = True): PFIBITMAP;
function FreeImage_RescaleRect(dib: PFIBITMAP; dst_width, dst_height, left, top, right, bottom: Integer;
  filter: FREE_IMAGE_FILTER = FILTER_CATMULLROM; flags: Cardinal = 0): PFIBITMAP;
function FreeImage_AdjustCurve(dib: PFIBITMAP; LUT: PByte;
  channel: FREE_IMAGE_COLOR_CHANNEL): LongBool;
function FreeImage_AdjustGamma(dib: PFIBITMAP; gamma: Double): LongBool;
function FreeImage_AdjustBrightness(dib: PFIBITMAP; percentage: Double): LongBool;
function FreeImage_AdjustContrast(dib: PFIBITMAP; percentage: Double): LongBool;
function FreeImage_GetHistogram(dib: PFIBITMAP; histo: PDWORD;
  channel: FREE_IMAGE_COLOR_CHANNEL = FICC_BLACK): LongBool;
function FreeImage_SetChannel(dst, src: PFIBITMAP; channel: FREE_IMAGE_COLOR_CHANNEL): LongBool;
function FreeImage_GetChannel(dib: PFIBITMAP; channel: FREE_IMAGE_COLOR_CHANNEL): PFIBITMAP;
function FreeImage_GetComplexChannel(src: PFIBITMAP; channel: FREE_IMAGE_COLOR_CHANNEL): PFIBITMAP;
function FreeImage_CreateView(dib: PFIBITMAP; left, top, right, bottom: Cardinal): PFIBITMAP;
function FreeImage_Copy(dib: PFIBITMAP; left, top, right, bottom: Integer): PFIBITMAP;
function FreeImage_Paste(dst, src: PFIBITMAP; left, top, alpha: Integer): LongBool;









implementation

procedure load;
begin
FreeimageHandle:=FindAndLoadLibrary(FIDLL);
assert(FreeimageHandleIsValid,'library named '+FIDLL+' not loaded');
end;

function FreeimageHandleIsValid:boolean;
begin
result:=not(FreeimageHandle=NilHandle);
end;

procedure FreeImage_Initialise(load_local_plugins_only: LongBool = False);
type TFreeImage_Initialise = procedure(load_local_plugins_only: LongBool = False); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_Initialise');
assert(Pproc<>nil,'library method not found');
TFreeImage_Initialise(Pproc)(load_local_plugins_only);
end;

procedure FreeImage_DeInitialise;
type TFreeImage_DeInitialise = procedure {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_DeInitialise');
assert(Pproc<>nil,'library method not found');
TFreeImage_DeInitialise(Pproc);
end;

function FreeImage_GetVersion: PAnsiChar;
type TFreeImage_GetVersion=function: PAnsiChar; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetVersion');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetVersion(Pproc)();
end;

function FreeImage_GetCopyrightMessage: PAnsiChar;
type TFreeImage_GetCopyrightMessage = function:PAnsiChar; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetCopyrightMessage');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetCopyrightMessage(Pproc)();
end;

function FreeImage_Allocate(width, height, bpp: Integer; red_mask: Cardinal = 0;
  green_mask: Cardinal = 0; blue_mask: Cardinal = 0): PFIBITMAP;
type TFreeImage_Allocate = function(width, height, bpp: Integer; red_mask: Cardinal = 0;
  green_mask: Cardinal = 0; blue_mask: Cardinal = 0): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_Allocate');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_Allocate(Pproc)(width, height, bpp,red_mask,green_mask,blue_mask);
end;

function FreeImage_AllocateT(_type: FREE_IMAGE_TYPE; width, height: Integer;
  bpp: Integer = 8; red_mask: Cardinal = 0; green_mask: Cardinal = 0;
  blue_mask: Cardinal = 0): PFIBITMAP;
type TFreeImage_AllocateT = function(_type: FREE_IMAGE_TYPE; width, height: Integer;
  bpp: Integer = 8; red_mask: Cardinal = 0; green_mask: Cardinal = 0;
  blue_mask: Cardinal = 0): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_AllocateT');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_AllocateT(Pproc)(_type,width, height, bpp,red_mask,green_mask,blue_mask);
end;

function FreeImage_Clone(dib: PFIBITMAP): PFIBITMAP;
type TFreeImage_Clone=function (dib: PFIBITMAP): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_Clone');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_Clone(Pproc)(dib);
end;

procedure FreeImage_Unload(dib: PFIBITMAP);
type TFreeImage_Unload=procedure (dib: PFIBITMAP); {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_Unload');
assert(Pproc<>nil,'library method not found');
TFreeImage_Unload(Pproc)(dib);
end;

function FreeImage_HasPixels(dib: PFIBITMAP): LongBool;
type TFreeImage_HasPixels=function (dib: PFIBITMAP): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_HasPixels');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_HasPixels(Pproc)(dib);
end;

function FreeImage_Load(fif: FREE_IMAGE_FORMAT; filename: PAnsiChar;
  flags: Integer = 0): PFIBITMAP;
type TFreeImage_Load= function (fif: FREE_IMAGE_FORMAT; filename: PAnsiChar;
  flags: Integer = 0): PFIBITMAP; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_Load');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_Load(Pproc)(fif,filename,flags);
end;

function FreeImage_LoadU(fif: FREE_IMAGE_FORMAT; filename: PWideChar;
  flags: Integer = 0): PFIBITMAP;
type TFreeImage_LoadU =function (fif: FREE_IMAGE_FORMAT; filename: PWideChar;
  flags: Integer = 0): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_LoadU');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_LoadU(Pproc)(fif,filename,flags);
end;

function FreeImage_LoadFromHandle(fif: FREE_IMAGE_FORMAT; io: PFreeImageIO;
  handle: fi_handle; flags: Integer = 0): PFIBITMAP;
type TFreeImage_LoadFromHandle=function (fif: FREE_IMAGE_FORMAT; io: PFreeImageIO;
  handle: fi_handle; flags: Integer = 0): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_LoadFromHandle');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_LoadFromHandle(Pproc)(fif,io,handle,flags);
end;

function FreeImage_Save(fif: FREE_IMAGE_FORMAT; dib: PFIBITMAP; filename: PAnsiChar;
  flags: Integer = 0): LongBool;
type TFreeImage_Save=function (fif: FREE_IMAGE_FORMAT; dib: PFIBITMAP; filename: PAnsiChar;
  flags: Integer = 0): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_Save');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_Save(Pproc)(fif,dib,filename,flags);
end;

function FreeImage_SaveU(fif: FREE_IMAGE_FORMAT; dib: PFIBITMAP; filename: PWideChar;
  flags: Integer = 0): LongBool;
type TFreeImage_SaveU =function (fif: FREE_IMAGE_FORMAT; dib: PFIBITMAP; filename: PWideChar;
  flags: Integer = 0): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SaveU');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SaveU(Pproc)(fif,dib,filename,flags);
end;

function FreeImage_SaveToHandle(fif: FREE_IMAGE_FORMAT; dib: PFIBITMAP;
  io: PFreeImageIO; handle: fi_handle; flags: Integer = 0): LongBool;
type TFreeImage_SaveToHandle=function (fif: FREE_IMAGE_FORMAT; dib: PFIBITMAP;
  io: PFreeImageIO; handle: fi_handle; flags: Integer = 0): LongBool;
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SaveToHandle');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SaveToHandle(Pproc)(fif,dib,io,handle,flags);
end;

function FreeImage_OpenMemory(data: PByte = nil; size_in_bytes: DWORD = 0): PFIMEMORY;
type TFreeImage_OpenMemory=function (data: PByte = nil; size_in_bytes: DWORD = 0): PFIMEMORY;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_OpenMemory');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_OpenMemory(Pproc)(data,size_in_bytes);
end;

procedure FreeImage_CloseMemory(stream: PFIMEMORY);
type TFreeImage_CloseMemory=procedure (stream: PFIMEMORY);{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_CloseMemory');
assert(Pproc<>nil,'library method not found');
TFreeImage_CloseMemory(Pproc)(stream);
end;

function FreeImage_LoadFromMemory(fif: FREE_IMAGE_FORMAT; stream: PFIMEMORY;
  flags: Integer = 0): PFIBITMAP;
type TFreeImage_LoadFromMemory=function (fif: FREE_IMAGE_FORMAT; stream: PFIMEMORY;
  flags: Integer = 0): PFIBITMAP;
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_LoadFromMemory');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_LoadFromMemory(Pproc)(fif, stream,flags);
end;

function FreeImage_SaveToMemory(fif: FREE_IMAGE_FORMAT; dib: PFIBITMAP;
  stream: PFIMEMORY; flags: Integer = 0): LongBool;
type TFreeImage_SaveToMemory=function (fif: FREE_IMAGE_FORMAT; dib: PFIBITMAP;
  stream: PFIMEMORY; flags: Integer = 0): LongBool; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SaveToMemory');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SaveToMemory(Pproc)(fif,dib,stream,flags);
end;

function FreeImage_TellMemory(stream: PFIMEMORY): LongInt;
type TFreeImage_TellMemory=function (stream: PFIMEMORY): LongInt;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_TellMemory');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_TellMemory(Pproc)(stream);
end;

function FreeImage_SeekMemory(stream: PFIMEMORY; offset: LongInt;
  origin: Integer): LongBool;
type TFreeImage_SeekMemory=function (stream: PFIMEMORY; offset: LongInt;
  origin: Integer): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SeekMemory');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SeekMemory(Pproc)(stream,offset,origin);
end;

function FreeImage_AcquireMemory(stream: PFIMEMORY; var data: PByte;
  var size_in_bytes: DWORD): LongBool;
type TFreeImage_AcquireMemory=function (stream: PFIMEMORY; var data: PByte;
  var size_in_bytes: DWORD): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_AcquireMemory');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_AcquireMemory(Pproc)(stream,data,size_in_bytes);
end;

function FreeImage_ReadMemory(buffer: Pointer; size, count: Cardinal;
  stream: PFIMEMORY): Cardinal;
type TFreeImage_ReadMemory=function (buffer: Pointer; size, count: Cardinal;
  stream: PFIMEMORY): Cardinal;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ReadMemory');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_ReadMemory(Pproc)(buffer,size, count,stream);
end;

function FreeImage_WriteMemory(buffer: Pointer; size, count: Cardinal;
  stream: PFIMEMORY): Cardinal;
type TFreeImage_WriteMemory=function (buffer: Pointer; size, count: Cardinal;
  stream: PFIMEMORY): Cardinal;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_WriteMemory');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_WriteMemory(Pproc)(buffer,size, count,stream);
end;

function FreeImage_LoadMultiBitmapFromMemory(fif: FREE_IMAGE_FORMAT; stream: PFIMEMORY;
  flags: Integer = 0): PFIMULTIBITMAP;
type TFreeImage_LoadMultiBitmapFromMemory=function (fif: FREE_IMAGE_FORMAT; stream: PFIMEMORY;
  flags: Integer = 0): PFIMULTIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_LoadMultiBitmapFromMemory');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_LoadMultiBitmapFromMemory(Pproc)(fif,stream,flags);
end;

function FreeImage_SaveMultiBitmapToMemory(fif: FREE_IMAGE_FORMAT; bitmap: PFIMULTIBITMAP;
  stream: PFIMEMORY; flags: Integer): LongBool;
type TFreeImage_SaveMultiBitmapToMemory=function (fif: FREE_IMAGE_FORMAT; bitmap: PFIMULTIBITMAP;
  stream: PFIMEMORY; flags: Integer): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SaveMultiBitmapToMemory');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SaveMultiBitmapToMemory(Pproc)(fif,bitmap,stream,flags);
end;


function FreeImage_GetFIFFromFilename(filename: PAnsiChar): FREE_IMAGE_FORMAT;
type TFreeImage_GetFIFFromFilename=function (filename: PAnsiChar): FREE_IMAGE_FORMAT;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetFIFFromFilename');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetFIFFromFilename(Pproc)(filename);
end;

function FreeImage_GetFIFFromFilenameU(filename: PWideChar): FREE_IMAGE_FORMAT;
type TFreeImage_GetFIFFromFilenameU=function (filename: PWideChar): FREE_IMAGE_FORMAT;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetFIFFromFilenameU');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetFIFFromFilenameU(Pproc)(filename);
end;

function FreeImage_FIFSupportsReading(fif: FREE_IMAGE_FORMAT): LongBool;
type TFreeImage_FIFSupportsReading=function (fif: FREE_IMAGE_FORMAT): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_FIFSupportsReading');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_FIFSupportsReading(Pproc)(fif);
end;

function FreeImage_FIFSupportsWriting(fif: FREE_IMAGE_FORMAT): LongBool;
type TFreeImage_FIFSupportsWriting=function (fif: FREE_IMAGE_FORMAT): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_FIFSupportsWriting');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_FIFSupportsWriting(Pproc)(fif);
end;

function FreeImage_FIFSupportsExportBPP(fif: FREE_IMAGE_FORMAT;
  bpp: Integer): LongBool;
type TFreeImage_FIFSupportsExportBPP=function (fif: FREE_IMAGE_FORMAT;
  bpp: Integer): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_FIFSupportsExportBPP');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_FIFSupportsExportBPP(Pproc)(fif, bpp);
end;

function FreeImage_FIFSupportsExportType(fif: FREE_IMAGE_FORMAT;
  _type: FREE_IMAGE_TYPE): LongBool;
type TFreeImage_FIFSupportsExportType=function (fif: FREE_IMAGE_FORMAT;
  _type: FREE_IMAGE_TYPE): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_FIFSupportsExportType');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_FIFSupportsExportType(Pproc)(fif,_type);
end;


function FreeImage_OpenMultiBitmap(fif: FREE_IMAGE_FORMAT; filename: PAnsiChar;
  create_new, read_only: LongBool; keep_cache_in_memory: LongBool = False;
  flags: Integer = 0): PFIMULTIBITMAP;
type TFreeImage_OpenMultiBitmap=function (fif: FREE_IMAGE_FORMAT; filename: PAnsiChar;
  create_new, read_only: LongBool; keep_cache_in_memory: LongBool = False;
  flags: Integer = 0): PFIMULTIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_OpenMultiBitmap');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_OpenMultiBitmap(Pproc)(fif,filename,create_new,
                                read_only,keep_cache_in_memory,flags);
end;

function FreeImage_OpenMultiBitmapFromHandle(fif: FREE_IMAGE_FORMAT; io: PFreeImageIO;
  handle: fi_handle; flags: Integer = 0): PFIMULTIBITMAP;
type TFreeImage_OpenMultiBitmapFromHandle=function (fif: FREE_IMAGE_FORMAT; io: PFreeImageIO;
  handle: fi_handle; flags: Integer = 0): PFIMULTIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_OpenMultiBitmapFromHandle');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_OpenMultiBitmapFromHandle(Pproc)(fif,io,handle,flags);
end;

function FreeImage_SaveMultiBitmapToHandle(fif: FREE_IMAGE_FORMAT; bitmap: PFIMULTIBITMAP;
  io: PFreeImageIO; handle: fi_handle; flags: Integer = 0): LongBool;
type TFreeImage_SaveMultiBitmapToHandle=function (fif: FREE_IMAGE_FORMAT; bitmap: PFIMULTIBITMAP;
  io: PFreeImageIO; handle: fi_handle; flags: Integer = 0): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SaveMultiBitmapToHandle');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SaveMultiBitmapToHandle(Pproc)(fif,bitmap,io,handle,flags);
end;

function FreeImage_CloseMultiBitmap(bitmap: PFIMULTIBITMAP;
  flags: Integer = 0): LongBool;
type TFreeImage_CloseMultiBitmap=function (bitmap: PFIMULTIBITMAP;
  flags: Integer = 0): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_CloseMultiBitmap');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_CloseMultiBitmap(Pproc)(bitmap,flags);
end;

function FreeImage_GetPageCount(bitmap: PFIMULTIBITMAP): Integer;
type TFreeImage_GetPageCount=function (bitmap: PFIMULTIBITMAP): Integer;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetPageCount');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetPageCount(Pproc)(bitmap);
end;

procedure FreeImage_AppendPage(bitmap: PFIMULTIBITMAP; data: PFIBITMAP);
type TFreeImage_AppendPage=procedure (bitmap: PFIMULTIBITMAP; data: PFIBITMAP);{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_AppendPage');
assert(Pproc<>nil,'library method not found');
TFreeImage_AppendPage(Pproc)(bitmap,data);
end;

procedure FreeImage_InsertPage(bitmap: PFIMULTIBITMAP; page: Integer;
  data: PFIBITMAP);
type TFreeImage_InsertPage=procedure (bitmap: PFIMULTIBITMAP; page: Integer;
  data: PFIBITMAP);{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_InsertPage');
assert(Pproc<>nil,'library method not found');
TFreeImage_InsertPage(Pproc)(bitmap,page,data);
end;

procedure FreeImage_DeletePage(bitmap: PFIMULTIBITMAP; page: Integer);
type TFreeImage_DeletePage=procedure (bitmap: PFIMULTIBITMAP; page: Integer);{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_DeletePage');
assert(Pproc<>nil,'library method not found');
TFreeImage_DeletePage(Pproc)(bitmap,page);
end;

function FreeImage_LockPage(bitmap: PFIMULTIBITMAP; page: Integer): PFIBITMAP;
type TFreeImage_LockPage=function (bitmap: PFIMULTIBITMAP; page: Integer): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_LockPage');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_LockPage(Pproc)(bitmap,page);
end;

procedure FreeImage_UnlockPage(bitmap: PFIMULTIBITMAP; data: PFIBITMAP;
  changed: LongBool);
type TFreeImage_UnlockPage=procedure (bitmap: PFIMULTIBITMAP; data: PFIBITMAP;
  changed: LongBool);{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_UnlockPage');
assert(Pproc<>nil,'library method not found');
TFreeImage_UnlockPage(Pproc)(bitmap,data,changed);
end;

function FreeImage_MovePage(bitmap: PFIMULTIBITMAP; target, source: Integer): LongBool;
type TFreeImage_MovePage=function (bitmap: PFIMULTIBITMAP; target, source: Integer): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_MovePage');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_MovePage(Pproc)(bitmap,target,source);
end;

function FreeImage_GetLockedPageNumbers(bitmap: PFIMULTIBITMAP; pages: PInteger;
      count: PInteger): LongBool;
type TFreeImage_GetLockedPageNumbers=function (bitmap: PFIMULTIBITMAP; pages: PInteger;
      count: PInteger): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetLockedPageNumbers');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetLockedPageNumbers(Pproc)(bitmap, pages,count);
end;

function FreeImage_GetFileType(filename: PAnsiChar;
  size: Integer = 0): FREE_IMAGE_FORMAT;
type TFreeImage_GetFileType=function (filename: PAnsiChar;
  size: Integer = 0): FREE_IMAGE_FORMAT;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetFileType');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetFileType(Pproc)(filename,size);
end;

function FreeImage_GetFileTypeU(filename: PWideChar;
  size: Integer = 0): FREE_IMAGE_FORMAT;
type TFreeImage_GetFileTypeU=function (filename: PWideChar;
  size: Integer = 0): FREE_IMAGE_FORMAT;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetFileTypeU');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetFileTypeU(Pproc)(filename,size);
end;

function FreeImage_GetFileTypeFromHandle(io: PFreeImageIO; handle: FI_Handle;
  size: Integer = 0): FREE_IMAGE_FORMAT;
type TFreeImage_GetFileTypeFromHandle=function (io: PFreeImageIO; handle: FI_Handle;
  size: Integer = 0): FREE_IMAGE_FORMAT;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetFileTypeFromHandle');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetFileTypeFromHandle(Pproc)(io, handle,size);
end;

function FreeImage_GetFileTypeFromMemory(stream: PFIMEMORY;
  size: Integer = 0): FREE_IMAGE_FORMAT;
type TFreeImage_GetFileTypeFromMemory=function (stream: PFIMEMORY;
  size: Integer = 0): FREE_IMAGE_FORMAT;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetFileTypeFromMemory');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetFileTypeFromMemory(Pproc)(stream,size);
end;

function FreeImage_GetImageType(dib: PFIBITMAP): FREE_IMAGE_TYPE;
type TFreeImage_GetImageType=function (dib: PFIBITMAP): FREE_IMAGE_TYPE;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetImageType');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetImageType(Pproc)(dib);
end;

function FreeImage_GetBits(dib: PFIBITMAP): PByte;
type TFreeImage_GetBits=function (dib: PFIBITMAP): PByte;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetBits');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetBits(Pproc)(dib);
end;

function FreeImage_GetScanLine(dib: PFIBITMAP; scanline: Integer): PByte;
type TFreeImage_GetScanLine=function (dib: PFIBITMAP; scanline: Integer): PByte;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetScanLine');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetScanLine(Pproc)(dib,scanline);
end;

function FreeImage_GetPixelIndex(dib: PFIBITMAP; x, y: Cardinal; var value: Byte): LongBool;
type TFreeImage_GetPixelIndex=function (dib: PFIBITMAP; x, y: Cardinal; var value: Byte): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetPixelIndex');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetPixelIndex(Pproc)(dib,x, y,value);
end;

function FreeImage_GetPixelColor(dib: PFIBITMAP; x, y: Cardinal; var value: RGBQUAD): LongBool;
type TFreeImage_GetPixelColor=function (dib: PFIBITMAP; x, y: Cardinal; var value: RGBQUAD): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetPixelColor');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetPixelColor(Pproc)(dib,x, y,value);
end;
function FreeImage_SetPixelIndex(dib: PFIBITMAP; x, y: Cardinal; var value: Byte): LongBool;
type TFreeImage_SetPixelIndex=function (dib: PFIBITMAP; x, y: Cardinal; var value: Byte): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetPixelIndex');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SetPixelIndex(Pproc)(dib,x, y,value);
end;

function FreeImage_SetPixelColor(dib: PFIBITMAP; x, y: Cardinal; var value: RGBQUAD): LongBool;
type TFreeImage_SetPixelColor=function (dib: PFIBITMAP; x, y: Cardinal; var value: RGBQUAD): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetPixelColor');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SetPixelColor(Pproc)(dib,x, y,value);
end;

function FreeImage_GetColorsUsed(dib: PFIBITMAP): Cardinal;
type TFreeImage_GetColorsUsed=function (dib: PFIBITMAP): Cardinal;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetColorsUsed');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetColorsUsed(Pproc)(dib);
end;

function FreeImage_GetBPP(dib: PFIBITMAP): Cardinal;
type TFreeImage_GetBPP=function (dib: PFIBITMAP): Cardinal; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetBPP');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetBPP(Pproc)(dib);
end;

function FreeImage_GetWidth(dib: PFIBITMAP): Cardinal;
type TFreeImage_GetWidth=function (dib: PFIBITMAP): Cardinal;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetWidth');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetWidth(Pproc)(dib);
end;

function FreeImage_GetHeight(dib: PFIBITMAP): Cardinal;
type TFreeImage_GetHeight=function (dib: PFIBITMAP): Cardinal;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetHeight');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetHeight(Pproc)(dib);
end;

function FreeImage_GetLine(dib: PFIBITMAP): Cardinal;
type TFreeImage_GetLine=function (dib: PFIBITMAP): Cardinal;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetLine');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetLine(Pproc)(dib);
end;

function FreeImage_GetPitch(dib: PFIBITMAP): Cardinal;
type TFreeImage_GetPitch=function (dib: PFIBITMAP): Cardinal;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetPitch');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetPitch(Pproc)(dib);
end;

function FreeImage_GetDIBSize(dib: PFIBITMAP): Cardinal;
type TFreeImage_GetDIBSize=function (dib: PFIBITMAP): Cardinal;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetDIBSize');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetDIBSize(Pproc)(dib);
end;

function FreeImage_GetMemorySize(dib: PFIBITMAP): Cardinal;
type TFreeImage_GetMemorySize=function (dib: PFIBITMAP): Cardinal;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetMemorySize');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetMemorySize(Pproc)(dib);
end;


function FreeImage_GetPalette(dib: PFIBITMAP): PRGBQuad;
type TFreeImage_GetPalette=function (dib: PFIBITMAP): PRGBQuad;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetPalette');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetPalette(Pproc)(dib);
end;

function FreeImage_GetDotsPerMeterX(dib: PFIBITMAP): Cardinal;
type TFreeImage_GetDotsPerMeterX=function (dib: PFIBITMAP): Cardinal;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetDotsPerMeterX');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetDotsPerMeterX(Pproc)(dib);
end;

function FreeImage_GetDotsPerMeterY(dib: PFIBITMAP): Cardinal;
type TFreeImage_GetDotsPerMeterY=function (dib: PFIBITMAP): Cardinal;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetDotsPerMeterY');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetDotsPerMeterY(Pproc)(dib);
end;

procedure FreeImage_SetDotsPerMeterX(dib: PFIBITMAP; res: Cardinal);
type TFreeImage_SetDotsPerMeterX=procedure (dib: PFIBITMAP; res: Cardinal);{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetDotsPerMeterX');
assert(Pproc<>nil,'library method not found');
TFreeImage_SetDotsPerMeterX(Pproc)(dib,res);
end;

procedure FreeImage_SetDotsPerMeterY(dib: PFIBITMAP; res: Cardinal);
type TFreeImage_SetDotsPerMeterY=procedure (dib: PFIBITMAP; res: Cardinal);{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetDotsPerMeterY');
assert(Pproc<>nil,'library method not found');
TFreeImage_SetDotsPerMeterY(Pproc)(dib,res);
end;

function FreeImage_GetInfoHeader(dib: PFIBITMAP): PBITMAPINFOHEADER;
type TFreeImage_GetInfoHeader=function (dib: PFIBITMAP): PBITMAPINFOHEADER;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetInfoHeader');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetInfoHeader(Pproc)(dib);
end;

function FreeImage_GetInfo(dib: PFIBITMAP): PBITMAPINFO;
type TFreeImage_GetInfo=function (dib: PFIBITMAP): PBITMAPINFO;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetInfo');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetInfo(Pproc)(dib);
end;

function FreeImage_GetColorType(dib: PFIBITMAP): FREE_IMAGE_COLOR_TYPE;
type TFreeImage_GetColorType=function (dib: PFIBITMAP): FREE_IMAGE_COLOR_TYPE;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetColorType');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetColorType(Pproc)(dib);
end;

function FreeImage_GetRedMask(dib: PFIBITMAP): Cardinal;
type TFreeImage_GetRedMask=function (dib: PFIBITMAP): Cardinal;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetRedMask');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetRedMask(Pproc)(dib);
end;


function FreeImage_GetGreenMask(dib: PFIBITMAP): Cardinal;
type TFreeImage_GetGreenMask=function (dib: PFIBITMAP): Cardinal;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetGreenMask');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetGreenMask(Pproc)(dib);
end;

function FreeImage_GetBlueMask(dib: PFIBITMAP): Cardinal;
type TFreeImage_GetBlueMask=function (dib: PFIBITMAP): Cardinal;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetBlueMask');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetBlueMask(Pproc)(dib);
end;

function FreeImage_GetTransparencyCount(dib: PFIBITMAP): Cardinal;
type TFreeImage_GetTransparencyCount=function (dib: PFIBITMAP): Cardinal;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetTransparencyCount');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetTransparencyCount(Pproc)(dib);
end;

function FreeImage_GetTransparencyTable(dib: PFIBITMAP): PByte;
type TFreeImage_GetTransparencyTable=function (dib: PFIBITMAP): PByte;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetTransparencyTable');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetTransparencyTable(Pproc)(dib);
end;

procedure FreeImage_SetTransparent(dib: PFIBITMAP; enabled: LongBool);
type TFreeImage_SetTransparent=procedure (dib: PFIBITMAP; enabled: LongBool);{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetTransparent');
assert(Pproc<>nil,'library method not found');
TFreeImage_SetTransparent(Pproc)(dib,enabled);
end;

procedure FreeImage_SetTransparencyTable(dib: PFIBITMAP; table: PByte;
  count: Integer);
type TFreeImage_SetTransparencyTable=procedure (dib: PFIBITMAP; table: PByte;
  count: Integer);{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetTransparencyTable');
assert(Pproc<>nil,'library method not found');
TFreeImage_SetTransparencyTable(Pproc)(dib,table,count);
end;

function FreeImage_IsTransparent(dib: PFIBITMAP): LongBool;
type TFreeImage_IsTransparent=function (dib: PFIBITMAP): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_IsTransparent');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_IsTransparent(Pproc)(dib);
end;

function FreeImage_HasBackgroundColor(dib: PFIBITMAP): LongBool;
type TFreeImage_HasBackgroundColor=function (dib: PFIBITMAP): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_HasBackgroundColor');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_HasBackgroundColor(Pproc)(dib);
end;

function FreeImage_GetBackgroundColor(dib: PFIBITMAP; var bkcolor: RGBQUAD): LongBool;
type TFreeImage_GetBackgroundColor=function (dib: PFIBITMAP; var bkcolor: RGBQUAD): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetBackgroundColor');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetBackgroundColor(Pproc)(dib,bkcolor);
end;

function FreeImage_SetBackgroundColor(dib: PFIBITMAP; bkcolor: PRGBQuad): LongBool;
type TFreeImage_SetBackgroundColor=function (dib: PFIBITMAP; bkcolor: PRGBQuad): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetBackgroundColor');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SetBackgroundColor(Pproc)(dib,bkcolor);
end;

function FreeImage_ConvertTo4Bits(dib: PFIBITMAP): PFIBITMAP;
type TFreeImage_ConvertTo4Bits=function (dib: PFIBITMAP): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ConvertTo4Bits');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_ConvertTo4Bits(Pproc)(dib);
end;

function FreeImage_ConvertTo8Bits(dib: PFIBITMAP): PFIBITMAP;
type TFreeImage_ConvertTo8Bits=function (dib: PFIBITMAP): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ConvertTo8Bits');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_ConvertTo8Bits(Pproc)(dib);
end;


function FreeImage_ConvertToGreyscale(dib: PFIBITMAP): PFIBITMAP;
type TFreeImage_ConvertToGreyscale=function (dib: PFIBITMAP): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ConvertToGreyscale');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_ConvertToGreyscale(Pproc)(dib);
end;


function FreeImage_ConvertTo16Bits555(dib: PFIBITMAP): PFIBITMAP;
type TFreeImage_ConvertTo16Bits555=function (dib: PFIBITMAP): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ConvertTo16Bits555');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_ConvertTo16Bits555(Pproc)(dib);
end;


function FreeImage_ConvertTo16Bits565(dib: PFIBITMAP): PFIBITMAP;
type TFreeImage_ConvertTo16Bits565=function (dib: PFIBITMAP): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ConvertTo16Bits565');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_ConvertTo16Bits565(Pproc)(dib);
end;

function FreeImage_ConvertTo24Bits(dib: PFIBITMAP): PFIBITMAP;
type TFreeImage_ConvertTo24Bits=function (dib: PFIBITMAP): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ConvertTo24Bits');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_ConvertTo24Bits(Pproc)(dib);
end;

function FreeImage_ConvertTo32Bits(dib: PFIBITMAP): PFIBITMAP;
type TFreeImage_ConvertTo32Bits=function (dib: PFIBITMAP): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ConvertTo32Bits');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_ConvertTo32Bits(Pproc)(dib);
end;

function FreeImage_ColorQuantize(dib: PFIBITMAP; quantize: FREE_IMAGE_QUANTIZE): PFIBITMAP;
type TFreeImage_ColorQuantize=function (dib: PFIBITMAP; quantize: FREE_IMAGE_QUANTIZE): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ColorQuantize');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_ColorQuantize(Pproc)(dib,quantize);
end;

function FreeImage_Threshold(dib: PFIBITMAP; T: Byte): PFIBITMAP;
type TFreeImage_Threshold=function (dib: PFIBITMAP; T: Byte): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_Threshold');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_Threshold(Pproc)(dib,T);
end;

function FreeImage_Dither(dib: PFIBITMAP; algorithm: FREE_IMAGE_DITHER): PFIBITMAP;
type TFreeImage_Dither=function (dib: PFIBITMAP; algorithm: FREE_IMAGE_DITHER): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_Dither');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_Dither(Pproc)(dib,algorithm);
end;

function FreeImage_ConvertFromRawBits(bits: PByte; width, height, pitch: Integer;
  bpp, red_mask, green_mask, blue_mask: Cardinal; topdown: LongBool = False): PFIBITMAP;
type TFreeImage_ConvertFromRawBits=function (bits: PByte; width, height, pitch: Integer;
  bpp, red_mask, green_mask, blue_mask: Cardinal; topdown: LongBool = False): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ConvertFromRawBits');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_ConvertFromRawBits(Pproc)(bits,width, height, pitch,bpp,
        red_mask, green_mask, blue_mask,topdown);
end;

function FreeImage_ConvertToRGBF(dib: PFIBITMAP): PFIBITMAP;
type TFreeImage_ConvertToRGBF=function (dib: PFIBITMAP): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ConvertToRGBF');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_ConvertToRGBF(Pproc)(dib);
end;

procedure FreeImage_ConvertToRawBits(bits: PByte; dib: PFIBITMAP; pitch: Integer;
  bpp, red_mask, green_mask, blue_mask: Cardinal; topdown: LongBool = False);
type TFreeImage_ConvertToRawBits=procedure (bits: PByte; dib: PFIBITMAP; pitch: Integer;
  bpp, red_mask, green_mask, blue_mask: Cardinal; topdown: LongBool = False);{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ConvertTo4Bits');
assert(Pproc<>nil,'library method not found');
TFreeImage_ConvertToRawBits(Pproc)(bits,dib,pitch,bpp,
        red_mask, green_mask, blue_mask,topdown);
end;

function FreeImage_ConvertToStandardType(src: PFIBITMAP;
  scale_linear: LongBool = True): PFIBITMAP;
type TFreeImage_ConvertToStandardType=function (src: PFIBITMAP;
  scale_linear: LongBool = True): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ConvertToStandardType');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_ConvertToStandardType(Pproc)(src,scale_linear);
end;

function FreeImage_ConvertToType(src: PFIBITMAP; dst_type: FREE_IMAGE_TYPE;
  scale_linear: LongBool = True): PFIBITMAP;
type TFreeImage_ConvertToType=function (src: PFIBITMAP; dst_type: FREE_IMAGE_TYPE;
  scale_linear: LongBool = True): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ConvertToType');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_ConvertToType(Pproc)(src,dst_type,scale_linear);
end;

function FreeImage_ToneMapping(dib: PFIBITMAP; tmo: FREE_IMAGE_TMO;
  first_param: Double = 0; second_param: Double = 0): PFIBITMAP;
type TFreeImage_ToneMapping=function (dib: PFIBITMAP; tmo: FREE_IMAGE_TMO;
  first_param: Double = 0; second_param: Double = 0): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ToneMapping');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_ToneMapping(Pproc)(dib,tmo,first_param,second_param);
end;

function FreeImage_ZLibCompress(target: PByte; target_size: DWORD; source: PByte;
         source_size: DWORD): DWORD;
type TFreeImage_ZLibCompress=function (target: PByte; target_size: DWORD; source: PByte; source_size: DWORD): DWORD; {$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ZLibCompress');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_ZLibCompress(Pproc)(target,target_size,source,source_size);
end;

function FreeImage_ZLibUncompress(target: PByte; target_size: DWORD; source: PByte;
  source_size: DWORD): DWORD;
type TFreeImage_ZLibUncompress=function (target: PByte; target_size: DWORD; source: PByte;
  source_size: DWORD): DWORD;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_ZLibUncompress');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_ZLibUncompress(Pproc)(target,target_size,source,source_size);
end;

function FreeImage_CreateTag: PFITAG;
type TFreeImage_CreateTag=function : PFITAG;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_CreateTag');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_CreateTag(Pproc)();
end;

function FreeImage_CloneTag(tag: PFITAG): PFITAG;
type TFreeImage_CloneTag=function (tag: PFITAG): PFITAG;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_CloneTag');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_CloneTag(Pproc)(tag);
end;

procedure FreeImage_DeleteTag(tag: PFITAG);
type TFreeImage_DeleteTag=procedure (tag: PFITAG);{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_DeleteTag');
assert(Pproc<>nil,'library method not found');
TFreeImage_DeleteTag(Pproc)(tag);
end;

function FreeImage_GetTagCount(tag: PFITAG): DWORD;
type TFreeImage_GetTagCount=function (tag: PFITAG): DWORD;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetTagCount');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetTagCount(Pproc)(tag);
end;

function FreeImage_SetTagDescription(tag: PFITAG; description: PAnsiChar): LongBool;
type TFreeImage_SetTagDescription=function (tag: PFITAG; description: PAnsiChar): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetTagDescription');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SetTagDescription(Pproc)(tag,description);
end;

function FreeImage_GetTagDescription(tag: PFITAG): PAnsiChar;
type TFreeImage_GetTagDescription=function (tag: PFITAG): PAnsiChar;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetTagDescription');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetTagDescription(Pproc)(tag);
end;

function FreeImage_GetTagID(tag: PFITAG): Word;
type TFreeImage_GetTagID=function (tag: PFITAG): Word;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetTagID');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetTagID(Pproc)(tag);
end;

function FreeImage_GetTagKey(tag: PFITAG): PAnsiChar;
type TFreeImage_GetTagKey=function (tag: PFITAG): PAnsiChar;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetTagKey');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetTagKey(Pproc)(tag);
end;

function FreeImage_GetTagType(tag: PFITAG): FREE_IMAGE_MDTYPE;
type TFreeImage_GetTagType=function (tag: PFITAG): FREE_IMAGE_MDTYPE;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetTagType');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetTagType(Pproc)(tag);
end;


function FreeImage_GetTagLength(tag: PFITAG): DWORD;
type TFreeImage_GetTagLength=function (tag: PFITAG): DWORD;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetTagLength');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetTagLength(Pproc)(tag);
end;

function FreeImage_GetTagValue(tag: PFITAG): Pointer;
type TFreeImage_GetTagValue=function (tag: PFITAG): Pointer;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetTagValue');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetTagValue(Pproc)(tag);
end;

function FreeImage_SetTagKey(tag: PFITAG; key: PAnsiChar): LongBool;
type TFreeImage_SetTagKey=function (tag: PFITAG; key: PAnsiChar): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetTagKey');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SetTagKey(Pproc)(tag,key);
end;

function FreeImage_SetTagID(tag: PFITAG; id: Word): LongBool;
type TFreeImage_SetTagID=function (tag: PFITAG; id: Word): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetTagID');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SetTagID(Pproc)(tag,id);
end;

function FreeImage_SetTagType(tag: PFITAG; _type: FREE_IMAGE_MDTYPE): LongBool;
type TFreeImage_SetTagType=function (tag: PFITAG; _type: FREE_IMAGE_MDTYPE): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetTagType');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SetTagType(Pproc)(tag,_type);
end;

function FreeImage_SetTagCount(tag: PFITAG; count: DWORD): LongBool;
type TFreeImage_SetTagCount=function (tag: PFITAG; count: DWORD): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetTagCount');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SetTagCount(Pproc)(tag,count);
end;

function FreeImage_SetTagLength(tag: PFITAG; length: DWORD): LongBool;
type TFreeImage_SetTagLength=function (tag: PFITAG; length: DWORD): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetTagLength');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SetTagLength(Pproc)(tag,length);
end;

function FreeImage_SetTagValue(tag: PFITAG; value: Pointer): LongBool;
type TFreeImage_SetTagValue=function (tag: PFITAG; value: Pointer): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetTagValue');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SetTagValue(Pproc)(tag,value);
end;

function FreeImage_FindFirstMetadata(model: FREE_IMAGE_MDMODEL; dib: PFIBITMAP;
  var tag: PFITAG): PFIMETADATA;
type TFreeImage_FindFirstMetadata=function (model: FREE_IMAGE_MDMODEL; dib: PFIBITMAP;
  var tag: PFITAG): PFIMETADATA;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_FindFirstMetadata');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_FindFirstMetadata(Pproc)(model,dib,tag);
end;


function FreeImage_FindNextMetadata(mdhandle: PFIMETADATA; var tag: PFITAG): LongBool;
type TFreeImage_FindNextMetadata=function (mdhandle: PFIMETADATA; var tag: PFITAG): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_FindNextMetadata');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_FindNextMetadata(Pproc)(mdhandle,tag);
end;


procedure FreeImage_FindCloseMetadata(mdhandle: PFIMETADATA);
type TFreeImage_FindCloseMetadata=procedure (mdhandle: PFIMETADATA);{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_FindCloseMetadata');
assert(Pproc<>nil,'library method not found');
TFreeImage_FindCloseMetadata(Pproc)(mdhandle);
end;

function FreeImage_SetMetadata(model: FREE_IMAGE_MDMODEL; dib: PFIBITMAP;
  key: PAnsiChar; tag: PFITAG): LongBool;
type TFreeImage_SetMetadata=function (model: FREE_IMAGE_MDMODEL; dib: PFIBITMAP;
  key: PAnsiChar; tag: PFITAG): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetMetadata');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SetMetadata(Pproc)(model,dib,key,tag);
end;


function FreeImage_GetMetadata(model: FREE_IMAGE_MDMODEL; dib: PFIBITMAP;
  key: PAnsiChar; var tag: PFITAG): LongBool;
type TFreeImage_GetMetadata=function (model: FREE_IMAGE_MDMODEL; dib: PFIBITMAP;
  key: PAnsiChar; var tag: PFITAG): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetMetadata');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetMetadata(Pproc)(model,dib,key,tag);
end;


function FreeImage_SetMetadataKeyValue(model: FREE_IMAGE_MDMODEL; dib: PFIBITMAP;
  key, value: PAnsiChar): LongBool;
type TFreeImage_SetMetadataKeyValue=function (model: FREE_IMAGE_MDMODEL; dib: PFIBITMAP;
  key, value: PAnsiChar): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetMetadataKeyValue');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SetMetadataKeyValue(Pproc)(model,dib,key,value);
end;

function FreeImage_GetMetadataCount(model: FREE_IMAGE_MDMODEL; dib: PFIBITMAP): Cardinal;
type TFreeImage_GetMetadataCount=function (model: FREE_IMAGE_MDMODEL; dib: PFIBITMAP): Cardinal;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetMetadataCount');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetMetadataCount(Pproc)(model,dib);
end;

function FreeImage_CloneMetadata(dst, src: PFIBITMAP): LongBool;
type TFreeImage_CloneMetadata=function (dst, src: PFIBITMAP): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_CloneMetadata');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_CloneMetadata(Pproc)(dst,src);
end;

function FreeImage_TagToString(model: FREE_IMAGE_MDMODEL; tag: PFITAG;
  Make: PAnsiChar = nil): PAnsiChar;
type TFreeImage_TagToString=function (model: FREE_IMAGE_MDMODEL; tag: PFITAG;
  Make: PAnsiChar = nil): PAnsiChar;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_TagToString');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_TagToString(Pproc)(model,tag,make);
end;

function FreeImage_Rotate(dib: PFIBITMAP; angle: Double; bkcolor: Pointer = nil): PFIBITMAP;
type TFreeImage_Rotate=function (dib: PFIBITMAP; angle: Double; bkcolor: Pointer = nil): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_Rotate');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_Rotate(Pproc)(dib,angle,bkcolor);
end;

function FreeImage_RotateEx(dib: PFIBITMAP; angle, x_shift, y_shift, x_origin, y_origin: Double;
  use_mask: LongBool): PFIBITMAP;
type TFreeImage_RotateEx=function (dib: PFIBITMAP; angle, x_shift, y_shift, x_origin, y_origin: Double;
  use_mask: LongBool): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_RotateEx');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_RotateEx(Pproc)(dib,angle, x_shift, y_shift, x_origin, y_origin,use_mask);
end;

function FreeImage_FlipHorizontal(dib: PFIBITMAP): LongBool;
type TFreeImage_FlipHorizontal=function (dib: PFIBITMAP): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_FlipHorizontal');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_FlipHorizontal(Pproc)(dib);
end;

function FreeImage_FlipVertical(dib: PFIBITMAP): LongBool;
type TFreeImage_FlipVertical=function (dib: PFIBITMAP): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_FlipVertical');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_FlipVertical(Pproc)(dib);
end;

function FreeImage_Rescale(dib: PFIBITMAP; dst_width, dst_height: Integer;
  filter: FREE_IMAGE_FILTER = FILTER_CATMULLROM): PFIBITMAP;
type TFreeImage_Rescale=function (dib: PFIBITMAP; dst_width, dst_height: Integer;
  filter: FREE_IMAGE_FILTER = FILTER_CATMULLROM): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_Rescale');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_Rescale(Pproc)(dib,dst_width, dst_height,filter);
end;

function FreeImage_MakeThumbnail(dib: PFIBITMAP; max_pixel_size: Integer;
         convert: LongBool = True): PFIBITMAP;
type TFreeImage_MakeThumbnail=function (dib: PFIBITMAP; max_pixel_size: Integer;
         convert: LongBool = True): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_MakeThumbnail');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_MakeThumbnail(Pproc)(dib,max_pixel_size,convert);
end;


function FreeImage_RescaleRect(dib: PFIBITMAP; dst_width, dst_height, left, top, right, bottom: Integer;
  filter: FREE_IMAGE_FILTER = FILTER_CATMULLROM; flags: Cardinal = 0): PFIBITMAP;
type TFreeImage_RescaleRect=function (dib: PFIBITMAP; dst_width, dst_height, left, top, right, bottom: Integer;
  filter: FREE_IMAGE_FILTER = FILTER_CATMULLROM; flags: Cardinal = 0): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_RescaleRect');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_RescaleRect(Pproc)(dib,dst_width, dst_height, left, top, right, bottom,filter,flags);
end;

function FreeImage_SetChannel(dst, src: PFIBITMAP; channel: FREE_IMAGE_COLOR_CHANNEL): LongBool;
type TFreeImage_SetChannel=function (dst, src: PFIBITMAP; channel: FREE_IMAGE_COLOR_CHANNEL): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_SetChannel');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_SetChannel(Pproc)(dst, src, channel);
end;

function FreeImage_GetChannel(dib: PFIBITMAP; channel: FREE_IMAGE_COLOR_CHANNEL): PFIBITMAP;
type TFreeImage_GetChannel=function (dib: PFIBITMAP; channel: FREE_IMAGE_COLOR_CHANNEL): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetChannel');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetChannel(Pproc)(dib,channel);
end;

function FreeImage_GetComplexChannel(src: PFIBITMAP; channel: FREE_IMAGE_COLOR_CHANNEL): PFIBITMAP;
type TFreeImage_GetComplexChannel=function (src: PFIBITMAP; channel: FREE_IMAGE_COLOR_CHANNEL): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetComplexChannel');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetComplexChannel(Pproc)(src,channel);
end;

function FreeImage_CreateView(dib: PFIBITMAP; left, top, right, bottom: Cardinal): PFIBITMAP;
type TFreeImage_CreateView=function (dib: PFIBITMAP; left, top, right, bottom: Cardinal): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_CreateView');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_CreateView(Pproc)(dib,left, top, right, bottom);
end;

function FreeImage_Copy(dib: PFIBITMAP; left, top, right, bottom: Integer): PFIBITMAP;
type TFreeImage_Copy=function (dib: PFIBITMAP; left, top, right, bottom: Integer): PFIBITMAP;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_Copy');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_Copy(Pproc)(dib,left, top, right, bottom);
end;

function FreeImage_Paste(dst, src: PFIBITMAP; left, top, alpha: Integer): LongBool;
type TFreeImage_Paste=function (dst, src: PFIBITMAP; left, top, alpha: Integer): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_Paste');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_Paste(Pproc)(dst, src,left, top, alpha);
end;

function FreeImage_AdjustCurve(dib: PFIBITMAP; LUT: PByte;
  channel: FREE_IMAGE_COLOR_CHANNEL): LongBool;
type TFreeImage_AdjustCurve=function (dib: PFIBITMAP; LUT: PByte;
  channel: FREE_IMAGE_COLOR_CHANNEL): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_AdjustCurve');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_AdjustCurve(Pproc)(dib,lut,channel);
end;

function FreeImage_AdjustGamma(dib: PFIBITMAP; gamma: Double): LongBool;
type TFreeImage_AdjustGamma=function (dib: PFIBITMAP; gamma: Double): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_AdjustGamma');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_AdjustGamma(Pproc)(dib,gamma);
end;

function FreeImage_AdjustBrightness(dib: PFIBITMAP; percentage: Double): LongBool;
type TFreeImage_AdjustBrightness=function (dib: PFIBITMAP; percentage: Double): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_AdjustBrightness');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_AdjustBrightness(Pproc)(dib,percentage);
end;

function FreeImage_AdjustContrast(dib: PFIBITMAP; percentage: Double): LongBool;
type TFreeImage_AdjustContrast=function (dib: PFIBITMAP; percentage: Double): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_AdjustContrast');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_AdjustContrast(Pproc)(dib,percentage);
end;

function FreeImage_GetHistogram(dib: PFIBITMAP; histo: PDWORD;
  channel: FREE_IMAGE_COLOR_CHANNEL = FICC_BLACK): LongBool;
type TFreeImage_GetHistogram=function (dib: PFIBITMAP; histo: PDWORD;
  channel: FREE_IMAGE_COLOR_CHANNEL = FICC_BLACK): LongBool;{$IFDEF MSWINDOWS}stdcall;{$ELSE}cdecl;{$ENDIF}
var Pproc:pointer=nil;
begin
assert(FreeimageHandleIsValid,'no lib loaded');
Pproc:=GetProcedureAddress(FreeimageHandle,'FreeImage_GetHistogram');
assert(Pproc<>nil,'library method not found');
result:=TFreeImage_GetHistogram(Pproc)(dib,histo,channel);
end;


//----------------------------------------------

begin


end.
{$ASSERTIONS OFF}
