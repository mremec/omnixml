(*******************************************************************************
* The contents of this file are subject to the Mozilla Public License Version  *
* 1.1 (the "License"); you may not use this file except in compliance with the *
* License. You may obtain a copy of the License at http://www.mozilla.org/MPL/ *
*                                                                              *
* Software distributed under the License is distributed on an "AS IS" basis,   *
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for *
* the specific language governing rights and limitations under the License.    *
*                                                                              *
* The Original Code is OmniXML.pas                                             *
*                                                                              *
* The Initial Developer of the Original Code is Miha Remec                     *
*   http://www.MihaRemec.com/                                                  *
*                                                                              *
* Contributor(s):                                                              *
*   Primoz Gabrijelcic (gp)                                                    *
*   Erik Berry (eb)                                                            *
*   Ondrej Pokorny (op)                                                        *
*******************************************************************************)
unit OmniXML;

interface

{$I OmniXML.inc}

{$IFDEF OmniXML_HasZeroBasedStrings}
  {$ZEROBASEDSTRINGS OFF}
{$ENDIF}

uses
  {$IFDEF OmniXML_Namespaces}
  System.Classes, System.SysUtils,
  {$ELSE}
  Classes, SysUtils,
  {$ENDIF}
  OEncoding, OTextReadWrite, OmniXML_Types, OmniXML_Dictionary
  {$IFDEF OmniXML_Generics}, Generics.Collections{$ENDIF}
  ;

const
  DEFAULT_DECIMALSEPARATOR  = '.';        // don't change!
  DEFAULT_TRUE              = '1';        // don't change!
  DEFAULT_FALSE             = '0';        // don't change!
  DEFAULT_DATETIMESEPARATOR = 'T';        // don't change!
  DEFAULT_DATESEPARATOR     = '-';        // don't change!
  DEFAULT_TIMESEPARATOR     = ':';        // don't change!
  DEFAULT_MSSEPARATOR       = '.';        // don't change!

const
  // element node
  ELEMENT_NODE = 1;
  // attribute node
  ATTRIBUTE_NODE = 2;
  // text node
  TEXT_NODE = 3;
  // CDATA section node
  CDATA_SECTION_NODE = 4;
  // entity reference node
  ENTITY_REFERENCE_NODE = 5;
  // entity node
  ENTITY_NODE = 6;
  // processing instruction node
  PROCESSING_INSTRUCTION_NODE = 7;
  // comment node
  COMMENT_NODE = 8;
  // document node
  DOCUMENT_NODE = 9;
  // document type node
  DOCUMENT_TYPE_NODE = 10;
  // document fragment node
  DOCUMENT_FRAGMENT_NODE = 11;
  // notation node
  NOTATION_NODE = 12;

type
  TNodeType = 1..12;

const
  // these codes are part of Exception codes

  // W3C DOM Level 1
  // index or size is negative, or greater than the allowed value
  INDEX_SIZE_ERR = 1;
  // the specified range of text does not fit into a DOMString
  DOMSTRING_SIZE_ERR = 2;
  // any node is inserted somewhere it doesn't belong
  HIERARCHY_REQUEST_ERR = 3;
  // a node is used in a different document than the one that created it (that doesn't support it)
  WRONG_DOCUMENT_ERR = 4;
  // an invalid character is specified, such as in a name
  INVALID_CHARACTER_ERR = 5;
  // data is specified for a node which does not support data
  NO_DATA_ALLOWED_ERR = 6;
  // an attempt is made to modify an object where modifications are not allowed
  NO_MODIFICATION_ALLOWED_ERR = 7;
  // an attempt was made to reference a node in a context where it does not exist
  NOT_FOUND_ERR = 8;
  // the implementation does not support the type of object requested
  NOT_SUPPORTED_ERR = 9;
  // an attempt is made to add an attribute that is already in use elsewhere
  INUSE_ATTRIBUTE_ERR = 10;

  // W3C DOM Level 2
  // an attempt is made to use an object that is not, or is no longer, usable
  INVALID_STATE_ERR = 11;
  // an invalid or illegal string is specified
  SYNTAX_ERR = 12;
  // an attempt is made to modify the type of the underlying object
  INVALID_MODIFICATION_ERR = 13;
  // an attempt is made to create or change an object in a way which is incorrect with regard to namespaces
  NAMESPACE_ERR = 14;
  // parameter or an operation is not supported by the underlying object
  INVALID_ACCESS_ERR = 15;

const
  MSG_E_NOTEXT = $0000;
  MSG_E_BASE = $0001;
  MSG_E_FORMATINDEX_BADINDEX = MSG_E_BASE + 0;
  MSG_E_FORMATINDEX_BADFORMAT = MSG_E_BASE + 1;
  MSG_E_SYSTEM_ERROR = MSG_E_BASE + 2;
  MSG_E_MISSINGEQUALS = MSG_E_BASE + 3;
  MSG_E_EXPECTED_TOKEN = MSG_E_BASE + 4;
  MSG_E_UNEXPECTED_TOKEN = MSG_E_BASE + 5;
  MSG_E_MISSINGQUOTE = MSG_E_BASE + 6;
  MSG_E_COMMENTSYNTAX = MSG_E_BASE + 7;
  MSG_E_BADSTARTNAMECHAR = MSG_E_BASE + 8;
  MSG_E_BADNAMECHAR = MSG_E_BASE + 9;
  MSG_E_BADCHARINSTRING = MSG_E_BASE + 10;
  MSG_E_XMLDECLSYNTAX = MSG_E_BASE + 11;
  MSG_E_BADCHARDATA = MSG_E_BASE + 12;
  MSG_E_MISSINGWHITESPACE = MSG_E_BASE + 13;
  MSG_E_EXPECTINGTAGEND = MSG_E_BASE + 14;
  MSG_E_BADCHARINDTD = MSG_E_BASE + 15;
  MSG_E_BADCHARINDECL = MSG_E_BASE + 16;
  MSG_E_MISSINGSEMICOLON = MSG_E_BASE + 17;
  MSG_E_BADCHARINENTREF = MSG_E_BASE + 18;
  MSG_E_UNBALANCEDPAREN = MSG_E_BASE + 19;
  MSG_E_EXPECTINGOPENBRACKET = MSG_E_BASE + 20;
  MSG_E_BADENDCONDSECT = MSG_E_BASE + 21;
  MSG_E_INTERNALERROR = MSG_E_BASE + 22;
  MSG_E_UNEXPECTED_WHITESPACE = MSG_E_BASE + 23;
  MSG_E_INCOMPLETE_ENCODING = MSG_E_BASE + 24;
  MSG_E_BADCHARINMIXEDMODEL = MSG_E_BASE + 25;
  MSG_E_MISSING_STAR = MSG_E_BASE + 26;
  MSG_E_BADCHARINMODEL = MSG_E_BASE + 27;
  MSG_E_MISSING_PAREN = MSG_E_BASE + 28;
  MSG_E_BADCHARINENUMERATION = MSG_E_BASE + 29;
  MSG_E_PIDECLSYNTAX = MSG_E_BASE + 30;
  MSG_E_EXPECTINGCLOSEQUOTE = MSG_E_BASE + 31;
  MSG_E_MULTIPLE_COLONS = MSG_E_BASE + 32;
  MSG_E_INVALID_DECIMAL = MSG_E_BASE + 33;
  MSG_E_INVALID_HEXADECIMAL = MSG_E_BASE + 34;
  MSG_E_INVALID_UNICODE = MSG_E_BASE + 35;
  MSG_E_WHITESPACEORQUESTIONMARK = MSG_E_BASE + 36;
  MSG_E_SUSPENDED = MSG_E_BASE + 37;
  MSG_E_STOPPED = MSG_E_BASE + 38;
  MSG_E_UNEXPECTEDENDTAG = MSG_E_BASE + 39;
  MSG_E_UNCLOSEDTAG = MSG_E_BASE + 40;
  MSG_E_DUPLICATEATTRIBUTE = MSG_E_BASE + 41;
  MSG_E_MULTIPLEROOTS = MSG_E_BASE + 42;
  MSG_E_INVALIDATROOTLEVEL = MSG_E_BASE + 43;
  MSG_E_BADXMLDECL = MSG_E_BASE + 44;
  MSG_E_MISSINGROOT = MSG_E_BASE + 45;
  MSG_E_UNEXPECTEDEOF = MSG_E_BASE + 46;
  MSG_E_BADPEREFINSUBSET = MSG_E_BASE + 47;
  MSG_E_PE_NESTING = MSG_E_BASE + 48;
  MSG_E_INVALID_CDATACLOSINGTAG = MSG_E_BASE + 49;
  MSG_E_UNCLOSEDPI = MSG_E_BASE + 50;
  MSG_E_UNCLOSEDSTARTTAG = MSG_E_BASE + 51;
  MSG_E_UNCLOSEDENDTAG = MSG_E_BASE + 52;
  MSG_E_UNCLOSEDSTRING = MSG_E_BASE + 53;
  MSG_E_UNCLOSEDCOMMENT = MSG_E_BASE + 54;
  MSG_E_UNCLOSEDDECL = MSG_E_BASE + 55;
  MSG_E_UNCLOSEDMARKUPDECL = MSG_E_BASE + 56;
  MSG_E_UNCLOSEDCDATA = MSG_E_BASE + 57;
  MSG_E_BADDECLNAME = MSG_E_BASE + 58;
  MSG_E_BADEXTERNALID = MSG_E_BASE + 59;
  MSG_E_BADELEMENTINDTD = MSG_E_BASE + 60;
  MSG_E_RESERVEDNAMESPACE = MSG_E_BASE + 61;
  MSG_E_EXPECTING_VERSION = MSG_E_BASE + 62;
  MSG_E_EXPECTING_ENCODING = MSG_E_BASE + 63;
  MSG_E_EXPECTING_NAME = MSG_E_BASE + 64;
  MSG_E_UNEXPECTED_ATTRIBUTE = MSG_E_BASE + 65;
  MSG_E_ENDTAGMISMATCH = MSG_E_BASE + 66;
  MSG_E_INVALIDENCODING = MSG_E_BASE + 67;
  MSG_E_INVALIDSWITCH = MSG_E_BASE + 68;
  MSG_E_EXPECTING_NDATA = MSG_E_BASE + 69;
  MSG_E_INVALID_MODEL = MSG_E_BASE + 70;
  MSG_E_INVALID_TYPE = MSG_E_BASE + 71;
  MSG_E_INVALIDXMLSPACE = MSG_E_BASE + 72;
  MSG_E_MULTI_ATTR_VALUE = MSG_E_BASE + 73;
  MSG_E_INVALID_PRESENCE = MSG_E_BASE + 74;
  MSG_E_BADXMLCASE = MSG_E_BASE + 75;
  MSG_E_CONDSECTINSUBSET = MSG_E_BASE + 76;
  MSG_E_CDATAINVALID = MSG_E_BASE + 77;
  MSG_E_INVALID_STANDALONE = MSG_E_BASE + 78;
  MSG_E_UNEXPECTED_STANDALONE = MSG_E_BASE + 79;
  MSG_E_DOCTYPE_IN_DTD = MSG_E_BASE + 80;
  MSG_E_MISSING_ENTITY = MSG_E_BASE + 81;
  MSG_E_ENTITYREF_INNAME = MSG_E_BASE + 82;
  MSG_E_DOCTYPE_OUTSIDE_PROLOG = MSG_E_BASE + 83;
  MSG_E_INVALID_VERSION = MSG_E_BASE + 84;
  MSG_E_DTDELEMENT_OUTSIDE_DTD = MSG_E_BASE + 85;
  MSG_E_DUPLICATEDOCTYPE = MSG_E_BASE + 86;
  MSG_E_RESOURCE = MSG_E_BASE + 87;
  MSG_E_INVALID_OPERATION = MSG_E_BASE + 88;
  MSG_E_WRONG_DOCUMENT = MSG_E_BASE + 89;

  XML_BASE = MSG_E_BASE + 90;
  XML_IOERROR = XML_BASE + 0;
  XML_ENTITY_UNDEFINED = XML_BASE + 1;
  XML_INFINITE_ENTITY_LOOP = XML_BASE + 2;
  XML_NDATA_INVALID_PE = XML_BASE + 3;
  XML_REQUIRED_NDATA = XML_BASE + 4;
  XML_NDATA_INVALID_REF = XML_BASE + 5;
  XML_EXTENT_IN_ATTR = XML_BASE + 6;
  XML_STOPPED_BY_USER = XML_BASE + 7;
  XML_PARSING_ENTITY = XML_BASE + 8;
  XML_E_MISSING_PE_ENTITY = XML_BASE + 9;
  XML_E_MIXEDCONTENT_DUP_NAME = XML_BASE + 10;
  XML_NAME_COLON = XML_BASE + 11;
  XML_ELEMENT_UNDECLARED = XML_BASE + 12;
  XML_ELEMENT_ID_NOT_FOUND = XML_BASE + 13;
  XML_DEFAULT_ATTRIBUTE = XML_BASE + 14;
  XML_XMLNS_RESERVED = XML_BASE + 15;
  XML_EMPTY_NOT_ALLOWED = XML_BASE + 16;
  XML_ELEMENT_NOT_COMPLETE = XML_BASE + 17;
  XML_ROOT_NAME_MISMATCH = XML_BASE + 18;
  XML_INVALID_CONTENT = XML_BASE + 19;
  XML_ATTRIBUTE_NOT_DEFINED = XML_BASE + 20;
  XML_ATTRIBUTE_FIXED = XML_BASE + 21;
  XML_ATTRIBUTE_VALUE = XML_BASE + 22;
  XML_ILLEGAL_TEXT = XML_BASE + 23;
  XML_MULTI_FIXED_VALUES = XML_BASE + 24;
  XML_NOTATION_DEFINED = XML_BASE + 25;
  XML_ELEMENT_DEFINED = XML_BASE + 26;
  XML_ELEMENT_UNDEFINED = XML_BASE + 27;
  XML_XMLNS_UNDEFINED = XML_BASE + 28;
  XML_XMLNS_FIXED = XML_BASE + 29;
  XML_E_UNKNOWNERROR = XML_BASE + 30;
  XML_REQUIRED_ATTRIBUTE_MISSING = XML_BASE + 31;
  XML_MISSING_NOTATION = XML_BASE + 32;
  XML_ATTLIST_DUPLICATED_ID = XML_BASE + 33;
  XML_ATTLIST_ID_PRESENCE = XML_BASE + 34;
  XML_XMLLANG_INVALIDID = XML_BASE + 35;
  XML_PUBLICID_INVALID = XML_BASE + 36;
  XML_DTD_EXPECTING = XML_BASE + 37;
  XML_NAMESPACE_URI_EMPTY = XML_BASE + 38;
  XML_LOAD_EXTERNALENTITY = XML_BASE + 39;
  XML_BAD_ENCODING = XML_BASE + 40;

type
  EXMLException = class(Exception)
  private
    FDOMCode: Integer;
    FXMLCode: Integer;
  public
    property DOMCode: Integer read FDOMCode;
    property XMLCode: Integer read FXMLCode;
    constructor CreateParseError(const DOMCode, XMLCode: Integer; const Args: array of const);
  end;

{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{                                                                             }
{         S T A R T   O F   I N T E R F A C E   D E C L A R A T I O N         }
{                                                                             }
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }


type
  TOutputFormat = (ofNone, ofFlat, ofIndent);
  IUnicodeStream = interface
    ['{F3ECA11F-EA18-491C-B59A-4203D5DC8CCA}']
    // private
    function GetEncoding: TEncoding;
    procedure SetEncoding(const AEncoding: TEncoding);
    function GetBOMFound: Boolean;
    function GetOutputFormat: TOutputFormat;
    procedure SetOutputFormat(const Value: TOutputFormat);
    // public
    procedure IncreaseIndent;
    procedure DecreaseIndent;
    procedure WriteIndent(const ForceNextLine: Boolean = False);
    property OutputFormat: TOutputFormat read GetOutputFormat write SetOutputFormat;
    property Encoding: TEncoding read GetEncoding write SetEncoding;
    property BOMFound: Boolean read GetBOMFound;
    procedure UndoRead;
    function ProcessChar(var Char: XmlChar): Boolean;
    function GetNextString(var ReadString: XmlString; const Len: Integer): Boolean;
    procedure WriteOutputChar(const OutChar: XmlChar);
    function GetOutputBuffer: XmlString;
    function OutputBufferLen: Integer;
    procedure ClearOutputBuffer;
    procedure WriteString(const Value: XmlString);
  end;

