(*:Demonstration project for the OmniXMLXpath parser.
   @author Primoz Gabrijelcic
   @desc <pre>
   (c) 2006 Primoz Gabrijelcic
   Free for personal and commercial use. No rights reserved.

   Author            : Primoz Gabrijelcic
   Creation date     : 2005-10-28
   Last modification : 2006-02-02
   Version           : 1.01
</pre>*)(*
   History:
     1.01: 2006-02-02
       - Added test cases for new functionality in OmniXMLXpath 1.01.
*)

unit XPathDemo1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  OmniXML;

type
  TfrmXPathDemo = class(TForm)
    btnClose         : TButton;
    btnExecute       : TButton;
    btnTestAll       : TButton;
    bvlVert1         : TBevel;
    cbxExample       : TComboBox;
    inpSourceDocument: TMemo;
    lab              : TLabel;
    lblDescription   : TLabel;
    lblResult        : TLabel;
    lblSourceDocument: TLabel;
    outExpression    : TEdit;
    outResult        : TMemo;
    procedure btnCloseClick(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
    procedure btnTestAllClick(Sender: TObject);
    procedure cbxExampleChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FXMLDocument     : IXMLDocument;
    FXPathExpressions: TStringList;
    FXPathResults    : TStringList;
    procedure AddExample(const xPathExpression, description, expectedResult: string);
    procedure PrepareExamples;
  end; { TfrmXPathDemo }

var
  frmXPathDemo: TfrmXPathDemo;

implementation

uses
  OmniXMLUtils,
  OmniXMLXPath;

{$R *.dfm}

{:Add XPath expression, description and expected result to appropriate lists.
  @since   2005-10-30
}
procedure TfrmXPathDemo.AddExample(const xPathExpression, description,
  expectedResult: string);
begin
  cbxExample.Items.Add(description);
  FXPathExpressions.Add(xPathExpression);
  FXPathResults.Add(expectedResult);
end; { TfrmXPathDemo.AddExample }

procedure TfrmXPathDemo.btnCloseClick(Sender: TObject);
begin
  Application.Terminate;
end; { TfrmXPathDemo.btnCloseClick }

{:Evaluate XPath expression.
  @since   2005-10-30
}
procedure TfrmXPathDemo.btnExecuteClick(Sender: TObject);
var
  expression    : string;
  expressionList: string;
  iNode         : integer;
  nodeList      : IXMLNodeList;
  p             : integer;
  queryNode     : IXMLNode;
  validResult   : boolean;
begin
  outResult.Lines.Clear;
  queryNode := FXMLDocument.DocumentElement;
  expressionList := FXPathExpressions[cbxExample.ItemIndex];
  repeat
    p := Pos('+', expressionList);
    if p > 0 then begin
      expression := TrimRight(Copy(expressionList, 1, p-1));
      Delete(expressionList, 1, p);
      expressionList := TrimLeft(expressionList);
    end
    else
      expression := expressionList;
    nodeList := XPathSelect(queryNode, expression);
    if nodeList.Length > 0 then
      queryNode := nodeList.Item[0]
    else
      queryNode := nil;
  until p = 0;
  for iNode := 0 to nodeList.Length-1 do begin
    outResult.Lines.Add(Format('%d:', [iNode]));
    outResult.Lines.Add('  '+nodeList.Item[iNode].XML);
  end; //for iNode
  validResult := (outResult.Lines.Text = FXPathResults[cbxExample.ItemIndex]);
  outResult.Lines.Add('');
  if validResult then
    outResult.Lines.Add('OK')
  else begin
    outResult.Lines.Add('ERROR');
    outResult.Lines.Add('');
    outResult.Lines.Add('Expected: ');
    outResult.Lines.Append(FXPathResults[cbxExample.ItemIndex]);
  end;
  outResult.Lines.Insert(0, Format('Result contains %d nodes', [nodeList.Length]));
end; { TfrmXPathDemo.btnExecuteClick }

{:Test all examples, stop on first error.
  @since   2005-10-30
}
procedure TfrmXPathDemo.btnTestAllClick(Sender: TObject);
var
  iExample: integer;
begin
  for iExample := 0 to cbxExample.Items.Count-1 do begin
    cbxExample.ItemIndex := iExample;
    cbxExample.OnChange(cbxExample);
    btnExecute.Click;
    if outResult.Lines[outResult.Lines.Count-1] <> 'OK' then
      Exit;
  end;
  cbxExample.ItemIndex := -1;
  cbxExample.OnChange(cbxExample);
  outResult.Lines.Clear;
  outResult.Lines.Add('All tests OK')
end; { TfrmXPathDemo.btnTestAllClick }

{:Reselect XPath expression when description changes.
  @since   2005-10-30
}
procedure TfrmXPathDemo.cbxExampleChange(Sender: TObject);
begin
  if cbxExample.ItemIndex < 0 then begin
    outExpression.Text := '';
    btnExecute.Enabled := false;
    cbxExample.Hint := '';
  end
  else begin
    outExpression.Text := FXPathExpressions[cbxExample.ItemIndex];
    btnExecute.Enabled := true;
    cbxExample.Hint := cbxExample.Text;
  end;
  outResult.Lines.Clear;
end; { TfrmXPathDemo.cbxExampleChange }

procedure TfrmXPathDemo.FormCreate(Sender: TObject);
begin
  FXMLDocument := CreateXMLDoc;
  if not XMLLoadFromAnsiString(FXMLDocument, inpSourceDocument.Lines.Text) then
    raise Exception.Create('Source document is not valid');
  FXPathExpressions := TStringList.Create;
  FXPathResults := TStringList.Create;
  PrepareExamples;
end; { TfrmXPathDemo.FormCreate }

procedure TfrmXPathDemo.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FXPathResults);
  FreeAndNil(FXPathExpressions);
