(*:XML helper unit. Contains a class to simplify creation of node-wrapper
   classes (classes that contain properties that map directly to the child nodes
   of some XML node).
   @author Primoz Gabrijelcic
   @desc <pre>
   (c) 2010 Primoz Gabrijelcic
   Free for personal and commercial use. No rights reserved.

   Author            : Primoz Gabrijelcic
   Creation date     : 2001-06-17
   Last modification : 2010-01-22
   Version           : 2.02b
</pre>*)(*
   History:
     2.02b: 2010-01-22
       - TGpXMLDoc.LoadFromString can be passed an empty string.
     2.02a: 2009-07-15
       - Bug fixed: If TGpXMLDoc.LoadFromString failed, internal XML document got corrupted.
     2.02: 2005-04-27
       - [Miha Vrhovnik] Added WideString functions: GetXMLPropCDataWide,
         SetXMLPropCDataWide, GetXMLPropCDataOrTextWide, GetXMLPropCDataOrText.
     2.01: 2004-08-13
       - Added WideString accessors GetXMLAttrPropWide, GetXMLPropWide,
         SetXMLAttrPropWide, and SetXMLPropWide to the TGpXMLData class.
     2.0a: 2004-03-01
       - Adapted for OmniXMLUtils 1.19.
     2.0: 2003-12-12
       - Major modifications to allow reading of RSS files (and other XML
         documents, of course).
         - TGpXMLDoc is now a TGpXMLData, too.
         - *List classes can now drop the 'listTag' in the constructor. Root
           class node will be used as a list wrapper in this case.
         - Added indexed property Items[] to both *List classes.
         - Added Get/SetXMLAttrProp* to the TGpXMLData class.
         - Added Get/SetXMLPropCDATA to the TGpXMLData class.
     1.09: 2003-11-27
       - Renamed CreateChildren method into RecreateChildren to serve as a
         visual reminder that it may be called when children are already created
         (in which case old instances must be destroyed first).
     1.08b: 2003-04-20
       - Bug fixed: Clearing TGpXMLList did not clear associated nodes.
     1.08a: 2003-01-16
       - Fixed range check error in SetXMLPropDWORD.
     1.08: 2003-01-13
       - Removed processing of default values in SetXMLProp* setters - it was
         causing a confusion when used in conjunction with the Assign method.
     1.07: 2003-01-13
       - Added TGpXMLData.InitChildNodes that greatly simplifies data node
         initialization.
       - Fixed saving - volatile/private markers are now not saved in the
         document element node anymore.
     1.06a: 2003-01-08
       - Standalone AsString fixed to work with volatile nodes.
       - TGpXMLDoc.AsString fixed to twork with volatile nodes.
     1.06: 2003-01-07
       - Added TGpXMLVolatileData class. It is only returned as a part of the
         AsString result and is _not_ saved in the TGpXMLDoc.SaveTo* methods.
     1.05: 2002-12-26
       - Added '_' support to the TGpXMLData class.
       - Added parameterless constructor to the TGpXMLData class.
       - Added 'load from string' constructor to the TGpXMLData class.
       - Added property AsString to the TGpXMLData class.
     1.04: 2002-12-22
       - Added property AsString to the TGpXMLDoc class.
     1.03: 2002-12-09
       - MSXML compatible (define USE_MSXML).
     1.02: 2002-10-01
       - TXMLData now implements Text property allowing for text-only nodes.
     1.01a: 2002-05-15
       - Fixed bug in TGpXMLList.Delete.
     1.01: 2001-12-01
       - Added functions LoadFromString, LoadFromRegistry, SaveToString,
         SaveToRegistry to the TGpXMLDoc class.
       - Added parameter outputFormat to TGpXMLDoc.SaveToFile and
         TGpXMLDoc.SaveToStream.
       - New class TGpXMLDocList.
     1.0: 2001-10-24
       - Created by extracting database-related functionality from unit GpXML.
       - Implemented TGpXMLDoc.LoadFromStream and TGpXMLDoc.SaveToStream.
*)

unit OmniXMLProperties;

interface

{$I OmniXML.inc}

{$IFDEF OmniXML_HasZeroBasedStrings}
  {$ZEROBASEDSTRINGS OFF}
{$ENDIF}


uses
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
{$IFDEF LINUX}
  Types,  // declares DWORD
{$ENDIF}
  Classes,
  Contnrs,
  TypInfo,
{$IFDEF HAS_UNIT_VARIANTS}
  Variants,
{$ENDIF}
  OmniXML
{$IFDEF USE_MSXML}
  , OmniXML_MSXML
{$ENDIF}
  ;

// TODO 3 -oPrimoz Gabrijelcic: Convert Load/Save routines to use mr_XML error reporting system.