type
  TStreamMode = (smRead, smWrite);

  TXMLTextStream = class(TInterfacedObject, IUnicodeStream)
  private
    FStreamMode: TStreamMode;
    FReader: TOTextReader;
    FWriter: TOTextWriter;
    FPreviousOutBuffer: XmlString;
    FOutBuffer: PXmlChar;
    FOutBufferPos,
    FOutBufferSize: Integer;
    FIndent: Integer;
    FOutputFormat: TOutputFormat;
    fBOMFound: Boolean;
    function GetEncoding: TEncoding;
    procedure SetEncoding(const AEncoding: TEncoding);
    function GetBOMFound: Boolean;
    function GetOutputFormat: TOutputFormat;
    procedure SetOutputFormat(const Value: TOutputFormat);
  protected
    FStream: TStream;
    FEOF: Boolean;
    function ReadChar(var ReadChar: XmlChar): Boolean; virtual;
    function ProcessChar(var ch: XmlChar): Boolean; virtual;
    procedure IncreaseIndent;
    procedure DecreaseIndent;
    procedure WriteIndent(const ForceNextLine: Boolean = False);
    // helper functions
    function GetPreviousOutputBuffer: XmlString;
  public
    property OutputFormat: TOutputFormat read GetOutputFormat write SetOutputFormat;
    property Encoding: TEncoding read GetEncoding write SetEncoding;
    property BOMFound: Boolean read GetBOMFound;
    constructor Create(const Stream: TStream; const Mode: TStreamMode; const Encoding: TEncoding; const WriteBOM: Boolean);
    destructor Destroy; override;
    procedure UndoRead; virtual;
    function GetNextString(var ReadString: XmlString; const Len: Integer): Boolean;
    procedure WriteOutputChar(const OutChar: XmlChar);
    function GetOutputBuffer: XmlString;
    function OutputBufferLen: Integer;
    procedure ClearOutputBuffer;
    procedure WriteString(const Value: XmlString);
  end;

  IXMLParseError = interface
    ['{546E9AE4-4E1E-4014-B0B8-4F024C797544}']
    // private
    function GetErrorCode: Integer;
    function GetFilePos: Integer;
    function GetLine: Integer;
    function GetLinePos: Integer;
    function GetSrcTextPos: Integer;
    function GetReason: string;
    function GetSrcText: XmlString;
    function GetURL: string;
    // public
    property ErrorCode: Integer read GetErrorCode;
    property FilePos: Integer read GetFilePos;
    property Line: Integer read GetLine;//1-based
    property LinePos: Integer read GetLinePos;//1-based
    property Reason: string read GetReason;
    property SrcText: XmlString read GetSrcText;
    property SrcTextPos: Integer read GetSrcTextPos;//1-based, position of error in SrcText
    property URL: string read GetURL;
  end;

  IXMLElement = interface;
  IXMLDocument = interface;
  IXMLNodeList = interface;
  IXMLNamedNodeMap = interface;

  IXMLNode = interface
    ['{F4D7D3DE-C6EC-4191-8E35-F652C2705E81}']
    // private
    function GetAttributes: IXMLNamedNodeMap;
    function GetChildNodes: IXMLNodeList;
    function GetFirstChild: IXMLNode;
    function GetLastChild: IXMLNode;
    function GetNextSibling: IXMLNode;
    function GetNodeName: XmlString;
    function GetNodeType: TNodeType;
    function GetNodeValue: XmlString;
    function GetOwnerDocument: IXMLDocument;
    function GetParentNode: IXMLNode;
    function GetPreviousSibling: IXMLNode;
    procedure SetNodeValue(const Value: XmlString);
    procedure SetParentNode(const Parent: IXMLNode);
    // public
    function InsertBefore(const NewChild, RefChild: IXMLNode): IXMLNode;
    function ReplaceChild(const NewChild, OldChild: IXMLNode): IXMLNode;
    function RemoveChild(const OldChild: IXMLNode): IXMLNode;
    function AppendChild(const NewChild: IXMLNode): IXMLNode;
    function HasChildNodes: Boolean;
    function CloneNode(const Deep: Boolean): IXMLNode;

    procedure SetCachedNodeIndex(const Index: integer);

    property NodeName: XmlString read GetNodeName;
    property NodeValue: XmlString read GetNodeValue write SetNodeValue;
    property NodeType: TNodeType read GetNodeType;
    property ParentNode: IXMLNode read GetParentNode;
    property ChildNodes: IXMLNodeList read GetChildNodes;
    property FirstChild: IXMLNode read GetFirstChild;
    property LastChild: IXMLNode read GetLastChild;
    property PreviousSibling: IXMLNode read GetPreviousSibling;
    property NextSibling: IXMLNode read GetNextSibling;
    property Attributes: IXMLNamedNodeMap read GetAttributes;
    property OwnerDocument: IXMLDocument read GetOwnerDocument;

    // MS (non-standard) extensions
    function GetText: XmlString;
    procedure SetText(const Value: XmlString);
    property Text: XmlString read GetText write SetText;
    procedure WriteToStream(const OutputStream: IUnicodeStream);
    procedure SelectSingleNode(Pattern: string; var Result: IXMLNode); overload;
    function SelectSingleNode(Pattern: string): IXMLNode; overload;
    procedure SelectNodes(Pattern: string; var Result: IXMLNodeList); overload;
    function SelectNodes(Pattern: string): IXMLNodeList; overload;
    function GetXML: XmlString;
    property XML: XmlString read GetXML;
  end;

  IXMLCustomList = interface
    ['{6520A0BC-8738-4E40-8CDB-33713DED32ED}']
    // protected
    function GetLength: Integer;
    function GetItem(const Index: Integer): IXMLNode;
    procedure MakeChildrenCacheSiblings(const Value: boolean);
    // public
    property Item[const Index: Integer]: IXMLNode read GetItem;
    property Length: Integer read GetLength;
    function Add(const XMLNode: IXMLNode): Integer;
    function IndexOf(const XMLNode: IXMLNode): Integer;
    procedure Insert(const Index: Integer; const XMLNode: IXMLNode);
    function Remove(const XMLNode: IXMLNode): Integer;
    procedure Delete(const Index: Integer);
    procedure Clear;
  end;

  IXMLNodeList = interface(IXMLCustomList)
    ['{66AF674E-4697-4356-ACCC-4258DA138EA1}']
    // public
    function AddNode(const Arg: IXMLNode): IXMLNode;
    // MS (non-standard) extensions
    procedure Reset;
    function NextNode: IXMLNode;
  end;

  IXMLNamedNodeMap = interface(IXMLCustomList)
    ['{87964B1D-F6CC-46D2-A602-67E198C8BFF5}']
    // public
    function GetNamedItem(const Name: XmlString): IXMLNode;
    function SetNamedItem(const Arg: IXMLNode): IXMLNode;
    function RemoveNamedItem(const Name: XmlString): IXMLNode;
  end;

  { TODO -omr : re-add after IXMLDocumentType will be properly supported }
(*
  IXMLDocumentType = interface(IXMLNode)
    ['{881517D3-A2F5-4AF0-8A3D-5A57D2C77ED9}']
    // private
    function GetEntities: IXMLNamedNodeMap;
    function GetName: XmlString;
    function GetNotations: IXMLNamedNodeMap;
    // public
    property Name: XmlString read GetName;
    property Entities: IXMLNamedNodeMap read GetEntities;
    property Notations: IXMLNamedNodeMap read GetNotations;
  end;
*)

  IXMLDocumentFragment = interface(IXMLNode)
    ['{A21A11BF-E489-4416-9607-172EFA2CFE45}']
  end;

  IXMLCharacterData = interface(IXMLNode)
    ['{613A6538-A0DC-49BC-AFA6-D8E611176B86}']
    // private
    function GetData: XmlString;
    function GetLength: Integer;
    procedure SetData(const Value: XmlString);
    // public
    property Data: XmlString read GetData write SetData;
    property Length: Integer read GetLength;
    function SubstringData(const Offset, Count: Integer): XmlString;
    procedure AppendData(const Arg: XmlString);
    procedure InsertData(const Offset: Integer; const Arg: XmlString);
    procedure DeleteData(const Offset, Count: Integer);
    procedure ReplaceData(const Offset, Count: Integer; const Arg: XmlString);
  end;

  IXMLText = interface(IXMLCharacterData)
    ['{0EC46ED2-AB58-4DC9-B964-965615248564}']
    // public
    function SplitText(const Offset: Integer): IXMLText;
  end;

  IXMLComment = interface(IXMLCharacterData)
    ['{B094A54C-039F-4ED7-9331-F7CF5A711EDA}']
  end;

  IXMLCDATASection = interface(IXMLText)
    ['{CF58778D-775D-4299-884C-F1DC61925D54}']
  end;

  IXMLDocumentType = interface(IXMLText)
    ['{E956F945-E8F6-4589-BF8D-D4DC23DE1089}']
  end;

  IXMLProcessingInstruction = interface(IXMLNode)
    ['{AF449E32-2615-4EF7-82B6-B2E9DCCE9FC3}']
    // private
    function GetData: XmlString;
    function GetTarget: XmlString;
    // public
    property Target: XmlString read GetTarget;
    property Data: XmlString read GetData;
  end;

  IXMLAttr = interface(IXMLNode)
    ['{10796B8E-FBAC-4ADF-BDD8-E4BBC5A5196F}']
    // private
    function GetName: XmlString;
    function GetSpecified: Boolean;
    function GetValue: XmlString;
    procedure SetValue(const Value: XmlString);
    // public
    property Name: XmlString read GetName;
    property Specified: Boolean read GetSpecified;
    property Value: XmlString read GetValue write SetValue;
  end;

  IXMLEntityReference = interface(IXMLNode)
    ['{4EC18B2B-BD52-464D-BAD1-1FBE2C445989}']
  end;

  IXMLDocument = interface(IXMLNode)
    ['{59A76970-451C-4343-947C-242EFF17413C}']
    // private
    function GetDocType: IXMLDocumentType;
    { TODO -omr : re-add after IXMLDocumentType will be properly supported }
//    procedure SetDocType(const Value: IXMLDocumentType);
    function GetDocumentElement: IXMLElement;
    procedure SetDocumentElement(const Value: IXMLElement);
    function GetPreserveWhiteSpace: Boolean;
    procedure SetPreserveWhiteSpace(const Value: Boolean);
    // public
    property DocType: IXMLDocumentType read GetDocType;
    property DocumentElement: IXMLElement read GetDocumentElement write SetDocumentElement;
    property PreserveWhiteSpace: Boolean read GetPreserveWhiteSpace write SetPreserveWhiteSpace;
    function CreateAttribute(const Name: XmlString): IXMLAttr;
    function CreateCDATASection(const Data: XmlString): IXMLCDATASection;
    function CreateComment(const Data: XmlString): IXMLComment;
    function CreateDocType(const Data: XmlString): IXMLDocumentType;
    function CreateDocumentFragment: IXMLDocumentFragment;
    function CreateElement(const TagName: XmlString): IXMLElement;
    function CreateEntityReference(const Name: XmlString): IXMLEntityReference;
    function CreateProcessingInstruction(const Target, Data: XmlString): IXMLProcessingInstruction;
    function CreateTextNode(const Data: XmlString): IXMLText;
    function GetElementsByTagName(const TagName: XmlString): IXMLNodeList;

    // MS (non-standard) extensions
    function Load(const FileName: string): Boolean;
    function LoadFromStream(const Stream: TStream): Boolean;
    procedure Save(const FileName: string; const OutputFormat: TOutputFormat = ofNone);
    procedure SaveToStream(const OutputStream: TStream; const OutputFormat: TOutputFormat = ofNone);
    function LoadXML(const XML: XmlString): Boolean;
    function GetParseError: IXMLParseError;
    property ParseError: IXMLParseError read GetParseError;
  end;

  IXMLElement = interface(IXMLNode)
    ['{C858C4E1-FB3F-4C98-8BDE-671E060D17B9}']
    // private
    function GetTagName: XmlString;
    // public
    property TagName: XmlString read GetTagName;
    function GetAttribute(const Name: XmlString): XmlString;
    procedure SetAttribute(const Name, Value: XmlString);
    procedure RemoveAttribute(const Name: XmlString);
    function GetAttributeNode(const Name: XmlString): IXMLAttr;
    function SetAttributeNode(const NewAttr: IXMLAttr): IXMLAttr;
    function RemoveAttributeNode(const OldAttr: IXMLAttr): IXMLAttr;
    function GetElementsByTagName(const Name: XmlString): IXMLNodeList;
    procedure Normalize;
  end;

{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{                                                                             }
{          E N D   O F   I N T E R F A C E   D E C L A R A T I O N            }
{                                                                             }
{                                                                             }
{      S T A R T   O F   I N T E R F A C E   I M P L E M E N T A T I O N      }
{                                                                             }
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }

type
  TXMLParseError = class(TInterfacedObject, IXMLParseError)
  private
    FErrorCode: Integer;
    FFilePos: Integer;
    FLine: Integer;
    FLinePos: Integer;
    FReason: string;
    FSrcText: XmlString;
    FSrcTextPos: Integer;
    FURL: string;
    function GetErrorCode: Integer;
    function GetFilePos: Integer;
    function GetLine: Integer;
    function GetLinePos: Integer;
    function GetSrcTextPos: Integer;
    function GetReason: string;
    function GetSrcText: XmlString;
    function GetURL: string;
  protected
    procedure SetErrorCode(const ErrorCode: Integer);
    procedure SetFilePos(const FilePos: Integer);
    procedure SetLine(const Line: Integer);
    procedure SetLinePos(const LinePos: Integer);
    procedure SetReason(const Reason: string);
    procedure SetSrcText(const SrcTextBefore, SrcTextAfter: XmlString);
    procedure SetURL(const URL: string);
  public
    property ErrorCode: Integer read GetErrorCode;
    property FilePos: Integer read GetFilePos;
    property Line: Integer read GetLine;
    property LinePos: Integer read GetLinePos;
    property Reason: string read GetReason;
    property SrcText: XmlString read GetSrcText;
    property SrcTextPos: Integer read GetSrcTextPos;
    property URL: string read GetURL;
  end;

  TXMLNodeList = class;
  TXMLNamedNodeMap = class;
  TXMLDocument = class;
  TXMLAttr = class;
  TXMLElement = class;
  TXMLText = class;
  TXMLComment = class;
  TXMLCDATASection = class;
  TXMLProcessingInstruction = class;

  TXMLNode = class(TInterfacedObject, IXMLNode)
  protected
    {$IFDEF AUTOREFCOUNT} [weak] {$ENDIF} FOwnerDocument: TXMLDocument;
    FNodeType: TNodeType;
    FAttributes: IXMLNamedNodeMap;
    FChildNodes: IXMLNodeList;
    FParentNode: IXMLNode;
    FNodeValueId: TDicId;
    FCachedNodeIndex:  integer;  // < 0 if non-cached hence unknown

    procedure ClearChildNodes;
    function HasAttributes: Boolean;
    function GetAttributes: IXMLNamedNodeMap;
    function GetChildNodes: IXMLNodeList;
    function GetFirstChild: IXMLNode;
    function GetLastChild: IXMLNode;
    function GetNextSibling: IXMLNode;
    function GetNodeName: XmlString; virtual; abstract; 
    function GetNodeType: TNodeType;
    function GetNodeValue: XmlString; virtual;
    function GetOwnerDocument: IXMLDocument; virtual;
    function GetParentNode: IXMLNode;
    function GetPreviousSibling: IXMLNode;
    procedure SetNodeValue(const Value: XmlString); virtual;
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); virtual;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); virtual;
    procedure SetParentNode(const Parent: IXMLNode);
    function GetText: XmlString; virtual;
    procedure SetText(const Value: XmlString); virtual;
    function GetXML: XmlString;
    procedure SelectNodes(Pattern: string; var Result: IXMLNodeList); overload; virtual;
    procedure SelectSingleNode(Pattern: string; var Result: IXMLNode); overload; virtual;

    procedure SetCachedNodeIndex(const Index: integer);
  public
    Dictionary: TDictionary;
    property NodeName: XmlString read GetNodeName;
    property NodeValue: XmlString read GetNodeValue write SetNodeValue;
    property NodeType: TNodeType read GetNodeType;
    property ParentNode: IXMLNode read GetParentNode;
    property ChildNodes: IXMLNodeList read GetChildNodes;
    property FirstChild: IXMLNode read GetFirstChild;
    property LastChild: IXMLNode read GetLastChild;
    property PreviousSibling: IXMLNode read GetPreviousSibling;
    property NextSibling: IXMLNode read GetNextSibling;
    property Attributes: IXMLNamedNodeMap read GetAttributes;
    property OwnerDocument: IXMLDocument read GetOwnerDocument;
    property Text: XmlString read GetText write SetText;
    constructor Create(const AOwnerDocument: TXMLDocument);
    destructor Destroy; override;
    function InsertBefore(const NewChild, RefChild: IXMLNode): IXMLNode;
    function ReplaceChild(const NewChild, OldChild: IXMLNode): IXMLNode;
    function RemoveChild(const OldChild: IXMLNode): IXMLNode;
    function AppendChild(const NewChild: IXMLNode): IXMLNode;
    function HasChildNodes: Boolean;
    function CloneNode(const Deep: Boolean): IXMLNode; virtual;
    procedure WriteToStream(const OutputStream: IUnicodeStream);
    function SelectNodes(Pattern: string): IXMLNodeList; overload; virtual;
    function SelectSingleNode(Pattern: string): IXMLNode; overload; virtual;
    property XML: XmlString read GetXML;
  end;

  { TODO -omr : re-add after IXMLDocumentType will be properly supported }
(*
  TXMLDocumentType = class(TXMLNode, IXMLNode)
  private
    function GetEntities: IXMLNamedNodeMap;
    function GetName: XmlString;
    function GetNotations: IXMLNamedNodeMap;
  public
    property Name: XmlString read GetName;
    property Entities: IXMLNamedNodeMap read GetEntities;
    property Notations: IXMLNamedNodeMap read GetNotations;
  end;
*)

  TXMLEntityReference = class(TXMLNode, IXMLEntityReference);

  TXMLDocumentFragment = class(TXMLNode, IXMLDocumentFragment)
  protected
    function GetNodeName: XmlString; override;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
  public
    constructor Create(const OwnerDocument: TXMLDocument);
  end;

  TXMLCustomList = class(TInterfacedObject, IXMLCustomList)
  private
    {$IFDEF OmniXML_Generics}
    FList: TList<IXMLNode>;
    {$ELSE}
    FList: TList;
    {$ENDIF}
    FChildrenCachedSiblings: boolean;
  protected
    function GetLength: Integer;
    function GetItem(const Index: Integer): IXMLNode;
    procedure Put(Index: Integer; Item: IXMLNode);

    procedure MakeChildrenCacheSiblings(const Value: boolean);
  public
    constructor Create;
    destructor Destroy; override;
    property Item[const Index: Integer]: IXMLNode read GetItem; default;
    property Length: Integer read GetLength;
    function Add(const XMLNode: IXMLNode): Integer;
    function IndexOf(const XMLNode: IXMLNode): Integer;
    procedure Insert(const Index: Integer; const XMLNode: IXMLNode);
    function Remove(const XMLNode: IXMLNode): Integer;
    procedure Delete(const Index: Integer);
    procedure Clear;
  end;

  TXMLNodeList = class(TXMLCustomList, IXMLNodeList)
  protected
    FItemNo: Integer;
  public
    procedure Reset;
    function NextNode: IXMLNode;
    function AddNode(const Arg: IXMLNode): IXMLNode;
  end;

  TXMLNamedNodeMap = class(TXMLCustomList, IXMLNamedNodeMap)
  public
    function GetNamedItem(const Name: XmlString): IXMLNode;
    function SetNamedItem(const Arg: IXMLNode): IXMLNode;
    function RemoveNamedItem(const Name: XmlString): IXMLNode;
  end;

  TXMLElement = class(TXMLNode, IXMLElement)
  private
    FTagNameId: TDicId;
  protected
    function GetNodeName: XmlString; override;
    function GetTagName: XmlString;
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); override;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
    procedure SetTagName(const TagName: XmlString);
  public
    property TagName: XmlString read GetTagName;
    constructor CreateElement(const OwnerDocument: TXMLDocument; const TagName: XmlString);
    function GetAttribute(const Name: XmlString): XmlString;
    procedure SetAttribute(const Name, Value: XmlString);
    procedure RemoveAttribute(const Name: XmlString);
    function GetAttributeNode(const Name: XmlString): IXMLAttr;
    function SetAttributeNode(const NewAttr: IXMLAttr): IXMLAttr;
    function RemoveAttributeNode(const OldAttr: IXMLAttr): IXMLAttr;
    function GetElementsByTagName(const Name: XmlString): IXMLNodeList;
    procedure Normalize;
