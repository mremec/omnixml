program RSSReader;

uses
  Forms,
  rrMain in 'rrMain.pas' {Form1},
  rrRSS in 'rrRSS.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