type
  TGpXMLList = class;

  {:Base class that handles most functionality of getting and setting XML-based
    properties. Derived class typically only has to declare indexed properties
    and initialize xmlChildNodeDefaults and xmlChildNodeTags arrays in the
    overridden constructor.
    Note that Int64 is not compatible with Variant. If you want to set the
    default value for a Int64 property, specify it as a string. GetXMLPropInt64
    will use StrToInt64 to convert default value into a number.
  }
  TGpXMLData = class
  private
    xmlList: TGpXMLList;
    xmlNode: IXMLNode;
  protected
    xmlChildNodeDefaults: array of Variant;
    xmlChildNodeTags    : array of string;
    xmlXMLDoc           : IXMLDocument;
    procedure FilterNodes(node: IXMLNode; var canProcess: boolean); virtual;
    procedure FilterPrivateNodes(node: IXMLNode; var canProcess: boolean); virtual;
    function  GetAsString: string; virtual;
    function  GetText: string; virtual;
    function  GetXMLAttrProp(index: integer): string; virtual;
    function  GetXMLAttrPropBool(index: integer): boolean; virtual;
    function  GetXMLAttrPropCardinal(index: integer): cardinal; virtual;
    function  GetXMLAttrPropDate(index: integer): TDateTime; virtual;
    function  GetXMLAttrPropDateTime(index: integer): TDateTime; virtual;
    function  GetXMLAttrPropDWORD(index: integer): DWORD; virtual;
    function  GetXMLAttrPropInt(index: integer): integer; virtual;
    function  GetXMLAttrPropInt64(index: integer): int64; virtual;
    function  GetXMLAttrPropReal(index: integer): real; virtual;
    function  GetXMLAttrPropTime(index: integer): TDateTime; virtual;
    function  GetXMLAttrPropWide(index: integer): WideString; virtual;
    function  GetXMLProp(index: integer): string; virtual;
    function  GetXMLPropBool(index: integer): boolean; virtual;
    function  GetXMLPropCardinal(index: integer): cardinal; virtual;
    function  GetXMLPropCData(index: integer): string; virtual;
    function  GetXMLPropCDataWide(index: integer): WideString; virtual;
    function  GetXMLPropCDataOrTextWide(index: integer): WideString; virtual;
    function  GetXMLPropCDataOrText(index: integer): string; virtual;
    function  GetXMLPropDate(index: integer): TDateTime; virtual;
    function  GetXMLPropDateTime(index: integer): TDateTime; virtual;
    function  GetXMLPropDWORD(index: integer): DWORD; virtual;
    function  GetXMLPropInt(index: integer): integer; virtual;
    function  GetXMLPropInt64(index: integer): int64; virtual;
    function  GetXMLPropReal(index: integer): real; virtual;
    function  GetXMLPropTime(index: integer): TDateTime; virtual;
    function  GetXMLPropWide(index: integer): WideString; virtual;
    procedure InitChildNodes(tags: array of string; defaults: array of Variant); virtual;
    procedure SetAsString(const Value: string); virtual;
    procedure SetText(const Value: string); virtual;
    procedure SetXMLAttrProp(const index: integer; const value: string); virtual;
    procedure SetXMLAttrPropBool(const index: integer; const value: boolean); virtual;
    procedure SetXMLAttrPropCardinal(const index: integer; const value: cardinal); virtual;
    procedure SetXMLAttrPropDate(const index: integer; const value: TDateTime); virtual;
    procedure SetXMLAttrPropDateTime(const index: integer; const value: TDateTime); virtual;
    procedure SetXMLAttrPropDWORD(const index: integer; const value: DWORD); virtual;
    procedure SetXMLAttrPropInt(const index: integer; const value: integer); virtual;
    procedure SetXMLAttrPropInt64(const index: integer; const value: int64); virtual;
    procedure SetXMLAttrPropReal(const index: integer; const value: real); virtual;
    procedure SetXMLAttrPropTime(const index: integer; const value: TDateTime); virtual;
    procedure SetXMLAttrPropWide(const index: integer; const value: WideString); virtual;
    procedure SetXMLProp(const index: integer; const value: string); virtual;
    procedure SetXMLPropBool(const index: integer; const value: boolean); virtual;
    procedure SetXMLPropCardinal(const index: integer; const value: cardinal); virtual;
    procedure SetXMLPropCData(const index: integer; const value: string); virtual;
    procedure SetXMLPropCDataWide(const index: integer; const value: WideString); virtual;
    procedure SetXMLPropDate(const index: integer; const value: TDateTime); virtual;
    procedure SetXMLPropDateTime(const index: integer; const value: TDateTime); virtual;
    procedure SetXMLPropDWORD(const index: integer; const value: DWORD); virtual;
    procedure SetXMLPropInt(const index: integer; const value: integer); virtual;
    procedure SetXMLPropInt64(const index: integer; const value: int64); virtual;
    procedure SetXMLPropReal(const index: integer; const value: real); virtual;
    procedure SetXMLPropTime(const index: integer; const value: TDateTime); virtual;
    procedure SetXMLPropWide(const index: integer; const value: WideString); virtual;
    property OwnerList: TGpXMLList read xmlList write xmlList;
  public
    constructor Create(node: IXMLNode); overload; virtual; // use this constructor in most cases
    constructor Create(nodeData: string); overload; virtual; // do other constructors need to be public?
    constructor Create(parentNode: IXMLNode; nodeTag: string); overload; virtual;
    constructor Create; overload; virtual;
    procedure Assign(dataNode: TGpXMLData);
    procedure AssignNonvolatile(dataNode: TGpXMLData);
    property  AsString: string read GetAsString write SetAsString;
    property  Node: IXMLNode read xmlNode;
    property  Text: string read GetText write SetText;
  end; { TGpXMLData }

  TGpXMLDataClass = class of TGpXMLData;

  {:Data class that is stringable but not persistent.
    @since   2003-01-06
  }
  TGpXMLVolatileData = class(TGpXMLData)
  protected
    procedure MarkVolatile; virtual;
  public
    constructor Create(node: IXMLNode); overload; override;
    constructor Create; overload; override;
  end; { TGpXMLVolatileData }

  {:Data class that is not streamable - it cannot be stored or extracted as a
    string.
    OK, that is a lie, you can do the XMLSaveToString(TGpXMLList.XMLDoc), but
    you are not supposed to.
    @since   2003-01-09
  }
  TGpXMLPrivateData = class(TGpXMLData)
  protected
    procedure MarkPrivate; virtual;
  public
    constructor Create(node: IXMLNode); overload; override;
    constructor Create; overload; override;
  end; { TGpXMLPrivateData }

  {:Base class handling list of twisty little TGpXMLData objects, all alike.
    Contains _no_ default indexed property - it should be created in derived
    classes.
  }
  TGpXMLList = class
  private
    xmlChildClass: TGpXMLDataClass;
    xmlChildTag  : string;
    xmlChildNodes: TObjectList; // of TGpXMLData
    xmlNode      : IXMLNode;
  protected
    function  CreateStandalone: TGpXMLData;
    function  Get(idx: integer): TGpXMLData;
  public
    constructor Create(parentNode: IXMLNode; nodeTag, childTag: string;
      childClass: TGpXMLDataClass); virtual;
    destructor  Destroy; override;
    function  Add: TGpXMLData; virtual;
    procedure Clear; virtual;
    function  Count: integer; virtual;
    procedure Delete(childNode: TGpXMLData); virtual;
    function  IndexOf(childNode: TGpXMLData): integer;
    property  Items[idxItem: integer]: TGpXMLData read Get;
    property  Node: IXMLNode read xmlNode;
  end; { TGpXMLList }

  {:Encapsulation of the XML document containing methods for loading and
    saving state. Derived classes will typically want to override
    RecreateChildren to create owned objects.
  }
  TGpXMLDoc = class(TGpXMLData)
  private
    xmlLastError: string;
    xmlRootTag  : string;
  protected
    function  CreatePersistentClone: IXMLDocument; virtual;
    function  GetAsString: string; override;
    function  GetXMLRoot: IXMLElement; virtual;
    procedure SetAsString(const Value: string); override;
  public
    constructor Create(rootTag: string); reintroduce;
    constructor Clone(doc: TGpXMLDoc); virtual;
    procedure CreateRootNode; virtual;
    function  LoadFromFile(const fileName: string): boolean; virtual;
{$IFDEF MSWINDOWS}
    function  LoadFromRegistry(rootKey: HKEY; const key, value: string): boolean; virtual;
    function  SaveToRegistry(rootKey: HKEY; const key, value: string; outputFormat: TOutputFormat = ofNone): boolean; virtual;
{$ENDIF}
    function  LoadFromStream(stream: TStream): boolean; virtual;
    function  LoadFromString(const dataString: string): boolean; virtual;
    procedure RecreateChildren; virtual;
    procedure Reset; virtual;
    function  SaveToFile(const fileName: string; outputFormat: TOutputFormat = ofNone): boolean; virtual;
    function  SaveToStream(stream: TStream; outputFormat: TOutputFormat = ofNone): boolean; virtual;
    function  SaveToString(var dataString: string; outputFormat: TOutputFormat = ofNone): boolean; virtual;
    property  AsString: string read GetAsString write SetAsString;
    property  LastError: string read xmlLastError;
    property  RootTag: string read xmlRootTag;
    property  XMLDoc: IXMLDocument read xmlXMLDoc;
    property  XMLRoot: IXMLElement read GetXMLRoot;
  end; { TGpXMLDoc }

  {:XML document containing only a list of nodes with the same structure.
  }
  TGpXMLDocList = class(TGpXMLDoc)
  private
    xmlChildClass: TGpXMLDataClass;
    xmlChildTag  : string;
    xmlList      : TGpXMLList;
    xmlListTag   : string;
  protected
    function  Get(idx: integer): TGpXMLData;
    function  GetNode: IXMLNode; virtual;
  public
    constructor Create(rootTag, listTag, childTag: string;
      childClass: TGpXMLDataClass); reintroduce; virtual;
    destructor  Destroy; override;
    function  Add: TGpXMLData; virtual;
    procedure Clear; virtual;
    function  Count: integer; virtual;
    procedure Delete(childNode: TGpXMLData); virtual;
    function  IndexOf(childNode: TGpXMLData): integer;
    procedure RecreateChildren; override;
    property  Items[idxItem: integer]: TGpXMLData read Get;
    property  Node: IXMLNode read GetNode;
  end; { TGpXMLDocList }