//    function CloneNode(const Deep: Boolean): IXMLNode; override;
  end;

  TXMLProcessingInstruction = class(TXMLNode, IXMLProcessingInstruction)
  private
    FTarget: XmlString;
    FData: XmlString;
    function GetData: XmlString;
    function GetTarget: XmlString;
  protected
    function GetNodeName: XmlString; override;
    procedure SetData(Data: XmlString); virtual;
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); override;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
  public
    property Target: XmlString read GetTarget;
    property Data: XmlString read GetData;
    constructor CreateProcessingInstruction(const OwnerDocument: TXMLDocument; const Target, Data: XmlString);
  end;

  TXMLAttr = class(TXMLNode, IXMLAttr)
  private
    FNameId: TDicId;
    FSpecified: Boolean;
    function GetName: XmlString;
    function GetSpecified: Boolean;
    function GetValue: XmlString;
    procedure SetValue(const Value: XmlString);
    procedure SetName(const Value: XmlString);
  protected
    function GetNodeName: XmlString; override;
    procedure SetNodeValue(const Value: XmlString); override;
    function GetText: XmlString; override;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); override;
  public
    property Name: XmlString read GetName;
    property Specified: Boolean read GetSpecified;
    property Value: XmlString read GetValue write SetValue;
    constructor CreateAttr(const OwnerDocument: TXMLDocument; const Name: XmlString);
  end;

  TXMLCharacterData = class(TXMLNode, IXMLCharacterData)
  private
    function GetData: XmlString;
    function GetLength: Integer;
  protected
    FNodeValue: XmlString;
    procedure SetData(const Value: XmlString); virtual;
    function GetNodeValue: XmlString; override;
    procedure SetNodeValue(const Value: XmlString); override;
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); override;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
  public
    property Data: XmlString read GetData write SetData;
    property Length: Integer read GetLength;
    constructor CreateCharacterData(const OwnerDocument: TXMLDocument; const Data: XmlString); virtual;
    function SubstringData(const Offset, Count: Integer): XmlString;
    procedure AppendData(const Arg: XmlString);
    procedure InsertData(const Offset: Integer; const Arg: XmlString);
    procedure DeleteData(const Offset, Count: Integer);
    procedure ReplaceData(const Offset, Count: Integer; const Arg: XmlString);
  end;

  TXMLText = class(TXMLCharacterData, IXMLText)
  protected
    function GetNodeName: XmlString; override;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
  public
    constructor Create(const OwnerDocument: TXMLDocument; const Data: XmlString); overload;
    function SplitText(const Offset: Integer): IXMLText;
  end;

  TXMLComment = class(TXMLCharacterData, IXMLComment)
  protected
    function GetNodeName: XmlString; override;
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); override;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
  public
    constructor CreateComment(const OwnerDocument: TXMLDocument; const Data: XmlString); virtual;
  end;

  TXMLCDATASection = class(TXMLText, IXMLCDATASection)
  private
    procedure CheckValue(const Value: XmlString);
  protected
    function GetNodeName: XmlString; override;
    procedure SetData(const Value: XmlString); override;
    procedure SetNodeValue(const Value: XmlString); override;
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); override;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
  public
    constructor CreateCDATASection(const OwnerDocument: TXMLDocument; const Data: XmlString); virtual;
  end;

  TXMLDocumentType = class(TXMLText, IXMLDocumentType)
  protected
    function GetNodeName: XmlString; override;
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); override;
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
  public
    constructor CreateDocumentType(const OwnerDocument: TXMLDocument; const Data: XmlString); virtual;
  end;

  TXMLAttrClass = class of TXMLAttr;
  TXMLCDATASectionClass = class of TXMLCDATASection;
  TXMLCommentClass = class of TXMLComment;
  TXMLDocumentTypeClass = class of TXMLDocumentType;
  TXMLElementClass = class of TXMLElement;
  TXMLProcessingInstructionClass = class of TXMLProcessingInstruction;
  TXMLTextClass = class of TXMLText;

  TXMLDocument = class(TXMLNode, IXMLDocument)
  private
    FDocType: IXMLDocumentType;
    FIParseError: IXMLParseError;
    FParseError: TXMLParseError;
    FPreserveWhiteSpace: Boolean;
    FURL: string;
  protected
    function GetNodeName: XmlString; override;
    function GetParseError: IXMLParseError;
    function GetDocType: IXMLDocumentType;
    { TODO -omr : re-add after IXMLDocumentType will be properly supported }
//    procedure SetDocType(const Value: IXMLDocumentType);
    function GetDocumentElement: IXMLElement;
    procedure SetDocumentElement(const Value: IXMLElement);
    function GetPreserveWhiteSpace: Boolean;
    procedure SetPreserveWhiteSpace(const Value: Boolean);
    function GetText: XmlString; override;
    function GetOwnerDocument: IXMLDocument; override;
  protected
    FXMLAttrClass: TXMLAttrClass;
    FXMLCDATASectionClass: TXMLCDATASectionClass;
    FXMLCommentClass: TXMLCommentClass;
    FXMLDocTypeClass: TXMLDocumentTypeClass;
    FXMLElementClass: TXMLElementClass;
    FXMLProcessingInstructionClass: TXMLProcessingInstructionClass;
    FXMLTextClass: TXMLTextClass;
    // creating new childs
    function InternalCreateAttribute(const Name: XmlString): TXMLAttr;
    function InternalCreateCDATASection(const Data: XmlString): TXMLCDATASection;
    function InternalCreateComment(const Data: XmlString): TXMLComment;
    function InternalCreateDocType(const Data: XmlString): TXMLDocumentType;
    function InternalCreateDocumentFragment: TXMLDocumentFragment;
    function InternalCreateElement(const TagName: XmlString): TXMLElement;
    function InternalCreateEntityReference(const Name: XmlString): TXMLEntityReference;
    function InternalCreateProcessingInstruction(const Target, Data: XmlString): TXMLProcessingInstruction;
    function InternalCreateTextNode(const Data: XmlString): TXMLText;
    // reading / writing support
    procedure ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream); override;
    procedure InternalWriteToStream(const OutputStream: IUnicodeStream); override;
  public
    UnclosedElementList: TInterfaceList;
    property DocType: IXMLDocumentType read GetDocType;
    property DocumentElement: IXMLElement read GetDocumentElement write SetDocumentElement;
    property PreserveWhiteSpace: Boolean read GetPreserveWhiteSpace write SetPreserveWhiteSpace;
    constructor Create; virtual;
    destructor Destroy; override;
    function CreateAttribute(const Name: XmlString): IXMLAttr;
    function CreateCDATASection(const Data: XmlString): IXMLCDATASection;
    function CreateComment(const Data: XmlString): IXMLComment;
    function CreateDocType(const Data: XmlString): IXMLDocumentType;
    function CreateDocumentFragment: IXMLDocumentFragment;
    function CreateElement(const TagName: XmlString): IXMLElement;
    function CreateEntityReference(const Name: XmlString): IXMLEntityReference;
    function CreateProcessingInstruction(const Target, Data: XmlString): IXMLProcessingInstruction;
    function CreateTextNode(const Data: XmlString): IXMLText;
    function GetElementsByTagName(const TagName: XmlString): IXMLNodeList;

    function Load(const FileName: string): Boolean; virtual;
    function LoadFromStream(const Stream: TStream): Boolean;
    procedure Save(const FileName: string; const OutputFormat: TOutputFormat = ofNone); virtual;
    procedure SaveToStream(const OutputStream: TStream; const OutputFormat: TOutputFormat = ofNone);
    function LoadXML(const XML: XmlString): Boolean; virtual;
    property ParseError: IXMLParseError read GetParseError;
  end;

// helper functions
function CreateXMLDoc: IXMLDocument;
// Unicode functions
function UniTrim(const Value: XmlString): XmlString;

// XML related helper functions
function CharIs_BaseChar(const ch: XmlChar): Boolean;
function CharIs_Ideographic(const ch: XmlChar): Boolean;
function CharIs_Letter(const ch: XmlChar): Boolean;
function CharIs_Extender(const ch: XmlChar): Boolean;
function CharIs_Digit(const ch: XmlChar): Boolean;
function CharIs_CombiningChar(const ch: XmlChar): Boolean;
function CharIs_WhiteSpace(const ch: XmlChar): Boolean;
function CharIs_Char(const ch: XmlChar): Boolean;
function CharIs_NameChar(const ch: XmlChar): Boolean;
function CharIs_Name(const ch: XmlChar; const IsFirstChar: Boolean): Boolean;
function EncodeText(const Value: XmlString): XmlString;

function ShrinkEol(const Value: XmlString): XmlString;
function ExpandEol(const Value: XmlString): XmlString;

implementation

uses
  OmniXML_LookupTables, OmniXMLXPath;

const
  MAX_OUTPUTBUFFERSIZE = 256;  // initial output buffer size (it only stores one tag at once!)
  OUTPUT_INDENT = 2;

type
  TCharRef = record
    Code: Word;
    Name: string;
  end;
  TCharacterReferences = array[1..101] of TCharRef;

var
  DOMErrorInfoList: array[INDEX_SIZE_ERR..INUSE_ATTRIBUTE_ERR] of string = (
    'Index or size is negative, or greater than the allowed value',
    'The specified range of text does not fit into a WideString',
    'Any node is inserted somewhere it doesn''t belong',
    'A node is used in a different document than the one that created it (that doesn''t support it)',
    'An invalid character is specified, such as in a name',
    'Data is specified for a node which does not support data',
    'An attempt is made to modify an object where modifications are not allowed',
    'An attempt was made to reference a node in a context where it does not exist',
    'The implementation does not support the type of object requested',
    'An attempt is made to add an attribute that is already inuse elsewhere');

type
  TErrorInfo = record
    ID: Integer;
    Text: string;
  end;

var
  NodeTypeList: array[TNodeType] of String =
    ('ELEMENT', 'ATTRIBUTE', 'TEXT', 'CDATA_SECTION', 'ENTITY_REFERENCE',
    'ENTITY_NODE', 'PROCESSING_INSTRUCTION', 'COMMENT', 'DOCUMENT',
    'DOCUMENT_TYPE', 'DOCUMENT_FRAGMENT', 'NOTATION');

var
  XMLErrorInfoList: array[MSG_E_NOTEXT..XML_BAD_ENCODING] of TErrorInfo =
    ( (ID: MSG_E_NOTEXT; Text: '%s'),
      (ID: MSG_E_FORMATINDEX_BADINDEX; Text: 'The value passed in to formatIndex needs to be greater than zero.'),
      (ID: MSG_E_FORMATINDEX_BADFORMAT; Text: 'Invalid format string.'),
      (ID: MSG_E_SYSTEM_ERROR; Text: 'System error: %s.'),
      (ID: MSG_E_MISSINGEQUALS; Text: 'Missing equals sign between attribute and attribute value.'),
      (ID: MSG_E_EXPECTED_TOKEN; Text: 'Expected token %s found %s.'),
      (ID: MSG_E_UNEXPECTED_TOKEN; Text: 'Unexpected token %s.'),
      (ID: MSG_E_MISSINGQUOTE; Text: 'A string literal was expected, but no opening quote character was found.'),
      (ID: MSG_E_COMMENTSYNTAX; Text: 'Incorrect syntax was used in a comment.'),
      (ID: MSG_E_BADSTARTNAMECHAR; Text: 'A name started with an invalid character.'),
      (ID: MSG_E_BADNAMECHAR; Text: 'A name contained an invalid character.'),
      (ID: MSG_E_BADCHARINSTRING; Text: 'The character "<" cannot be used in an attribute value.'),
      (ID: MSG_E_XMLDECLSYNTAX; Text: 'Invalid syntax for an xml declaration.'),
      (ID: MSG_E_BADCHARDATA; Text: 'An invalid character was found in text content.'),
      (ID: MSG_E_MISSINGWHITESPACE; Text: 'Required white space was missing.'),
      (ID: MSG_E_EXPECTINGTAGEND; Text: 'The character ">" was expected.'),
      (ID: MSG_E_BADCHARINDTD; Text: 'Invalid character found in DTD.'),
      (ID: MSG_E_BADCHARINDECL; Text: 'An invalid character was found inside a DTD declaration.'),
      (ID: MSG_E_MISSINGSEMICOLON; Text: 'A semi colon character was expected.'),
      (ID: MSG_E_BADCHARINENTREF; Text: 'An invalid character was found inside an entity reference.'),
      (ID: MSG_E_UNBALANCEDPAREN; Text: 'Unbalanced parentheses.'),
      (ID: MSG_E_EXPECTINGOPENBRACKET; Text: 'An opening "[" character was expected.'),
      (ID: MSG_E_BADENDCONDSECT; Text: 'Invalid syntax in a conditional section.'),
      (ID: MSG_E_INTERNALERROR; Text: 'Internal error: %s'),
      (ID: MSG_E_UNEXPECTED_WHITESPACE; Text: 'Whitespace is not allowed at this location.'),
      (ID: MSG_E_INCOMPLETE_ENCODING; Text: 'End of file reached in invalid state for current encoding.'),
      (ID: MSG_E_BADCHARINMIXEDMODEL; Text: 'Mixed content model cannot contain this character.'),
      (ID: MSG_E_MISSING_STAR; Text: 'Mixed content model must be defined as zero or more("*").'),
      (ID: MSG_E_BADCHARINMODEL; Text: 'Invalid character in content model.'),
      (ID: MSG_E_MISSING_PAREN; Text: 'Missing parenthesis.'),
      (ID: MSG_E_BADCHARINENUMERATION; Text: 'Invalid character found in ATTLIST enumeration.'),
      (ID: MSG_E_PIDECLSYNTAX; Text: 'Invalid syntax in processing instruction declaration.'),
      (ID: MSG_E_EXPECTINGCLOSEQUOTE; Text: 'A single or double closing quote character ('' or ") is missing.'),
      (ID: MSG_E_MULTIPLE_COLONS; Text: 'Multiple colons are not allowed in a name.'),
      (ID: MSG_E_INVALID_DECIMAL; Text: 'Invalid character for decimal digit.'),
      (ID: MSG_E_INVALID_HEXADECIMAL; Text: 'Invalid character for hexadecimal digit.'),
      (ID: MSG_E_INVALID_UNICODE; Text: 'Invalid Unicode character value for this platform.'),
      (ID: MSG_E_WHITESPACEORQUESTIONMARK; Text: 'Expecting white space or "?".'),
      (ID: MSG_E_SUSPENDED; Text: 'The parser is suspended.'),
      (ID: MSG_E_STOPPED; Text: 'The parser is stopped.'),
      (ID: MSG_E_UNEXPECTEDENDTAG; Text: 'End tag was not expected at this location.'),
      (ID: MSG_E_UNCLOSEDTAG; Text: 'The following tags were not closed: %s.'),
      (ID: MSG_E_DUPLICATEATTRIBUTE; Text: 'Duplicate attribute.'),
      (ID: MSG_E_MULTIPLEROOTS; Text: 'Only one top level element is allowed in an XML document.'),
      (ID: MSG_E_INVALIDATROOTLEVEL; Text: 'Invalid character at the top level of the document.'),
      (ID: MSG_E_BADXMLDECL; Text: 'Invalid XML declaration.'),
      (ID: MSG_E_MISSINGROOT; Text: 'XML document must have a top level element.'),
      (ID: MSG_E_UNEXPECTEDEOF; Text: 'Unexpected end of file.'),
      (ID: MSG_E_BADPEREFINSUBSET; Text: 'Parameter entities cannot be used inside markup declarations in an internal subset.'),
      (ID: MSG_E_PE_NESTING; Text: 'The replacement text for a parameter entity must be properly nested with parenthesized groups.'),
      (ID: MSG_E_INVALID_CDATACLOSINGTAG; Text: 'The literal string "]]>" is not allowed in element content.'),
      (ID: MSG_E_UNCLOSEDPI; Text: 'Processing instruction was not closed.'),
      (ID: MSG_E_UNCLOSEDSTARTTAG; Text: 'Element was not closed.'),
      (ID: MSG_E_UNCLOSEDENDTAG; Text: 'End element was missing the character ">".'),
      (ID: MSG_E_UNCLOSEDSTRING; Text: 'A string literal was not closed.'),
      (ID: MSG_E_UNCLOSEDCOMMENT; Text: 'A comment was not closed.'),
      (ID: MSG_E_UNCLOSEDDECL; Text: 'A declaration was not closed.'),
      (ID: MSG_E_UNCLOSEDMARKUPDECL; Text: 'A markup declaration was not closed.'),
      (ID: MSG_E_UNCLOSEDCDATA; Text: 'A CDATA section was not closed.'),
      (ID: MSG_E_BADDECLNAME; Text: 'Declaration has an invalid name.'),
      (ID: MSG_E_BADEXTERNALID; Text: 'External ID is invalid.'),
      (ID: MSG_E_BADELEMENTINDTD; Text: 'An XML element is not allowed inside a DTD.'),
      (ID: MSG_E_RESERVEDNAMESPACE; Text: 'The namespace prefix is not allowed to start with the reserved string "xml".'),
      (ID: MSG_E_EXPECTING_VERSION; Text: 'The version attribute is required at this location.'),
      (ID: MSG_E_EXPECTING_ENCODING; Text: 'The encoding attribute is required at this location.'),
      (ID: MSG_E_EXPECTING_NAME; Text: 'At least one name is required at this location.'),
      (ID: MSG_E_UNEXPECTED_ATTRIBUTE; Text: 'The specified attribute was not expected at this location. The attribute may be case-sensitive.'),
      (ID: MSG_E_ENDTAGMISMATCH; Text: 'End tag %s does not match the start tag %s.'),
      (ID: MSG_E_INVALIDENCODING; Text: 'System does not support the specified encoding.'),
      (ID: MSG_E_INVALIDSWITCH; Text: 'Switch from current encoding to specified encoding not supported.'),
      (ID: MSG_E_EXPECTING_NDATA; Text: 'NDATA keyword is missing.'),
      (ID: MSG_E_INVALID_MODEL; Text: 'Content model is invalid.'),
      (ID: MSG_E_INVALID_TYPE; Text: 'Invalid type defined in ATTLIST.'),
      (ID: MSG_E_INVALIDXMLSPACE; Text: 'XML space attribute has invalid value. Must specify "default" or "preserve".'),
      (ID: MSG_E_MULTI_ATTR_VALUE; Text: 'Multiple names found in attribute value when only one was expected.'),
      (ID: MSG_E_INVALID_PRESENCE; Text: 'Invalid ATTDEF declaration. Expected #REQUIRED, #IMPLIED, or #FIXED.'),
      (ID: MSG_E_BADXMLCASE; Text: 'The name "xml" is reserved and must be lowercase.'),
      (ID: MSG_E_CONDSECTINSUBSET; Text: 'Conditional sections are not allowed in an internal subset.'),
      (ID: MSG_E_CDATAINVALID; Text: 'CDATA is not allowed in a DTD.'),
      (ID: MSG_E_INVALID_STANDALONE; Text: 'The standalone attribute must have the value "yes" or "no".'),
      (ID: MSG_E_UNEXPECTED_STANDALONE; Text: 'The standalone attribute cannot be used in external entities.'),
      (ID: MSG_E_DOCTYPE_IN_DTD; Text: 'Cannot have a DOCTYPE declaration in a DTD.'),
      (ID: MSG_E_MISSING_ENTITY; Text: 'Reference to an undefined entity.'),
      (ID: MSG_E_ENTITYREF_INNAME; Text: 'Entity reference is resolved to an invalid name character.'),
      (ID: MSG_E_DOCTYPE_OUTSIDE_PROLOG; Text: 'Cannot have a DOCTYPE declaration outside of a prolog.'),
      (ID: MSG_E_INVALID_VERSION; Text: 'Invalid version number.'),
      (ID: MSG_E_DTDELEMENT_OUTSIDE_DTD; Text: 'Cannot have a DTD declaration outside of a DTD.'),
      (ID: MSG_E_DUPLICATEDOCTYPE; Text: 'Cannot have multiple DOCTYPE declarations.'),
      (ID: MSG_E_RESOURCE; Text: 'Error processing resource %s.'),
      (ID: MSG_E_INVALID_OPERATION; Text: 'This operation can not be performed with a Node of type %s.'),
      (ID: MSG_E_WRONG_DOCUMENT; Text: 'NewChild was created from a different document than the one that created this node.'),

      (ID: XML_IOERROR; Text: 'Error opening input file: ''%s''.'),
      (ID: XML_ENTITY_UNDEFINED; Text: 'Reference to undefined entity %s.'),
      (ID: XML_INFINITE_ENTITY_LOOP; Text: 'Entity %s contains an infinite entity reference loop.'),
      (ID: XML_NDATA_INVALID_PE; Text: 'Cannot use the NDATA keyword in a parameter entity declaration.'),
      (ID: XML_REQUIRED_NDATA; Text: 'Cannot use a general parsed entity ''%s'' as the value for attribute ''%s''.'),
      (ID: XML_NDATA_INVALID_REF; Text: 'Cannot use unparsed entity %s in an entity reference.'),
      (ID: XML_EXTENT_IN_ATTR; Text: 'Cannot reference an external general parsed entity %s in an attribute value.'),
      (ID: XML_STOPPED_BY_USER; Text: 'XML parser stopped by user.'),
      (ID: XML_PARSING_ENTITY; Text: 'Error while parsing entity %s. %s.'),
      (ID: XML_E_MISSING_PE_ENTITY; Text: 'Parameter entity must be defined before it is used.'),
      (ID: XML_E_MIXEDCONTENT_DUP_NAME; Text: 'The same name must not appear more than once in a single mixed-content declaration: %s.'),
      (ID: XML_NAME_COLON; Text: 'Entity, EntityRef, PI, Notation names, or NMToken cannot contain a colon.'),
      (ID: XML_ELEMENT_UNDECLARED; Text: 'The element %s is used but not declared in the DTD/Schema.'),
      (ID: XML_ELEMENT_ID_NOT_FOUND; Text: 'The attribute %s references the ID %s, which is not defined anywhere in the document.'),
      (ID: XML_DEFAULT_ATTRIBUTE; Text: 'Error in the default attribute value defined in DTD/Schema.'),
      (ID: XML_XMLNS_RESERVED; Text: 'Reserved namespace "%s" cannot be redeclared.'),
      (ID: XML_EMPTY_NOT_ALLOWED; Text: 'Element cannot be empty according to the DTD/Schema.'),
      (ID: XML_ELEMENT_NOT_COMPLETE; Text: 'Element content is incomplete according to the DTD/Schema.'),
      (ID: XML_ROOT_NAME_MISMATCH; Text: 'The name of the top-most element must match the name of the DOCTYPE declaration.'),
      (ID: XML_INVALID_CONTENT; Text: 'Element content is invalid according to the DTD/Schema.'),
      (ID: XML_ATTRIBUTE_NOT_DEFINED; Text: 'The attribute %s on this element is not defined in the DTD/Schema.'),
      (ID: XML_ATTRIBUTE_FIXED; Text: 'Attribute %s has a value which does not match the fixed value defined in the DTD/Schema.'),
      (ID: XML_ATTRIBUTE_VALUE; Text: 'Attribute %s has an invalid value according to the DTD/Schema.'),
      (ID: XML_ILLEGAL_TEXT; Text: 'Text is not allowed in this element according to the DTD/Schema.'),
      (ID: XML_MULTI_FIXED_VALUES; Text: 'An attribute declaration cannot contain multiple fixed values: "%s".'),
      (ID: XML_NOTATION_DEFINED; Text: 'The notation %s is already declared.'),
      (ID: XML_ELEMENT_DEFINED; Text: 'The element %s is already declared.'),
      (ID: XML_ELEMENT_UNDEFINED; Text: 'Reference to undeclared element: %s.'),
      (ID: XML_XMLNS_UNDEFINED; Text: 'Reference to undeclared namespace prefix: %s.'),
      (ID: XML_XMLNS_FIXED; Text: 'Attribute %s must be a #FIXED attribute.'),
      (ID: XML_E_UNKNOWNERROR; Text: 'Unknown error: %s.'),
      (ID: XML_REQUIRED_ATTRIBUTE_MISSING; Text: 'Required attribute %s is missing.'),
      (ID: XML_MISSING_NOTATION; Text: 'Declaration %s contains a reference to undefined notation %s.'),
      (ID: XML_ATTLIST_DUPLICATED_ID; Text: 'Cannot define multiple ID attributes on the same element.'),
      (ID: XML_ATTLIST_ID_PRESENCE; Text: 'An attribute of type ID must have a declared default of #IMPLIED or #REQUIRED.'),
      (ID: XML_XMLLANG_INVALIDID; Text: 'The language ID %s is invalid.'),
      (ID: XML_PUBLICID_INVALID; Text: 'The public ID %s is invalid.'),
      (ID: XML_DTD_EXPECTING; Text: 'Expecting: %s.'),
      (ID: XML_NAMESPACE_URI_EMPTY; Text: 'Only a default namespace can have an empty URI.'),
      (ID: XML_LOAD_EXTERNALENTITY; Text: 'Could not load %s.'),
      (ID: XML_BAD_ENCODING; Text: 'Unable to save character to %s encoding.') );

