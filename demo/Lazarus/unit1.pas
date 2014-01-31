unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  OmniXML;

type

  { TForm1 }

  TForm1 = class(TForm)
    BtnBasicTest: TBitBtn;
    procedure BtnBasicTestClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.BtnBasicTestClick(Sender: TObject);
var
  xXML: IXMLDocument;
begin
  xXML := CreateXMLDoc;
  xXML.DocumentElement := xXML.CreateElement('root');

  ShowMessage(xXML.XML);
end;

end.

