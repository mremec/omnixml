unit main;

interface

// if you want to use MS XML parser, create a global compiler define: 'USE_MSXML'

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Contnrs,
  OmniXML
{$IFDEF USE_MSXML}
  , OmniXML_MSXML
{$ENDIF}
  ;

type
  TErrorCase = class
    Category,
    Description,
    Original,
    Replacement: string;
  end;
  TErrorCaseList = class(TObjectList)
  private
    function GetErrorCase(i: Integer): TErrorCase;
  public
    property Items[i: Integer]: TErrorCase read GetErrorCase; default;
    procedure AddErrorCase(const Category, Description, Original, Replacement: string);
  end;
  TfMain = class(TForm)
    bTest: TButton;
    mErrorInfo: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    reXML: TRichEdit;
    tvErrorCases: TTreeView;
    chbAutoTest: TCheckBox;
    procedure bTestClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure tvErrorCasesChange(Sender: TObject; Node: TTreeNode);
  private
    IsClosing: Boolean;
    FECL: TErrorCaseList;
    OriginalXML: string;
    xmlDoc: IXMLDocument;
    procedure AddErrorCases;
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}

{ TErrorCaseList }

procedure TErrorCaseList.AddErrorCase(const Category, Description, Original, Replacement: string);
var
  EC: TErrorCase;
begin
  EC := TErrorCase.Create;
  EC.Category := Category;
  EC.Description := Description;
  EC.Original := Original;
  EC.Replacement := Replacement;
  inherited Add(EC);
end;

function TErrorCaseList.GetErrorCase(i: Integer): TErrorCase;
begin
  Result := TErrorCase(inherited Items[i]);
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  xmlDoc := CreateXMLDoc;
  FECL := TErrorCaseList.Create;

  OriginalXML := reXML.Text;
  AddErrorCases;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
  FECL.Free;
  xmlDoc := nil;
end;

procedure TfMain.AddErrorCases;
var
  i: Integer;
  ParentNode: TTreeNode;
