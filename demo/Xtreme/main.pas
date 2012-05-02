unit main;

interface

// if you want to use MS XML parser, create a global compiler define: 'USE_MSXML'

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  OmniXML,
{$IFDEF USE_MSXML}
  OmniXML_MSXML,
{$ENDIF}
  OmniXMLUtils;

type
  TfMain = class(TForm)
    Label8: TLabel;
    Bevel3: TBevel;
    Bevel1: TBevel;
    Label2: TLabel;
    Label10: TLabel;
    eFileName: TEdit;
    Label9: TLabel;
    cobCodePage: TComboBox;
    bDriveSave: TButton;
    rgOutputFormat: TRadioGroup;
    procedure bDriveSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    DocPath: string;
    FDoc: IXMLDocument;
    FRoot: IXMLElement;
    function AddPort(const Parent: IXMLElement; const Keyword, Decimal, Description: string): IXMLElement;
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}

procedure TfMain.FormCreate(Sender: TObject);
{$IFNDEF USE_MSXML}
var
  i: Integer;
{$ENDIF}
begin
  DocPath := ExtractFilePath(ExpandFileName(ExtractFilePath(Application.ExeName) + '..\doc\dummy.xml'));

  eFileName.Text := DocPath + 'xtreme.xml';

  cobCodePage.Items.AddObject('<none (UTF-8)>', nil);

{$IFNDEF USE_MSXML}
  for i := Low(TCodePages) to High(TCodePages) do
    cobCodePage.Items.AddObject(CodePages[i].Alias, TObject(CodePages[i].CodePage));
{$ENDIF}

  cobCodePage.ItemIndex := 0;
end;

function TfMain.AddPort(const Parent: IXMLElement; const Keyword, Decimal, Description: string): IXMLElement;
var
  AttrNode: IXMLAttr;

  procedure AddSubElement(const Parent: IXMLElement; const Name, Value: string);
  var
    Element: IXMLElement;
    Text: IXMLText;
  begin
    Element := FDoc.createElement(Name);
    Text := FDoc.createTextNode(Value);
    Element.appendChild(Text);
    Parent.appendChild(Element);
  end;

begin
  // add port
  Result := FDoc.createElement('port');
  Parent.appendChild(Result);

  // add attributes
  AddSubElement(Result, 'keyword', Keyword);
  AddSubElement(Result, 'decimal', Decimal);
  AddSubElement(Result, 'desc', Description);

  // create attribute and set it's value to false
  AttrNode := FDoc.CreateAttribute('active');
  AttrNode.AppendChild(FDoc.CreateTextNode(DEFAULT_TRUE));

  // a different way to change attribute's value
  AttrNode.Value := DEFAULT_FALSE;
  Result.Attributes.SetNamedItem(AttrNode);

  // another way to set/change attribute's value
  Result.SetAttribute('active', DEFAULT_TRUE);
end;

procedure TfMain.bDriveSaveClick(Sender: TObject);
var
  PI: IXMLProcessingInstruction;
  Element: IXMLElement;
  SS: TStringStream;
  CData: IXMLCDATASection;
  Comment: IXMLComment;
begin
  FDoc := CreateXMLDoc;

  FDoc.PreserveWhiteSpace := True;

  // processing instruction
  if cobCodePage.ItemIndex <> 0 then begin
    PI := FDoc.CreateProcessingInstruction('xml', Format('version="1.0" encoding="%s"', [cobCodePage.Items[cobCodePage.ItemIndex]]));
    FDoc.AppendChild(PI);
  end;

  // create root element
  FRoot := FDoc.CreateElement('MyTest');
  FDoc.DocumentElement := FRoot;

  // add some data
  Element := FDoc.CreateElement('SimpleElement');
  Element.SetAttribute('AttrX', 'yes');
  Element.SetAttribute('AttrY', '1');
  Element.Text := '     Text <with> "strange" chars,   words   & whitespaces   ';
  FRoot.AppendChild(Element);

  CData := FDoc.CreateCDATASection('     CDATA section <with> "strange" chars,   words   & whitespaces   ');
  FRoot.AppendChild(CData);

  // CDATA section
  SS := TStringStream.Create('');
  try
    SS.WriteComponent(Self);
    CData := FDoc.CreateCDATASection(SS.DataString);
    FRoot.AppendChild(CData);
    CData := FDoc.CreateCDATASection('<greeting>Hello, world!</greeting>');
    FRoot.AppendChild(CData);
  finally
    SS.Free;
  end;

  // comment
  Comment := FDoc.CreateComment('Just'#13#10'<!another!>'#13#10'comment');
  FRoot.AppendChild(Comment);

  AddPort(FRoot, 'echo', '7', 'Echo');
  AddPort(FRoot, 'ftp', '21', 'File Transfer [Control]');
  AddPort(FRoot, 'ssh', '22', 'SSH Remote Login Protocol');

  // save XML document to file
  XMLSaveToFile(FDoc, eFileName.Text, TOutputFormat(rgOutputFormat.ItemIndex));
end;

end.

