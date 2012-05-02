unit rrMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    btnSelectRSS: TButton;
    inpRSS      : TEdit;
    lbLog       : TListBox;
    lblRSS      : TLabel;
    OpenDialog1 : TOpenDialog;
    procedure btnSelectRSSClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure Log(const msg: string); overload;
    procedure Log(const msg: string; params: array of const); overload;
    procedure ParseRSS(const rssName: string);
    procedure WMUser(var msg: TMessage); message WM_USER;
  public
  end;

var
  Form1: TForm1;

implementation

uses
  rrRSS;

{$R *.DFM}

procedure TForm1.btnSelectRSSClick(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    inpRSS.Text := OpenDialog1.FileName;
    ParseRSS(inpRSS.Text);
  end;
end; { TForm1.btnSelectRSSClick }

procedure TForm1.Log(const msg: string);
begin
  lbLog.ItemIndex := lbLog.Items.Add(msg);
end; { TForm1.Log }

procedure TForm1.FormCreate(Sender: TObject);
begin
  OpenDialog1.InitialDir := ExtractFilePath(ParamStr(0));
  PostMessage(Handle, WM_USER, 0, 0);
end; { TForm1.FormCreate }

procedure TForm1.Log(const msg: string; params: array of const);
begin
  Log(Format(msg, params));
end; { TForm1.Log }

procedure TForm1.ParseRSS(const rssName: string);
var
  iChannel: integer;
  iItem   : integer;
  rss     : TRSS;
begin
  lbLog.Items.Clear;
  rss := TRSS.Create;
  try
     if not rss.LoadFromFile(inpRSS.Text) then
      Log('Load failed. %s', [rss.LastError])
    else begin
      Log('Version: %s', [rss.Version]);
      for iChannel := 0 to rss.Count-1 do begin
        Log('--channel');
        Log('  Title: %s', [rss[iChannel].Title]);
        Log('  Link: %s', [rss[iChannel].Link]);
        Log('  Description: %s', [rss[iChannel].Description]);
        Log('  Language: %s', [rss[iChannel].Language]);
        Log('  --image');
        Log('    Title: %s', [rss[iChannel].Image.Title]);
        Log('    URL: %s', [rss[iChannel].Image.URL]);
        Log('    Link: %s', [rss[iChannel].Image.Link]);
        Log('    Width: %d', [rss[iChannel].Image.Width]);
        Log('    Height: %d', [rss[iChannel].Image.Height]);
        Log('    Description: %s', [rss[iChannel].Image.Description]);
        for iItem := 0 to rss[iChannel].Items.Count-1 do begin
          with rss[iChannel].Items[iItem] do begin
            Log('  --item');
            Log('    Title: %s', [Title]);
            Log('    Link: %s', [Link]);
            Log('    Description: %s', [Description]);
          end; //with
        end; //for
      end; //for
    end;
  finally FreeAndNil(rss); end;
end; { TForm1.ParseRSS }

procedure TForm1.WMUser(var msg: TMessage);
begin
  ParseRSS(inpRSS.Text);
end; { TForm1.WMUser }

end.
