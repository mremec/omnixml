unit blMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, kbmMemTable, Grids, DBGrids, StdCtrls, DBCtrls, ExtCtrls;

const
  WM_POSTCREATE = WM_USER;

type
  TfrmBioLife = class(TForm)
    DataSource1          : TDataSource;
    DBGrid1              : TDBGrid;
    DBImage1             : TDBImage;
    DBMemo1              : TDBMemo;
    lbLog                : TListBox;
    memBioLife           : TkbmMemTable;
    memBioLifeCategory   : TStringField;
    memBioLifeCommon_Name: TStringField;
    memBioLifeGraphic    : TGraphicField;
    memBioLifeLength_In  : TFloatField;
    memBioLifeLengthcm   : TFloatField;
    memBioLifeNotes      : TMemoField;
    memBioLifeSpeciesName: TStringField;
    memBioLifeSpeciesNo  : TFloatField;
    Panel1               : TPanel;
    tblBioLife           : TTable;
    procedure FormCreate(Sender: TObject);
  private
    procedure Log(msg: string);
    procedure WMPostCreate(var msg: TMessage); message WM_POSTCREATE;
  public
  end;

var
  frmBioLife: TfrmBioLife;

implementation

uses
  OmniXML,
  OmniXMLUtils,
  OmniXMLDatabase;

{$R *.DFM}

procedure TfrmBioLife.FormCreate(Sender: TObject);
begin
  PostMessage(Handle, WM_POSTCREATE, 0, 0);
end; { TForm1.FormCreate }

procedure TfrmBioLife.Log(msg: string);
begin
  lbLog.ItemIndex := lbLog.Items.Add(msg);
end; { TfrmBioLife.Log }

procedure TfrmBioLife.WMPostCreate(var msg: TMessage);
var
  fstrXML    : TFileStream;
  mstrXML    : TMemoryStream;
  nameBiolife: string;
  time       : DWORD;
  xmlDoc     : IXMLDocument;
begin
  Log('Opening BioLife table');
  tblBioLife.Active := true;
  memBioLife.Active := true;
  mstrXML := TMemoryStream.Create;
  try
    Log('Converting BioLife table into xml document');
    time := GetTickCount;
    DatasetToXMLDocument(tblBioLife, mstrXML, 'Biolife', '', ofIndent);
    time := GetTickCount-time;
    Log(Format('  %d s %d ms', [time div 1000, time mod 1000]));
    nameBiolife := ExtractFilePath(ParamStr(0))+'biolife.xml';
    Log(Format('Saving xml document into file %s', [nameBiolife]));
    fstrXML := TFileStream.Create(nameBiolife, fmCreate);
    try
      fstrXML.CopyFrom(mstrXML,0);
    finally FreeAndNil(fstrXML); end;
    Log('Converting xml document into memory table');
    mstrXML.Position := 0;
    time := GetTickCount;
    (* Simple way: * )
    XMLDocumentToDataset(mstrXML, memBioLife);
    (* Long way: *)
    xmlDoc := CreateXMLDoc;
    if not XMLLoadFromStream(xmlDoc, mstrXML) then
      raise Exception.CreateFmt(
        'Failed to parse XML document. Error occured at character %d line %d. Reason: %s',
        [xmlDoc.ParseError.LinePos, xmlDoc.ParseError.LinePos, xmlDoc.ParseError.Reason]);
    if not assigned(xmlDoc.DocumentElement) then
      raise Exception.Create('XML document is empty');
    Log('Root tag: '+xmlDoc.DocumentElement.NodeName);
    XMLToDataset(xmlDoc.DocumentElement, memBioLife);
    (**)
    time := GetTickCount-time;
    Log(Format('  %d s %d ms', [time div 1000, time mod 1000]));
  finally FreeAndNil(mstrXML); end;
  Log('All done');
end; { TForm1.WMPostCreate }

end.