implementation

uses
  SysUtils,
{$IFDEF MSWINDOWS}
  Registry,
{$ENDIF}
  OmniXMLUtils;

resourcestring
  sXMLfileIsCorrupt = 'XML file is corrupt.';

const
  CContainsPrivateAttr  = 'ContainsPrivateNodes';
  CContainsVolatileAttr = 'ContainsVolatileNodes';
  CIsPrivateAttr        = 'Private';
  CIsVolatileAttr       = 'Volatile';

{ TGpXMLData }

{:Assign contents of another data object.
  @since   2002-12-26
}
procedure TGpXMLData.Assign(dataNode: TGpXMLData);
begin
  CopyNode(dataNode.Node, xmlNode, true);
end; { TGpXMLData.Assign }

{:Assign nonvolatile contents of another data object.
  @since   2003-01-07
}        
procedure TGpXMLData.AssignNonvolatile(dataNode: TGpXMLData);
begin
  CopyNode(dataNode.Node, xmlNode, true, FilterNodes);
end; { TGpXMLData.AssignNonvolatile }

{:Create object and remember XML node. Derived classes should inherit from this
  constructor and initialize xmlChildNodeDefaults and xmlChildNodeTags arrays.
  @param   node XML node containing object data.
}
constructor TGpXMLData.Create(node: IXMLNode);
begin
  Assert(assigned(node), 'Node is not assigned in TGpXMLData.Create');
  xmlNode := node;
end; { TGpXMLData.Create }

{:Create object in named child node. If child node doesn't exist, it will be
  created.
  @param   parentNode Parent XML node.
  @param   nodeTag    Child node tag.
}
constructor TGpXMLData.Create(parentNode: IXMLNode; nodeTag: string);
var
  myNode: IXMLNode;
begin
  myNode := EnsureNode(parentNode, nodeTag);
  Create(myNode);
end; { TGpXMLData.Create }

{:Create object in standalone mode.
}
constructor TGpXMLData.Create;
begin
  xmlXMLDoc := CreateXMLDoc;
  Create(EnsureNode(xmlXMLDoc,'_'));
end; { TGpXMLData.Create }

{:Create an object in standalone mode and load its contents from a string.
  @since   2002-12-26
}        
constructor TGpXMLData.Create(nodeData: string);
begin
  Create;
  AsString := nodeData;
end; { TGpXMLData.Create }

{:Triggered on each node during the AssignNonvolatile operation. Filters out
  volatile and private nodes.
  @since   2003-01-06
}
procedure TGpXMLData.FilterNodes(node: IXMLNode;
  var canProcess: boolean);
begin
  canProcess :=
    (not (GetNodeAttrBool(node, CIsVolatileAttr, false) or
          GetNodeAttrBool(node, CIsPrivateAttr, false)));
end; { TGpXMLData.FilterNodes }

{:Filter out private nodes during the AsString get.
  @since   2003-01-09
}        
procedure TGpXMLData.FilterPrivateNodes(node: IXMLNode;
  var canProcess: boolean);
begin
  canProcess := (not GetNodeAttrBool(node, CIsPrivateAttr, false));
end; { TGpXMLData.FilterPrivateNodes }

{:Serialize contents of an object.
  @since   2002-12-25
}
function TGpXMLData.GetAsString: string;
var
  p            : integer;
  tmpDoc       : IXMLDocument;
  xmlStandalone: TGpXMLData;
