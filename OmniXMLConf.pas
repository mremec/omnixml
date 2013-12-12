(*******************************************************************************
* The contents of this file are subject to the Mozilla Public License Version  *
* 1.1 (the "License"); you may not use this file except in compliance with the *
* License. You may obtain a copy of the License at http://www.mozilla.org/MPL/ *
*                                                                              *
* Software distributed under the License is distributed on an "AS IS" basis,   *
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for *
* the specific language governing rights and limitations under the License.    *
*                                                                              *
* The Original Code is OmniXMLConf.pas                                         *
*                                                                              *
* The Initial Developer of the Original Code is Miha Vrhovnik                  *
*   http://simail.sourceforge.net/, http://xcollect.sourceforge.net            *
*                                                                              *
* Last changed: 2004-04-10                                                     *
*                                                                              *
* History:                                                                     *
*     1.0.7: 2007-02-08                                                        *
*       - check if root node of xml indeed is a config file                    *
*           if it's not then recreate it with conf as default root element     *
*     1.0.6: 2006-12-10                                                        *
*       - config file now opens xml via stream and holds file open this        *
*          puts a lot less stress on computers with slower processors and it   *
*          also gets rid of EFCreateError... file already used by another      *
*          process if those computers are using antivirus software             *
*     1.0.5: 2005-05-12                                                        *
*       - rewritten class constructor and thus fixed possiblity                *
*           of getting exception because  FxmlRoot = nil                       *
*     1.0.4: 2004-05-28                                                        *
*       - added function Read / Write WideString                               *
*     1.0.3: 2004-04-10                                                        *
*       - added property SaveAfterChange if this property is True,             *
*          then document is saved after each change                            *
*       - procedure SaveConfig is now public so you can force document change  *
*     1.0.2: 2003-12-14                                                        *
*       - document can be marked as read only (no changes are saved)           *
*     1.0.1: 2003-11-01                                                        *
*       - fixed bug in  WriteIdentNode                                         *
*     1.0.0: 2003-10-25                                                        *
*       - initial version                                                      *
*                                                                              *
* Contributor(s):                                                              *
* op: Ondrej Pokorny                                                           *
*******************************************************************************)

unit OmniXMLConf;

interface

{$I OmniXML.inc}

{$IFDEF OmniXML_HasZeroBasedStrings}
  {$ZEROBASEDSTRINGS OFF}
{$ENDIF}

uses SysUtils, Classes, OmniXML, OmniXMLUtils, Controls, Forms
  {$IFDEF TNT_UNICODE}, TntSysUtils, TntClasses{$ENDIF};

//you may use this class as replacement for TIniFile
type TxmlConf=class
  private
    FFileName: WideString;
    {$IFDEF TNT_UNICODE}
    FFileStream: TTntFileStream;
    {$ELSE}
    FFileStream: TFileStream;
    {$ENDIF}
    FxmlDoc: IXMLDocument;
    FxmlRoot: IXMLElement;
    FSaveAfterChange: Boolean;
    FReadOnly: Boolean;
    dirty, shutdown: Boolean;
    procedure WriteIdentNode(Section: WideString; Ident: WideString; Value: WideString);
  public
    constructor Create(FileName: WideString);
    destructor Destroy; override;

    function ReadInteger(Section: WideString; Ident: WideString; Default: Int64): Int64;
    function ReadString(Section: WideString; Ident: WideString; Default: String): String;
    function ReadWideString(Section: WideString; Ident: WideString; Default: WideString): WideString;
    function ReadBool(Section: WideString; Ident: WideString; Default: Boolean): Boolean;
    function ReadFloat(Section: WideString; Ident: WideString; Default: Extended): Extended;
    function ReadDate(Section: WideString; Ident: WideString; Default: TDateTime): TDateTime;
    function ReadTime(Section: WideString; Ident: WideString; Default: TDateTime): TDateTime;
    function ReadDateTime(Section: WideString; Ident: WideString; Default: TDateTime): TDateTime;
    procedure ReadControlSettings(Control: TControl; ctlName: WideString = '');

    procedure WriteInteger(Section: WideString; Ident: WideString; Value: Int64);
    procedure WriteString(Section: WideString; Ident: WideString; Value: WideString);
    procedure WriteWideString(Section: WideString; Ident: WideString; Value: WideString);
    procedure WriteBool(Section: WideString; Ident: WideString; Value: Boolean);
    procedure WriteFloat(Section: WideString; Ident: WideString; Value: Extended);
    procedure WriteDate(Section: WideString; Ident: WideString; Value: TDateTime);
    procedure WriteTime(Section: WideString; Ident: WideString; Value: TDateTime);
    procedure WriteDateTime(Section: WideString; Ident: WideString; Value: TDateTime);

    procedure WriteControlSettings(Control: TControl; ctlName: WideString = '');
    procedure SaveConfig;
  public
    property DocReadOnly: Boolean read FReadOnly write FReadOnly;
    property SaveAfterChange: Boolean read FSaveAfterChange write FSaveAfterChange;
