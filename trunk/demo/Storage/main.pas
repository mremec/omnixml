unit main;

interface

// if you want to use MS XML parser, create a global compiler define: 'USE_MSXML'

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  OmniXML, OmniXML_Types,
{$IFDEF USE_MSXML}
  OmniXML_MSXML,
{$ENDIF}
  OmniXMLPersistent;

type
  {$IFDEF UNICODE}
  TSlovenianString = type AnsiString(1250);  // 1250 - Slovenian
  TChineseString = type AnsiString(950);  // 950 - Traditional Chinese Big5
  TJapaneseString = type AnsiString(932);  // 932 - Japanese
  {$ENDIF}  // UNICODE
  TSomeValues = (svOne, svTwo, svThree, svFour, svFive);
  TMySet = set of TSomeValues;

  TStandaloneClass = class(TPersistent)
  private
    FpropFloat: Double;
  published
    property propFloat: Double read FpropFloat write FpropFloat;
  end;

  TChildClass = class(TCollectionItem)
  private
    FpropFloat: Double;
  published
    property propFloat: Double read FpropFloat write FpropFloat;
  end;

  TPropList = class(TCollection)
  private
    FCurDate: TDateTime;
  published
    property curDate: TDateTime read FCurDate write FCurDate;
  end;

  TMyXML = class(TPersistent)
  private
    FpropString: string;
    FpropAnsiString: AnsiString;
    FpropShortString: ShortString;
    FpropUTF8String: UTF8String;
    {$IFDEF UNICODE}
    FpropChineseString: TChineseString;
    FpropRawByteString: RawByteString;
    {$ENDIF}  // UNICODE
    FpropWideString: WideString;
    FpropWideChar: WideChar;
    FpropBoolean: Boolean;
    FpropInteger: Integer;
    FpropChar: Char;
    FpropCharDefault: Char;
    FpropByte: Byte;
    FpropWord: Word;
    FpropSmallInt: SmallInt;
    FpropEnum: TSomeValues;
    FpropSet: TMySet;
    FpropClass: TStandaloneClass;
    FpropClass_ReadOnly: TStandaloneClass;
    FpropFloat: Double;
    FpropList: TPropList;
    FpropDate: TDate;
    FpropTime: TTime;
    FpropDateTime: TDateTime;
    FpropEmptyDateTime: TDateTime;
    FpropStringList: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property propString: string read FpropString write FpropString;
    property propAnsiString: AnsiString read FpropAnsiString write FpropAnsiString;
    property propShortString: ShortString read FpropShortString write FpropShortString;
    property propUTF8String: UTF8String read FpropUTF8String write FpropUTF8String;
    {$IFDEF UNICODE}
    property propChineseString: TChineseString read FpropChineseString write FpropChineseString;
    property propRawByteString: RawByteString read FpropRawByteString write FpropRawByteString;
    {$ENDIF}  // UNICODE
    property propWideString: WideString read FpropWideString write FpropWideString;
    property propWideChar: WideChar read FpropWideChar write FpropWideChar;
    property propChar: Char read FpropChar write FpropChar;
    property propCharDefault: Char read FpropCharDefault write FpropCharDefault default 'B';
    property propBoolean: Boolean read FpropBoolean write FpropBoolean default False;
    property propInteger: Integer read FpropInteger write FpropInteger;
    property propByte: Byte read FpropByte write FpropByte;
    property propWord: Word read FpropWord write FpropWord;
    property propSmallInt: SmallInt read FpropSmallInt write FpropSmallInt;
    property propEnum: TSomeValues read FpropEnum write FpropEnum;
    property propSet: TMySet read FpropSet write FpropSet;
    property propClass: TStandaloneClass read FpropClass write FpropClass;
    property propClass_ReadOnly: TStandaloneClass read FpropClass_ReadOnly;
    property propFloat: Double read FpropFloat write FpropFloat;
    property propList: TPropList read FpropList write FpropList;
    property propDate: TDate read FpropDate write FpropDate;
    property propTime: TTime read FpropTime write FpropTime;
    property propDateTime: TDateTime read FpropDateTime write FpropDateTime;
    property propEmptyDateTime: TDateTime read FpropEmptyDateTime write FpropEmptyDateTime;
    property propStringList: TStringList read FpropStringList write FpropStringList;
  end;

  TfMain = class(TForm)
    bWriteToFile: TButton;
    bLoadFromFile: TButton;
    mDescription: TMemo;
    Label10: TLabel;
    Bevel1: TBevel;
    Label1: TLabel;
    rgPropsFormat: TRadioGroup;
    rgOutputFormat: TRadioGroup;
    Bevel2: TBevel;
    Label11: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure bWriteToFileClick(Sender: TObject);
    procedure bLoadFromFileClick(Sender: TObject);
  private
    DocPath: string;
    PX: TmyXML;
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}

type
  TExampleTextStringType = XmlString;
  TExampleTextCharType = XmlChar;

  TExampleText = record
    CodePage: Word;
    SampleString: TExampleTextStringType;
    SampleCharIndex: Integer;
    function SampleChar: TExampleTextCharType;
  end;

