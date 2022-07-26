(*******************************************************************************
* The contents of this file are subject to the Mozilla Public License Version  *
* 1.1 (the "License"); you may not use this file except in compliance with the *
* License. You may obtain a copy of the License at http://www.mozilla.org/MPL/ *
*                                                                              *
* Software distributed under the License is distributed on an "AS IS" basis,   *
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for *
* the specific language governing rights and limitations under the License.    *
*                                                                              *
* The Original Code is mr_Storage_XML.pas                                      *
*                                                                              *
* The Initial Developer of the Original Code is Miha Remec,                    *
*   http://www.MihaRemec.com/                                                  *
*                                                                              *
* Contributor(s):                                                              *
*   Miha Vrhovnik, Primoz Gabrijelcic, John                                    *
*******************************************************************************)
unit OmniXMLPersistent;

interface

{$I OmniXML.inc}

{$IFDEF OmniXML_HasZeroBasedStrings}
  {$ZEROBASEDSTRINGS OFF}
{$ENDIF}

// if you want to use MS XML parser, uncomment (in your program!!!)
// the following compiler directive {.$DEFINE USE_MSXML}

uses
  Classes, SysUtils,
{$IFDEF VCL} Controls, {$ENDIF}
  TypInfo,
{$IFDEF HAS_UNIT_VARIANTS} Variants, {$ENDIF}
  OEncoding, OmniXML, OmniXML_Types,
{$IFDEF USE_MSXML} OmniXML_MSXML, {$ENDIF}
  OmniXMLUtils;

type
  TPropsFormat = (pfAuto, pfAttributes, pfNodes);
  EOmniXMLPersistent = class(Exception);

{$IFDEF VisualCLX}
  TTime = type TDateTime;
  TDate = type TDateTime;
{$ENDIF}

type
  TOmniXMLWriter = class
  protected
    Doc: IXMLDocument;
    procedure WriteProperty(Instance: TPersistent; PropInfo: PPropInfo;
      Element: IXMLElement; WriteDefaultValues: Boolean);
    procedure InternalWriteText(Root: IXMLElement; Name, Value: XmlString);
    procedure WriteCollection(Collection: TCollection; Root: IXMLElement);
  public
    PropsFormat: TPropsFormat;
    constructor Create(Doc: IXMLDocument; const PropFormat: TPropsFormat = pfAuto);
    class procedure SaveToFile(const Instance: TPersistent; const FileName: string;
      const PropFormat: TPropsFormat = pfAuto; const OutputFormat: TOutputFormat = ofNone);
    class procedure SaveXML(const Instance: TPersistent; var XML: XmlString;
      const PropFormat: TPropsFormat = pfAuto; const OutputFormat: TOutputFormat = ofNone);
    procedure Write(Instance: TPersistent; Root: IXMLElement;
      const WriteRoot: Boolean = True; const CheckIfEmpty: Boolean = True;
      const WriteDefaultValues: Boolean = False);
  end;

  TOmniXMLReader = class
  protected
    function FindElement(const Root: IXMLElement; const TagName: XmlString): IXMLElement;
    procedure ReadProperty(Instance: TPersistent; PropInfo: Pointer; Element: IXMLElement);
    function InternalReadText(Root: IXMLElement; Name: XmlString; var Value: XmlString): Boolean;
    procedure ReadCollection(Collection: TCollection; Root: IXMLElement);
  public
    PropsFormat: TPropsFormat;
    constructor Create(const PropFormat: TPropsFormat = pfAuto);
    class procedure LoadFromFile(Instance: TPersistent; FileName: string); overload;
    class procedure LoadFromFile(Collection: TCollection; FileName: string); overload;
    class procedure LoadXML(Instance: TPersistent; const XML: XmlString); overload;
    procedure Read(Instance: TPersistent; Root: IXMLElement; const ReadRoot: Boolean = False);
  end;

var
  DefaultPropFormat: TPropsFormat = pfNodes;

implementation

{$IFDEF UNICODE}
const
  CP_ACP = 0;  // default to ANSI code page
  CP_RawByteString = $FFFF;  // codepage of RawByteString string type
{$ENDIF}  // UNICODE

