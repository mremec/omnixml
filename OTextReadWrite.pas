unit OTextReadWrite;

{

  Author:
    Ondrej Pokorny, http://www.kluug.net
    All Rights Reserved.

  License:
    MPL 1.1 / GPLv2 / LGPLv2 / FPC modified LGPLv2

}

{
  OTextReadWrite.pas

  TOTextReader -> read text from streams with buffer.
    - very fast thanks to internal string and stream buffer
    - read from streams with every supported encoding
    - when reading char-by-char an internal buffer can be used for
      saving last read keyword etc.


  TOTextWriter -> write text to a destination stream with buffer.
    - very fast thanks to internal string buffer
    - write to streams with every supported encoding
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
  SysUtils, Classes, OBufferedStreams, OEncoding, OWideSupp;

type

  TOTextReaderCustomBuffer = record
    Buffer: OWideString;
    Position: Integer;
    Length: Integer;
  end;
  POTextReaderCustomBuffer = ^TOTextReaderCustomBuffer;

  TOTextReader = class(TObject)
  private
    fTempString: OWideString;
    fTempStringPosition: Integer;
    fTempStringLength: Integer;
    fBufferSize: Integer;

    fStream: TStream;
    fStreamSize: ONativeInt;
    fStreamPosition: ONativeInt;
    fStreamStartPosition: ONativeInt;
    fOwnsStream: Boolean;

    fEncoding: TEncoding;
    fOwnsEncoding: Boolean;

    //undo support
    fPreviousChar: OWideChar;
    fReadFromUndo: Boolean;

    //custom buffer support
    fCustomBuffer: Array[0..1] of TOTextReaderCustomBuffer;

    procedure SetEncoding(const Value: TEncoding);

    function GetPreviousChar: OWideChar;
    function GetApproxStreamPosition: ONativeInt;

    procedure DoCreate(aStream: TStream;
      var aBOMFound: Boolean;
      const aDefaultSingleByteEncoding: TEncoding;
      const aBufferSize: Integer); virtual;
  public
    //create reader with original stream
    //aDefaultSingleByteEncoding - if no BOM is found, use this encoding,
    //  if BOM is found, always correct encoding from the BOM is used
    constructor Create(aStream: TStream;
      const aDefaultSingleByteEncoding: TEncoding = nil;
      const aBufferSize: Integer = 10*1024 {10 KB}); overload;
    constructor Create(aStream: TStream;
      var aBOMFound: Boolean;
      const aDefaultSingleByteEncoding: TEncoding = nil;
      const aBufferSize: Integer = 10*1024 {10 KB}); overload;
    destructor Destroy; override;
  public
    //read char-by-char, returns false if EOF is reached
    function ReadNextChar(var outChar: OWideChar): Boolean;
    //read text
    function ReadString(const aMaxChars: Integer): OWideString;
    //get text from temp buffer that has been already read
    //  -> it's not assured that some text can be read, use only as extra information
    //     e.g. for errors etc.
    function ReadPreviousString(const aMaxChars: Integer): OWideString;
    //go back 1 char. only 1 undo operation is supported
    procedure UndoRead;

    //fast internal buffer support
    //can be used for saving last read keyword etc.
    //you may use up to 2 buffers
      //write last read char to custom buffer
    procedure WritePreviousCharToBuffer(const aBufferIndex: Byte = 0);
      //write a char to custom buffer
    procedure WriteCharToBuffer(const aChar: OWideChar; const aBufferIndex: Byte = 0);
      //write a string to custom buffer
    procedure WriteStringToBuffer(const aStr: OWideString; const aBufferIndex: Byte = 0);
      //retrieve custom buffer
    function GetCustomBuffer(const aBufferIndex: Byte = 0): OWideString;
      //retrieve custom buffer length
    function CustomBufferLength(const aBufferIndex: Byte = 0): Integer;
      //clear custom buffer
    procedure ClearCustomBuffer(const aBufferIndex: Byte = 0);
      //remove last character from custom buffer
    procedure RemovePreviousCharFromBuffer(const aBufferIndex: Byte = 0);

    //if your original stream does not allow seeking and you want to change encoding at some point
    //  (e.g. the encoding is read from the text itself) you have to block the temporary buffer
    procedure BlockFlushTempBuffer;
    procedure UnblockFlushTempBuffer;
  public
    //encoding of the text that is read from the stream
    //  when changing encoding, the stream is always reset to the starting position
    //  and the stream has to be read again
    property Encoding: TEncoding read fEncoding write SetEncoding;
    property OwnsEncoding: Boolean read fOwnsEncoding write fOwnsEncoding;

    //Approximate position in original stream
    //  exact position cannot be determined because of variable UTF-8 character lengths
    property ApproxStreamPosition: ONativeInt read GetApproxStreamPosition;
    //size of original stream
    property StreamSize: ONativeInt read fStreamSize;
  end;

  TOTextWriter = class(TObject)
  private
    fTempString: OWideString;
    fTempStringPosition: Integer;
    fTempStringLength: Integer;

    fStream: TStream;

    fEncoding: TEncoding;
    fOwnsEncoding: Boolean;

    fWriteBOM: Boolean;
    fBOMWritten: Boolean;

    procedure WriteStringToStream(const aString: OWideString; const aMaxLength: Integer);
    procedure SetEncoding(const Value: TEncoding);
  protected
    procedure DoCreate(aStream: TStream; aEncoding: TEncoding; aWriteBOM: Boolean;
      aBufferSize: Integer);
  public
    constructor Create(aStream: TStream; aBufferSize: Integer = 10*1024 {10*1024 Chars = 20 KB}); overload;
    constructor Create(aStream: TStream; aEncoding: TEncoding; aWriteBOM: Boolean = True;
      aBufferSize: Integer = 10*1024 {10*1024 Chars = 20 KB}); overload;
    destructor Destroy; override;
  public
    //write string
    procedure WriteString(const aString: OWideString);
    //write the whole temporary buffer to the destination stream
    procedure EnsureTempStringWritten;
  public
    //encoding of the resulting stream
    //the encoding will be used only for new text, old text (that has already
    //been written with WriteString()) is written with last used encoding
    property Encoding: TEncoding read fEncoding write SetEncoding;
    property OwnsEncoding: Boolean read fOwnsEncoding write fOwnsEncoding;
    //should BOM be written
    property WriteBOM: Boolean read fWriteBOM write fWriteBOM;
  end;

  EOTextReader = class(Exception);

//decide what encoding is used in a stream (BOM markers are searched for)
//  only UTF-8, UTF-16, UTF-16BE can be recognized
function GetEncodingFromStream(const aStream: TStream;
  var {%H-}aTempStringPosition: ONativeInt;
  const aLastPosition: ONativeInt;
  const {%H-}aDefaultSingleByteEncoding: TEncoding): TEncoding;

implementation

{$IFDEF FPC}
uses LazUTF8;
{$ENDIF}

resourcestring
  OTextReadWrite_Undo2Times = 'The aStream parameter must be assigned when creating a buffered stream.';

function GetEncodingFromStream(const aStream: TStream;
  var aTempStringPosition: ONativeInt;
  const aLastPosition: ONativeInt;
  const aDefaultSingleByteEncoding: TEncoding): TEncoding;
var
  xSize: Integer;
  xBuffer: TEncodingBuffer;
  xEncoding: TEncoding;
begin
  //MULTI BYTE ENCODINGS MUST HAVE A BOM DEFINED!!!
  if Assigned(aDefaultSingleByteEncoding) and aDefaultSingleByteEncoding.IsSingleByte then
    Result := aDefaultSingleByteEncoding
  else
    Result := TEncoding.Ansi;

  xSize := aLastPosition - aStream.Position;
  if xSize < 2 then
    Exit;//BOM must be at least 2 characters

  if xSize > 3 then
    xSize := 3;//BOM may be up to 3 characters

  SetLength(xBuffer, xSize);
  aStream.ReadBuffer(xBuffer[TEncodingBuffer_FirstElement], xSize);
  xEncoding := nil;
  aTempStringPosition := aTempStringPosition +
    TEncoding.GetBufferEncoding(xBuffer, xEncoding {$IFDEF O_DELPHI_XE_UP}, Result{$ENDIF});

  if Assigned(xEncoding) then
    Result := xEncoding;
  if not Assigned(Result) then
    Result := TEncoding.{$IFDEF O_DELPHI_XE2_UP}ANSI{$ELSE}ASCII{$ENDIF};

  aStream.Position := aTempStringPosition;
end;

function LoadString(
  const aReadStream: TStream;
  const aByteCount: ONativeInt;
  var aTempString: OWideString;
  const aEncoding: TEncoding): ONativeInt;
var
  xBuffer: TEncodingBuffer;
  xUTF8Inc: Integer;
const
  BS = TEncodingBuffer_FirstElement;
begin
  if aByteCount = 0 then begin
    Result := 0;
    Exit;
  end;
  SetLength(xBuffer, aByteCount);
  aReadStream.ReadBuffer(xBuffer[BS], aByteCount);
  Result := aByteCount;
  if aEncoding is TUTF8Encoding then begin
    //check if we did not reach an utf-8 character in the middle
    if
     ((Ord(xBuffer[BS+aByteCount-1]) and $80) = $00)
    then//last byte is 0.......
      xUTF8Inc := 0
    else if
     ((aByteCount > 1) and ((Ord(xBuffer[BS+aByteCount-1]) and $E0) = $C0)) or//110..... -> double char
     ((aByteCount > 2) and ((Ord(xBuffer[BS+aByteCount-2]) and $F0) = $E0)) or//1110.... -> triple char
     ((aByteCount > 3) and ((Ord(xBuffer[BS+aByteCount-3]) and $F8) = $F0)) or//11110... -> 4 char
     ((aByteCount > 4) and ((Ord(xBuffer[BS+aByteCount-4]) and $FC) = $F8)) or//111110.. -> 5 char
     ((aByteCount > 5) and ((Ord(xBuffer[BS+aByteCount-5]) and $FE) = $FC))   //1111110. -> 6 char
    then
      xUTF8Inc := 1
    else if
     ((aByteCount > 1) and ((Ord(xBuffer[BS+aByteCount-1]) and $F0) = $E0)) or//1110.... -> triple char
     ((aByteCount > 2) and ((Ord(xBuffer[BS+aByteCount-2]) and $F8) = $F0)) or//11110... -> 4 char
     ((aByteCount > 3) and ((Ord(xBuffer[BS+aByteCount-3]) and $FC) = $F8)) or//111110.. -> 5 char
     ((aByteCount > 4) and ((Ord(xBuffer[BS+aByteCount-4]) and $FE) = $FC))   //1111110. -> 6 char
    then
      xUTF8Inc := 2
    else if
     ((aByteCount > 1) and ((Ord(xBuffer[BS+aByteCount-1]) and $F8) = $F0)) or//11110... -> 4 char
     ((aByteCount > 2) and ((Ord(xBuffer[BS+aByteCount-2]) and $FC) = $F8)) or//111110.. -> 5 char
     ((aByteCount > 3) and ((Ord(xBuffer[BS+aByteCount-3]) and $FE) = $FC))   //1111110. -> 6 char
    then
      xUTF8Inc := 3
    else if
     ((aByteCount > 1) and ((Ord(xBuffer[BS+aByteCount-1]) and $FC) = $F8)) or//111110.. -> 5 char
     ((aByteCount > 2) and ((Ord(xBuffer[BS+aByteCount-2]) and $FE) = $FC))   //1111110. -> 6 char
    then
      xUTF8Inc := 4
    else if
     ((aByteCount > 1) and ((Ord(xBuffer[BS+aByteCount-1]) and $FE) = $FC))   //1111110. -> 6 char
    then
      xUTF8Inc := 5
    else
      xUTF8Inc := 0;//ERROR ?

    if xUTF8Inc > 0 then begin
      SetLength(xBuffer, aByteCount + xUTF8Inc);
      aReadStream.ReadBuffer(xBuffer[BS+aByteCount], xUTF8Inc);
      Result := Result + xUTF8Inc;
    end;
  end;
  aTempString := aTempString + aEncoding.GetString(xBuffer);
end;

procedure ClearTempString(
  var aTempString: OWideString;
  var aTempStringPosition: Integer;
  var aTempStringLength: Integer);
begin
  if aTempStringLength > aTempStringPosition then begin
    aTempString := '';
    aTempStringLength := 0;
  end else begin
    //LEAVE UNREAD TAIL
    Delete(aTempString, 1, aTempStringPosition-1);
    aTempStringLength := Length(aTempString);
  end;
  aTempStringPosition := 1;
end;

procedure CheckTempString(
  const aReadStream: TStream;
  var aReadStreamPosition: ONativeInt;
  const aReadStreamSize: ONativeInt;
  var aTempString: OWideString; var aTempStringPosition, aTempStringLength: Integer;
  const aReadChars: Integer;
  const aEncoding: TEncoding;
  const aBufferSize: Integer);
var
  xReadBytes: ONativeInt;
  xInc: ONativeInt;
begin
  if
    (aTempStringPosition+aReadChars-1 > aTempStringLength)
  then begin
    //LOAD NEXT BUFFER INTO TEMP STREAM, LEAVE UNREAD TAIL
    ClearTempString(aTempString, aTempStringPosition, aTempStringLength);

    xReadBytes := aReadStreamSize-aReadStreamPosition;
    if xReadBytes > aBufferSize then
      xReadBytes := aBufferSize;
    if xReadBytes > 0 then begin
      xInc := LoadString(aReadStream, xReadBytes, aTempString, aEncoding);
      aTempStringLength := Length(aTempString);
      aReadStreamPosition := aReadStreamPosition + xInc;
    end;
  end;
end;

{ TOTextReader }

procedure TOTextReader.BlockFlushTempBuffer;
begin
  if fStream is TOBufferedReadStream then
    TOBufferedReadStream(fStream).BlockFlushTempBuffer;
end;

procedure TOTextReader.ClearCustomBuffer(const aBufferIndex: Byte);
begin
  fCustomBuffer[aBufferIndex].Position := 1;
end;

constructor TOTextReader.Create(aStream: TStream; var aBOMFound: Boolean;
  const aDefaultSingleByteEncoding: TEncoding; const aBufferSize: Integer);
begin
  inherited Create;

  DoCreate(aStream, aBOMFound, aDefaultSingleByteEncoding, aBufferSize);
end;

constructor TOTextReader.Create(aStream: TStream; const aDefaultSingleByteEncoding: TEncoding;
  const aBufferSize: Integer);
var
  xBOMFound: Boolean;
begin
  inherited Create;

  DoCreate(aStream, xBOMFound, aDefaultSingleByteEncoding, aBufferSize);
end;

function TOTextReader.CustomBufferLength(const aBufferIndex: Byte): Integer;
begin
  Result := fCustomBuffer[aBufferIndex].Position - 1;
end;

destructor TOTextReader.Destroy;
begin
  if fOwnsStream then
    fStream.Free;

  if fOwnsEncoding then
    fEncoding.Free;

  inherited;
end;

procedure TOTextReader.DoCreate(aStream: TStream; var aBOMFound: Boolean;
  const aDefaultSingleByteEncoding: TEncoding; const aBufferSize: Integer);
var
  I: Integer;
  xStreamPosition: Integer;
begin
  if aStream is TCustomMemoryStream then begin
    //no need for buffering on memory stream
    fStream := aStream;
    fOwnsStream := False;
  end else begin
    //we need buffering support for file or zip streams etc.
    fStream := TOBufferedReadStream.Create(aStream, aBufferSize);
    fStreamPosition := fStream.Position;
    fStreamStartPosition := fStreamPosition;
    fOwnsStream := True;
  end;

  fStreamSize := fStream.Size;
  fBufferSize := aBufferSize;

  BlockFlushTempBuffer;//block because GetEncodingFromStream seeks back in stream!
  try
    xStreamPosition := fStreamPosition;
    fEncoding := GetEncodingFromStream(fStream, fStreamPosition, fStreamSize, aDefaultSingleByteEncoding);
    aBOMFound := (xStreamPosition < fStreamPosition);//if BOM was found, fStreamPosition will increase
  finally
    UnblockFlushTempBuffer;
  end;
  fOwnsEncoding := not TEncoding.IsStandardEncoding(fEncoding);

  fTempString := '';
  fTempStringPosition := 1;

  for I := Low(fCustomBuffer) to High(fCustomBuffer) do begin
    fCustomBuffer[I].Length := 256;
    fCustomBuffer[I].Position := 1;
    SetLength(fCustomBuffer[I].Buffer, fCustomBuffer[I].Length);
  end;
end;

function TOTextReader.GetCustomBuffer(const aBufferIndex: Byte): OWideString;
var
  xCurrentBuffer: POTextReaderCustomBuffer;
begin
  xCurrentBuffer := @fCustomBuffer[aBufferIndex];
  if xCurrentBuffer.Position > 1 then
    Result := Copy(xCurrentBuffer.Buffer, 1, xCurrentBuffer.Position-1)
  else
    Result := '';
  ClearCustomBuffer(aBufferIndex);
end;

function TOTextReader.GetApproxStreamPosition: ONativeInt;
begin
  //YOU CAN'T KNOW IT EXACTLY!!! (due to Lazarus Unicode->UTF8 or Delphi UTF8->Unicode conversion etc.)
  //the char lengths may differ from one character to another
  Result := fStreamPosition - fStreamStartPosition + fTempStringPosition;
end;

function TOTextReader.GetPreviousChar: OWideChar;
begin
  Result := fPreviousChar;
end;

function TOTextReader.ReadNextChar(var outChar: OWideChar): Boolean;
begin
  if fReadFromUndo then begin
    outChar := GetPreviousChar;
    fReadFromUndo := False;
    Result := True;
    Exit;
  end;

  Result := (fStreamPosition < fStreamSize) or
    (fTempStringPosition <= fTempStringLength);

  if not Result then begin
    outChar := #0;
  end else begin
    CheckTempString(fStream, fStreamPosition, fStreamSize, fTempString,
      fTempStringPosition, fTempStringLength, 1, fEncoding, fBufferSize);

    if fTempStringPosition <= fTempStringLength then begin
      outChar := fTempString[fTempStringPosition];
      fPreviousChar := outChar;
      Inc(fTempStringPosition);
    end else begin
      Result := False;
      outChar := #0;
    end;
  end;
end;

function TOTextReader.ReadPreviousString(const aMaxChars: Integer): OWideString;
var
  xReadChars: Integer;
begin
  xReadChars := fTempStringPosition-1;
  if xReadChars > aMaxChars then
    xReadChars := aMaxChars;

  if xReadChars > 0 then
    Result := Copy(fTempString, fTempStringPosition-xReadChars, xReadChars)
  else
    Result := '';
end;

function TOTextReader.ReadString(const aMaxChars: Integer): OWideString;
var
  I: Integer;
  xC: OWideChar;
begin
  if aMaxChars <= 0 then begin
    Result := '';
    Exit;
  end;

  SetLength(Result, aMaxChars);
  I := 0;
  while ReadNextChar({%H-}xC) do begin
    Inc(I);
    Result[I] := xC;
    if I >= aMaxChars then
      Break;
  end;

  if I < aMaxChars then
    SetLength(Result, I);
end;

procedure TOTextReader.RemovePreviousCharFromBuffer(const aBufferIndex: Byte);
var
  xCurrentBuffer: POTextReaderCustomBuffer;
begin
  xCurrentBuffer := @fCustomBuffer[aBufferIndex];
  Dec(xCurrentBuffer.Position);
  if xCurrentBuffer.Position < 0 then
    xCurrentBuffer.Position := 0;
end;

procedure TOTextReader.SetEncoding(const Value: TEncoding);
begin
  if fEncoding <> Value then begin//the condition fEncoding <> Value must be here!!!
    if fOwnsEncoding then
      fEncoding.Free;
    fEncoding := Value;
    fOwnsEncoding := not TEncoding.IsStandardEncoding(fEncoding);

    //CLEAR ALREADY READ STRING AND GO BACK
    fStream.Position := fStreamStartPosition;
    fStreamPosition := fStreamStartPosition;

    fTempString := '';
    fTempStringLength := 0;
    fTempStringPosition := 1;
  end;
end;

procedure TOTextReader.UnblockFlushTempBuffer;
begin
  if fStream is TOBufferedReadStream then
    TOBufferedReadStream(fStream).UnblockFlushTempBuffer;
end;

procedure TOTextReader.UndoRead;
begin
  if fReadFromUndo then
    raise EOTextReader.Create(OTextReadWrite_Undo2Times);

  fReadFromUndo := True;
end;

procedure TOTextReader.WriteCharToBuffer(const aChar: OWideChar; const aBufferIndex: Byte);
var
  xCurrentBuffer: POTextReaderCustomBuffer;
begin
  xCurrentBuffer := @fCustomBuffer[aBufferIndex];
  if xCurrentBuffer.Position-1 = xCurrentBuffer.Length then
  begin
    xCurrentBuffer.Length := 2 * xCurrentBuffer.Length;
    SetLength(xCurrentBuffer.Buffer, xCurrentBuffer.Length);
  end;
  xCurrentBuffer.Buffer[xCurrentBuffer.Position] := aChar;
  Inc(xCurrentBuffer.Position);
end;

procedure TOTextReader.WritePreviousCharToBuffer(const aBufferIndex: Byte);
begin
  if fPreviousChar <> #0 then
    WriteCharToBuffer(fPreviousChar, aBufferIndex)
end;

procedure TOTextReader.WriteStringToBuffer(const aStr: OWideString;
  const aBufferIndex: Byte);
var
  I: Integer;
begin
  for I := 1 to Length(aStr) do
    WriteCharToBuffer(aStr[I], aBufferIndex);
end;

{ TOTextWriter }

constructor TOTextWriter.Create(aStream: TStream; aBufferSize: Integer);
begin
  inherited Create;

  DoCreate(aStream, TEncoding.Default, True, aBufferSize);
end;

constructor TOTextWriter.Create(aStream: TStream; aEncoding: TEncoding;
  aWriteBOM: Boolean; aBufferSize: Integer);
begin
  inherited Create;

  DoCreate(aStream, aEncoding, aWriteBOM, aBufferSize);
end;

destructor TOTextWriter.Destroy;
begin
  EnsureTempStringWritten;

  if fOwnsEncoding then
    fEncoding.Free;

  inherited;
end;

procedure TOTextWriter.DoCreate(aStream: TStream; aEncoding: TEncoding;
  aWriteBOM: Boolean; aBufferSize: Integer);
begin
  fStream := aStream;

  fTempStringLength := aBufferSize;

  fEncoding := aEncoding;
  fOwnsEncoding := not TEncoding.IsStandardEncoding(fEncoding);

  fWriteBOM := aWriteBOM;

  SetLength(fTempString, fTempStringLength);
  fTempStringPosition := 1;
end;

procedure TOTextWriter.EnsureTempStringWritten;
begin
  if fTempStringPosition > 1 then begin
    if fTempStringLength = fTempStringPosition-1 then begin
      WriteStringToStream(fTempString, -1);
    end else begin
      WriteStringToStream(fTempString, fTempStringPosition-1);
    end;
    fTempStringPosition := 1;
  end;
end;

procedure TOTextWriter.SetEncoding(const Value: TEncoding);
begin
  if fEncoding <> Value then begin
    EnsureTempStringWritten;
    if fOwnsEncoding then
      fEncoding.Free;
    fEncoding := Value;
    fOwnsEncoding := not TEncoding.IsStandardEncoding(fEncoding);
  end;
end;

procedure TOTextWriter.WriteString(const aString: OWideString);
var
  xStringLength: Integer;
begin
  xStringLength := Length(aString);
  if xStringLength = 0 then
    Exit;

  if fTempStringPosition-1 + xStringLength > fTempStringLength then begin
    EnsureTempStringWritten;//WRITE TEMP BUFFER
  end;

  if xStringLength > fTempStringLength then begin
    WriteStringToStream(aString, -1);
  end else begin
    Move(aString[1], fTempString[fTempStringPosition], xStringLength*SizeOf(OWideChar));
    fTempStringPosition := fTempStringPosition + xStringLength;
  end;
end;

procedure TOTextWriter.WriteStringToStream(const aString: OWideString; const aMaxLength: Integer);
var
  xBytes: TEncodingBuffer;
  xBytesLength: Integer;
  xBOM: TEncodingBuffer;
begin
  if fWriteBOM and not fBOMWritten then begin
    //WRITE BOM
    xBOM := fEncoding.GetPreamble;
    if Length(xBOM) > 0 then
      fStream.WriteBuffer(xBOM[TEncodingBuffer_FirstElement], Length(xBOM));
  end;
  fBOMWritten := True;

  if aMaxLength < 0 then begin
    //write complete string
    xBytes := fEncoding.GetBytes(aString);
    xBytesLength := Length(xBytes);
  end else begin
    //write part of string
    xBytes := fEncoding.GetBytes(Copy(aString, 1, aMaxLength));
    xBytesLength := Length(xBytes);
  end;

  if xBytesLength > 0 then
    fStream.WriteBuffer(xBytes[TEncodingBuffer_FirstElement], xBytesLength);
end;

end.