end;

implementation

{ TxmlConf }

constructor TxmlConf.Create(FileName: WideString);
begin
  FSaveAfterChange := True;
  FReadOnly := False;

  FFileName := FileName;
  FxmlDoc := CreateXMLDoc;
  FxmlDoc.PreserveWhiteSpace := False;
  FxmlRoot := nil;

  //read file if exists
  {$IFDEF TNT_UNICODE}
  if WideFileExists(FFileName) then begin
    FFileStream := TTntFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);
  {$ELSE}
  if FileExists(FFileName) then begin
    FFileStream := TFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);
  {$ENDIF}
    FxmlDoc.LoadFromStream(FFileStream);
    FxmlRoot := FxmlDoc.DocumentElement;
  end
  else begin
    {$IFDEF TNT_UNICODE}
    FFileStream := TTntFileStream.Create(FileName, fmOpenReadWrite or fmCreate or fmShareDenyWrite);
    {$ELSE}
    FFileStream := TFileStream.Create(FileName, fmOpenReadWrite or fmCreate or fmShareDenyWrite);
    {$ENDIF}
  end;

  if (FxmlDoc <> nil) and (FxmlRoot <> nil) then begin
    if FxmlDoc.DocumentElement.TagName <> 'conf' then begin
      FxmlDoc := CreateXMLDoc;
      FxmlDoc.PreserveWhiteSpace := False;
      FxmlRoot := nil;
    end;
  end;

  if FxmlRoot = nil then begin
    FxmlDoc.AppendChild(FxmlDoc.CreateProcessingInstruction('xml', 'version="1.0" encoding="utf-8"'));
    FxmlRoot := FxmlDoc.CreateElement('conf');
    FxmlDoc.DocumentElement := FxmlRoot;
    SaveConfig;
  end;
end;

destructor TxmlConf.Destroy;
begin
  shutdown := True;
  SaveConfig; //Save settings before exit
  shutdown := False;
  FreeAndNil(FFileStream);
  FxmlRoot := nil;
  FxmlDoc := nil;
end;

function TxmlConf.ReadBool(Section, Ident: WideString; Default: Boolean): Boolean;
var dataNode: IXMLNode;
begin
  //set return value to default one
  Result := Default;

  //1st find section node
  dataNode := FxmlRoot.SelectSingleNode(Section + '/' + Ident);
  if dataNode <> nil then begin
    if Length(dataNode.Text) = 1 then
      XMLStrToBool(dataNode.Text, Result)
    else //this is solely for backward compatibility purposes
      Result := (dataNode.Text[1] = 'T')
  end;

end;

procedure TxmlConf.ReadControlSettings(Control: TControl; ctlName: WideString = '');
var t,l: Integer;
begin
  if ctlName = '' then
    ctlName := Control.Name;

  if Control is TForm then begin
    //damn this throws an exception
    //(Control as TForm).Position := poDesigned;

    //set form width & height only if form is sizeable
    if (Control as TForm).BorderStyle = bsSizeable then begin
      Control.Width := ReadInteger(ctlName, 'width', Control.Width);
      Control.Height := ReadInteger(ctlName, 'height', Control.Height);
    end;

    t := (Screen.Height div 2) - (Control.Height div 2);
    l := (Screen.Width div 2) - (Control.Width div 2);

    Control.Top := ReadInteger(ctlName, 'top', t);
    Control.Left := ReadInteger(ctlName, 'left', l);
  end
  else begin
    Control.Width := ReadInteger(ctlName, 'width', Control.Width);
    Control.Height := ReadInteger(ctlName, 'height', Control.Height);
    Control.Top := ReadInteger(ctlName, 'top', Control.Top);
    Control.Left := ReadInteger(ctlName, 'left', Control.Left);
  end;

end;

function TxmlConf.ReadDate(Section, Ident: WideString; Default: TDateTime): TDateTime;
var dataNode: IXMLNode;
begin
  //set return value to default one
  Result := Default;

  //1st find section node
  dataNode := FxmlRoot.SelectSingleNode(Section + '/' + Ident);
  if dataNode <> nil then begin
    XMLStrToDate(dataNode.Text, Result)
  end;
end;

function TxmlConf.ReadDateTime(Section, Ident: WideString; Default: TDateTime): TDateTime;
var dataNode: IXMLNode;
begin
  //set return value to default one
  Result := Default;

  //1st find section node
  dataNode := FxmlRoot.SelectSingleNode(Section + '/' + Ident);
  if dataNode <> nil then begin
    XMLStrToDateTime(dataNode.Text, Result)
  end;
end;