const
  // Unicode text examples copied from http://www.i18nguy.com/unicode-example.html
  CDefaultString = 'Brad Pitt';  // English (default): Brad Pitt (actor)
  CSloveneString = 'Frane Milčinski - Ježek';  // Slovene: Frane "Jezek" Milcinski (actor, singer)
  CChineseString = '章子怡';  // Traditional Chinese Big5: ZHANG Ziyi (actress)
  CJapaneseString = '久保田    利伸';  // Japanese: KUBOTA Toshinobu (singer)
  CUnicodeString = '€ ß ¤';  // some symbols

const
  ExampleTextList: array[1..5] of TExampleText =
  (
    ( CodePage: 1252; SampleString: CDefaultString; SampleCharIndex: 1 ),
    ( CodePage: 932; SampleString: CJapaneseString; SampleCharIndex: 1 ),
    ( CodePage: 950; SampleString: CChineseString; SampleCharIndex: 1 ),
    ( CodePage: 1250; SampleString: CSloveneString; SampleCharIndex: 21 ),
    ( CodePage: 1200; SampleString: CUnicodeString; SampleCharIndex: 1 )  
  );

{ TExampleText }

function TExampleText.SampleChar: TExampleTextCharType;
begin
  Result := SampleString[SampleCharIndex];
end;

{ TMyXML }

constructor TMyXML.Create;
begin
  inherited;
  propList := TPropList.Create(TChildClass);
  propClass := TStandaloneClass.Create;
  FpropClass_ReadOnly := TStandaloneClass.Create;
  propStringList := TStringList.Create;
end;

destructor TMyXML.Destroy;
begin
  propStringList.Free;
  FreeAndNil(FpropClass_ReadOnly);
  propClass.Free;
  propList.Free;
  inherited;
end;

procedure TfMain.FormCreate(Sender: TObject);
var
  UseCodePage: Word;
  ExampleTextIndex: Integer;
  ExampleText: TExampleText;
begin
  // try to find most appropriate codepage based on system default code page
  UseCodePage := GetACP;

  ExampleTextIndex := Low(ExampleTextList);
  while ExampleTextIndex <= High(ExampleTextList) do
  begin
    if ExampleTextList[ExampleTextIndex].CodePage = UseCodePage then
      Break
    else
      Inc(ExampleTextIndex);
  end;
  if ExampleTextIndex > High(ExampleTextList) then
    ExampleTextIndex := Low(ExampleTextList);  // use default
  ExampleText := ExampleTextList[ExampleTextIndex];

  OmniXMLPersistent.DefaultPropFormat := pfNodes;

  DocPath := ExtractFilePath(ExpandFileName(ExtractFilePath(Application.ExeName) + '..\doc\dummy.xml'));
  PX := TMyXML.Create;
  PX.propClass.propFloat := 32/11;
  PX.propClass_ReadOnly.propFloat := 22/7;
  PX.propString := ExampleText.SampleString;
  PX.propAnsiString := AnsiString(ExampleText.SampleString);
  PX.propShortString := ShortString(ExampleText.SampleString);
  PX.propUTF8String := UTF8String(ExampleText.SampleString);
  {$IFDEF UNICODE}
  PX.propChineseString := CChineseString;  // this is hardcoded to constant
  PX.propRawByteString := UTF8Encode(ExampleText.SampleString);
  {$ENDIF}  // UNICODE
  PX.propWideString := WideString(ExampleText.SampleString);
  PX.propWideChar := WideChar(ExampleText.SampleChar);
  PX.propChar := Utf8ToAnsi(UTF8Encode(ExampleText.SampleChar))[1];
  PX.propCharDefault := 'B';

  PX.propBoolean := True;
  PX.propInteger := 128934;
  PX.propEnum := svTwo;
  PX.propSet := [svTwo, svFive, svFour];
  PX.propFloat := 22/7;
  PX.propDate := Trunc(Now);
  PX.propTime := Frac(Now);
  PX.propDateTime := Now;
//  PX.propEmptyDateTime := 0;
  PX.propStringList.Add('line'#3'1');
  PX.propStringList.Add('');
  PX.propStringList.Add('line 3');
  PX.propStringList.Delimiter := ';';

  PX.propList.curDate := Now;
  TChildClass(PX.propList.Add).propFloat := 23/7;
  TChildClass(PX.propList.Add).propFloat := 12/8;
  TChildClass(PX.propList.Add).propFloat := 1/3;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  PX.Free;
end;

procedure TfMain.bWriteToFileClick(Sender: TObject);
begin
  // first we save PX (custom TPersistent class)
  TOmniXMLWriter.SaveToFile(PX, DocPath + 'storage_PX.xml',
    TPropsFormat(rgPropsFormat.ItemIndex + 1), TOutputFormat(rgOutputFormat.ItemIndex));
  // then, we save Self (TForm class)
  TOmniXMLWriter.SaveToFile(Self, DocPath + 'storage_form.xml',
    TPropsFormat(rgPropsFormat.ItemIndex + 1), TOutputFormat(rgOutputFormat.ItemIndex));
end;

procedure TfMain.bLoadFromFileClick(Sender: TObject);
begin
  FreeAndNil(PX);
  PX := TMyXML.Create;

  TOmniXMLReader.LoadFromFile(PX, DocPath + 'storage_PX.xml');
  TOmniXMLWriter.SaveToFile(PX, DocPath + 'storage_PX_resaved.xml',
    TPropsFormat(rgPropsFormat.ItemIndex + 1), TOutputFormat(rgOutputFormat.ItemIndex));
end;

initialization
  RegisterClass(TChildClass);

end.

