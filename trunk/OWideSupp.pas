unit OWideSupp;

{

  Author:
    Ondrej Pokorny, http://www.kluug.net
    All Rights Reserved.

  License:
    MPL 1.1 / GPLv2 / LGPLv2 / FPC modified LGPLv2
    Please see the /license.txt file for more information.

}

{
  OWideSupp.pas

  A collection of types, classes and methods to support WideStrings across all
  compilers.

  OWideString type:
    Default string type that supports unicode characters
    - Delphi 2009+   String         (UTF-16)
    - Delphi 2007-   WideString     (UTF-16)
    - FPC            String         (UTF-8)

  ORealWideString type:
    Always a UTF-16 string type
    - Delphi 2009+   String         (UTF-16)
    - Delphi 2007-   WideString     (UTF-16)
    - FPC            UnicodeString  (UTF-16)

  OFastString type:
    The fastest possible character container for unicode characters
    !!! must be converted with OFastToWide/OWideToFast to OWideString !!!
    - should be used as internal string storage where high performance is needed
      (basically only for D6-D2007 - their WideString performance is bad)
    - Delphi 2009+   String         (UTF-16)
    - Delphi 2007-   String         (UTF-16 is stored inside!!!)
    - FPC            String         (UTF-8)

  TOWideStringList
    - For Delphi 7-2007: TStringList replacement with WideStrings

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
  System.SysUtils, System.Classes
  {$ELSE}
  SysUtils, Classes
  {$ENDIF}

  {$IF DEFINED(O_DELPHI_2006_UP) AND DEFINED(O_DELPHI_2007_DOWN)}
  , WideStrUtils
  {$IFEND}

  {$IFDEF O_DELPHI_XE3_UP}
  , Character
  {$ENDIF}

  {$IFDEF O_GENERICS}
    {$IFDEF O_NAMESPACES}
    , System.Generics.Collections
    {$ELSE}
    , Generics.Collections
    {$ENDIF}
  {$ENDIF}
  ;

type
  {$IFDEF FPC}
    OWideString = String;//UTF-8
    ORealWideString = UnicodeString;//UTF-16
    OWideChar = Char;
    POWideChar = PChar;
    ORawByteString = AnsiString;
    ONativeInt = NativeInt;
    ONativeUInt = NativeUInt;
  {$ELSE}
    {$IFDEF O_UNICODE}
      OWideString = String;//UTF-16
      ORealWideString = String;//UTF-16
      OWideChar = Char;
      POWideChar = PChar;
      {$IFDEF O_RAWBYTESTRING}
      ORawByteString = RawByteString;
      {$ENDIF}
      {$IFDEF O_DELPHI_2010_UP}
      ONativeInt = NativeInt;
      ONativeUInt = NativeUInt;
      {$ELSE}
      //D2009 bug
      ONativeInt = Integer;
      ONativeUInt = Cardinal;
      {$ENDIF}
    {$ELSE}
      OWideString = WideString;//UTF-16
      ORealWideString = WideString;//UTF-16
      OWideChar = WideChar;
      POWideChar = PWideChar;
      ORawByteString = AnsiString;
      ONativeInt = Integer;
      ONativeUInt = Cardinal;
    {$ENDIF}
  {$ENDIF}

  //OFastString is the fastest possible WideString replacement
  //Unicode Delphi: String
  //Non-unicode Delphi: WideString casted as AnsiString
  //Lazarus: UTF8
  {$IFDEF O_UNICODE}
  OFastString = String;
  {$ELSE}
  OFastString = String;//WideString data is stored inside -> with double char size!!!
  {$ENDIF}
  TOWideStringArray = array of OWideString;

  {$IFNDEF O_UNICODE}
  TOWideStringList = class;
  TOWideStringListSortCompare = function(List: TOWideStringList; Index1, Index2: Integer): Integer;
  TOWideStringList = class(TPersistent)
  protected
    fList: TStringList;
  private
    function GetI(Index: Integer): OWideString;
    function GetCount: Integer;
    function GetText: OWideString;
    function GetCapacity: Integer;
    function GetCommaText: OWideString;
    function GetDelimitedText: OWideString;
    function GetDelimiter: Char;
    function GetName(Index: Integer): OWideString;
    function GetObject(Index: Integer): TObject;
    function GetQuoteChar: Char;
    function GetValue(const Name: OWideString): OWideString;
    function GetCaseSensitive: Boolean;
    function GetDuplicates: TDuplicates;
    function GetOnChange: TNotifyEvent;
    function GetOnChanging: TNotifyEvent;
    function GetSorted: Boolean;
    procedure SetI(Index: Integer; const Value: OWideString);
    procedure SetText(const Value: OWideString);
    procedure SetObject(Index: Integer; const Value: TObject);
    procedure SetCapacity(const Value: Integer);
    procedure SetCommaText(const Value: OWideString);
    procedure SetDelimitedText(const Value: OWideString);
    procedure SetDelimiter(const Value: Char);
    procedure SetQuoteChar(const Value: Char);
    procedure SetValue(const Name, Value: OWideString);
    procedure SetCaseSensitive(const Value: Boolean);
    procedure SetDuplicates(const Value: TDuplicates);
    procedure SetOnChange(const Value: TNotifyEvent);
    procedure SetOnChanging(const Value: TNotifyEvent);
    procedure SetSorted(const Value: Boolean);
    {$IFDEF O_DELPHI_7_UP}
    function GetNameValueSeparator: Char;
    function GetValueFromIndex(Index: Integer): OWideString;
    procedure SetNameValueSeparator(const Value: Char);
    procedure SetValueFromIndex(Index: Integer; const Value: OWideString);
    {$ENDIF}
    {$IFDEF O_DELPHI_2006_UP}
    function GetLineBreak: OWideString;
    procedure SetLineBreak(const Value: OWideString);
    function GetStrictDelimiter: Boolean;
    procedure SetStrictDelimiter(const Value: Boolean);
    {$ENDIF}
  protected
    procedure Changed;
    procedure Changing;
    function CompareStrings(const S1, S2: OWideString): Integer;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function Add(const S: OWideString): Integer;
    function AddObject(const S: OWideString; AObject: TObject): Integer;
    procedure AddStrings(Strings: TStrings); overload;
    procedure AddStrings(Strings: TOWideStringList); overload;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure EndUpdate;
    function Equals(Strings: TOWideStringList): Boolean; reintroduce;
    procedure Exchange(Index1, Index2: Integer);
    function IndexOf(const S: OWideString): Integer;
    function IndexOfName(const Name: OWideString): Integer;
    function IndexOfObject(AObject: TObject): Integer;
    procedure Insert(Index: Integer; const S: OWideString);
    procedure InsertObject(Index: Integer; const S: OWideString;
      AObject: TObject);
    procedure LoadFromFile(const FileName: String);
    procedure LoadFromStream(Stream: TStream);
    procedure Move(CurIndex, NewIndex: Integer);
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);

    procedure Sort;
    procedure CustomSort(Compare: TOWideStringListSortCompare); virtual;
    procedure QuickSort(L, R: Integer; SCompare: TOWideStringListSortCompare);
  public
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount;
    property CommaText: OWideString read GetCommaText write SetCommaText;
    property Delimiter: Char read GetDelimiter write SetDelimiter;
    property DelimitedText: OWideString read GetDelimitedText write SetDelimitedText;
    property Names[Index: Integer]: OWideString read GetName;
    property Objects[Index: Integer]: TObject read GetObject write SetObject;
    property QuoteChar: Char read GetQuoteChar write SetQuoteChar;
    property Values[const Name: OWideString]: OWideString read GetValue write SetValue;
    property Strings[Index: Integer]: OWideString read GetI write SetI; default;
    property Text: OWideString read GetText write SetText;

    property Duplicates: TDuplicates read GetDuplicates write SetDuplicates;
    property Sorted: Boolean read GetSorted write SetSorted;
    property CaseSensitive: Boolean read GetCaseSensitive write SetCaseSensitive;
    property OnChange: TNotifyEvent read GetOnChange write SetOnChange;
    property OnChanging: TNotifyEvent read GetOnChanging write SetOnChanging;

    {$IFDEF O_DELPHI_7_UP}
    property NameValueSeparator: Char read GetNameValueSeparator write SetNameValueSeparator;
    property ValueFromIndex[Index: Integer]: OWideString read GetValueFromIndex write SetValueFromIndex;
    {$ENDIF}
    {$IFDEF O_DELPHI_2006_UP}
    property LineBreak: OWideString read GetLineBreak write SetLineBreak;
    property StrictDelimiter: Boolean read GetStrictDelimiter write SetStrictDelimiter;
    {$ENDIF}
  end;
  {$ELSE}
  TOWideStringList = TStringList;
  {$ENDIF}

  TOTextBuffer = class(TPersistent)
  private
    fBuffer: Array of OWideChar;//Faster in D7 than OWideString
    fAllocLength: Integer;//allocated length
    fUsedLength: Integer;//used length
    fRemaining: Integer;//fAllocLength-fUsedLength

    fDefBufferLength: Integer;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    procedure Clear(const aFullClear: Boolean = True);
    procedure GetBuffer(var outString: OWideString); overload;
    procedure GetBuffer(var outString: OWideString; const aPosition, aLength: Integer); overload;
    function GetBuffer: OWideString; overload;
    procedure RemoveLastChar;
    procedure RemoveLastString(const aLength: Integer);

    procedure WriteChar(const aChar: OWideChar);
    procedure WriteString(const aString: OWideString); overload;//outPosition 1-based!
    procedure WriteString(const aString: OWideString; var outPosition, outLength: Integer); overload;//outPosition 1-based!
    procedure Grow(const aMinChars: Integer);

    constructor Create(const aBufferLength: Integer = 1024);
  public
    property UsedLength: Integer read fUsedLength;
    property AllocLength: Integer read fAllocLength;
  end;

  TOWideStringStackItem = packed record
    Position: Integer;
    Length: Integer;
  end;
  POWideStringStackItem = ^TOWideStringStackItem;

  TOWideStringStackArray = Array of TOWideStringStackItem;
  POWideStringStackArray = ^TOWideStringStackArray;

  TOBufferWideStrings = class(TPersistent)
  private
    fBuffer: TOTextBuffer;

    {$IFDEF O_GENERICS}
    fItems: TList<POWideStringStackArray>;//Memory blocks of 1024 elements. Do not reallocate its memory!
    {$ELSE}
    fItems: TList;
    {$ENDIF}
    fItemsAllocCount: Integer;//allocated count
    fItemsUsedCount: Integer;//used count
  private
    function GetItem(const aIndex: Integer; var outItem: POWideStringStackItem): Boolean;
  protected
    procedure Grow;

    procedure DoCreate; virtual;

    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create;
    destructor Destroy; override;
  public
    function Add(const aString: OWideString): Integer;
    function Get(const aIndex: Integer): OWideString; overload; {$IFDEF O_INLINE}inline;{$ENDIF}
    procedure Get(const aIndex: Integer; var outString: OWideString); overload; {$IFDEF O_INLINE}inline;{$ENDIF}

    procedure DeleteLast;

    procedure Clear(const aFullClear: Boolean = True);
  public
    property Count: Integer read fItemsUsedCount;
  end;