var
  CharacterReferences: TCharacterReferences = (
    (Code:  34; Name: 'quot'),
    (Code:  38; Name: 'amp'),
    (Code:  39; Name: 'apos'),
    (Code:  60; Name: 'lt'),
    (Code:  62; Name: 'gt'),
    (Code: 160; Name: 'nbsp'),
    (Code: 161; Name: 'iexcl'),
    (Code: 162; Name: 'cent'),
    (Code: 163; Name: 'pound'),
    (Code: 164; Name: 'curren'),
    (Code: 165; Name: 'yen'),
    (Code: 166; Name: 'brvbar'),
    (Code: 167; Name: 'sect'),
    (Code: 168; Name: 'uml'),
    (Code: 169; Name: 'copy'),
    (Code: 170; Name: 'ordf'),
    (Code: 171; Name: 'laquo'),
    (Code: 172; Name: 'not'),
    (Code: 173; Name: 'shy'),
    (Code: 174; Name: 'reg'),
    (Code: 175; Name: 'macr'),
    (Code: 176; Name: 'deg'),
    (Code: 177; Name: 'plusm'),
    (Code: 178; Name: 'sup2'),
    (Code: 179; Name: 'sup3'),
    (Code: 180; Name: 'acute'),
    (Code: 181; Name: 'micro'),
    (Code: 182; Name: 'para'),
    (Code: 183; Name: 'middot'),
    (Code: 184; Name: 'cedil'),
    (Code: 185; Name: 'supl'),
    (Code: 186; Name: 'ordm'),
    (Code: 187; Name: 'raquo'),
    (Code: 188; Name: 'frac14'),
    (Code: 189; Name: 'frac12'),
    (Code: 190; Name: 'frac34'),
    (Code: 191; Name: 'iquest'),
    (Code: 192; Name: 'Agrave'),
    (Code: 193; Name: 'Aacute'),
    (Code: 194; Name: 'circ'),
    (Code: 195; Name: 'Atilde'),
    (Code: 196; Name: 'Auml'),
    (Code: 197; Name: 'ring'),
    (Code: 198; Name: 'AElig'),
    (Code: 199; Name: 'Ccedil'),
    (Code: 200; Name: 'Egrave'),
    (Code: 201; Name: 'Eacute'),
    (Code: 202; Name: 'Ecirc'),
    (Code: 203; Name: 'Euml'),
    (Code: 204; Name: 'Igrave'),
    (Code: 205; Name: 'Iacute'),
    (Code: 206; Name: 'Icirc'),
    (Code: 207; Name: 'Iuml'),
    (Code: 208; Name: 'ETH'),
    (Code: 209; Name: 'Ntilde'),
    (Code: 210; Name: 'Ograve'),
    (Code: 211; Name: 'Oacute'),
    (Code: 212; Name: 'Ocirc'),
    (Code: 213; Name: 'Otilde'),
    (Code: 214; Name: 'Ouml'),
    (Code: 215; Name: 'times'),
    (Code: 216; Name: 'Oslash'),
    (Code: 217; Name: 'Ugrave'),
    (Code: 218; Name: 'Uacute'),
    (Code: 219; Name: 'Ucirc'),
    (Code: 220; Name: 'Uuml'),
    (Code: 221; Name: 'Yacute'),
    (Code: 222; Name: 'THORN'),
    (Code: 223; Name: 'szlig'),
    (Code: 224; Name: 'agrave'),
    (Code: 225; Name: 'aacute'),
    (Code: 226; Name: 'acirc'),
    (Code: 227; Name: 'atilde'),
    (Code: 228; Name: 'auml'),
    (Code: 229; Name: 'aring'),
    (Code: 230; Name: 'aelig'),
    (Code: 231; Name: 'ccedil'),
    (Code: 232; Name: 'egrave'),
    (Code: 233; Name: 'eacute'),
    (Code: 234; Name: 'ecirc'),
    (Code: 235; Name: 'euml'),
    (Code: 236; Name: 'igrave'),
    (Code: 237; Name: 'iacute'),
    (Code: 238; Name: 'icirc'),
    (Code: 239; Name: 'iuml'),
    (Code: 240; Name: 'ieth'),
    (Code: 241; Name: 'ntilde'),
    (Code: 242; Name: 'ograve'),
    (Code: 243; Name: 'oacute'),
    (Code: 244; Name: 'ocirc'),
    (Code: 245; Name: 'otilde'),
    (Code: 246; Name: 'ouml'),
    (Code: 247; Name: 'divide'),
    (Code: 248; Name: 'oslash'),
    (Code: 249; Name: 'ugrave'),
    (Code: 250; Name: 'uacute'),
    (Code: 251; Name: 'ucirc'),
    (Code: 252; Name: 'uuml'),
    (Code: 253; Name: 'yacute'),
    (Code: 254; Name: 'thorn'),
    (Code: 255; Name: 'yuml')
  );

const
  BIT_IS_BaseChar = Byte($01);
  BIT_IS_CombiningChar = Byte($02);
  BIT_IS_Digit = Byte($04);
  BIT_IS_Ideographic = Byte($08);
  BIT_IS_Letter = Byte($10);
  BIT_IS_Extender = Byte($20);
  BIT_IS_Char = Byte($40);
  BIT_IS_NameChar = Byte($80);

function CreateXMLDoc: IXMLDocument;
begin
  Result := TXMLDocument.Create;
end;

function FindEncoding(const PI: IXMLProcessingInstruction; var OutEncoding: TEncoding): Boolean;
var
  EncodingStartPos,
  EncodingEndPos: Integer;
  R: XmlString;
  Encoding: XmlString;
  DelimiterChar: XmlChar;