end; { TfrmXPathDemo.FormDestroy }

procedure TfrmXPathDemo.PrepareExamples;
begin
  AddExample(
    '/bookstore/book[1]',
    'Select the first book in bookstore',
    '0:' + #13#10 +
    '  <book>' + #13#10 +
    '    <title lang="eng">Harry Potter</title>' + #13#10 +
    '  </book>' + #13#10);
  AddExample(
    '/bookstore/book[2]',
    'Select the second book in bookstore',
    '0:' + #13#10 +
    '  <book>' + #13#10 +
    '    <title lang="eng">Learning XML</title>' + #13#10 +
    '  </book>' + #13#10);
  AddExample(
    '/bookstore/book/title[@lang=''eng'']',
    'Select all english books',
    '0:' + #13#10 +
    '  <title lang="eng">Harry Potter</title>' + #13#10 +
    '1:' + #13#10 +
    '  <title lang="eng">Learning XML</title>' + #13#10);
  AddExample(
    '/bookstore/book/title[@lang="eng"]',
    'Select all english books, with double quotes',
    '0:' + #13#10 +
    '  <title lang="eng">Harry Potter</title>' + #13#10 +
    '1:' + #13#10 +
    '  <title lang="eng">Learning XML</title>' + #13#10);
  AddExample(
    '//title[@lang=''eng'']',
    'Select all english books, simplified',
    '0:' + #13#10 +
    '  <title lang="eng">Harry Potter</title>' + #13#10 +
    '1:' + #13#10 +
    '  <title lang="eng">Learning XML</title>' + #13#10);
  AddExample(
    '/bookstore/book/title',
    'Select all titles',
    '0:' + #13#10 +
    '  <title lang="eng">Harry Potter</title>' + #13#10 +
    '1:' + #13#10 +
    '  <title lang="eng">Learning XML</title>' + #13#10 +
    '2:' + #13#10 +
    '  <title lang="slo">Z OmniXML v lepso prihodnost</title>' + #13#10 +
    '3:' + #13#10 +
    '  <title>Kwe sona standwa sam</title>' + #13#10);
  AddExample(
    '//title',
    'Select all titles, simplified',
    '0:' + #13#10 +
    '  <title lang="eng">Harry Potter</title>' + #13#10 +
    '1:' + #13#10 +
    '  <title lang="eng">Learning XML</title>' + #13#10 +
    '2:' + #13#10 +
    '  <title lang="slo">Z OmniXML v lepso prihodnost</title>' + #13#10 +
    '3:' + #13#10 +
    '  <title>Kwe sona standwa sam</title>' + #13#10);
  AddExample(
    '/bookstore//title[@lang]',
    'Select all titles with lang attribute',
    '0:' + #13#10 +
    '  <title lang="eng">Harry Potter</title>' + #13#10 +
    '1:' + #13#10 +
    '  <title lang="eng">Learning XML</title>' + #13#10 +
    '2:' + #13#10 +
    '  <title lang="slo">Z OmniXML v lepso prihodnost</title>' + #13#10);
  AddExample(
    '/bookstore/book[3]/*',
    'Select all nodes of the third book',
    '0:' + #13#10 +
    '  <title lang="slo">Z OmniXML v lepso prihodnost</title>' + #13#10 +
    '1:' + #13#10 +
    '  <year>2006</year>' + #13#10);
  AddExample(
    '/bookstore/book[1]/title/@lang',
    'Select language of the first book',
    '0:' + #13#10 +
    '   lang="eng"' + #13#10);
  AddExample(
    '/bookstore/book/title/@lang',
    'Select all languages',
    '0:' + #13#10 +
    '   lang="eng"' + #13#10 +
    '1:' + #13#10 +
    '   lang="eng"' + #13#10 +
    '2:' + #13#10 +
    '   lang="slo"' + #13#10);
  AddExample(
    '//title/@lang',
    'Select all languages, simpler way',
    '0:' + #13#10 +
    '   lang="eng"' + #13#10 +
    '1:' + #13#10 +
    '   lang="eng"' + #13#10 +
    '2:' + #13#10 +
    '   lang="slo"' + #13#10);
  AddExample(
    '//@lang',
    'Select all languages, oversimplified (can return wrong result if there is lang attrib in other nodes)',
    '0:' + #13#10 +
    '   lang="eng"' + #13#10 +
    '1:' + #13#10 +
    '   lang="eng"' + #13#10 +
    '2:' + #13#10 +
    '   lang="slo"' + #13#10);
  AddExample(
    '//book//@lang',
    'Select all languages, weird way',
    '0:' + #13#10 +
    '   lang="eng"' + #13#10 +
    '1:' + #13#10 +
    '   lang="eng"' + #13#10 +
    '2:' + #13#10 +
    '   lang="slo"' + #13#10);
  AddExample(
    '//book/@lang',
    'Select all languages (mistyped, no @lang in book nodes, no results',
    '');
  AddExample(
    '/bookstore/book[2] + title',
    'Select the second book in bookstore, then get its name via relative query',
    '0:' + #13#10 +
    '  <title lang="eng">Learning XML</title>' + #13#10);
  AddExample(
    '/bookstore/book[2] + ./title',
    'Select the second book in bookstore, then get its name via relative query (alternate way)',
    '0:' + #13#10 +
    '  <title lang="eng">Learning XML</title>' + #13#10);
end; { TfrmXPathDemo.PrepareExamples }

end.
