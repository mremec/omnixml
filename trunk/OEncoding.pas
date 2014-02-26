unit OEncoding;

{

  Author:
    Ondrej Pokorny, http://www.kluug.net
    All Rights Reserved.

  License:
    MPL 1.1 / GPLv2 / LGPLv2 / FPC modified LGPLv2
    Please see the /license.txt file for more information.

}

{
  OEncoding.pas

  Convert buffers to strings and back with encoding classes.

}

{$I OXml.inc}

{$IFDEF O_DELPHI_XE4_UP}
  {$ZEROBASEDSTRINGS OFF}
{$ENDIF}

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

{$BOOLEVAL OFF}

interface

uses
  {$IFDEF O_NAMESPACES}
  System.SysUtils,
  {$ELSE}
  SysUtils,
  {$ENDIF}

  OWideSupp;

const
  //see http://msdn.microsoft.com/en-us/library/windows/desktop/dd317756%28v=vs.85%29.aspx

  //single-byte
  CP_WIN_1250 = 1250;//ANSI Central European; Central European (Windows)
  CP_WIN_1251 = 1251;//ANSI Cyrillic; Cyrillic (Windows)
  CP_WIN_1252 = 1252;//ANSI Latin 1; Western European (Windows)
  CP_WIN_1253 = 1253;//ANSI Greek; Greek (Windows)
  CP_WIN_1254 = 1254;//ANSI Turkish; Turkish (Windows)
  CP_WIN_1255 = 1255;//ANSI Hebrew; Hebrew (Windows)
  CP_WIN_1256 = 1256;//ANSI Arabic; Arabic (Windows)
  CP_WIN_1257 = 1257;//ANSI Baltic; Baltic (Windows)
  CP_WIN_1258 = 1258;//ANSI/OEM Vietnamese; Vietnamese (Windows)
  CP_ISO_8859_1 = 28591;//ISO 8859-1 Latin 1; Western European (ISO)
  CP_ISO_8859_2 = 28592;//ISO 8859-2 Central European; Central European (ISO)
  CP_ISO_8859_3 = 28593;//ISO 8859-3 Latin 3
  CP_ISO_8859_4 = 28594;//ISO 8859-4 Baltic
  CP_ISO_8859_5 = 28595;//ISO 8859-5 Cyrillic
  CP_ISO_8859_6 = 28596;//ISO 8859-6 Arabic
  CP_ISO_8859_7 = 28597;//ISO 8859-7 Greek
  CP_ISO_8859_8 = 28598;//ISO 8859-8 Hebrew; Hebrew (ISO-Visual)
  CP_ISO_8859_9 = 28599;//ISO 8859-9 Turkish
  CP_ISO_8859_13 = 28603;//ISO 8859-13 Estonian
  CP_ISO_8859_15 = 28605;//ISO 8859-15 Latin 9
  CP_ISO_2022 = 50220;//ISO 2022 Japanese with no halfwidth Katakana; Japanese (JIS)
  CP_EUC_JP = 51932;//ISO 2022 Japanese with no halfwidth Katakana; Japanese (JIS)
  CP_KOI8_R = 20866;//Russian (KOI8-R); Cyrillic (KOI8-R)
  CP_KOI8_U = 21866;//Ukrainian (KOI8-U); Cyrillic (KOI8-U)
  CP_IBM_437 = 437;//OEM United States
  CP_IBM_850 = 850;//OEM Multilingual Latin 1; Western European (DOS)
  CP_IBM_852 = 852;//OEM Latin 2; Central European (DOS)
  CP_IBM_866 = 866;//OEM Russian; Cyrillic (DOS)
  CP_WIN_874 = 874;//ANSI/OEM Thai (ISO 8859-11); Thai (Windows)
  CP_IBM_932 = 932;//ANSI/OEM Japanese; Japanese (Shift-JIS)
  CP_US_ASCII = 20127;//US-ASCII (7-bit)

  //multi-byte
  CP_UNICODE = 1200;//Unicode UTF-16, little endian byte order
  CP_UNICODE_BE = 1201;//Unicode UTF-16, big endian byte order
  CP_UTF7 = 65000;//Unicode (UTF-7)
  CP_UTF8 = 65001;//Unicode (UTF-8)

{$IFDEF O_DELPHI_2009_UP}
type
  TEncodingBuffer = TBytes;
const
  TEncodingBuffer_FirstElement = 0;
{$ELSE}
type
  TEncodingBuffer = AnsiString;
