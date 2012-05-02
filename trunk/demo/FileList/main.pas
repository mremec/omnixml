unit main;

interface

// if you want to use MS XML parser, create a global compiler define: 'USE_MSXML'

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl, ComCtrls, ExtCtrls,
  OmniXML,
{$IFDEF USE_MSXML}
  OmniXML_MSXML,
{$ENDIF}
  OmniXMLUtils;

type
  TfMain = class(TForm)
    Label2: TLabel;
    eFileName: TEdit;
    Label10: TLabel;
    Label1: TLabel;
    cobDrive: TDriveComboBox;
    cobCodePage: TComboBox;
    Label9: TLabel;
    bDriveSave: TButton;
    Bevel1: TBevel;
    bDriveLoad: TButton;
    tvDrive: TTreeView;
    Label11: TLabel;
    Bevel2: TBevel;
    Label3: TLabel;
    mDescription: TMemo;
    rgOutputFormat: TRadioGroup;
    chbPreserveWhiteSpace: TCheckBox;
    procedure bDriveSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bDriveLoadClick(Sender: TObject);
    procedure cobDriveChange(Sender: TObject);
  private
    DocPath: string;
    XMLDoc: IXMLDocument;
    RootElement: IXMLElement;
    procedure Start(const Dir: string; const Element: IXMLElement);
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

{$R *.DFM}

procedure XML2TreeView(const XMLDoc: IXMLDocument; const TreeView: TTreeView);
var
  RootNode: TTreeNode;

  procedure AddNode(const Parent: TTreeNode; const Node: IXMLNode);
  var
    i: Integer;
    SubNode: IXMLNode;
    TreeNode: TTreeNode;
    NodeName: string;
  begin
    for i := 0 to Node.ChildNodes.Length - 1 do begin
      SubNode := Node.ChildNodes.Item[i];
      NodeName := SubNode.NodeName;

      if NodeName = 'dir' then
        NodeName := SubNode.Attributes.GetNamedItem('name').NodeValue;
      if NodeName = 'file' then
        NodeName := SubNode.Attributes.GetNamedItem('name').NodeValue;

      TreeNode := TreeView.Items.AddChild(Parent, NodeName);
      AddNode(TreeNode, SubNode);
    end;
  end;
begin
  TreeView.Items.BeginUpdate;
  try
    TreeView.Items.Clear;
    if XMLDoc.DocumentElement <> nil then begin
      RootNode := TreeView.Items.Add(nil,
        Format('DRIVE %s', [XMLDoc.DocumentElement.GetAttribute('name')]));
      AddNode(RootNode, XMLDoc.DocumentElement);
      RootNode.Expand(False);
    end;
  finally
    TreeView.Items.EndUpdate;
  end;
end;

procedure TfMain.FormCreate(Sender: TObject);
{$IFNDEF USE_MSXML}
var
  i: Integer;
{$ENDIF}
begin
  DocPath := ExtractFilePath(ExpandFileName(ExtractFilePath(Application.ExeName) + '..\doc\dummy.xml'));

  cobDrive.Drive := ' ';
  cobDrive.Drive := ExtractFileDrive(Application.ExeName)[1];

  cobCodePage.Items.AddObject('<none (UTF-8)>', nil);
{$IFNDEF USE_MSXML}
  for i := Low(TCodePages) to High(TCodePages) do
    cobCodePage.Items.AddObject(CodePages[i].Alias, TObject(CodePages[i].CodePage));
{$ENDIF}
  cobCodePage.ItemIndex := 0;
end;

procedure TfMain.bDriveSaveClick(Sender: TObject);
var
  PI: IXMLProcessingInstruction;
begin
  Screen.Cursor := crHourGlass;
  try
    XMLDoc := CreateXMLDoc;
    try
      if cobCodePage.ItemIndex <> 0 then
        PI := XMLDoc.CreateProcessingInstruction('xml',
          Format('version="1.0" encoding="%s"', [cobCodePage.Items[cobCodePage.ItemIndex]]))
      else
        PI := nil;

      // create root element
      RootElement := XMLDoc.CreateElement('drive');
      // assign it as a root element
      XMLDoc.DocumentElement := RootElement;
      if PI <> nil then
        XMLDoc.InsertBefore(PI, RootElement);

      RootElement.SetAttribute('name', cobDrive.Drive);
      // start recursive scan of selected drive
      Start(cobDrive.Drive + ':', RootElement);
      // save document to file
      ForceDirectories(ExtractFileDir(eFileName.Text));
      XMLSaveToFile(XMLDoc, eFileName.Text, TOutputFormat(rgOutputFormat.ItemIndex));
    finally
      XMLDoc := nil;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfMain.Start(const Dir: string; const Element: IXMLElement);
var
  sr: TSearchRec;
  SingleFile,
  SubDirectory: IXMLElement;
  Attributes: string;
begin
  if FindFirst(Dir + '\*.*', faAnyFile, sr) = 0 then begin
    try
      repeat
        if (sr.Attr and faDirectory) > 0 then begin
          if (sr.Name <> '') and (sr.Name[1] <> '.') then begin
            // sub-directory
            SubDirectory := XMLDoc.CreateElement('dir');
            SubDirectory.SetAttribute('name', sr.Name);
            Element.AppendChild(SubDirectory);
            Start(Dir + '\' + sr.Name, SubDirectory);
          end
        end
        else begin
          SingleFile := XMLDoc.CreateElement('file');
          SingleFile.SetAttribute('name', sr.Name);
          SingleFile.SetAttribute('size', IntToStr(sr.Size));
          Attributes := '';
          if (sr.Attr and faReadOnly) > 0 then
            Attributes := Attributes + 'R';
          if (sr.Attr and faHidden) > 0 then
            Attributes := Attributes + 'H';
          if (sr.Attr and faSysFile) > 0 then
            Attributes := Attributes + 'S';
          if (sr.Attr and faArchive) > 0 then
            Attributes := Attributes + 'A';
          SingleFile.SetAttribute('attr', Attributes);
          Element.AppendChild(SingleFile);
        end;
      until FindNext(sr) <> 0;
    finally
      FindClose(sr);
    end;
  end;
end;

procedure TfMain.bDriveLoadClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    XMLDoc := CreateXMLDoc;
    try
      XMLDoc.PreserveWhiteSpace := chbPreserveWhiteSpace.Checked;
      XMLDoc.Load(eFileName.Text);
      XML2TreeView(XMLDoc, tvDrive);
    finally
      XMLDoc := nil;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfMain.cobDriveChange(Sender: TObject);
begin
  eFileName.Text := Format('%sdrive_%s.xml', [DocPath, cobDrive.Drive]);
end;

end.