begin
  OutEncoding := nil;
  Result := False;
  if CompareText(PI.Target, 'xml') = 0 then
  begin
    // 2004-02-06 (mr): modified to recognize valid delimiter characters
    EncodingStartPos := Pos(XmlString('encoding='), PI.Data) + 9;

    if EncodingStartPos > 9 then
    begin
      DelimiterChar := PI.Data[EncodingStartPos];

      if (DelimiterChar = '''') or (DelimiterChar = '"') then
      begin
        Inc(EncodingStartPos);
        R := Copy(PI.Data, EncodingStartPos, MaxInt);
        EncodingEndPos := Pos(DelimiterChar, R) + EncodingStartPos;
        if EncodingEndPos > 0 then
        begin
          Encoding := Copy(PI.Data, EncodingStartPos, EncodingEndPos - EncodingStartPos - 1);
          Result := TEncoding.EncodingFromAlias(Encoding, OutEncoding);
        end;
      end;
    end;
  end;
end;

function FindCharReference(const CharReferenceName: string; var Character: XmlChar): Boolean;
var
  i: Integer;
begin
  Result := False;

  i := Low(CharacterReferences);
  while (not Result) and (i <= High(CharacterReferences)) do
  begin
    Result := CompareStr(CharReferenceName, CharacterReferences[i].Name) = 0;
    if Result then
      Character := XmlChar(CharacterReferences[i].Code)
    else
      Inc(i);
  end;
end;

function CharIs_BaseChar(const ch: XmlChar): Boolean;
begin
  // [85] BaseChar
  Result := (XMLCharLookupTable[Ord(ch)] and BIT_IS_BaseChar) > 0;
end;

function CharIs_Ideographic(const ch: XmlChar): Boolean;
begin
  // [86] Ideographic
  Result := (XMLCharLookupTable[Ord(ch)] and BIT_IS_Ideographic) > 0;
end;

function CharIs_Letter(const ch: XmlChar): Boolean;
begin
  // [84] Letter ::= BaseChar | Ideographic
  Result := (XMLCharLookupTable[Ord(ch)] and BIT_IS_Letter) > 0;
end;

function CharIs_Extender(const ch: XmlChar): Boolean;
begin
  // [89] Extender
  Result := (XMLCharLookupTable[Ord(ch)] and BIT_IS_Extender) > 0;
end;

function CharIs_Digit(const ch: XmlChar): Boolean;
begin
  // [88] Digit
  Result := (XMLCharLookupTable[Ord(ch)] and BIT_IS_Digit) > 0;
end;

function CharIs_CombiningChar(const ch: XmlChar): Boolean;
begin
  // [87] CombiningChar
  Result := (XMLCharLookupTable[Ord(ch)] and BIT_IS_CombiningChar) > 0;
end;

function CharIs_WhiteSpace(const ch: XmlChar): Boolean;
var
  _ch: LongWord;
begin
  // [3] WhiteSpace
  _ch := Ord(ch);
  Result := (_ch = $0020) or (_ch = $0009) or (_ch = $000D) or (_ch = $000A);
end;

function CharIs_Char(const ch: XmlChar): Boolean;
begin
  // [2] Char - any Unicode character, excluding the surrogate blocks, FFFE, and FFFF
  Result := (XMLCharLookupTable[Ord(ch)] and BIT_IS_Char) > 0;
end;

function CharIs_NameChar(const ch: XmlChar): Boolean;
begin
  // [4] NameChar ::= Letter | Digit | '.' | '-' | '_' | ':' | CombiningChar | Extender
  Result := (XMLCharLookupTable[Ord(ch)] and BIT_IS_NameChar) > 0;
end;

function CharIs_Name(const ch: XmlChar; const IsFirstChar: Boolean): Boolean;
var
  _ch: LongWord;
begin
  // [5] Name ::= (Letter | '_' | ':') (NameChar)*
  _ch := Ord(ch);
  if IsFirstChar then
    Result := CharIs_Letter(ch) or (_ch = $005F) or (_ch = $003A)  // '_', ':'
  else
    Result := CharIs_NameChar(ch);
end;

//
//  E N D
// 


function EncodeText(const Value: XmlString): XmlString;
var
  iResult: Integer;
  iValue: Integer;

  procedure ExtendResult(atLeast: Integer = 0);
  begin
    SetLength(Result, Round(1.1 * System.Length(Result) + atLeast));
  end;

  procedure Store(const token: XmlString);
  var
    iToken: Integer;
  begin
    if (iResult + System.Length(token)) >= System.Length(Result) then
      ExtendResult(System.Length(token));
    for iToken := 1 to System.Length(token) do
    begin
      Inc(iResult);
      Result[iResult] := token[iToken];
    end;
  end;
begin
  SetLength(Result, Round(1.1 * System.Length(Value)));  // a wild guess
  iResult := 0;
  iValue := 1;
  while iValue <= System.Length(Value) do
  begin
    case Ord(Value[iValue]) of
      34: Store('&quot;');
      38: Store('&amp;');
      39: Store('&apos;');
      60: Store('&lt;');
      62: Store('&gt;');
    else
      begin
        Inc(iResult);
        if iResult > System.Length(Result) then
          ExtendResult;
        Result[iResult] := Value[iValue];
      end;
    end;
    Inc(iValue);
  end;
  SetLength(Result, iResult);
end;

function Reference2Char(const InputStream: IUnicodeStream): XmlChar;
type
  TParserState = (psReference, psEntityRef, psCharRef, psCharDigitalRef, psCharHexRef);
var
  ReadChar: XmlChar;
  PState: TParserState;
  CharRef: LongWord;
  EntityName: XmlString;
begin
  // [67] Reference ::= EntityRef | CharRef
  // [68] EntityRef ::= '&' Name ';'
  // [66] CharRef ::= '&#' [0-9]+ ';' | '&#x' [0-9a-fA-F]+ ';'
  PState := psReference;
  CharRef := 0;
  Result := ' ';
  // read next available character
  while InputStream.ProcessChar(ReadChar) do
  begin
    case PState of
      psReference:
        if CharIs_WhiteSpace(ReadChar) then
          raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_UNEXPECTED_WHITESPACE, [])
        else if ReadChar = '#' then
          PState := psCharRef
        else
        begin
          if CharIs_Name(ReadChar, True) then
          begin
            PState := psEntityRef;
            EntityName := ReadChar;
          end
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADSTARTNAMECHAR, []);
        end;
      psCharRef:
        if CharIs_WhiteSpace(ReadChar) then
          raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_UNEXPECTED_WHITESPACE, [])
        else
        begin
          case ReadChar of
            '0'..'9':
              begin
                CharRef := Ord(ReadChar) - 48;
                PState := psCharDigitalRef;
              end;
            'x': PState := psCharHexRef;
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADCHARINENTREF, []);
          end;
        end;
      psCharDigitalRef:
        if CharIs_WhiteSpace(ReadChar) then
          raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_UNEXPECTED_WHITESPACE, [])
        else
        begin
          case ReadChar of
            '0'..'9': CharRef := LongWord(CharRef * 10) + LongWord(Ord(ReadChar) - 48);
            ';':
              begin
                Result := XmlChar(CharRef);
                Exit;
              end;
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_INVALID_DECIMAL, []);
          end;
        end;
      psCharHexRef:
        if CharIs_WhiteSpace(ReadChar) then
          raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_UNEXPECTED_WHITESPACE, [])
        else
        begin
          case ReadChar of
            '0'..'9': CharRef := LongWord(CharRef shl 4) + LongWord(Ord(ReadChar) - 48);
            'A'..'F': CharRef := LongWord(CharRef shl 4) + LongWord(Ord(ReadChar) - 65 + 10);
            'a'..'f': CharRef := LongWord(CharRef shl 4) + LongWord(Ord(ReadChar) - 97 + 10);
            ';':
              if CharIs_Char(XmlChar(CharRef)) then
              begin
                Result := XmlChar(CharRef);
                Exit;
              end
              else
                raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_INVALID_UNICODE, []);
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_INVALID_HEXADECIMAL, []);
          end;
          // simple "out of range" check
          if CharRef > $10FFFF then
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_INVALID_UNICODE, []);
        end;
      psEntityRef:
        case ReadChar of
          ';':
            begin
              if FindCharReference(EntityName, Result) then
                Exit
              else
                raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, XML_ENTITY_UNDEFINED, [EntityName]);
            end;
        else
          if CharIs_NameChar(ReadChar) then
            EntityName := EntityName + ReadChar
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_MISSINGSEMICOLON, []);
        end;
    end;
  end;
end;

// Unicode functions

function UniTrim(const Value: XmlString): XmlString;
var
  Start, Stop: Integer;
begin
  Start := 1;
  Stop := Length(Value);

  // trim from start
  while (Start <= Stop) and (Value[Start] = #$0020) do
    Inc(Start);

  // little optimization
  if Start > Stop then
  begin
    Result := '';
    Exit;
  end;

  // trim from end
  while (Value[Stop] = #$0020) and (Stop > Start) do
    Dec(Stop);

  Result := Copy(Value, Start, Stop - Start + 1);
end;

// Eol and Whitespace handling

function ShrinkEol(const Value: XmlString): XmlString;
var
  i: Integer;
  SkipFirstLF: Boolean;
  ResultPos: Integer;
  ValueLength: Integer;
begin
  // 2003-02-22 (mr): speed optimization: skip conversion when Value contains no CR characters
  i := 1;
  while i <= System.Length(Value) do
  begin
    if Value[i] = #$000D then
      Break;
    Inc(i);
  end;
  if i > System.Length(Value) then
  begin
    // indeed, there was no CR so return original text
    Result := Value;
    Exit;
  end;

  // 2003-08-29 (eb): optimized
  // The result string can only shrink or remain the same, not grow
  ValueLength := System.Length(Value);
  SetLength(Result, ValueLength);
  ResultPos := 1;
  SkipFirstLF := False;
  for i := 1 to ValueLength do
  begin
    Assert(ResultPos <= ValueLength);
    if Value[i] = #$000D then
    begin
      SkipFirstLF := True;
      Result[ResultPos] := #$000A;
      Inc(ResultPos);
    end
    else if not ((Value[i] = #$000A) and SkipFirstLF) then
    begin
      SkipFirstLF := False;
      Result[ResultPos] := Value[i];
      Inc(ResultPos);
    end
    else if Value[i] = #$000A then
      SkipFirstLF := False;
  end;
  Assert(ResultPos >= 1);
  SetLength(Result, ResultPos - 1);
end;

function ExpandEol(const Value: XmlString): XmlString;
var
  i: Integer;
  ValueLength: Integer;
  MaxResultLength: Integer;
  ResultPos: Integer;
begin
  // 2003-02-22 (mr): speed optimization: skip conversion when Value contains no LF characters
  i := 1;
  while i <= System.Length(Value) do
  begin
    if Value[i] = #$000A then
      Break;
    Inc(i);
  end;
  if i > System.Length(Value) then
  begin
    // indeed, there was not LF so return original text
    Result := Value;
    Exit;
  end;

  // 2003-08-29 (eb): optimized
  // The result can never be more than twice the length of the input
  // Switch to a growable buffer (see EncodeText for example) if you need to deal with huge values
  ValueLength := Length(Value);
  MaxResultLength := 2 * ValueLength;
  SetLength(Result, MaxResultLength);
  ResultPos := 1;
  for i := 1 to ValueLength do
  begin
    Assert(ResultPos <= MaxResultLength);
    if Value[i] = #$000A then
    begin
      Result[ResultPos] := #$000D;
      Result[ResultPos + 1] := #$000A;
      Inc(ResultPos, 2);
    end
    else
    begin
      Result[ResultPos] := Value[i];
      Inc(ResultPos, 1);
    end;
  end;
  Assert(ResultPos >= 1);
  SetLength(Result, ResultPos - 1);
end;

function ShrinkWhitespace(const Value: XmlString): XmlString;
var
  Start, Stop: Integer;
begin
  Start := 1;
  Stop := Length(Value);

  // trim from start
  while (Start <= Stop) and CharIs_WhiteSpace(Value[Start]) do
    Inc(Start);

  // little optimization
  if Start > Stop then
  begin
    Result := '';
    Exit;
  end;

  // trim from end
  while CharIs_WhiteSpace(Value[Stop]) and (Stop > Start) do
    Dec(Stop);

  Result := Copy(Value, Start, Stop - Start + 1);
end;


{ EXMLException }

constructor EXMLException.CreateParseError(const DOMCode, XMLCode: Integer; const Args: array of const);
begin
  inherited CreateFmt(XMLErrorInfoList[XMLCode].Text, Args);
  FDOMCode := DOMCode;
  FXMLCode := XMLCode;
end;

{ TXMLTextStream }

constructor TXMLTextStream.Create(const Stream: TStream; const Mode: TStreamMode;
  const Encoding: TEncoding; const WriteBOM: Boolean);
begin
  FStreamMode := Mode;
  if FStreamMode = smRead then
  begin
    FReader := TOTextReader.Create(Stream, Encoding);
    fBOMFound := FReader.BOMFound;
  end
  else
  begin
    FWriter := TOTextWriter.Create(Stream, Encoding, WriteBOM);
  end;

  // set defaults
  FIndent := -1;

  // allocate initial output buffer
  FOutBufferSize := MAX_OUTPUTBUFFERSIZE;
  FOutBufferPos := -1;
  GetMem(FOutBuffer, FOutBufferSize * SizeOf(XmlChar));
end;

destructor TXMLTextStream.Destroy;
begin
  FreeMem(FOutBuffer, FOutBufferSize * SizeOf(XmlChar));

  FreeAndNil(FReader);
  FreeAndNil(FWriter);

  inherited;
end;

procedure TXMLTextStream.ClearOutputBuffer;
begin
  FOutBufferPos := -1;
end;

function TXMLTextStream.GetOutputFormat: TOutputFormat;
begin
  Result := FOutputFormat;
end;

procedure TXMLTextStream.SetOutputFormat(const Value: TOutputFormat);
begin
  FOutputFormat := Value;
end;

function TXMLTextStream.GetBOMFound: Boolean;
begin
  Result := fBOMFound;
end;

function TXMLTextStream.GetEncoding: TEncoding;
begin
  if FStreamMode = smRead then
    Result := FReader.Encoding
  else
    Result := FWriter.Encoding;
end;

procedure TXMLTextStream.SetEncoding(const AEncoding: TEncoding);
begin
  if FStreamMode = smRead then
    FReader.Encoding := AEncoding
  else
    FWriter.Encoding := AEncoding
end;

function TXMLTextStream.GetNextString(var ReadString: XmlString; const Len: Integer): Boolean;
var
  i: Integer;
  ReadChar: XmlChar;
begin
  SetLength(ReadString, Len);
  i := 0;
  while (i < Len) and ProcessChar(ReadChar) do
  begin
    ReadString[i+1] := ReadChar;
    Inc(i);
  end;
  Result := i = Len;
end;

function TXMLTextStream.GetOutputBuffer: XmlString;
begin
  SetString(Result, FOutBuffer, FOutBufferPos + 1);
  FPreviousOutBuffer := Result;
  ClearOutputBuffer;  // do not remove this call!
end;

function TXMLTextStream.ReadChar(var ReadChar: XmlChar): Boolean;
begin
  Result := FReader.ReadNextChar(ReadChar);
end;

function TXMLTextStream.ProcessChar(var ch: XmlChar): Boolean;
begin
  Result := ReadChar(ch);
end;

procedure TXMLTextStream.UndoRead;
begin
  // next char will be from the undo buffer
  FReader.UndoRead;
end;

procedure TXMLTextStream.WriteOutputChar(const OutChar: XmlChar);
begin
  // FOutBufferPos points to PXmlChar buffer - increment only by 1
  Inc(FOutBufferPos);
  // check for space in output buffer
  if FOutBufferPos = FOutBufferSize then
  begin
    // double the size of the output buffer
    FOutBufferSize := 2 * FOutBufferSize;
    ReallocMem(FOutBuffer, FOutBufferSize * SizeOf(XmlChar));
  end;
  FOutBuffer[FOutBufferPos] := OutChar;
end;

procedure TXMLTextStream.WriteString(const Value: XmlString);
begin
  FWriter.WriteString(Value);
end;

procedure TXMLTextStream.IncreaseIndent;
begin
  if FIndent = MaxInt then
    FIndent := 0;
  Inc(FIndent);
end;

procedure TXMLTextStream.DecreaseIndent;
begin
  Dec(FIndent);
  if FIndent = 0 then
    FIndent := MaxInt;
end;

procedure TXMLTextStream.WriteIndent(const ForceNextLine: Boolean);
begin
  if FOutputFormat = ofNone then
    Exit;

  // 2002-12-17 (mr): added ForceNextLine
  if (FIndent > 0) or ForceNextLine then
    FWriter.WriteString(#13#10);

  if (FOutputFormat = ofIndent) and (FIndent < MaxInt) and (FIndent > 0) then
    FWriter.WriteString(StringOfChar(' ', FIndent * OUTPUT_INDENT));
end;

function TXMLTextStream.OutputBufferLen: Integer;
begin
  Result := FOutBufferPos + 1;
end;

function TXMLTextStream.GetPreviousOutputBuffer: XmlString;
begin
  Result := FPreviousOutBuffer;
end;

{ TXMLParseError }

function TXMLParseError.GetErrorCode: Integer;
begin
  Result := FErrorCode;
end;

function TXMLParseError.GetFilePos: Integer;
begin
  Result := FFilePos;
end;

function TXMLParseError.GetLine: Integer;
begin
  Result := FLine;
end;

function TXMLParseError.GetLinePos: Integer;
begin
  Result := FLinePos;
end;

function TXMLParseError.GetReason: string;
begin
  Result := FReason;
end;

function TXMLParseError.GetSrcText: XmlString;
begin
  Result := FSrcText;
end;

function TXMLParseError.GetSrcTextPos: Integer;
begin
  Result := FSrcTextPos;
end;

function TXMLParseError.GetURL: string;
begin
  Result := FURL;
end;

procedure TXMLParseError.SetErrorCode(const ErrorCode: Integer);
begin
  FErrorCode := ErrorCode;
end;

procedure TXMLParseError.SetFilePos(const FilePos: Integer);
begin
  FFilePos := FilePos;
end;

procedure TXMLParseError.SetLine(const Line: Integer);
begin
  FLine := Line;
end;

procedure TXMLParseError.SetLinePos(const LinePos: Integer);
begin
  FLinePos := LinePos;
end;

procedure TXMLParseError.SetReason(const Reason: string);
begin
  FReason := Reason;
end;

procedure TXMLParseError.SetSrcText(const SrcTextBefore, SrcTextAfter: XmlString);
begin
  FSrcText := SrcTextBefore+SrcTextAfter;
  FSrcTextPos := Length(SrcTextBefore);
end;

procedure TXMLParseError.SetURL(const URL: string);
begin
  FURL := URL;
end;

{ TXMLCustomList }

type TNotifyingList = class({$IFDEF OmniXML_Generics}TList<IXMLNode>{$Else}TList{$EndIf})
   private
     {$IFDEF AUTOREFCOUNT} [weak] {$ENDIF} Owner: TXMLCustomList;
   protected
{$IfDef OmniXML_Generics}
     procedure Notify(const Item: IXMLNode; Action: TCollectionNotification); override;
{$Else}
     procedure Notify(Ptr: Pointer; Action: TListNotification); override;
{$EndIf}
end;

{$IFDEF OmniXML_Generics}
procedure TNotifyingList.Notify(const Item: IXMLNode; Action: TCollectionNotification);
{$Else}
procedure TNotifyingList.Notify(Ptr: Pointer; Action: TListNotification);
{$EndIf}
begin
  // for preformance reasons we would not call inherited function here
  // 1) non-generic TList.Notify is empty anywhere
  // 2) generic TList<T>.Notify merely checks event property and possibly calls
  //         it, which implies extra redirection and AddRef/Release calls
  //         And yet again, we do not use that event.

  if Count > 0 then
     if Owner <> nil then
        if Owner.FChildrenCachedSiblings then
           Owner.MakeChildrenCacheSiblings( False );
end;

constructor TXMLCustomList.Create;
begin
  FList := TNotifyingList.Create;
  TNotifyingList(FList).Owner := Self;
end;

destructor TXMLCustomList.Destroy;
begin
  if GetLength > 0 then
     MakeChildrenCacheSiblings(False);
  if FList <> nil then
     (FList as TNotifyingList).Owner := nil;
  Clear;
  FList.Free;
  inherited;
end;

procedure TXMLCustomList.MakeChildrenCacheSiblings(const Value: boolean);
var i, l: integer;
begin
  if Value
     then l := 0   // all bits clear
     else l := -1; // all bits set!
  for i := 0 to GetLength - 1 do
      GetItem(i).SetCachedNodeIndex( i or l );
  FChildrenCachedSiblings := Value;
end;

function TXMLCustomList.GetItem(const Index: Integer): IXMLNode;
begin
  {$IFDEF OmniXML_Generics}
  Result := FList.Items[Index];
  {$ELSE}
  Result := IInterface(FList.Items[Index]) as IXMLNode;
  {$ENDIF}
end;

function TXMLCustomList.GetLength: Integer;
begin
  Result := FList.Count;
end;

function TXMLCustomList.Add(const XMLNode: IXMLNode): Integer;
begin
  {$IFDEF OmniXML_Generics}
  Result := FList.Add(XMLNode);
  {$ELSE}
  Result := FList.Add(Pointer(XMLNode));
  XMLNode._AddRef;
  {$ENDIF}
end;

function TXMLCustomList.Remove(const XMLNode: IXMLNode): Integer;
begin
  {$IFDEF OmniXML_Generics}
  Result := FList.Remove(XMLNode);
  {$ELSE}
  Result := FList.Remove(Pointer(XMLNode));
  XMLNode._Release;
  {$ENDIF}
end;

procedure TXMLCustomList.Put(Index: Integer; Item: IXMLNode);
begin
  {$IFDEF OmniXML_Generics}
  FList[Index] := Item;
  {$ELSE}
  if Assigned(FList[Index]) then
    IInterface(FList[Index])._Release;
  FList[Index] := Pointer(Item as IXMLNode);
  Item._AddRef;
  {$ENDIF}
end;

function TXMLCustomList.IndexOf(const XMLNode: IXMLNode): Integer;
begin
  {$IFDEF OmniXML_Generics}
  Result := FList.IndexOf(XMLNode);
  {$ELSE}
  Result := FList.IndexOf(Pointer(XMLNode));
  {$ENDIF}
end;

procedure TXMLCustomList.Insert(const Index: Integer; const XMLNode: IXMLNode);
begin
  {$IFDEF OmniXML_Generics}
  FList.Insert(Index, XMLNode);
  {$ELSE}
  FList.Insert(Index, Pointer(XMLNode));
  XMLNode._AddRef;
  {$ENDIF}
end;

procedure TXMLCustomList.Delete(const Index: Integer);
begin
  if Index < FList.Count then begin
    {$IFNDEF OmniXML_Generics}
    (IInterface(FList[Index]) as IXMLNode)._Release;
    {$ENDIF}
    FList.Delete(Index);
  end;
end;

procedure TXMLCustomList.Clear;
{$IFNDEF OmniXML_Generics}
var I: Integer;
begin
  for I := 0 to FList.Count-1 do
    (IInterface(FList[I]) as IXMLNode)._Release;
  FList.Clear;
end;
{$ELSE}
begin
  FList.Clear;
end;
{$ENDIF}

{ TXMLNodeList }

function TXMLNodeList.NextNode: IXMLNode;
begin
  Result := nil;
  if FItemNo < GetLength then
  begin
    Result := Item[FItemNo];
    Inc(FItemNo);
  end;
end;

procedure TXMLNodeList.Reset;
begin
  FItemNo := 0;
end;

function TXMLNodeList.AddNode(const Arg: IXMLNode): IXMLNode;
begin
  Result := Arg;
  Add(Arg);
end;

{ TXMLNamedNodeMap }

function TXMLNamedNodeMap.GetNamedItem(const Name: XmlString): IXMLNode;
var
  i: Integer;
begin
  i := 0;
  Result := nil;
  while (Result = nil) and (i < GetLength) do
  begin
    if Item[i].NodeName = Name then
      Result := Item[i]
    else
      Inc(i);
  end;
end;

function TXMLNamedNodeMap.RemoveNamedItem(const Name: XmlString): IXMLNode;
begin
  Result := GetNamedItem(Name);
  if Result <> nil then
    Remove(Result);
end;

function TXMLNamedNodeMap.SetNamedItem(const Arg: IXMLNode): IXMLNode;
var
  Index: Integer;
begin
  Result := GetNamedItem(Arg.NodeName);
  if Result = nil then
    // old node was not found
    Add(Arg)
  else
  begin
    // replace old node with new node
    Index := IndexOf(Result);
    Put(Index, Arg);
  end;
end;

{ TXMLNode }

constructor TXMLNode.Create(const AOwnerDocument: TXMLDocument);
begin
  inherited Create;
  FOwnerDocument := AOwnerDocument;
  FChildNodes := nil;
  FAttributes := nil;
  FNodeValueId := CInvalidDicId;
  FCachedNodeIndex := -1;

  Dictionary := FOwnerDocument.Dictionary;
end;

destructor TXMLNode.Destroy;
begin
  FAttributes := nil;
  FChildNodes := nil;
  Pointer(FParentNode) := nil;  // (gp)
  inherited;
end;

procedure TXMLNode.ClearChildNodes;
begin
  if HasChildNodes then
    FChildNodes := nil;
end;

function TXMLNode.HasAttributes: Boolean;
begin
  Result := FAttributes <> nil;
end;

function TXMLNode.appendChild(const newChild: IXMLNode): IXMLNode;
begin
  // NewChild should be created from the same document than the one that created this node
  if (Self.OwnerDocument <> nil) and (NewChild.OwnerDocument <> nil) and (NewChild.OwnerDocument <> Self.OwnerDocument) then
    raise EXMLException.CreateParseError(WRONG_DOCUMENT_ERR, MSG_E_WRONG_DOCUMENT, []);

  { TODO -omr : do full checking }
  if (NodeType = ELEMENT_NODE) and (newChild.NodeType = ATTRIBUTE_NODE) then
    raise EXMLException.CreateParseError(HIERARCHY_REQUEST_ERR,
      MSG_E_INVALID_OPERATION, [NodeTypeList[newChild.NodeType]]);

  // if the NewChild is already in the tree, it is first removed
  if NewChild.ParentNode <> nil then
    NewChild.ParentNode.ChildNodes.Remove(NewChild);

  Result := ChildNodes.AddNode(NewChild);
  NewChild.SetParentNode(Self);
end;

function TXMLNode.GetParentNode: IXMLNode;
begin
  Result := FParentNode;
end;

procedure TXMLNode.SetParentNode(const Parent: IXMLNode);
begin
  Pointer(FParentNode) := Pointer(Parent);  // (gp)
end;

function TXMLNode.CloneNode(const Deep: Boolean): IXMLNode;
var
  i: Integer;
begin
  case NodeType of
    ELEMENT_NODE: Result := FOwnerDocument.CreateElement(Self.NodeName);
    ATTRIBUTE_NODE: Result := FOwnerDocument.CreateAttribute(Self.NodeName);
    TEXT_NODE: Result := FOwnerDocument.CreateTextNode(Self.NodeValue);
    CDATA_SECTION_NODE: Result := FOwnerDocument.CreateCDATASection(Self.NodeValue);
    ENTITY_REFERENCE_NODE, ENTITY_NODE, DOCUMENT_TYPE_NODE: Assert(False, 'NYI - CloneNode');
    PROCESSING_INSTRUCTION_NODE: Result := FOwnerDocument.CreateProcessingInstruction(Self.NodeName, Self.NodeValue);
    COMMENT_NODE: Result := FOwnerDocument.CreateComment(Self.NodeValue);
    DOCUMENT_NODE: Result := CreateXMLDoc;
    DOCUMENT_FRAGMENT_NODE: Result := FOwnerDocument.CreateDocumentFragment;
    NOTATION_NODE: raise EXMLException.Create('Invalid operation: cannot clone Notation node');
  end;

  if NodeType in [ATTRIBUTE_NODE, CDATA_SECTION_NODE, COMMENT_NODE, PROCESSING_INSTRUCTION_NODE, TEXT_NODE] then
    Result.NodeValue := Self.NodeValue;

  // clone attributes
  if HasAttributes then
  begin
    for i := 0 to FAttributes.Length - 1 do
      Result.Attributes.Add(FAttributes.Item[i].CloneNode(Deep));
  end;

  if Deep and HasChildNodes then
  begin
    // clone child nodes
    for i := 0 to FChildNodes.Length - 1 do
      Result.ChildNodes.Add(FChildNodes.Item[i].CloneNode(Deep));
  end;
end;

function TXMLNode.GetAttributes: IXMLNamedNodeMap;
begin
  if FAttributes = nil then
    FAttributes := TXMLNamedNodeMap.Create;
  Result := FAttributes;
end;

function TXMLNode.GetChildNodes: IXMLNodeList;
begin
  if FChildNodes = nil then
    FChildNodes := TXMLNodeList.Create;
  Result := FChildNodes;
end;

function TXMLNode.GetFirstChild: IXMLNode;
begin
  if HasChildNodes then
    Result := FChildNodes.Item[0]
  else
    Result := nil;
end;

function TXMLNode.GetLastChild: IXMLNode;
begin
  if HasChildNodes then
    Result := FChildNodes.Item[FChildNodes.Length - 1]
  else
    Result := nil;
end;

function TXMLNode.GetNodeType: TNodeType;
begin
  Result := FNodeType;
end;

function TXMLNode.GetNodeValue: XmlString;
begin
  if FNodeValueId <> CInvalidDicId then
    Result := Dictionary.Get(FNodeValueId)
  else
    Result := '';
end;

procedure TXMLNode.SetNodeValue(const Value: XmlString);
begin
  // 2003-02-22 (mr): exception is now raised as default action
  raise EXMLException.CreateParseError(NO_MODIFICATION_ALLOWED_ERR,
    MSG_E_INVALID_OPERATION, [NodeTypeList[FNodeType]]);
end;

function TXMLNode.GetOwnerDocument: IXMLDocument;
begin
  Result := FOwnerDocument;
end;

function TXMLNode.GetPreviousSibling: IXMLNode;
var ns: IXMLNodeList;
begin
  Result := nil;
  if (FParentNode <> nil) and (FParentNode.HasChildNodes) then
  begin
    ns := FParentNode.ChildNodes;
    if FCachedNodeIndex < 0 then
          ns.MakeChildrenCacheSiblings(True);
    if FCachedNodeIndex > 0 then
       Result := ns.Item[FCachedNodeIndex-1];
  end;
end;

function TXMLNode.GetNextSibling: IXMLNode;
var ns: IXMLNodeList; next_id: integer;
begin
  Result := nil;
  if (FParentNode <> nil) and (FParentNode.HasChildNodes) then
  begin
    ns := FParentNode.ChildNodes;
    if FCachedNodeIndex < 0 then
          ns.MakeChildrenCacheSiblings(True);
    next_id := FCachedNodeIndex + 1;
    if next_id < ns.Length then
       Result := ns.Item[next_id];
  end;
end;

//function TXMLNode.GetPreviousSibling: IXMLNode;
//  function FindPreviousNode(const Self: IXMLNode): IXMLNode;
//  var
//    Childs: IXMLNodeList;
//    Index: Integer;
//  begin
//    Childs := FParentNode.ChildNodes;
//    Index := Childs.IndexOf(Self);
//    if (Index >= 0) and ((Index - 1) >= 0) then
//      Result := Childs.Item[Index - 1]
//    else
//      Result := nil;
//  end;
//begin
//  if (FParentNode <> nil) and (FParentNode.HasChildNodes) then
//    Result := FindPreviousNode(Self as IXMLNode)
//  else
//    Result := nil;
//end;
//
//function TXMLNode.GetNextSibling: IXMLNode;
//  function FindNextNode(const Self: IXMLNode): IXMLNode;
//  var
//    Childs: IXMLNodeList;
//    Index: Integer;
//  begin
//    Childs := FParentNode.ChildNodes;
//    Index := Childs.IndexOf(Self);
//    if (Index >= 0) and ((Index + 1) < Childs.Length) then
//      Result := Childs.Item[Index + 1]
//    else
//      Result := nil;
//  end;
//begin
//  if (FParentNode <> nil) and (FParentNode.HasChildNodes) then
//    Result := FindNextNode(Self as IXMLNode)
//  else
//    Result := nil;
//end;

function TXMLNode.HasChildNodes: Boolean;
begin
  Result := (FChildNodes <> nil) and (FChildNodes.Length > 0);
end;

function TXMLNode.InsertBefore(const NewChild, RefChild: IXMLNode): IXMLNode;
var
  RefChildIndex: Integer;
  RecalculateRefChildIndex: Boolean;
begin
  // NewChild should be created from the same document than the one that created this node
  if (Self.OwnerDocument <> nil) and (NewChild.OwnerDocument <> nil) and (NewChild.OwnerDocument <> Self.OwnerDocument) then
    raise EXMLException.CreateParseError(WRONG_DOCUMENT_ERR, MSG_E_WRONG_DOCUMENT, []);

  if RefChild <> nil then
  begin
    RefChildIndex := FChildNodes.IndexOf(RefChild);

    // RefChild should be a child of this node
    if RefChildIndex = -1 then
      raise EXMLException.CreateParseError(NOT_FOUND_ERR, MSG_E_NOTEXT, ['RefChild is not a child of this node.']);
  end
  else
    RefChildIndex := -1;

  // if NewChild is RefChild, do nothing
  if (NewChild.ParentNode = (Self as IXMLNode)) and (FChildNodes.IndexOf(NewChild) = RefChildIndex) then
    Exit;

  // if NewChild has same parent as RefChild, we should recalculate RefChildIndex
  RecalculateRefChildIndex := NewChild.ParentNode = (Self as IXMLNode);

  // if the NewChild is already in the tree, it is first removed
  if NewChild.ParentNode <> nil then
    NewChild.ParentNode.ChildNodes.Remove(NewChild);

  if RefChild = nil then
    AppendChild(NewChild)
  else
  begin
    if RecalculateRefChildIndex then
      RefChildIndex := FChildNodes.IndexOf(RefChild);

    FChildNodes.Insert(RefChildIndex, NewChild);
    // note: AppendChild already changes parent, so this should be done only with Insert
    NewChild.SetParentNode(Self);
  end;

  Result := NewChild;
end;

function TXMLNode.RemoveChild(const OldChild: IXMLNode): IXMLNode;
var
  Index: Integer;
begin
  if HasChildNodes then
    Index := FChildNodes.IndexOf(OldChild)
  else
    Index := -1;
    
  if Index > -1 then
  begin
    Result := FChildNodes.Item[Index];
    FChildNodes.Remove(OldChild);
    if FChildNodes.Length = 0 then
      FChildNodes := nil;
  end
  else
    raise EXMLException.CreateParseError(NOT_FOUND_ERR, MSG_E_NOTEXT, ['Child not found.']);
end;

function TXMLNode.ReplaceChild(const NewChild, OldChild: IXMLNode): IXMLNode;
var
  Index: Integer;
begin
  if HasChildNodes then
    Index := FChildNodes.IndexOf(OldChild)
  else
    Index := -1;

  if Index > -1 then
  begin
    Result := OldChild;
    FChildNodes.Insert(Index, NewChild);
    FChildNodes.Remove(OldChild);
  end
  else
    raise EXMLException.CreateParseError(NOT_FOUND_ERR, MSG_E_NOTEXT, ['Child not found.']);
end;

procedure TXMLNode.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
begin
  // do nothing
end;

procedure TXMLNode.InternalWriteToStream(const OutputStream: IUnicodeStream);
var
  i: Integer;
begin
  if HasChildNodes then
  begin
    // 2002-12-17 (mr): fixed indentation
    OutputStream.IncreaseIndent;
    for i := 0 to FChildNodes.Length - 1 do
      (FChildNodes.Item[i]).WriteToStream(OutputStream);
    // 2002-12-17 (mr): fixed indentation
    OutputStream.DecreaseIndent;
  end;
end;

procedure TXMLNode.WriteToStream(const OutputStream: IUnicodeStream);
begin
  InternalWriteToStream(OutputStream);
end;

function TXMLNode.GetXML: XmlString;
var
  Stream: TMemoryStream;
  US: IUnicodeStream;
begin
  US := nil;
  Stream := TMemoryStream.Create;
  try
    US := TXMLTextStream.Create(Stream, smWrite, TEncoding.OWideStringEncoding, False);

    InternalWriteToStream(US);
    US := nil;//(op) MUST BE HERE -> FLUSH BUFFER
    SetLength(Result, Stream.Size div SizeOf(XmlChar));
    if Stream.Size > 0 then
    begin
      Stream.Position := 0;
      Stream.ReadBuffer(PXmlChar(Result)^, Stream.Size);
    end;
  finally
    Stream.Free;
  end;
end;

function TXMLNode.GetText: XmlString;
var
  i: Integer;
begin
  Result := '';

  if HasChildNodes then
  begin
    i := 0;
    while i < FChildNodes.Length do
    begin
      // 2002-12-20 (mr): GetText is now using recursion
      Result := Result + FChildNodes.Item[i].Text;
      Inc(i);
    end;
  end;
  if FOwnerDocument.PreserveWhiteSpace then
    Result := Result + Self.NodeValue
  else
    Result := Result + ShrinkWhitespace(Self.NodeValue);
end;

procedure TXMLNode.SetText(const Value: XmlString);
var
  TextNode: TXMLText;
begin
  ClearChildNodes;

  // adding pure text - no parsing needed
  if Value <> '' then
  begin
    TextNode := TXMLText.Create(FOwnerDocument, Value);
    AppendChild(TextNode);
  end;
end;

procedure TXMLNode.SelectNodes(Pattern: string; var Result: IXMLNodeList);
begin
  Result := XPathSelect(Self, Pattern);
end;

function TXMLNode.SelectNodes(Pattern: string): IXMLNodeList;
begin
  SelectNodes(Pattern, Result);
end;

procedure TXMLNode.SelectSingleNode(Pattern: string; var Result: IXMLNode);
var
  NodeList: IXMLNodeList;
begin
  NodeList := XPathSelect(Self, Pattern);
  if NodeList.Length > 0 then
  begin
    while NodeList.Length > 2 do
      NodeList.Remove(NodeList.Item[NodeList.Length - 1]);
    Result := NodeList.Item[0];
  end
  else
    Result := nil;
end;

function TXMLNode.SelectSingleNode(Pattern: string): IXMLNode;
begin
  SelectSingleNode(Pattern, Result);
end;

procedure TXMLNode.SetCachedNodeIndex(const Index: integer);
begin
  if Index >= 0
     then FCachedNodeIndex := Index
     else FCachedNodeIndex := -1;
end;

{ TODO -omr : re-add after IXMLDocumentType will be properly supported }
(*
{ TXMLDocumentType }

function TXMLDocumentType.GetEntities: IXMLNamedNodeMap;
begin
  Assert(False, 'NYI - getEntities');
end;

function TXMLDocumentType.GetName: XmlString;
begin
  Assert(False, 'NYI - getName');
end;

function TXMLDocumentType.GetNotations: IXMLNamedNodeMap;
begin
  Assert(False, 'NYI - getNotations');
end;
*)

{ TXMLElement }

constructor TXMLElement.CreateElement(const OwnerDocument: TXMLDocument; const tagName: XmlString);
begin
  inherited Create(OwnerDocument);
  SetTagName(tagName);
  FNodeType := ELEMENT_NODE;
end;

function TXMLElement.GetAttribute(const Name: XmlString): XmlString;
var
  Attr: IXMLAttr;
begin
  Attr := GetAttributeNode(Name);
  if Attr <> nil then
    Result := Attr.Value
  else
    Result := '';
end;

function TXMLElement.GetAttributeNode(const Name: XmlString): IXMLAttr;
var
  i: Integer;
begin
  Result := nil;
  if not HasAttributes then
    Exit;

  i := 0;
  while i < Attributes.Length do
  begin
    if Attributes.Item[i].NodeName = Name then
    begin
      Result := Attributes.Item[i] as IXMLAttr;
      Exit;
    end;
    Inc(i);
  end;
end;

function TXMLElement.GetElementsByTagName(const Name: XmlString): IXMLNodeList;
  procedure InternalGetElementsByTagName(const Node: IXMLNode);
  var
    i: Integer;
    ChildNode: IXMLNode;
  begin
    if Node.HasChildNodes then
    begin
      for i := 0 to Node.ChildNodes.Length - 1 do
      begin
        ChildNode := Node.ChildNodes.Item[i];
        if (ChildNode.NodeType = ELEMENT_NODE) and ((ChildNode as IXMLElement).NodeName = Name) then
          Result.AddNode(ChildNode);
        InternalGetElementsByTagName(ChildNode);
      end;
    end;
  end;
begin
  Result := TXMLNodeList.Create;
  InternalGetElementsByTagName(Self);
end;

function TXMLElement.GetNodeName: XmlString;
begin
  Result := GetTagName;
end;

function TXMLElement.GetTagName: XmlString;
begin
  Result := Dictionary.Get(FTagNameId);
end;

procedure TXMLElement.SetTagName(const TagName: XmlString);
begin
  FTagNameId := Dictionary.Add(TagName);
end;

procedure TXMLElement.Normalize;
begin
  Assert(False, 'NYI - Normalize');
end;

procedure TXMLElement.RemoveAttribute(const Name: XmlString);
begin
  Assert(False, 'NYI - RemoveAttribute');
end;

function TXMLElement.RemoveAttributeNode(const OldAttr: IXMLAttr): IXMLAttr;
begin
  Assert(False, 'NYI - RemoveAttributeNode');
end;

procedure TXMLElement.InternalWriteToStream(const OutputStream: IUnicodeStream);
var
  i: Integer;
begin
  // 2002-12-17 (mr): fixed indentation
  OutputStream.WriteIndent;
  OutputStream.WriteString('<' + NodeName);

  if HasAttributes then
  begin
    for i := 0 to Attributes.Length - 1 do
      Attributes.Item[i].WriteToStream(OutputStream);
  end;

  if not HasChildNodes then
  begin
    if OutputStream.OutputFormat = ofIndent then
      OutputStream.WriteString(' ');
    OutputStream.WriteString('/>');
    Exit;
  end;

  OutputStream.WriteString('>');
  inherited;

  if HasChildNodes and (not ((ChildNodes.Length = 1) and (ChildNodes.Item[0].NodeType = TEXT_NODE))) then
    OutputStream.WriteIndent;

  OutputStream.WriteString('</' + NodeName + '>');
end;

procedure TXMLElement.SetAttribute(const Name, Value: XmlString);
var
  Attr: IXMLAttr;
begin
  Attr := FOwnerDocument.InternalCreateAttribute(Name);
  Attr.Value := Value;
  Attributes.SetNamedItem(Attr);
end;

function TXMLElement.SetAttributeNode(const NewAttr: IXMLAttr): IXMLAttr;
begin
  Assert(False, 'NYI - SetAttributeNode');
end;

procedure TXMLElement.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
type
  TParserState = (psName, psAttr, psEndTag);
var
  _nodeAttr: TXMLAttr;
  ReadChar: XmlChar;
  PState: TParserState;
begin
  // [40] STag ::= '<' Name (S Attribute)* S? '>'
  PState := psName;
  // read next available character
  while InputStream.ProcessChar(ReadChar) do
  begin
    case PState of
      psName:
        if CharIs_WhiteSpace(ReadChar) then
        begin
          SetTagName(InputStream.GetOutputBuffer);
          PState := psAttr;  // switch to an attribute name
        end
        else
        begin
          case ReadChar of
            '/':
              begin
                SetTagName(InputStream.GetOutputBuffer);
                PState := psEndTag;
              end;
            '>':
              begin
                SetTagName(InputStream.GetOutputBuffer);
                // write to list of unclosed nodes
                FOwnerDocument.UnclosedElementList.Add(Self);
                // recursively read subnodes
                FOwnerDocument.ReadFromStream(Self, InputStream);
                Break;
              end;
          else
            // [4] NameChar
            if CharIs_NameChar(ReadChar) then
              InputStream.WriteOutputChar(ReadChar)
            else
              raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADNAMECHAR, []);
          end;
        end;
      psAttr:
        if not CharIs_WhiteSpace(ReadChar) then
        begin
          case ReadChar of
            '/': PState := psEndTag;
            '>':
              begin
                // write to list of unclosed nodes
                FOwnerDocument.UnclosedElementList.Add(Self);
                // recursively read subnodes
                FOwnerDocument.ReadFromStream(Self, InputStream);
                Break;
              end;
          else
            // [41] Attribute
            // [5] Name
            if CharIs_Letter(ReadChar) or (ReadChar = '_') then
            begin
              InputStream.ClearOutputBuffer;
              InputStream.WriteOutputChar(ReadChar);
              _nodeAttr := FOwnerDocument.InternalCreateAttribute('');
              Attributes.SetNamedItem(_nodeAttr);
              _nodeAttr.SetParentNode( Self );
              _nodeAttr.ReadFromStream(Self, InputStream);
            end
            else
              raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADSTARTNAMECHAR, []);
          end;
        end;
      psEndTag:
        // [44] EmptyElemTag
        begin
          if ReadChar = '>' then
            Break
          else if CharIs_WhiteSpace(ReadChar) then
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_UNEXPECTED_WHITESPACE, [])
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_EXPECTINGTAGEND, []);
        end;
    end;
  end;

  if ReadChar <> '>' then
    raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_UNCLOSEDSTARTTAG, []);
end;

{ TXMLProcessingInstruction }

constructor TXMLProcessingInstruction.CreateProcessingInstruction(const OwnerDocument: TXMLDocument; const Target, Data: XmlString);
begin
  inherited Create(OwnerDocument);
  FNodeType := PROCESSING_INSTRUCTION_NODE;
  FTarget := Target;
  SetData(Data);
end;

function TXMLProcessingInstruction.GetData: XmlString;
begin
  Result := FData;
end;

function TXMLProcessingInstruction.GetNodeName: XmlString;
begin
  Result := FTarget;
end;

procedure TXMLProcessingInstruction.SetData(Data: XmlString);
begin
  FData := Data;
end;

function TXMLProcessingInstruction.GetTarget: XmlString;
begin
  Result := FTarget;
end;

procedure TXMLProcessingInstruction.InternalWriteToStream(const OutputStream: IUnicodeStream);
begin
  // 2002-12-17 (mr): fixed indentation
  OutputStream.WriteIndent;
  OutputStream.WriteString('<?' + NodeName + ' ' + FData + '?>');
end;

procedure TXMLProcessingInstruction.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
type
  TParserState = (psTarget, psInTarget, psWaitForData, psData, psEndData);
var
  ReadChar: XmlChar;
  PState: TParserState;
  Encoding: TEncoding;
  _xmlDoc: IXMLDocument;
begin
  // [16] PI ::= '<?' PITarget (S (Char* - (Char* '?>' Char*)))? '?>'
  PState := psTarget;
  // read next available character
  while InputStream.ProcessChar(ReadChar) do
  begin
    case PState of
      psTarget:
        begin
          // [17] PITarget ::= Name - (('X' | 'x') ('M' | 'm') ('L' | 'l')) 
          if CharIs_Name(ReadChar, True) then
          begin
            InputStream.WriteOutputChar(ReadChar);
            PState := psInTarget;
          end
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADSTARTNAMECHAR, []);
        end;
      psInTarget:
        begin
          // [17] PITarget ::= Name - (('X' | 'x') ('M' | 'm') ('L' | 'l'))
          if CharIs_WhiteSpace(ReadChar) then
          begin
            FTarget := InputStream.GetOutputBuffer;
            if SameText(FTarget, 'xml') and (not Supports(Parent as IXMLNode, IXMLDocument, _xmlDoc)) then
              raise EXMLException.CreateParseError(HIERARCHY_REQUEST_ERR, MSG_E_BADXMLDECL, []);
            PState := psWaitForData;
          end
          else if CharIs_NameChar(ReadChar) then
            InputStream.WriteOutputChar(ReadChar)
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADNAMECHAR, []);
        end;
      psWaitForData:
        if not CharIs_WhiteSpace(ReadChar) then
        begin
          if ReadChar = '?' then
            PState := psEndData
          else
          begin
            InputStream.WriteOutputChar(ReadChar);
            PState := psData;
          end;
        end;
      psData:
        if ReadChar = '?' then
          PState := psEndData
        else if CharIs_Char(ReadChar) then
          InputStream.WriteOutputChar(ReadChar)
        else
          raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADNAMECHAR, []);
      psEndData:
        begin
          if ReadChar = '>' then
          begin
            SetData(InputStream.GetOutputBuffer);
            if not InputStream.BOMFound and FindEncoding(Self, Encoding) then//(op): DO NOT CHANGE ENCODING IF BOM WAS FOUND!!!
            begin
              if (InputStream.Encoding.EncodingCodePage <> Encoding.EncodingCodePage) then
              begin
                InputStream.Encoding := Encoding;
                FOwnerDocument.ClearChildNodes;
              end
              else
              if Assigned(Encoding) and not TEncoding.IsStandardEncoding(Encoding) then
              Encoding.Free;
            end;
            Exit;
          end
          else
          begin
            // it was a false alert - both characters are part of PI
            InputStream.WriteOutputChar('?');
            InputStream.WriteOutputChar(ReadChar);
            // read more
            PState := psData;
          end;
        end;
    end;
  end;
end;

{ TXMLAttr }

constructor TXMLAttr.CreateAttr(const OwnerDocument: TXMLDocument; const Name: XmlString);
begin
  inherited Create(OwnerDocument);
  SetName(Name);
  FNodeType := ATTRIBUTE_NODE;
  FSpecified := True;
end;

procedure TXMLAttr.SetName(const Value: XmlString);
begin
  FNameId := Dictionary.Add(Value);
end;

procedure TXMLAttr.SetNodeValue(const Value: XmlString);
begin
  FNodeValueId := Dictionary.Add(Value);
end;

function TXMLAttr.GetName: XmlString;
begin
  if FNameId <> CInvalidDicId then
    Result := Dictionary.Get(FNameId)
  else
    Result := '';
end;

function TXMLAttr.GetNodeName: XmlString;
begin
  Result := GetName;
end;

function TXMLAttr.GetSpecified: Boolean;
begin
  Result := FSpecified;
end;

function TXMLAttr.GetText: XmlString;
begin
  // same as nodeValue except the leading and trailing white space is trimmed
  // 2002-12-20 (mr): added checking of PreserveWhiteSpace property
  if FOwnerDocument.PreserveWhiteSpace then
    Result := NodeValue
  else
    Result := ShrinkWhitespace(NodeValue);
end;

function TXMLAttr.GetValue: XmlString;
begin
  Result := NodeValue;
end;

procedure TXMLAttr.SetValue(const Value: XmlString);
begin
  NodeValue := Value;
end;

procedure TXMLAttr.InternalWriteToStream(const OutputStream: IUnicodeStream);
begin
  OutputStream.WriteString(' ' + NodeName + '="' + EncodeText(NodeValue) + '"');
end;

procedure TXMLAttr.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
type
  TParserState = (psName, psBeforeEqual, psValue, psInValue);
  TAttrValueDelimiter = (avdNone, avdSingle, avdDouble);
var
  ReadChar: XmlChar;
  PState: TParserState;
  AttrValueDelimiter: TAttrValueDelimiter;
begin
  // [41] Attribute ::= Name Eq AttValue
  // [5] Name ::= (Letter | '_' | ':') (NameChar)*  
  // [25] Eq ::= S? '=' S?
  // [10] AttValue ::= '"' ([^<&"] | Reference)* '"' | "'" ([^<&'] | Reference)* "'"

  PState := psName;
  AttrValueDelimiter := avdNone;
  // read next available character
  while InputStream.ProcessChar(ReadChar) do
  begin
    case PState of
      psName:
        if CharIs_WhiteSpace(ReadChar) then
        begin
          SetName(InputStream.GetOutputBuffer);
          PState := psBeforeEqual;
        end
        else if ReadChar = '=' then
        begin
          SetName(InputStream.GetOutputBuffer);
          PState := psValue;
        end
        else
        begin
          // [4] NameChar
          if CharIs_NameChar(ReadChar) then
            InputStream.WriteOutputChar(ReadChar)
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADNAMECHAR, []);
        end;
      psBeforeEqual:
        if not CharIs_WhiteSpace(ReadChar) then
        begin
          if ReadChar = '=' then
            PState := psValue
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_MISSINGEQUALS, []);
        end;
      psValue:
        if not CharIs_WhiteSpace(ReadChar) then
        begin
          case ReadChar of
            '''', '"':  // [10] AttValue
              begin
                PState := psInValue;
                if ReadChar = '''' then
                  AttrValueDelimiter := avdSingle
                else
                  AttrValueDelimiter := avdDouble;
              end;
          else
            raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_MISSINGQUOTE, []);
          end;
        end;
      psInValue:
        // [10] AttValue
        case ReadChar of
          '''': if AttrValueDelimiter = avdSingle then
            begin
              NodeValue := InputStream.GetOutputBuffer;
              Exit;
            end
            else
              InputStream.WriteOutputChar(ReadChar);
          '"': if AttrValueDelimiter = avdDouble then
            begin
              NodeValue := InputStream.GetOutputBuffer;
              Exit;
            end
            else
              InputStream.WriteOutputChar(ReadChar);
          '<': raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADCHARINSTRING, []);
          '&': InputStream.WriteOutputChar(Reference2Char(InputStream));
        else
          InputStream.WriteOutputChar(ReadChar);
        end;
    end;
  end;