const
  COLLECTIONITEM_NODENAME = 'o';  // do not change!
  PROP_FORMAT = 'PropFormat';  // do not change!
  StringS_COUNT_NODENAME = 'Count';  // do not change!
  StringS_PREFIX = 'l';  // do not change!

var
  PropFormatValues: array[TPropsFormat] of string = ('auto', 'attr', 'node');

function IsElementEmpty(Element: IXMLElement; PropsFormat: TPropsFormat): Boolean;
begin
  Result := ((PropsFormat = pfAttributes) and (Element.Attributes.Length = 0)) or
    ((PropsFormat = pfNodes) and (Element.ChildNodes.Length = 0));
end;

procedure CreateDocument(var XMLDoc: IXMLDocument; var Root: IXMLElement;
  RootNodeName: XmlString);
begin
  XMLDoc := CreateXMLDoc;
  XMLDoc.AppendChild(XMLDoc.CreateProcessingInstruction('xml', 'version="1.0" encoding="utf-8"'));
  Root := XMLDoc.CreateElement(RootNodeName);
  XMLDoc.DocumentElement := Root;
end;

procedure Load(var XMLDoc: IXMLDocument; var XMLRoot: IXMLElement;
  var PropsFormat: TPropsFormat);
var
  i: TPropsFormat;
  PropFormatValue: XmlString;
begin
  // set root element
  XMLRoot := XMLDoc.documentElement;
  PropsFormat := pfNodes;

  if XMLRoot = nil then
    Exit;

  PropFormatValue := XMLRoot.GetAttribute(PROP_FORMAT);

  for i := Low(TPropsFormat) to High(TPropsFormat) do begin
    if SameText(PropFormatValue, PropFormatValues[i]) then begin
      PropsFormat := i;
      Break;
    end;
  end;
end;

procedure LoadDocument(const FileName: string; var XMLDoc: IXMLDocument;
  var XMLRoot: IXMLElement; var PropsFormat: TPropsFormat);
begin
  XMLDoc := CreateXMLDoc;
  { TODO : implement and test preserveWhiteSpace }
  XMLDoc.preserveWhiteSpace := True;
  XMLDoc.Load(FileName);

  Load(XMLDoc, XMLRoot, PropsFormat);
end;

{ TOmniXMLWriter }

class procedure TOmniXMLWriter.SaveToFile(const Instance: TPersistent;
  const FileName: string; const PropFormat: TPropsFormat = pfAuto;
  const OutputFormat: TOutputFormat = ofNone);
var
  XMLDoc: IXMLDocument;
  Root: IXMLElement;
  Writer: TOmniXMLWriter;
begin
  if Instance is TCollection then
    CreateDocument(XMLDoc, Root, Instance.ClassName)
  else
    CreateDocument(XMLDoc, Root, 'data');

  Writer := TOmniXMLWriter.Create(XMLDoc, PropFormat);
  try
    if Instance is TCollection then
      Writer.WriteCollection(TCollection(Instance), Root)
    else
      Writer.Write(Instance, Root);
  finally
    Writer.Free;
  end;

{$IFNDEF USE_MSXML}
  XMLDoc.Save(FileName, OutputFormat);
{$ELSE}
  XMLDoc.Save(FileName);
{$ENDIF}
end;

class procedure TOmniXMLWriter.SaveXML(const Instance: TPersistent; var XML: XmlString;
  const PropFormat: TPropsFormat; const OutputFormat: TOutputFormat);
var
  XMLDoc: IXMLDocument;
  Root: IXMLElement;
  Writer: TOmniXMLWriter;
begin
  if Instance is TCollection then
    CreateDocument(XMLDoc, Root, Instance.ClassName)
  else
    CreateDocument(XMLDoc, Root, 'data');

  Writer := TOmniXMLWriter.Create(XMLDoc, PropFormat);
  try
    if Instance is TCollection then
      Writer.WriteCollection(TCollection(Instance), Root)
    else
      Writer.Write(Instance, Root);
  finally
    Writer.Free;
  end;

  XML := XMLDoc.XML;