begin
  if assigned(xmlXMLDoc) then begin
    if GetNodeAttrBool(xmlXMLDoc, CContainsPrivateAttr, false) then
      tmpDoc := CloneDocument(xmlXMLDoc, FilterPrivateNodes)
    else
      tmpDoc := xmlXMLDoc;
    Result := XMLSaveToString(tmpDoc);
    Delete(Result, 1, Pos('>', Result));
    p := LastDelimiter('<', Result);
    Delete(Result, p, Length(Result)-p+1);
  end
  else if not assigned(xmlList) then
    raise Exception.Create('TGpXMLData.GetAsString: OwnerList is not set')
  else begin
    xmlStandalone := xmlList.CreateStandalone;
    try
      xmlStandalone.Assign(Self);
      Result := xmlStandalone.AsString;
    finally FreeAndNil(xmlStandalone); end;
  end;
end; { TGpXMLData.GetAsString }

function TGpXMLData.GetText: string;
begin
  Result := Node.Text;
end; { TGpXMLData.GetText }

function TGpXMLData.GetXMLAttrProp(index: integer): string;
begin
  Result := GetNodeAttrStr(xmlNode, xmlChildNodeTags[index],
    WideString(xmlChildNodeDefaults[index]));
end; { TGpXMLData.GetXMLAttrProp }

function TGpXMLData.GetXMLAttrPropBool(index: integer): boolean;
begin
  Result := GetNodeAttrBool(xmlNode, xmlChildNodeTags[index],
    xmlChildNodeDefaults[index]);
end; { TGpXMLData.GetXMLAttrPropBool }

function TGpXMLData.GetXMLAttrPropCardinal(index: integer): cardinal;
begin
  Result := cardinal(GetXMLAttrPropInt64(index));
end; { TGpXMLData.GetXMLAttrPropCardinal }

function TGpXMLData.GetXMLAttrPropDate(index: integer): TDateTime;
begin
  Result := GetNodeAttrDate(xmlNode, xmlChildNodeTags[index],
    xmlChildNodeDefaults[index]);
end; { TGpXMLData.GetXMLAttrPropDate }

function TGpXMLData.GetXMLAttrPropDateTime(index: integer): TDateTime;
begin
  Result := GetNodeAttrDateTime(xmlNode, xmlChildNodeTags[index],
    xmlChildNodeDefaults[index]);
end; { TGpXMLData.GetXMLAttrPropDateTime }

function TGpXMLData.GetXMLAttrPropDWORD(index: integer): DWORD;
begin
  Result := DWORD(GetXMLAttrPropInt(index));
end; { TGpXMLData.GetXMLAttrPropDWORD }

function TGpXMLData.GetXMLAttrPropInt(index: integer): integer;
begin
  Result := GetNodeAttrInt(xmlNode, xmlChildNodeTags[index],
    xmlChildNodeDefaults[index]);
end; { TGpXMLData.GetXMLAttrPropInt }

function TGpXMLData.GetXMLAttrPropInt64(index: integer): int64;
begin
  Result := GetNodeAttrInt64(xmlNode, xmlChildNodeTags[index],
    StrToIntDef(xmlChildNodeDefaults[index], 0));
end; { TGpXMLData.GetXMLAttrPropInt64 }

function TGpXMLData.GetXMLAttrPropReal(index: integer): real;
begin
  Result := GetNodeAttrReal(xmlNode, xmlChildNodeTags[index],
    xmlChildNodeDefaults[index]);
end; { TGpXMLData.GetXMLAttrPropReal }

function TGpXMLData.GetXMLAttrPropTime(index: integer): TDateTime;
begin
  Result := GetNodeAttrTime(xmlNode, xmlChildNodeTags[index],
    xmlChildNodeDefaults[index]);
end; { TGpXMLData.GetXMLAttrPropTime }

function TGpXMLData.GetXMLAttrPropWide(index: integer): WideString;
begin
  Result := GetNodeAttrStr(xmlNode, xmlChildNodeTags[index],
    WideString(xmlChildNodeDefaults[index]));
end; { TGpXMLData.GetXMLAttrPropWide }

function TGpXMLData.GetXMLProp(index: integer): string;
begin
  Result := GetNodeTextStr(xmlNode, xmlChildNodeTags[index],
    WideString(xmlChildNodeDefaults[index]));
end; { TGpXMLData.GetXMLProp }

function TGpXMLData.GetXMLPropBool(index: integer): boolean;
begin
  Result := GetNodeTextBool(xmlNode, xmlChildNodeTags[index],
    xmlChildNodeDefaults[index]);
end; { TGpXMLData.GetXMLPropBool }

function TGpXMLData.GetXMLPropCardinal(index: integer): cardinal;
begin
  Result := cardinal(GetXMLPropInt64(index));
end; { TGpXMLData.GetXMLPropCardinal }

function TGpXMLData.GetXMLPropCData(index: integer): string;
begin
  Result := GetNodeCData(xmlNode, xmlChildNodeTags[index],
    WideString(xmlChildNodeDefaults[index]));
end; { TGpXMLData.GetXMLPropCData }

function TGpXMLData.GetXMLPropCDataWide(index: integer): WideString;
begin
  Result := GetNodeCData(xmlNode, xmlChildNodeTags[index],
    WideString(xmlChildNodeDefaults[index]));
end; { TGpXMLData.GetXMLPropCDataWide }

function TGpXMLData.GetXMLPropCDataOrTextWide(index: integer): WideString;
begin
  Result := GetNodeCData(xmlNode, xmlChildNodeTags[index], '');
  if Result = '' then
    Result := GetNodeTextStr(xmlNode, xmlChildNodeTags[index], '');

  if Result = '' then
    Result := WideString(xmlChildNodeDefaults[index]);
end; { TGpXMLData.GetXMLPropCDataOrTextWide }

function TGpXMLData.GetXMLPropCDataOrText(index: integer): string;
begin
  Result := GetNodeCData(xmlNode, xmlChildNodeTags[index], '');
  if Result = '' then
    Result := GetNodeTextStr(xmlNode, xmlChildNodeTags[index], '');

  if Result = '' then
    Result := WideString(xmlChildNodeDefaults[index]);