const
  TEncodingBuffer_FirstElement = 1;

type

  TEncoding = class(TObject)
  public
    //functions that convert strings to buffers and vice versa
    function BufferToString(const aBytes: TEncodingBuffer): OWideString; overload;
    procedure BufferToString(const aBytes: TEncodingBuffer; var outString: OWideString); overload; virtual; abstract;//faster in D7 and FPC than "function BufferToString"
    function StringToBuffer(const S: OWideString): TEncodingBuffer; overload;
    procedure StringToBuffer(const S: OWideString; var outBuffer: TEncodingBuffer); overload; virtual; abstract;//faster in D7 and FPC than "function StringToBuffer"

  public
    //functions that get information about current encoding object
    class function IsSingleByte: Boolean; virtual; abstract;
    class function IsStandardEncoding(aEncoding: TEncoding): Boolean;

    function EncodingName: OWideString; virtual; abstract;
    function EncodingAlias: OWideString;
    function EncodingCodePage: Cardinal;

  public
    //class functions for finding correct encoding from BOM, code page, alias etc.
    class function GetEncodingFromBOM(const aBuffer: TEncodingBuffer; var outEncoding: TEncoding): Integer; overload;
    class function GetEncodingFromBOM(const aBuffer: TEncodingBuffer; var outEncoding: TEncoding;
      aDefaultEncoding: TEncoding): Integer; overload;
    function GetBOM: TEncodingBuffer; virtual; abstract;

    class function EncodingFromCodePage(aCodePage: Integer): TEncoding;
    class function EncodingFromAlias(const aAlias: OWideString; var outEncoding: TEncoding): Boolean;
    class function AliasToCodePage(const aAlias: OWideString): Cardinal;
    class function CodePageToAlias(const aCodePage: Cardinal): OWideString;
  public
    //retrieve standard encodings
    class function Default: TEncoding;
    class function Unicode: TEncoding;
    class function UTF8: TEncoding;
    class function ANSI: TEncoding;
    class function ASCII: TEncoding;
    class function OWideStringEncoding: TEncoding;
  public
    destructor Destroy; override;
  end;

  TUnicodeEncoding = class(TEncoding)
  public
    function GetBOM: TEncodingBuffer; override;
    procedure BufferToString(const aBytes: TEncodingBuffer; var outString: OWideString); override;
    procedure StringToBuffer(const S: OWideString; var outBuffer: TEncodingBuffer); override;
    class function IsSingleByte: Boolean; override;
    function EncodingName: OWideString; override;
  end;

  TUTF8Encoding = class(TEncoding)
  public
    function GetBOM: TEncodingBuffer; override;
    procedure BufferToString(const aBytes: TEncodingBuffer; var outString: OWideString); override;
    procedure StringToBuffer(const S: OWideString; var outBuffer: TEncodingBuffer); override;
    class function IsSingleByte: Boolean; override;
    function EncodingName: OWideString; override;
  end;

  TMBCSEncoding = class(TEncoding)
  private
    fCodePage: Cardinal;
  public
    constructor Create(aCodePage: Cardinal);
  public
    function GetBOM: TEncodingBuffer; override;
    procedure BufferToString(const aBytes: TEncodingBuffer; var outString: OWideString); override;
    procedure StringToBuffer(const S: OWideString; var outBuffer: TEncodingBuffer); override;
    class function IsSingleByte: Boolean; override;
    function EncodingName: OWideString; override;
  public
    property CodePage: Cardinal read fCodePage;
  end;
{$ENDIF O_DELPHI_2009_UP}

{$IF (DEFINED(O_DELPHI_2009_UP))}
//Delphi 2009 to 2010
type
  TEncodingHelper = class helper for TEncoding
  public
    function EncodingAlias: String;
    function EncodingCodePage: Cardinal;
    {$IF NOT DEFINED(O_DELPHI_XE_UP)}
    function EncodingName: String;
    {$IFEND}
    {$IF NOT DEFINED(O_DELPHI_XE2_UP)}
    class function ANSI: TEncoding;
    {$IFEND}
    class function OWideStringEncoding: TEncoding;

    class function EncodingFromCodePage(aCodePage: Integer): TEncoding;
    class function EncodingFromAlias(const aAlias: OWideString; var outEncoding: TEncoding): Boolean;
    class function AliasToCodePage(const aAlias: OWideString): Cardinal;
    class function CodePageToAlias(const aCodePage: Cardinal): OWideString;
    class function GetEncodingFromBOM(const aBuffer: TEncodingBuffer; var outEncoding: TEncoding): Integer; overload;
    class function GetEncodingFromBOM(const aBuffer: TEncodingBuffer; var outEncoding: TEncoding;
      aDefaultEncoding: TEncoding): Integer; overload;
    function GetBOM: TEncodingBuffer;
  end;
  TMBCSEncodingHelper = class helper for TMBCSEncoding
  public
    function GetCodePage: Cardinal;
  end;
{$IFEND}