end;

{ TXMLCharacterData }

constructor TXMLCharacterData.CreateCharacterData(const OwnerDocument: TXMLDocument; const Data: XmlString);
begin
  inherited Create(OwnerDocument);
  NodeValue := Data;
end;

procedure TXMLCharacterData.SetNodeValue(const Value: XmlString);
begin
  // 2003-02-22 (mr): apply EOL handling when setting NodeValue
  FNodeValue := ShrinkEol(Value);
end;

function TXMLCharacterData.GetNodeValue: XmlString;
begin
  Result := FNodeValue;
end;

procedure TXMLCharacterData.AppendData(const Arg: XmlString);
begin
  Assert(False, 'NYI - AppendData');
end;

procedure TXMLCharacterData.DeleteData(const Offset, Count: Integer);
begin
  Assert(False, 'NYI - DeleteData');
end;

function TXMLCharacterData.GetData: XmlString;
begin
  Result := NodeValue;
end;

function TXMLCharacterData.GetLength: Integer;
begin
  Result := System.Length(NodeValue);
end;

procedure TXMLCharacterData.InsertData(const Offset: Integer; const Arg: XmlString);
begin
  Assert(False, 'NYI - InsertData');
end;

procedure TXMLCharacterData.ReplaceData(const Offset, Count: Integer; const Arg: XmlString);
begin
  Assert(False, 'NYI - ReplaceData');