end; { TGpXMLData.GetXMLPropCDataOrText }
function TGpXMLData.GetXMLPropDate(index: integer): TDateTime;
begin
  Result := GetNodeTextDate(xmlNode, xmlChildNodeTags[index],
    xmlChildNodeDefaults[index]);
end; { TGpXMLData.GetXMLPropDate }

function TGpXMLData.GetXMLPropDateTime(index: integer): TDateTime;
begin
  Result := GetNodeTextDateTime(xmlNode, xmlChildNodeTags[index],
    xmlChildNodeDefaults[index]);
end; { TGpXMLData.GetXMLPropDateTime }

function TGpXMLData.GetXMLPropDWORD(index: integer): DWORD;
begin
  Result := DWORD(GetXMLPropInt(index));
end; { TGpXMLData.GetXMLPropDWORD }

function TGpXMLData.GetXMLPropInt(index: integer): integer;
begin
  Result := GetNodeTextInt(xmlNode, xmlChildNodeTags[index],
    xmlChildNodeDefaults[index]);
end; { TGpXMLData.GetXMLPropInt }

function TGpXMLData.GetXMLPropInt64(index: integer): int64;
begin
  Result := GetNodeTextInt64(xmlNode, xmlChildNodeTags[index],
    StrToIntDef(xmlChildNodeDefaults[index], 0));
end; { TGpXMLData.GetXMLPropInt64 }

function TGpXMLData.GetXMLPropReal(index: integer): real;
begin
  Result := GetNodeTextReal(xmlNode, xmlChildNodeTags[index],
    xmlChildNodeDefaults[index]);
end; { TGpXMLData.GetXMLPropReal }

function TGpXMLData.GetXMLPropTime(index: integer): TDateTime;
begin
  Result := GetNodeTextTime(xmlNode, xmlChildNodeTags[index],
    xmlChildNodeDefaults[index]);
end; { TGpXMLData.GetXMLPropTime }

function TGpXMLData.GetXMLPropWide(index: integer): WideString;
begin
  Result := GetNodeTextStr(xmlNode, xmlChildNodeTags[index],
    WideString(xmlChildNodeDefaults[index]));
end; { TGpXMLData.GetXMLPropWide }

{:Init 'tags' and 'defaults' arrays.
  @since   2003-01-13
}
procedure TGpXMLData.InitChildNodes(tags: array of string;
  defaults: array of Variant);
var
  iNode: integer;
begin
  if Length(tags) <> Length(defaults) then
    raise Exception.Create('TGpXMLData.InitChildNodes: Size of ''tags'' and ''defaults'' arrays doesn''t match');
  SetLength(xmlChildNodeTags, Length(tags));
  SetLength(xmlChildNodeDefaults, Length(tags));
  for iNode := 0 to Length(tags)-1 do begin
    xmlChildNodeTags[iNode] := tags[iNode];
    xmlChildNodeDefaults[iNode] := defaults[iNode];
  end; //for
end; { TGpXMLData.InitChildNodes }

{:Set contents of an object.
  @since   2002-12-25
}
procedure TGpXMLData.SetAsString(const Value: string);
var
  xmlStandalone: TGpXMLData;
begin
  if assigned(xmlXMLDoc) then begin
    XMLLoadFromString(xmlXMLDoc, '<standalone>'+Value+'</standalone>');
    xmlNode := xmlXMLDoc.DocumentElement;
  end
  else if not assigned(xmlList) then
    raise Exception.Create('TGpXMLData.SetAsString: OwnerList is not set')
  else begin
    xmlStandalone := xmlList.CreateStandalone;
    try
      xmlStandalone.AsString := Value;
      Assign(xmlStandalone);
    finally FreeAndNil(xmlStandalone); end;
  end;
end; { TGpXMLData.SetAsString }

procedure TGpXMLData.SetText(const Value: string);
begin
  xmlNode.Text := Value;
end; { TGpXMLData.SetText }

procedure TGpXMLData.SetXMLAttrProp(const index: integer;
  const value: string);
begin
  SetNodeAttrStr(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLAttrProp }

procedure TGpXMLData.SetXMLAttrPropBool(const index: integer;
  const value: boolean);
begin
  SetNodeAttrBool(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLAttrPropBool }

procedure TGpXMLData.SetXMLAttrPropCardinal(const index: integer;
  const value: cardinal);
begin
  SetXMLAttrPropInt64(index, value);
end; { TGpXMLData.SetXMLAttrPropCardinal }

procedure TGpXMLData.SetXMLAttrPropDate(const index: integer;
  const value: TDateTime);
begin
  SetNodeAttrDate(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLAttrPropDate }

procedure TGpXMLData.SetXMLAttrPropDateTime(const index: integer;
  const value: TDateTime);
begin
  SetNodeAttrDateTime(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLAttrPropDateTime }

procedure TGpXMLData.SetXMLAttrPropDWORD(const index: integer;
  const value: DWORD);
begin
  SetXMLAttrPropInt(index, integer(value));
end; { TGpXMLData.SetXMLAttrPropDWORD }

procedure TGpXMLData.SetXMLAttrPropInt(const index, value: integer);
begin
  SetNodeAttrInt(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLAttrPropInt }

procedure TGpXMLData.SetXMLAttrPropInt64(const index: integer;
  const value: int64);
begin
  SetNodeAttrInt64(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLAttrPropInt64 }

procedure TGpXMLData.SetXMLAttrPropReal(const index: integer;
  const value: real);
begin
  SetNodeAttrReal(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLAttrPropReal }

procedure TGpXMLData.SetXMLAttrPropTime(const index: integer;
  const value: TDateTime);
begin
  SetNodeAttrTime(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLAttrPropTime }

procedure TGpXMLData.SetXMLAttrPropWide(const index: integer;
  const value: WideString);
begin
  SetNodeAttrStr(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLAttrPropWide }

procedure TGpXMLData.SetXMLProp(const index: integer; const value: string);
begin
  SetNodeTextStr(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLProp }

procedure TGpXMLData.SetXMLPropBool(const index: integer;
  const value: boolean);