end;

constructor TOmniXMLWriter.Create(Doc: IXMLDocument; const PropFormat: TPropsFormat = pfAuto);
begin
  Self.Doc := Doc;
  if PropFormat <> pfAuto then
    PropsFormat := PropFormat
  else
    PropsFormat := DefaultPropFormat;
  Doc.DocumentElement.SetAttribute(PROP_FORMAT, PropFormatValues[PropsFormat]);
end;

procedure TOmniXMLWriter.InternalWriteText(Root: IXMLElement; Name, Value: XmlString);
var
  PropNode: IXMLElement;
begin
  case PropsFormat of
    pfAttributes: Root.SetAttribute(Name, Value);
    pfNodes:
      begin
        PropNode := Doc.CreateElement(Name);
        PropNode.Text := Value;
        Root.appendChild(PropNode);
      end;
  end;
end;

procedure TOmniXMLWriter.WriteCollection(Collection: TCollection; Root: IXMLElement);
var
  i: Integer;
begin
  for i := 0 to Collection.Count - 1 do
    Write(Collection.Items[i], Root, True, False);
end;

procedure TOmniXMLWriter.WriteProperty(Instance: TPersistent; PropInfo: PPropInfo;
  Element: IXMLElement; WriteDefaultValues: Boolean);
var
  PropType: PTypeInfo;

  procedure WriteStrProp;
  var
    Value: XmlString;
  begin
    if PropType^.Kind = tkWString then
      Value := GetWideStrProp(Instance, PropInfo)
    else
      Value := GetStrProp(Instance, PropInfo);

    if (Value <> EmptyStr) or (WriteDefaultValues) then
      InternalWriteText(Element, XmlString(PPropInfo(PropInfo)^.Name), Value);
  end;

  procedure WriteOrdProp;
  var
    Value: Longint;
  begin
    Value := GetOrdProp(Instance, PropInfo);
    if (WriteDefaultValues) or (Value <> PPropInfo(PropInfo)^.Default) then begin
      case PropType^.Kind of
        tkInteger: InternalWriteText(Element, XmlString(PPropInfo(PropInfo)^.Name), XMLIntToStr(Value));
        tkChar:
          begin
            {$IFDEF UNICODE}
            InternalWriteText(Element, XmlString(PPropInfo(PropInfo)^.Name), Char(Value));
            {$ELSE}
            InternalWriteText(Element, XmlString(PPropInfo(PropInfo)^.Name), UTF8Decode(AnsiToUtf8(Char(Value))));
            {$ENDIF}  // UNICODE
          end;
        tkWChar: InternalWriteText(Element, XmlString(PPropInfo(PropInfo)^.Name), WideChar(Value));
        tkSet: InternalWriteText(Element, XmlString(PPropInfo(PropInfo)^.Name),
          GetSetProp(Instance, PPropInfo(PropInfo), True));
        tkEnumeration:
          begin
            if PropType = System.TypeInfo(Boolean) then
              InternalWriteText(Element, XmlString(PPropInfo(PropInfo)^.Name), XMLBoolToStr(Boolean(Value)))
            else if PropType^.Kind = tkInteger then
              InternalWriteText(Element, XmlString(PPropInfo(PropInfo)^.Name), XMLIntToStr(Value))
            // 2003-05-27 (mr): added tkEnumeration processing
            else if PropType^.Kind = tkEnumeration then
              InternalWriteText(Element, XmlString(PPropInfo(PropInfo)^.Name), GetEnumName(PropType, Value));
          end;
      end;
    end;
  end;

  procedure WriteFloatProp;
  var
    Value: Real;
  begin
    Value := GetFloatProp(Instance, PropInfo);
    if (Value <> 0) or (WriteDefaultValues) then
      InternalWriteText(Element, XmlString(PPropInfo(PropInfo)^.Name), XMLRealToStr(Value));
  end;

  procedure WriteDateTimeProp;
  var
    Value: TDateTime;
  begin
    Value := VarAsType(GetFloatProp(Instance, PropInfo), varDate);
    if (Value <> 0) or (WriteDefaultValues) then
      InternalWriteText(Element, XmlString(PPropInfo(PropInfo)^.Name), XMLDateTimeToStrEx(Value));
  end;

  procedure WriteInt64Prop;
  var
    Value: Int64;
  begin
    Value := GetInt64Prop(Instance, PropInfo);
    if (Value <> 0) or (WriteDefaultValues) then
      InternalWriteText(Element, XmlString(PPropInfo(PropInfo)^.Name), XMLInt64ToStr(Value));
  end;

  procedure WriteObjectProp;
  var
    Value: TObject;
    PropNode: IXMLElement;

    procedure WriteStrings(const Strings: TStrings);
    var
      i: Integer;
    begin
      SetNodeAttrInt(PropNode, StringS_COUNT_NODENAME, Strings.Count);
      for i := 0 to Strings.Count - 1 do begin
        if Strings[i] <> '' then
          InternalWriteText(PropNode, StringS_PREFIX + IntToStr(i), Strings[i]);
      end;
    end;
  begin
    Value := TObject(GetOrdProp(Instance, PropInfo));
    if (Value <> nil) and (Value is TPersistent) then begin
      PropNode := Doc.CreateElement(XmlString(PPropInfo(PropInfo)^.Name));

      // write object's properties
      Write(TPersistent(Value), PropNode, False, True, WriteDefaultValues);
      if Value is TCollection then begin
        WriteCollection(TCollection(Value), PropNode);
        if not IsElementEmpty(PropNode, pfNodes) then
          Element.AppendChild(PropNode);
      end
      else if Value is TStrings then begin
        WriteStrings(TStrings(Value));
        Element.AppendChild(PropNode);
      end
      else if not IsElementEmpty(PropNode, PropsFormat) then
        Element.AppendChild(PropNode);
    end;
  end;