function OStringReplace(const S, OldPattern, NewPattern: OWideString;
  Flags: TReplaceFlags): OWideString; {$IFDEF O_INLINE}inline;{$ENDIF}
function OLowerCase(const aStr: OWideString): OWideString; {$IFDEF O_INLINE}inline;{$ENDIF}
function OUpperCase(const aStr: OWideString): OWideString; {$IFDEF O_INLINE}inline;{$ENDIF}

{$IFNDEF NEXTGEN}
//CharInSet for all compilers
function OCharInSet(const aChar: OWideChar; const aSet: TSysCharSet): Boolean; {$IFDEF O_INLINE}inline;{$ENDIF}
{$ENDIF}
//really WideString enabled CharInSet -> but slower!
function OCharInSetW(const aChar: OWideChar; const aCharArray: Array of OWideChar): Boolean;//TRUE WIDE SUPPORT

{$IFDEF O_DELPHI_6_DOWN}
type
  TFormatSettings = record
    DecimalSeparator: AnsiChar;
    ThousandSeparator: AnsiChar;
    TimeSeparator: AnsiChar;
    ListSeparator: AnsiChar;
    ShortDateFormat: AnsiString;
    LongDateFormat: AnsiString;
    ShortTimeFormat: AnsiString;
    LongTimeFormat: AnsiString;
  end;
{$ENDIF}