begin
  SetNodeTextBool(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLPropBool }

procedure TGpXMLData.SetXMLPropCardinal(const index: integer;
  const value: cardinal);
begin
  SetXMLPropInt64(index, value);
end; { TGpXMLData.SetXMLPropCardinal }

procedure TGpXMLData.SetXMLPropCData(const index: integer;
  const value: string);
begin
  SetNodeCData(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLPropCData }
procedure TGpXMLData.SetXMLPropCDataWide(const index: integer;
  const value: WideString);
begin
  SetNodeCData(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLPropCDataWide }

procedure TGpXMLData.SetXMLPropDate(const index: integer;
  const value: TDateTime);
begin
  SetNodeTextDate(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLPropDate }

procedure TGpXMLData.SetXMLPropDateTime(const index: integer;
  const value: TDateTime);
begin
  SetNodeTextDateTime(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLPropDateTime }

procedure TGpXMLData.SetXMLPropDWORD(const index: integer;
  const value: DWORD);
begin
  SetXMLPropInt(index, integer(value));
end; { TGpXMLData.SetXMLPropDWORD }

procedure TGpXMLData.SetXMLPropInt(const index, value: integer);
begin
  SetNodeTextInt(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLPropInt }

procedure TGpXMLData.SetXMLPropInt64(const index: integer;
  const value: int64);
begin
  SetNodeTextInt64(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLPropInt64 }

procedure TGpXMLData.SetXMLPropReal(const index: integer;
  const value: real);
begin
  SetNodeTextReal(xmlNode,xmlChildNodeTags[index],value);
end; { TGpXMLData.SetXMLPropReal }

procedure TGpXMLData.SetXMLPropTime(const index: integer;
  const value: TDateTime);
begin
  SetNodeTextTime(xmlNode,xmlChildNodeTags[index],value);
end; { TGpXMLData.SetXMLPropTime }
                                                          
procedure TGpXMLData.SetXMLPropWide(const index: integer; const value: WideString);
begin
  SetNodeTextStr(xmlNode, xmlChildNodeTags[index], value);
end; { TGpXMLData.SetXMLPropWide }

{ TGpXMLVolatileData }

constructor TGpXMLVolatileData.Create(node: IXMLNode);
begin
  inherited Create(node);
  MarkVolatile;
end; { TGpXMLVolatileData.Create }

constructor TGpXMLVolatileData.Create;
begin
  inherited Create;
  MarkVolatile;
end; { TGpXMLVolatileData.Create }

{:Mark XML node as volatile.
  @since   2003-01-06
}        
procedure TGpXMLVolatileData.MarkVolatile;
begin
  SetNodeAttrBool(xmlNode, CIsVolatileAttr, true);
  SetNodeAttrBool(xmlNode.OwnerDocument.DocumentElement, CContainsVolatileAttr, true);
end; { TGpXMLVolatileData.MarkVolatile }

{ TGpXMLPrivateData }

constructor TGpXMLPrivateData.Create(node: IXMLNode);
begin
  inherited Create(node);
  MarkPrivate;
end; { TGpXMLPrivateData.Create }

constructor TGpXMLPrivateData.Create;
begin
  inherited Create(node);
  MarkPrivate;
end; { TGpXMLPrivateData.Create }

procedure TGpXMLPrivateData.MarkPrivate;
begin
  SetNodeAttrBool(xmlNode, CIsPrivateAttr, true);
  SetNodeAttrBool(xmlNode.OwnerDocument.DocumentElement, CContainsPrivateAttr, true);
end; { TGpXMLPrivateData.MarkPrivate }

{ TGpXMLList }

{:Create new child node and add it to the list.
  @returns New child node.
}
function TGpXMLList.Add: TGpXMLData;
var
  newNode: IXMLNode;
begin
  Assert(assigned(Node),'Node is not assigned in TGpXMLList.Add');
  newNode := xmlNode.OwnerDocument.CreateElement(xmlChildTag);
  Assert(assigned(newNode),'Child node is not assigned in TGpXMLList.Add');
  xmlNode.AppendChild(newNode);
  Result := xmlChildClass.Create(newNode);
  Result.OwnerList := Self;
  xmlChildNodes.Add(Result);
end; { TGpXMLList.Add }

{:Clear the node list.
}
procedure TGpXMLList.Clear;
begin
  xmlChildNodes.Clear;
  DeleteAllChildren(xmlNode);
end; { TGpXMLList.Clear }

{:Get number of nodes in the list.
  @returns Number of nodes in the list.
}
function TGpXMLList.Count: integer;
begin
  Result := xmlChildNodes.Count;
end; { TGpXMLList.Count }

{:Create list of equally named nodes.
  @param   parentNode Parent XML node.
  @param   nodeTag    Tag of the node containing child nodes.
  @param   childTag   Child nodes' tag.
  @param   childClass Class of the child nodes.
}
constructor TGpXMLList.Create(parentNode: IXMLNode; nodeTag, childTag: string;
  childClass: TGpXMLDataClass);
var
  childNode: TGpXMLData;
  csList   : IXMLNodeList;
  csNode   : IXMLNode;
begin
  Assert(assigned(parentNode), 'Parent node is not assigned in TGpXMLList.Create');
  if nodeTag = '' then
    xmlNode := parentNode
  else begin
    xmlNode := parentNode.SelectSingleNode(nodeTag);
    if not assigned(xmlNode) then begin
      xmlNode := parentNode.OwnerDocument.CreateElement(nodeTag);
      parentNode.AppendChild(xmlNode);
    end;
  end;
  xmlChildClass := childClass;
  xmlChildTag   := childTag;
  xmlChildNodes := TObjectList.Create(true);
  csList := xmlNode.SelectNodes(childTag);
  csList.Reset;
  repeat
    csNode := csList.NextNode;
    if assigned(csNode) then begin
      childNode := childClass.Create(csNode);
      childNode.OwnerList := Self;
      xmlChildNodes.Add(childNode);
    end;
  until not assigned(csNode);
end; { TGpXMLList.Create }

{:Create standalone data object.
  @since   2002-12-26
}        
function TGpXMLList.CreateStandalone: TGpXMLData;
begin
  Result := xmlChildClass.Create;
