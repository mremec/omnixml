program ErrorInfo;

uses
  Forms,
  main in 'main.pas' {fMain},
  MSXML2_TLB in '..\..\MSXML2_TLB.pas',
  OBufferedStreams in '..\..\OBufferedStreams.pas',
  OEncoding in '..\..\OEncoding.pas',
  OmniXML in '..\..\OmniXML.pas',
  OmniXML_Dictionary in '..\..\OmniXML_Dictionary.pas',
  OmniXML_LookupTables in '..\..\OmniXML_LookupTables.pas',
  OmniXML_MSXML in '..\..\OmniXML_MSXML.pas',
  OmniXML_Types in '..\..\OmniXML_Types.pas',
  OmniXMLConf in '..\..\OmniXMLConf.pas',
  OmniXMLDatabase in '..\..\OmniXMLDatabase.pas',
  OmniXMLPersistent in '..\..\OmniXMLPersistent.pas',
  OmniXMLProperties in '..\..\OmniXMLProperties.pas',
  OmniXMLUtils in '..\..\OmniXMLUtils.pas',
  OmniXMLXPath in '..\..\OmniXMLXPath.pas',
  OTextReadWrite in '..\..\OTextReadWrite.pas',
  OWideSupp in '..\..\OWideSupp.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.