implementation

{$IFNDEF O_DELPHI_2009_UP}

{$IF DEFINED(MSWINDOWS)}
uses Windows;
{$ELSEIF DEFINED(FPC)}
uses LConvEncoding;
{$IFEND}

{$ENDIF NOT O_DELPHI_2009_UP}

type
  TCodePage = record
    CodePage: Word;
    CPAlias: OWideString;
  end;
  TCodePages = array[0..34] of TCodePage;

const
  CodePages: TCodePages = (
    (CodePage: CP_WIN_1250; CPAlias: 'windows-1250'),
    (CodePage: CP_WIN_1251; CPAlias: 'windows-1251'),
    (CodePage: CP_WIN_1252; CPAlias: 'windows-1252'),
    (CodePage: CP_WIN_1253; CPAlias: 'windows-1253'),
    (CodePage: CP_WIN_1254; CPAlias: 'windows-1254'),
    (CodePage: CP_WIN_1255; CPAlias: 'windows-1255'),
    (CodePage: CP_WIN_1256; CPAlias: 'windows-1256'),
    (CodePage: CP_WIN_1257; CPAlias: 'windows-1257'),
    (CodePage: CP_WIN_1258; CPAlias: 'windows-1258'),
    (CodePage: CP_ISO_8859_1; CPAlias: 'iso-8859-1'),
    (CodePage: CP_ISO_8859_2; CPAlias: 'iso-8859-2'),
    (CodePage: CP_ISO_8859_3; CPAlias: 'iso-8859-3'),
    (CodePage: CP_ISO_8859_4; CPAlias: 'iso-8859-4'),
    (CodePage: CP_ISO_8859_5; CPAlias: 'iso-8859-5'),
    (CodePage: CP_ISO_8859_6; CPAlias: 'iso-8859-6'),
    (CodePage: CP_ISO_8859_7; CPAlias: 'iso-8859-7'),
    (CodePage: CP_ISO_8859_8; CPAlias: 'iso-8859-8'),
    (CodePage: CP_ISO_8859_9; CPAlias: 'iso-8859-9'),
    (CodePage: CP_ISO_8859_13; CPAlias: 'iso-8859-13'),
    (CodePage: CP_ISO_8859_15; CPAlias: 'iso-8859-15'),
    (CodePage: CP_ISO_2022; CPAlias: 'iso-2022-jp'),
    (CodePage: CP_EUC_JP; CPAlias: 'euc-jp'),
    (CodePage: CP_KOI8_R; CPAlias: 'koi8-r'),
    (CodePage: CP_KOI8_U; CPAlias: 'koi8-u'),
    (CodePage: CP_IBM_437; CPAlias: 'ibm437'),
    (CodePage: CP_IBM_850; CPAlias: 'ibm850'),
    (CodePage: CP_IBM_852; CPAlias: 'ibm852'),
    (CodePage: CP_IBM_866; CPAlias: 'cp866'),
    (CodePage: CP_WIN_874; CPAlias: 'windows-874'),
    (CodePage: CP_IBM_932; CPAlias: 'shift-jis'),
    (CodePage: CP_US_ASCII; CPAlias: 'us-ascii'),
    (CodePage: CP_UNICODE; CPAlias: 'utf-16'),
    (CodePage: CP_UNICODE_BE; CPAlias: 'utf-16be'),
    (CodePage: CP_UTF7; CPAlias: 'utf-7'),
    (CodePage: CP_UTF8; CPAlias: 'utf-8')
  );

{$IFNDEF O_DELPHI_2009_UP}

var
  fxANSIEncoding: TEncoding = nil;
  fxUTF8Encoding: TEncoding = nil;
  fxUnicodeEncoding: TEncoding = nil;
  fxASCIIEncoding: TEncoding = nil;

