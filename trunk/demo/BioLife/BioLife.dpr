(*:OmniXML BioLife demo. Demonstrates how to move data between TDataset and XML
   document.
   @author Primoz Gabrijelcic
   @desc <pre>
   (c) 2003 Primoz Gabrijelcic
   Free for personal and commercial use. No rights reserved.

   Author            : Primoz Gabrijelcic
   Creation date     : 2001-10-24
   Last modification : 2003-03-30
   Version           : 1.01
</pre>*)(*
   History:
     1.01: 2003-03-31
       - Updated to export indented XML document.
       - Added memo and image viewer.
     1.0: 2001-10-24
       - Created.
*)

program BioLife;

uses
  Forms,
  blMain in 'blMain.pas' {frmBioLife},
  OmniXMLUtils in '..\..\OmniXMLUtils.pas',
  OmniXMLDatabase in '..\..\OmniXMLDatabase.pas',
  OmniXML in '..\..\OmniXML.pas',
  OmniXML_LookupTables in '..\..\OmniXML_LookupTables.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmBioLife, frmBioLife);
  Application.Run;
end.