end; { TGpXMLList.CreateStandalone }

{:Delete node from the list.
  @param   childNode Child node to be deleted.
}
procedure TGpXMLList.Delete(childNode: TGpXMLData);
var
  idx: integer;
begin
  idx := IndexOf(childNode);
  Assert(idx >= 0, 'Idx is <= 0 in TGpXMLList.Delete');
  if idx >= 0 then begin
    xmlNode.RemoveChild((xmlChildNodes[idx] as xmlChildClass).Node);
    xmlChildNodes.Delete(idx);
  end;
end; { TGpXMLList.Delete }

{:Destroy list.
}
destructor TGpXMLList.Destroy;
begin
  FreeAndNil(xmlChildNodes);
end; { TGpXMLList.Destroy }

{:Get idx-th child.
  @param   idx Index (0-based) of a child to be retrieved.
  @returns Child object.
}
function TGpXMLList.Get(idx: integer): TGpXMLData;
begin
  //Gp, 2002-12-26: I think this casting is not necessary as Get is only used from indexed accessors in derived classes which add this casting nevertheless
  Result := TGpXMLData(xmlChildNodes[idx]{ as xmlChildClass});
end; { TGpXMLList.Get }

{:Locate child node in the list.
  @param   childNode Child node to be located.
  @returns Index of the child node (0 based) or -1 if not found.
}
function TGpXMLList.IndexOf(childNode: TGpXMLData): integer;
var
  iChild: integer;
begin
  Result := -1;
  for iChild := 0 to Count-1 do begin
    if xmlChildNodes[iChild] = childNode then begin
      Result := iChild;
      break; //for
    end;
  end; //for
end; { TGpXMLList.IndexOf }

{ TGpXMLDoc }

{:Create a copy of the document.
  @param   doc Existing XML document object.
}
constructor TGpXMLDoc.Clone(doc: TGpXMLDoc);
begin
  Create(doc.RootTag);
  xmlXMLDoc.LoadXML(doc.XMLDoc.XML);
  CreateRootNode;
  RecreateChildren;
end; { TGpXMLDoc.Clone }

{:Create XML document object.
  @param   rootTag Name of the root tag.
}
constructor TGpXMLDoc.Create(rootTag: string);
begin
  xmlRootTag := rootTag;
  Reset;
end; { TGpXMLDoc.Create }

{:Create representation of the document that contains only persistent data.
  @since   2003-01-06
}        
function TGpXMLDoc.CreatePersistentClone: IXMLDocument;
begin
  if GetNodeAttrBool(xmlXMLDoc, CContainsVolatileAttr, false) or
     GetNodeAttrBool(xmlXMLDoc, CContainsPrivateAttr, false) then
  begin
    Result := CloneDocument(xmlXMLDoc, FilterNodes);
    Result.DocumentElement.Attributes.Clear;
  end
  else
    Result := xmlXMLDoc;
end; { TGpXMLDoc.CreatePersistentClone }

{:Create root node of the document if it doesn't already exist.
}
procedure TGpXMLDoc.CreateRootNode;
begin
  if not assigned(xmlXMLDoc.DocumentElement) then
    xmlXMLDoc.AppendChild(xmlXMLDoc.CreateElement(xmlRootTag));
  xmlNode := xmlXMLDoc.DocumentElement; 
end; { TGpXMLDoc.CreateRootNode }

function TGpXMLDoc.GetAsString: string;
var
  tmpDoc: IXMLDocument;
begin
  if GetNodeAttrBool(xmlXMLDoc, CContainsPrivateAttr, false) then
    tmpDoc := CloneDocument(xmlXMLDoc, FilterPrivateNodes)
  else
    tmpDoc := xmlXMLDoc;
  Result := XMLSaveToString(tmpDoc);
end; { TGpXMLDoc.GetAsString }

{:Return DocumentElement.
}
function TGpXMLDoc.GetXMLRoot: IXMLElement;
begin
  Result := xmlXMLDoc.DocumentElement;
end; { TGpXMLDoc.GetXMLRoot }

{:Load XML document from the persistent storage.
  @param   fileName Name of the external XML file.
  @returns False if file exists but document cannot be loaded. In that case,
           LastError property contains error message.
}
function TGpXMLDoc.LoadFromFile(const fileName: string): boolean;
begin
  xmlLastError := '';
  if not FileExists(fileName) then begin
    Reset;
    Result := true;
  end
  else begin
    try
      Result := XMLLoadFromFile(xmlXMLDoc, fileName);
      if not Result then
        xmlLastError := sXMLfileIsCorrupt;
    except
      on E: Exception do begin
        xmlLastError := E.Message;
        Result := false;
      end;
    end;
  end;
  if Result then begin
    CreateRootNode;
    RecreateChildren;
  end;
end; { TGpXMLDoc.LoadFromFile }

{$IFDEF MSWINDOWS}
{:Load XML document from the registry key.
  @param   rootKey Root registry key.
  @param   key     Registry key.
  @param   value   Registry value containing the string representation of the
                   XML document.
  @returns False if document cannot be loaded. In that case, LastError property
           contains error message.
}
function TGpXMLDoc.LoadFromRegistry(rootKey: HKEY; const key,
  value: string): boolean;
begin
  xmlLastError := '';
  try
    Result := XMLLoadFromRegistry(xmlXMLDoc, rootKey, key, value);
    if not Result then
      xmlLastError := sXMLfileIsCorrupt;
  except
    on E: Exception do begin
      xmlLastError := E.Message;
      Result := false;
    end;
  end;
  if Result then begin
    CreateRootNode;
    RecreateChildren;
  end;
end; { TGpXMLDoc.LoadFromRegistry }

{:Save XML document to the registry key.
  @param   rootKey Root registry key.
  @param   key     Registry key.
  @param   value   Registry value to contain the string representation of the
                   XML document.
  @returns False if document cannot be saved. In that case, LastError property
           contains error message.
}
function TGpXMLDoc.SaveToRegistry(rootKey: HKEY; const key, value: string;
  outputFormat: TOutputFormat): boolean;
var
  tmpXMLDoc: IXMLDocument;