{$IF DEFINED(MSWINDOWS) AND NOT DEFINED(O_DELPHI_2009_UP)}
type
  _cpinfoExW = record
    MaxCharSize: UINT;                       { max length (bytes) of a char }
    DefaultChar: array[0..MAX_DEFAULTCHAR - 1] of Byte; { default character }
    LeadByte: array[0..MAX_LEADBYTES - 1] of Byte;      { lead byte ranges }
    UnicodeDefaultChar: WideChar;
    Codepage: UINT;
    CodePageName: array[0..MAX_PATH -1] of WideChar;
  end;
  TCPInfoExW = _cpinfoExW;

  function GetCPInfoExW(CodePage: UINT; dwFlags: DWORD; var lpCPInfoEx: TCPInfoExW): BOOL; stdcall; external kernel32 name 'GetCPInfoExW';
{$IFEND}

{$IF DEFINED(FPC) AND NOT DEFINED(MSWINDOWS)}
function UTF8ToCodePage(const S: OWideString; aCodePage: Cardinal): AnsiString;
begin
  case aCodePage of
    CP_IBM_437, CP_US_ASCII: Result := UTF8ToCP437(S);
    CP_IBM_850: Result := UTF8ToCP850(S);
    CP_IBM_852: Result := UTF8ToCP852(S);
    CP_IBM_866: Result := UTF8ToCP866(S);
    CP_WIN_874: Result := UTF8ToCP874(S);
    CP_IBM_932: Result := UTF8ToCP932(S);
    CP_WIN_1250: Result := UTF8ToCP1250(S);
    CP_WIN_1251: Result := UTF8ToCP1251(S);
    CP_WIN_1252: Result := UTF8ToCP1252(S);
    CP_WIN_1253: Result := UTF8ToCP1253(S);
    CP_WIN_1254: Result := UTF8ToCP1254(S);
    CP_WIN_1255: Result := UTF8ToCP1255(S);
    CP_WIN_1256: Result := UTF8ToCP1256(S);
    CP_WIN_1257: Result := UTF8ToCP1257(S);
    CP_WIN_1258: Result := UTF8ToCP1258(S);
    CP_ISO_8859_1: Result := UTF8ToISO_8859_1(S);
    CP_ISO_8859_2: Result := UTF8ToISO_8859_2(S);
    CP_KOI8_R, CP_KOI8_U: Result := UTF8ToKOI8(S);
  else
    Result := S;//Encoding not supported by lazarus
  end;
end;
function CodePageToUTF8(const S: AnsiString; aCodePage: Cardinal): OWideString;
begin
  case aCodePage of
    CP_IBM_437, CP_US_ASCII: Result := CP437ToUTF8(S);
    CP_IBM_850: Result := CP850ToUTF8(S);
    CP_IBM_852: Result := CP852ToUTF8(S);
    CP_IBM_866: Result := CP866ToUTF8(S);
    CP_WIN_874: Result := CP874ToUTF8(S);
    CP_IBM_932: Result := CP932ToUTF8(S);
    CP_WIN_1250: Result := CP1250ToUTF8(S);
    CP_WIN_1251: Result := CP1251ToUTF8(S);
    CP_WIN_1252: Result := CP1252ToUTF8(S);
    CP_WIN_1253: Result := CP1253ToUTF8(S);
    CP_WIN_1254: Result := CP1254ToUTF8(S);
    CP_WIN_1255: Result := CP1255ToUTF8(S);
    CP_WIN_1256: Result := CP1256ToUTF8(S);
    CP_WIN_1257: Result := CP1257ToUTF8(S);
    CP_WIN_1258: Result := CP1258ToUTF8(S);
    CP_ISO_8859_1: Result := ISO_8859_1ToUTF8(S);
    CP_ISO_8859_2: Result := ISO_8859_2ToUTF8(S);
    CP_KOI8_R, CP_KOI8_U: Result := KOI8ToUTF8(S);
  else
    Result := S;//Encoding not supported by lazarus
  end;
end;
{$IFEND}

{ TEncoding }

class function TEncoding.ANSI: TEncoding;
begin
  if not Assigned(fxANSIEncoding) then begin
    {$IFDEF MSWINDOWS}
    fxANSIEncoding := TMBCSEncoding.Create(GetACP);
    {$ELSE}
    fxANSIEncoding := TMBCSEncoding.Create(CP_WIN_1252);
    {$ENDIF}
  end;
  Result := fxANSIEncoding;
end;