begin
  if (PPropInfo(PropInfo)^.GetProc <> nil) then begin
    PropType := {$IFDEF FPC}@{$ENDIF}PPropInfo(PropInfo).PropType{$IFNDEF FPC}^{$ENDIF};
    case PropType^.Kind of
      tkInteger, tkChar, tkWChar, tkEnumeration, tkSet: WriteOrdProp;
      tkString, tkLString, tkWString {$IFDEF UNICODE}, tkUString {$ENDIF}: WriteStrProp;
      tkFloat:
        if (PropType = System.TypeInfo(TDateTime)) or (PropType = System.TypeInfo(TTime))
          or (PropType = System.TypeInfo(TDate)) then
            WriteDateTimeProp
        else
          WriteFloatProp;
      tkInt64: WriteInt64Prop;
      tkClass: WriteObjectProp;
    end;
  end;
end;

procedure TOmniXMLWriter.Write(Instance: TPersistent; Root: IXMLElement;
  const WriteRoot: Boolean; const CheckIfEmpty: boolean; const WriteDefaultValues: Boolean);
var
  PropCount: Integer;
  PropList: PPropList;
  i: Integer;
  PropInfo: PPropInfo;
  Element: IXMLElement;
begin
  PropCount := GetTypeData(Instance.ClassInfo)^.PropCount;
  if PropCount = 0 then
    Exit;

  if Instance is TCollectionItem then
    Element := Doc.CreateElement(COLLECTIONITEM_NODENAME)
  else if WriteRoot then
    Element := Doc.CreateElement(Instance.ClassName)
  else
    Element := Root;

  GetMem(PropList, PropCount * SizeOf(Pointer));
  try
    GetPropInfos(Instance.ClassInfo, PropList);
    for i := 0 to PropCount - 1 do begin
      PropInfo := PropList^[I];
      if PropInfo = nil then
        Break;
      if IsStoredProp(Instance, PropInfo) then
        WriteProperty(Instance, PropInfo, Element, WriteDefaultValues)
    end;
  finally
    FreeMem(PropList, PropCount * SizeOf(Pointer));
  end;

  if WriteRoot then begin
    if CheckIfEmpty and IsElementEmpty(Element, PropsFormat) then
      Exit
    else begin
      if Root <> nil then
        Root.appendChild(Element)
      else
        Doc.documentElement := Element;
    end;
  end;