//GetLocaleFormatSettings for all compilers
function OGetLocaleFormatSettings: TFormatSettings; {$IFDEF O_INLINE}inline;{$ENDIF}

{$IFNDEF NEXTGEN}
//wide string to owidestring and back
function WSToOWS(const aWS: WideString): OWideString; {$IFDEF O_INLINE}inline;{$ENDIF}
function OWSToWS(const aOWS: OWideString): WideString; {$IFDEF O_INLINE}inline;{$ENDIF}
//ansi string to owidestring and back
function ASToOWS(const aAS: AnsiString): OWideString; {$IFDEF O_INLINE}inline;{$ENDIF}
function OWSLength(const aOWS: OWideString): Integer; {$IFDEF O_INLINE}inline;{$ENDIF}
{$ENDIF}

//ofaststring to owidestring and back
{$IFNDEF O_UNICODE}
function OFastToWide(const aSourceFast: OFastString): OWideString; {$IFDEF O_INLINE}inline;{$ENDIF}
function OWideToFast(const aSourceWide: OWideString): OFastString; overload; {$IFDEF O_INLINE}inline;{$ENDIF}
procedure OWideToFast(const aSourceWide: OWideString; var outDestFast: OFastString); overload; {$IFDEF O_INLINE}inline;{$ENDIF}
{$ENDIF}

//split a text to pieces with a delimiter
//if aConsiderQuotes=True, delimiters in quotes are ignored
//quotes must be escaped in XML-style, i.e. escaping with backslash is not considered as escaped: \" will not work
procedure OExplode(const aText: OWideString; const aDelimiter: OWideChar;
  const aStrList: TOWideStringList; const aConsiderQuotes: Boolean = False);
procedure OExpandPath(const aReferencePath, aVarPath: TOWideStringList);
function OReplaceLineBreaks(const aString: OWideString; const aLineBreak: OWideString = sLineBreak): OWideString;

implementation

function OReplaceLineBreaks(const aString: OWideString; const aLineBreak: OWideString = sLineBreak): OWideString;
var
  IRes, IStr: Integer;
  xStrLen: Integer;
  xLineBreakByteSize: Integer;
  xExtraLineBreakInc: Integer;

  procedure _CopyLineBreak;
  begin
    if xLineBreakByteSize > 0 then
      Move(aLineBreak[1], Result[IRes], xLineBreakByteSize);
    if xExtraLineBreakInc <> 0 then
      Inc(IRes, xExtraLineBreakInc);
  end;