function TxmlConf.ReadFloat(Section, Ident: WideString; Default: Extended): Extended;
var dataNode: IXMLNode;
begin
  //set return value to default one
  Result := Default;

  //1st find section node
  dataNode := FxmlRoot.SelectSingleNode(Section + '/' + Ident);
  if dataNode <> nil then begin
    XMLStrToExtended(dataNode.Text, Result)
  end;
end;

function TxmlConf.ReadInteger(Section, Ident: WideString; Default: Int64): Int64;
var dataNode: IXMLNode;
begin
  //set return value to default one
  Result := Default;

  //1st find section node
  dataNode := FxmlRoot.SelectSingleNode(Section + '/' + Ident);
  if dataNode <> nil then begin
    XMLStrToInt64(dataNode.Text, Result)
  end;
end;

function TxmlConf.ReadString(Section, Ident: WideString; Default: String): String;
var dataNode: IXMLNode;
begin

  //1st find section node
  dataNode := FxmlRoot.SelectSingleNode(Section + '/' + Ident);
  if dataNode <> nil then begin
    Result := dataNode.Text
  end
  //return default value
  else Result := Default;

end;

function TxmlConf.ReadWideString(Section, Ident:WideString; Default: WideString): WideString;
var dataNode: IXMLNode;
begin

  //1st find section node
  dataNode := FxmlRoot.SelectSingleNode(Section + '/' + Ident);
  if dataNode <> nil then begin
    Result := dataNode.Text
  end
  //return default value
  else Result := Default;

end;

function TxmlConf.ReadTime(Section, Ident: WideString; Default: TDateTime): TDateTime;
var dataNode: IXMLNode;
begin

  //1st find section node
  dataNode := FxmlRoot.SelectSingleNode(Section + '/' + Ident);
  if dataNode <> nil then begin
    XMLStrToTime(dataNode.Text, Result)
  end
  //return default value
  else Result := Default;

end;

procedure TxmlConf.SaveConfig;
begin
  if FFileName = '' then Exit;
  if FReadOnly then Exit;
  if FFileStream = nil then Exit;

  if dirty or shutdown then
  begin
    FFileStream.Size := 0;//op: clear file stream before saving!!!
    FxmlDoc.SaveToStream(FFileStream, ofIndent);
  end;
end;

procedure TxmlConf.WriteBool(Section, Ident: WideString; Value: Boolean);
begin
  WriteIdentNode(Section, Ident, XMLBoolToStr(Value));
end;

procedure TxmlConf.WriteControlSettings(Control: TControl; ctlName: WideString = '');
begin
  if ctlName = '' then
    ctlName := Control.Name;

  WriteInteger(ctlName, 'width', Control.Width);
  WriteInteger(ctlName, 'height', Control.Height);
  WriteInteger(ctlName, 'top', Control.Top);
  WriteInteger(ctlName, 'left', Control.Left);
  if FSaveAfterChange then
    SaveConfig;
end;

procedure TxmlConf.WriteDate(Section, Ident: WideString; Value: TDateTime);
begin
  WriteIdentNode(Section, Ident, XMLDateToStr(Value));
end;

procedure TxmlConf.WriteDateTime(Section, Ident: WideString; Value: TDateTime);
begin
  WriteIdentNode(Section, Ident, XMLDateTimeToStr(Value));
end;

procedure TxmlConf.WriteFloat(Section, Ident: WideString; Value: Extended);
begin
  WriteIdentNode(Section, Ident, XMLExtendedToStr(Value));
end;

procedure TxmlConf.WriteIdentNode(Section, Ident: WideString; Value: WideString);
var sectNode, identNode: IXMLNode;
begin
  dirty := True;
  sectNode := nil;
  identNode := nil;

  //1st find section node
  sectNode := FindNode(FxmlRoot, Section, '');
  if sectNode <> nil then begin
    //section node exists
    //now find ident node
    identNode := FindNode(sectNode, Ident, '');
    //if does not exists then create it
    if identNode = nil then
      identNode := EnsureNode(sectNode, Ident);
  end
  //create both nodes
  else begin
    sectNode := EnsureNode(FxmlRoot, Section);
    identNode := EnsureNode(sectNode, Ident);
  end;

  identNode.Text := Value;

  if FSaveAfterChange then
    SaveConfig;
end;

procedure TxmlConf.WriteInteger(Section, Ident: WideString; Value: Int64);
begin
  WriteIdentNode(Section, Ident, XMLInt64ToStr(Value));
end;

procedure TxmlConf.WriteString(Section, Ident, Value: WideString);
begin
  WriteIdentNode(Section, Ident, Value);
end;

procedure TxmlConf.WriteWideString(Section, Ident: WideString; Value: WideString);
begin
  WriteIdentNode(Section, Ident, Value);
end;

procedure TxmlConf.WriteTime(Section, Ident: WideString; Value: TDateTime);
begin
  WriteIdentNode(Section, Ident, XMLTimeToStr(Value));
end;

end.