end;

{ TOmniXMLReader }

class procedure TOmniXMLReader.LoadXML(Instance: TPersistent; const XML: XmlString);
var
  XMLDoc: IXMLDocument;
  XMLRoot: IXMLElement;
  Reader: TOmniXMLReader;
  PropsFormat: TPropsFormat;
begin
  XMLDoc := CreateXMLDoc;
  { TODO : implement and test preserveWhiteSpace }
  XMLDoc.preserveWhiteSpace := True;
  XMLDoc.LoadXML(XML);

  Load(XMLDoc, XMLRoot, PropsFormat);

  Reader := TOmniXMLReader.Create(PropsFormat);
  try
    if Instance is TCollection then
      Reader.ReadCollection(TCollection(Instance), XMLRoot)
    else
      Reader.Read(Instance, XMLRoot, True);
  finally
    Reader.Free;
  end;
end;

class procedure TOmniXMLReader.LoadFromFile(Instance: TPersistent; FileName: string);
var
  XMLDoc: IXMLDocument;
  XMLRoot: IXMLElement;
  Reader: TOmniXMLReader;
  PropsFormat: TPropsFormat;
begin
  // read document
  LoadDocument(FileName, XMLDoc, XMLRoot, PropsFormat);

  Reader := TOmniXMLReader.Create(PropsFormat);
  try
    if Instance is TCollection then
      Reader.ReadCollection(TCollection(Instance), XMLRoot)
    else
      Reader.Read(Instance, XMLRoot, True);
  finally
    Reader.Free;
  end;
end;

class procedure TOmniXMLReader.LoadFromFile(Collection: TCollection; FileName: string);
var
  XMLDoc: IXMLDocument;
  XMLRoot: IXMLElement;
  Reader: TOmniXMLReader;
  PropsFormat: TPropsFormat;
begin
  // read document
  LoadDocument(FileName, XMLDoc, XMLRoot, PropsFormat);

  Reader := TOmniXMLReader.Create(PropsFormat);
  try
    Reader.ReadCollection(Collection, XMLRoot);
  finally
    Reader.Free;
  end;
end;

constructor TOmniXMLReader.Create(const PropFormat: TPropsFormat = pfAuto);
begin
  if PropFormat = pfAuto then
    raise EOmniXMLPersistent.Create('Auto PropFormat not allowed here.');

  PropsFormat := PropFormat;
end;

function TOmniXMLReader.FindElement(const Root: IXMLElement; const TagName: XmlString): IXMLElement;
var
  i: Integer;
begin
  Result := nil;
  if Root = nil then
    Exit;
  i := 0;
  while (Result = nil) and (i < Root.ChildNodes.Length) do begin
    if (Root.ChildNodes.Item[i].NodeType = ELEMENT_NODE)
      and (CompareText(Root.ChildNodes.Item[i].NodeName, TagName) = 0) then
        Result := Root.ChildNodes.Item[i] as IXMLElement
    else
      Inc(i);
  end;
end;

function TOmniXMLReader.InternalReadText(Root: IXMLElement; Name: XmlString; var Value: XmlString): Boolean;
var
  PropNode: IXMLElement;
  AttrNode: IXMLNode;
begin
  case PropsFormat of
    pfAttributes:
      begin
        AttrNode := Root.Attributes.GetNamedItem(Name);
        Result := AttrNode <> nil;
        if Result then
          Value := AttrNode.NodeValue;
      end;
    pfNodes:
      begin
        PropNode := FindElement(Root, Name);
        Result := PropNode <> nil;
        if Result then
          Value := PropNode.Text;
      end;
    else
      Result := False;
  end;
end;

procedure TOmniXMLReader.ReadCollection(Collection: TCollection; Root: IXMLElement);
var
  i: Integer;
  Item: TCollectionItem;
