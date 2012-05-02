program XPathDemo;

uses
  Forms,
  XPathDemo1 in 'XPathDemo1.pas' {frmXPathDemo},
  OmniXMLXPath in '..\..\OmniXMLXPath.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmXPathDemo, frmXPathDemo);
  Application.Run;
end.