begin
  xStrLen := Length(aString);
  xLineBreakByteSize := Length(aLineBreak)*SizeOf(OWideChar);
  xExtraLineBreakInc := Length(aLineBreak)-1;

  SetLength(Result, xStrLen*2);//worst case #10 -> #13#10
  IRes := 1;
  IStr := 1;
  while IStr <= xStrLen do begin
    case aString[IStr] of
      #13: begin
        _CopyLineBreak;
        if (IStr < xStrLen) and (aString[IStr+1] = #10) then
          Inc(IStr);
      end;
      #10: _CopyLineBreak;
    else
      Result[IRes] := aString[IStr];
    end;

    Inc(IRes);
    Inc(IStr);
  end;
  SetLength(Result, IRes-1);
end;

procedure OExpandPath(const aReferencePath, aVarPath: TOWideStringList);
var
  xNewPath: TOWideStringList;
  I: Integer;
begin
  if (aVarPath.Count > 0) and (aVarPath[aVarPath.Count-1] = '') then//delete last empty element ("root/name/")
    aVarPath.Delete(aVarPath.Count-1);

  if (aVarPath.Count = 0) then begin//current directory
    aVarPath.Assign(aReferencePath);
    Exit;
  end;

  xNewPath := TOWideStringList.Create;
  try
    if (aVarPath[0] <> '') then//is relative path
      xNewPath.Assign(aReferencePath);

    for I := 0 to aVarPath.Count-1 do begin
      if aVarPath[I] = '..' then
      begin
        //go up
        if xNewPath.Count > 0 then
          xNewPath.Delete(xNewPath.Count-1);
      end
      else
      if (aVarPath[I] <> '.') and (aVarPath[I] <> '') then//not current directory
      begin
        xNewPath.Add(aVarPath[I]);
      end;
    end;

    aVarPath.Assign(xNewPath);
  finally
    xNewPath.Free;
  end;
end;

procedure OExplode(const aText: OWideString; const aDelimiter: OWideChar;
  const aStrList: TOWideStringList; const aConsiderQuotes: Boolean);
var
  xBuffer: OWideString;
  xI, xTextLength: Integer;
  xC: OWideChar;

  procedure _ClearBuffer;
  begin
    xBuffer := '';
  end;

  function _ReadChar: Boolean;
  begin
    Result := (xI <= xTextLength);
    if Result then begin
      xC := aText[xI];
      Inc(xI);
      xBuffer := xBuffer + xC;
    end;
  end;

  procedure _DeleteLastCharFromBuffer;
  begin
    if xBuffer <> '' then
      SetLength(xBuffer, Length(xBuffer)-1);
  end;

  procedure _AddBufferToStrList;
  begin
    aStrList.Add(xBuffer);
    _ClearBuffer;
  end;
begin
  aStrList.Clear;

  xTextLength := Length(aText);
  if xTextLength = 0 then
    Exit;

  xI := 1;
  while _ReadChar do begin
    if aConsiderQuotes then begin
      case xC of
        '"':begin
          while _ReadChar do
          if xC = '"' then
            Break;
        end;
        '''': begin
          while _ReadChar do
          if xC = '''' then
            Break;
        end;
      end;
    end;
    if xC = aDelimiter then begin
      _DeleteLastCharFromBuffer;
      _AddBufferToStrList;
    end;
  end;

  _AddBufferToStrList;//must be here
end;

function OLowerCase(const aStr: OWideString): OWideString;
begin
  {$IFDEF O_UNICODE}
  Result := LowerCase(aStr);
  {$ELSE}
  Result := WideLowerCase(aStr);
  {$ENDIF}
end;

function OUpperCase(const aStr: OWideString): OWideString;
begin
  {$IFDEF O_UNICODE}
  Result := UpperCase(aStr);
  {$ELSE}
  Result := WideUpperCase(aStr);
  {$ENDIF}
end;

{$IFNDEF O_UNICODE}
function OFastToWide(const aSourceFast: OFastString): OWideString;
var
  xL: Integer;
  xS: PWideChar;
  I: Integer;
begin
  xL := Length(aSourceFast) div SizeOf(OWideChar);
  SetLength(Result, xL);
  if xL > 0 then
  begin
    xS := @aSourceFast[1];
    for I := 1 to xL do
    begin
      Result[I] := xS^;
      Inc(xS);
    end;
  end;
end;

function OWideToFast(const aSourceWide: OWideString): OFastString;
begin
  OWideToFast(aSourceWide, Result);
end;

procedure OWideToFast(const aSourceWide: OWideString; var outDestFast: OFastString);
var
  xL: Integer;
  xR: PWideChar;
  I: Integer;
begin
  xL := Length(aSourceWide);
  SetLength(outDestFast, xL*SizeOf(OWideChar));
  if xL > 0 then
  begin
    xR := @outDestFast[1];
    for I := 1 to xL do
    begin
      xR^ := aSourceWide[I];
      Inc(xR);
    end;
  end;
end;
{$ENDIF}

{$IFNDEF NEXTGEN}
function OCharInSet(const aChar: OWideChar; const aSet: TSysCharSet): Boolean;
begin
  Result := (Ord(aChar) <= 255) and ({$IFDEF NEXTGEN}Char{$ELSE}AnsiChar{$ENDIF}(aChar) in aSet);
end;
{$ENDIF}

function OCharInSetW(const aChar: OWideChar; const aCharArray: Array of OWideChar): Boolean;
var I: Integer;
begin
  for I := Low(aCharArray) to High(aCharArray) do
  if aChar = aCharArray[I] then begin
    Result := True;
    Exit;
  end;

  Result := False;
end;

function OWSLength(const aOWS: OWideString): Integer; {$IFDEF O_INLINE}inline;{$ENDIF}
begin
  {$IFDEF FPC}
  Result := Length(OWSToWS(aOWS));
  {$ELSE}
  Result := Length(aOWS);
  {$ENDIF}
end;

{$IFNDEF NEXTGEN}
function ASToOWS(const aAS: AnsiString): OWideString; {$IFDEF O_INLINE}inline;{$ENDIF}
begin
  {$IFDEF FPC}
  Result := AnsiToUtf8(aAS);
  {$ELSE}
  Result := OWideString(aAS);
  {$ENDIF}
end;
function WSToOWS(const aWS: WideString): OWideString; {$IFDEF O_INLINE}inline;{$ENDIF}
begin
  {$IFDEF FPC}
  Result := UTF8Encode(aWS);
  {$ELSE}
  Result := aWS;
  {$ENDIF}
end;

function OWSToWS(const aOWS: OWideString): WideString; {$IFDEF O_INLINE}inline;{$ENDIF}
begin
  {$IFDEF FPC}
  Result := UTF8Decode(aOWS);
  {$ELSE}
  Result := aOWS;
  {$ENDIF}
end;
{$ENDIF}

function OGetLocaleFormatSettings: TFormatSettings;
begin
{$IF DEFINED(FPC)}
  Result := DefaultFormatSettings;
{$ELSEIF DEFINED(O_DELPHI_XE_UP)}
  Result := TFormatSettings.Create;
{$ELSEIF DEFINED(O_DELPHI_6_DOWN)}
  Result.DecimalSeparator := DecimalSeparator;
  Result.ThousandSeparator := #0;
  Result.TimeSeparator := TimeSeparator;
  Result.ListSeparator := ListSeparator;
  Result.ShortDateFormat := ShortDateFormat;
  Result.LongDateFormat := LongDateFormat;
  Result.ShortTimeFormat := ShortTimeFormat;
  Result.LongTimeFormat := LongTimeFormat;
{$ELSE}
  GetLocaleFormatSettings(0, Result);
{$IFEND}
end;

{$IF NOT DEFINED(O_DELPHI_2006_UP)}
//Delphi 6, 7
function WideStringReplace(const S, OldPattern, NewPattern: WideString;
  Flags: TReplaceFlags): WideString; {$IFDEF O_INLINE}inline;{$ENDIF}
var
  SearchStr, OldPatt: WideString;
  I, L, K, OldPattLength, NewPattLength, SLength: Integer;
begin
  if (OldPattern = '') or (S = '') then
    Exit;
    
  if rfIgnoreCase in Flags then
  begin
    SearchStr := WideUpperCase(S);
    OldPatt := WideUpperCase(OldPattern);
  end
  else
  begin
    SearchStr := S;
    OldPatt := OldPattern;
  end;
  OldPattLength := Length(OldPatt);
  NewPattLength := Length(NewPattern);
  SLength := Length(S);
  
  if NewPattLength <= OldPattLength then
    SetLength(Result, SLength)
  else
    SetLength(Result, (SLength*NewPattLength) div OldPattLength + OldPattLength);//maximum length + some extra buffer just in case...

  I := 1;//position in S
  L := 1;//position in Result
  while I <= SLength-OldPattLength+1 do
  begin
    if CompareMem(@SearchStr[I], @OldPatt[1], OldPattLength*SizeOf(WideChar)) then
    begin
      //pattern found
      for K := 1 to NewPattLength do
      begin
        Result[L] := NewPattern[K];
        Inc(L);
      end;
      Inc(I, OldPattLength);
      if not(rfReplaceAll in Flags) then
        break;
    end
    else
    begin
      //pattern not found
      Result[L] := S[I];
      Inc(I);
      Inc(L);
    end;
  end;

  //write trail
  while I <= SLength do
  begin
    Result[L] := S[I];
    Inc(I);
    Inc(L);
  end;

  if Length(Result) <> L-1 then
    SetLength(Result, L-1);
end;
{$IFEND}

function OStringReplace(const S, OldPattern, NewPattern: OWideString;
  Flags: TReplaceFlags): OWideString;
begin
{$IF DEFINED(O_UNICODE)}
  //D2009+, FPC
  Result := StringReplace(S, OldPattern, NewPattern, Flags);
{$ELSE}
  //D6-D2007
  Result := WideStringReplace(S, OldPattern, NewPattern, Flags);
{$IFEND}
end;

{$IFNDEF O_UNICODE}
{ TOWideStringList }

function TOWideStringList.Add(const S: OWideString): Integer;
begin
  Result := fList.Add(UTF8Decode(S));
end;

function TOWideStringList.AddObject(const S: OWideString; AObject: TObject): Integer;
begin
  Result := fList.AddObject(UTF8Decode(S), AObject);
end;

procedure TOWideStringList.AddStrings(Strings: TOWideStringList);
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := 0 to Strings.Count - 1 do
      fList.AddObject(Strings.fList[I], Strings.fList.Objects[I]);
  finally
    EndUpdate;
  end;
end;

procedure TOWideStringList.Assign(Source: TPersistent);
begin
  if Source is TStrings then
    fList.Assign(Source)
  else if Source is TOWideStringList then
    fList.Assign(TOWideStringList(Source).fList);
end;

procedure TOWideStringList.BeginUpdate;
begin
  fList.BeginUpdate;
end;

procedure TOWideStringList.AddStrings(Strings: TStrings);
begin
  fList.AddStrings(Strings);
end;

type
  TMyStringList = class(TStringList);

procedure TOWideStringList.Changed;
begin
  TMyStringList(fList).Changed;
end;

procedure TOWideStringList.Changing;
begin
  TMyStringList(fList).Changing;
end;

procedure TOWideStringList.Clear;
begin
  fList.Clear;
end;

function TOWideStringList.CompareStrings(const S1, S2: OWideString): Integer;
begin
  Result := WideCompareText(S1, S2);
end;

constructor TOWideStringList.Create;
begin
  inherited Create;

  fList := TStringList.Create;
end;

procedure TOWideStringList.CustomSort(Compare: TOWideStringListSortCompare);
begin
  if not Sorted and (Count > 1) then
  begin
    BeginUpdate;
    try
      QuickSort(0, Count - 1, Compare);
    finally
      EndUpdate;
    end;
  end;
end;

procedure TOWideStringList.Delete(Index: Integer);
begin
  fList.Delete(Index);
end;

destructor TOWideStringList.Destroy;
begin
  fList.Destroy;

  inherited;
end;

procedure TOWideStringList.EndUpdate;
begin
  fList.EndUpdate;
end;

function TOWideStringList.Equals(Strings: TOWideStringList): Boolean;
begin
  Result := fList.Equals(Strings.fList);
end;

procedure TOWideStringList.Exchange(Index1, Index2: Integer);
begin
  fList.Exchange(Index1, Index2);
end;

function TOWideStringList.GetCapacity: Integer;
begin
  Result := fList.Capacity;
end;

function TOWideStringList.GetCaseSensitive: Boolean;
begin
  Result := fList.CaseSensitive;
end;

function TOWideStringList.GetCommaText: OWideString;
begin
  Result := UTF8Decode(fList.CommaText);
end;

function TOWideStringList.GetCount: Integer;
begin
  Result := fList.Count;
end;

function TOWideStringList.GetDelimitedText: OWideString;
begin
  Result := UTF8Decode(fList.DelimitedText);
end;

function TOWideStringList.GetDelimiter: Char;
begin
  Result := fList.Delimiter;
end;

function TOWideStringList.GetDuplicates: TDuplicates;
begin
  Result := fList.Duplicates;
end;

function TOWideStringList.GetI(Index: Integer): OWideString;
begin
  Result := UTF8Decode(fList[Index]);
end;

function TOWideStringList.GetName(Index: Integer): OWideString;
begin
  Result := UTF8Decode(fList.Names[Index]);
end;

function TOWideStringList.GetObject(Index: Integer): TObject;
begin
  Result := fList.Objects[Index];
end;

function TOWideStringList.GetOnChange: TNotifyEvent;
begin
  Result := fList.OnChange;
end;

function TOWideStringList.GetOnChanging: TNotifyEvent;
begin
  Result := fList.OnChanging;
end;

function TOWideStringList.GetQuoteChar: Char;
begin
  Result := fList.QuoteChar;
end;

function TOWideStringList.GetSorted: Boolean;
begin
  Result := fList.Sorted;
end;

function TOWideStringList.GetText: OWideString;
begin
  Result := UTF8Decode(fList.Text);
end;

function TOWideStringList.GetValue(const Name: OWideString): OWideString;
begin
  Result := UTF8Decode(fList.Values[UTF8Encode(Name)]);
end;

function TOWideStringList.IndexOf(const S: OWideString): Integer;
begin
  Result := fList.IndexOf(UTF8Encode(S));
end;

function TOWideStringList.IndexOfName(const Name: OWideString): Integer;
begin
  Result := fList.IndexOfName(UTF8Encode(Name));
end;

function TOWideStringList.IndexOfObject(AObject: TObject): Integer;
begin
  Result := fList.IndexOfObject(AObject);
end;

procedure TOWideStringList.Insert(Index: Integer; const S: OWideString);
begin
  fList.Insert(Index, UTF8Encode(S));
end;

procedure TOWideStringList.InsertObject(Index: Integer; const S: OWideString;
  AObject: TObject);
begin
  fList.InsertObject(Index, UTF8Encode(S), AObject);
end;

procedure TOWideStringList.LoadFromFile(const FileName: string);
begin
  fList.LoadFromFile(FileName);
end;

procedure TOWideStringList.LoadFromStream(Stream: TStream);
begin
  fList.LoadFromStream(Stream);
end;

procedure TOWideStringList.Move(CurIndex, NewIndex: Integer);
begin
  fList.Move(CurIndex, NewIndex);
end;

procedure TOWideStringList.QuickSort(L, R: Integer;
  SCompare: TOWideStringListSortCompare);
var
  I, J, P: Integer;
begin
  BeginUpdate;
  try
    repeat
      I := L;
      J := R;
      P := (L + R) shr 1;
      repeat
        while SCompare(Self, I, P) < 0 do Inc(I);
        while SCompare(Self, J, P) > 0 do Dec(J);
        if I <= J then
        begin
          if I <> J then
            Exchange(I, J);
          if P = I then
            P := J
          else if P = J then
            P := I;
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then QuickSort(L, J, SCompare);
      L := I;
    until I >= R;
  finally
    EndUpdate;
  end;
end;

procedure TOWideStringList.SaveToFile(const FileName: string);
begin
  fList.SaveToFile(FileName);
end;

procedure TOWideStringList.SaveToStream(Stream: TStream);
begin
  fList.SaveToStream(Stream);
end;

procedure TOWideStringList.SetCapacity(const Value: Integer);
begin
  fList.Capacity := Value;
end;

procedure TOWideStringList.SetCaseSensitive(const Value: Boolean);
begin
  fList.CaseSensitive := Value;
end;

procedure TOWideStringList.SetCommaText(const Value: OWideString);
begin
  fList.CommaText := UTF8Encode(Value);
end;

procedure TOWideStringList.SetDelimitedText(const Value: OWideString);
begin
  fList.DelimitedText := UTF8Encode(Value);
end;

procedure TOWideStringList.SetDelimiter(const Value: Char);
begin
  fList.Delimiter := Value;
end;

procedure TOWideStringList.SetDuplicates(const Value: TDuplicates);
begin
  fList.Duplicates := Value;
end;

procedure TOWideStringList.SetI(Index: Integer; const Value: OWideString);
begin
  fList[Index] := UTF8Encode(Value);
end;

procedure TOWideStringList.SetObject(Index: Integer; const Value: TObject);
begin
  fList.Objects[Index] := Value;
end;

procedure TOWideStringList.SetOnChange(const Value: TNotifyEvent);
begin
  fList.OnChange := Value;
end;

procedure TOWideStringList.SetOnChanging(const Value: TNotifyEvent);
begin
  fList.OnChanging := Value;
end;

procedure TOWideStringList.SetQuoteChar(const Value: Char);
begin
  fList.QuoteChar := Value;
end;

procedure TOWideStringList.SetSorted(const Value: Boolean);
begin
  fList.Sorted := Value;
end;

procedure TOWideStringList.SetText(const Value: OWideString);
begin
  fList.Text := UTF8Encode(Value);
end;

procedure TOWideStringList.SetValue(const Name, Value: OWideString);
begin
  fList.Values[UTF8Encode(Name)] := UTF8Encode(Value);
end;

function OWideStringListCompareStrings(List: TOWideStringList; Index1, Index2: Integer): Integer;
begin
  Result := List.CompareStrings(List[Index1],
                                List[Index2]);
end;

procedure TOWideStringList.Sort;
begin
  CustomSort(OWideStringListCompareStrings);
end;

{$IFDEF O_DELPHI_7_UP}
function TOWideStringList.GetNameValueSeparator: Char;
begin
  Result := fList.NameValueSeparator;
end;

procedure TOWideStringList.SetNameValueSeparator(const Value: Char);
begin
  fList.NameValueSeparator := Value;
end;

function TOWideStringList.GetValueFromIndex(Index: Integer): OWideString;
begin
  Result := UTF8Decode(fList.ValueFromIndex[Index]);
end;

procedure TOWideStringList.SetValueFromIndex(Index: Integer;
  const Value: OWideString);
begin
  fList.ValueFromIndex[Index] := UTF8Encode(Value);
end;

{$ENDIF}

{$IFDEF O_DELPHI_2006_UP}
function TOWideStringList.GetLineBreak: OWideString;
begin
  Result := UTF8Decode(fList.LineBreak);
end;

function TOWideStringList.GetStrictDelimiter: Boolean;
begin
  Result := fList.StrictDelimiter;
end;

procedure TOWideStringList.SetLineBreak(const Value: OWideString);
begin
  fList.LineBreak := UTF8Encode(Value);
end;

procedure TOWideStringList.SetStrictDelimiter(const Value: Boolean);
begin
  fList.StrictDelimiter := Value;
end;

{$ENDIF}

{$ENDIF O_UNICODE}//TOWideStringList

{ TOBufferWideStrings }

function TOBufferWideStrings.Add(const aString: OWideString): Integer;
var
  xNewItem: POWideStringStackItem;
begin
  Result := fItemsUsedCount;

  if fItemsUsedCount = fItemsAllocCount then
    Grow;

  Inc(fItemsUsedCount);
  GetItem(fItemsUsedCount-1, {%H-}xNewItem);
  fBuffer.WriteString(aString, xNewItem.Position, xNewItem.Length);
end;

procedure TOBufferWideStrings.AssignTo(Dest: TPersistent);
var
  xDestStrL: TStrings;
  xDestWStrL: TOWideStringList;
  xDestBWS: TOBufferWideStrings;
  I: Integer;
begin
  if Dest is TOWideStringList then begin
    xDestWStrL := TOWideStringList(Dest);
    xDestWStrL.Clear;
    for I := 0 to Count-1 do
      xDestWStrL.Add(Get(I));
  end else
  if Dest is TStrings then begin
    xDestStrL := TStrings(Dest);
    xDestStrL.Clear;
    for I := 0 to Count-1 do
      xDestStrL.Add(Get(I));
  end else
  if Dest is TOBufferWideStrings then begin
    xDestBWS := TOBufferWideStrings(Dest);
    xDestBWS.Clear;
    for I := 0 to Count-1 do
      xDestBWS.Add(Get(I));
  end else
    inherited;
end;

procedure TOBufferWideStrings.Clear(const aFullClear: Boolean);
begin
  fItemsUsedCount := 0;
  fBuffer.Clear(aFullClear);
end;

constructor TOBufferWideStrings.Create;
begin
  inherited Create;

  DoCreate;
end;

procedure TOBufferWideStrings.DeleteLast;
var
  xItem: POWideStringStackItem;
begin
  if fItemsUsedCount = 0 then
    Exit;

  GetItem(fItemsUsedCount-1, {%H-}xItem);
  Dec(fItemsUsedCount);

  fBuffer.RemoveLastString(xItem.Length);
end;

destructor TOBufferWideStrings.Destroy;
var
  I: Integer;
begin
  for I := 0 to fItems.Count-1 do
    Dispose(POWideStringStackArray(fItems[I]));

  fBuffer.Free;
  fItems.Free;

  inherited;
end;

procedure TOBufferWideStrings.DoCreate;
begin
  {$IFDEF O_GENERICS}
  fItems := TList<POWideStringStackArray>.Create;
  {$ELSE}
  fItems := TList.Create;
  {$ENDIF}

  fBuffer := TOTextBuffer.Create(1024);
end;

function TOBufferWideStrings.Get(const aIndex: Integer): OWideString;
begin
  Get(aIndex, {%H-}Result);
end;

procedure TOBufferWideStrings.Get(const aIndex: Integer;
  var outString: OWideString);
var
  xItem: POWideStringStackItem;
begin
  if GetItem(aIndex, {%H-}xItem) then
    fBuffer.GetBuffer({%H-}outString, xItem.Position, xItem.Length)
  else
    outString := '';
end;

function TOBufferWideStrings.GetItem(const aIndex: Integer; var outItem: POWideStringStackItem): Boolean;
begin
  Result := (aIndex >= 0) and (aIndex < fItemsUsedCount);
  if Result then
    outItem := @(POWideStringStackArray(fItems[aIndex shr 10])^)[aIndex and 1023]//= [aNode div 1024][aNode mod 1024]
  else
    outItem := nil;
end;

procedure TOBufferWideStrings.Grow;
var
  xNewArray: POWideStringStackArray;
begin
  fItemsAllocCount := fItemsAllocCount+1024;

  New(xNewArray);
  SetLength(xNewArray^, 1024);
  fItems.Add(xNewArray);
end;

{ TOTextBuffer }

procedure TOTextBuffer.AssignTo(Dest: TPersistent);
var
  xDest: TOTextBuffer;
begin
  if Dest is TOTextBuffer then begin
    xDest := TOTextBuffer(Dest);

    if xDest.fAllocLength < Self.fAllocLength then begin
      xDest.fAllocLength := Self.fAllocLength;
      SetLength(xDest.fBuffer, xDest.fAllocLength);
    end;

    xDest.fUsedLength := Self.fUsedLength;
    xDest.fRemaining := Self.fRemaining;

    xDest.fBuffer := Copy(Self.fBuffer, 0, Self.fUsedLength);
  end else
    inherited;
end;

procedure TOTextBuffer.Clear(const aFullClear: Boolean);
begin
  if aFullClear and (fAllocLength > fDefBufferLength) then begin
    fAllocLength := fDefBufferLength;
    SetLength(fBuffer, fAllocLength);
  end;

  fUsedLength := 0;
  fRemaining := fAllocLength;
end;

constructor TOTextBuffer.Create(const aBufferLength: Integer);
begin
  inherited Create;

  fDefBufferLength := aBufferLength;
  fAllocLength := aBufferLength;
  fRemaining := fAllocLength;
  fUsedLength := 0;
  SetLength(fBuffer, fAllocLength);
end;

procedure TOTextBuffer.GetBuffer(var outString: OWideString);
begin
  GetBuffer(outString, 1, fUsedLength);
end;

procedure TOTextBuffer.GetBuffer(var outString: OWideString; const aPosition,
  aLength: Integer);
{$IFDEF O_DELPHI_2007_DOWN}
var
  I: Integer;
{$ENDIF}
begin
  SetLength(outString, aLength);
  if aLength > 0 then
  begin
    {$IFDEF O_DELPHI_2007_DOWN}
    //Move() is extremly slow here in Delphi 7, copy char-by-char is faster for short strings
    if aLength < 5 then begin
      for I := 0 to aLength-1 do
        outString[I+1] := fBuffer[aPosition+I-1];
    end else begin
      Move(fBuffer[aPosition-1], outString[1], aLength*SizeOf(OWideChar));
    end;
    {$ELSE}
    Move(fBuffer[aPosition-1], outString[1], aLength*SizeOf(OWideChar));
    {$ENDIF}
  end;
end;

function TOTextBuffer.GetBuffer: OWideString;
begin
  GetBuffer({%H-}Result);
end;

procedure TOTextBuffer.Grow(const aMinChars: Integer);
var
  xGrowSize: Integer;
begin
  xGrowSize := 0;
  while fRemaining+xGrowSize < aMinChars do
    Inc(xGrowSize, fAllocLength+xGrowSize);

  Inc(fRemaining, xGrowSize);
  Inc(fAllocLength, xGrowSize);
  SetLength(fBuffer, fAllocLength);
end;

procedure TOTextBuffer.RemoveLastChar;
begin
  Dec(fUsedLength);
  Inc(fRemaining);
  if fUsedLength < 0 then begin
    fUsedLength := 0;
    fRemaining := fAllocLength;
  end;
end;

procedure TOTextBuffer.RemoveLastString(const aLength: Integer);
begin
  Dec(fUsedLength, aLength);
  Inc(fRemaining, aLength);
  if fUsedLength < 0 then begin
    fUsedLength := 0;
    fRemaining := fAllocLength;
  end;
end;

procedure TOTextBuffer.WriteChar(const aChar: OWideChar);
begin
  if fRemaining = 0 then
    Grow(1);

  Inc(fUsedLength);
  Dec(fRemaining);
  fBuffer[fUsedLength-1] := aChar;
end;

procedure TOTextBuffer.WriteString(const aString: OWideString);
var
  xPos, xLen: Integer;
begin
  WriteString(aString, {%H-}xPos, {%H-}xLen);
end;

procedure TOTextBuffer.WriteString(const aString: OWideString; var outPosition,
  outLength: Integer);
begin
  outLength := Length(aString);
  outPosition := fUsedLength+1;

  if outLength > 0 then begin
    if fRemaining < outLength then
      Grow(outLength);

    Inc(fUsedLength, outLength);
    Dec(fRemaining, outLength);

    Move(aString[1], fBuffer[outPosition-1], outLength*SizeOf(OWideChar));
  end;
end;

end.