begin
  // reference
  FECL.AddErrorCase('CharReference', 'MSG_E_UNEXPECTED_WHITESPACE @ Reference [67]', '&amp;', '& amp;');
  FECL.AddErrorCase('CharReference', 'MSG_E_BADSTARTNAMECHAR @ EntityRef [68]', '&amp;', '&*amp;');
  FECL.AddErrorCase('CharReference', 'MSG_E_UNEXPECTED_WHITESPACE @ CharRef [66]', '&#33;', '&# 33;');
  FECL.AddErrorCase('CharReference', 'MSG_E_BADCHARINENTREF @ CharRef [66]', '&#33;', '&#a33;');
  FECL.AddErrorCase('CharReference', 'MSG_E_UNEXPECTED_WHITESPACE @ CharRef [66]', '&#33;', '&#3 3;');
  FECL.AddErrorCase('CharReference', 'MSG_E_INVALID_DECIMAL @ CharRef [66]', '&#33;', '&#3a3;');
  FECL.AddErrorCase('CharReference', 'MSG_E_UNEXPECTED_WHITESPACE @ CharRef [66]', '&#x21;', '&#x 21;');
  FECL.AddErrorCase('CharReference', 'MSG_E_INVALID_HEXADECIMAL @ CharRef [66]', '&#x21;', '&#x2r1;');
  FECL.AddErrorCase('CharReference', 'MSG_E_INVALID_UNICODE @ CharRef [66]', '&#x21;', '&#x110000;');
  FECL.AddErrorCase('CharReference', 'MSG_E_INVALID_UNICODE @ CharRef [66]', '&#x21;', '&#x0003;');
  FECL.AddErrorCase('CharReference', 'XML_ENTITY_UNDEFINED @ EntityRef [68]', '&amp;', '&winamp;');
  FECL.AddErrorCase('CharReference', 'MSG_E_MISSINGSEMICOLON @ EntityRef [68]', '&amp;', '&amp<a />');

  // element
  FECL.AddErrorCase('xmlElement', 'MSG_E_BADSTARTNAMECHAR @ Name [5]', '<customer', '<(c)ustomer');
  FECL.AddErrorCase('xmlElement', 'MSG_E_BADNAMECHAR @ NameChar [4]', '<customer', '<cu*stomer');
  FECL.AddErrorCase('xmlElement', 'MSG_E_ENDTAGMISMATCH @ ETag [42]', '</first_name>', '</customer></first_name>');
  FECL.AddErrorCase('xmlElement', 'MSG_E_UNEXPECTED_WHITESPACE @ EmptyElemTag [44]', '/>', '/ >');
  FECL.AddErrorCase('xmlElement', 'MSG_E_EXPECTINGTAGEND @ EmptyElemTag [44]', '/>', '/A>');

  // attribute
  FECL.AddErrorCase('xmlAttribute', 'MSG_E_BADSTARTNAMECHAR @ Attribute [41]', 'id="1"', '*d="1"');
  FECL.AddErrorCase('xmlAttribute', 'MSG_E_BADNAMECHAR @ NameChar [4]', 'id="1"', 'id(x)="1"');
  FECL.AddErrorCase('xmlAttribute', 'MSG_E_MISSINGEQUALS @ Eq [25]', 'id="1"', 'id new');
  FECL.AddErrorCase('xmlAttribute', 'MSG_E_MISSINGQUOTE @ AttValue [10]', 'id="1"', 'id=1');
  FECL.AddErrorCase('xmlAttribute', 'MSG_E_BADCHARINSTRING @ AttValue [10]', 'id="1"', 'id="1<2"');

  // PITarget
  FECL.AddErrorCase('xmlProcInstruction', 'MSG_E_BADSTARTNAMECHAR @ PITarget [17]', '<?xml', '<?*ml');
  FECL.AddErrorCase('xmlProcInstruction', 'MSG_E_BADXMLDECL @ PITarget [17]', '<?xml version="1.0"?>'#13#10'<customer id="1">', '<customer id="1">'#13#10'<?xml version="1.0"?>');
  FECL.AddErrorCase('xmlProcInstruction', 'MSG_E_BADNAMECHAR @ PITarget [17]', '<?xml', '<?x*ml');

  for i := 0 to FECL.Count - 1 do begin
    ParentNode := tvErrorCases.Items.GetFirstNode;
    while ParentNode <> nil do begin
      if SameText(ParentNode.Text, FECL[i].Category) then
        Break;
      ParentNode := ParentNode.getNextSibling;
    end;
    if ParentNode = nil then
      ParentNode := tvErrorCases.Items.AddChild(nil, FECL[i].Category);
    tvErrorCases.Items.AddChild(ParentNode, FECL[i].Description).Data := Pointer(i+1);
  end;
end;

procedure TfMain.bTestClick(Sender: TObject);
begin
  with mErrorInfo.Lines do begin
    Clear;
    if not xmlDoc.LoadXML(WideString(reXML.Text)) then begin
      Add('Loading failed :(');
      Add(Format('Error code: %d', [xmlDoc.ParseError.ErrorCode]));
      Add(Format('FilePos: %d', [xmlDoc.ParseError.FilePos]));
      Add(Format('Line: %d', [xmlDoc.ParseError.Line]));
      Add(Format('LinePos: %d', [xmlDoc.ParseError.LinePos]));
      Add(Format('Reason: %s', [xmlDoc.ParseError.Reason]));
      Add(Format('URL: %s', [xmlDoc.ParseError.URL]));
      Add(Format('SrcText: %s', [xmlDoc.ParseError.SrcText]));
      Add(StringOfChar(' ', 9) + StringOfChar('-', xmlDoc.ParseError.LinePos - 1) + '^');
    end
    else begin
      Text := 'No errors found.';
//      Add(#13#10 + 'XML document:' + #13#10 + xmlDoc.XML);
    end;
  end;
end;

procedure TfMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  IsClosing := True;
end;

procedure TfMain.tvErrorCasesChange(Sender: TObject; Node: TTreeNode);
var
  NewXML: string;
  DocPos: Integer;
  EC: TErrorCase;
begin
  if IsClosing then
    Exit;

  reXML.Text := '';
  reXML.SelStart := 0;
  reXML.SelLength := 0;
  reXML.SelAttributes.Color := clWindowText;
  reXML.SelAttributes.Style := [];

  if Node.Data = nil then begin
    reXML.Text := OriginalXML;
    Exit;
  end;

  NewXML := OriginalXML;
  EC := FECL[Integer(Node.Data) - 1];
  DocPos := Pos(EC.Original, NewXML);

  NewXML := Copy(NewXML, 1, DocPos - 1) +
    EC.Replacement +
    Copy(NewXML, DocPos + Length(EC.Original), MaxInt);

  reXML.Text := NewXML;
  reXML.SelStart := DocPos-1;
  reXML.SelLength := Length(EC.Replacement);
  reXML.SelAttributes.Color := clRed;
  reXML.SelAttributes.Style := [fsBold];

  if chbAutoTest.Checked then
    bTest.Click;
end;

end.