begin
  xmlLastError := '';
  try
    tmpXMLDoc := CreatePersistentClone;
    Result := XMLSaveToRegistry(tmpXMLDoc, rootKey, key, value, outputFormat);
  except
    on E: Exception do begin
      xmlLastError := E.Message;
      Result := false;
    end;
  end;
end; { TGpXMLDoc.SaveToRegistry }
{$ENDIF}

{:Load XML document from the stream (from the current position).
  @param   stream Input stream.
  @returns False if document cannot be loaded. In that case, LastError property
           contains error message.
}
function TGpXMLDoc.LoadFromStream(stream: TStream): boolean;
begin
  xmlLastError := '';
  try
    Result := XMLLoadFromStream(xmlXMLDoc,stream);
    if not Result then
      xmlLastError := sXMLfileIsCorrupt;
  except
    on E: Exception do begin
      xmlLastError := E.Message;
      Result := false;
    end;
  end;
  if Result then begin
    CreateRootNode;
    RecreateChildren;
  end;
end; { TGpXMLDoc.LoadFromStream }

{:Load XML document from the string.
  @param   dataString XML document.
  @returns False if document cannot be loaded. In that case, LastError property
           contains error message.
}
function TGpXMLDoc.LoadFromString(const dataString: string): boolean;
begin
  xmlLastError := '';
  if dataString = '' then
    Result := true
  else try
    Result := XMLLoadFromString(xmlXMLDoc, dataString);
    if not Result then
      xmlLastError := sXMLfileIsCorrupt;
  except
    on E: Exception do begin
      xmlLastError := E.Message;
      Result := false;
    end;
  end;
  if Result then begin
    CreateRootNode;
    RecreateChildren;
  end
  else
    Reset;
end; { TGpXMLDoc.LoadFromString }

{:Recreate owned children objects. Do-nothing. Derived classes will typically
  override this method.
}
procedure TGpXMLDoc.RecreateChildren;
begin
end; { TGpXMLDoc.RecreateChildren }

{:Reset XML document to an empty state containing only root node.
}
procedure TGpXMLDoc.Reset;
begin
  xmlXMLDoc := CreateXMLDoc;
  CreateRootNode;
  RecreateChildren;
end; { TGpXMLDoc.Reset }

{:Save XML document to the persistent storage.
  @param   fileName Name of the external XML file.
  @returns False if document cannot be saved. In that case, LastError
           property contains error message.
}
function TGpXMLDoc.SaveToFile(const fileName: string;
  outputFormat: TOutputFormat): boolean;
var
  tmpXMLDoc: IXMLDocument;
begin
  xmlLastError := '';
  try
    tmpXMLDoc := CreatePersistentClone;
    XMLSaveToFile(tmpXMLDoc, fileName, outputFormat);
    Result := true;
  except
    on E: Exception do begin
      xmlLastError := E.Message;
      Result := false;
    end;
  end;
end; { TGpXMLDoc.SaveToFile}

{:Save XML document to the stream at the current position.
  @param   stream Output stream.
  @returns False if document cannot be saved. In that case, LastError
           property contains error message.
}
function TGpXMLDoc.SaveToStream(stream: TStream;
  outputFormat: TOutputFormat): boolean;
var
  tmpXMLDoc: IXMLDocument;
begin
  xmlLastError := '';
  try
    tmpXMLDoc := CreatePersistentClone;
    XMLSaveToStream(tmpXMLDoc, stream, outputFormat);
    Result := true;
  except
    on E: Exception do begin
      xmlLastError := E.Message;
      Result := false;
    end;
  end;
end; { TGpXMLDoc.SaveToStream }

{:Save XML document to the string.
  @param   stream (out) XML document.
  @returns False if document cannot be saved. In that case, LastError property
           contains error message.
}
function TGpXMLDoc.SaveToString(var dataString: string;
  outputFormat: TOutputFormat): boolean;
var
  tmpXMLDoc: IXMLDocument;
begin
  xmlLastError := '';
  try
    tmpXMLDoc := CreatePersistentClone;
    dataString := XMLSaveToString(tmpXMLDoc, outputFormat);
    Result := true;
  except
    on E: Exception do begin
      xmlLastError := E.Message;
      Result := false;
    end;
  end;
end; { TGpXMLDoc.SaveToString }

procedure TGpXMLDoc.SetAsString(const Value: string);
begin
  LoadFromString(Value);
end; { TGpXMLDoc.SetAsString }

{ TGpXMLDocList }

function TGpXMLDocList.Add: TGpXMLData;
begin
  Result := xmlList.Add;
end; { TGpXMLDocList.Add }

procedure TGpXMLDocList.Clear;
begin
  xmlList.Clear;
end; { TGpXMLDocList.Clear }

function TGpXMLDocList.Count: integer;
begin
  Result := xmlList.Count;
end; { TGpXMLDocList.Count }

constructor TGpXMLDocList.Create(rootTag, listTag, childTag: string;
  childClass: TGpXMLDataClass);
begin
  xmlListTag := listTag;
  xmlChildTag := childTag;
  xmlChildClass := childClass;
  inherited Create(rootTag);
end; { TGpXMLDocList.Create }

procedure TGpXMLDocList.Delete(childNode: TGpXMLData);
begin
  xmlList.Delete(childNode);
end; { TGpXMLDocList.Delete }

destructor TGpXMLDocList.Destroy;
begin
  FreeAndNil(xmlList);
  inherited;
end; { TGpXMLDocList.Destroy }

function TGpXMLDocList.Get(idx: integer): TGpXMLData;
begin
  Result := xmlList.Get(idx);
end; { TGpXMLDocList.Get }

function TGpXMLDocList.GetNode: IXMLNode;
begin
  Result := xmlList.Node;
end; { TGpXMLDocList.GetNode }

function TGpXMLDocList.IndexOf(childNode: TGpXMLData): integer;
begin
  Result := xmlList.IndexOf(childNode);
end; { TGpXMLDocList.IndexOf }

procedure TGpXMLDocList.RecreateChildren;
begin
  FreeAndNil(xmlList);
  xmlList := TGpXMLList.Create(XMLRoot, xmlListTag, xmlChildTag, xmlChildClass);
end; { TGpXMLDocList.RecreateChildren }

end.