begin
  Collection.Clear;
  if Root = nil then
    Exit;
  for i := 0 to Root.ChildNodes.Length - 1 do begin
    if Root.ChildNodes.Item[i].NodeType = ELEMENT_NODE then begin
      if Root.ChildNodes.Item[i].NodeName = COLLECTIONITEM_NODENAME then begin
        Item := Collection.Add;
        Read(Item, Root.ChildNodes.Item[i] as IXMLElement, False);
      end;
    end;
  end;
end;

procedure TOmniXMLReader.ReadProperty(Instance: TPersistent; PropInfo: Pointer;
  Element: IXMLElement);
var
  PropType: PTypeInfo;

  procedure ReadFloatProp;
  var
    Value: Extended;
    Text: XmlString;
  begin
    if InternalReadText(Element, XmlString(PPropInfo(PropInfo)^.Name), Text) then
      Value := XMLStrToRealDef(Text, 0)
    else
      Value := 0;
    SetFloatProp(Instance, PropInfo, Value)
  end;

  procedure ReadDateTimeProp;
  var
    Value: TDateTime;
    Text: XmlString;
  begin
    if InternalReadText(Element, XmlString(PPropInfo(PropInfo)^.Name), Text) then begin
      if XMLStrToDateTime(Text, Value) then
        SetFloatProp(Instance, PropInfo, Value)
      else
        raise EOmniXMLPersistent.CreateFmt('Error in datetime property %s', [PPropInfo(PropInfo)^.Name]);
    end
    else
      SetFloatProp(Instance, PropInfo, 0);  // 2004-02-02
  end;

  procedure ReadStrProp;
  var
    Value: XmlString;
    {$IFDEF UNICODE}
    TypeData: PTypeData;
    CP: Word;
    RBS: RawByteString;
    {$ENDIF}  // UNICODE
  begin
    if not InternalReadText(Element, XmlString(PPropInfo(PropInfo)^.Name), Value) then
      Value := '';

    case PropType^.Kind of
      tkWString: SetWideStrProp(Instance, PropInfo, Value);
      {$IFDEF UNICODE}
      tkLString:
        begin
          TypeData := GetTypeData(PropType);
          CP := TypeData^.CodePage;

          case CP of
            CP_ACP: SetAnsiStrProp(Instance, PropInfo, AnsiString(Value));  // default code page
            CP_UNICODE: SetUnicodeStrProp(Instance, PropInfo, Value);  // Unicode code page
          else
            // convert to valid codepage using RawByteString
            RBS := UTF8Encode(Value);
            if CP <> CP_RawByteString then
              SetCodePage(RBS, CP, True);
            SetAnsiStrProp(Instance, PropInfo, RBS);
          end;
        end;
      {$ENDIF}  // UNICODE
    else
      SetStrProp(Instance, PropInfo, Value);
    end;
  end;

  procedure ReadOrdProp;
  var
    Value: XmlString;
    IntValue: Integer;
    BoolValue: Boolean;
  begin
    if InternalReadText(Element, XmlString(PPropInfo(PropInfo)^.Name), Value) then begin
      case PropType^.Kind of
        tkInteger:
          if XMLStrToInt(Value, IntValue) then
            SetOrdProp(Instance, PropInfo, XMLStrToIntDef(Value, 0))
          else
            raise EOmniXMLPersistent.CreateFmt('Invalid integer value (%s).', [Value]);
        tkChar:
          begin
            {$IFDEF UNICODE}
            SetOrdProp(Instance, PropInfo, Ord(Char(Value[1])));
            {$ELSE}
            SetOrdProp(Instance, PropInfo, Ord(Char(Utf8ToAnsi(UTF8Encode(Value))[1])));
            {$ENDIF}  // UNICODE
          end;
        tkWChar: SetOrdProp(Instance, PropInfo, Cardinal(Value[1]));
        tkSet: SetSetProp(Instance, PropInfo, Value);
        tkEnumeration:
          begin
            if PropType = System.TypeInfo(Boolean) then begin
              if XMLStrToBool(LowerCase(Value), BoolValue) then
                SetOrdProp(Instance, PropInfo, Ord(BoolValue))
              else
                raise EOmniXMLPersistent.CreateFmt('Invalid boolean value (%s).', [Value]);
            end
            else if PropType^.Kind = tkInteger then begin
              if XMLStrToInt(Value, IntValue) then
                SetOrdProp(Instance, PropInfo, IntValue)
              else
                raise EOmniXMLPersistent.CreateFmt('Invalid enum value (%s).', [Value]);
            end
            // 2003-05-27 (mr): added tkEnumeration processing
            else if PropType^.Kind = tkEnumeration then
              SetEnumProp(Instance, PropInfo, Value);
          end;
      end;
    end
    else
      SetOrdProp(Instance, PropInfo, PPropInfo(PropInfo)^.Default)
  end;

  procedure ReadInt64Prop;
  var
    Value: XmlString;
    IntValue: Int64;
  begin
    if InternalReadText(Element, XmlString(PPropInfo(PropInfo)^.Name), Value) then begin
      if XMLStrToInt64(Value, IntValue) then
        SetInt64Prop(Instance, PropInfo, IntValue)
      else
        raise EOmniXMLPersistent.CreateFmt('Invalid int64 value (%s).', [Value]);
    end
    else
      SetFloatProp(Instance, PropInfo, 0)
  end;

  procedure ReadObjectProp;
  var
    Value: TObject;
    PropNode: IXMLElement;

    procedure ReadStrings(const Strings: TStrings);
    var
      i: Integer;
      Count: Integer;
      Value: XmlString;
    begin
      Strings.Clear;

      Count := GetNodeAttrInt(PropNode, StringS_COUNT_NODENAME, 0);
      for i := 0 to Count - 1 do
        Strings.Add('');
        
      for i := 0 to Strings.Count - 1 do begin
        if InternalReadText(PropNode, StringS_PREFIX + IntToStr(i), Value) then
          Strings[i] := Value;
      end;
    end;
  begin
    Value := TObject(GetOrdProp(Instance, PropInfo));
    if (Value <> nil) and (Value is TPersistent) then begin
      PropNode := FindElement(Element, XmlString(PPropInfo(PropInfo)^.Name));
      Read(TPersistent(Value), PropNode);
      if Value is TCollection then
        ReadCollection(TCollection(Value), PropNode)
      else if Value is TStrings then
        ReadStrings(TStrings(Value));
    end;
  end;