class function TEncoding.ASCII: TEncoding;
{$IFDEF MSWINDOWS}
var
  xCPInfo: TCPInfo;
{$ENDIF}
begin
  if not Assigned(fxASCIIEncoding) then begin
    {$IFDEF MSWINDOWS}
    if GetCPInfo(CP_US_ASCII, {%H-}xCPInfo) then
      fxASCIIEncoding := TMBCSEncoding.Create(CP_US_ASCII)
    else
      fxASCIIEncoding := TMBCSEncoding.Create(CP_IBM_437);
    {$ELSE}
    fxASCIIEncoding := TMBCSEncoding.Create(CP_IBM_437);
    {$ENDIF}
  end;
  Result := fxASCIIEncoding;
end;

class function TEncoding.Default: TEncoding;
begin
  {$IFDEF MSWINDOWS}
  Result := ANSI;
  {$ELSE}
  Result := UTF8;
  {$ENDIF}
end;

class function TEncoding.GetEncodingFromBOM(const aBuffer: TEncodingBuffer;
  var outEncoding: TEncoding): Integer;
begin
  Result := GetEncodingFromBOM(aBuffer, outEncoding, Default);
end;

class function TEncoding.GetEncodingFromBOM(const aBuffer: TEncodingBuffer;
  var outEncoding: TEncoding; aDefaultEncoding: TEncoding): Integer;