end;

procedure TXMLCharacterData.SetData(const Value: XmlString);
begin
  NodeValue := Value;
end;

function TXMLCharacterData.substringData(const Offset, Count: Integer): XmlString;
begin
  Assert(False, 'NYI - SubstringData');
end;

procedure TXMLCharacterData.InternalWriteToStream(const OutputStream: IUnicodeStream);
begin
  // 2003-01-13 (mr): call inherited to include any child nodes
  inherited;
  OutputStream.WriteString(EncodeText(ExpandEol(NodeValue)));
end;

procedure TXMLCharacterData.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
begin
  // do nothing
end;

{ TXMLText }

constructor TXMLText.Create(const OwnerDocument: TXMLDocument; const Data: XmlString);
begin
  inherited CreateCharacterData(OwnerDocument, Data);
  FNodeType := TEXT_NODE;
end;

function TXMLText.GetNodeName: XmlString;
begin
  Result := '#text';
end;

procedure TXMLText.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
type
  TParserState = (psText);
var
  ReadChar: XmlChar;
  PState: TParserState;
begin
  // [43] content ::= CharData? ((element | Reference | CDSect | PI | Comment) CharData?)* /* */ 
  // [14] CharData ::= [^<&]* - ([^<&]* ']]>' [^<&]*)
  PState := psText;
  // read next available character
  while InputStream.ProcessChar(ReadChar) do
  begin
    case PState of
      psText:
        case ReadChar of
          '<':
            begin
              InputStream.UndoRead;
              // 2002-12-20 (mr): speed optimization
              // add #text node only when some text exists
              if InputStream.OutputBufferLen > 0 then
              begin
                if not FOwnerDocument.PreserveWhiteSpace then
                  NodeValue := ShrinkWhitespace(NodeValue + InputStream.GetOutputBuffer)
                else
                  NodeValue := NodeValue + InputStream.GetOutputBuffer;
                if NodeValue = '' then
                  Parent.RemoveChild(Self);
              end
              else
                Parent.RemoveChild(Self);
              Exit;
            end;
          '&': InputStream.WriteOutputChar(Reference2Char(InputStream));
        else
          InputStream.WriteOutputChar(ReadChar);
        end;
    end;
  end;
end;

function TXMLText.SplitText(const Offset: Integer): IXMLText;
begin
  Assert(False, 'NYI - SplitText');
end;

{ TXMLCDATASection }

constructor TXMLCDATASection.CreateCDATASection(const OwnerDocument: TXMLDocument; const Data: XmlString);
begin
  CheckValue(Data);
  inherited CreateCharacterData(OwnerDocument, Data);
  FNodeType := CDATA_SECTION_NODE;
end;

function TXMLCDATASection.GetNodeName: XmlString;
begin
  Result := '#cdata-section';
end;

procedure TXMLCDATASection.CheckValue(const Value: XmlString);
begin
  if Pos(XmlString(']]>'), Value) > 0 then
    raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_INVALID_CDATACLOSINGTAG, []);
end;

procedure TXMLCDATASection.SetNodeValue(const Value: XmlString);
begin
  CheckValue(Value);
  // 2003-02-22 (mr): there is no EOL handling for CDATA element
  FNodeValue := Value;
end;

procedure TXMLCDATASection.InternalWriteToStream(const OutputStream: IUnicodeStream);
begin
  // 2002-12-17 (mr): fixed indentation
  OutputStream.WriteIndent(True);
  OutputStream.WriteString('<![CDATA[' + NodeValue + ']]>');
end;

procedure TXMLCDATASection.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
type
  TParserState = (psData, psInEnd, psEnd);
var
  ReadChar: XmlChar;
  PState: TParserState;
begin
  PState := psData;
  // read next available character
  while InputStream.ProcessChar(ReadChar) do
  begin
    case PState of
      psData:
        if ReadChar = ']' then
          PState := psInEnd
        else
          InputStream.WriteOutputChar(ReadChar);
      psInEnd:
        if ReadChar = ']' then
          PState := psEnd
        else
        begin
          InputStream.WriteOutputChar(']');  // 2004-04-07 (mr): fixed bug
          InputStream.WriteOutputChar(ReadChar);
          PState := psData;
        end;
      psEnd:
        if ReadChar = '>' then
        begin
          NodeValue := InputStream.GetOutputBuffer;
          Exit;
        end
        else
        begin
          InputStream.WriteOutputChar(ReadChar);
          if ReadChar = ']' then
            PState := psEnd
          else
            PState := psData;
        end;
    end;
  end;
end;

procedure TXMLCDATASection.SetData(const Value: XmlString);
begin
  CheckValue(Value);
  inherited;
end;

{ TXMLComment }

constructor TXMLComment.CreateComment(const OwnerDocument: TXMLDocument; const Data: XmlString);
begin
  inherited CreateCharacterData(OwnerDocument, Data);
  FNodeType := COMMENT_NODE;
end;

function TXMLComment.GetNodeName: XmlString;
begin
  Result := '#comment';
end;

procedure TXMLComment.InternalWriteToStream(const OutputStream: IUnicodeStream);
begin
  // 2002-12-17 (mr): fixed indentation
  OutputStream.WriteIndent(True);
  OutputStream.WriteString('<!--' + ExpandEol(NodeValue) + '-->');
end;

procedure TXMLComment.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
type
  TParserState = (psData, psInEnd, psEnd);
var
  ReadChar: XmlChar;
  PState: TParserState;
