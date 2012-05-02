program xmlFormatter;

uses
  SysUtils,
  OmniXML;

{$R *.res}

var
  XmlDoc: IXMLDocument;

begin
  if FileExists(ParamStr(1)) then begin
    XmlDoc := CreateXMLDoc;
    XmlDoc.PreserveWhiteSpace := False;
    XmlDoc.Load(ParamStr(1));
    XmlDoc.Save(ParamStr(1), ofIndent);
  end;
end.