begin
  PropType := PPropInfo(PropInfo)^.PropType^;
  if (PPropInfo(PropInfo)^.GetProc <> nil) and
     ((PropType^.Kind = tkClass) or (PPropInfo(PropInfo)^.SetProc <> nil)) and
     (IsStoredProp(Instance, PPropInfo(PropInfo))) then
  begin
    case PropType^.Kind of
      tkInteger, tkChar, tkWChar, tkEnumeration, tkSet: ReadOrdProp;
      tkString, tkLString, tkWString {$IFDEF UNICODE}, tkUString {$ENDIF}: ReadStrProp;
      tkFloat:
        if (PropType = System.TypeInfo(TDateTime)) or (PropType = System.TypeInfo(TTime))
          or (PropType = System.TypeInfo(TDate)) then
            ReadDateTimeProp
        else
          ReadFloatProp;
      tkInt64: ReadInt64Prop;
      tkClass: ReadObjectProp;
    end;
  end;
end;

procedure TOmniXMLReader.Read(Instance: TPersistent; Root: IXMLElement; const ReadRoot: Boolean);
var
  PropCount: Integer;
  PropList: PPropList;
  i: Integer;
  PropInfo: PPropInfo;
begin
  if ReadRoot then
    Root := FindElement(Root, Instance.ClassName);

  if Root = nil then
    Exit;

  PropCount := GetTypeData(Instance.ClassInfo)^.PropCount;
  if PropCount > 0 then begin
    GetMem(PropList, PropCount * SizeOf(Pointer));
    try
      GetPropInfos(Instance.ClassInfo, PropList);
      for i := 0 to PropCount - 1 do begin
        PropInfo := PropList^[I];
        if PropInfo = nil then
          Break;
        ReadProperty(Instance, PropInfo, Root);
      end;
    finally
      FreeMem(PropList, PropCount * SizeOf(Pointer));
    end;
  end;
end;

end.