begin
  if (Length(aBuffer) >= 3) and
     (aBuffer[TEncodingBuffer_FirstElement+0] = #$EF) and
     (aBuffer[TEncodingBuffer_FirstElement+1] = #$BB) and
     (aBuffer[TEncodingBuffer_FirstElement+2] = #$BF)
  then begin
    outEncoding := UTF8;
    Result := 3;
  end else
  if (Length(aBuffer) >= 2) and
     (aBuffer[TEncodingBuffer_FirstElement+0] = #$FF) and
     (aBuffer[TEncodingBuffer_FirstElement+1] = #$FE)
  then begin
    outEncoding := Unicode;
    Result := 2;
  end else begin
    outEncoding := aDefaultEncoding;
    Result := 0;
  end;
end;

function TEncoding.BufferToString(const aBytes: TEncodingBuffer): OWideString;
begin
  BufferToString(aBytes, {%H-}Result);
end;

function TEncoding.StringToBuffer(const S: OWideString): TEncodingBuffer;
begin
  StringToBuffer(S, {%H-}Result);
end;

class function TEncoding.Unicode: TEncoding;
begin
  if not Assigned(fxUnicodeEncoding) then
    fxUnicodeEncoding := TUnicodeEncoding.Create;
  Result := fxUnicodeEncoding;
end;

class function TEncoding.UTF8: TEncoding;
begin
  if not Assigned(fxUTF8Encoding) then
    fxUTF8Encoding := TUTF8Encoding.Create;
  Result := fxUTF8Encoding;
end;

class function TEncoding.IsStandardEncoding(aEncoding: TEncoding): Boolean;
begin
  Result :=
    Assigned(aEncoding) and (
      (aEncoding = fxANSIEncoding) or
      (aEncoding = fxUTF8Encoding) or
      (aEncoding = fxUnicodeEncoding) or
      (aEncoding = fxASCIIEncoding));
end;

class function TEncoding.OWideStringEncoding: TEncoding;
begin
  {$IFDEF FPC}
  Result := UTF8;
  {$ELSE}
  Result := Unicode;
  {$ENDIF}
end;

function TEncoding.EncodingAlias: OWideString;
var
  xCodePage, I: Integer;
begin
  xCodePage := EncodingCodePage;

  for I := Low(CodePages) to High(CodePages) do
  if CodePages[I].CodePage = xCodePage then begin
    Result := CodePages[I].CPAlias;
    Exit;
  end;

  Result := IntToStr(xCodePage);
end;

function TEncoding.EncodingCodePage: Cardinal;
begin
  if Self is TMBCSEncoding then
    Result := TMBCSEncoding(Self).CodePage
  else if Self is TUnicodeEncoding then
    Result := CP_UNICODE
  else if Self is TUTF8Encoding then
    Result := CP_UTF8
  else
    Result := 0;
end;

destructor TEncoding.Destroy;
begin
  if (Self = fxANSIEncoding) then
    fxANSIEncoding := nil
  else if (Self = fxUTF8Encoding) then
    fxUTF8Encoding := nil
  else if (Self = fxUnicodeEncoding) then
    fxUnicodeEncoding := nil
  else if (Self = fxASCIIEncoding) then
    fxASCIIEncoding := nil;

  inherited;
end;

{ TMBCSEncoding }

constructor TMBCSEncoding.Create(aCodePage: Cardinal);
begin
  inherited Create;

  fCodePage := aCodePage;
end;

function TMBCSEncoding.EncodingName: OWideString;
{$IFDEF MSWINDOWS}
var
  xCPInfo: TCPInfoExW;
begin
  if GetCPInfoExW(fCodePage, 0, xCPInfo{%H-}) then
    Result := xCPInfo.CodePageName
  else
    Result := IntToStr(fCodePage);
end;
{$ELSE}
begin
  Result := IntToStr(fCodePage);
end;
{$ENDIF}

procedure TMBCSEncoding.StringToBuffer(const S: OWideString; var outBuffer: TEncodingBuffer);
{$IFDEF MSWINDOWS}
var
  xLength: integer;
  {$IFDEF FPC}
  xUS: UnicodeString;
  {$ENDIF}
{$ENDIF}
begin
  if S = '' then begin
    outBuffer := '';
    Exit;
  end;

  {$IFDEF MSWINDOWS}
    {$IFDEF FPC}
    xUS := UTF8Decode(S);
    xLength := WideCharToMultiByte(fCodePage,
      WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
      PWideChar(@xUS[1]), -1, nil, 0, nil, nil);

    SetLength(outBuffer, xLength-1);
    if xLength > 1 then
      WideCharToMultiByte(codePage,
        WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
        PWideChar(@xUS[1]), -1, @outBuffer[1], xLength-1, nil, nil);
    {$ELSE}
    xLength := WideCharToMultiByte(fCodePage,
      WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
      PWideChar(@S[1]), -1, nil, 0, nil, nil);

    SetLength(outBuffer, xLength-1);
    if xLength > 1 then
      WideCharToMultiByte(codePage,
        WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
        PWideChar(@S[1]), -1, @outBuffer[1], xLength-1, nil, nil);
    {$ENDIF}
  {$ELSE}
  outBuffer := UTF8ToCodePage(S, fCodePage);
  {$ENDIF}
end;

function TMBCSEncoding.GetBOM: TEncodingBuffer;
begin
  Result := '';
end;

procedure TMBCSEncoding.BufferToString(const aBytes: TEncodingBuffer; var outString: OWideString);
{$IFDEF MSWINDOWS}
var
  xLength: integer;
  {$IFDEF FPC}
  xUS: UnicodeString;
  {$ENDIF}
{$ENDIF}
begin
  if aBytes = '' then begin
    outString := '';
    Exit;
  end;

  {$IFDEF MSWINDOWS}
    {$IFDEF FPC}
    xLength := MultiByteToWideChar(fCodePage, MB_PRECOMPOSED, PAnsiChar(@aBytes[1]), -1, nil, 0);
    SetLength(xUS, xLength-1);
    if xLength > 1 then
      MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PAnsiChar(@aBytes[1]), -1, PWideChar(@xUS[1]), xLength-1);
    outString := UTF8Encode(xUS);
    {$ELSE}
    xLength := MultiByteToWideChar(fCodePage, MB_PRECOMPOSED, PAnsiChar(@aBytes[1]), -1, nil, 0);
    SetLength(outString, xLength-1);
    if xLength > 1 then
      MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PAnsiChar(@aBytes[1]), -1, PWideChar(@outString[1]), xLength-1);
    {$ENDIF}
  {$ELSE}
  outString := CodePageToUTF8(aBytes, fCodePage);
  {$ENDIF}
end;

class function TMBCSEncoding.IsSingleByte: Boolean;
begin
  Result := True;
end;

{ TUnicodeEncoding }

function TUnicodeEncoding.EncodingName: OWideString;
begin
{$IFDEF MSWINDOWS}
  Result := '1200  (Unicode)';
{$ELSE}
  Result := 'Unicode (UTF-16LE)';
{$ENDIF}
end;

procedure TUnicodeEncoding.StringToBuffer(const S: OWideString; var outBuffer: TEncodingBuffer);
var
  xCharCount: Integer;
  {$IFDEF FPC}
  xUS: UnicodeString;
  {$ENDIF}
begin
  {$IFDEF FPC}
  //FPC
  xUS := UTF8Decode(S);
  xCharCount := Length(xUS);
  SetLength(outBuffer, xCharCount*2);
  if xCharCount > 0 then begin
    Move(xUS[1], outBuffer[1], xCharCount*2);
  end;
  {$ELSE}
  //DELPHI
  xCharCount := Length(S);
  SetLength(outBuffer, xCharCount*2);
  if xCharCount > 0 then begin
    Move(S[1], outBuffer[1], xCharCount*2);
  end;
  {$ENDIF}
end;

function TUnicodeEncoding.GetBOM: TEncodingBuffer;
begin
  SetLength(Result, 2);
  Result[TEncodingBuffer_FirstElement+0] := #$FF;
  Result[TEncodingBuffer_FirstElement+1] := #$FE;
end;

procedure TUnicodeEncoding.BufferToString(const aBytes: TEncodingBuffer; var outString: OWideString);
var
  xByteCount: Integer;
  {$IFDEF FPC}
  xUS: UnicodeString;
  {$ENDIF}
begin
  xByteCount := Length(aBytes);
  if xByteCount = 0 then begin
    outString := '';
    Exit;
  end;
  {$IFDEF FPC}
  //FPC
  SetLength(xUS, xByteCount div 2);
  Move(aBytes[1], xUS[1], xByteCount);
  outString := UTF8Encode(xUS);
  {$ELSE}
  //DELPHI
  SetLength(outString, xByteCount div 2);
  Move(aBytes[1], outString[1], xByteCount);
  {$ENDIF}
end;

class function TUnicodeEncoding.IsSingleByte: Boolean;
begin
  Result := False;
end;

{ TUTF8Encoding }

function TUTF8Encoding.EncodingName: OWideString;
{$IFDEF MSWINDOWS}
var
  xCPInfo: TCPInfoExW;
begin
  if GetCPInfoExW(CP_UTF8, 0, xCPInfo{%H-}) then
    Result := xCPInfo.CodePageName
  else
    Result := '65001  (UTF-8)';
end;
{$ELSE}
begin
  Result := 'UTF-8';
end;
{$ENDIF}

procedure TUTF8Encoding.StringToBuffer(const S: OWideString; var outBuffer: TEncodingBuffer);
begin
  {$IFDEF FPC}
  outBuffer := S;
  {$ELSE}
  //DELPHI
  outBuffer := UTF8Encode(S);
  {$ENDIF}
end;

function TUTF8Encoding.GetBOM: TEncodingBuffer;
begin
  SetLength(Result, 3);
  Result[TEncodingBuffer_FirstElement+0] := #$EF;
  Result[TEncodingBuffer_FirstElement+1] := #$BB;
  Result[TEncodingBuffer_FirstElement+2] := #$BF;
end;

procedure TUTF8Encoding.BufferToString(const aBytes: TEncodingBuffer; var outString: OWideString);
begin
  {$IFDEF FPC}
  outString := aBytes;
  {$ELSE}
  //DELPHI
  outString := UTF8Decode(aBytes);
  {$ENDIF}
end;

class function TUTF8Encoding.IsSingleByte: Boolean;
begin
  Result := False;
end;
{$ENDIF O_DELPHI_2009}

{$IF (DEFINED(O_DELPHI_2009_UP))}
class function TEncodingHelper.EncodingFromCodePage(aCodePage: Integer): TEncoding;
{$ELSE}
class function TEncoding.EncodingFromCodePage(aCodePage: Integer): TEncoding;
{$IFEND}
begin
  case aCodePage of
    CP_UNICODE: Result := Unicode;
    {$IFDEF O_DELPHI_2009_UP}
    CP_UNICODE_BE: Result := BigEndianUnicode;
    CP_UTF7: Result := UTF7;
    {$ENDIF}
    CP_UTF8: Result := UTF8;
  else
    Result := TMBCSEncoding.Create(aCodePage);
  end;
end;

{$IF (DEFINED(O_DELPHI_2009_UP))}
class function TEncodingHelper.EncodingFromAlias(const aAlias: OWideString; var outEncoding: TEncoding): Boolean;
{$ELSE}
class function TEncoding.EncodingFromAlias(const aAlias: OWideString; var outEncoding: TEncoding): Boolean;
{$IFEND}
var
  xCP: Cardinal;
begin
  xCP := AliasToCodePage(aAlias);
  Result := (xCP <> 0);
  if Result then
    outEncoding := TEncoding.EncodingFromCodePage(xCP)
  else
    outEncoding := nil;
end;

{$IF (DEFINED(O_DELPHI_2009_UP))}
class function TEncodingHelper.AliasToCodePage(const aAlias: OWideString): Cardinal;
{$ELSE}
class function TEncoding.AliasToCodePage(const aAlias: OWideString): Cardinal;
{$IFEND}
var
  I: Integer;
begin
  for I := Low(CodePages) to High(CodePages) do
  if SameText(aAlias, CodePages[I].CPAlias) then begin
    Result := CodePages[I].CodePage;
    Exit;
  end;
  Result := 0;
end;

{$IF (DEFINED(O_DELPHI_2009_UP))}
class function TEncodingHelper.CodePageToAlias(const aCodePage: Cardinal): OWideString;
{$ELSE}
class function TEncoding.CodePageToAlias(const aCodePage: Cardinal): OWideString;
{$IFEND}
var
  I: Integer;
begin
  for I := Low(CodePages) to High(CodePages) do
  if aCodePage = CodePages[I].CodePage then begin
    Result := CodePages[I].CPAlias;
    Exit;
  end;
  Result := '';
end;

{$IF NOT DEFINED(FPC) AND (DEFINED(O_DELPHI_2009_UP))}
{ TEncodingHelper }

{$IF NOT DEFINED(O_DELPHI_XE_UP)}
function TEncodingHelper.EncodingName: String;
begin
  if Self is TMBCSEncoding then
    Result := IntToStr(TMBCSEncoding(Self).GetCodePage)
  else if Self is TUnicodeEncoding then
    Result := IntToStr(CP_UNICODE)
  else if Self is TBigEndianUnicodeEncoding then
    Result := IntToStr(CP_UNICODE_BE)
  else
    Result := '';
end;
{$IFEND}

{$IF NOT DEFINED(O_DELPHI_XE2_UP)}
class function TEncodingHelper.ANSI: TEncoding;
begin
  {$IFDEF MSWINDOWS}
  Result := Default;
  {$ELSE}
  Result := TMBCSEncoding.Create(CP_WIN_1252);
  {$ENDIF}
end;

{$IFEND}
class function TEncodingHelper.OWideStringEncoding: TEncoding;
begin
  {$IFDEF FPC}
  Result := UTF8;
  {$ELSE}
  Result := Unicode;
  {$ENDIF}
end;

function TEncodingHelper.EncodingAlias: String;
var
  xCodePage, I: Integer;
begin
  xCodePage := EncodingCodePage;

  for I := Low(CodePages) to High(CodePages) do
  if CodePages[I].CodePage = xCodePage then begin
    Result := CodePages[I].CPAlias;
    Exit;
  end;

  Result := IntToStr(xCodePage);
end;

class function TEncodingHelper.GetEncodingFromBOM(const aBuffer: TEncodingBuffer; var outEncoding: TEncoding): Integer;
begin
  outEncoding := nil;//must be here: otherwise if outEncoding<>nil, GetBufferEncoding would check only towards outEncoding
  Result := Self.GetBufferEncoding(aBuffer, outEncoding);
end;

class function TEncodingHelper.GetEncodingFromBOM(const aBuffer: TEncodingBuffer; var outEncoding: TEncoding;
  aDefaultEncoding: TEncoding): Integer;
begin
  outEncoding := nil;//must be here: otherwise if outEncoding<>nil, GetBufferEncoding would check only towards outEncoding
  {$IFDEF O_DELPHI_XE_UP}
  Result := Self.GetBufferEncoding(aBuffer, outEncoding, aDefaultEncoding);
  {$ELSE}
  Result := Self.GetBufferEncoding(aBuffer, outEncoding);
  if Result = 0 then//BOM not found
    outEncoding := aDefaultEncoding;
  {$ENDIF}
end;

function TEncodingHelper.GetBOM: TEncodingBuffer;
begin
  Result := GetPreamble;
end;

function TEncodingHelper.EncodingCodePage: Cardinal;
begin
  if Self is TMBCSEncoding then
    Result := TMBCSEncoding(Self).GetCodePage
  else if Self is TUnicodeEncoding then
    Result := CP_UNICODE
  else if Self is TBigEndianUnicodeEncoding then
    Result := CP_UNICODE_BE
  else
    Result := 0;
end;

{ TMBCSEncodingHelper }

function TMBCSEncodingHelper.GetCodePage: Cardinal;
begin
  Result := Self.FCodePage;
end;
{$IFEND}

{$IFNDEF O_DELPHI_2009_UP}
initialization

finalization
  fxANSIEncoding.Free;
  fxUTF8Encoding.Free;
  fxUnicodeEncoding.Free;
  fxASCIIEncoding.Free;


{$ENDIF O_DELPHI_2009_UP}

end.
