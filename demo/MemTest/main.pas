unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls,
  OmniXML, ActnList
{$IFDEF USE_MSXML}
  , OmniXML_MSXML
{$ENDIF}
  ;

type
  TfMain = class(TForm)
    Label8: TLabel;
    Bevel3: TBevel;
    bCreateXMLDoc: TButton;
    bFreeXMLDoc: TButton;
    bCreateAndFree: TButton;
    bCreateElement: TButton;
    bAppendChild: TButton;
    bFreeElement: TButton;
    bCreateAttr: TButton;
    bSetAttr: TButton;
    bSimpleCycle: TButton;
    bLoadAndSelectNodes: TButton;
    ActionList1: TActionList;
    actCreateElement: TAction;
    actAppendChild: TAction;
    actCreateAttribute: TAction;
    actSetAttribute: TAction;
    actFreeElement: TAction;
    actCreateXMLDoc: TAction;
    actFreeXMLDoc: TAction;
    procedure bCreateAndFreeClick(Sender: TObject);
    procedure bSimpleCycleClick(Sender: TObject);
    procedure bLoadAndSelectNodesClick(Sender: TObject);
    procedure actCreateElementExecute(Sender: TObject);
    procedure actCreateElementUpdate(Sender: TObject);
    procedure actAppendChildExecute(Sender: TObject);
    procedure actAppendChildUpdate(Sender: TObject);
    procedure actCreateAttributeExecute(Sender: TObject);
    procedure actCreateAttributeUpdate(Sender: TObject);
    procedure actSetAttributeExecute(Sender: TObject);
    procedure actSetAttributeUpdate(Sender: TObject);
    procedure actFreeElementExecute(Sender: TObject);
    procedure actCreateXMLDocExecute(Sender: TObject);
    procedure actFreeXMLDocExecute(Sender: TObject);
    procedure actFreeXMLDocUpdate(Sender: TObject);
    procedure actFreeElementUpdate(Sender: TObject);
  private
    XMLDoc: IXMLDocument;
    Element: IXMLElement;
    Attr: IXMLAttr;
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}

procedure TfMain.bCreateAndFreeClick(Sender: TObject);
begin
  XMLDoc := CreateXMLDoc;
  XMLDoc := nil;
end;

procedure TfMain.bSimpleCycleClick(Sender: TObject);
var
  XMLDoc: IXMLDocument;
  Root: IXMLElement;
  Element: IXMLElement;
begin
  XMLDoc := CreateXMLDoc;
  Root := XMLDoc.CreateElement('RootElement');
  XMLDoc.DocumentElement := Root;
  Element := XMLDoc.CreateElement('SubElement');
  Root.AppendChild(Element);
  Root := nil;
end;

procedure TfMain.bLoadAndSelectNodesClick(Sender: TObject);
var
  XMLDoc: IXMLDocument;
  NodeList: IXMLNodeList;
begin
  XMLDoc := CreateXMLDoc;
  XMLDoc.Load(ExpandFileName(ExtractFilePath(Application.ExeName) + '..\doc\animals.xml'));
  NodeList := XMLDoc.DocumentElement.SelectNodes('DATA1/FISH');
  ShowMessageFmt('(1) %d nodes', [NodeList.Length]);
  NodeList := nil;
  NodeList := XMLDoc.DocumentElement.SelectNodes('DATA1/FISH');
  ShowMessageFmt('(2) %d nodes', [NodeList.Length]);
  XMLDoc := nil;
end;

procedure TfMain.actCreateElementExecute(Sender: TObject);
begin
  Element := XMLDoc.CreateElement('ROOT');
end;

procedure TfMain.actCreateElementUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := XMLDoc <> nil;
end;

procedure TfMain.actAppendChildExecute(Sender: TObject);
begin
  XMLDoc.AppendChild(Element);
end;

procedure TfMain.actAppendChildUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (XMLDoc <> nil) and (Element <> nil);
end;

procedure TfMain.actCreateAttributeExecute(Sender: TObject);
begin
  Attr := XMLDoc.CreateAttribute('AttrName');
  Attr.Value := 'AttrValue';
end;

procedure TfMain.actCreateAttributeUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := XMLDoc <> nil;
end;

procedure TfMain.actSetAttributeExecute(Sender: TObject);
begin
  Element.SetAttribute('AttrName', 'AttrValue');
end;

procedure TfMain.actSetAttributeUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Element <> nil;
end;

procedure TfMain.actFreeElementExecute(Sender: TObject);
begin
  Element := nil;
end;

procedure TfMain.actFreeElementUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Element <> nil;
end;

procedure TfMain.actCreateXMLDocExecute(Sender: TObject);
begin
  XMLDoc := CreateXMLDoc;
end;

procedure TfMain.actFreeXMLDocExecute(Sender: TObject);
begin
  XMLDoc := nil;
end;

procedure TfMain.actFreeXMLDocUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := XMLDoc <> nil;
end;

end.