begin
  PState := psData;
  // read next available character
  while InputStream.ProcessChar(ReadChar) do
  begin
    case PState of
      psData:
        if ReadChar = '-' then
          PState := psInEnd
        else
          InputStream.WriteOutputChar(ReadChar);
      psInEnd:
        if ReadChar = '-' then
          PState := psEnd
        else
        begin
          InputStream.WriteOutputChar('-');  // 2004-04-07 (mr): fixed bug
          InputStream.WriteOutputChar(ReadChar);
          PState := psData;
        end;
      psEnd:
        if ReadChar = '>' then
        begin
          NodeValue := InputStream.GetOutputBuffer;
          Exit;
        end;
        else
        begin
          InputStream.WriteOutputChar(ReadChar);
          PState := psData;
        end;
    end;
  end;
end;

{ TXMLDocumentType }

constructor TXMLDocumentType.CreateDocumentType(const OwnerDocument: TXMLDocument;
  const Data: XmlString);
begin
  inherited CreateCharacterData(OwnerDocument, Data);
  FNodeType := DOCUMENT_TYPE_NODE;
end;

function TXMLDocumentType.GetNodeName: XmlString;
begin
  Result := '#doctype';
end;

procedure TXMLDocumentType.InternalWriteToStream(
  const OutputStream: IUnicodeStream);
begin
  OutputStream.WriteIndent;
  OutputStream.WriteString('<!DOCTYPE ' + NodeValue + '>');
end;

procedure TXMLDocumentType.ReadFromStream(const Parent: TXMLNode;
  const InputStream: IUnicodeStream);
type
  TParserState = (psData, psInString);
var
  BracketDepth: Integer;
  EndOfString: XmlChar;
  PState: TParserState;
  ReadChar: XmlChar;
  SkipInitialSpace: Boolean;
begin
  BracketDepth := 0;
  EndOfString := #0; // to keep Delphi happy
  SkipInitialSpace := True;
  PState := psData;
  // read next available character
  while InputStream.ProcessChar(ReadChar) do
  begin
    case PState of
      psData:
        begin
          if SkipInitialSpace then
          begin
            if CharIs_WhiteSpace(ReadChar) then
              continue
            else
              SkipInitialSpace := False;
          end;
          if (ReadChar = '>') and (BracketDepth <= 0) then
          begin
            NodeValue := InputStream.GetOutputBuffer;
            Exit;
          end
          else
          begin
            InputStream.WriteOutputChar(ReadChar);
            if ReadChar = '[' then
              Inc(BracketDepth)
            else if ReadChar = ']' then
              Dec(BracketDepth)
            else if (ReadChar = '"') or (ReadChar = '''') then
            begin
              PState := psInString;
              EndOfString := ReadChar;
            end;
          end;
        end; //psData
      psInString:
        begin
          InputStream.WriteOutputChar(ReadChar);
          if ReadChar = EndOfString then
            PState := psData;
        end; //psInString
    end; //case
  end;
end;

{ TXMLDocumentFragment }

constructor TXMLDocumentFragment.Create(const OwnerDocument: TXMLDocument);
begin
  inherited Create(OwnerDocument);
  FNodeType := DOCUMENT_FRAGMENT_NODE;
end;

function TXMLDocumentFragment.GetNodeName: XmlString;
begin
  Result := '#document-fragment';
end;

procedure TXMLDocumentFragment.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
begin
{ TODO -omr : choose better - Self or Parent }
  FOwnerDocument.ReadFromStream(Self, InputStream);
end;

{ TXMLDocument }

constructor TXMLDocument.Create;
begin
  inherited Create(Self);

  Dictionary := TDictionary.Create;

  FNodeType := DOCUMENT_NODE;
  FParseError := TXMLParseError.Create;
  FIParseError := FParseError as IXMLParseError;

  // unlike MS XML parser, we want all characters preserved
  FPreserveWhiteSpace := True;

  // define XML child classes
  FXMLAttrClass := TXMLAttr;
  FXMLCDATASectionClass := TXMLCDATASection;
  FXMLCommentClass := TXMLComment;
  FXMLDocTypeClass := TXMLDocumentType;
  FXMLElementClass := TXMLElement;
  FXMLProcessingInstructionClass := TXMLProcessingInstruction;
  FXMLTextClass := TXMLText;

  UnclosedElementList := TInterfaceList.Create;
end;

destructor TXMLDocument.Destroy;
begin
  UnclosedElementList.Free;
  FIParseError := nil;
  FreeAndNil(Dictionary);
  inherited;
end;

function TXMLDocument.GetDocumentElement: IXMLElement;
var
  i: Integer;
begin
  Result := nil;
  if HasChildNodes then
  begin
    i := 0;
    while (Result = nil) and (i < ChildNodes.Length) do
    begin
      if not Supports(ChildNodes.Item[i], IXMLElement, Result) then
        Inc(i);
    end;
  end;
end;

procedure TXMLDocument.SetDocumentElement(const Value: IXMLElement);
var
  i: Integer;
begin
  if HasChildNodes then
  begin
    i := 0;
    while i < ChildNodes.Length do
    begin
      if ChildNodes.Item[i].NodeType = ELEMENT_NODE then
      begin
        // insert new element
        ChildNodes.Insert(i, Value);
        // delete old
        ChildNodes.Delete(i + 1);
        Exit;
      end;
      Inc(i);
    end;
  end;

  // old document element was not found, so add new
  AppendChild(Value);
end;

function TXMLDocument.GetPreserveWhiteSpace: Boolean;
begin
  Result := FPreserveWhiteSpace;
end;

procedure TXMLDocument.SetPreserveWhiteSpace(const Value: Boolean);
begin
  FPreserveWhiteSpace := Value;
end;

function TXMLDocument.GetParseError: IXMLParseError;
begin
  Result := FParseError as IXMLParseError;
end;

function TXMLDocument.GetDocType: IXMLDocumentType;
begin
  Result := FDocType;
end;

{ TODO -omr : re-add after IXMLDocumentType will be properly supported }
(*
procedure TXMLDocument.SetDocType(const Value: IXMLDocumentType);
begin
  FDocType := Value;
end;
*)

function TXMLDocument.InternalCreateAttribute(const Name: XmlString): TXMLAttr;
begin
  Result := FXMLAttrClass.CreateAttr(Self, Name);
end;

function TXMLDocument.CreateAttribute(const Name: XmlString): IXMLAttr;
begin
  Result := InternalCreateAttribute(Name);
end;

function TXMLDocument.InternalCreateCDATASection(const Data: XmlString): TXMLCDATASection;
begin
  // 2003-01-13 (mr): calling CreateCDATASection instead CreateCharacterData
  Result := FXMLCDATASectionClass.CreateCDATASection(Self, Data);
end;

function TXMLDocument.CreateCDATASection(const Data: XmlString): IXMLCDATASection;
begin
  Result := InternalCreateCDATASection(Data);
end;

function TXMLDocument.InternalCreateComment(const Data: XmlString): TXMLComment;
begin
  Result := FXMLCommentClass.CreateComment(Self, Data);
end;

function TXMLDocument.CreateComment(const Data: XmlString): IXMLComment;
begin
  Result := InternalCreateComment(Data);
end;

function TXMLDocument.InternalCreateDocType(const Data: XmlString): TXMLDocumentType;
begin
  Result := FXMLDocTypeClass.CreateDocumentType(Self, Data);
end;

function TXMLDocument.CreateDocType(const Data: XmlString): IXMLDocumentType;
begin
  FDocType := InternalCreateDocType(Data);
  Result := FDocType;
end;

function TXMLDocument.InternalCreateDocumentFragment: TXMLDocumentFragment;
begin
  Result := TXMLDocumentFragment.Create(Self);
end;

function TXMLDocument.CreateDocumentFragment: IXMLDocumentFragment;
begin
  Result := InternalCreateDocumentFragment;
end;

function TXMLDocument.InternalCreateElement(const TagName: XmlString): TXMLElement;
begin
  Result := FXMLElementClass.CreateElement(Self, TagName);
end;

function TXMLDocument.CreateElement(const TagName: XmlString): IXMLElement;
begin
  Result := InternalCreateElement(TagName);
end;

function TXMLDocument.InternalCreateEntityReference(const Name: XmlString): TXMLEntityReference;
begin
  Assert(False, 'NYI - CreateEntityReference');
  Result := nil;
end;

function TXMLDocument.CreateEntityReference(const Name: XmlString): IXMLEntityReference;
begin
  Result := InternalCreateEntityReference(Name);
end;

function TXMLDocument.InternalCreateProcessingInstruction(const Target, Data: XmlString): TXMLProcessingInstruction;
begin
  Result := FXMLProcessingInstructionClass.CreateProcessingInstruction(Self, Target, Data);
end;

function TXMLDocument.CreateProcessingInstruction(const Target, Data: XmlString): IXMLProcessingInstruction;
begin
  Result := InternalCreateProcessingInstruction(Target, Data);
end;

function TXMLDocument.InternalCreateTextNode(const Data: XmlString): TXMLText;
begin
  Result := FXMLTextClass.Create(Self, Data);
end;

function TXMLDocument.CreateTextNode(const Data: XmlString): IXMLText;
begin
  Result := InternalCreateTextNode(Data);
end;

function TXMLDocument.GetText: XmlString;
var
  TempDocElement: IXMLElement;
begin
  TempDocElement := DocumentElement;
  if TempDocElement <> nil then
    Result := TempDocElement.Text
  else
    Result := '';
end;

function TXMLDocument.GetOwnerDocument: IXMLDocument;
begin
  // 2003-01-13 (mr): overriden for DOM compatibility
  Result := nil;
end;

function TXMLDocument.GetElementsByTagName(const TagName: XmlString): IXMLNodeList;
var
  TempDocElement: IXMLElement;
begin
  TempDocElement := DocumentElement;
  if TempDocElement = nil then
    Result := TXMLNodeList.Create
  else
    Result := TempDocElement.GetElementsByTagName(TagName);
end;

function TXMLDocument.GetNodeName: XmlString;
begin
  Result := '#document';
end;

function TXMLDocument.LoadXML(const XML: XmlString): Boolean;
var
  Stream: TMemoryStream;
  BOM: TEncodingBuffer;
begin
  Stream := TMemoryStream.Create;
  try
    BOM := TEncoding.OWideStringEncoding.GetBOM;
    Stream.Write(BOM[TEncodingBuffer_FirstElement], Length(BOM));
    Stream.Write(PXmlChar(XML)^, Length(XML) * SizeOf(XmlChar));
    Stream.Seek(0, soFromBeginning);
    Result := LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

function TXMLDocument.Load(const FileName: string): Boolean;
var
  MS: TMemoryStream;
begin
  FURL := FileName;
  MS := TMemoryStream.Create;
  try
    MS.LoadFromFile(FileName);
    Result := LoadFromStream(MS);
  finally
    MS.Free;
  end;
end;

function TXMLDocument.LoadFromStream(const Stream: TStream): Boolean;
var
  XTS: TXMLTextStream;
  xPreviousText, xNextText: XmlString;

  function GetUnclosedTags: XmlString;
  begin
    Result := '';
    while UnclosedElementList.Count > 0 do
    begin
      Result := Result + (UnclosedElementList[0] as IXMLElement).NodeName;
      UnclosedElementList.Delete(0);
      if UnclosedElementList.Count > 0 then
        Result := Result + ', ';
    end;
  end;
begin
  Result := True;
  ClearChildNodes;

  Stream.Position := 0;
  XTS := TXMLTextStream.Create(Stream, smRead, TEncoding.UTF8, False);
  try
    try
      UnclosedElementList.Clear;

      ReadFromStream(Self, XTS);

      if UnclosedElementList.Count > 0 then
        raise EXMLException.CreateParseError(HIERARCHY_REQUEST_ERR, MSG_E_UNCLOSEDTAG, [GetUnclosedTags]);
    except
      on E: Exception do
      begin
        if E is EXMLException then
        begin
          FParseError.SetErrorCode(EXMLException(E).XMLCode);
          FParseError.SetFilePos(XTS.FReader.FilePosition);
          FParseError.SetLine(XTS.FReader.Line);
          FParseError.SetLinePos(XTS.FReader.LinePosition);
          FParseError.SetReason(E.Message);
          xPreviousText := XTS.FReader.ReadPreviousString(30, True);
          xNextText := XTS.FReader.ReadString(10, True);
          FParseError.SetSrcText(xPreviousText, xNextText);//do not write ReadPreviousStringInLine() and ReadString() directly here because due to some Delphi optimizations, ReadString would be called first
          FParseError.SetURL(Self.FURL);

          ClearChildNodes;
          Result := False;
        end
        else
          raise;
      end;
    end;
  finally
    FreeAndNil(XTS);
    FURL := '';
  end;
end;

procedure TXMLDocument.InternalWriteToStream(const OutputStream: IUnicodeStream);
var
  i: Integer;
begin
  if HasChildNodes then
  begin
    // 2002-12-17 (mr): fixed indentation
    OutputStream.IncreaseIndent;
    for i := 0 to ChildNodes.Length - 1 do
    begin
      (ChildNodes.Item[i]).WriteToStream(OutputStream);
      if i < (ChildNodes.Length - 1) then
        OutputStream.WriteIndent(True);
    end;
    // 2002-12-17 (mr): fixed indentation
    OutputStream.DecreaseIndent;
  end;
end;

procedure TXMLDocument.SaveToStream(const OutputStream: TStream; const OutputFormat: TOutputFormat);
var
  US: TXMLTextStream;

  function InternalFindEncoding: TEncoding;
  var
    i: Integer;
    TempPI, PI: IXMLProcessingInstruction;
    Encoding: TEncoding;
  begin
    Result := TEncoding.UTF8;
    if HasChildNodes then
    begin
      // find last processing instruction
      for i := 0 to ChildNodes.Length - 1 do
      begin
        if Supports(ChildNodes.Item[i], IXMLProcessingInstruction, TempPI) then
          PI := TempPI;
      end;
    end;
    if (PI <> nil) and FindEncoding(PI, Encoding) then
      Result := Encoding;
  end;
begin
  US := TXMLTextStream.Create(OutputStream, smWrite, InternalFindEncoding, True);
  try
    US.OutputFormat := OutputFormat;
    InternalWriteToStream(US);
  finally
    US.Free;
  end;
end;

procedure TXMLDocument.Save(const FileName: string; const OutputFormat: TOutputFormat = ofNone);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(FileStream, OutputFormat);
  finally
    FileStream.Free;
  end;
end;

procedure TXMLDocument.ReadFromStream(const Parent: TXMLNode; const InputStream: IUnicodeStream);
type
  TParserState = (psTag, psTagName, psEndTagName, psCommentOrCDATAOrDoctype);
var
  _nodeCDATA: TXMLCDATASection;
  _nodeComment: TXMLComment;
  _nodeDocType: TXMLDocumentType;
  _nodeElement: TXMLElement;
  _nodePI: TXMLProcessingInstruction;
  _nodeText: TXMLText;
  EndTagName: XmlString;
  PState: TParserState;
  ReadChar: XmlChar;
  Text: XmlString;
begin
  PState := psTag;

  // read next available character
  while InputStream.ProcessChar(ReadChar) do
  begin
    case PState of
      psTag:
        if ReadChar = '<' then
          PState := psTagName  // waiting for a tag name
        else
        begin
          InputStream.UndoRead;
          _nodeText := InternalCreateTextNode('');
          Parent.AppendChild(_nodeText);
          _nodeText.ReadFromStream(Parent, InputStream);
        end;
      psTagName:  // one-time stop
        if not CharIs_WhiteSpace(ReadChar) then
        begin
          case ReadChar of
            '?':
              begin
                _nodePI := InternalCreateProcessingInstruction('', '');
                Parent.AppendChild(_nodePI);
                _nodePI.ReadFromStream(Parent, InputStream);
                PState := psTag;
              end;
            '!': PState := psCommentOrCDATAOrDoctype;  // not enough info, check also next char
            '/': PState := psEndTagName;
          else
            // [40] STag
            // [5] Name
            if CharIs_Letter(ReadChar) or (ReadChar = '_') then
            begin
              // it's an element
              InputStream.WriteOutputChar(ReadChar);
              _nodeElement := InternalCreateElement('');
              Parent.AppendChild(_nodeElement);
              _nodeElement.ReadFromStream(Parent, InputStream);
              PState := psTag;
            end
            else
              raise EXMLException.CreateParseError(INVALID_CHARACTER_ERR, MSG_E_BADSTARTNAMECHAR, []);
          end;
        end;
      psEndTagName:
        // [42] ETag
        begin
          case ReadChar of
            '>':
              begin
                EndTagName := InputStream.GetOutputBuffer;
                if (EndTagName = Parent.NodeName) and (EndTagName = (UnclosedElementList[UnclosedElementList.Count - 1] as IXMLElement).NodeName) then
                begin
                  UnclosedElementList.Delete(UnclosedElementList.Count - 1);
                  Exit;
                end
                else
                  raise EXMLException.CreateParseError(HIERARCHY_REQUEST_ERR, MSG_E_ENDTAGMISMATCH, [EndTagName, Parent.NodeName]);
              end;
          else
            {'A'..'Z', 'a'..'z', '0'..'9':}
            InputStream.WriteOutputChar(ReadChar);
          end;
        end;
      psCommentOrCDATAOrDoctype:
        begin
          case ReadChar of
            '[':
              begin
                InputStream.GetNextString(Text, 6);
                if Text = 'CDATA[' then
                begin
                  InputStream.ClearOutputBuffer;
                  _nodeCDATA := InternalCreateCDATASection('');
                  Parent.AppendChild(_nodeCDATA);
                  _nodeCDATA.ReadFromStream(Parent, InputStream);
                  PState := psTag;
                end;
              end;
            '-':
              begin
                if InputStream.ProcessChar(ReadChar) and (ReadChar = '-') then
                begin
                  _nodeComment := InternalCreateComment('');
                  Parent.AppendChild(_nodeComment);
                  _nodeComment.ReadFromStream(Parent, InputStream);
                  PState := psTag;
                end
                else
                  raise Exception.CreateFmt('Invalid node %s', [InputStream.GetOutputBuffer]);
              end;
            'D':{OCTYPE}
              begin
                InputStream.GetNextString(Text, 6);
                if Text = 'OCTYPE' then
                begin
                  InputStream.ClearOutputBuffer;
                  _nodeDocType := InternalCreateDocType('');
                  Parent.AppendChild(_nodeDocType);
                  _nodeDocType.ReadFromStream(Parent, InputStream);
                  FDocType := _nodeDocType as IXMLDocumentType;
                  PState := psTag;
                end;
              end;
          end;
        end;
    end;
  end;

  if FChildNodes = nil then
    raise EXMLException.CreateParseError(0, MSG_E_MISSINGROOT, [])
end;

end.
